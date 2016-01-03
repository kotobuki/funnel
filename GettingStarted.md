# Getting Started #

## Configuration for Arduino users ##
  1. Open "server/settings.yaml" with your favorite text editor
  1. Change "io: type" from **Gainer** to **Arduino**
```
server:
  command port: 9000
  notification port: 9001

io:
  type: Arduino
  com: 
```
  1. Save the settings file. You are ready to use your Arduino with Funnel. :)


## How to try Funnel? ##
  1. Configure the settings file if needed
  1. Connect an I/O module
  1. Double click on "server/funnel\_server.jar" to launch Funnel Server
  1. See examples at the following location
    * ActionScript 3 => libraries/actionscript3/src/ArduinoTest.as (or GainerTest.as)
    * Processing => libraries/processing/sketch\_samples/ARDUINO (or GAINER)
    * Ruby => libraries/ruby/arduino\_test.rb (or gainer\_test.rb)