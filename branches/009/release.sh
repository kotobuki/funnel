#!/bin/sh
mv ./server/funnel_server.jar ./libraries/processing/library
cp ./server/rxtxSerial.dll ./libraries/processing/library
cp ./server/librxtxSerial.* ./libraries/processing/library
cp ./server/settings.*.txt ./libraries/processing/library
cp ./server/lib/RXTXcomm.jar ./libraries/processing/library
cp ./server/lib/jvyaml.jar ./libraries/processing/library
cp ./documents/src/installation_instructions_*.pdf ./documents
rm -r ./documents/src/
rm -r ./release/
mv ./server/rxtxSerial.dll ./server/lib
rm ./server/librxtxSerial.*
rm ./release.sh
rm -r ./libraries/of/
