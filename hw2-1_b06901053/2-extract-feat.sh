#!/bin/bash

cmvn_dir=exp/cmvn
path=feat
options="--use-energy=false"

echo "Acoustic features will be extracted in the following directory : "
echo "  $path"

mkdir -p $path
mkdir -p $cmvn_dir

echo "Extracting train set"
target=train
log=$path/$target.extract.log

compute-mfcc-feats --verbose=2 --sample-frequency=8000 $options scp:material/$target.wav.scp ark,t,scp:$path/$target.13.ark,$path/$target.13.scp 2> $log
add-deltas ark:$path/$target.13.ark ark:$path/$target.tmp.ark 2> $log
compute-cmvn-stats ark:$path/$target.tmp.ark ark:$path/$target.tmp.compute 2> $log
apply-cmvn ark:$path/$target.tmp.compute ark:$path/$target.tmp.ark ark,t,scp:$path/$target.39.cmvn.ark,$path/$target.39.cmvn.scp 2> $log

echo "Extracting test set"
target=test
log=$path/$target.extract.log

compute-mfcc-feats --verbose=2 --sample-frequency=8000 $options scp:material/$target.wav.scp ark,t,scp:$path/$target.13.ark,$path/$target.13.scp 2> $log
add-deltas ark:$path/$target.13.ark ark:$path/$target.tmp.ark 2>> $log
compute-cmvn-stats ark:$path/$target.tmp.ark ark:$path/$target.tmp.compute 2>> $log
apply-cmvn ark:$path/$target.tmp.compute ark:$path/$target.tmp.ark ark,t,scp:$path/$target.39.cmvn.ark,$path/$target.39.cmvn.scp 2>> $log

rm -rf feat/*13* feat/*tmp*

sec=$SECONDS
echo ""
echo "Execution time for whole script = `utility/timer.pl $sec`"
echo ""
