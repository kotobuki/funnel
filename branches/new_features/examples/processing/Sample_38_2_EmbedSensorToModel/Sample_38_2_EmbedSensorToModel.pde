import ddf.minim.*;
import processing.funnel.*;

Arduino arduino;
Pin sensorPin;
Minim minim;
AudioSample crySound;

void setup() {
  size(400, 400);

  // Minimを初期化し、鳴き声用のサウンドデータをロードする
  minim = new Minim(this);
  crySound = minim.loadSample("cry.mp3");

  // センサに接続したピンにSetPointフィルタをセットする
  arduino = new Arduino(this, Arduino.FIRMATA);
  sensorPin = arduino.analogPin(0);
  SetPoint setPoint = new SetPoint(0.2, 0.05);
  sensorPin.addFilter(setPoint);
}

void draw() {
  background(100);
}

void risingEdge(PinEvent e) {
  // センサに接続したピンの立ち上がりでサウンドを再生
  if (e.target == sensorPin) {
    crySound.trigger();
  }
}

void stop() {
  crySound.close();
  minim.stop();
  super.stop();
}

