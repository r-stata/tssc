*! version 1.3.2 20Jun2012 MLB
*  version 1.3.0 17Mar2012 MLB
*  version 1.2.0 13Dec2011 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
program define margdistfit, rclass sortpreserve
	version 10.1
	syntax , [pp qq cumul HANGRoot HANGRoot2(string) *]
	if "`pp'`qq'`cumul'`hangroot'`hangroot2'" == "" { 
		local qq = "qq" // default
	}
	if ("`pp'" != "" & "`qq'`cumul'`hangroot'`hangroot2'" != "") | ///
	   ("`qq'" != "" & "`cumul'`hangroot'`hangroot2'" != "") | ///
	   ("`cumul'" != "" & "`hangroot'`hangroot2'" != ""){
		di as err "the options pp, qq, cumul, hangroot may not be combined"
		exit 198
	}
	if "`hangroot2'" != "" {
		local hangroot "hangroot"
		local hangr_opts "hangr_opts(`hangroot2')"
	}
	marg_`pp'`qq'`cumul'`hangroot', `options' `hangr_opts'
end

program define marg_pp, rclass 
	version 10.1
	syntax ,          ///
	[                 ///
	simopts(passthru) ///
	obsopts(string)   ///
	refopts(string)   ///
	nosquare          ///
	sims(integer 20)  ///
	noPArsamp         ///
	e(numlist max=1 >=0 <=1e-3) ///
	*                 ///
	]
		
	if `sims' < 0 {
		di as err "sims must be larger than or equal to 0"
		exit 198
	}
	if `sims' == 0 & "`simci'" != "" {
		di as err "simci cannot be specified when 0 simulations are to be created"
		exit 198
	}
	
	Get_dist
	local dist "`s(dist)'"
	local infl "`s(infl)'"
		
	tempvar touse ptheor pobs 
	
	local y `e(depvar)'

	gen byte `touse' = e(sample)

	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	else {
		local N = r(N)
	}

	if "`e'" != "" {
		if inlist("`dist'", "poisson", "zip", "nb1", "nb2", "zinb") {
			di as err "option e() not allowed with Poisson, zero inflated Poisson, negative binomial or zero inflated negative binomial"
			exit 198
		}
		else if `e' > 10^-ceil(log10(`N')) {
			di as txt "Note: maximal error set at " 10^-ceil(log10(`N'))
			local e = 10^-ceil(log10(`N'))
		}
	}
	else {
		local e = min(1e-6, 10^-ceil(log10(`N')))
	}

	sort `y'
	qui gen `pobs' = sum(`touse')
	qui replace `pobs' = cond(`touse',`pobs'/(`pobs'[_N]+1),.)
	label var `pobs' "observed"
	
	if `sims' > 0 {
		forvalues i = 1/`sims' {
			tempvar sim`i'
			local simvars "`simvars' `sim`i''"
			if inlist("`dist'", "poisson", "zip", "nb1", "nb2", "zinb") {
				tempvar pobs`i'
				local pobsvars "`pobsvars' `pobs`i''"
			}
		}
		local simvarsopt "simvars(`simvars')"
		if inlist("`dist'", "poisson", "zip", "nb1", "nb2", "zinb") {
			local pobsvars "pobsvars(`pobsvars')"
		}
	}

	marg_`dist'pp_prep if `touse', ///
	`simvarsopt'                    ///
	`simopts'                    ///
	sims(`sims')                 ///
	ptheor(`ptheor')             ///
	pobs(`pobs')                 ///
	n(`N')                       ///
	y(`y')                       ///
	e(`e')                       ///
	`parsamp' `pobsvars' `infl'
	
	local gr `"`r(gr)'"'
	
	if `sims' > 1 {
		local leg legend(order(1 "simulations" `=`sims'+1' "observed" `=`sims'+2'))
	}
	else if `sims' == 1 {
		local leg legend(order(1 "simulation" `=`sims'+1' "observed" `=`sims'+2'))
	} 
	else {
		local leg legend(order(1 "observed" 2))
	}
	if "`square'" == "" {
		local aspect "aspect(1)"
	}
	if c(stata_version) < 11 {
		local xtitle `"xtitle("Empirical Pr(Y <= y) = i/(N+1)")"' 
		local ytitle `"ytitle("theoretical Pr(Y <= y)")"'    
	}
	else {
		local xtitle `"xtitle("Empirical Pr(Y {&le} y) = i/(N+1)")"'
		local ytitle `"ytitle("theoretical Pr(Y {&le} y)")"'
	}
	
	twoway `gr'                               || ///
		  scatter `ptheor' `pobs',               ///
		  `aspect' msymbol(oh) `obsopts'     ||  ///
		  function reference = x,                ///
		  lstyle(solid) `leg'                    ///
		  `ytitle' `xtitle' `refopts' `options'
end

program define marg_qq, rclass 
	version 10.1
	syntax ,                        ///
	[                               ///
	simopts(passthru)               ///
	obsopts(string)                 ///
	refopts(string)                 ///
	nosquare                        ///
	sims(integer 20)                ///
	e(numlist max=1 >=0 <=1e-3)     ///
	noPArsamp                       ///
	*                               /// 
	]
	
	if `sims' < 0 {
		di as err "sims must be larger than or equal to 0"
		exit 198
	}
	
	Get_dist
	local dist "`s(dist)'"
	local infl "`s(infl)'"
	
	tempvar touse ptheor pobs q
	
	local y `e(depvar)'

	qui gen byte `touse' = e(sample)

	sort `touse' `y'
	qui gen float `pobs' = sum(`touse')
	local N = `pobs'[_N]
	qui replace `pobs' = cond(`touse', `pobs'/(`pobs'[_N]+1), .)
	if `N' == 0 {
		error 2000
	}
	if "`e'" != "" {
		if `e' < 1e-12 {
			di as err "maximal error cannot be set at less than 1e-12 with the qq option"
			exit 198
		}
		if `e' > 10^-ceil(log10(`N')) {
			tempname newe
			scalar `newe' = max(10^-ceil(log10(`N')), 1e-12)
			if `e' != `newe' {
				di as txt "Note: maximal error set at " `newe')
				local e = `newe'
			}
		}
	}
	else {
		local e = max(min(1e-6, 10^-ceil(log10(`N'))),1e-12)
	}
	
	if `sims' > 0 {
		forvalues i = 1/`sims' {
			tempvar sim`i'
			local simvars "`simvars' `sim`i''"
		}
		local simvarsopt "simvars(`simvars')"
	}
	
	marg_`dist'qq_prep if `touse', ///
	`simvarsopt'                   ///
	`simopts'                      ///
	sims(`sims')                   ///
	q(`q')                         ///
	pobs(`pobs')                   ///
	n(`N')                         ///
	y(`y')                         ///
	e(`e')                         ///
	`parsamp'

	local gr `"`r(gr)'"'
	
	if `sims' > 1 {
		local leg legend(order(1 "simulations" `=`sims'+1' "observed" `=`sims'+2'))
	}
	else if `sims' == 1 {
		local leg legend(order(1 "simulation" `=`sims'+1' "observed" `=`sims'+2'))
	} 
	else {
		local leg legend(order(1 "observed" 2))
	}
	
	sum `q' if `touse', meanonly

	local refrange `"range(`r(min)' `r(max)')"'
	
	if "`square'" == "" {
		local aspect "aspect(1)"
		
		sum `y' if `touse', meanonly
		local min = r(min)
		local max = r(max)
		
		forvalues i = 1/`sims' {
			sum `sim`i'' if `touse', meanonly
			local min = min(`min', r(min))
			local max = max(`max', r(max))
		}
		
		_natscale `min' `max' 5
		local lab "lab(`r(min)'(`r(delta)')`r(max)')"
		local aspect `"`aspect' x`lab' y`lab'"'
		
		local range "scale(range(`min' `max'))"
		local aspect `"`aspect' x`range' y`range'"'
	}
	
	if `"`: var label `y''"' != "" {
		local ytitle `"ytitle(`"`: var label `y''"')"'
	}
	else {
		local ytitle `"ytitle(`y')"'
	}
	
	twoway `gr'                               ||   ///
		  scatter `y' `q',                         ///
		  `aspect' msymbol(oh) `obsopts'      ||   ///
		  function reference = x, `refrange'       ///
		  lstyle(solid) `leg'                      ///
		  `ytitle' xtitle("theoretical quantiles") ///
		  `refopts' `options'
end

program define marg_cumul, rclass 
	version 10.1
	syntax ,          ///
	[                 ///
	simopts(passthru) ///
	obsopts(string)   ///
	refopts(string)   ///
	nosquare          /// not allowed
	sims(integer 20)  ///
	noPArsamp         ///      
	e(numlist max=1 >=0 <=1e-3)  ///
	*                 ///
	]                 ///
	
	if "`nosquare'" != "" {
		di as err "option nosquare not allowed in combination with option cumul"
		exit 198
	}
	if `sims' < 0 {
		di as err "sims must be larger than or equal to 0"
		exit 198
	}

	Get_dist
	local dist "`s(dist)'"
	local infl "`s(infl)'"
	
	tempvar touse ptheor pobs ytheor
	
	local y `e(depvar)'

	gen byte `touse' = e(sample)

	qui count if `touse'
	if r(N) == 0 {
		error 2000
	}
	else {
		local N = r(N)
	}

	if "`e'" != "" {
		if `e' > 10^-ceil(log10(`N')) {
			di as txt "Note: maximal error set at " 10^-ceil(log10(`N'))
			local e = 10^-ceil(log10(`N'))
		}
	}
	else {
		local e = min(1e-6, 10^-ceil(log10(`N')))
	}

	sort `y'
	quietly {
		gen `pobs' = sum(`touse')
		replace `pobs' = cond(`touse',`pobs'/(`pobs'[_N]+1),.)
		if inlist("`dist'", "poisson", "zip", "nb1", "nb2", "zinb") {
			by `y' : replace `pobs' = `pobs'[_N]
			tempvar tobedropped
			gen byte `tobedropped' = 0
		}
		label var `pobs' "observed"
	}
	
	if `sims' > 0 {
		forvalues i = 1/`sims' {
			tempvar sim`i' p`i'
			local simvars "`simvars' `sim`i''"
			local pi "`pi' `p`i''"
		}
		local simvarsopt "simvars(`simvars')"
		local piopt "pi(`pi')"
	}

	marg_`dist'cumul_prep if `touse', ///
	`simvarsopt'                    ///
	`piopt'                         ///  
	`simopts'                       ///
	ytheor(`ytheor')                ///
	sims(`sims')                    ///
	ptheor(`ptheor')                ///
	pobs(`pobs')                    ///
	n(`N')                          ///
	y(`y')                          ///
	e(`e')                          ///
	`parsamp'
	
	local gr `"`r(gr)'"'
	
	if `sims' > 1 {
		local leg legend(order(1 "simulations" `=`sims'+1' "observed" `=`sims'+2' "theoretical"))
	}
	else if `sims' == 1 {
		local leg legend(order(1 "simulation" `=`sims'+1' "observed" `=`sims'+2' "theoretical"))
	} 
	else {
		local leg legend(order(1 "observed" 2 "theoretical"))
	}
	
	if c(stata_version) < 11 {
		local ytitle `"ytitle("Pr(Y <= y)")"' 
		if `"`: var label `y''"' != "" {
			local xtitle `"xtitle(`"`: var label `y''"')"'
		}
		else {
			local xtitle `"xtitle(`y')"'
		}    
	}
	else {
		local ytitle `"ytitle("Pr(Y {&le} y)")"'
		if `"`: var label `y''"' != "" {
			local xtitle `"xtitle(`"`: var label `y''"')"'
		}
		else {
			local xtitle `"xtitle(`y')"'
		}    
	}
	
	twoway `gr'                               || ///
		  scatter `pobs' `y',                    ///
		  msymbol(oh) `obsopts'               || ///
		  line `ptheor' `ytheor',                ///
		  lstyle(solid) `leg'                    ///
		  `ytitle' `xtitle' `refopts' `options'
	
	if inlist("`dist'", "poisson", "zip", "nb1", "nb2", "zinb") {
		qui drop if `tobedropped' != 0
	}
end

program define marg_hangroot, rclass 
	version 10.1
	syntax ,          ///
	[                 ///
	hangr_opts(passthru) ///
	simopts(passthru) ///
	obsopts(string)   ///
	refopts(string)   ///
	nosquare          ///
	sims(integer 20)  ///
	noPArsamp         ///
	e(numlist max=1 >=0 <=1e-3) ///
	*                 ///
	]

	capture which hangroot
	if _rc {
		di as err "the hangroot option requires the hangroot package"
		di as err "to get that package type: ssc install hangroot"
		exit _rc
	}
	if "`simopts'" != "" {
		local simsopt `"simsopt(`simopts')"'
	}
	if "`refopts'" != "" {
		local k : word count `hangr_opts'
		if `k' > 0 {
			forvalues i = 1/`k' {
				local opt : word `i' of `hangr_opts'
				local l = length(`opt')
				if "`opt'" == substr("notheoretical", 1, `l'){
					di as err "option refopts() not allowed in combination with notheoretical"
					exit 198
				} 
			}
		}
		local theoropt `"theoropt(`refopts')"' 
	}
	if "`obsopts'" != "" {
		local mainopt `"mainopt(`obsopts')"'
	}
	if "`square'" != "" {
		di as err "option nosquare not allowed with hangroot"
		exit 198
	}
	if "`e'" != "" {
		di as err "option e() not allowed with hangroot"
		exit 198
	}

	if `sims' < 0 {
		di as err "sims must be larger than or equal to 0"
		exit 198
	}
	
	Get_dist
	local dist "`s(dist)'"
	local infl "`s(infl)'"
	
	marg_`dist'hangroot_prep , ///
	    `hangr_opts' `mainopt' `theoropt' `simsopt' /// 
		sims(`sims') `options' `parsamp'
end

program define Get_dist, sclass
	if "`e(cmd)'" == "betafit" {
		local dist "beta"
	}
	else if "`e(cmd)'" == "regress" {
		local dist "norm"
	}
	else if "`e(cmd)'" == "poisson" {
		if "`e(offset)'" != ""  {
			di as err "margdistfit cannot be used in combination with exposure or offset"
			exit 198
		}		
		local dist "poisson"
	}
	else if "`e(cmd)'" == "zip" {
		if "`e(offset)'" != ""  {
			di as err "margdistfit cannot be used in combination with exposure or offset"
			exit 198
		}
		local dist "zip"
	}
	else if "`e(cmd)'" == "nbreg" {
		 if "`e(offset)'" != ""  {
			di as err "margdistfit cannot be used in combination with exposure or offset"
			exit 198
		 }
		 if "`e(dispers)'" != "mean" {
			local dist nb1
		 }
		 else {
			local dist nb2
		 }
	}
	else if "`e(cmd)'" == "gnbreg" {
		 if "`e(offset)'" != ""  {
			di as err "margdistfit cannot be used in combination with exposure or offset"
			exit 198
		 }
		 local dist nb2
 	}
	else if "`e(cmd)'" == "zinb" {
		 if "`e(offset)'" != ""  {
			di as err "margdistfit cannot be used in combination with exposure or offset"
			exit 198
		 }
		 local dist zinb
	}
	else if "`e(cmd)'" == "" {
		di as err "margdistfit is for use after an estimation command"
		exit 198
	}
	else {
		di as err "margdistfit cannot be used after `e(cmd)'"
		exit 198
	}
	
	sreturn local dist "`dist'"

end
