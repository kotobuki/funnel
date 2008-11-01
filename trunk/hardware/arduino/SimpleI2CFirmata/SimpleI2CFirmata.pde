#include <Wire.h>
#include <Firmata.h>

#define SYSEX_I2C 0x76
#define I2C_WRITE 0
#define I2C_READ 1
#define I2C_READ_CONTINUOUSLY 2
#define I2C_STOP_READING 3

unsigned long currentMillis;     // store the current value from millis()
unsigned long nextExecuteMillis; // for comparison with currentMillis

byte slaveAddress;
byte slaveRegister;
byte i2cRxData[32];
boolean readingContinuously = false;

void setRegister(int address, int thisRegister) {
  Wire.beginTransmission(address);
  Wire.send(thisRegister);
  Wire.endTransmission();
}

void readAndReportData(int address, int numBytes) {
  Wire.requestFrom(address, numBytes);

  // TODO: Do timeout here if needed
  while (Wire.available() < numBytes) {

  }

  i2cRxData[0] = address;
  for (int i = 0; i < numBytes; i++) {
    i2cRxData[i + 1] = Wire.receive();
  }

  Firmata.sendSysex(SYSEX_I2C, numBytes + 1, i2cRxData);
}

void sysexCallback(byte command, byte argc, byte *argv)
{
  byte *p = argv;
  byte mode;
  char message[32];
  int i = 0;
  int length;
  byte data;

  if (command == SYSEX_I2C) {
    mode = *(p++);
    slaveAddress = *(p++);

    switch(mode) {
    case I2C_WRITE:
      Wire.beginTransmission(slaveAddress);
      length = (argc - 2) / 2;
      for (i = 0; i < length; i++) {
        data = *(p++) + (*(p++) << 7);
        Wire.send(data);
      }
      Wire.endTransmission();
      delayMicroseconds(70);
      break;
    case I2C_READ:
      slaveRegister = *(p++) + (*(p++) << 7);
      data = *(p++) + (*(p++) << 7);  // bytes to read
      setRegister(slaveAddress, slaveRegister);
      readAndReportData(slaveAddress, data);
      break;
    case I2C_READ_CONTINUOUSLY:
      slaveRegister = *(p++);
      slaveRegister += *(p++) << 7;
      data = *(p++);
      data += *(p++) << 7;
      readingContinuously = true;
      break;
    case I2C_STOP_READING:
      readingContinuously = false;
      break;
    default:
      break;
    }
  }
}

void setup()
{
  Firmata.setFirmwareVersion(2, 0);
  Firmata.attach(START_SYSEX, sysexCallback);

  for (int i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
    pinMode(i, OUTPUT);
  }

  Firmata.begin();
  Wire.begin();
}

void loop()
{
  while (Firmata.available()) {
    Firmata.processInput();
  }

  currentMillis = millis();
  if(currentMillis > nextExecuteMillis) {  
    nextExecuteMillis = currentMillis + 19; // run this every 20ms

    // TODO: read continuously and report here if requested
  }
}
