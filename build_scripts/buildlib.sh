#! /bin/bash

echo "starting ..."

START_TIME=$SECONDS

## ----------------------
numcpus_=$(nproc)
quiet_=1
download_full="1"
## ----------------------

_HOME_="/root/work/"
export _HOME_
echo "_HOME_=$_HOME_"

export WRKSPACEDIR="$_HOME_""/workspace/"
export CIRCLE_ARTIFACTS="$_HOME_""/artefacts/"
_ANDROID_SDK_FILE_="sdk-tools-linux-4333796.zip"
_ANDROID_SDK_HASH_="92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9"

mkdir -p $WRKSPACEDIR
mkdir -p $CIRCLE_ARTIFACTS

export qqq=""

if [ "$quiet_""x" == "1x" ]; then
	export qqq=" -qq "
fi


redirect_cmd() {
    if [ "$quiet_""x" == "1x" ]; then
        "$@" > /dev/null 2>&1
    else
        "$@"
    fi
}

echo $_HOME_

export _SRC_=$_HOME_/build/
export _INST_=$_HOME_/inst/

echo $_SRC_
echo $_INST_

rm -Rf $_SRC_
rm -Rf $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_


export ORIG_PATH_=$PATH
export _SDK_="$_INST_/sdk"
export _NDK_="$_INST_/ndk/"
export ANDROID_NDK_HOME="$_NDK_"
export ANDROID_HOME="$_SDK_"

export _BLD_="$_SRC_/build/"
export _CPUS_=$numcpus_

export _s_="$_SRC_/"
mkdir -p "$WRKSPACEDIR"

rm -Rf "$_s_"
mkdir -p "$_s_"


#######################################################
cd "$WRKSPACEDIR"
if [ -e /sdk.zip ]; then
    cp -v /sdk.zip sdk.zip
else
    curl https://dl.google.com/android/repository/"$_ANDROID_SDK_FILE_" -o sdk.zip
fi
cd "$WRKSPACEDIR"
# --- verfiy SDK package ---
echo "$_ANDROID_SDK_HASH_"'  sdk.zip' \
    > sdk.zip.sha256
sha256sum -c sdk.zip.sha256 || exit 1
# --- verfiy SDK package ---
unzip sdk.zip >/dev/null 2>&1
mkdir -p "$_SDK_"
mv -v tools "$_SDK_"/
yes | "$_SDK_"/tools/bin/sdkmanager --licenses > /dev/null 2>&1
#######################################################




# get current artefact version number
cur_version=$(cat /root/work/app/jnilib/build.gradle|grep 'def maven_artefact_version'|cut -d "'" -f 2)

if [ "$cur_version""x" == "x" ]; then
    echo "ERROR: can not determine current verion"
    exit 1
fi

ls -hal /root/work//artefacts//android/libs/armeabi/libjni-ranzodium.so || exit 1
ls -hal /root/work//artefacts//android/libs/arm64-v8a/libjni-ranzodium.so || exit 1
ls -hal /root/work//artefacts//android/libs/x86/libjni-ranzodium.so || exit 1
ls -hal /root/work//artefacts//android/libs/x86_64/libjni-ranzodium.so || exit 1

ls -al /root/work/app/jnilib/src/main/jniLibs/

cp -v /root/work//artefacts//android/libs/armeabi/libjni-ranzodium.so /root/work/app/jnilib/src/main/jniLibs/armeabi-v7a/ || exit 1
cp -v /root/work//artefacts//android/libs/arm64-v8a/libjni-ranzodium.so /root/work/app/jnilib/src/main/jniLibs/arm64-v8a/ || exit 1
cp -v /root/work//artefacts//android/libs/x86/libjni-ranzodium.so /root/work/app/jnilib/src/main/jniLibs/x86/ || exit 1
cp -v /root/work//artefacts//android/libs/x86_64/libjni-ranzodium.so /root/work/app/jnilib/src/main/jniLibs/x86_64/ || exit 1

apt-get install openjdk-17-jdk-headless -y --force-yes

cd /root/work/app/
find . -name '*.aar' -exec rm -v {} \; || echo "NO ERR"
./gradlew build
find . -name '*.aar'
find . -name '*.aar' -exec ls -hal {} \;

unzip -t ./jnilib/build/outputs/aar/ranzodium-jni-lib-release.aar

pwd

./gradlew publishToMavenLocal

ls -alR ~/.m2/repository/com/zoffcc/applications/ranzodium/ranzodium-jni-lib/ || exit 1


ls -al $CIRCLE_ARTIFACTS/

echo "CIRCLE_ARTIFACTS=""$CIRCLE_ARTIFACTS"

pwd

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo "compile time: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"

