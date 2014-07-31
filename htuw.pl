use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my $inputDatei = "CSVExport.csv";
my $exportDatei = "Export.txt";

print "Einzulesende Datei: $inputDatei\n";
print "Ausgabedatei:       $exportDatei\n";

GetOptions ("in|i=s"  => \$inputDatei,
			"out|o=s" => \$exportDatei);
###########################################################
## Dateihandles öffnen                                    #
###########################################################			 
open(EXPORT, "$inputDatei") or die " Kann Exportdatei nicht öffnen: $!\n";
open(AUSGABE, ">$exportDatei") or die " Kann Ausgabedatei nicht öffnen: $!\n";

###########################################################
## Hilfsmethoden                                          #
###########################################################
sub verarbeiteDaten
{
	my %hash = ();
	while (my $line = <EXPORT>)
	{
		next if not defined($line);
		next if $line =~ /^.*;.*art;.*/;
		
		my ($tag, $start, $ende, $dauer) = verarbeiteZeile($line);
		my ($xtag, $monat, $jahr) = split (/\./, $tag);
		my $key = "$jahr$monat$xtag";
		
		$hash{$key} = {'tag' => $tag, 'dauer' => "00:00", 'pause' => "00:00", 'ende' => "00:00", 'start' => "24:00"}
			if not exists $hash{$key};
		
		$hash{$key}{start} 	= $start if vergleichZeit($start, $hash{$key}{start}) == 1;
		$hash{$key}{ende} 	= $ende  if vergleichZeit($hash{$key}{ende}, umwandlung($ende)) == 1;
		
		$hash{$key}{dauer} 	= addiereDauer($hash{$key}{dauer}, $dauer);
		
		my $gesDauer = berechneDauer($hash{$key}{start}, $hash{$key}{ende});
		$hash{$key}{pause}	= subDauer($gesDauer , $hash{$key}{dauer});
	}
	return \%hash;
}
sub umwandlung($)
{
	my $ende = shift;
	my ($sE, $mE) = split (":",$ende);
	
	$sE += 24 if ($sE < 4);
	return sprintf "%02d:%02d", $sE, $mE;
}
sub vergleichZeit($$)
{
	my ($zeit1, $zeit2) = @_;
	my ($sZeit1, $mZeit1) = split (":", $zeit1);
	my ($sZeit2, $mZeit2) = split (":", $zeit2);
	return ($sZeit1 < $sZeit2
		or ($sZeit1 == $sZeit2 and $mZeit1 < $mZeit2));
}
sub subDauer($$)
{
	my ($dauer1,$dauer2) = @_;
	my ($sDauer1, $mDauer1) = split (":", $dauer1);
	my ($sDauer2, $mDauer2) = split (":", $dauer2);
	my $sD = $sDauer1 - $sDauer2;
	my $mD = $mDauer1 - $mDauer2;
	if ($mD < 0)
	{
		$mD += 60;
		$sD -= 1;
	}
	if( $sD < 0)
	{
		$sD += 24;
	}
	return sprintf "%02d:%02d", $sD, $mD;
}
sub addiereDauer($$)
{
	my ($dauer1,$dauer2) = @_;
	my ($sDauer1, $mDauer1) = split (":", $dauer1);
	my ($sDauer2, $mDauer2) = split (":", $dauer2);
	my $sD = $sDauer1 + $sDauer2;
	my $mD = $mDauer1 + $mDauer2;
	if ($mD >= 60)
	{
		$mD -= 60;
		$sD +=1;
	}
	return sprintf "%02d:%02d", $sD, $mD;
}
sub verarbeiteZeile($)
{
	my $line = shift;
	my($job, $anfang, $beendet) = split (";", $line);
	my($Tag, $start) = split (" ",$anfang); 
	my $ende = (split (" ",$beendet))[1];
	return ($Tag, $start, $ende, berechneDauer($start, $ende));
}
sub berechneDauer($$)
{
	my ($start, $ende) = @_;
	my ($aStunde, $aMinute) = split (":", $start);
	my ($eStunde, $eMinute) = split (":", $ende);
	
	my $stunde = $eStunde - $aStunde;
	my $minute = $eMinute - $aMinute;
	if ($minute < 0)
	{
		$minute += 60;
		$stunde -= 1;
	}
	if( $stunde < 0)
	{
		$stunde += 24;
	}
	return sprintf "%02d:%02d", $stunde, $minute;
}
sub ergebnisAusgeben($$)
{
	my $hash = shift;
	my $fh = shift;

	print $fh "-" x45 . "\n";
	printf $fh "| %-10s | %-5s | %-5s | %-5s | %-5s |\n",
		"Tag", "Start", "Pause", " Ende", "Dauer";
	print $fh  "-" x45 . "\n";
	foreach my $key (sort keys %$hash)
	{
		printf $fh "| %-10s | %-5s | %-5s | %-5s | %-5s |\n",
			"$hash->{$key}{tag}", "$hash->{$key}{start}", "$hash->{$key}{pause}", "$hash->{$key}{ende}", "$hash->{$key}{dauer}";
	}
	print $fh  "-" x45 . "\n";
}
###########################################################
## Hauptprogramm                                          #
###########################################################
print "Lese Datei ein...";
my $hash = verarbeiteDaten();
ergebnisAusgeben($hash, *AUSGABE);
print "Fertig\n";
