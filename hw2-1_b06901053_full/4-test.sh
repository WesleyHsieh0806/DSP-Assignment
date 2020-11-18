#!/bin/bash

srcdir=exp/mono
dir=viterbi/mono

lm=material/lm.arpa.txt
lex=decode/lexicon.txt
test_feat=feat/test.39.cmvn.ark


### parameters that you can modify
opt_acwt=0.25
test_beam=60.0
###

mkdir -p $dir
mkdir -p $dir/log

echo "Converting acoustic models to HTK format"
if [ ! -f $dir/final.mmf ] || [ ! -f $dir/tiedlist ]; then
  log=$dir/log/am.to.htk.log
  echo "    output -> $dir/final.mmf $dir/tiedlist"
  echo "    log -> $log"
  utility/vulcan-am-kaldi-to-htk --trans-mdl=$srcdir/final.mdl --tree=$srcdir/tree \
    --phonelist=train/phones.txt --htk-mmf=$dir/final.mmf --htk-tiedlist=$dir/tiedlist \
    2> $log
else
  echo "    $dir/final.mmf $dir/tiedlist exist , skipping ..."
fi

log=$dir/log/latgen.test.log
echo "Generating results for test set with acoustic weight = [ $opt_acwt ]"
echo "    output -> $dir/test.mlf"
echo "    log -> $log"
utility/Hybrid.HDecode.mod --trace=1 --beam=$test_beam \
  --am-weight=$opt_acwt --lm-weight=1.0 \
  --arpa-lm=$lm --mlf=$dir/test.mlf \
  --htk-mmf=$dir/final.mmf --htk-tiedlist=$dir/tiedlist \
  --lex=$lex --phonelist=train/phones.txt \
  --gmm-weight=1.0 --gmm-mdl=$srcdir/final.mdl --gmm-tree=$srcdir/tree \
  --feature="ark,s,cs:$test_feat" \
  2> $log

cat $dir/test.mlf \
  | utility/result.htk2kaldi.pl \
  | python utility/word2char.py \
  > $dir/test.rec
cat $dir/test.rec \
  | python utility/compute-acc.py decode/test.text \
  > $dir/test.acc
acc=`grep "overall accuracy" $dir/test.acc | awk '{ print $4 }'`
echo "    result -> $dir/test.rec"
echo "    accuracy -> [ $acc ] %"

sec=$SECONDS

echo ""
echo "Execution time for whole script = `utility/timer.pl $sec`"
echo ""
