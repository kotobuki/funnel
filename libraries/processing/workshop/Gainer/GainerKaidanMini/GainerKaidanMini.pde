/**
 * Gainer Kaidan Mini
 * 
 * by Shigeru Kobayashi for "Make: Tokyo Meeting"
 * inputs: photocells
 * outputs: solenoids via SSR modules
 */

import processing.funnel.*;

Gainer gio;
Delay[] delayLine;
boolean[] interrupted;

void setup()
{
  // Set the frame rate high to control in draw()
  // 出力のコントロールをdraw()内で行う関係でフレームレートを高めに設定する
  frameRate(50);

  // Use mode 4: 8 analog inputs and 8 analog outputs
  // アナログ入力8個、アナログ出力8個を利用できるモード4を使用する
  gio = new Gainer(this, Gainer.MODE4);

  // A worksround to enable delay() in setup()
  // Processingの仕様でsetup()中ではdelay()が使えないのに対する回避策
  frameCount = 1;

  // Wait for a while to measure baseline levels
  // 一定時間待ってその間の各入力ポートの値をベースラインとして用いる
  println("waiting...");
  delay(1000);
  println("done!");

  // Instantiate 8 pairs of a flag and a Delay
  // ステップを踏まれたかどうかのフラグとディレイのインスタンスを生成
  interrupted = new boolean[8];
  delayLine = new Delay[8];

  for (int i = 0; i < 8; i++) {
    // Read an average value of the input port
    // 各ポートの平均値を読み取る
    println("avg[" + i + "]: " + gio.analogInput(i).average);

    // Set a threshold according to the average value,
    // then set a SetPoint filter to the input port
    // それを元にしきい値を設定してフィルタとして各ポートにセットする
    Filter[] f = {
      new SetPoint(gio.analogInput(i).average - 0.1, 0.05)
    };
    gio.analogInput(i).filters = f;

    // Initialize flags and Delay objects
    // フラグとディレイを初期化
    interrupted[i] = false;
    delayLine[i] = new Delay(25);
  }
}

void draw()
{
  for (int i = 0; i < 8; i++) {
    // Read from the delay line
    // ディレイから値を取り出す
    gio.analogOutput(i).value = delayLine[i].getOutput();

    if (interrupted[i]) {
      // If the step is stepped, put 1 to the delay line
      // もしステップを踏まれていたらディレイに1を入力する
      delayLine[i].setInput(1);

      // Overwrite the output port with 1
      // 出力する値を1で上書きする
      gio.analogOutput(i).value = 1.0;
      
      // Clear the flag
      // ステップを踏まれたことを示すフラグをクリアする
      interrupted[i] = false;
    } else {
      // If the step is not stepped, put 0 to the delay line
      // もしステップを踏まれていなければディレイに0を入力する
      delayLine[i].setInput(0);
    }
  }

  // Update all output ports at once
  // すべてのポートの状態をまとめて出力する
  gio.update();  
}

// The event handler to handle falling edge (from non zero to 0) events
// 1→0に変化したときに呼ばれるイベントハンドラ
void fallingEdge(PortEvent e)
{
  switch (e.target.number) {
  case 0:
  case 1:
  case 2:
  case 3:
  case 4:
  case 5:
  case 6:
  case 7:
    // Set the according flag to true
    // 対応するフラグをセットする
    interrupted[e.target.number] = true;
    break;

  default:
    break;
  }
}

