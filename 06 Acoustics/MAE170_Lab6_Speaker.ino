float Tmicros=0, freq=0;
String freq_str=" "; // initialize frequency string variable

void setup() {
   Serial.begin(115200); // start serial reader
}
void loop() {
   while (Serial.available() > 0) { // loop while there are strings in read buffer
    freq_str = Serial.readString(); // read string
    freq=freq_str.toFloat(); // convert string to float type
    Tmicros=1*1e6*5/freq; // calculate duration for 5 cycle pulse of given frequency in microseconds
                          // we use microseconds to ensure we have sufficient precision at ~1ms time scales
    tone(9,freq); // generate tone at given frequency on pin 9
    delayMicroseconds(Tmicros); // let tone run for desired amount of time. Need to use delayMicroseconds to ensure sufficient
                                // precision at ~1ms scale
    noTone(9); // stop the tone on pin 9
   }
}
