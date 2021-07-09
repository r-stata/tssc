*! clhet_d2 1.1.0  13Aug2007
*! author arh

program define clhet_d2
	version 9.2
	args todo b lnf g negH
	tempvar theta1 theta2 nobs num den last
	mleval `theta1' = `b', eq(1)
	mleval `theta2' = `b', eq(2)
	quietly {
		local id $CLHET_ID
		local clustid $CLHET_CLUSTID

		by `id': gen double `num' = cond(_n==_N,exp(sum($ML_y1*`theta1'*exp(`theta2'))),.) if $ML_samp
		by `id': gen double `den' = cond(_n==_N,sum(exp(`theta1'*exp(`theta2'))),.) if $ML_samp
		by `id': gen `last' 	= 1 if _n==_N & $ML_samp
		mlsum `lnf'			= $CLHET_WGT * ln(`num'/`den') if `last' ==1

		if (`todo'==0 | `lnf'>=.) exit
		tempvar pr g1 g2 v vsum 
		tempname d1 d2

		** Calculate probabilities **
		by `id': gen double `pr'  = sum(exp(`theta1'*exp(`theta2'))) if $ML_samp			  
		by `id': replace `pr'     = exp(`theta1'*exp(`theta2')) / `pr'[_N] if $ML_samp

		** Calculate scores for eq1 **
		gen double `g1' = ($ML_y1 - `pr') * exp(`theta2') if $ML_samp					  
		mlvecsum `lnf' `d1' = $CLHET_WGT * `g1', eq(1)

		by `id': gen double `v'    = cond(_n==_N,sum($ML_y1*`theta1'),.) if $ML_samp 
		by `id': gen double `vsum' = cond(_n==_N,sum(`pr'*`theta1'),.) if $ML_samp 

		** Calculate scores for eq2 **
		gen double `g2' = (`v' - `vsum') * exp(`theta2') if $ML_samp					  
		mlvecsum `lnf' `d2' = $CLHET_WGT * `g2' if `last' == 1, eq(2)

		matrix `g' = (`d1',`d2')

		if (`todo'==1 | `lnf'>=.) exit

		tempvar xc xp xcxpm

		local k1: word count $CLHET_X
		local k2: word count $CLHET_HET
		local k = `k1' + `k2'		

		** Calculate scores for eq1 **
		local i = 1 
		foreach var of global CLHET_X {
			capture drop `xc' `xp'
			by `id': gen double `xc' = cond(_n==_N,sum(`var'*$ML_y1),.) if $ML_samp 
			by `id': gen double `xp' = cond(_n==_N,sum(`var'*`pr'),.) if $ML_samp 
			tempvar xcxp`i'
			gen double `xcxp`i'' = (`xc' - `xp') * exp(`theta2') if $ML_samp  
			local scores `scores' `xcxp`i''
			local i = `i' + 1
		}

		** Calculate scores for eq2 **
		by `id': replace `xc' = cond(_n==_N,sum(`theta1'*$ML_y1),.) if $ML_samp 
		by `id': replace `xp' = cond(_n==_N,sum(`theta1'*`pr'),.) if $ML_samp 
		foreach var of global CLHET_HET {
			tempvar xcxp`i'
			gen double `xcxp`i'' = (`xc' - `xp') * exp(`theta2') * `var' if $ML_samp  
			local scores `scores' `xcxp`i''
			local i = `i' + 1
		}

		** Sum scores over clusters ** 
		if "`clustid'" != "" {
			sort `clustid'
			local scores
			forvalues i = 1(1)`k' {
				by `clustid': replace `xcxp`i'' = cond(_n==_N,sum($CLHET_WGT * `xcxp`i''),.) if $ML_samp 
				local scores `scores' `xcxp`i''
			}
			sort `id'
		}

		** Calculate OPG matrix ** 
		if "`clustid'" != "" {
			matrix accum `negH' = `scores', noconst	
		}
		else if "$CLHET_WGTTYP" == "iweight" | "$CLHET_WGTTYP" == "pweight" {
			matrix accum `negH' = `scores' [iw=$CLHET_WGT^2], noconst	
		}
		else {
			matrix accum `negH' = `scores' [iw=$CLHET_WGT], noconst	
		}
	}
end

