*! version 0.1.0 12jul2012

/*
History
MJC 12jul2012: version 0.1.0
*/

program define metapowplot
	version 11.2
	syntax varlist(min=4 max=6 numeric), 												///
											START(integer) 								/// -min number of subjects in each group (d/h or pos/neg)-
											STOP(integer) 								/// -max number of subjects in each group (d/h or pos/neg)-
											STEP(integer)           					/// -step size used-
											TYPE(string) 								/// -type of study: clinical or diagnostic-
											NIT(real) 									/// -number of simulations-
											POW(numlist min=1 max=2) 					/// -value used to calculate power-
																						///
										[												///
											MEASure(string)               				/// -type of measure: (or/rr/rd/nostandard/d/ss)-
											INFerence(string) 							/// -level used to calculate power-
											P(real 0) 									/// -event rate in control group/prob being disease in positive group-
											R(real 1) 									/// -ratio of number of subjects in each group (default=1)-
											Studies(integer 1) 	                        ///	-number of new studies to be generated-
											MODel(string) 								/// -type of meta-analysis (default=fixed effect)-
											NPOW(numlist min=1 max=2) 					/// -value used to recalculate power-
											CI(real 95) 								/// -width of confidence interval for power estimate (default=95%)-
											DIST(string) 								/// -type of distribution: (normal/t)-
											IND       						    		/// -calculate power values for newly simulated study on its own-
											NIP(integer 2) 								/// -number of iteration points-
											SOS(string) 								/// -inference option for sens and spec to be used with ciwidth or lci-
											GRaph(string) 								/// -type of graph: (lowess/connect/overlay)-
											NOCI 										/// -don't want confidence intervals to be displayed on the graph-
											REGRAPH 									///
											Level(cilevel)								///
										]

	capture which metan 
	if _rc>0 {
		display in yellow "You need to install the command metan. This can be installed using,"
		display in yellow ". {stata ssc install metan}"
		exit 198
	}

	if "`type'"=="diagnostic" {
		capture which metandi 
		if _rc>0 {
			display in yellow "You need to install the command metandi. This can be installed using,"
			display in yellow ". {stata ssc install metandi}"
			exit 198
		}
		capture which midas 
		if _rc>0 {
			display in yellow "You need to install the command midas. This can be installed using,"
			display in yellow ". {stata ssc install midas}"
			exit 198
		}
	}
	   
	/*** Error messages ***/

	if "`npow'"!="" {
		di in green "It is the users responsibility to ensure that all options specified remain the same as when temppow2 was initially created"
	}

	tokenize `varlist'

	/*** Set up defaults ***/

	if "`graph'"=="" {
		local graph = "connect"
	}
	
	if "`model'" == "" & "`measure'"!="nostandard" {
		local model = "fixed"
	}

	if "`model'" == "" & "`measure'"=="nostandard" {
		local model = "fixedi"
	}



	if "`type'" == "clinical" {
		if  "`6'"=="" & "`measure'"=="" {
			local measure "rr"
		}
		else if "`6'"!="" & "`measure'"=="" {
			local measure "nostandard"
		}
	}

	if "`type'"=="diagnostic" {
		if "`measure'"=="" {  
			local measure "ss"
		}
	}

	if "`type'" == "diagnostic" & "`inference'"=="" {
		if "`measure'"=="ss" {
			local inference "ciwidth"
			local sos "sens"
		}
		if "`measure'"=="dor" {
			local inference "ciwidth"
		}	
	}

	if "`type'" == "clinical" & "`inference'" == "" {
		local inference = "ciwidth"
	}

	if "`type'"=="diagnostic" & "`inference'"=="" {
		if "`measure'"=="ss" {
			local inference "ciwidth"
			local sos "sens"
		}
		if "`measure'" == "dor" {
			local inference "ciwidth"
		}	
	}

	if "`type'"=="clinical" & "`inference'"=="" {
		local inference "ciwidth"
	}

	*** Check user hasn't specified options that don't exist ***
	if "`model'"!="fixed" & "`model'"!="fixedi" & "`model'"!="random" & "`model'"!="randomi" & "`model'"!="bivariate" {
		di as err "Unknown model specified"
		exit 198
	}

	if "`type'"!="clinical" & "`type'"!="diagnostic" {
		di as err "Unknown type specified"
		exit 198
	}

	if "`measure'"!="or" & "`measure'"!="rr" & "`measure'"!="rd" & "`measure'"!="nostandard" & "`measure'"!="dor" & "`measure'"!="ss" {
		di as err "Unknown measure specified"
		exit 198
	}


	/*** Preserve original data to use at the end. **/
	preserve
	tempfile orig_data
	qui save "`orig_data'"

