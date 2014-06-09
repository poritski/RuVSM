#! /usr/bin/perl -w
use locale;
use List::Util qw/sum/;

opendir (INPUT, "./res/");
open (FILEOUT, ">EVALRES.txt");
while (defined ($handle = readdir(INPUT)))
	{
	if ($handle =~ /\.txt$/)
		{
		$inhandle = "./res/" . $handle;
		open (ITEM, "<$inhandle");
		while (<ITEM>)
			{
			chomp;
			($a, $b, $s, $g) = split (/\t/, $_);
			$score{$a . "\t" . $b} = $s;
			$gold{$a . "\t" . $b} = $g;
			}
		close (ITEM);
		if ($handle =~ /\-(js|kl)\-/) { @pairs = sort {$score{$a} <=> $score{$b}} keys %score; }
		else { @pairs = sort {$score{$b} <=> $score{$a}} keys %score; }
		$f_score = (sum map { $gold{$_} } @pairs[0..579])/580;
		$ranksum = sum grep { $gold{$pairs[$_]} == 1 } (0..$#pairs);
		print FILEOUT "$handle\t$f_score\t$ranksum\n";
		}
	}
closedir (INPUT);
close (FILEOUT);