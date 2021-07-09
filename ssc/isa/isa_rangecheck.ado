*capture program drop isa_rangecheck

*********************************************************************
*	INITIAL CHECK OF WHETHER DELTA THAT SATISFIES BIAS EXISTS OR NOT GIVE ALPHA
	
program define isa_rangecheck
	version 9
	syntax varlist [if] [in] [fw aw], [vce(passthru)] [TAU(numlist >0)] [TSTAT(numlist >0)] ///
		[MINAlpha(real 0)] [MAXAlpha(real 10)] [MINDelta(real 0)] [MAXDelta(real 5)] ///
		[ml_iterate(passthru)]
	
	marksample touse

	tempname matB_maxa_maxd matB_maxa_mind matB_mina_maxd matB_mina_mind ///
	matV_maxa_maxd matV_maxa_mind matV_mina_maxd matV_mina_mind ///
	tau_maxa_maxd tau_maxa_mind tau_mina_maxd tau_mina_mind ///
	se_maxa_maxd se_maxa_mind se_mina_maxd se_mina_mind ///
	t_maxa_maxd t_maxa_mind t_mina_maxd t_mina_mind ///
	qoi

	if "`tau'" != "" {
		local qoi = `tau'
	}
	else {
		local qoi = `tstat'	
	}

	foreach a in max min {
		foreach d in max min {
			isa_est `varlist' if `touse' [`weight'`exp'], alpha(``a'alpha') delta(``d'delta') `vce'
			matrix `matB_`a'a_`d'd' = e(b)
			matrix `matV_`a'a_`d'd' = e(V)
			scalar `tau_`a'a_`d'd' = `matB_`a'a_`d'd'[1,1]
			scalar `se_`a'a_`d'd' = sqrt(`matV_`a'a_`d'd'[1,1])
			scalar `t_`a'a_`d'd' = scalar(`tau_`a'a_`d'd')/scalar(`se_`a'a_`d'd')
		}
	}

	if "`tau'" != "" {
		if `tau_maxa_maxd'>`qoi' {
			noisily display ""
			noisily display as error "Error: tau is larger than the target value when alpha=max delta=max."
			noisily display as error "Perhaps, either maxalpha or maxdelta is too small."			
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}
	else {
		if `t_maxa_maxd'>`qoi' {
			noisily display ""
			noisily display as error "Error: t-value is larger than the target value when alpha=max delta=max."
			noisily display as error "Perhaps, either maxalpha or maxdelta is too small."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}

	if "`tau'" != "" {
		if `tau_mina_mind'<`qoi' {
			noisily display ""
			noisily display as error "Error: tau is smaller than the target value when alpha=min delta=min."
			noisily display as error "Perhaps, either minalpha or mindelta is too large."			
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}
	else {
		if `t_mina_mind'<`qoi' {
			noisily display ""
			noisily display as error "Error: t-value is smaller than the target value when alpha=min delta=min."
			noisily display as error "Perhaps, either minalpha or mindelta is too large."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}

	if "`tau'" != "" {
		if `tau_maxa_mind'<`qoi' {
			noisily display ""
			noisily display as error "Error: tau is smaller than the target value when alpha=max delta=min."
			noisily display as error "Perhaps, either maxalpha or mindelta is too large."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}
	else {
		if `t_maxa_mind'<`qoi' {
			noisily display ""
			noisily display as error "Error: t-value is smaller than the target value when alpha=max delta=min."
			noisily display as error "Perhaps, either maxalpha or mindelta is too large."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}	

	if "`tau'" != "" {
		if `tau_mina_maxd'<`qoi' {
			noisily display ""
			noisily display as error "Error: tau is smaller than the target value when alpha=min delta=max."
			noisily display as error "Perhaps, either minalpha or maxdelta is too large."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}
	else {
		if `t_mina_maxd'<`qoi' {
			noisily display ""
			noisily display as error "Error: t-value is smaller than the target value when alpha=min delta=max."
			noisily display as error "Perhaps, either minalpha or maxdelta is too large."	
			noisily display as text "If you believe you selected options correctly, you can also avoid this error with -skipr- option."	
			error 121
		}
	}		
	
end

