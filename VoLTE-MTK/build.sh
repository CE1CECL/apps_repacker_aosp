#!/bin/bash
clear
set -e
rm -rf ImsService ImsService.apk
if [ "$#" -lt 1 ]; then echo "Usage: $0 /path/to/root/"; exit 1; fi
java -jar ../apktool.jar d -o ImsService "$1"/system/priv-app/ImsService/ImsService.apk
java -jar ../baksmali.jar d -o ImsService/smali "$1"/system/framework/mediatek-common.jar
java -jar ../baksmali.jar d -o ImsService/smali "$1"/system/framework/mediatek-ims-base.jar
xmlstarlet ed -L -N a=http://schemas.android.com/apk/res/android -d '/manifest/application/@a:usesNonSdkApi' ImsService/AndroidManifest.xml
java -jar ../apktool.jar b ImsService
LD_LIBRARY_PATH=../signapk/ java -jar ../signapk/signapk.jar -a 4096 ../keys/platform.x509.pem ../keys/platform.pk8 ImsService/dist/ImsService.apk ImsService.apk
rm -rf ImsService
