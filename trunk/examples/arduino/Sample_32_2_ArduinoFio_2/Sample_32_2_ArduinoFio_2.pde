#include <StonesThrow.h>

// 自分のIDと相手のID
const int myID = 2;
const int pairWithID = 1;

// StonesThrow
StonesThrow stonesThrow;

void setup(){
  // 自分のIDと相手のIDでStonesThrowを初期化する
  stonesThrow.begin(myID, pairWithID);
}

void loop(){
  // 状態を更新する
  // 相手側からメッセージを受け取っていたらここで反映される
  stonesThrow.update();

  // 次のループ開始までに10ms待つ
  delay(10);
}

