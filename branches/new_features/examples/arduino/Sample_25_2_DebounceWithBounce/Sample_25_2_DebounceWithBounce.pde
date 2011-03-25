#include <LiquidCrystal.h>
#include <Bounce.h>

// ボタンに接続したピンの番号
const int buttonPin = 8;

// デバウンサ：引数はデバウンス処理を行うピンの番号とデバウンス時間
Bounce bouncer = Bounce(buttonPin, 10);

// 前回のボタンの状態
int lastButtonState = LOW;

// ボタンが押されたカウント
int count = 0;

// LCD
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  // ボタンを接続したピンのモードを入力にセット
  pinMode(buttonPin, INPUT);

  // LCDの桁数と行数をセット
  lcd.begin(16, 2);

  // カウントをLCDにプリント
  printCount();
}

void loop() {
  // デバウンサを更新
  bouncer.update();
  // デバウンス処理を行った結果を読み取る
  int buttonState = bouncer.read();
  // 前回がLOWで今回がHIGHであれば以下を実行
  if (lastButtonState == LOW && buttonState == HIGH) {
    onPress();
  }
  // 前回の状態として現在の状態をセット
  lastButtonState = buttonState;
}

void onPress() {
  // カウントを1だけ増やす
  count = count + 1;
  // LCDにカウントをプリント
  printCount();
}

void printCount() {
  // LCDの表示内容をクリアした後カウントをプリント
  lcd.clear();
  lcd.print("Count: ");
  lcd.print(count);
}


