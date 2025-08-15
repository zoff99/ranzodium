#! /bin/bash

echo "starting ..."

START_TIME=$SECONDS

## ----------------------
numcpus_=$(nproc)
quiet_=1
full="1"
download_full="1"
## ----------------------

## ----------------------
FORTIFY_FLAGS="" # "-D_FORTIFY_SOURCE=2"
JNI_CUSTOM_FLAGS="-Wl,-z,max-page-size=16384" # align for 16kB
_LIBSODIUM_VERSION_="1.0.20-RELEASE"
_ANDROID_SDK_FILE_="sdk-tools-linux-4333796.zip"
_ANDROID_SDK_HASH_="92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9"

_ANDROID_NDK_FILE_="android-ndk-r21e-linux-x86_64.zip"
_ANDROID_NDK_HASH_="ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e"
_ANDROID_NDK_UNPACKDIR_="android-ndk-r21e"

_ANDOIRD_CMAKE_VER_="3.10.2.4988404"
_GITREPO_HOME_="/home/runner/work/ranzodium/ranzodium" # this works only for github CI for now
## ----------------------

# export ASAN_CLANG_FLAGS=" -fsanitize=address -fno-omit-frame-pointer -fno-optimize-sibling-calls "
export ASAN_CLANG_FLAGS=" "

_HOME_="/root/work/"
export _HOME_
echo "_HOME_=$_HOME_"

export WRKSPACEDIR="$_HOME_""/workspace/"
export CIRCLE_ARTIFACTS="$_HOME_""/artefacts/"
mkdir -p $WRKSPACEDIR
mkdir -p $CIRCLE_ARTIFACTS

mkdir -p .android && touch ~/.android/repositories.cfg

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


echo "installing system packages ..."
export DEBIAN_FRONTEND=noninteractive

if [ ! -e /installing_more_system_packages_done ]; then
    redirect_cmd apt-get update $qqq
    redirect_cmd apt-get install $qqq -y --force-yes lsb-release
fi

system__=$(lsb_release -i|cut -d ':' -f2|sed -e 's#\s##g')
version__=$(lsb_release -r|cut -d ':' -f2|sed -e 's#\s##g')
echo "compiling on: $system__ $version__"

if [ ! -e /installing_more_system_packages_done ]; then
    echo "installing more system packages ..."

    redirect_cmd apt-get install $qqq -y --force-yes wget
    redirect_cmd apt-get install $qqq -y --force-yes git
    redirect_cmd apt-get install $qqq -y --force-yes curl

    redirect_cmd apt-get install $qqq -y --force-yes python-software-properties
    redirect_cmd apt-get install $qqq -y --force-yes software-properties-common
fi

pkgs="
    unzip
    zip
    automake
    autotools-dev
    build-essential
    check
    checkinstall
    libtool
    libfreetype6-dev
    fontconfig-config
    libfontconfig1-dev
    pkg-config
    openjdk-8-jdk
"

if [ ! -e /installing_more_system_packages_done ]; then
    for i in $pkgs ; do
        redirect_cmd apt-get install $qqq -y --force-yes $i
    done
fi

export ORIG_PATH_=$PATH



#### ARM build ###############################################


echo $_HOME_

export _SRC_=$_HOME_/build/
export _INST_=$_HOME_/inst/

echo $_SRC_
echo $_INST_

rm -Rf $_SRC_
rm -Rf $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_


export _SDK_="$_INST_/sdk"
export _NDK_="$_INST_/ndk/"
export _BLD_="$_SRC_/build/"
export _CPUS_=$numcpus_

