package com.newrelic.codingchallenge;
import java.io.*;  
import java.net.*;  

import java.net.ServerSocket;
import java.net.Socket;
import java.io.IOException;
import java.util.concurrent.ExecutorService; 
import java.util.concurrent.Executors; 
import java.util.concurrent.*;
import java.util.Timer;
import java.util.TimerTask;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import java.util.concurrent.locks.Lock; 
import java.util.concurrent.locks.ReentrantLock; 
import java.util.concurrent.ConcurrentHashMap;
import java.util.HashMap;
import java.util.Map;

import java.util.Date;
import java.time.ZonedDateTime;
import java.util.Calendar;

// Control class to keep numbers for 10 second activity and total unique.
// Synchronize setters, let getters go.
class Control {
  private static int report_unique_change = 0;
  private static int report_unique_total = 0;
  private static int report_duplicates = 0;
  private final Lock AddQueueLock = new ReentrantLock(); 
  private final Lock SearchQueueLock = new ReentrantLock();
  private static ConcurrentHashMap unumbers = new ConcurrentHashMap(); 
  private static boolean terminate = false;

  public boolean IsDuplicateNumber(String search_for){
     final Lock SearchLock = this.SearchQueueLock;
     if ( unumbers.containsValue(search_for ) ){
        SearchLock.lock();
        try{
           report_duplicates++;
           return true;
        }
        catch (Exception e) {
           e.printStackTrace(); 
        }
        finally{
           SearchLock.unlock();
        }
     }
     return false;
  }
  public boolean  get_terminate(){
     return terminate;
  }
  public void set_terminate(){
     terminate = true;
  }
  public int get_unique_total(){
     return report_unique_total;
  }
  public void add_number(String new_number){
     final Lock AddLock = this.AddQueueLock;
     try{
        AddLock.lock();
        unumbers.put(report_unique_total,new_number); 
        report_unique_total++;
        report_unique_change++;
     }
     catch (Exception e) {
         e.printStackTrace(); 
     }
     finally{
       AddLock.unlock(); 
     }
     // Write to file.
     BufferedWriter bw = null;
     try{
       File file = new File("/tmp/numbers.log");
       FileWriter fw = new FileWriter(file.getAbsoluteFile(), true);
       bw = new BufferedWriter(fw);
       bw.write(new_number);
       bw.write("\n");
       bw.close();
     }
     catch(IOException e){
       System.out.println("File Error ");
     }

  }
  public int get_unique(){
    return report_unique_change;
  }
  public synchronized void zero_unique_and_dups(){
    report_unique_change = 0;
    report_duplicates = 0;
  }
  public int get_dups(){
    return report_duplicates;
  }
}

// Main class sets up timer and listens to socket. 
// Create thread pool of 5 to ensure only 5 calls at a time are serviced.
public class Main {
Timer timer;
public static final int MAX_THREADS = 5;
public static final int SECONDS_REPORT = 10;

    public static void main(String[] args) throws InterruptedException {

       // Control class for synchronization
       Control control = new Control();

       // Create thread pool for processing client calls.
       ExecutorService executor = Executors.newFixedThreadPool(MAX_THREADS);

       // Create 10 second timer for online reporting.
       Timer timer = new Timer("Repeated Interval");
       TimerTask task = new TimerTask() {
           @Override
           public void run() {
               System.out.println("Received " + control.get_unique() + " unique numbers, " + control.get_dups() + " duplicates. Unique total: "+ control.get_unique_total());
               control.zero_unique_and_dups();
           }
       };
       long duration = 10000L;
       long delay= 10000L;
       timer.schedule(task, delay,duration);

       // Wipe out the file
       try{
           File file = new File("/tmp/numbers.log");
           if (file.exists()) 
                file.delete();
       }
       catch (Exception e){
          System.out.println("Problem killing file at startup");
          System.exit(1);
       }

       // try to listen on port 4000 and loop for client calls until "terminate" is sent.
       Calendar c1 = null;
       Date dateOne = null;
       long timeMilli = 0L;
       int loop_counter=0;
       InputStream input = null;
       BufferedReader reader = null;
       try ( ServerSocket listener = new ServerSocket(4000)) {
            System.out.println("The server is starting...");
            String NineDigitNumber = "Start";
            while (true) {
                try {
                    //c1 = Calendar.getInstance();
                    //dateOne = c1.getTime();
                    //timeMilli = dateOne.getTime();
                    //System.out.println("Socket loop Start. Time in ms:  "+timeMilli+", Loop counter: " +loop_counter);

                    Socket socket = listener.accept();
                    loop_counter++;

                    //c1 = Calendar.getInstance();
                    //dateOne = c1.getTime();
                    //timeMilli = dateOne.getTime();
                    //System.out.println("Socket loop Middle. Time in ms:  "+timeMilli+", Loop counter: " +loop_counter);

                    // Callable, return a future, submit and run the task async
                    //Future<Integer> futureTask1 = executor.submit(() -> {
                    //    System.out.println("I'm Callable task.");
                    //    return 1 + 1;
                    //});
                    //socket.close();

                    WorkerThread worker = new WorkerThread(control,socket);
                    CompletableFuture<Void> future = CompletableFuture.runAsync(worker,executor);  

                    // executor.execute(new WorkerThread(control,socket)  );

                    //if (executor instanceof ThreadPoolExecutor) 
                    //  System.out.println( "Pool size is now " + ((ThreadPoolExecutor) executor).getActiveCount() );

                    //c1 = Calendar.getInstance();
                    //dateOne = c1.getTime();
                    //timeMilli = dateOne.getTime();
                    //System.out.println("Socket loop end. Time in ms:  "+timeMilli+", Loop counter: " +loop_counter);

                    if (control.get_terminate())
                      break;
                }
                catch (Exception e){
                    if (control.get_terminate())
                       break;
                }
            }
            //  Clean up thread pool
            System.out.println("Terminating, please wait for final totals...");
            executor.shutdown();
            TimeUnit.SECONDS.sleep(11);
            timer.cancel();
        }
        catch (Exception e) {
               System.out.println("We have a problem Houston");
               System.out.println(e);
               e.printStackTrace();
        }
        System.exit(0);
    }
} // End Main class

