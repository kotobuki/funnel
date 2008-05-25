#include <m8c.h>        // part specific constants and macros

#pragma interrupt_handler XBEE_UART_RX_ISR

// total number of pins currently supported
#define TOTAL_ANALOG_PINS		(8)
#define TOTAL_DIGITAL_PINS		(10)

// digital pin modes
#define IN		(0)
#define OUT		(1)
#define PWM		(2)
#define SERVO	(3)

// Message Types
enum {
	ANALOG_MESSAGE = 0,	// the analog value for a single pin 
	DIGITAL_MESSAGE,	// 8-bits of digital pin data (one port) 
	REPORT_ANALOG,		// enable/disable the reporting of analog pin 
	REPORT_DIGITAL,		// enable/disable the reporting of a digital port 
	SET_PIN_MODE,		// change the pin mode between INPUT/OUTPUT/PWM/etc.
};

// start the library
void Firmata_begin(void);

// send the protocol version to the host computer
void Firmata_printVersion(void);

// check to see if there are any incoming messages in the buffer
BOOL Firmata_available(void);

void clearFlag(void);

// process incoming messages from the buffer, sending the data to any registered callback functions
void Firmata_processInput(void);

// attach a function to an incoming message type
void Firmata_attach(BYTE command, void* myHandler);

// detach a function from an incoming message type
void Firmata_detach(BYTE command);

// send an analog message
void Firmata_sendAnalog(BYTE pin, WORD value);

// send digital ports as individual bytes
void Firmata_sendDigitalPort(BYTE port, WORD portData);

// begin a packet
// NOTE: Original extention for FIO 8x8 to support XBee API mode 2
void Firmata_beginPacket(void);

// close and send a packet
// NOTE: Original extention for FIO 8x8 to support XBee API mode 2
void Firmata_endPacket(void);

// This is non-Firmata library standard API
void reportIOStatus(WORD dioStatus, WORD *adcStatus, BYTE adcChannels);
