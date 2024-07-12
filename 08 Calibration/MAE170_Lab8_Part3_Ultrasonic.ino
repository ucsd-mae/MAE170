int trigPin = 3;
int echoPin = 2;
long duration;
int distance;

void setup() {
	pinMode(trigPin, OUTPUT);
	pinMode(echoPin, INPUT);
	Serial.begin(9600);
}

void loop() {
	digitalWrite(trigPin, LOW);
	delayMicroseconds(2);
	digitalWrite(trigPin,HIGH);
	delayMicroseconds(10);
	digitalWrite(trigPin,LOW);
	duration=pulseIn(echoPin,HIGH);
	Serial.println(duration);
	delay(100);
}