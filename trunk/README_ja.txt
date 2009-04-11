■はじめに
Funnelはフィジカルコンピューティングのためのツールキットです。Gainer I/O
モジュール、Arduino I/Oボード、XBee無線モデムとFIO（Funnel I/O）ボードに
対応し、それぞれの入出力ポートに対して閾（しきい）値による分割、LPFやHPF
などのフィルタ処理、スケーリング、オシレータなどのフィルタをセットすること
ができます。

最新の情報に関しては次のウェブサイトを参照してください
http://funnel.cc


■動作環境
□OS
・Windows XP SP2/3またはVista
・Mac OS X 10.4または10.5

□ライブラリの動作環境
・Flash CS3/4、Flex Builder 3、Flex 3 SDKなどActionScript 3で
　プログラミングできる環境
・Processing 1.0
・Ruby 1.8.*（1.9では未確認）＋ふなばただよしさんのOSCライブラリ
　http://raa.ruby-lang.org/project/osc/

□Funnel Serverの動作環境
・Javaランタイム実行環境1.5以上

□ハードウェア
・Gainer I/Oモジュール
・Arduinoまたは互換機＋Firmata v2（http://firmata.org/）
・XBee 802.15.4またはZB ZigBee PRO
・FIO（Funnel I/O）モジュール

□オプションの環境
・Arduino 0015（ArduinoまたはFioを使用する場合）
・action-coding
　http://code.google.com/p/action-coding/

■バグレポートや要望など
バグレポートや要望は、Google CodeのIssuesシステムを利用して下さい。
このシステムのユーザーインタフェースは英語のみですが、日本語で記入して
いただくことも可能です。バグレポートの場合、問題を再現する手順に関しては
できるだけ詳しく記入して下さい。
http://code.google.com/p/funnel/issues/list

その他一般的なディスカッションに関しては、以下のフォーラムを利用して
下さい。なお、スパム防止のため、フォーラムへの投稿には登録が必要です。
・日本語：http://gainer.cc/forum/index.php?board=26.0
・英語：http://gainer.cc/forum/index.php?board=25.0


■クレジット
Funnelはオープンソースプロジェクトです。
Funnel開発チームの構成メンバーは小林茂、遠藤孝則、増田一太郎です。
FunnelはIllposed SoftwareによるJava OSC、Ola Bini氏によるJvYAML、
Keane Jarvi氏によるRXTXを使用しています。
・Java OSC：http://www.illposed.com/software/javaosc.html
・JvYAML：https://jvyaml.dev.java.net/
・RXTX：http://www.rxtx.org/

コントリビュータ
・Jeff Hoefsさん：I2C関連クラスおよびAS3ライブラリの改善
・加藤和良さん：RubyライブラリでのマトリクスLED（Gainer I/Oのモード7）のサポート


■更新履歴
Funnel  009（2009.04.16）
・Nathan Seidle（SparkFun Electronics）の協力によりFIO（Funnel I/O）v1.3をリリース
　http://www.sparkfun.com/commerce/product_info.php?products_id=8957
・FirmataでのI2Cをサポート
　・それぞれのソフトウェアライブラリにI2C関連のクラスを追加
　・ArduinoおよびFIO用にSimpleI2CFirmataとStandardFirmataWithI2Cを追加
・XBee設定用ツールの追加
　・XBeeConfigTerminal：一般的な設定用
　・XBeeConfigTool：無線でスケッチをFIOボードにアップロードする設定用
・Processing：Funnel ServerのText Areaへの組込み
・Ruby：マトリクスLED（Gainer I/Oモード7）のサポートを追加
・さまざまなバグ修正とパフォーマンスの改善

Funnel  008（2008.09.25）
・FIO（Funnel I/O）v1.0を追加
・Funnel Serverが使用するネットワークポートが1つのみに
・各ハードウェア用のサンプルを追加
・XBee ZB ZigBee PROのサポートを追加
・XBee 802.15.4の出力側コントロールを追加
・インストールマニュアルを追加
・さまざまなバグ修正とパフォーマンスの改善

Funnel 007（2008.04.21）
・Processing用ライブラリの改良とバグ修正
　・Make: Tokyo MeetingでのGainerワークショップ用に作成したサンプルを追加
　・XBee用のサンプルを追加
　・XBeeを使用した際Processingライブラリがクラッシュするバグを修正
・Funnel Serverの改良と不具合対応
　・ArduinoおよびXBeeでシリアル通信のボーレートを設定できるようにした
　・RXTXライブラリをPowerPCマシンでも動作するよう入れ替えた

Funnel 006（2007.12.21）
・Processing用ライブラリのバグ修正と改良
　・イベントハンドラchangeで値を取得した時に1つ前の値になるバグを修正
　・イベントハンドラgainerButtonEventを追加
　・led()およびbutton()を追加
　・各ポートの番号を返すプロパティanalogInput[0]などを追加

Funnel 005（2007.12.17）
・ActionScript 3とProcessingライブラリにFunnel I/OモジュールおよびXBeeのサポートを追加

Funnel 004（2007.12.06）
・ソフトウェアライブラリの内部構造を変更
・ソフトウェアライブラリ間で定数やメソッドなどを統一
・RubyライブラリにFunnel I/OモジュールおよびXBeeのサポートを追加
・Funnel I/Oモジュールのハードウェアおよびファームウェアを追加

Funnel 003（2007.11.12）
・Processing用ライブラリのバグを修正（WindowsでのOutOfMemoryエラー）

Funnel 002（2007.11.08）
・Processing用ライブラリのバグを修正（ScalerとConvolution）
・ActionScript 3ライブラリのバグを修正
　http://gainer.cc/forum/index.php?topic=205

Funnel 001（2007.10.31）
・ConfigurationクラスとGainerおよびArduino用のショートカットを追加しま
　した。
・ProcesingライブラリにArduino用のサンプルコードを追加しました。
・AS3ライブラリにGainer.MODE7のユーティリティークラスとサンプルを追加
　しました。
・実験的にXBeeのサポートを追加しました。XBeeモジュールの設定に関しては
　次の設定ファイルを参照してください。
　・sketchbook/configure_xbee_base.py
　・sketchbook/configure_xbee_remote.py
・RubyライブラリにXBee用のサンプルコードを追加しました。
・Funnel ServerのOSCはTCPのみ対応しています（UDPのサポートはありません）。
・パフォーマンスはまだ最適化されていません。

Funnel 000（2007.09.24）
・最初の公開ビルドです。
・対象とするI/OモジュールはGainer I/OモジュールとArduino I/Oボードです。
　ArduinoはFirmata 0.3.1ファームウェアを書き込んだArduino NGとArduino 
　Diecimilaで動作確認を行いました。
・Funnel ServerのOSCはTCPのみ対応しています（UDPのサポートはありません）。
・パフォーマンスはまだ最適化されていません。


■謝辞
FunnelはIPA（情報処理推進機構）未踏ソフトウェア創造事業（2007年第I期）
の支援を受けて開発されました。
テーマ名：プロトタイピングのためのツールキット「Funnel」の開発

Funnelの開発に関して以下の方々に感謝いたします：
・美馬義亮（未踏ソフトウェア創造事業プロジェクトマネージャ）
・David A. Mellis（RXTXライブラリのバイナリ）