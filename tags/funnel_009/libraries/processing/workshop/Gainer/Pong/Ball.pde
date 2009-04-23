class Ball{
  float px;
  float py;
  float vx;
  float vy;
  
  Ball(float x,float y){
    px = x;
    py = y;
  }
  
  void update(float x,float y,float vx,float vy){
    px = x;
    py = y;
    this.vx = vx;
    this.vy = vy;
  }
  
  void update(){
    px+=vx;
    py+=vy;
    
   
    if(py < court_y+wall || py> court_y+court_height+wall){
      vy *= -1;
    }
    
    if(px < bar1.px+8 && px > bar1.px-4 && py < bar1.py+16 && py > bar1.py-16){
      vx *= -1;
    }
    
    
    if(px > bar2.px-8 && px < bar2.px+4 && py < bar2.py+16 && py > bar2.py-16){
      vx *= -1;
    }
    
    
    if(px-4 < 0 || px+4 > court_width){
      reset();
    }
    
    
  }
  
  void reset(){
      float tx = random(-2.0,2.0);
      float ty = random(-2.0,2.0);
      tx = tx>0 ? tx+2.5 : tx-2.5;
      update(court_centerx,court_centery,tx,ty );
  }
  
  void display(){
    pushMatrix();
    translate(px,py);
    fill(colWE);
    rect(0,0,8,8);
    popMatrix();
  }
};
