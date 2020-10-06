#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\[')
PROJECT=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.artifactId | grep -v '\[')
# Build first time
mvn clean verify -e -DskipTests artifact:buildinfo
JARFILES=$(find . -name '*.jar')
for file in $JARFILES; do
  mv $file /tmp
done
# Rebuild second time and compare builds
mvn clean verify -e -DskipTests artifact:buildinfo
NEWJARFILES=$(find . -name '*.jar')
for file in $NEWJARFILES; do
  filename=$(echo "$file" | sed 's|.*/||')
  # Strip out any filesystem disorder
  strip-nondeterminism /tmp/$filename
  strip-nondeterminism $file
  diffoscope /tmp/$filename $file
  exitCode=$?
  if [ "$exitCode" -gt "0" ]
  then
    echo "[FAILURE] Build was not reproducible check diffoscope output above."
    exit $exitCode
  fi
done
echo "[SUCCESS] Build has been verified to be reproducible."



