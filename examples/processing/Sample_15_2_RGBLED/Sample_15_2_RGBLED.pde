import processing.funnel.*;

// LEDのドライブ方法に関する定数
final int COMMON_KATHODE = 0;
final int COMMON_ANODE = 1;

Arduino arduino;

// R、G、BそれぞれのLEDに接続したデジタルピン
Pin rLEDPin;
Pin gLEDPin;
Pin bLEDPin;

// R、G、Bそれぞれをコントロールする可変抵抗器に接続したアナログピン
Pin rPotPin;
Pin gPotPin;
Pin bPotPin;

// LEDのドライブモード。アノードコモンの場合にはここをCOMMON_ANODEに変更する
int driveMode = COMMON_KATHODE;

void setup() {
  size(200, 200);

  // テキスト表示用のフォントを生成してセット
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  config.setDigitalPinMode(10, Arduino.PWM);
  config.setDigitalPinMode(11, Arduino.PWM);
  arduino = new Arduino(this, config);

  // LEDと可変抵抗器に接続したピンを表す変数を初期化
  rLEDPin = arduino.digitalPin(9);
  gLEDPin = arduino.digitalPin(10);
  bLEDPin = arduino.digitalPin(11);
  rPotPin = arduino.analogPin(0);
  gPotPin = arduino.analogPin(1);
  bPotPin = arduino.analogPin(2);
}

void draw() {
  // カソードコモンであれば可変抵抗器の値をそのまま出力にセット
  if (driveMode == COMMON_KATHODE) {
    rLEDPin.value = rPotPin.value;
    gLEDPin.value = gPotPin.value;
    bLEDPin.value = bPotPin.value;
  }
  // アノードコモンであれば可変抵抗器の値を反転させて出力にセット
  else {
    rLEDPin.value = 1 - rPotPin.value;
    gLEDPin.value = 1 - gPotPin.value;
    bLEDPin.value = 1 - bPotPin.value;
  }

  // 背景を黒で塗りつぶしてR、G、Bそれぞれの値を表示
  background(0);
  text("R: " + rPotPin.value, 10, 20);
  text("G: " + gPotPin.value, 10, 40);
  text("B: " + bPotPin.value, 10, 60);
}

