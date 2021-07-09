*! version 1.5.0 18Aug2011 MLB
program define hangr_theoretical, rclass
	syntax varname [if] [fweight],  ///
	groupvar(varname)               ///
	theor(string)                   ///
	theorgr(string)                 ///
	h(string)                       ///
	x(string)                       /// 
	x2(string)                      ///
	[                               /// 
	SUSPended                       ///
	BIN(passthru)                   /// number of bins
	Width(passthru)                 /// width of bins
	START(passthru)                 /// first bin position
	Discrete                        ///
	nobs(string)                    /// ignored
	nbins(string)                   /// ignored
	min(string)                     /// ignored
	max(string)                     /// ignored
	XXfit(integer 0)                /// ignored
	withx(integer 0)                /// ignored
	xwx(varname)                    /// ignored
	grden(string)                   /// ignored
	]

	if "`suspended'" != "" local minus "-"
	if "`weight'" != "" local wght "[`weight'`exp']"
	marksample touse
	
	sum `varlist' `wght' if `groupvar' & `touse', meanonly
	local nobstheor = r(sum_w)
	local mintheor = r(min)
	local maxtheor = r(max)
	sum `varlist' `wght' if !`groupvar' & `touse', meanonly
	local nobsemp = r(sum_w)
	local minemp = r(min)
	local maxemp = r(max)
		
	local max     = max(`maxtheor', `maxemp')
	local min     = min(`mintheor', `minemp')
	local nobsmin = min(`nobstheor', `nobsemp')
	if "`discrete'" != "" {
		di as err "option discrete not allowed with the empricial distribution"
		exit 198
	}
	if "`bin'`width'" == "" {
		local bin =  ceil(min(sqrt(`nobsmin'), 10*ln(`nobsmin')/ln(10)))
		local bin "bin(`bin')"
	}
	if "`start'" == "" {
			local start "start(`min')"
	}
		
	hangr_histgen `varlist' if `touse' & `groupvar' `wght', ///
	gen(`theor' `x') `bin' `width' `start' `discrete' tmax(`max')
	qui drop `x'
		
	// !`groupvar' does not include missing values in `groupvar' as these have
	// been filtered out in `touse'
	hangr_histgen `varlist' if `touse' & !`groupvar' `wght', ///
	gen(`h' `x') display `bin' `width' `start' `discrete' tmax(`max')
	local w     = r(width)
	local min   = r(min)
	local max   = r(max)
	local nobs  = r(N)
	local nbins = r(bin)
		
	qui replace `theor' = sqrt(`theor'*`nobs'*`w')
	qui gen `theorgr' = `minus'`theor'

	qui gen `x2' = `x' - .5*`w'
	qui replace `x2' = `x2'[_n-1] + `w' in `=`nbins'+1'
	qui replace `x2' = `x2'[_n-1] in `=`nbins'+2'
	qui replace `x2' = `x2'[1] in `=`nbins'+3'
	sort `x2' `theorgr'
	qui replace `theorgr' = `theorgr'[1] in 2
	qui replace `theorgr' = 0 in 1
	qui replace `theorgr' = `theorgr'[`=`nbins'+1'] in `=`nbins'+2'
	qui replace `theorgr' = 0 in `=`nbins'+3'
		
	return local gr "line `theorgr' `x2', connect(J)"
	return scalar width = `w'
	return scalar min   = `min'
	return scalar max   = `max'
	return scalar N     = `nobs'
	return scalar bin   = `nbins'
end

