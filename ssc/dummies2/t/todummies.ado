*! version 1.0.6 29aug2012 Daniel Klein

pr todummies
	vers 10.1

	syntax anything(id = varname) [if][in] ///
	[, Generate(namelist) REFerence(str) noVARLabel sic Missing]
		// missing is not documented
	
	// sample
	marksample touse ,nov
	qui cou if `touse'
	if !(r(N)) err 2000

	// get varname and storage type
	gettoken sicvarn anything : anything
	unab varn : `sicvarn'
	if (`: word count `varn'' > 1) err 103
	conf numeric v `varn'
	cap as (`varn' == int(`varn')) if `touse'
	if (_rc) {
		di as err "`varn' has noninteger values"
		e 459
	}
	
	// generate
	loc ngen : word count `generate'
	if !(`ngen') loc generate ``sic'varn'
	if (`ngen' > 1) {
		conf new v `generate'
		token `generate'
	}
	
	// get value label (for variable labels)
	if ("`varlabel'" == "") {
		loc vall : val l `varn'
		tempname vlbl
		if ("`vall'" != "") {
			m : st_vlload("`vall'", v = ., t = "")
			m : st_vlmodify("`vlbl'", v, t)
		}
	}
	
	// no levels specified
	if (`"`macval(anything)'"' == "") {
		tempname R
		if (`ngen' < 2) loc gopt generate(`generate')
		else if ("`missing'" == "") {
			qui replace `touse' = 0 if mi(`varn')
		}
		
		// create dummies
		nobreak {
			qui ta `varn' if `touse' ,`gopt' `missing' matrow(`R')
			loc r = r(r)
			if !(`r') err 2000 // no indicators created
			
			// check generate
			if (`ngen' > 1) & (`ngen' != `r') {
				di as err "option generate: `ngen' names for " ///
				`"`r' `= plural(`r', "indicator")' specified"'
				e 198
			}
			else {
				if (`r' == 1) & ("`sic'" != "") {
					cap noi conf new v `generate'
					if (_rc) {
						drop `generate'1
						e _rc
					}
				}
			}
			
			// label (and create) variables
			forv j = 1/`r' {
				if (`ngen' > 1) { // create indicator
					qui g byte ``j'' = (`varn' == `R'[`j', 1]) ///
					if `touse'
				}
				else loc `j' `generate'`j'
				
				// label
				if ("`varlabel'" != "") {
					if (`ngen' < 2) la var ``j''
				}
				else {
					m : st_varlabel("``j''", ///
					st_vlmap("`vlbl'", st_matrix("`R'")[`j', 1]))
				}
			}
			
			// sic rename
			if (`r' == 1) & ("`sic'" != "") ren `generate'1 `generate'
		}	
		if ("`reference'" != "") {
			di as txt "(note: option reference ignored)"
		}
		e 0 // done
	}
	
	// at least one level specified
	
	// min and max
	foreach x in anything reference {
		m : st_local("m", strofreal(strpos(st_local("`x'"), "m")))
		if (`m') loc xch `xch' `x'
	}
	if ("`xch'" != "") {
		su `varn' ,mean
		foreach x of loc xch {
			foreach m in min max {
				loc `x' : subinstr loc `x' "`m'" "`r(`m')'" ,all
			}
		}
	}
	
	// reference
	loc maxl 249
	m : st_local("rest", ///
	strofreal(strpos(st_local("reference"), "rest")))
	if ("`reference'" != "") & !(`rest') {
		cap numlist "`reference'" ,int miss max(`maxl')
		if _rc {
			di as err `"invalid `macval(reference)'"'
			err _rc
		}
		loc alln `r(numlist)'
		loc maxl = `maxl' - `: word count `alln''
	}
		
	// parse anything
	loc ni 0
	while (`"`macval(anything)'"' != "") {
		gettoken tok anything : anything ,p (`" `""'"') m(p)
		loc ++ni
		
		// strip label if tok is (numlist ["label"])
		if ("`p'" != "") & ("`varlabel'" == "") {
			gettoken tok lbl : tok ,p(`"`""'"')
		}
		
		// parse tok as numlist
		cap numlist `"`macval(tok)'"' ,int miss max(`maxl')
		if (_rc) {
			if (_rc != 123) di as err `"invalid `macval(tok)'"'
			err _rc
		}
		loc num `r(numlist)'
		loc nnum : word count `num'
		loc maxl = `maxl' - `nnum'
		
		// labels
		if ("`p'" == "") { // tok is #
			if ("`varlabel'" == "") {
				gettoken lbl anything : anything ,qed(q)
				if !(`q') loc anything `lbl' `anything'
				else {
					m : st_vlmodify("`vlbl'", ///
					strtoreal(tokens(st_local("num"))'), ///
					J(`nnum', 1, st_local("lbl")))
				}
			}
			
			if (`nnum' > 1) { // # is from/to
				gettoken num back : num
				loc anything `back' `anything'
			}
		}
		else { // tok is (numlist)
			if (`"`macval(lbl)'"' != "") {
				gettoken lbl mpty : lbl
				loc nmpty : word count `mpty'
				if (`nmpty') {
					di as err `"invalid label `macval(mpty)'"'
					e 198
				}
				gettoken fnum num : num
				m : st_vlmodify("`vlbl'", `fnum', st_local("lbl"))
				
				if (`nnum' > 1) {
					m : st_vlmodify("`vlbl'", ///
					strtoreal(tokens(st_local("num"))'), ///
					J(`--nnum', 1, ""))
				}
				loc num `fnum' `num'
			}
		}
		
		loc num`ni' : list clean num
		loc dup : list num`ni' & alln
		if ("`dup'" != "") {
			di as err "value `: word 1 of `dup''" ///
			" mentioned more than once"
			e 198
		}
		loc alln `alln' `num`ni''
	}
		
	// dummy names
	if (`ngen' > 1) {
		if (`ngen' != `ni') {
			di as err "option generate: `ngen' names for " ///
			`"`ni' `= plural(`ni', "indicator")' specified"'
			e 198
		}
	}
	else {
		if (`ni' > 1) | ("`sic'" == "") {
			loc stub `generate'
			loc generate `generate'1
			forv j = 2/`ni' {
				loc generate `generate' `stub'`j'
			}
		}
		conf new v `generate'
		token `generate'
	}
	
	// mark out omitted levels
	loc alln : list clean alln
	loc alln : subinstr loc alln " " ", " ,all
	if !(`rest') {
		qui {
			replace `touse' = 0 if !inlist(`varn', `alln')
			cou if `touse'
			if !(r(N)) err 2000
		}
	}
	
	// create dummies
	nobreak {
		forv j = 1/`ni' {
			loc num`j' : subinstr loc num`j' " " ", " ,all
			qui g byte ``j'' = inlist(`varn', `num`j'') if `touse'
			
			// reference rest
			if (`rest') {
				qui replace ``j'' = . ///
				if mi(`varn') & !inlist(`varn', `alln')
			}
		
			// label variable
			if ("`vall'" == "") | ("`varlabel'" != "") continue
			m : st_varlabel("``j''", ///
			invtokens(st_vlmap("`vlbl'", (`num`j''))))
		}
	}
end
e

1.0.6	29aug2012	early check for number of variables specified
1.0.5	21aug2012	fix bug: -min- and -max- allowed in -reference-
					allow namelist in -generate- w/o levels
					enhance existing option -sic-
					non-integers not allowed in categorical variable
					do not -cap pr drop todummies-
					code polish
1.0.4	04aug2012	fix bug in option -reference-
					-reference- may be "rest"
					(sent to SSC)
1.0.3	02aug2012	allow user variable labels
					option -reference- ignored w/o levels
1.0.2	27jul2012	fix problems with -sic-
					option -reference- may not be used w/o levels
1.0.1	24jul2012	may use keywords -min- and -max-
					option -reference- added
1.0.0	23jul2012
