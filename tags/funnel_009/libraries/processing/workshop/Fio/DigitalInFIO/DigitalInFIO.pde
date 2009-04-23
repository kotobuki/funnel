import processing.funnel.*;

Fio fio;

void setup()
{
  size(320, 240);
  frameRate(30);
  
  int[] moduleIDs = {1};
  
  // Since default pin mode of all digital pins are OUT, 
  // change to IN if needed.
  // デジタルピンのデフォルトのモードはOUTなので必要な場合にはINに設定する
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(12, Fio.IN);  

  fio = new Fio(this, moduleIDs, config);
}

void draw()
{
  if (fio.iomodule(1).digitalPin(12).value == 0) {
    background(200);
  } else {
    background(20);
  }
}

