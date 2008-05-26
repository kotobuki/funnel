#include "PSoCAPI.h"    // PSoC API definitions for all User Modules
#include "stdlib.h"

#include "xbee.h"
#include "fio.h"
#include "ring_buffer.h"

/*
 * XBee Related Definitions
 */
#define FRAME_DELIMITER	(0x7E)
#define ESCAPE			(0x7D)
#define XON				(0x11)
#define XOFF			(0x13)
#define RX_PACKET_16BIT		(0x81)
#define RX_IO_STATUS_16BIT	(0x83)
#define AT_COMMAND_RESPONSE	(0x88)
#define TX_STATUS_MESSAGE	(0x89)
#define MODEM_STATUS		(0x8A)

const BYTE IDX_LENGTH_MSB = 1;
const BYTE IDX_LENGTH_LSB = 2;
const BYTE IDX_API_IDENTIFIER = 3;
const BYTE IDX_SOURCE_ADDRESS_MSB = 4;
const BYTE IDX_SOURCE_ADDRESS_LSB = 5;
const BYTE IDX_RSSI = 6;
const BYTE IDX_SAMPLES = 8;
const BYTE IDX_RF_DATA = 8;
const BYTE IDX_IO_ENABLE_MSB = 9;
const BYTE IDX_IO_ENABLE_LSB = 10;
const BYTE IDX_IO_STATUS_START = 11;


/*
 * Firmata Related Definitions
 */
#define FIRMATA_MAJOR_VERSION   1 // for non-compatible changes
#define FIRMATA_MINOR_VERSION   0 // for backwards compatible changes

void (*pAnalogMessageHandler)(BYTE pin, WORD value) = NULL;
void (*pDigitalMessageHandler)(BYTE pin, WORD value) = NULL;
void (*pReportAnalogHandler)(BYTE pin, WORD value) = NULL;
void (*pReportDigitalHandler)(BYTE pin, WORD value) = NULL;
void (*pSetPinModeHandler)(BYTE pin, WORD value) = NULL;

BYTE rfDataIdx = 0;
BYTE rfData[128];
BYTE frameData[128];
BYTE txBuffer[128];

BOOL wasEscaped = FALSE;
BYTE rxIndex = 0;
BYTE receivedPacket[128];
BYTE rxBytesToReceive = 0;
WORD rxSum = 0;

char rxBuffer[256];
rbuffer_t rxBufferInfo;
//BOOL hasPacketToHandle = FALSE;
//BYTE receivedPacketSize = 0;

// max number of data bytes in non-SysEx messages
#define MAX_DATA_BYTES	(2)

#define DIGITAL_MESSAGE			(0x90) // send data for a digital pin
#define ANALOG_MESSAGE			(0xE0) // send data for an analog pin (or PWM)
#define REPORT_ANALOG_PIN		(0xC0) // enable analog input by pin #
#define REPORT_DIGITAL_PORTS	(0xD0) // enable digital input by port pair
#define START_SYSEX				(0xF0) // start a MIDI SysEx message
#define SET_DIGITAL_PIN_MODE	(0xF4) // set a digital pin to INPUT or OUTPUT 
#define END_SYSEX				(0xF7) // end a MIDI SysEx message
#define REPORT_VERSION			(0xF9) // report firmware version
#define SYSTEM_RESET			(0xFF) // reset from MIDI

// local functions
void parseFirmataMessage(BYTE inputData);
void sendTransmitRequest(WORD destAddress, BYTE rfDataLength);
void sendCommand(BYTE frameDataLength);
void putByteToPacket(BYTE data);

// variables for Firmata like message parser
BYTE bytesToReceive = 0;
BYTE storedInputData[MAX_DATA_BYTES + 1];
BYTE executeMultiByteCommand = 0;
BYTE multiByteChannel = 0;


void Firmata_begin()
{
	if (rbuffer_init(&rxBufferInfo, rxBuffer, 256) != NULL) {
		UART_EnableInt();
		UART_Start(UART_PARITY_NONE);
	}
}

void Firmata_printVersion(void)
{
	rfData[0] = REPORT_VERSION;
	rfData[1] = (BYTE)FIRMATA_MAJOR_VERSION;
	rfData[2] = (BYTE)FIRMATA_MINOR_VERSION;
	sendTransmitRequest(0x0000, 3);
}

BOOL Firmata_available(void)
{
	return (rbuffer_size(&rxBufferInfo) > 0);
}