export _toolchain_="$_INST_/toolchains/"
export _s_="$_SRC_/"
export CF2=" -ftree-vectorize "
export CF3=" -funsafe-math-optimizations -ffast-math "
# ---- arm -----
export AND_TOOLCHAIN_ARCH="arm"
export AND_TOOLCHAIN_ARCH2="arm-linux-androideabi"
export AND_PATH="$_toolchain_/arm-linux-androideabi/bin:$ORIG_PATH_"
export AND_PKG_CONFIG_PATH="$_toolchain_/arm-linux-androideabi/sysroot/usr/lib/pkgconfig"
export AND_CC="$_toolchain_/arm-linux-androideabi/bin/arm-linux-androideabi-clang"
export AND_AS="$_toolchain_/arm-linux-androideabi/bin/arm-linux-androideabi-as"
export AND_GCC="$_toolchain_/arm-linux-androideabi/bin/arm-linux-androideabi-clang"
export AND_CXX="$_toolchain_/arm-linux-androideabi/bin/arm-linux-androideabi-clang++"
export AND_READELF="$_toolchain_/arm-linux-androideabi/bin/arm-linux-androideabi-readelf"
export AND_ARTEFACT_DIR="arm"

echo "-------------------------------------------------------"
echo $_toolchain_
echo "-------------------------------------------------------"
echo $AND_PATH
echo "-------------------------------------------------------"
echo $AND_CC
echo "-------------------------------------------------------"
echo $AND_AS
echo "-------------------------------------------------------"
echo $AND_GCC
echo "-------------------------------------------------------"
echo $AND_CXX
echo "-------------------------------------------------------"

export PATH="$_SDK_"/tools/bin:$ORIG_PATH_

export ANDROID_NDK_HOME="$_NDK_"
export ANDROID_HOME="$_SDK_"


mkdir -p $_toolchain_
mkdir -p $AND_PKG_CONFIG_PATH
mkdir -p $WRKSPACEDIR

if [ "$full""x" == "1x" ]; then

    if [ "$download_full""x" == "1x" ]; then
        cd $WRKSPACEDIR
        if [ -e /sdk.zip ]; then
            cp -v /sdk.zip sdk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_SDK_FILE_" -o sdk.zip
        fi

        cd $WRKSPACEDIR
        if [ -e /ndk.zip ]; then
            cp -v /ndk.zip ndk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_NDK_FILE_" -o ndk.zip
        fi
    fi

    cd $WRKSPACEDIR
    # --- verfiy SDK package ---
    echo "$_ANDROID_SDK_HASH_"'  sdk.zip' \
        > sdk.zip.sha256
    sha256sum -c sdk.zip.sha256 || exit 1
    # --- verfiy SDK package ---
    redirect_cmd unzip sdk.zip
    mkdir -p "$_SDK_"
    mv -v tools "$_SDK_"/
    yes | "$_SDK_"/tools/bin/sdkmanager --licenses > /dev/null 2>&1

    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    $ANDROID_HOME/tools/bin/sdkmanager --update
    ANDROID_VERSION=26
    ANDROID_BUILD_TOOLS_VERSION=26.0.2
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools"
    ANDROID_VERSION=25
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}"
    ANDROID_BUILD_TOOLS_VERSION=25.0.0
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27"
    # -- why is this not just called "cmake" ? --
    # cmake_pkg_name=$($ANDROID_HOME/tools/bin/sdkmanager --list --verbose|grep -i cmake| tail -n 1 | cut -d \| -f 1 |tr -d " ");
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "cmake;$_ANDOIRD_CMAKE_VER_"
    # -- why is this not just called "cmake" ? --
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries



    cd $WRKSPACEDIR
    # --- verfiy NDK package ---
    echo "$_ANDROID_NDK_HASH_"'  ndk.zip' \
        > ndk.zip.sha256
    sha256sum ndk.zip
    sha256sum -c ndk.zip.sha256 || exit 1
    # --- verfiy NDK package ---
    redirect_cmd unzip ndk.zip
    rm -Rf "$_NDK_"
    mv -v "$_ANDROID_NDK_UNPACKDIR_" "$_NDK_"


    echo 'export ARTEFACT_DIR="$AND_ARTEFACT_DIR";export PATH="$AND_PATH";export PKG_CONFIG_PATH="$AND_PKG_CONFIG_PATH";export READELF="$AND_READELF";export GCC="$AND_GCC";export CC="$AND_CC";export CXX="$AND_CXX";export CPPFLAGS="";export LDFLAGS="";export TOOLCHAIN_ARCH="$AND_TOOLCHAIN_ARCH";export TOOLCHAIN_ARCH2="$AND_TOOLCHAIN_ARCH2"' > $_HOME_/pp
    chmod u+x $_HOME_/pp
    rm -Rf "$_s_"
    mkdir -p "$_s_"

    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    . $_HOME_/pp
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##

    echo "CC=""$CC"
    echo "GCC=""$GCC"
    echo "PATH=""$PATH"

    mkdir -p "$PKG_CONFIG_PATH"
    redirect_cmd $_NDK_/build/tools/make_standalone_toolchain.py --arch "$TOOLCHAIN_ARCH" \
        --install-dir "$_toolchain_"/arm-linux-androideabi --api 21 --force

    # --- LIBSODIUM ---
    cd $_s_;git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git
    cd $_s_/libsodium/;autoreconf -fi
    rm -Rf "$_BLD_"
    mkdir -p "$_BLD_"
    cd "$_BLD_";export CXXFLAGS=" -g -O3 ";export CFLAGS=" -g -Os -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -marm -march=armv7-a "
    $_s_/libsodium/configure --prefix="$_toolchain_"/arm-linux-androideabi/sysroot/usr \
        --disable-shared --disable-soname-versions --host=arm-linux-androideabi \
        --with-sysroot="$_toolchain_"/arm-linux-androideabi/sysroot --disable-pie
    cd "$_BLD_";make -j $_CPUS_ || exit 1
    cd "$_BLD_";make install
    export CFLAGS=" -g -O3 "
    # --- LIBSODIUM ---

