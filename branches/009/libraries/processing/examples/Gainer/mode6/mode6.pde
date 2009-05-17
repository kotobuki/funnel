import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(200, 200);

  gainer= new Gainer(this, Gainer.MODE6);
}

void draw()
{
  background(100);
}

void mousePressed()
{

  for(int i=0;i<gainer.digitalOutput.length;i++){ 
    gainer.digitalOutput(i).value = 1;
  }

}

void mouseReleased()
{
  for(int i=0;i<gainer.digitalOutput.length;i++){ 
    gainer.digitalOutput(i).value = 0;
  }

}