if "`regraph'"=="" { 
  
	tempname samp3
	if "`ind'"!="" {
		postfile `samp3' t power lci uci nit indpower indlci induci using temppow3.dta, replace 
	}
	else {
		postfile `samp3' t power lci uci nit using temppow3.dta, replace 
	}
  
	di ""
	di as txt "Sample size" 
	di ""
  
	/*** Loop around minimum and maximum sample sizes ***/
	forvalues t = `start'(`step')`stop' {

		use "`orig_data'", clear

		*** Calculate n and m ***

		local n = round(`t'/(1+`r'))
		local m = round(`n'*`r')
		local newt = `n'+`m'

		/*** Call on metapow program ***/
		qui metapow `varlist', 	n(`n') type(`type') nit(`nit') pow(`pow') measure (`measure') inference(`inference')  		/// 
								p(`p') r(`r') studies(`studies') model(`model') npow(`npow') ci(`ci') dist(`dist') `ind'	///
								nip(`nip') sos(`sos')

		/*** Print sample size information to the results window. ***/
		if "`measure'"=="dor" {
			di in green "t = " %7.0g `newt'  "     Positive/Negative = `n'/`m'" 
			if "`t'"!="`newt'" di in yellow "Numbers in Positive/Negative have been rounded"
		}
		if "`measure'"=="ss" {
			di in green "t = " %7.0g `newt'  "     Diseased/Healthy = `n'/`m'" 
			if "`t'"!="`newt'" di in yellow "Numbers in Diseased/Healthy have been rounded"
		}
		if "`type'"=="clinical" {
			di in green "t = " %7.0g `newt'  "     Treatment/Control = `m'/`n'" 
			if "`t'"!="`newt'" di in yellow "Numbers in Treatment/Control have been rounded"
		}

		if "`ind'"!="" {
			post `samp3' (`t') ($pow) ($lci) ($uci) ($nit) ($indpow) ($indlci) ($induci)
		}
		else {
			post `samp3' (`t') ($pow) ($lci) ($uci) ($nit) 
		}
	}
	  
	di as txt ""
	di ""

	/*** Inform user if npow was used ***/
	if "`npow'" != ""{
		di in yellow "Level used to estimate power has changed"
		di in yellow "Simulated data has not changed"
		di ""
	}

	/*** Display the model used ***/
	if "`model'"=="fixed" {
		di as txt "Fixed effect Mantel-Haenszel model"
	}
	else if "`model'"=="fixedi" {
		di as txt "Fixed effect inverse variance-weighted model"
	}
	else if "`model'"=="peto" {
		display as txt "Peto model"
	}
	else if "`model'"=="random" {
		display as txt "Random effects model with Mantel-Haenszel estimates of heterogeneity"
	}
	else if "`model'"=="randomi" {
		display as txt "Random effects model with inverse variance-weighted estimates of heterogeneity"
	}
	else if "`model'"=="bivariate" {
		display as txt "Bivariate random effects meta-analysis"
	}					 


	/*** Display the measure used ***/
	if "`measure'"=="rr" {
		display as txt "Statistic used was relative risk"
	}
	else if "`measure'"=="or" {
		display as txt "Statistic used was odds ratio"
	}
	else if "`measure'"=="rd" {
		display as txt "Statistic used was risk difference"
	}
	else if "`measure'"=="nostandard" {
		display as txt "Statistic used was mean difference"
	}
	else if "`measure'"=="ss" {
		display as txt "Statistics used were sensitivity and specificity"
	}
	else if "`measure'"=="dor" {
		display as txt "Statistic used was diagnostic odds ratio"
	}
  
	*** Display the inference used ***
	if "`npow'"=="" {

		if "`inference'"=="ciwidth" {
			if "`sos'"=="" {
				display in green "Confidence interval width used to estimate power = " %4.2f as res `pow'
			}
			else {
				display in green "Confidence interval width for " "`sos'" " used to estimate power = " %4.2f as res `pow'
			}
		}

		if "`inference'"=="lci" {
			if "`sos'"=="" {
				display in green "Lower confidence interval value used to estimate power = " %4.2f as res `pow'
			}
			else {
				display in green "Lower confidence interval value for " "`sos'" " used to estimate power = " %4.2f as res `pow'
			}
		}

		if "`inference'"=="pvalue" {
			display in green "Level of significance used to estimate power = " %4.2f as res `pow'
		}

		if "`inference'"=="ssciwidth" {
			display in green "Confidence interval width for sensitivity used to estimate power = " %4.2f as res `minsens'
			display in green "Confidence interval width for specificity used to estimate power = " %4.2f as res `minspec'
		}

		if "`inference'"=="sslci" {
			display in green "Lower confidence interval value for sensitivity used to estimate power = " %4.2f as res `minsens'
			display in green "Lower confidence interval value for specificity used to estimate power = " %4.2f as res `minspec'
		}
		
	}
	else {

		if "`inference'"=="ciwidth" {
			if "`sos'"=="" {
				display in green "Confidence interval width used to estimate power = " %4.2f as res `npow'
			}
			else {
				display in green "Confidence interval width for " "`sos'" " used to estimate power = " %4.2f as res `npow'
			}
		}

		if "`inference'"=="lci" {
			if "`sos'"=="" {
				display in green "Lower confidence interval value used to estimate power = " %4.2f as res `npow'
			}
			else {
				display in green "Lower confidence interval value for " "`sos'" " used to estimate power = " %4.2f as res `npow'
			}
		}

		if "`inference'"=="pvalue" {
			display in green "Level of significance used to estimate power = " %4.2f as res `npow'
		}

		if "`inference'"=="ssciwidth" {
			display in green "Confidence interval width for sensitivity used to estimate power = " %4.2f as res `nminsens'
			display in green "Confidence interval width for specificity used to estimate power = " %4.2f as res `nminspec'
		}

		if "`inference'"=="sslci" {
			display in green "Lower confidence interval value for sensitivity used to estimate power = " %4.2f as res `nminsens'
			display in green "Lower confidence interval value for specificity used to estimate power = " %4.2f as res `nminspec'
		}
		
	}

	if "`model'"=="bivariate" {
		if $missing!="0" {
			dis in yellow "A total of $missing out of $ntotal iterations failed to converge using the bivariate random effects meta-analysis" ///
			_newline "for a sample size of `t'. The power calculation has been adjusted for this."
			dis in yellow "If a large proportion of iterations have failed it is recommended that the analysis is re-run using the metapowb" ///
			_newline "Stata command for power calculations in winbugs."
		} 
	}
 
	postclose `samp3' 
	
}
  
	use temppow3, clear 
  
  /*** Plot the graph ***/
	if "`noci'"=="" {

		if "`ind'"!="" {
		  
			if "`graph'" == "overlay" {

				twoway (scatter power t, color(blue) msymbol(o) msize(small))                  ///
					   (lowess power t, lpattern(solid) color(blue))                           ///
					   (scatter lci t, color(midblue*0.6) msymbol(o) msize(small))             ///
					   (lowess lci t, lpattern(dash) color(midblue*0.6))                       ///
					   (scatter uci t, color(midblue*0.6) msymbol(o) msize(small))                  ///
					   (lowess uci t, lpattern(dash) color(ltblue))                            ///
					   (scatter indpower t, color(cranberry) msymbol(s) msize(small))          ///
					   (lowess indpower t, lpattern(shortdash_dot) color(cranberry))           ///
					   (scatter indlci t, color(pink*0.8) msymbol(o) msize(small))             ///
					   (lowess indlci t, lpattern(dot) color(pink*0.8))                        ///
					   (scatter induci t, color(pink*0.8) msymbol(o) msize(small))          ///
					   (lowess induci t, lpattern(dot) color(magenta*0.6)),                    ///
					   title("Power curves")                                                   ///
					   subtitle( with `ci'% confidence intervals)                              ///
					   xtitle(Total Study Sample size) ytitle(Power)                                       ///
					   legend(order(2 "meta-analysis" 4 "CI meta-analysis" 8 "individual"      ///
					   10 "CI individual") cols(2)) ylabel(, angle(0)) name(power, replace)   
			}	
			else if "`graph'" == "lowess" || "`graph'" == "connect" {
				twoway (`graph' power t, color(blue) msymbol(o) msize(small) lpattern(solid))                 ///
					   (`graph' lci t, lpattern(dash) color(midblue*0.6) msymbol(o) msize(small))             ///           
					   (`graph' uci t, lpattern(dash) color(midblue*0.6) msymbol(o) msize(small))                  ///
					   (`graph' indpower t, color(cranberry) msymbol(o) msize(small) lpattern(shortdash_dot)) ///
					   (`graph' indlci t, lpattern(dot) color(pink*0.8) msymbol(o) msize(small))              ///           
					   (`graph' induci t, lpattern(dot) color(pink*0.8) msymbol(o) msize(small)),          ///
					   title("Power curves")                                                                  ///
					   xtitle(Total Study Sample size) subtitle( with `ci'% confidence intervals) ytitle(Power)           ///
					   legend(order(1 "meta-analysis" 2 "CI meta-analysis" 4 "individual"                     ///
					   5 "CI individual") cols(2)) ylabel(, angle(0)) name(power, replace) 
			}
		}

		if "`ind'"=="" {
			if "`graph'" == "overlay" {
				twoway (scatter power t, color(blue) msymbol(o) msize(small))                  ///
					   (lowess power t, lpattern(solid) color(blue))                           ///
					   (scatter lci t, color(midblue*0.6) msymbol(o) msize(small))             ///
					   (lowess lci t, lpattern(dash) color(midblue*0.6))                       ///
					   (scatter uci t, color(midblue*0.6) msymbol(o) msize(small))             ///
					   (lowess uci t, lpattern(dash) color(ltblue)),                           ///
					   title("Power curve")                                                    ///
					   subtitle( with `ci'% confidence intervals)                              ///
					   xtitle(Total Study Sample size) ytitle(Power)                           ///
					   legend(order(2 "meta-analysis" 4 "CI meta-analysis") cols(2))           ///
					   ylabel(, angle(0)) name(power, replace) 
			}	
			else if "`graph'" == "lowess" | "`graph'" == "connect" {
				twoway (`graph' power t, color(blue) msymbol(o) msize(small) lpattern(solid))                 		///
					   (`graph' lci t, lpattern(dash) color(midblue*0.6) msymbol(o) msize(small))            		///           
					   (`graph' uci t, lpattern(dash) color(midblue*0.6) msymbol(o) msize(small)),                 	///
					   title("Power curves")                                                                  		///
					   xtitle(Total Study Sample size) subtitle( with `ci'% confidence intervals) ytitle(Power)     ///
					   legend(order(1 "meta-analysis" 2 "CI meta-analysis") cols(2)) ylabel(, angle(0))       		///
					   name(power, replace) 
			}
		}
	}

	if "`noci'"!="" {
		if "`ind'"!="" {
			if "`graph'" == "overlay" {
				twoway 	(scatter power t, color(blue) msymbol(o) msize(small))                  ///
						(lowess power t, lpattern(solid) color(blue))                           ///
						(scatter indpower t, color(cranberry) msymbol(s) msize(small))          ///
						(lowess indpower t, lpattern(shortdash_dot) color(cranberry)),          ///
						title("Power curves")                                                   ///
						xtitle(Total Study Sample size) ytitle(Power)                           ///
						legend(order(2 "meta-analysis" 4 "individual") cols(2))                 ///
						ylabel(, angle(0)) name(power, replace)  
			}	
			else if "`graph'" == "lowess" || "`graph'" == "connect" {
				twoway 	(`graph' power t, color(blue) msymbol(o) msize(small) lpattern(solid))                  	///
						(`graph' indpower t, color(cranberry) msymbol(o) msize(small) lpattern(shortdash_dot)), 	///
						title("Power curves") xtitle(Total Study Sample size) ytitle(Power)                         ///
						legend(order(1 "meta-analysis" 2 "individual") cols(2)) ylabel(, angle(0))              	///
						name(power, replace) 
			}
		}
		else {
			if "`graph'" == "overlay" {
				twoway 	(scatter power t, color(blue) msymbol(o) msize(small))   			///
						(lowess power t, lpattern(solid) color(blue)),            			///
						title("Power curve") xtitle(Total Study Sample size) ytitle(Power)  ///
						legend(order(2 "meta-analysis") cols(2))                 			///
						ylabel(, angle(0)) name(power, replace) 
			}	
			else if "`graph'" == "lowess" | "`graph'" == "connect" {
				twoway (`graph' power t, color(blue) msymbol(o) msize(small) lpattern(solid)),          ///
				title("Power curves") xtitle(Total Study Sample size) ytitle(Power)                     ///
				legend(order(1 "meta-analysis") cols(2)) ylabel(, angle(0)) name(power, replace) 
			}
		}  
	}

	local dir `c(pwd)'
	display in green "Power estimates used to plot the graph are saved in file called `dir'\temppow3"

	/*** Label variables in temppow3 ***/
	quietly{
		use temppow3, clear
		label variable t "Total sample size of new study"
		label variable power "Power of updated meta-analysis"
		label variable lci "Lower CI value for power of updated meta-analysis"
		label variable uci "Upper CI value for power of updated meta-analysis"
		label variable nit "Number of iterations the power calculation is based on"

		if "`ind'"!="" {
			label variable indpower "Power of newly simulated study"
			label variable indlci "Lower CI value for power of newly simulated study"
			label variable induci "Upper CI value for power of newly simulated study"  
		}
		
		save temppow3, replace
	}

	restore

end
