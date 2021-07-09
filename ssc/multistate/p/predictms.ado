*! version 2.3.2 13aug2019 MJC

/*
History
MJC 13aug2019: version 2.3.2 - bug fix: missed an edit in 2.3.1 fix preventing aj to work in predictms (merlin function names); now fixed
							 - error check added for streg, d(ggamma) combined with aj - not supported
MJC 25jul2019: version 2.3.1 - bug fix: edits in merlin function names caused predictms to fail; now fixed
                             - error check added for bhtime with strcs models - not currently supported
MJC 03jun2019: version 2.3.0 - bug fix: stpm2 and strcs models failed, introduced in 2.2.0; now fixed
							 - streg, dist(lognormal) now allowed with clock-forward models
							 - bug fix: streg, dist(lognormal) with reset incorrectly assumed loglogistic; now fixed
MJC 28may2019: version 2.2.0 - bug fix: with novcv() when ci not specified introduced in 2.1.0; now fixed
							 - bug in error check for log normal requiring reset; now fixed
							 - Generalised gamma streg model now supported when used in the models() syntax
							 - bug fix in msaj when number of transitions was not equal to number dimension of transmatrix()
MJC 15apr2019: version 2.1.0 - novcv() option added to use mean vector instead of draws in CI calculations
MJC 19mar2019: version 2.0.1 - help file improved for msaj
MJC 23feb2018: version 2.0.0 - bug fix: los was incorrectly scaled to 1, introduced in 1.2.0. Now fixed.
							 - normal approximation for CIs is now the default. percentile option replaces normal.
							 - bug fix: level() was ignored in CI calculations, always assumed 95%. Now fixed.
							 - gen() removed
							 - bug fix: in some cases mm_root_vec produced an error when solving the root. Now fixed.
							 - all predictions now available in one call
							 - infinite at#()s added (limited to 50 for error check reasons)
							 - at() changed to at1()
							 - difference option added
							 - added atref(#) - default 1
							 - standardise option added to calculate standardised (population-averaged) predictions
							 - bug fix: with Stata 15 and streg (apart from dist(exp)), with at2(), the ancilary parameter constant was ignored. Now fixed.
							 - _time = 0 now allowed with normal ci's
							 - userfunction() added for user-defined prediction function, subroutines for probs and los
							 - userlink() added for normal cis of userfunction() - default identity, can also be log or logit
							 - cr option added to avoid specifying a transition matrix. For use with models() only.
							 - bug fix: reset now synced with root-finding updates for stpm2 and strcs models
							 - outsample added
							 - stms added
							 - enter() removed, now min(timevar or _t)
							 - aj added for Aalen-Johansen estimator with Markov models
							 - reversible transitions now allowed
MJC 17nov2017: version 1.2.1 - bug fix with simulation from strcs models with delayed entry
MJC 13nov2017: version 1.2.0 - tscale2() and time2() added for multiple timescales
							 - probabilities/los scaled to 1/t
release moved to website
MJC 21nov2016: verison 1.1.1 - bug fix
MJC 16nov2016: version 1.1.0 - some re-writes of source code for massive speed improvements when root-finding required
							 - trans#() syntax removed, now parsing is done automatically and using covariates expanded using msset
							 - model#() changed to models()
							 - improvements to help files
							 - covariates() added to msset to create transition-specific dummies, which must be used in model fitting (if required)
							 - default n() now 100,000, or 10,000 with ci
							 - survival added to calculate all predictions on a standard single event model
MJC 09aug2016: version 1.0.1 - gen() option to allow a stub for created variables, default is pred
MJC 12jul2016: version 1.0.0 

Development
stms not allowed yet
MJC 19may2015: version 1.1.0 - error check on transmatrix() added
							 - separate models allowed through model#(name, [at()])
MJC 14may2015: verison 1.0.8 - added error check not allowing AFT weibull or exp
MJC 11may2015: verison 1.0.7 - timevar() added
							 - basic graph option added which creates stacked plots
MJC 11may2015: verison 1.0.6 - fixed bug with weibull and forward approach
							 - Error checks improved					 
MJC 09may2015: version 1.0.5 - fixed bug in from() which occurred when anything but from(1) was used
							 - fixed bug in forward calculations when enter>0
							 - fixed bug that only calculated predictions to states you could go to from first state
MJC 09may2015: version 1.0.4 - clock-forward approach now the default (simulations incorporate delayed entry), reset option added to use clock-reset
							 - only reset approach allowed with streg, dist(lnormal)
MJC 06may2015: version 1.0.3 - now synced with streg, dist(exp|weib|gompertz|llogistic|lnormal)
							 - normal approximation added for CI calculations
MJC 15apr2015: version 1.0.2 - when no ci's calculated it was using first draw from MVN, this has been fixed to be e(b)
MJC 01apr2015: version 1.0.1 - stpm2 simulation improved by creating and passing struct
							 - odds and normal scales added for stpm2 models
MJC 31mar2015: version 1.0.0
*/

