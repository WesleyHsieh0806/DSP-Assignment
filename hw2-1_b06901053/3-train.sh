#!/bin/bash

dir=exp/mono
feat=feat/train.39.cmvn.ark

### parameters that you can modify
numiters=30                                   # Number of iterations of training
maxiterinc=25                                  # Last iter to increase #Gauss on.
numgauss=10                                   # Initial num-Gauss (must be more than #states=3*phones).
totgauss=3000                                    # Target #Gaussians.
incgauss=$[($totgauss-$numgauss)/$maxiterinc] # per-iter increment for #Gauss
realign_iters="1 2 3 4 5 10 15 20";
scale_opts="--transition-scale=1.0 --acoustic-scale=0.1 --self-loop-scale=0.1"
###

mkdir -p $dir
mkdir -p $dir/log
utility/sym2int.pl train/phones.txt train/phoneset.txt > $dir/phonesets.int
shared_phones_opt="--shared-phones=$dir/phonesets.int"
dim=`feat-to-dim --print-args=false "ark,s,cs:$feat" - 2> /dev/null`
# dim = 39 (dimension of MFCC)
echo "Initializing monophone system with dim = [ $dim ]"
if [ ! -f $dir/00.mdl ] || [ ! -f $dir/tree ]; then
  log=$dir/log/mono.init.log
  echo "    output -> $dir/00.mdl $dir/tree"
  echo "    log -> $log"
  gmm-init-mono --binary=false $shared_phones_opt \
    "--train-feats=ark:subset-feats --n=10 \"ark,s,cs:$feat\" ark:- |" train/topo $dim \
    $dir/00.mdl $dir/tree 2> $log
else
  echo "    $dir/00.mdl exists , skipping ..."
fi
echo "Compiling training graphs"
if [ ! -f $dir/log/done.graph ] || [ ! -f $dir/train.graph ]; then
  log=$dir/log/compile.graphs.log
  echo "    output -> $dir/train.graph"
  echo "    log -> $log"
  compile-train-graphs $dir/tree $dir/00.mdl train/L.fst ark:train/train.int \
    ark:$dir/train.graph 2> $log
  touch $dir/log/done.graph
else
  echo "    $dir/train.graph exists , skipping ..."
fi

iter=0
x=`printf "%02g" $iter`
y=`printf "%02g" $[$iter+1]`

echo "Iteration 00 :"
echo "    aligning training graphs equally"
if [ ! -f $dir/log/done.00.ali ] || [ ! -f $dir/00.ali ]; then
  log=$dir/log/align.00.log
  echo "        output -> $dir/00.ali"
  echo "        log -> $log"
  align-equal-compiled ark:$dir/train.graph "ark,s,cs:$feat" \
    ark:$dir/00.ali 2> $log
  touch $dir/log/done.00.ali
else
  echo "        $dir/00.ali exists , skipping ..."
fi
ln -sf 00.ali $dir/train.ali

echo "    accumulating GMM statistics"
if [ ! -f $dir/00.acc ]; then
  log=$dir/log/acc.00.log
  echo "        output -> $dir/00.acc"
  echo "        log -> $log"
  gmm-acc-stats-ali --binary=false $dir/00.mdl "ark,s,cs:$feat" \
    ark:$dir/train.ali $dir/00.acc 2> $log
else
  echo "        $dir/00.acc exists , skipping ..."
fi

echo "    updating GMM parameters and splitting to [ $numgauss ] gaussians"
if [ ! -f $dir/01.mdl ]; then
  log=$dir/log/update.00.log
  echo "        output -> $dir/01.mdl"
  echo "        log -> $log"
  gmm-est --binary=false --min-gaussian-occupancy=3 --mix-up=$numgauss \
    $dir/00.mdl $dir/00.acc $dir/01.mdl 2> $log
else
  echo "        $dir/01.mdl exists , skipping ..."
fi


iter=1
beam=6

while [ $iter -lt $numiters ]; do

	x=`printf "%02g" $iter`
	y=`printf "%02g" $[$iter+1]`

	echo "Iteration $x :"	
	# whether or not to realign the training sequence (obtain new state sequence)
	if echo $realign_iters | grep -w $iter > /dev/null ; then
		echo "    aligning training graphs by GMM model"
		if [ ! -f $dir/log/done.$x.ali ] || [ ! -f $dir/$x.ali ]; then
			log=$dir/log/align.$x.log
			echo "      output -> $dir/$x.ali"
			echo "      log -> $log"
			# train.graph: the FST(Finite State Tranducer) of this task
			gmm-align-compiled $scale_opts --beam=$beam --retry-beam=$[$beam*4] $dir/$x.mdl \
				ark:$dir/train.graph "ark,s,cs:$feat" \
				ark:$dir/$x.ali 2> $log
			touch $dir/log/done.$x.ali
		else
			echo "      $dir/$x.ali exists , skipping ..."
		fi
 		ln -sf $x.ali $dir/train.ali
	fi

	echo "    accumulating GMM statistics"
	# Obtain the alpha beta gamma epsilon and so on
	if [ ! -f $dir/$x.acc ]; then
 	 log=$dir/log/acc.$x.log
 	 echo "        output -> $dir/$x.acc"
 	 echo "        log -> $log"
	  #.ali align sequence of each file
 	 gmm-acc-stats-ali --binary=false $dir/$x.mdl "ark,s,cs:$feat" \
 	   ark:$dir/train.ali $dir/$x.acc 2> $log
	else
 		echo "        $dir/$x.acc exists , skipping ..."
	fi

	# Obtain new parameters A B pi
	echo "    updating GMM parameters and splitting to [ $numgauss ] gaussians"
	if [ ! -f $dir/$y.mdl ]; then
 		log=$dir/log/update.$x.log
 		echo "        output -> $dir/$y.mdl"
 		echo "        log -> $log"
	# x.mdl: the model from the last iteration
  	gmm-est --binary=false --min-gaussian-occupancy=3 --mix-up=$numgauss --write-occs=$dir/$y.occs \
    	$dir/$x.mdl $dir/$x.acc $dir/$y.mdl 2> $log
	else
  	echo "        $dir/$y.mdl exists , skipping ..."
	fi

	if [ $iter -le $maxiterinc ]; then
		numgauss=$[$numgauss+$incgauss]
	fi
	beam=10
	iter=$[$iter+1];

done
echo "Training completed:"
echo "     mdl = $dir/final.mdl"
echo "    occs = $dir/final.occs"
echo "    tree = $dir/tree"
cp -f $dir/$y.mdl $dir/final.mdl
cp -f $dir/$y.occs $dir/final.occs

echo "Cleaning redundant materials generated during training process"
rm -f $dir/phonesets.int
rm -f $dir/train.graph
ali=`readlink $dir/train.ali`
rm -f $dir/train.ali
cp -f $dir/$ali $dir/train.ali
rm -f $dir/00.*
iter=1
while [ $iter -le $numiters ]; do
  x=`printf "%02g" $iter`
  y=`printf "%02g" $[$iter+1]`
  rm -f $dir/$x.* $dir/$y.*
  iter=$[$iter+1];
done

sec=$SECONDS

echo ""
echo "Execution time for whole script = `utility/timer.pl $sec`"
echo ""

