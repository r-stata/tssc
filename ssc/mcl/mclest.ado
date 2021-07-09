*! version 2.0, 23Sep2004, John_Hendrickx@yahoo.com
/*
Direct comments to:

John Hendrickx <John_Hendrickx@yahoo.com>

Version 2.0, September 23, 2004
- mclest can now be run several times consecutively, special variables
  are dropped at the beginning of the program
- mclest prints "Model fit information" containing the correct number
  of model df, taking the estimated phi and sigma scale coefficients
  into account
- mclest saves estimates. The phi and sigma scales are saved as
  matrices and the correct model degrees of freedom is saved as a
  scalar
Version 1.9, October 29, 1999
Updated for version 7
*/
program define mclest, eclass
	version 7
	syntax varlist [if] [in] [fweight iweight]                 /*
*/   [, SOR(varlist) SORITER(integer 20) SORTOL(real 0.0001) /*
*/      RC2(varname) EQRC2(varname) MUBY(varlist) DEBUG noNOrm ]

	if "`weight'" ~= "" {
		local weight="[`weight'`exp']"
	}

	* if no special effects, estimate the model and exit
	if "`sor'" == "" & "`rc2'" == "" & "`eqrc2'" == "" {
		clogit __didep `varlist' `weight' `if' `in', strata(__strata)
		exit
	}

	foreach x in __phi* __beta* __sumbet __row* __sig __msig* __mu* __summu {
		capture drop `x'
	}
	capture estimates drop c0_1

	global varlist "`varlist'"
	global if "`if'"
	global in "`in'"
	global weight "`weight'"
	if "`sor'" ~= "" {global sor "`sor'"}
	if "`debug'"  ==  "" {global debug="quietly "}

	* simple phi scale
	gen __phi=($respfact-1)/($ncat-1)
	label var __phi "phi"

	* create variables for beta parameters, store in $lftlist
	if "$sor" ~= "" {
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			gen __beta`i'=`var'*__phi
			local thislab: variable label `var'
			label variable __beta`i' "SOR effect for `var': `thislab'"
		}
		local nbeta=`i'
		if `nbeta' == 1 {global lftlist="__beta1"}
		if `nbeta'> 1 {global lftlist="__beta1-__beta`nbeta'"}
		display as text _newline "Estimating Stereotype Ordered Regression for $sor"
	}
	else {
		local nbeta=0
	}

	gen __sumbet=0
	forval i=2/$ncat {
		gen __phi`i'=0
	}
	global rgtlist="__phi2-__phi$ncat"

	if "`rc2'" ~= "" & "`eqrc2'" ~= "" {
		display as error _newline "Error: options RC2 and EQRC2 may not be used together"
		display as error "Error: The EQRC2 option will be ignored" _newline
		local eqrc2=""
	}

	if "`rc2'" ~= "" | "`eqrc2'" ~= "" { global row="`rc2'`eqrc2'" }

	if "$row" ~= "" {
		quietly tab $row, gen(__row)
		global rowcat=r(r)
		gen __sig=($row-1)/($rowcat-1)
		label var __sig "sigma"

		gen __mu=__sig*__phi
		gen __summu=0
	}
	if "`rc2'" ~= "" {
		global rc2="`rc2'"

		label variable __mu "mu: RC2 assoc $respfact and $rc2"
		forval i=2/$rowcat {
			gen __msig`i'=__row`i'*__phi
		}
		global lftlist="$lftlist __msig2-__msig$rowcat"
		display as text _newline "Estimating rc2 effects for $rc2"
	}

	if "`eqrc2'" ~= "" {
		global eqrc2="`eqrc2'"
		label variable __mu "mu: eqRC2 assoc $respfact and $eqrc2"
		forval i=2/$rowcat {
			gen __msig`i'=__row`i'*__phi+($respfact==`i')*__sig
		}
		global cenlist="$lftlist __msig2-__msig$rowcat"
		global lftlist="$lftlist __mu"
		display _newline "Estimating equal rc2 effects for $eqrc2"
	}

	if "`muby'" ~= "" & "$row" == "" {
		display
		display as error _newline "Error: Either the RC2 or EQRC2 option is required"
		display as error "Error: when using the MUBY option"
		display as error "Error: The MUBY option will be ignored" _newline
		local muby=""
	}

	if "`muby'" ~= "" {
		global muby="`muby'"
		local i 0
		foreach var of varlist $muby {
			local i=`i'+1
			gen __muby`i'=`var'*__sig*__phi
			local thislab: variable label `var'
			label variable __muby`i' "mu by `var': `thislab'"
			display as text "mu varies by `var'"
		}
		local nmu=`i'
		if "$eqrc2" ~= "" {
			if `nmu' == 1 {global lftlist="$lftlist __muby1" }
			if `nmu' >1 {global lftlist="$lftlist __muby1-__muby`nmu'" }
		}
		else {
			if `nbeta' == 1 { global cenlist="__beta1" }
			if `nbeta' > 1  { global cenlist="__beta1-__beta`nbeta'" }
			if `nmu' == 1   { global cenlist="$cenlist __mu __muby1" }
			if `nmu' > 1    { global cenlist="$cenlist __mu __muby1-__muby`nmu'" }
		}
	}

	display _newline as text "{hline  70}"
	display as text "iteration {col 17}log likelihood {col 40}sub-changes {col 59}main changes"
	display as text "{hline  70}"
	global iter=0
	global prev=0
	global chng=9999
	global lft=0
	global rgt=0
	global cen=0
	local conv=0
	if "`eqrc2'" == "" {
		while `conv' ~= 1 {
			leftest
			rightest
		if "$muby" ~= "" { cenest }
		if abs($chng) < `sortol' {local conv=1}
		if $iter >= `soriter' {local conv=1}
		}
	}
	else {
		while `conv' ~= 1 {
			eq1est
			eq2est
		if abs($chng) < `sortol' {local conv=1}
		if $iter >= `soriter' {local conv=1}
		}
	}
	display as text "{hline  70}"
	if abs($chng) >= `sortol' {
		display as text "Maximum number of `soriter' iterations reached without convergence"
	}
	else {
		display as text "Convergence criterion `sortol' reached in $iter iterations"
	}
	display _newline

	* display the scales and the final model
	finmod
	* save the phi and sigma scales as matrices
	savescl

	if "`norm'" ~= "nonorm" {
		estimates hold c0_1
		display _newline _newline as text "Normalized Solution:"

		* normalize the phi and sig matrices created by -savescl-
		tempname w v sig_d phi_d
		if "$row" ~= "" {
			mat `sig_d' = sig-J($rowcat,$rowcat,1/$rowcat)*sig
			mat svd sig_n `w' `v' = `sig_d'
			forval i=1/$rowcat {
				quietly replace __sig=sig_n[`i',1] if $row==`i'
			}
		}
		mat `phi_d' = phi-J($ncat,$ncat,1/$ncat)*phi
		mat svd phi_n `w' `v' = `phi_d'

		forval i=1/$ncat {
			quietly replace __phi=phi_n[`i',1] if $respfact==`i'
		}
		finmod "Normalized "
		estimates matrix phi_n phi_n
		if "$row" ~= "" {
			estimates matrix sig_n sig_n
		}
	}

	* summarize improvement in model fit
	tempname df_m

	if "`rc2'" ~= "" {
		scalar `df_m'=e(df_m)+$rowcat+$ncat-4
	}
	else {
		scalar `df_m'=e(df_m)+$rowcat-2
	}
	local linewd: set linesize
	local colpos=`linewd'-14

	display _newline"{.-}{text:Model fit information}{.-}"
	display "{text:log likelihood}"   as result _col(`colpos') %15.4f e(ll)
	display "{text:model df}"         as result _col(`colpos') %15.0f `df_m'
	display "{.-}"

	* save the scales using the 0 and 1 restriction
	estimates matrix phi phi
	if "$row" ~= "" {
		estimates matrix sig sig
	}
	* update the model degrees of freedom to take the -phi-
	* (and -sigma-) parameters into account
	estimates scalar df_m=`df_m'

	* cleanup
	foreach mat in phi sig phi_n sig_n {
		capture matrix drop `mat'
	}

	macro drop lftlist rgtlist rowcat cenlist muby rc2 eqrc2 row
	macro drop sor varlist iter prev chng lft rgt cen
	macro drop weight if in debug
