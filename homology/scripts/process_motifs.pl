#!/usr/bin/env perl

use strict;
use warnings;

# Function to reverse complement sequences
sub revcomp {
    my ($seq) = @_;
    $seq =~ tr/ACGTacgt/TGCAtgca/;
    return reverse $seq;}

# Function to get the lexicographically smallest cyclic permutation motif
sub cyclic_min {
    my ($motif) = @_;
    my $len = length($motif);
    my $min = $motif;

    for my $i (1 .. $len-1) {
        my $rot = substr($motif, $i) . substr($motif, 0, $i);
        $min = $rot if $rot lt $min;}
    return $min;}

my ($infile, $out_normal, $out_rev) = @ARGV;

open my $IN,  "<", $infile      or die $!;
open my $ON,  ">", $out_normal  or die $!;
open my $OR,  ">", $out_rev     or die $!;

while (<$IN>) {
    chomp;
    my @f = split /\t/;

    # normal
    # replaces motif with its smalllest cyclic permutation
    $f[4] = cyclic_min($f[4]);
    $f[9] = cyclic_min($f[9]);
    print $ON join("\t", @f), "\n";

    # revcomp target motif only
    # replaces reverse complement motif with its smallest cyclic permutation
    $f[4] = cyclic_min(revcomp($f[4]));
    print $OR join("\t", @f), "\n";}
