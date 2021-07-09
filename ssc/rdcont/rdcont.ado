*! version 2.0.0 Ivan Canay 15apr2020
program rdcont, rclass
	version 12.0
	syntax varlist [if] [in], [threshold(numlist) alpha(numlist) Qband(numlist)]
	marksample touse
	qui cou if `touse'
	loc N = r(N)
	
	*Logic checks
	cap assert `:word count `varlist'' == 1
	if _rc != 0 {
		di as err "Too many variables"
		exit 198
	}
	if "`threshold'" == "" {
		loc threshold = 0
	}
	else {
		cap assert `:word count `threshold'' == 1
		if _rc != 0 {
			di as err "Too many thresholds"
			exit 198
		}
	}
	if "`qband'" != "" {
		cap assert `:word count `qband'' == 1
		if _rc != 0 {
			di as err "Too many qbands"
			exit 198
		}
		cap assert `qband' > 0 
		if _rc != 0 {
			di as err "qband must be positive"
			exit 198
		}
		if "`alpha'" != "" {
			di as err "Cannot set both alpha and qband"
			exit 198
		}
	}
	if "`alpha'" == "" {
		loc alpha = 0.05
	}
	else {
		cap assert `:word count `alpha'' == 1
		if _rc != 0 {
			di as err "Too many alphas"
			exit 198
		}
		cap assert `alpha' > 0 & `alpha' < 1
		if _rc != 0 {
			di as err "alpha must be in (0,1)"
			exit 198
		}
	}
	
	tempvar Z
	gen `Z' = `varlist' if `touse'
	
	if "`qband'" != "" {
		*User-specified q
		loc q = `qband'
		loc b = floor(`q'/4) 
		loc width = floor(`q'/4)
		loc test = 1
		while (binomial(`q', `b' - 1, 0.5) >  `alpha'/2) | (binomial(`q', `b', 0.5) < `alpha'/2) {
			loc ++test
			if binomial(`q', `b' - 1, 0.5) > `alpha'/2 { 
				loc b = `b' - ceil(`width'/2^`test')
			}
			else {
				loc b = `b' + ceil(`width'/2^`test')
			}
		}
		loc b_q = `b'
	}
	else {
		*Get sum stats about Z
		qui su `Z'
		loc mu = r(mean)
		loc sd = r(sd)

		*Calculate q_rot
		loc C_phi = (`sd'*4*normalden(`threshold',`mu', `sd')^2/(normalden(`mu'+`sd',`mu', `sd')))^(2/3) 
		loc qrot = `C_phi'*`N'^(0.5)
		loc q_star = ceil(1 - ln(`alpha')/ln(2))
		loc q = ceil(max(`q_star', `qrot'))
		loc qpre = `q'

		*Calculate q_irot 
		loc argmax = 0
		loc start = max(`q'-ceil(4*ln(`q')), `q_star')
		loc stop = `q'+ceil(4*ln(`q'))

		forv Q = `start'/`stop'{
			loc b = floor(`Q'/4) 
			loc width = floor(`Q'/4)
			loc test = 1
			while (binomial(`Q', `b' - 1, 0.5) >  `alpha'/2) | (binomial(`Q', `b', 0.5) < `alpha'/2) {
				loc ++test
				if binomial(`Q', `b' - 1, 0.5) > `alpha'/2 { 
					loc b = `b' - ceil(`width'/2^`test')
				}
				else {
					loc b = `b' + ceil(`width'/2^`test')
				}
			}
			assert inrange(`b', 0, floor(`Q'/2))
			if binomial(`Q', `b' - 1, 0.5) > `argmax' {
				loc q_irot = `Q'
				loc b_q = `b'
				loc argmax = binomial(`Q', `b' - 1, 0.5)
			}
		}
		loc q = `q_irot'	
	}

	*g-ordering
	qui replace `Z' = `Z' - `threshold'
	tempvar absZ
	qui gen `absZ' = abs(`Z')
	sort `absZ'
	tempvar order
	qui gen `order' = _n if `touse'
	qui cou if `Z' >= 0 & `order' <= `q'
	loc Sn = r(N)
	
	*p-value
	loc pvalue = 2*min(binomial(`q', `Sn', 0.5), binomial(`q', `q' - `Sn', 0.5))
	
	*Table stats
	qui cou if `Z' < 0 & `touse'
	loc N_l = r(N)
	qui cou if `Z' >= 0 & `touse'
	loc N_r = r(N)
	qui su `Z' if `Z' >= 0 & `order' <= `q'
	loc ul = r(max) 
	qui su `Z' if `Z' < 0 & `order' <= `q'
	loc ll = r(min) 
	
	*Display
	disp in smcl in gr "{bf:RDD non-randomized approximate sign test}"   
	disp in smcl in gr "Running variable: `varlist'"      
	disp in smcl in gr "Cutoff {bf:c} = {ralign 7:`threshold'}"    _col(19) " {c |} " _col(21) in gr "Left of " in yellow "c"  _col(33) in gr "Right of " in yellow "c"        	_col(55) in gr "Number of obs = "  in yellow %10.0f `N'
	disp in smcl in gr "{hline 19}{c +}{hline 22}"                                                                                                                       		_col(55) in gr "{it:q}             = "  in yellow "{ralign 10:`q'}" 
	disp in smcl in gr "{ralign 18:Number of obs}"          	_col(19) " {c |} " _col(21) as result %9.0f `N_l'           _col(34) %9.0f  `N_r'                              	
	disp in smcl in gr "{ralign 18:Eff. number of obs}"     	_col(19) " {c |} " _col(21) as result %9.0f `=`q'-`Sn''     _col(34) %9.0f 	`Sn'                            	
	disp in smcl in gr "{ralign 18:Eff. neighborhood}"     	_col(19) " {c |} " _col(21) as result %9.3f `ll'     _col(34) %9.3f 	`ul'                            	
	disp in smcl in gr "{hline 19}{c +}{hline 22}"  
	disp in smcl in gr "{ralign 18: {it:p}-value}"         	_col(19) " {c |} " _col(21) as result %9.3f `pvalue'                            
	
	*Return values
	ret sca p = `pvalue'
	ret sca N = `N'
	ret sca q = `q'
	ret sca q_r = `Sn'
	ret sca q_l = `q' - `Sn'
	ret sca c = `threshold'
	ret sca N_l = `N_l'
	ret sca N_r = `N_r'
	ret sca ub = `ul'
	ret sca lb = `ll'
	ret sca q_p = `qpre'

end


