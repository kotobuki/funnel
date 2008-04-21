/*
 * Gainer用のProcessingライブラリに含まれているサンプルを
 * Funnel用に変更したもの
 */

import processing.funnel.*;

float court_x = 0;
float court_y = 50;
float court_width = 560;
float court_height = 310;

float wall = 20;
float bar_pos = 60;

float court_centerx = court_width/2;
float court_centery = court_y+wall+court_height/2;

color colBK = #9c4a58;
color colRD = #ce906b;
color colGN = #4dc854;
color colWE = #fcfcfc;

Ball b;
Bar bar1,bar2;

Gainer gainer;

void setup()
{
  size(560,400);
  background(colBK);
  noStroke();
  frameRate(30);
  rectMode(CENTER);

  b = new Ball(100,100); 
  b.reset();

  bar1 = new Bar(colRD,bar_pos,court_centery);
  bar2 = new Bar(colGN,court_width-bar_pos,court_centery);

  gainer = new Gainer(this, Gainer.MODE1);
}

void draw()
{
  background(colBK);
  fill(colWE);
  rectMode(CORNER);
  rect(court_x,court_y,court_width,20);
  rect(court_x,court_y+court_height+20,court_width,20); 
  rectMode(CENTER);
  b.update();
  b.display();
  
  bar1.update((int)(gainer.analogInput(0).value * 255.0));
  bar2.update((int)(gainer.analogInput(1).value * 255.0));

  bar1.display();
  bar2.display();
}
