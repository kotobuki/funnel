/*
Gainer
din0 
*/

import processing.funnel.*;

Gainer gainer;
Pin buttonPin;

void setup()
{
 size(200, 200);
 gainer= new Gainer(this, Gainer.MODE1);
 
 buttonPin = gainer.digitalInput(0);
}

void draw()
{
 background(100);
}

void change(PinEvent e)
{
 if (e.target == buttonPin){
   print("* " + buttonPin.value + "   ");
   println("! " + buttonPin.lastValue);
 }
}
