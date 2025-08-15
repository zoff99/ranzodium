#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

echo $_HOME_
cd $_HOME_

# docker info

mkdir -p $_HOME_/artefacts
mkdir -p $_HOME_/script
mkdir -p $_HOME_/workspace

if [ "$1""x" == "buildx" ]; then

    echo "make a local copy ..."
    cp -v ../build_scripts/deps.sh ./__temp__deps.sh
    rsync -avz --exclude=".localrun" --exclude="local.properties" ../ ./__temp__src/
    docker build -f Dockerfile -t ranzodium_001 .
    rm -Rf ./__temp__src/
    rm -f ./__temp__deps.sh
    exit 0
fi

echo '#! /bin/bash

## ----------------------
numcpus_=$(nproc)
quiet_=0
## ----------------------

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

echo ""
echo ""
echo "--------------------------------"
echo "clang version:"
c++ --version
echo "--------------------------------"
echo "java version:"
java -version
echo "--------------------------------"
echo ""
echo ""

cd /maindir/

pwd
id -a

mkdir -p /root/work/
mkdir -p /root/work/deploy/
mkdir -p /root/.android/

rsync -avz --exclude=".localrun" --exclude="local.properties" ./build_scripts/buildlib.sh /root/work/build_scripts/buildlib.sh
redirect_cmd rsync -az --exclude=".localrun" --exclude="local.properties" ./stub /root/work/
redirect_cmd rsync -az --exclude=".localrun" --exclude="local.properties" ./stubaar /root/work/

cd /root/work/
mkdir -p build_dir

cd /root/work/build_dir/
bash ../build_scripts/buildlib.sh || exit 1

cp -av /root/work//artefacts/* /artefacts/

chmod a+rwx -R /workspace/
chmod a+rwx -R /artefacts/

' > $_HOME_/script/do_it___external.sh

chmod a+rx $_HOME_/script/do_it___external.sh


system_to_build_for="ranzodium_001"

cd $_HOME_/
docker run -ti --rm \
  -v $_HOME_/artefacts:/artefacts \
  -v $_HOME_/script:/script \
  -v $_HOME_/../:/maindir \
  -v $_HOME_/workspace:/workspace \
  -e DISPLAY=$DISPLAY \
  "$system_to_build_for" \
  /bin/bash /script/do_it___external.sh

