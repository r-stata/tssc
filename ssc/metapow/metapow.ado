*! version 0.1.0 18jul2012

/*
History
MJC 18jul2012 version 0.1.1 1.96 changed to invnorm calculation based on level()
MJC 12jul2012 version 0.1.0 
*/

program define metapow
	version 11.2
	syntax varlist(min=4 max=6 numeric), 											///
											N(integer) 								/// -number of subjects in group 1 -
											NIT(integer) 							/// -number of simulations-
											TYpe(string)							/// -type of study: clinical or diagnostic-
											POW(numlist min=1 max=2)				/// -value used to calculate power-
																					///
										[											///
											MEASure(string) 						/// -type of measure: (or/rr/rd/nostandard/dor/ss)-
											INFerence(string) 						/// -level used to calculate power-
											P(real 0)  								/// -event rate in control group/prob being disease in positive group-
											R(real 1) 								/// -ratio of number of subjects in each group (default=1)-
											STudies(integer 1) 						/// -number of new studies to be generated-
											MODel(string) 							/// -type of meta-analysis (default=fixed effect)-
											NPOW(numlist min=1 max=2)   			/// -value used to recalculate power-
											CI(real 95) 							/// -width of confidence interval for power estimate (default=95%)-
											DIST(string) 							/// -type of distribution: (normal/t)-
											IND 									/// -calculate power values for newly simulated study on its own-
											NIP(integer 2) 							/// -number of iteration points-
											SOS(string) 							/// -inference option for sens and spec to be used with ciwidth or lci-
											LEVEL(real 95)							///
										]
	
	local siglev = abs(invnormal((100-`level')/200))
	
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

	// Set defaults 
	if "`model'"=="" & "`measure'"!="nostandard" {
		local model "fixed"
	}

	if "`model'"=="" & "`measure'"=="nostandard" {
		local model "fixedi"
	}

	if "`dist'"=="" & ("`model'"=="random" | "`model'"=="randomi") {
		local dist "t"
	}

	if "`dist'"=="" & ("`model'"=="fixed" | "`model'"=="fixedi" | "`model'"=="peto" | "`model'"=="bivariate") {
		local dist "normal"
	}	

	// Check user hasn't specified options that don't exist
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

	// 	Count number of estimates specified in numlist variables to
	//	determine if using sensitivity and specificity.

	local npo : word count `pow'
	if `npo' > 1 { 
		tokenize `pow'
		local minsens = `1'
		local minspec = `2'
		global minsens = `minsens'
		global minspec = `minspec'
	}
	else {
		local minsens = `pow'
		local minspec = `pow'
	}

	if "`measure'"!="ss" & `npo'>1 {
		di as err "Can only specify more than one value to calculate power when using sensitivity and specificity"
		exit 198
	}

	if "`sos'"!="" & `npo'>1 {
		di as err "Only need to specify one value for pow when using the sos option"
		exit 198
	}

	if "`npow'"!="" {
		local nnpo : word count `npow'
		if `nnpo' > 1 { 
			tokenize `npow'
			local nminsens = `1'
			local nminspec = `2'
			global nminsens = `nminsens'
			global nminspec = `nminspec'
		}
		else {
			local nminsens = `npow'
			local nminspec = `npow'
		}

		if "`measure'"!="ss" & `npo'>1 {
			di as err "Can only specify more than one value to calculate power when using sensitivity and specificity"
			exit 198
		} 

		if "`sos'"!="" & `nnpo'>1 {
			di as err "Only need to specify one value for pow when using the sos option"
			exit 198
		}
	}

	*** Error messages ***

	if "`ind'"!="" & "`inference'"=="pvalue" {
		di as err "Can not calculate power value for individual study based on p-value"
		exit 198
	}

	if "`type'"=="diagnostic" & "`inference'"=="pvalue" {
		di as err "Can not calculate power value for diagnostic studies based on p-value"
		exit 198
	}

	if "`measure'"!="ss" & ("`inference'"=="sslci" | "`inference'"=="ssciwidth") {
		di as err "Can only specify these measures of inference when using sensitivity and specificity"
		exit 198
	}

	if "`dist'"=="t" & ("`model'"=="fixed" | "`model'"=="fixedi" | "`model'"=="peto" | "`model'"=="bivariate") {
		di as err "Can only use the t-distribution to sample a new study when using the random or randomi models"
		exit 198
	}

	local number=_N
	if "`dist'"=="t" & `number'<3 {
		di as err "Can only use the t-distribution when there are 3 or more studies in the current dataset"
		exit 198
	}

	if "`type'"=="diagnostic" & "`inference'"=="uci" {
		di as err "Can only use the upper confidence interval value to estimate power with clinical studies"
		exit 198
	}

	if "`model'"=="peto" & ("`measure'"=="rr" || "`measure'"=="rd" || "`measure'"=="nostandard" || "`measure'"=="ss") {
		di as err "The Peto method can only be used with OR or DOR"
		exit 198
	}

	if "`model'"=="bivariate" & "`measure'"!="ss" {
		di as err "Can only use the bivariate random effects model with sensitivity and specificity"
		exit 198
	}

	global ntotal=`nit'

	tokenize `varlist'

	if "`type'" == "clinical" {
		if  "`6'"=="" & "`measure'" == "" {
			local measure = "rr"
		}
		else if "`6'"!="" & "`measure'" == "" {
			local measure = "nostandard"
		}
	}
	 
	if "`type'" == "diagnostic" {
		if "`measure'" == "" {  
			local measure = "ss"
		}
	}

	if "`type'" == "diagnostic" & "`inference'" == "" {
		if "`measure'" == "ss" {
			local inference = "ciwidth"
			local sos = "sens"
		}
		if "`measure'" == "dor" {
			local inference = "ciwidth"
		}	
	}

	if "`type'" == "clinical" & "`inference'" == "" {
		local inference = "ciwidth"
	}

	if "`6'"!="" & "`measure'"!= "nostandard" {
		di as err "Can only input 6 values when using nostandard as measure"
		exit 198
	}

	*** Use the existing data to calculate p. ***
	*** Add 0.5 to any studies with a zero.    ***

	if "`type'" == "clinical" {
		if "`p'" == "0" & "`6'" == ""{
			tempvar h t p1
			gen `h'=`3'
			gen `t'=`3'+`4'
			qui replace `t' = `t' + 1 if `h'==0 
			qui recode `h' 0=0.5
			gen `p1' = `h' / `t'
			qui sum `p1',meanonly
			local p = `r(mean)'
			global p = `p'
		}
	}

	if "`type'" == "diagnostic" {
		if "`p'" == "0" {
			tempvar h t p1
			gen `h'=`1'
			gen `t'=`1'+`2'
			qui replace `t' = `t' + 1 if `h'==0 
			qui recode `h' 0=0.5
			gen `p1' = `h' / `t'
			qui sum `p1',meanonly
			local p = `r(mean)'
			global p = `p'
		}
	}

