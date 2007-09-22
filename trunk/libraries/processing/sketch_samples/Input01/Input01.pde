import processing.funnel.*;

Funnel funnel;
void setup()
{
  
  size(300,300);
  frameRate(20);
  
  
  funnel = new Funnel(this,100,GAINER.CONFIGURATION_1);
  funnel.autoUpdate = true;
  
}

void draw()
{
  if(funnel.port(GAINER.button).value==0){
    background(0);
  }else{
    background(128);
  }
}
  



