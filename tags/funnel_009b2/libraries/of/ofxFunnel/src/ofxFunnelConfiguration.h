/*
 *  ofxFunnelConfiguration.h
 *  openFrameworks
 *
 *  Created by 小林 茂 on 08/09/27.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _OFX_FUNNEL_CONFIGURATION_H_
#define _OFX_FUNNEL_CONFIGURATION_H_

#include "ofConstants.h"

typedef enum {
	GAINER = 0,
	ARDUINO,
	XBEE,
	FIO
} ofxFunnelIOModuleType;

typedef enum {
	AIN = 0,
	DIN,
	AOUT,
	DOUT,
	PWM = AOUT
} ofxFunnelPinMode;

class ofxFunnelConfiguration {

public:
	ofxFunnelConfiguration(ofxFunnelIOModuleType type);
	~ofxFunnelConfiguration();

	void setPinMode(int pinNumber, ofxFunnelPinMode pinMode);
	vector<int> getConfiguration();

private:
	int numberOfPins;
	int *configuration;
};

#endif