void parseXBeePacket(void)
{
	BYTE length = 0;
	BYTE i = 0;

//	hasPacketToHandle = FALSE;

	switch ((BYTE)receivedPacket[IDX_API_IDENTIFIER]) {
	case RX_PACKET_16BIT:
		// {0x7E}+{0x00}+{0x**}+{0x81}+{MSB}+{LSB}+{RSSI}+{OPTION}+{RF Data}+{Checksum}
		// OPTION
		// bit 1: Address Broadcast
		// bit 2: PAN Broadcast
		length = receivedPacket[IDX_LENGTH_LSB] - 5;	// RF Data Length
		for (i = 0; i < length; i++) {
			parseFirmataMessage(receivedPacket[IDX_RF_DATA + i]);
		}
		break;
	case TX_STATUS_MESSAGE:
		// {0x7E}+{0x00+0x03}+{0x89}+{Frame ID}+{Status}+{Checksum}
		switch (receivedPacket[IDX_API_IDENTIFIER + 2]) {
		case 0x01:
			// NO ACK
			break;
		case 0x02:
			// CCA FAILURE
			break;
		case 0x03:
			// PURGED
			break;
		default:
			break;
		}
		break;
	case MODEM_STATUS:
		// {0x7E}+{0x00+0x02}+{0x8A}+{cmdData}+{sum}
		switch (receivedPacket[IDX_API_IDENTIFIER + 1]) {
		case 0x00:
			// HARDWARE RESET
			break;
		case 0x01:
			// WDT RESET
			break;
		case 0x02:
			// ASSOCIATED
			break;
		case 0x03:
			// DISASSOCIATED
			break;
		case 0x04:
			// SYNCHRONIZATION LOST
			break;
		case 0x05:
			// COORDINATOR REALIGNMENT
			break;
		case 0x06:
			// COORDINATOR STARTED
			break;
		default:
			break;
		}
		break;
	default:
		break;
	}
}

void Firmata_attach(BYTE command, void* myHandler)
{
	switch (command) {
	case ANALOG_MESSAGE:
		pAnalogMessageHandler = myHandler;
		break;
	case DIGITAL_MESSAGE:
		pDigitalMessageHandler = myHandler;
		break;
	case REPORT_ANALOG:
		pReportAnalogHandler = myHandler;
		break;
	case REPORT_DIGITAL:
		pReportDigitalHandler = myHandler;
		break;
	case SET_PIN_MODE:
		pSetPinModeHandler = myHandler;
		break;
	default:
		break;
	}
}

void Firmata_detach(BYTE command)
{
	switch (command) {
	case ANALOG_MESSAGE:
		pAnalogMessageHandler = NULL;
		break;
	case DIGITAL_MESSAGE:
		pDigitalMessageHandler = NULL;
		break;
	case REPORT_ANALOG:
		pReportAnalogHandler = NULL;
		break;
	case REPORT_DIGITAL:
		pReportDigitalHandler = NULL;
		break;
	case SET_PIN_MODE:
		pSetPinModeHandler = NULL;
		break;
	default:
		break;
	}
}

void Firmata_sendAnalog(BYTE pin, WORD value) {
	putByteToPacket(ANALOG_MESSAGE | (pin & 0xF));
	putByteToPacket((BYTE)(value % 0x80));	// LSB
	putByteToPacket((BYTE)(value >> 7));	// MSB
}

void Firmata_sendDigitalPort(BYTE port, WORD portData) {
	putByteToPacket(DIGITAL_MESSAGE | (port & 0xF));
	putByteToPacket((BYTE)(portData % 0x80));	// Tx bits 0-6
	putByteToPacket((BYTE)(portData >> 7));		// Tx bits 7-13
}

void Firmata_beginPacket(void) {
	rfDataIdx = 0;
}

void Firmata_endPacket(void) {
	// send the message to the coordinator of the PAN
	sendTransmitRequest(0x0000, rfDataIdx);
}


void reportIOStatus(WORD dioStatus, WORD *adcStatus, BYTE adcChannels)
{
	BYTE i = 0;
	BYTE idx = 0;

	// NOTE: modify here to report more than 14 digital pins
	rfData[0] = DIGITAL_MESSAGE;
	rfData[1] = (BYTE)(dioStatus % 0x80);
	rfData[2] = (BYTE)(dioStatus >> 7);
	idx = 3;

	for (i = 0; i < adcChannels; i++) {
		rfData[idx] = ANALOG_MESSAGE + i;			// analog in: 0xE0 - 0xEF
		idx++;
		rfData[idx] = (BYTE)(adcStatus[i] % 0x80);	// analog in value (LSB)
		idx++;
		rfData[idx] = (BYTE)(adcStatus[i] >> 7);	// analog in value (MSB)
		idx++;
	}
	// send the message to the coordinator of the PAN
	sendTransmitRequest(0x0000, idx);
}

void XBEE_UART_RX_ISR()
{
	BYTE inputData = UART_bReadRxData();
	rbuffer_write(&rxBufferInfo, &inputData, 1);
}

