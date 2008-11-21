/**
 * A simple oscilloscope class
 */

class Scope {
  private int l;
  private int t;
  private int h;
  private float values[];
  private int index = 0;
  private int points = 200;
  private String title;

  Scope(int l, int t, int w, int h, String title) {
    this.l = l;
    this.t = t;
    this.h = h;
    this.points = w;
    this.title = title;

    values = new float[this.points];
  }

  public void updateAndDraw(float value) {
    values[index] = value;

    smooth();

    textSize(12);
    text(title, l - 24, t - 8);
    text("1.0", l - 24, t + 8);
    text("0.0", l - 24, t + h);
    text("val: " + value, l + points + 8, t + 8);

    // draw outlines
    stroke(200);
    noFill();
    beginShape();
    vertex(l - 1, t - 1);
    vertex(l + points, t - 1);
    vertex(l + points, t + h);
    vertex(l - 1, t + h);
    endShape(CLOSE);

    // draw the signal
    stroke(255);
    beginShape();
    for (int i = 1; i < points; i++) {
      vertex(l + i, t + h - values[(index + i) % points] * (float)h);
    }
    endShape();

    index = (index + 1) % points;
  }
}


