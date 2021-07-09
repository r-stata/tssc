* Version: January 2008
* Alejandro Lopez-Feldman
* Escuela de Economia
* Universidad de Guanajuato
* lopezfeldman@gmail.com
program descogini, eclass sortpreserve 
	version 8
	syntax varlist(min=2 numeric) [if] [in] [, d(integer 4) BARs] 

	quietly {
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 
		local N = r(N)
		replace `touse' = -`touse' 

		tempname meantot mean cov b V 
		tempvar y yt work 
		gettoken total varlist: varlist

		sum `total' if `touse', meanonly
		scalar `meantot' = r(mean)              
		sort `touse' `total', stable
		g double `yt' = _n/`N' if `touse'
		corr `total' `yt' if `touse', cov
		g double `work' = sum(_n * `touse' * (`meantot' - `total')) 
		scalar gtotal = (2 * `work'[_N])/(`N'^2 * `meantot') 

		g double `y' = . 
	}

	di _n as txt "{title:Gini Decomposition by Income Source}"
	di _n as txt "Total Income Variable:" as res " `total'"
	di as txt "{hline 70}"

	if "`bars'" != "" { 
		di as txt "Source " _col(15)  "|Sk" _col(28) "|Gk"  ///
		_col(40) "|Rk" _col(52) "|Share" _col(62) "|% Change" 
		local B "|" 
	}
	else di as txt "Source " _col(18)  "Sk" _col(31) "Gk" ///
		_col(43) "Rk" _col(53) "Share" _col(63) "% Change"

	di as txt "{hline 70}"
	local fmt "%`= `d' + 3'.`d'f"					
	matrix `b' = J(1,`: word count `varlist'', .) 
	local j = 1 

	quietly foreach var of local varlist {
		sum `var' if `touse', meanonly
		scalar `mean' = r(mean) 
		scalar s`var' = r(mean)/`meantot'
		sort `touse' `var', stable
		replace `y' = _n/`N' if `touse'
	
		corr `var' `yt' if `touse', cov
		scalar `cov' = r(cov_12)
		corr `var' `y' if `touse', cov
		scalar r`var' = `cov'/ r(cov_12) 

		replace `work' = sum(_n * `touse' * (`mean' - `var')) 
		scalar g`var' = (2 * `work'[_N])/(`N'^2 * `mean') 
		scalar sg`var' = ///
		scalar(s`var') * scalar(r`var') * scalar(g`var')/scalar(gtotal)
		scalar mg`var' = scalar(sg`var') - scalar(s`var')
		matrix `b'[1,`j++'] = mg`var' 

		noisily di as res abbrev("`var'", 13)              ///
		                  _col(15) "`B'" `fmt' s`var'      ///
			          _col(28) "`B'" `fmt' g`var'      ///
				  _col(40) "`B'" `fmt' r`var'      ///
			          _col(52) "`B'" `fmt' sg`var'     ///
				  _col(63) "`B'" `fmt' mg`var' 
	}		
			
	di as txt "Total income" _col(28) as res "`B'`B'" `fmt'  gtotal  
	di as txt "{hline 70}"

	qui replace `touse' = -`touse' 
	matrix colnames `b' = `varlist'
	ereturn post `b' , esample(`touse') obs(`N')
	ereturn local cmd "descogini"
end