quietly {

	*** Preserve original data to be restored at the end of the program. ***

	preserve
	tempfile orig_data
	save "`orig_data'"

	if "`type'" == "clinical" {

		*** If re-estimating power with different level, do not re-run simulations. ***

		if "`npow'"=="" {

			*** tempname assigns the name samp2 to a local macro               ***
			*** postfile declares the filename of a new Stata dataset          ***

			tempname samp2

			postfile `samp2' es se_es ciw lci uci pval indes indse_es indciw indlci induci using temppow2, replace

			*** Using the dataset defined in the program call, run a meta-analysis ***
			*** on the existing data						                         ***

			metan `varlist', `measure' `model' nograph nointeger ilevel(`level') olevel(`level')

			*** Create a local macros for effect size and standard error of ES     ***

			if "`measure'" != "or" & "`measure'" != "rr" {
				local maines		=	$S_1     			//r(ES)
				local mainse_es		=	$S_2   				//r(seES)
				local mainvar		=	`mainse_es'*`mainse_es'
			}
			else if "`measure'" == "or" | "`measure'" == "rr"  {
				local maines		=	log($S_1)   		//ln(r(ES))
				local mainse_es		=	$S_2     			//r(selogES)
				local mainvar		=	`mainse_es'*`mainse_es'
			}

			*** Include extra variability if using random effect model ***

			if "`model'" == "random" | "`model'" == "randomi" {
				local maintausq=$S_12 
			}
			else{
				local maintausq=0
			}

			*** Call on metasim program. ***

			forvalues i=1/`nit' {	

				metasim `varlist', n(`n') es(`maines') var(`mainvar') type(`type') measure(`measure') ///
				p(`p') r(`r') studies(`studies') model(`model') tausq(`maintausq')   ///
				dist(`dist') 

				use temppow,clear

				*** Add a continuity correction to simulated data set if any values are 0. ***	
				gen zeros=0
				replace zeros=1 if (`1'==0 | `2'==0 | `3'==0 | `4'==0 )
				replace `1' = `1' + 0.5 if zeros==1
				replace `2' = `2' + 0.5 if zeros==1
				replace `3' = `3' + 0.5 if zeros==1
				replace `4' = `4' + 0.5 if zeros==1				

				if "`measure'"=="or" {
					gen or = (`1'*`4')/(`2'*`3')
					gen logor=log(or)
					gen logseor=sqrt((1/`1')+(1/`2')+(1/`3')+(1/`4'))
					gen loglci=logor-(`siglev'*logseor)
					gen loguci=logor+(`siglev'*logseor)
					gen lci=exp(loglci)
					gen uci=exp(loguci)

					local indes=or
					local indse_es=logseor
					local indciw=uci-lci
					local indlci=lci
					local induci=uci 		  
				}

				if "`measure'"=="rr" {
					gen rr=(`1'/(`1'+`2'))/(`3'/(`3'+`4'))
					gen logrr=log(rr)
					gen logserr=sqrt((1/`1')-(1/(`1'+`2'))+(1/`3')-(1/(`3'+`4')))
					gen loglci=logrr-(`siglev'*logserr)
					gen loguci=logrr+(`siglev'*logserr)
					gen lci=exp(loglci)
					gen uci=exp(loguci)

					local indes=rr
					local indse_es=logserr
					local indciw=uci-lci
					local indlci=lci
					local induci=uci 		  
				}

				if "`measure'"=="rd" | "`measure'"=="nostandard" {

					metan `varlist', `measure' `model' nograph nointeger ilevel(`level') olevel(`level')

					*** Calculate values for new study on its own. ***		  

					local indes=r(ES)
					local indse_es=r(seES)
					local indciw = ($S_4)-($S_3)
					local indlci = ($S_3)
					local induci = ($S_4)			
				}

				** 	Append the existing data. ***
				*** Rerun the meta-analysis on all the data ***

				//use temppow, clear
				append using "`orig_data'"		

				metan `varlist', `measure' `model' nograph nointeger ilevel(`level') olevel(`level')

				local es=`r(ES)'
				local se_es=$S_2
				local ciw =($S_4)-($S_3)  /* r(ci_upp) - r(ci_low) */	
				local lci = ($S_3) 
				local uci = ($S_4)
				local pval = ($S_6)

				post `samp2' (`es') (`se_es') (`ciw') (`lci') (`uci') (`pval') (`indes') (`indse_es') (`indciw') (`indlci') (`induci')
				noisily di "." _continue
			}
			postclose `samp2'
			
			//Load simulation results at specified sample size
			use temppow2, clear

			if "`inference'" == "pvalue" {
				*** Calculate power of updated meta-analysis including new study. ***
				count if pval<`pow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100
			}

			if "`inference'" == "ciwidth" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if ciw<`pow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***	  
				if "`ind'"!=""{
					count if indciw<`pow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}	  
			}

			if "`inference'" == "lci" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if lci>`pow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if indlci>`pow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}  
			}

			if "`inference'" == "uci" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if uci<`pow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if induci<`pow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}  
			}
		}

		*** If changing level used to calculate power, re-estimate power ***
		else {
			di in green "It is the users responsibility to ensure that all options specified remain the same as when temppow2 was initially created"
			use temppow2, clear

			if "`inference'" == "pvalue" {
				*** Calculate power of updated meta-analysis including new study. ***
				count if pval<`npow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if indpval<`npow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100	  
				}
			}

			if "`inference'" == "ciwidth" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if ciw<`npow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if indciw<`npow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}
			}

			if "`inference'" == "lci" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if lci>`npow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if indlci>`npow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}
			}

			if "`inference'" == "uci" {
				*** Calculate power of updated meta-analysis including new study. ***	
				count if uci<`npow'
				local power=100*r(N)/`nit'
				global rn=r(N)

				cii `nit' r(N), level(`ci')

				global pow=`power'
				global lci=r(lb)*100
				global uci=r(ub)*100

				*** Calculate power of newly simulated study. ***
				if "`ind'"!=""{
					count if induci<`npow'
					local indpower=100*r(N)/`nit'
					global indrn=r(N)

					cii `nit' r(N), level(`ci')

					global indpow=`indpower'
					global indlci=r(lb)*100
					global induci=r(ub)*100
				}  
			}
		}
	}

	if "`type'" == "diagnostic" {

		if "`measure'"=="ss" {

			if "`npow'"=="" {

				*** Tempname assigns the name "samp2" to the specified local macro.   ***
				*** Postfile declares the filename of a new Stata dataset "temppow2". *** 
				*** "Samp2" will contain estimates, confidence interval widths and    ***
				*** lower confidence interval values from each simulation.            ***

				tempname samp2

				postfile `samp2' sens spec ciw_sens ciw_spec lci_sens lci_spec uci_sens uci_spec  /// 
				indsens indspec indse_logsens indse_logspec indciw_sens indciw_spec indlci_sens indlci_spec induci_sens induci_spec using temppow2, replace

				*** Create local macros depending on type of model(fixed/random/bivariate). ***

				if "`model'"=="fixed" | "`model'"=="random" | "`model'"=="fixedi" | "`model'"=="randomi" {

					*** Use data to calculate logit(sens) and logit(spec) and their confidence intervals. ***

					gen logsens = logit(`1'/(`1'+`3'))
					gen logspec = logit(`4'/(`2'+`4'))

					gen se_logsens = sqrt((1/`1')+(1/`3'))
					gen se_logspec = sqrt((1/`2')+(1/`4'))

					gen lci_logsens=logsens-(`siglev'*se_logsens)
					gen uci_logsens=logsens+(`siglev'*se_logsens)

					gen lci_logspec=logspec-(`siglev'*se_logspec)
					gen uci_logspec=logspec+(`siglev'*se_logspec)

					local corr = "0"

					*** Meta-analysis of logit(sens). ***

					metan logsens lci_logsens uci_logsens, `model' nograph nointeger ilevel(`level') olevel(`level')

					*** Store estimates from meta-analysis. ***

					local es_sens=$S_1   /*r(ES)*/
					local se_sens=$S_2   /*r(seES)*/
					local var_sens=`se_sens'^2

					if "`model'"=="random" {
						local tausq_sens=$S_12  /* est of between study var - D&L */
					}
					else {
						local tausq_sens=0
					}

					*** Meta-analysis of logit(spec). ***

					metan logspec lci_logspec uci_logspec, `model' nograph nointeger ilevel(`level') olevel(`level')

					*** Store estimates from meta-analysis. ***

					local es_spec=$S_1    /*r(ES)*/
					local se_spec=$S_2   /*r(seES)*/
					local var_spec=`se_spec'^2

					if "`model'"=="random"  {
						local tausq_spec=$S_12  /* est of between study var - D&L */
					}
					else {
						local tausq_spec=0
					}
				}  
				else if "`model'"=="bivariate" {

					*** Bivariate random effects meta-analysis. ***

					cap metandi `varlist', nolog nohsroc nosummarypt force xtmelogit nip(`nip') level(`level')
					*** Store estimates from meta-analysis. ***
					if _rc==0 {
						local es_sens = _b[muA]
						local es_spec = _b[muB]

						local tausq_sens = _b[s2A]
						local tausq_spec = _b[s2B]

						matrix v=e(V)
						local var_sens = v[1,1]
						local var_spec = v[2,2]			 

						scalar corr = ((_b[sAB])/(sqrt((_b[s2A])*(_b[s2B]))))
						local corr = corr
					}

					if _rc!=0 {

						cap metandi `varlist', nolog nohsroc nosummarypt force gllamm nip(`nip') level(`level')
						if _rc==0 {
							local es_sens = _b[muA]
							local es_spec = _b[muB]

							local tausq_sens = _b[s2A]
							local tausq_spec = _b[s2B]

							matrix v=e(V)
							local var_sens = v[1,1]
							local var_spec = v[2,2]			 

							scalar corr = ((_b[sAB])/(sqrt((_b[s2A])*(_b[s2B]))))
							local corr = corr
						}
						else {

							capture gen tp=`1'
							capture gen fp=`2'
							capture gen fn=`3'
							capture gen tn=`4'

							midas tp fp fn tn, res(all) nip(`nip') level(`level')

							local es_sens=logit(r(mtpr))
							local es_spec=logit(r(mtnr))
							local se_sens= ((logit(r(mtprlo))-logit(r(mtpr)))/(-`siglev'))
							local se_spec= ((logit(r(mtnrlo))-logit(r(mtnr)))/(-`siglev'))
							local var_sens=`se_sens'^2
							local var_spec=`se_spec'^2
							local tausq_sens=r(reffs2)
							local tausq_spec=r(reffs1)
							local corr = r(rho)
						}
					}
				}

				*** Loop around the number of specified iterations. ***

				forvalues i=1/`nit' {

					*** Call on metasim program. ***

					metasim `varlist', n(`n') es(`es_sens' `es_spec') var(`var_sens' `var_spec') type(`type') measure(`measure') ///
						p(`p') r(`r') studies(`studies') model(`model') tausq(`tausq_sens' `tausq_spec')   ///
						dist(`dist') corr(`corr')		 

					use temppow,clear

					*** Add a continuity correction to simulated data set if any values are 0. ***	
					gen zeros=0
					replace zeros=1 if (`1'==0 | `2'==0 | `3'==0 | `4'==0 )
					replace `1' = `1' + 0.5 if zeros==1
					replace `2' = `2' + 0.5 if zeros==1
					replace `3' = `3' + 0.5 if zeros==1
					replace `4' = `4' + 0.5 if zeros==1				

					*** Calculate sens and spec for new study on its own. ***

					gen sens=`1'/(`1'+`3')
					gen se_sens=sqrt((sens*(1-sens))/(`1'+`3'))
					gen spec=`4'/(`2'+`4')
					gen se_spec=sqrt((spec*(1-spec))/(`2'+`4'))
					gen lci_sens=sens-(`siglev'*se_sens)
					gen lci_spec=spec-(`siglev'*se_spec)
					gen uci_sens=sens+(`siglev'*se_sens)
					gen uci_spec=spec+(`siglev'*se_spec)
					gen ciw_sens=uci_sens-lci_sens
					gen ciw_spec=uci_spec-lci_spec
					gen se_logsens = sqrt((1/`1')+(1/`3'))
					gen se_logspec = sqrt((1/`2')+(1/`4'))

					*** Store results of new study in local macros. ***

					local indsens=sens
					local indspec=spec
					local indse_logsens=se_logsens
					local indse_logspec=se_logspec
					local indlci_sens=lci_sens
					local indlci_spec=lci_spec
					local induci_sens=uci_sens
					local induci_spec=uci_spec
					local indciw_sens=ciw_sens
					local indciw_spec=ciw_spec
					
					cap drop sens se_sens spec se_spec lci_sen lci_spec uci_sens uci_spec ciw_sens ciw_spec se_logsens se_logspec
					
					*** Add new study to original data. ***

					//use temppow, clear
					append using "`orig_data'"

					tokenize `varlist'

					if "`model'"=="fixed" | "`model'"=="random" | "`model'"=="fixedi" | "`model'"=="randomi" {

						gen logsens = logit(`1'/(`1'+`3'))
						gen logspec = logit(`4'/(`2'+`4'))

						gen se_logsens = sqrt((1/`1')+(1/`3'))
						gen se_logspec = sqrt((1/`2')+(1/`4'))

						gen lci_logsens=logsens-(`siglev'*se_logsens)
						gen uci_logsens=logsens+(`siglev'*se_logsens)

						gen lci_logspec=logspec-(`siglev'*se_logspec)
						gen uci_logspec=logspec+(`siglev'*se_logspec)

						*** Meta-analysis of logit(sens) including new study. ***

						metan logsens lci_logsens uci_logsens, `model' nograph nointeger ilevel(`level') olevel(`level') 

						*** Store results in local macros. ***
						local sens = invlogit($S_1)  /* r(ES) */
						local ciw_sens = (invlogit($S_4))-(invlogit($S_3))  /* r(ci_upp) - r(ci_low) */
						local lci_sens = invlogit($S_3)
						local uci_sens = invlogit($S_4)

						*** Meta-analysis of logit(spec) including new study. ***

						metan logspec lci_logspec uci_logspec, `model' nograph nointeger ilevel(`level') olevel(`level')

						*** Store results in local macros. ***
						local spec = invlogit($S_1)  /* r(ES) */
						local ciw_spec =(invlogit($S_4))-(invlogit($S_3)) /* r(ci_upp) - r(ci_low) */
						local lci_spec = invlogit($S_3)
						local uci_spec = invlogit($S_4)

						*** Post results to samp2. ***

						post `samp2' (`sens') (`spec') (`ciw_sens') (`ciw_spec') (`lci_sens') (`lci_spec') (`uci_sens') (`uci_spec')  /// 
						(`indsens') (`indspec') (`indse_logsens') (`indse_logspec') (`indciw_sens') (`indciw_spec') (`indlci_sens') (`indlci_spec') (`induci_sens') (`induci_spec')

						noisily di "." _continue
					}

					if "`model'"=="bivariate" {

						*** Bivariate random effects meta-analysis including new study. ***
						capture: metandi `varlist', nolog nohsroc nosummarypt nip(`nip') level(`level')

						*** Store the results in local macros if no errors are found in metandi command. ***

						if _rc==0 {

							local sens = invlogit(_b[muA])
							local spec = invlogit(_b[muB])		  

							matrix v=e(V)
							scalar se_logsens = sqrt(v[1,1])
							scalar se_logspec = sqrt(v[2,2])

							gen lci_sens=invlogit(_b[muA]-(`siglev'*se_logsens))
							gen uci_sens=invlogit(_b[muA]+(`siglev'*se_logsens))
							gen lci_spec=invlogit(_b[muB]-(`siglev'*se_logspec))
							gen uci_spec=invlogit(_b[muB]+(`siglev'*se_logspec))

							local ciw_sens = uci_sens - lci_sens 	  
							local ciw_spec = uci_spec - lci_spec

							local lci_sens=lci_sens
							local lci_spec=lci_spec

							local uci_sens=uci_sens
							local uci_spec=uci_spec
						}

						*** Store the missing values in local macros if errors are found in metandi command. ***
						else {
						
							cap metandi `varlist', nolog nohsroc nosummarypt gllam nip(`nip') level(`level')

							if _rc==0 {
								local sens = invlogit(_b[muA])
								local spec = invlogit(_b[muB])		  

								matrix v=e(V)
								scalar se_logsens = sqrt(v[1,1])
								scalar se_logspec = sqrt(v[2,2])

								gen lci_sens=invlogit(_b[muA]-(`siglev'*se_logsens))
								gen uci_sens=invlogit(_b[muA]+(`siglev'*se_logsens))
								gen lci_spec=invlogit(_b[muB]-(`siglev'*se_logspec))
								gen uci_spec=invlogit(_b[muB]+(`siglev'*se_logspec))

								local ciw_sens = uci_sens - lci_sens 	  
								local ciw_spec = uci_spec - lci_spec

								local lci_sens=lci_sens
								local lci_spec=lci_spec

								local uci_sens=uci_sens
								local uci_spec=uci_spec
							}
							else {

								capture gen tp=`1'
								capture gen fp=`2'
								capture gen fn=`3'
								capture gen tn=`4'

								cap  midas tp fp fn tn, res(all) nip(`nip') level(`level')

								if _rc==0 {
								local sens=invlogit(r(mtpr))
								local spec=invlogit(r(mtnr))

								local ciw_sens=r(mtprhi)-r(mtprlo)
								local ciw_spec=r(mtnrhi)-r(mtnrlo)

								local lci_sens=r(mtprlo)
								local lci_spec=r(mtnrlo)

								local uci_sens=r(mtprhi)
								local uci_spec=r(mtnrhi)
								}
								else {
									local sens = .
									local spec = .
									local ciw_sens = .  
									local ciw_spec = .		  
									local lci_sens = .
									local lci_spec = .
									local uci_sens = .
									local uci_spec = .
								}
							}
						}

						*** Post results to samp2. ***

						post `samp2' (`sens') (`spec') (`ciw_sens') (`ciw_spec') (`lci_sens') (`lci_spec') (`uci_sens') (`uci_spec') /// 
						(`indsens') (`indspec') (`indse_logsens') (`indse_logspec') (`indciw_sens') (`indciw_spec') (`indlci_sens') (`indlci_spec') (`induci_sens') (`induci_spec')
						noisily di "." _continue				
					}
				
				}
				//sims done
				postclose `samp2'
				
				//==========================================================================================//
				// Power calcs.
				use temppow2, clear

				if "`model'"=="bivariate" {
					su sens
					global missing=-r(N)+$ntotal
					local nit=r(N)
				}	  

				*** Calculate power depending on approach to inference. ***

				if "`inference'"=="ciwidth" {

					if "`sos'"=="" {

						*** Calculate power for updated meta-analysis including new study. ***  
						count if ciw_sens<`minsens' & ciw_spec<`minspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indciw_sens<`minsens' & indciw_spec<`minspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 	  
					}

					if "`sos'"=="sens" {	  
						*** Calculate power for updated meta-analysis including new study. ***  
						count if ciw_sens<`minsens' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indciw_sens<`minsens' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	

					if "`sos'"=="spec" {	  
						*** Calculate power for updated meta-analysis including new study. ***	  
						count if ciw_spec<`minspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indciw_spec<`minspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	
				}

				if "`inference'"=="lci" {

					if "`sos'"=="" {
						*** Calculate power for updated meta-analysis including new study. ***  
						count if lci_sens>`minsens' & lci_spec>`minspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_sens>`minsens' & lci_spec>`minspec'
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}

					if "`sos'"=="sens" {	  
						*** Calculate power for updated meta-analysis including new study. ***  
						count if lci_sens>`minsens' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_sens>`minsens' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	

					if "`sos'"=="spec" {	  
						*** Calculate power for updated meta-analysis including new study. ***	  
						count if lci_spec>`minspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_spec>`minspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	
				}

			}

			*** If power value is being changed then re-calculate power. ***

			else if "`npow'"!="" {
				use temppow2, clear

				if "`inference'"=="ciwidth" {

					if "`sos'"=="" {

						*** Calculate power for updated meta-analysis including new study. ***  
						count if ciw_sens<`nminsens' & ciw_spec<`nminspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
						*** Calculate power for newly simulated study. ***
							count if indciw_sens<`nminsens' & indciw_spec<`nminspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 	  
					}

					if "`sos'"=="sens" {	  
						*** Calculate power for updated meta-analysis including new study. ***  
						count if ciw_sens<`nminsens' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indciw_sens<`nminsens' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	

					if "`sos'"=="spec" {	  
						*** Calculate power for updated meta-analysis including new study. ***	  
						count if ciw_spec<`nminspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indciw_spec<`nminspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	
				}

				if "`inference'"=="lci" {

					if "`sos'"=="" {
						*** Calculate power for updated meta-analysis including new study. ***  
						count if lci_sens>`nminsens' & lci_spec>`nminspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_sens>`nminsens' & lci_spec>`nminspec'
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}

					if "`sos'"=="sens" {	  
						*** Calculate power for updated meta-analysis including new study. ***  
						count if lci_sens>`nminsens' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_sens>`nminsens' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	

					if "`sos'"=="spec" {	  
						*** Calculate power for updated meta-analysis including new study. ***	  
						count if lci_spec>`nminspec' 
						local power=100*r(N)/`nit'
						global rn=r(N)

						cii `nit' r(N), level(`ci')

						global pow=`power'
						global lci=r(lb)*100
						global uci=r(ub)*100

						if "`ind'"!="" {
							*** Calculate power for newly simulated study. ***
							count if indlci_spec>`nminspec' 
							local indpower=100*r(N)/`nit'
							global indrn=r(N)

							cii `nit' r(N), level(`ci')

							global indpow=`indpower'
							global indlci=r(lb)*100
							global induci=r(ub)*100
						} 
					}	
				}

			}
		
		}

		*** Create macros for DOR methods. ***

		if "`measure'"=="dor" {

			if "`npow'"=="" {

				*** Tempname assigns the name "samp2" to the specified local macro.   ***
				*** Postfile declares the filename of a new Stata dataset "temppow2". *** 
				*** "Samp2" will contain estimates, confidence interval widths and    ***
				*** lower confidence interval values from each simulation.            ***

				tempname samp2

				postfile `samp2' es se_es ciw lci uci indes indse_es indciw indlci induci using temppow2, replace

				*** Meta-analysis of log(DOR). ***

				metan `varlist', or `model' nograph nointeger ilevel(`level') ilevel(`level')

				*** Store estimates from meta-analysis. ***

				local maines=log($S_1)    /*r(ES)*/
				local mainse_es=($S_2)   /*r(seES)*/
				local mainvar=`mainse_es'*`mainse_es'

				if "`model'"=="random" {
					local maintausq=$S_12  /* est of between study var - D&L */
				}
				else{
					local maintausq=0
				}

				*** Loop around specified number of iterations. ***

				forvalues i=1/`nit' {

					*** Call on metasim program. ***

					metasim `varlist', n(`n') es(`maines') var(`mainvar') type(`type') measure(`measure') p(`p') ///  
					r(`r') studies(`studies') model(`model') tausq(`maintausq') dist(`dist') 


					use temppow,clear

					metan `varlist', or `model' nograph nointeger ilevel(`level') olevel(`level')

					*** Store results in local macros. ***

					local indes=r(ES)
					local indse_es=($S_2)
					local indlci=($S_3)
					local induci=($S_4)
					local indciw=($S_4)-($S_3)


					*** Add new study to original data. ***

					use temppow, clear
					append using "`orig_data'"

					tokenize `varlist', parse(" ")

					*** Meta-analysis of log(DOR) including new study. ***		

					metan `varlist', or `model' nograph nointeger ilevel(`level') olevel(`level')

					*** Store results from meta-analysis. ***

					local es=r(ES)
					local se_es=($S_2)
					local ciw =($S_4)-($S_3)  /* r(ci_upp) - r(ci_low) */	
					local lci = ($S_3) 
					local uci = ($S_4)

					*** Post results to samp2. ***

					post `samp2' (`es') (`se_es') (`ciw') (`lci') (`uci') (`indes') (`indse_es') (`indciw') (`indlci') (`induci') 

					noisily di "." _continue
				}
				//sims done, power stuff now
				postclose `samp2'
				
				use temppow2, clear

				*** Calculate power depending on approach to inference. ***

				if "`inference'"=="ciwidth" {

					*** Calculate power of updated meta-analysis including new study. ***

					count if ciw<`pow'
					local power=100*r(N)/`nit'
					global rn=r(N)

					cii `nit' r(N), level(`ci')

					global pow=`power'
					global lci=r(lb)*100
					global uci=r(ub)*100

					*** Calculate power of newly simulated study. ***
					if "`ind'"!="" {
						count if indciw<`pow'
						local indpower=100*r(N)/`nit'
						global indrn=r(N)

						cii `nit' r(N), level(`ci')

						global indpow=`indpower'
						global indlci=r(lb)*100
						global induci=r(ub)*100
					}
				}

				if "`inference'"=="lci" {

					*** Calculate power of updated meta-analysis including new study. ***

					count if lci>=`pow'
					local power=100*r(N)/`nit'
					global rn=r(N)

					cii `nit' r(N), level(`ci')

					global pow=`power'
					global lci=r(lb)*100
					global uci=r(ub)*100

					*** Calculate power of newly simulated study. ***
					if "`ind'"!="" {
						count if indlci>=`pow'
						local indpower=100*r(N)/`nit'
						global indrn=r(N)

						cii `nit' r(N), level(`ci')

						global indpow=`indpower'
						global indlci=r(lb)*100
						global induci=r(ub)*100
					}
				}		
			}
			else if "`npow'"!="" {
			
				di in green "It is the users responsibility to ensure that all options specified remain the same as when temppow2 was initially created"
				use temppow2, clear

				if "`inference'"=="ciwidth" {

					*** Calculate power of updated meta-analysis including new study. ***

					count if ciw<`npow'
					local power=100*r(N)/`nit'
					global rn=r(N)

					cii `nit' r(N), level(`ci')

					global pow=`power'
					global lci=r(lb)*100
					global uci=r(ub)*100

					*** Calculate power of newly simulated study. ***
					if "`ind'"!="" {
						count if indciw<`npow'
						local indpower=100*r(N)/`nit'
						global indrn=r(N)

						cii `nit' r(N), level(`ci')

						global indpow=`indpower'
						global indlci=r(lb)*100
						global induci=r(ub)*100
					}
				}

				if "`inference'"=="lci" {

					*** Calculate power of updated meta-analysis including new study. ***

					count if lci>=`npow'
					local power=100*r(N)/`nit'
					global rn=r(N)

					cii `nit' r(N), level(`ci')

					global pow=`power'
					global lci=r(lb)*100
					global uci=r(ub)*100

					*** Calculate power of newly simulated study. ***
					if "`ind'"!="" {
						count if indlci>=`npow'
						local indpower=100*r(N)/`nit'
						global indrn=r(N)

						cii `nit' r(N), level(`ci')

						global indpow=`indpower'
						global indlci=r(lb)*100
						global induci=r(ub)*100
					}
				}		  
			}
		}  
	}
  
	global nit = `nit'
	local m=`n'*`r'
}	

	//===================================================================================================================================================//
	// Label variables in temppow2 data set 
	
quietly {

	use temppow2, clear

	if "`measure'"=="or" {
		label variable es "Pooled OR from updated meta-analysis"
		label variable se_es "Standard error for pooled log OR from updated meta-analysis"
		label variable ciw "Width of CI for pooled OR from updated meta-analysis"
		label variable lci "Lower CI value for pooled OR from updated meta-analysis"
		label variable uci "Upper CI value for pooled OR from updated meta-analysis"
		label variable pval "P-value from updated meta-analysis"
		label variable indes "OR from newly simulated study"
		label variable indse_es "Standard error for log OR from newly simulated study"
		label variable indciw "Width of CI for OR from newly simulated study"
		label variable indlci "Lower CI value for OR from newly simulated study"
		label variable induci "Upper CI value for OR from newly simulated study"
	}

	if "`measure'"=="rr" {
		label variable es "Pooled RR from updated meta-analysis"
		label variable se_es "Standard error for pooled log RR from updated meta-analysis"
		label variable ciw "Width of CI for pooled RR from updated meta-analysis"
		label variable lci "Lower CI value for pooled RR from updated meta-analysis"
		label variable uci "Upper CI value for pooled RR from updated meta-analysis"
		label variable pval "P-value from updated meta-analysis"
		label variable indes "RR from newly simulated study"
		label variable indse_es "Standard error for log RR from newly simulated study"
		label variable indciw "Width of CI for RR from newly simulated study"
		label variable indlci "Lower CI value for RR from newly simulated study"
		label variable induci "Upper CI value for RR from newly simulated study"
	}

	if "`measure'"=="rd" {
		label variable es "Pooled RD from updated meta-analysis"
		label variable se_es "Standard error for pooled RD from updated meta-analysis"
		label variable ciw "Width of CI for pooled RD from updated meta-analysis"
		label variable lci "Lower CI value for pooled RD from updated meta-analysis"
		label variable uci "Upper CI value for pooled RD from updated meta-analysis"
		label variable pval "P-value from updated meta-analysis"
		label variable indes "RD from newly simulated study"
		label variable indse_es "Standard error for RD from newly simulated study"
		label variable indciw "Width of CI for RD from newly simulated study"
		label variable indlci "Lower CI value for RD from newly simulated study"
		label variable induci "Upper CI value for RD from newly simulated study"
	}

	if "`measure'"=="nostandard" {
		label variable es "Pooled unstandardized MD from updated meta-analysis"
		label variable se_es "Standard error for pooled unstandardized MD from updated meta-analysis"
		label variable ciw "Width of CI for pooled unstandardized MD from updated meta-analysis"
		label variable lci "Lower CI value for pooled unstandardized MD from updated meta-analysis"
		label variable uci "Upper CI value for pooled unstandardized MD from updated meta-analysis"
		label variable pval "P-value from updated meta-analysis"
		label variable indes "Unstandardized MD from newly simulated study"
		label variable indse_es "Standard error for unstandardized MD from newly simulated study"
		label variable indciw "Width of CI for unstandardized MD from newly simulated study"
		label variable indlci "Lower CI value for unstandardized MD from newly simulated study"
		label variable induci "Upper CI value for unstandardized MD from newly simulated study"
	}

	if "`measure'"=="dor" {
		label variable es "Pooled DOR from updated meta-analysis"
		label variable se_es "Standard error for pooled log DOR from updated meta-analysis"
		label variable ciw "Width of CI for pooled DOR from updated meta-analysis"
		label variable lci "Lower CI value for pooled DOR from updated meta-analysis"
		label variable uci "Upper CI value for pooled DOR from updated meta-analysis"
		label variable indes "DOR from newly simulated study"
		label variable indse_es "Standard error for log DOR from newly simulated study"
		label variable indciw "Width of CI for DOR from newly simulated study"
		label variable indlci "Lower CI value for DOR from newly simulated study"
		label variable induci "Upper CI value for DOR from newly simulated study"
	}

	if "`measure'"=="ss" {
		label variable sens "Pooled sens from updated meta-analysis"
		label variable spec "Pooled spec from updated meta-analysis"
		label variable ciw_sens "Width of CI for pooled sens from updated meta-analysis"
		label variable ciw_spec "Width of CI for pooled spec from updated meta-analysis"
		label variable lci_sens "Lower CI value for pooled sens from updated meta-analysis"
		label variable lci_spec "Lower CI value for pooled spec from updated meta-analysis"
		label variable uci_sens "Upper CI value for pooled sens from updated meta-analysis"
		label variable uci_spec "Upper CI value for pooled spec from updated meta-analysis"

		label variable indsens "Sens from newly simulated study"
		label variable indspec "Spec from newly simulated study"
		label variable indse_logsens "Standard error for logit sens from newly simulated study"
		label variable indse_logspec "Standard error for logit spec from newly simulated study"
		label variable indciw_sens "Width of CI for sens from newly simulated study"
		label variable indciw_spec "Width of CI for spec from newly simulated study"
		label variable indlci_sens "Lower CI value for sens from newly simulated study"
		label variable indlci_spec "Lower CI value for spec from newly simulated study"
		label variable induci_sens "Upper CI value for sens from newly simulated study"
		label variable induci_spec "Upper CI value for spec from newly simulated study"
	}

	save temppow2, replace
}
	
	restore

	//===================================================================================================================================================//
	// Display the results including relevant information 

	di ""
	di ""

	*** Inform user if npow was used ***
	if "`npow'" != ""{
		di in yellow "Level used to estimate power has changed"
		di in yellow "Simulated data has not changed"
		di ""
	}

	*** Display the model used ***
	if "`model'"=="fixed" {
		display as txt "Fixed effect Mantel-Haenszel model"
	}
	else if "`model'"=="fixedi" {
		display as txt "Fixed effect inverse variance-weighted model"
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

	*** Display the measure used ***
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

	*** Display the sample size in each group and the power values ***
	if "`type'"=="clinical" {
		di ""
		di "n=" %4.0f `n' " (in control group)"            
		di "m=" %4.0f `m' " (in treatment group)"
		di ""
		di "Power of meta-analysis is: "  %4.2f  as res `power' " (95% CI: " %4.2f  as res $lci ", " %4.2f  as res $uci ")"
		di ""
		if "`ind'"!="" {
			display "Power of individual study is: "  %4.2f  as res `indpower' " (95% CI: " %4.2f  as res $indlci ", " %4.2f  as res $induci ")"
			display " "
		}
	}

	if "`type'"=="diagnostic" {
		if "`measure'"=="dor" {
			display " "
			display "n=" %4.0f `n' " (positive test results)"      
			display "m=" %4.0f `m' " (negative test results)" 
			display " "
			display "Power of meta-analysis is: "  %4.2f  as res `power' " (95% CI: " %4.2f  as res $lci ", " %4.2f  as res $uci ")"
			display " "
			if "`ind'"!="" {
				display "Power of individual study is: "  %4.2f  as res `indpower' " (95% CI: " %4.2f  as res $indlci ", " %4.2f  as res $induci ")"
				display " "
			}
		}	

		if "`measure'"=="ss" {
			display " "
			display "n=" %4.0f `n' " (diseased patients)" 
			display "m=" %4.0f `m' " (healthy patients)" 
			display " "
			display "Power of meta-analysis is: "  %4.2f  as res `power' " (95% CI: " %4.2f  as res $lci ", " %4.2f  as res $uci ")"
			display " "
			if "`ind'"!="" {
				display "Power of individual study is: "  %4.2f  as res `indpower' " (95% CI: " %4.2f  as res $indlci ", " %4.2f  as res $induci ")"
				display " "
			}
		}
	}

	*** Display the inference used ***
	if "`npow'"=="" {

		if "`inference'"=="ciwidth" {
			if "`measure'"!="ss" {
				display in green "Confidence interval width used to estimate power = " %4.2f as res `pow'
			}
			if "`measure'"=="ss" {
				if "`sos'"=="" {
					display in green "Confidence interval width for sensitivity used to estimate power = " %4.2f as res `minsens'
					display in green "Confidence interval width for specificity used to estimate power = " %4.2f as res `minspec'
				}
				if "`sos'"!="" {
					display in green "Confidence interval width for " "`sos'" " used to estimate power = " %4.2f as res `pow'
				}
			}
		}

		if "`inference'"=="lci" {
			if "`measure'"!="ss" {
				display in green "Lower confidence interval value used to estimate power = " %4.2f as res `pow'
			}
			if "`measure'"=="ss" {
				if "`sos'"=="" {
					display in green "Lower confidence interval value for sensitivity used to estimate power = " %4.2f as res `minsens'
					display in green "Lower confidence interval value for specificity used to estimate power = " %4.2f as res `minspec'    
				}
				if "`sos'"!="" {
					display in green "Lower confidence interval value for " "`sos'" " used to estimate power = " %4.2f as res `pow'
				}
			}
		}

		if "`inference'"=="pvalue" {
			display in green "Level of significance used to estimate power = " %4.2f as res `pow'
		}
	}

	if "`npow'"!="" {

		if "`inference'"=="ciwidth" {
			if "`measure'"!="ss" {
				display in green "Confidence interval width used to estimate power = " %4.2f as res `npow'
			}
			if "`measure'"=="ss" {
				if "`sos'"=="" {
					display in green "Confidence interval width for sensitivity used to estimate power = " %4.2f as res `nminsens'
					display in green "Confidence interval width for specificity used to estimate power = " %4.2f as res `nminspec'
				}
				if "`sos'"!="" {
					display in green "Confidence interval width for " "`sos'" " used to estimate power = " %4.2f as res `npow'
				}
			}
		}

		if "`inference'"=="lci" {
			if "`measure'"!="ss" {
				display in green "Lower confidence interval value used to estimate power = " %4.2f as res `npow'
			}
			if "`measure'"=="ss" {
				if "`sos'"=="" {
					display in green "Lower confidence interval value for sensitivity used to estimate power = " %4.2f as res `nminsens'
					display in green "Lower confidence interval value for specificity used to estimate power = " %4.2f as res `nminspec'    
				}
				if "`sos'"!="" {
					display in green "Lower confidence interval value for " "`sos'" " used to estimate power = " %4.2f as res `npow'
				}
			}
		}
	}

	if "`model'"=="bivariate" {
		if $missing!=0 {
			di in yellow "A total of $missing out of $ntotal iterations failed to converge using the bivariate random effects meta-analysis" ///
			_newline "for a sample size of `t'. The power calculation has been adjusted for this."
			di in yellow "If a large proportion of iterations have failed it is recommended that the analysis is re-run using the metapowb" ///
			_newline "Stata command for power calculations in winbugs."
		} 
	}

	local dir `c(pwd)'
	display in green "Simulation estimates are saved in file called `dir'\temppow2"

end 
	
