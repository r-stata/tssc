*! bctobit v1.0.0 DWVincent 10june2010
program bctobit, rclass
	version 10.1
	syntax , [Fixed Nodots bfile(string) reps(integer 499)]  /*Defualt is stochastic regressors with dots*/
	
	if "`e(cmd)'" != "tobit" {
		display as err "bctobit only works after tobit"
		exit 198
	}

	if e(llopt) != 0 | "`e(ulopt)'" != "" {
		display as err "bctobit only works with left censored data"/*
			*/" and with censoring at zero"
		exit 198
	}


/*Compute the LM test statistic from original data*/

	tempvar one xb sxb ssigma slambda lmstar 
	tempname lm 
	qui predict `xb', xb
	local sigma=_b[/sigma]
	qui predict `sxb' `ssigma', scores
	local c=1
	local tobvars: colnames e(b)
	qui foreach var of local tobvars {
		if "`var'"!="_cons" {
			tempvar z`c' g`c'
			gen `z`c''=`var'
			gen `g`c''=`var'*`sxb'
			local g `g' `g`c''
			local z `z' `z`c''
			local c=`c'+1
		}
	}

	qui {
		gen `one'=1
		gen `slambda'=ln(`e(depvar)')-((`e(depvar)'-`xb')/`sigma'^2)*(`e(depvar)'*ln(`e(depvar)')-(`e(depvar)'-1)) if `e(depvar)'>0
		replace `slambda'=normalden(`xb'/`sigma')/(1-normal(`xb'/`sigma'))*(1/`sigma') if `e(depvar)'<=0
		regress `one' `g' `sxb' `ssigma' `slambda', noconstant
		scalar `lm'=e(N)*e(r2)
	}

/*Compute the critical value of the LM-test from the bootstrap null distribution*/

	tempvar xbb sigmab sxbb ssigmab slambdab eb yb ylatb 
	tempname memlm cval10 cval5 cval1 
	tempfile bs_data
	
	if "`bfile'"=="" {
		tempfile simslm
	}
	else {
		local simslm "`bfile'"
	}

	postfile `memlm' lm_bs using `simslm'
	qui preserve
	keep `z' `xb' `one'
	qui save `bs_data'

	if "`nodots'"!="nodots" {
		nois _dots 0, title(Bootstrap replications) reps(`reps')
	}

	qui forvalues i=1(1)`reps' {
	
		if "`fixed'"=="fixed" {	
			clear
			use `bs_data'
			gen `eb'=rnormal(0,`sigma')
			gen `ylatb'=`xb'+`eb'
		}
		else	{
			clear
			use `bs_data'
			bsample
			gen `eb'=rnormal(0,`sigma')
			gen `ylatb'=`xb'+`eb'
		}	
		gen `yb'=max(`ylatb',0)	
		capture tobit `yb' `z', ll iterate(150)

		if e(converged)==1 & _rc==0 {
			if "`nodots'"!="nodots"  {
				nois _dots `i' 0 
			}
			predict `xbb', xb
			gen `sigmab'=_b[/sigma]
			predict `sxbb' `ssigmab', scores
	
			local cb=1
			local gb 
			local tobvars: colnames e(b)
			foreach var of local tobvars {
				if "`var'"!="_cons" {
					tempvar gb`cb'
					gen `gb`cb''=`var'*`sxbb'
					local gb `gb' `gb`cb''
					local cb=`cb'+1
				}
			}
			gen `slambdab'=ln(`e(depvar)')-((`e(depvar)'-`xbb')/`sigmab'^2)*(`e(depvar)'*ln(`e(depvar)')-(`e(depvar)'-1)) if `e(depvar)'>0
			replace `slambdab'=normalden(`xbb'/`sigmab')/(1-normal(`xbb'/`sigmab'))*(1/`sigmab') if `e(depvar)'<=0
			regress `one' `gb' `sxbb' `ssigmab' `slambdab', noconstant
			scalar lm_bs=e(N)*e(r2)			
		}
		else if e(converged)==0 | _rc>0 {
			if "`nodots'"!="nodots" {
				nois _dots `i' 1
			}
			scalar lm_bs=.
		}

		post `memlm' (lm_bs)
	}
	postclose `memlm'

	qui use `simslm', clear
	qui sum lm_bs, detail
	scalar `cval10' = r(p90)
	scalar `cval5' = r(p95)
	scalar `cval1' = r(p99)
	qui restore

	di

	di as txt "LM test of Tobit specification "
		
		di as txt "{col 20}Bootstrap critical values"
		di as txt "{col 5}lm{col 15}%10{col 25}%5{col 35}%1"
		di as res %9.5g `lm' "{col 13}" %6.5f `cval10' /*
			*/ _col(22) `cval5' _col(32) `cval1' 

		ret scalar lm = `lm'
		ret scalar cval10 = `cval10'
		ret scalar cval5 = `cval5'
		ret scalar cval1 = `cval1'
	
end


