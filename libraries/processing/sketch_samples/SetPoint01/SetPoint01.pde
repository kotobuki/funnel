import processing.funnel.*;

Funnel funnel;
SetPoint border;

void setup()
{
  
  size(300,300);
  frameRate(10);
  
  funnel = new Funnel(this);
  border = new SetPoint(0.3,0.1);

  Filter filters[] = {border};
  funnel.port(0).filters = filters;
  
  noLoop();
}

void draw()
{
  //println(funnel.port(0).value);
}

void risingEdge(PortEvent e)
{
  background(0);
  redraw();
  println("rising  " + e.target.number + " " + e.target.value);
  
}

void fallingEdge(PortEvent e)
{
  background(200);
  redraw();
  println("falling  " + e.target.number + " " + e.target.value);;  
}





