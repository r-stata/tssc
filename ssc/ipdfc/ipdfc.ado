*! version 1.2.2 Yinghui Wei, Patrick Royston. 20 August 2020.
program define ipdfc, sortpreserve
/*
	Reconstruct IPD survival data from published KM survival or failure curve.
	Based on Guyot, Ades, Ouvwens and Welton (2012) BMC Methodology, 12:9.
	Translation to do-file by YW of their R program. Do-file converted to ado-file by PR.
*/
version 12.1
// varlist consists of surv, tstart, nrisk, trisk in that order
syntax, surv(varname) TStart(varname) TRisk(varname) NRisk(varname) GENerate(string) SAVing(string) ///
 [ PROBability FAILure ISOtonic TOTevents(string)]
 
if wordcount("`generate'") != 2 {
	di as err "generate() must provide names for two new variables"
	exit 198
}

if "`totevents'" != "" confirm integer number `totevents'

_prefix_saving `saving'
local saving `"`s(filename)'"'
local replace `"`s(replace)'"'
if "`replace'" == "" {
	confirm new file `"`saving'"'
}

/*
	`generate' will create 2 variables known locally as `t_ipd' and `event_ipd' and save them to file `saving'
*/
local t_ipd : word 1 of `generate'
local event_ipd : word 2 of `generate'
confirm new var `t_ipd'
confirm new var `event_ipd'
confirm numeric variable `nrisk'
confirm numeric variable `trisk'
tempvar s n_censor n_hat cen d KM_hat last_i cen_t
qui drop if `surv'==. & `tstart'==. & `trisk' ==. & `nrisk'==. 

quietly {
	// initialize vectors
	count if !missing(`nrisk')
	local n_int = r(N)
/*
	Check that nrisk and trisk have consecutively
	non-missing values in obs 1, 2, ..., `n_int'
	and that the values in trisk are strictly increasing
	and that the values in nrisk are strictly non-increasing.
*/
	forvalues i = 1/`n_int' {
		if missing(`trisk'[`i']) {
			di as err "`trisk' is missing for interval `i'"
			di as err "times at risk must be consecutively non-missing"
			error 198
		}
		if missing(`nrisk'[`i']) {
			di as err "`nrisk' is missing for interval `i'"
			di as err "numbers at risk must be consecutively non-missing"
			exit 198
		}
		local im1 = `i' - 1
		if `i' > 1 {
			if `trisk'[`i'] <= `trisk'[`im1'] {
				di as err "times at risk must be in increasing order, number of participant at risk should be specified only once for each time point"
				di as err "times for intervals `im1' and `i' are " `trisk'[`im1'] " and " `trisk'[`i']
				error 198
			}
			if `nrisk'[`i'] > `nrisk'[`im1'] {
				di as err "numbers at risk must be in non-increasing order"
				di as err "numbers for intervals `im1' and `i' are " `nrisk'[`im1'] " and " `nrisk'[`i']
				exit 198
			}
		}
		else {
			if `trisk'[1] != 0 {
				di as err "the first time at risk must be 0"
				exit 198
			}
		}
	}
	foreach thing in lower upper {
		tempvar `thing'
		gen long ``thing'' = 0 in 1/`n_int'
		local n_`thing' 0
	}
	replace `upper' = _N in `n_int'
	forvalues i = 1/`n_int' {
		if `i'!=1 {
			count if `tstart' < `trisk'[`i']
			replace `lower' = r(N) +1 in `i'
		}
		if `i'==1 {
			replace `lower' =1 in `i'
		}
		if (`i'!=`n_int'){
			local pos = `i'+1
			count if `tstart' < `trisk'[`pos']
			replace `upper' = r(N) in `i'
		}
		else{
			replace `upper' = _N in `n_int'
		}
	}
	count if !missing(`lower') in 1/`n_int'
	local n_lower = r(N)

	if `tstart'[_N] <  `trisk'[`n_int'] {
		local tlast = `trisk'[`n_int']
		di as err "Please add data points in surv(), tstart(), trisk(), nrisk() at time `tlast'"
		exit 198
	}
