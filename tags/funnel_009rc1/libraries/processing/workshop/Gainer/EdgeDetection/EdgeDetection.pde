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
  gainer.digitalInput(0).filters = filters;
}

void draw() {
  background(brightness);  
}

// the event handler to handle changes from zero to non-zero
// ゼロからそれ以外への変化を受けるイベントハンドラ
void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    brightness = 255;
  }
}

// the event handler to handle changes from non-zero to zero
// ゼロ以外からゼロへの変化を受けるイベントハンドラ
void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    brightness = 0;
  }
}

