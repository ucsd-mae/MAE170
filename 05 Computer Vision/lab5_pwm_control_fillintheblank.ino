// Lab 5 Motor control for pi pico script
// the state machine has been defined for you
// fill in the blanks to make it work

const uint adcPin = A0;
const uint pwmPin = 15;
const uint adcResolution = 10;
const uint pwmResolution = 8;
const float adcVoltage = 3.3;

uint motorEnable = 0;
uint pwmValue = 0;

unsigned long timeMillis = millis();
unsigned long updateInterval = 1000; // print update once a second

float readADC(uint adcPin){
  // --------------------
  // YOUR CODE GOES HERE
    // hint: analogRead()?
  float lastVoltage = 0;

  // --------------------
  return lastVoltage;
}

void setPWM(float lastVoltage){
  // --------------------
  // YOUR CODE GOES HERE
    // hint: set PWM output to motorPin with analogWrite, which accepts int between 0-255
    //       do you need to scale your lastVoltage value to map onto a 0-255 range?

  pwmValue = 0;
  // --------------------
  // no need to return anything (function type is void)
}

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
  Serial.print("Last ADC value: ");
  Serial.print(readADC(adcPin));
  setPWM(readADC(adcPin));
  Serial.print("  Corresponding PWM Value: "); Serial.print(pwmValue);
  Serial.print("  Motor State: "); Serial.println(motorEnable);
}

void loop() {
  // loop implemented as a binary state machine:
  //    state defined by motorEnable
  //    every loop check if user has updated motorEnable
  //    if motor is enabled, read adc pin and set 
  //    otherewise set PMM output to 0
  //    print an update to the user every 1000 ms
  
  int userValue = 0;
  // check if user has updated motor condition
  if (Serial.available() > 1){
    
    userValue = Serial.parseInt();
    Serial.print("Received user input: "); Serial.println(userValue);
    // do some checking on the value and set to our desired range (0,1)
    if (userValue < 0){
      userValue = 0;
    }
    if (userValue > 1){
      userValue = 1;
    }
    Serial.print("Setting motorEnable value to: "); Serial.println(userValue);
    motorEnable = (unsigned)userValue; //  explicitly cast as unsigned now that we've handled negative values
    Serial.print("motorEnable value: "); Serial.println(motorEnable);
  }
  // if motor is on, set PWM output to current potentiometer %
  if (motorEnable){
    setPWM(readADC(adcPin)); // read adcPin and set PWM
  }
  else {
    setPWM(0);
  }

  // user feedback (nonblocking)
  if ((millis()- timeMillis) > updateInterval){
    timeMillis = millis();
    Serial.print("ADC voltage: ");
    Serial.print(readADC(adcPin));
    setPWM(readADC(adcPin));
    Serial.print("  Corresponding PWM Value: "); Serial.print(pwmValue);
    Serial.print("  Motor State: "); Serial.println(motorEnable);
  }
}
