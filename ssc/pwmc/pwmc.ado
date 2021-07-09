*! version 1.1.0 07jan2014 Daniel Klein

pr pwmc
	vers 12.1
	
	if (replay()) {
		PwmcOut `0'
		e 0 // done
	}
	
	syntax varlist(num) [if] [in] , Over(varname num) ///
	[ PROCedure(passthru) MCOMPare(passthru) ///
	Level(cilevel) PValues noTABle VARLabel VALLabel ///
	CFORMAT(passthru) PFORMAT(passthru) SFORMAT(passthru) ]
	
	marksample touse
	qui cou if `touse'
	if !(r(N)) err 2000
	
	// procedure request
	if ("`procedure'`mcompare'" == "") loc procedure c gh t2
	else PwmcGetProc ,`procedure' `mcompare'
	
	// check factor variable has all integers
	cap as (`over' == int(`over'))
	if (_rc) {
		di as err "`over' may not contain noninteger values"
		e 498
	}
	
	// get levels of factor variable
	tempname lvls
	qui ta `over' if `touse' ,matrow(`lvls')
	loc k = r(r)
	if (`k' < 3) {
		di as err "`over' has too few levels"
		e 498
	}
		
	// get stats per level
	tempname stats
	mat `stats' = J(`k', 3, .)
	forv j = 1/`k' {
		qui su `varlist' if (`over' == `lvls'[`j', 1]) & (`touse')
		mat `stats'[`j', 1] = r(N)
		mat `stats'[`j', 2] = r(mean)
		mat `stats'[`j', 3] = r(sd)
	}
	
	// Mata
	m : mPwmc(st_matrix("`stats'"), tokens(st_local("procedure")), ///
	`level', st_matrix("`lvls'"), "`over'")
	
	// output
	PwmcOut , `table' `pvalues' `varlabel' `vallabel' ///
	`cformat' `pformat' `sformat' 
end

pr PwmcOut
	
	// confirm and get results from r()
	if ("`r(cmd)'" != "pwmc") err 301
	loc tmpnams diff Var ci t p_adj levels_over
	foreach x of loc tmpnams {
		conf mat r(`x')
		tempname `x'
		mat ``x'' = r(`x')
	}
	loc rprocedure `r(procedure)'
	if ("`r(depvar)'" != "") loc lopts VARLabel VALLabel
	
	syntax [, PROCedure(passthru) MCOMPare(passthru) ///
	noTABle PValues `lopts' ///
	CFORMAT(str) PFORMAT(str) SFORMAT(str)  ]
	
	if ("`table'" != "") e 0 // done
	
	// procedure request
	if ("`procedure'`mcompare'" == "") loc procedure `rprocedure'
	else PwmcGetProc ,`procedure' `mcompare'
	
	foreach x of loc procedure {
		loc pos : list posof "`x'" in rprocedure
		if !(`pos') err 301
		loc proc_pos `proc_pos' `pos'
	}
	
	// format options
	foreach x in cf pf sf {
		if ("``x'ormat'" != "") {
			conf numeric fo ``x'ormat'
			loc `x' : subinstr loc `x'ormat "-" ""
			if ("`x'" == "cf") loc maxwdth 9
			else if ("`x'" == "pf") loc maxwdth 5
			else if ("`x'" == "sf") loc maxwdth 8
			loc wdth = substr("``x''", 2, strpos("``x''", ".") - 2)
			if (`wdth' > `maxwdth') {
				di as err "invalid `x'ormat;"
				di as err "width too large"
				e 198
			}
			if (`wdth' < `maxwdth') {	
				loc `x' %`maxwdth'`= substr("``x''", 3, .)'
			}
		}
		else {
			if ("`x'" == "cf") loc `x' %9.7g
			else if ("`x'" == "pf") loc `x' %5.3f
			else if ("`x'" == "sf") loc `x' %8.2f
		}
	}
	
	// labels
	if ("`r(depvar)'" != "") {
		if ("`varlabel'" != "") loc varlabel ": var l"
		if ("`vallabel'" != "") loc vallabel ": lab (`r(over)')"
	}

	// variable lables
	foreach x in depvar over {
		loc `x' `varlabel' `r(`x')'
		if ("`x'" == "") loc `x' `r(`x')'
	}
	loc lbllen = max(length("`depvar'"), length("`r(over)'"), 12)
	
	// value labels
	forv j = 1/`r(k)' {
		loc `j' `vallabel' `= `levels_over'[`j', 1]'
		loc vllen `vllen' `: length loc `j''
	}
	tempname maxvllen
	m : st_matrix("`maxvllen'", ///
	sort(strtoreal(tokens(st_local("vllen"))'), (-1))[(1, 2), 1])
	loc lbllen = max(`maxvllen'[1, 1] + `maxvllen'[2, 1] + 6, `lbllen')
	
	// set ci title
	loc c Dunnett's C
	loc gh Games and Howell
	loc t2 Tamhane's T2
	
	// set tabel columns
	loc cilen = 18 + length("`r(level)'")
	
	loc c_nam = `lbllen' + 1 // start rownames
	loc c_diff = `c_nam' + 4 // start diff
	loc c_se = `c_nam' + 15 // start se
	loc c_ci = `c_nam' + 29 // start ci
	loc c_citxt = `c_nam' + 31 - length("`r(level)'") // ci and t text
	loc c_t = `c_nam' + 26
	loc c_p = `c_nam' + 40
	loc c_end = (`c_citxt' + `cilen') - (`c_nam' + 1) // end of table
	
	// header
	di as txt _n "Pairwise comparisons of means (unequal variances)" _n
	
	// the tables
	foreach pos of loc proc_pos {
	
		loc proc : word `pos' of `rprocedure'
		
		loc c_proc = `c_citxt' ///
		+ ceil(`cilen'/2) - ceil(length("``proc''")/2)
			// headline
		di as txt "{hline `c_nam'}{c TT}{hline `c_end'}"
			// procedure
		di as txt _col(`c_nam') " {c |}" _col(`c_proc') " ``proc''"
			// column names
		di as txt %`c_nam's `"`macval(depvar)' "' "{c |}" ///
		_col(`c_diff') "  Diff." _col(`c_se') " Std.Err" _c
		
		if ("`pvalues'" != "") {
			di _col(`c_citxt') _s(3) "t" _s(4) "adj. P>|t|"
		}
		else {
			di _col(`c_citxt') " [`r(level)'% Conf. Interval]"
		}
			// sepline
		di as txt "{hline `c_nam'}{c +}{hline `c_end'}"
			// over varname
		di as txt %`c_nam's `"`macval(over)' "' "{c |}"
		
		// the results
		loc cnt 0
		forv j = 1/`r(ks)' {
			forv i = `= `j' + 1'/`r(k)' {
				loc ++cnt
				
				di as txt %`c_nam's "``i'' vs ``j''  " "{c |}" ///
				as res _col(`c_diff') `cf' `diff'[1, `cnt'] ///
				as res _col(`c_se') `cf' `= sqrt(`Var'[1, `cnt'])' _c
				
				if ("`pvalues'" != "") {
					di as res _col(`c_t') `sf' `t'[1, `cnt'] /// 
					as res _col(`c_p') `pf' ///
					`p_adj'[`cnt', `pos']
				}
				else {
					loc _cnt = `cnt' + r(ks) * (`pos' - 1)
					di as res _col(`c_ci') `cf' `ci'[`_cnt', 1] ///
					"   " ///
					as res _col(`c_ci') `cf' `ci'[`_cnt', 2]
				}
			}
		}
		di as txt "{hline `c_nam'}{c BT}{hline `c_end'}"
		if (`pos' < `: word count `procedure'') di _n
	}
end

pr PwmcGetProc
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

1.1.0	07jan2014	external Mata function (mPwmc.mo)
					calculate adjusted p-values
					changed returned results (old results hidden)
					new output (new code)
					-replay()- results
					new option -pvalues-
					new options -pformat()-, -sformat()-, -notable-
					option -mcompare- as synonym for -procedure-
1.0.0	28jan2013	first release on SSC
