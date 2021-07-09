*! version 1.1.7  26Jun2017
*! Directly standardized rates with improved confidence intervals
program define distrate, rclass
	version 9.0
	syntax varlist(min=2 max=2) [if] [in] using/ , STANDstrata(varlist) ///
                 [ BY(varlist) REFrate(integer 1) POPSTAND(name) FAY DOBSON MULT(numlist integer max=1) Format(string) /// 
                   LIst(namelist) SAving(string asis) Level(integer $S_level) FORMATN(integer 0) SEPBY(varlist) PREfix(string) POSTfix(string) ]

/* Relevant sample */
	marksample touse
	markout `touse' `by' `standstrata', strok
	tokenize `varlist'
	local death `1'
	local studypop `2'
	cap assert `death' <= `studypop'
	if _rc {
		di as err "Number events in `death' cannot be greater than population specified in `studypop'."
		exit 459 
	}

*	confirm file `"`using'.dta"'
	if index("`using'", ".") == 0 {
		local using = `"`using'"' + ".dta"
	}
	confirm file `"`using'"'

/* Check that format is valid */
	if "`format'" != "" {
		if index("`format'",",") local format = subinstr("`format'", "," , "." , 1) /* european numeric format */
		local fmt = substr("`format'",index("`format'",".")-1,3) 
		capture {
			assert substr("`format'",1,1)=="%" & substr("`format'",2,1)!="d" ///
				& substr("`format'",2,1)!="t" & index("`format'","s")==0
			confirm number `fmt'
		}
		if _rc {
			di as err "invalid format. format has been set to default %6.4f"
		}
	}

	if "`saving'" != "" {
		gettoken stfile saving : saving, parse(",")
		gettoken comma saving  : saving, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrgro saving : saving, parse(" ,")
			gettoken comma saving : saving, parse(" ,")
			if `"`outrgro'"' != "replace" | `"`comma'"'!="" { 
				di as err "option saving() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			di as err "option saving() invalid"
			exit 198
		}
		else 	confirm new file `"`stfile'.dta"'
	}
	preserve
	qui keep if `touse'
	qui keep `death' `studypop' `standstrata' `by'
	if "`by'"== "" {
		tempvar by
		g byte `by' = 1
		local nby y
	}

	local n_vby = wordcount("`by'")
	if `n_vby'>1 {
		local bylast = word("`by'",-1)
		local byref : list by - bylast
		local byref "bysort `byref' (`bylast') :"
	}

	if "`mult'"!="" {
		local per "(per `mult')"
		local mult "*`mult'"
	}
	if "`sepby'"!="" local sepby "sepby(`sepby')"  

/* Data must be in appropriate aggregate form */ 
	collapse (sum) `death' `studypop', by(`standstrata' `by')
	tempvar ckstr rate sumpop 

/* Check that all standstrata strata are present in each by level */
	bysort `by' : g `ckstr' = _N
	cap assert `ckstr' == `ckstr'[_n-1] if _n>1
	if _rc {
		di in red "Some strata across which to average the stratum-specific rates are not present in some `by' level." 
		exit 459 
	}
	local J = `ckstr'

/* Define popstand */
	if "`popstand'"=="" | "`popstand'"=="`studypop'"{
		local popstand `studypop'
		tempvar stpop
		g `stpop' = `studypop'
		drop `studypop'
		local studypop `stpop'
	}

	g double `rate' = `death'/`studypop'
	sort `standstrata'
	qui merge `standstrata' using "`using'"
	
