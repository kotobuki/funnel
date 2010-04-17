#include <Firmata.h>

// スイッチに接続したピンの番号
const int switchPin = 6;

// 最初の桁のLEDに接続したピンの番号
const int firstLedPin = 7;

// 更新の間隔
const int updateInterval = 3000;

// パターンの行数
const int numPatterns = 14;

// パターンを収める配列
int pattern[numPatterns] = {
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
  B0000000,
};

// 次回更新を行う時刻
unsigned long nextExecuteMicros = 0;

// 前回スイッチが押された時刻
unsigned long lastPressed = 0;

// パターンの行のインデックス
int index = 0;

// システム・エクスクルーシブ・メッセージのコールバック
void sysexCallback(byte command, byte argc, byte *argv) {
  switch (command) {
  case 0x10:
    if (argc == (numPatterns * 2)) {
      for (int i = 0; i < numPatterns; i++) {
        pattern[i] = argv[i * 2] + (argv[i * 2 + 1] << 7);
      }
    }
    break;
  }
}

void setup() {
  // それぞれの桁のLEDに接続したピンのモードを出力にセット
  for (int i = 0; i < 7; i++) {
    int pin = i + firstLedPin;
    pinMode(pin, OUTPUT);
  }

  // スイッチに接続したピンのモードを入力にセットし
  // チップ内部のプルアップをセット
  pinMode(switchPin, INPUT);
  digitalWrite(switchPin, HIGH);

  // システム・エクスクルーシブ・メッセージのコールバックをセットして
  // Firmataをスタート
  Firmata.attach(START_SYSEX, sysexCallback);
  Firmata.begin(57600);
}

void loop() {
  // 現在の時刻を取得する
  unsigned long currentMicros = micros();

  // スイッチに接続したピンがロー（押された状態）であれば
  if (digitalRead(switchPin) == LOW) {
    // 前回押されてから10000uS経過していたら
    if ((currentMicros - lastPressed) > 10000) {
      // ホストに対して文字列「!」を送信し
      // 更新の間隔と表示する行のインデックスをリセット
      Firmata.sendString("!");
      nextExecuteMicros = currentMicros + updateInterval;
      index = 0;
    }
    // 前回押された時刻として現在の時刻をセット
    lastPressed = currentMicros;
  }

  // ホストから受信したメッセージがあれば処理
  while (Firmata.available()) {
    Firmata.processInput();
  }

  // 更新の時刻になっていたら
  if (currentMicros > nextExecuteMicros) {
    // 次回の更新時刻を現在の時刻＋更新の間隔にセット
    nextExecuteMicros = currentMicros + updateInterval;

    // 全ての行を表示し終えていたら全ての桁のLEDを消灯して以下の処理をスキップ
    if (index == numPatterns) {
      for (int i = 0; i < 7; i++) {
        int pin = i + firstLedPin;
        digitalWrite(pin, LOW);
      }
      return;
    }

    // 全ての桁のLEDの表示を更新
    for (int i = 0; i < 7; i++) {
      // パターンデータから表示する桁ごとにビットマスクで値を読取って表示
      int pin = i + firstLedPin;
      int bitMask = B1000000 >> i;
      if ((pattern[index] & bitMask) != 0) {
        digitalWrite(pin, HIGH);
      }
      else {
        digitalWrite(pin, LOW);
      }
    }

    // 行のインデックスを更新（最大値はパターンデータの行数）
    index = min(index + 1, numPatterns);
  }
}
