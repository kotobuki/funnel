package funnel.gui {

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class OnScreenController extends Sprite {

		public static const ANALOG:uint = 0;

		public static const DIGITAL_MOMENTARY:uint = 1;

		public static const DIGITAL_TOGGLE:uint = 2;

		public static const HEIGHT:uint = 14;

		private static const BAR_COLOR:uint = 0x808080;

		private static const BASE_COLOR:uint = 0x404040;

		private static const HIGHLIGHT_COLOR:uint = 0xE0E0E0;

		private static const KNOB_COLOR:uint = 0xFFE000;

		private static const LABEL_WIDTH:uint = 40;

		private static const MINIMUM_WIDTH:uint = LABEL_WIDTH + SLIDER_MODE_KNOB_WIDTH;

		private static const SLIDER_MODE_KNOB_WIDTH:uint = 16;

		private var _barHeight:int;

		private var _barLeft:int;

		private var _barWidth:int;

		private var _base:Shape;

		private var _dragOffset:Number;

		private var _knob:Sprite;

		private var _knobMarker:Sprite;

		private var _knobWidth:int;

		private var _label:TextField;

		private var _type:uint;

		private var _value:Number;

		private var _width:int;

		private var _min:Number;

		private var _max:Number;

		public function OnScreenController(label:String, width:int = 128, type:uint = ANALOG, isInput:Boolean = true, min:Number = 0, max:Number = 1) {
			super();
			_width = (width < MINIMUM_WIDTH) ? MINIMUM_WIDTH : width;
			_type = type;
			_min = min;
			_max = max;
			_barHeight = HEIGHT - 2 - 2;

			_base = new Shape();
			_base.graphics.beginFill(BASE_COLOR);
			_base.graphics.drawRoundRect(0, 0, _width, HEIGHT, 4, 4);
			_base.graphics.endFill();
			_base.graphics.beginFill(BAR_COLOR);
			_base.graphics.drawRoundRect(LABEL_WIDTH, 2, _width - LABEL_WIDTH - 2, _barHeight, 2, 2);
			_base.graphics.endFill();
			addChild(_base);

			_knobWidth = (type == ANALOG) ? SLIDER_MODE_KNOB_WIDTH : (_width - LABEL_WIDTH - 2);
			_barLeft = LABEL_WIDTH + _knobWidth / 2;
			_barWidth = _width - LABEL_WIDTH - _knobWidth - 2;

			_knob = new Sprite();
			_knob.graphics.beginFill(KNOB_COLOR);
			_knob.graphics.drawRoundRect(-_knobWidth / 2, -_barHeight / 2, _knobWidth, _barHeight, 2, 2);
			_knob.graphics.endFill();
			_knob.x = _barLeft;
			_knob.y = 2 + (_barHeight / 2);
			_knob.buttonMode = isInput;
			addChild(_knob);

			// TODO: refine graphical design
			if (isInput) {
				_knobMarker = new Sprite();
				_knobMarker.graphics.lineStyle(1, HIGHLIGHT_COLOR);
				_knobMarker.graphics.moveTo(-3, -_barHeight * 0.3);
				_knobMarker.graphics.lineTo(-3, _barHeight * 0.3);
				_knobMarker.graphics.moveTo(0, -_barHeight * 0.3);
				_knobMarker.graphics.lineTo(0, _barHeight * 0.3);
				_knobMarker.graphics.moveTo(3, -_barHeight * 0.3);
				_knobMarker.graphics.lineTo(3, _barHeight * 0.3);
				_knob.addChild(_knobMarker);
			}

			_label = new TextField();
			_label.width = LABEL_WIDTH - 2;
			_label.height = HEIGHT;
			_label.x = 1;
			_label.y = -0.5;
			_label.autoSize = TextFieldAutoSize.NONE;
			_label.defaultTextFormat = new TextFormat('Verdana', 8, 0xE0E0E0, null, null, null, null, null, TextFormatAlign.LEFT);
			_label.text = label;
			addChild(_label);

			if (!isInput) {
				return;
			}

			if (type == ANALOG) {
				_knob.addEventListener(MouseEvent.MOUSE_DOWN, sliderModeMouseDownHandler);
			} else {
				_knob.addEventListener(MouseEvent.MOUSE_DOWN, buttonModeMouseDownHandler);
				_knob.addEventListener(MouseEvent.MOUSE_UP, buttonModeMouseUpHandler);
			}
		}

		public function get value():Number {
			return scale(_value, 0, 1, _min, _max);
		}

		public function set value(newValue:Number):void {
			_value = scale(newValue, _min, _max);
			_value = Math.max(0, Math.min(1, _value));

			if (_type == ANALOG) {
				_knob.x = _barLeft + _barWidth * _value;
			} else {
				_value = (_value < 0.5) ? 0 : 1;
				_knob.alpha = (_value == 0) ? 0.2 : 1;
			}

			dispatchEvent(new Event(Event.CHANGE));
		}

		private function buttonModeMouseDownHandler(e:MouseEvent):void {
			if (_type == DIGITAL_MOMENTARY) {
				this.value = 1;
			} else if (_type == DIGITAL_TOGGLE) {
				this.value = (_value == 0) ? 1 : 0;
			}
		}

		private function buttonModeMouseUpHandler(e:MouseEvent):void {
			if (_type == DIGITAL_MOMENTARY) {
				this.value = 0;
			}
		}

		private function sliderModeMouseDownHandler(e:MouseEvent):void {
			_dragOffset = _knob.mouseX;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, true);
			stageMouseMoveHandler(null);
			e.stopPropagation();
		}

		private function stageMouseMoveHandler(e:MouseEvent):void {
			var val:Number = (mouseX - _dragOffset - _barLeft) / _barWidth;
			this.value = val;
		}

		private function stageMouseUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, true);
			e.stopPropagation();
		}

		private function scale(input:Number, inMin:Number, inMax:Number, outMin:Number = 0, outMax:Number = 1):Number {
			var inRange:Number = inMax - inMin;
			var outRange:Number = outMax - outMin;
			return ((input - inMin) / inRange) * outRange + outMin;
		}

	}
}