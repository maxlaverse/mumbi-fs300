const int PIN_RECV = 2;
const int PIN_XMIT = 3;
const int PULSE_LONG_DURATION_US = 900;
const int PULSE_SHORT_DURATION_US = 300;
const int PULSE_TOLERANCE_US = 150;
const int TRANSMIT_SYNC_US = 15000;
const int TRANSMIT_PAUSE_US = 10000;
const int TRANSMIT_REPETITION = 8;
const int MAX_SIGNAL_LENGTH = 40;

volatile unsigned long  lastFallingTime = 0;
String serialInputString = "";

void setup() {
  Serial.begin(9600);
  pinMode(PIN_RECV, INPUT_PULLUP);
  pinMode(PIN_XMIT, OUTPUT);
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), rising, RISING);
  serialInputString.reserve(200);
}

void serialEvent() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    serialInputString += inChar;
  }
}

void loop() {
  while (serialInputString.indexOf("\n") != -1) {
    sendSignal(serialInputString.substring(0, serialInputString.indexOf("\n")));
    serialInputString = serialInputString.substring(serialInputString.indexOf("\n") + 1);
    delay(10);
  }
  delay(100);
}

void rising() {
  static unsigned long highTime, lastRisingTime, lowTime;
  static int signalCharIndex, signalArrayIndex;
  static char signalArray[TRANSMIT_REPETITION][MAX_SIGNAL_LENGTH];
  static bool sent;
  
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), falling, FALLING);
  highTime = lastFallingTime - lastRisingTime;
  lastRisingTime = micros();
  lowTime = lastRisingTime - lastFallingTime;
  
  if (lowTime > TRANSMIT_SYNC_US) {
    signalArrayIndex = 0;
    signalCharIndex = 0;
    sent = false;
  } else if (lowTime > TRANSMIT_PAUSE_US) {
    signalArray[signalArrayIndex][signalCharIndex++ % MAX_SIGNAL_LENGTH] = '0';
    signalArray[signalArrayIndex][signalCharIndex++ % MAX_SIGNAL_LENGTH] = '\n';
    if(sent == false ){
      int found = 0;
      for (int i = 0; i < signalArrayIndex; i++) {
        if (strcmp(signalArray[signalArrayIndex], signalArray[i]) == 0) {
          Serial.println(signalArray[signalArrayIndex]);
          sent = true;
          break;
        }
      } 
    }
    signalArrayIndex = (signalArrayIndex + 1) % TRANSMIT_REPETITION;
    signalCharIndex = 0;
  } else if (highTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || lowTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || highTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US
      || lowTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US) {
    signalCharIndex = 0;
  } else if (highTime > lowTime) {
    signalArray[signalArrayIndex][signalCharIndex++ % MAX_SIGNAL_LENGTH] = '1';
  } else if (highTime < lowTime) {
    signalArray[signalArrayIndex][signalCharIndex++ % MAX_SIGNAL_LENGTH] = '0';
  }
}

void falling() {
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), rising, RISING);
  lastFallingTime = micros();
}

void sendSignal(String signal) {
  digitalWrite(LED_BUILTIN, HIGH);
  sendZero(TRANSMIT_SYNC_US);
  for (int i = 0; i < TRANSMIT_REPETITION; i++) {
    transmitPwm(signal);
    sendZero(TRANSMIT_PAUSE_US);
  }
  digitalWrite(LED_BUILTIN, LOW);
}

void transmitPwm(String signal) {
  for (int i = 0; i < signal.length(); i++) {
    if (signal.charAt(i) == '1') {
      transmitHigh();
    } else if (signal.charAt(i) == '0') {
      transmitLow();
    }
  }
}

void transmitLow() {
  digitalWrite(PIN_XMIT, HIGH);
  delayMicroseconds(PULSE_SHORT_DURATION_US);
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(PULSE_LONG_DURATION_US);
}

void transmitHigh() {
  digitalWrite(PIN_XMIT, HIGH);
  delayMicroseconds(PULSE_LONG_DURATION_US);
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(PULSE_SHORT_DURATION_US);
}

void sendZero(int duration) {
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(duration);
}
