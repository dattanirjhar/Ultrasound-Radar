#include <Servo.h>

const int servoPin = 9;
const int trigPin = 10;
const int echoPin = 11;

Servo myServo;

int angle = 15;
int angleStep = 1;
int minAngle = 15;
int maxAngle = 165;
unsigned long previousMillis = 0;
int stepDelay = 30;  // Controls sweep speed (ms)

void setup() {
  Serial.begin(9600);
  myServo.attach(servoPin);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  myServo.write(angle);
}

void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= stepDelay) {
    previousMillis = currentMillis;

    myServo.write(angle);

    // Trigger the ultrasonic sensor
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);

    long duration = pulseIn(echoPin, HIGH, 20000); // Timeout after 20ms
    int distance = duration > 0 ? duration * 0.034 / 2 : -1;

    // Send data to Processing
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");

    // Update angle
    angle += angleStep;
    if (angle >= maxAngle || angle <= minAngle) {
      angleStep = -angleStep;
    }
  }
}
