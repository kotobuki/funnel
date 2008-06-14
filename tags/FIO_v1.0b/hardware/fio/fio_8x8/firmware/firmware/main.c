//----------------------------------------------------------------------------
// C main line
//----------------------------------------------------------------------------

#include <m8c.h>        // part specific constants and macros
#include "PSoCAPI.h"    // PSoC API definitions for all User Modules

#include "xbee.h"
#include "fio.h"

//       ljmp _XBEE_UART_RX_ISR


WORD adcData[TOTAL_ANALOG_PINS];
WORD dioStatus = 0x0000;
WORD analogPinsToReport = 0x00FF;	// ain 0-7
WORD digitalPinsToReport = 0x0100;	// button pin only

#if 0
// prototypes of event handlers
void analogMessageHandler(BYTE pin, WORD value);
void digitalMessageHandler(BYTE pin, WORD value);
void setPinModeHandler(BYTE pin, WORD value);
void reportAnalogHandler(BYTE pin, WORD state);
void reportDigitalHandler(BYTE pin, WORD state);
#endif

void updateInputs(void);

void setup()
{
    M8C_EnableGInt;
    
	SleepTimer_Start();
	SleepTimer_SetInterval(SleepTimer_512_HZ);	// Set interrupt to a 512 Hz rate
	SleepTimer_EnableInt();

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

#if 0
	Firmata_attach(ANALOG_MESSAGE, analogMessageHandler);
	Firmata_attach(DIGITAL_MESSAGE, digitalMessageHandler);
	Firmata_attach(REPORT_ANALOG, reportAnalogHandler);
	Firmata_attach(REPORT_DIGITAL, reportDigitalHandler);
#endif
	Firmata_begin();
}

void loop(void)
{
	BYTE analogPin = 0;
	BYTE digitalPin = 0;
	
	if (Firmata_available()) {
		Firmata_processInput();
	}

	if (SleepTimer_bGetTimer() > 0) {
		return;
	}

	SleepTimer_SetTimer(8);
	updateInputs();
	Firmata_beginPacket();
	for (analogPin = 0; analogPin < TOTAL_ANALOG_PINS; analogPin++) {
		if (analogPinsToReport & (1 << analogPin)) {
			Firmata_sendAnalog(analogPin, adcData[analogPin]);
		}
	}
	Firmata_sendDigitalPort(0, dioStatus);
	Firmata_endPacket();
}

void main()
{
	setup();
	SleepTimer_SetTimer(128);
	while(1) {
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

	// TODO: Implement for the other pins
	if (GET_BUTTON()) {
		dioStatus = dioStatus | 0x0100;	// button is the 8th digital input
	} else {
		dioStatus = dioStatus & 0xFEFF;	// button is the 8th digital input
	}
}

#if 0
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

void digitalMessageHandler(BYTE port, WORD value)
{
	// TODO: Support digital pin from 0 to 8
	
	// digital pin 9 is the on-board LED
	if (value & 0x0200) {
		SET_LED_H();
	} else {
		SET_LED_L();
	}
}

void setPinModeHandler(BYTE pin, WORD value)
{
	// NOTE: TO BE IMPLEMENTED!!!
}

void reportAnalogHandler(BYTE pin, WORD state)
{
	if (state == 0) {
		analogPinsToReport = analogPinsToReport &~ (1 << pin);
	} else {
		analogPinsToReport = analogPinsToReport | (1 << pin);
	}
}

void reportDigitalHandler(BYTE pin, WORD state)
{
	if (state == 0) {
		digitalPinsToReport = digitalPinsToReport &~ (1 << pin);
	} else {
		digitalPinsToReport = digitalPinsToReport | (1 << pin);
	}
}
#endif
