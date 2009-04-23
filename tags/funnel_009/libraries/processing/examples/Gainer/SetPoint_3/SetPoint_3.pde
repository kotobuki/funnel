/*
Gainer
turn on led when digital input 0 button pressed
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
 size(200, 200);
 frameRate(30);
 gainer= new Gainer(this, Gainer.MODE1);

 //SetPoint border = new SetPoint(0.5, 0.1);
 //Filter filters[] = {border};
 //gainer.digitalInput(0).filters = filters;
 
}

void draw()
{
 background(100);
}

void change(PinEvent e)
{
 if (e.target.number == Gainer.digitalInput[0]) {
   gainer.led().value = e.target.value;
   println("change: " + e.target.value);
 }
}