/* Print a warning message if any records do not match with standard population file and exit */
	cap assert _merge==3
	if _rc {
		count if _m!=3
		di in red "`r(N)' records fail to match with standard population file " ///
			"(records who do not match are saved to _merge_error_.dta)."
		qui keep if _merge!=3
		qui save _merge_error_.dta, replace
		exit 459 
	}
	drop _m
	
	tempvar w var vartiw wfay ratetiw vardob woldfay yl yu 
	qui {
		egen `sumpop' = sum(`popstand'), by(`by') 
		g double `w' = `popstand'/ `sumpop'
		g double rateadj = `rate'*`w' 
		g double `wfay' = `w'/`studypop'
		g double `var' = `death' * `wfay'^2
		g double `vartiw' = (`death'+1/`J') * `wfay'^2
		g double `vardob'=`popstand'^2*`rate'/`studypop' 
		collapse (sum) `death' `studypop' `popstand' rateadj `var' `vartiw' `vardob' (mean) `wfay' (max) `woldfay'=`wfay', by(`by')  // Tiwary correction -mean-
		g double crude      = `death'/`studypop' `mult' 
		g double `ratetiw' = rateadj + `wfay'
		g double lb_gam = (`var'/(2*rateadj))*invchi2(2*rateadj^2/`var',1-(.5+`level'/200)) `mult'
		replace  lb_gam = 0 if `death'== 0 
		g double ub_gam = (`vartiw'/(2*`ratetiw')) * ///
			invchi2((2*`ratetiw'^2)/`vartiw',.5+`level'/200) `mult'

		if "`fay'"!= "" {
			g double ub_fay = ((`var' + `woldfay'^2)/(2*(rateadj+`woldfay'))) * ///
				invchi2((2*(rateadj+`woldfay')^2)/(`var'+`woldfay'^2),.5+`level'/200) `mult'
			local ubfay ub_fay
		}
		replace `vardob' = `vardob'/`popstand'^2
		g double `yl' = .
		g double `yu' = .
		count
		local n = r(N)
		forval i = 1/`r(N)' {
			_crccip `death'[`i'] `level'
			replace `yl' = `r(lower)' if _n == `i'
			replace `yu' = `r(upper)' if _n == `i'
		}
		g double ub_dob= (rateadj+(`yu'-`death')*sqrt(`var'/`death')) `mult' 
		g double lb_dob= (rateadj+(`yl'-`death')*sqrt(`var'/`death')) `mult'

		if "`nby'"=="" {
			if rateadj[`refrate']==0 {
				di in red "WARNING. Ratios of Directly Standardized Rates cannot be computed because" ///
				" the standardized rate in the denominator is 0."
				di in red "You can specify a different standardized rate in the denominator by using refrate(#) option."
			}
			`byref' g double srr = rateadj/rateadj[`refrate']
			`byref' g double lb_srr = cond(rateadj!=0,(rateadj/`ratetiw'[`refrate']) * invF(2*rateadj^2/`var', ///
				2*`ratetiw'[`refrate']^2/`vartiw'[`refrate'],1-(.5+`level'/200)),0)
			`byref' g double ub_srr = (`ratetiw'/rateadj[`refrate']) * invF(2*`ratetiw'^2/`vartiw',2*rateadj[`refrate']^2/`var'[`refrate'],.5+`level'/200)
			`byref' replace lb_srr = . if _n==`refrate'
			`byref' replace ub_srr = . if _n==`refrate'
			local stratio srr lb_srr ub_srr
		}

		replace rateadj = rateadj `mult'
	}
	if "`nby'"!="" local by
