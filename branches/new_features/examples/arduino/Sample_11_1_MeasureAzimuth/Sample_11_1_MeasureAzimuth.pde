// 参照：forum.sparkfun.com/viewtopic.php?t=6236
#include <Wire.h>

// HMC6352のI2Cアドレス
// データシートに記載されているのは0x42だが、これは8bitで表現した
// アドレスであるため、7bitでの表現にしたものをアドレスとして扱う
const int i2cAddress = 0x42 >> 1;

// RGB LED中の赤、緑、青に接続したピンの番号
const int redPin = 11;
const int greenPin = 9;
const int bluePin = 10;

// Arduinoボード上のLEDに接続されているピン番号
const int ledPin = 13;

// HSVからRGBに変換する関数のプロトタイプ
void hsv2rgb(
  float h, float s, float v, int& r, int& g, int& b);

void setup() {
  // RGB LEDとボード上のLEDに接続したピンのモードを出力にセット
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(ledPin, OUTPUT);

  // アナログピンの3 番と2 番をそれぞれ+5VとGNDにセット
  enablePowerPins(PORTC3, PORTC2);

  // I2Cバスをスタート
  Wire.begin();

  // 読み取った方位角をシリアルモニタで確認するためシリアル通信をスタート
  Serial.begin(9600);
}

void loop() {
  // デジタルコンパスに対してコマンドを送信して方位角を読み取る
  Wire.beginTransmission(i2cAddress);
  Wire.send("A");
  Wire.endTransmission();

  // データシートによるとコマンド送信後に角度を取得できるまで
  // 6ms待つということなのでここで一定時間待つ
  delay(6);

  // デジタルコンパスにデータを要求する
  Wire.requestFrom(i2cAddress, 2);

  // 2 バイト分のデータがそろうまで待つ
  // 一定時間待ってもデータがそろわない場合にはコンパスが正常に
  // 動作していないことが考えられるため
  int count = 0;
  while (Wire.available() < 2) {
    // もしデータがそろっていなければ500μs待つ
    delayMicroseconds(500);
    // 10回以上待ってもデータがこない場合にはタイムアウトと判定する
    count++;
    if (count > 10) {
      // D13のLEDを3 回点滅させてloopからリターン
      for (int i = 0; i < 3; i++) {
        digitalWrite(ledPin, HIGH);
        delay(250);
        digitalWrite(ledPin, LOW);
        delay(250);
      }
      return;
    }
  }

  // 読み取った値から方位角を求める（0から3600が0～360.0度に対応）
  int reading;
  reading = Wire.receive();
  reading = reading << 8;
  reading += Wire.receive();

  // シリアルに方位角（整数部と小数部）をプリントする
  Serial.print("Heading: ");
  Serial.print(int(reading / 10));
  Serial.print(".");
  Serial.print(int(reading % 10));
  Serial.println(" degree");

  // 方位角からHue（色相）を決める
  // Saturation（彩度）とValue（明度）は1で固定
  float h = (float)reading / 3600;
  float s = 1, v = 1;
  int r, g, b;

  // HSV色空間からRGB色空間に変換
  hsv2rgb(h, s, v, r, g, b);

  // RGB LEDのそれぞれのLEDの輝度を更新
  analogWrite(redPin, r);
  analogWrite(greenPin, g);
  analogWrite(bluePin, b);

  // 次のループ開始までに100ms待つ
  delay(100);
}

// 指定したピンをそれぞれ+5VとGNDにセットする
// 参照：ThingM（thingm.com）のTod E. KurtによるBlinkM_funcs.h
static void enablePowerPins(byte pwrPin, byte gndPin) {
  DDRC |= _BV(pwrPin) | _BV(gndPin);
  PORTC &=~ _BV(gndPin);
  PORTC |= _BV(pwrPin);
}

// HSV色空間からRGB色空間に変換
// 参照：www.hcn.zaq.ne.jp/no-ji/lib/ColorSpace.c
// www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1207331496
void hsv2rgb(float h, float s, float v, int& r, int& g, int& b) {
  float phase, ofs, d1, d2, d3;

  if (s == 0) {
    r = floor(v * 255);
    g = floor(v * 255);
    b = floor(v * 255);
  }
  else {
    phase = (h - floor(h)) * 6;
    ofs = phase - floor(phase);
    d1 = v * (1 - s);
    d2 = v * (1 - s * ofs);
    d3 = v * (1 - s * (1 - ofs));
    switch ((int)phase) {
    case 0:
      r = floor(v * 255);
      g = floor(d3 * 255);
      b = floor(d1 * 255);
      break;
    case 1:
      r = floor(d2 * 255);
      g = floor(v * 255);
      b = floor(d1 * 255);
      break;
    case 2:
      r = floor(d1 * 255);
      g = floor(v * 255);
      b = floor(d3 * 255);
      break;
    case 3:
      r = floor(d1 * 255);
      g = floor(d2 * 255);
      b = floor(v * 255);
      break;
    case 4:
      r = floor(d3 * 255);
      g = floor(d1 * 255);
      b = floor(v * 255);
      break;
    case 5:
      r = floor(v * 255);
      g = floor(d1 * 255);
      b = floor(d2 * 255);
      break;
    }
  }
}

