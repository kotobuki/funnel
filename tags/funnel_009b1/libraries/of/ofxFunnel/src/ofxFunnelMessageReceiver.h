/*
 *  ofxFunnelMessageReceiver.h
 *  openFrameworks
 * 
 *  Created by Shigeru Kobayashi on 08/09/26.
 */

#ifndef _OFX_FUNNEL_MESSAGE_RECEIVER_H_
#define _OFX_FUNNEL_MESSAGE_RECEIVER_H_

#include <deque>
#include <ofMain.h>
#define OF_ADDON_USING_OFXTHREAD
#define OF_ADDON_USING_OFXNETWORK
#define OF_ADDON_USING_OFXOSC
//#include <ofxFunnel.h>
#include "ofAddons.h"

#define FUNNEL_MAX_MSG_SIZE 1536

class ofxFunnel;
class ofxTCPClient;
class ofxFunnelMessageReceiver : public ofxThread {

public:
	ofxFunnelMessageReceiver(ofxFunnel *parent, ofxTCPClient *client);
	~ofxFunnelMessageReceiver();
	
//	bool hasWaitingMessages();
//	bool getNextMessage(ofxOscMessage*);

	void threadedFunction();

private:
//	void ProcessMessage(const osc::ReceivedMessage &message);

	ofxFunnel *funnel;
	ofxTCPClient *tcpClient;
//	std::deque< ofxOscMessage* > messages;
	char rxBuffer[FUNNEL_MAX_MSG_SIZE];
	float values[22];
};

#endif