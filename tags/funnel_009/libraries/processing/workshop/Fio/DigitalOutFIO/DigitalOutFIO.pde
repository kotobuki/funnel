import processing.funnel.*;

Fio fio;

// 0xFFFF means 'broadcast' to all nodes in the same PAN ID
// 0xFFFFは同じPAN IDの全てのノードに対するブロードキャストを意味する
final int ALL = 0xFFFF;

void setup()
{
  size(200, 200);
  frameRate(30);

  int[] moduleIDs = {1, ALL};
  fio = new Fio(this, moduleIDs, Fio.FIRMATA);
}

void draw()
{
  background(100);
}

void mousePressed()
{
  fio.iomodule(1).digitalPin(13).value = 1.0;
//  fio.iomodule(ALL).digitalPin(13).value = 1.0;
}

void mouseReleased()
{
  fio.iomodule(1).digitalPin(13).value = 0.0;
//  fio.iomodule(ALL).digitalPin(13).value = 0.0;
}

