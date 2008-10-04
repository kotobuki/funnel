#ifndef _OFX_FUNNEL_EVENTS_H
#define _OFX_FUNNEL_EVENTS_H

#include "Poco/FIFOEvent.h"
#include "Poco/Delegate.h"
#include "ofTypes.h"

class ofxFunnelEventArgs : public ofEventArgs {
public:
	int value;
	string message;
};


class ofxFunnelEventListener {
	
protected:
	
	virtual void onReady(int value){};
    
	void onReady(const void* sender, ofxFunnelEventArgs& eventArgs){
		onReady(eventArgs.value);
	}
};


class ofxFunnelEventManager {
	
public:
	
    ofxFunnelEventArgs 	funnelEventArgs;

	void addListener(ofxFunnelEventListener* listener){
		addOnReadyListener(listener);
	}
	
	void removeListener(ofxFunnelEventListener* listener){
		removeOnReadyListener(listener);
    }  

	void addOnReadyListener(ofxFunnelEventListener* listener){
		onReadyEvent += Poco::Delegate<ofxFunnelEventListener, ofxFunnelEventArgs>(listener, &ofxFunnelEventListener::onReady);
	}
	
	void removeOnReadyListener(ofxFunnelEventListener* listener){
		onReadyEvent -= Poco::Delegate<ofxFunnelEventListener, ofxFunnelEventArgs>(listener, &ofxFunnelEventListener::onReady);
	}
    
	void notifyOnReady(void* sender){
		onReadyEvent.notify(sender, funnelEventArgs);
	}
	
private:
	
	Poco::FIFOEvent<ofxFunnelEventArgs> onReadyEvent;
	
};

extern ofxFunnelEventManager ofxFunnelEvents;

#endif