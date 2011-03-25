#include <NewSoftSerial.h>
#include <OLED.h>

// ボタンを接続したピンの番号
const int buttonPin = 8;

// OLEDオブジェクトを用意。引数はRx、Tx、リセットの各ピン番号
OLED oled(2, 3, 4);

// 前回ボタンが押されていたか否か
boolean wasPressed = true;

void setup() {
  // OLEDを初期化
  oled.init();

  // 背景色を黒にセットして画面をクリア
  oled.setBackgroundColour(OLED_BLACK);
  oled.clearScreen();
}

void loop() {
  // 現在ボタンが押されているか否かをチェック
  boolean isPressed = (digitalRead(buttonPin) == HIGH);

  // 前回ボタンが押されていなくて今回押されていれば
  if (!wasPressed && isPressed) {
    // μSDカードからムービーを読み込んで表示
    // 引数はx、y、幅、高さ、色数、フレームの間隔、フレーム数、セクタアドレス
    oled.displayVideoAnimationClipFromMemoryCard(
      0, 0, 128, 128, OLED_COLOR_16, 100, 0x001E, 0x001000);
  }

  // 前回の値として今回の値をセット
  wasPressed = isPressed;

  // 次のループ開始までに10ms待つ
  delay(10);
}

