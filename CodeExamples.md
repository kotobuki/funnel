# Example 1: Detect changes of an analog input #

## Issue ##
I'd like to call a handler when an analog input value goes less that a threshold.

## Gainer ##
```
var io:Gainer = new Gainer(...);
var lastStatus:Number = -1;	// -1: unknown, 0: low, 1:high
var threshold = 80;
var hysteresis = 20;

loop() {
	if (io.analogInput[0] < (threshold - hysteresis)) {
		status = 0;
	} else if (io.analogInput[0] > (threshold + hysteresis)) {
		status = 1;
	} else {
		status = lastStatus;
	}

	if ((lastStatus == 0) && (status == 1)) {
		handler();
	}

	lastStatus = status;
}

function handler():void {
	...
}
```

## Funnel ##
```
var fio:Funnel = new Funnel(...);
var threshold:float = 0.3;
var hysteresis:float = 0.1;

fio.port(0).filters = [new SetPoint(threshold, hysteresis)];
fio.port(0).addEventListener(FALLING_EDGE, handler);

function handler():void {
	...
}
```


# Example 2: Control an digital output with time #

## Issue ##
I'd like to blink a LED at 2Hz

## Gainer ##
```
var io:Gainer = new Gainer(...);
var value:Boolean = false;

var blinkTimer:Timer = new Timer(250, 0); // interval (in ms), times (0 means repeat infinitely)
blinkTimer.addEventListener(TimerEvent.TIMER, blink);
blinkTimer.start();

function blink():void {
	if (value == false) {
		value = true;
	} else {
		value = false;
	}

	io.digitalOutput(0, value);
}
```

## Funnel ##
```
var fio:Funnel = new Funnel(...);
var blinker:Osc = new Osc(Osc.SQUARE, 2, 0); // wave, frequency (in Hz), times (0 means repeat infinitely)

fio.port(0).filters = [blinker];
blinker.start();
```

# Example 3: Control an analog output with time #

## Issue ##
I'd like fade a LED with triangle wave at 0.5Hz

## Gainer ##
```
var io:Gainer = new Gainer(...);
var value:Number = 0;
var i:Number = 0;

var blinkTimer:Timer = new Timer(20, 0); // interval (in ms), times (0 means repeat infinitely)
blinkTimer.addEventListener(TimerEvent.TIMER, dimming);
blinkTimer.start();

function dimming():void {
	i += 1;
	if (i < 255) {
		value += 1;
	} else if (i < 509) {
		value -= 1;
	} else {
		i = 1;
	}

	io.analogOutput(0, value);
}
```

## Funnel ##
```
var fio:Funnel = new Funnel(...);
var dimmer:Osc = new Osc(Wave.TRIANGLE, 0.5, 0); // wave, frequency (in Hz), times (0 means repeat infinitely)

fio.port(0).filters = [dimmer];
dimmer.start();
```

# Example 4: Control an analog output with time #

## Issue ##
I'd like turn on a solenoid only 20ms

## Gainer ##
```
var io:Gainer = new Gainer(...);

function startTrigger():void {
	io.digitalOutput(0, true);
	var tTimer:Timer = new Timer(20, 1); // interval, times
	tTimer.addEventListener(TimerEvent.TIMER, finishTrigger);
	tTimer.start();
}

function finishTrigger():void {
	io.digitalOutput(0, false);
}
```

## Funnel ##
```
var fio:Funnel = new Funnel(...);
var trigger:Osc = new Osc(Osc.IMPULSE, 1000/20, 1); // wave, frequency, times

fio.port(0).filters = [trigger];
trigger.start();
```

