#include <StonesThrow.h>

// 自分のIDと相手のID
const int myID = 1;
const int pairWithID = 2;

// 相手側でLEDに接続したピンの番号
const int remoteLedPin = 13;

// StonesThrow
StonesThrow stonesThrow;

void setup() {
  // 自分のIDと相手のIDでStonesThrowを初期化する
  stonesThrow.begin(myID, pairWithID);
}

void loop(){
  // 相手側でLEDに接続したピンをHIGHにセットして1000ms待つ
  stonesThrow.remoteDigitalWrite(remoteLedPin, HIGH);
  delay(1000);

  // 相手側でLEDに接続したピンをLOWにセットして1000ms待つ
  stonesThrow.remoteDigitalWrite(remoteLedPin, LOW);
  delay(1000);
}

