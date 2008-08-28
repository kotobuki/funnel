/*
 * A simple pong client, modify to use physical controllers.
 * シンプルなポンのクライアント。変更を加えてフィジカルなコントローラを使用できるようにする。
 */

import processing.net.*;

Client c;

void setup() 
{
  size(450, 255);
  background(204);
  stroke(0);

  // replace the host name and port number if needed
  // ホスト名とポート名を必要に応じて書き換える
  c = new Client(this, "127.0.0.1", 5432);
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
  }
}

// send the new relative position of the paddle
// パドルの新しい相対位置を送信
void keyPressed()
{
  switch (keyCode) {
  case LEFT:
    // send "l" to move the paddle left
    // パドルを左に動かすには"l"を送信する
    c.write("l\r\n");
    break;
  case RIGHT:
    // send "r" to move the paddle left
    // パドルを右に動かすには"l"を送信する
    c.write("r\r\n");
    break;
  default:
    break;
  }
}

/*
// send the new absolute position of the paddle
// パドルの新しい絶対位置を送信
void mouseMoved()
{
  float position = (float)mouseX / (float)(width - 1);
  c.write(str(position) + "\r\n");
}
*/

void stop()
{
  // send "x" to disconnect from the server
  // サーバとの接続を切るには"x"を送信する（※Escキーで終了しない場合にはこのメソッドは呼ばれません）
  c.write("x\r");
}

