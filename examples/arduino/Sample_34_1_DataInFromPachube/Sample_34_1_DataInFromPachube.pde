#include <Ethernet.h>
#include <EthernetDHCP.h>

// Pachubeの環境ID
const int environmentId = 504;

// 自分のAPIキー
const char *apiKey = "YOUR_API_KEY";

// フィードの間隔（この場合は5000ms）
const unsigned long INTERVAL = 4999;

// LEDに接続したピンの番号
const int ledPin = 9;

// MACアドレス（Ethernetシールド底面のシールに記載）
byte macAddress[] = { 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB };

// PachubeのIPアドレス
byte serverIpAddress[] = { 173, 203, 98, 29 };

// 次にフィードを更新する時刻
unsigned long nextExecuteMillis;

// サーバから受け取ったデータを収める配列
char buffer[64];

// バッファに書き込む際のインデックス
int index;

// すでに受け取ったデータを示すフラグ
boolean foundStatus200 = false;
boolean foundBlankLine = false;

// データ本体のサイズを表す変数
int contentLength = 0;

// クライアント
Client client(serverIpAddress, 80);

void setup() {
  // LEDを接続したピンのモードを出力に
  pinMode(ledPin, OUTPUT);

  // シリアルモニタで動作確認するためのシリアル通信を動作開始
  Serial.begin(9600);

  // DHCPでIPアドレスを取得
  Serial.println("Getting an IP address...");
  EthernetDHCP.begin(macAddress);

  // 確認用に取得したIPアドレスをシリアルにプリント
  const byte* ipAddr = EthernetDHCP.ipAddress();
  Serial.print("IP address: ");
  Serial.print(ipAddr[0], DEC);
  Serial.print(".");
  Serial.print(ipAddr[1], DEC);
  Serial.print(".");
  Serial.print(ipAddr[2], DEC);
  Serial.print(".");
  Serial.print(ipAddr[3], DEC);
  Serial.println();

  // 接続を試みる
  Serial.println("Connecting...");
  if (client.connect()) {
    // 接続に成功したらシリアルにレポート
    Serial.println("Connected");
  }
  else {
    // 接続に失敗したらシリアルにレポート
    Serial.println("Connection failed");
    while(true);
  }
}

void loop() {
  // サーバから受け取ったデータがあれば処理
  while (client.available()) {
    processReply();
  }

  // フィードを更新すべき時刻になっているかどうか判断
  unsigned long currentMillis = millis();
  if (currentMillis > nextExecuteMillis) {
    // 更新すべき時刻であれば次回更新する時刻をセット
    nextExecuteMillis = currentMillis + INTERVAL;

    // フィードのデータを要求
    Serial.println("Requesting...");
    foundStatus200 = false;
    foundBlankLine = false;
    contentLength = 0;
    index = 0;
    sendRequest();
  }
}

// フィードのデータを要求
void sendRequest() {
  client.print("GET /api/feeds/");
  client.print(environmentId);
  client.println(".csv HTTP/1.1");
  client.println("Host: www.pachube.com");
  client.print("X-PachubeApiKey: ");
  client.println(apiKey);
  client.println();
}

// サーバからのリプライを処理する
void processReply() {
  // ネットワークから受信したバイトを読み取って確認用にシリアルにプリント
  char incomingByte = client.read();
  Serial.print(incomingByte);

  // 読み取ったバイトを順次バッファに書き込む
  buffer[index] = incomingByte;
  if (index < 64) {
    index++;
  }

  // まだ空行を受け取っておらず、受信したバイトが改行であれば
  if (!foundBlankLine && incomingByte == '\n') {
    // まだステータス200を受け取っていなければ
    if (!foundStatus200) {
      // 受け取った行の中に「200 OK」があればフラグをtrueにセット
      if (strstr(buffer, "200 OK") != NULL) {
        foundStatus200 = true;
      }
    }
    // すでにステータス200を受取っていれば
    else {
      // 受け取った行の中に「Content-Length:」があれば
      if (strstr(buffer, "Content-Length:") != NULL) {
        // データ本体のバイト数を読み取って変数contentLengthにセット
        char *contentLengthStr = strstr(buffer, " ");
        contentLength = atoi(contentLengthStr);
      }
      // 受け取った行が空行であれば
      else if (!foundBlankLine && strlen(buffer) == 2) {
        // 空行を受け取ったことを示すフラグをセット
        foundBlankLine = true;
      }
    }

    // 受信用のバッファをリセット
    index = 0;
    memset(buffer, 0, sizeof(buffer));
  }
  // 既に空行を受け取っていたら（＝データ本体を処理中であれば）
  else if (foundBlankLine) {
    // データ本体の予定したバイト数を受け取っていたら
    if (index == contentLength) {
      // バッファの中身を「,」を区切り文字として分割
      char delimiter[] = ",";
      char *result = NULL;
      char *ptr;
      result = strtok_r(buffer, delimiter, &ptr);
      int counter = 0;
      while (result != NULL) {
        // CSVデータから目的とするデータ（この場合は明るさ）を取り出す
        if (counter == 1) {
          // 取り出した値でLEDの輝度を更新
          int value = round(atof(result));
          analogWrite(ledPin, value);
          Serial.print("\nvalue: ");
          Serial.println(value);
        }
        counter++;
        result = strtok_r(NULL, delimiter, &ptr);
      }
    }
  }
}

