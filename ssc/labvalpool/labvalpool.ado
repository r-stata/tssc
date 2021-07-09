*! version 1.0.5 03sep2012 Daniel Klein

pr labvalpool
	vers 9.2
	
	syntax [namelist(id = "target-lblname lblname-list")] ///
	[ , Append Append_p(str) REPLACE UPDATE OVERWrite Pool ///
	SEParator(str) ]
	
	// check options
	if ("`overwrite'" != "") loc update update
	if ("`append_p'" != "") loc append append
	
	if ("`replace'" != "") & (`"`append'"' != "") {
		di as err "replace and append not both allowed"
		e 198
	}
	
	if ("`update'" != "") & ("`pool'" != "") {
		di as err "update and pool not both allowed"
		e 198
	}
	
	if ("`separator'" != "") & ("`pool'" == "") {
		di as err "option separator not allowed"
		e 198
	}
	
	if ("`pool'" != "") & ("`separator'" == "") loc separator " "
	
	// check namelist
	loc dup : list dups namelist
	if ("`dup'" != "") {
		di as err `"`: word 1 of `dup'' mentioned more than once"'
		e 198
	}
	
	// minimum number of labels specified
	loc n : word count `namelist'
	if (`n' < 2) {
		qui la di
		loc namelist `namelist' `r(names)'
		loc namelist : list uniq namelist
		loc n : word count `namelist'
		if (`n' < 2) {
			di as err "too few value labels"
			e 198
		}
	}
	
	// check value labels to be pooled
	gettoken tlbl namelist : namelist
	foreach nam of loc namelist {
		qui la li `nam'
		if !r(k) {
			loc out `out' `nam'
		}
	}
	loc namelist : list namelist - out
	if ("`namelist'" == "") {
		di as err "too few value labels"
		e 111
	}
	if ("`replace'`append'" == "") {
		cap la li `tlbl'
		if !(_rc) {
			di as err "label `tlbl' already defined"
			e 110
		}
	}
	else {
		if ("`append'" != "") {
			qui la li `tlbl' // check tlbl exists
			loc namelist `tlbl' `namelist'
		}
		if ("`replace'" != "") cap la drop `tlbl'
	}
	
	// parse append option
	if (`"`append_p'"' != "") {
		loc append append
		cap numlist "`append_p'" ,miss
		if (_rc) {
			cap unab vars : `append_p'
			if (_rc) {
				di as err "invalid option append"
				e _rc
			}
			cap noi conf numeric v `vars'
			if (_rc) {
				if (_rc == 7) e 109
				else e _rc
			}
			loc append_p
			foreach var of loc vars {
				qui levelsof `var' ,miss
				loc append_p `append_p' `r(levels)'
			}
		}
		else loc append_p `r(numlist)'
		loc append_p : list uniq append_p
	}
	
	// pool value labels
	tempname v
	foreach nam of loc namelist {
		m : st_vlload("`nam'", v = ., t = "")
		m : st_matrix("`v'", v)
		forv r = 1/`= rowsof(`v')' {
			loc val = `v'[`r', 1]
			if ("`append_p'" != "") & !(`: list val in append_p') {
				continue
			}
			loc txt : lab `nam' `val'
			if (`: list val in labvalpool') {
				if ("`update'`pool'" == "") continue
				if ("`pool'" != "") {
					loc txt2 : lab `tlbl' `val'
					m : st_vlmodify("`tlbl'", `val', ///
					st_local("txt2") ///
					+ st_local("separator") ///
					+ st_local("txt"))
					continue
				}
			}
			m : st_vlmodify("`tlbl'", `val', st_local("txt"))
			loc labvalpool `labvalpool' `val'
		}
	}
end
e

1.0.5	03sep2012	extend option -append-
					code polish
1.0.4	05jan2012	use Mata to work around left single quotes
					code speedup and polish
1.0.3	12aug2011	improve handeling left single quotes
					part of -labutil2- package
1.0.2	13jun2011	namelist may be empty, meaning all value labels
					-overwrite- as synonym for -update-
1.0.1	13may2011	change all ` to '
					add -append- and -separator- options
					some changes in code
