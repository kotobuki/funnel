/*
Gainer
turn on led when button pressed
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
 size(200, 200);
 frameRate(30);
 gainer= new Gainer(this, Gainer.MODE1);
 
}

void draw()
{
 background(100);
}

void change(PinEvent e)
{
 if (e.target.number == Gainer.button) {
   gainer.led().value = e.target.value;
   println("change: " + e.target.value);
 }
}
