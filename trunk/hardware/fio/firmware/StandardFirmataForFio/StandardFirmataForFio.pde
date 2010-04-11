/*
 * Standard Firmata firmware for Arduino Fio boards
 *
 * Written by Shigeru Kobayashi (kotobuki@yapan.org)
 *
 * Reference: StandardFirmata by Hans-Christoph Steiner <hans@eds.org>
 */

#include <Firmata.h>

int analogInputsToReport = 0;  // bitwise array to store pin reporting
byte reportPINs[TOTAL_PORTS];  // PIN == input port

unsigned long currentMillis;     // store the current value from millis()
unsigned long nextExecuteMillis; // for comparison with currentMillis
unsigned int samplingInterval = 32;  // default sampling interval is 33ms

#define MINIMUM_SAMPLING_INTERVAL 10

void setPinModeCallback(byte pin, int mode) {
  if (pin < 2) {
    return;  // ignore RxTx pins (0,1)
  }

  switch(mode) {
  case INPUT:
  case OUTPUT:
    pinMode(pin, mode);
    break;
  case PWM:
    pinMode(pin, OUTPUT);
    break;
  default:
    break;
  }
}

void analogWriteCallback(byte pin, int value) {
  setPinModeCallback(pin, PWM);
  analogWrite(pin, value);
}

void digitalWriteCallback(byte port, int value) {
  switch (port) {
  case 0: // pins 2-7  (0,1 are serial RX/TX, don't change their values)
    // 0xFF03 == B1111111100000011    0x03 == B00000011
    PORTD = (value &~ 0xFF03) | (PORTD & 0x03);
    break;
  case 1: // pins 8-13 (14,15 are disabled for the crystal)
    PORTB = (byte)value;
    break;
  case 2: // analog pins used as digital
    PORTC = (byte)value;
    break;
  }
}

void reportAnalogCallback(byte pin, int value) {
  if (value == 0) {
    analogInputsToReport = analogInputsToReport &~ (1 << pin);
    pinMode(14 + pin, OUTPUT);
  }
  else { // everything but 0 enables reporting of that pin
    analogInputsToReport = analogInputsToReport | (1 << pin);
    pinMode(14 + pin, INPUT);
  }
}

void reportDigitalCallback(byte port, int value) {
  reportPINs[port] = (byte)value;

  // turn off analog reporting when used as digital
  if (port == ANALOG_PORT) {
    analogInputsToReport = 0;
  }
}

void sysexCallback(byte command, byte argc, byte *argv) {
  if (command == SAMPLING_INTERVAL) {
    samplingInterval = argv[0] + (argv[1] << 7);
    if (samplingInterval < MINIMUM_SAMPLING_INTERVAL) {
      samplingInterval = MINIMUM_SAMPLING_INTERVAL;
    }
    samplingInterval -= 1;
  }
}

void systemResetCallback() {
  for (byte i = 0; i < 3; i++) {
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    delay(100);
  }
}

void setup() {
  byte i;

  Firmata.setFirmwareVersion(2, 0);

  Firmata.attach(ANALOG_MESSAGE, analogWriteCallback);
  Firmata.attach(DIGITAL_MESSAGE, digitalWriteCallback);
  Firmata.attach(REPORT_ANALOG, reportAnalogCallback);
  Firmata.attach(REPORT_DIGITAL, reportDigitalCallback);
  Firmata.attach(SET_PIN_MODE, setPinModeCallback);
  Firmata.attach(START_SYSEX, sysexCallback);
  Firmata.attach(SYSTEM_RESET, systemResetCallback);

  for (i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
    pinMode(i, OUTPUT);
  }

  for (i = 0; i < TOTAL_PORTS; ++i) {
    reportPINs[i] = false;
  }

  Firmata.begin(19200);
}

void loop()
{
  int analogPin = 0;

  // process received data as soon as possible
  while (Firmata.available()) {
    Firmata.processInput();
  }

  currentMillis = millis();
  if (currentMillis > nextExecuteMillis) {
    nextExecuteMillis = currentMillis + samplingInterval;

    // report digital ports if requested
    if (reportPINs[0]) {
      Firmata.sendDigitalPort(0, PIND &~ B00000011); // ignore Rx/Tx 0/1
    }

    if (reportPINs[1]) {
      Firmata.sendDigitalPort(1, PINB);
    }

    // report analog inputs if requested
    for (analogPin = 0; analogPin < TOTAL_ANALOG_PINS; analogPin++) {
      if (analogInputsToReport & (1 << analogPin)) {
        Firmata.sendAnalog(analogPin, analogRead(analogPin));
      }
    }
  }
}
