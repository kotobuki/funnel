import processing.funnel.*;

Gainer gainer;

int brightness = 0;

void setup()
{
  size(200, 200);

  gainer = new Gainer(this, Gainer.MODE1);

  // set a SetPoint filter to din 0 (threshold is 0.5, hysteresis is 0.1)
  // din 0にSetPointフィルタをセット（閾値が0.5でヒステリシス0.1）
  Filter filters[] = {
    new SetPoint(0.5, 0.1)
  };
  // comment-in the following line to set the filter
  // 次の行をコメントインするとフィルタがセットされる
//  gainer.analogInput(0).filters = filters;
}

void draw() {
  background(brightness);  
}

// the event handler to handle changes
// 変化を受けるイベントハンドラ
void change(PinEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    brightness = int(e.target.value * 255);
  }
}

