#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

#include "xbee.h"

#pragma interrupt_handler UART_RX_ISR
#pragma interrupt_handler UART_TX_ISR

#define FRAME_DELIMITER	(0x7E)
#define ESCAPE			(0x7D)
#define XON				(0x11)
#define XOFF			(0x13)
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
	SendTransmitRequest(0x1234, 10 + (adcChannels * 2));
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
			if ((rxSum & 0xFF) + rxData[rxBytesToReceive - 1] == 0xFF) {
				hasPacketToHandle = TRUE;
			}
		} else if (rxIndex > 2) {
			rxSum += rxData[rxIndex];
		}
	}

	// just for testing
	hasPacketToHandle = TRUE;
}

// just to inhibit "multiple define: '_UART_RX_ISR'" error
void UART_TX_ISR()
{

}

void ParsePacket(void) {
	switch ((BYTE)rxData[IDX_API_IDENTIFIER]) {
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
