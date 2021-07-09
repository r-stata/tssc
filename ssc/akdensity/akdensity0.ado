*! version 4.2 18nov2010 -- Ph. Van Kerm    
*   -- change epan option to epanechnikov
*   -- add options kernel() and bwidth() for compatibility with Stata 10+ syntax
* version 4.1 26aug2010 -- Ph. Van Kerm    
*   -- add cdf variability bands
*! version 4.0 10mar2010/13jul2010 -- Ph. Van Kerm    
*   -- add cdf() option
* version 2.0 22sep2005 -- Ph. Van Kerm        (SJ3-2: st0037, SJ4-1: st0037_1, SJ?-?: st0037_2)
* version 1.3 15dec2003 -- Ph. Van Kerm        (SJ3-2: st0037, SJ4-1: st0037_1)
* version 1.2 05jan2003 -- Ph. Van Kerm


* AKDENSITY0 computes adaptive kernel density estimates.
* Essentially official -kdensity- hacked to allow adaptive
* stuff and report variability bands.
* Can be used alone, or as an engine for AKDENSITY
* version 1.3 corrects a bug in -ipolate4-
* version 2.0 corrects an errorin the formula used for
*   computing the variability bands for
*   Epanechnikov kernel. Adds the EPAN2 option
*   for alternative Epanechnikov Kernel.


 program define akdensity0, rclass sortpreserve

    version 7.0

	syntax varname [if] [in] [fw aw] , /*
		*/ AT(varname)  /*
		*/ Generate(string)  /*
		*/ [Width(string) BWidth(string) CDF(string) STDBands(real 0) LAMBDA(string) /*
		*/ EPanechnikov GAUssian EPAN2	Kernel(string)	DOUBLE]

    /** 0. get width: added 20101118 to handle bwidth() and width() **/
  local width  `width' `bwidth'
	local k : word count `width'
	if `k' > 1 {
				di as err "width() and bwidth() are mutually exclusive"
				exit 198
			}
	if `k' == 0 {
				di as err "width() or bwidth() required"
				exit 198
			}	
	**end addition 2010-11-18
		
		
    /** 1. get var names and labels **/
	local ix `"`varlist'"'
	local ixl: variable label `ix'
	if `"`ixl'"'=="" {
		local ixl "`ix'"
	}

    /** 2. check validity of options and mark sample **/
	local gen `"`generat'"'

  ** added 2011-11-18 (to update to Stata 11 -kernel()- option)
  ** copied from kdensity.ado with adjustment to allow only epan epan2 gauss
	local kernel_old  ///
				`epanechnikov'	///
				`gaussian'	///
				`epan2'
	local k : word count `kernel_old'
		if `"`kernel'"' == "" {
			if `k' > 1 {
				di as err "only one kernel may be specified"
				exit 198
			}
			if `k' == 0 {
				local kernel epanechnikov
			}
			else {
				local kernel `kernel_old'
			}
		}
		else {
			if `k' != 0 {
				di as err "kernel(): old syntax "    ///
					  "may not be combined with new syntax"
				exit 198
			}
			local k : word count `kernel'
			if `k' > 1 {
				di as err "only one kernel may be specified"
				exit 198
			}
			_get_kernel_name, kernel(`"`kernel'"')
			local kernel `s(kernel)'
			if `"`kernel'"' == "" {
				di as err "invalid kernel function"
				exit 198
			}
		}  // **end addition 2010-11-18
	
