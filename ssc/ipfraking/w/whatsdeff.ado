*! whatsdeff : compute 1+CV^2 approximation to the unequal weighting design effect 
*! v.0.8.1 Stas Kolenikov skolenik at gmail.com
program define whatsdeff, rclass
	version 10
	
	syntax varlist (numeric min=1 max=1) [if] [in] , [by(varlist numeric min=1 max=1)]
	
	marksample touse
	
	local wgt `varlist'
	tempvar wgt2 
	qui gen `wgt2' = `wgt'*`wgt' if `touse'
	
	* header
	di _n "{txt}    Group" _col(15) "{c |}   Min" _col(27) "{c |}   Mean" _col(39) "{c |}   Max"   _c 
	di _col(51) "{c |}    CV" _col(61) "{c |}   DEFF" _col(71) "{c |}   N" _col(79) "{c |}  N eff"
	di "{txt}{dup 14:{c -}}{c +}{dup 11:{c -}}{c +}{dup 11:{c -}}{c +}{dup 11:{c -}}{c +}{dup 9:{c -}}{c +}{dup 9:{c -}}{c +}{dup 7:{c -}}{c +}{dup 8:{c -}}"
	
	if "`by'" != "" {
		qui levelsof `by' if `touse', local( allbys )
		di "{res}`by'" _c
		if length("`by'") < 15 di _col(15)"{txt}{c |}" _c
		if length("`by'") < 27 di _col(27)"{txt}{c |}" _c
		di _col(39) "{c |}" _col(51) "{c |}" _col(61) "{c |}" _col(71) "{c |}" _col(79) "{c |}"
		foreach k of numlist `allbys' {
			PrintDEFF `wgt' `wgt2' if `touse' & `by'==`k', caption("`: lab (`by') `k''")
			return add
		}
		di "{txt}{dup 14:{c -}}{c +}{dup 11:{c -}}{c +}{dup 11:{c -}}{c +}{dup 11:{c -}}{c +}{dup 9:{c -}}{c +}{dup 9:{c -}}{c +}{dup 7:{c -}}{c +}{dup 8:{c -}}"
	}
	
	PrintDEFF `wgt' `wgt2' if `touse' , caption(Overall)
	return add
	
end

program define PrintDEFF, rclass

	syntax varlist( numeric min=2 max=2) [if] [in], caption(str)
	
	marksample touse
	
	local wgt  : word 1 of `varlist'
	local wgt2 : word 2 of `varlist'
	
	tempname sumw sumw2 N deff

	sum `wgt2' if `touse', mean
	scalar `sumw2' = r(sum)
	scalar `N' = r(N)
	
	qui sum `wgt' if `touse'
	scalar `sumw' = r(sum)
	assert scalar(`N') == r(N)
	
	scalar `deff' = scalar(`N')*scalar(`sumw2')/( scalar(`sumw')*scalar(`sumw') )
		
	di "{txt}" %13s abbrev("`caption'",13) _c
	di _col(15) "{txt}{c |}{res}" %10.2f r(min) _col(27) "{txt}{c |}{res}" %10.2f r(mean) _col(39) "{txt}{c |}{res}" %10.2f r(max) _c
	di _col(51) "{txt}{c |}{res}" %8.4f r(sd)/r(mean) _col(61) "{txt}{c |}{res}" %8.4f scalar(`deff') _c
	di _col(71) "{txt}{c |}{res}" %6.0f `N' _col(79) "{txt}{c |}{res}" %8.2f `N'/scalar(`deff')
	
	* strip eq signs from caption
	local capeq = subinstr("`caption'","==","_eq_",1)
	return scalar DEFF_`capeq' = scalar(`deff')
	return scalar Neff_`capeq' = `N'/scalar(`deff')
	return scalar MOE50 = invt(return(Neff_`capeq'),0.975)*sqrt(0.5*0.5/return(Neff_`capeq'))
	return scalar MOE10 = invt(return(Neff_`capeq'),0.975)*sqrt(0.1*0.9/return(Neff_`capeq'))
	return scalar N = `N'

end

exit

History
31-Mar-2015	v.0.7	produces DEFF by groups 
22-Nov-2016 v.0.8	more space for summaries; MOEs returned
02-Jun-2017	v.0.8.1	r(N) added
