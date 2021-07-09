*! version 1.1.5     24sep2008    C F Baum / Fabian Bornhorst
*  Andrew Levin, Chien-Fu Lin, Chai-Shang James Chu,
*  J. Econometrics 2002, 108, 1-24 (LLC)
*  Andrew Levin and Chien-Fu Lin, Unit Root Tests in Panel Data: New Results, 
*  UCSD DP 93-56
* v1.0.1 : 2A20 cfb Corrections indicated by Gene Liang in demeaning, calc
*		   LR variance, correction factor table lookup
* v1.1.1 : 4B14 cfb Correction for Andrews truncation rule
* v1.1.2:  4B29 cfb Trap zero unit variation
* v1.1.3:  5C02 cfb Correction to zero unit variation logic
* v1.1.4:  6618 cfb Correction to make case tempname, change subroutine call accordingly
* v1.1.5:  8924 cfb Correction to index demeaned vars by panel unit rather than panelvar code

program define levinlin, rclass
	version 7.0
	syntax varname(ts) [if] [in] , Lags(numlist int >=0) [ Trend noConstant ]  

	qui tsset
	local id `r(panelvar)'
	local time `r(timevar)'
	tempname case 
	
    if "`constant'" != "" & "`trend'" == "" { 
    		scalar `case'=1
    		local det ",noc"
    		local text "none"
			}
        else if "`constant'" == "" & "`trend'" == "" { 
        	scalar `case'=2
        	local text "constant"
        	}
        else if "`constant'" == "" & "`trend'" != "" { 
        	scalar `case'=3
        	local text "constant & trend"
        	}
        else {
        	di in red "You cannot choose trend and no constant!"
        	error 198
             }
    di in gr _n "Levin-Lin-Chu test for " in ye "`varlist'" _col(35) in gr "Deterministics chosen: " in ye "`text'"
	
   	marksample touse
	markout `touse' `time'
	tsreport if `touse', report panel
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		error 198
	}
	qui xtsum `time' if `touse'
// N: number of panel units
	local N `r(n)'
	local T `r(Tbar)'
	if int(`T')*`N' ~= r(N) {
		di in red "panel must be balanced"
		error 198
		}
	local tmin `r(min)'
	local tmax `r(max)'
	local npi : word count `lags'
 	tempname Vals 
	tempvar eps epstil vl vltil hold dy dy2 vvar
* copy variable to prevent alteration and allow ts ops
	qui gen double `vvar' = `varlist' if `touse'
	if "`trend'" ~= "" {
		local trend "`time'"
		}
* remove common time effects per LLC p.13
	forv t = `tmin'/`tmax' {
		qui { 
			su `vvar' if `time' == `t' & `touse' /*, meanonly */
			replace `vvar' = `vvar' - r(mean) if `time' == `t' & `touse'
			}
		}
* 4B29 corr 5C02: guard against no unit variation
	qui su `vvar' 
	if abs(r(sd))<1d-10 {
		di as err _n "Error: no variation across units."
		error 2000
		}
* 2A20: relocate generating lags here to ensure that the lagged variables
*       correspond to the time-demeaned variable
// single lag common to all panel units
	if `npi' == 1 {
		forv i=1/`N' {
			local ps`i' = `lags'
			if `lags' > 0 {
				local tps`i' "L(1/`lags')D.`vvar'"
			}
		}
		scalar lavg = `lags'
		}
	else if `npi' ~= `N' {
		di in r "Error: For `N' panel units, either 1 or `N' lag lengths must be specified"
		error 198
		}
	else {
		scalar lavg = 0
// lag specified for each panel unit
		forv i = 1/`N' {
			local ps`i' : word `i' of `lags'
			if `ps`i'' > 0 {
				local tps`i' "L(1/`ps`i'')D.`vvar'"
				scalar lavg = lavg + `ps`i''
			}
		}
		scalar lavg = lavg / `N'
		}
* define unit identifier
    qui tab `id' if `touse', matrow(`Vals') 
    local nvals = r(r)
/* 4B29: mod to forv per NJC    
    local i = 1
    while `i' <= `nvals' {
    	local val = `Vals'[`i',1]
    	local vals "`vals' `val'"
    	local i = `i' + 1
    	}
 */
 	forv i = 1/`nvals' {
 		local val = `Vals'[`i',1]
    		local vals "`vals' `val'"
    		}
	qui {
		gen double `eps' = .
		gen double `epstil' = .
		gen double `vl' = .
		gen double `vltil' = .
		gen double `dy' = .
		gen double `dy2' = .
		}
	scalar ttil = `T' - lavg - 1
	scalar sn = 0
	scalar vn = 0
* LL truncation (p. 24, due to Andrews)
    local trunc = int(3.21*((ttil)^(1/3)))
* 4A11: guard against insufficient obs. 
    if (`trunc' > `T'-3) {
    		local trunc = `T'-3
    		di in r "Reducing Andrews truncation"
    		}
* double Bartlett weights, div by (asy) T-1
    forv i=1/`trunc' {
    	scalar w`i' = 2.0/(`T'-1)*(1.0-(`i'/(`trunc'+1)))
    	}
// di as err "vals `vals'"
	local jpan 0
	foreach i of local vals {
    	qui { 
* LLC eqn 2 (LL eqns 2, 3, 4)
// corr 8924: must reference number of panel unit rather than panelvar value
			local ++jpan
// noi di as err "*** `i' `jpan' `tps`jpan''"
// noi su D.`vvar' `tps`jpan'' `trend' if `id'==`i' & `touse'
    /*noi*/	reg D.`vvar' `tps`jpan'' `trend' if `id' == `i' & `touse' `det' 
			capt drop `hold' 
			predict double `hold' if e(sample), r 
		 	replace `eps' = `hold' if e(sample)
	/*noi*/ reg L.`vvar' `tps`jpan'' `trend' if `id' == `i' & `touse' `det' 
			capt drop `hold'
			predict double `hold' if e(sample), r 
		 	replace `vl' = `hold' if e(sample)
* (LLC eqn 4 (LL eqns 5, 6, 7)
		 	regress `eps' `vl' if e(sample), noc
		 	scalar se`i' = e(rmse)
		 	replace `epstil' = `eps' / se`i' if e(sample)
		 	replace `vltil' = `vl' / se`i' if e(sample)
* LLC eqn 5 (LL eqn 8, term 1): rewritten 2A21
			if `case'==1 {
				replace `dy' = D.`vvar' if `id' == `i' & `touse'
			}
			else if `case'==2 {
				su D.`vvar' if `id' == `i' & `touse', meanonly
				replace `dy' = D.`vvar' - r(mean) if `id' == `i' & `touse'
			}
			else if `case'==3 {
				reg D.`vvar' `time' if `id' == `i' & `touse'
				capt drop `hold'
				predict double `hold' , r
				replace `dy' = `hold' if e(sample)
			}
			replace `dy2' = `dy'^2 if `id' == `i' & `touse'
		 	su `dy2' if `id' == `i' & `touse',meanonly
		 	scalar s2y`i' = r(mean)
* LLC eqn 5 (LL eqn 8 term 2)
/* set trace on
di in r "`trunc'  `i'"
noi su `dy' if `id' == `i' & `touse'
*/
		 	forv l=1/`trunc' {
		 		mat accum dd = `dy' L`l'.`dy' if `id' == `i' & `touse', noc
		 		scalar s2y`i' = s2y`i' + w`l'* dd[2,1]
			} 
			scalar sy`i' = sqrt(s2y`i')
* LLC eqn 6 (LL eqn 9)
			scalar s`i' = sy`i'/se`i'
			scalar ess2 = se`i'^2
*			noi di   "`i' " " " ess2 " " s2y`i'
			scalar sn = sn + s`i'
*			scalar vn = sn + s`i'*s`i'
			}
		}
