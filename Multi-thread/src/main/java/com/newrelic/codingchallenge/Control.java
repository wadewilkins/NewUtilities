public class Control {
  private static int report_unique_change = 0;
  public synchronized void increment(){
     report_unique_change++;
     System.out.println("Control:  " +report_unique_change);
  }
  public synchronized int get_unique(){
    return report_unique_change;
  }
}


