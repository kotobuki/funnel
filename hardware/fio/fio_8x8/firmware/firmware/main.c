//----------------------------------------------------------------------------
// C main line
//----------------------------------------------------------------------------

#include <m8c.h>        // part specific constants and macros
#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

#include "xbee.h"
#include "fio.h"

WORD adcData[TOTAL_ANALOG_PINS];
WORD dioStatus = 0x0000;

// prototypes of event handlers
void analogMessageHandler(BYTE pin, WORD value);
void digitalMessageHandler(BYTE pin, WORD value);
void setPinModeHandler(BYTE pin, WORD value);

void updateInputs(void);

void setup()
{
	UART_EnableInt();
	UART_Start(UART_PARITY_NONE);

    M8C_EnableGInt;
    
	SleepTimer_Start();
	SleepTimer_SetInterval(SleepTimer_64_HZ);	// Set interrupt to a  
	SleepTimer_EnableInt();						// 64 Hz rate 	

	// initialize and start analog input related blocks
	AMUX_InputSelect(0);
	AMUX_Start();
	PGA_Start(PGA_MEDPOWER);
	PGA_SetGain(PGA_G1_00);
	ADC_Start(ADC_MEDPOWER);
	
	// initialize and start PWM related blocks
	PWM8_0_WritePeriod(254);
	PWM8_1_WritePeriod(254);
	PWM8_2_WritePeriod(254);
	PWM8_3_WritePeriod(254);
	PWM8_4_WritePeriod(254);
	PWM8_5_WritePeriod(254);
	PWM8_6_WritePeriod(254);
	PWM8_7_WritePeriod(254);

	PWM8_0_WritePulseWidth(0);
	PWM8_1_WritePulseWidth(0);
	PWM8_2_WritePulseWidth(0);
	PWM8_3_WritePulseWidth(0);
	PWM8_4_WritePulseWidth(0);
	PWM8_5_WritePulseWidth(0);
	PWM8_6_WritePulseWidth(0);
	PWM8_7_WritePulseWidth(0);
	
	PWM8_0_Start();
	PWM8_1_Start();
	PWM8_2_Start();
	PWM8_3_Start();
	PWM8_4_Start();
	PWM8_5_Start();
	PWM8_6_Start();
	PWM8_7_Start();

	attach(ANALOG_MESSAGE, analogMessageHandler);
	attach(DIGITAL_MESSAGE, digitalMessageHandler);
	begin();
}

void loop(void)
{
	if (available()) {
		processInput();
	}

	updateInputs();
	reportIOStatus(dioStatus, adcData, TOTAL_ANALOG_PINS);
}

void main()
{
	setup();

	while(1) {
		SleepTimer_SyncWait(1, SleepTimer_WAIT_RELOAD);
		loop();
	}
}

const BYTE muxNumToChNumTbl[TOTAL_ANALOG_PINS] = {7, 3, 6, 2, 5, 1, 4, 0};

void updateInputs(void)
{
	BYTE channel = 0;

	for (channel = 0; channel < TOTAL_ANALOG_PINS; channel++) {
		AMUX_InputSelect(channel);
		ADC_GetSamples(1);
		while (ADC_fIsDataAvailable() == 0) {
			;
		}
		adcData[muxNumToChNumTbl[channel]] = ADC_iGetDataClearFlag();
	}

	// just for testing
	if (GET_BUTTON()) {
		dioStatus = 0x0100;	// button is the 8th digital input
	} else {
		dioStatus = 0x0000;	// button is the 8th digital input
	}
}

void analogMessageHandler(BYTE pin, WORD value)
{
	switch (pin) {
	case 0:
		PWM8_0_WritePulseWidth((BYTE)value);
		break;
	case 1:
		PWM8_1_WritePulseWidth((BYTE)value);
		break;
	case 2:
		PWM8_2_WritePulseWidth((BYTE)value);
		break;
	case 3:
		PWM8_3_WritePulseWidth((BYTE)value);
		break;
	case 4:
		PWM8_4_WritePulseWidth((BYTE)value);
		break;
	case 5:
		PWM8_5_WritePulseWidth((BYTE)value);
		break;
	case 6:
		PWM8_6_WritePulseWidth((BYTE)value);
		break;
	case 7:
		PWM8_7_WritePulseWidth((BYTE)value);
		break;
	default:
		break;
	}
}

void digitalMessageHandler(BYTE pin, WORD isHigh)
{
/*
	BYTE i;
	WORD mask;

	for (i = 0; i < TOTAL_DIGITAL_PINS; ++i) {
		mask = 1 << i;
		if (!(pwmStatus & mask)) {
			digitalWrite(i, (BOOL)(newState & mask ? TRUE : FALSE));
		}
	}
*/
	switch (pin) {
	case 0:
		if (isHigh) SET_DOUT_0_H(); else SET_DOUT_0_L();
		break;
	case 1:
		if (isHigh) SET_DOUT_1_H(); else SET_DOUT_1_L();
		break;
	case 2:
		if (isHigh) SET_DOUT_2_H(); else SET_DOUT_2_L();
		break;
	case 3:
		if (isHigh) SET_DOUT_3_H(); else SET_DOUT_3_L();
		break;
	case 4:
		if (isHigh) SET_DOUT_4_H(); else SET_DOUT_4_L();
		break;
	case 5:
		if (isHigh) SET_DOUT_5_H(); else SET_DOUT_5_L();
		break;
	case 6:
		if (isHigh) SET_DOUT_6_H(); else SET_DOUT_6_L();
		break;
	case 7:
		if (isHigh) SET_DOUT_7_H(); else SET_DOUT_7_L();
		break;
	case 9:
		if (isHigh) SET_LED_H(); else SET_LED_L();
		break;
	default:
		break;
	}
}

void setPinModeHandler(BYTE pin, WORD value)
{
	// NOTE: TO BE IMPLEMENTED!!!
}
