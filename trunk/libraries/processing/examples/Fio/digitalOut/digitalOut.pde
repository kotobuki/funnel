/*
Fio
digital out (d2)
*/
import processing.funnel.*;

Fio fio;

void setup()
{
  size(200,200);
  frameRate(25);
  
  int[] fioIDs = {1};
  fio = new Fio(this,fioIDs,Fio.FIRMATA);
  fio.autoUpdate = true;
  
}

void draw()
{
  background(170);
  
  if(mousePressed){
    fio.iomodule(1).digitalPin(3).value = 1.0;
    //fio.iomodule(1).port(3).value = 1.0;
  }else{
    fio.iomodule(1).digitalPin(3).value = 0.0;
    //fio.iomodule(1).port(3).value = 0.0;
  }
  
}
