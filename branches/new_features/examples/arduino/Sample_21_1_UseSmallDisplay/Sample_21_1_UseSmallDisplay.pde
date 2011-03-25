#include <NewSoftSerial.h>
#include <OLED.h>

// OLEDオブジェクトを用意。引数はRx、Tx、リセットの各ピン番号
OLED oled(2, 3, 4);

void setup() {
  // OLEDを初期化
  oled.init();

  // 背景色を黒にセット
  oled.setBackgroundColour(OLED_BLACK);

  // 画面をクリア
  oled.clearScreen();

  // 文字列をテキストとして描画
  // 引数は桁、行、フォント、文字列、描画色
  oled.drawStringAsText(1, 8, OLED_FONT1, "Hello, world!",
                        OLED_WHITE);
}

// loopでは特に何も処理を行わない
void loop() { 

}

