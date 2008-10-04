#ifndef _TEST_APP
#define _TEST_APP


#include "ofMain.h"
#define OF_ADDON_USING_OFXFUNNEL
#include "ofAddons.h"

class UdpTransmitSocket;

class testApp : public ofSimpleApp, public ofxFunnelEventListener {
	
	public:
		
		void setup();
		void update();
		void draw();
		
		void keyPressed(int key);
		void keyReleased(int key);		
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		
		void onReady(int value);
	
		float 			counter;
		ofTrueTypeFont 	vagRounded;
		char eventString[255];
		char timeString[255];


private:
	ofxFunnel		funnel;
	UdpTransmitSocket *socket;
};

#endif