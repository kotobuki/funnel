class Bar{
  color c;
  float px;
  float py;

  
  Bar(color c,float x,float y){
    px = x;
    py = y;
    this.c = c;
  }
  /*
  void center(){
    py = court_centery;
  }
  
  void update(float vy){
    py +=vy;
    if(py-15 < court_y+wall){
      py = court_y+wall +15;
    }else if(py+15 > court_y+court_height+wall){
      py = court_y+court_height+wall -15;
    }
  }*/
  
  void update(int y){
    float ty = (float)y/255;
    
    py = ty*court_height + court_y;
    if(py-15 < court_y+wall){
      py = court_y+wall +15;
    }else if(py+15 > court_y+court_height+wall){
      py = court_y+court_height+wall -15;
    }   
  }
  
  void display(){
    pushMatrix();
    translate(px,py);
    fill(c);
    rect(0,0,16,30);
    popMatrix(); 
  }
}
