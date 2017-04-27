#!/usr/bin/perl -w
use strict;
use threads;
use threads::shared;
use List::Util qw[min max];
use Data::Dumper;
my $path = "D://Komodo Workspace//";
my $namesfile = $path."names.txt";
my $trainfile = $path."train.txt";
my $output = $path."out_rep_all.txt";
my $start = time();

sub trim{
    my $line = shift @_;
    $line=~s/^\s+//;
    $line=~s/\s+$//;
    return $line;
}

open (NAME,$namesfile) or die $!;
open (TRAIN,$trainfile) or die $!;
open (OUT,$output) or die $!;
my @names;
my %nameHash;


my $count = 0;
my @ts;
#while(my $line = <TRAIN>){
#    $line = trim($line);
#    #get the persian name - Latin name pair
#    my ($perName,$latName) = split("\t",$line);
#    $perName = lc(trim($perName));
#    $latName = lc(trim($latName));
#    
#    $nameHash{$perName} = $latName;
#}
$count = 0;
my $mcount = 0;
my $firstcount = 0;
my $guesscount = 0;
while(my $line = <OUT>){
    $line = trim($line);
    $count++;
    if($line=~/^([\w']+)\t(\w+)\t([\d.]+)$/){
        my ($word,$ans) = ($1,$2);
        $line = <OUT>;
        $line = trim ($line);
        my @matches = split("\t",$line);
        $guesscount += scalar(@matches);
        my $first = shift(@matches);
        if($first eq $ans){
            $firstcount++;
            $mcount++;
        }else{
            foreach my $match(@matches){
                if($match eq $ans){
                    $mcount++;
                    last;
                }
            }
        }
        
    }
}

print $count."\n";
print $mcount."\n";
print $firstcount."\n";;
print $guesscount;