■はじめに
Funnelはフィジカルコンピューティングのためのツールキットです。
Gainer I/Oモジュール、Arduino I/Oボード、XBee無線モデムと
Funnel I/Oモジュールに対応し、それぞれの入出力ポートに対して閾
（しきい）値による分割、LPFやHPFなどのフィルタ処理、スケーリング、
オシレータなどのフィルタをセットすることができます。
詳細や今後のプランに関しては、specifications_ja.pdfを参照して下さい。
なお、これはあくまで現時点での仕様や計画であり、今後大幅に変更
される可能性もあります。

最新の情報に関しては次のウェブサイトを参照してください：
http://funnel.cc

■動作環境
□動作確認を行ったOS
・Windows XP SP2/Vista
・Mac OS X 10.4/10.5

□ライブラリの動作環境
・Flash CS3、Flex Builder 2/3、Flex 2/3 SDKなどActionScript 3で
　プログラミングできる環境
・Processing 0135
・Ruby 1.8.2（1.9では未確認）＋ふなばただよしさんのOSCライブラリ
　http://raa.ruby-lang.org/project/osc/

□Funnel Serverの動作環境
・Javaランタイム実行環境1.4.2以上

□ハードウェア
・Gainer I/Oモジュールv1.0
・Arduino USB/NG/Diecimila＋Firmata v1.0のファームウェア
　Standard_Firmata_334（またはFirmataライブラリを使用したスケッチ）
　http://www.arduino.cc/playground/Interfacing/Firmata

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

■更新履歴
Funnel 007（2008.04.20）
・XBeeに関するサンプルを追加
・XBeeを使用した際Processingライブラリがクラッシュするバグを修正
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
の支援を受けて開発されました（テーマ名：プロトタイピングのためのツール
キット「Funnel」の開発）。

Funnelの開発に関して以下の方々に感謝いたします：
・David A. Mellis（RXTXライブラリのバイナリ）
