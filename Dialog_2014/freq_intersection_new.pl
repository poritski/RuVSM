#! /usr/bin/perl -w
use locale;
use Array::Utils qw/intersect/;

$src = shift @ARGV; # 'lts2'|'lts3'|'lts3b'|'l22'|'l33'|'t22'|'t22l33'|'t4spec'
$eqpos = shift @ARGV; # 0|1
$freq_handling = shift @ARGV; # 'sum'|'max'

open (FILEIN, "<vsm-cfreq-" . $src . "semcor-" . $eqpos . "-" . $freq_handling . ".txt");
while (<FILEIN>)
	{
	chomp;
	($w, $f) = split (/\t/, $_);
	if ($f > 0) { ++$semcor{$w}; }
	}
close (FILEIN);

open (FILEIN, "<vsm-freq-full.txt");
while (<FILEIN>)
	{
	chomp;
	($w, $f) = split (/\t/, $_);
	++$full{$w};
	}
close (FILEIN);

@a = keys %semcor;
@b = keys %full;
@basis = intersect(@a, @b);

open (FILEOUT, ">common_basis-" . join ("-", ($src, $eqpos, $freq_handling)) . ".txt");
foreach (@basis) { print FILEOUT "$_\n"; }
close (FILEOUT);
