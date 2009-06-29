/*
 Copyright (C) 2009 Shigeru Kobayashi.  All rights reserved.
 Copyright (C) 2009 Jeff Hoefs.  All rights reserved.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 See file LICENSE.txt for further informations on licensing terms.
 */

/*
  Issues with current version:
  - Analog pins cannot be configured as digital inputs (same as StandardFirmata)
  - Arduino Mega and Wiring I/O board is not supported yet
 */

#include <Wire.h>
#include <Firmata.h>


#define I2C_WRITE B00000000
#define I2C_READ B00001000
#define I2C_READ_CONTINUOUSLY B00010000
#define I2C_STOP_READING B00011000
#define I2C_READ_WRITE_MODE_MASK B00011000
#define I2C_10BIT_ADDRESS_MODE_MASK B00100000

#define MAX_QUERIES 8
#define MINIMUM_SAMPLING_INTERVAL 10

#define REGISTER_NOT_SPECIFIED -1

struct i2c_device_info {
  byte addr;
  byte reg;
  byte bytes;
};

i2c_device_info query[MAX_QUERIES];

byte i2cRxData[32];
boolean readingContinuously = false;
byte queryIndex = 0;

/*==============================================================================
 * GLOBAL VARIABLES
 *============================================================================*/

/* analog inputs */
int analogInputsToReport = 0; // bitwise array to store pin reporting
int analogPin = 0; // counter for reading analog pins

/* digital pins */
byte reportPINs[TOTAL_PORTS];   // PIN == input port
byte previousPINs[TOTAL_PORTS]; // PIN == input port
byte pinStatus[TOTAL_DIGITAL_PINS]; // store pin status, default OUTPUT
byte portStatus[TOTAL_PORTS];

/* timer variables */
unsigned long currentMillis;     // store the current value from millis()
unsigned long nextExecuteMillis; // for comparison with currentMillis
unsigned int samplingInterval = 32;  // default sampling interval is 33ms
unsigned int i2cReadDelayTime = 0;  // default delay time between i2c read request and Wire.requestFrom()
unsigned int powerPinsEnabled = 0;  // use as boolean to prevent enablePowerPins from being called more than once


/*==============================================================================
 * FUNCTIONS
 *============================================================================*/

void readAndReportData(byte address, int theRegister, byte numBytes) {
  // allow I2C requests that don't require a register read
  // for example, some devices using an interrupt pin to signify new data available
  // do not always require the register read so upon interrupt you call Wire.requestFrom()  
  if (theRegister != REGISTER_NOT_SPECIFIED) {
    Wire.beginTransmission(address);
    Wire.send((byte)theRegister);
    Wire.endTransmission();
    delayMicroseconds(i2cReadDelayTime);  // delay is necessary for some devices such as WiiNunchuck
  } else {
    theRegister = 0;  // fill the register with a dummy value
  }

  Wire.requestFrom(address, numBytes);  // all bytes are returned in requestFrom

  // check to be sure correct number of bytes were returned by slave
  if(numBytes == Wire.available()) {
    i2cRxData[0] = address;
    i2cRxData[1] = theRegister;
    for (int i = 0; i < numBytes; i++) {
      i2cRxData[2 + i] = Wire.receive();
    }
  }
  else {
    if(numBytes > Wire.available()) {
      Firmata.sendString("I2C Read Error: Too many bytes received");
    } else {
      Firmata.sendString("I2C Read Error: Too few bytes received"); 
    }
  }

  // send slave address, register and received bytes
  Firmata.sendSysex(SYSEX_I2C_REPLY, numBytes + 2, i2cRxData);
}

