import processing.serial.*;
import java.util.*;

//-------------------------------------------------------------------------------------------------
//****** CONTROL PANEL ****************************************************************************
//-------------------------------------------------------------------------------------------------
public static final int SUBJECT_ID = 15;                                     //TEST SUBJECT ID HERE
public static final int MANUAL_TEST = -1;                                    //MANUALLY SPECIFY WHICH TEST TO USE (-1 for standard procedure)
public static final int CALIBRATION_PERIOD = 15000;                          //CALIBRATION TIME IN MILLISECONDS
public static final Integer[] REDUNDANT_TESTS = new Integer[] {5,6,7,8,9};   //DICTIONARY ENTRY AT WHICH THE REDUNDANT TESTS BEGIN
public static final int numRedundantTests = 2;                               //NUMBER OF TIMES TO RUN THE FALL TESTS
//-------------------------------------------------------------------------------------------------
//*************************************************************************************************
//-------------------------------------------------------------------------------------------------

int testNum = 0;
int secondaryCount = 1;
int xMaxPos = 0;
int yMaxPos = 0;
int zMaxPos = 0;
int xMaxNeg = 0;
int yMaxNeg = 0;
int zMaxNeg = 0;
int maxTotalAcc = 0;
int keyStart = 0;
List<Integer> redundant;
PrintWriter csv_output;
Serial arduino;
HashMap<Integer, String> m;

void setup() {
  size(480, 270);
  background(51);
  int indent = 25;
  text("Elderly Fall Monitoring Testing Utility\n", indent, 40);
  text("Controls:\n\n'S' - start recording data\n'Q' - Stop recording data\n'enter' - Force terminate program.", indent, 80);
  initDict();
   m = new HashMap<Integer, String>();
   redundant = Arrays.asList(REDUNDANT_TESTS);
   arduino = new Serial(this, "/dev/ttyACM0", 115200);
   String csv_path = "";
   if(MANUAL_TEST >= 0) {
     testNum = MANUAL_TEST;
     csv_path = "Data/subject_" + SUBJECT_ID + "_" + m.get(MANUAL_TEST) + ".csv";
   } else {
     csv_path = "Data/subject_" + SUBJECT_ID + ".csv";
   }
   File f = new File(csv_path);
   if(f.exists()) {
     println("\nTest data for subject " + SUBJECT_ID + " already exists.");
     println("If you wish to overwrite this data please manually delete the data file.");
     println("Program termination.");
     exit();
   } else {
     calibrate();
     csv_output = createWriter(csv_path);
     csv_output.print("Subject ID:," + SUBJECT_ID + "\n");
     println("\nSubject ID: " + SUBJECT_ID);
     printNext();  
   }
   
}

void draw() {
   if(keyStart == 1) {
     while(arduino.available() > 0) {
       listen();
     }  
   } else if (keyStart == -1) {
     printMax();
     keyStart = 0;
     if(redundant.contains(testNum) && secondaryCount < numRedundantTests) {
        secondaryCount++;       
     } else {
       secondaryCount = 1;
       testNum++;  
     }
     if(testNum >= m.size()) {
       println("Testing procedure for subject " + SUBJECT_ID + " complete.\nProgram termination.");
       csv_output.close();
       exit();
     } else {
       printNext();  
     }
     
   }
}

void initDict() {
   m.put(0, "Walk");
   m.put(1, "Slow Sit Down");
   m.put(2, "Slow Stand Up");
   m.put(3, "Fast Sit Down");
   m.put(4, "Fast Stand Up");
   m.put(5, "Fall Forwards (hands)");
   m.put(6, "Fall Forwards (twist)");
   m.put(7, "Fall Backwards (w/ hands)");
   m.put(8, "Fall Backwards (w/o hands)");
   m.put(9, "Fall Sideways");  
}

void printMax() {
  csv_output.print("MAX ACCEL POS:\n");
  csv_output.print("," + xMaxPos + "," + yMaxPos + "," + zMaxPos + "," + maxTotalAcc + "\n");
  csv_output.print("MAX ACCEL NEG:\n");
  csv_output.print("," + xMaxNeg + "," + yMaxNeg + "," + zMaxNeg + "\n");
  csv_output.flush();
  xMaxPos = 0;
  yMaxPos = 0;
  zMaxPos = 0;
  xMaxNeg = 0;
  yMaxNeg = 0;
  zMaxNeg = 0;
  maxTotalAcc = 0;
}

void listen() {
  String output = arduino.readStringUntil('\n');
    if(output != null){
      println(output + "\n");
      csv_output.print(",");
      csv_output.print(output);
      csv_output.flush();
      output = output.replace("\n", "");
      String[] strArr = output.split(",");
      try {
        int xM = Integer.valueOf(strArr[0]);
        int yM = Integer.valueOf(strArr[1]);
        int zM = Integer.valueOf(strArr[2]);
        int totalAcc = Integer.valueOf(strArr[3]);
        if(xM > xMaxPos) {xMaxPos = xM;}
        if(yM > yMaxPos) {yMaxPos = yM;}
        if(zM > zMaxPos) {zMaxPos = zM;}
        if(xM < xMaxNeg) {xMaxNeg = xM;}
        if(yM < yMaxNeg) {yMaxNeg = yM;}
        if(zM < zMaxNeg) {zMaxNeg = zM;}  
        if(totalAcc > maxTotalAcc) {maxTotalAcc = totalAcc;}
      } catch (NumberFormatException ex) {
        println("Number format exception."); 
      } catch (ArrayIndexOutOfBoundsException e) {
        println("Array index exception.");
      }
  } 
}

void keyPressed() {
   if(key == 's') {
     if(keyStart == 0) {
       keyStart = 1;
       initCase();  
     }
   } else if(key == 'q') {
     if(keyStart == 1) {
       println("End case.");
       keyStart = -1;  
     }
   } else if(key == '\n') {
     if(keyStart == 0) {
       println("Program termination.");
       csv_output.flush();
       csv_output.close();
       exit();  
     }
   }
}

void printNext() {
   println("\nThe next test is: " + m.get(testNum) + " (" + secondaryCount + ")");
   println("Press 'S' to start.");
}

void initCase() {
  println("\nTest Case: " + m.get(testNum) + " (" + secondaryCount + ")\n");
  println("Listening...");
  println("Press 'Q' to end.");
  csv_output.print("\n");
  csv_output.print("TEST: " + m.get(testNum) + " (" + secondaryCount + ")\n");
  csv_output.print("ACCEL VALS:,X,Y,Z,totalAcc\n"); 
}

void calibrate() {
   println("DO NOT PRESS ANY KEYS, CALIBRATING...");
   println("Please wait " + CALIBRATION_PERIOD/1000 + " seconds...");
   int calibrateStart = millis();
   int calibrateCur = 0;
   int calibrateLast = 0;
   do {
     calibrateCur = millis();
     if(calibrateCur - calibrateLast > 500) { //interval between status icons
       print("#");
       calibrateLast = calibrateCur;
     }
     arduino.readStringUntil('\n');
   } while(calibrateCur - calibrateStart < CALIBRATION_PERIOD);
   println("\nCalibration complete.");
}

//AUTHOR: Kyle Won
//2 June 2019
