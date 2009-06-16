package funnel {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * 入力の状態を表示するためのスコープクラス
	 * A signal scope class to show changes of inputs.
	 */
	public class SignalScope extends Sprite {
		private var _values:Array;
		private var _descriptionLabel:TextField;
		private var _currentValueText:TextField;
		private var _maximumValueText:TextField;
		private var _minimumValueText:TextField;
		private var _averageValueText:TextField;
		private const CUR_VAL_COLOR:uint = 0xFFFFFF;
		private const MAX_VAL_COLOR:uint = 0xFF5A00;
		private const MIN_VAL_COLOR:uint = 0x00D42D;
		private const AVG_VAL_COLOR:uint = 0xFFE000;
		private var _range:Number = 100;
		private var _rangeMax:Number = 1;

		public function SignalScope(left:Number, top:Number, points:int, description:String = "", rangeMin:Number = 0, rangeMax:Number = 1) {
			super();
			this.x = left;
			this.y = top;
			_values = new Array(points);
			for (var i:int = 0; i < _values.length; i++) {
				_values[i] = 0.0;
			}

			var format:TextFormat = new TextFormat();
			format.font = "Monaco";
			format.size = 12;

			_currentValueText = new TextField();
			_maximumValueText = new TextField();
			_minimumValueText = new TextField();
			_averageValueText = new TextField();
			_descriptionLabel = new TextField();
			format.color = CUR_VAL_COLOR;
			_currentValueText.defaultTextFormat = format;
			_currentValueText.width = 102;
			format.color = MAX_VAL_COLOR;
			_maximumValueText.defaultTextFormat = format;
			_maximumValueText.width = 102;
			format.color = MIN_VAL_COLOR;
			_minimumValueText.defaultTextFormat = format;
			_minimumValueText.width = 102;
			format.color = AVG_VAL_COLOR;
			_averageValueText.defaultTextFormat = format;
			_averageValueText.width = 102;
			format.color = CUR_VAL_COLOR;
			_descriptionLabel.defaultTextFormat = format;
			_descriptionLabel.autoSize = TextFieldAutoSize.LEFT;
			_currentValueText.text = "current: 0.0";
			_maximumValueText.text = "maximum: 0.0";
			_minimumValueText.text = "minimum: 0.0";
			_averageValueText.text = "average: 0.0";
			_descriptionLabel.text = description;
			_currentValueText.x = x + 210;
			_currentValueText.y = y + 32 - 4;
			_maximumValueText.x = x + 210;
			_maximumValueText.y = y + 48 - 4;
			_minimumValueText.x = x + 210;
			_minimumValueText.y = y + 64 - 4;
			_averageValueText.x = x + 210;
			_averageValueText.y = y + 80 - 4;
			_descriptionLabel.x = x + 210;
			_descriptionLabel.y = y + 0 - 4;
			addChild(_currentValueText);
			addChild(_maximumValueText);
			addChild(_minimumValueText);
			addChild(_averageValueText);
			addChild(_descriptionLabel);

			_range = 1 / (rangeMax - rangeMin) * 100;
			_rangeMax = rangeMax;
		}

		public function update(input:*):void {
			this.graphics.clear();
			this.graphics.beginFill(0x000000, 0.5);
			this.graphics.drawRect(x - 2, y - 2, _values.length + 4, 100 + 4);
			this.graphics.endFill();
			this.graphics.lineStyle(0.25, CUR_VAL_COLOR);
			this.graphics.drawRect(x - 2, y - 2, _values.length + 4, 100 + 4);
			this.graphics.lineStyle(0.5, CUR_VAL_COLOR);
			this.graphics.moveTo(x, y + 100);

			var offset:Number = 0;
			var i:int = 0;

			if (input is Pin) {
				_values.push(input.value);
				_values.shift();

				for (i = 0; i < _values.length; i++) {
					offset = (_rangeMax - _values[i]) * _range;
					this.graphics.lineTo(x + i, y + offset);
				}

				offset = (_rangeMax - input.maximum) * _range;
				this.graphics.lineStyle(0.25, MAX_VAL_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				offset = (_rangeMax - input.minimum) * _range;
				this.graphics.lineStyle(0.25, MIN_VAL_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				offset = (_rangeMax - input.average) * _range;
				this.graphics.lineStyle(0.25, AVG_VAL_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				_currentValueText.text = "current: " + input.value;
				_maximumValueText.text = "maximum: " + input.maximum;
				_minimumValueText.text = "minimum: " + input.minimum;
				_averageValueText.text = "average: " + input.average;
			} else if (input is Number) {
				_values.push(input);
				_values.shift();

				for (i = 0; i < _values.length; i++) {
					offset = (_rangeMax - _values[i]) * _range;
					this.graphics.lineTo(x + i, y + offset);
				}

				_currentValueText.text = "current: " + input;
			}
		}
	}
}