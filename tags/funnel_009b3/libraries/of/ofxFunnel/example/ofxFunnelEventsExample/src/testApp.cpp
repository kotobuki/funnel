#include <UdpSocket.h>

#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	 
	counter = 0;
	vagRounded.loadFont("vag.ttf", 32);
	ofBackground(50,50,50);	

	ofSetFrameRate(10);
	
	ofxFunnelConfiguration config(ARDUINO);
	config.setPinMode(13, DOUT);
	config.setPinMode(14, AIN);
	
	funnel.connect("127.0.0.1", 9000, config);
	ofxFunnelEvents.addListener(this);
	
	socket = new UdpTransmitSocket(IpEndpointName("127.0.0.1", 9001));
}


//--------------------------------------------------------------
void testApp::update(){
	counter = counter + 0.033f;
}

//--------------------------------------------------------------
void testApp::draw(){
	
	sprintf (timeString, "time: %0.2i:%0.2i:%0.2i \nelapsed time %i", ofGetHours(), ofGetMinutes(), ofGetSeconds(), ofGetElapsedTimeMillis());
	
	float w = vagRounded.stringWidth(eventString);
	float h = vagRounded.stringHeight(eventString);
	
	ofSetColor(0xffffff);
	char text[255];
	float val = funnel.getPinValue(14);
	
	sprintf(text, "A0: %f", val);
	vagRounded.drawString(text, 98,198);
	socket->Send((char *)&val, sizeof(float));
	
//	ofSetColor(0xffffff);
//	vagRounded.drawString(eventString, 98,198);

//	ofSetColor(255,122,220);
//	vagRounded.drawString(eventString, 100,200);
//	
//	
//	ofSetColor(0xffffff);
//	vagRounded.drawString(timeString, 98,98);
//	
//	ofSetColor(255,122,220);
//	vagRounded.drawString(timeString, 100,100);
	
}


//--------------------------------------------------------------
void testApp::keyPressed  (int key){ 
	sprintf(eventString, "keyPressed = (%i)", key);
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){ 
	
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
	sprintf(eventString, "mouseMoved = (%i,%i)", x, y);
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
	sprintf(eventString, "mouseDragged = (%i,%i - button %i)", x, y, button);
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
	sprintf(eventString, "mousePressed = (%i,%i - button %i)", x, y, button);
	funnel.setOutput(0, 13, 1.0f);
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
	sprintf(eventString, "mouseReleased = (%i,%i - button %i)", x, y, button);
	funnel.setOutput(0, 13, 0.0f);
}

void testApp::onReady(int value) {
	printf("READY!!!!!!!!!!!!!!!!!!!\n");
}
