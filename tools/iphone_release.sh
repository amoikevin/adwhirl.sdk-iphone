#!/usr/bin/bash

set -o errexit

if [ $# -lt 2 ]; then
  echo "Usage: $0 <version> <path to instructions file>"
  exit 1
fi

ver=$1
instr_file=$2

if [ ! -f $instr_file ]; then
  echo "Instruction file $instr_file not a file"
  exit 1
fi

dir=AdWhirlSDK_iPhone_$ver
rm -rf $dir
mkdir -p $dir
cp -r iphone/AdWhirl $dir/
cp -r iphone/AdWhirlSDK2_Sample $dir/
cp -r iphone/TouchJSON $dir/
cp iphone/Changelog.txt $dir/
cp iphone/README $dir/
cp $instr_file $dir/
zip -r $dir.zip $dir
