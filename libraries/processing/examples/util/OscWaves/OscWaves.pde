/*
Osc waves
*/

import processing.funnel.*;

Osc oscSin;
Osc oscSqu;
Osc oscSaw;
Osc oscTri;
Osc oscInp;

PGraphics pg;

void setup()
{
  size(300,600);
 
  pg = createGraphics(width,height,P3D);
  pg.beginDraw();
  pg.background(200,200,200);
  pg.strokeWeight(5.0);

  pg.endDraw();
  frameRate(25);
    
  oscSin = new Osc(this,Osc.SIN,1.0,1);
  oscSin.serviceInterval = 30;
  oscSin.addEventListener(Osc.UPDATE,"oscUpdated");

  oscSqu = new Osc(this,Osc.SQUARE,1.0,1);
  oscSqu.serviceInterval = 30;
  oscSqu.addEventListener(Osc.UPDATE,"oscUpdated");

  oscSaw = new Osc(this,Osc.SAW,1.0,1);
  oscSaw.serviceInterval = 30;
  oscSaw.addEventListener(Osc.UPDATE,"oscUpdated");
  
  oscTri = new Osc(this,Osc.TRIANGLE,1.0,1);
  oscTri.serviceInterval = 30;
  oscTri.addEventListener(Osc.UPDATE,"oscUpdated");
  
  oscInp = new Osc(this,Osc.IMPULSE,1.0,1);
  oscInp.serviceInterval = 30;
  oscInp.addEventListener(Osc.UPDATE,"oscUpdated");
  
  oscSin.start();
  oscSqu.start();
  oscSaw.start();
  oscTri.start();
  oscInp.start();

}

void draw()
{
  image(pg,0,0);
}


int rate = 100;

int cnt=0;
void oscUpdated(Osc osc)
{
  pg.beginDraw();
  
  int y=0;
  switch(osc.wave){
    case Osc.SIN:
     drawWaves(10,osc.value,color(200,30,30));
    break;
    
    case Osc.SQUARE:
     drawWaves(130,osc.value,color(30,30,200));
    break;
    
   case Osc.SAW:
     drawWaves(250,osc.value,color(30,100,30));
    break;
    
   case Osc.TRIANGLE:
     drawWaves(370,osc.value,color(200,100,30));
    break;
    
   case Osc.IMPULSE:
     drawWaves(490,osc.value,color(20,20,20));
    break;
  }
  
  pg.endDraw();

}

void drawWaves(int y,float v,color c)
{
     pg.translate(pg.width/2,y);
     pg.stroke(c);
     pg.point(0,rate*v);
     pg.copy(0,y,pg.width,rate+1,-1,y,pg.width,rate+1);
}

void mousePressed()
{
  oscSin.start();
  oscSqu.start();
  oscSaw.start();
  oscTri.start();
  oscInp.start();
  println("osc update start");
}



