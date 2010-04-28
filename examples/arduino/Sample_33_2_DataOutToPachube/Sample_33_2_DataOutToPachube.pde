#include <Ethernet.h>
#include <EthernetDHCP.h>

// Pachubeの環境ID
const int environmentId = 1234;

// 自分のAPIキー
const char *apiKey = "YOUR_API_KEY";

// フィードの間隔(この場合は5000ms)
const unsigned int samplingInterval = 4999;

// MACアドレス（Ethernetシールド底面のシールに記載）
byte macAddress[] = { 
  0x01, 0x23, 0x45, 0x67, 0x90, 0xAB };

// PachubeのIPアドレス
byte serverIpAddress[] = { 
  209, 40, 205, 190 };

// クライアント
Client client(serverIpAddress, 80);

// 次にフィードを更新する時刻
unsigned long nextExecuteMillis;

void setup() {
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
  Serial.println("Connecting to Pachube...");
  if (client.connect()) {
    // 接続に成功したらシリアルにレポート
    Serial.println("Connected");
  }
  else {
    // 接続に失敗したらシリアルにレポートして以降の動作を停止
    Serial.println("Connection failed");
    while(true);
  }
}

void loop() {
  // DHCPによるIPアドレスのリースを維持
  EthernetDHCP.maintain();

  // サーバから受け取ったデータをPCにもエコー
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // フィードを更新すべき時刻になっているかどうか判断
  unsigned long currentMillis = millis();
  if (currentMillis > nextExecuteMillis) {
    // 更新すべき時刻であれば次回更新する時刻をセット
    nextExecuteMillis = currentMillis + samplingInterval;

    // データストリームを更新
    Serial.println();
    Serial.println("Updating...");
    int value = analogRead(0);
    updateDataStream(1, value);
  }
}

// データストリームの更新処理
void updateDataStream(int datastreamId, int value) {
  // サーバに対して送信するデータを収める配列
  static char pachubeData[10];

  // データを配列pachubeDataにプリント
  sprintf(pachubeData, "%d", value);
  int contentLength = strlen(pachubeData);

  // サーバにアクセスして指定したデータストリームを更新
  client.print("PUT /api/feeds/");
  client.print(environmentId);
  client.print("/datastreams/");
  client.print(datastreamId);
  client.println(".csv HTTP/1.1");
  client.println("User-Agent: Arduino");
  client.println("Host: www.pachube.com");
  client.print("X-PachubeApiKey: ");
  client.println(apiKey);
  client.print("Content-Length: ");
  client.println(contentLength);
  client.println("Content-Type: text/csv");
  client.println();
  client.println(pachubeData);
}

