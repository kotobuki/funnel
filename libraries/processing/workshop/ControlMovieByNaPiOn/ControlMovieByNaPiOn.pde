/**
 * din 0�ɐڑ������œd�Z���T�̏o�͂ŐÎ~����R���g���[�����܂�
 */

import processing.funnel.*;
import processing.video.*;

Gainer gainer;
Movie myMovie;
boolean playing = false;

void setup()
{
  size(168, 128);
  background(0);
  frameRate(30);

  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.5, 0.0)
  };
  gainer.digitalInput(0).filters = filters;

  myMovie = new Movie(this, "station.mov");
  myMovie.noLoop();
  println("duration: " + myMovie.duration());
}

void movieEvent(Movie m) {
  if (m.time() < m.duration()) {
    m.read();
    println(m.time());
  } else {
    m.stop();
    playing = false;
    println("FINISHED!");
  }
}

void draw()
{
  tint(255, 20);
  image(myMovie, 4, 4);
}

void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    gainer.led().value = 1.0;

    if (!playing) {
      myMovie.jump(0);
      myMovie.play();
      playing = true;
      println("START!");
    }
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    gainer.led().value = 0.0;
  }
}
