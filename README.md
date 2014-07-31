# Dokumentation #

## Hintergrund ##
Die App Hourstracker (http://hourstrackerapp.com/) dient der Zeiterfassung.
Die erfassten Zeiten können im CSV-Format exportiert werden. In der Export-
Datei sind alle Stempelzeiten aufgeführt, die in der App erfasst wurden. 
Da die Daten in dieser Datei nach Job eingetragen sind, lässt sich aus den 
Daten des Exports nicht direkt ermitteln, wie lange an einem Tag gearbeitet 
und wie lange Pause gemacht wurde.

## Ziel ##
Um dieses Problem zu lösen kann man diese Exportdateien mit diesem Perl-Skript
umwandeln und erhält eine Ausgabedatei in der je Tag Startzeit, Endzeit, 
Arbeitsstunden und Gesamtpausen hervorgehen. 

## Systemvoraussetzungen ##
* Installiertes Perl (z.B. http://strawberryperl.com/)
* Modul Getopt::Long (http://perldoc.perl.org/Getopt/Long.html)

## Verwendung ##
Das Programm kann durch einen Doppelklick auf die pl-Datei ausgeführt werden. 
Hierbei werden aber die Input- (CSVExport.csv) und 
Outputdatei (Export.txt) verwendet die im Programm vorgegeben sind.
Um diese Dateien selber auswählen zu können, führt man das Programm am besten 
in der Eingabeaufforderung aus. Dazu wechselt man in das Verzeichnis in welchem 
sich das Programm "htuw.pl" befindet (der Name "htuw" steht für HoursTracker Umwandlung).
Es lässt sich dann mit "perl uw.pl" aufruft und versteht folgende Parameter:

--in|-i  [dateiname]		wählt Inputdatei aus 
--out|-o [dateiname]		wählt Outputdatei aus

