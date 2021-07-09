// ------------------------- General frame of the command -------------------------------
// This command needs that the file with survival data has been suitably merged with
// the rates of a reference population. Note that each of the three methods estimating
// an expected survival requires a different follow-up time and so the results
// of merging st-data with rate-data are different.
// Starting from reference rates stexpect creates a file where Hakulinen (default), 
// Ederer I (Exact) or Conditional (Ederer II) expected survival is estimated.
// User must specify the reference rate variable.
// By default, if the method is Hakulinen or Conditional, an estimate is returned for
// each unique follow-up time. In the case of Ederer I and optionally in the other methods
// at(numlist) option gives a set of times at which expected survival will be computed.
// Internal computation used in stexpect partitions the time line at every death or
// censoring point, but in Ederer 1 method. This may result in an huge expansion of the
// data set. Therefore for large data sets the npoints(#) option is available. In this  
// case an approximate computation of the expected survival function will be done 
// at # equally spaced times.
// --------------------------------------------------------------------------------------

*! stexpect 1.1.2 - EC 10APR2005
*! Expected Survival
program define stexpect
	version 8
	st_is 2 analysis
	syntax [ newvarname(numeric) ] [if] [in], RATEVAR(varname) [ OUTput(string asis) ///
		AT(numlist sort >=0) METhod(int 3) BY(varlist min=1 max=5) ///
	  	NPoints(numlist integer max=1 >1) noLIst]
	marksample touse, novarlist
	markout `touse' `by' , strok
	qui replace `touse' = 0 if _st==0 | _st>=.
	if `"`_dta[st_id]'"' == "" {
		di as err ///
		"stexpect requires that you have previously stset an id() variable"
		exit 198
	}
	cap confirm numeric variable `_dta[st_id]'
	if _rc {
		di as err ///
		"stexpect requires that you have previously stset an id() numeric variable"
		exit 198
	}
	if `method' < 1 | `method' > 3 {
                di as err "method code should be between 1 and 3"
                exit 198 
        }
	// byvars cannot contain non-integer values 
	if "`by'" != "" {
		foreach var of varlist `by' {
			capture confirm numeric variable `var'
			if !_rc {
				capture assert `var' == int(`var') if `touse' 
				if _rc {
					di as err "`var' contains non-integer values" 
					exit 459
				}
			}
		} 
	}
	if "`at'" != "" {
		DropDup at : "`at'"
		local mode NF 
	} 
	else {
		if `method'==1 {
			di as err "Ederer 1 method requires an" /// EDERER I needs 
		   	" at(numlist) option be specified"	//  an at(numlist) 
               		exit 198
               	}
               	if "`npoints'"==""  local mode F  // if at(num) unspecified, then at(failures)
		else                local mode N  // if only npoints(#) is specified 
	}
       	if "`npoints'"!=""  local np "np(`npoints')" // we can have at(numlist) and npoints(#)  
	//mode's code
	//F  exact, only at failure - Default if no at(numlist)
	//N  approximate, only at equally spaced points - it doesn't affect Ederer I method
	//NF at numlist with(approximate) or without(exact) npoints
	//E  Ederer I method - set below
        if "`by'" != "" {
        	local varby `by'
                local by `"by(`by')"'
        }
        if "`varlist'" == "" 	local varlist Survexp
	
	// output(filename[, replace]) -- copied from strate 
	if "`output'" != "" {
		gettoken outnam output : output, parse(",")
		gettoken comma output : output, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrepl output : output, parse(" ,")
			gettoken comma output : output, parse(" ,")
			if `"`outrepl'"' != "replace" | `"`comma'"'!="" { 
				di as err "option output() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			di as err "option output() invalid"
		exit 198
		}
		else 	confirm new file `"`outnam'.dta"'
	}
	preserve

	qui keep if `touse'
	qui keep `_dta[st_id]' `ratevar' `varby' _st _d _t _t0
	qui gen double `varlist' = .

	// mode E sets HakConEd to exclude computation at each fail/censoring time 
	// npoints(#) is not specified even if the user specify it  
	if `method'==1 {
		local mode E
		qui HakConEd `varlist' `ratevar' , mode(`mode') method(3) at(`at') `by'
	}
	else  	qui HakConEd `varlist' `ratevar' , mode(`mode') method(`method') at(`at') `by' `np'
	sort `varby' t_exp
	if "`list'" == ""{
		if "`by'" != ""  local by "sepby(`varby')"
		st_show
		format `varlist' %5.4f
		cap assert t_exp==int(t_exp)
		if _rc format t_exp %10.4f
		list `varby' t_exp atrisk `varlist', `by' noobs
		if `method' !=2 {
			di as txt "  Note:  When Ederer or Hakulinen method is used" /// 
			             " the atrisk number does not correspond" _n ///
				   "         to the actual number of subjects in the study cohort." 
		}
	}
	// outfile 
	if "`outnam'" != "" {
		qui {
			label var `varlist' "Expected Survival"
			label data 
			order `varby' t_exp atrisk `varlist'
			stset, clear
			save `"`outnam'"', `outrepl'
			}
	}
end

// DropDup newlist : list
// drops all duplicate tokens from list -- copied from stsplit.ado
program define DropDup
	args newlist colon list
	gettoken token list : list
	while "`token'" != "" {
		local fixlist `fixlist' `token'
		local list : subinstr local list "`token'" "", word all
		gettoken token list : list
	}
	c_local `newlist' `fixlist'
end

program define HakConEd
	version 8
	args nvar rate
	syntax varlist, Mode(string) MEthod(integer) [AT(numlist) BY(varlist) NP(integer 0)]
	tempvar timexp rate_h w_h rset prev_h n_ini tsave last wei
	local id `_dta[st_id]'
	if "`by'"!=""     local byby `"by(`by')"'
	if "`by'"!=""     local strata `"strata(`by')"'
	
	// A trick to cope with late entry 
	bysort `id' (_t): gen byte `n_ini'=_n==1
	gsort -`n_ini'
	count if `n_ini'
	local n_obs = `r(N)'
	su _t0 in 1/`n_obs',meanonly
	if `r(max)'!=`r(min)' 	local late late
	else drop `n_ini'

	// Saving original _t to compute weigths
	gen double `tsave' = _t 
	bysort `id' (_t) : gen byte `last'=_n==_N
	gsort -`last'
	su _t in 1/`n_obs',meanonly
	local tmax = `r(max)'
	
	// Replacing last time if approximation
	if `np'!=0 {
		local tmin = r(min)
		local np = `np' - 1
		replace _t = autocode(_t,`np',`tmin',`tmax') if `last'
		replace _t = `tmin' if `last' & float(`tsave')==float(`tmin')
		drop `n_ini' `last'
	}	
	
	// Time coordinates for expected survival if at(numlist)
	if "`mode'"=="NF" | "`mode'" =="E" 	stsplit `timexp',at(`at') nopreserve
	
	// Set _d to stsplit at(failures) and generate risksets if late entry
	replace _d=0

	// Splitting at the end of all observations if Hakulinen or Conditional and no approximate computation 
	if "`mode'"!="E" & `np'==0  {
		bysort `id' (_t) : replace _d=1 if _n==_N
		if "`late'"!="" {
			bysort `id' (_t): replace `n_ini'=_n==1
			expand 2 if `n_ini'
			bysort `id' (_t) : replace _t=_t0 if _n==1
			replace _d=1 if _t==_t0 & `n_ini'
			if "`mode'"=="NF"	bysort `id' `timexp' (_t) : replace _d=1 if _n==_N
			drop `timexp' `last' `n_ini'
			recast float _t _t0 `tsave',force
		}
		else drop `last' 
		stsplit,at(failures) nopreserve `strata' riskset(`rset')
		// R does not restrict episode splitting to the failures that occur within each stratum.
		// So it computes expected survival at the same times in all strata and output
		// looks apparently different from stexpect.
		if "`late'"!=""   bysort `id' (_t) : drop if _n==1
		if "`late'"=="" & "`mode'"=="NF"  bysort `id' `timexp' (_t) : replace `rset'=0 if _n==_N
		replace `tsave' = _t if _t<=`tsave'
	}	

	// Splitting at equally spaced times if approximation
	if `np'!=0 {
		tempvar attime
		local inter = (`tmax' - `tmin') / `np'
		local whil `tmin'(`inter')`tmax'
		stsplit `attime',at(`whil') nopreserve
		bysort `id' `attime' (_t) : gen long `rset'=1 if _n==_N
		if "`mode'"=="NF"	bysort `id' `timexp' (_t) : replace `rset'=0 if _n==_N
		replace `tsave' = _t if _t<=`tsave'
	}
	
	if "`mode'"=="E" {
	 	bysort `id' `timexp' (_t) : gen long `rset'=0 if _n==_N
		replace `tsave' = _t if _t<=`tsave'
	}

	bysort `id' (_t) : gen double `rate_h' = sum(max(0,`rate'*(`tsave' - _t0)))
	drop `rate'
	bysort `id' (_t): gen byte `n_ini'=_n==1
	keep if `rset' < . | `n_ini'
	bysort `id' (_t) : replace _t0 = _t0[1] if _n==2 & `rset'[1]==.
	keep if `rset'<.
	gen `wei' = 1

	// If late entry and npoints 
	if "`late'"!="" & `np'!=0 {
		drop `rset'
		egen `rset' = group(`attime' `timexp')
	}

	// If no late entry risksets are in sequence 
	if "`late'"==""		bysort `id' (_t) : replace `rset'= _n
		
	if "`at'" != "" local t_at at(`at')
		
	// Adjusting weights if approximation 	
	if `np'!=0 {
		Adj_wei `wei' `tsave' `id' , whil(`whil') `late' `t_at'
	}

	// Ederer method inappropriate with late entry 	
	if "`mode'"=="E" & "`late'"!="" {
		di in red "Late entry detected. Ederer method for expected survival cannot be used."
		exit 184
	}

	// Individual Expected Survival
	if `method'==3 { 
		bysort `id' (_t) :  gen double `w_h' = exp(-`rate_h') * `wei' 
		bysort `id' (_t) : gen double `prev_h' = `w_h'[_n-1] / `wei'[_n-1] * `wei'
		bysort `id' (_t) : replace `prev_h' = 1 * `wei' if _n==1
		// Collapsing and saving the estimates	
		replace `id'=. if `w_h'==0
		Col_save `w_h' `prev_h' `id' `nvar' `rset' , method(`method') mode(`mode') `byby' `t_at' `late'
	}
	else {
		bysort `id' (_t) : gen double `w_h'= (`rate_h'-`rate_h'[_n-1]) * `wei' if _n>1 
		bysort `id' (_t) : replace `w_h'=`rate_h'*`wei' if _n==1 
		replace `id' = . if `w_h'==0
		Col_save `wei' `w_h' `id' `nvar' `rset' , method(`method') mode(`mode') `byby' `t_at' `late'
	}
end

program define Adj_wei
	version 8
	args wei tsave id
	syntax	varlist, whil(string) [ late at(numlist) ]
	tempvar tmi minnp mintc minmin
	egen `tmi'= min(_t0), by(`id')
	bysort `id' (_t) : replace `wei'=max(0,(`tsave'-_t[_n-1])/(_t-_t[_n-1]))
	if "`late'" != "" {
		egen `minnp'=cut(`tmi'), at(`whil')
		gen `minmin' = `minnp'
		if "`at'" != "" {
			egen `mintc'=cut(`tmi'), at(`at')
			replace `minmin' = max(`minnp', `mintc')
		}
		replace `minmin' = min(`minmin',`tmi')
	} 
	else 	gen `minmin' = `tmi'
	bysort `id' (`rset') : replace `wei'=(`tsave'-`tmi')/(_t-`minmin') if _n==1 
