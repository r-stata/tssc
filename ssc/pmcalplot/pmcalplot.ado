
******************************************************************
*												 				 *
*  PROGRAM TO PRODUCE FLEXIBLE CALIBRATION PLOTS 				 *
*  24/05/17 									 				 *
*  Updated: 24/05/2017											 *
*  	- added cutpoints option					 				 *
*  Updated: 21/10/2018 											 *
*	- added survival model observed data		 				 *
*  Updated: 27/10/2018 											 *
*	- added linear model capabilities			 				 *
*  Updated: 2/4/2019 											 *
*	- removed width default in histograms for cont outcomes		 *
*  Updated: 23/12/2019											 *
*	- updated range() option to ensure plotting of lowess 		 *
*		& spike plot inside range only							 *
*	- updated range() option to ensure correct scaling of spike  *
*		plot at any range										 *
*	- updated graph axes defaults when using range()			 *
*	- added 'zoom' option, which automatically scales the plot 	 *
*		to fit all groupings & CI's (lowess & spikes plotted	 *
*		within this zoomed range only)							 *
*	- updated survival plot: displays groupings at 1 if all 	 *
*		patients had an event before the time point of interest  *
*	- updated survival plot to allow spike plot					 *
*																 *
*  2.1.0 J. Ensor								 				 *
******************************************************************

*! 2.1.0 J.Ensor 23Dec2019

capture program drop pmcalplot
program define pmcalplot, rclass

version 12.1						

/* Syntax
	VARLIST = A list of two variables, the predicted probabilities from the model,
				and the event indicator (observed outcome) for binary 
				[not input for survival outcomes]
	Bin = Number of bins used to group patients average observed
					& expected probabilities
	CUTpoints = A numeric list of cutpoints based on risk to be used instead
		of equally sized bins. Real numbers in the interval [0,1].
	NOLowess = Remove lowess line
	NOSpike = Remove spike plot
	CI = add 95% CI's for the groups (CI's for proportions)
	SCatteropts = twoway options to affect rendition of the groups
	Range = a range for the plot describing the square size of the plot
	LOwessopts = twoway options to affect rendition of the lowess line
	SPikeopts = twoway options to affect rendition of the spikes
	CIopts = twoway options to affect rendition of the confidence intervals
	* = all other twoway options e.g. titles, legends (defaults apply otherwise)
	SURVival = calibration plot for survival models (uses KM estimates 
					for observed data)
	Timepoint = must be provided if survival option is on. A single time point 
					at which calibration is plotted. Units of time are defined by 
					the stset command prior to using pmcalplot. 
					Default = 1 unit of time.
	NOHist = Remove histograms from axes for continuous outcome models
	HIstopts = twoway options to affect rendition of the histograms
	KEEP = return variables for the expected, observed, & risk groups
	ZOOM = produces a plot displaying all data but in a narrower range than [0 1]

*/
	syntax varlist(min=1 max=2 numeric) [if] [in], [Bin(int 10) ///
						CUTpoints(numlist >=0 <=1 sort) noLowess noSpike ///
						CI SCatteropts(string asis) ///
						Range(numlist min=2 max=2 sort) ///
						LOwessopts(string asis) SPikeopts(string asis) ///
						CIopts(string asis) noStatistics SURVival ///
						Timepoint(int 1) KEEP CONTinuous noHist ///
						OBSHIstopts(string asis) EXPHIstopts(string asis) ///
						P(int 0) LP(varname numeric) ZOOM *] 

//SET UP TEMPVARS
tempvar binvar obs obsn exp binvar2 exp2 events nonevents outcomp ///
			lci uci obsse lowvar spikejitter binary_lp thresh

// check on the if/in statement
marksample touse
qui count if `touse'
local n = `r(N)'
if `r(N)'==0 { 
	di as err "if statement identifies subgroup with no data?"
	error 2000
	}
	
// check only one of the surv or cont options is specified
if "`continuous'"=="continuous" & "`survival'"=="survival" {
	di as err "Only one outcome type can be selected (default=binary, surv=survival, cont=continuous)."
	error 198
	}
	else if "`survival'"=="survival" {
		di as inp "Survival option selected: Calibration plot for survival prediction model displaying..."
		}
		else if "`continuous'"=="continuous" {
			di as inp "Continuous option selected: Calibration plot for linear prediction model displaying..."
			}
			else {
				di as inp "Binary option selected: Calibration plot for logistic prediction model displaying..."
				}
			
