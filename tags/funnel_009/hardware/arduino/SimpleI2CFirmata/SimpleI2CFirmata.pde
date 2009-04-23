#include <Wire.h>
#include <Firmata.h>

//#define ENABLE_POWER_PINS
#define SYSEX_I2C_REQUEST 0x76
#define SYSEX_I2C_REPLY 0x77
#define SYSEX_SAMPLING_INTERVAL 0x78
#define I2C_WRITE B00000000
#define I2C_READ B00001000
#define I2C_READ_CONTINUOUSLY B00010000
#define I2C_STOP_READING B00011000
#define I2C_READ_WRITE_MODE_MASK B00011000
#define I2C_10BIT_ADDRESS_MODE_MASK B00100000

#define MAX_QUERIES 8

unsigned long currentMillis;     // store the current value from millis()
unsigned long nextExecuteMillis; // for comparison with currentMillis
unsigned int samplingInterval = 32;  // default sampling interval is 33ms

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

void readAndReportData(byte address, int theRegister, byte numBytes) {
  if (theRegister != REGISTER_NOT_SPECIFIED) {
    Wire.beginTransmission(address);
    Wire.send((byte)theRegister);
    Wire.endTransmission();
  } 
  else {
    theRegister = 0;  // fill the register with a dummy value
  }

  Wire.requestFrom(address, numBytes);

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
      Firmata.sendString("I2C Read Error: Try lowering the baud rate");
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
}

void systemResetCallback()
{
  readingContinuously = false;
  queryIndex = 0;
}

// reference: BlinkM_funcs.h by Tod E. Kurt, ThingM, http://thingm.com/
static void enablePowerPins(byte pwrpin, byte gndpin)
{
  DDRC |= _BV(pwrpin) | _BV(gndpin);
  PORTC &=~ _BV(gndpin);
  PORTC |=  _BV(pwrpin);
  delay(100);
}

void setup()
{
  Firmata.setFirmwareVersion(2, 0);

  Firmata.attach(START_SYSEX, sysexCallback);
  Firmata.attach(SYSTEM_RESET, systemResetCallback);

  for (int i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
    pinMode(i, OUTPUT);
  }

#ifdef ENABLE_POWER_PINS
  // AD2, AD3, AD4, AD5
  // GND, PWR, SDA, SCL: e.g. BlinkM, HMC6352
  enablePowerPins(PC3, PC2);
#endif

  // It seems that Arduino Pro Mini won't work with 115200bps
  if (F_CPU == 8000000) {
    Firmata.begin(19200);
  }
  else {
    Firmata.begin(57600);  // I2C data is not reliable at higher baud rates
  }

  Wire.begin();
}

void loop()
{
  while (Firmata.available()) {
    Firmata.processInput();
  }

  currentMillis = millis();
  if (currentMillis > nextExecuteMillis) {
    nextExecuteMillis = currentMillis + samplingInterval;

    for (byte i = 0; i < queryIndex; i++) {
      readAndReportData(query[i].addr, query[i].reg, query[i].bytes);
    }
  }
}
