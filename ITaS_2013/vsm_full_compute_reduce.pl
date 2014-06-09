#! /usr/bin/perl -w

# VSM_COMPUTE.pl by Vladislav Poritski
# A quick-and-dirty script to compute semantic distances
# Rev. 2013-04-13

use locale;
use Storable;
use List::Util qw/sum min max/;
# use Benchmark;

# Parameters
$src = shift @ARGV; # 'np'|'fict'
$width = shift @ARGV; # left & right context width in wordforms
$threshold_len = shift @ARGV; # minimal length of a salient word
$threshold_fmin = shift @ARGV; # minimal frequency of a salient word
$threshold_fmax = shift @ARGV; # maximal frequency of a salient word
$metric = shift @ARGV; # 'cosine'|'jaccard'|'js'|'kl'
$reweighting = shift @ARGV; # 1|0
$smoothing_constant = shift @ARGV; # any number from [0, 1]; relevant only for KL divergence

# Reading the pre-computed VSM
$hashref = retrieve("vsm-$src-$width.dat") or die "No model found! (Your parameters require vsm-$src-$width.dat.)";
%globalhash = %{$hashref};

# Reading the list of word frequencies within the selected corpus
open (FILEIN, "<vsm-freq-$src.txt") or die "No frequency list found! (Your parameters require vsm-freq-$src.txt.)";
while (<FILEIN>)
	{
	chomp;
	@line = split (/\t/, $_);
	$freq{$line[0]} = $line[1];
	}
close (FILEIN);

# Reading the evaluation set of word pairs
%boolean_mapping = ("true" => 1, "false" => 0);
for $characteristics ("true", "false")
	{
	open (FILEIN, "<EVAL_$characteristics.txt") or die "No evaluation set found! (The '$characteristics' part is missing.)";
	while (<FILEIN>)
		{
		chomp;
		@line = split (/\t/, $_);
		$gold{$line[0]}{$line[1]} = $boolean_mapping{$characteristics};
		++$eval{$line[0]}{$line[1]};
		++$lookup{$line[0]};
		++$lookup{$line[1]};
		}
	close (FILEIN);
	}

# Establishing the reweighting constant
%pmi_constant = ('fict' => 9900000, 'np' => 7500000, 'full' => 17400000); # 

# PMI reweighting, if required
if ($reweighting == 1)
	{
	print STDOUT "PMI reweighting...\n";
	foreach $w (keys %globalhash)
		{
		foreach $c (keys %{$globalhash{$w}})
			{ $globalhash{$w}{$c} = log($pmi_constant{$src}) + log($globalhash{$w}{$c}/($freq{$w}*$freq{$c})); }
		}
	}

# Simplistic feature selection
%salient_hash = map { $_ => 1 }
	grep { /^([à-ÿ\-\|])+$/i && $freq{$_} >= $threshold_fmin && $freq{$_} <= $threshold_fmax && length($_) >= $threshold_len }
		keys %freq;
print STDOUT scalar (keys %salient_hash) . " basis elements satisfy all constraints.\n";
print STDOUT "Selecting features...\n";
@salient = keys %salient_hash;
for $a (@salient)
	{
	for $b (keys %{$globalhash{$a}})
		{ unless ($salient_hash{$b}) { delete($globalhash{$a}{$b}); } }
	}
undef(%salient_hash);

