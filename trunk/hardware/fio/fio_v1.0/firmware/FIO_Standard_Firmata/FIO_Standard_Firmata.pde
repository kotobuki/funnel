/*
 * Standard Firmata firmware for Funnel I/O modules
 * 
 * Written by Shigeru Kobayashi (kotobuki@yapan.org)
 * 
 * Reference: Standard_Firmata by Hans-Christoph Steiner <hans@eds.org>
 */

#include <Firmata.h>

int analogInputsToReport = 0;  // bitwise array to store pin reporting
byte reportPINs[TOTAL_PORTS];  // PIN == input port

extern volatile unsigned long timer0_overflow_count; // timer0 from wiring.c
unsigned long nextExecuteTime; // for comparison with timer0_overflow_count


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
    pinMode(pin,OUTPUT);
    break;
  default:
    break;
  }
}

void analogWriteCallback(byte pin, int value) {
  setPinModeCallback(pin,PWM);
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
  } else { // everything but 0 enables reporting of that pin
    analogInputsToReport = analogInputsToReport | (1 << pin);
  }
}

void reportDigitalCallback(byte port, int value) {
  reportPINs[port] = (byte)value;

  // turn off analog reporting when used as digital
  if (port == ANALOG_PORT) {
    analogInputsToReport = 0;
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

  while (Firmata.available()) {
    Firmata.processInput();
  }

  if (timer0_overflow_count > nextExecuteTime) {  
    nextExecuteTime = timer0_overflow_count + 32; // run this every 33ms

    // report digital ports every time
    Firmata.sendDigitalPort(0, PIND &~ B00000011); // ignore Rx/Tx 0/1
    Firmata.sendDigitalPort(1, PINB);

    for (analogPin = 0; analogPin < TOTAL_ANALOG_PINS; analogPin++) {
      if (analogInputsToReport & (1 << analogPin)) {
        Firmata.sendAnalog(analogPin, analogRead(analogPin));
      }
    }
  }
}