// !! Better to work with missing values in `s' via marksample etc.
	gen `s' = `surv'
	if ("`probability'" == "") replace `s' = `s' / 100	// convert data from percents
	if ("`failure'" == "failure") replace `s' = 1 - `s'	// convert failure to survival prob
	replace `s' = 1 if `s'>1 & `s'!=.
	count if !missing(`s')
	local len2 = r(N)
	sort `tstart'
	if "`isotonic'" == "isotonic" {
		tempvar iso
		irax `s' `tstart', generate(`iso') reverse nograph
		//noi di "[isotonic regression performed to ensure survival probabilities are monotonic]"
		replace `s' = `iso'
		drop `iso' `iso'_p
	}
	else {
		// Simple way to make survival probabilities monotone decreasing	
		forvalues i = 2/`len2'{
			local pos = `i'-1
			local temp = `s'[`pos']
			if `s'[`i'] > `temp' {
				qui replace `s' = `temp' in `i'
				//noi di "Warning: survival probabilities must be monotone decreasing! Adjusted."
			}
		}
	}

	count if !missing(`lower')
	local n_int = r(N)
	local n_t = `upper'[`n_int']
	local len = `nrisk'[1]
    	if `len' > _N {
		tempvar to_drop
		gen byte `to_drop' = 0
		set obs `len'
		replace `to_drop' = 1 if missing(`to_drop')
	}
	else {
	      local tot_n_obs = _N+1
	      set obs `tot_n_obs'
	}
	local len2 `n_t' // `len2' = number of extracted data points
	gen long `n_censor' = 0 in 1/`len2'
	gen long `n_hat' = 0 in 1/`len2'
	gen long `cen' = 0 in 1/`len2'
	gen int `d' = 0 in 1/`len2'
	gen `KM_hat' = 1 in 1/`len2'
	gen `last_i' = 1 in 1/`len2'
	local sumdL 0
	if `n_int' > 1 {
		local n_intervals = `n_int'-1
		forvalues i = 1/`n_intervals' {
/*
	Adjust tot. no. censored until n.hat = n.risk at start of interval (i+1) 
	First approximation of no. censored on interval i
*/
           local temp2 = `nrisk'[`i']
		 //  di as error "Checking number at risk at `i' interval: `temp2'"
			local temp = `nrisk'[`i']*`s'[`lower'[`i'+1]]/`s'[`lower'[`i']]-`nrisk'[`i'+1]
			replace `n_censor' = round(`temp') in `i'
			if `n_censor'[`i']<0  replace `n_censor' = 0 in `i'
			while (`n_hat'[`lower'[`i'+1]] > `nrisk'[`i'+1]) | ///
			 ((`n_hat'[`lower'[`i'+1]] < `nrisk'[`i'+1]) & (`n_censor'[`i']>=0)) {
				if `n_censor'[`i'] <= 0 {
					local start = `lower'[`i']
					local end = `upper'[`i']
					replace `cen' = 0 in `start'/`end'
					replace `n_censor' = 0 in `i'
				}
				if `n_censor'[`i'] > 0 & !missing(`n_censor'[`i']) {
					local len = `n_censor'[`i']	/*need "=" to specify the local variable correctly*/
					di `len'
					gen `cen_t' = 0 in 1/`len'	
					// distribute censored observations evenly over time
					forvalues j = 1/`len' {
						local temp =`tstart'[`lower'[`i']] + `j'*(`tstart'[`lower'[`i'+1]]-`tstart'[`lower'[`i']])/(`n_censor'[`i']+1)
						replace `cen_t' = `temp' in `j'
					}
					// Find no. censored on each time interval
					local start = `lower'[`i']
					local end = `upper'[`i']
					// one-step in R using hist(,plot=F)$count. not sure in stata
					forvalues k = `start'/`end' {
						qui count if `cen_t' >= `tstart'[`k'] & `cen_t' < `tstart'[`k'+1]
						replace `cen' = r(N) in `k' 		 
						// di `k' _column(5) `cen'[`k']
		 			}
		 			capture drop `cen_t'
					
				}
				// Find no. events and no. at risk on each interval to agree with KM estimates read from curves	
				local pos = `lower'[`i']
				
				replace `n_hat' = `nrisk'[`i'] in `pos'
				// gen `last' = `last_i'[`i'] !! Surely last does not need to be a variable, a local will do.
				local last = `last_i'[`i']
				local start = `lower'[`i']
				local end = `upper'[`i']
				forvalues k = `start'/`end' {
					if `i'==1 & `k'==`start' {
						replace `d' = 0 in `k'
						replace `KM_hat' = 1 in `k'
					}
					else {
						replace `d' = round(`n_hat'[`k']*(1-(`s'[`k']/`KM_hat'[`last']))) in `k'
						replace `KM_hat' = `KM_hat'[`last']*(1-(`d'[`k']/`n_hat'[`k'])) in `k'
					}
					local index = `k' + 1
				       replace `n_hat' = `n_hat'[`k']-`d'[`k']-`cen'[`k'] in `index'
					if `d'[`k'] > 0 { 
						local last `k'
					}
					if `d'[`k'] <0 {
						di as error "number of events is " `d'[`k'] " in interval `i'. It can't be less than zero!"
					}
				}
				local pos = `lower'[`i'+1]
				replace `n_censor' = `n_censor'[`i'] +(`n_hat'[`pos'] - `nrisk'[`i'+1]) in `i'
			}
			local pos = `lower'[`i'+1]
			if `n_hat'[`pos']< `nrisk'[`i'+1] { 
				 local index = `i' + 1
				//di as text "`nrisk' was " `nrisk'[`index']
				replace `nrisk' = `n_hat'[`pos'] in `index'
				//di as text "and now " `n_hat'[`pos']
			}
			local index = `i' + 1
			replace `last_i' = `last' in `index'
			di `last_i'[`index']
		}
	}
