#! /usr/bin/perl -w
use locale;
use Storable;
use List::Util qw/sum/;
use Array::Utils qw/unique/;
use Benchmark;

$mode = 'fused';
$src = shift @ARGV; # 'np'|'fict'
$width = shift @ARGV; # left & right context width in wordforms

open (FILEIN, "<dirlist_$src.txt");
while (<FILEIN>) { chomp; s/(\/)data(\/)/$1$mode$2/g; push @dirlist, $_; }
close (FILEIN);

open (DEBUG, ">debug-vsm.txt");
foreach $current_dir (@dirlist)
	{
	print STDOUT "Working on $current_dir...\n";
	$start = new Benchmark;
	opendir (INPUT, $current_dir);
	while (defined ($handle = readdir(INPUT)))
		{
		unless ($handle =~ /^\.{1,2}$/)
			{
			# print STDOUT "Processing $handle...\n";
			$inhandle = $current_dir . $handle;
			@lemmata = ();
			open (ITEM, "<$inhandle");
			while (<ITEM>)
				{
				chomp;
				($wform, $lemma, $gram) = split (/\t/, $_);
				undef($wform);
				undef($gram);
				if ($lemma)
					{
					# ++$freq{$lemma};
					push @lemmata, $lemma;
					# push @{$grams{$lemma}}, $gram;
					}
				else { print DEBUG "$inhandle\t$_\n"; }
				}
			foreach $first_index (0..$#lemmata-1)
				{
				if ($first_index >= $#lemmata - $width) { $end = $#lemmata; }
				else { $end = $first_index + $width; }
				foreach $second_index ($first_index+1..$end)
					{
					++$globalhash{$lemmata[$first_index]}{$lemmata[$second_index]};
					++$globalhash{$lemmata[$second_index]}{$lemmata[$first_index]};
					}
				}
			close (ITEM);
			}
		}
	closedir(INPUT);
	$end = new Benchmark;
	$diff = timediff($end, $start);
	print timestr($diff, 'all') . "\n";
	}
close (DEBUG);

print "Serializing...\n";
$start = new Benchmark;
store \%globalhash, 'vsm-' . $src . '-' . $width . '.dat';
$end = new Benchmark;
$diff = timediff($end, $start);
print timestr($diff, 'all') . "\n";

=pod
@basis = keys %freq;
open (FILEOUT, ">vsm-freq.txt");
foreach (@basis) { print FILEOUT $_ . "\t" . $freq{$_} . "\t" . join (" ", unique(@{$grams{$_}})) . "\n"; }
close (FILEOUT);
=cut

print STDOUT "Complete!\n";

######################

=pod # a bit slower than the Array::Utils subroutine
sub unique
	{
	my %seen = ();
	foreach (@_) { ++$seen{$_}; }
	return keys %seen;
	}
=cut