# Funnel API Specifications #

## Funnel ##
Funnel is the class to represent an I/O module.

### Constructor ###
`Funnel(hostname:String, portNumber:int, config:Array, samplingInterval:int)`

### Instance variables ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `autoUpdate` | boolean    | update output ports automatically |
| `samplingInterval` | int        | current sampling interval |
| `samplingInterval =` | int        | set new sampling interval |
| `portCount` | int        | the number of ports |

### Instance methods ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `port(number:int)` | Port       | specified port  |
| `update()` | void       | update outputs manually |

### Event handlers (Processing only) ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `risingEdge(PortEvent event)` | void       | the handler for PortEvent.RISING\_EDGE |
| `rfallingEdge(PortEvent event)` | void       | the handler for PortEvent.FALLING\_EDGE |
| `change(PortEvent event)` | void       | the handler for PortEvent.CHANGE |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `AIN`    | analog inputs   |
| `DIN`    | digital inputs  |
| `AOUT`   | analog outputs (PWM) |
| `DOUT`   | digital outputs |


## Configuration ##
Configuration is the class to express a configuration for an I/O module.

### Constructor ###
`Configuration(model:int)`
`Configuration(model:int, mode:int)`

### Instance methods ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `setDigitalPinMode(pin:int, mode:int)` | void       | set digital pin mode for a pin (for Arduino) |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `GAINER` | a Gainer I/O module |
| `ARDUINO` | an Arduino I/O board with Firmata firmware |
| `XBEE`   | a XBee wireless modem |
| `FUNNEL` | a Funnel I/O module |
| `IN`     | digital input (for Arduino) |
| `OUT`    | digital output (for Arduino) |
| `PWM`    | PWM (for Arduino) |

## Port ##
Port is the class to represent each port of an I/O module.

### Instance variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `number` | int      | the number of the port |
| `type`   | int      | type of the port (`AIN`, `DIN`, `AOUT` or `DOUT`) |
| `value`  | float    | current value of the port |
| `value =` | float    | set value of the port |
| `lastValue` | float    | the value before a change |
| `average` | float    | average value of the port |
| `minimum` | float    | minimum value of the port |
| `maximum` | float    | maximum value of the port |
| `filters` | Array    | current filters |
| `filters =` | Array    | set filters     |

### Instance methods ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `clear()` | void       | reset history (average, min and max) |
| `addEventListener(e:Event, f:function)` | void       | add an event listenert |


## Event ##
Event is the abstract class for all types of events.

### Instance variables ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `text`   | String     | message         |


## PortEvent _< Event_ ##
PortEvent is the class for port specific events.

### Constructor ###
`PortEvent(type:int, text:String, port:Port)`

### Instance variables ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `target` | Port       | an instance of Port for the event |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `RISING_EDGE` | the value of the port changed from 0 to non-zero |
| `FALLING_EDGE` | the value of the port changed from non-zero to 0 |
| `CHANGE` | the value of the port changed |

## ErrorEvent _< Event_ ##
ErrorEvent is the class for error specific events.

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `SERVER_NOT_FOUND_ERROR` | Counldn't find a proper server |
| `REBOOT_ERROR` | Faild to reboot the I/O module |
| `CONFIGURATION_ERROR` | Failed to configure |


## Filter ##
Filter is the base class to be set to a port to process inputs or generate something. All filter classes should implement the following interface:
```
interface Filter {
	public function processSample(in:Number, buffer:Array):Number;
}
```


## Convolution _< Filter_ ##
Convolution is a very simple convolution filter.

### Constructor ###
`Convolution(coef:Array)`

### Instance variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `coef`   | Array    | current coefficients of the filter |
| `coef =` | Array    | set coefficients of the filter |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `LPF`    | low pass filter |
| `HPF`    | high pass filter |
| `MOVING_AVERAGE` | moving average filter (8 times) |


## Scaler _< Filter_ ##
Scaler is a filter to scale inputs in specified range to outpts in specified range. Users can use custom scaling functions as follows:
```
function myFilterFunc(in:float, buffer:Array):float {
	return Math.abs(in);
}
```

### Constructor ###
`Scaler(inMin:float, inMax:float, outMin:float, outMax:float, type:function, limiter:boolean)`

### Instance variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `type`   | function | current type of the scaler |
| `type =` | function | set type of the scaler |
| `inMin`  | float    | current minimum value for input |
| `inMin =` | float    | set minimum value for input |
| `inMax`  | float    | current maximum value for input |
| `inMax =` | float    | set maximum value for input |
| `outMin` | float    | current minimum value for output |
| `outMin =` | float    | current minimum value for output |
| `outMax` | float    | current maximum value for output |
| `outMax =` | float    | current maximum value for output |
| `limiter` | boolean  | state of the limiter |
| `limiter =` | void     | set state of the limiter |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `LINEAR` | linear (y = x)  |
| `SQUARE` | square curve (y = x<sup>2</sup>) |
| `SQUARE_ROOT` | square root curve (y = x<sup>0.5</sup>) |
| `CUBE`   | cube curve (y = x<sup>4</sup>) |
| `CUBE_ROOT` | cube root curve (y = x<sup>0.25</sup>) |


## SetPoint _< Filter_ ##
SetPoint is filter to divide analog inputs to indices.

### Constructor ###
`SetPoint(threshold:float, hysteresis:float)`

`SetPoint([[t0:float, h0:float], [t1:float, h1:float], ...])`

### Instance variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `point[n]` | Array    | pairs of a threshold and a hysteresis |

### Instance methods ###
| **name** | **return** | **description** |
|:---------|:-----------|:----------------|
| `addPoint(threshold:float, hysteresis:float)` | void       | add a new point |
| `removePoint(threshold:float)` | void       | remove the specified point |


## Osc _< Filter_ ##
Osc is a filter to generate various waves to control outputs.

### Constructor ###
`Osc(wave:function, freq:float, times:int)`

`Osc(wave:function, freq:float, amp:float, offset:float, phase:float, times:int)`

### Class variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `serviceInterval` | int      | service interval of the Osc |

### Instance variables ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `wave`   | function | current wave function |
| `wave =` | function | set wave function |
| `freq`   | float    | current frequency |
| `freq =` | void     | set frequency   |
| `amplitude` | float    | current amplitude |
| `amplitude =` | void     | set amplitude   |
| `offset` | float    | current offset  |
| `offset =` | void     | set offset      |
| `phase`  | float    | current degree  |
| `phase =` | void     | set degree      |
| `times`  | int      | current times   |
| `times =` | void     | set times       |

### Instance methods ###
| **name** | **type** | **description** |
|:---------|:---------|:----------------|
| `start()` | void     | start the oscillator |
| `stop()` | void     | stop the oscillator |
| `reset()` | void     | restart the oscillator |
| `update(interval:int)` | void     | update the oscillator by specified time (in ms) |
| `update()` | void     | update the oscillator by the interval specified as serviceInterval |
| `addEventListener(e:Event, f:function)` | void     | add an event listener to the oscillator |

### Constants ###
| **name** | **description** |
|:---------|:----------------|
| `SIN`    | sin wave        |
| `SQUARE` | square wave     |
| `SAW`    | sawtooth wave   |
| `TRIANGLE` | triangle wave   |
| `IMPULSE` | implse          |