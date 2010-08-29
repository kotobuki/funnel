#include <Firmata.h>
#include <Stepper.h>

// 動作確認に使用するLEDに接続したデジタルピンの番号
const int ledPin = 13;

// ステッピングモータを表すオブジェクト
// 引数はステップ数とモータに接続されたピンの番号（4個）
Stepper stepper(100, 8, 9, 10, 11);

// ステッピングモータの回転方向
int steps = 0;

void setup() {
  // モータの回転速度を30回転/分にセット
  stepper.setSpeed(30);

  // Firmataの文字列イベントに対するイベントハンドラをセット
  Firmata.attach(STRING_DATA, stringCallback);
  Firmata.begin(57600);

  // 動作確認に使用するLEDに接続したピンのモードを出力にセット
  pinMode(ledPin, OUTPUT);
}

void stringCallback(char *message) {
  // 受取った文字列の最初の1文字目に応じて回転方向をセットする
  if (message[0] == '+') {
    steps = 1;
    Firmata.sendString("Forward");
    digitalWrite(ledPin, HIGH);
  } 
  else if (message[0] == '0') {
    steps = 0;
    Firmata.sendString("Stop");
    digitalWrite(ledPin, LOW);
  } 
  else if (message[0] == '-') {
    steps = -1;
    Firmata.sendString("Backward");
    digitalWrite(ledPin, HIGH);
  }
}

void loop() {
  // PC側から受取ったメッセージを処理する
  while (Firmata.available()) {
    Firmata.processInput();
  }

  // ステッピングモータを1ステップ進める
  stepper.step(steps);
}

/*
package {
  import flash.display.Sprite;
  import flash.events.KeyboardEvent;

  import funnel.*;

  public class StepperFirmataTest extends Sprite {
    // Arduino
    private var arduino:Arduino;

    public function StepperFirmataTest() {
      // ステッピングモータを接続したArduino
      arduino = new Arduino(Arduino.FIRMATA);

      // Arduinoボードの準備ができた時に発生するイベントのイベントリスナをセット
      arduino.addEventListener(FunnelEvent.READY, onReady);

      // 動作確認用にキーボードで操作するため、キーイベントに対するリスナをセット
      stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    // Arduinoボードの準備ができたら
    private function onReady(e:FunnelEvent):void {
      // ステッピングモータの回転を停止させる
      arduino.sendFirmataString("0");
    }

    private function onKeyDown(e:KeyboardEvent):void {
      if (e.keyCode == 39) { // →キー
        trace("Forward");
        arduino.sendFirmataString("+");
      } else if (e.keyCode == 37) { // ←キー
        trace("Backward");
        arduino.sendFirmataString("-");
      } else if (e.keyCode == 40) { // ↓キー
        trace("Stop");
        arduino.sendFirmataString("0");
      }
    }
  }
}
*/