fi

echo ""
echo ""
echo "compiling jni ..."

echo ""
echo ""
echo "-------- compiler version --------"
echo "-------- compiler version --------"
$GCC --version
echo "-------- compiler version --------"
echo "-------- compiler version --------"
echo ""
echo ""

echo "... done"

if [ $res -ne 0 ]; then
    echo "ERROR"
    exit 1
fi

#### ARM build ###############################################











#### ARM64 build ###############################################


echo $_HOME_

export _SRC_=$_HOME_/arm64_build/
export _INST_=$_HOME_/arm64_inst/

echo $_SRC_
echo $_INST_

rm -Rf $_SRC_
rm -Rf $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_




export _SDK_="$_INST_/sdk"
export _NDK_="$_INST_/ndk/"
export _BLD_="$_SRC_/build/"
export _CPUS_=$numcpus_

export _toolchain_="$_INST_/toolchains/"
export _s_="$_SRC_/"
export CF2=" -ftree-vectorize "
export CF3=" -funsafe-math-optimizations -ffast-math "
# ---- arm -----
export AND_TOOLCHAIN_ARCH="arm64"
export AND_TOOLCHAIN_ARCH2="aarch64"
export AND_TOOLCHAIN_ARCH3="aarch64-linux-android"
export AND_PATH="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin:$ORIG_PATH_"
export AND_PKG_CONFIG_PATH="$_toolchain_/$AND_TOOLCHAIN_ARCH/sysroot/usr/lib/pkgconfig"
export AND_CC="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/aarch64-linux-android-clang"
export AND_AS="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/aarch64-linux-android-as"
export AND_GCC="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/aarch64-linux-android-clang"
export AND_CXX="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/aarch64-linux-android-clang++"
export AND_READELF="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/aarch64-linux-android-readelf"
export AND_ARTEFACT_DIR="arm64"

export PATH="$_SDK_"/tools/bin:$ORIG_PATH_

export ANDROID_NDK_HOME="$_NDK_"
export ANDROID_HOME="$_SDK_"


mkdir -p $_toolchain_
mkdir -p $AND_PKG_CONFIG_PATH
mkdir -p $WRKSPACEDIR