// parse varlist
tokenize `varlist' , parse(" ", ",")

// run checks on user input variables in varlist
// check if user has input both exp and obs (for binary/survival outcomes)
local varcountcheck: word count `varlist'
if "`survival'"=="survival" {
	if `varcountcheck'!=1 {
		di as err "Varlist contains too many variables. For survival outcomes only predicted probabilities (expected values) are required"
		error 103
		}
	}
	else if "`continuous'"=="continuous" {
			if `varcountcheck'!=2 {
					di as err "Varlist must contain two variables. Predicted values (expected values), followed by observed values are required"
					error 102
					}
			}
			else {
				if `varcountcheck'!=2 {
					di as err "Varlist must contain two variables. Predicted probabilities (expected values), followed by observed outcomes (binary variable) are required"
					error 102
					}
					
				// check first var in varlist is a binary outcome (0 1) var
				qui levelsof `2', l(distinct)
				local sum = 0
				local prod = 1
				foreach i in `distinct' {
					local count = `count'+1
					local sum = `sum'+`i'
					local prod = `prod'*`i'
					}
					
				if `count'!=2 {	
						di as err "Event indicator not binary? Check which type of outcome you're using."
						error 450 
						}
						else if (`sum'!=1 & `prod'!=0) {
							di as err "Event indicator must be coded 0 or 1"
							error 450 
							}			
				}
			
// check the first var in varlist is probabilities lying btwn 0-1 (binary/survival)
if "`continuous'"!="continuous" {
	qui su `1'
	if `r(min)'>=0 & `r(max)'<=1 { 
		}
		else {
			di as err "1st element of varlist must be probabilities in the interval [0,1]"
			error 459
			}
		}
		
