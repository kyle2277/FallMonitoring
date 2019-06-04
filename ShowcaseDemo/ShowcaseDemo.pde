import processing.serial.*;
import java.util.*;

//----------------------------------------------------------------------
//**************  CONTROL PANEL  ***************************************
//----------------------------------------------------------------------
public static final int CALIBRATION_PERIOD = 1000;  //CALIBRATION TIME IN MILLISECONDS
public static final String port = "/dev/ttyACM0";    //ARDUINO SERIAL CONNECTION PORT
public static final String loadingIcon = "|";        //ICON USED FOR LOADING BAR
//----------------------------------------------------------------------
//**********************************************************************
//----------------------------------------------------------------------

Serial arduino;
public int keyStatus = 0;
public String loadingBar = "";


/*
Draw Status Key:
0 = Standby
1 = Calibrate
2 = Listen for fall
3 = Showing fall detected
*/

//Timer variables
public int timerStart = 0;
public int timerCur = 0;
public int timerLast = 0;


//Last fall data variables
public double xMax = 0;
public double yMax = 0;
public double zMax = 0;

void setup() {
  arduino = new Serial(this, port, 115200);
  size(800,500);
  background(51);
  timerStart = millis();
  keyStatus = 1;
}

void draw() {
  //println(keyStatus);
  if(keyStatus != 3) {
    if(keyStatus == 1) {
      if(timerCur - timerStart < CALIBRATION_PERIOD) {
        calibrate();  
      } else {
        keyStatus = 2; 
      }
    } else if(keyStatus == 2) {
      listen();
    } 
  } else {
    showFall(); 
  }
}

void keyPressed() {
  if(key == ' ') {
    if(keyStatus == 3) {
      keyStatus = 2;
      xMax = 0;
      yMax = 0;
      zMax = 0;
    }
  } else if (key == '\n') {
    exit(); 
  }
}

void listen() {
  background(51);
  textSize(45);
  fill(255);
  text("Listening...", 275, 250);
}

void showFall() {
  fill(255);
  strokeWeight(1);
  background(244,66,66);
  textSize(80);
  text("FALL", 300, 150);
  textSize(25);
  text("Max X-axis acceleration: " + Math.round(xMax*1000)/1000.0 + "  ms^-2\nMax Y-axis acceleration: " + Math.round(yMax*1000)/1000.0 + "  ms^-2\nMax Z-axis acceleration: " + Math.round(zMax*1000)/1000.0 + "  ms^-2", 150,300);
}


void serialEvent(Serial arduino) {
  if(keyStatus == 2) {
    String output = arduino.readStringUntil('\n');
    if(output != null) {
      String[] strArr = output.split(",");
      try {
        xMax = (Double.valueOf(strArr[0]) / 16384) * 9.81;
        yMax = (Double.valueOf(strArr[1]) / 16384) * 9.81;
        zMax = (Double.valueOf(strArr[2]) / 16384) * 9.81;
        keyStatus = 3;
      } catch(ArrayIndexOutOfBoundsException e) {
        keyStatus = 1;
      }
    }  
  }
  
}

void calibrate() {
  background(50);
  textSize(26);
  text("Welcome to UW HuskyADAPT build team:\nElderly Fall Monitoring", 45,100);
  textSize(20);
  text("By Kyle Won", 45, 200);
  textSize(18);
  text("DO NOT PRESS ANY KEYS,  CALIBRATING\nPlease wait " + CALIBRATION_PERIOD/1000 + " seconds...", 45, 300);
  text(loadingBar, 45, 375);
  timerCur = millis();
  if(timerCur - timerLast > 500) { //interval between status icons
    loadingBar = loadingBar + loadingIcon;
    timerLast = timerCur;
  }
  //arduino.readStringUntil('\n');
}