void sysexCallback(byte command, byte argc, byte *argv)
{
  byte mode;
  byte slaveAddress;
  byte slaveRegister;
  byte data;
  unsigned int delayTime;  

  if (command == SYSEX_I2C_REQUEST) {
    mode = argv[1] & I2C_READ_WRITE_MODE_MASK;
    if (argv[1] & I2C_10BIT_ADDRESS_MODE_MASK) {
      Firmata.sendString("10-bit addressing mode is not yet supported");
      return;
    }
    else {
      slaveAddress = argv[0];
    }

    switch(mode) {
    case I2C_WRITE:
      Wire.beginTransmission(slaveAddress);
      for (byte i = 2; i < argc; i += 2) {
        data = argv[i] + (argv[i + 1] << 7);
        Wire.send(data);
      }
      Wire.endTransmission();
      delayMicroseconds(70);
      break;
    case I2C_READ:
      if (argc == 6) {
        // a slave register is specified
        slaveRegister = argv[2] + (argv[3] << 7);
        data = argv[4] + (argv[5] << 7);  // bytes to read
        readAndReportData(slaveAddress, (int)slaveRegister, data);
      }
      else {
        // a slave register is NOT specified
        data = argv[2] + (argv[3] << 7);  // bytes to read
        readAndReportData(slaveAddress, (int)REGISTER_NOT_SPECIFIED, data);
      }
      break;
    case I2C_READ_CONTINUOUSLY:
      if ((queryIndex + 1) >= MAX_QUERIES) {
        // too many queries, just ignore
        Firmata.sendString("too many queries");
        break;
      }
      query[queryIndex].addr = slaveAddress;
      query[queryIndex].reg = argv[2] + (argv[3] << 7);
      query[queryIndex].bytes = argv[4] + (argv[5] << 7);
      readingContinuously = true;
      queryIndex++;
      break;
    case I2C_STOP_READING:
      readingContinuously = false;
      queryIndex = 0;
      break;
    default:
      break;
    }
  }
  else if (command == SYSEX_SAMPLING_INTERVAL) {
    samplingInterval = argv[0] + (argv[1] << 7);

    if (samplingInterval < MINIMUM_SAMPLING_INTERVAL) {
      samplingInterval = MINIMUM_SAMPLING_INTERVAL;
    }

    samplingInterval -= 1;
  }
  else if (command == I2C_CONFIG) {
    delayTime = (argv[4] + (argv[5] << 7));                        // MSB
    delayTime = (delayTime << 8) + (argv[2] + (argv[3] << 7));     // add LSB

    if((argv[0] + (argv[1] << 7)) > 0) {
      enablePowerPins(PC3, PC2);
    }

    if(delayTime > 0) {
      i2cReadDelayTime = delayTime;
    }

    if(argc > 6) {
      // If you extend I2C_Config, handle your data here
    }

  }   
}

void systemResetCallback()
{
  readingContinuously = false;
  queryIndex = 0;
}

/* reference: BlinkM_funcs.h by Tod E. Kurt, ThingM, http://thingm.com/ */
// Enables Pins A2 and A3 to be used as GND and Power
// so that I2C devices can be plugged directly
// into Arduino header (pins A2 - A5)
static void enablePowerPins(byte pwrpin, byte gndpin)
{
  if(powerPinsEnabled == 0) {
    
    // moved here from setup()
    // are these 2 lines dependent on anything else from setup()?
    portStatus[2] = B00111100;  // ignore A2-5
    if(reportPINs[ANALOG_PORT]) outputPort(ANALOG_PORT, PINC &~ B00111100);  // ignore A2-5
    
    DDRC |= _BV(pwrpin) | _BV(gndpin);
    PORTC &=~ _BV(gndpin);
    PORTC |=  _BV(pwrpin);
    powerPinsEnabled = 1;
    Firmata.sendString("Power pins enabled");
    delay(100);
  }
}

void outputPort(byte portNumber, byte portValue)
{
  portValue = portValue &~ portStatus[portNumber];
  if(previousPINs[portNumber] != portValue) {
    Firmata.sendDigitalPort(portNumber, portValue);
    previousPINs[portNumber] = portValue;
    Firmata.sendDigitalPort(portNumber, portValue);
  }
}

/* -----------------------------------------------------------------------------
 * check all the active digital inputs for change of state, then add any events
 * to the Serial output queue using Serial.print()
 */
void checkDigitalInputs(void)
{
  byte i, tmp;
  for(i=0; i < TOTAL_PORTS; i++) {
    if(reportPINs[i]) {
      switch(i) {
      case 0:
        outputPort(0, PIND &~ B00000011);
        break; // ignore Rx/Tx 0/1
      case 1:
        outputPort(1, PINB);
        break;
      case ANALOG_PORT:
        if(powerPinsEnabled) {
           outputPort(ANALOG_PORT, PINC &~ B00111100);  // ignore A2-5
        } else {
           outputPort(ANALOG_PORT, PINC &~ B00110000);  // ignore A4-5
        }
        break;
      }
    }
  }
}

// -----------------------------------------------------------------------------
/* sets the pin mode to the correct state and sets the relevant bits in the
 * two bit-arrays that track Digital I/O and PWM status
 */
void setPinModeCallback(byte pin, int mode) {
  byte port = 0;
  byte offset = 0;
  byte maxPin;    // To do: use a more descriptive variable name?

  if (pin < 8) {
    port = 0;
    offset = 0;
  }
  else if (pin < 14) {
    port = 1;
    offset = 8;
  }
  else if (pin < 22) {
    port = 2;
    offset = 14;
  }

  if(powerPinsEnabled) {
    maxPin = 16;   // ignore RxTx (pins 0 and 1) and A2-7
  } else {
    maxPin = 18;  // ignore RxTx (pins 0 and 1) and A4-7
  }

  if(pin > 1 && pin < maxPin) {
    pinStatus[pin] = mode;
    switch(mode) {
    case INPUT:
      pinMode(pin, INPUT);
      portStatus[port] = portStatus[port] &~ (1 << (pin - offset));
      break;
    case OUTPUT:
      digitalWrite(pin, LOW); // disable PWM
    case PWM:
      pinMode(pin, OUTPUT);
      portStatus[port] = portStatus[port] | (1 << (pin - offset));
      break;
      //case ANALOG: // TODO figure this out
    default:
      Firmata.sendString("");
    }
  }
}

