float Tmillis=0, freq=0;
String freq_str=" "; // initialize frequency string variable

void setup() {
   Serial.begin(115200); // start serial reader
}
void loop() {
   while (Serial.available() > 0) { // loop while there are strings in read buffer
    freq_str = Serial.readString(); // read string
    freq=freq_str.toFloat(); // convert string to float type
    Tmillis=1*1000*5/freq; // calculate duration for 5 cycle pulse of given frequency
    tone(9,freq,Tmillis); // generate tone at given frequency for above duration on pin 9
   }
}