end

program define leftest
	version 7
	* given phi[j], estimate beta[k]
	* (and if applicable, sigma[v]*(mu+mu[t]X[t]))
	*global lftlist="__beta1-__beta`nbeta' __msig2-__msig$rowcat"
	$debug clogit __didep $varlist $lftlist $weight $if $in, strata(__strata)
	global iter=$iter+1
	local chng1=e(ll)-$prev
	global chng=e(ll)-$lft
	global lft =e(ll)
	global prev=e(ll)
	display as result $iter.1 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	* prepare variables for estimating phi's
	quietly replace __sumbet=0
	if "$sor" ~= "" {
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			quietly replace __sumbet=__sumbet+_b[__beta`i']*`var'
		}
	}

	if "$rc2" ~= "" {
		* update the sig scale
		forval i=2/$rowcat {
			quietly replace __sig=_b[__msig`i']/_b[__msig$rowcat] if $rc2 == `i'
		}
		if "$muby" == "" {
			quietly replace __sumbet=__sumbet+_b[__msig$rowcat]*__sig
		}
		else {
			if $iter == 1 { quietly replace  __summu=_b[__msig$rowcat] }
			quietly replace __sumbet=__sumbet+__summu*__sig
		}
	}

	forval i=2/$ncat {
		quietly replace __phi`i'=__sumbet*($respfact==`i')
	}
end

program define rightest
	version 7
	* given beta[k]X[k] (and if applicable, sigma[v]*(mu+mu[t]*X[t])),
	* estimate phi[j]
	* global rgtlist="__phi2-__phi$ncat"
	$debug clogit __didep $varlist $rgtlist $weight $if $in, strata(__strata)

	local chng1=e(ll)-$prev
	global chng=e(ll)-$rgt
	global rgt =e(ll)
	global prev=e(ll)
	display as result $iter.2 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	* update the phi variate
	forval i=2/$ncat {
		quietly replace __phi=_b[__phi`i']/_b[__phi$ncat] if $respfact == `i'
	}

	if "$sor" ~= "" {
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			quietly replace __beta`i'=`var'*__phi
		}
	}

	if "$muby" ~= "" {
		quietly replace __mu=__sig*__phi
		local i 0
		foreach var of varlist $muby {
			local i=`i'+1
			quietly replace __muby`i'=`var'*__sig*__phi
		}
	}
	else if "$rc2" ~= "" {
		* redefine the __msig values
		forval i=2/$rowcat {
			quietly replace __msig`i'=__row`i'*__phi
		}
	}
end

program define cenest
	version 7
	* given phi[j] and sigma[v], estimate mu and mu[t]
	* global cenlist="__beta1-__beta`nbeta' __mu __muby1-__muby`nmu'"
	$debug clogit __didep $varlist $cenlist $weight $if $in, strata(__strata)

	local chng1=e(ll)-$prev
	global chng=e(ll)-$cen
	global cen =e(ll)
	global prev=e(ll)
	display as result $iter.3 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	quietly replace __summu=_b[__mu]
	local i 0
	foreach var of varlist $muby {
		local i=`i'+1
		quietly replace __summu=__summu+`var'*_b[__muby`i']
	}

	* redefine the __msig values
	forval i=2/$rowcat {
		quietly replace __msig`i'=__row`i'*__phi*__summu
	}
