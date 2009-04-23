import processing.funnel.*;
import processing.funnel.i2c.*;

Arduino arduino;
RTC8564NB rtc;

void setup()
{
  Configuration config = Arduino.FIRMATA;
 
  arduino = new Arduino(this,config);
  
  rtc = new RTC8564NB(arduino.iomodule());
  
}

void draw()
{
}


void mousePressed()
{
  rtc.updateSecond();
  delay(100);
  println("p " + rtc.second);
}

