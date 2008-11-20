/*
 *  ofxFunnelClient.h
 *  openFrameworks
 *
 *  Created by Shigeru Kobayashi on 08/09/26.
 */

#ifndef _OFX_FUNNEL_H_
#define _OFX_FUNNEL_H_

#include <ofMain.h>
#define OF_ADDON_USING_OFXTHREAD
#define OF_ADDON_USING_OFXNETWORK
#define OF_ADDON_USING_OFXOSC
#include "ofAddons.h"

#include "ofxFunnelConfiguration.h"
#include "ofxFunnelEvents.h"

class ofxFunnelMessageReceiver;
class ofxFunnel : public ofxThread {
	
public:
	ofxFunnel();
	~ofxFunnel();

	void connect(string ipAddress, int networkPortNumber, ofxFunnelConfiguration config);
	void processMessage(const ofxOscMessage& message);
	float getPinValue(int pinNumber);
	void setOutput(int nodeId, int pinNumber, float value);
	
private:
	void sendMessage(const ofxOscMessage& message);
	
	void resetServer();
	void sendConfiguration(vector<int> config);
	void setPolling(bool enabled);
	
	ofxTCPClient				tcpClient;
	bool						isConnected;
	ofxFunnelMessageReceiver*	receiver;
	float						values[22];
};

#endif