*	g double se_F = sqrt(`var')`mult'  // based on Fay and Feuer formula
	g double se_gam = sqrt(`vartiw')`mult'  
	if "`format'" != "" format crude rateadj lb_g ub_g lb_dob ub_dob se_gam `stratio' `ubfay' `format'
	tempname NDeath Nobs Crude Adj Se_gam Ub_G Lb_G Ub_D Lb_D 
	if "`fay'"!= "" tempname Ub_F 
	if "`stratio'"!= "" tempname SRR Lb_S Ub_S
	mat `Ub_D'=J(1,`n',0)
	mat `Lb_D'=J(1,`n',0)
	mat `Ub_G'=J(1,`n',0)
	mat `Lb_G'=J(1,`n',0)
	mat `Crude'=J(1,`n',0)
	mat `Adj'=J(1,`n',0)
	mat `Se_gam'=J(1,`n',0)
	mat `NDeath'=J(1,`n',0)
	mat `Nobs'=J(1,`n',0)
	if "`fay'"!= "" 	mat `Ub_F'=J(1,`n',0)
	if "`stratio'"!= "" {
		mat `SRR'=J(1,`n',0)
		mat `Lb_S'=J(1,`n',0)
		mat `Ub_S'=J(1,`n',0)
	}
	forval i = 1 / `n' {
			mat `NDeath'[1,`i']=`death'[`i']
			mat `Nobs'[1,`i']=`studypop'[`i']
			mat `Crude'[1,`i']=  cond(crude[`i']==.,9,crude[`i']) 
			mat `Adj'[1,`i']= cond(rateadj[`i']==.,9,rateadj[`i'])
			mat `Se_gam'[1,`i']= cond(`vartiw'[`i']==.,9,sqrt(`vartiw'[`i'])) 
			mat `Ub_G'[1,`i']= cond(ub_gam[`i']==.,9,ub_gam[`i']) 
			mat `Lb_G'[1,`i']= cond(lb_gam[`i']==.,9,lb_gam[`i']) 
			mat `Ub_D'[1,`i']= cond(ub_dob[`i']==.,9,ub_dob[`i']) 
			mat `Lb_D'[1,`i']= cond(lb_dob[`i']==.,9,lb_dob[`i']) 
			if "`fay'"!= "" 	mat `Ub_F'[1,`i']= cond(ub_fay[`i']==.,9,ub_fay[`i']) 
			if "`stratio'"!= "" {
				mat `SRR'[1,`i']= cond(srr[`i']==.,9,srr[`i']) 
				mat `Lb_S'[1,`i']= cond(lb_srr[`i']==.,9,lb_srr[`i']) 
				mat `Ub_S'[1,`i']= cond(lb_srr[`i']==.,9,ub_srr[`i']) 
			}
	}
	ret scalar k = `n'
	return mat ub_D `Ub_D'
	return mat lb_D `Lb_D'
	if "`fay'"!= ""  return mat ub_F `Ub_F'
	return mat se_gam `Se_gam'
	return mat ub_G `Ub_G'
	return mat lb_G `Lb_G'
	if "`stratio'"!= "" {
		return mat srr `SRR'
		return mat lb_srr `Lb_S'
		return mat ub_srr `Ub_S'
	}
	rename `studypop' N
	return mat adj `Adj'
	return mat crude `Crude'
	return mat NDeath `NDeath'
	if "`dobson'"!=""{
		local dd " and as proposed by Dobson et al"
		local dlist "lb_dob ub_dob"
	}
	if "`fay'"!=""	local fd ". Fay and Feuer previous upper bound (ub_fay) also displayed."
	
	if `formatn' > 0 {
		if `formatn'<16 format N %`formatn'.0f
	}
	di as txt "Directly standardized rates `per'"
di as txt "CI based on the gamma distribution (Fay and Feuer, 1997. Tiwari and al., 2006)`dd'`fd'"
	if "`list'"=="" list `by' `death' N crude rateadj lb_g ub_g `ubfay' se_gam `stratio' `dlist', noobs table `sepby'
	else {
		foreach name of local list {
			cap confirm var `name'
			if _rc    di as err "WARNING: `name' invalid or ambiguous in list option" 
			else	{
				unab ilist: `name'
				local tolist "`tolist' `ilist'"
			}
		}
		if "`by'" != "" local tolist : list tolist - by
		list `by' `tolist', noobs table `sepby'
	}
	if "`stfile'" != "" {
		di
		keep `by' `death' N crude rateadj lb_g ub_g `ubfay' lb_dob ub_dob se_gam `stratio'
		label var `death'	"Events"
		label var N		"Study Population"
		label var crude		"Crude Rate"
		label var rateadj	"Directly Adjusted Rate"
		label var lb_g		"Lower Tiwari, Clegg and Zou bound" 
		label var ub_g		"Upper Tiwari, Clegg and Zou bound" 
		label var lb_dob	"Lower  DKES (Dobson et al) bound" 
		label var ub_dob	"Upper DKES (Dobson et al) bound" 
		label var se_gam	"Standard Error (Tiwari, Clegg and Zou)"
		if "`stratio'" != "" {
			label var srr "Ratio of Directly Adjusted Rates"
			label var lb_srr "LB of Ratio of Directly Adjusted Rates"  
			label var ub_srr "UB of Ratio of Directly Adjusted Rates"
		}
		if "`fay'"!="" label var ub_fay	"Upper Fay and Feuer bound"  
		label data		"Directly Standardized Rates `per'"
		order `by' `death' N crude rateadj lb_g ub_g se_gam lb_dob ub_dob 
		if "`postfix'" != "" | "`prefix'" != "" {
			foreach var of varlist crude rateadj lb_g ub_g lb_dob ub_dob se_gam  `ubfay' `stratio' {
				rename `var' `prefix'`var'`postfix'
			}
		}
		save `stfile', `outrgro'
	}
end

program define _crccip, rclass
	version 6
	tempname f fp x k topk lev
* touched by kth  -- double saves in r() and S_#
* touched by jml -- fix algorithm
	scalar `k'= `1'
	scalar `lev' = (100-`2')/200
	scalar `x' = `k'
	if `x'== 0 {
		scalar `x' = .1  /* need a better starting point */
	}
	scalar `f' = 1-gammap(`k'+1,`x') - `lev'	/* Pr(k or fewer)*/
	while ((abs(`f')> 1e-8)&(`x' < .)) { 
		scalar `fp'= -dgammapdx(`k'+1,`x')
		scalar `x' = `x' - `f'/`fp'
		scalar `f' = 1-gammap(`k'+1,`x') - `lev'
	}
	global S_2 : di %16.0g `x'
	ret scalar upper = `x'
	if `k'==0 { 
		global S_1 0
		ret scalar lower = 0
		exit
	}
	scalar `x' = `k'
	scalar `topk'= `k'
	scalar `f' = gammap(`k',`x') - `lev'	/* Pr(k or more)	*/
	while ((abs(`f') > 1e-8)&(`x'<.)) { 
		scalar `fp'=dgammapdx(`k',`x')
		scalar `x' = `x' - `f'/`fp'
		if `x'<0 { 
			scalar `x' = 0 
		}
		else if `x'>`topk' { 
			scalar `topk' = `topk' - .1
			scalar  `x'= `topk'
		}
		scalar `f' = gammap(`k',`x') - `lev'
	}
	global S_1 : di %16.0g `x' 
	ret scalar lower = `x'
end
