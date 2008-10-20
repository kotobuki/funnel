/*
 *  ofxFunnelConfiguration.cpp
 *  openFrameworks
 *
 *  Created by 小林 茂 on 08/09/27.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "ofxFunnelConfiguration.h"

ofxFunnelConfiguration::ofxFunnelConfiguration(ofxFunnelIOModuleType type) {
	numberOfPins = 22;
	configuration = new int[numberOfPins];
	
	for (int i = 0; i < 14; i++) {
		configuration[i] = DOUT;
	}

	for (int i = 14; i < 22; i++) {
		configuration[i] = AIN;
	}
}

ofxFunnelConfiguration::~ofxFunnelConfiguration() {
	if (configuration != nil) {
		delete configuration;
	}
}

void ofxFunnelConfiguration::setPinMode(int pinNumber, ofxFunnelPinMode pinMode) {
	configuration[pinNumber] = pinMode;
}

vector<int> ofxFunnelConfiguration::getConfiguration() {
	vector<int> config(configuration, configuration + numberOfPins);
	return config;
}
