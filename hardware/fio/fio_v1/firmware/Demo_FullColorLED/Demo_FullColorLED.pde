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

#define RED_PIN  3
#define GREEN_PIN  10
#define BLUE_PIN  11
#define FLUSH_PIN  5

float output = 0;
float scaler = 0.7;

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
  switch (pin) {
  case RED_PIN:
  case GREEN_PIN:
  case BLUE_PIN:
    setPinModeCallback(pin, PWM);
    analogWrite(pin, 255 - value);  // active low
    break;
  case FLUSH_PIN:
    output = (float)value;
    break;
  default:
    break;
  }
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
  Firmata.attach(SYSTEM_RESET, systemResetCallback);

  for (i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
    pinMode(i, OUTPUT);
  }

  for (i = 0; i < TOTAL_PORTS; ++i) {
    reportPINs[i] = false;
  }

  setPinModeCallback(RED_PIN, PWM);
  setPinModeCallback(GREEN_PIN, PWM);
  setPinModeCallback(BLUE_PIN, PWM);
  analogWrite(RED_PIN, 255);
  analogWrite(GREEN_PIN, 255);
  analogWrite(BLUE_PIN, 255);

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

#if 0
    // report digital ports every time
    Firmata.sendDigitalPort(0, PIND &~ B00000011); // ignore Rx/Tx 0/1
    Firmata.sendDigitalPort(1, PINB);
#endif

    if (output > 0) {
      // a fading state
      output = output * scaler;
      analogWrite(RED_PIN, 255 - (byte)output); 
      analogWrite(GREEN_PIN, 255 - (byte)output); 
      analogWrite(BLUE_PIN, 255 - (byte)output); 
      if (output < 1.0) {
        // let's back to a normal state
        output = 0;
      }
    }

#if 0
    for (analogPin = 0; analogPin < TOTAL_ANALOG_PINS; analogPin++) {
      if (analogInputsToReport & (1 << analogPin)) {
        Firmata.sendAnalog(analogPin, analogRead(analogPin));
      }
    }
#endif
  }
}
