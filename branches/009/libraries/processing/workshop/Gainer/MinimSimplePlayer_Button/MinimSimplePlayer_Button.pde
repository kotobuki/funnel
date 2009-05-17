import ddf.minim.*;
import processing.funnel.*;

AudioPlayer player;
Gainer gainer;

void setup()
{
  size(512, 200);

  // always start Minim first
  // 常にMinimを最初にスタートする
  Minim.start(this);

  // load a file, give the AudioPlayer buffers that are 512 samples long
  // ファイルをロードし、AudioPlayerのバッファサイズを512サンプルにセット
  player = Minim.loadFile("marcus_kellis_theme.mp3", 512);

  gainer = new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;
}

void draw()
{
  background(0);
}

void gainerButtonEvent(boolean pressed)
{
  if (pressed) {
    // ファイルの再生を開始する
    // play the file
    player.play();
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  // スケッチの終了時には常にMinimオブジェクトをcloseする
  player.close();
  super.stop();
}

