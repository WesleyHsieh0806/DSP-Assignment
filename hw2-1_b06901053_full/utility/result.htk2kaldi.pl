#!/usr/bin/perl

use warnings;

while(<STDIN>) {
    chomp;
    if($_ eq "#!MLF!#") { next; }
    if($_ eq "\.") {
        printf STDOUT ("\n");
        next;
    }
    if($_ =~ /^\"/) {
        my $spos = rindex($_, "/");
        if($spos < 0) { $spos = index($_, "\"")+1; }
        else { $spos++; }
        my $epos = rindex($_, "\.");
        if($epos < 0) { $epos = rindex($_, "\""); }
        my $utt = substr($_, $spos, $epos-$spos);
        printf STDOUT ("%-20s", $utt); 
        next;
    }
    my @arr = split(/\s+/, $_);
    if($arr[2] eq "<s>") { next; }
    if($arr[2] eq "</s>") { next; }
    printf STDOUT (" %s", $arr[2]);
}

