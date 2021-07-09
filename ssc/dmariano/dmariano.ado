*! version 1.0.3  26apr2011  CFBaum
* 1.0.1: 04feb2003
* 1.0.2: 27jun2006, corrected for calculation of autocovariances using Mata
* 1.0.3: 26apr2011, add Oliver Jones' suggested MAPE criterion

program define dmariano, rclass
	version 9.2
	syntax varlist(ts min=3 max=3) [if] [in] [, Crit(string) Maxlag(integer -1) Kernel(string)]
	marksample touse
	_ts timevar, sort
	markout `touse' `timevar'
* MSE default criterion
	local criterion "MSE"
	if upper("`crit'") == "MSE" | upper("`crit'") == "MAE" | upper("`crit'") == "MAPE" {
		local criterion = upper("`crit'")
		}
	else if "`crit'" != "" {
		dis as err ///
			"The accuracy measure you specified is not available."
		exit
		}
* Uniform default kernel
	local window "uniform"
	if lower("`kernel'") == "uniform" | lower("`kernel'") == "bartlett" {
		local window = lower("`kernel'")
		}
	tempvar  e1 e2 d count
	tempname lrvar T J s1 gamma
* get the three variables
	tokenize `varlist'
	local depvar `1'
	local fcvar1 `2'
	local fcvar2 `3'
* set maxlag
	qui	gen `count' = sum(`touse')
	local nobs = `count'[_N]
	if `maxlag' == -1 {
* set maxlag via Schwert criterion (Ng/Perron JASA 1995)
		local maxlag = int(12*(`nobs'/100)^0.25)
		local kmax = "Maxlag = `maxlag' chosen by Schwert criterion" 
		}
	else {
		local kmax "Maxlag = `maxlag'"
		}
* calculate e1 and e2
	if "`criterion'" == "MSE" {
		qui gen double `e1' = (`depvar' - `fcvar1')^2 if `touse'
		qui gen double `e2' = (`depvar' - `fcvar2')^2 if `touse'
		}
	else if "`criterion'" == "MAE" {
		qui gen double `e1' = abs(`depvar' - `fcvar1') if `touse'
		qui gen double `e2' = abs(`depvar' - `fcvar2') if `touse'
		}
	else if "`criterion'" == "MAPE" {
		qui gen double `e1' = abs((`depvar' - `fcvar1')/`depvar') if `touse'
		qui gen double `e2' = abs((`depvar' - `fcvar2')/`depvar') if `touse'
		}
	qui {
		gen double `d' = `e1' - `e2' if `touse'
		summ `e1' if `touse', meanonly
		local e1bar = r(mean)
		summ `e2' if `touse', meanonly
		local e2bar = r(mean)	
		summ `d' if `touse', meanonly
		local T = r(N)
		local dbar = r(mean)
		}
 
* generate autocovariances of d series
	local varlist2 L(0/`maxlag').`d'
	tsrevar `varlist2'
	local varlist3 `r(varlist)'
	local ml1 = `maxlag' + 1
	mata:  autocov("`varlist3'",`dbar',"`touse'")
    scalar `J' = __gamma[1,1]
    forv l = 1/`maxlag' {
* uniform kernel is unweighted; otherwise use Bartlett kernel
        local w 1
        if "`window'" == "bartlett" {
        	local w = 1 - (`l'/(`maxlag'+1))
        	}
        scalar `J' = `J' + 2*`w'*__gamma[`l'+1,1]
        }       
    scalar `lrvar' = sqrt(`J'/`T')
    if `lrvar' == . {
    	di _n "Long-run variance is non-positive for this kernel and truncation lag."
    	error 506
    	}
*
	qui {
		tsset
		summ `r(timevar)' if `touse'
		}	
	return scalar e1bar = `e1bar'
	return scalar e2bar = `e2bar'
 	return scalar dbar = `dbar'
 	return scalar lrsd = `lrvar'
	return scalar s1 = `dbar'/`lrvar'
	return scalar p = 2*normprob(-abs(return(s1)))
	return scalar nobs = `T'
	return scalar maxlag = `maxlag'
	return local criterion  `criterion'
	return local kernel  `window'
	di _n "Diebold-Mariano forecast comparison test for actual : {res:`depvar'}" 
*	di in gr "Forecast period : " %tm r(min) " -" %tm r(max) "  N : `nobs'"
	di "Competing forecasts:  {res:`fcvar1'} versus {res:`fcvar2'}"
	di "Criterion: " return(criterion) " over " return(nobs) " observations"
	di in gr "`kmax'   Kernel : " return(kernel)
	di in gr _n "Series" _col(24)  return(criterion)
 	di in gr _dup(30) "_"
	di in ye "{res:`fcvar1'}" _col(20) in gr %9.4g `e1bar' 
	di in ye "{res:`fcvar2'}" _col(20) in gr %9.4g `e2bar' 
	di "Difference" _col(20) %9.4g `dbar' 
	local better `fcvar1'
	if `e1bar'>`e2bar' {
		local better `fcvar2'
		}
	di _n "By this criterion, {res:`better'} is the better forecast"
	di "H0: Forecast accuracy is equal."
	di "S(1) = " %9.4g return(s1)   "  p-value = " %5.4f return(p)  _n
*	di "Forecast comparison statistic : " %9.4g  
*	di "H0 : no difference in accuracy, distributed N(0,1) with pval = " %5.4f return(p)
	di _n
*
end

mata:
mata set matastrict on
void autocov(string scalar vname, real scalar dbar, string scalar touse)
{
        real matrix X, gamma
        real scalar T
        string rowvector vars
        string scalar v
   // access the Stata variables in varlist, respecting touse
        vars = tokens(vname)
        v = vars[|1,.|]
        st_view(X,.,v,touse)
// demean by dbar
		X = X :- dbar
// change all missing values to 0, which will be ignored in cross
		_editmissing(X,0)
// apply cross to get the covariances and scale by T
        gamma = cross(X,X) :/ strtoreal(st_local("T"))
// return the __gamma matrix
		st_matrix("__gamma",gamma)
}
end

		        
	
