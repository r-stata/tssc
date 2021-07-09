*! version 1.0.3 20may2012 Daniel Klein

pr labcpy
	vers 9.2
	
	syntax anything(id = "oldlblname newlblname") ///
	[ , REPLACE VALues(varlist num) NOFIX ] 
		// nofix is not documented
	
	// parse
	gettoken old anything : anything
	gettoken new anything : anything
	
	// check
	if (`"`new'"' ==  "") err 198
	qui la li `old'
	loc nrows = r(k) // needed if rules specified
	if !(`nrows') { // not an error
		di as txt "(note: value label " ///
		as res "`old' " as txt "has no mapped values)"
	}
	cap la li `new'
	if !(_rc) {
		di as err "label `new' already defined"
		e 110
	}
	cap conf name `new'
	if _rc {
		di as err `"`new' invalid name"'
		e 198
	}
	
	// get oldlbl
	mata : st_vlload("`old'", val = ., txt = "")
	
	// copy and modify
	if (`"`anything'"' == "") mata : st_vlmodify("`new'", val, txt)
	else {
	
		// parse anything
		gettoken tok : anything ,p("(") match(par)
		if ("`par'" == "") {
			if ("`replace'" == "") {
				mata : st_vlmodify("`new'", val, txt)
			}
			cap noi la de `new' `tok' ,modify
			if _rc {
				la drop `new'
				e _rc
			}
		}
		else {
			if !(`nrows') e 0 // done
			if ("`replace'" != "") {
				di as err "option replace not allowed"
				e 198
			}
			_labchng `nrows' `new' `anything' // rules specified
		}
	}
	
	// label values
	if ("`values'" != "") {
		foreach var of loc values {
			la val `var' `new' ,`nofix'
		}
	}
end

pr _labchng
	
	// parse
	gettoken k 0 : 0
	gettoken new rules : 0
	
	// create rules
	while (`"`rules'"' != "") {
		gettoken rule rules : rules ,match(par)
		if ("`par'" == "") {
			di as err `"`rule': parentheses required"'
			e 198
		}
		gettoken org des : rule ,p("=")
		loc des : subinstr loc des "=" "" ,c(loc eq)
		if !(`eq') {
			di as err "(`rule'): = required"
			e 198
		}
		cap noi numlist "`des'" ,int miss
		if _rc {
			di as err `"invalid rule: (`rule')"'
			e _rc
		}
		loc des `r(numlist)'
		loc ndes : word count `des'
		if (`ndes' > 1) {
			cap noi numlist "`org'" ,int miss
			if _rc {
				di as err `"invalid rule: (`rule')"'
				e _rc
			}
			loc org `r(numlist)'
			if (`: word count `org'' != `ndes') {
				di as err "invalid rule (`rule'); " ///
				"{it:numlist} = {it:numlist} mismatch"
				e 198
			}
			loc i 0
			token `des'
			foreach o of loc org {
				loc rl `rl' (`o' = ``++i'')
			}
			loc rls `rls' `rl'
		}
		else loc rls `rls' (`rule')
	}
	
	// check sufficient observations
	if (`k' > c(N)) {
		loc resto qui drop in `= `c(N)' + 1'/`k'
		qui se obs `k'
	}
	
	// change values
	tempname tmp
	qui mata : st_addvar("int", "`tmp'")
	mata : st_store(1::rows(val), "`tmp'", val)
	cap recode `tmp' `rls'
	if _rc {
		di as err "an unexpected error occurred;"
		di as err "probably there is something " ///
		"wrong with the specified {it:modifications}"
		`resto'
		e 498
	}
	loc nchg = r(N)

	mata : st_view(val, 1::rows(val), "`tmp'")
	mata : st_vlmodify("`new'", val , txt)
	mata : st_vlmodify("`new'", ., "")
	drop `tmp'
	cap `resto'
	di as txt "(value label `new': " ///
	`"`nchg' `= plural(`nchg', "change")' made)"'
end
e

1.0.3	20may2012	may attach copied label to variables
1.0.2	15nov2011	option -replace- compatible with version 9.2
1.0.1	30oct2011	modifications may be specified as rules
1.0.0	27sep2011	part of -labutil2-
