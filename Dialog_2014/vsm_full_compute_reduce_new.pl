#! /usr/bin/perl -w
use locale;
use Storable;
use List::Util qw/sum min max/;

# Parameters
$src_main = 'full'; # we always use the complete benchmark corpus 
$width = shift @ARGV; # left & right context width in tokens
$metric = shift @ARGV; # only 'cosine' is available in this build
$reweighting = shift @ARGV; # 0|1
$src_semcor = shift @ARGV; # 'lts2'|'lts3'|'lts3b'|'l22'|'l33'|'t22'|'t22l33'|'t4spec'
$eqpos = shift @ARGV; # 0|1
$freq_handling = shift @ARGV; # 'sum'|'max'

# Reading the pre-computed VSMs
$hashref1 = retrieve("vsm-" . $src_main . "-" . $width . ".dat") or die "No base model found!";
%globalhash = %{$hashref1};
$hashref2 = retrieve("vsm-" . $src_semcor . "semcor-" . $eqpos . "-" . $freq_handling . ".dat") or die "No model for SEMCOR found!";
%semcor = %{$hashref2};

# Reading the common basis
open (FILEIN, "<common_basis-" . join ("-", ($src_semcor, $eqpos, $freq_handling)) . ".txt") or die "No common basis found!";
while (<FILEIN>) { chomp; ++$salient{$_}; }
close (FILEIN);

# Reading the frequency statistics
open (FILEIN, "<vsm-wfreq-" . $src_semcor . "semcor-" . $eqpos . "-" . $freq_handling . ".txt") or die "No wfreq found!";
while (<FILEIN>) { chomp; ($w, $f) = split (/\t/, $_); $wfreq{$w} = $f; }
close (FILEIN);

open (FILEIN, "<vsm-cfreq-" . $src_semcor . "semcor-" . $eqpos . "-" . $freq_handling . ".txt") or die "No cfreq found!";
while (<FILEIN>) { chomp; ($w, $f) = split (/\t/, $_); $cfreq{$w} = $f; }
close (FILEIN);

open (FILEIN, "<vsm-freq-" . $src_main . ".txt") or die "No freq-full found!";
while (<FILEIN>) { chomp; ($w, $f) = split (/\t/, $_); $freq{$w} = $f; }
close (FILEIN);

# Establishing the reweighting constants
%pmi_constant = ('full' => 17400000, 'semcor' => 1000000); # roughly, the corpus size in tokens

# Reading the evaluation set of word pairs
open (FILEIN, "<EVAL_" . $src_semcor . "_" . $eqpos . ".txt") or die "No evaluation set found!";
while (<FILEIN>)
	{
	chomp;
	@line = split (/\t/, $_);
	++$eval{$line[0]}{$line[1]};
	++$lookup_globalhash{$line[0]};
	++$lookup_semcor{$line[1]};
	}
close (FILEIN);

# Simplistic feature selection
print STDOUT "Selecting features...\n";
for $a (keys %lookup_globalhash)
	{
	for $b (keys %{$globalhash{$a}})
		{ unless ($salient{$b}) { delete($globalhash{$a}{$b}); } }
	}
for $a (keys %lookup_semcor)
	{
	for $b (keys %{$semcor{$a}})
		{ unless ($salient{$b}) { delete($semcor{$a}{$b}); } }
	}

# PMI reweighting, if required
if ($reweighting == 1)
	{
	print STDOUT "PMI reweighting...\n";
	for $a (keys %lookup_globalhash)
		{
		for $b (keys %{$globalhash{$a}})
			{ $globalhash{$a}{$b} = log($pmi_constant{'full'}) + log($globalhash{$a}{$b}/($freq{$a}*$freq{$b})); }
		}
	for $a (keys %lookup_semcor)
		{
		for $b (keys %{$semcor{$a}})
			{ $semcor{$a}{$b} = log($pmi_constant{'semcor'}) + log($semcor{$a}{$b}/($wfreq{$a}*$cfreq{$b})); }
		}
	}

# Computing norms
for $w (keys %lookup_globalhash)
	{ $norm{$w} = sqrt (sum map { $_**2 } values %{$globalhash{$w}}); }
for $w (keys %lookup_semcor)
	{ $norm{$w} = sqrt (sum map { $_**2 } values %{$semcor{$w}}); }

# Computing similarities
print STDOUT "Computing similarities for the pairs being evaluated...\n";
open (FILEOUT, ">res-" . join ("-", ($src_main, $width, $metric, $reweighting, $src_semcor, $eqpos, $freq_handling))  . ".txt");
for $a (keys %lookup_globalhash)
	{
	%seen = map { $_ => 1 } keys %{$globalhash{$a}};
	for $b (keys %{$eval{$a}})
		{
		if ($metric eq "cosine") # slightly faster than Purandare & Pedersen
			{
			@actual = grep { $seen{$_} } keys %{$semcor{$b}};
			$dot = sum map { $globalhash{$a}{$_} * $semcor{$b}{$_} } @actual;
			if ($dot) { $answer = $dot / ($norm{$a} * $norm{$b}); }
			else { $answer = 0; }
			}
		print FILEOUT join ("\t", ($a, $b, $answer)) . "\n";
		}
	}
close (FILEOUT);
print STDOUT "Complete!\n";
