/*  filename = MAE170-Lab6-Spring2023.ino
    MAE170 convective cooling heat transfer experiment
    SWR 18 Feb 2022) - 11 Aug 2022
    MR11 bulb, 12V, 2.8A, 35W
    NEMA 17 step motor StepperOnline model 17HS19-2004S1
    Uses Pololu DRV8825 step driver @ 16:1 ustepping
*/

byte stp   =    3;     // step pin
byte dir   =    2;     // direction of rotation
#define down    5      // lamp down button 
#define up      4      // lamp up button

#define OK      6      // OK button
#define Thot   A0      // heated thermistor 
#define Tamb   A1      // ambient thermistor
#define bulb    9      // halogen bulb control
#define fan     10     // fan control

int  dlyon    = 100;   // uS delay for pulse hi
int  dlyoff   = 4000;  // uS delay for pulse lo
int  n90      = 800;   // # steps for up rotation
int  ScanDly  = 1000; // loop length, mS

int  cooling = 0;      // 0 = not in cooling mode, 1 = cooling
int i;                 // reuseable int i
float  Tset;           // Max degrees C set point
float AmbTol = 2.0;    // cutoff tolerance for plate temperature returning to ambient
int Thold = 0;
int TholdSet = 15 ;    // how long to hold Tset (sec)
float Tplate, Tair;    // plate temp, air temp (deg C)
long Tstart;           // initialize elapsed millisecs

int standBy = 1 ;       // start in "standby mode" - accept button inputs, wait for matlab serial command
int firstRun = 0;       // flag for a the first block of code that needs to be run for each test

void rotate(byte x) {          // make 1 atep on the step motor
  digitalWrite(dir, x);        // set direction (x=0/1,up/dn)
  digitalWrite(stp, 1); delayMicroseconds(dlyon);  // pulse hi
  digitalWrite(stp, 0); delayMicroseconds(dlyoff); // pulse lo
}

void setup() {
  pinMode(stp, OUTPUT);       // pulse pin for step motor
  pinMode(dir, OUTPUT);       // motor direction 1=CCW, 0=CW
  pinMode(down, INPUT_PULLUP); // jogs bulb toward plate
  pinMode(up,  INPUT_PULLUP); // jogs bulb away from plate
  pinMode(OK,  INPUT_PULLUP); // OK when bulb is in heating position
  pinMode(bulb, OUTPUT);      // bulb on/off control
  pinMode(fan, OUTPUT);       // fan on/off control
  Serial.begin(9600);         // set serial baud rate

  digitalWrite(bulb, 0);         // turn off bulb
  digitalWrite(fan, 0);          // turn off fan
} // end of setup


void loop() {
  if (standBy) {
    digitalWrite(bulb, 0);      // turn off bulb
    digitalWrite(fan, 0);       // turn off fan
    if (Serial.available() > 0) {
      String s = Serial.readString(); // read matlab setpoint temperature in from serial
      Tset = s.toFloat();
      standBy = 0;
    }
    while (digitalRead(down) == 0) {
      rotate(1);   // rotate bulb toward plate
    }
    while (digitalRead(up)   == 0) {
      rotate(0);   // rotate bulb away from plate
    }
  } else {
    if (not firstRun) {
      for (i = 0; i < n90; i++) rotate(1); // rotate bulb down
      for (i = 0; i < 255; i++) {
        analogWrite(bulb, i);  // soft turn-on
        delay(20);
      }
      firstRun = 1;
    }


    if (cooling == 0) {                         // if not in cooling mode
      if (Tplate < Tset) {
        analogWrite(bulb, 150); // plate is below set point
      }
      if (Tplate > Tset) {
        analogWrite(bulb, 0); // plate is above set point
      }
    }

    int T1 = analogRead(Thot);                 // read T hot
    float T1V = 5.0 * T1 / 1023.;              // assumes Vusb = 5.00
    Tplate = T1V * 23.7585 - 19.064;           // cal equation

    int T2 = analogRead(Tamb);                 // read T amb
    float T2V = 5.0 * T2 / 1023.;              // assumes Vusb = 5.00
    Tair = T2V * 23.7585 - 19.064;             // cal equation

    Serial.print(Tplate, 2); Serial.print(",");     // plate temperature (C)
    Serial.print(Tair, 2); Serial.print(";"); // free-air temperature (C)
    Serial.print (millis());           // total mS
    Serial.println();

    if (cooling == 0) {                           // if not in cooling mode...
      if ((Tset - Tplate) <= 0.5) Thold++;       // count # seconds when T-Tset < 1 degC
      if (Thold > TholdSet) {                    // shut down heating control
        cooling = 1;                            // flag in cooling mode
          digitalWrite(bulb, 0);                  // bulb off
        for (i = 0; i < n90; i++) rotate(0);    // rotate bulb up
        digitalWrite(fan, 1);                   // turns on fan, if switch enabled
      }
    } else {
      if (Tplate < Tair + AmbTol) {  // if plate temp is close to ambient air temp 
        Serial.println("C!");     // flag to tell MATLAB that data collection is Complete
        cooling = 0;              // reset flags back to initial values to wait for next command from MATLAB
        standBy = 1;
        firstRun = 0;
      }
    }
  }
  delay(ScanDly);
}  // end of loop
