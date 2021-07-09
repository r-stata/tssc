*! version 1.1.0  //  Ariel Linden 01may2019 || removed restriction that "df" be limited to linear models
*! version 1.0.0  //  Ariel Linden 25apr2019 

program define getregstats, rclass
version 11.0

	syntax anything ,			///
		[ MODel(string)			/// model types include linear and exponentiated
		SE(numlist max=1)		/// std err
		DF(numlist max=1)		/// degrees of freedom (for t-distribution)
		Zstat(numlist max=1)	/// z or t depending on model
		Pval(numlist max=1)		/// p value
		Lcl(numlist max=1)		/// lower CI
		Ucl(numlist max=1)		/// upper CI
		LEVel(real 95)			/// 
		]

    numlist "`anything'", max(1)

	local b = `anything' 

	// * Error checking * //
	if "`se'" == "" & "`zstat'" == "" & "`pval'" == "" & "`lcl'" == "" & "`ucl'" == "" {
		di as err "one of the following options must be entered: zstat, pval, lcl, or ucl" 
		exit 198
	}
	
	if !inlist("`model'", "lin", "exp", "or", "hr", "irr", "rr", "rd","")  {
		di as err "`model' is an invalid model type" 
		exit 198
	}
	
	if `level' <0 | `level'>99.99 { 
		di as err "level() must be between 0 and 99.99 inclusive"
		exit 198
	}   

	if "`pval'" != "" {
		if `pval' <= 0 | `pval'> 0.999 {
			di as err "pval() must be > 0 and < 1.0"
			exit 198
		}   
	}
	if "`se'" != "" {
		if `se' < 0 {
			di as err "se cannot be negative" 
			exit 411
		}
	}

	local levelci = `level' * 0.005 + 0.50
	local mlevelci = 1- `levelci'


	*************************************************************************************
	* linear models (producing coefficients), e.g. regress, logit, poisson, stcox (nohr) 
	*************************************************************************************
	if inlist("`model'", "lin", "rd") | "`model'"  == "" {
		
		*** for a t-distribution ***
		if "`df'" != "" {
			// * compute std err * //
			if "`se'" == "" {
				if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
				}
				else if "`pval'" != "" {
					local zstat = invttail(`df', `pval'/2)
					local se = abs(`b' /`zstat')
				}
				else if "`lcl'" != "" {
					local se = abs((`b' - `lcl')/invttail(`df',`mlevelci'))
				}
				else if "`ucl'" != "" {
					local se = abs((`ucl' - `b')/invttail(`df',`mlevelci')) 
				}
			} // end se

			// * compute zstat (t-stat when df is specified)* //
			if "`zstat'" == "" {
				if "`se'" != "" {
					local zstat = (`b' /`se')
				}
				else if "`pval'" != "" {
					local zstat	= invttail(`df', `pval'/2)
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invttail(`df',`mlevelci')
					local zstat	= invttail(`df', `pval'/2)
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invttail(`df',`mlevelci') 
					local zstat	= invttail(`df', `pval'/2)
				}
			} // end zstat

			// * compute pval * //
			if "`pval'" == "" {
				if "`zstat'" != "" {
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`se'" != "" {
					local zstat = `b' /`se'
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invttail(`df',`mlevelci')
					local zstat	= invttail(`df', `pval'/2)
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invttail(`df',`mlevelci')
					local zstat	= invttail(`df', `pval'/2)
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
			} // end pval
			
			// * compute lcl * //
			if "`lcl'" == "" {
				if "`se'" != "" {
					local lcl = `b' - invttail(`df',`mlevelci') * `se'
				}
				else if "`pval'" != "" {
					local zstat	= invttail(`df', `pval'/2)
					local se = abs(`b' /`zstat')
					local lcl = `b' - invttail(`df',`mlevelci') * `se'
				}
				else if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
					local lcl = `b' - invttail(`df',`mlevelci') * `se'
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invttail(`df',`mlevelci')
					local lcl = `b' - invttail(`df',`mlevelci') * `se'
				}
			} // end lcl
			
			// * compute ucl * //
			if "`ucl'" == "" {
				if "`se'" != "" {
					local ucl = `b' + invttail(`df',`mlevelci') * `se'
				}
				else if "`pval'" != "" {
					local zstat	= invttail(`df', `pval'/2)
					local se = abs(`b' /`zstat')
					local ucl = `b' + invttail(`df',`mlevelci') * `se'
				}
				else if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
					local ucl = `b' + invttail(`df',`mlevelci') * `se'
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invttail(`df',`mlevelci')
					local lcl = `b' + invttail(`df',`mlevelci') * `se'
				}
			} // end ucl
		} // end if df != ""
		
		*** for a z-distribution ***
		else if "`df'" == "" {
			
			// * compute std err * //
			if "`se'" == "" {
				if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local se = abs(`b' /`zstat')
				}
				else if "`lcl'" != "" {
					local se = abs((`b' - `lcl')/invnorm(`levelci')) 
				}
				else if "`ucl'" != "" {
					local se = abs((`ucl' - `b')/invnorm(`levelci')) 
				}
			} // end se
			
			// * compute zstat * //
			if "`zstat'" == "" {
				if "`se'" != "" {
					local zstat = `b' /`se'
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invnorm(`levelci') 
					local zstat = `b' /`se'
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invnorm(`levelci') 
					local zstat = `b' /`se'
				}
			} // end zstat
						
			// * compute pval * //
			if "`pval'" == "" {
				if "`zstat'" != "" {
					local pval = 2 * normal(-abs(`zstat'))
				}
				else if "`se'" != "" {
					local zstat = `b' /`se'
					local pval = 2*(1-normal(abs(`zstat')))
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invnorm(`levelci') 
					local zstat = `b' /`se'
					local pval = 2*(1-normal(abs(`zstat')))
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invnorm(`levelci') 
					local zstat = `b' /`se'
					local pval = 2*(1-normal(abs(`zstat')))
				}
			} // end pval

			// * compute lcl * //
			if "`lcl'" == "" {
				if "`se'" != "" {
					local lcl = `b' - invnorm(`levelci') * `se'
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local se = abs(`b' /`zstat')
					local lcl = `b' - invnorm(`levelci') * `se'
				}
				else if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
					local lcl = `b' - invnorm(`levelci') * `se'
				}
				else if "`ucl'" != "" {
					local se = (`ucl' - `b')/invnorm(`levelci') 
					local lcl = `b' - invnorm(`levelci') * `se'
				}
			} // end lcl
		
			// * compute ucl * //
			if "`ucl'" == "" {
				if "`se'" != "" {
					local ucl = `b' + invnorm(`levelci') * `se'
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local se = abs(`b' /`zstat')
					local ucl = `b' + invnorm(`levelci') * `se'
				}
				else if "`zstat'" != "" {
					local se = abs(`b' /`zstat')
					local ucl = `b' + invnorm(`levelci') * `se'
				}
				else if "`lcl'" != "" {
					local se = (`b' - `lcl')/invnorm(`levelci') 
					local ucl = `b' + invnorm(`levelci') * `se'
				}
			} // end ucl
		} // end if df == ""
	} // end linear models			
	
	*********************************************
	* Exponentiated models, e.g. OR, HR, IRR, RR
	*********************************************
	if inlist("`model'", "exp", "or", "hr", "irr", "rr")  {
	
		*** for a t-distribution ***
		if "`df'" != "" {
			// * compute std err * //
			if "`se'" == "" {
				if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local se = abs(`b' * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invttail(`df', `pval'/2)
					local linse = ln(`b') /`zstat'
					local se = abs(`b' * `linse')
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invttail(`df',`mlevelci')) 
					local se = abs(`b' * `linse')
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invttail(`df',`mlevelci')) 
					local se = abs(`b' * `linse')
				}
			} // end se
		
			// * compute zstat * //
			if "`zstat'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local zstat = ln(`b') /`linse'
				}
				else if "`pval'" != "" {
					local zstat = invttail(`df', `pval'/2)
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invttail(`df',`mlevelci')) 
					local se = `b' * `linse'	
					local zstat = (`b' /`se')
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invttail(`df',`mlevelci'))  
					local se = `b' * `linse' 
					local zstat = (`b' /`se')
				}
			} // end zstat
		
			// * compute pval * //
			if "`pval'" == "" {
				if "`zstat'" != "" {
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`se'" != "" {
					local linse = `se' / `b'
					local zstat = ln(`b') /`linse'
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invttail(`df',`mlevelci') 
					local se = `b' * `linse'	
					local zstat = (`b' /`se')
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invttail(`df',`mlevelci') 
					local se = `b' * `linse' 
					local zstat = (`b' /`se')
					local pval = 2 * ttail(`df',abs(`zstat'))
				}
			} // end pval
		
			// * compute lcl * //
			if "`lcl'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local lcl = exp(ln(`b') - invttail(`df',`mlevelci') * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invttail(`df', `pval'/2)
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invttail(`df',`mlevelci') * `linse')
				}
				else if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invttail(`df',`mlevelci') * `linse')
				}
				else if "`ucl'" != "" {
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invttail(`df',`mlevelci') * `linse')
				}
			} // end lcl

			// * compute ucl * //
			if "`ucl'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local ucl = exp(ln(`b') + invttail(`df',`mlevelci') * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invttail(`df', `pval'/2)
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invttail(`df',`mlevelci') * `linse')
				}
				else if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invttail(`df',`mlevelci') * `linse')
				}
				else if "`lcl'" != "" {
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invttail(`df',`mlevelci') * `linse')
				}
			} // end ucl
		} // end if "`df'" != ""
		
		*** z-distribution ***
		if "`df'" == "" {
			// * compute std err * //
			if "`se'" == "" {
				if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local se = abs(`b' * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local linse = ln(`b') /`zstat'
					local se = abs(`b' * `linse')
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invnorm(`levelci') 
					local se = abs(`b' * `linse')
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invnorm(`levelci') 
					local se = abs(`b' * `linse')
				}
			} // end se

			// * compute zstat * //
			if "`zstat'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local zstat = ln(`b') /`linse'
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invnorm(`levelci') 
					local se = `b' * `linse'	
					local zstat = `b' /`se'
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invnorm(`levelci') 
					local se = `b' * `linse' 
					local zstat = `b' /`se'
				}
			} // end zstat

			// * compute pval * //
			if "`pval'" == "" {
				if "`zstat'" != "" {
					local pval = 2 * normal(-abs(`zstat'))
				}
				else if "`se'" != "" {
					local linse = `se' / `b'
					local zstat = ln(`b') /`linse'
					local pval = 2*(1-normal(abs(`zstat')))
				}
				else if "`lcl'" != "" {
					local linse = ln(`b'/`lcl')/invnorm(`levelci') 
					local se = `b' * `linse'	
					local zstat = (`b' /`se')
					local pval = 2*(1-normal(abs(`zstat')))
				}
				else if "`ucl'" != "" {
					local linse = ln(`ucl'/`b')/invnorm(`levelci') 
					local se = `b' * `linse' 
					local zstat = `b' /`se'
					local pval = 2*(1-normal(abs(`zstat')))
				}
			} // end pval
	
			// * compute lcl * //
			if "`lcl'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local lcl = exp(ln(`b') - invnorm(`levelci') * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invnorm(`levelci') * `linse')
				}
				else if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invnorm(`levelci') * `linse')
				}
				else if "`ucl'" != "" {
					local linse = ln(`b') /`zstat'
					local lcl = exp(ln(`b') - invnorm(`levelci') * `linse')
				}
			} // end lcl
	
			// * compute ucl * //
			if "`ucl'" == "" {
				if "`se'" != "" {
					local linse = `se' / `b'
					local ucl = exp(ln(`b') + invnorm(`levelci') * `linse')
				}
				else if "`pval'" != "" {
					local zstat = invnorm(`pval'/2)
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invnorm(`levelci') * `linse')
				}
				else if "`zstat'" != "" {
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invnorm(`levelci') * `linse')
				}
				else if "`lcl'" != "" {
					local linse = ln(`b') /`zstat'
					local ucl = exp(ln(`b') + invnorm(`levelci') * `linse')
				}
			} // end ucl
		} // end if "`df'" == ""
	} // end exponentiated models			

	***********************
	*** DISPLAY RESULTS ***
	***********************
	
	// * z or t value * //
	if "`df'" != "" {
		local zt t
		local ztp P>|t|
	}
	else {
		local zt z
		local ztp P>|z|
	}

	// * display outcome type"
	if "`model'" == "exp" { 
		local est _col(16) "Exp. Coef. "
	}
	else if "`model'" == "or" { 
		local est _col(16) "Odds Ratio "
	}
	else if "`model'" == "hr" { 
		local est _col(16) "Haz. Ratio "
	}
	else if "`model'" == "rr" { 
		local est _col(16) "Risk Ratio "
	}
	else if "`model'" == "rd" { 
		local est _col(16) "Risk Diff. "
	}
	else if "`model'" == "irr" {
		local est _col(23) "IRR"
	}
	else {
		local est _col(21) "Coef. "
	}
	
	local clv `level'
	local cil `=length("`clv'")'
	di _newline(1)
	#delim ;
	di in smcl in gr "{hline 13}{c TT}{hline 64}"
	_newline "             {c |}"
	`est'	// model type //
	_col(29) "Std. Err."
	_col(44) "`zt'"
	_col(49) "`ztp'"
	_col(`=61-`cil'') `"[`clv'% Conf. Interval]"'
	_newline
	in gr in smcl "{hline 13}{c +}{hline 64}"
	_newline
	_col(1) "   Estimates"
	_col(14) "{c |}" in ye
	_col(17) %9.0g `b'
	_col(28) %9.0g `se'
	_col(38) %8.2f `zstat'
	_col(49) %5.3f `pval'
	_col(58) %9.0g `lcl'
	_col(70) %9.0g `ucl'
	_newline
	in gr in smcl "{hline 13}{c BT}{hline 64}"
	;
	#delim cr

	// * saved values * //
	return scalar ucl = `ucl'
	return scalar lcl = `lcl'
	return scalar pval = `pval'
	return scalar z = `zstat'
	return scalar se = `se'
	return scalar b = `b'
end

