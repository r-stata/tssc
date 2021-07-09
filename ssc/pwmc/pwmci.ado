*! version 2.0.0 07jan2014 Daniel Klein

pr pwmci
	vers 12.1
	
	syntax anything(id = "arguments") ///
	[, PROCedure(passthru) MCOMPare(passthru) ///
	Level(cilevel) PValues noTable ///
	CFORMAT(passthru) PFORMAT(passthru) SFORMAT(passthru) ]
	
	// check args
	foreach par in ( ) [ ] {
		loc anything : subinstr loc anything "`par'" " " ,all
	}
	numlist "`anything'" ,min(9)
	loc nargs : word count `anything'
	if (mod(`nargs', 3)) {
		di as err "wrong number of arguments"
		e 198
	}
	loc k = `nargs'/3
	
	// procedure request
	if ("`procedure'`mcompare'" == "") loc procedure c gh t2
	else PwmciGetProc ,`procedure' `mcompare'
	
	// get stats
	tempname stats
	mat `stats' = J(`k', 3, .)
	token `anything'
	loc row 0
	forv j = 1(`k')`nargs' {
		loc ++row
		conf integer n ``j''
		mat `stats'[`row', 1] = ``j''
		mat `stats'[`row', 2] = ``= `j' + 1''
		loc j2 = `j' + 2
		if ((``j2'') < 0) {
			di as err "standard deviation must be positive"
			e 498
		}
		mat `stats'[`row', 3] = ``j2''
	}
	
	// Mata
	m : mPwmc(st_matrix("`stats'"), tokens(st_local("procedure")), ///
	`level', J(1, 1, (1::`k')))
	
	// replay r()
	pwmc , `table' `pvalues' `cformat' `pformat' `sformat'
end

pr PwmciGetProc
	syntax [, procedure(str) mcompare(str) ]
	if ("`mcompare'" != "") {
		if !inlist("`procedure'", "", "`mcompare'") {
			di as err "invalid option mcompare()"
			e 198
		}
		loc procedure : copy loc mcompare
	}
	loc procedure = lower("`procedure'")
	loc procedure : list uniq procedure
	foreach x of loc procedure {
		if !(inlist("`x'", "c", "gh", "t2")) {
			di as err `"unknown procedure `x'"'
			e 198
		}
	}
	c_local procedure `procedure'
end
e

2.0.0	07jan2014	no longer do any calculations
					parse args and do minimal checking
					call external Mata function
					call -pwmc- to replay results
					parentheses around args may be used
1.0.0	28jan2013	initial release on SCC
