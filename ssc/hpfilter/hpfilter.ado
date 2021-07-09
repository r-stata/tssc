* Version:	1.0.0
* Version:	1.0.1 - fixed a bug
* Updated:	01.10.2017
* Author: Narek Ohanyan, Universitat Pompeu Fabra, Email: narek.ohanyan@upf.edu

* ==============================================================================

program define hpfilter, rclass

	version 12.0
	
	syntax varlist(min=1 max=1) [if] [in] , [trend(string) cycle(string)] [smooth(real 0) optimal] [onesided twosided] [forecast(int 0)]
	
	di ""

	set type double

	qui tsset
	local timevar = `"`r(timevar)'"'
	local unit = `"`r(unit)'"'
	local time_max_string = `"`r(tmaxs)'"'
	local panel = `"`r(panelvar)'"'
	
	if `"`panel'"' != `""' {
		di as err "Panel data not supported"
		exit 198
	}
	
	local y = `"`varlist'"'
	
	local nopts1 = (`"`trend'"' != "") + (`"`cycle'"' != "")
	
	if `nopts1' == 0 {
		di as err "At least one of " as result "trend()" as err " and " as result "cycle()" as err " options must be specified"
		exit 198
	}
	
	local nopts2 = (`"`onesided'"' != "") + (`"`twosided'"' != "")
	
	if `nopts2' == 0 {
		local twosided = "twosided"
	}
	if `nopts2' == 2 {
		di as err "Either " as result "onesided" as err " or " as result "twosided" as err " option must be specified"
		exit 198
	}

	local nopts3 = (`smooth' != 0) + (`"`optimal'"' != "")
	
	if `nopts3' == 2 {
		di as err "Either " as result "smooth()" as err " or " as result "optimal" as err " option must be specified"
		exit 198
	}

	if `smooth' < 0 {
		di as result "smooth()" as err " must be positive"
		exit 198
	}
	
	confirm new variable `trend' `cycle'
	
	if `"`optimal'"' == `""' {
		if `smooth' == 0 {
			local mode = 0	// default
			local smooth = 1600
			if `"`unit'"' == "daily" {
				local smooth = 1600*(365/4)^4
			}
			if `"`unit'"' == "weekly" {
				local smooth = 1600*(12)^4
			}
			if `"`unit'"' == "monthly" {
				local smooth = 1600*(3)^4
			}
			if `"`unit'"' == "quarterly" {
				local smooth = 1600
			}
			if `"`unit'"' == "halfyearly" {
				local smooth = 1600*(1/2)^4
			}
			if `"`unit'"' == "yearly" {
				local smooth = 1600*(1/4)^4
			}
		}
		if `smooth' != 0 {
			local mode = 1	// user-specified smoothing parameter
		}
	}
	if `"`optimal'"' != `""' {
			local mode = 2	// optimal smoothing parameter
	}

	* =========================== Define constraints ===========================
	
	constraint drop _all
	* State transition matrix
	constraint define 1 [x1]l.x1 = 2
	constraint define 2 [x1]l.x2 = -1
	constraint define 3 [x2]l.x1 = 1
	constraint define 4 [x2]l.x2 = 0

	* Observation matrix
	constraint define 5 [`y']x1 = 1
	constraint define 6 [`y']x3 = 1
	
	if `mode' != 2 {
		* Restriction on noise/signal ratio for lambda = sqrt(smooth)
		local noise_to_signal = sqrt(`smooth')
		constraint define 7 [`y']e.`y' = `noise_to_signal'*[x1]e.x1
		constraint define 8 [x3]e.x3 = `noise_to_signal'*[x1]e.x1
	}

	* ============================= Run the model ==============================

	if `mode' == 2 {
		di as text "Finding the optimal smoothing parameter"
	}

	qui sspace (x1 l.x1 l.x2 e.x1, state noconstant) (x2 l.x1 l.x2, state noconstant) (`y' x1 e.`y', noconstant) `if' `in', constraints(1/8)
	local sample_max_string = `"`e(tmaxs)'"'
	local smooth = abs(([`y']e.`y')^2/([x1]e.x1)^2)

	di as text "Setting smoothing parameter = " `smooth'

	* ============================== Predictions ===============================
	
	di ""
	di as text "Extracting the trend and the cycle"
	di ""
	
	tempvar tr cy
	
	if `"`onesided'"' != `""' {
		predict `tr' `if' `in', smethod(filter) equation(x1) states
		qui gen `cy' = `y' - `tr' `if' `in'
		if `"`trend'"' != `""' {
			qui gen `trend' = `tr' `if' `in'
			label var `trend' "Trend of `varlist' (one-sided)"
		}
		if `"`cycle'"' != `""' {
			qui gen `cycle' = `cy' `if' `in'
			label var `cycle' "Cycle of `varlist' (one-sided)"
		}
	}

	if `"`twosided'"' != `""' {
		predict `tr' `if' `in', smethod(smooth) equation(x1) states
		qui gen `cy' = `y' - `tr' `if' `in'
		if `"`trend'"' != `""' {
			qui gen `trend' = `tr' `if' `in'
			label var `trend' "Trend of `varlist' (two-sided)"
		}
		if `"`cycle'"' != `""' {
			qui gen `cycle' = `cy' `if' `in'
			label var `cycle' "Cycle of `varlist' (two-sided)"
		}
	}
	
	if `"`trend'"' != `""' {
		if `"`forecast'"' != `"0"' {
			tempvar time time_string time_string_sample_max time_string_time_max
			qui tostring `timevar', gen(`time_string') force usedisplayformat
			qui gen `time' = _n
			qui gen `time_string_sample_max' = `time' if `time_string' == `"`sample_max_string'"'
			qui sum `time_string_sample_max'
			local sample_max = `r(max)'
			qui gen `time_string_time_max' = `time' if `time_string' == `"`time_max_string'"'
			qui sum `time_string_time_max'
			local time_max = `r(max)'
			local forecast_begin = `sample_max' + 1
			local forecast_end = `forecast_begin' + `forecast' -1
			if `time_max' < `forecast_end' {
				local addtime = `forecast_end' - `time_max'
				tsappend, add(`addtime')
				qui replace `time' = _n
			}
			qui replace `trend' = L.`trend' + L.D.`trend' if `time' >= `forecast_begin' & `time' <= `forecast_end'
		}
	}
	
	di as text "Done"

	* ================================= Return =================================
	
	return scalar smooth = `smooth'
	return local varname = `"`varlist'"'
	return local trendname = `"`trend'"'
	return local cyclename = `"`cycle'"'
	if `"`onesided'"' != `""' {
		return local method = `"Hodrick-Prescott (one-sided)"'	
	}
	if `"`twosided'"' != `""' {
		return local method = `"Hodrick-Prescott (two-sided)"'
	}
	return local unit = `"`unit'"'

end
