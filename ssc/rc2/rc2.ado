*! version 1.0, 23Sep2004, John_Hendrickx@yahoo.com
/*
Direct comments to:

John Hendrickx <John_Hendrickx@yahoo.com>

Version 1.0, September 23, 2004
based on -mclest-, -rc2- estimates Goodman's row and columns model 2
using -poisson-.
*/

program define rc2, eclass
	version 7
	syntax [if] [in] [fweight iweight]        /*
*/   , Row(varname) Col(varname) [ Muby(varlist) MUBY3(string) /*
*/      noNOrm EQ                   /*
*/      NITER(integer 20) RCTOL(real 0.0001) DEBUG]

	if e(cmd) ~= "glm" & e(cmd) ~= "poisson"  {
		display as error "Estimate a baseline loglinear model using {hi:poisson} or {hi:glm} before running {hi:rc2}"
		exit
	}
	if e(cmd) == "glm" {
		if e(linkt) ~= "Log" | e(varfunct) ~= "Poisson" {
			display as error "Use {hi:link(log)} and {hi:family(poisson)} to estimate a loglinear baseline model"
			exit
		}
	}

	foreach x in __sig __phi* __msig* __mu __summu __muby* {
		capture drop `x'
	}
	capture estimates drop c0_1

	tempname LL0 df0
	if "`e(model)'" == "" {
		* no previous run of -rc2-, save baseline model information
    	global RC_depvar `e(depvar)'
    	global RC_base $S_1
    	scalar `LL0'=e(ll)
    	scalar `df0'=e(df_m)
    }
    else {
    	* copy loglikelihood information from previous run
    	scalar `LL0'=e(ll_b)
    	scalar `df0'=e(df_b)
    }

	if "`weight'" ~= "" {
		local weight="[`weight'`exp']"
	}
	global row "`row'"
	global col "`col'"
	global if "`if'"
	global in "`in'"
	global weight "`weight'"
	if "`debug'"  ==  "" {global debug="quietly "}

	global iter=0
	global prev=e(ll)
	global chng=9999
	global lft=0
	global rgt=0
	global cen=0

	quietly tab `col'
	global colcat `r(r)'
	quietly tab $row
	global rowcat `r(r)'
	if "`eq'" ~= "" & $rowcat ~= $colcat {
		display as error "The number of rows ($rowcat) is not the same as the number of columns ($colcat)."
		display as error "The {hi:eq} option will be ignored"
		local eq ""
	}

	* simple sigma and phi scales
	gen __sig=($row-1)/($rowcat-1)
	label var __sig "sigma"
	gen __phi=($col-1)/($colcat-1)
	label var __phi "phi"
	if "`eq'" == "" {
		display _newline as text "Estimating rc2 effects between $row and $col" _newline
	}
	else {
		display _newline as text "Estimating equal rc2 effects for $row and $col" _newline
	}
	gen __mu=__sig*__phi
	gen __summu=0
	if "`muby3'" ~= "" {
 		global todroplater : char _dta[__xi__Vars__To__Drop__]
 		char _dta[__xi__Vars__To__Drop__]
 		global muby="`muby3'"
 		display as text "mu interacts with dummies created by command: xi3 , prefix(_M) `muby3'"
 		capture drop _M*
		$debug xi3 , prefix(_M) `muby3'
	}
	else if "`muby'" ~= "" {
 		global muby="`muby'"
		local xicmd="$debug xi , prefix(_M)"
		foreach var of varlist `muby' {
			local xicmd="`xicmd' i.`var'"
			display as text "mu varies by `var'"
		}
 		capture drop _M*
		`xicmd'
	}
	if "$muby" ~= "" {
		local i=0
		foreach var of varlist _M* {
			local i=`i'+1
			gen __muby`i'=`var'*__mu
			local lbl: variable label `var'
			label variable __muby`i' "`lbl'*mu"
			global mubylst="$mubylst __muby`i'"
		}
	}

	* estimate the model here:
	if "`eq'" == "" {
		forval i=2/$colcat {
			gen __phi`i'=($col==`i')*__sig
		}
		forval i=2/$rowcat {
			gen __msig`i'=($row==`i')*__phi
		}
	}
	else {
		forval i=2/$rowcat {
			quietly gen __msig`i'=($row==`i')*__phi+($col==`i')*__sig
		}
	}
	display as text "{hline  70}"
	display as text "iteration {col 17}log likelihood {col 40}sub-changes {col 59}main changes"
	display as text "{hline  70}"
	local conv=0
	if "`eq'" == "" {
		while `conv' ~= 1 {
			leftest
			rightest
			if "$muby" ~= "" { cenest }
			if abs($chng) < `rctol' {local conv=1}
			if $iter >= `niter' {local conv=1}
		}
	}
    else {
		while `conv' ~= 1 {
			eq1est
			eq2est
			if abs($chng) < `rctol' {local conv=1}
			if $iter >= `niter' {local conv=1}
		}
	}

	display as text "{hline  70}"
	if abs($chng) >= `rctol' {
		display as text "Maximum number of `niter' iterations reached without convergence"
	}
	else {
		display as text "Convergence criterion `rctol' reached in $iter iterations"
	}
	display _newline

	* estimate the final model using the phi and sigma scales
	finmod , `eq'
	* save the phi and sigma scales
	savescl

	if "`norm'" ~= "nonorm" {
		estimates hold c0_1

		* normalize the phi and sig matrices created by -savescl-
		tempname w v sig_d phi_d
		mat `sig_d' = sig-J($rowcat,$rowcat,1/$rowcat)*sig
		mat svd sig_n `w' `v' = `sig_d'
		mat `phi_d' = phi-J($colcat,$colcat,1/$colcat)*phi
		mat svd phi_n `w' `v' = `phi_d'

		forval i=1/$rowcat {
			quietly replace __sig=sig_n[`i',1] if $row==`i'
		}
		forval i=1/$colcat {
			quietly replace __phi=phi_n[`i',1] if $col==`i'
		}
		finmod, normalized `eq'
		* save the phi and sigma scales
		estimates matrix phi_n phi_n
		estimates matrix sig_n sig_n
	}

	* summarize improvement in model fit
	tempname improv df_m df_c prob_c df ncases prob bic aic
	$debug poisgof
	scalar `df'=r(df)

	scalar `improv'=2*(e(ll)-`LL0')
	if "`eq'" ~= "" {
		scalar `df_m'=e(df_m)+$rowcat-2
		scalar `df'=`df'-$rowcat+2
	}
	else {
		scalar `df_m'=e(df_m)+$rowcat+$colcat-4
		scalar `df'=`df'-$rowcat-$colcat+4
	}
	scalar `df_c'=`df_m'-`df0'
	scalar `prob_c'=chiprob(`df_c',`improv')

	tempvar sumfreq
	gen `sumfreq'=sum(`e(depvar)')
	scalar `ncases'=`sumfreq'[_N]

	scalar `prob'=chiprob(`df',r(chi2))
	scalar `ncases'=`sumfreq'[_N]
	scalar `bic'=r(chi2)-`df'*ln(`ncases')
	scalar `aic'=r(chi2)-2*`df'

	local linewd: set linesize
	local colpos=`linewd'-14
	local model "rc2"
	if "`eq'" ~= "" {local model "eqrc2"}

	display _newline"{.-}{text:Model summary}{.-}"
	display "{text:Baseline model log likelihood}"  as result _col(`colpos') %15.4f `LL0'
	display "{text:Baseline model model df}"        as result _col(`colpos') %15.0f `df0'
	display "{text:`model' model log likelihood}"   as result _col(`colpos') %15.4f e(ll)
	display "{text:`model' model df}"               as result _col(`colpos') %15.0f `df_m'
	display "{text:Chi-square improvement}"         as result _col(`colpos') %15.4f `improv'
	display "{text:df change}"                      as result _col(`colpos') %15.0f `df_c'
	display "{text:significance}"                   as result _col(`colpos') %15.4f `prob_c'
	display "{text:`model' model deviance}"         as result _col(`colpos') %15.4f r(chi2)
	display "{text:`model' model residual df}"      as result _col(`colpos') %15.0f `df'
	display "{text:`model' model prob}"             as result _col(`colpos') %15.4f `prob'
	display "{text:`model' model bic}"              as result _col(`colpos') %15.4f `bic'
	display "{text:`model' model aic}"              as result _col(`colpos') %15.4f `aic'
	display "{text:Number of cases}"                as result _col(`colpos') %15.0f `ncases'
	display "{.-}"

	estimates matrix phi phi
	estimates matrix sig sig
	estimates scalar df_m=`df_m'
	estimates scalar deviance=r(chi2)
	estimates scalar df=`df'
	estimates scalar ll_b=`LL0'
	estimates scalar df_b=`df0'
	estimates local model "`model'"

	* cleanup
	if "$todroplater" ~= "" {
		local todrop : char _dta[__xi__Vars__To__Drop__]
		char _dta[__xi__Vars__To__Drop__] "`todrop' $todroplater"
	}
	foreach mat in phi sig phi_n sig_n {
		capture matrix drop `mat'
	}

	macro drop chng col colcat debug if in iter lft muby muby3 mubylst
	macro drop niter prev rctol rgt row rowcat cen todroplater weight
end

program define leftest
	version 7
	* given phi[j], estimate sigma[v]*(mu+mu[t]X[t])
	$debug poisson $RC_depvar $RC_base __msig2-__msig$rowcat $weight $if $in

	global iter=$iter+1
	local chng1=e(ll)-$prev
	global chng=e(ll)-$lft
	global lft =e(ll)
	global prev=e(ll)
	display as result $iter.1 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	* update the sig scale
	forval i=2/$rowcat {
		quietly replace __sig=_b[__msig`i']/_b[__msig$rowcat] if $row == `i'
	}

	if "$muby" ~= "" {
		if $iter == 1 { quietly replace  __summu=_b[__msig$rowcat] }
		quietly replace __summu=__summu*__sig
	}
    else {
      quietly replace __summu=_b[__msig$rowcat]*__sig
    }

	forval i=2/$colcat {
		quietly replace __phi`i'=__summu*($col==`i')
	}

end

program define rightest
	version 7
	* estimate phi[j], given sigma[v]*(mu+mu[t]*X[t])
	$debug poisson $RC_depvar $RC_base __phi2-__phi$colcat $weight $if $in

	local chng1=e(ll)-$prev
	global chng=e(ll)-$rgt
	global rgt =e(ll)
	global prev=e(ll)
	display as result $iter.2 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	* update the phi variate
	forval i=2/$colcat {
		quietly replace __phi=_b[__phi`i']/_b[__phi$colcat] if $col == `i'
	}

	forval i=2/$rowcat {
		quietly replace __msig`i'=__phi*($row==`i')
	}
end

program define cenest
	version 7
	* given phi[j] and sigma[v], estimate mu and mu[t]
	* multiply the muby dummies by __mu
	quietly replace __mu=__sig*__phi
	* make dummies with the muby variables
	local i=0
	foreach var of varlist _M* {
		local i=`i'+1
		quietly replace __muby`i'=`var'*__mu
	}

	$debug poisson $RC_depvar $RC_base __mu $mubylst $weight $if $in

	local chng1=e(ll)-$prev
	global chng=e(ll)-$cen
	global cen =e(ll)
	global prev=e(ll)
	display as result $iter.3 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	quietly replace __summu=_b[__mu]
	local i=0
	foreach var of varlist _M* {
		local i=`i'+1
		quietly replace __summu=__summu+`var'*_b[__muby`i']
	}

	* redefine the __msig values
	forval i=2/$rowcat {
		quietly replace __msig`i'=($row==`i')*__phi*__summu
	}
end

program define eq1est
	version 7
	* treat phi=sig as given
	* estimate mu, and mu["t"]
	$debug poisson $RC_depvar $RC_base __mu $mubylst $weight $if $in
	global iter=$iter+1

	local chng1=e(ll)-$prev
	global chng=e(ll)-$cen
	global cen =e(ll)
	global prev=e(ll)
	display as result $iter.1 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	quietly replace __summu=_b[__mu]
		if "$muby" ~= "" {
		local i 0
		foreach var of varlist _M* {
			local i=`i'+1
			quietly replace __summu=__summu+`var'*_b[__muby`i']
		}
	}

	* redefine the __msig values
	#delimit ;
	forval i=2/$rowcat {
		quietly replace __msig`i'=($row==`i')*__phi*__summu+
				                      ($col==`i')*(__sig*__summu);
	};
	#delimit cr
end

program define eq2est
	version 7
	* treat mu, and mu["t"] as given
	* estimate phi["j"]=sig["i"]
	$debug poisson $RC_depvar $RC_base __msig2-__msig$rowcat $weight $if $in

	local chng1=e(ll)-$prev
	global chng=e(ll)-$lft
	global lft= e(ll)
	global prev=e(ll)
	display as result $iter.2 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	* update the phi and sig scales
	tempvar signew
	gen `signew'=__sig
	tempvar phinew
	gen `phinew'=__phi
	forval i=2/$rowcat {
		quietly replace `signew'=_b[__msig`i']/_b[__msig$rowcat] if $row == `i'
		quietly replace `phinew'=_b[__msig`i']/_b[__msig$rowcat] if $col == `i'
	}
	quietly replace __sig=(`signew'+__sig)/2
	quietly replace __phi=(`phinew'+__phi)/2

	quietly replace __mu=__sig*__phi
	if "$muby" ~= "" {
		local i 0
		foreach var of varlist _M* {
			local i=`i'+1
			quietly replace __muby`i'=`var'*__sig*__phi
		}
	}