/*
	Time interval `n_int'. (last interval of risk table. Step 6 in Guyot et al 2012).

	YW note 03/June/2013. Guyot et al's method consider the case when the
	number at risk is not reported in the last interval. I modified it here
	such that if the total number at risk is not reported at the last
	interval, we do what they do. However, if the total number at risk is
	reported at the last interval, the computations are carried out using
	the same method as that for the other intervals and these are done in the
	previous loop. An option -fullrisktable- was given to note if the
	number at risk at the last interval is given; now deleted.
*/

   
	
	if `n_int' >= 1 {
		if `n_int'==1 {
			local N_INT  `n_int'
			replace `n_censor' = 0 in `N_INT'
		}
		if `n_int' > 1 {
			// Assume same censoring rate as average over previous time intervals
			local len = `n_int' - 1
			qui sum `n_censor' in 1/`len'
			local sum_n_censor = r(sum)
			local temp1 = `sum_n_censor' * ///
			 (`tstart'[`upper'[`n_int']]-`tstart'[`lower'[`n_int']])/(`tstart'[`upper'[`n_int'-1]] - `tstart'[`lower'[1]])	
			local pos `n_int'
			local temp2 = min(round(`temp1'),`nrisk'[`n_int']) 
			replace `n_censor' = `temp2' in `pos'
		}
/*
	If number at risk is not reported at intervals but only the total number
	of patients are available to each arm, in this case `n_int' = 1, and it
	appears that we only do the calculation in the last interval.
*/
	
		local N_INT = `n_int'
		//line 253 - 259 added on 29/July/2015
		if `n_censor'[`N_INT'] <= 0 {
		   local start = `lower'[`N_INT']
		   local end   = `upper'[`N_INT']
		   replace `cen' = 0 in `start'/`end'
		   replace `n_censor' = 0 in `N_INT'
		   local temp = `n_censor'[`N_INT']
		}
		if `n_censor'[`N_INT'] > 0 {
			local len = `n_censor'[`N_INT']	// need "=" to specify the local variable correctly
			//di as text "number censored at the last interval is " `len'
			gen `cen_t' = 0 in 1/`len'	
			// distribute censored observations evenly over time
			forvalues j = 1/`len'{
				local temp =`tstart'[`lower'[`N_INT']] + `j'*(`tstart'[`upper'[`N_INT']]-`tstart'[`lower'[`N_INT']])/(`n_censor'[`N_INT']+1)
				replace `cen_t' = `temp' in `j'
				//di as text "censoring time is" `temp'
			}
			// Find no. censored on each time interval
			local start = `lower'[`N_INT']
			local end = `upper'[`N_INT']-1
			// one-step in R using hist(,plot=F)$count. not sure in stata
			forvalues k = `start'/`end'{
				qui count if `cen_t' >=`tstart'[`k'] & `cen_t'<`tstart'[`k'+1]
				replace `cen' = r(N) in `k' 		 
				//di `k' _column(5) `cen'[`k']
			}
			capture drop `cen_t'
		}
		// Find no. events and no. at risk on each interval to agree with KM estimates read from curves	
		local pos = `lower'[`N_INT']
		replace `n_hat' = `nrisk'[`N_INT'] in `pos' 
		local last = `last_i'[`N_INT']
		local start = `lower'[`N_INT']
		local end = `upper'[`N_INT']
		forvalues k = `start'/`end' {
			if `KM_hat'[`last'] != 0 {
				replace `d' = round(`n_hat'[`k']*(1-(`s'[`k']/`KM_hat'[`last']))) in `k'
			}
			else {
				replace `d' = 0 in `k'
			}
			replace `KM_hat' = `KM_hat'[`last']*(1-(`d'[`k']/`n_hat'[`k'])) in `k'		
			local index = `k' + 1
			replace `n_hat' = `n_hat'[`k']-`d'[`k']-`cen'[`k'] in `index'
			*No. at risk cannot be negative
			if `n_hat'[`k'+1] < 0 {
				local index = `k' + 1
				replace `n_hat' = 0 in `index'
				replace `cen' = `n_hat'[`k'] - `d'[`k']	in `k'
			}
			if `d'[`k'] !=0 {
				local last `k'
			}
		}
/*
	Comment out the code relevant to totevents , 23 July2014.
	if "`totevents'" != ""  will be expanded if remove comment.
*/
		local N_INT = `n_int' 
		local len = `n_censor'[`N_INT']
		// if total no. of events reported, adjust no. censored so that total no. of events agrees.
		if "`totevents'" != "" {
			if `N_INT' > 1 {
				local endp = `upper'[`N_INT'-1]		
				qui sum(`d') in 1/`endp'
				local sumdL = r(sum)	
				// If total no. events already too big, then set events and censoring = 0 on all further time intervals
				if `sumdL' >= `totevents' {
					local startp = `lower'[`N_INT']
					local endp	 = `upper'[`N_INT']
					replace `d' = 0 in `startp'/`endp'
					local endp = `upper'[`N_INT'] -1
					replace `cen' = 0 in `startp'/`endp'
					local startp = `lower'[`N_INT'] +1
					local endp	 = `upper'[`N_INT'] +1
					replace `n_hat' = `nrisk'[`N_INT'] in `startp'/`endp'
					// noi di "[Stop condition 1] Estimated tot events `sumdL' prior to the last interval is greater than reported tot events `totevents'"
				}
			}
