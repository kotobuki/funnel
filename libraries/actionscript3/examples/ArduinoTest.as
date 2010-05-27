﻿package {    import flash.display.Sprite;    import funnel.*;    import funnel.gui.*;    import funnel.ui.*;    /**     * D13に接続したLEDを矩形波で点滅させる     * Drive a LED connected to the D13 pin with a square wave     */    public class ArduinoTest extends Sprite {        // Arduino        private var arduino:Arduino;        // LED        private var led:LED;        public function ArduinoTest() {            // LEDに接続したピンのモードを出力にセット            var config:Configuration = Arduino.FIRMATA;            config.setDigitalPinMode(13, OUT);            arduino = new Arduino(config);            // Arduinoボードの準備ができた時に発生するイベントのイベントリスナをセット            arduino.addEventListener(FunnelEvent.READY, onReady);            // 動作確認用のGUIを生成してセット            var gui:ArduinoGUI = new ArduinoGUI();            addChild(gui);            arduino.gui = gui;            // LEDのインスタンスを生成            led = new LED(arduino.digitalPin(13));        }        // Arduinoボードの準備ができたら        private function onReady(e:FunnelEvent):void {            // LEDを周波数1000Hzで点滅させる            led.blink(1000, 0, Osc.SQUARE);        }    }}