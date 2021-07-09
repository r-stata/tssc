*! version 1.0.0 18dec2017 daniel klein
program kappaetcssi // , rclass
	version 11.2
	
	/*
		Gwet (2014, 159) 'rule of thumb'
			
			(1) V = p_a(1-p_a)/n
			(2) V_max = 1/(4n) 
				p_a(1-p_a) = p_a-p_a^2
				derivative w.r.t p_a
				1 - 2p_a = 0
				p_a = 0.5
				Maximum at p_a = 0.5
				V_max = p_a(1-p_a)*(1/n)
				V_max = 0.5(1-0.5)*(1/n)
				V_max = 0.25*(1/n) = (1/4)*(1/n) = 1/(4n)
			(3) E = 2*sqrt(V)
			(4) n = 1/E^2
				E < 2*sqrt(V)
				E^2 < 4V
				E^2 < 4V_max
				E^2 < 4 * 1/4n
				E^2 < 1/n
				n > 1/E^2
				
		to allow speicification of p_a and confidence level we use
		
			(2a) V_max = p_a(1-p_a) * (1/n)	
			(3a) E = z*sqrt(V)
		
		with
			z = abs(invnormal((1-level/100)/2))
			
			(4a) n = (z^2*V_max)/E^2
			
		this gives equivalent results to
		
			power oneproportion # #+E  , power(.5)
			
		/--------------------------------------------------------/	
		
		the standard error in kappaetc is equivalent to
		
			(5) se = sqrt(pa(1-pa)/((n-1)/(1-n/N)))
			
		the expected error margin, using standard normal, is
		
			(6) E[E] = z*se
			
		for small samples (default) the t ditribution is used
		
			(6a) E[E] = t*se
		
		with
			t = invttail((n-1), (1-level/100)/2)
	*/
	
	/*
		parse syntax */
		
	syntax anything(id = "number") 						///
	[ , 												///
		Level(cilevel) 									///
		CFORMAT(string asis) 							///
		NSUBJECTS(numlist integer missingok max = 1 >0) ///
		LARGESAMPLE 									///
		noRETURN 										///
	]
		
	if mi(`"`cformat'"') {
		local cformat %8.4f
	}
	else {
		capture noisily confirm numeric format `cformat'
		if (_rc) {
			exit 198
		}
		if (fmtwidth("`cformat'") > 8) {
			display as txt "note: invalid cformat(), using default"
			local cformat %8.4f
		}
	}
	
	gettoken E anything 	: anything
	gettoken p_a anything 	: anything
	
	if (`"`anything'"' != "") {
		error 198
	}
	
	if mi(`"`p_a'"') {
		local p_a 0.5
	}
	
	foreach arg in E p_a {
		capture noisily confirm number ``arg''
		if (_rc) {
			exit 198
		}
		capture assert inrange(``arg'', 0, 1)
		if (_rc) {
			error 125
		}
	}
	
	/*
		estimate */
		
	tempname N V z n se se_t errmarg errmarg_t
	
	scalar `N' 	= real("`nsubjects'")
	scalar `V' 	= (`p_a'*(1-`p_a'))
	scalar `z' 	= abs(invnormal((1-`level'/100)/2))
	scalar `n' 	= max(ceil((`z'^2*`V')/`E'^2), 2)
	scalar `se' = sqrt(`V'/`n')
	
	if (`N' <= `n') {
		display as err "population size is too small"
		exit 498
	}
	
	if mi(`N') {
		scalar `se_t' 	= sqrt(`V'/(`n'-1))
	}
	else {
		scalar `se_t' 	= sqrt(`V'/((`n'-1)/(1-`n'/`N')))
	}
	
	scalar `errmarg' 	= `z'*`se'
	
	if mi("`largesample'") {
		scalar `errmarg_t' 	= invttail((`n'-1), (1-`level'/100)/2)*`se_t'
	}
	else {
		scalar `errmarg_t' 	= `z'*`se_t'
	}
	
	scalar `errmarg_t' 	= min(`errmarg_t', 1)
	
	/*
		display */
		
	local cfmt : copy local cformat
	local wdth = max(fmtwidth("`cfmt'"), 4)
	
	if (strlen("`level'") > 2) {
		local lfmt %`=`wdth'-1'.2f
	}
	else {
		local lfmt %`=`wdth'-1'.0f
	}
	
	if mi("`largesample'") {
		local smallsample " (small sample)"
	}

	display as txt _n "Sample size estimation for agreement coefficients"
	display as txt _n "Study parameters:" _n
	display as txt %38s "Error margin" 						" = " ///
		as res `cfmt' `E'
	display as txt %38s "Confidence level" 					" = " ///
		as res `lfmt' `level' "%"
	display as txt %38s "Percent agreement" 				" = " ///
		as res `cfmt' `p_a'
	if ("`nsubjects'" != "") {
		display as txt %38s "Population size" 				" = " ///
			as res %`wdth'.0f `N'
	}
	
	display as txt _n "Estimates:" _n
	display as txt %38s "Number of subjects" 				" = " ///
		as res %`wdth'.0f `n'
	display as txt %38s "Standard error (normal approx.)" 	" = " ///
		as res `cfmt' `se'
	display as txt  %38s "Error margin (normal approx.)" 	" = " ///
		as res `cfmt' `errmarg'
	display as txt %38s "Standard error`smallsample'" 		" = " ///
		as res `cfmt' `se_t'
	display as txt  %38s "Error margin`smallsample'" 		" = " ///
		as res `cfmt' `errmarg_t'
	
	/*
		return */
		
	if mi("`return'") {
		mata : st_rclear()
		mata : st_numscalar("r(level)", strtoreal(st_local("level")))
		mata : st_numscalar("r(E)", strtoreal(st_local("E")))
		mata : st_numscalar("r(prop_o)", strtoreal(st_local("p_a")))
		if ("`nsubjects'" != "") {
			mata : st_numscalar("r(N_pop)", st_numscalar("`N'"))
		}
		mata : st_numscalar("r(N)", st_numscalar("`n'"))
		mata : st_numscalar("r(se)", st_numscalar("`se'"))
		mata : st_numscalar("r(errmarg)", st_numscalar("`errmarg'"))
		mata : st_numscalar("r(se_t)", st_numscalar("`se_t'"))
		mata : st_numscalar("r(errmarg_t)", st_numscalar("`errmarg_t'"))
	}
end
exit

1.0.0	18dec2017	submitted to SJ