end

program define Col_save
	version 8
	args w pr_w id nvar rset
	syntax varlist, method(integer) mode(string) [ by(varlist) at(numlist) late ]
	tempvar tmin n_ini t_at bygr
	egen `tmin'= min(_t0), by(`by')
	egen `n_ini'= sum(_t0==`tmin'), by(`by')
	collapse (sum) `w' `pr_w' (count) atrisk=`id' (median) t_exp=_t (mean) `tmin' `n_ini', by(`rset' `by') fast
	if `method'==3	local expest "exp(sum(log(`w'/`pr_w')))"
	else	local expest "exp(sum(log(exp(-`pr_w'/`w'))))"
	if "`by'"=="" {
		tempvar by
		gen byte `by' = 1
	}
	bysort `by' (t_exp) : gen double `nvar' = `expest'
	bysort `by' : gen byte `bygr' = _n==1
	local obs = _N
	expand 2 if `bygr'
	replace t_exp=`tmin' if _n>`obs'
	replace atrisk=`n_ini' if _n>`obs' 
	replace `nvar'= 1 if _n>`obs'
	if "`mode'"=="NF" | "`mode'"=="E" {
		gen byte `t_at' = 0
		foreach i of local at {
			replace `t_at' = 1 if t_exp==float(`i')
			replace t_exp = `i' if t_exp==float(`i')
		}
	 	keep if `t_at'
		fillin `by' t_exp
		bysort `by' (t_exp) : replace `nvar' = `nvar'[_n-1] if `nvar'==.
		replace atrisk = 0 if atrisk==.
		drop _f
		drop if `nvar'==. 
	}
	label var t_exp "Expected Survival Time"
	label var atrisk "Number at risk"
end
