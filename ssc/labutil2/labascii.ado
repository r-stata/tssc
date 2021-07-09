*! version 1.0.0 06dec2011 Daniel Klein

pr labascii ,rclass
	vers 9.2

	syntax [anything(name = do)] using/ /*
	*/ [ , /*
	*/ MODIFY /*
	*/ Parse(passthru) /*
	*/ From(str asis) To(str asis) /*
	*/ SKip(numlist int > 0) /*
	*/ STArt(integer 0) STOp(integer 0) /*
	*/ REPLACE noDEFine /*
	*/ ]
	
	* fix filenames and check existence
	if !(strpos(`"`using'"', ".")) loc using `"`using'.txt"'
	conf f `"`using'"'
		
		// dofile
	if (`"`do'"' != "") {
		loc do : subinstr loc do `"""' "" ,all
		if !(strpos("`do'", ".")) loc do "`do'.do"
		
			// extract directory from filespec
		loc tmp = reverse("`do'")
		gettoken df pth : tmp ,p(/\)
		if ("`pth'" != "") {
			loc pth = reverse("`pth'")
			loc pwd `"`c(pwd)'"'
			cap cd "`pth'"
			if _rc {
				di as err "`pth' not found"
				e 601
			}
			else qui cd `"`pwd'"'
		}
		if (strlen("`df'") == 3) {
			di as err "{it:dofile-name} expected"
			e 198
		}
		cap conf f "`do'"
		if !(_rc) & ("`replace'" == "") {
			di as err "file `do' already exists"
			e 602			
		}
	}
	
	* check options
	if ("`do'" == "") {
		foreach x in replace define {
			if ("``x''" != "") {
				di as err "option ``x'' not allowed"
				e 198
			}
		}
	}
		
	foreach x in start stop {
		if (``x'' < 0) {
			di as err "option `x' must be positive"
			e 198
		}
	}
	if (`stop') & ((`stop' - `start') < 0) {
		di as err "invalid options start and stop: "/*
		*/ "start should be lower than stop"
		e 198
	}
	
	if (`"`parse'"' != "") {
		gettoken dmp chrs : parse ,p("(")
		gettoken chrs : chrs ,m(par)
		token `macval(chrs)' ,`parse'
		loc nchrs 0
		while (`"`1'"' != "") {
			loc chr`++nchrs' "`1'"
			ma s
		}
	}
	
	loc nfrom : word count `from'
	loc nto : word count `to'
	if (`nto') & !(`nfrom') {
		di as err "option to not allowed"
		e 198
	}
	if (`nfrom') {
		if !inlist(`nto', 0, 1, `nfrom') {
			di as err "invalid to: wrong number of strings"
			e 198
		}
	}
		
	if ("`skip'" != "") {
		loc nskl 1
		loc nsk : word count `skip'
		if (`nsk' <= 249) {
			loc skl : subinstr loc skip " " ", " ,all
			loc skl , `skl'
		}
		else {
			loc i 0
			forv j = 1/`nsk' {
				if (`++i' > 249) {
					loc ++nskl
					loc i 1
				}
				loc skl`nskl' `skl`nskl'', `: word `j' of `skip''
			}
		}
	}
	
	* set tempfiles and names
	tempfile tmpf0 tmpf1 tmpdo
	tempname fh dfh

	* clean using (leave original file unchanged)
	loc m 0
	loc n 1
		
		// remove tab stop
	filef `"`using'"' `tmpf`m'' ,f(\t) t(" ")
	
		// user specified from to
	if (`nfrom') {
		token `"`from'"'
		forv j = 1/`nfrom' {
			if (`nto' == `nfrom') loc t `"`: word `j' of `to''"'
			else loc t `"`to'"'
			loc mwas `m'
			qui filef `tmpf`m'' `tmpf`n'' ,f(`"``j''"') t(`"`t'"') r
			loc m `n'
			loc n `mwas'
		}
	}
	
	* open do-file (tempfile)
	qui file open `dfh' using `tmpdo' ,w
	file w `dfh' `"/* value labels from `using'"' _n
	file w `dfh' `"created `c(current_date)' `c(current_time)' */"' _n
	
	* open using
	file open `fh' using `tmpf`m'' ,r
	loc ln 0
	
	* skip to start
	if (`start') {
		forv j = 1/`--start' {
			file r `fh' dmp
			if r(eof) {
				di as err "option start invalid: "	/*
				*/ `"`using' only has `j' `= plural(`ln', "line")'"'
				e 698
			}
			loc ++ln
		}
	}
	
	* extract value labels
	loc flbl 1
	file r `fh' line
	while !r(eof) {
		if (`ln' > `start') file r `fh' line
		loc ++ln
		if (`stop') & (`ln' > `stop') continue ,br
		
			// skip empty lines
		mata : st_local("line", strltrim(st_local("line")))
		if (`"`macval(line)'"' == "") continue
		
			// skip user specified lines
		loc skp 0
		if ("`skip'" != "") {
			forv j = 1/`nskl' {
				if inlist(`ln'`skl') {
					loc skp 1
					continue ,br
				}
			}
		}
		if (`skp') continue
		
			// parse line
		token `"`macval(line)'"' ,`parse'
		loc 1 : list clean 1
		if (`"`macval(1)'"' == ".") loc 1 `1'`2'
		if (`"`macval(2)'"' == ".") {
			cap as `macval(3)' == int(`macval(3)')
			if !(_rc) continue
		}
		loc line : subinstr loc line `"`macval(1)'"' ""
		if (`"`parse'"' != "") {
			forv j = 1/`nchrs' {
				if (`"`macval(2)'"' == `"`macval(chr`j')'"') {
					loc line : subinstr loc line `"`macval(2)'"' ""
					continue ,br
				}
			}
		}
		loc line : list clean line
		cap conf name `macval(1)'
		if !(_rc) {
			if (`"`1'"' != "`lblnam'") loc newlbl 1
			loc lblnam `1'
			continue
		}
		cap conf e `lblnam'
		if _rc continue
		cap as `macval(1)' == int(`macval(1)')
		if _rc continue 
		if ("`1'" != ".") {
			if (`newlbl') {
				if !(`flbl') {
					if ("`modify'" != "") {
						file w `dfh' " /*" _n
						file w `dfh' "*/ ,modify" _n
					}
					else file w `dfh' _n
				}
				file w `dfh' _n
				file w `dfh' "label define `lblnam' /*" _n
				loc newlbl 0
			}
			else file w `dfh' " /*" _n
			if strpos(`"`macval(line)'"', "`") {
				file w `dfh' "*/"
				file w `dfh' _tab(2) `"`1' "`macval(line)'""'
			}
			else {
				file w `dfh' "*/"
				file w `dfh' _tab(2) `"`1' `"`macval(line)'"'"'
			}
			if !(`: list lblnam in lblnamlst') {
				loc lblnamlst `lblnamlst' `lblnam'
			}
			loc flbl 0
		}
		else {
			di as txt "(note: `lblnam' may not label .)"
		}
	}
	if !(`flbl') {
		if ("`modify'" != "") { 
			file w `dfh' " /*" _n
			file w `dfh' "*/ ,modify" _n
		}
		else file w `dfh' _n
	}
	
	* close the files
	file close `fh'
	file close `dfh' 
	
	* create labels
	if ("`define'" == "") {
		cap noi ru `tmpdo'
		if _rc {
			di as err "an error occurred defining value labels"
			e _rc
		}
	}
	
	* number of labels
	loc nl : word count `lblnamlst'
	di as txt "(note: `nl' value `= plural(`nl', "label")' " /*
	*/ `"found in `using')"'
	
	* save do-file
	if (`"`do'"' != "") & (`nl') {
		qui copy `tmpdo' `"`do'"' ,pub `replace'
		di as txt `"file `do' saved"'
	}
	
	ret loc labelnames `lblnamlst'
end
e

History

1.0.0	06dec2011	improved version of txtlabdef.ado
					better defaults and enhanced functionality
