#!/bin/bash

read -p "Are you sure you want to clean the directory? [y/N] " sure
if [[ "$sure" =~ ^[Yy]$ ]]; then
    dir=(decode exp train viterbi feat)
    set -x
    rm -rf ${dir[@]}
    rm -f log/*
else
    echo "Abort."
fi
