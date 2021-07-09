*! version 3.0.4  22jun2004 NJGW
*! brrmodel Nicholas Winter
*
* 3.0.4 fixed to allow no varlist
* 3.0.3 dealt with setting up -predict- after logit/probit style models
* 3.0.2 fixed bug whereby -svyset- settings could interfere with sample used to calculate V_srs for deff/deft
* 3.0.1 fixed display of rep weights bug


* Catch models with no observations or dropped variables
* Skip ftest if dof is negative
* Watch for negative or missing weights
* Set up for appropriate summary stats and saved results, by command
*

prog define svrmodel, eclass
	version 7

	if ~replay() {
		syntax [varlist] [pweight/] [if] [in] , [  /*
				*/ deff deft 	/*
				*/ Cmd(string) Level(int $S_level) or noVL dots ] *

		if "`vl'"!="" {
			local vl "novarlist"
		}

		local dodeff 1

		local rwtype aw				/* use aweights for replicates, except as changed below */
							/* (only changed for poisson)				*/
		
		if "`cmd'"=="" | substr(trim("`cmd'"),1,3)=="reg" {
			local cmd "regress"
			local predict "svyreg_p"
			*local predict "regres_p"
			local model "OLS"
			local svycmd "svyreg"
		}
		else if substr(trim("`cmd'"),1,4)=="prob" {
			local cmd "probit"
			*local predict "probit_p"
			local predict "svrlog_p"
			local dor2 "*"
			local model "Probit"
			local svycmd "svyprobit"
		}
		else if trim("`cmd'")=="logistic" {
			local cmd "logit"
			*local predict "logit_p"
			local predict "svrlog_p"
			local eform "eform(Odds Ratio)"
			local or or				/* set up for odds ratio */
			local dor2 "*"
			local model "Logistic"
			local svycmd "svylogit"
		}
		else if substr(trim("`cmd'"),1,4)=="logi" {
			local cmd "logit"
			*local predict "logit_p"
			local predict "svrlog_p"
			local dor2 "*"
			if "`or'"=="or" {
				local eform "eform(Odds Ratio)"
			}
			local model "Logit"
			local svycmd "svylogit"
		}
		else if substr(trim("`cmd'"),1,5)=="oprob" {
			local cmd "oprobit"
			local predict "svrologit_p"
			local dor2 "*"
			local model "Ordered Probit"
			local svycmd "svyoprobit"
		}
		else if substr(trim("`cmd'"),1,4)=="olog" {
			local cmd "ologit"
			local predict "svrologit_p"
			local dor2 "*"
			local model "Ordered Logit"
			local svycmd "svyologit"
		}
		else if substr(trim("`cmd'"),1,4)=="mlog" {
			if !index("`options'","base(") {
				di as error "must specify base() option to ensure correct mlogit estimation
				exit 198
			}
			local cmd "mlogit"
			local predict "svrmlogit_p"
			local dor2 "*"
			local model "Multinomial Logistic Regression"
			local svycmd "svymlogit"
		}
		else if substr(trim("`cmd'"),1,4)=="pois" {
			local cmd "poisson"
			local predict "poisso_p"
			local dor2 "*"
			local model "Poisson Regression"
			local svycmd "svypois"
			local rwtype pw				/* -poisson- doesn't accept aweights */
		}
		else {
			di as text "`cmd' does not have a {help svy} version;"
			di "design effects not calculated and prediction command not set"
			di
			local dodeff 0
			local deff		/* don't print them! */
			local deft
			local model=upper(substr("`cmd'",1,1))+substr("`cmd'",2,.)
		}

		if !inrange(`level',10,99) {
			di as err "level() must be between 10 and 99 inclusive"
			exit 198
		}

* DEAL WITH Replication Params

		svr_get
		local exp `r(pw)'
		local mainweight `exp'

		local svrweight `r(rw)'
		local svrwspec "`svrweight'"
		local nsvrw `r(n_rw)'

		local fay `r(fay)'
		local dof `r(dof)'

		local method `r(meth)'
		if "`method'"=="jkn" {
			local psusizes `r(psun)'
		}

		local printdeff=cond("`deff'`deft'"!="",1,0)


*RUN THE FULL-SAMPLE COMMAND TO GET overall b-hat

		local depv : word 1 of `varlist'
		marksample touse , `vl'				/* vl contains "novarlist" if noVL option selected */
		tempname totb repb accumV r2

		qui `cmd' `varlist' [pw=`mainweight'] if `touse' , `options'
		local df_m=e(df_m)
		scalar `r2'=e(r2)
		
		if "`cmd'"=="oprobit" | "`cmd'"=="ologit" | "`cmd'"=="mlogit" {
			tempname cats k_cat
			matrix `cats' = e(cat)
			scalar `k_cat' = e(k_cat)
		}

		if "`cmd'"=="mlogit" {
			tempname basecat ibasecat
			scalar `basecat' = e(basecat)
			scalar `ibasecat' = e(ibasecat)
			local eqnames `"`e(eqnames)'"'
		}

		matrix `totb'=get(_b)
		local nb = colsof(`totb')
		mat `accumV' = J(`nb',`nb',0)


