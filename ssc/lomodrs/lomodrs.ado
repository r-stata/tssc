*! version 1.0.3   26jun2006     C F Baum/T Room
*  1.0.2 corr for defn of sample size; supersedes STB version
*  1.0.3 Stata 8 syntax, make byable(recall) and onepanel 
 
program define lomodrs, rclass byable(recall)
	version 8.2
	syntax varname(ts) [if] [in] [ , Maxlag(integer -1) ]  

   	marksample touse
   				/* get time variables; enable onepanel */
   	_ts timevar panelvar if `touse', sort onepanel
//	_ts timevar, sort
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}

	tempvar y count dy my
	qui gen double `y' = `varlist' if `touse'
	qui summ `y',meanonly
	local nobs=r(N)
	local yvar  `varlist'
	local nw 1
	local ss "Lo Modified"
	if `maxlag'==-1 {
* set lag cutoff via Lo (5.1), assuming AR(1) process; ensure that ro>0
		qui regress `y' L.`y' if `touse'
		local ro=_b[L.`y']
		local ro=max(`ro',0.001)
		local nobs=e(N)
		local maxl=abs(int((3.0*`nobs'/2.0)^(1/3)*(2.0*`ro'/(1-`ro'^2))^(2/3)))
		local maxl=int(min(99,`maxl'))
* 0915: guard against lag length exceeding sample size
		if `maxl'>`nobs' { 
			local maxl = int(0.9*`nobs') 
		}
		local kmax = "(`maxl' lags via Andrews criterion)" 
		}
	else 	if `maxlag'==0 {
		local maxl 0
		local kmax = " "
		local ss "Hurst-Mandelbrot Classical"
		local nw 0
		}
	else {
		local maxl=int(min(99,`maxlag'))
* 0915: guard against lag length exceeding sample size
		if `maxl'>`nobs' { 
			local maxl = int(0.9*`nobs') 
		}
		local kmax "(`maxl' lags)"
	}
	if (`nw')  {
		markout `touse' L(1/`maxl').`touse'
	}
	qui gen `count'=sum(`touse')
	local nobs=`count'[_N]
	drop `count'
	if (`nw') {
* nobs reflects the max lag provided or calculated 
* construct the matrix of autocovariances, div by (N-1)
		qui mat accum A = `y' L(1/`maxl').`y' if `touse', dev noc
		mat A = A/(r(N)-1)
* v2 = the sample variance
		local v2=A[1,1]
* calculate the truncated sum of weighted autocovariances
		local j 1
		local s2 0
		while `j'<=`maxl'{
   			local w=1-(`j'/(`maxl'+1))
   			local s2=`s2'+`w'*A[`j'+1,1]
   			local j=`j'+1
		}
* calculate the Newey-West long-run variance
  		local longv2=`v2'+ 2*`s2'
  	}
  	else {
  		qui summ `y'
  		local longv2 = r(Var)
  	}
* generate the demeaned series
  	qui summ `y',meanonly
 	qui gen double `dy'=`y'-r(mean) if `touse'
* generate my = vector of partial sums of dy (j-th element = sum to j) 
 	qui gen double `my'=sum(`dy') if `touse'
* obtain the max and min values of my
  	qui summ `my' if `touse'
  	local enn=r(N)
 	local maxy=r(max)
 	local miny=r(min)
* calculate Lo's modified R/S statistic (Lo, 1991, (3.5) on p.1289),
* divided by root(N) for hypothesis test vs Table 2 fractiles
 	local stat=(`maxy'-`miny')/(`longv2'*`enn')^(1/2) 
	di " "
	di in gr "`ss' R/S test for `yvar'"
	di " "
	di in gr "Critical values for H0: `yvar' is not long-range dependent"
        di " "
        di in gr "90%: [ 0.861, 1.747 ]"
        di in gr "95%: [ 0.809, 1.862 ]"
        di in gr "99%: [ 0.721, 2.098 ]" 
        di " "
	di "Test statistic: " %8.3g `stat' "  `kmax'  N = " `enn'
	return scalar N = `enn'
	return scalar lomodrs = `stat'	
	end
	exit      
