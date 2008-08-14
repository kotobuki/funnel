/*
Fio 
analog in
*/

import processing.funnel.*;

Fio fio;

int R = 3;
int G = 10;
int B = 11;


Osc osc_r,osc_g,osc_b;



void setup()
{
  size(400,130);
  frameRate(25);
  
  
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(R,Fio.PWM);
  config.setDigitalPinMode(G,Fio.PWM);
  config.setDigitalPinMode(B,Fio.PWM);
  
  int[] nodeIDs = {1};
  
  fio = new Fio(this,nodeIDs,config);
  fio.autoUpdate = true;
 
  osc_r = new Osc(this,Osc.SIN,0.5,1,0,0,0);
  osc_r.serviceInterval = 1;
  osc_r.addEventListener(Osc.UPDATE,"oscUpdated");
  osc_r.start();
  
  osc_g = new Osc(this,Osc.SIN,0.5,1,0,0.33,0);
  osc_g.serviceInterval = 1;
  osc_g.addEventListener(Osc.UPDATE,"oscUpdated");
  osc_g.start();
  
  osc_b = new Osc(this,Osc.SIN,0.5,1,0,0.66,0);
  osc_b.serviceInterval = 1;  
  osc_b.addEventListener(Osc.UPDATE,"oscUpdated");
  osc_b.start();
  
  frameRate(1);
  
  noLoop();
}

void oscUpdated(Osc osc)
{
//  fio.iomodule(1).digitalPin(R).value = osc_r.value;
//  fio.iomodule(1).digitalPin(G).value = osc_g.value;
//  fio.iomodule(1).digitalPin(B).value = osc_b.value;
  fio.iomodule(1).port(R).value = osc_r.value;
  fio.iomodule(1).port(G).value = osc_g.value;
  fio.iomodule(1).port(B).value = osc_b.value;

  //println(osc_r.value + " " + osc_g.value + " " + osc_b.value);
}


void draw()
{
  background(0);
}
  



