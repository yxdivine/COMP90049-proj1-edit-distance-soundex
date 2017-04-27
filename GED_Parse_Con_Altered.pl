#!/usr/bin/perl -w
use strict;
use threads;
use threads::shared;
use List::Util qw[min max];
use Data::Dumper;
my $path = "D://Komodo Workspace//";
my $namesfile = $path."names.txt";
my $trainfile = $path."train.txt";
my $output = $path."output_rep.txt";
my $start = time();
#replacing matrix
my %rmat = ("iy"=>0.6,"ae"=>0.6,"ao"=>0.6,"au"=>0.4,
            "ck"=>0.3,"dt"=>0.3,"ov"=>0.3,
            "gq"=>0,"uv"=>0,"kx"=>0
            );

sub match{
    my @duo = @_;
    my $str = join("",sort(@duo));
    if(exists($rmat{$str})){
        return $rmat{$str};
    }elsif($duo[0] eq $duo[1]){
        return 2;
    }else{
        return -1;
    }
}

sub GED{
    my($s1,$s2) = @_;
    my $dist;
    my @str1 = split("",$s1);
    my @str2 = split("",$s2);
    my %matrix = ();
    my @init;
    for(my $i = 0; $i<=scalar(@str1);$i++){
        $matrix{"0_$i"} = -$i;
    }
    for(my $i = 0; $i<=scalar(@str2);$i++){
        $matrix{$i."_0"} = -$i;
    }
    #[m,i,d,r] = [(m),-1,-1,(r)]
    for(my $i = 1; $i<=scalar(@str1);$i++){#row
        for(my $j = 1; $j<=scalar(@str2);$j++){#column
            my $match = match($str1[$i-1],$str2[$j-1]);
            my $temp = max($matrix{$j."_".($i-1)} - 1,
                           $matrix{($j-1)."_".$i} - 1,
                           $matrix{($j-1)."_".($i-1)}+ $match);
            $matrix{$j."_$i"} = $temp;
        }
    }
    $dist = $matrix{scalar(@str2)."_".scalar(@str1)};
    #for(my $j = 0;$j<=scalar(@str2);$j++){
    #    for(my $i = 0;$i<=scalar(@str1);$i++){
    #        print $matrix{$j."_$i"}."\t";
    #    }
    #    print "\n";
    #}
    #print $dist;
    %matrix = ();
    return $dist;
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

#(persian name => @(best matches))
my %fullHash;
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
    #$fullHash{$persname} = \%matches;
    print OUT "$persname\t$latname\t$bestmatch\n".join("\t",keys(%matches))."\n";
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
    if($count eq 10){#limit the number of threads
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