*DO REPLICATES

		local rfac 1
		forval rep = 1/`nsvrw' {
			if "`dots'"!="" {
				di "." _c
			}
			local curw : word `rep' of `svrwspec'
			qui `cmd' `varlist' [`rwtype'=`curw'] if `touse', `options'
			matrix `repb'=e(b)
			matrix `repb'=`repb'-`totb'						/* turn into deviation */
			if "`method'"=="jkn" {
				local rfac : word `rep' of `psusizes'
				local rfac = ((`rfac'-1)/`rfac')
			}
			matrix `accumV' = `accumV' + (`rfac')* ((`repb'')*(`repb'))		/* add this one:  (b_k - b_tot)'(b_k - b_tot) */
														/* NOTE: Stata stores b as ROW vector, so b'b is  */
														/*       OUTER product, not inner				*/
		}
		if "`dots'"!="" {
			di
		}

		tempname scalefac
		if "`method'"=="brr" {
			scalar `scalefac' = 1 / (`nsvrw' * (1-`fay')^2 )
		}
		else if "`method'"=="jk1" {
			scalar `scalefac' = (`nsvrw'-1)/`nsvrw'
		}
		else if "`method'"=="jk2" {
			scalar `scalefac' = 1
		}
		else if "`method'"=="jkn" {
			scalar `scalefac' = 1
		}

		matrix `accumV'=`accumV' * `scalefac'

		qui count if `touse'
		local N `r(N)'


		tempname N_pop
		qui sum `mainweight' if `touse'
		scalar `N_pop'=`r(sum)'

*CALCULATE F STAT FOR FULL MODEL
		tempname b D F aug
		mat `b' = `totb''			/* column vector! */
		if `df_m'>0 {
			mat `D' = I(`df_m')			/* i.e. number of variables in b */
			local nextra = rowsof(`b')-`df_m'
			mat `aug' = J(`df_m',`nextra',0)
			mat `D' = `D' , `aug'
			mat `F'= (`D'*`b')' * inv(`D'*`accumV'*`D'') * (`D'*`b') * ( (`dof'-`df_m'+1) / (`dof'*`df_m') )
		}
		else mat `F' = (0)

*USE SVY-BASED COMMAND TO GET SRS VARIANCE FOR DEFF

		if `dodeff' {
			
			svy_get pweight, optional		/* store svy options in order to restore */
			local svy_pw = "$S_1"
			svy_get strata, optional
			local svy_str = "$S_1"
			svy_get psu, optional
			local svy_psu = "$S_1"
			svy_get fpc, optional
			local svy_fpc = "$S_1"
			
			svyset , clear
			
			qui `svycmd' `varlist' [pw=`mainweight'] if `touse' , `options'

			svyset, clear
			qui svyset pweight `svy_pw'
			qui svyset strata `svy_str'
			qui svyset psu `svy_psu'
			qui svyset fpc `svy_fpc'

