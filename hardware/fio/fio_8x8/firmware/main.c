//----------------------------------------------------------------------------
// C main line
//----------------------------------------------------------------------------

#include <m8c.h>        // part specific constants and macros
#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

#include "xbee.h"
#include "fio.h"

WORD adcData[8];
WORD ioEnable = 0xFF00;
WORD dioStatus = 0x0000;

void Initialize(void);
void UpdateInputs(void);
void UpdateOutputs(void);

void main()
{
	Initialize();

	while(1) {
		SleepTimer_SyncWait(1, SleepTimer_WAIT_RELOAD);

		if (HasPacketToHandle()) {
			ClearHasPacketFlag();
			ParsePacket();
//			SET_LED_H();
		} else {
//			SET_LED_L();
		}
		UpdateOutputs();

		UpdateInputs();
		ReportIOStatus(ioEnable, dioStatus, adcData, 8);
	}
}

void Initialize()
{
	UART_EnableInt();
	UART_Start(UART_PARITY_NONE);

    M8C_EnableGInt;
    
	SleepTimer_Start();
	SleepTimer_SetInterval(SleepTimer_64_HZ);	// Set interrupt to a  
	SleepTimer_EnableInt();						// 64 Hz rate 	

	AMUX_InputSelect(0);
	AMUX_Start();

	PGA_Start(PGA_MEDPOWER);
	PGA_SetGain(PGA_G1_00);

	ADC_Start(ADC_MEDPOWER);
}

void UpdateInputs(void)
{
	BYTE channel = 0;

	for (channel = 0; channel < 8; channel++) {
		AMUX_InputSelect(channel);
		ADC_GetSamples(1);
		while (ADC_fIsDataAvailable() == 0) {
			;
		}
		adcData[channel] = ADC_iGetDataClearFlag();
	}

	// just for testing
	if (GET_BUTTON()) {
		dioStatus = 0x7777;
	} else {
		dioStatus = 0x2222;
	}
}

void UpdateOutputs(void)
{

}
