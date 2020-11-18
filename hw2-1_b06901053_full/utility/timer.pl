#!/usr/bin/perl

my $sec = $ARGV[0];
my $hr = int($sec/3600);
$sec = $sec % 3600;
my $min = int($sec/60);
$sec = $sec % 60;

printf("%02d hours %02d mins %02d secs\n", $hr, $min, $sec);
