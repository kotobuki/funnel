/*
Gainer
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
 size(200, 200);
 gainer= new Gainer(this, Gainer.MODE1);
}

void draw()
{
 background(100);
}

void risingEdge(PinEvent e)
{
 if (e.target.number == Gainer.digitalInput[0]) {

   println("* " + e.target.value);
 }
}
