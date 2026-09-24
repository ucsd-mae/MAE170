// Lab 5 Motor control for pi pico script
// fill in the blanks to make it work
//
// This is the ONLY file you need to edit. Everything you need for this
// week's lab (readADC and setPWM) lives here.
//
// Lab5Helpers.h handles serial input and print timing so this file can
// stay focused on the two functions below -- see that file's header
// comment if you're curious what it does.

#include "Lab5Helpers.h"

// Set constant values that will never change while script is running
const uint adcPin = A0;
const uint pwmPin = 15;
const uint adcResolution = 10;
const uint pwmResolution = 8;
const float adcVoltage = 3.3;

// Create global variables that will be updated as the script runs
uint motorEnable = 0;
uint pwmValue = 0;

// Functions that you need to finish
float readADC(uint readPin){
  // --------------------
  // YOUR CODE GOES HERE
    // hint: analogRead()?
    // hint: max ADC count = 2^adcResolution - 1 -> what's that as a float?

  float lastVoltage = 0;

  // --------------------
  return lastVoltage;
}

void setPWM(uint writePin, float lastVoltage){
  // --------------------
  // YOUR CODE GOES HERE
  // store the value you send to the pwmPin in the global variable pwmValue
  // that way your value is visible in the output print statements
    // hint: scale voltage to a pwm count. max PWM count = 2^pwmResolution - 1  
  pwmValue = 0;
    // hint: analogWrite()?
  
  // --------------------
  // no need to return anything (function type is void)
}
// no need to change anything below here

void setup() {
  analogReadResolution(adcResolution); // set pico to specified ADC resolution
  analogWriteResolution(pwmResolution);// set pwm to specified resolution-default is 8 bit
  Serial.begin();
  while(!Serial){
    // wait for serial (USB CDC) connection to be opened on computer
  }

  pinMode(pwmPin, OUTPUT);
  pinMode(adcPin, INPUT);
  Serial.print("PWM Motor Control via Potentiometer. Set PWM duty cycle with potentiometer. ");
  Serial.print("Send \"1\" via Serial to enable motor. Send \"0\" to stop motor.\n\n");

  float voltage = readADC(adcPin);
  setPWM(pwmPin, voltage);
  Serial.print("Last ADC value: ");            Serial.print(voltage);
  Serial.print("  Corresponding PWM Value: "); Serial.print(pwmValue);
  Serial.print("  Motor State: ");             Serial.println(motorEnable);
}

void loop() {
  // 1. check if MATLAB (or you, via the serial monitor) sent a new
  //    motor on/off command -- this updates the global motorEnable
  updateMotorEnableFromSerial(motorEnable);

  // 2. read the current potentiometer voltage
  float voltage = readADC(adcPin);

  // 3. drive the motor at that voltage if enabled, otherwise hold it off
  if (motorEnable) {
    setPWM(pwmPin, voltage);
  } else {
    setPWM(pwmPin, 0);
  }

  // 4. give the user feedback (throttled to once a second internally)
  printStatus(voltage, pwmValue, motorEnable);
}
