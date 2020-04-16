//package com.newrelic.codingchallenge;

//import org.junit.Test;
import java.io.*;
import java.net.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;


public class MainTest {
public static final int MAX_THREADS = 8;

    public static void main(String[] args) {

        // Test something here (optional)
        System.out.println("Testing");
        ExecutorService executor = Executors.newFixedThreadPool(MAX_THREADS);

        for ( int i = 0; i < MAX_THREADS; i++ ){
            String s = String.valueOf(i);
            Runnable worker = new WorkerThread(s);
            executor.execute(worker);
        }
        executor.shutdown();

    }
}

//  Worker thread that checks input for being unique and writes to the file if it is.
class WorkerThread implements Runnable {

    private String command;

    public WorkerThread(String s){
        this.command=s;
    }

    @Override
    public void run() {
        processCommand();
    }

    private void processCommand() {
        try {
//           System.out.println("Received " + this.command);
           int result = Integer.parseInt(this.command);
           long start = result*1000000;
           long end  = start+1000000;
           System.out.println("Start Loop " + start);
           String test;
           InetAddress host = InetAddress.getLocalHost();
           Socket socket = null;
           ObjectOutputStream oos = null;
           ObjectInputStream ois = null;
           for (long i = start; i < end; i++){
              try{
                 socket = new Socket(host.getHostName(), 4000);
                 test = String.format("%09d", i);
                 //System.out.println("Loop " + test+ " Length: "+test.length());
 
                 // get the output stream from the socket.
                 OutputStream outputStream = socket.getOutputStream();
                 // create a data output stream from the output stream so we can send data through it
                 DataOutputStream dataOutputStream = new DataOutputStream(outputStream);
                 //System.out.println("Sending string to the ServerSocket");
                 // write the message we want to send
                 dataOutputStream.writeUTF(test);
                 dataOutputStream.flush(); // send the message
                 dataOutputStream.close(); // close the output stream when we're done.

                 //OutputStreamWriter osw =new OutputStreamWriter(socket.getOutputStream(), "UTF-8");
                 //osw.write(test, 0, test.length());
                 //oos = new ObjectOutputStream(socket.getOutputStream());
                 //oos.writeObject(test);
                 socket.close();
               }
               catch (Exception e){
                 continue;
               }
            }
        }
        catch (Exception e)  {
            e.printStackTrace();
        }
    }
    @Override
    public String toString(){
        return this.command;
    }
}

