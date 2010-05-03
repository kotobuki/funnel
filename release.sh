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
rm -r ./libraries/of/
mkdir ./funnel_server-mac
mkdir ./funnel_server-win
cp -r ./server/Funnel\ Server.app ./funnel_server-mac/
cp -r ./server/Funnel\ Server.exe ./funnel_server-win/
cp -r ./server/lib ./funnel_server-win/
cp ./*.txt ./funnel_server-mac/
cp ./*.txt ./funnel_server-win/
mkdir ./tools
cp -r ./hardware/fio/tool/ ./tools/
hdiutil create -format UDRO -fs HFS+ -srcfolder ./funnel_server-mac -volname "funnel_server" funnel_server-mac.dmg
zip -r funnel_server-win.zip ./funnel_server-win/
rm -r ./funnel_server-mac/
rm -r ./funnel_server-win/
cp ./funnel_server-win.zip ./server/win.zip
cp ./funnel_server-mac.dmg ./server/mac.dmg
rm ./release.sh