if [ "$full""x" == "1x" ]; then

    if [ "$download_full""x" == "1x" ]; then
        cd $WRKSPACEDIR
        if [ -e /sdk.zip ]; then
            cp -v /sdk.zip sdk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_SDK_FILE_" -o sdk.zip
        fi

        cd $WRKSPACEDIR
        if [ -e /ndk.zip ]; then
            cp -v /ndk.zip ndk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_NDK_FILE_" -o ndk.zip
        fi
    fi

    cd $WRKSPACEDIR
    # --- verfiy SDK package ---
    echo "$_ANDROID_SDK_HASH_"'  sdk.zip' \
        > sdk.zip.sha256
    sha256sum -c sdk.zip.sha256 || exit 1
    # --- verfiy SDK package ---
    redirect_cmd unzip sdk.zip
    mkdir -p "$_SDK_"
    mv -v tools "$_SDK_"/
    yes | "$_SDK_"/tools/bin/sdkmanager --licenses > /dev/null 2>&1

    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    $ANDROID_HOME/tools/bin/sdkmanager --update
    ANDROID_VERSION=26
    ANDROID_BUILD_TOOLS_VERSION=26.0.2
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools"
    ANDROID_VERSION=25
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}"
    ANDROID_BUILD_TOOLS_VERSION=25.0.0
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27"
    # -- why is this not just called "cmake" ? --
    # cmake_pkg_name=$($ANDROID_HOME/tools/bin/sdkmanager --list --verbose|grep -i cmake| tail -n 1 | cut -d \| -f 1 |tr -d " ");
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "cmake;$_ANDOIRD_CMAKE_VER_"
    # -- why is this not just called "cmake" ? --
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries



    cd $WRKSPACEDIR
    # --- verfiy NDK package ---
    echo "$_ANDROID_NDK_HASH_"'  ndk.zip' \
        > ndk.zip.sha256
    sha256sum -c ndk.zip.sha256 || exit 1
    # --- verfiy NDK package ---
    redirect_cmd unzip ndk.zip
    rm -Rf "$_NDK_"
    mv -v "$_ANDROID_NDK_UNPACKDIR_" "$_NDK_"



    echo 'export ARTEFACT_DIR="$AND_ARTEFACT_DIR";export PATH="$AND_PATH";export PKG_CONFIG_PATH="$AND_PKG_CONFIG_PATH";export READELF="$AND_READELF";export GCC="$AND_GCC";export CC="$AND_CC";export CXX="$AND_CXX";export CPPFLAGS="";export LDFLAGS="";export TOOLCHAIN_ARCH="$AND_TOOLCHAIN_ARCH";export TOOLCHAIN_ARCH2="$AND_TOOLCHAIN_ARCH2"' > $_HOME_/pp
    chmod u+x $_HOME_/pp
    rm -Rf "$_s_"
    mkdir -p "$_s_"


    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    . $_HOME_/pp
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##


    mkdir -p "$PKG_CONFIG_PATH"
    redirect_cmd $_NDK_/build/tools/make_standalone_toolchain.py --arch "$TOOLCHAIN_ARCH" \
        --install-dir "$_toolchain_"/arm64 --api 21 --force

    # --- LIBSODIUM ---
    cd $_s_;git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git
    cd $_s_/libsodium/;autoreconf -fi
    rm -Rf "$_BLD_"
    mkdir -p "$_BLD_"
    cd "$_BLD_";export CXXFLAGS=" -g -Os -march=armv8-a ";export CFLAGS=" -g -Os -march=armv8-a "
    $_s_/libsodium/configure --prefix="$_toolchain_"/"$AND_TOOLCHAIN_ARCH"/sysroot/usr \
        --disable-shared --disable-soname-versions --host="$AND_TOOLCHAIN_ARCH3" \
        --with-sysroot="$_toolchain_"/"$AND_TOOLCHAIN_ARCH"/sysroot --disable-pie
    cd "$_BLD_";make -j $_CPUS_ || exit 1
    cd "$_BLD_";make install
    export CFLAGS=" -g -O3 "
    export CXXFLAGS=" -g -O3 "
    # --- LIBSODIUM ---

fi


echo ""
echo ""
echo "compiling jni ..."

echo ""
echo ""
echo "-------- compiler version --------"
echo "-------- compiler version --------"
$GCC --version
echo "-------- compiler version --------"
echo "-------- compiler version --------"
echo ""
echo ""

echo "... done"

if [ $res -ne 0 ]; then
    echo "ERROR"
    exit 1
fi


#### ARM64 build ###############################################





#### x86 build ###############################################



echo $_HOME_

