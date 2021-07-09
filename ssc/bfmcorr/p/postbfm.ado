*! bfmsvycorr v0.0.0.9000 Thomas Blanchet, Ignacio Flores, Marc Morgan

program postbfm
	version 11
	syntax name [, Country(string) Year(string) EXport(string) NOBIGtheta NOSMalltheta NOANTItheta NOMAtheta NOEXtratheta WINdow(real 4) replace] 
	
	if ("`replace'" == "")	{
		preserve
	}	
		
	local income = "`e(income_var)'"

	// ---------------------------------------------------------------------- //
	// Bias plot 
	// ---------------------------------------------------------------------- //
	
	if ("`namelist'" == "biasplot") {
		quietly clear
		local mergingpoint = e(mergingpoint)
		tempname theta
		matrix define `theta' = e(theta)
		tempvar v
		quietly svmat `theta', names(`v'_)
		sort `v'_1
				
		// Create the percentile scale with zoom at the top
		tempvar p
		quietly generate `p' = `v'_1
		quietly replace `p' = 100*`p' if inrange(`v'_1, 0, 0.99)
		quietly replace `p' = 100 + 1000*(`p' - 0.99) if inrange(`v'_1, 0.99, 0.999)
		quietly replace `p' = 109 + 10000*(`p' - 0.999) if inrange(`v'_1, 0.999, 0.9999)
		quietly replace `p' = 118 + 100000*(`p' - 0.9999) if inrange(`v'_1, 0.9999, 1)
		
		// Use the same scale for the merging point
		if inrange(`mergingpoint', 0, 0.99) {
			local mergingpoint = 100*`mergingpoint'
		}
		else if inrange(`mergingpoint', 0.99, 0.999) {
			local mergingpoint = 99 + 1000*(`mergingpoint' - 0.99)
		}
		else if inrange(`mergingpoint', 0.999, 0.9999) {
			local mergingpoint = 108 + 10000*(`mergingpoint' - 0.999)
		}
		else if inrange(`mergingpoint', 0.9999, 1) {
			local mergingpoint = 117 + 100000*(`mergingpoint' - 0.9999)
		}
		// Truncate 
		quietly drop if (`v'_3 > 3 |`v'_4 > 3)
		quietly summarize `v'_3, meanonly
		local maxtheta = max(ceil(r(max)), 3)
		
		// Remove estimations of theta in case of extrapolation
		quietly replace `v'_4 = . if `v'_5
		tempvar thetaextra
		quietly generate `thetaextra' = `v'_3 if `v'_5[_n-1] | `v'_5
		quietly replace `v'_3 = . if `v'_5==1
		local legendno = 1
		if ("`nosmalltheta'" == "") {
			local plot_smalltheta (scatter `v'_3 `p', msize(vsmall) mcolor(gs12))
			local legend `legend' label(`legendno' "{&theta}(y)")	
			local legendno = `legendno' + 1
		}
		if ("`noantitheta'" == "") {
			local plot_antitheta (line `v'_4 `p', lpattern(l) color("55 126 184" /*"152 78 163"*/))
			local legend `legend' label(`legendno' "{&theta}(y) (antitonic)")
			local legendno = `legendno' + 1
		}
		if ("`nobigtheta'" == "") {
			local plot_bigtheta (line `v'_2 `p', lpattern(l) color("228 26 28"))
			local legend `legend' label(`legendno' "{&Theta}(y)")
			local legendno = `legendno' + 1
		}
		if ("`nomatheta'" == "") {
			// Get central tendency by moving average
			tempvar thetacentral
			local ma `v'_3
			forvalue i = 1/`window' {
				tempvar thetacentral_l`i' thetacentral_f`i'
				quietly generate `thetacentral_l`i'' = `v'_3[_n - `i']
				quietly generate `thetacentral_f`i'' = `v'_3[_n + `i']
				local ma `ma' `thetacentral_l`i'' `thetacentral_f`i''
			}
			quietly egen `thetacentral' = rowmean(`ma')
			
			// Remove estimations of theta in case of extrapolation
			quietly replace `thetacentral' = . if `v'_5
			
			local plot_matheta (line `thetacentral' `p', lpattern(solid) color(/*black*/ "77 175 74"))
			local legend `legend' label(`legendno' "{&theta}(y) (moving avg.)")
			local legendno = `legendno' + 1
		}
		if ("`noextratheta'" == "") {
			quietly count if `v'_5
			if (r(N) > 0) {
				local sigma = e(var_res)
				tempname b
				matrix define `b' = e(beta_ridge)
				quietly replace `thetaextra' = exp(`b'[1, 1] + `b'[2, 1]*log(`v'_6) + `sigma'/2)
			
				local plot_thetaextra (line `thetaextra' `p', lpattern(shortdash) color("55 126 184"))
				local legend `legend' label(`legendno' "{&theta}(y) (extrapolation)")
			}
		}
		
		local nrows = cond(`legendno' <= 3, 1, 2)
		graph twoway ///
			`plot_smalltheta' ///
			`plot_antitheta' ///
			`plot_bigtheta' ///
			`plot_matheta' ///
			`plot_thetaextra', ///
			xline(`mergingpoint', lcolor(gs10)) ///
			text(`maxtheta' `mergingpoint' "merging point", orientation(vertical) placement(se) color(gs10)) ///
			ylabel(0(1)`maxtheta', labsize(small)) ///
			xlabel(1"P0" 11"P10" 21"P20" 31"P30" 41"P40" 51"P50" 61"P60" 71"P70" ///
				81"P80" 91"P90" 100 "P99" 109 "P99.9" 118 "P99.99" 127 "P99.999", ///
				grid labels labsize(small) angle(forty_five)) ///
			/// title("Finding the merging point") ///
			/// subtitle("using the shape of the bias") ///
				legend(rows(/*`nrows'*/2) `legend') ///
			xtitle("") ytitle("") ///
			graphregion(color(white)) /*(legend(off)*/ scale(1.3) 
	}

	// ---------------------------------------------------------------------- //
	// Lorenz curves
	// ---------------------------------------------------------------------- //	
	
	else if ("`namelist'" == "lorenz") {
		
		tempvar freq F fy cumfy L bckt_size	ftile
		
		// Generate Quantile function
		sort `income'
		quietly sum	_weight, meanonly
		local poptot = r(sum)
		quietly	gen	`freq' = _weight/`poptot'
		quietly	gen `F' = sum(`freq')
		
		// Generate L
		quietly	gen `fy' = `freq'*`income'
		quietly	gen `cumfy' = sum(`fy')
		quietly sum `cumfy', meanonly
		local cumfy_max = r(max)
		quietly	gen `L' = `cumfy'/`cumfy_max'
		
		// Identify ftiles and collapse
		quietly egen `ftile' = cut(`F'), at(0(0.01)0.99 0.991(0.001)0.999 0.9991(0.0001)0.9999 0.99991(0.00001)0.99999 1) 	
		collapse (min) `L', by(`ftile')
		
		// Generate 127 percentiles from scratch
		tempfile collapsed_L
		quietly save "`collapsed_L'"
		clear
		quietly set obs 127
		quietly gen `ftile' = (_n - 1)/100 in 1/100
		quietly replace `ftile' = (99 + (_n - 100)/10)/100 in 101/109
		quietly replace `ftile' = (99.9 + (_n - 109)/100)/100 in 110/118
		quietly replace `ftile' = (99.99 + (_n - 118)/1000)/100 in 119/127
		quietly merge n:1 `ftile' using "`collapsed_L'"
		
		// Interpolate missing data
		tempvar ipo_L
		quietly ipolate `L' `ftile', gen(`ipo_L')
		drop `L'
		rename `ipo_L' `L'
		summarize `L', meanonly
		quietly replace `L' = r(max) if missing(`L')
		
		quietly generate `F' = `ftile'
		label var `L' "After Correction"
		label var `F' "Equality line"
		
		// Bring old data
		matrix define mat_lorenz_old = e(mat_lorenz_old)
		quietly gen ftile_old = mat_lorenz_old[_n, 1]
		quietly gen L_old = mat_lorenz_old[_n, 2]
		label var L_old "Before Correction"
		
		// Complete Lorenz curve at last point
		quietly set obs 128
		quietly replace L_old = 1 in 128
		quietly replace `L' = 1 in 128
		quietly replace `F' = 1 in 128
					
		twoway ///
			(line L_old ftile_old, lwidth(thin) lpattern(dash) lcolor(black) xaxis(1 2) yaxis(1 2)) ///
			(line `L' `F', lwidth(thin) lcolor(black)) ///
			(line `F' `F', lwidth(thin) lcolor(gs10)), ///
			xlabel(0 "0" 0.25 "25%" 0.5 "50%" 0.75 "75%" 1 "100%", grid axis(1)) ///
			ylabel(0 "0" 0.25 "25%" 0.5 "50%" 0.75 "75%" 1 "100%", grid axis(1)) ///
			xlabel(, axis(2) noticks nolabel) ylabel(, axis(2) noticks nolabel) ///
			/// title("Adjusted vs. Raw Lorenz curves. `country' `year'", size(medium) color(black)) ///
			ytitle("Cumulative income share") xtitle("Cumulative frequency") ///
			graphregion(color(white)) /*legend(off)*/ scale(1.3)
	}
				
	// ---------------------------------------------------------------------- //
	// Summary 
	// ---------------------------------------------------------------------- //
	else if ("`namelist'" == "summarize") {
		tempvar ftile freq F fy cumfy L d_eq bckt_size cum_weight wy
		
		// Total average
		quietly sum `income' [w=_weight]
		local rew_avg = r(mean)	
		
		// Estimate Gini and keep in memory
		quietly sum	_weight, meanonly
		local poptot = r(sum)
		sort `income'
		
		// Unobserved population
		local y_max_old=e(y_max_old)
		quietly sum _weight if `income'>`y_max_old'
		local unobs_pop=r(sum)/`poptot'
		
		quietly	gen `freq' = _weight/`poptot'
		quietly	gen `F' = sum(`freq'[_n - 1])	
		quietly	gen `fy'= `freq'*`income'
		quietly	gen `cumfy' = sum(`fy')
		
		quietly sum `cumfy', meanonly
		local cumfy_max = r(max)
		quietly	gen `L'= `cumfy'/`cumfy_max'
		quietly gen `d_eq' = (`F' - `L')*_weight/`poptot'
		quietly sum	`d_eq', meanonly
		local d_eq_tot = r(sum)
		local gini = `d_eq_tot'*2
		
		
		// Classify obs in 127 g-percentiles
		quietly egen `ftile' = cut(`F'), at(0(0.01)0.99 0.991(0.001)0.999 0.9991(0.0001)0.9999 0.99991(0.00001)0.99999 1)
					
		// Top average 
		gsort -`F'
		quietly gen `wy' = `income'*_weight
		quietly gen topavg = sum(`wy')/sum(_weight)
		sort `F'
		
		// Interval thresholds
		quietly collapse (min) thr = `income' (mean) bckt_avg = `income' (min) topavg [w=_weight], by (`ftile')
		sort `ftile'
		quietly gen ftile = `ftile'
		
		// Generate 127 percentiles from scratch
		tempfile collapsed_sum
		quietly save "`collapsed_sum'"
		clear
		quietly set obs 127
		quietly gen ftile = (_n - 1)/100 in 1/100
		quietly replace ftile = (99 + (_n - 100)/10)/100 in 101/109
		quietly replace ftile = (99.9 + (_n - 109)/100)/100 in 110/118
		quietly replace ftile = (99.99 + (_n - 118)/1000)/100 in 119/127
		quietly merge n:1 ftile using "`collapsed_sum'"
		
		// Interpolate missing info
		quietly ipolate bckt_avg ftile, gen(bckt_avg2)      
		quietly ipolate thr ftile, gen(thr2)
		quietly ipolate topavg ftile, gen(topavg2)
		
		// Fill last cases if blank
		sort ftile
		drop bckt_avg thr topavg
		quietly rename bckt_avg2 bckt_avg
		quietly rename thr2 thr
		quietly rename topavg2 topavg
		quietly sum bckt_avg, meanonly
		quietly replace bckt_avg = r(max) if missing(bckt_avg)
		quietly sum thr, meanonly
		quietly replace thr = r(max) if missing(thr) 
		quietly sum topavg, meanonly
		quietly replace topavg = r(max) if missing(topavg)		
		
		// Top shares  
		quietly replace ftile = round(ftile, 0.00001)
		quietly gen topshare = (topavg/`rew_avg')*(1 - ftile)  	
		
		// Total average  
		quietly gen average = .
		quietly replace average = `rew_avg' in 1		
		
		// Inverted beta coefficient
		quietly gen b = topavg/thr		
		
		// Fractile
		quietly rename ftile p
		
		// Year
		quietly gen year = .
		if ("`year'" != "")	{		
			quietly replace year = `year' in 1
		}
		// Write Gini
		quietly gen gini = `gini' in 1
		
		// Order and save	
		order year gini average p thr bckt_avg topavg topshare b
		keep year gini average p thr bckt_avg topavg topshare b	
		tempname mat_sum
		mkmat gini average p thr bckt_avg topavg topshare b, matrix(`mat_sum')
		mkmat gini average p thr bckt_avg topavg topshare b, matrix(_mat_sum)
		
		// Structure of missing population
		local mergingpoint =e(mergingpoint)
		local above_MP_svy=e(above_MP_svy)
		local above_MP_tax=e(above_MP_tax)
		local corrected_pop=e(corrected_pop)
		local unobs_sh=e(unobs_sh)
		local other_sh=e(other_sh)
		local underestimated=`above_MP_tax'-`above_MP_svy'
	
		// Display structure of adjusted population
		display as text "{hline 75}"
		display as text "The structure of the corrected population"
		display as text "{hline 75}"
		display as text "(1)         Population above Merging Point in Tax data:              "%5.2f 100*`above_MP_tax'   "%"
		display as text "(2)         Population above Merging Point in Survey data:           "%5.2f 100*`above_MP_svy'   "%"
		display as text "(3)         Population above Survey's max. income in Tax data:       "%5.2f 100*`unobs_pop'      "%"
		display as text "(4)=(1)-(2) Share of total population that is corrected:             "%5.2f 100*`underestimated' "%"
		display as text "(5)=(3)/(4)          incl. Share outside survey's scope:             "%5.2f 100*`unobs_sh'       "%"
		display as text "(6)=1-(5)             incl. Share inside survey's scope:             "%5.2f 100*`other_sh'       "%"
		display as text "{hline 75}"
		
		
		// Bring data from initial survey
		tempname mat_sum_old
		matrix define `mat_sum_old' = e(mat_sum_old)
		quietly gen gini_old     = `mat_sum_old'[_n, 1] in 1
		quietly gen average_old  = `mat_sum_old'[_n, 2]
		quietly gen p_old        = `mat_sum_old'[_n, 3]
		quietly gen thr_old      = `mat_sum_old'[_n, 4]
		quietly gen bckt_avg_old = `mat_sum_old'[_n, 5]
		quietly gen topavg_old   = `mat_sum_old'[_n, 6]
		quietly gen topshare_old = `mat_sum_old'[_n, 7]
		quietly gen b_old        = `mat_sum_old'[_n, 8]
		
		// Display some results
		display as text ""
		display as text "Summary statistics"
		display as text "{hline 21}{c TT}{hline 41}"
		display as text "           Statistic {c |}          Unadjusted             Adjusted"
		display as text "{hline 21}{c +}{hline 41}"
		display as text "             average {c |}" %20.5gc `mat_sum_old'[1, 2] " " %20.5gc `mat_sum'[1, 2]
		display as text "              median {c |}" %20.5gc `mat_sum_old'[51, 4] " " %20.5gc `mat_sum'[51, 4]
		display as text "                     {c |}"
		display as text "                Gini {c |}" %20.3g `mat_sum_old'[1, 1] " " %20.3g `mat_sum'[1, 1]
		display as text "                     {c |}"
		display as text "    bottom 50% share {c |}" %19.3g 100*(1 - `mat_sum_old'[51, 7]) "% " %19.3g 100*(1 - `mat_sum'[51, 7]) "%"
		display as text "    middle 40% share {c |}" %19.3g 100*(`mat_sum_old'[51, 7] - `mat_sum_old'[91, 7]) ///
			"% " %19.3g 100*(`mat_sum'[51, 7] - `mat_sum'[91, 7]) "%"
		display as text "       top 10% share {c |}" %19.3g 100*`mat_sum_old'[91, 7] "% " %19.3g 100*`mat_sum'[91, 7] "%"
		display as text "        top 1% share {c |}" %19.3g 100*`mat_sum_old'[100, 7] "% " %19.3g 100*`mat_sum'[100, 7] "%"
		display as text "      top 0.1% share {c |}" %19.3g 100*`mat_sum_old'[109, 7] "% " %19.3g 100*`mat_sum'[109, 7] "%"
		display as text "{hline 21}{c BT}{hline 41}"
		
		display as text ""
		display as text "Detailed distributions"
		display as text "{hline 111}"
		display as text "                         Threshold                       Top average                      Top share"
		display as text "              {hline 30}   {hline 30}   {hline 30}"
		display as text "                    Unadj.         Adj.              Unadj.         Adj.              Unadj.         Adj."
		display as text "{hline 111}"
		
		forvalues i = 1/127 {
			display as text "p" %-13.5g 100*`mat_sum'[`i', 3] " " ///
				%13.4gc `mat_sum_old'[`i', 4] "  " %13.4gc `mat_sum'[`i', 4] "     " ///
				%13.4gc `mat_sum_old'[`i', 6] "  " %13.4gc `mat_sum'[`i', 6] "     " ///
				%12.3gc 100*`mat_sum_old'[`i', 7] "%  " %12.3gc 100*`mat_sum'[`i', 7] "%"
		}
		display as text "{hline 111}"
		
		// Export to Excel
		if ("`export'" != "") {
			export excel using "`export'", firstrow(variables) sheet("sum`year'") sheetreplace
		}
	}
	else if ("`namelist'" == "factors") {
		tempname adjfactors
		matrix define `adjfactors' = e(adj_factors)
		
		display as text ""
		display as text "Calibration factors"
		display as text "{hline 15}{c TT}{hline 55}"
		display as text "      Variable {c |}      Coef.       Mean       Min.     Median       Max."
		display as text "{hline 15}{c +}{hline 55}"
		
		local nvars = rowsof(`adjfactors') - 1
		local vars: roweq `adjfactors'
		local vals: rownames `adjfactors'
		forvalues j = 1/`nvars' {
			local var: word `j' of `vars'
			local val: word `j' of `vals'
			if ("`var'" != "`oldvar'") {
				if (`j' > 1) {
					display as text "               {c |}"
				}
				display as text %14s abbrev("`var'", 14) " {c |}"
			}
			display as text _column(4) %10.5gc `val' "  {c |}", _continue
			display as text " " as res ///
				%9.0g `adjfactors'[`j', 1] "  " ///
				%9.0g `adjfactors'[`j', 2] "  " ///
				%9.0g `adjfactors'[`j', 3] "  " ///
				%9.0g `adjfactors'[`j', 4] "  " ///
				%9.0g `adjfactors'[`j', 5]
			local oldvar `var'
		}
		display as text "               {c |}"
		display as text "         _cons {c |}", _continue
		display as text " " as res ///
			%9.0g `adjfactors'[`nvars' + 1, 1] "  " ///
			%9.0g `adjfactors'[`nvars' + 1, 2] "  " ///
			%9.0g `adjfactors'[`nvars' + 1, 3] "  " ///
			%9.0g `adjfactors'[`nvars' + 1, 4] "  " ///
			%9.0g `adjfactors'[`nvars' + 1, 5]
		display as text "{hline 15}{c BT}{hline 55}"
	}

	else {
		display as error "`namelist' is not a valid subcommand"
		exit 198
	}		
	

	end
