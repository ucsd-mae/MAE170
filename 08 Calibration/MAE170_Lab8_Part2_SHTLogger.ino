#include <Wire.h>
#include "Adafruit_SHT31.h"
#include <Arduino.h>
Adafruit_SHT31 sht31 = Adafruit_SHT31();

void setup() {
  Serial.begin(9600);
}

void loop() {
  sht31.begin(0x44);                    // chamber, addr = 0x44
  float Tchb = sht31.readTemperature(); // read chamber T 
  float Hchb = sht31.readHumidity();    // read chamber RH

  sht31.begin(0x45);                    // ambient, addr = 0x45
  float Tamb = sht31.readTemperature(); // read ambient T, add offseet
  float Hamb = sht31.readHumidity();    // read ambient RH, add offset

  float sec = millis() / 1000.0;

  Serial.print(sec);  Serial.print(",");
  Serial.print(Tchb); Serial.print(",");
  Serial.print(Hchb); Serial.print(",");
  Serial.print(Tamb); Serial.print(",");
  Serial.println(Hamb);
}
