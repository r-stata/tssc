*! version 2.4.0 01dec2016 daniel klein

pr xls2dta
	vers 12
	if (c(stata_version) > 12) {
		vers 12.1
	}
	
	if !(c(excelsupport)) {
		di as txt "xls2dta is not supported on this platform"
		e 0
			/* done */
	}
	
	tempname xh rr
	_ret hold `rr'
	_ret res `rr' , h
	.`xh' = .xls2dta_work.new
	_ret res `rr'
	.`xh'.main dump `0'
end
e

2.4.0	01dec2016	xls2dta_work 1.3.0
2.3.0	19apr2016	xls2dta_work 1.2.0
2.2.0	08dec2015	xls2dta_work 1.1.0
					version 12 declared
2.1.1	15oct2015	xls2dta_work 1.0.1
2.1.0	06oct2015 	fix bug: sheets() would not expand numlist
					fix bug: sheets() malfunctioned "inverted"
					new suboption sheets(<...> , not)
					new option dta() selects s(dta_#)
					suboption save( , emptyok) saves empty file
					add full unicode support
					combine no longer clears s(dta_#)
					rewrite code as class program xls2dta_work
2.0.0	05jun2015	new syntax conceptualized as prefix command
					old syntax still works
					available commands 
						-import excel- 
						-append- 
						-merge- 
						-joinby-
						-xeq-
						-do- | -run-
						-erase-
					return filenames in s()
					old syntax still returns r() aditionally
					-retrun- option returns r() (not documented)
					new option -generate- marks source of file
					new option -recursive- (requires -filelist-)
					option -save- has suboptions
					options -replace- and -mkdir- now suboptions
					other -save- options may be specified
					option -allsheets()- renamed -sheets()-
					option -allsheets- synonym for -sheets(*)-
					code with much more subroutines
					save tempfiles first, then -copy- as .dta
1.2.0	15oct2012	uppercase <filename> implies -respectcase-
					-respectcase- is documented
					-using- is now optional (default is c(pwd))
1.1.0	14sep2012	pattern/s allowed in -allsheets- (-strmatch-)
					new option -mkdir-
					new option -respectcase- (not documented)
					do not terminate if Excel sheet is empty
1.0.0	08sep2012	based on -impxlsfolder- (1.0.0 and 1.0.1)