*			if "`svy_pw'"=="" {				/* restore svyset's pweight to whatever it was */
*				svyset pweight, clear
*			}
*			else {
*				svyset pweight `svy_pw'
*			}

			tempname V_srs deff deft
			matrix `V_srs'=e(V_srs)
			local i = colsof(`V_srs')
			matrix `deff' = vecdiag(`accumV')
			matrix `deft' = `deff'
			forval j=1/`i' {
				matrix `deff'[1,`j']=`deff'[1,`j']/`V_srs'[`j',`j']
				matrix `deft'[1,`j']=sqrt(`deff'[1,`j'])
			}
		}

*POST RESULTS!


		estimates post `totb' `accumV' , dof(`dof') depn(`depv') obs(`N') esample(`touse')

		est scalar N_pop=`N_pop'
		est scalar N_reps=`nsvrw'
		est scalar df_m=`df_m'
		est scalar N_psu=`dof'*2			/* cludge to get svytest to work appropriately */
		est scalar N_strata=`dof'			/* ditto */
		est scalar F=`F'[1,1]
		`dor2' est scalar r2=`r2'
		
		if "`k_cat'"!="" {
			est scalar k_cat = `k_cat'
			est matrix cat = `cats'
		}
		if "`cmd'"=="mlogit" {
			est scalar basecat = `basecat'
			est scalar ibasecat = `ibasecat'
			est local eqnames `"`eqnames'"'
		}

		est local svr_method "`method'"
		est local svr_wspec "`svrwspec'"
		est local pweight "`mainweight'"
		est local depvar "`depv'"
		est local predict "`predict'"
		est local model "`model'"
		est local cmd "svysvrmodel"		/* svy at beginning to get svytest to accept results */
		
			

		if `dodeff' {
			est matrix deff `deff'
			est matrix deft `deft'
			est matrix V_srs `V_srs'
		}

	}
	else {							/* this is a re-display */
		if "`e(cmd)'"!="svysvrmodel" {
			error 301
		}
		syntax [, Level(integer $S_level) or deff deft ]
		if !inrange(`level',10,99) {
			di as err "level() must be between 10 and 99 inclusive"
			exit 198
		}
		if "`or'"=="or" {
			local eform "eform(Odds Ratio)"
		}
		if "`deff'`deft'"!="" {
			tempname df dt
			capture matrix `df' = e(deff)
			if _rc {
				di as text "No deff matrix estimated; deff not printed"
				di
				local printdeff 0
			}
			else {
				matrix `dt' = e(deft)
				local printdeff 1
			}
		}
		else {
			local printdeff 0
		}

	}

*DISPLAY RESULTS

	di
	di "{txt}`e(model)' estimates with replicate-based (`e(svr_method)') standard errors"
	di
	di "{txt}Analysis weight:      `e(pweight)'" _c
	di "{col 48}Number of obs       ={res}{ralign 10:`e(N)'}"

	if length(`"`e(svr_wspec)'"')<=24 {
		di "{txt}Replicate weights:" _col(23) "`e(svr_wspec)'" _c
	}
	else {
		local part : word 1 of `e(svr_wspec)'
		di "{txt}Replicate weights:" _col(23) `"{stata svrset list rw:`part'...}"' _c
	}

	di _col(48) "{txt}Population size" _col(68) "={res}" %10.0g `e(N_pop)'

	di "{txt}Number of replicates: `e(N_reps)'" _c
	di "{txt}{col 48}Degrees of freedom{col 68}={res}{ralign 10:`e(df_r)'}"

	local df_d=e(df_r)-e(df_m)+1
	local dispF : di %3.2f e(F)

	if "`e(svr_method)'"=="brr" {
		di "{txt}k (Fay's method):     " %4.3f `fay' _c
	}
	di "{txt}{col 48}F({res}{ralign 4:`e(df_m)'}{txt},{res}{ralign 7:`df_d'}{txt})     ={res}{ralign 10:`dispF'}"

	local prob=Ftail(`e(df_m)',`df_d',`e(F)')
	local prob : di %5.4f `prob'
	di "{txt}{col 48}Prob > F{col 68}={res}{ralign 10:`prob'}"

	local r2 : di %5.4f e(r2)
	if `r2'!=. {
		di `"{txt}{col 48}R-squared{col 68}={res}{ralign 10:`r2'}"'
	}
	di

	estimates display, level(`level') `eform'

	if `printdeff' {

		tempname df dt
		matrix `df'=e(deff)
		matrix `dt'=e(deft)
		tempname v

		di
		di "{hline 13}{c TT}{hline 22}"
		di %12s abbrev("`depv'",12) " {c |}      Deff       Deft"
		di "{hline 13}{c +}{hline 22}"

		local names : colnames `df'
		local i=colsof(`df')
		forval i=1/`i' {
			local vn : word `i' of `names'
			di "{txt}" %12s abbrev("`vn'",12) " {c |}" _c
			scalar `v'=`df'[1,`i']
			di "  {res}" %9.0g `v' _c
			scalar `v'=`dt'[1,`i']
			di "  " %9.0g `v'
		}
		di "{txt}{hline 13}{c BT}{hline 22}"

	}


end