program define predictms, sortpreserve properties(st) rclass
	version 14.2
	syntax 						, 											///
																			///
										[									///
											TRANSMatrix(string)				///	-transition matrix-
											MODels(string)					///	-est store objects-
											RESET							///	-use clock reset approach in simulations-
											FROM(numlist >0 asc int)		/// -starting state for predictions-
											OBS(string)						///	-Number of time points to calculate predictions at between mint() and maxt()-
											MINT(string)					///	-minimum time to calculate predictions at-
											MAXT(string)					///	-maximum time to calculate predictions at-
											TIMEvar(varname numeric)		///	-prediction times-
											exit(string)					/// -time patients exit, for fixed horizon-
											SEED(string)					///	-pass to set seed-
											SURVival						///	-a single event survival model was fitted-
											CR								/// -competing risks model was fitted-
																			///
											N(string)						/// -sample size-
											M(numlist >=20 int max=1)		/// -number of parameter samples from MVN-
											CI								/// -calculate confidence intevals for transprobs-
											PERCentile						///	-calculate confidence intervals using percentiles-
											NOVCV(string)					/// -transitions to skip VCV when calculating CIs-
											Level(cilevel)					/// -level for CIs-
																			///
											LOS								///	-calculate length of stay in each state-
											VISIT							/// -prob. of ever visiting each state within time window-
																			///
											DIFFerence						///	-calculate differences of predictions between at() and at2()-
											RATIO							///	-calculate ratio of predictions between at() and at2()-
																			///
											ATREFerence(string)				///
																			///
											TSCALE2(string)					/// -transition models on a second timescale-
											TIME2(string)					/// -time to add to main timescale-
																			///
											TSRESET(string)					/// -transition-specific resets-
																			///
											USERFunction(string)			///
											USERLink(string)				///
																			///
											STANDardise						/// -standardised (pop.-averaged) predictions-
																			///
											OUTsample						///	-out of sample predictions-
																			///
											AJ								///
																			///
											GRAPH							///
											GRAPHOPTS(string)				///
																			///
											VARAJ							/// -not documented-
											STDIF(string)					///	-not documented-
											STDIF2(string)					///	-not documented-
											PROBINDEX						///	-not documented-
											SURVSIM(string)					/// -not documented-
											SURVSIMTOUSE(string)			/// -not documented-
																			///
											DEVCODE1(string)				/// -not documented-
											DEVCODE2(string)				/// -not documented-
											DEVCODE3(string)				/// -not documented-
											MARGinal						/// -not documented-
																			///
											INTERactive						/// -not documented-
											JSONpath(string)				/// -not documented-
																			///
											*								/// -infinite ats-
										]
					
	//================================================================================================================================================//
	// Preliminaries
	
	capture which merlin
	if _rc>0 {
		display in yellow "You need to install the command merlin. This can be installed using,"
		display in yellow ". {stata ssc install merlin}"
		exit  198
	}
	
	local ats `options'
	
	if "`aj'"!="" {
		if "`reset'"!="" {
			di as error "aj not allowed with reset"
			exit 198
		}
		if "`exit'"!="" {
			di as error "exit() not allowed with aj"
			exit 198
		}
		if "`n'"!="" {
			di as error "n() not needed with aj"
			exit 198
		}
		if "`models'"=="" {
			di as error "aj only available with models() syntax"
			exit 198
		}
		if "`visit'"!="" {
			di as error "visit not allowed with aj"
			exit 198
		}
	}
	
	if "`standardise'"!="" {
		local std std
	}
	local K = 1
	if "`std'"!="" {
		if "`outsample'"!="" | "`probindex'"!="" {
			exit 1986
		}
		tempvar stdtouse
		if "`stdif'"!="" {
			cap confirm var _trans1
			if _rc {
				qui gen byte `stdtouse' = `stdif'==1
				qui count if `stdif'==1
			}
			else {
				qui gen byte `stdtouse' = _trans1==1 & `stdif'==1
				qui count if _trans1==1 & `stdif'==1
			}
		}
		else {
			cap confirm var _trans1
			if _rc {
				qui gen byte `stdtouse' = 1
				qui count if `stdtouse'==1
			}
			else {
				qui gen byte `stdtouse' = _trans1==1
				qui count if _trans1==1
			}
		}
		local K = r(N)	
	}
	
	if "`outsample'"!="" {
		local out = 1
	}
	else local out = 0
	
	if `out' & "`timevar'"=="" {
		di as error "timevar() must be specified with outsample"
		exit 198
	}
	
	if "`n'"=="" & "`ci'"=="" {
		local n = 100000
	}
	else if "`n'"=="" & "`ci'"!="" {
		local n = 10000
	}
	
	if ("`probindex'"!="" | "`difference'"!="" | "`ratio'"!="") & "`ats'"=="" {
		di as error "at least at2() needed"
		exit 198
	}
	
	if "`seed'"!="" {
		set seed `seed'
	}
	
	local survsimcall = "`survsim'"!=""
	
	if "`survival'"!="" {
		if "`transmatrix'"!="" {
			di in yellow  "transmatrix(`transmatrix') ignored"
		}
		tempname transmatrix
		mat `transmatrix' = (.,1\.,.)
	
	}
	
	if "`cr'"!="" & "`models'"=="" {
		di as error "cr can only be used with models()"
		exit 198
	}
	
	if "`cr'"!="" {
		if "`transmatrix'"!="" {
			di in yellow  "transmatrix(`transmatrix') ignored"
		}
		local Ntrans : word count `models'
		tempname transmatrix
		mat `transmatrix' = J(`Ntrans'+1,`Ntrans'+1,.)
		forvalues i=1/`Ntrans' {
			mat `transmatrix'[1,`i'+1] = `i'
		}
	}
	
	if "`graph'"!="" & ("`los'"!="" | "`hasats'"!="") {
		di as error "graph not allowed with los or at2()"
		exit 198
	}
	
	cap confirm matrix `transmatrix'
	if _rc>0 & "`survival'"=="" {
		di as error "transmatrix(`transmatrix') not found"
		exit 198
	}
	mata: check_transmatrix()
	
	if ("`tscale2'"!="" & "`time2'"=="" ) | ("`tscale2'"=="" & "`time2'"!="" ) {
		di as error "tscale2() and time2() must both be specified"
		exit 198
	}
	
	if "`tscale2'"!="" & "`reset'"!="" {
		di as error "reset not allowed with tscale2()"
		exit 198
	}
	
	if "`ci'"=="" & "`m'"!="" {
		di as error "Cannot specify m() without ci"
		exit 198
	}
	
	if "`e(cmd2)'"=="streg" & ("`e(cmd)'"=="weibull" | "`e(cmd)'"=="ereg") & "`e(frm2)'"== "time" {
		di as error "streg, dist(weib|exp) time, not supported"
		exit 198
	}
	
	cap which lmoremata.mlib
	if _rc>0 {
		di as error "You need to install the moremata library from SSC"
		exit 198
	}	

	local model = "`models'"!=""
	if `model' {
		local Nmodels : word count `models'
		if `Ntrans'!=`Nmodels' {
			di as error "Number of estimates objects in model() must be equal to number of transitions" 
			exit 198
		}
		forvalues i=1/`Ntrans' {
			local model`i' : word `i' of `models'
		}
	}
		
	//extended parsing of model#()
	if `model' {
		forvalues i=1/`Ntrans' {
			local 0 `model`i''
			syntax name(id="model estimates required") 
			local modelests`i' `namelist'
		}				
	}
	
	if "`standardise'"!="" & "`e(cmd)'"=="stms" {
		di as error "standardise not available after stms"
		exit 198
	}
	
	if "`novcv'"!="" & "`models'"=="" {
		di as error "novcv() only allowed with models()"
		exit 198
	}
	
	local sim = "`aj'"==""
	
	
	//===================================================================================================================//
	//parse ats
	
	//check at#()
	
	local atind = 1
	while "`ats'"!="" {
		
		if `atind'>50 {
			di as error "at#() limit reached, or unrecognised option"
			exit 198
		}
		
		local 0 , `ats'
		syntax , [at`atind'(string) *]
		local ats `options'
		
		if !`out' {
			local varcount : word count `at`atind''
			local count = `varcount'/2			//!!add error check = integer
			tokenize ``at`atind'''
			while "`1'"!="" {
				unab 1: `1'
				cap confirm var `1'
				if _rc {
					di in red "invalid at`atind'(... `1' `2' ...)"
					exit 198
				}
				forvalues i=1/`Ntrans' {
					if "`1'"=="_trans`i'" {
						di as error "Cannot specify _trans# variables in at`atind'()"
						exit 198				
					}
				}
				cap confirm num `2'
				if _rc {
					di in red "invalid at`atind'(... `1' `2' ...)"
					exit 198
				}
				mac shift 2
			}  
		}
		local atind = `atind'+1

	}
	if `atind'>1 {
		local Nats = `atind'-1
	}
	else {
		local Nats = 1
	}

	if "`atreference'"=="" {
		local atref = 1
	}
	else {
		cap confirm integer number `atreference'
		if _rc {
			di as error "atreference() must be an integer"
			exit 198
		}
		if `atreference'<1 {
			di as error "atreference() must be >=1"
			exit 198		
		}
		local atref = `atreference'
	}
	
	if `atref'>`Nats' & `Nats'>1 {
		di as error "atreference(#) must be an at#()"
		exit 198
	}
	
	//==//

	
	if "`ci'"=="" local m = 1
	
	//default m for sims
	if "`ci'"!="" & "`m'"=="" local m = 200
			
	if "`from'"=="" local from 1
	
	// prediction time variable
	if "`timevar'"!="" & ("`mint'"!="" | "`maxt'"!="" | "`obs'"!="") {
		di as error "timevar() cannot be specified with mint()/maxt()/obs()"
		exit 198
	}
	
	if "`timevar'"=="" {
		if "`exit'"=="" {
			if "`maxt'"=="" {
				qui su _t, meanonly
				local maxt = `r(max)'
			}
			if "`mint'"=="" {
				local mint = 0
				local enter = `mint'
			}
			else {
				local enter = `mint'
			}
		}
		else {
			if "`aj'"!="" local enter = 0
			if "`maxt'"=="" {
				local maxt = `exit'
			}
			if "`mint'"=="" {
				local mint = 0
			}
			if `maxt'>`exit' {
				di as error "maxt() must be <= exit()"
				exit 198
			}
			if `mint'>=`exit' {
				di as error "mint() must be < exit()"
				exit 198
			}
		}
		
		if "`obs'"=="" & "`aj'"=="" local obs = 20
		else if "`obs'"=="" & "`aj'"!="" local obs = 500
		local timevar _time
		cap drop _time
		cap range2 _time `mint' `maxt' `obs'	
		label var _time "Follow-up time"
		
		//touse variable for predictions etc.
		tempvar touse
		qui gen byte `touse' = _n<= `obs'
	}
	else {
		//touse variable for predictions etc.
		tempvar touse
		qui gen byte `touse' = `timevar'!=.
		qui count if `touse'==1
		local obs = `r(N)'
		qui su `timevar', meanonly
		if "`exit'"=="" {
			local enter = `r(min)'
			if `r(max)'<`enter' {
				di as error "max(`timevar') must be > enter()"
				exit 198
			}
			if `r(min)'<`enter' {
				di as error "min(`timevar') must be >= enter()"
				exit 198
			}
		}
		else {
			if "`aj'"!="" local enter = 0
			if `r(max)'>`exit' {
				di as error "max(`timevar') must be <= exit()"
				exit 198
			}
			if `r(min)'>=`exit' {
				di as error "min(`timevar') must be < exit()"
				exit 198
			}
			if `r(max)'==`exit' & "`ci'"!="" & "`percentile'"=="" {
				di as error "max(`timevar') < exit() when confidence intervals with normal approximation are required"
				exit 198
			}			
		}
	}
	
	// Checks for interactive options
	if "`jsonpath'" != "" & "`interactive'" == "" {
		di as error "You have used the jsonpath option without using the interactive option."
		exit 198
	}
	if "`interactive'" != "" {
		if "`jsonpath'" != "" {
			mata st_local("direxists",strofreal(direxists("`jsonpath'")))
			if !`direxists' {
				di as error "Folder `jsonpath' does not exist."
				exit 198
			}
			mata st_local("jsonfile",pathjoin("`jsonpath'","msboxes_predictions.json"))
			mata st_local("htmlfile",pathjoin("`jsonpath'","msboxes.html"))
		}
		else {
			local jsonfile msboxes_predictions.json
			local htmlfile msboxes.html
		}
		capture confirm file "`jsonfile'"
		if !_rc {
			capture erase "`jsonfile'"
			if _rc {
				display as error "`jsonfile' cannot be deleted'"
			}
		}
		capture confirm file "`htmlfile'"
		if _rc {
			di as error "msboxes.html does not exist in folder `jsonpath'"
		}
		// hazard functions
		forvalues i = 1/`Ntrans' {
			qui estimates restore `model`i''
			forvalues j=1/`Nats' {
				tempname hazard_trans`i'_at`j'
				if `Nats' == 1 & "`at1'" == "" local tmpat ""
				else local tmpat at(`at`j'')
				qui predict `hazard_trans`i'_at`j'', timevar(`timevar') hazard `tmpat'
			}
		}
	}
	

	//get core stuff

	//possible transitions from each state
	local Nstates = colsof(`transmatrix')
	if `Nstates'<2 {
		di as error "Must be at least 2 possible states, including starting state"
		exit 198
	}
	
	forvalues i=1/`Nstates' {
		forvalues j=1/`Nstates' {
			if (`transmatrix'[`i',`j']!=.) {
				local row`i'trans `row`i'trans' `=`transmatrix'[`i',`j']'
				local row`i'next `row`i'next' `j'
			}
		}
	}
	
	//check somewhere to go
	foreach frm in `from' {
		if "`row`frm'next'"=="" {
			di as error "No possible next states from(`frm')"
			exit 198
		}
	}
	
	if "`ci'"!="" & "`aj'"=="" {
		tempvar mvnind
		gen byte `mvnind' = _n<=`m'
	}
	
	
	//=====================================================================================================================================================//
	//CORE
	
	//======================================================//
	// stacked model 
	if !`model' {
		
		predictms_modelcheck 0 "`aj'"
				
		if `sim' {
		
			local cmds `e(cmd)'
			
			//coefficients
			tempname emat evmat
			mat `emat' = e(b)
			if "`ci'"!="" {
				mat `evmat' = e(V)
			}
			if "`e(cmd)'"=="stpm2" {
				mat `emat' = `emat'[1,"xb:"]
				if "`ci'"!="" {
					mat `evmat' =`evmat'["xb:","xb:"]
				}
			}
			local Nparams = colsof(`emat')

			if "`e(cmd2)'"=="streg" {
				
				if "`e(cmd)'"=="ereg" {
					local cmdline `e(cmdline)'
					gettoken cmd 0 : cmdline
					syntax varlist, [NOCONStant *]
					if "`noconstant'"=="" local addcons _cons
					local corevars `varlist' `addcons'
				}
				else {
					local cmdline `e(cmdline)'
					gettoken cmd 0 : cmdline
					syntax varlist, [NOCONStant ANCillary(varlist) *]
					if "`noconstant'"=="" local addcons _cons
					local corevars `varlist' `addcons' `ancillary' _cons
					//indices for lambda and gamma
					tempname indices			
					mat `indices' = J(2,2,1)
					local colindex = `: word count `varlist'' + ("`noconstant'"=="")
					mat `indices'[2,1] = `colindex'
					mat `indices'[1,2] = `colindex' + 1
					mat `indices'[2,2] = `: word count `corevars''
					forvalues i=1/`Ntrans' {
						tempname indices`i'										//extension to index dm and b
						mat `indices`i'' = `indices'
					}
				}
				
				forval a=1/`Nats' {
				
					//now loop over vars and update DM and indices
					//can match variables in at() with varlist
					forvalues i=1/`Ntrans' {
											
						//design matrix for each transition
						tempname at`a'dm`i'
						mat `at`a'dm`i'' = J(1,`Nparams',0)
						
						local colindex = 1
						foreach corevar in `corevars' {
						
							if "`corevar'"=="_cons" {
								mat `at`a'dm`i''[1,`colindex'] = 1
							}
							else {
								local inat = 0
								predictms_atparse, 	corevar(`corevar') colindex(`colindex') dmmat(`at`a'dm`i'') 	///
											i(`i') ntrans(`Ntrans') at(`at`a'') out(`out')
								local inat = r(inat)
								local todrop `todrop' `r(todrop)'
								
								if !`inat' & "`std'"!="" {
									predictms_stdparse `corevar' `i' `Ntrans'
									if r(include) {
										local at`a'stdvars`i' `at`a'stdvars`i'' `r(stdvar)'
										local at`a'stdvarsindex`i' `at`a'stdvarsindex`i'' `colindex'
									}
								}
								
							}
							local colindex = `colindex' + 1
							
						}
					
					}
				}
			
			}
			else if "`e(cmd)'"=="stpm2" | "`e(cmd)'"=="strcs" {
			
				//DM is only for varlist, tvc splines and base splines are handled separately
				local corevars `e(varlist)'
				local Ncovs : word count `corevars'
				local nocons `e(noconstant)'
				local orthog `e(orthog)'
				
				//design matrix for each transition
				if `Ncovs' > 0 {

					forval a=1/`Nats' {
					
						//now loop over trans# and update DM and indices
						//can match variables in at() with varlist and ancillary
						forvalues i=1/`Ntrans' {
							tempname at`a'dm`i'
							mat `at`a'dm`i'' = J(1,`Ncovs',0)
							local colindex = 1
							foreach corevar in `corevars' {
							
								local inat = 0
								predictms_atparse, corevar(`corevar') colindex(`colindex') dmmat(`at`a'dm`i'') i(`i') ntrans(`Ntrans') at(`at`a'') out(`out')
								local inat = r(inat)
								local todrop `todrop' `r(todrop)'
								
								//standardising	-> kept out here as could standardise without at()s
								if !`inat' & "`std'"!="" {
									predictms_stdparse `corevar' `i' `Ntrans'
									if r(include) {
										local at`a'stdvars`i' `at`a'stdvars`i'' `r(stdvar)'
										local at`a'stdvarsindex`i' `at`a'stdvarsindex`i'' `colindex'
									}
								}
								local colindex = `colindex' + 1
							}
						}
						
					}
				}
				
				local rcsbaseoff `e(rcsbaseoff)'										//always empty for strcs
				if "`rcsbaseoff'"=="" {
					local Nsplines : word count `e(rcsterms_base)'
					if "`e(cmd)'"=="stpm2" {
						local ln_bknots `e(ln_bhknots)'										//all log baseline knots including boundary knots
						if "`ln_bknots'"=="" {	//this is empty when df(1)
							local ln_bknots `=log(`: word 1 of `e(boundary_knots)'')' `=log(`: word 2 of `e(boundary_knots)'')'
						}
					}
					else {
						local ln_bknots `e(bhknots)'										//all log baseline knots including boundary knots
						if "`ln_bknots'"=="" {	//this is empty when df(1)
							local ln_bknots -5 10 //fudge - these values are not used
						}
					}
					if "`orthog'"!="" {
						tempname rmat
						mat `rmat' = e(R_bh)
						local rmatopt rmatrix(`rmat')
					}			
				}
				
				//to sync with separate model sim
				forvalues i=1/`Ntrans' {
					local rcsbaseoff`i' `rcsbaseoff'
					local scale`i' `e(scale)'
					local orthog`i' `e(orthog)'
					local nocons`i' `e(noconstant)'
					if "`rcsbaseoff`i''"=="" {
						local ln_bknots`i' `ln_bknots'
						if "`orthog`i''"!="" {
							tempname rmat`i'
							mat `rmat`i'' = `rmat'
						}
					}
				}
						
				local tvc `e(tvc)'
				forvalues i=1/`Ntrans' {
					local tvc`i' `tvc'
				}
				if "`tvc'"!="" {
					local i = 1
					foreach tvcvar in `tvc' {
						if "`e(cmd)'"=="stpm2" {
							local boundary_knots_`i' `e(boundary_knots_`tvcvar')'
							local ln_tvcknots_`i' `e(ln_tvcknots_`tvcvar')'
							if "`ln_tvcknots_`i''"=="" {
								local ln_tvcknots_`i' `=log(`: word 1 of `boundary_knots_`i''')' `=log(`: word 2 of `boundary_knots_`i''')'
							}		
						}
						else {
							local boundary_knots_`i' `e(boundary_knots_`tvcvar')'
							local ln_tvcknots_`i' `e(tvcknots_`tvcvar')'
							if "`ln_tvcknots_`i''"=="" {
								local ln_tvcknots_`i' -5 10	//fudge - these values are not used
							}	
						
						}
						forvalues j=1/`Ntrans' {
							local ln_tvcknots`j'_`i' `ln_tvcknots_`i''
						}
						if "`orthog'"!="" {
							tempname R_`i'
							mat `R_`i'' = e(R_`tvcvar')
							forvalues j=1/`Ntrans' {
								tempname R`j'_`i'
								mat `R`j'_`i'' = `R_`i''
							}
						}
						local i = `i' + 1
					}
					local Ntvcvars = `i' - 1
					forvalues i=1/`Ntrans' {
						local Ntvcvars`i' `Ntvcvars'
					}
					//tvc DM
					forval a=1/`Nats' {
					
						forvalues i=1/`Ntrans' {
							tempname at`a'dmtvc`i'
							mat `at`a'dmtvc`i'' = J(1,`Ntvcvars`i'',0)
							local colindex = 1
							foreach corevar in `tvc`i'' {
							
								local inat = 0
								predictms_atparse, corevar(`corevar') colindex(`colindex') dmmat(`at`a'dmtvc`i'') i(`i') ntrans(`Ntrans') at(`at`a'') out(`out')
								local inat = r(inat)
								local todrop `todrop' `r(todrop)'
								
								//standardising
								if "`std'"!="" {
									if !`inat' {
										predictms_stdparse `corevar' `i' `Ntrans'
										if r(include) {
											local at`a'tvcstdvars`i' `at`a'tvcstdvars`i'' `r(stdvar)'
											local at`a'tvcstdvarsindex`i' `at`a'tvcstdvarsindex`i'' `colindex'
										}
									}						
								}
								local colindex = `colindex' + 1
							}
						}

					}
					
				}
			
			}
			else if "`e(cmd)'"=="stms" {
			
				local cmds `e(models)'
				
				//coefficients
				tempname emat evmat
				mat `emat' = e(b)
				if "`ci'"!="" {
					mat `evmat' = e(V)
				}
				
				forval a=1/`Nats' {
				
					local ind = 1
					
					forvalues i=1/`Ntrans' {
				
						local stmodel : word `i' of `e(models)'		
						
						predictms_stms_model, trans(`i') model(`stmodel') bmat(`emat') at(`at`a'') 
						//leaves stpm2 info behind in locals
						
						tempname at`a'dm`i'
						mat `at`a'dm`i'' = r(dm)
					
						if `a'==1 {
							
							//index for extracting model specific betas
							tempname stmsindex`i'
							if `i'==1 {
								mat `stmsindex`i'' = (`ind',`r(Nparams)')
								if "`r(Nparams2)'"=="" {
									local ind = `r(Nparams)' + 1
								}
								else {
									local ind = `r(Nparams2)' + 1
								}
							}
							else {
								mat `stmsindex`i'' = (`ind',`=`ind'+`r(Nparams)'-1')
								if "`r(Nparams2)'"=="" {
									local ind = `ind' + `r(Nparams)'
								}
								else {
									local ind = `ind' + `r(Nparams2)'
								}
							}
							
							if "`stmodel'"!="stpm2" & "`stmodel'"!="ereg"{
								tempname indices`i'
								mat `indices`i'' = r(indices)
							}
							if "`stmodel'"=="stpm2" {
								if "`e(orthog`i')'"=="orthog" {
									tempname rmat`i'
									mat `rmat`i'' = r(rmat)
									if "`e(tvc`i')'"!="" {
										forvalues j=1/`Ntvcvars`i'' {
											tempname R`i'_`j'
											mat `R`i'_`j'' = r(R_`j')
										}
									}
								}
								if "`e(tvc`i')'"!="" {
									tempname at`a'dmtvc`i'
									mat `at`a'dmtvc`i'' = r(dmtvc)
								}
							}
							
						}
					}
				}
			
			}
			
		}
		

	}	
	
	//======================================================//
	// models framework
	else {
		

			forval a=1/`Nats' {

				forvalues i=1/`Ntrans' {
				
					//error checks
					cap estimates restore `modelests`i''
						
					if _rc>0 {
						di as error "model estimates `modelests`i'' not found"
						exit 198			
					}
					predictms_modelcheck 1 "`aj'"

					//get estimates and variances
					tempname emat`i'
					mat `emat`i'' = e(b)
					if "`e(cmd)'"=="stpm2" {
						mat `emat`i'' = `emat`i''[1,"xb:"]
					}
					if "`ci'"!="" {
						tempname  evmat`i'
						mat `evmat`i'' = e(V)
						if "`e(cmd)'"=="stpm2" {
							mat `evmat`i'' =`evmat`i''["xb:","xb:"]
						}
					}
					local Nparams`i' = colsof(`emat`i'')
					
					//get design matrix for at#() and other things
					predictms_model, 	trans(`i') 					///
										nparams(`Nparams`i'') 		///
										ntrans(`Ntrans') 			///
										at(`at`a'')					///
										aind(`a')					///
										`std' 						///
										out(`out')
					tempname at`a'dm`i'
					mat `at`a'dm`i'' = r(dm)
					
					local todrop `todrop' `r(todrop)'
					
					if "`std'"!="" {
						local at`a'stdvars`i' `r(stdvars)'
						local at`a'stdvarsindex`i' `r(stdvarsindex)'
					}

					if `a'==1 & "`e(cmd)'"!="stpm2" & "`e(cmd)'"!="ereg" & "`e(cmd)'"!="strcs" & "`e(cmd)'"!="cox" {
						tempname indices`i'
						mat `indices`i'' = r(indices)
					}
					
					if "`e(cmd)'"=="stpm2" | "`e(cmd)'"=="strcs" {
						if `a'==1 & "`e(orthog)'"=="orthog" {
							tempname rmat`i'
							mat `rmat`i'' = r(rmat)
							if "`e(tvc)'"!="" {
								forvalues j=1/`Ntvcvars`i'' {
									tempname R`i'_`j'
									mat `R`i'_`j'' = r(R_`j')
								}
							}
						}
						if "`e(tvc)'"!="" {
							tempname at`a'dmtvc`i'
							mat `at`a'dmtvc`i'' = r(dmtvc)
							if "`std'"!="" {
								local at`a'tvcstdvars`i' `r(tvcstdvars)'
								local at`a'tvcstdvarsindex`i' `r(tvcstdvarsindex)'
							}
						}
					}
					if `a'==1 {
						local cmds `cmds' `cmdname'
					}
					
				}
			}
	
	}
	
	if "`std'"!="" {
		local stdcheck = 0
		forval a=1/`Nats' {
			forvalues i=1/`Ntrans' {
				di as text "Transition `i', at`a'(): Standardising over -> `at`a'stdvars`i''"
				local stdcheck = `stdcheck' + ("`at`a'stdvars`i''"=="")
			}
		}
		if `stdcheck' {
			di as error "No variables for standardising"
			exit 1986
		}
	}
	
	mata: predictms()				
	
	//tidy up
	if `survsimcall' {
		cap drop _time
		exit
	}
	cap drop `todrop'	
	
	//=====================================================================================================================//
	//finish
	
	if "`graph'"!="" {
		if "`e(cmd)'"=="cox" local coxgraph cox
		msgraph, from(`from') nstates(`Nstates') timevar(`timevar') enter(`enter') gen(`gen') `graphopts' `coxgraph'
	}
	
	if "`interactive'" != "" {
		mata: predictms_writejson()
		display `"{browse "`htmlfile'":Click here for interative graphs}"'
	}

