#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

#include "xbee.h"
#include "fio.h"

#pragma interrupt_handler UART_RX_ISR
#pragma interrupt_handler UART_TX_ISR

#define FRAME_DELIMITER	(0x7E)
#define ESCAPE			(0x7D)
#define XON				(0x11)
#define XOFF			(0x13)
#define RX_PACKET_16BIT		(0x81)
#define RX_IO_STATUS_16BIT	(0x83)
#define AT_COMMAND_RESPONSE	(0x88)
#define TX_STATUS_MESSAGE	(0x89)
#define MODEM_STATUS		(0x8A)

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

BYTE rfData[128];
BYTE frameData[128];
BYTE txBuffer[128];

BOOL wasEscaped = FALSE;
BYTE rxIndex = 0;
BYTE rxData[100];
BYTE rxBytesToReceive = 0;
WORD rxSum = 0;

// total number of pins currently supported
#define TOTAL_ANALOG_PINS		(8)
#define TOTAL_DIGITAL_PINS		(10)

// for comparing along with INPUT and OUTPUT
#define IN		(0)
#define OUT		(1)
#define PWM		(2)
#define SERVO	(3)

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


// variables for Firmata like message parser
unsigned char bytesToReceive = 0;
unsigned char storedInputData[3];
unsigned char analogData[14];

unsigned char executeMultiByteCommand = 0;
unsigned char multiByteChannel = 0;


BOOL hasPacketToHandle = FALSE;

BOOL HasPacketToHandle(void)
{
	return hasPacketToHandle;
}

void ClearHasPacketFlag(void)
{
	hasPacketToHandle = FALSE;
}

void ReportIOStatus(WORD ioEnable, WORD dioStatus, WORD *adcStatus, BYTE adcChannels)
{
	BYTE i = 0;
	BYTE idx = 0;
#if 0
	rfData[0] = 0x83;	// API Identifier
	rfData[1] = 0xFF;	// From Address (MSB)
	rfData[2] = 0xFF;	// From Address (LSB)
	rfData[3] = 0x00;	// RSSI
	rfData[4] = 0x00;	// Option
	rfData[5] = 0x01;	// Samples
	rfData[6] = (BYTE)(ioEnable >> 8);
	rfData[7] = (BYTE)(ioEnable & 0xFF);
	rfData[8] = (BYTE)(dioStatus >> 8);
	rfData[9] = (BYTE)(dioStatus & 0xFF);
	idx = 10;
	for (i = 0; i < adcChannels; i++) {
		rfData[idx] = (BYTE)(adcStatus[i] >> 8);
		idx++;
		rfData[idx] = (BYTE)(adcStatus[i] & 0xFF);
		idx++;
	}
	SendTransmitRequest(0x0000, 10 + (adcChannels * 2));
#else
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
	SendTransmitRequest(0x0000, idx);
#endif
}


void UART_RX_ISR()
{
	BYTE inputData = UART_bReadRxData();
	if (inputData == FRAME_DELIMITER) {
		rxIndex = 0;
		rxSum = 0;
		wasEscaped = FALSE;
		rxData[rxIndex] = inputData;
	} else if (inputData == ESCAPE) {
		wasEscaped = TRUE;
	} else {
		rxIndex++;
		if (wasEscaped) {
			rxData[rxIndex] = (inputData ^ 0x20);
			wasEscaped = FALSE;
		} else {
			rxData[rxIndex] = inputData;
		}
		if (rxIndex == IDX_LENGTH_LSB) {
			// [START][LENGTH MSB][LENGTH LSB][FRAME DATA][CHECKSUM]
			rxBytesToReceive = (rxData[1] << 8) + rxData[2] + 4;
		} else if (rxIndex == (rxBytesToReceive - 1)) {
//			if ((rxSum & 0xFF) + rxData[rxBytesToReceive - 1] == 0xFF) {
			if (1) {	// ignore checksum (FOR TESTING USE ONLY)
				hasPacketToHandle = TRUE;
			}
		} else if (rxIndex > 2) {
			rxSum += rxData[rxIndex];
		}
	}
}

// just to inhibit "multiple define: '_UART_RX_ISR'" error
void UART_TX_ISR()
{

}

void ParsePacket(void) {
	BYTE length = 0;
	BYTE i = 0;

	switch ((BYTE)rxData[IDX_API_IDENTIFIER]) {
	case RX_PACKET_16BIT:
		// {0x7E}+{0x00}+{0x**}+{0x81}+{MSB}+{LSB}+{RSSI}+{OPTION}+{RF Data}+{Checksum}
		// OPTION
		// bit 1: Address Broadcast
		// bit 2: PAN Broadcast
		length = rxData[IDX_LENGTH_LSB] - 5;	// RF Data Length
		for (i = 0; i < length; i++) {
			ParseFirmataMessage(rxData[IDX_RF_DATA + i]);
		}
		break;
	case TX_STATUS_MESSAGE:
		// {0x7E}+{0x00+0x03}+{0x89}+{Frame ID}+{Status}+{Checksum}
		switch (rxData[IDX_API_IDENTIFIER + 2]) {
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
		switch (rxData[IDX_API_IDENTIFIER + 1]) {
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

void ParseFirmataMessage(BYTE inputData) {
	BYTE command = 0;
	
	if (bytesToReceive > 0 & inputData < 128) {
		bytesToReceive--;
		storedInputData[bytesToReceive] = inputData;
		if ((executeMultiByteCommand != 0) && (bytesToReceive == 0)) {
 			switch (executeMultiByteCommand) {
			case ANALOG_MESSAGE:
				analogData[multiByteChannel] = (BYTE)((storedInputData[0] << 7) + storedInputData[1]);
				break;
			case DIGITAL_MESSAGE:
				SetDigitalOutputs((WORD)((storedInputData[0] << 7) + storedInputData[1])); //(LSB, MSB)
				break;
			case SET_DIGITAL_PIN_MODE:
//				setPinMode(storedInputData[1], storedInputData[0]); // (pin#, mode)
//				if(storedInputData[0] == INPUT) 
//				digitalInputsEnabled = true; // enable reporting of digital inputs
				break;
			case REPORT_ANALOG_PIN:
//				setAnalogPinReporting(multiByteChannel,storedInputData[0]);
				break;
			case REPORT_DIGITAL_PORTS:
				// TODO: implement MIDI channel as port base for more than 16 digital inputs
//				if(storedInputData[0] == 0)
//					digitalInputsEnabled = false;
//				else
//				digitalInputsEnabled = true;
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
			bytesToReceive = 2;
			executeMultiByteCommand = command;
			break;
		case REPORT_ANALOG_PIN:
		case REPORT_DIGITAL_PORTS:
			bytesToReceive = 1; // two data bytes needed
			executeMultiByteCommand = command;
			break;
		case SYSTEM_RESET:
			// this doesn't do anything yet
			break;
		case REPORT_VERSION:
			// this doesn't do anything yet
			break;
		default:
			break;
		}
	}	
}

void SetDigitalOutputs(WORD newState)
{
	BYTE i;
	WORD mask;

	for (i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
		mask = 1 << i;
//		if ((digitalPinStatus & mask) && !(pwmStatus & mask)) {
//			digitalWrite(i, twoBytesForPorts & mask ? HIGH : LOW);
//		} 
		if (i == 9) {
			if (newState & mask) {
				SET_LED_H();
			} else {
				SET_LED_L();
			}
		}
	}
}

void SendTransmitRequest(WORD destAddress, BYTE rfDataLength) {
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
	SendCommand(frameDataLength);
}

void SendCommand(BYTE frameDataLength) {
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
