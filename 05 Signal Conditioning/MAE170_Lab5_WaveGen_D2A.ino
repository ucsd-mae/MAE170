// NOTE: This script requires two open source packages in order to run.
// To install these packages, navigate to Sketch > Include Library > Manage Libraries
// and search for and install the following:
//    * Adafruit BUSIO
//    * Adafruit MCP4725


#include <Wire.h> // I2C library
#include <Adafruit_MCP4725.h> // MCP4725 library
Adafruit_MCP4725 dac; //invoke the MCP4725 library


float freq = 0, volts = .5, vavg = 1.0; // initialize frequency and voltage variables
int counts = 4095; // initialize counts and max voltage variables
double pi = 3.14159; // set pi
String freq_str = " "; // initialize frequency string variable


void setup() {
  dac.begin(0x62); // set I2C address
  Serial.begin(115200); // start serial reader
}


void loop() {
  while (Serial.available() > 0) { // loop while there are strings in read buffer
    freq_str = Serial.readString(); // read the signal frequency
    Serial.println(freq_str); // print out the frequency to the serial monitor
    freq = freq_str.toFloat(); // convert the frequency read on serial to float type
  }
  dac.setVoltage(counts / 5 * (volts * sin(2 * pi * freq * micros() / 1E6) + vavg), false);
  // drive a sine wave with amplitude volts, and offset max voltage / 2
}
