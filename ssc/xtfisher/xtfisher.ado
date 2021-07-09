*! version 1.0.1   September 4, 2005 Scott Merryman    
*! Based on Luca Nunziata's -xtfptest- and -xtdftest- 

program xtfisher, rclass
	version 8.2
	syntax varname(ts) [if] [in], [, TRend drift Lags(int 0) Display pp]
	
	if "`drift'" != "" {
		if "`trend'" != "" {
			noi di as error "cannot specify drift if time trend is included"
			exit 198
		}
	}
	
	if "`drift'" != "" {
		if "`pp'" != "" {
			noi di as error "cannot specify drift with Phillips Perron test"
			exit 198
		}
	}
qui {
	marksample touse
	tsset 
		if "`r(panelvar)'" == "" { 
			di as err "no panel variable set, use tsset"
			exit 198 
		} 

		if "`r(timevar)'" == "" { 
			di as err "no time variable set, use tsset"
			exit 198 
		} 

	local id `r(panelvar)'
	local time `r(timevar)'

	tempvar imax imin N_g P Z L 
	tempname P
	
	
	scalar `imax'= r(imax)
	scalar `imin' = r(imin)
	levels `id' , local(levels)
	scalar `P'=0
	scalar `Z' = 0
	scalar `L' = 0
	sort `id' `time'
	local N_g = 0
}

	if "`pp'" == ""  {
	foreach l of local levels {
		capture dfuller `varlist' if `id' == `l' & `touse'  , `trend' `drift' lags(`lags') 
		if r(p) != . {	
			local N_g = `N_g' + 1
			}
		if  "`display'" != ""  & r(p) ! = . {
			disp ""
			display in gr "Cross-section unit: " `l'
			dfuller `varlist' if `id' == `l' & `touse'  , `trend' `drift' lags(`lags') 
		}
		
			
		if r(p)==0  | r(p) == . {
			scalar `P'=`P'+ 0
			scalar `Z' = `Z' + 0
			scalar `L' = `L' + 0 
		} 
		else  {
		scalar `P'=`P'+log(r(p)) 
		scalar `Z' = `Z' + invnorm(r(p))
		*scalar `L' = ln(r(p)/(1- r(p)))
		}	
		}
	
	
	scalar `P'=-2*`P'
	scalar `Z' = (1/sqrt(`N_g'))*`Z'

	return scalar n_groups = `N_g'
	*return scalar L = 1/(1 + exp(-`L'))
	*return scalar Z = `Z'
	*return scalar pval_z =  norm(`Z')

	return scalar lags = `lags'
	return scalar dftest= `P'
	return scalar pval= chiprob(2*`N_g',`P')
	}
	
	else if "`pp'" == "pp" {
	foreach l of local levels {
		capture pperron `varlist' if `id' == `l' & `touse' , `trend'  lags(`lags')
		if r(pval) != . {
			local N_g = `N_g' + 1
			}
		if  "`display'" != ""  & r(pval) != . {
			disp ""
			display in gr "Cross-section unit: " `l'
			pperron  `varlist' if `id' == `l' & `touse'  , `trend'  lags(`lags')
		}
		
		if r(pval)==0 | r(pval) == . {
			scalar `P'=`P'+ 0
			} 
		else scalar `P'=`P'+log(r(pval))
		}
		

	scalar `P'=-2*`P'
	return scalar n_groups = `N_g'
	return scalar lags = `lags'
	return scalar pptest= `P'
	return scalar pval= chiprob(2*`N_g',`P')
	return local name_test  "pperron"
	}


	di ""
	if "`pp'" == "pp" {
		display ""
		display in green "Fisher Test for panel unit root using Phillips-Perron test (`lags' lags)"
		}

	else {
		display ""
		display in green "Fisher Test for panel unit root using an augmented Dickey-Fuller test (`lags' lags)"
		}

	display""
	display in gr "Ho: unit root"
	display""
	disp _col(10) in gr "chi2(" in ye 2*`N_g' in gr ")"  _col(23) "=" in ye _col(25) %9.4f `P'
	disp _col(10) in gr "Prob > chi2  =" in ye _col(30) %6.4f chiprob(2*`N_g',`P')
	disp ""
end