/*
	Otherwise adjust no. censored to give correct total no. events
	YW: note. for the ICON7 data, the following code in the condition
	if(`sumdL'<`tot_events') was not tested .
*/
			if `sumdL' < `totevents' | `n_int'==1 {
				local endp = `upper'[`N_INT']
				qui sum `d' in 1/`endp'
				local sumd = r(sum)
				local abc = `n_censor'[`N_INT']
				//di as err "estimated tot events (include the last interval) is `sumd'; reported tot events `totevents'; estimated number censor `abc'"							
				if `sumd' == `totevents' {
					// noi di "[Stop condition 2] Estimated tot events `sumd' is equal to the reported tot events `totevents'"
				}
				if `sumd' < `totevents' &`abc' == 0 {
					// noi di "[Stop condition 3] Estimated censor at the last interval is 0"
				}
				if ((`sumd'>`totevents') | (`sumd' < `totevents' & `abc' > 0)) {
					// noi di "redistributing the estimated censoring over the last interval"
	            	}
				while (`sumd'>`totevents') | (`sumd' < `totevents' & `abc' > 0) {
					noi di as text "estimated tot events is `sumd'; reported tot events `totevents';estimated number censor `abc'"	
					di `abc'
					if `n_censor'[`N_INT'] <= 0 {
						local startp = `lower'[`N_INT']
						local endp	 = `upper'[`N_INT']
						replace `cen' = 0 in `startp'/`endp'
						replace `n_censor' = 0 in `N_INT'
					}
					if `n_censor'[`N_INT'] > 0 {
						local len = `n_censor'[`N_INT']
						gen `cen_t' = 0 in 1/`len'	
						forvalues j = 1/`len' {
							local temp =`tstart'[`lower'[`N_INT']] + `j'*(`tstart'[`upper'[`N_INT']]-`tstart'[`lower'[`N_INT']])/(`n_censor'[`N_INT']+1)
							replace `cen_t' = `temp' in `j'
						}				
						local start = `lower'[`N_INT']
						local end = `upper'[`N_INT']-1
						forvalues k = `start'/`end'{
							qui count if `cen_t' >=`tstart'[`k'] & `cen_t'<`tstart'[`k'+1]
							replace `cen' = r(N) in `k' 		 
							//di `k' _column(5) `cen'[`k']
						}
						capture drop `cen_t'
					}
					local index = `lower'[`N_INT']
					replace `n_hat' = `nrisk'[`N_INT'] in `index'
					local last = `last_i'[`N_INT']
					local start = `lower'[`N_INT']
					local end = `upper'[`N_INT']
					forvalues k = `start'/`end' {
						replace `d' = round(`n_hat'[`k']*(1-(`s'[`k']/`KM_hat'[`last']))) in `k'								
						replace `KM_hat' = `KM_hat'[`last']*(1-(`d'[`k']/`n_hat'[`k'])) in `k'						 
						if `k' != `upper'[`n_int'] {
							local index = `k' + 1
							replace `n_hat' = `n_hat'[`k'] - `d'[`k'] - `cen'[`k'] in `index'
							// No. at risk cannot be negative
							if `n_hat'[`k'+1] < 0 {
								replace `n_hat' = 0 in `index'
								replace `cen' = `n_hat'[`k'] - `d'[`k'] in `k'
							}
						}
						if `d'[`k'] !=0 { 
							local last `k'
						}
					}
					local endp = `upper'[`N_INT']
					qui sum `d' in 1/`endp'
					local sumd = r(sum)
					replace `n_censor' = `n_censor'[`N_INT'] + (`sumd' - `totevents') in `N_INT'
					local abc = `n_censor'[`N_INT']
					if !((`sumd'>`totevents') | (`sumd' < `totevents' & `abc' > 0)) {
						// noi di "[Stop condition 4] Complete after redistributions of censor at the last interval!"
					}
				}
			}
		}
		else {
			// di as text "total number of events was not reported in the publication"
		}
	}
