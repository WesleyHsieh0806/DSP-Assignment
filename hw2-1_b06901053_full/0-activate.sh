#!/bin/bash +v

export KALDI_REP_PATH="/opt/kaldi"

if [ ! -v KALDI_BIN_PATH ]
then
	export KALDI_BIN_PATH="$KALDI_REP_PATH/src/bin:$KALDI_REP_PATH/src/gmmbin:$KALDI_REP_PATH/src/featbin:$KALDI_REP_PATH/src/fstbin:$KALDI_REP_PATH/tools/openfst-1.6.7/bin"
	export PATH="$KALDI_BIN_PATH:$PATH"
	export PS1="(kaldi) $PS1"
fi

deactivate() {
	export PATH=${PATH#$(echo $KALDI_BIN_PATH):}
	export PS1=${PS1#(kaldi) }
	unset KALDI_REP_PATH
	unset KALDI_BIN_PATH
	unset -f deactivate
}
export -f deactivate
