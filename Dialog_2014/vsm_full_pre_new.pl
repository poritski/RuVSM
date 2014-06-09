#! /usr/bin/perl -w
use locale;
use Storable;

$src = shift @ARGV; # 'lts2'|'lts3'|'lts3b'|'l22'|'l33'|'t22'|'t22l33'|'t4spec'
$eqpos = shift @ARGV; # 0|1
$freq_handling = shift @ARGV; # 'sum'|'max'

open (FILEIN, "<frequency_$src.csv");
while (<FILEIN>)
	{
	chomp;
	($word, $pos_word, $context, $pos_context, $f, $uw_word, $f_uww_wn, $f_uww_proper, $uw_context, $f_uwc_wn, $f_uwc_proper) = split (/\t/, $_);
	if ($eqpos == 1) { $condition = $pos_word ne ""; }
	elsif ($eqpos == 0) { $condition = $pos_word eq ""; }
	if ($condition)
		{
		++$eval{$word . "\t" . $uw_word};
		$wfreq{$uw_word} = $f_uww_proper;
		if ($freq_handling eq "sum")
			{
			$globalhash{$uw_word}{$context} += $f;
			unless ($seen{$context}{$uw_context}) { $cfreq{$context} += $f_uwc_proper; }
			}
		elsif ($freq_handling eq "max")
			{
			if (!$globalhash{$uw_word}{$context} || $globalhash{$uw_word}{$context} < $f) { $globalhash{$uw_word}{$context} = $f; }
			if (!$cfreq{$context} || $cfreq{$context} < $f_uwc_proper) { $cfreq{$context} = $f_uwc_proper; }
			}
		++$seen{$context}{$uw_context};
		}
	}
close (FILEIN);

open (FILEOUT, ">vsm-wfreq-" . $src . "semcor-" . $eqpos . "-" . $freq_handling . ".txt");
foreach (keys %wfreq) { print FILEOUT "$_\t$wfreq{$_}\n"; }
close (FILEOUT);

open (FILEOUT, ">vsm-cfreq-" . $src . "semcor-" . $eqpos . "-" . $freq_handling . ".txt");
foreach (keys %cfreq) { print FILEOUT "$_\t$cfreq{$_}\n"; }
close (FILEOUT);

@evalpairs = keys %eval;
open (FILEOUT, ">EVAL_" . $src . "_$eqpos.txt");
foreach (@evalpairs) { print FILEOUT $_ . "\n"; }
close (FILEOUT);

print STDOUT "Serializing...\n";
store \%globalhash, "vsm-" . $src . "semcor-" . $eqpos . "-" . $freq_handling . ".dat";
print STDOUT "Complete!\n";