/*
	Form IPD (create reconstructed survival data at patient level)
*/

	// initialize vectors
	local endp = `nrisk'[1]
	gen `t_ipd' = `tstart'[`n_t'] in 1/`endp'
	gen byte `event_ipd' = 0 in 1/`endp'
	// write event time and event indicator (=1) for each event, as separate row in t_IPD and event_IPD
	local k 1
	local N_t=`n_t'
	//di as error "Checkign N_t = `N_t'"
	forvalues j = 1/`N_t' {
	 // di as error "check `j'"
		if `d'[`j'] != 0&`d'[`j']!=. {
			local startp `k'
			local endp = `k' + `d'[`j'] - 1
		
			/*if `j'==75{
			local temp2 = `d'[`j']
			 di as error "`temp2'"
			 di as error "`startp'"
			 di as error "`endp'"
			}*/
			replace `t_ipd' = `tstart'[`j'] in `startp'/`endp'
			replace `event_ipd' = 1 in `startp'/`endp'
			local k = `startp' + `d'[`j']
		}
	}
	// write censor time and event indicator (=0) for each censor, as separate row in t_IPD and event_IPd
	local N_t_1 = `n_t' - 1
	forvalues j = 1/`N_t_1' {
		if `cen'[`j'] != 0 {
			local startp = `k'
			local endp = `k' + `cen'[`j'] - 1
			local temp = (`tstart'[`j'] +`tstart'[`j'+1])/2
			//di `temp'
			replace `t_ipd' = `temp' in `startp'/`endp'
			replace `event_ipd' = 0 in `startp'/`endp'
			local k = `startp' + `cen'[`j']
		}
	}
	// Save results to file and tidy up
	preserve
	keep `t_ipd' `event_ipd'
	drop if missing(`t_ipd')
	save `"`saving'"', replace
	restore
	if ("`to_drop'" != "") drop if `to_drop'
}
end

* v 1.0.0 PR/WvP 24may2013
/*
	Simplified version of WvP ira.ado, last updated 26/10/2012.
	Temporary variables:
	 PART     to define the current partition in merged sets.
	 VIOL     to detect a violation of the required ordering
	          and the need for an additional merge.
	 M        mean of response variable.
*/
program define irax, sortpreserve
version 11.0
quietly {
	syntax varlist(min=2 max=2 numeric) [if] [in] ///
	 [, COMbine GENerate(string) noPTs REVerse ci noGRaph *]
	if "`generate'" != "" {
		gettoken generate rest : generate, parse(" ,")
		tokenize `"`rest'"', parse(" ,")
		while "`1'" != "" {
			if "`1'" == "replace" {
				local gen_replace replace
				continue, break
			}
			mac shift
		}
	}
	marksample touse

	gettoken y xvar : varlist
	sum `y' if `touse', meanonly
	if r(min) == r(max) {
		di as err "`y' does not vary"
		exit 198
	}
	local mean_y = r(mean)
	count if (`touse'==1) & !inlist(`y', 0, 1)
	if (r(N)==0) local type LR 	// Logistic regression
	else local type LINR		// Linear regression
	noi di _n as txt "type = `type'"
	tempvar PART VIOL HR M x
	if "`reverse'"=="" {
		gen `x' = -`xvar' if `touse'
	}
	else gen `x' = `xvar' if `touse'
	gen int `PART' = 1 if `touse'==1
	sort `PART' `x' `y'
	replace `PART' = `PART'[_n-1] + (`x' > `x'[_n-1]) if !missing(`PART') & _n > 1
	if "`reverse'"=="" {
		replace `x' = -`x'
	}
	sort `PART'
	by `PART': gen `M' = sum(`y') if !missing(`PART')
	by `PART': replace `M' = `M'[_N] / _N
	gen int `VIOL' = sum((`M' >= `M'[_n-1]) & (`PART'>`PART'[_n-1]) & !missing(`PART'))
	while `VIOL'[_N] != 0 {
	   replace `PART' = `PART'[_n-1] + (`M' < `M'[_n-1]) if !missing(`PART') & _n > 1
	   sort `PART'
	   by `PART': replace `M' = sum(`y') if !missing(`PART')
	   by `PART': replace `M' = `M'[_N] / _N
	   replace `VIOL' = sum((`M' >= `M'[_n-1]) & (`PART' > `PART'[_n-1]) & !missing(`PART'))
	}
	if ("`type'"=="LR") label variable `M' "Event probability"
	else if ("`type'"=="LINR") label variable `M' "Mean of `y'"
	if "`combine'" != "" {
		// For the -combine- option, need to create the "other" curve
		if ("`reverse'" == "") local Reverse reverse
		tempvar tempfit
		irax `y' `xvar' if `touse', `Reverse' nograph generate(`tempfit', replace)
		replace `M' = `M' + `tempfit' - `mean_y'
		drop `tempfit' `tempfit'_p
		// Update partition to one based on the new mean-y groups
		drop `PART'
		egen int `PART' = group(`M') if `touse'
	/*
		// Not clear if we should best re-estimate mean for new partition. Can easily be done:
		drop `M'
		sort `PART'
		by `PART': gen `M' = sum(`y') if !missing(`PART')
		by `PART': replace `M' = `M'[_N] / _N		
	*/
	}
	if "`ci'" != "" {
		// Crude pointwise CI from partition model
		tempvar se lci uci
		tempname z
		scalar `z' = invnormal((100 + c(level))/200)
		if "`type'"=="LR" {
			local cmd logit
			local backtransf invlogit
			local transf logit
		}
		else {
			local cmd regress
		}
		`cmd' `y' ibn.`PART' if `touse'
		predict `se' if `touse', stdp
		gen `lci' = `backtransf'(`transf'(`M') - `z' * `se')
		gen `uci' = `backtransf'(`transf'(`M') + `z' * `se')
		drop `se'
	}
/*
	Create graph.
*/
	if "`graph'" != "nograph" {
		local title Isotonic Regression Analysis
		if ("`combine'" != "") local title `title' (extended)
		if "`type'" == "LINR" {
			local varlab: var lab `y'
			if ("`varlab'"=="" | index("`varlab'", ")") > 0) local varlab `y'
			local yplot = cond("`pts'" == "nopts", "", "`y'")
			if "`ci'" == "" {
				scatter `M' `yplot' `xvar' if `touse', sort connect(J .) msymbol(i oh) ///
				 title(`title') ytitle("`varlab'") `options'
			}
			else {
				scatter `M' `lci' `uci' `yplot' `xvar' if `touse', sort connect(J J J .) lpattern(l shortdash ..) ///
				 cmissing(y n n) msymbol(i i i oh) title(`title') ytitle("`varlab'") legend(off) `options'
			}
		}
		else {
			if "`ci'" == "" {
				line `M' `xvar' if `touse', sort connect(J) title(`title') `options'
			}
			else {
				line `M' `lci' `uci' `xvar' if `touse', sort connect(J J J) lpattern(l shortdash ..) ///
				 cmissing(y n n) title(`title') legend(off) `options'
			}
		}
	}
	if "`generate'" != "" {
		local lab : var lab `M'
		compute `generate' = `M', `gen_replace' label("`lab'")
		noi di as txt "[variable `generate' created]"
		compute `generate'_p = `PART', `gen_replace' label("partition of `xvar'")
		noi di as txt "[variable `generate'_p created]"
		if "`ci'" != "" {
			compute `generate'_lci = `lci', `gen_replace' label("lower CL for `lab'")
			compute `generate'_uci = `uci', `gen_replace' label("upper CL for `lab'")
			noi di as txt "[variables `generate'_lci and `generate'_uci created]"
		}
	}
}
end

