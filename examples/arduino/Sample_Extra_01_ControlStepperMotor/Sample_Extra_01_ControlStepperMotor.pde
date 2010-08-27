#include <Stepper.h>

// 使用するモータのステップ数
const int steps = 100;

// ステッピングモータを表すオブジェクト
// 引数はステップ数とモータに接続されたピンの番号（4個）
Stepper stepper(steps, 8, 9, 10, 11);

void setup() {
  // モータの回転速度を30回転/分にセット
  stepper.setSpeed(30);
}

void loop() {
  // モータを1ステップ動かす
  stepper.step(1);
}