// return list
	return matrix transmatrix = `transmatrix', copy
	return local Nstates = `Nstates'
	return local from `from'
	return local stub `stub'
	
	//Done

end

//for stgenreg
program updatebmat, eclass
	syntax, N(int) j(int) draws(string)
	
	tempname bmat
	matrix `bmat' = e(b)
	
	forvalues i=1/`n' {
		local var`i': word `i' of `draws'
	}
	
	forvalues i=1/`n' {
		matrix `bmat'[1,`i'] = `var`i''[`j']
	}
	ereturn repost b = `bmat'
end

* double added to range
program define range2
        version 3.1
        if "`3'"=="" | "`5'"!="" { error 198 }
        confirm new var `1'
        if _N==0 { 
                if "`4'"=="" { error 198 } 
                set obs `4'
                local o "`4'"
        }
        else { 
                if "`4'"!="" { 
                        local o "`4'"
                        if `4' > _N { set obs `4' }
                }
                else    local o=_N
        }
        gen double `1'=(_n-1)/(`o'-1)*((`3')-(`2'))+(`2') in 1/`o'
end

program predictms_modelcheck
	args model aj

	if "`e(cmd)'"!="merlin" & "`e(cmd)'"!="stms" & "`e(cmd)'"!="stpm2" & "`e(cmd)'"!="stgenreg" & "`e(cmd2)'"!="streg" & "`e(cmd)'"!="strcs" {
		di as error "Last estimates not found"
		exit 198	
	}	
	
	if "`e(cmd2)'"=="streg" & "`e(cmd)'"=="gamma" & !`model' {
		di as error "Generalised gamma only allowed when combined with models()"
		exit 198
	}
	
	if "`e(cmd2)'"=="streg" & "`e(cmd)'"=="gamma" & "`aj'"!="" {
		di as error "Generalised gamma not allowed with aj"
		exit 198
	}
	
	if "`e(cmd2)'"=="streg" & ("`e(cmd)'"=="weibull" | "`e(cmd)'"=="ereg") & "`e(frm2)'"== "time" {
		di as error "streg, dist(weib|exp) time, not supported"
		exit 198
	}
	
	if "`e(cmd)'"=="strcs" & "`e(bhtime)'"!="" {
		di as error "bhtime with a strcs model is not currently supported"
		exit 198
	}
	
end

mata
void check_transmatrix()
{
	tmat = st_matrix(st_local("transmatrix"))
	tmat_ind = tmat:!=.							//indicator matrix
	
	//Error checks
	if (max(diagonal(tmat_ind))>0) {
		errprintf("All elements on the diagonal of transmatrix() must be coded missing = .\n")
		exit(198)
	}
	row = 1
	rtmat = rows(tmat)
	trans = 1
	while (row<rtmat) {
		for (i=1;i<=rtmat;i++) {
			if (sum(tmat:==tmat[row,i])>1 & tmat[row,i]!=.) {
				errprintf("Elements of transmatrix() are not unique\n")
				exit(198)
			}
			if (tmat[row,i]!=. & tmat[row,i]!=trans){
				errprintf("Elements of transmatrix() must be sequentially numbered from 1,...,K, where K = number of transitions\n")
				exit(198)
			}		
			if (tmat[row,i]!=.) trans++
		}
		row++
	}
	st_local("Ntrans",strofreal(trans-1))

}

end