export _SRC_=$_HOME_/x86_build/
export _INST_=$_HOME_/x86_inst/

echo $_SRC_
echo $_INST_

rm -Rf $_SRC_
rm -Rf $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_




export _SDK_="$_INST_/sdk"
export _NDK_="$_INST_/ndk/"
export _BLD_="$_SRC_/build/"
export _CPUS_=$numcpus_

export _toolchain_="$_INST_/toolchains/"
export _s_="$_SRC_/"
export CF2=" -ftree-vectorize "
export CF3=" -funsafe-math-optimizations -ffast-math "
# ---- arm -----
export AND_TOOLCHAIN_ARCH="x86"
export AND_TOOLCHAIN_ARCH2="x86"
export AND_PATH="$_toolchain_/x86/bin:$ORIG_PATH_"
export AND_PKG_CONFIG_PATH="$_toolchain_/x86/sysroot/usr/lib/pkgconfig"
export AND_CC="$_toolchain_/x86/bin/i686-linux-android-clang"
export AND_AS="$_toolchain_/x86/bin/i686-linux-android-as"
export AND_GCC="$_toolchain_/x86/bin/i686-linux-android-clang"
export AND_CXX="$_toolchain_/x86/bin/i686-linux-android-clang++"
export AND_READELF="$_toolchain_/x86/bin/i686-linux-android-readelf"
export AND_ARTEFACT_DIR="x86"

export PATH="$_SDK_"/tools/bin:$ORIG_PATH_

export ANDROID_NDK_HOME="$_NDK_"
export ANDROID_HOME="$_SDK_"


mkdir -p $_toolchain_
mkdir -p $AND_PKG_CONFIG_PATH
mkdir -p $WRKSPACEDIR

if [ "$full""x" == "1x" ]; then

    if [ "$download_full""x" == "1x" ]; then
        cd $WRKSPACEDIR
        if [ -e /sdk.zip ]; then
            cp -v /sdk.zip sdk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_SDK_FILE_" -o sdk.zip
        fi

        cd $WRKSPACEDIR
        if [ -e /ndk.zip ]; then
            cp -v /ndk.zip ndk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_NDK_FILE_" -o ndk.zip
        fi
    fi

    cd $WRKSPACEDIR
    # --- verfiy SDK package ---
    echo "$_ANDROID_SDK_HASH_"'  sdk.zip' \
        > sdk.zip.sha256
    sha256sum -c sdk.zip.sha256 || exit 1
    # --- verfiy SDK package ---
    redirect_cmd unzip sdk.zip
    mkdir -p "$_SDK_"
    mv -v tools "$_SDK_"/
    yes | "$_SDK_"/tools/bin/sdkmanager --licenses > /dev/null 2>&1

    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager --update
    ANDROID_VERSION=26
    ANDROID_BUILD_TOOLS_VERSION=26.0.2
    $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools"
    ANDROID_VERSION=25
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}"
    ANDROID_BUILD_TOOLS_VERSION=25.0.0
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27"
    # -- why is this not just called "cmake" ? --
    # cmake_pkg_name=$($ANDROID_HOME/tools/bin/sdkmanager --list --verbose|grep -i cmake| tail -n 1 | cut -d \| -f 1 |tr -d " ");
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "cmake;$_ANDOIRD_CMAKE_VER_"
    # -- why is this not just called "cmake" ? --
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries



    cd $WRKSPACEDIR
    # --- verfiy NDK package ---
    echo "$_ANDROID_NDK_HASH_"'  ndk.zip' \
        > ndk.zip.sha256
    sha256sum -c ndk.zip.sha256 || exit 1
    # --- verfiy NDK package ---
    redirect_cmd unzip ndk.zip
    rm -Rf "$_NDK_"
    mv -v "$_ANDROID_NDK_UNPACKDIR_" "$_NDK_"



    echo 'export ARTEFACT_DIR="$AND_ARTEFACT_DIR";export PATH="$AND_PATH";export PKG_CONFIG_PATH="$AND_PKG_CONFIG_PATH";export READELF="$AND_READELF";export GCC="$AND_GCC";export CC="$AND_CC";export CXX="$AND_CXX";export CPPFLAGS="";export LDFLAGS="";export TOOLCHAIN_ARCH="$AND_TOOLCHAIN_ARCH";export TOOLCHAIN_ARCH2="$AND_TOOLCHAIN_ARCH2"' > $_HOME_/pp
    chmod u+x $_HOME_/pp
    rm -Rf "$_s_"
    mkdir -p "$_s_"


    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    . $_HOME_/pp
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##


    mkdir -p "$PKG_CONFIG_PATH"
    redirect_cmd $_NDK_/build/tools/make_standalone_toolchain.py --arch "$TOOLCHAIN_ARCH" \
        --install-dir "$_toolchain_"/x86 --api 21 --force

    # --- LIBSODIUM ---
    cd $_s_;git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git
    cd $_s_/libsodium/;autoreconf -fi
    rm -Rf "$_BLD_"
    mkdir -p "$_BLD_"
    cd "$_BLD_";export CXXFLAGS=" -g -O3 ";export CFLAGS=" -g -Os -march=i686 "
    $_s_/libsodium/configure --prefix="$_toolchain_"/x86/sysroot/usr \
        --disable-shared --disable-soname-versions --host=x86 \
        --with-sysroot="$_toolchain_"/x86/sysroot --disable-pie
    cd "$_BLD_";make -j $_CPUS_ || exit 1
    cd "$_BLD_";make install
    export CFLAGS=" -g -O3 "
    # --- LIBSODIUM ---

