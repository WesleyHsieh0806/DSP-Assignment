#!/bin/bash

phoneset=material/phoneset.txt
roots=material/roots.txt
lexicon=material/lexicon.txt

proto=material/topo.proto
train_text=material/train.text
test_text=material/test.text

echo "Data : "
echo "    phone set = $phoneset"
echo "    phone tree root = $roots"
echo "    lexicon = $lexicon"
echo "    language model for decoding = $lm"
echo "    phone HMM prototype = $proto"
echo "    training set label (text) = $train_text"
echo "    developing set label (text) = $dev_text"
echo "    testing set label (text) = $test_text"
echo ""

mkdir -p train
mkdir -p decode

cat $phoneset | awk 'BEGIN{ print "<eps> 0"; } { printf("%s %d\n", $1, NR); }' \
  > train/phones.txt

ln -sf ../train/phones.txt decode/phones.txt

ln -sf ../$phoneset train/phoneset.txt

utility/silphones.pl train/phones.txt sil \
  train/silphones.csl train/nonsilphones.csl

cat material/phoneset.txt | utility/remove.silence.pl sil \
  > train/phonecluster.txt

ln -sf ../$roots train/roots.txt

cat $lexicon | grep -v "<s>\|</s>" \
  > train/lexicon.txt

cat train/lexicon.txt | awk '{print $1}' | sort | uniq \
  | awk 'BEGIN{print "<eps> 0";} {printf("%s %d\n", $1, NR);} END{printf("#0 %d\n", NR+1);} ' \
  > train/words.txt

utility/make_lexicon_fst.pl train/lexicon.txt 0.5 sil \
  | fstcompile --isymbols=train/phones.txt \
    --osymbols=train/words.txt --keep_isymbols=false \
    --keep_osymbols=false \
  | fstarcsort --sort_type=olabel > train/L.fst

silphonelist=`cat train/silphones.csl | sed 's/:/ /g'`
nonsilphonelist=`cat train/nonsilphones.csl | sed 's/:/ /g'`
sed -e "s:NONSILENCEPHONES:$nonsilphonelist:" \
  -e "s:SILENCEPHONES:$silphonelist:" $proto > train/topo

cat $train_text | utility/sym2int.pl --ignore-first-field train/words.txt > train/train.int

ln -sf ../$lexicon decode/lexicon.txt

cat $test_text | python utility/word2char.py > decode/test.text

cat decode/test.text | cut -d ' ' -f 1 > decode/test.list

sec=$SECONDS

echo "Execution time for whole script = `utility/timer.pl $sec`"
echo ""
