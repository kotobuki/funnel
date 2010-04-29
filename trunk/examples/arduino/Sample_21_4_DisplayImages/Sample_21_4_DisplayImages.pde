#include <NewSoftSerial.h>
#include <OLED.h>

// ボタンに接続したピンの番号
const int buttonPin = 8;

// 1枚目と2枚目のセクタアドレス
const unsigned long sectorAddress[] = {
  0x001000,
  0x001040
};

// OLEDオブジェクトを用意。引数はRx、Tx、リセットの各ピン番号
OLED oled(2, 3, 4);

// 前回ボタンが押されていたか否か
boolean wasPressed = true;

void setup() {
  // OLEDを初期化
  oled.init();

  // 背景色を黒にセット
  oled.setBackgroundColour(OLED_BLACK);

  // 画面をクリア
  oled.clearScreen();
}

void loop() {
  // 現在ボタンが押されているか否かをチェック
  boolean isPressed = (digitalRead(buttonPin) == HIGH);

  // 前回ボタンが押されていなくて今回押されていれば
  if (!wasPressed && isPressed) {
    // μSDカードからイメージを読み込んで表示
    // 引数はx、y、幅、高さ、色数、セクタアドレス
    oled.displayImageIconFromMemoryCard(
      0, 0, 128, 128, OLED_COLOR_16, sectorAddress[0]);
  }
  // 前回ボタンが押されていて今回押されていなければ
  else if (wasPressed && !isPressed) {
    // μSDカードからイメージを読み込んで表示
    oled.displayImageIconFromMemoryCard(
      0, 0, 128, 128, OLED_COLOR_16, sectorAddress[1]);
  }

  // 前回の値として今回の値をセット
  wasPressed = isPressed;

  // 次のループ開始までに10ms待つ
  delay(10);
}