void Firmata_processInput() {
	BYTE inputData = 0;

	while (rbuffer_size(&rxBufferInfo) > 0) {
		rbuffer_read(&rxBufferInfo, &inputData, 1);
	
		if (inputData == FRAME_DELIMITER) {
			rxIndex = 0;
			rxSum = 0;
			wasEscaped = FALSE;
			receivedPacket[rxIndex] = inputData;
		} else if (inputData == ESCAPE) {
			wasEscaped = TRUE;
		} else {
			rxIndex++;
			if (wasEscaped) {
				receivedPacket[rxIndex] = (inputData ^ 0x20);
				wasEscaped = FALSE;
			} else {
				receivedPacket[rxIndex] = inputData;
			}
	
			if (rxIndex == IDX_LENGTH_MSB) {
				rxBytesToReceive = (inputData << 8);
			} else if (rxIndex == IDX_LENGTH_LSB) {
				// [START][LENGTH MSB][LENGTH LSB][FRAME DATA][CHECKSUM]
				rxBytesToReceive = rxBytesToReceive + inputData + 4;
			} else if (rxIndex == (rxBytesToReceive - 1)) {
#if 0
				if ((rxSum & 0xFF) + rxData[rxBytesToReceive - 1] == 0xFF) {
#else
				// ignore checksum (FOR TESTING USE ONLY)
				if (1) {
#endif
					parseXBeePacket();
				}
			} else if (rxIndex > 2) {
				rxSum += inputData;
			}
		}
	}
}

void parseFirmataMessage(BYTE inputData) {
	BYTE command = 0;
	WORD value = 0;
	
	if (bytesToReceive > 0 & inputData < 128) {
		bytesToReceive--;
		storedInputData[bytesToReceive] = inputData;
		if ((executeMultiByteCommand != 0) && (bytesToReceive == 0)) {
 			switch (executeMultiByteCommand) {
			case ANALOG_MESSAGE:
				if (pAnalogMessageHandler != NULL) {
					value = (BYTE)((storedInputData[0] << 7) + storedInputData[1]);
					pAnalogMessageHandler(multiByteChannel, value);
				}
				break;
			case DIGITAL_MESSAGE:
				if (pDigitalMessageHandler != NULL) {
					value = (WORD)((storedInputData[0] << 7) + storedInputData[1]);
					pDigitalMessageHandler(0, value);
				}
				break;
			case SET_DIGITAL_PIN_MODE:
				if (pSetPinModeHandler != NULL) {
					pSetPinModeHandler(storedInputData[1], storedInputData[0]); // (pin#, mode)
				}
				break;
			case REPORT_ANALOG_PIN:
				if (pReportAnalogHandler != NULL) {
					pReportAnalogHandler(multiByteChannel, storedInputData[0]);
				}
				break;
			case REPORT_DIGITAL_PORTS:
				if (pReportDigitalHandler != NULL) {
					pReportDigitalHandler(multiByteChannel, storedInputData[0]);
				}
				break;
			default:
				break;
 			}
 			executeMultiByteCommand = 0;
 		}
	} else {
		if (inputData < 0xF0) {
			command = inputData & 0xF0;
			multiByteChannel = inputData & 0x0F;
		} else {
			command = inputData;
		}

		switch (command) {
		case ANALOG_MESSAGE:
		case DIGITAL_MESSAGE:
		case SET_DIGITAL_PIN_MODE:
			bytesToReceive = 2;	// two data bytes needed
			executeMultiByteCommand = command;
			break;
		case REPORT_ANALOG_PIN:
		case REPORT_DIGITAL_PORTS:
			bytesToReceive = 1; // one data byte needed
			executeMultiByteCommand = command;
			break;
		case SYSTEM_RESET:
			// this doesn't do anything yet
			break;
		case REPORT_VERSION:
			Firmata_printVersion();
			break;
		default:
			break;
		}
	}	
}

// TODO: Modify this function to avaid deep copy
void sendTransmitRequest(WORD destAddress, BYTE rfDataLength) {
	BYTE frameDataLength = 5 + rfDataLength;
	BYTE idx = 0;
	
	frameData[0] = 0x01; // Transmit Request
	frameData[1] = 0x00; // Frame ID (0x00 means no ACK)
	frameData[2] = (BYTE)(destAddress >> 8);
	frameData[3] = (BYTE)(destAddress & 0xFF);
	frameData[4] = 0x01; // Options (0x00: with ACK, 0x01: without ACK)
	for (idx = 0; idx < rfDataLength; idx++) {
		frameData[5 + idx] = rfData[idx];
	}
	sendCommand(frameDataLength);
}

void sendCommand(BYTE frameDataLength) {
	WORD sum = 0;
	BYTE length = 0;
	BYTE escaped = 0;
	BYTE idx = 0;
	BYTE txLength;

	for (idx = 0; idx < frameDataLength; idx++) {
		switch (frameData[idx]) {
		case FRAME_DELIMITER:
		case ESCAPE:
		case XON:
		case XOFF:
			txBuffer[3 + length] = ESCAPE;
			length++;
			txBuffer[3 + length] = (BYTE)(frameData[idx] ^ 0x20);
			length++;
			escaped++;
			break;
		default:
			txBuffer[3 + length] = frameData[idx];
			length++;
			break;
		}
		sum += frameData[idx];
	}
	txBuffer[0] = 0x7E; // FRAME_DELIMITER
	txBuffer[1] = 0x00; // Length (MSB)
	txBuffer[2] = length - escaped; // Length (LSB)
	txBuffer[3 + length] = (BYTE)(0xFF - (sum & 0xFF)); // Checksum
	txLength = length + 4;

	UART_Write(txBuffer, txLength);
}

void putByteToPacket(BYTE data) {
	rfData[rfDataIdx] = data;
	rfDataIdx++;
}
