*! version 1.0.9 20aug2012 Daniel Klein

pr labvalch3
	vers 9.2
	
	syntax [anything(name = namelist)] ///
	[ , Upper Lower PREfix(str) SUFFix(str) ///
	BEFore(str) AFTer(str) noEXClude ///
	SUBst(str asis) STRFCN(str asis) SYmbol(str) ///
	VALid(numlist int miss) INValid(numlist int miss) ///
	LSQ(str) VARiables ] // no longer documented
	
	// check options
	loc tro 0
	foreach opt in prefix suffix before after subst strfcn {
		loc is_`opt' 0
		cap conf e ``opt''
		if !(_rc) {
			loc tro 1
			loc is_`opt' 1
		}
	}
	if ("`upper'`lower'`lsq'" == "") & !(`tro') {
		di as err "transformation option required"
		e 198
	}	
	
	if (`"`valid'`invalid'"' != "") {
		if ("`valid'" != "") & ("`invalid'" != "") {
			loc vinv : list valid & invalid
			if ("`vinv'" != "") {
				di as err `"`vinv' may not be valid and invalid"'
				e 198
			}
		}
		foreach opt in valid invalid {
			if ("``opt''" != "") {
				loc `opt' : subinstr loc `opt' " " "," ,all
			}
		}
	}
	
	if ("`upper'`lower'" != "") {
		if ("`upper'" != "") & ("`lower'" != "") {
			di as err "upper and lower not both allowed"
			e 198
		}
		loc uplo `upper'`lower'
	}
	
	if (`is_before') & (`is_after') {
		di as err "before and after not both allowed"
		e 198
	}
	
	if ("`exclude'" != "") {
		if !(`is_before') & !(`is_after') {
			di as err "option noexclude not allowed"
			e 198
		}
	}
	loc exclude = ("`exclude'" == "")
	
	if (`is_subst') {
		if (`: word count `subst'' != 2) {
			di as err "subst must be two strings"
			e 198
		}
		loc f : word 1 of `subst'
		loc t : word 2 of `subst'
	}
	
	if (`is_strfcn') & ("`symbol'" == "") loc symbol @
	if !(`is_strfcn') & ("`symbol'" != "") {
		di as err "option symbol not allowed"
		e 198
	}
	
	foreach opt in symbol lsq {
		if ("``opt''" != "") {
			if (length("``opt''") > 1) {
				di as err "`opt' must be one character"
				e 198
			}
		}
	}
	
	// get value label names
	loc ok 0
	if ("`namelist'" == "") loc namelist _all
	if ("`variables'" != "") {
		foreach v of varlist `namelist' {
			loc lblnamelist `lblnamelist' `: val l `v''
		}
	}
	else {
		if (`: list posof "_all" in namelist') {
			qui la di
			loc lblnamelist `r(names)'
			loc ok 1
		}
		else {
			cap la li `namelist'
			if !(_rc) {
				loc lblnamelist `namelist'
				loc ok 1
			}
			else {
				m : st_local("hasd", ///
				strofreal(strpos(st_local("namelist"), "-")))
				if (`hasd') {
					loc namelist : subinstr loc namelist "- " "-" ,all
					loc namelist : subinstr loc namelist " - " "-" ,all
					loc namelist : subinstr loc namelist " -" "-" ,all
				}
				while (`"`namelist'"' != "") {
					gettoken tok namelist : namelist
					cap la li `tok'
					if !(_rc) loc lblnamelist `lblnamelist' `tok'
					else loc varlist `varlist' `tok'
				}
				foreach v of varlist `varlist' {
					loc lblnamelist `lblnamelist' `: val l `v''
				}
			}
		}
	}
	if ("`lblnamelist'" == "") {
		di as err "no value labels found"
		e 498
	}
	loc lblnamelist : list uniq lblnamelist
	if !(`ok') qui la li `lblnamelist'
	
	// change value labels
	tempname val
	foreach nam of loc lblnamelist {
		qui la li `nam'
		if !r(k) continue
		mata : st_vlload("`nam'", v = ., t = "")
		mata : st_matrix("`val'" ,v)
		forval j = 1/`= rowsof(`val')' {
			loc v = `val'[`j', 1]
			if ("`valid'" != "") {
				if !inlist(`v', `valid') continue
			}
			if ("`invalid'" != "") {
				if inlist(`v', `invalid') continue
			}
			loc txt : lab `nam' `v'
		
				// lsq
			if ("`lsq'" != "") {
				loc txt : subinstr loc txt "`" "`lsq'" ,all
			}
		
				// before() after()
			if (`is_before') | (`is_after') {
				loc ba = cond(`is_before', "before", "after")
				m : st_local("pos", ///
				strofreal(strpos(st_local("txt"), st_local("`ba'"))))
				if (`pos') {
					m : st_local("add", ///
					strofreal(strlen(st_local("`ba'"))))
					if (`is_before') {
						loc strt 1
						loc stp = `pos' - 1
						if !(`exclude') {
							loc stp = `stp' + `add'
						}
					}
					if (`is_after') {
						loc stp .
						loc strt `pos'
						if (`exclude') {
							loc strt = `strt' + `add'
						}
					}
					m : st_local("txt", ///
					substr(st_local("txt"), `strt', `stp'))
				}
			}		
			
				// substitute
			cap conf e `subst'
			if !(_rc) {
				m : st_local("txt", ///
				subinstr(st_local("txt"), st_local("f"), st_local("t")))
			}
			
				// upper lower
			if ("`uplo'" != "") {
				mata : st_local("txt", str`uplo'(st_local("txt")))
			}
			
				// string fuction
			if (`is_strfcn') {
				loc _cpy_strfcn : subinstr ///
				loc strfcn `"`symbol'"' `"`macval(txt)'"' ,all
				cap noi loc txt = `_cpy_strfcn'
				if _rc {
					di as err "invalid strfcn() returned error"
					e _rc
				}
			}
			
				// prefix suffix
			if (`is_prefix') | (`is_suffix') {
				m : st_local("txt", ///
				st_local("prefix") ///
				+ st_local("txt") + st_local("suffix"))
			}
			
			// modify value label
			m : st_vlmodify("`nam'", `v', st_local("txt"))
		}
	}
end
e

1.0.9	20aug2012	fix bug
					code polish
1.0.8	05jan2012	use Mata to work around single left quotes
					code polish
1.0.7	01oct2011	fix bug in option noexclude
1.0.6	12aug2011	change order of transformations
					handle single left quotes w/o changing them
					part of -labutil2- package
1.0.5	07aug2011	missing values allowed in -(in)valid- option
					fix bug if "_all" is spcified along with other names
1.0.4	25jun2011	fix specifying "_all" w/o -variables- resulted in error
					namelist allows wildcards now (namelist now anything)
					synonym -map()- no longer allowed (was confusing)
1.0.3	12jun2011	two elements must be specified in -subst- option
1.0.2	17may2011	exit if no options specified 
1.0.1		na		change left single quote (`) to typewriter 
						apostrophe (')
					change minimal abbreviation in -subst()-
					synonym -map()- may be used for -strfcn()-
					compatibility with 9.2
					