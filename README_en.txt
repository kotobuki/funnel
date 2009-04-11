INTRODUCTION
Funnel is a toolkit for physical computing. Funnel supports 
Arduino I/O boards, Gainer I/O modules, XBee wireless modems and 
FIO (Funnel I/O) boards. The user can set filters to input or 
outputs ports: range division, filtering (e.g. LPF, HPF), 
scaling and oscillators.

About the latest information, please refer to the following web site:
http://funnel.cc


REQUIREMENTS
* OS
  * Windows XP SP2/3 or Vista
  * Mac OS X 10.4 or 10.5
* Runtime environments for software libraries
  * Various programming environments for ActionScript 3 (e.g. 
    Flash CS3/4, Flex Builder 3, Flex SDK 3)
  * Processing 1.0
  * Ruby 1.8.* with OSC library by Tadayoshi Funaba
    http://raa.ruby-lang.org/project/osc/
* Runtime environments for the Funnel Server
  * Java Runtime Environment 1.5 or higher
* Hardware
  * Arduino or clones via Firmata v2 (http://firmata.org/)
  * Gainer I/O module v1.0
* Optional environments
  * Arduino 0015 (required for Arduino and FIO)
  * action-coding
    http://code.google.com/p/action-coding/

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

Contributors
* Jeff Hoefs: I2C support related classes and improvement of the AS3 library
* Kazuyoshi Kato: matrix LED (Gainer I/O's mode 7) support for the Ruby library


UPDATES
Funnel 009 (2009.04.16)
* released FIO (Funnel I/O) v1.3 in cooperation with Nathan Seidle (SparkFun Electronics)
  http://www.sparkfun.com/commerce/product_info.php?products_id=8957
* added I2C over Firmata support
  * added I2C related classes for each software library
  * added SimpleI2CFirmata and StandardFirmataWithI2C for Arduino and FIO
* added configuration tools for XBee
  * XBeeConfigTerminal: for generic configurations
  * XBeeConfigTool: for uploading sketches wirelessly to FIO boards
* Processing: Funnel Server is now embedded into Text Area
* Ruby: added matrix LED (Gainer I/O's mode 7) support
* fixed various bugs and improved performance

Funnel 008 (2008.09.25)
* added FIO (Funnel I/O) v1.0
* Funnel Server now requires only one network port
* added more samples for each hardware
* XBee ZB ZigBee PRO is supported
* output side control for XBee 802.15.4 is supported
* added the installation instructions
* fixed various bugs and improved performance

Funnel 007 (2008.04.21)
* fixed bugs and added new features in the Processing library
  * added examples for Gainer (created for the workshop at 
    Make: Tokyo Meeting)
  * added examples for XBee
  * fixed a bug about XBee (the Processing library crushes)
* added a new feature and fixed an issue about the Funnel Server
  * added serial baud rate setting for Arduino and XBee
  * replaced the binary files of the RXTX to run on PowerPC 
    machines

Funnel 006 (2007.12.21)
* fixed bugs and added new features in the Processing library
  * modified to return proper value in "change()"
  * added new event handler "gainerButtonEvent()"
  * added new methods "led()" and "button()"
  * added new properties "analogInput[0]" and so on...

Funnel 005 (2007.12.17)
* added Funnel I/O module and XBee support to ActionScript 3 
  and Processing library

Funnel 004 (2007.12.06)
* re-structured software libraries to support multiple I/O modules
* Unified constants and methods between software libraries
* added Funnel I/O module and XBee support to the Ruby library
* added hardware and firmware data of the Funnel I/O module

Funnel 003 (2007.11.12)
* fixed a bug in Processing library (OutOfMemory error on Windows)

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
Funnel is developed with the support of the Exploratory Software 
Project (the first half of 2007) of IPA (Information-technology 
Promotion Agency).

We would like to acknowledge the following people for assisting us in 
creating Funnel:
* Yoshiaki Mima (was the project manager of the project)
* David A. Mellis (for the binary files of the RXTX library)
