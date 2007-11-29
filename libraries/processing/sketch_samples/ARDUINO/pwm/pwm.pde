/*
Arduino 
pwm (9pin)
*/

import processing.funnel.*;

Arduino arduino;

int pwmPin = 9;

void setup()
{
  size(200,200);
  frameRate(25);
  
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(pwmPin,Arduino.PWM);
  arduino = new Arduino(this,config);
  arduino.autoUpdate = true;

}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  arduino.digitalPin(pwmPin).value = val;

}


