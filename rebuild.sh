#!/usr/bin/env bash
echo "[INFO] REBUILD STARTED"
INJECTDIRS=("junit4" "quickperf")
BASEDIR=$(pwd)
echo "[INFO] INJECTING REBUILD FILES"
for dir in "${INJECTDIRS[@]}"; do
    echo "[INFO] INJECTING REBUILD INTO $dir"
    cp injector.sh $dir/rebuild.sh
    chmod 0755 $dir/rebuild.sh
    cd $dir
    EXISTS=$(cat pom.xml | grep "JFROG_REPRODUCIBLE_BUILD_INJECTOR" | wc -l)
    if [[ "$EXISTS" =~ (0) ]]
    then
      POM=$(sed '$d' pom.xml)
      echo "$POM" > pom.xml.new
      cat ../pom.injector >> pom.xml.new
      echo "[INFO] BUILDING $dir"
      mv pom.xml pom.xml.org
      cp pom.xml.new pom.xml
    fi
    cd $BASEDIR
done
echo "[INFO] EXECUTING REPRODUCIBLE BUILDS"
REBUILDS=$(find . -name 'rebuild.sh' | grep -v "\./rebuild.sh")
for script in $REBUILDS; do
  SCRIPTDIR=$(echo "$script" | sed 's|\(.*\)/.*|\1|')
  cd $SCRIPTDIR
  ./rebuild.sh
  cd $BASEDIR
done
echo "[INFO] CLEANING UP REBUILD FILES"
for dir in "${INJECTDIRS[@]}"; do
  cd $dir
  cp pom.xml.org pom.xml
  rm pom.xml.org rebuild.sh pom.xml.new
  cd $BASEDIR
done
echo "[INFO] COMPLETED REBUILD"
