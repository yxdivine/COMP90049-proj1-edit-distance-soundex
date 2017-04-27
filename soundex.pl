#!/usr/bin/perl -w
use strict;
use threads;
use threads::shared;
use Data::Dumper;
use Text::Soundex;


my $path = "D://Komodo Workspace//";
my $namesfile = $path."names.txt";
my $trainfile = $path."train.txt";
my $output = $path."outputsoundex.txt";

sub trim{
    my $line = shift @_;
    $line=~s/^\s+//;
    $line=~s/\s+$//;
    return $line;
}
open (TRAIN,$trainfile) or die $!;
open (OUT,">",$output) or die $!;

my @names;
my %nameHash; #(soundex=>@(corresponding names))
#share(@names);
#share(%nameHash);

sub getSoundex{
    my $persname = shift @_;
    my $soundex = soundex($persname);
    $soundex =~ s/0//g;
    
    return $soundex;
}

sub loadNames{
    open (NAME,$namesfile) or die $!;
    
    while(my $line = <NAME>){
        $line = trim($line);
        #$nameHash{$line} = 1;
        my $soundex = getSoundex($line);
        push(@{$nameHash{$soundex}},$line);
    }
    close NAME;
}

loadNames();


my $count = 0;
my $matchcount = 0;
my $returned = 0;
my $firstmatch = 0;
my $noresult = 0;
my $guessed = 0;
while(my $line = <TRAIN>){
    $count++;
    $line = trim($line);
    #get the persian name - Latin name pair
    my ($perName,$latName) = split("\t",$line);
    $perName = lc(trim($perName));
    $latName = lc(trim($latName));
    
    my $soundex = getSoundex($perName);
    
    print OUT "$perName\t$latName\t$soundex\n";
    if(($nameHash{$soundex})){
        foreach my $m(@{$nameHash{$soundex}}){
            if($m eq $latName){
                $matchcount++;
                if($m eq ${$nameHash{$soundex}}[0]){
                    $firstmatch++;
                }
                $guessed += scalar(@{$nameHash{$soundex}});
                last;
            }
        }
        print OUT join("\t",@{$nameHash{$soundex}})."\n";
        $returned++;
    }else{
        $noresult++;
        print OUT "NO MATCHING RESULT\n";
    }
}
print OUT "$count parsed. $returned returned a result, $firstmatch returned accurately, $matchcount returned correctly, $noresult has no return value.\n";
print OUT "total:\t$count\nreturned:\t$returned\naccurate:\t$firstmatch\ncorrect:\t$matchcount\nfail:\t$noresult\nguess:\t$guessed\n";




#print OUT Dumper(%nameHash);


