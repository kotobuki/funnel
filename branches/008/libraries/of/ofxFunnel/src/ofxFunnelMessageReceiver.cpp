/*
 *  ofxFunnelMessageReceiver.cpp
 *  openFrameworks
 *
 *  Created by 小林 茂 on 08/09/26.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "ofxFunnel.h"
#include "ofxFunnelMessageReceiver.h"

ofxFunnelMessageReceiver::ofxFunnelMessageReceiver(ofxFunnel *parent, ofxTCPClient *client) {
	funnel = parent;
	tcpClient = client;
}

ofxFunnelMessageReceiver::~ofxFunnelMessageReceiver() {

}

void ofxFunnelMessageReceiver::threadedFunction() {
	while (isThreadRunning()) {
		int readSize = tcpClient->receiveRawBytes(rxBuffer, 4096);
		int processedSize = 0;
		
		if (readSize < 1) {
			continue;
		}
		
		while (processedSize < readSize) {
			int packetSize = ((rxBuffer[processedSize + 0] << 24) & 0xFF)
			+ ((rxBuffer[processedSize + 1] << 16) & 0xFF)
			+ ((rxBuffer[processedSize + 2] << 8) & 0xFF)
			+ (rxBuffer[processedSize + 3] & 0xFF);
			
			if (packetSize > 1536) {
				printf("ERROR: Your client's endianness is not compatible with the server.\n");
				break;
			}
			
			osc::ReceivedPacket p(&rxBuffer[processedSize + 4], packetSize);
			
			if (p.IsBundle()) {
				// NOTE: Since a Funnel Server will not use bundle to send messages, so just ignore
			} else if (p.IsMessage()) {
				osc::ReceivedMessage m(p);
				ofxOscMessage* ofMessage = new ofxOscMessage();
				ofMessage->setAddress( m.AddressPattern() );
				
				for ( osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
					 arg != m.ArgumentsEnd();
					 ++arg )
				{
					if ( arg->IsInt32() )
						ofMessage->addIntArg( arg->AsInt32Unchecked() );
					else if ( arg->IsFloat() )
						ofMessage->addFloatArg( arg->AsFloatUnchecked() );
					else if ( arg->IsString() )
						ofMessage->addStringArg( arg->AsStringUnchecked() );
					else
					{
						assert( false && "message argument is not int, float, or string" );
					}
				}
				
				if (lock()) {
					funnel->processMessage(*ofMessage);
					unlock();
				}
			}
			
			processedSize += packetSize + 4;
		}	
	}	
}
