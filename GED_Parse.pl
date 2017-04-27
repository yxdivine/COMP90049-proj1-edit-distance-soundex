#!/usr/bin/perl -w
use strict;

use Text::Brew qw(distance);
my $path = "D://Komodo Workspace//";
my $namesfile = $path."names.txt";
my $trainfile = $path."train.txt";
my $output = $path."output.txt";

sub GED{
    my($str1,$str2) = @_;
    my ($dist) = distance($str1,$str2,{-cost=>[-1,1,1,1]});
    return -$dist;
}

sub trim{
    my $line = shift @_;
    $line=~s/^\s+//;
    $line=~s/\s+$//;
    return $line;
}

open (NAME,$namesfile) or die $!;
open (TRAIN,$trainfile) or die $!;
open (OUT,">",$output) or die $!;
my @names;
my %nameHash;
while(my $line = <NAME>){
    $line = trim($line);
    $nameHash{$line} = 1;
}
@names = keys(%nameHash);


my $count = 0;
my $matchcount = 0;
while(my $line = <TRAIN>){
    $line = trim($line);
    #get the persian name - Latin name pair
    my ($perName,$latName) = split("\t",$line);
    $perName = lc(trim($perName));
    $latName = lc(trim($latName));
    
    my %matches;
    my $bestmatch = -99;
    #calculate Global edit distances
    if($perName eq $latName){#if there's exactly the same name
        $bestmatch = length($perName);
        %matches = ($perName => $bestmatch);
    }else{
        foreach my $name(@names){
            my $dist = GED($name,$perName);
            if($dist > $bestmatch){
                $bestmatch = $dist;
                my %t;
                %matches = %t;
                $matches{$name} = $dist;
            }elsif($dist eq $bestmatch){
                $matches{$name} = $dist;
            }
        }
    }
    #count all names
    $count++;
    if(exists($matches{$latName})){
        $matchcount++;
    }
    
    print OUT "$perName\t$latName\t$bestmatch\n";
    print OUT join("\t",keys(%matches))."\n";
    #if($count eq 20){
    #    print OUT "calculated:\t$count\tmatched:\t$matchcount\n";
    #    exit(0);
    #}
}
        print OUT "calculated:\t$count\tmatched:\t$matchcount\n";