* v 1.0.1 PR 03mar2013
program define compute
version 8.0
gettoken type 0 : 0, parse("= ") bind
// Process putative type
local ok 0
foreach t in byte int long float double {
	if "`t'" == "`type'" {
		local ok 1
		continue, break
	}
}
if !`ok' {
	if substr("`type'", 1, 3) == "str" {
		local strn = substr("`type'", 4, .)
		confirm integer number `strn'
		local ok 1
	}
}
if !`ok' {
	local newvar `type'
	local type
}
else gettoken newvar 0 : 0, parse("= ") bind
gettoken eqs 0 : 0, parse("= ")
if "`eqs'" != "=" {
	di "{p}{err}syntax is {cmd:compute [{it:type}] {it:existing_var}|{it:newvar} = {it:exp}}" ///
	 " [, {cmd:replace} {cmd:force} {cmd:label(}{it:label}{cmd:)}]{p_end}"
	 exit 198
}
gettoken Exp 0 : 0, parse(", ") bind
syntax [if] [in] [, replace LABel(string) force ]
if "`type'" != "" {
	local ok 0
	foreach t in byte int long float double {
		if "`t'" == "`type'" {
			local ok 1
			continue, break
		}
	}
	if !`ok' {
		if substr("`type'", 1, 3) == "str" {
			local strn = substr("`type'", 4, .)
			confirm integer number `strn'
			local ok 1
		}
	}
	if !`ok' {
		di as err "type `type' not recognized"
		exit 198
	}
}
capture confirm var `newvar', exact
local rc = c(rc)
if `rc' != 0 {
	// `newvar' does not exist; safe to create it from `Exp'
	generate `type' `newvar' = `Exp' `if' `in'
}
else {
	// `newvar' exists
	if "`replace'" != "" {
		// safe to recreate `newvar'
		replace `newvar' = `Exp' `if' `in'
		if "`type'" != "" {
			recast `type' `newvar', `force'
		}
	}
	else {
		di as err "`newvar' already defined"
		exit 110
	}
}
if "`label'" != "" {
	label var `newvar' "`label'"
}
end
exit

