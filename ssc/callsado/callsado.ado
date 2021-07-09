*! version 1.0.4 16apr2011 Daniel Klein, Matthew White

pr callsado ,rclass
	vers 9.2
	
	syntax anything(id = "filename" name = filename) /*
	*/ [, Path(passthru) SYSdir(str) EXTension(str) /*
	*/ DIsplay(int 100000) /* undocumented
	*/ ]
	
	* check file exists and strip name
	qui findfile `filename' ,`path'
	mata : st_local("usernam", pathrmsuffix(st_local("filename")))
	loc filename `r(fn)'
	
	* check options
	if (`"`sysdir'"' == "") loc sysdir PLUS PERSONAL
	if (`"`extension'"' == "") loc extension .ado
	
	* get list of all ados
	loc pwd `"`c(pwd)'"'
	foreach pth of loc sysdir {
		loc dirct : sysdir `pth'
		cap cd `"`dirct'"'
		if !(_rc) {
			loc anyado : dir `"`dirct'"' file "*`extension'"
			loc anyado : subinstr loc anyado "`extension'" "" ,all
			loc adolst `adolst' `anyado'
			
			* get ados from subdirectories
			loc subdir : dir `"`dirct'"' dir "*"	
			foreach subdirct of loc subdir {
				loc anyado : /*
				*/ dir `"`dirct'`subdirct'"' file "*`extension'"
				loc anyado : subinstr loc anyado "`extension'" "" ,all
				loc adolst `adolst' `anyado'
			}
		}
		else di as txt `"(note: directory `dirct' not found)"'
	}
	qui cd `"`pwd'"'
	
	loc adolst : list adolst - usernam
	if ("`adolst'" == "") {
		di as txt "no `extension' files found"
		e 0 // done
	}
	
	* create tempfile
	tempfile tmp tmp1
	filef `"`filename'"' `"`tmp1'"' ,f(\t) t(" ")
	filef `"`tmp1'"' `"`tmp'"' ,f(\LQ) t("{c 96}")
	qui filef `"`tmp'"' `"`tmp1'"' ,f(\RQ) t("{c 39}") r
	qui filef `"`tmp1'"' `"`tmp'"' ,f(\$) t("{c 36}") r
	
	* search for occurrences of ados in code
	loc called
	tempname fh
	loc i 0
	file open `fh' using `tmp' ,r
	file r `fh' line
	loc ++i
	while !r(eof) {
		if !mod(`i', `display') {
			di as txt %6s _n "`i'" " " `"`line'"'
		}
		gettoken comment : line ,p("* ")
		if inlist(`"`comment'"',"*", "//") {
			file r `fh' line
			loc ++i
			continue
		}
		loc lne : subinstr loc line "," " , "
		foreach cmd of loc adolst {
			if (`: list cmd in lne') {
				di as res _n "`cmd'"
				di as txt %6s "`i'" " " `"`line'"'
				if !(`: list cmd in called') {
					loc called `called' `cmd'
				}
				loc `cmd' ``cmd'' `i'
			}
		}
		file r `fh' line
		loc ++i
	}
	file close `fh'
	
	* nothing found
	if ("`called'" == "") {
		di as txt "no `extension' files in " as res `"`filename'"'
	}
	else {
		foreach c of loc called {
			ret loc `c' ``c''
		}
		ret loc called `called'
	}
end
e

1.0.4	16apr2012	no longer report filename as called ado
					r-class again (not documented)
1.0.3	04oct2011	Matthew White fixed a bug
					add option -path-
1.0.2	12sep2011	only filename.ext must be specified
					comment lines in filename are skipped
					changes to output
					no longer r-class
1.0.1	08sep2011	fixed bug caused by tab-stops in (a)do-files
					first version on SSC
1.0.0	08sep2011
