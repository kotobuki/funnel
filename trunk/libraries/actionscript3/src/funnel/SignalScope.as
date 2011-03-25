package funnel {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * A signal scope class to show changes of inputs. Create an instance of this class 
	 * and add it to the stage to view the input signal.
	 * 
	 * <p>入力の状態を表示するためのスコープクラス</p>
	 */
	public class SignalScope extends Sprite {
		private var _values:Array;
		private var _preFilterValues:Array;
		private var _descriptionLabel:TextField;
		private var _currentValueText:TextField;
		private var _maximumValueText:TextField;
		private var _minimumValueText:TextField;
		private var _averageValueText:TextField;
		private const CURRENT_VALUE_COLOR:uint = 0xFFFFFF;
		private const MAXIMUM_VALUE_COLOR:uint = 0xFF5A00;
		private const MINIMUM_VALUE_COLOR:uint = 0x00D42D;
		private const AVERAGE_VALUE_COLOR:uint = 0xFFE000;
		private const PRE_FILTER_VALUE_COLOR:uint = 0x808080;
		private var _range:Number = 100;
		private var _rangeMax:Number = 1;

		public function SignalScope(left:Number, top:Number, points:int, description:String = "", rangeMin:Number = 0, rangeMax:Number = 1) {
			super();
			this.x = left;
			this.y = top;

			var i:int = 0;

			_values = new Array(points);
			for (i = 0; i < _values.length; i++) {
				_values[i] = 0.0;
			}

			_preFilterValues = new Array(points);
			for (i = 0; i < _preFilterValues.length; i++) {
				_preFilterValues[i] = 0.0;
			}

			var format:TextFormat = new TextFormat();
			format.font = "Monaco";
			format.size = 12;

			_currentValueText = new TextField();
			_maximumValueText = new TextField();
			_minimumValueText = new TextField();
			_averageValueText = new TextField();
			_descriptionLabel = new TextField();
			format.color = CURRENT_VALUE_COLOR;
			_currentValueText.defaultTextFormat = format;
			_currentValueText.autoSize = TextFieldAutoSize.LEFT;
			format.color = MAXIMUM_VALUE_COLOR;
			_maximumValueText.defaultTextFormat = format;
			_maximumValueText.autoSize = TextFieldAutoSize.LEFT;
			format.color = MINIMUM_VALUE_COLOR;
			_minimumValueText.defaultTextFormat = format;
			_minimumValueText.autoSize = TextFieldAutoSize.LEFT;
			format.color = AVERAGE_VALUE_COLOR;
			_averageValueText.defaultTextFormat = format;
			_averageValueText.autoSize = TextFieldAutoSize.LEFT;
			format.color = CURRENT_VALUE_COLOR;
			_descriptionLabel.defaultTextFormat = format;
			_descriptionLabel.autoSize = TextFieldAutoSize.LEFT;
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

		/**
		 * update the graph with the input value
		 * 
		 * @param input the input value to be plotted by the signal scope
		 */
		public function update(input:*):void {
			this.graphics.clear();
			this.graphics.beginFill(0x000000, 0.5);
			this.graphics.drawRect(x - 2, y - 2, _values.length + 4, 100 + 4);
			this.graphics.endFill();
			this.graphics.lineStyle(0.25, CURRENT_VALUE_COLOR);
			this.graphics.drawRect(x - 2, y - 2, _values.length + 4, 100 + 4);

			var offset:Number = 0;
			var i:int = 0;

			if (input is Pin) {
				_values.push(input.value);
				_values.shift();
				_preFilterValues.push(input.preFilterValue);
				_preFilterValues.shift();

				this.graphics.lineStyle(0.5, PRE_FILTER_VALUE_COLOR);
				this.graphics.moveTo(x, y + 100);
				for (i = 0; i < _preFilterValues.length; i++) {
					offset = (_rangeMax - _preFilterValues[i]) * _range;
					this.graphics.lineTo(x + i, y + offset);
				}

				this.graphics.lineStyle(0.5, CURRENT_VALUE_COLOR);
				this.graphics.moveTo(x, y + 100);
				for (i = 0; i < _values.length; i++) {
					offset = (_rangeMax - _values[i]) * _range;
					this.graphics.lineTo(x + i, y + offset);
				}

				offset = (_rangeMax - input.maximum) * _range;
				this.graphics.lineStyle(0.25, MAXIMUM_VALUE_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				offset = (_rangeMax - input.minimum) * _range;
				this.graphics.lineStyle(0.25, MINIMUM_VALUE_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				offset = (_rangeMax - input.average) * _range;
				this.graphics.lineStyle(0.25, AVERAGE_VALUE_COLOR);
				this.graphics.moveTo(x, y + offset);
				this.graphics.lineTo(x + _values.length, y + offset);

				_currentValueText.text = "current: " + input.value.toFixed(3);
				_maximumValueText.text = "maximum: " + input.maximum.toFixed(3);
				_minimumValueText.text = "minimum: " + input.minimum.toFixed(3);
				_averageValueText.text = "average: " + input.average.toFixed(3);
			} else if (input is Number) {
				_values.push(input);
				_values.shift();

				this.graphics.lineStyle(0.5, CURRENT_VALUE_COLOR);
				this.graphics.moveTo(x, y + 100);
				for (i = 0; i < _values.length; i++) {
					offset = (_rangeMax - _values[i]) * _range;
					this.graphics.lineTo(x + i, y + offset);
				}

				_currentValueText.text = "current: " + input.toFixed(3);
			}
		}
	}
}