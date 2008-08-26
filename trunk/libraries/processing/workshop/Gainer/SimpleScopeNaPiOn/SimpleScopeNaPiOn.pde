/**
 * din 0から指定した数だけのポートの入力波形を表示します
 */

import processing.funnel.*;

final int kChannles = 1;  // the number of channels to display
final int kPoints = 200;  // the number of points to display

Gainer gainer;
PFont fixedWidthFont;
float values[][];
int index = 0;

void setup()
{
  size(400, 400);
  frameRate(30);

  fixedWidthFont = loadFont("CourierNewPSMT-12.vlw");

  values = new float[kChannles][kPoints];

  for (int channel = 0; channel < kChannles; channel++) {
    for (int i=0; i < kPoints; i++) {
      values[channel][i] = 0;
    }
  }

  gainer = new Gainer(this, Gainer.MODE1);
}

final int kLeft = 35;
final int kTop = 25;
final int kHeight = 100;

void draw()
{ 
  background(0);

  smooth();

  for (int channel = 0; channel < kChannles; channel ++) {
    int offset = channel * 130;

    textFont(fixedWidthFont);
    textSize(12);
    text("digitalInput(" + channel + ")", kLeft - 24, kTop - 8 + offset);
    text("1.0", kLeft - 24, kTop + 8 + offset);
    text("0.0", kLeft - 24, kTop + kHeight + offset);
    text("val: " + gainer.digitalInput(channel).value, kLeft + kPoints + 8, kTop + 8 + offset);
    text("max: " + gainer.digitalInput(channel).maximum, kLeft + kPoints + 8, kTop + 20 + offset);
    text("min: " + gainer.digitalInput(channel).minimum, kLeft + kPoints + 8, kTop + 32 + offset);
    text("avg: " + gainer.digitalInput(channel).average, kLeft + kPoints + 8, kTop + 44 + offset);

    values[channel][index] = gainer.digitalInput(channel).value;

    // draw outlines
    stroke(200);
    noFill();
    beginShape();
    vertex(kLeft - 1, kTop - 1 + offset);
    vertex(kLeft + kPoints, kTop - 1 + offset);
    vertex(kLeft + kPoints, kTop + kHeight + offset);
    vertex(kLeft - 1, kTop + kHeight + offset);
    endShape(CLOSE);
  
    // draw the signal
    stroke(255);
    beginShape();
    for (int i = 1; i < kPoints; i++) {
      vertex(kLeft + i, kTop + kHeight - values[channel][(index + i) % kPoints] * (float)kHeight + offset);
    }
    endShape();
  }

  index = (index + 1) % kPoints;
}