//  Worker thread that checks input for being unique and writes to the file if it is.
class WorkerThread implements Runnable {

    private Socket socket;
    private Control control;
    
    private String NineDigitNumber="123456789";
    private  InputStream input;
    private BufferedReader reader;
    private Calendar c1;
    private Date dateOne;
    private long timeMilli;

    public WorkerThread(Control c,Socket socket){
        this.control = c;
        this.socket = socket;
    }

    @Override
    public void run() {
        //c1 = Calendar.getInstance(); 
        //dateOne = c1.getTime(); 
        //timeMilli = dateOne.getTime();
        //System.out.println(timeMilli+"\t"+Thread.currentThread().getName()+" Start. NineDigitNumber = "+NineDigitNumber);
        try{
           InputStream input = this.socket.getInputStream();
           BufferedReader reader = new BufferedReader(new InputStreamReader(input));
           this.NineDigitNumber = reader.readLine();
           this.NineDigitNumber = this.NineDigitNumber.trim();
           this.socket.close();
           //System.out.println("NineDigitNumber="+this.NineDigitNumber);
           if ( this.NineDigitNumber.equals("terminate") ){
                //System.out.println("Got Termincate!!!!!!!!!!!!!!!!");
                this.control.set_terminate();
                return;
           }
           // Confirm input length is 9.
           if( this.NineDigitNumber.length() != 9 ){
                //System.out.println("Size Problem!!!!!!!!!!!!!!!!!!");
                return;
           }
           // Test for numeric.
           try{
               int result = Integer.parseInt(this.NineDigitNumber);
           }
           catch (Exception e) {
                //System.out.println("Not Numeric!!!!!!!!!!!!!!!!!!!");
               return;
           }
           try{
               if ( !this.control.IsDuplicateNumber(this.NineDigitNumber) ){
                  //c1 = Calendar.getInstance();
                  //dateOne = c1.getTime();
                  //timeMilli = dateOne.getTime();
                  //System.out.println("Start add_number:  Command = "+this.NineDigitNumber+ " Time in ms:  "+timeMilli);

                  this.control.add_number(this.NineDigitNumber);

                  //c1 = Calendar.getInstance();
                  //dateOne = c1.getTime();
                  //timeMilli = dateOne.getTime();
                  //System.out.println("End add_number:  Command = "+this.NineDigitNumber+ " Time in ms:  "+timeMilli);
               }
               //c1 = Calendar.getInstance();         
               //dateOne = c1.getTime();     
               //timeMilli = dateOne.getTime();
               //System.out.println(timeMilli+"\t"+Thread.currentThread().getName()+" Stop. NineDigitNumber = "+NineDigitNumber);
           }
           catch (Exception e) {
               e.printStackTrace();
           }
        }
        catch (Exception e){
           System.out.println("Catch socket read");
           System.out.println(e);
        }
    }

    @Override
    public String toString(){
        return this.NineDigitNumber;
    }
}

