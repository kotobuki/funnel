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
//  gainer.analogInput(0).filters = filters;
}

void draw() {
  background(brightness);  
}

void change(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    brightness = int(e.target.value * 255);
  }
}

