#include <Wire.h>

// スイッチに接続したピンの番号
const int switchPin = 6;

// 最初の桁のLEDに接続したピンの番号
const int firstLedPin = 7;

// Japaninoボード上のLEDに接続されているピン番号
const int ledPin = 13;

// 更新の間隔
const unsigned long updateInterval = 3000;

// 更新の間隔
const unsigned long pollingInterval = 100000;

// パターンの行数
const int numPatterns = 15;

// HMC6352のI2Cアドレス
// データシートに記載されているのは0x42だが、これは8bitで表現した
// アドレスであるため、7bitでの表現にしたものをアドレスとして扱う
const int i2cAddress = 0x42 >> 1;

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
  B0000000,
};

// 次回更新を行う時刻
unsigned long nextExecuteMicros = 0;

// 次回更新を行う時刻
unsigned long nextPollingMicros = 0;

// 前回スイッチが押された時刻
unsigned long lastPressed = 0;

// パターンの行のインデックス
int index = 0;

void setup() {
  // アナログピンの3番と2番をそれぞれ+5VとGNDにセット
  enablePowerPins(PORTC3, PORTC2);

  // それぞれの桁のLEDに接続したピンのモードを出力にセット
  for (int i = 0; i < 7; i++) {
    int pin = i + firstLedPin;
    pinMode(pin, OUTPUT);
  }

  // スイッチに接続したピンのモードを入力にセットし
  // チップ内部のプルアップをセット
  pinMode(switchPin, INPUT);
  digitalWrite(switchPin, HIGH);

  // LEDに接続したピンのモードを出力にセット
  pinMode(ledPin, OUTPUT);

  // I2Cバスをスタート
  Wire.begin();
}

void loop() {
  // 現在の時刻を取得する
  unsigned long currentMicros = micros();

  // スイッチに接続したピンがロー（押された状態）であれば
  if (digitalRead(switchPin) == LOW) {
    // 前回押されてから10000uS経過していたら
    if ((currentMicros - lastPressed) > 10000) {
      // 更新の間隔と表示する行のインデックスをリセット
      nextExecuteMicros = currentMicros + updateInterval;
      index = 0;
    }
    // 前回押された時刻として現在の時刻をセット
    lastPressed = currentMicros;
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

  // 更新の時刻になっていたら
  if (currentMicros > nextPollingMicros) {
    // 次回の更新時刻を現在の時刻＋更新の間隔にセット
    nextPollingMicros = currentMicros + pollingInterval;
    
    // 方位角を読み取る
    readHeading();
  }
}

void readHeading() {
    // デジタルコンパスに対してコマンドを送信して方位角を読み取る
    Wire.beginTransmission(i2cAddress);
    Wire.send("A");
    Wire.endTransmission();

    // データシートによるとコマンド送信後に角度を取得できるまで
    // 6ms待つということなのでここで一定時間待つ
    delay(6);

    // デジタルコンパスにデータを要求する
    Wire.requestFrom(i2cAddress, 2);

    // 2 バイト分のデータがそろうまで待つ
    // 一定時間待ってもデータがそろわない場合にはコンパスが正常に
    // 動作していないことが考えられるため
    int count = 0;
    while (Wire.available() < 2) {
      // もしデータがそろっていなければ500μs待つ
      delayMicroseconds(500);
      // 10回以上待ってもデータがこない場合にはタイムアウトと判定する
      count++;
      if (count > 10) {
        // D13のLEDを3 回点滅させてloopからリターン
        for (int i = 0; i < 3; i++) {
          digitalWrite(ledPin, HIGH);
          delay(250);
          digitalWrite(ledPin, LOW);
          delay(250);
        }
        return;
      }
    }

    // 読み取った値から方位角を求める（0から3600が0～360.0度に対応）
    int heading;
    heading = Wire.receive();
    heading = heading << 8;
    heading += Wire.receive();

    // 読み取った方位角から4つの方角を判断する
    if ((3300 < heading && heading < 3599) || (0 < heading && heading < 300)) {
      // 330度〜30度であれば北（Northの頭文字でN）
      pattern[0]  = B0000000;
      pattern[1]  = B0000000;
      pattern[2]  = B0000000;
      pattern[3]  = B0000000;
      pattern[4]  = B1111111;
      pattern[5]  = B0000010;
      pattern[6]  = B0000100;
      pattern[7]  = B0001000;
      pattern[8]  = B0010000;
      pattern[9]  = B0100000;
      pattern[10] = B1111111;
      pattern[11] = B0000000;
      pattern[12] = B0000000;
      pattern[13] = B0000000;
      pattern[14] = B0000000;
    } 
    else if (600 < heading && heading < 1200) {
      // 60度〜120度であれば東（Eastの頭文字でE）
      pattern[0]  = B0000000;
      pattern[1]  = B0000000;
      pattern[2]  = B0000000;
      pattern[3]  = B0000000;
      pattern[4]  = B1111111;
      pattern[5]  = B1001001;
      pattern[6]  = B1001001;
      pattern[7]  = B1001001;
      pattern[8]  = B1001001;
      pattern[9]  = B1001001;
      pattern[10] = B1001001;
      pattern[11] = B0000000;
      pattern[12] = B0000000;
      pattern[13] = B0000000;
      pattern[14] = B0000000;
    } 
    else if (1500 < heading && heading < 2100) {
      // 150度〜210度であれば南（Southの頭文字でS）
      pattern[0]  = B0000000;
      pattern[1]  = B0000000;
      pattern[2]  = B0000000;
      pattern[3]  = B0000000;
      pattern[4]  = B0100110;
      pattern[5]  = B1001001;
      pattern[6]  = B1001001;
      pattern[7]  = B1001001;
      pattern[8]  = B1001001;
      pattern[9]  = B1001001;
      pattern[10] = B0110010;
      pattern[11] = B0000000;
      pattern[12] = B0000000;
      pattern[13] = B0000000;
      pattern[14] = B0000000;
    } 
    else if (2400 < heading && heading < 3000) {
      // 240度〜300度であれば西（Westの頭文字でW）
      pattern[0]  = B0000000;
      pattern[1]  = B0000000;
      pattern[2]  = B0000000;
      pattern[3]  = B0000000;
      pattern[4]  = B1111111;
      pattern[5]  = B0100000;
      pattern[6]  = B0010000;
      pattern[7]  = B0001000;
      pattern[8]  = B0010000;
      pattern[9]  = B0100000;
      pattern[10] = B1111111;
      pattern[11] = B0000000;
      pattern[12] = B0000000;
      pattern[13] = B0000000;
      pattern[14] = B0000000;
    }
}

// 指定したピンをそれぞれ+5VとGNDにセットする
// 参照：ThingM（thingm.com）のTod E. KurtによるBlinkM_funcs.h
static void enablePowerPins(byte pwrPin, byte gndPin) {
  DDRC |= _BV(pwrPin) | _BV(gndPin);
  PORTC &=~ _BV(gndPin);
  PORTC |= _BV(pwrPin);
}

