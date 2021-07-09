*CALCUATES ICCs and Variances of ICCs based on Hedges Derivations

program iccvar, rclass
	syntax, [UNBalance] [Alpha(real 0.05)]
	version 11.1
	tempname cs l4vc l4vcv l3vc l3vcv l2vc l2vcv l1vc tv tv4 icc2 icc3 icc4 ns m N  ///
	se2 se3 se4 v1 v2 v3 v4 b V p r q a b c d e f l u higher lower z cv23 cv24 ///
	cv34 c23 icc2bar icc3bar icc4bar qp qp2 qp2tv4 qtv4
	tempvar n
	if e(cmd) == "xtmixed" | e(cmd) == "mixed" {
		local levels = 0
		local test1 = e(revars) 
		foreach v in `test1' {
			if "`v'" == "_cons" {
				local ++levels
			}
			else if "`v'" == "." {
				display as error "must have at least one group-level random effect"
				exit 9
			}
			else {
				display as error "only _cons can have random effects"
				exit 9
			}
		}
		capture assert `levels' <= 3 & `levels' > 0
		if _rc == 9 {
			display as error "this command is for models with up to 4 levels only"
			exit 9
		}
		scalar `cs' = colsof(e(N_g))
		assert `cs' == `levels'
		
		*Display Headers
		
		display _newline as text "Intraclass Correlation Estimates" _newline
		
		if `levels' == 1 {
			if "`unbalance'" == "unbalance" {
				display as error "there is no balance option for two level models"
				exit 9
			}
			local l2var = e(ivars)
			local y = e(depvar)
			quietly : _diparm lns1_1_1, function((exp(@))^2) derivative(2*exp(@)^2)		
			scalar `l2vc' = r(est) 
			scalar `l2vcv' = (r(se))^2
			quietly : _diparm lnsig_e, function((exp(@))^2) derivative(2*exp(@)^2)
			scalar `l1vc' = r(est)
			scalar `tv' = `l1vc' + `l2vc'
			scalar `tv4' = ((`tv')^.5)^4
			scalar `icc2' = `l2vc' / `tv'
			scalar `v2' = (((1-`icc2')^2)*`l2vcv')/`tv4'
			scalar `se2' = (`v2')^.5	
			matrix define `b' = (`icc2')
			matrix define `V' = (`v2')
			matrix colnames `b' = `l2var'
			matrix rownames `b' = `y'
			matrix colnames `V' = `l2var'
			matrix rownames `V' = `l2var'		
		}
		else if `levels' == 2 {
			preserve
			gen `n' = e(sample)
			local lvars = e(ivars)
			local k = 3 
			foreach v in `lvars' {
				local l`k'var "`v'"
				local --k
			}
			local y = e(depvar)
			quietly : _diparm lns1_1_1, function((exp(@))^2) derivative(2*exp(@)^2)			
			scalar `l3vc' = r(est)
			scalar `l3vcv' = (r(se))^2
			quietly : _diparm lns2_1_1, function((exp(@))^2) derivative(2*exp(@)^2)		
			scalar `l2vc' = r(est)
			scalar `l2vcv' = (r(se))^2
			quietly : _diparm lnsig_e, function((exp(@))^2) derivative(2*exp(@)^2)
			scalar `l1vc' = r(est)
			scalar `tv' = `l1vc' + `l2vc' + `l3vc'
			scalar `tv4' = ((`tv')^.5)^4
			scalar `icc2' = `l2vc' / `tv'
			scalar `icc3' = `l3vc' / `tv'
			if "`unbalance'" == "" {
				collapse (max) `n', by(`l2var' `l3var')
				collapse (sum) `n', by(`l3var')
				quietly : drop if `n' == 0
				quietly: means `n'
				scalar `p' = r(mean_h)
				
				display as text "Harmonic Mean of Level 2 Units per Level 3 Unit" _col(50) "=" _col(51) as result %12.3f `p'
				return scalar p = `p'
				
				*variance of icc2
				
				scalar `v2' = (((`p'*((1-`icc2')^2))+(2*`icc2'*(1-`icc2')))*`l2vcv')/(`p'*`tv4') + (((`icc2'^2)*`l3vcv')/`tv4')			
				scalar `se2' = `v2'^.5
				
				*variance of icc3  
				
				scalar `v3' = ((((`p'*(`icc3'^2))+(2*`icc3'*(1-`icc3')))*`l2vcv') / (`p'*`tv4'))+((((1-`icc3')^2)*`l3vcv')/`tv4')
				scalar `se3' = `v3'^.5
				
				*covariance
				scalar `cv23' = (((((`p'*`icc3'*(1-`icc2'))+(`icc2'*`icc3')+((1-`icc2')*(1-`icc3')))*-1)*`l2vcv')/(`p'*`tv4'))-((`icc2'*(1-`icc3')*`l3vcv')/`tv4')
				
				matrix define `b' = (`icc3', `icc2')
				matrix define `V' = (`v3', `cv23' \ `cv23', `v2')
				matrix colnames `b' = `l3var' `l2var'
				matrix rownames `b' = `y'
				matrix colnames `V' = `l3var' `l2var'
				matrix rownames `V' = `l3var' `l2var'		

			}
			else if "`unbalance'" == "unbalance" {
				
				*getting covariance between variance components
				
				collapse (sum) `n' if e(sample), by(`l2var' `l3var')
				quietly : gen a = `n'/((`n'*(`l2vc'))+(`l1vc'))
				quietly : gen b = (`n'^2)/(((`n'*(`l2vc'))+(`l1vc'))^2)
				quietly : gen p = 1 if `n' > 0 & `n' != .
				collapse (sum) a b p, by(`l3var')
				quietly: means p
				scalar `p' = r(mean_h)
				gen d = b/(1+(a*(`l3vc')))
				gen e = (a^2)/(1+(a*(`l3vc')))
				collapse (sum) d e
				gen c = -1*((d*`l2vcv')/e)
				
				scalar `c23' = c
				
				display as text "Harmonic Mean of Level 2 Units per Level 3 Unit" _col(50) "=" _col(51) as result %12.3f `p'
				return scalar p = `p'
				return scalar c23 = `c23'
				
				*variance of icc2 
				scalar `v2' = ((((1-`icc2')^2)*`l2vcv')/`tv4')+(((`icc2'^2)*`l3vcv')/`tv4')-(((2*`icc2')*(1-`icc2')*`c23')/`tv4')
				scalar `se2' = `v2'^.5
				
				*variance of icc3

				scalar `v3' = (((`icc3'^2)*`l2vcv')/`tv4') + ((((1-`icc3')^2)*`l3vcv')/`tv4') - (((2*`icc3')*(1-`icc3')*`c23')/`tv4')
				scalar `se3' = `v3'^.5
				
				*covaraince?

				scalar `cv23' = .
				
				matrix define `b' = (`icc3', `icc2')
				matrix define `V' = (`v3', `cv23' \ `cv23', `v2')
				matrix colnames `b' = `l3var' `l2var'
				matrix rownames `b' = `y'
				matrix colnames `V' = `l3var' `l2var'
				matrix rownames `V' = `l3var' `l2var'		
			}
			restore
		}
		else if `levels' == 3 {
			if "`unbalance'" == "unbalance" {
				display as error "there is no balance option for four level models"
				exit 9
			}
			preserve
			gen `n' = e(sample)
			local lvars = e(ivars)
			local k = 4 
			foreach v in `lvars' {
				local l`k'var "`v'"
				local --k
			}
			local y = e(depvar)
			quietly : _diparm lns1_1_1, function((exp(@))^2) derivative(2*exp(@)^2)			
			scalar `l4vc' = r(est)
			scalar `l4vcv' = (r(se))^2
			quietly : _diparm lns2_1_1, function((exp(@))^2) derivative(2*exp(@)^2)		
			scalar `l3vc' = r(est)
			scalar `l3vcv' = (r(se))^2
			quietly : _diparm lns3_1_1, function((exp(@))^2) derivative(2*exp(@)^2)		
			scalar `l2vc' = r(est)
			scalar `l2vcv' = (r(se))^2
			quietly : _diparm lnsig_e, function((exp(@))^2) derivative(2*exp(@)^2)
			scalar `l1vc' = r(est)
			scalar `tv' = `l1vc' + `l2vc' + `l3vc' + `l4vc'
			scalar `tv4' = ((`tv')^.5)^4
			scalar `icc2' = `l2vc' / `tv'
			scalar `icc3' = `l3vc' / `tv'
			scalar `icc4' = `l4vc' / `tv'
			scalar `icc4bar' = 1-`icc4'
			scalar `icc3bar' = 1-`icc3'
			scalar `icc2bar' = 1-`icc2'
			
			
			collapse (max) `n' if e(sample), by(`l2var' `l3var' `l4var')
			quietly drop if `n' == 0
			collapse (sum) `n', by(`l3var' `l4var')
			quietly: means `n'
			scalar `p' = r(mean_h)
			quietly replace `n' = 1
			collapse (sum) `n', by( `l4var')
			quietly: means `n'
			scalar `q' = r(mean_h)
			
			display as text "Harmonic Mean of Level 2 Units per Level 3 Unit" _col(50) "=" _col(51) as result %12.3f `p'
			return scalar p = `p'
			display as text "Harmonic Mean of Level 3 Units per Level 4 Unit" _col(50) "=" _col(51) as result %12.3f `q'
			return scalar q = `q'
			
			scalar `qp' = `q'*`p'
 			scalar `qp2' = `q'*(`p'^2)
 			scalar `qp2tv4' = `q'*(`p'^2)*`tv4'
 			scalar `qtv4' = `q'*`tv4'
			
			*variance of icc2
 			 			
 			scalar `v2' = ((((`qp2'*(`icc2bar'^2))+(2*`qp'*`icc2'*`icc2bar')+(2*(`icc2'^2)))*`l2vcv')/`qp2tv4') ///
 						+ (((`q'-2)*(`icc2'^2)*`l3vcv')/`qtv4') ///
 						+ (((`icc2'^2)*`l4vcv')/`tv4')
			
			scalar `se2' = `v2'^.5
			
			*variance of icc3 
			 
			scalar `v3' = ((((`qp2'*(`icc3'^2))+(2*(`qp'-1)*`icc3'*`icc3bar'))*`l2vcv')/`qp2tv4') ///
						+ ((((`q'*(`icc3bar'^2))+(2*`icc3'*`icc3bar'))*`l3vcv')/`qtv4') ///
						+ (((`icc3'^2)*`l4vcv')/`tv4')

			scalar `se3' = `v3'^.5			
		
			*variance of icc4
			
			scalar `v4' = ((((`qp'*(`p'-2)*`icc4'^2)-(2*`icc4'*`icc4bar'))*`l2vcv')/`qp2tv4') ///
						+ ((((`q'*(`icc4'^2)) + (2*`icc4'*`icc4bar'))*`l3vcv')/`qtv4') ///
						+ (((`icc4bar'^2)*`l4vcv')/`tv4')
			
			scalar `se4' = `v4'^.5
			
			
			*covariance between icc2 and icc3
			
			scalar `cv23' = ((((-`qp2'*`icc2bar'*`icc3')+(`qp'*((`icc2'*`icc3')-(`icc2bar'*`icc3bar')))-(`icc2'*`icc3bar')+(`icc2'*`icc3'))*`l2vcv')/`qp2tv4') ///
						  - ((((`q'*`icc2'*`icc3bar')-(`icc2'*`icc3bar')+(`icc2'*`icc3'))*`l3vcv')/`qtv4') ///
						  + ((`icc2'*`icc3'*`l4vcv')/`tv4')
										
			*covariance between icc2 and icc4
			
			scalar `cv24' = ((((-1*(`q'*(`p'^2)*`icc2bar'*`icc4'))+(`q'*`p'*((`icc2bar'*`icc4')-(`icc2'*`icc4')))+(`icc2'*`icc4')-(`icc2'*`icc4bar'))*`l2vcv')/(`q'*(`p'^2)*`tv4')) + ((((`q'*`icc2'*`icc4')-(`icc2'*`icc4')+(`icc2'*`icc4bar'))*`l3vcv')/(`q'*`tv4')) - ((`icc2'*`icc4bar'*`l4vcv')/`tv4')		
					
			*covariance between icc3 and icc4 
															
			scalar `cv34' = ((((`qp2'*`icc3'*`icc4')+(`qp'*((`icc3bar'*`icc4')-(`icc3'*`icc4')))+(`icc3'*`icc4')+(`icc3bar'*`icc4bar'))*`l2vcv')/`qp2tv4') ///
						  - ((((`q'*`icc3bar'*`icc4')+(`icc3'*`icc4')+(`icc3bar'*`icc4bar'))*`l3vcv')/`qtv4') ///
						  - ((`icc3'*`icc4bar'*`l4vcv')/`tv4')
			
			matrix define `b' = (`icc4', `icc3', `icc2')
			matrix define `V' = (`v4', `cv34' , `cv24' \ `cv34', `v3' , `cv23' \ `cv24' , `cv23' , `v2') 
			matrix colnames `b' = `l4var' `l3var' `l2var'
			matrix rownames `b' = `y'
			matrix colnames `V' = `l4var' `l3var' `l2var'
			matrix rownames `V' = `l4var' `l3var' `l2var'		

			restore
			
		}
		
		*post results
		
		return local model = e(cmdline)
		return scalar tv = `tv'
		return scalar l1vc = `l1vc'
		return matrix b = `b'
		return matrix V = `V'
		
		
		*display results & calculate ci
		
		scalar `z' = invnormal(1-(`alpha'/2))
		
		local lv = `levels'+1	
		
		display _newline as text "{hline 13}" "{c TT}" "{hline 51}"
		display as text _col(14) "{c |}" _col(19) "ICC" _col(28) "Std. Err." ///
		_col(43) %12.0f "[" (1-`alpha')*100 "% Conf. Interval]"
		display as text "{hline 13}" "{c +}" "{hline 51}"
		
		forvalues level = `lv'(-1)2 {
			return scalar l`level'vc = `l`level'vc'
			return scalar l`level'vc_v = `l`level'vcv'
			scalar `lower' = `icc`level'' - (`z'*`se`level'')
			scalar `higher' = `icc`level'' + (`z'*`se`level'')
			if `lower' < 0 {
				scalar `lower' = 0
			}
			if `higher' > 1 {
				scalar `higher' = 1
			}
			display as text as text %12s abbrev("`l`level'var'",12) _col(14) "{c |}" ///
			_col(15) as result %9.5f `icc`level'' _col(27) as result %9.5f `se`level'' _col(41) ///
			as result %9.5f `lower' _col(54) as result %9.5f `higher'
		}
		display as text "{hline 13}" "{c BT}" "{hline 51}"	
		
		
	}
	else {
		display as error "can't find last xtmixed or mixed estimations"
		exit 301
	}
end
