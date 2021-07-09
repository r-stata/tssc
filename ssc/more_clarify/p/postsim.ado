*! postsim v1.0 10may2014 JavierMarquez 
program postsim, rclass
	version 11.2

//-----	<my_stuff> : <command>
	_on_colon_parse `0'
	local command = trim(`"`s(after)'"')
	local 0 `"`s(before)'"'

//-----	<by> not allowed (note: <_prefix_command> does not allow <mi>)
	local cmdname : word 1 of `command'
	if inlist(`"`cmdname'"', "by", "bysort") {
		di as err "`cmdname' may not be used in this context"
		exit 199
	}

//-----	Parse prefix
	syntax [anything(name=exp_list equalok)] [, ///
		Reps(integer 1000) ///
		SAVing(string) ///
		SEED(string) ///
		forcepsd ///
		exact ] // undocumented
	
	// reps
	if `reps' <= 1  {
		di as err "reps() must be greater than 1"
		exit 198
	}
	
	// saving
	if `"`saving'"'=="" {
		tempfile saving
		local filetmp "yes"
	}
	else {
		_parse_saving_opt `saving'
		local saving `"`s(filename)'"'
		local double `"`s(double)'"'
		local replace `"`s(replace)'"'
		local append `"`s(append)'"'
	}
	
	// corr2data or drawnorm
	if "`exact'"=="exact" {
		local method corr2data
	}
	else {
		local method drawnorm
	}
	
	// random seed
	if "`seed'" != "" {
		set seed `seed'
	}
	local seed `c(seed)'

//-----	Estimate
	`command'
	confirm matrix e(b) e(V)

//-----	Build matrix of the computed values from all expressions
	// preliminary parse of <exp_list>
	_prefix_explist `exp_list', stub(_sim_) edefault
	local eqlist    `"`s(eqlist)'"'
	local idlist    `"`s(idlist)'"'
	local explist   `"`s(explist)'"'
	local eexplist  `"`s(eexplist)'"'
	// expand eexp's
	tempname b V
	_prefix_expand `b' `explist', ///
		stub(_sim_) ///
		eexp(`eexplist') ///
		colna(`idlist') ///
		coleq(`eqlist') ///
		// blank
	local explist   `"`s(explist)'"'
	local k_eq      `s(k_eq)'
	local k_exp     `s(k_exp)'
	local k_eexp    `s(k_eexp)'
	local K = `k_exp' + `k_eexp'
	local k_extra   `s(k_extra)'
	local names     `"`s(enames)' `s(names)'"'
	local express   `"`s(explist)'"'
	local eexpress  `"`s(eexplist)'"'
	local coleq     `"`s(ecoleq)' `s(coleq)'"'
	local colna     `"`s(ecolna)' `s(colna)'"'
	forval i = 1/`K' {
		local exp`i' `"`s(exp`i')'"'
	}

//-----	Get b V
	qui nlcom `explist'
	mat `b' = r(b)
	mat `V' = r(V)
	mata: st_replacematrix("`V'", makesymmetric(st_matrix("`V'")))

//-----	Simulate from the multivariate normal
	preserve
	clear
	qui `method' `names', n(`reps') means(`b') cov(`V') `double' `forcepsd'

//----- Collect results
	tempname N_reps b_sp V_sp
	// N
	qui count
	scalar `N_reps' = r(N)
	// b
	qui tabstat _all, stat(mean) save
	mat `b_sp' = r(StatTotal)  
	mat colnames `b_sp' = `names'
	// V
	qui corr _all, cov
	mat `V_sp' = r(C)
	mat colnames `V_sp' = `names'
	mat rownames `V_sp' = `names'

//-----	Save data
	if `"`filetmp'"'=="" {
		// save characteristics and labels to data set
		label data `"postsim: `e(cmd)'"'
		char _dta[command] `"`e(cmdline)'"'
		char _dta[seed] `"`seed'"'
		char _dta[reps] `reps'
		char _dta[k_eq] `k_eq'
		char _dta[k_extra] `k_extra'
		forvalues i = 1/`K' {
			local name : word `i' of `names'
			char `name'[observed] `= `b'[1,`i'] '
			local label = substr(`"`exp`i''"',1,80)
			label variable `name' `"`label'"'
			char `name'[expression] `"`exp`i''"'
			if `"`coleq'"' != "" {
				char `name'[colname]
				local na : word `i' of `colna'
				local eq : word `i' of `coleq'
				char `name'[coleq] `eq'
				char `name'[colname] `na'
					if `i' <= `k_eexp' {
					char `name'[is_eexp] 1
				}
			}
		}
		// append
		if "`append'" != "" {
			qui append using `"`saving'"', ///
				keep(`names') ///
				nolabel ///
				nonotes
		}
		// save data
		save `"`saving'"', `replace'
	}

//-----	Return
	return matrix V = `V_sp'
	return matrix b = `b_sp'
	return scalar N_reps  = `N_reps'

	return local seed `"`seed'"'
	return local cmdline `"`command'"'
	return local prefix  "postsim"
end

*------------------------------------------------------
* Parse saving options
*------------------------------------------------------
program _parse_saving_opt, sclass
	capture noisily ///
	syntax anything(id="file name" name=fname) [, ///
		DOUBle ///
		REPLACE ///
		APPend]

	opts_exclusive "`replace' `append'"
	local ss : subinstr local fname ".dta" ""
	if "`replace'" == "" {
		if "`append'" == "" confirm new file `"`ss'.dta"'
		else {
			confirm file `"`ss'.dta"'
			local replace replace
		}
	}
	sreturn local filename  `"`fname'"'
	sreturn local double    `"`double'"'
	sreturn local replace   `"`replace'"'
	sreturn local append    `"`append'"'
end
