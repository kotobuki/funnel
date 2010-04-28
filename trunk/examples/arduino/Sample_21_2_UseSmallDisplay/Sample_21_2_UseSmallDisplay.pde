#include <NewSoftSerial.h>
#include <OLED.h>

// ボタンに接続したピンの番号
const int buttonPin = 8;

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

  // ペンを塗りつぶしにセット
  oled.setPenSize(OLED_SOLID);

  // 白い矩形を描画
  // 引数は左上のxとy、右下のxとy、描画色
  oled.drawRectangle(3, 4, 85, 18, OLED_WHITE);

  // ペンをワイヤフレームにセット
  oled.setPenSize(OLED_WIRE_FRAME);

  // 赤い枠を描画
  oled.drawRectangle(3, 4, 85, 18, OLED_RED);

  // 赤い文字列をテキストとして描画
  // 引数は桁、行、フォント、文字列、描画色
  oled.drawStringAsText(1, 1, OLED_FONT1, "Make:",
                        OLED_RED);
  // シアンで文字列をテキストとして描画
  unsigned int color = oled.get16bitColourFromRGB(0, 174,
                                                  239);
  oled.drawStringAsText(6, 1, OLED_FONT1, "PROJECTS", color);
  oled.drawStringAsText(1, 3, OLED_FONT1, "Prototyping",
                        color);
  oled.drawStringAsText(1, 4, OLED_FONT1, "Lab", color);

  // マゼンタで円を描画
  // 引数は中心点のxとy、半径、描画色
  color = oled.get16bitColourFromRGB(236, 0, 140);
  oled.setPenSize(OLED_SOLID);
  oled.drawCircle(64, 64, 16, color);

  // イエローで三角形を描画
  // 引数は第1 点のxとy、第2 点のxとy、第3 点のxとy、描画色
  // 点を指定する順番は必ず反時計回りにする
  color = oled.get16bitColourFromRGB(255, 212, 0);
  oled.drawTriangle(81, 80, 113, 80, 81, 48, color);
}

void loop() {
  // 現在ボタンが押されているか否かをチェック
  boolean isPressed = (digitalRead(buttonPin) == HIGH);

  // 前回ボタンが押されていなくて今回押されていれば
  if (!wasPressed && isPressed) {
    // 文字列「ON!」をテキストボタンとして描画
    // 引数はボタンの状態、x、y、ボタンの描画色、フォント
    // テキストの描画色、横方向の倍率、縦方向の倍率、文字列
    oled.drawTextButton(
      OLED_BUTTON_DOWN, 0, 96, OLED_WHITE, OLED_FONT1,
      OLED_BLACK, 1, 1, "ON!");
  }

  // 前回ボタンが押されていて今回押されていなければ
  else if (wasPressed && !isPressed) {
    // 文字列「OFF」をテキストボタンとして描画
    oled.drawTextButton(
      OLED_BUTTON_UP, 0, 96, OLED_WHITE, OLED_FONT1,
      OLED_BLACK, 1, 1, "OFF");
  }

  // 前回の値として今回の値をセット
  wasPressed = isPressed;

  // 現在の時刻を表示するための文字列を用意
  char timeString[17];
  sprintf(timeString, "Time:%ld", millis());

  // 前回文字列を表示していた部分だけを黒で塗りつぶす
  oled.setPenSize(OLED_SOLID);
  oled.drawRectangle(0, 120, 127, 127, OLED_BLACK);

  // 文字列をテキストとして描画
  oled.drawStringAsText(1, 15, OLED_FONT1, timeString,
                        OLED_WHITE);

  // 次のループ開始までに100ms待つ
  delay(100);
}

