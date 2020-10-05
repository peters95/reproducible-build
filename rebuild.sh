#!/usr/bin/env bash
echo "[INFO] REBUILD STARTED ON CHILD DIRECTORIES"
for dir in */ ; do
    echo "[INFO] INJECTING REBUILD INTO $dir"
    cp rebuild.injector $dir/rebuild.sh
    chmod 0755 $dir/rebuild.sh
    cd $dir
    POM=$(sed '$d' pom.xml)
    echo "$POM" > pom.xml.new
    cat ../pom.injector >> pom.xml.new
    echo "[INFO] BUILDING $dir"
    mv pom.xml pom.xml.org
    cp pom.xml.new pom.xml
    ./rebuild.sh
    cp pom.xml.org pom.xml
    rm pom.xml.org rebuild.sh pom.xml.new
done
echo "[INFO] COMPLETED REBUILD"
