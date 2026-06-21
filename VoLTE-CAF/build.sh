#!/bin/bash
clear
rm -rf ims ims.apk
set -e
if [ "$#" -lt 1 ]; then echo "Usage: $0 /path/to/root/"; exit 1; fi
if [ -f "$1"/system/system_ext/app/ims/ims.apk ]; then java -jar ../apktool.jar -o ims d "$1"/system/system_ext/app/ims/ims.apk apkbase="$1"/system/system_ext/app/ims/; else java -jar ../apktool.jar d -o ims "$1"/system/system_ext/priv-app/ims/ims.apk; apkbase="$1"/system/system_ext/priv-app/ims/; fi
mkdir -p "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/system_ext/lib/libimsmedia_jni.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/system_ext/lib/libimscamera_jni.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libandroid.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libbinder.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libc++.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/apex/com.android.runtime/lib/bionic/libc.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libcutils.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/apex/com.android.runtime/lib/bionic/libdl.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libgui.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/liblog.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/apex/com.android.runtime/lib/bionic/libm.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/apex/com.android.art.release/lib/libnativehelper.so "ims/lib/armeabi-v7a/"
cp -rf "$1"/system/lib/libutils.so "ims/lib/armeabi-v7a/"
for i in android.frameworks.bufferhub@1.0.so android.hardware.configstore-utils.so android.hardware.configstore@1.0.so android.hardware.graphics.bufferqueue@1.0.so android.hardware.graphics.bufferqueue@2.0.so android.hardware.graphics.common@1.1.so android.hardware.graphics.common@1.2.so android.hidl.token@1.0-utils.so; do newName="$(echo "$i" | sed -E -e 's/^android/diordna/g' -e 's/@/-/g')"; cp -rf "$1"/system/lib/$i "ims/lib/armeabi-v7a/"/$newName; done
for i in android.frameworks.bufferhub@1.0.so android.hardware.configstore-utils.so android.hardware.configstore@1.0.so android.hardware.graphics.bufferqueue@1.0.so android.hardware.graphics.bufferqueue@2.0.so android.hardware.graphics.common@1.1.so android.hardware.graphics.common@1.2.so android.hidl.token@1.0-utils.so; do newName="$(echo "$i" | sed -E -e 's/^android/diordna/g' -e 's/@/-/g')"; sed -i -E "s/$i/$newName/g" "ims/lib/armeabi-v7a/"/*.so; done
xmlstarlet ed -L -N a=http://schemas.android.com/apk/res/android -d '//uses-library' -d '/manifest/@a:compileSdkVersion' -d '/manifest/@a:compileSdkVersionCodename' -d '/manifest/application/@a:usesNonSdkApi' ims/AndroidManifest.xml
java -jar ../baksmali.jar d -o ims/smali "$1"/system/system_ext/framework/qti-telephony-hidl-wrapper.jar
java -jar ../baksmali.jar d -o ims/smali "$1"/system/system_ext/framework/qti-telephony-utils.jar
java -jar ../baksmali.jar d -o ims/smali "$1"/product/framework/ims-ext-common.jar
java -jar ../apktool.jar b ims
LD_LIBRARY_PATH=../signapk/ java -jar ../signapk/signapk.jar -a 4096 ../keys/platform.x509.pem ../keys/platform.pk8 ims/dist/ims.apk ims.apk
rm -rf ims
