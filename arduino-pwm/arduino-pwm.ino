const int PIN_RECV = 2;
const int PIN_XMIT = 3;
const int PULSE_LONG_DURATION_US = 900;
const int PULSE_SHORT_DURATION_US = 300;
const int PULSE_TOLERANCE_US = 150;
const int TRANSMIT_SYNC_US = 15000;
const int TRANSMIT_PAUSE_US = 10000;
const int TRANSMIT_REPETITION = 8;
const int MAX_SIGNAL_LENGTH = 40;
const int MIN_SIGNAL_LENGTH = 8;

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
  static bool signalArray[TRANSMIT_REPETITION][MAX_SIGNAL_LENGTH], signalRecognized;
  static int signalArrayIndex, signalLengths[TRANSMIT_REPETITION];

  // Attach to the interrupt to catch the next falling edge
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), falling, FALLING);
  highTime = lastFallingTime - lastRisingTime;
  lastRisingTime = micros();
  lowTime = lastRisingTime - lastFallingTime;

  // Beginning of a transmission
  if (lowTime > TRANSMIT_SYNC_US) {
    signalArrayIndex = 0;
    signalLengths[0] = 0;
    signalRecognized = false;

  // Beginning of a repetition
  } else if (lowTime > TRANSMIT_PAUSE_US) {
    // The pause also contains the low part of a pulse signal
    // Analyzing this last pulse
    if (highTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US) {
      signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = true;
    }else{
      signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = false;
    }
    signalLengths[signalArrayIndex]++;

    // Analyze the stored signals if we haven't recognized a signal yet
    if(signalRecognized == false ){
      for (int i = 0; i < signalArrayIndex; i++) {
        if (signalLengths[signalArrayIndex] == signalLengths[i] &&
            signalLengths[i] > MIN_SIGNAL_LENGTH &&
            memcmp(signalArray[signalArrayIndex], signalArray[i], signalLengths[i]) == 0) {
          String signal = "";
          signal.reserve(signalLengths[i]);
          for (int j = 0; j < signalLengths[i]; j++) {
            signal+=signalArray[i][j]==true ? "1" : "0";
          }
          Serial.println(signal);
          signalRecognized = true;
          break;
        }
      } 
    }

    // Move to the next signal
    signalArrayIndex = (signalArrayIndex + 1) % TRANSMIT_REPETITION;
    signalLengths[signalArrayIndex] = 0;

  // Invalid timing
  } else if (highTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || lowTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || highTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US
      || lowTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US) {
    signalLengths[signalArrayIndex] = 0;

  // Received a high pulse
  } else if (highTime > lowTime) {
    signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = true;
    signalLengths[signalArrayIndex] = (signalLengths[signalArrayIndex] + 1) % MAX_SIGNAL_LENGTH;
  // Received a low pulse
  } else if (highTime < lowTime) {
    signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = false;
    signalLengths[signalArrayIndex] = (signalLengths[signalArrayIndex] + 1) % MAX_SIGNAL_LENGTH;
  }
}

void falling() {
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), rising, RISING);
  lastFallingTime = micros();
}

void sendSignal(String signal) {
  digitalWrite(LED_BUILTIN, HIGH);
  transmitLow(TRANSMIT_SYNC_US);
  for (int i = 0; i < TRANSMIT_REPETITION; i++) {
    transmitPwm(signal);
    transmitLow(TRANSMIT_PAUSE_US);
  }
  digitalWrite(LED_BUILTIN, LOW);
}

void transmitPwm(String signal) {
  for (int i = 0; i < signal.length(); i++) {
    if (signal.charAt(i) == '1') {
      transmitHighPulse();
    } else if (signal.charAt(i) == '0') {
      transmitLowPulse();
    }
  }
}

void transmitLowPulse() {
  digitalWrite(PIN_XMIT, HIGH);
  delayMicroseconds(PULSE_SHORT_DURATION_US);
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(PULSE_LONG_DURATION_US);
}

void transmitHighPulse() {
  digitalWrite(PIN_XMIT, HIGH);
  delayMicroseconds(PULSE_LONG_DURATION_US);
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(PULSE_SHORT_DURATION_US);
}

void transmitLow(int duration) {
  digitalWrite(PIN_XMIT, LOW);
  delayMicroseconds(duration);
}
