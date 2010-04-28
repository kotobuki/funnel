import processing.funnel.*;

// ソレノイドに通電する時間
final int POWER_ON_DURATION = 40;

Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// ソレノイドに接続したピン
Pin solenoidPin;

// メトロノームを担当するスレッド
MetronomeThread metronome;

// 前回のテンポ
int lastTempo = 0;

void setup() {
  size(400, 400);

  // テキスト表示用のフォントを生成してセット
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // ソレノイドを接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // センサとソレノイドに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  solenoidPin = arduino.digitalPin(9);

  // 自動アップデートを停止
  // 通常、FunnelライブラリはupdateIntervalでセットした間隔ごとに
  // 出力をアップデートする。今回はより正確なタイミングで
  // コントロールするため、手動でupdateメソッドを呼ぶ
  arduino.autoUpdate = false;

  // メトロノームを担当するスレッドを生成してスタート
  metronome = new MetronomeThread(120);
  metronome.start();
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);

  // センサの値を読み取る
  float sensorReading = sensorPin.value;

  // 読み取った値を元にテンポをセット（小数点以下は四捨五入）
  int tempo = round(map(sensorReading, 0, 1, 40, 208));

  // 前回のテンポをセットしてから一定の変化があった時に更新する
  if (abs(tempo - lastTempo) > 2) {
    metronome.setTempo(tempo);
    lastTempo = tempo;
  }

  // 求めたテンポをテキストで表示
  text("Tempo: " + tempo, 10, 20);
}

// escキーを押してスケッチを終了する際に呼ばれる
public void stop() {
  // もしメトロノームスレッドが有効であれば終了を要求
  if (metronome != null) {
    metronome.quitRequested = true;
  }

  // 元々用意されている終了処理を行う
  super.stop();
}

// メトロノームのスレッド
class MetronomeThread extends Thread {
  // 終了が要求されているか否か
  boolean quitRequested = false;

  // ソレノイドをコントロールする間隔
  float interval = 500;

  // コンストラクタ
  MetronomeThread(float defaultTempo) {
    setTempo(defaultTempo);
  }

  // テンポをセットするメソッド
  void setTempo(float newTempo) {
    // 指定されたテンポから間隔を求める
    interval = 1000 / (newTempo / 60);
  }

  // スレッドで実行される処理
  void run() {
    try {
      // 終了が要求されない限り以下を繰り返し実行
      while (!quitRequested) {
        // 現在の時刻を取得
        int now = millis();

        // ソレノイドを駆動
        // updateメソッドを呼ぶことで任意のタイミングで出力を更新できる
        solenoidPin.value = 1;
        arduino.update();
        Thread.sleep(POWER_ON_DURATION);
        solenoidPin.value = 0;
        arduino.update();

        // スリープする時間を求める
        long delay = (long)(interval - (millis() - now));

        // 次の処理を開始するまでスリープする
        Thread.sleep(delay);
      }
    }
    // 例外が発生した時には以下を実行
    catch(InterruptedException e) {
      println("Interrupted Exception occurred");
    }
  }
}

