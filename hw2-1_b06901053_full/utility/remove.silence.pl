#!/usr/bin/perl

while(<STDIN>) {
    chomp;
    my $sil = 0;
    for(my $i = 0; $i <= $#ARGV; $i++) {
        if($_ eq $ARGV[$i]) { $sil = 1; last; }
    }
    if($sil != 0) { next; }
    print "$_\n";
}