fi


echo ""
echo ""
echo "compiling jni ..."

echo "... done"


if [ $res -ne 0 ]; then
    echo "ERROR"
    exit 1
fi


#### x86 build ###############################################





#### x86_64 build ###############################################



echo $_HOME_

export _SRC_=$_HOME_/x86_64_build/
export _INST_=$_HOME_/x86_64_inst/

echo $_SRC_
echo $_INST_

rm -Rf $_SRC_
rm -Rf $_INST_

mkdir -p $_SRC_
mkdir -p $_INST_




export _SDK_="$_INST_/sdk"
export _NDK_="$_INST_/ndk/"
export _BLD_="$_SRC_/build/"
export _CPUS_=$numcpus_

export _toolchain_="$_INST_/toolchains/"
export _s_="$_SRC_/"
export CF2=" -ftree-vectorize "
export CF3=" -funsafe-math-optimizations -ffast-math "
# ---- arm -----
export AND_TOOLCHAIN_ARCH="x86_64"
export AND_TOOLCHAIN_ARCH2="x86_64"
export AND_TOOLCHAIN_ARCH3="x86_64-linux-android"
export AND_PATH="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin:$ORIG_PATH_"
export AND_PKG_CONFIG_PATH="$_toolchain_/$AND_TOOLCHAIN_ARCH/sysroot/usr/lib/pkgconfig"
export AND_CC="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/x86_64-linux-android-clang"
export AND_AS="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/x86_64-linux-android-as"
export AND_GCC="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/x86_64-linux-android-clang"
export AND_CXX="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/x86_64-linux-android-clang++"
export AND_READELF="$_toolchain_/$AND_TOOLCHAIN_ARCH/bin/x86_64-linux-android-readelf"
export AND_ARTEFACT_DIR="x86_64"

export PATH="$_SDK_"/tools/bin:$ORIG_PATH_

export ANDROID_NDK_HOME="$_NDK_"
export ANDROID_HOME="$_SDK_"


mkdir -p $_toolchain_
mkdir -p $AND_PKG_CONFIG_PATH
mkdir -p $WRKSPACEDIR

