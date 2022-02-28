#!/bin/bash

DT=$(date +%Y-%m-%d-%H-%M)
DIR=.bak
FILE="$DIR/$DT.tgz"
FILE_EXCLUDE=exclude.tag
mkdir $DIR -p

touch .bak/$FILE_EXCLUDE
touch tutorial/build/$FILE_EXCLUDE

tar -zcvf $FILE \
  --exclude-tag-all=$FILE_EXCLUDE \
  .
