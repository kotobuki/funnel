#!/bin/sh
cp ./server/funnel_server.jar ./server/Funnel\ Server.app/Contents/Resources/Java
cp ./server/librxtxSerial.jnilib ./server/Funnel\ Server.app/Contents/Resources/Java
cp ./server/lib/RXTXcomm.jar ./server/Funnel\ Server.app/Contents/Resources/Java
mv ./server/funnel_server.jar ./libraries/processing/funnel/library
cp ./server/rxtxSerial.dll ./libraries/processing/funnel/library
cp ./server/librxtxSerial.* ./libraries/processing/funnel/library
cp ./server/settings.*.txt ./libraries/processing/funnel/library
cp ./server/lib/RXTXcomm.jar ./libraries/processing/funnel/library
cp ./server/lib/javaosc.jar ./libraries/processing/funnel/library
cp ./server/lib/jvyaml.jar ./libraries/processing/funnel/library
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
cp -r ./hardware/japanino/ ./funnel_server-mac/Japanino
cp -r ./hardware/japanino/ ./funnel_server-win/Japanino
mkdir ./tools
cp -r ./hardware/fio/tool/ ./tools/
hdiutil create -format UDRO -fs HFS+ -srcfolder ./funnel_server-mac -volname "funnel_server" funnel_server-mac.dmg
zip -r funnel_server-win.zip ./funnel_server-win/
rm -r ./funnel_server-mac/
rm -r ./funnel_server-win/
cp ./funnel_server-win.zip ./server/windows.zip
cp ./funnel_server-mac.dmg ./server/macosx.dmg
mv ./funnel_server-win.zip ./funnel_server_japanino.zip
mv ./funnel_server-mac.dmg ./funnel_server_japanino.dmg
rm ./server/*.txt
rm ./server/*.exe
rm -r ./server/lib/
rm -r ./server/Funnel\ Server.app/
rm ./release.sh