******************** BINARY OUTCOMES
if "`survival'"!="survival" & "`continuous'"!="continuous" {
	// check if user specified cutpoints
	if "`cutpoints'"!="" {
		qui gen `thresh' = .
		local q = 1
		foreach i in `cutpoints' {
			qui replace `thresh' = `i' in `q'
			local ++q
			}	
		
		* warning message for transparent reporting 
		di as err _n "WARNING: Do not use the cut-point option unless the model has prespecified clinically relevant cut-points."
		
		* create risk groups based on cutpoints
		xtile `binvar' = `1' if `touse', cutpoints(`thresh')
		}
		else {
			// create equally sized risk groups by number of bins
			xtile `binvar' = `1' if `touse', n(`bin')
			}
			
	// average the observed & expected over the bins 
	qui egen `obs' = mean(`2') if `touse', by(`binvar')
	qui egen `obsn' = count(`2') if `touse', by(`binvar')
	qui egen `exp' = mean(`1') if `touse', by(`binvar')

	// CIs for scatter points
	if "`ci'"=="ci" {
		qui gen `obsse' = ((`obs'*(1-`obs'))/`obsn')^.5
		qui gen `lci' = max(0,(`obs' - (1.96*`obsse')))
		qui gen `uci' = min(1,(`obs' + (1.96*`obsse')))
		}
		
	// create spike plot
	qui gen byte `events' = 0
	qui replace `events' = 1 if `2'==1 
	qui replace `events'=. if `1'==.
	qui gen `outcomp'= 1-`2'
	qui gen byte `nonevents' = 0
	qui replace `nonevents' = -1 if `outcomp'==1 
	qui replace `nonevents'=. if `1'==.
	}

******************** SURVIVAL OUTCOMES
if "`survival'"=="survival" & "`continuous'"!="continuous" {
	// Lowess for survival not incorportated yet 
	// turn off lowess
	local lowess = "nolowess"
	*local spike = "nospike"

	********************
	// check if user specified cutpoints
	if "`cutpoints'"!="" {
		qui gen `thresh' = .
		local q = 1
		foreach i in `cutpoints' {
			qui replace `thresh' = `i' in `q'
			local ++q
			}	
	
		* warning message for transparent reporting 
		di as err _n "WARNING: Do not use the cut-point option unless the model has prespecified clinically relevant cut-points."
		
		* create risk groups based on cutpoints
		xtile `binvar' = `1' if `touse', cutpoints(`thresh')
		}
		else {
			// create equally sized risk groups by number of bins
			xtile `binvar' = `1' if `touse', n(`bin')
			}
			
	// identify the bin numbers in binvar (particularly when using cutpoints)
	qui levelsof `binvar', l(newbins)
		
	// average the observed over the bins - survival outcomes
	*Slightly more complicated for observed
	qui gen `obs'=.
	qui gen `lci'=.
	qui gen `uci'=.
	tempfile temp
		foreach i in `newbins' {
			qui sts list if `binvar'==`i' , at(0 `timepoint') saving(`temp', replace)
			preserve
				qui use `temp', clear
				qui drop if time==0
				local cal_obs=1-survivor
				local cal_obs_lb=1-lb
				local cal_obs_ub=1-ub

			restore
			if `cal_obs'==. {
				qui replace `obs'=1 if `binvar'==`i'
				qui replace `lci'=. if `binvar'==`i'
				qui replace `uci'=. if `binvar'==`i'
				}
				else {
					qui replace `obs'=`cal_obs' if `binvar'==`i'
					qui replace `lci'=`cal_obs_lb' if `binvar'==`i'
					qui replace `uci'=`cal_obs_ub' if `binvar'==`i'
					}
		}

	// average the expected over the bins - survival outcomes
	qui egen `exp' = mean(`1') if `touse', by(`binvar')
		
	
	// create spike plot
	qui gen byte `events' = 0
	qui replace `events' = 1 if _d==1 & _t<=`timepoint'
	qui replace `events'=. if `1'==. 
	//qui gen `outcomp'= 1-_d
	qui gen byte `nonevents' = 0
	qui replace `nonevents' = -1 if `events'!=1 
	qui replace `nonevents'=. if `1'==. 
	}

******************** CONTINUOUS OUTCOMES
if "`survival'"!="survival" & "`continuous'"=="continuous" {
	// average the observed & expected over the bins 
	qui gen `obs' = `2' if `touse'
	qui gen `exp' = `1' if `touse'
	
	// Lowess for continuous data possible, but computationally intensive!
	*local lowess = "nolowess"
	
	// turn spike plot off as continuous outcomes uses histograms
	local spike = "nospike"
	
	// turn off ci for continuous outcomes
	local ci = ""
	}

********************
************************************
// calculate range locals from user input (or default 0 1)
if "`range'"!="" {
		gettoken first second : range
		local minr = `first'
		local maxr = `second'
		di as err _n "WARNING: Plot range has been manually restricted. Be aware that information may lie outside of this range." _n "Groupings & CI's will not be displayed if they lie outside of the specified range" _n "Further, lowess values outside of the specified range will not be plotted"
		
		local range_diff = abs(`maxr'-`minr')
		local adj = `minr' -(.05*`range_diff')
		local adjdown = `minr' -(.04*`range_diff')
		local adjup = `minr' -(.06*`range_diff')
		
		// scale the spike plot to fit along the bottom of the cal plot
		if "`continuous'"!="continuous" {
			qui replace `events' = (`events'/30)*(`range_diff') + `adj'
			qui replace `nonevents' = (`nonevents'/30)*(`range_diff') + `adj' 
			qui gen `spikejitter' = `1'+(runiform()*0.00001)
			}
		
		local sp1 = cond("`spike'"=="nospike","",`"|| rspike `events' `nonevents' `spikejitter' if (`spikejitter'<`maxr') & (`spikejitter'>`minr'), yline(`adj') text(`adjdown' `maxr' "1", place(n)) text(`adjup' `maxr' "0", place(s)) lw(thin) lcol(maroon) `spikeopts'"')
		local ci1 = cond("`ci'"=="ci","|| rspike `uci' `lci' `exp' if (`exp'<=`maxr') & (`exp'>=`minr') & (`uci'<=`maxr') & (`uci'>=`minr') & (`lci'<=`maxr') & (`lci'>=`minr'), lcol(forest_green) `ciopts'","")
		}
		else if "`range'"=="" & "`continuous'"=="continuous" {
			qui su `2'
			
			local minr = r(min)
			local maxr = r(max)
			}
			else if "`zoom'"=="zoom" {
				if "`survival'"=="survival" {
					qui su `uci'
					local ci_minr = r(min)
					qui su `lci'
					local ci_maxr = r(max) 
					qui su `obs'
					local obs_minr = r(min)
					local obs_maxr = r(max)
					qui su `exp'
					local exp_minr = r(min)
					local exp_maxr = r(max)
					local minr = min(`exp_minr', `obs_minr', `ci_minr')
					local maxr = max(`exp_maxr', `obs_maxr', `ci_maxr')
					}
					else {
						qui su `uci'
						local ci_maxr = r(max)
						qui su `lci'
						local ci_minr = r(min)
						qui su `obs'
						local obs_minr = r(min)
						local obs_maxr = r(max)
						qui su `exp'
						local exp_minr = r(min)
						local exp_maxr = r(max)
						local minr = min(`exp_minr', `obs_minr', `ci_minr')
						local maxr = max(`exp_maxr', `obs_maxr', `ci_maxr')
						}
				
				local ci1 = cond("`ci'"=="ci","|| rspike `uci' `lci' `exp' if (`exp'<=`maxr') & (`exp'>=`minr'), lcol(forest_green) `ciopts'","") 
				di as err _n "WARNING: Plot range has been manually restricted. Be aware that information may lie outside of this range." _n "Lowess & Spike plot values may lie outside of the plot range when using zoom option"
		
				local range_diff = abs(`maxr'-`minr')
				local adj = `minr' -(.05*`range_diff')
				local adjdown = `minr' -(.04*`range_diff')
				local adjup = `minr' -(.06*`range_diff')
				
				// scale the spike plot to fit along the bottom of the cal plot
				if "`continuous'"!="continuous" {
					qui replace `events' = (`events'/30)*(`range_diff') + `adj'
					qui replace `nonevents' = (`nonevents'/30)*(`range_diff') + `adj' 
					qui gen `spikejitter' = `1'+(runiform()*0.00001)
					}
		
				local sp1 = cond("`spike'"=="nospike","",`"|| rspike `events' `nonevents' `spikejitter' if (`spikejitter'<`maxr') & (`spikejitter'>`minr'), yline(`adj') text(`adjdown' `maxr' "1", place(n)) text(`adjup' `maxr' "0", place(s)) lw(thin) lcol(maroon) `spikeopts'"')
				}
				else {
					local minr = 0
					local maxr = 1
					
					// scale the spike plot to fit along the bottom of the cal plot
					if "`continuous'"!="continuous" {
						qui replace `events' = (`events'/30)-.05
						qui replace `nonevents' = (`nonevents'/30)-.05 
						qui gen `spikejitter' = `1'+(runiform()*0.00001)
						}
					
					local sp1 = cond("`spike'"=="nospike","",`"|| rspike `events' `nonevents' `spikejitter' if (`spikejitter'<`maxr') & (`spikejitter'>`minr'), yline(-.05) text(-.04 `maxr' "1", place(n)) text(-.06 `maxr' "0", place(s)) lw(thin) lcol(maroon) `spikeopts'"')
					local ci1 = cond("`ci'"=="ci","|| rspike `uci' `lci' `exp' if (`exp'<=`maxr') & (`exp'>=`minr') & (`uci'<=`maxr') & (`uci'>=`minr') & (`lci'<=`maxr') & (`lci'>=`minr'), lcol(forest_green) `ciopts'","")
					}

					
// derive and save lowess curve variable
if "`lowess'"!="nolowess" {
	lowess `2' `1' if `touse', nog gen(`lowvar')
	}

// graph command locals (all combinations of hist/lowess or not)
local lo1 = cond("`lowess'"=="nolowess","","|| line `lowvar' `1' if (`lowvar'<=`maxr') & (`lowvar'>=`minr') & (`1'<=`maxr') & (`1'>=`minr'), sort lcol(midblue) `lowessopts'")
	
// create local to manage the legend ordering
if ("`lowess'"=="nolowess") & ("`ci'"=="ci") {
	local leglaborder "1 2 3"
	local labs "lab(1 Reference) lab(2 Groups) lab(3 95% CIs) "
	}
	else if ("`lowess'"=="") & ("`ci'"=="") {
		local leglaborder "1 2 3"
		local labs "lab(1 Reference) lab(2 Groups) lab(3 Lowess)"
		}
		else if ("`lowess'"=="nolowess") & ("`ci'"=="")  {
			local leglaborder "1 2"
			local labs "lab(1 Reference) lab(2 Groups)"
			}
			else {
				local leglaborder "1 2 3 4"
				local labs "lab(1 Reference) lab(2 Groups) lab(3 95% CIs) lab(4 Lowess)"
				} 

				 
// Calibration performance statistics
if "`statistics'"!="nostatistics"  {
	// stats for binary outcomes
	if "`survival'"!="survival" & "`continuous'"!="continuous" {
		* calculating linear predictor
		qui gen `binary_lp' = ln(`1'/(1-`1'))

		* calculating c-slope
		qui logistic `2' `binary_lp' if `touse', coef 
		local cslope = _b[`binary_lp']
		local cslope : di %4.3f `cslope'
		return scalar cslope = `cslope'

		* calculating calibration-in-the-large (CITL)
		qui logistic `2' if `touse', offset(`binary_lp') coef
		local citl = _b[_cons]
		local citl : di %4.3f `citl'
		return scalar citl = `citl'

		* exp/obs ratio
		qui su `2' if `touse'
		local o = r(mean)
		qui su `1' if `touse'
		local e = r(mean)
		local eo = `e'/`o'
		local eo : di %4.3f `eo'
		return scalar eo_ratio = `eo'

		* c-index
		qui roctab `2' `1' if `touse'
		local cstat = r(area) 
		local cstat : di %4.3f `cstat'
		return scalar cstat = `cstat'
		
		local st1 = `" text(`maxr' `minr' "E:O = `eo'" "CITL = `citl'" "Slope = `cslope'" "AUC = `cstat'", size(small) place(se) just(left))"'
		}
		
		// stats for survival outcomes
	if "`survival'"=="survival" {
		* calculating linear predictor
		if "`lp'"!="" {
			* calculating c-slope
			qui stcox `lp' if `touse', nohr
			local cslope = _b[`lp']
			local cslope : di %4.3f `cslope'
			return scalar cslope = `cslope'
			
			* c-index
			qui estat concordance
			local cstat = r(C) 
			local cstat : di %4.3f `cstat'
			return scalar cstat = `cstat'
			
			
			local st1 = `" text(`maxr' `minr' "Slope = `cslope'" "C-statistic = `cstat'", size(small) place(se) just(left))"'
			}
		}
		
		// stats for continuous outcomes
	if "`continuous'"=="continuous" {
		* calculating c-slope
		qui reg `2' `1' if `touse' 
		local cslope = _b[`1']
		local cslope : di %4.3f `cslope'
		return scalar cslope = `cslope'
		
		* r-sq
		local r2 = `e(r2)'
		if `p'!=0 {
			* r-sq adjusted
			local r2a = (((`n'-1)*`r2')-`p')/(`n'-`p'-1)
			local r2a : di %4.3f `r2a'
			return scalar r2a = `r2a'
			}
			
		local r2 : di %4.3f `r2'
		return scalar r2 = `r2'
		
		
		* calculating calibration-in-the-large (CITL)
		qui constraint 1 `1'=1
		qui cnsreg `2' `1' if `touse', constraint(1)
		local citl = _b[_cons]
		local citl : di %4.3f `citl'
		return scalar citl = `citl'
		
		if `n'!=0 & `p'!=0 {
			local st1 = `" text(`maxr' `minr' "R-squared = `r2'" "Adj R-squared = `r2a'" "CITL = `citl'" "Slope = `cslope'", size(small) place(se) just(left))"'
			}
			else {
				local st1 = `" text(`maxr' `minr' "R-squared = `r2'" "CITL = `citl'" "Slope = `cslope'", size(small) place(se) just(left))"'
				}
		
		}
	}


