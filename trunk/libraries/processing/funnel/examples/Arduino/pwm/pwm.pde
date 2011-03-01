/*
Arduino 
pwm (digital 9pin)
 mouse positon
*/

import processing.funnel.*;

Arduino arduino;

int pwmPin = 9;

void setup()
{
  size(200,200);
  
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(pwmPin,Arduino.PWM);
  arduino = new Arduino(this,config);

}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  arduino.digitalPin(pwmPin).value = val;

}