/*	
	local kflag = ( (`"`epan'"' != `""') + (`"`gauss'"' != `""') + (`"`epan2'"' != `""')  )
	if `kflag' > 1 {
		di in red `"only one kernel may be specified"'
		exit 198
	}

    if `"`gauss'"'  != `""' {
       local kernel=`"Gaussian"'
       }
	else {
		if `"`epan2'"'  !=  `""'  {
       		local kernel=`"Alternative Epanechnikov"'
        }
        else {
       local kernel=`"Epanechnikov"'
        }
	}
*/

	marksample use          /* use identifies variables in IF/IN clauses */
	qui count if `use'
	if r(N)==0 { error 2000 }

	confirm new var `generate'
	local yl  `"`generate'"'
	local xl `"`at'"'

	if "`cdf'"~="" {
		confirm new var `cdf'
		qui gen `double' `cdf' = .
	}

	if "`lambda'"~="" {confirm new var `lambda'}

	
    /** 3. prepare the temporary variables **/
	tempvar d m z y
	qui gen `double' `d'=.   /* estimated density at m */
	qui gen double `y'=.   /* value of kernel times weight */
	qui gen `z'=.   /* distance from current grid point */
	qui gen `m'=.   /* grid points */

    /** 4. count number of grid points, create 'm' and sort in grid order **/
	qui count if `at' != .
	local n = r(N)
	qui replace `m' = `at'
	local srtlst : sortedby
	tempvar obssrt
	gen `obssrt' = _n
	sort `m' `obssrt'

    /** 5. care for the weights: generate the tt variable **/
	if "`weight'" != "" {
		tempvar tt
		qui gen double `tt' `exp' if `use'
		qui summ `tt', meanonly
		if "`weight'" == "aweight"  {
			qui replace `tt' = `tt'/r(mean)
		}
	}
	else {
		local tt = 1
	}


    /** 6. computation of the density function **/
	local i 1
  if `"`kernel'"' == `"gaussian"' {
  * if `"`gauss'"' != `""' {
		local con1 = sqrt(2*_pi)
		while `i'<=`n' {
			qui replace `z'=(`ix'-`m'[`i'])/(`width') if `use'
			qui replace `y'= (1/`width')*(exp(-0.5*((`z')^2))/`con1') /* kernel divided by width */
			qui summ `y' [aw=`tt'] , meanonly
			qui replace `d'=(r(mean)) in `i'
			qui replace `y' = .
			if ("`cdf'"!="") {
			  qui replace `y'= normal(-`z') 
			  qui summ `y' [aw=`tt'] , meanonly
			  qui replace `cdf'=(r(mean)) in `i'
			  qui replace `y' = .
			}			
			local i = `i'+1
		}
		qui replace `d'=0 if `d'==. in 1/`n'
	}
	
	else {
  if `"`kernel'"' == `"epan2"' {
	* if `"`epan2'"' != `""' {
		local con1 = 3/4
		local con2 = 1
		local con3 = 1/3
		while `i'<=`n' {
			qui replace `z'=(`ix'-`m'[`i'])/(`width') if `use'
			qui replace `y'= cond(abs(round(`z',1e-8))<=`con2', /*
			   */ (1/`width')*(`con1'*(1-((`z')^2))) , 0) /*
			   */  if `z'~=.
			qui summ `y' [aw=`tt'] if `use' , meanonly
			qui replace `d'=(r(mean)) in `i'
			qui replace `y'=.
			if ("`cdf'"!="") {
			  qui replace `y'= cond(round(-`z',1e-8)<-`con2', 0, cond(round(-`z',1e-8)>`con2',1, /*
			     */ (0.5 + `con1'*(-`z' - `con3'*(-`z')^3) ) )) /*
			     */  if `z'~=.
			  qui summ `y' [aw=`tt'] , meanonly
			  qui replace `cdf'=(r(mean)) in `i'
			  qui replace `y' = .
			}			
			local i = `i'+1
		}
		qui replace `d'=0 if `d'==. in 1/`n'
	}
	else {
		local con1 = 3/(4*sqrt(5))
		local con2 = sqrt(5)
		local con3 = 1/15
		while `i'<=`n' {
			qui replace `z'=(`ix'-`m'[`i'])/(`width') if `use'
			qui replace `y'= cond(abs(round(`z',1e-8))<=`con2', /*
			   */ (1/`width')*(`con1'*(1-(((`z')^2)/5))) , 0) /*
			   */  if `z'~=.
			qui summ `y' [aw=`tt'] if `use' , meanonly
			qui replace `d'=(r(mean)) in `i'
			qui replace `y'=.
			if ("`cdf'"!="") {
			  qui replace `y'= cond(round(-`z',1e-8)<-`con2', 0, cond(round(-`z',1e-8)>`con2',1, /*
			     */ (0.5 + `con1'*(-`z'-(((-`z')^3)/15))) )) /*
			     */  if `z'~=.
			  qui summ `y' [aw=`tt'] , meanonly
			  qui replace `cdf'=(r(mean)) in `i'
			  qui replace `y' = .
			}			
			local i = `i'+1
		}
		qui replace `d'=0 if `d'==. in 1/`n'
	}
	}


    /** 7. if lambda required: generate the lambda variable **/
    if "`lambda'"~="" {
      tempvar fipol
      qui ipolate4 `m' `d' `ix' , generate(`fipol') zero `double'
      qui means `fipol' [aw=`tt'] if `use'
      qui gen `double' `lambda' = sqrt(r(mean_g)/`fipol') if `use'
      }

    /** 8. if std error bands required: generate the bands **/
    if (`stdbands'>0) {
      tempvar hipol
      cap confirm var `width'
      if _rc==0 {qui ipolate4 `ix' `width' `m' , generate(`hipol') epolate}
      else {qui gen `hipol' = `width'}
      tempvar sqw
      tempname totsqw
      qui gen `sqw' = (`tt'^2) if `use'
      su `sqw' , meanonly
      scalar `totsqw' = r(sum)
      qui replace `sqw' = `tt' if `use'
      su `sqw' , meanonly
      if `"`kernel'"' == `"gaussian"' {
      * if `"`gauss'"' != `""' {
  	  	loc const = 1/(2*sqrt(_pi))
  	  	loc constcdf = 1/sqrt(_pi) /* Hansen lec notes */
  	  	}
  	  else {
        if `"`kernel'"' == `"epan2"' {
		    * if `"`epan2'"' != `""' {
			    loc const = 0.6
			    loc constcdf = 9/35  /* Hansen lec notes */
			  }
		   else {
			  loc const = 3/(5*sqrt(5))
			  loc constcdf = 0.57498891 /* pvk calculations */
			  }
		  }
      confirm new variable `yl'_up
      confirm new variable `yl'_lo
      qui gen `double' `yl'_up = `d' + `stdbands'*(sqrt((`totsqw'/((r(sum))^2))*(`d'/`hipol')*(`const')))
      qui gen `double' `yl'_lo = `d' - `stdbands'*(sqrt((`totsqw'/((r(sum))^2))*(`d'/`hipol')*(`const')))
      
	  if ("`cdf'"!="") {
	      	confirm new variable `cdf'_up
    		confirm new variable `cdf'_lo
    		tempvar varcdf
    		qui gen double `varcdf' = max(0, (`totsqw'/((r(sum))^2)) * ( (`cdf' * (1 - `cdf'))  -  (`d'*`hipol'*`constcdf')     ) )
    		/* See Hansen lec notes */ 
      		qui gen `double' `cdf'_up = `cdf' + `stdbands'* sqrt(`varcdf')
      		qui gen `double' `cdf'_lo = `cdf' - `stdbands'* sqrt(`varcdf')
      	}
      }

	/** 9. double save in S_# and r() **/
	ret clear
	ret local kernel `"`kernel'"'
	global S_1   `"`kernel'"'

	/** 10. rename and label created vars **/
	label var `d' `"density: `ixl'"'
	rename `d' `yl'
	if ("`cdf'" != "") {
		lab var `cdf' `"smooth cdf: `ixl'"'
	}

	sort `srtlist' `obssrt'   /* re-put the values in original order then by grid */

