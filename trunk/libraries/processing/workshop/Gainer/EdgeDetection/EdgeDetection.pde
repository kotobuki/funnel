import processing.funnel.*;

Gainer gainer;
int brightness = 0;

void setup()
{
  size(200, 200);

  gainer = new Gainer(this, Gainer.MODE1);
  Filter filters[] = {
    new SetPoint(0.5, 0.1)
  };
  gainer.digitalInput(0).filters = filters;
}

void draw() {
  background(brightness);  
}

void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    brightness = 255;
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    brightness = 0;
  }
}