end

program define savescl
	version 7
	preserve
	args row col
	collapse(min) __phi __sig, by($row $col)
	mkmat __phi if $row==1, matrix(phi)
	mkmat __sig if $col==1, matrix(sig)
	restore
end

program define prhd
	version 7
	display _newline as text "{hline 37}{c TT}{hline 41}"
	display as text "{col 38}{c |}{col 45}Coef. {col 53}Std. Err. {col 69}z {col 75}P>|z|"
	display as text "{hline 37}{col 38}{c +}{hline 41}"
end

program define prsnt
	version 7
	* `efnm' is the effect name
	* `var' is the variable name
	args efnm var
	local thislab: variable label `var'
	local thislab=substr("`thislab'",1,36)
	local z=_b[`var']/_se[`var']
	local prob=2*(1-normprob(abs(`z')))
	display as text "`thislab' {col 38}{c |}" as result _col(42) %8.4f  _b[`var'] /*
*/  _col(53) %8.4f _se[`var'] _col(64) %8.4f `z' _col(72) %8.4f `prob'
end

program define finmod
	version 7
	syntax [ , NORMalized EQ ]
	if "`normalized'" ~= "" {local normalized "Normalized "}
	if "`eq'" ~= "" {
		label variable __mu "mu: eqRC2 assoc $row & $col"
		display _newline as text "`normalized'Sigma/Phi scale for $row and $col:"
		tabdisp $row, cell(__sig) format(%8.4f)
	}
	else {
		label variable __mu "mu: RC2 assoc $col & $row"
		display _newline as text "`normalized'Sigma scale for $row:"
		tabdisp $row, cell(__sig) format(%8.4f)
		display _newline as text "`normalized'Phi scale for $col:"
		tabdisp $col, cell(__phi) format(%8.4f)
	}

	quietly replace __mu=__phi*__sig
	if "$muby" ~= "" {
		local i 0
		foreach var of varlist _M* {
			local i=`i'+1
			quietly replace __muby`i'=`var'*__sig*__phi
		}
	}
	$debug poisson $RC_depvar $RC_base __mu $mubylst $weight $if $in

	* print mu (and muby if applicable)
	if "`eq'" ~= "" {
		display _newline as text "EQRC2 association parameters:"
	}
	else {
		display _newline as text "RC2 association parameters:"
	}
	prhd
	prsnt "mu" __mu
	if "$muby" ~= "" {
		local i 0
		foreach var of varlist _M* {
			local i=`i'+1
			prsnt "`var'" __muby`i'
		}
	}
	display as text "{hline 37}{col 38}{c BT}{hline 41}"

	display _newline as text "Full parameter listing:"
	*display the rest
	poisson
end
