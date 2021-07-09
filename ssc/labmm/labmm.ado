*! version 1.0.5 20aug2012 Daniel Klein

pr labmm ,rclass
	vers 9.2
	
	syntax anything(id = `"# "label""') [, VARiables]
		// variables no longer documented

	// compatibility with old syntax (can do fast)
	gettoken names anything : anything ,p(\)
	if (`"`macval(anything)'"' == "") {
		loc anything `names'
		loc names
	}
	else {
		if ("`names'" == "\") {
			loc names
			loc def `anything'
		}
		else gettoken bs def : anything ,p(\)
	}
	
	// get labelnames and definitions
	if (`"`macval(def)'"' == "") {
		m : st_local("hasd", ///
		strofreal(strpos(st_local("anything"), "-")))
		if (`hasd') {
			loc anything : subinstr loc anything "- " "-" ,all
			loc anything : subinstr loc anything " - " "-" ,all
			loc anything : subinstr loc anything " -" "-" ,all
		}
		while (`"`macval(anything)'"' != "") {
			gettoken tok anything : anything ,p(`" ""')
			cap conf n `tok'
			loc rc1 = _rc
			cap as mi(`tok')
			loc rc2 = _rc
			cap unab tok : `tok'
			if (!(`rc1') | !(`rc2')) & (_rc) {
				loc def `tok' `anything'
				loc anything
			}
			else loc names `names' `tok'
		}
	}
	if (`"`macval(def)'"' == "") err 198
	
	// check labelnames
	if (`"`names'"' == "") loc names _all
	loc ok 0
	if ("`variables'" != "") {
		foreach v of varlist `names' {
			loc lblnames `lblnames' `: val l `v''
		}
	}
	else {
		if (`: list posof "_all" in names') {
			qui la di
			loc lblnames `r(names)'
			loc ok 1
		}
		else {
			cap la li `names'
			if !(_rc) {
				loc lblnames `names'
				loc ok 1
			}
			else {
				m : st_local("hasd", ///
				strofreal(strpos(st_local("names"), "-")))
				if (`hasd') {
					loc names : subinstr loc names "- " "-" ,all
					loc names : subinstr loc names " - " "-" ,all
					loc names : subinstr loc names " -" "-" ,all
				}
				while (`"`names'"' != "") {
					gettoken tok names : names
					cap la li `tok'
					if !(_rc) loc lblnames `lblnames' `tok'
					else loc varlist `varlist' `tok'
				}
				foreach v of varlist `varlist' {
					loc lblnames `lblnames' `: val l `v''
				}
			}
		}
	}
	if ("`lblnames'" == "") {
		di as err "no value labels found"
		e 111
	}
	loc lblnames : list uniq lblnames
	if !(`ok') qui la li `lblnames'
	
	// modify value labels
	foreach nam of loc lblnames {
		qui la de `nam' `def' ,modify
	}
	
	// return labelnamelist
	ret loc lblnamelist `lblnames'
end
e

1.0.5	20aug2012	fix bug
					rclass
1.0.4	05jan2012	fix bug if old syntax was used
					fix problems with left single quotes
					namelist may contain variable names
1.0.3	11sep2011	changed syntax (compatible with old syntax)
					code more efficient
1.0.2	11aug2011	changed syntax
					no longer loop over all values (from Nick Cox)
					fix bug when specifying _all w/o -variables-
					part of -labutil2- package
1.0.1	22jun2011	completely revised version
1.0.0	05aug2010
