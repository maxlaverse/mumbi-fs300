const int PIN_RECV = 2;
const int PIN_XMIT = 3;
const int PULSE_LONG_DURATION_US = 750;
const int PULSE_SHORT_DURATION_US = 375;
const int PULSE_TOLERANCE_US = 150;
const int TRANSMIT_PAUSE_MS = 10;
const int TRANSMIT_REPETITION = 8;
const int BUFFER_LENGTH = 512;
const int MINIMUM_SIGNAL_LENGTH = 34;

volatile unsigned long  highTimeStart = 0;
volatile unsigned long  lowTimeStart = 0;
volatile unsigned int writePointer = 0;
volatile int cBuffer[BUFFER_LENGTH];
unsigned int readPointer = 0;
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

  readSignal();
  delay(100);
}

const int MAX_SIGNAL = 6;
String signalArray[MAX_SIGNAL];
int signalArrayIndex = 0;

void readSignal() {
  String currentSignal = "";
  currentSignal.reserve(MINIMUM_SIGNAL_LENGTH);
  int start = readPointer;
  int writePointerStart = writePointer;
  while ((writePointerStart - readPointer + BUFFER_LENGTH) % BUFFER_LENGTH  > 2) {
    int bitt = cycle_to_bit(cBuffer[readPointer], cBuffer[readPointer + 1]);

    readPointer = (readPointer + 2) % BUFFER_LENGTH;
    if (bitt < 0) {
      if (currentSignal.length() > MINIMUM_SIGNAL_LENGTH-2) {
        //Add signal
        signalArray[signalArrayIndex] = currentSignal;
        signalArrayIndex = (signalArrayIndex + 1) % MAX_SIGNAL;

        //Count occurences
        int found = 0;
        for (int i = 0; i < MAX_SIGNAL; i++) {
          if (signalArray[i] == currentSignal) {
            found++;
          }
        }

        //Release signal
        if (found > 1) {
          for (int i = 0; i < MAX_SIGNAL; i++) {
            signalArray[i] = "";
          }
          //Declare all the buffer read
          Serial.println(currentSignal + "0");
          delay(400);
        }
      }
      currentSignal = "";
    } else if (bitt == 1) {
      currentSignal += "1";
    } else if (bitt == 0) {
      currentSignal += "0";
    }
  }
}

void rising() {
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), falling, FALLING);
  cBuffer[writePointer] = highTimeStart - lowTimeStart;
  writePointer = (writePointer + 1) % BUFFER_LENGTH;
  lowTimeStart = micros();
}

void falling() {
  attachInterrupt(digitalPinToInterrupt(PIN_RECV), rising, RISING);
  cBuffer[writePointer] = lowTimeStart - highTimeStart;
  writePointer = (writePointer + 1) % BUFFER_LENGTH;
  highTimeStart = micros();
}

int cycle_to_bit(unsigned long highTime, unsigned long lowTime) {
  if (highTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || lowTime > PULSE_LONG_DURATION_US + PULSE_TOLERANCE_US
      || highTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US
      || lowTime < PULSE_SHORT_DURATION_US - PULSE_TOLERANCE_US) {
    return -1;
  } else if (highTime > lowTime) {
    return 1;
  } else if (highTime < lowTime) {
    return 0;
  }
}

void sendSignal(String signal) {
  digitalWrite(LED_BUILTIN, HIGH);
  for (int i = 0; i < TRANSMIT_REPETITION; i++) {
    transmitPwm(signal);
    pause();
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

void pause() {
  digitalWrite(PIN_XMIT, LOW);
  delay(TRANSMIT_PAUSE_MS);
}