// Graph command combining user selected features (binary & survival)
if "`continuous'"!="continuous" {
	graph twoway function y=x, range(`minr' `maxr') lp(-) || ///
		scatter `obs' `exp' if (`exp'<=`maxr') & (`exp'>=`minr') & (`obs'<=`maxr') & (`obs'>=`minr'), mcol(dkgreen) ///
		msym(Oh)  graphr(col(white)) ///
		xlab(#5) ylab(#5) ///
		ytitle("Observed") xtitle("Expected") aspect(1) ///
				legend(pos(3) order(`leglaborder') ///
						`labs' col(1) size(small)) ///
						`scatteropts' `options' `ci1' `lo1' `sp1' `st1' 
	}

******************* 	

// Graph commands for continuous outcomes
if "`continuous'"=="continuous" {
// if histogram is on then produce and combine graphs
	if "`hist'"!="nohist" {
		* set up tempmnames for graphs
		tempname obs_graph sc_graph exp_graph
		
		* graphs
		qui graph twoway function y=x, range(`minr' `maxr') lp(-) || ///
			scatter `obs' `exp' if (`1'<`maxr') & (`1'>`minr'), mcol(dkgreen) ///
			msym(Oh) graphr(col(white)) ///
			xlab(#5) ylab(#5) nodraw ///
			ytitle("") xtitle("") aspect(1)	legend(off) saving(`sc_graph', replace) ///
							`scatteropts' `options' `ci1' `lo1'  `st1' 
		
		qui twoway histogram `obs', graphr(col(white))  xlab(minmax, angle(v) ///
			format(%3.2f)) xsca(reverse) ylab(#5) ysca() ytitle("Observed") xtitle("") ///
			horiz fxsize(15) saving(`obs_graph', replace) col(maroon) nodraw `obshistopts'

		qui twoway histogram `exp', graphr(col(white))  ylab(minmax, angle(h) ///
			format(%3.2f)) xlab(#5) ytitle("") xtitle("Expected") ///
			fysize(15) saving(`exp_graph', replace) col(maroon) nodraw `exphistopts'

		* Combine the above plots in one plot. 
		graph combine `obs_graph'.gph `sc_graph'.gph `exp_graph'.gph, hole(3) imargin(1 0 1 0) ///
		graphregion(margin(l=1 r=3)) xsize(4) ysize(4) graphr(col(white)) `options'
		}
		else {
			graph twoway function y=x, range(`minr' `maxr') lp(-) || ///
			scatter `obs' `exp' if (`1'<`maxr') & (`1'>`minr'), mcol(dkgreen) ///
			msym(Oh) graphr(col(white)) ///
			xlab(#5) ylab(#5) ///
			ytitle("Observed") xtitle("Expected") aspect(1) ///
					legend(pos(3) order(`leglaborder') ///
							`labs' col(1) size(small)) ///
							`scatteropts' `options' `ci1' `lo1'  `st1' 
			}
		}
		
****************************************************************************
/* give user the option to leave behind the cutpoints/bins variable
	so they can see if there were no patients in a specific risk group */
if "`keep'"=="keep" {
	capture confirm variable obs_pmcalplot
	if !_rc {
		di as err "Variable with name 'obs_pmcalplot' already exists, pmcalplot cannot generate required variables"
		}
		else {
			rename `obs' obs_pmcalplot
		    }
	
	capture confirm variable exp_pmcalplot
	if !_rc {
		di as err "Variable with name 'exp_pmcalplot' already exists, pmcalplot cannot generate required variables"
		}
		else {
			rename `exp' exp_pmcalplot
		    }
	
	if "`continuous'"!="continuous" {
	capture confirm variable groups_pmcalplot
		if !_rc {
			di as err "Variable with name 'groups_pmcalplot' already exists, pmcalplot cannot generate required variables"
			}
			else {
				rename `binvar' groups_pmcalplot
				}	
			}
	}
	
end 	

// END OF PROGRAM
*********************************************************************************

*******************************************************************************
*********************************************************************************
*********************************************************************************
// STATA DATASET EXAMPLES - all apparent performance examples
********************************************************************************

/*
// a couple of example datasets free from stata
// EXAMPLE DATASET 1			

webuse lbw, clear
expand 2, gen(val1)
expand 2, gen(val2)
replace val1 = 0 if val2==1
replace val2 = 0 if val1==1

logistic low age lwt i.race smoke ptl ht ui if val1==0

predict p_dev
predict xb_dev, xb

pmcalplot low p_dev if val1==0, name(EX1a, replace) graphr(col(white)) ci 

logistic low xb_dev if val1==0, coef //offset(xb_dev)
replace xb_dev = xb_dev*1.111 if val1==1
replace xb_dev = xb_dev - 0.55 if val2==1

predict p_val

pmcalplot low p_val if val1==1, name(EX1b, replace) graphr(col(white)) ci 
pmcalplot low p_val if val2==1, name(EX1c, replace) graphr(col(white)) ci 

ret list
			
* relyplot, gr(10) ci aspect(1)
*******************************************************************************
