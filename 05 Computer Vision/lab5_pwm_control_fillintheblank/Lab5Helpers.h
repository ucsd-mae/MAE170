// Lab5Helpers.h
//
// A small local library for Lab 5. You do NOT need to read or understand
// this file to complete the lab -- it exists so that
// lab5_pwm_control_fillintheblank.ino can stay focused on the two
// functions you're implementing this week.
//
// Like any library you #include, you're trusting its interface (the
// function names, parameters, and what they do) without needing to read
// its implementation. That's normal -- you've been doing this all
// quarter with Serial, Wire, etc.
//
// What's here, for the curious:
//   - updateMotorEnableFromSerial(): listens for "1" / "0" sent over
//     Serial and updates motorEnable accordingly. This is how the
//     MATLAB video-capture script starts and stops your motor.
//   - printStatus(): prints your ADC/PWM/motor state once a second
//     without freezing the rest of the loop (a technique called
//     "non-blocking timing"). We'll cover this idea properly in a later
//     lab.

#ifndef LAB5_HELPERS_H
#define LAB5_HELPERS_H

#include <Arduino.h>

// Checks for a new motor on/off command over Serial and writes the
// result into motorEnable (passed by reference, so this function can
// update the caller's variable directly).
inline void updateMotorEnableFromSerial(uint &motorEnable){
  if (Serial.available() > 1){
    int userValue = Serial.parseInt();
    Serial.print("Received user input: "); Serial.println(userValue);

    // clamp to our valid range (0, 1)
    if (userValue < 0) userValue = 0;
    if (userValue > 1) userValue = 1;

    motorEnable = (uint)userValue;
    Serial.print("motorEnable value: "); Serial.println(motorEnable);
  }
}

// Prints the current voltage/PWM/motor state, throttled to once a
// second. The timer that makes this non-blocking lives entirely inside
// this function (as a static local variable) -- nothing about it leaks
// out into your sketch.
inline void printStatus(float voltage, uint pwmValue, uint motorEnable){
  static unsigned long lastPrintTime = 0;
  const unsigned long printInterval = 1000; // once a second

  if ((millis() - lastPrintTime) > printInterval){
    lastPrintTime = millis();
    Serial.print("ADC voltage: ");               Serial.print(voltage);
    Serial.print("  Corresponding PWM Value: "); Serial.print(pwmValue);
    Serial.print("  Motor State: ");              Serial.println(motorEnable);
  }
}

#endif
