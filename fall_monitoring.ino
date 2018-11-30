#include <Arduino.h>
#include "User_Setup.h"
#include "Wire.h"

const int MPU_addtess=0x68 //12C address of the IMU
int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ; //store accelerometer and gyroscope values
//todo does IMU have temperature sensor?

void setup() {
    Wire.begin();
    Wire.beginTransmission(MPU_addtess);
    Wire.write(0x6B); //PWR_MGMT_1register
    Wire.write(0); //sent to zero (wakes up MPU-6050 unit)
    Wire.endTransmission(true);
    Serial.begin(9600);
}

void loop() {
//todo output raw data from sensor
}
