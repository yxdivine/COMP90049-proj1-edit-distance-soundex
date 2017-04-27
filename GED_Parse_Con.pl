#!/usr/bin/perl -w
use strict;
use threads;
use threads::shared;
use Text::Brew qw(distance);
use Data::Dumper;
my $path = "D://Komodo Workspace//";
my $namesfile = $path."names.txt";
my $trainfile = $path."train.txt";
my $output = $path."output.txt";
my $start = time();
sub GED{
    my($str1,$str2) = @_;
    #match,ins,del,subst
    my ($dist) = distance($str1,$str2,{-cost=>[0,1,1,2]});
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


share(@names);
share(%nameHash);
while(my $line = <NAME>){
    $line = trim($line);
    $nameHash{$line} = 1;
    push(@names,$line);
}
#@names = keys(%nameHash);

my %fullHash;#(persian name => @(best matches))
share(%fullHash);

sub calcGED{
    my $persname = shift @_;
    my $latname = shift @_;
    my %matches;
    my $bestmatch = -99;
    
    foreach my $name(@names){
        
        my $dist = GED($name,$persname);
        if($dist > $bestmatch){
            $bestmatch = $dist;
            my %t;
            %matches = %t;
            $matches{$name} = $dist;
        }elsif($dist eq $bestmatch){
            $matches{$name} = $dist;
        }
    }
    #$fullHash{$persname} = $bestmatch."\t".join("\t",keys(%matches));
    print OUT "$persname\t$latname\t$bestmatch\n".join("\t",keys(%matches))."\n";
    #$fullHash{$persname} = \%matches;
}
my $count = 0;
my @ts;
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
        $fullHash{$perName} = length($perName)."\t$perName";
    }else{
        my $t = threads->create(\&calcGED,$perName,$latName);
        #calcGED($perName);
        push (@ts,$t);
    }
    $count++;
    if($count eq 10){
        foreach my $t(@ts){
            $t->join();
        }
        $count = 0;
        my @t;
        @ts = @t;
        #exit(0);
    }
}
foreach my $t(@ts){
    $t->join();
}
print time() - $start;

#print OUT Dumper(%fullHash);