History
 
v 1.2.1 PR 31/July/2015. Tidy up code for lower and upper. Includes YW's recent changes in int() -> round().
v 1.1.0 YW 26/July/2015.  Remove lower() and uppwer() as options as they are not needed.
v 1.0.9 YW 25/July/2014. Output error message if the data information on the last interval of `trisk' are not given.
						 Include messages on the conditions of completing reconstruction. 
v 1.0.8 YW 23/July/2014. Delete the option "fullrisktable" as it makes little difference. 
	                     Comment out the relevant code. Keep the option "totevents".
v 1.0.7 YW 23/July/2014. Minor update. Set the while condition in the redistribution of total events.
v 1.0.7	YW 12/June/2013. Minor update. Set survival probability to be 1 if recorded as greater than 1.
v 1.0.7	YW 03/June/2013. Add -fullrisktable- option, default ("`fullrisktable'" == "") means that the total number at
		risk is not given for the last interval. The reconstruction for last interval are following those specified in Guyot.
		But if the total number at risks is given at the last interval, the reconstruction for last interval are following those
        specified for the other intervals.
v 1.0.6 PR 29may2013. Using irax not ira3 for isotonic regression. Minor tidying up. Renamed to reconstruct_ipd.
		Changed the -probability- option, default ("`probability'" == "") means percent.
v 1.0.5 YW 24may2013 minor updates. correct a bracket matching error in "if notal no. of events reported...."
v 1.0.4 PR/YW 24may2013 add isotonic regression as an alternative approach to correct survival/failure//
		probabilities if they are not monotonic
v 1.0.3 YW 22may2013 modify the first while condition, to allow the computation when number of censor (n_censor) 
		at interval i is equal to zero. prior to the first while condition, set the number of censor to be zero if negative.
		PR 22may2013 modify the code for lower() and upper()
v 1.0.2 YW 20may2013 allow index of bigger interval (lower, upper) to be missing
v 1.0.1 YW 17may2013 correct survival/failure probabilities if they are not monotonic
v 1.0.0 YW/PR 16may2013 
