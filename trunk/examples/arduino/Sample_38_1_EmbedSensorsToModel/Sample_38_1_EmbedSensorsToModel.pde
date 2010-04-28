#include <stdint.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>

#define SAMPLE_RATE 8000
#include "PCMData.h"

// センサに接続したピンの番号
const int sensorPin = 0;

// スピーカに接続したピンの番号
const int speakerPin = 11;

// 閾値
int threshold = 200;

// ヒステリシス
int hysteresis = 50;

// 前回モデルの口が開いていたか否か
boolean wasOpened = false;
volatile uint16_t sample;
byte lastSample;

// タイマ割り込みでサウンドを再生
ISR (TIMER1_COMPA_vect) {
  if (sample >= SOUNDDATA_LENGTH) {
    if (sample == SOUNDDATA_LENGTH + lastSample) {
      stopPlayback();
    }
    else {
      OCR2A = SOUNDDATA_LENGTH + lastSample - sample;
    }
  }
  else {
    OCR2A = pgm_read_byte(&soundData[sample]);
  }
  ++sample;
}

// サウンド再生開始
void startPlayback() {
  ASSR &= ~(_BV(EXCLK) | _BV(AS2));
  TCCR2A |= _BV(WGM21) | _BV(WGM20);
  TCCR2B &= ~_BV(WGM22);
  TCCR2A = (TCCR2A | _BV(COM2A1)) & ~_BV(COM2A0);
  TCCR2A &= ~(_BV(COM2B1) | _BV(COM2B0));
  TCCR2B = (TCCR2B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);
  OCR2A = pgm_read_byte(&soundData[0]);
  cli();
  TCCR1B = (TCCR1B & ~_BV(WGM13)) | _BV(WGM12);
  TCCR1A = TCCR1A & ~(_BV(WGM11) | _BV(WGM10));
  TCCR1B = (TCCR1B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);
  OCR1A = F_CPU / SAMPLE_RATE;
  TIMSK1 |= _BV(OCIE1A);
  lastSample = pgm_read_byte(
  &soundData[SOUNDDATA_LENGTH - 1]);
  sample = 0;
  sei();
}

// サウンド再生停止
void stopPlayback() {
  TIMSK1 &= ~_BV(OCIE1A);
  TCCR1B &= ~_BV(CS10);
  TCCR2B &= ~_BV(CS10);
  digitalWrite(speakerPin, LOW);
}

void setup() {
  // スピーカを接続したピンのモードを出力にセット
  pinMode(speakerPin, OUTPUT);
}

void loop() {
  // センサの値を読み取る
  int sensorReading = analogRead(sensorPin);

  // 現在モデルの口が開いているか否か
  boolean isOpened = wasOpened;
  if (sensorReading > (threshold + hysteresis)) {
    // センサの値が閾値＋ヒステリシスよりも大きければ開いていると判断
    isOpened = true;
  }
  else if (sensorReading < (threshold - hysteresis)) {
    // センサの値が閾値＋ヒステリシスよりも小さければ閉じていると判断
    isOpened = false;
  }

  // 前回閉じていて今回開いていたらサウンド再生を開始
  if (!wasOpened && isOpened) {
    startPlayback();
  }

  // 前回の状態を表す変数を今回の値で更新
  wasOpened = isOpened;

  // 次のループ開始まで10ms待つ
  delay(10);
}

