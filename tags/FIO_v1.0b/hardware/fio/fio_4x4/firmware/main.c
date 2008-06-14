//----------------------------------------------------------------------------
// C main line
//----------------------------------------------------------------------------

#include <m8c.h>        // part specific constants and macros
#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

/*
 * NOTE: Be sure to add "ljmp _MY_UART_RX_ISR" to uartint.asm as follows
   ;@PSoC_UserCode_BODY_2@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.
   ljmp _MY_UART_RX_ISR
   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
 */
#pragma interrupt_handler MY_UART_RX_ISR

BOOL updated = FALSE;
unsigned char bytesToReceive = 0;
unsigned char storedInputData[3];
unsigned char analogData[14];

unsigned char executeMultiByteCommand = 0;
unsigned char multiByteChannel = 0;

void MY_UART_RX_ISR(void) {
	unsigned char inputData = 0;
	unsigned char command = 0;
	inputData = UART_bReadRxData();
	
	if (bytesToReceive > 0 & inputData < 128) {
		bytesToReceive--;
		storedInputData[bytesToReceive] = inputData;
		if ((executeMultiByteCommand != 0) && (bytesToReceive == 0)) {
 			switch (executeMultiByteCommand) {
			case 0xE0:
				analogData[multiByteChannel] = storedInputData[0] << 7;
				analogData[multiByteChannel] += storedInputData[1];
				updated = TRUE;
				break;
			default:
				break;
 			}
 		}
	} else {
		if (inputData < 0xF0) {
			command = inputData & 0xF0;
			multiByteChannel = inputData & 0x0F;
		} else {
			command = inputData;
		}

		switch (command) {
		case 0xE0:
			bytesToReceive = 2;
			executeMultiByteCommand = command;
			break;
		default:
			break;
		}
	}	
}

void main()
{
	UART_IntCntl(UART_ENABLE_RX_INT);     // Enable RX interrupts  
	UART_Start(UART_PARITY_NONE);         // Enable UART  

	PWM8_0_WritePulseWidth(0);
	PWM8_0_Start();
	PWM8_1_WritePulseWidth(0);
	PWM8_1_Start();
	PWM8_2_WritePulseWidth(0);
	PWM8_2_Start();
	PWM8_3_WritePulseWidth(0);
	PWM8_3_Start();
  
	M8C_EnableGInt ;                      // Turn on interrupts  

	while(1) {
		if (updated) {
			PWM8_3_WritePulseWidth(analogData[10]);
			PWM8_1_WritePulseWidth(analogData[11]);
			PWM8_0_WritePulseWidth(analogData[12]);
			PWM8_2_WritePulseWidth(analogData[13]);
			updated = FALSE;
		}
	}
}
