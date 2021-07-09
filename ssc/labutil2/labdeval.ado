*! version 1.0.4 26oct2012 Daniel Klein

pr labdeval
	vers 9.2
	
	syntax [anything(id = "varlist [# label ...]")][ , * force ]
	
	// parse anything and determine syntax
	if (`"`macval(anything)'"' != "") {
		cap unab varlist : `anything'
		if (_rc) {
			while (`"`macval(anything)'"' != "") {
				gettoken tok anything : anything ,p(`"`""' "')
				cap conf v `tok'
				if !(_rc) loc varlist `varlist' `tok'
				else {
					cap conf n `tok'
					loc rc = _rc
					cap as `tok' == int(`tok')
					if inlist(0, _rc, `rc') {
						loc def `tok' `anything'
						continue ,br
					}
					else loc varlist `varlist' `tok'
				}
			}
			_labdeval `varlist' ,def(`def') `options'
		}
		else _labdeval2 `varlist' ,`options'
	}
	else _labdeval2 ,`options'
end

pr _labdeval

	syntax varlist(num) , def(str asis) ///
	[ modify replace DEFine(name) nofix ]
	
	// option violations
	if ("`modify'" != "") & ("`replace'" != "") {
		di as err "option replace may " ///
		"not be combined with option modify"
		e 198
	}
	
	// labels already defined
	if ("`modify'`replace'`define'" == "") _alreadydef `varlist'
	
	// tempnames
	tempname val txt
	
	// define
	if ("`define'" != "") {
		if ("`replace'" != "") {
			m : st_vlload("`define'", `val' = ., `txt' = "")
			cap la drop `define'
		}
		cap noi la de `define' `def' ,`modify' `nofix'
		if (_rc) {
			if ("`replace'" != "") {
				m : st_vlmodify("`define'", `val', `txt')
			}
			e _rc
		}
	}
	
	// define and attach labels
	foreach v of loc varlist {
		if ("`define'" != "") la val `v' `define'
		else {
			if ("`replace'" != "") {
				m : st_vlload("`v'", `val' = ., `txt' = "")
				cap la drop `v'
			}
			cap noi la de `v' `def' ,`modify' `nofix'
			if (_rc) {
				if ("`replace'" != "") {
					m : st_vlmodify("`v'", `val', `txt')
				}
				e _rc
			}
			la val `v' `v'
		}
	}
	e 0 // done
end

pr _labdeval2
	
	syntax [varlist(default = none num)] /// 
	[, COPY_p(name) copy replace ]
	
	// get and check varlist
	if ("`varlist'" == "") {
		qui ds ,has(t numeric)
		loc varlist `r(varlist)'
	}
	if ("`varlist'" == "") e 0 // done
	
	// copy copy()
	if ("`copy'" != "") {
		if !inlist("`copy_p'", "", "_all") {
			di as err "invalid option copy"
			e 198
		}
		loc copy_p _all
	}
	loc copy `copy_p'
	
	// option violation
	if ("`copy'" == "") & ("`replace'" != "") {
		di as err "option replace not allowed"
		e 198
	}
	
	// copy
	if ("`copy'" != "") {
		if ("`replace'" == "") {
			qui la di
			loc lbls `r(names)'
			loc adef : list lbls & varlist
			if ("`adef'" != "") {
				di as err "label `: word 1 of `adef'' " ///
				"already defined"
				e 110
			}
		}
		tempname val txt
		if ("`copy'" != "_all") {
			qui la li `copy'
			m : st_vlload("`copy'", `val' = ., `txt' = "")
		}
		else {
			tempname `varlist'
			foreach v of loc varlist {
				loc vl : val l `v'
				if inlist("`vl'", "", "`v'") continue
				m : st_vlload("`vl'", `val' = ., `txt' = "")
				m : st_vlmodify("``v''", `val', `txt')
			}
		}
	}

	// define and attach labels
	foreach v of loc varlist {
		loc vl : val l `v'
		if ("`vl'" == "`v'") continue
		if ("`copy'" == "") {
			cap la li `v'
			if (_rc) continue
		}
		else {
			if ("`copy'" == "_all") {
				if ("`vl'" == "") continue
				m : st_vlload("``v''", `val' = ., `txt' = .)
			}
			if ("`replace'" != "") cap la drop `v'
			m : st_vlmodify("`v'", `val', `txt')
		}
		la val `v' `v'
	}
	e 0 // done
end

pr _alreadydef
	qui la di
	loc lbls `r(names)'
	loc adef : list lbls & 0
	if ("`adef'" != "") {
		di as err "label `: word 1 of `adef'' already defined"
		e 110
	}
end
e

1.0.4	26oct2012	complete rewrite code
					major bug:
						value labels with variable names attached 
						to other variables corrupted -copy(_all)-
						-> fixed
					-force- no longer needed (but retained)
1.0.3	29aug2012	-copy- as synonym for -copy(_all)-
					code polish
					(not released)
1.0.2	22dec2011	_all may specified in -copy()-
					better checks and speed things up
1.0.1	17nov2011	fix -replace- to work in Stata 9.2
					add option -copy-
1.0.0	10sep2011	first version on SSC
