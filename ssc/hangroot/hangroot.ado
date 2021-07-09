*! version 1.5.0 MLB 12Jul2011
* allow explanatory variables
* split-up the program in several smaller hangr_*.ado programs
* add negative binomial, zip, zinb, zoib
* allow use after -poisson-
* version 1.4.4 MLB 20Feb2011
* Add the logistic distribution
* use Stata's gammaden() function instead of my own formula
* version 1.4.2 MLB 03Jan2010
* fix sort order in the theoretical distribution
* version 1.4.1 MLB 04Dec2009
* implement the empirical distribution
* version 1.4.0 MLB 19Nov2009
* Implemented the suspended rootogram
* version 1.3.0 MLB 17Nov2009
* added the par() option and the Chi square distribution
* version 1.2.3 MLB 15Jan2008
* fixed bug when filling in zero bins when the number of bins is larger 
* than the number of observations in the dataset
* fixed bug with -discrete- option
* version 1.2.2 MLB 23Dec2007
* implemented the log-normal, Weibull, gamma, Gumbel, inverse gamma, 
* Wald, Fisk, Dagum, Singh-Maddala, Generalized Beta II, and the
* generalized extreme value distribution
* version 1.2.1 MLB 17Dec2007
* Fixed bug in axis title options, and changed default legend
* with beta distribution only use those cases between 0 and 1
* integrated hangroot with betafit and paretofit
* version 1.2.0 MLB 29Nov2007
* added exponential, laplace, uniform, geometric distribution
* changed to dist option instead of normal poisson etc options
* added plot, and ci options
* version 1.1.1 MLB 27Nov2007
* corrected a bug in the calculations of the hight of the bars	
* version 1.1.0 MLB 10Nov2007
* correct bug in passing thru options to -twoway rspike-/-twoway rbar-
* added beta, pareto and poisson distribution
* allowed fweights
* version 1.0.0 MLB 04Nov2007
program define hangroot, rclass sortpreserve
	version 9.2
	syntax  [varname(default=none)]         ///
	[if] [in] [fweight /] [,                ///
	SPike                                   /// default 
	BAR                                     /// 
    DIST(string)                            ///
    ci                                      ///
    par(numlist)                            /// overwrite parameters
	SUSPended                               ///	suspended rootogram
	noTHEORetical                           /// suppress display of theoretical distribution
    sims(varlist)                           /// used for overlaying a protfolio of scenarios
	simsopt(string)                         /// optios for simulations
	JITTERsims(numlist max=1 >0 integer)    ///
	jitterseed(numlist max=1 >0 )           ///
	Level(integer $S_level)                 /// 
	BIN(passthru)                           /// number of bins
	Width(passthru)                         /// width of bins
	START(passthru)                         /// first bin position
	Discrete                                ///
	ninter(numlist max=1 >= 0 <=20 integer) /// number of points between bin mids
	LEGend(passthru)                        ///
	YTItle(passthru)                        ///
	XTItle(passthru)                        ///
	MAINOpt(string)                         /// options for the main graph (counts or residuals)
	CIOpt(string)                           /// options for the confidence intervals
	THEOROpt(string)                        /// options for the theoretical distribution
	BY(passthru)                            /// not allowed
	HORizontal                              /// not allowed
	VERTical                                /// not allowed
	plot(str asis)                          /// extra overlaid graph
	*                                       /// options sent to -twoway rbar-/ -twoway rspike-
	]

	sreturn clear
	// parse distribution
    if `"`dist'"' != "" local distopt `"dist(`dist')"'
	if `"`par'"' != "" local paropt `"par(`par')"'
	hangr_parsedist `varlist', `distopt' `paropt'
	
    local dist `s(dist)'           // name of the distribution,
	                               // cleaned and/or derived from last estimation command
    
	local groupvar `s(groupvar)'   // variable identifying theoretical and empirical groups in the theoretical distribution
	
	local XXfit `s(XXfit)'         // the previous estimation command can be used to extract the theoretical distribution from
	
	local withx `s(withx)'         // the previous estimation command contained explanatory variables

	local inflate `s(inflate)'
	
	if `XXfit' {
		local varlist "`s(varlist)'"
		local weight  "`s(weight)'"
		local exp     "`s(exp)'"
	}
	
	// parse options
	if "`weight'" != "" {
		local wght "[`weight' = `exp']"
	}
	
	if "`ciopt'"        != "" local cioptopt "ciopt(`ciopt')"
	if "`theoropt'"     != "" local theoroptopt "theoropt(`theoropt')"
	if "`mainopt'"      != "" local mainoptopt "mainopt(`mainopt')"
	if "`ninter'"       != "" local ninteropt "ninter(`ninter')"
	hangr_parseopts `varlist' `if' `in' `wght',                 ///
	                `suspended' `ci' dist(`dist') `spike' `bar' ///
					withx(`withx') `ninteropt'                  ///   
					`horizontal' `vertical' `by'                ///
					`theoretical' `cioptopt' `theoroptopt' `mainoptopt' 
	
	// parse sample
	marksample touse
	markout `touse' `groupvar' `sims', strok	
	if "`dist'" == "theoretical" local parsesampleopt "groupvar(`groupvar')"
	if "`sims'" != "" local parsesampleopt "`parsesampleopt' sims(`sims')"
	hangr_parsesample `varlist', dist(`dist') touse(`touse') `parsesampleopt'
		
	if "`suspended'" != "" local minus "-"

	// prepare the histogram
	tempvar newobs
	qui gen byte `newobs' = 0
	
	tempvar h x theor floor t step
	if `withx' {
		tempvar xwx grden
		local xwxopt "xwx(`xwx')"
		local ninteropt "ninter(`ninter')"
		local grdenopt "grden(`grden')"
	}
	if "`dist'" != "theoretical" {
		if `"`sims'"' == "" {
			hangr_histgen `varlist' if `touse' `wght', ///
			gen(`h' `x') display `bin' `width' `start' `discrete'  ///
			`xwxopt' `ninteropt' `inflate'
		}
		else {
			forvalues i = 1/`: word count `sims'' {
				tempvar h`i'
				local hi `"`hi' `h`i''"'
			}
			hangr_histgensims `varlist' if `touse' `wght', sims(`sims') hi(`hi') ///
			gen(`h' `x') display `bin' `width' `start' `discrete' `xwxopt' `ninteropt' `inflate'
		}
		local w = r(width)
		local min = r(min)
		local max = r(max)
		local nobs = r(N)
		local nbins = r(bin)
	}
	
	// -hangr_<distname>- creates the theoretical distribution
	return clear
	if "`dist'" == "theoretical" {
		tempvar theorgr x2
		local theopts h(`h') x2(`x2') theorgr(`theorgr') ///
	    `bin' `width' `start' `discrete' groupvar(`groupvar')
	}
	if inlist("`dist'", "poisson", "geometric", "nb1", "nb2", "zip", "zinb") {
		tempvar theorgr
		local theorgropt "theorgr(`theorgr')"
	}
	local XXfitopt "xxfit(`XXfit') withx(`withx')"

	hangr_`dist' `varlist' if `touse' `wght',                           ///
		x(`x') nobs(`nobs') nbins(`nbins') w(`w') min(`min') max(`max') theor(`theor') ///
		`paropt' `suspended' `XXfitopt' `theopts' `xwxopt' `grdenopt' `theorgropt'
		
	local gr `"`r(gr)'"'	
	if "`dist'" == "theoretical" {
		local w = r(width)
		local min = r(min)
		local max = r(max)
		local nobs = r(N)
		local nbins = r(bin)
	} 
	
	// store paramters
	local a = r(a)
	local b = r(b)
	local c = r(c)
	local d = r(d)
	
	// hangr_hist_gen and hangr_theoretical create new observations when #bins>N
	qui replace `newobs' = 1 if `newobs' == .

	
	qui gen `floor' = `minus'(`theor' - sqrt(`h'*`nobs'*`w'))

	if "`ci'" != "" {
		// collect the necessary information for -hangr_ci- in options
		tempvar lb ub 
		local hangr_ciopts "dist(`dist') level(`level') nbins(`nbins') h(`h') w(`w') nobs(`nobs')"
		local hangr_ciopts "`hangr_ciopts' lb(`lb') ub(`ub') `suspended' `spike' `bar'  x(`x') `inflate'"
		if "`suspended'" != "" {
			tempvar xsusp
			local hangr_ciopts "`hangr_ciopts' xsusp(`xsusp') min(`min') max(`max')"
			if "`dist'" == "theoretical" {
				local hangr_ciopts "`hangr_ciopts' x2(`x2')"
			}
			else {
				local hangr_ciopts"`hangr_ciopts' newobs(`newobs')"
			}
		}
		else {
			local hangr_ciopts "`hangr_ciopts' theor(`theor')"
		}
		if "`ciopt'" != "" {
			local hangr_ciopts "`hangr_ciopts' ciopt(`ciopt')"
		}
		// compute confidence intervals and return the graphs in
		// s(cispike), s(cibar), or s(ciarea)
		hangr_ci , `hangr_ciopts'
		local cispike "`s(cispike)'"
		local cibar "`s(cibar)'"
		local ciarea "`s(ciarea)'"
	}
	
	// Create the graph command
	if `"`xtitle'"' == "" {
		local xtitle : variable label `varlist'
		if "`xtitle'" == "" {
			local xtitle "`varlist'"
		}
		local xtitle `"xtitle("`xtitle'")"'
	}

	if `"`ytitle'"' == "" {
		if "`theoretical'" != "" {
			local ytitle `"ytitle("sqrt(residuals)")"'
		}
		else{
			local ytitle `"ytitle("sqrt(frequency)")"'
		}
	}

	if `"`legend'"' == "" {
		if "`ci'" != "" {
			if "`suspended'" == "" {
				if "`sims'" == "" {
					if "`spike'" != "" {
						local legend `"legend(order(1 "`level'% Conf. Int."))"'
					}
					else {
						local legend `"legend(order(3 "`level'% Conf. Int."))"'
					}
				}
				else {
					if "`spike'" != "" {
						local legend `"legend(order(1 "`level'% Conf. Int." 2 "simulations"))"'
					}
					else {
						local legend `"legend(order(3 "`level'% Conf. Int." 4 "simulations"))"'
					}			
				}
			}
			else if "`sims'" == "" {
				if "`dist'" != "theoretical" {
					local legend `"legend(order(1 "`level'% Conf. Int." 3 "residual"))"'
				}
				else {
					local legend `"legend(order(1 "`level'% Conf. Int." 3 "residual" 4 "theoretical" "distribution"))"'
				}
			}
			else {
				if "`dist'" != "theoretical" {
					local legend `"legend(order(1 "`level'% Conf. Int." 3 "simulations"  `=`: word count `sims'' + 3' "residual"))"'
				}
				else {
					local legend `"legend(order(1 "`level'% Conf. Int." 3 "simulations"  `=`: word count `sims'' + 3' "residual" `=`: word count `sims'' + 4' "theoretical" "distribution"))"'
				}
			}
		}
		else {
			if "`sims'" == "" {
				local legend "legend(off)"
			}
			else {
				if "`spike'" != "" {
					local legend `"legend(order( `=`: word count `sims'' + 1' "observed" 1 "simulations"))"'
				}
				else {
					local legend `"legend(order(1 "observed" 4 "simulations" ))"'
				}
			}
		}
	}
	
	if "`bar'" != "" {
		local barw "barw(`w')"
	}
	
	if "`suspended'" != "" {
		tempvar zero
		gen byte `zero' = 0
		if "`spike'" != "" local lstyle "lstyle(p3)"
		local maingr r`spike'`bar' `zero' `floor' `x', `lstyle' `mainopt'
	}
	else {
		if "`spike'" != "" local lstyle "lstyle(p1)"
		local maingr r`spike'`bar' `theor' `floor' `x', `lstyle' `mainopt'
	}
	if "`theoretical'" == "" {
		local theordistgr `"`gr' lstyle(p1)"'
	}
	if "`sims'" != "" {
		if "`jitterseed'" != "" local jitterseed "jitterseed(`jitterseed')"
		if "`jittersims'" != "" local jittersims "jittersims(`jittersims')"
		tempvar xl xr
		hangr_sims, x(`x') w(`w') xl(`xl') xr(`xr') `suspended' ///
                    theor(`theor') hi(`hi') nobs(`nobs')        ///
					`jittersims' `jitterseed' `spike' `bar'
		local simgr`spike'`bar' `r(simgr`spike'`bar')'
	}	
	
	twoway `cispike'`ciarea'`simgrspike' || ///
	       `maingr' `barw' yline(0) `options' `ytitle' `xtitle' `legend' || ///
		   `theordistgr' `theoropt' || `cibar'`simgrbar' || `plot'

	
	// cleanup extra obs created by twoway__histrogram_gen2
	qui drop if `newobs'
	
	// return parameters
	if inlist("`dist'", "poisson", "exponential", "geometric", "chi2") {
		return scalar a = `a'
	}
	if inlist("`dist'", "normal", "beta", "pareto", "laplace", "uniform", ///
	                     "lognormal", "weibull", "gumbel", "invgamma") | ///
	   inlist("`dist'", "wald", "fisk", "gamma", "logistic", "nb1", "nb2", "zip" ) {
		return scalar a = `a'
		return scalar b = `b'
	}
	if inlist("`dist'", "dagum", "sm", "gev", "zinb", "zib", "oib")  {
		return scalar a = `a'
		return scalar b = `b'
		return scalar c = `c'
	}
	if inlist("`dist'", "gb2", "zoib")  {
		return scalar a = `a'
		return scalar b = `b'
		return scalar c = `c'
		return scalar d = `d'
	}
	return local dist "`dist'"

end
		