end

program define eq1est
	version 7
	* treat phi=sig as given
	* estimate beta["k"], mu, and mu["t"]
	* estimate mu parameters
	* global lftlist="__beta1-__beta`nbeta' __mu __muby1-__muby`nmu'"
	$debug clogit __didep $varlist $lftlist $weight $if $in, strata(__strata)
	global iter=$iter+1

	local chng1=e(ll)-$prev
	global chng=e(ll)-$cen
	global cen =e(ll)
	global prev=e(ll)
	display as result $iter.1 _col(16) %15.4f e(ll) _col(36) %15.4f `chng1' _col(56) %15.4f $chng

	quietly replace __sumbet=0
	if "$sor" ~= "" {
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			quietly replace __sumbet=__sumbet+_b[__beta`i']*`var'
		}
	}

	quietly replace __summu=_b[__mu]
		if "$muby" ~= "" {
		local i 0
		foreach var of varlist $muby {
			local i=`i'+1
			quietly replace __summu=__summu+`var'*_b[__muby`i']
		}
	}

	* redefine the __msig values
	#delimit ;
	forval i=2/$rowcat {
		quietly replace __msig`i'=__row`i'*__phi*__summu+
				                      ($respfact==`i')*(__sig*__summu+__sumbet);
	};
	#delimit cr
end

program define eq2est
	version 7
	* treat beta["k"], mu, and mu["t"] as given
	* estimate phi["j"]=sig["i"]
	* estimate sig["i"]=phi["i"]
	* global cenlist="__beta1-__beta`nbeta' __msig2-__msig$rowcat"
	$debug clogit __didep $varlist $cenlist $weight $if $in, strata(__strata)

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
		quietly replace `signew'=_b[__msig`i']/_b[__msig$rowcat] if $eqrc2 == `i'
		quietly replace `phinew'=_b[__msig`i']/_b[__msig$rowcat] if $respfact == `i'
	}
	quietly replace __sig=(`signew'+__sig)/2
	quietly replace __phi=(`phinew'+__phi)/2

	if "$sor" ~= "" {
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			quietly replace __beta`i'=`var'*__phi
		}
	}

	quietly replace __mu=__sig*__phi
	if "$muby" ~= "" {
		local i 0
		foreach var of varlist $muby {
			local i=`i'+1
			quietly replace __muby`i'=`var'*__sig*__phi
		}
	}
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

program define savescl
	version 7
	preserve
	if "$rc2" ~= "" {
		local row="$rc2"
	}
	else if "$eqrc2" ~= "" {
		local row="$eqrc2"
	}

	if "`row'" ~= "" {
		collapse(min) __phi __sig, by(`row' $respfact)
		mkmat __phi if `row'==1, matrix(phi)
		mkmat __sig if $respfact==1, matrix(sig)
	}
	else {
		collapse(min) __phi, by($respfact)
		mkmat __phi, matrix(phi)
	}
	restore
end

program define finmod
	version 7
	args normed
	if "$eqrc2" ~= "" {
		display _newline as text "`normed'Phi/Sigma scale for $respfact and $eqrc2:"
	}
	else {
		display _newline as text "`normed'Phi scale for $respfact:"
	}
	tabdisp $respfact, cell(__phi) format(%8.4f)
	if "$rc2" ~= "" {
		display _newline as text "`normed'Sigma scale for $rc2:"
		tabdisp $rc2, cell(__sig) format(%8.4f)
	}

	if "$sor" ~= "" {
		* create variables for beta parameters, store in `finlist'
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			quietly replace __beta`i'=`var'*__phi
		}
		if `i' == 1 {local finlist="__beta1"}
		else {local finlist="__beta1-__beta`i'"}
	}
	if "$row" ~= "" {
		quietly replace __mu=__phi*__sig
		local finlist="`finlist' __mu"
	}
	if "$muby" ~= "" {
		local i 0
		foreach var of varlist $muby {
			local i=`i'+1
			quietly replace __muby`i'=`var'*__sig*__phi
		}
		if `i' == 1 { local finlist="`finlist' __muby1" }
		else { local finlist="`finlist' __muby1-__muby`i'" }
	}
	$debug clogit __didep $varlist `finlist' $weight $if $in, strata(__strata)

	* print mu (and muby if applicable)
	if "$row" ~= "" {
		if "$eqrc2" ~= "" {
			display _newline as text "EQRC2 association parameters:"
		}
		else {
			display _newline as text "RC2 association parameters:"
		}
		prhd
		prsnt "mu" __mu
		if "$muby" ~= "" {
			local i 0
			foreach var of varlist $muby {
				local i=`i'+1
				prsnt "`var'" __muby`i'
			}
		}
		display as text "{hline 37}{col 38}{c BT}{hline 41}"
	}

	* display the beta's
	if "$sor" ~= "" {
		display _newline as text "Beta parameters:"
		prhd
		local i 0
		foreach var of varlist $sor {
			local i=`i'+1
			prsnt "`var'" __beta`i'
		}
		display as text "{hline  79}"
	}

	display _newline as text "Full parameter listing:"
	*display the rest
	clogit
end

