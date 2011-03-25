import eeml.*;
import processing.funnel.*;

Arduino arduino;

// Pachubeに対してデータを出力する際に使用するオブジェクト
DataOut dataOut;

// 前回フィードを更新した時刻
float lastUpdate;

void setup() {
  // DataOutオブジェクトをセットアップ
  // 更新するEEMLのURLとAPI Keyが必要
  dataOut = new DataOut(this, "URL_OF_THE_EEML",
                        "YOUR_API_KEY");

  // データストリームにタグを追加
  dataOut.addData(0, "light sensor");
  arduino = new Arduino(this, Arduino.FIRMATA);
}

void draw() {
  // 前回更新してから5 秒が経過したら以下を実行
  if ((millis() - lastUpdate) > 5000) {
    println("ready to POST: ");
    // データストリームを更新
    dataOut.update(0, arduino.analogPin(0).value);

    // updatePachube()で認証されたPUT HTTPリクエストにより更新
    int response = dataOut.updatePachube();

    // 成功したら200、認証に失敗したら401、フィードが存在しない場合は404
    println(response);
    lastUpdate = millis();
  }
}

