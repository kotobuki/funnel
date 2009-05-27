/*
Fio
digital out (d13)
*/
import processing.funnel.*;

Fio fio;
int outPin = 13;

void setup()
{
  size(200,200);
  
  int[] fioIDs = {1};
  fio = new Fio(this,fioIDs,Fio.FIRMATA);
}

void draw()
{
  background(170);
  
  if(mousePressed){
    fio.iomodule(1).digitalPin(outPin).value = 1.0;
  }else{
    fio.iomodule(1).digitalPin(outPin).value = 0.0;
  }
  
}
