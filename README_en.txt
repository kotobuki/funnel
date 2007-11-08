INTRODUCTION
Funnel is a toolkit for physical computing. Funnel supports 
Arduino I/O boards and Gainer I/O modules. The user can set 
filters to input or outputs ports: range division, filtering 
(e.g. LPF, HPF), scaling and oscillators.
Details, future plans are described at the following location, 
but are subject to change.
http://code.google.com/p/funnel/


REQUIREMENTS
* OS
  * Windows XP SP2
  * Mac OS X 10.4
* Runtime environments for software libraries
  * Various programming environments for ActionScript 3 (e.g. 
    Flash CS3, Flex Builder 2, Flex SDK 2)
  * Processing 0133
  * Ruby 1.8.2 with OSC library by Tadayoshi Funaba
    http://raa.ruby-lang.org/project/osc/
* Runtime environments for the Funnel Server
  * Java Runtime Environment 1.4.2 or higher
* Hardware
  * Arduino USB/NG/Diecimila with Firmara firmware v1.0
    Standard_Firmata_334
    http://www.arduino.cc/playground/Interfacing/Firmata
  * Gainer I/O module v1.0


BUG REPORTS AND REQUESTS
Please file your bug reports or requests via Google Code's 
Issues system. We accepts issues written in English or 
Japanese.
http://code.google.com/p/funnel/issues/

For general discussions, please use the following forums:
English: http://gainer.cc/forum/index.php?board=25.0
Japanese: http://gainer.cc/forum/index.php?board=26.0

NOTE: To avoid unsolicited posts, you need to log into the 
forum to post articles.


CREDITS
Funnel is an open source project.

The Funnel development team is composed of Shigeru Kobayashi, 
Takanori Endo and Ichitaro Masuda.

Funnel uses the Java OSC by Illposed Software, JvYAML by Ola 
Bini and RXTX by Keane Jarvi.

* Java OSC: http://www.illposed.com/software/javaosc.html
* JvYAML: https://jvyaml.dev.java.net/
* RXTX: http://www.rxtx.org/


UPDATES
Funnel 002 (2007.11.08)
* fixed bugs in Processing library (Scaler and Convolution)
* fixed a bug in ActionScript 3 library
  http://gainer.cc/forum/index.php?topic=205

Funnel 001 (2007.10.31)
* added Configuration class and shortcuts for Gainer and 
  Arduino
* added Arduino examples for the Processing library
* added an utility class and an example for Gainer.MODE7 for 
  the AS3 library
* added experimental XBee support, please refer the following 
  scripts to configure
  * sketchbook/configure_xbee_base.py
  * sketchbook/configure_xbee_remote.py
* added XBee example for the Ruby library
* Funnel Server supports OSC via TCP only (i.e. no UDP support)
* Not optimized

Funnel 000 (2007.09.24)
* The first public build
* Supports Arduino NG, Arduino Diecimila and Gainer I/O module
* Funnel Server supports OSC via TCP only
* Not optimized


ACKNOWLEDGMENTS
Funnel is developed with the support of the Exploratory 
Software Project (the first half of 2007) of IPA (Information-
technology Promotion Agency).
