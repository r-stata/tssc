prog drop _all
*! arimasel 1.0.0  cfbaum 12sep2020
*! requires arimafit from ssc
prog arimasel, rclass
version 13
syntax varname(ts) [if] [in] [, AR(int 3) MA(int 3) ITER(int 100) MATrix(string) GRAPH]
tempname res
marksample touse
qui count if `touse'
	if r(N)==0 {
		error 2000
	}
loc EN = r(N)
qui tsset
capt which arimafit
if (_rc > 0) {
	ssc install arimafit
}
loc en = (`ar'+1) *(`ma'+1) -1
mat `res' = J(`en',6,.)
loc vv maxLLF minAIC minSIC 
foreach v of local vv {
	tempvar `v'
	qui g ``v'' = .
}
tempvar en
qui g `en' = _n
loc k 0
forv i=0/`ar' {
	forv j=0/`ma' {
		if (`i'+`j' > 0) {
		loc ++k
		loc rn "`rn' Model`k'"
		di "Model`k': AR(`i') MA(`j')"
		mat `res'[`k',1] = `i'
		mat `res'[`k',2] = `j'
		if (`i'==0) {
		qui arima `varlist' if `touse', ma(1/`j') iter(`iter')
		}
		else if (`j'==0) {
		qui arima `varlist' if `touse', ar(1/`i') iter(`iter')
		}
		else {
		qui arima `varlist' if `touse', ar(1/`i') ma(1/`j') iter(`iter')
		}
		qui if (e(converged)) {
			mat `res'[`k',4] = e(ll)
			qui arimafit
			mat `res'[`k',3] = r(np)
			mat `res'[`k',5] = r(aic)
			mat `res'[`k',6] = r(sic)
			replace `maxLLF' = e(ll) in `k'
			replace `minAIC' = r(aic) in `k'
			replace `minSIC' = r(sic) in `k'
			}
		}
	}
}
mat rownames `res' = `rn'
mat colnames `res' = AR MA Nparm LLF AIC SIC
matlist `res'

mata: max2min("`res'")
di _n "Max LLF: Model `vmaxLLF'"
di    "Min AIC: Model `vminAIC'"
di    "Min SIC: Model `vminSIC'"
return scalar maxllf = `vmaxLLF'
return scalar minaic = `vminAIC'
return scalar minsic = `vminSIC'
return scalar N = `EN'
return local varname `varlist'
if "`matrix'" != "" {
	return matrix `matrix' = `res'
}
if "`graph'" != "" {
	foreach v of local vv {
		lab var ``v'' " "
		lab var `en' "Model"
		line ``v'' `en' if !mi(``v''), ylab(#3,angle(0)) ti("`v'") ///
		xline(`v`v'') nodraw name("`v'",replace)	
	}
	gr combine  `vv', col(1)
}
end

version 13
mata:
void function max2min(string scalar res)
{
	real colvector ind
	real colvector w
	results = st_matrix(res)
	maxindex(results[.,4],1,ind,w)
	st_local("vmaxLLF", strofreal(ind[1]))
	minindex(results[.,5],1,ind,w)
	st_local("vminAIC", strofreal(ind[1]))
	minindex(results[.,6],1,ind,w)
	st_local("vminSIC", strofreal(ind[1]))
}
end


