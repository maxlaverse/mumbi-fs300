static const byte PIN_RECV = 2;
static const byte PIN_XMIT = 3;
static const unsigned int PULSE_LONG_DURATION_US = 900;
static const unsigned int PULSE_SHORT_DURATION_US = 300;
static const unsigned int PULSE_TOLERANCE_US = 150;
static const unsigned int TRANSMIT_SYNC_US = 15000;
static const unsigned int TRANSMIT_PAUSE_US = 10000;
static const byte TRANSMIT_REPETITION = 8;
static const byte MAX_SIGNAL_LENGTH = 40;
static const byte MIN_SIGNAL_LENGTH = 8;

static volatile unsigned long  lastFallingTime = 0;

void setup() {
  Serial.begin(9600);
  pinMode(PIN_RECV, INPUT_PULLUP);
  pinMode(PIN_XMIT, OUTPUT);
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), rising, RISING);
}

void loop() {
  static bool message[MAX_SIGNAL_LENGTH];
  static unsigned int messageIndex;
  static char character;
  static bool transmissionStarted;

  while (Serial.available()) {
    character = (char)Serial.read();
    if (character == '<') {
      transmissionStarted = true;
    } else if (transmissionStarted && (character == '0' || character == '1') && messageIndex <  MAX_SIGNAL_LENGTH) {
      message[messageIndex++] = character == '1';
    } else if (transmissionStarted && character == '>' ) {
      sendSignal(message, messageIndex);
      Serial.print("<OK:");
      for (int j = 0; j < messageIndex; j++) {
        Serial.print(message[j] == true ? "1" : "0");
      }
      Serial.print(">");
      Serial.flush();
      messageIndex = 0;
      transmissionStarted = false;
    } else {
      Serial.print("<ERR:");
      Serial.print(transmissionStarted == true ? "0" : "1");
      Serial.print(":");
      Serial.print(String(messageIndex));
      Serial.print(":");
      Serial.print(String(character));
      Serial.print(">");
      Serial.flush();
    }
  }

  delay(100);
}

void rising() {
  static unsigned long highTime, lastRisingTime, lowTime;
  static bool signalArray[TRANSMIT_REPETITION][MAX_SIGNAL_LENGTH];
  static byte signalArrayIndex, signalLengths[TRANSMIT_REPETITION], signalOccurences[TRANSMIT_REPETITION];

  // Attach to the interrupt to catch the next falling edge
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), falling, FALLING);
  highTime = lastFallingTime - lastRisingTime;
  lastRisingTime = micros();
  lowTime = lastRisingTime - lastFallingTime;

  // Beginning of a transmission
  if (lowTime > TRANSMIT_SYNC_US) {
    signalArrayIndex = 0;
    signalLengths[0] = 0;
    signalOccurences[0] = 0;

    // Beginning of a repetition
  } else if (lowTime > TRANSMIT_PAUSE_US) {
    // The pause also contains the low part of a pulse signal
    // Analyzing this last pulse
    if (highTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US) {
      signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = true;
    } else {
      signalArray[signalArrayIndex][signalLengths[signalArrayIndex]] = false;
    }
    signalLengths[signalArrayIndex]++;

    // Analyze the stored signals if we haven't recognized a signal yet
    for (int i = 0; i < signalArrayIndex; i++) {
      if (signalLengths[signalArrayIndex] == signalLengths[i] &&
          signalLengths[i] > MIN_SIGNAL_LENGTH &&
          memcmp(signalArray[signalArrayIndex], signalArray[i], signalLengths[i]) == 0) {

        if (signalOccurences[i] == 1) {
          // Send only if recognize twice
          Serial.print("<");
          for (int j = 0; j < signalLengths[i]; j++) {
            Serial.print(signalArray[i][j] == true ? "1" : "0");
          }
          Serial.print(">");
          Serial.flush();
        }
        signalOccurences[i]++;
        break;
      }
    }

    // Move to the next signal
    signalArrayIndex = (signalArrayIndex + 1) % TRANSMIT_REPETITION;
    signalLengths[signalArrayIndex] = 0;
    signalOccurences[signalArrayIndex] = 0;

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

void sendSignal(bool message[], byte messageLength) {
  digitalWrite(LED_BUILTIN, HIGH);
  transmitLow(TRANSMIT_SYNC_US);
  for (int i = 0; i < TRANSMIT_REPETITION; i++) {
    transmitPwm(message, messageLength);
    transmitLow(TRANSMIT_PAUSE_US);
  }
  digitalWrite(LED_BUILTIN, LOW);
}

void transmitPwm(bool message[], byte messageLength) {
  for (byte i = 0; i < messageLength; i++) {
    if (message[i] == true) {
      transmitHighPulse();
    } else {
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
