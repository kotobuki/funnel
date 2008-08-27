/*
 * A simple pong client, modify to use physical controllers.
 * シンプルなポンのクライアント。変更を加えてフィジカルなコントローラを使用できるようにする。
 */

import processing.net.*;

Client c;

final int IDLE = 0;
final int CONNECTED = 1;

int state = IDLE;

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
  switch (state) {
  case IDLE:
    background(10);
    break;
  case CONNECTED:
    background(250);
    break;
  default:
    break;
  }
}

void clientEvent(Client someClient) {
  String reply = someClient.readString();
  if (reply == null) {
    return;
  }

  print("server says: " + reply);
  if (reply.equals("hi\r\n")) {
    println("connected");
    state = CONNECTED;
  } 
  else if (reply.equals("bye\r\n")) {
    println("disconnected");
    state = IDLE;
  }
  else if (reply.equals("win\r\n")) {
    println("You win!");
  }
  else if (reply.equals("hit\r\n")) {
    println("Hit!");
  }
  else if (reply.equals("lose\r\n")) {
    println("You lose...");
  }
}

void keyPressed()
{
  switch (keyCode) {
  case LEFT:
    // send "l" to move the paddle left
    // パドルを左に動かすには"l"を送信する
    c.write("l");
    break;
  case RIGHT:
    // send "r" to move the paddle left
    // パドルを右に動かすには"l"を送信する
    c.write("r");
    break;
  default:
    break;
  }
}

void stop()
{
  // send "x" to disconnect from the server
  // サーバとの接続を切るには"x"を送信する
//  c.write("x");
//  delay(100);
}