if [ "$full""x" == "1x" ]; then

    if [ "$download_full""x" == "1x" ]; then
        cd $WRKSPACEDIR
        if [ -e /sdk.zip ]; then
            cp -v /sdk.zip sdk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_SDK_FILE_" -o sdk.zip
        fi

        cd $WRKSPACEDIR
        if [ -e /ndk.zip ]; then
            cp -v /ndk.zip ndk.zip
        else
            redirect_cmd curl https://dl.google.com/android/repository/"$_ANDROID_NDK_FILE_" -o ndk.zip
        fi
    fi

    cd $WRKSPACEDIR
    # --- verfiy SDK package ---
    echo "$_ANDROID_SDK_HASH_"'  sdk.zip' \
        > sdk.zip.sha256
    sha256sum -c sdk.zip.sha256 || exit 1
    # --- verfiy SDK package ---
    redirect_cmd unzip sdk.zip
    mkdir -p "$_SDK_"
    mv -v tools "$_SDK_"/
    yes | "$_SDK_"/tools/bin/sdkmanager --licenses > /dev/null 2>&1

    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager --update
    ANDROID_VERSION=26
    ANDROID_BUILD_TOOLS_VERSION=26.0.2
    $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "platforms;android-${ANDROID_VERSION}" \
        "platform-tools"
    ANDROID_VERSION=25
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}"
    ANDROID_BUILD_TOOLS_VERSION=25.0.0
    redirect_cmd $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;27.0.3"
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-27"
    # -- why is this not just called "cmake" ? --
    # cmake_pkg_name=$($ANDROID_HOME/tools/bin/sdkmanager --list --verbose|grep -i cmake| tail -n 1 | cut -d \| -f 1 |tr -d " ");
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "cmake;$_ANDOIRD_CMAKE_VER_"
    # -- why is this not just called "cmake" ? --
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries ------------------------------
    # Install Android Build Tool and Libraries



    cd $WRKSPACEDIR
    # --- verfiy NDK package ---
    echo "$_ANDROID_NDK_HASH_"'  ndk.zip' \
        > ndk.zip.sha256
    sha256sum -c ndk.zip.sha256 || exit 1
    # --- verfiy NDK package ---
    redirect_cmd unzip ndk.zip
    rm -Rf "$_NDK_"
    mv -v "$_ANDROID_NDK_UNPACKDIR_" "$_NDK_"



    echo 'export ARTEFACT_DIR="$AND_ARTEFACT_DIR";export PATH="$AND_PATH";export PKG_CONFIG_PATH="$AND_PKG_CONFIG_PATH";export READELF="$AND_READELF";export GCC="$AND_GCC";export CC="$AND_CC";export CXX="$AND_CXX";export CPPFLAGS="";export LDFLAGS="";export TOOLCHAIN_ARCH="$AND_TOOLCHAIN_ARCH";export TOOLCHAIN_ARCH2="$AND_TOOLCHAIN_ARCH2"' > $_HOME_/pp
    chmod u+x $_HOME_/pp
    rm -Rf "$_s_"
    mkdir -p "$_s_"


    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    . $_HOME_/pp
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##
    ## ------- init vars ------- ##


    mkdir -p "$PKG_CONFIG_PATH"
    redirect_cmd $_NDK_/build/tools/make_standalone_toolchain.py --arch "$TOOLCHAIN_ARCH" \
        --install-dir "$_toolchain_"/x86_64 --api 21 --force

    # --- LIBSODIUM ---
    cd $_s_;git clone --depth=1 --branch="$_LIBSODIUM_VERSION_" https://github.com/jedisct1/libsodium.git
    cd $_s_/libsodium/;autoreconf -fi
    rm -Rf "$_BLD_"
    mkdir -p "$_BLD_"
    cd "$_BLD_";export CXXFLAGS=" -g -O3 ";export CFLAGS=" -g -Os -march=westmere "
    $_s_/libsodium/configure --prefix="$_toolchain_"/"$AND_TOOLCHAIN_ARCH"/sysroot/usr \
        --disable-shared --disable-soname-versions --host="$AND_TOOLCHAIN_ARCH3" \
        --with-sysroot="$_toolchain_"/"$AND_TOOLCHAIN_ARCH"/sysroot --disable-pie
    cd "$_BLD_";make -j $_CPUS_ || exit 1
    cd "$_BLD_";make install
    export CFLAGS=" -g -O3 "
    # --- LIBSODIUM ---

fi

echo ""
echo ""
echo "compiling jni ..."

echo "... done"


if [ $res -ne 0 ]; then
    echo "ERROR"
    exit 1
fi


#### x86_64 build ###############################################

pwd

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo "compile time: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"