* LL eqn 10
	scalar sn = sn/`N'
*	scalar vn = vn/`N'
* LLC eqn 8 (LL eqn 11): calculate sige, rse with large-sample divisor
//	su `epstil' `vltil'
	qui regress `epstil' `vltil', noc
	scalar sige = e(rmse)*sqrt(e(df_r)/e(N))
	scalar delta = _b[`vltil']
	matrix v = e(V)
	scalar rse = sqrt(v[1,1]*e(df_r)/e(N))
	scalar tee = delta/rse
* LLC eqn 12 (LL eqn 16)
	_getLL, case(`case') ttil(ttil)
* di "N, ttil, sn, sige, rse, r(mustar) `N' " ttil " " sn " " sige " " rse " " r(mustar)
* di "tee, r(sigstar)" tee " " r(sigstar)
	scalar tstar = (tee - `N'*ttil*sn/(sige^2)*rse*r(mustar))/r(sigstar)
* 2A21: calculate as signed	
    scalar pval = norm(tstar)
    noi di in gr _n "Pooled ADF test, N,T = (`N',`T')" /*
    */ _col(35) "Obs = " e(N) _col(48) _n "Augmented by " lavg " lags (average) " /*
    */ _col(35) "Truncation: `trunc' lags"
    noi di in gr _n "coefficient"  _col(16) "t-value"  _col(31) "t-star" _col(44) "P > t"
    noi di in ye %9.5f delta _col(14) %9.3f tee _col(26) /*
	*/ %11.5f tstar _col(40) %9.4f pval
	return scalar nobs=e(N)
	return scalar N=`N'
	return scalar T=`T'
	return scalar delta=delta
	return scalar tstar=tstar
	return scalar pval=pval
	return scalar lavg=lavg
	return local trunc=`trunc'
	return local lags `lags'
	return local determ `text'
	end		

program define _getLL, rclass
	syntax , Case(string) Ttil(string)
*    args kayse ttil
    tempname ss msda 

* LL Table 2, mean and std dev adjustments (corr 2A21 for equality)
	mat `ss' = ( 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 250, 999999)
	if `case' == 1 {
    	mat `msda' = ( 0.004, 0.003, 0.002, 0.002 , 0.001, 0.001, 0.001, 0, 0, 0, 0, 0, 0\ /*
    	*/ 1.049, 1.035, 1.027, 1.021, 1.017, 1.014, 1.011, 1.008, 1.007, 1.006, 1.005, 1.001, 1.000)
    	}
    if `case' == 2 {
        mat `msda' = (-.554,-.546,-.541,-.537,-.533,-.531,-.527,-.524,-.521, -.520,-.518,-.509,-.500 \ /*
        */ .919,.889,.867,.85,.837,.826,.810,.798,.789,.782,.776,.742,.707)
        }
    if `case' == 3 {
        mat `msda' = (-.703,-.674,-.653,-.637,-.624,-.614,-.598,-.587,-.578,-.571, -.566,-.533,-.500 \ /*
        */ 1.003,.949,.906,.871,.842,.818,.780,.751,.728,.710,.695,.603,.500)
        }
    forv i=1/13 {
    	if `ttil' <= `ss'[1,`i'] {
    		return scalar mustar = `msda'[1,`i']
    		return scalar sigstar = `msda'[2,`i']
    		continue,break
    		}
    	}
	end