# Looking up the words we're going to compare pairwise
@lookup_indices = grep { $lookup{$salient[$_]} } (0..$#salient);

# Computing norms
if ($metric eq 'cosine') { @find_norm = @lookup_indices; }
else { @find_norm = (0..$#salient); }
print STDOUT "Computing norms...\n";
for $i (@find_norm)
	{
	if ($metric eq 'cosine' || $metric eq 'jaccard') # L2 norm
		{ $norm[$i] = sqrt (sum map { $_**2 } values %{$globalhash{$salient[$i]}}); }
	else # L1 norm
		{ $norm[$i] = sum values %{$globalhash{$salient[$i]}}; }
	}

# Renormalization and add-constant smoothing, if required
if ($metric eq 'kl' || $metric eq 'js' || $metric eq 'jaccard')
	{
	print STDOUT "Renormalization and smoothing...\n";
	%renormalized = ();
	%smooth = ();
	$denom = 1 + scalar(@salient)*$smoothing_constant;
	foreach $i (0..$#salient)
		{
		foreach $c (keys %{$globalhash{$salient[$i]}})
			{
			$renormalized{$salient[$i]}{$c} = $globalhash{$salient[$i]}{$c}/$norm[$i];
			if ($metric eq 'kl')
				{ $smooth{$salient[$i]}{$c} = ($renormalized{$salient[$i]}{$c} + $smoothing_constant)/$denom; }
			}
		}
	}

# Computing similarities
print STDOUT "Computing similarities for the pairs being evaluated...\n";
open (FILEOUT, ">./res/vsm-" . join ("-", ($src, $width, $threshold_len, $threshold_fmin, $threshold_fmax, $metric, $reweighting, $smoothing_constant))  . ".txt");
for $i (grep { $eval{$salient[$_]} } @lookup_indices)
	{
	$a = $salient[$i];
	if ($metric eq "js") { @avec = grep { $globalhash{$_} } keys %{$renormalized{$a}}; }
	%seen = map { $_ => 1 } keys %{$globalhash{$a}};
	for $j (grep { $eval{$salient[$i]}{$salient[$_]} } @lookup_indices)
		{
		$b = $salient[$j];
		if ($metric eq "cosine") # slightly faster than Purandare & Pedersen
			{
			@actual = grep { $seen{$_} } keys %{$globalhash{$b}};
			$dot = sum map
				{ $globalhash{$a}{$_} * $globalhash{$b}{$_} }
					grep { $seen{$_} } keys %{$globalhash{$b}};
			if ($dot) { $answer = $dot / ($norm[$i] * $norm[$j]); }
			else { $answer = 0; }
			}
		elsif ($metric eq "jaccard") # fast enough
			{
			@actual = grep { $seen{$_} } keys %{$globalhash{$b}};
			$j_num = sum map
				{ min ($renormalized{$a}{$_}, $renormalized{$b}{$_}) }
					@actual;
			unless ($j_num) { $answer = 0; goto OUTPUT; } # ugly but efficient
			$j_denom = sum map
				{ max ($renormalized{$a}{$_}, $renormalized{$b}{$_}) }
					@actual;
			$answer = $j_num / $j_denom;
			}
		elsif ($metric eq "kl") # rather slow, but this might be inherent
			{
			%union = map { $_ => 1 } (keys %{$globalhash{$a}}, keys %{$globalhash{$b}});
			$kl_ij = sum map
				{
				if ($smooth{$a}{$_} && $smooth{$b}{$_}) { log($smooth{$a}{$_}/$smooth{$b}{$_})*$smooth{$a}{$_}; }
				elsif ($smooth{$a}{$_}) { log($smooth{$a}{$_}/$smoothing_constant)*$smooth{$a}{$_}; }
				else { log($smoothing_constant/$smooth{$b}{$_})*$smoothing_constant; }
				}
				keys %union;
			$kl_ji = sum map
				{
				if ($smooth{$a}{$_} && $smooth{$b}{$_}) { log($smooth{$b}{$_}/$smooth{$a}{$_})*$smooth{$b}{$_}; }
				elsif ($smooth{$b}{$_}) { log($smooth{$b}{$_}/$smoothing_constant)*$smooth{$b}{$_}; }
				else { log($smoothing_constant/$smooth{$a}{$_})*$smoothing_constant; }
				}
				keys %union;
			$answer = ($kl_ij + $kl_ji)/2;
			}
		elsif ($metric eq "js") # rather slow, but this might be inherent
			{
			%avg1 = map {
					if ($renormalized{$b}{$_}) { $_ => ($renormalized{$a}{$_} + $renormalized{$b}{$_})/2; }
					else { $_ => $renormalized{$a}{$_}/2; }
					} @avec;
			%avg2 = map {
					if ($renormalized{$a}{$_}) { $_ => ($renormalized{$a}{$_} + $renormalized{$b}{$_})/2; }
					else { $_ => $renormalized{$b}{$_}/2; }
					} grep { $globalhash{$_} } keys %{$renormalized{$b}};
			$p_to_avg = sum map { log($renormalized{$a}{$_}/$avg1{$_})*$renormalized{$a}{$_} } keys %avg1;
			$q_to_avg = sum map { log($renormalized{$b}{$_}/$avg2{$_})*$renormalized{$b}{$_} } keys %avg2;
			$answer = ($p_to_avg + $q_to_avg)/2;
			}
		OUTPUT:
		print FILEOUT join ("\t", ($a, $b, $answer, $gold{$a}{$b})) . "\n";
		}
	}
close (FILEOUT);

print STDOUT "Complete!\n";
