import eeml.*;
import processing.funnel.*;

// フィードのURL
final String FEED_URL
  = "http://www.pachube.com/api/504.xml";

// YOUR_API_KEYの部分を自分のAPI Keyで置き換える
final String API_KEY = "YOUR_API_KEY";

// LEDに接続したピン
Pin ledPin;

Arduino arduino;

// DataInオブジェクト
DataIn dataIn;

void setup() {
  size(400, 400);

  // 受け取った値の表示に使用するフォントを生成
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  arduino = new Arduino(this, config);
  ledPin = arduino.digitalPin(9);

  // DataInオブジェクトをセットアップ
  // フィードのURL、PachubeのAPI Keyと更新の間隔をミリ秒単位で設定
  dataIn = new DataIn(this, FEED_URL, API_KEY, 5000);
}

void draw() { 

}

// 要求したEEMLが返ってきたら以下が呼ばれる
void onReceiveEEML(DataIn d) {
  // ストリーム1 のデータを取得
  float lightLevel = d.getValue(1);

  // 背景の明るさをlightLevelで決め、テキストで受け取った値を表示
  background(int(map(lightLevel, 0, 1023, 0, 255)));
  text("Light level: " + lightLevel, 10, 20);

  // LEDの明るさをlightLevelで決める
  ledPin.value = map(lightLevel, 0, 1023, 0, 1);
}