end


program define ipolate4 , sortpreserve

	version 7
	syntax varlist(min=3 max=3), generate(string) [ {Zero|epolate} DOUBLE]
    tempvar tmp tmppos
	confirm new var `generate'
	tokenize `varlist'
	local initX "`1'"
	local initY "`2'"
	local newX  "`3'"

	loc sortvar : sortedby

*  ce qui est out-of-range (no extrapolation -> mis a missing par deaut (on peut mettre a zero)

    sort `initX'
	qui count if `initX'~=.
	loc nbinit = _result(1)
    loc i 1
    qui gen `double' `generate' = .
    qui gen `tmppos' = _n

    preserve
     keep `initX' `initY' `newX' `generate' `tmppos'
	 qui stack `initX' `initY' `tmppos' `newX' `generate' `tmppos', into(x y pos) clear
	 if "`epolate'"~="" {
	 	qui ipolate y x , gen(ynew) epolate
	 	}
	 else {
	 	qui ipolate y x , gen(ynew)
	 	if "`zero'"~="" {replace ynew = 0 if ynew==. & x~=. }
	 	}
     qui keep if _stack==2
     rename ynew `tmp'
     drop y x
     * rename x `newX'
     rename pos `tmppos'
     drop _stack
     tempfile tmpsav
     sort `tmppos'
     qui save `"`tmpsav'"' , replace
    restore

    sort `tmppos'
    qui merge `tmppos' using  `"`tmpsav'"'
    qui replace `generate' = `tmp'
    drop _merge

end
