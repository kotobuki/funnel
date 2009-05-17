/*
 * An example of simple pong client with Funnel and Minim
 * FunnelとMinimを使用するシンプルなPongクライアントのサンプル
 * 
 * Sound: BLASTWAVE FX
 * http://www.soundsnap.com/node/71874
 * http://www.soundsnap.com/user/19113
 * Mouseover musical slide_BLASTWAVEFX_06241.mp3
 */

import processing.net.*;
import ddf.minim.*;
import processing.funnel.*;

Client c;
AudioSample sample;
Gainer gainer;

void setup() 
{
  size(450, 255);

  // always start Minim first
  // 常にMinimを最初にスタートする
  Minim.start(this);

  background(204);
  stroke(0);

  // replace the host name and port number if needed
  // ホスト名とポート名を必要に応じて書き換える
  c = new Client(this, "127.0.0.1", 5432);

  // load a file, give the AudioPlayer buffers that are 512 samples long
  // ファイルをロードし、AudioPlayerのバッファサイズを512サンプルにセット
  sample = Minim.loadSample("BLASTWAVEFX_06241.mp3", 512);

  gainer = new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;
}

void draw() 
{

}

void clientEvent(Client someClient) {
  String reply = someClient.readString();
  if (reply == null) {
    return;
  }
  print("server says: " + reply);

  if (reply.equals("hi\r\n")) {
    println("connected");
  } 
  else if (reply.equals("bye\r\n")) {
    println("disconnected");
  }
  else if (reply.equals("win\r\n")) {
    println("You win!");
  }
  else if (reply.equals("lose\r\n")) {
    println("You lose...");
  }
  else if (reply.equals("hit\r\n")) {
    println("Hit!");

    // trigger the sample
    // サンプルをトリガーする
    sample.trigger();
  }
}

// the event handler to handle changes
// 変化を受けるイベントハンドラ
void change(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    // send the new absolute position of the paddle
    // パドルの新しい絶対位置を送信
    c.write(str(e.target.value) + "\r\n");
  }
}

void stop()
{
  // send "x" to disconnect from the server
  // サーバとの接続を切るには"x"を送信する（※Escキーで終了しない場合にはこのメソッドは呼ばれません）
  c.write("x\r");

  // always close Minim audio classes when you are done with them
  // スケッチの終了時には常にMinimのaudioオブジェクトをcloseする
  sample.close();

  super.stop();
}

