/*
 *  ofxFunnel.cpp
 *  openFrameworks
 *
 *  Created by 小林 茂 on 08/09/26.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#include <OscOutboundPacketStream.h>

#include "ofxFunnel.h"
#include "ofxFunnelConfiguration.h"
#include "ofxFunnelMessageReceiver.h"
#include "ofxFunnelEvents.h"

ofxFunnel::ofxFunnel() {

}

ofxFunnel::~ofxFunnel() {
	receiver->stopThread();
}

void ofxFunnel::connect(string ipAddress, int networkPortNumber, ofxFunnelConfiguration config) {
	isConnected = tcpClient.setup(ipAddress, networkPortNumber);
	
	tcpClient.setVerbose(true);
	receiver = new ofxFunnelMessageReceiver(this, &tcpClient);
	receiver->startThread(true, false);
	
	resetServer();
	
	sendConfiguration(config.getConfiguration());
	setPolling(true);	
}

void ofxFunnel::processMessage(const ofxOscMessage& message) {
	if (strcmp(message.getAddress(), "/in") == 0) {
		int nodeId = message.getArgAsInt32(0);
		int startPinNumber = message.getArgAsInt32(1);
		for (int i = 0; i < (message.getNumArgs() - 2); i++) {
			values[startPinNumber + i] = message.getArgAsFloat(i + 2);
		}
	} else if (strcmp(message.getAddress(), "/configure") == 0) {
		if (message.getArgType(0) == OFXOSC_TYPE_INT32) {
			if (message.getArgAsInt32(0) == 0) {
				printf("OK: configuration\n");
			} else {
				printf("ERROR: configuration\n");
			}
		}
	} else if (strcmp(message.getAddress(), "/reset") == 0) {
		if (message.getArgType(0) == OFXOSC_TYPE_INT32) {
			if (message.getArgAsInt32(0) == 0) {
				printf("OK: reset\n");
				ofxFunnelEvents.notifyOnReady(0);
			} else {
				printf("ERROR: reset\n");
			}
		}
	} else if (strcmp(message.getAddress(), "/samplingInterval") == 0) {
	} else if (strcmp(message.getAddress(), "/polling") == 0) {
		if (message.getArgType(0) == OFXOSC_TYPE_INT32) {
			printf("polling %d\n", message.getArgAsInt32(0));
		}
	} else if (strcmp(message.getAddress(), "/out") == 0) {
	} else {
		printf("UNKNOWN: %s\n", message.getAddress());
	}
}

float ofxFunnel::getPinValue(int pinNumber)
{
	float theValue = -1.0f;
	if (receiver->lock()) {
		theValue = values[pinNumber];
		receiver->unlock();
	}

	return theValue;
}

void ofxFunnel::sendMessage(const ofxOscMessage& message)
{
	static const int OUTPUT_BUFFER_SIZE = 16384;
	char buffer[OUTPUT_BUFFER_SIZE];
    osc::OutboundPacketStream p( buffer + 4, OUTPUT_BUFFER_SIZE - 4 );
	
    p << osc::BeginBundleImmediate << osc::BeginMessage( message.getAddress() );
	for ( int i=0; i< message.getNumArgs(); ++i ) {
		if ( message.getArgType(i) == OFXOSC_TYPE_INT32 )
			p << message.getArgAsInt32( i );
		else if ( message.getArgType( i ) == OFXOSC_TYPE_FLOAT )
			p << message.getArgAsFloat( i );
		else if ( message.getArgType( i ) == OFXOSC_TYPE_STRING )
			p << message.getArgAsString( i );
		else
		{
			assert( false && "bad argument type" );
		}
	}
	p << osc::EndMessage << osc::EndBundle;
	
	// have to put the packet size at the beginning
	buffer[0] = (p.Size() >> 24) & 0xFF;
	buffer[1] = (p.Size() >> 16) & 0xFF;
	buffer[2] = (p.Size() >> 8) & 0xFF;
	buffer[3] = p.Size() & 0xFF;
	
	tcpClient.sendRawBytes(buffer, p.Size() + 4);
}

void ofxFunnel::resetServer()
{
	ofxOscMessage message;
	message.setAddress("/reset");
	sendMessage(message);
}

void ofxFunnel::sendConfiguration(vector<int> config)
{
	printf("config: length = %d\n", config.size());
	ofxOscMessage message;
	message.setAddress("/configure");
	message.addIntArg(0);	// nodeId
	
	int pinNumber = 0;
	for (vector<int>::const_iterator iter = config.begin(); iter != config.end(); ++iter) {
		int pinMode = *iter;
		printf("pin mode[%d] = %d\n", pinNumber, pinMode);
		message.addIntArg(pinMode);
		pinNumber++;
	}
	
	sendMessage(message);
}

void ofxFunnel::setPolling(bool enabled)
{
	ofxOscMessage message;
	message.setAddress("/polling");
	message.addIntArg(enabled ? 1 : 0);
	sendMessage(message);
}

void ofxFunnel::setOutput(int nodeId, int pinNumber, float value)
{
	ofxOscMessage message;
	message.setAddress("/out");
	message.addIntArg(nodeId);
	message.addIntArg(pinNumber);
	message.addFloatArg(value);
	sendMessage(message);	
}
