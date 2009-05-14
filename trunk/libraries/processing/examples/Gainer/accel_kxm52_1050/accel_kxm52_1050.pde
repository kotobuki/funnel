/*
Gainer
analog minimum & maximum
*/

import processing.funnel.*;

Gainer gainer;
PFont myFont;

void setup()
{
  size(450,450);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  gainer = new Gainer(this,Gainer.MODE1);
  
}

void draw()
{
  background(0);
  text("analogInput[0]: " + nf(gainer.analogInput(0).value,1,8),10,40);
  text("min " + nf(gainer.analogInput(0).minimum,1,8) +
  " max " +nf(gainer.analogInput(0).maximum,1,8),10,70);

  text("analogInput[1]: " + nf(gainer.analogInput(1).value,1,8),10,120);
  text("min " + nf(gainer.analogInput(1).minimum,1,8) +
  " max " +nf(gainer.analogInput(1).maximum,1,8),10,150);

  text("analogInput[2]: " + nf(gainer.analogInput(2).value,1,8),10,200);
  text("min " + nf(gainer.analogInput(2).minimum,1,8) +
  " max " +nf(gainer.analogInput(2).maximum,1,8),10,230);

  text("analogInput[3]: " + nf(gainer.analogInput(3).value,1,8),10,280);
  text("min " + nf(gainer.analogInput(3).minimum,1,8) +
  " max " +nf(gainer.analogInput(3).maximum,1,8),10,310);
}

