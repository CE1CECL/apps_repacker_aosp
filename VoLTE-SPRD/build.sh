#!/bin/bash
clear
set -e
rm -rf vdexExtractor_deodexed out ims ims.apk
if [ "$#" -lt 2 ]; then echo "Usage: $0 /path/to/root/ /path/to/ims.apk"; exit 1; fi
java -jar ../apktool.jar d "$2"
xmlstarlet ed -L -N android=http://schemas.android.com/apk/res/android -d '/manifest/@android:compileSdkVersion' -d '/manifest/@android:compileSdkVersionCodename' -d '//application/@android:appComponentFactory' -d '//application/@android:usesNonSdkApi' ims/AndroidManifest.xml
rm -rf out classes*.dex vdexExtractor_deodexed boot-framework boot-telephony-common boot-radio_interactor_common
../vdexExtractor/tools/deodex/run.sh -i "$1"/system/framework/boot-framework.vdex
for a in vdexExtractor_deodexed/*/*; do java -jar ../baksmali.jar d $a; done
mv out boot-framework
../vdexExtractor/tools/deodex/run.sh -i "$1"/system/framework/boot-telephony-common.vdex
for b in vdexExtractor_deodexed/*/*; do java -jar ../baksmali.jar d $b; done
mv out boot-telephony-common
../vdexExtractor/tools/deodex/run.sh -i "$1"/system/framework/boot-radio_interactor_common.vdex
for c in vdexExtractor_deodexed/*/*; do java -jar ../baksmali.jar d $c; done
mv out boot-radio_interactor_common
(cd boot-radio_interactor_common; tar c . | tar x -C ../ims/smali/)
perl -0777 -pe 's/.annotation.*InnerClass.*\n.*accessFlag.*\n.*name.*\n.*end annotation.*\n//g' -i ims/smali/vendor/sprd/hardware/radio/V1_0/IAtcRadioIndication\$Proxy.smali
mkdir -p ims/smali/com/android/internal/telephony/{,dataconnection}
cp boot-telephony-common/com/android/internal/telephony/dataconnection/{DcNetworkManager*,ApnSetting*,AbsApnSett*} ims/smali/com/android/internal/telephony/dataconnection/
cp boot-telephony-common/com/android/internal/telephony/VolteConfig.smali ims/smali/com/android/internal/telephony/
cp boot-framework/com/android/internal/telephony/ITelephonyEx* ims/smali/com/android/internal/telephony/
mkdir -p ims/smali/com/android/ims/internal
cp boot-framework/com/android/ims/internal/{IImsUtEx*,IImsServiceEx*,IVoWifi*,IImsDoze*,ImsManagerEx*,IImsUtListenerEx*} ims/smali/com/android/ims/internal
mkdir -p ims/smali/android/telephony/
cp boot-framework/android/telephony/TelephonyManagerEx.smali ims/smali/android/telephony/perl -0777 -i -pe 's/.*invoke.*CarrierConfigManager;->getConfigForPhoneId.*\n\n\h*move-result-object v([0-9]*)\n/const v\1, 0/g' ims/smali/com/spreadtrum/ims/ut/ImsUtProxy.smali
java -jar ../apktool.jar b ../prebuilts/build-tools/linux-x86/bin/zip2zip -0 'lib/**/*' -i ims/dist/ims.apk -o ims/dist/ims.new.apk
mv -f ims/dist/ims.new.apk ims/dist/ims.apk
LD_LIBRARY_PATH=../signapk/ java -jar ../signapk/signapk.jar -a 4096 ../keys/platform.x509.pem ../keys/platform.pk8 ims/dist/ims.apk ims.apk
rm -rf ims
echo ims.apk