void analogWriteCallback(byte pin, int value)
{
  setPinModeCallback(pin,PWM);
  analogWrite(pin, value);
}

void digitalWriteCallback(byte port, int value)
{
  switch(port) {
  case 0: // pins 2-7 (don't change Rx/Tx, pins 0 and 1)
    // 0xFF03 == B1111111100000011    0x03 == B00000011
    PORTD = (value &~ 0xFF03) | (PORTD & 0x03);
    break;
  case 1: // pins 8-13 (14,15 are disabled for the crystal)
    PORTB = (byte)value;
    break;
  case 2: // analog pins used as digital
    if(powerPinsEnabled) {
      // 0xFF3C == B1111111100111100    0x3C == B00111100
      PORTC = (value &~ 0xFF3C) | (PORTC & 0x3C);
    } else {
      // 0xFF30 == B1111111100110000    0x30 == B00110000
      PORTC = (value &~ 0xFF30) | (PORTC & 0x30);      
    }
    break;
  }
}

// -----------------------------------------------------------------------------
/* sets bits in a bit array (int) to toggle the reporting of the analogIns
 */
//void FirmataClass::setAnalogPinReporting(byte pin, byte state) {
//}
void reportAnalogCallback(byte pin, int value)
{
  
  if(powerPinsEnabled) {
    // ignore A2-5
    if (16 <= pin && pin <= 19)
      return;    
  } else {
    // ignore A4-5
    if (18 <= pin && pin <= 19)
      return;    
  }
  
  if(value == 0) {
    analogInputsToReport = analogInputsToReport &~ (1 << pin);
  }
  else { // everything but 0 enables reporting of that pin
    analogInputsToReport = analogInputsToReport | (1 << pin);
  }
}

void reportDigitalCallback(byte port, int value)
{
  reportPINs[port] = (byte)value;
  if(port == ANALOG_PORT) // turn off analog reporting when used as digital
    analogInputsToReport = 0;
}

/*==============================================================================
 * SETUP()
 *============================================================================*/
void setup()
{
  byte i;

  Firmata.setFirmwareVersion(2, 0);

  Firmata.attach(ANALOG_MESSAGE, analogWriteCallback);
  Firmata.attach(DIGITAL_MESSAGE, digitalWriteCallback);
  Firmata.attach(REPORT_ANALOG, reportAnalogCallback);
  Firmata.attach(REPORT_DIGITAL, reportDigitalCallback);
  Firmata.attach(SET_PIN_MODE, setPinModeCallback);
  Firmata.attach(START_SYSEX, sysexCallback);
  Firmata.attach(SYSTEM_RESET, systemResetCallback);

  portStatus[0] = B00000011;  // ignore Tx/RX pins
  portStatus[1] = B11000000;  // ignore 14/15 pins
  portStatus[2] = B00110000;  // ignore A4-5

  //    for(i=0; i<TOTAL_DIGITAL_PINS; ++i) { // TODO make this work with analogs
  for(i=0; i<14; ++i) {
    setPinModeCallback(i,OUTPUT);
  }

  // set all outputs to 0 to make sure internal pull-up resistors are off
  PORTB = 0; // pins 8-15
  PORTC = 0; // analog port
  PORTD = 0; // pins 0-7

  // TODO rethink the init, perhaps it should report analog on default
  for(i=0; i<TOTAL_PORTS; ++i) {
    reportPINs[i] = false;
  }
  // TODO: load state from EEPROM here

  /* send digital inputs here, if enabled, to set the initial state on the
   * host computer, since once in the loop(), this firmware will only send
   * digital data on change. */
  if(reportPINs[0]) outputPort(0, PIND &~ B00000011); // ignore Rx/Tx 0/1
  if(reportPINs[1]) outputPort(1, PINB);
  if(reportPINs[ANALOG_PORT]) outputPort(ANALOG_PORT, PINC &~ B00110000);  // ignore A4-5

  // It seems that Arduino Pro Mini won't work with 115200bps
  if (F_CPU == 8000000) {
    Firmata.begin(19200);
  }
  else {
    Firmata.begin(57600);   // 115200 is too fast when using I2C
  }

  Wire.begin();
}

/*==============================================================================
 * LOOP()
 *============================================================================*/
void loop()
{
  checkDigitalInputs();
  currentMillis = millis();
  if(currentMillis > nextExecuteMillis) {
    nextExecuteMillis = currentMillis + samplingInterval; // run this every 20ms

    while(Firmata.available())
      Firmata.processInput();

    for(analogPin=0;analogPin<TOTAL_ANALOG_PINS;analogPin++) {
      if( analogInputsToReport & (1 << analogPin) ) {
        Firmata.sendAnalog(analogPin, analogRead(analogPin));
      }
    }

    for (byte i = 0; i < queryIndex; i++) {
      readAndReportData(query[i].addr, query[i].reg, query[i].bytes);
    }
  }
}
