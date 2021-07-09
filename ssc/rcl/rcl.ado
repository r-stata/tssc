*! rcl 1.01 Szabolcs Lorincz 23Aug2016
* estimation and simulation of random coefficient logit models
* author: Szabolcs Lorincz
* disclaimer: the views expressed are those of the author and cannot be regarded 
*	as stating an official position of the European Commission, or as an indication 
*	on what methodologies the European Commission would use or how it would assess 
*	them in any of its proceedings.

capture program drop rcl

program rcl, eclass sortpreserve

	syntax [anything] [if] [in],/*
				General
			*/	Market(varname) [MSIZE(varname)] [TSLS] [GMM2s] [IGMM] [CUE] [OPTimal] [CF] [Robust] [cluster(varname)] [NOCONStant] [NOCOLLIN] [partial(varlist)] [NODISPlay] /*
				BLP
			*/	[RC(varlist)] [DEMOG(namelist)] [INTegrationmethod(name)] [ACCuracy(integer 6)] [draws(integer 500)] [itol(real 0.000000000001)] [imaxiter(integer 2500)] [STARTParams(name)] [pgroups(varname)] [rc_pgroups(varname)] /*
				Logit, nested logit
			*/	[NESTS(varlist)] /*
				Equilibrium (system) estimation
			*/  [EQESTimation] [XP(varlist)] [PInstruments(varlist)] [EQSTARTParams(name)] /*
				Elasticities, merger simulation, marginal costs, SSNIP test
			*/	[ELASticities(name)] [MSIMULation(varlist)] [VAT(varname)] [MC(varname)] [ONLYMC] [CMCE] [SSNIP(varlist)] /*
				Simulation without estimation
			*/	[NOESTimation] [ALPHA(numlist)] [SIGMAS(numlist)] [RCSIGMAS(numlist)] [AELAST(numlist)] [XB0(varname)] [KSI(varname)]

	* lowest version of Stata to use for interpreting the command
	version 11.0, missing

	* seed, work sample, constant, index of variables
	set seed 1
	marksample touse
	tempvar obs cns0
	quietly generate `cns0'=1 if `touse'
	quietly generate `obs'=sum(`cns0') if `touse'

	* ensuring consistency of model types
	if ("`rc'"=="") {
		local model nlogit
	}
	if ("`rc'"!="" & "`nests'"=="") {
		local model blp
	}
	if ("`rc'"!="" & "`nests'"!="") {
		local model nlogit
	}

	* check whether Mata function libraries lrcl and lnwspgr are available (indexed)
	capture quietly mata: mata which replace_matrix()
	local _rc_lrc=_rc
	local _rc=`_rc_lrc'
	local _rc_nwspgr=0
	if ("`model'"=="blp") {
		capture quietly mata: mata which nwspgr()
		local _rc_nwspgr=_rc
		local _rc=`_rc'+`_rc_nwspgr'
	}
	if (`_rc'!=0) {
		quietly mata: mata mlib index
		capture quietly mata: mata which replace_matrix()
		local _rc_lrc=_rc
		if ("`model'"=="blp") {
			capture quietly mata: mata which nwspgr()
			local _rc_nwspgr=_rc
		}
		if (`_rc_lrc'!=0 & `_rc_nwspgr'==0) {
			noisily di as err "Mata function library lrcl.mlib not available"
			noisily di as err "Either, download it by reinstalling the rcl command: " _c
			noisily di in smcl "{stata ssc install rcl, all replace :ssc install rcl, all replace}"
			noisily di as err "or run Block I. of the rcl_mlib_and_test_data_generation.do file: " _c
			noisily di in smcl `"doedit `c(sysdir_plus)'r\rcl_mlib_and_test_data_generation.do"'
			exit 601
		}
		if (`_rc_lrc'==0 & `_rc_nwspgr'!=0) {
			noisily di as err "Mata function library lnwspgr.mlib not available"
			noisily di as err "Download it by reinstalling the rcl command: " _c
			noisily di in smcl "{stata ssc install rcl, all replace :ssc install rcl, all replace}"
			exit 601
		}
		if (`_rc_lrc'!=0 & `_rc_nwspgr'!=0) {
			noisily di as err "Mata function libraries lrcl.mlib and lnwspgr.mlib not available"
			noisily di as err "Download them by reinstalling the rcl command: " _c
			noisily di in smcl "{stata ssc install rcl, all replace :ssc install rcl, all replace}"
			exit 601
		}
	}

	* ensuring consistency for the simulation-without-estimation mode (option noestimation specified)
	if ("`alpha'"=="") {
		local alpha=.
	}
	if ("`noestimation'"!="") {
		local alpha=abs(`alpha')
		if (wordcount("`nests'")>wordcount("`sigmas'")) {
			local nests0
			if (wordcount("`sigmas'")>0) {
				local ns=wordcount("`sigmas'")
				forvalues s=1/`ns' {
					local ss=word("`nests'",`s')
					local nests0 "`nests0' `ss'"
				}
			}
			local nests=trim("`nests0'")
		}
		if (wordcount("`nests'")<wordcount("`sigmas'")) {
			local sigmas0
			if (wordcount("`nests'")>0) {
				local ns=wordcount("`nests'")
				forvalues s=1/`ns' {
					local ss=word("`sigmas'",`s')
					local sigmas0 "`sigmas0' `ss'"
				}
			}
			local sigmas=trim("`sigmas0'")
		}
		if (wordcount("`nests'")==wordcount("`sigmas'")) {
			local nests0
			local sigmas0
			if (wordcount("`nests'")>0) {
				local ns=wordcount("`nests'")
				forvalues s=1/`ns' {
					local ss=word("`sigmas'",`s')
					local ns=word("`nests'",`s')
					if (`ss'!=0) {
						local nests0 "`nests0' `ns'"
						local sigmas0 "`sigmas0' `ss'"
					}
				}
			}
			local nests=trim("`nests0'")
			local sigmas=trim("`sigmas0'")
		}
		if (wordcount("`nests'")==3 & wordcount("`sigmas'")==3) {
			if (word("`sigmas'",3)==word("`sigmas'",2)) {
				local s3=word("`sigmas'",3)
				local n3=word("`nests'",3)
				local sigmas: list sigmas - s3
				local nests: list nests - n3
			}
		}
		if (wordcount("`nests'")==2 & wordcount("`sigmas'")==2) {
			if (word("`sigmas'",2)==word("`sigmas'",1)) {
				local s2=word("`sigmas'",2)
				local n2=word("`nests'",2)
				local sigmas: list sigmas - s2
				local nests: list nests - n2
			}
		}
		if (wordcount("`nests'")==1 & wordcount("`sigmas'")==1) {
			if (word("`sigmas'",1)=="0") {
				local sigmas
				local nests
			}
		}
		if (wordcount("`rc'")>wordcount("`rcsigmas'")) {
			local rc0
			if (wordcount("`rcsigmas'")>0) {
				local ns=wordcount("`rcsigmas'")
				forvalues s=1/`ns' {
					local ss=word("`rc'",`s')
					local rc0 "`rc0' `ss'"
				}
			}
			local rc=trim("`rc0'")
		}
		if (wordcount("`rc'")<wordcount("`rcsigmas'")) {
			local rcsigmas0
			if (wordcount("`rc'")>0) {
				local ns=wordcount("`rc'")
				forvalues s=1/`ns' {
					local ss=word("`rcsigmas'",`s')
					local rcsigmas0 "`rcsigmas0' `ss'"
				}
			}
			local rcsigmas=trim("`rcsigmas0'")
		}
		if (wordcount("`rc'")==wordcount("`rcsigmas'")) {
			local rc0
			local rcsigmas0
			if (wordcount("`rc'")>0) {
				local ns=wordcount("`rc'")
				forvalues s=1/`ns' {
					local ss=word("`rcsigmas'",`s')
					local ns=word("`rc'",`s')
					if (`ss'!=0) {
						local rc0 "`rc0' `ns'"
						local rcsigmas0 "`rcsigmas0' `ss'"
					}
				}
			}
			local rc=trim("`rc0'")
			local rcsigmas=trim("`rcsigmas0'")
		}
		if ("`rc'"=="") {
			local model nlogit
		}
		if ("`rc'"!="" & "`nests'"=="") {
			local model blp
		}
		if ("`rc'"!="" & "`nests'"!="") {
			local model nlogit
		}
	}

	* setting default integration method (sparse grid) if necessary
	if ("`integrationmethod'"=="") {
		local integrationmethod sparsegrid
	}
	/*display "`integrationmethod'"
	display "`accuracy'"*/

	/* BLP model */
	if ("`model'"=="blp") {
	
		********************
		* COLLECTING INPUTS
		********************
	
		* varlists
		* creating locals with varlists from the main command line (i.e., the user specified content after the rcl command and before the sample if condition or option comma)
		* locals created:
		*	share	share variable
		*	iexog	list of included right hand side exogenous variables
		*	exexog	list of excluded right hand side exogenous variables ("instruments")
		*	endog	list of endogenous right hand side variables
		local length: list sizeof anything
		local iexog
		local exexog
		local endog
		local n=0
		local inbracket=0
		local aftereq=0
		local iiendog=0
		local iiexexog=0
		forvalues i=1/`length' {
			*display "``i''"
			if (`i'==1) {
				local share "``i''"
			}
			if (`i'>1) {
				local name="``i''"
				local cpos=strpos("`name'",",")
				if (`cpos'!=0) {
					local name=substr("`name'",1,`cpos'-1)
				}
				if (substr("`name'",1,1)=="(") {
					local inbracket=1
					local name=substr("`name'",2,.)
				}
				if (`inbracket'==1) {
					local eqpos=strpos("`name'","=")
					if (`eqpos'!=0) {
						local aftereq=1
						local name_preeq=substr("`name'",1,`eqpos'-1)
						local name_posteq=substr("`name'",`eqpos'+1,.)
						local endog `endog' `name_preeq'
						local exexog `exexog' `name_posteq'
					}
					if (`aftereq'==0 & `eqpos'==0) {
						local endog `endog' `name'
					}				
					if (`aftereq'==1 & `eqpos'==0) {
						if (substr("`name'",-1,.)==")") {
							local inbracket=0
							local name=substr("`name'",1,length("`name'")-1)
						}
						local exexog `exexog' `name'
					}
					if (substr("`endog'",-1,.)==")") {
						local es=substr("`endog'",-1,.)
						local endog: list endog - es
					}					
				}
				if (`inbracket'==0) {
					local iexog `iexog' `name'
					local iexog: list iexog - exexog
				}
			
			}		
		}
		/*display "`share'"
		display "`iexog'"
		display "`endog'"
		display "`exexog'"*/
		* expanding wildcards, removing duplicates
		if ("`iexog'"!="") {
			local iexog0
			foreach v of varlist `iexog' {
				local iexog0 `iexog0' `v'
			}
			local iexog `iexog0'
			local dupsiexog : list dups iexog
			local iexog : list uniq iexog
		}
		if ("`endog'"!="") {
			local endog0
			foreach v of varlist `endog' {
				local endog0 `endog0' `v'
			}
			local endog `endog0'
			local dupsendog : list dups endog
			local endog : list uniq endog
		}
		if ("`exexog'"!="") {
			local exexog0
			foreach v of varlist `exexog' {
				local exexog0 `exexog0' `v'
			}
			local exexog `exexog0'
			local dupsexexog : list dups exexog
			local exexog : list uniq exexog
		}
		if ("`pinstruments'"!="") {
			local pinstruments0
			foreach v of varlist `pinstruments' {
				local pinstruments0 `pinstruments0' `v'
			}
			local pinstruments `pinstruments0'
			local dupspinstruments : list dups pinstruments
			local pinstruments : list uniq pinstruments
		}
		* remove iexog from endog
		local dupsen2 : list endog & iexog
		local endog   : list endog - iexog
		* remove iexog from exexog
		local dupsex2 : list exexog & iexog
		local exexog : list exexog - iexog
		* remove endog from exexog
		local dupsex3 : list exexog & endog
		local exexog : list exexog - endog
		local dups "`dupsendog' `dupsexexog' `dupsiexog' `dupsen2' `dupsex2' `dupsex3'"
		local dups    : list uniq dups
		/*display "`share'"
		display "`iexog'"
		display "`endog'"
		display "`exexog'"*/
		* duplicates warning message, if necessary
		if ("`noestimation'"=="") {
			if ("`dups'"!="") {
				di in gr "Warning - duplicate variables detected"
				di in gr "Duplicates: " _c
				disp "`dups'", _col(21)
			}
		}

		* excluding observations with non-positive share from work sample
		quietly replace `touse'=0 if `share'<=0 | `share'==.

		* constant variable as a linear regressor (if noconstant option is not specified)
		if ("`noestimation'"=="") {
			if ("`noconstant'"=="") {
				local _cns _cns
				capture drop `_cns'
				qui gen byte `_cns' = 1 if `touse'
				local iexog `iexog' `_cns'
				*display "`iexog'"
			}
		}

		* checking collinearities (from ivreg2)
		if ("`noestimation'"=="") {
			if ("`nocollin'"=="") {
				collincheck , lhs(`share') endog(`endog') iexog(`iexog') exexog(`exexog') weight(`weight') wtexp(`wtexp') touse(`touse')
				local endog `r(endog)'
				local iexog `r(iexog)'
				local exexog `r(exexog)'
				local collin `r(collin)'
				local lists endog iexog exexog collin
				foreach list of local lists {
					if ("``list''"==".") {
						local `list'=""
					}
				}
				/*display "`endog'"
				display "`iexog'"
				display "`exexog'"
				display "`collin'"*/
			}
		}

		* check whether there is random coefficient on price; if there is price is ordered as the first in the rc varlist
		if ("`endog'"!="") {
			local price=word("`endog'",1)
		}
		if ("`endog'"=="") {
			local price=word("`iexog'",1)
		}
		local _is_rc_on_p=0
		foreach r of local rc {
			if ("`r'"=="`price'") {
				local _is_rc_on_p=1
			}
		}
		if (`_is_rc_on_p'==1) {
			local rc0: list rc - price
			local rc `price' `rc0'
		}
		local title="Berry, Levinsohn and Pakes (BLP) random coefficient logit model"

		* price variable
		* it is assumed that price is the first endogenous variable or, if no endogenous variables specified, the first incldued exogenous variable
		if ("`endog'"!="") {
			local price=word("`endog'",1)
		}
		if ("`endog'"=="") {
			local price=word("`iexog'",1)
		}

		* number of variables
		local iexog_ct=0
		if ("`exexog'"=="") {
			local iexog `endog' `iexog'
			local endog
		}
		if ("`iexog'"!="") {
			foreach v of varlist `iexog' {
				local iexog_ct=`iexog_ct'+1
			}
		}
		local endog_ct=0
		if ("`endog'"!="") {
			foreach v of varlist `endog' {
				local endog_ct=`endog_ct'+1
			}
		}
		local exexog_ct=0
		if ("`exexog'"!="") {
			foreach v of varlist `exexog' {
				local exexog_ct=`exexog_ct'+1
			}
		}
		local iv_ct=`iexog_ct'+`exexog_ct'
		local rhs_ct=`iexog_ct'+`endog_ct'
		/*display "`dups'"
		display "`dropped'"
		display "`iexog'"
		display "`endog'"
		display "`exexog'"*/

		* variance-covariance matrix estimator
		local vcetype
		if ("`cluster'"!="") {
			local robust robust
			quietly tab `cluster'
			local N_clust=r(r)
		}
		if ("`robust'"!="") {
			local vcetype=proper("`robust'")
		}
		
		* estimator
		local estimator 2sls
		if ("`gmm2s'"!="") {
			local estimator `gmm2s'
		}
		if ("`igmm'"!="") {
			local estimator `igmm'
		}
		
		* demographic variables
		if ("`demog'"!="") {
			tempname demog_mean demog_cov
			local dm=word("`demog'",1)
			local dc=word("`demog'",2)
			matrix `demog_mean'=`dm'
			matrix `demog_cov'=`dc'
			local demog_matrices `dm' `dc'
			local demog_xvars: list demog - demog_matrices
			local lhs `endog' `iexog'
			local demog_xvars: list demog_xvars & lhs
			if ("`demog_xvars'"=="") {
				local demog
			}
		}

		* starting parameter vector (if not specified)
		*display "`market'"
		*display "`rc'"
		local nrc: list sizeof rc
		if ("`startparams'"=="") {
			if ("`demog'"!="") {
				local ndemog_xvars: list sizeof demog_xvars
				local ndemogs=rowsof(`demog_mean')
				*display `nrc'
				*display `ndemogs'
				*display `ndemog_xvars'
				local nrc=`nrc' + `ndemogs'*`ndemog_xvars'
			}
			*display `nrc'
			matrix params0=J(1,`nrc',0.12050982667055227)
			local startparams params0
		}
		*display "`startparams'"
		*matlist `startparams'

		* market size (if not specified)
		if ("`msize'"=="") {
			tempvar msize
			generate `msize'=1
		}

		* generate labelled numeric variable with elasticity groups (if elasticity option specified)
		if ("`elasticities'"!="") {
			tempname _isnumvar el_num el_str 
			mata: st_numscalar("`_isnumvar'",st_isnumvar("`elasticities'"))
			if (`_isnumvar'==0) {
				quietly generate `el_str'=`elasticities'
				quietly encode `elasticities', generate(`el_num')
			}
			if (`_isnumvar'==1) {
				quietly generate `el_num'=`elasticities'
				quietly capture decode `elasticities', generate(`el_str')
				if (_rc==182) {
					capture tostring `elasticities', generate(`el_str')
				}
			}
		}

		* additional input management for optimal instrumenting
		if ("`noestimation'"=="" & ("`optimal'"!="" & "`exexog'"!="")) {
			* prexexog: list of additional variables in the reduced form price equation (excluded exogenous variables and their polinomials)
			* the other variables in the reduced form price equation are the demand side's included exogenous variables (list "iexog")
			local prexexog `prexexog'
			foreach z of local exexog {
				tempvar __`z'2 __`z'3 __ln`z'
				quietly generate `__`z'2'=`z'^2
				quietly generate `__`z'3'=`z'^3
				quietly generate `__ln`z''=ln(`z')
				local prexexog `prexexog' `z' `__`z'2' /*`__`z'3' `__ln`z''*/
			}
			quietly ivreg2 `price' `prexexog' `iexog' if `touse'
			if ("`e(collin)'"!="") {
				local zpcollin `e(collin)'
				local prexexog: list prexexog - zpcollin
			}
		}

		* additional input management for equilibrium estimation
		if ("`noestimation'"=="" & ("`eqestimation'"!="" | "`xp'"!="")) {
			if ("`msimulation'"!="") {
				local firm=word("`msimulation'",1)
			}
			if ("`msimulation'"=="") {
				tempvar __firm __sort
				quietly generate `__sort'=_n
				sort `market', stable
				quietly by `market': generate `__firm'=_n
				local firm `__firm'
				sort `__sort', stable
			}
			* xp: list of linear regressors in the price equation (treated as included exogenous)
			* if xp is not user specified it includes the demand side included exogenous variables (iexog) and polinomials of the excluded exogenous variables (exexog)
			if ("`xp'"=="") {
				local xp `iexog'
				foreach z of local exexog {
					tempvar __`z'2 __`z'3 __ln`z'
					quietly generate `__`z'2'=`z'^2
					quietly generate `__`z'3'=`z'^3
					quietly generate `__ln`z''=ln(`z')
					local xp `xp' `__`z'2' /*`__`z'3' `__ln`z''*/
				}
			}
			* constant variable as a linear regressor (if noconstant option is not specified)
			if ("`noconstant'"=="") {
				local xp `xp' `_cns'
			}
			quietly ivreg2 `price' `xp' if `touse', nocons
			if ("`e(collin)'"!="") {
				local xpcollin `e(collin)'
				local xp: list xp - xpcollin
			}
			* pexexog: list of excluded exogenous variables (instruments) of the price equation
			* if pexexog is not user specified it is the same as the demand side excluded exogenous variables (exexog)
			local pexexog `pinstruments'
			if ("`pinstruments'"=="") {
				local pexexog `exexog'
			}
			if ("`vat'"=="") {
				tempvar vat
				generate `vat'=0
			}
			local estimator 2sls
			if ("`tsls'"!="") {
				local estimator 3sls
			}
			if ("`gmm2s'"!="") {
				local estimator `gmm2s'
			}
			if ("`igmm'"!="" | "`cue'"!="") {
				local estimator `igmm'
			}
			local title="Berry, Levinsohn and Pakes (BLP) random coefficient logit model with pricing equation"
			local _iseqstartparams=1
			if ("`eqstartparams'"=="") {
				matrix eqparams0=params0
				local eqstartparams eqparams0
				local _iseqstartparams=0
			}
			if (colsof(`eqstartparams')!=`nrc'+1) {
				matrix `eqstartparams'=J(1,`nrc',0.12349523055327649),J(1,1,-0.2433882629897722)
			}
		}

		* sigma parameters (noestimation option)
		if ("`noestimation'"!="") {
			local nrc: list sizeof rcsigmas
			matrix params0=J(1,`nrc',0)
			forvalues r=1/`nrc' {
				local rr=word("`rcsigmas'",`r')
				matrix params0[1,`r']=`rr'
			}
			local startparams params0
		}
		
		* sort varlists
		foreach l in exexog prexexog demog_xvars pexexog {
			if ("``l''"!="") {
				local `l': list sort `l'
			}
		}

		*************
		* ESTIMATION
		*************

		timer clear 1
		timer on 1
		set seed 1
		sort `market', stable
		if ("`noestimation'"!="" | ("`eqestimation'"=="" & "`xp'"=="")) {								/* demand estimation only */
			mata: estimation_blp("`share'","`iexog'","`endog'","`exexog'","`prexexog'","`rc'","`market'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","`estimator'","`optimal'","`integrationmethod'","`accuracy'","`draws'","`itol'","`imaxiter'","`startparams'",`alpha',"`aelast'","`xb0'","`ksi'","`robust'","`cluster'","`touse'","`el_num'","`prices'","`rc_prices'",`_is_rc_on_p',"`noestimation'","`nodisplay'")
			if ("`optimal'"!="" & "`exexog'"!="") {
				matrix b_nonoptimal=b
				matrix V_nonoptimal=V
				local j=j
				local jp=jp
				local jdf=jdf
				local exexog
				foreach v of varlist __optik* __optip {
					local exexog `exexog' `v'
				}
				sort `market' `firm', stable
				matrix params0=b[1,1..`nrc']
				forvalues i=1/`nrc' {																	/* set (near) zero starting parameter values to non-zero */
					local ii=params0[1,`i']
					if (`ii'==0 | abs(`ii')<0.00001) {
						matrix params0[1,`i']=0.12349523055327649
					}
				}
				mata: estimation_blp("`share'","`iexog'","`endog'","`exexog'","","`rc'","`market'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","2sls","","`integrationmethod'","`accuracy'","`draws'","`itol'","`imaxiter'","`startparams'",`alpha',"`aelast'","`xb0'","`ksi'","`robust'","`cluster'","`touse'","`el_num'","`prices'","`rc_prices'",`_is_rc_on_p',"`noestimation'","`nodisplay'")
				scalar j_firststep=`j'
				scalar jp_firststep=`jp'
				scalar jdf_firststep=`jdf'
			}
		}
		if ("`noestimation'"=="" & ("`eqestimation'"!="" | "`xp'"!="")) {								/* equilibrium system estimation (demand + pricing equations) */
			sort `market' `firm', stable
			mata: estimation_blp("`share'","`iexog'","`endog'","`exexog'","`prexexog'","`rc'","`market'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","gmm2s","`optimal'","`integrationmethod'","`accuracy'","`draws'","`itol'","`imaxiter'","`startparams'",`alpha',"`aelast'","`xb0'","`ksi'","robust","`cluster'","`touse'","","`prices'","`rc_prices'",`_is_rc_on_p',"`noestimation'","`nodisplay'")
			if (`_iseqstartparams'==0) {
				matrix params0=b[1,1..`nrc'+1]
				matrix eqparams0=params0
			}
			forvalues i=1/`nrc' {																		/* set (near) zero starting parameter values to non-zero */
				local ii=eqparams0[1,`i']
				if (`ii'==0 | abs(`ii')<0.00001) {
					matrix eqparams0[1,`i']=0.12349523055327649
				}
			}
			mata: estimation_blp_eq("`share'","`iexog'","`xp'","`endog'","`exexog'","`pexexog'","`prexexog'","`rc'","`market'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","`firm'","`vat'","`estimator'","`optimal'","`integrationmethod'","`accuracy'","`draws'","`itol'","`imaxiter'","`eqstartparams'","__delta","`robust'","`cluster'","`touse'","`el_num'","`prices'","`rc_prices'",`_is_rc_on_p',"`nodisplay'")
			if ("`optimal'"!="" & "`exexog'"!="") {
				matrix b_nonoptimal=b
				matrix V_nonoptimal=V
				local exexog
				foreach v of varlist __optiek* __optiep {
					local exexog `exexog' `v'
				}
				local pexexog
				foreach v of varlist __optiep __optieo* {
					local pexexog `pexexog' `v'
				}
				sort `market' `firm', stable
				matrix eqparams0=b[1,1..`nrc'+1]
				forvalues i=1/`nrc' {																	/* set (near) zero starting parameter values to non-zero */
					local ii=eqparams0[1,`i']
					if (`ii'==0 | abs(`ii')<0.00001) {
						matrix eqparams0[1,`i']=0.12349523055327649
					}
				}
				mata: estimation_blp_eq("`share'","`iexog'","`xp'","`endog'","`exexog'","`pexexog'","","`rc'","`market'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","`firm'","`vat'","`estimator'","","`integrationmethod'","`accuracy'","`draws'","`itol'","`imaxiter'","`eqstartparams'","__delta","`robust'","`cluster'","`touse'","`el_num'","`prices'","`rc_prices'",`_is_rc_on_p',"`nodisplay'")
			}
			local exexog `exexog' `pexexog'
			local exexog: list uniq exexog
		}
		timer off 1
		quietly timer list
		local estimation_time=r(t1)
		local estimation_time_ms=msofseconds(r(t1))

		******************
		* POSTING INTO e()
		******************
		
		if ("`noestimation'"=="") {
			ereturn post b V, esample(`touse')
			ereturn scalar estimation_time=`estimation_time'
			ereturn scalar estimation_time_ms=`estimation_time_ms'
			quietly count if e(sample)
			ereturn scalar N=r(N)
			if ("`cluster'"!="") {
				ereturn scalar N_clust=`N_clust'
				ereturn local clustvar="`cluster'"
			}
			ereturn scalar j=j
			ereturn scalar jp=jp
			ereturn scalar jdf=jdf
			if ("`optimal'"!="" & "`exexog'"!="") {
				ereturn scalar j_firststep=j_firststep
				ereturn scalar jp_firststep=jp_firststep
				ereturn scalar jdf_firststep=jdf_firststep
			}
			ereturn scalar F=F
			ereturn scalar Fp=Fp
			ereturn scalar Fdf1=Fdf1
			ereturn scalar Fdf2=Fdf2
			ereturn scalar r2=r2
			ereturn scalar r2_a=r2_a
			if ("`eqestimation'"!="" | "`xp'"!="") {
				ereturn scalar r2_d=r2_d
				ereturn scalar r2_p=r2_p
				ereturn scalar r2_a_d=r2_a_d
				ereturn scalar r2_a_p=r2_a_p
			}
			ereturn local vcetype="`vcetype'"
			ereturn local endog `endog'
			ereturn local iexog `iexog'
			ereturn local exexog `exexog'
			ereturn local rc `rc'
			ereturn local market="`market'"
			ereturn local share="`share'"
			ereturn local dups="`dups'"
			ereturn local collin="`collin'"
			ereturn local estimator="`estimator'"
			if ("`estimator'"=="2sls") {
				ereturn local estimator_name="Non-linear 2SLS estimation"
				if (`exexog_ct'==0) {
					ereturn local estimator_name="Non-linear OLS estimation"
					ereturn local estimator="nols"
				}
			}
			if ("`estimator'"=="3sls") {
				ereturn local estimator_name="Non-linear 3SLS estimation"
				if (`exexog_ct'==0) {
					ereturn local estimator_name="Non-linear SUR estimation"
					ereturn local estimator="nsur"
				}
			}
			if ("`estimator'"=="gmm2s") {
				ereturn local estimator_name="Non-linear 2-Step GMM estimation"
				if (`exexog_ct'==0) {
					ereturn local estimator_name="Non-linear GLS estimation"
					ereturn local estimator="ngls"
				}
			}
			if ("`estimator'"=="igmm") {
				ereturn local estimator_name="Iterated non-linear GMM estimation"
				if (`exexog_ct'==0) {
					ereturn local estimator_name="Iterated non-linear GLS estimation"
					ereturn local estimator="ingls"
				}
			}
			if ("`optimal'"!="" & "`exexog'"!="") {
				local estimator_name="`e(estimator_name)'"
				local _minus estimation
				local estimator_name: list estimator_name - _minus
				local estimator_name "`estimator_name' with optimal instruments"
				ereturn local estimator_name="`estimator_name'"
				ereturn matrix b_nonoptimal=b_nonoptimal
				ereturn matrix V_nonoptimal=V_nonoptimal
			}
		}
		if ("`noestimation'"!="" & "`aelast'"!="") {
			// resetting market size and shares consistent with pre-defined aggregate elasticity (only in no-estimation mode with the aelast option is specified)
			tempvar msize share
			quietly generate `msize'=__msize
			quietly generate `share'=__s
		}
		ereturn local title="`title'"
		local dmodel blp
		ereturn local dmodel="`dmodel'"
		
		*************************
		* RANKTEST (from ivreg2)
		*************************
		
		if ("`noestimation'"=="") {
			rranktest , endog(`endog') iexog(`iexog') exexog(`exexog') exexog_ct(`exexog_ct') endog_ct(`endog_ct') rhs_ct(`rhs_ct') iv_ct(`iv_ct') robust(`robust') cluster(`cluster') noconstant(`noconstant')
		}

		******************
		* DISPLAY RESULTS
		******************

		if ("`noestimation'"=="") {
			if ("`nodisplay'"=="") {
				display_results , exexog_ct(`exexog_ct') endog_ct(`endog_ct') elasticities(`elasticities') el_str(`el_str')
			}
			if ("`nodisplay'"!="") {
				if ("`elasticities'"!="") {
					quietly levelsof `el_str' if e(sample), local(elabels) clean
					matrix colnames el = `elabels'
					matrix rownames el = `elabels'
					matrix colnames dr = `elabels'
					matrix rownames dr = `elabels'
					ereturn matrix el=el
					ereturn matrix dr=dr
				}
			}
		}
		if ("`noestimation'"!="") {
			if (`alpha'==.) {
				capture local alpha=alpha
			}
			matrix b=params0,J(1,1,-`alpha'),J(1,1,1)
			ereturn post b, esample(`touse')
			tempvar touse
			quietly generate `touse'=(e(sample))
			ereturn local title="`title'"
			ereturn local dmodel="`dmodel'"
			if ("`nodisplay'"=="") {
				display "`title'"
			}
			if ("`elasticities'"!="") {
				quietly levelsof `el_str' if e(sample), local(elabels) clean
				matrix colnames el = `elabels'
				matrix rownames el = `elabels'
				matrix colnames dr = `elabels'
				matrix rownames dr = `elabels'
				ereturn matrix el=el
				ereturn matrix dr=dr
				if ("`nodisplay'"=="") {
					display ""
					display in gr "Estimated average elasticities (by `elasticities')"
					matlist e(el), format(%10.1f)
					display ""
					display in gr "Estimated average diversion ratios (by `elasticities')"
					matlist e(dr), format(%10.0f)
				}
			}
		}

		********************
		* MERGER SIMULATION
		********************

		if (("`msimulation'"!="" & wordcount("`msimulation'")>1) | ("`msimulation'"!="" & "`onlymc'"!="") | ("`msimulation'"!="" & "`noestimation'"!="") | "`ssnip'"!="") {
			timer clear 1
			timer on 1
			set seed 1
			if ("`onlymc'"=="" & "`msimulation'"!="") {
				if ("`nodisplay'"=="") {
					display ""
					display in gr "Merger simulation"
				}
			}
			local iexogm `iexog'
			local p=word("`endog'",1)
			if ("`endog'"=="") {
				local p=word("`iexog'",1)
				local iexogm: list iexog -p
			}
			if (wordcount("`endog'")>1) {
				local endog_other: list endog - p
				local iexogm `endog_other' `iexogm'
			}
			if ("`noestimation'"!="") {
				local iexogm __xb0
			}
			if ("`msimulation'"!="") {
				local firm=word("`msimulation'",1)
				if (wordcount("`msimulation'")>1) {
					local firm_post=word("`msimulation'",2)
				}
				if (wordcount("`msimulation'")==1) {
					local firm_post `firm'
				}
			}
			if ("`ssnip'"!="") {
				local segment=word("`ssnip'",1)
				tempvar _isnumvar segment_num segment_str 
				mata: st_numscalar("`_isnumvar'",st_isnumvar("`segment'"))
				if (`_isnumvar'==0) {
					quietly generate `segment_str'=`segment'
					quietly encode `segment', generate(`segment_num')
				}
				if (`_isnumvar'==1) {
					quietly generate `segment_num'=`segment'
					capture quietly decode `segment', generate(`segment_str')
					if (_rc==182) {
						capture quietly tostring `segment', generate(`segment_str')
					}
				}
				if ("`msimulation'"=="") {
					local firm=word("`ssnip'",2)
					local firm_post `firm'
					if ("`onlymc'"=="") {
						local onlymc onlymc
					}
				}
			}
			local xb0 __xb0
			local ksi __ksi
			local delta __delta
			local b e(b)
			tempvar touse
			quietly generate `touse'=(e(sample))
			if ("`vat'"=="") {
				tempvar vat
				generate `vat'=0
			}
			mata: mata drop beta simdraws params
			* call merger simulation function
			mata: merger_simulation_blp("`b'","`market'","`firm'","`firm_post'","`p'","`share'","`iexogm'","`xb0'","`ksi'","`delta'","`rc'","`demog_mean'","`demog_cov'","`demog_xvars'","`msize'","`mc'","`vat'","`segment_num'","`integrationmethod'","`accuracy'","`draws'","`onlymc'","`nodisplay'","`cmce'","`touse'",`_is_rc_on_p')
			timer off 1
			quietly timer list
			local computation_time_msimul=r(t1)
			local time_ms=msofseconds(r(t1))
			ereturn scalar computation_time_msimul=`computation_time_msimul'
			* display results
			if ("`nodisplay'"=="") {
				if ("`onlymc'"=="") {
					display ""
					tempname _isnumvar firm_num firm_str
					mata: st_numscalar("`_isnumvar'",st_isnumvar("`firm'"))
					if (`_isnumvar'==0) {
						quietly generate `firm_str'=`firm'
						quietly encode `firm', generate(`firm_num')
					}
					if (`_isnumvar'==1) {
						quietly generate `firm_num'=`firm'
						capture decode `firm', generate(`firm_str')
						if (_rc==182) {
							capture tostring `firm', generate(`firm_str')
						}
					}
					preserve
						tempvar pmarket __mc
						quietly bys `market': egen `pmarket'=max(abs(__foc_post)) if e(sample)
						quietly replace `pmarket'=(`pmarket'>0.027)
						if ("`mc'"=="") {
							quietly generate `__mc'=__mc
						}
						if ("`mc'"!="") {
							quietly generate `__mc'=`mc'
							capture confirm variable __mrkp
							if (_rc==0) {
								capture drop __mrkp
							}
							quietly generate __mrkp=(`p'/(1+`vat'))-`__mc' if e(sample)
						}
						quietly keep if e(sample) & __p_post!=. & __foc_post!=. & __s_post!=. & `pmarket'==0 & `__mc'>0 & `__mc'<=`p' & __mrkp>=0 & __mrkp<=`p'
						quietly count
						if (r(N)>0) {
							tempname q
							capture drop `q'
							quietly generate `q'=`share'*`msize'
							* weighting by "quantity"
							quietly replace __mrkp=__mrkp*`q'
							quietly replace `p'=`p'*`q'
							quietly replace __p_post=__p_post*`q'
							local nmce=0
							if ("`cmce'"!="") {
								* compensating marginal cost efficiencies
								tempname dmc mce
								capture drop `dmc'
								quietly generate `mce'=(`__mc'-__mce)*`q'
								local nmce=1
								local cnmce cmp
								local tmce , compensating marginal cost reduction
							}
							* results aggregated to the level of "firms"
							collapse (sum) `p' __p_post __mrkp `q' `mce', by(`firm_str')
							quietly replace `p'=`p'/`q'
							quietly replace __p_post=__p_post/`q'
							quietly replace __mrkp=100*__mrkp/(`p'*`q')
							quietly generate dp=100*(__p_post-`p')/`p'
							if ("`cmce'"!="") {
								quietly replace `mce'=100*`mce'/(`p'*`q')
							}
							mkmat dp __mrkp `mce' `p', matrix(dp) rownames(`firm_str')
							local rnames: rowfullnames dp
							quietly replace `p'=`p'*`q'
							quietly replace __p_post=__p_post*`q'
							quietly replace __mrkp=__mrkp*`p'/100
							* results aggregated to overall level
							collapse (sum) `p' __p_post __mrkp `q'
							quietly replace `p'=`p'/`q'
							quietly replace __p_post=__p_post/`q'
							quietly replace __mrkp=100*__mrkp/(`p'*`q')
							quietly generate dp=100*(__p_post-`p')/`p'
							mkmat dp __mrkp, matrix(dp_overall)
							matrix dp_overall=dp_overall,J(1,1+`nmce',.)
							* combining results into one display matrix and displaying
							matrix dp=dp\dp_overall
							local rnames `rnames' overall
							matrix rownames dp = `rnames'
							matrix colnames dp = dp mrg `cnmce' p
							display ""
							display "Predicted price changes, pre-merger implied margin`tmce' (%) and price"
							matlist dp, format(%6.1f) linesize(100)
							scalar dp=dp[rowsof(dp),1]
							ereturn scalar dp=dp
						}
					restore
				}
			}
			if ("`ssnip'"!="") {
				* performing SSNIP tests
				quietly levelsof `segment_str', local(ssegments) clean
				local ns: list sizeof ssegments
				matrix rownames ssnip = `ssegments'
				matrix colnames ssnip = 1% 5% 10%
				if ("`nodisplay'"=="") {
					display ""
					display "SSNIP test of groups (% change in group's total profit due to a 1-5-10% price increase)"
					matlist ssnip, format(%8,1f)
				}
				ereturn matrix ssnip=ssnip
			}
			if ("`nodisplay'"=="") {
				di in gr "Computation time: " %1.0f = hh(`time_ms') "h " %1.0f = mm(`time_ms') "m " %4.3f = ss(`time_ms') "s"
			}
		}

	}	/* end of BLP model */

	/* Nested logit models */
	if ("`model'"=="nlogit") {

		********************
		* COLLECTING INPUTS
		********************
	
		* varlists
		* creating locals with varlists from the main command line (i.e., the user specified content after the rcl command and before the sample if condition or option comma)
		* locals created:
		*	share	share variable
		*	iexog	list of included right hand side exogenous variables
		*	exexog	list of excluded right hand side exogenous variables ("instruments")
		*	endog	list of endogenous right hand side variables
		local length: list sizeof anything
		local iexog
		local exexog
		local endog
		local n=0
		local inbracket=0
		local aftereq=0
		local iiendog=0
		local iiexexog=0
		forvalues i=1/`length' {
			*display "``i''"
			if (`i'==1) {
				local share "``i''"
			}
			if (`i'>1) {
				local name="``i''"
				local cpos=strpos("`name'",",")
				if (`cpos'!=0) {
					local name=substr("`name'",1,`cpos'-1)
				}
				if (substr("`name'",1,1)=="(") {
					local inbracket=1
					local name=substr("`name'",2,.)
				}
				if (`inbracket'==1) {
					local eqpos=strpos("`name'","=")
					if (`eqpos'!=0) {
						local aftereq=1
						local name_preeq=substr("`name'",1,`eqpos'-1)
						local name_posteq=substr("`name'",`eqpos'+1,.)
						local endog `endog' `name_preeq'
						local exexog `exexog' `name_posteq'
					}
					if (`aftereq'==0 & `eqpos'==0) {
						local endog `endog' `name'
					}				
					if (`aftereq'==1 & `eqpos'==0) {
						if (substr("`name'",-1,.)==")") {
							local inbracket=0
							local name=substr("`name'",1,length("`name'")-1)
						}
						local exexog `exexog' `name'
					}
					if (substr("`endog'",-1,.)==")") {
						local es=substr("`endog'",-1,.)
						local endog: list endog - es
					}					
				}
				if (`inbracket'==0) {
					local iexog `iexog' `name'
					local iexog: list iexog - exexog
				}
			
			}		
		}

		* expanding wildcards, removing duplicates
		if ("`iexog'"!="") {
			local iexog0
			foreach v of varlist `iexog' {
				local iexog0 `iexog0' `v'
			}
			local iexog `iexog0'
		}
		if ("`endog'"!="") {
			local endog0
			foreach v of varlist `endog' {
				local endog0 `endog0' `v'
			}
			local endog `endog0'
		}
		if ("`exexog'"!="") {
			local exexog0
			foreach v of varlist `exexog' {
				local exexog0 `exexog0' `v'
			}
			local exexog `exexog0'
		}
		local opartial
		if ("`partial'"!="") {
			local opartial partial(`partial')
			local iexog: list iexog - partial
			local endog: list endog - partial
			if ("`exexog'"!="") {
				local exexog: list exexog - partial
			}			
		}
		/*display "`share'"
		display "`iexog'"
		display "`endog'"
		display "`exexog'"*/

		* excluding observations with non-positive share from work sample
		quietly replace `touse'=0 if `share'<=0 | `share'==.

		* market size
		if ("`msize'"=="") {
			tempvar msize
			generate `msize'=1
		}

		* check ivreg2 is installed (for estimation)
		if ("`noestimation'"=="") {
			capture ivreg2, version
			if _rc != 0 {
				noisily di as err "Error: must have the command ivreg2 installed"
				noisily di as err "To install, type into the Stata command line " _c
				noisily di in smcl "{stata ssc install ivreg2 :ssc install ivreg2}"
				exit 601
			}
		}

		* setting market size and shares consistent with pre-defined aggregate elasticity (only in no-estimation mode when the aelast option is specified)
		if ("`noestimation'"!="" & "`aelast'"!="") {
			if ("`exexog'"=="") {
				local price=word("`iexog'",1)
			}
			if ("`exexog'"!="") {
				local price=word("`endog'",1)
			}
			tempvar q tq __msize __s
			local aelast=-abs(`aelast')
			quietly generate `q'=`share'*`msize' if `touse'
			quietly sum `price' [aweight=`q'] if `touse'
			local ap=r(mean)
			quietly bys `market': egen `tq'=total(`q') if `touse'
			quietly sum `tq' if `touse'
			local mtq=r(mean)
			quietly generate `__msize'=`alpha'*`mtq'*`ap'/(`aelast'+`alpha'*`ap') if `touse'
			quietly generate `__s'=`q'/`__msize' if `touse'
			capture confirm new variable __msize
			if (_rc!=0) {
				capture drop __msize
			}
			capture confirm new variable __s
			if (_rc!=0) {
				capture drop __s
			}
			quietly generate __msize=`__msize'
			quietly generate __s=`__s'
			local msize `__msize'
			local share `__s'
		}

		* share of outside good, left hand side variable, quantity
		tempvar ts s0 q
		quietly bys `market': egen `ts'=total(`share') if `touse'
		quietly generate `s0'=1-`ts' if `touse'
		quietly generate `q'=`share'*`msize' if `touse'
		capture drop __lnss0
		quietly generate __lnss0=ln(`share')-ln(`s0') if `touse'						/* left hand side variable (mean utility) */
		capture drop __delta
		quietly generate __delta=ln(`share')-ln(`s0') if `touse'						/* mean utility */
		local lnss0 __lnss0

		* nests, within-nest shares
		local nnests=wordcount("`nests'")
		if (`nnests'==0) {
			local dmodel logit
			local title="Simple logit model"
		}
		if (`nnests'==1) {
			local dmodel nlogit
			tempvar qg sjg
			local g=word("`nests'",1)
			quietly bys `market' `g': egen `qg'=total(`q') if `touse'
			quietly generate `sjg'=`q'/`qg' if `touse'
			capture drop __sigma_g
			quietly generate __sigma_g=ln(`sjg') if `touse'									/* within-nest share */
			local lnsjg __sigma_g
			local endog `endog' `lnsjg'
			local title="One-level nested logit model, nesting by `g'"
		}
		if (`nnests'==2) {
			local dmodel nlogit`nnests'
			tempvar qg qhg sjg sjh shg
			local g=word("`nests'",1)
			local h=word("`nests'",2)
			quietly bys `market' `g': egen `qg'=total(`q') if `touse'
			quietly bys `market' `h' `g': egen `qhg'=total(`q') if `touse'
			quietly generate `sjh'=`q'/`qhg' if `touse'
			quietly generate `shg'=`qhg'/`qg' if `touse'
			capture drop __sigma_hg
			quietly generate __sigma_hg=ln(`sjh') if `touse'									/* within-subnest share */
			local lnsjh __sigma_hg
			capture drop __sigma_g
			quietly generate __sigma_g=ln(`shg') if `touse'										/* within-nest share */
			local lnshg __sigma_g
			local endog `endog' `lnshg' `lnsjh'
			local title="Two-level nested logit model, nesting by `g' and `h'"
		}
		if (`nnests'>=3) {
			if (`nnests'>3) {
				local nests=word("`nests'",1)+" "+word("`nests'",2)+" "+word("`nests'",3)
				local nnests=wordcount("`nests'")			
			}
			local dmodel nlogit`nnests'
			tempvar qg qhg qkhg sjg sjh sjk skh shg lnsjk lnskh lnshg
			local g=word("`nests'",1)
			local h=word("`nests'",2)
			local k=word("`nests'",3)
			quietly bys `market' `g': egen `qg'=total(`q') if `touse'
			quietly bys `market' `h' `g': egen `qhg'=total(`q') if `touse'
			quietly bys `market' `k' `h' `g': egen `qkhg'=total(`q') if `touse'
			quietly generate `sjk'=`q'/`qkhg' if `touse'
			quietly generate `skh'=`qkhg'/`qhg' if `touse'
			quietly generate `shg'=`qhg'/`qg' if `touse'
			capture drop __sigma_khg
			quietly generate __sigma_khg=ln(`sjk')	 if `touse'							/* within-subsubnest share */
			local lnsjk __sigma_khg
			capture drop __sigma_hg
			quietly generate __sigma_hg=ln(`skh') if `touse'							/* within-subnest share */
			local lnskh __sigma_hg
			capture drop __sigma_g
			quietly generate __sigma_g=ln(`shg') if `touse'								/* within-nest share */
			local lnshg __sigma_g
			local endog `endog' `lnshg' `lnskh' `lnsjk'
			local title="Three-level nested logit model, nesting by `g', `h' and `k'"
		}
		/*display "`nests'"
		display "`nnests'"
		display "`dmodel'"*/

		* make sure that price is ordered as the first in the regeressor varlist
		* it is assumed that price is the first endogenous variable or, if no endogenous variables specified, the first incldued exogenous variable
		if ("`exexog'"=="") {
			local price=word("`iexog'",1)
			local iexog: list iexog - price
			local endog `price' `endog'
		}
		/*display "`share'"
		display "`iexog'"
		display "`endog'"
		display "`exexog'"*/

		* additional input management for optimal instrumenting, and calculating optimal instruments for single equation estimation
		if ("`noestimation'"=="" & ("`optimal'"!="" & "`exexog'"!="") & `nnests'!=0) {
			* prexexog: list of additional variables in the reduced form price equation (excluded exogenous variables and their polinomials)
			* the other variables in the reduced form price equation are the demand side's included exogenous variables (list "iexog")
			local prexexog `prexexog'
			foreach z of local exexog {
				tempvar __`z'2 __`z'3 __ln`z'
				quietly generate `__`z'2'=`z'^2
				quietly generate `__`z'3'=`z'^3
				quietly generate `__ln`z''=ln(`z')
				local prexexog `prexexog' `__`z'2' /*`__`z'3' `__ln`z''*/
			}
			quietly ivreg2 `price' `prexexog' `iexog' if `touse'
			if ("`e(collin)'"!="") {
				local zpcollin `e(collin)'
				local prexexog: list prexexog - zpcollin
			}
			* calculating optimal instruments for single equation estimation
			if ("`eqestimation'"=="" & "`xp'"=="") {
				local iexogo `iexog'
				if ("`noconstant'"=="") {
					tempvar _cns
					quietly generate byte `_cns' = 1 if `touse'
					local iexogo `iexogo' `_cns'
				}
				capture drop __optika
				capture drop __optiks*
				mata: opti_nlogit("`share'","`iexogo'","`endog'","`exexog'","`prexexog'","`g'","`h'","`k'","`market'","`msize'","`estimator0'","`robust'","`cluster'","`touse'")
				local exexog
				foreach v of varlist __optiks* __optika {
					local exexog `exexog' `v'
				}
			}
		}

		* additional input management for equilibrium estimation
		if ("`noestimation'"=="" & ("`eqestimation'"!="" | "`xp'"!="")) {
			if ("`msimulation'"!="") {
				local firm=word("`msimulation'",1)
			}
			if ("`msimulation'"=="") {
				tempvar __firm __sort
				quietly generate `__sort'=_n
				sort `market', stable
				quietly by `market': generate `__firm'=_n
				local firm `__firm'
				sort `__sort', stable
			}
			* xp: list of linear regressors in the price equation (treated as included exogenous)
			* if xp is not user specified it includes the demand side included exogenous variables (iexog) and polinomials of the excluded exogenous variables (exexog)
			if ("`xp'"=="") {
				local xp `iexog'
				foreach z of local exexog {
					tempvar __`z'2
					quietly generate `__`z'2'=`z'^2
					local xp `xp' `__`z'2'
				}
			}
			local price=word("`iexog'",1)
			quietly xi: ivreg2 `price' `endog' `xp' if `touse'
			local dups `e(dups)'
			local collin `e(collin)'
			if ("`exexog'"=="") {
				quietly xi: ivreg2 `lnss0' `endog' `iexog' if `touse', `robust' `ocluster' `noconstant' `opartial'
			}
			if ("`exexog'"!="") {
				quietly xi: ivreg2 `lnss0' `iexog' (`endog' = `exexog') if `touse', `robust' `ocluster' `noconstant' `opartial'
			}
			if ("`noconstant'"=="") {
				tempvar _cns
				quietly generate byte `_cns' = 1 if `touse'
				local iexog `iexog' `_cns'
				local xp `xp' `_cns'
			}
			local iexog: list uniq iexog
			local iexog: list iexog - collin
			local endog: list uniq endog
			local endog: list endog - collin
			local exexog: list uniq exexog
			local exexog: list exexog - collin
			local xp: list uniq xp
			local xp: list xp - collin
			local dups `dups' `e(dups)'
			local dups: list uniq dups
			local collin `collin' `e(collin)'
			local collin: list uniq collin
			* pexexog: list of excluded exogenous variables (instruments) of the price equation
			* if pexexog is not user specified, using the pinstruments() option, it is the same as the demand side excluded exogenous variables (exexog)
			local pexexog `pinstruments'
			if ("`pinstruments'"=="") {
				local pexexog `exexog'
			}
			quietly ivreg2 `price' `pexexog' `xp' if `touse', noconstant
			local pcollin `e(collin)'
			local pexexog: list pexexog - pcollin
			local xp: list xp - pcollin
			local dups `dups' `e(dups)'
			local dups: list uniq dups
			local collin `collin' `e(collin)'
			local collin: list uniq collin
			if ("`nodisplay'"=="") {
				if ("`dups'"!="") {
					di in gr "Warning - duplicate variables detected"
					di in gr "Duplicates: " _c
					disp "`dups'", _col(21)
				}
				if ("`collin'" != "") {
					di in gr "Warning - collinearities detected"
					local mlength=78
					local tab=23
					local init "Vars dropped:        "
					dispbreak , initial("`init'") todisplay("`collin'") mlength(78) tab(23)
				}
			}
			local iexog_ct=0
			if ("`iexog'"!="") {
				foreach v of varlist `iexog' `xp' {
					local iexog_ct=`iexog_ct'+1
				}
			}
			local endog_ct=0
			if ("`endog'"!="") {
				foreach v of varlist `endog' {
					local endog_ct=`endog_ct'+1
				}
			}
			local exexog_ct=0
			if ("`exexog'"!="") {
				foreach v of varlist `exexog' {
					local exexog_ct=`exexog_ct'+1
				}
			}
			local iv_ct=`iexog_ct'+`exexog_ct'
			local rhs_ct=`iexog_ct'+`endog_ct'
			local vcetype
			if ("`cluster'"!="") {
				local robust robust
				quietly tab `cluster'
				local N_clust=r(r)
			}
			if ("`robust'"!="") {
				local vcetype=proper("`robust'")
			}
			if ("`vat'"=="") {
				tempvar vat
				generate `vat'=0
			}
			local estimator0 2sls
			if ("`tsls'"!="") {
				local estimator0 3sls
			}
			if ("`gmm2s'"!="") {
				local estimator0 `gmm2s'
			}
			if ("`igmm'"!="" | "`cue'"!="") {
				local estimator0 `igmm'
			}
			quietly xi: ivreg2 `lnss0' `iexog' (`endog' = `exexog' `pexexog') if `touse', `robust' `ocluster' `noconstant' `opartial'
			local cdf=e(cdf)
			local cd=e(cd)
			local idstat=e(idstat)
			local idp=e(idp)
			local iddf=e(iddf)
			local widstat=e(widstat)
			if (`nnests'==0) {
				local title="Simple logit model with pricing equation"
			}
			if (`nnests'==1) {
				local title="One-level nested logit model with pricing equation, nesting by `g'"
			}
			if (`nnests'==2) {
				local title="Two-level nested logit model with pricing equation, nesting by `g' and `h'"
			}
			if (`nnests'>=3) {
				local title="Three-level nested logit model with pricing equation, nesting by `g', `h' and `k'"
			}
		}

		* sigma parameters (noestimation option)
		if ("`noestimation'"!="") {
			if (wordcount("`sigmas'")!=0) {
				if (wordcount("`sigmas'")>=1) {
					local sigmag=word("`sigmas'",1)
				}
				if (wordcount("`sigmas'")>=2) {
					local sigmah=word("`sigmas'",2)
				}
				if (wordcount("`sigmas'")>=3) {
					local sigmak=word("`sigmas'",3)
				}
			}
		}

		* sort varlists
		foreach l in exexog prexexog demog_xvars {
			if ("``l''"!="") {
				local `l': list sort `l'
			}
		}

		*************
		* ESTIMATION
		*************

		if ("`noestimation'"=="") {
			* estimation options
			local estimator
			if ("`gmm2s'"!="") {
				local estimator `gmm2s'
			}
			if ("`cue'"!="" | "`igmm'"!="") {
				local estimator cue
			}
			if ("`exexog'"=="") {
				local estimator		
			}
			if ("`cluster'"!="") {
				local ocluster cluster(`cluster')
			}
			local eoptions title("`title'") `estimator' `robust' `ocluster' `nocollin' `noconstant' `opartial'
			local quiet
			if ("`nodisplay'"!="") {
				local quiet quietly
			}
			* estimation
			timer clear 1
			timer on 1
			sort `obs', stable
			if ("`eqestimation'"=="" & "`xp'"=="") {												/* demand estimation only */
				if ("`exexog'"=="") {
					`quiet' xi: ivreg2 `lnss0' `endog' `iexog' if `touse', `eoptions'
				}
				if ("`exexog'"!="") {
					`quiet' xi: ivreg2 `lnss0' `iexog' (`endog' = `exexog') if `touse', `eoptions'
				}
			}
			if ("`eqestimation'"!="" | "`xp'"!="") {												/* equilibrium system estimation (demand + pricing equations) */
				mata: estimation_nlogit_eq("`share'","`iexog'","`xp'","`endog'","`exexog'","`pexexog'","`prexexog'","`g'","`h'","`k'","`market'","`msize'","`firm'","`vat'","`startparams'","`estimator0'","`optimal'","`robust'","`cluster'","`touse'","`nodisplay'")
				if ("`optimal'"!="" & "`exexog'"!="") {
					if (`nnests'!=0) {
						local optieks __optieks*
						local optieos __optieos*
					}
					local exexog
					foreach v of varlist `optieks' __optiep {
						local exexog `exexog' `v'
					}
					local pexexog
					foreach v of varlist `optieos' __optiep {
						local pexexog `pexexog' `v'
					}
					matrix params0=b[1,1..`endog_ct']
					local startparams params0
					sort `market' `firm', stable
					mata: estimation_nlogit_eq("`share'","`iexog'","`xp'","`endog'","`exexog'","`pexexog'","","`g'","`h'","`k'","`market'","`msize'","`firm'","`vat'","`startparams'","`estimator0'","","`robust'","`cluster'","`touse'","`nodisplay'")
					quietly xi: ivreg2 `lnss0' `iexog' (`endog' = `exexog' `pexexog') if `touse', `robust' `ocluster' `noconstant' `opartial'
					local cdf=e(cdf)
					local cd=e(cd)
					local idstat=e(idstat)
					local idp=e(idp)
					local iddf=e(iddf)
					local widstat=e(widstat)
				}
				local exexog `exexog' `pexexog'
				local exexog: list uniq exexog
			}
			timer off 1
			quietly timer list
			local estimation_time=r(t1)
			local estimation_time_ms=msofseconds(r(t1))
			ereturn scalar estimation_time=`estimation_time'
			if ("`eqestimation'"=="" & "`xp'"=="") {												/* demand estimation only */
				ereturn local vcetype="`vcetype'"
				ereturn local endog `endog'
				ereturn local iexog `iexog'
				ereturn local xp `xp'
				ereturn local exexog `exexog'
				ereturn local market="`market'"
				ereturn local share="`share'"
				ereturn local dups="`dups'"
				ereturn local collin="`collin'"
				if ("`estimator'"=="2sls" | "`estimator'"=="") {
					ereturn local estimator_name="2SLS estimation"
					if ("`exexog'"=="") {
						ereturn local estimator_name="OLS estimation"
						ereturn local estimator="ols"
					}
				}
				if ("`estimator'"=="gmm2s") {
					ereturn local estimator_name="2-Step GMM estimation"
					if ("`exexog'"=="") {
						ereturn local estimator_name="OLS estimation"
						ereturn local estimator="ols"
					}
				}
				if ("`estimator'"=="igmm" | "`estimator'"=="cue") {
					ereturn local estimator_name="CUE GMM estimation"
					if ("`exexog'"=="") {
						ereturn local estimator_name="OLS estimation"
						ereturn local estimator="ols"
					}
				}
				capture drop __ksi
				capture drop __xb0
				local p=word("`endog'",1)
				quietly predict __ksi, res
				quietly generate __xb0=__lnss0-__ksi
				quietly replace __xb0=__xb0-_b["`p'"]*`p'
				if ("`dmodel'"=="nlogit") {
					quietly replace __xb0=__xb0-_b["`lnsjg'"]*`lnsjg'
				}
				if ("`dmodel'"=="nlogit2") {
					quietly replace __xb0=__xb0-_b["`lnshg'"]*`lnshg'-_b["`lnsjh'"]*`lnsjh'
				}
				if ("`dmodel'"=="nlogit3") {
					quietly replace __xb0=__xb0-_b["`lnshg'"]*`lnshg'-_b["`lnskh'"]*`lnskh'-_b["`lnsjk'"]*`lnsjk'
				}
				if ("`nodisplay'"=="") {
					di in gr "Estimation time: " %1.0f = hh(`estimation_time_ms') "h " %1.0f = mm(`estimation_time_ms') "m " %1.0f = ss(`estimation_time_ms') "s"
				}
			}
			if ("`eqestimation'"!="" | "`xp'"!="") {
				* posting into e() (if equilibrium system estimation)
				ereturn post b V, esample(`touse')
				ereturn scalar estimation_time=`estimation_time'
				ereturn scalar estimation_time_ms=`estimation_time_ms'
				quietly count if e(sample)
				ereturn scalar N=r(N)
				if ("`cluster'"!="") {
					ereturn scalar N_clust=`N_clust'
					ereturn local clustvar="`cluster'"
				}
				ereturn scalar j=j
				ereturn scalar jp=jp
				ereturn scalar jdf=jdf
				ereturn scalar F=F
				ereturn scalar Fp=Fp
				ereturn scalar Fdf1=Fdf1
				ereturn scalar Fdf2=Fdf2
				ereturn scalar r2=r2
				ereturn scalar r2_d=r2_d
				ereturn scalar r2_p=r2_p
				ereturn scalar r2_a=r2_a
				ereturn scalar r2_a_d=r2_a_d
				ereturn scalar r2_a_p=r2_a_p
				ereturn scalar cdf=`cdf'
				ereturn scalar cd=`cd'
				ereturn scalar idstat=`idstat'
				ereturn scalar idp=`idp'
				ereturn scalar iddf=`iddf'
				ereturn scalar widstat=`widstat'
				ereturn local vcetype="`vcetype'"
				ereturn local endog `endog'
				ereturn local iexog `iexog'
				ereturn local xp `xp'
				ereturn local exexog `exexog'
				ereturn local market="`market'"
				ereturn local share="`share'"
				ereturn local dups="`dups'"
				ereturn local collin="`collin'"
				ereturn local estimator="`estimator0'"
				if ("`estimator0'"=="2sls") {
					ereturn local estimator_name="Non-linear 2SLS estimation"
					if (`exexog_ct'==0) {
						ereturn local estimator_name="Non-linear OLS estimation"
						ereturn local estimator="nols"
					}
				}
				if ("`estimator0'"=="3sls") {
					ereturn local estimator_name="Non-linear 3SLS estimation"
					if (`exexog_ct'==0) {
						ereturn local estimator_name="Non-linear SUR estimation"
						ereturn local estimator="nsur"
					}
				}
				if ("`estimator0'"=="gmm2s") {
					ereturn local estimator_name="Non-linear 2-Step GMM estimation"
					if (`exexog_ct'==0) {
						ereturn local estimator_name="Non-linear GLS estimation"
						ereturn local estimator="ngls"
					}
				}
				if ("`estimator0'"=="igmm") {
					ereturn local estimator_name="Iterated non-linear GMM estimation"
					if (`exexog_ct'==0) {
						ereturn local estimator_name="Iterated non-linear GLS estimation"
						ereturn local estimator="ingls"
					}
				}
				ereturn local title="`title'"
				tempvar touse
				quietly generate `touse'=(e(sample))
				if ("`nodisplay'"=="") {
					display_results , exexog_ct(`exexog_ct') endog_ct(`endog_ct')
				}
			}
		}
		if ("`noestimation'"!="") {
			if ("`nodisplay'"=="") {
				display "`title'"
			}
			ereturn post, esample(`touse')
			ereturn local title="`title'"
			tempvar touse
			quietly generate `touse'=(e(sample))
		}
		capture confirm new variable __shat
		if (_rc!=0) {
			capture drop __shat
		}
		quietly generate __shat=`share'
		ereturn local dmodel="`dmodel'"

		***************
		* ELASTICITIES
		***************

		if ("`elasticities'"!="") {
			* generate labelled numeric variable with elasticity groups (if elasticity option specified)
			tempvar _isnumvar el_num el_str 
			mata: st_numscalar("`_isnumvar'",st_isnumvar("`elasticities'"))
			if (`_isnumvar'==0) {
				quietly generate `el_str'=`elasticities'
				quietly encode `elasticities', generate(`el_num')
			}
			if (`_isnumvar'==1) {
				quietly generate `el_num'=`elasticities'
				capture quietly decode `elasticities', generate(`el_str')
				if (_rc==182) {
					capture quietly tostring `elasticities', generate(`el_str')
				}
			}
			quietly replace `el_str'=subinstr(`el_str'," ","_",.)
			tempvar _alpha _sigmag _sigmah _sigmak
			local p=word("`endog'",1)
			if ("`noestimation'"=="") {
				generate `_alpha'=-_b["`p'"]
			}
			if ("`noestimation'"!="") {
				generate `_alpha'=`alpha'
			}
			if ("`dmodel'"=="logit") {
				mata: elasticities_logit("`market'","`el_num'","`p'","`q'","`share'","`_alpha'","`touse'")
			}
			if ("`dmodel'"=="nlogit") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnsjg'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
				}
				mata: elasticities_nlogit("`market'","`el_num'","`g'","`p'","`q'","`share'","`sjg'","`_alpha'","`_sigmag'","`touse'")
			}
			if ("`dmodel'"=="nlogit2") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnshg'"]
					generate `_sigmah'=_b["`lnsjh'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
					generate `_sigmah'=`sigmah'
				}
				quietly generate `sjg'=`q'/`qg'
				mata: elasticities_nlogit2("`market'","`el_num'","`g'","`h'","`p'","`q'","`share'","`sjg'","`sjh'","`_alpha'","`_sigmag'","`_sigmah'","`touse'")
			}
			if ("`dmodel'"=="nlogit3") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnshg'"]
					generate `_sigmah'=_b["`lnskh'"]
					generate `_sigmak'=_b["`lnsjk'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
					generate `_sigmah'=`sigmah'
					generate `_sigmak'=`sigmak'
				}
				quietly generate `sjg'=`q'/`qg'
				quietly generate `sjh'=`q'/`qhg'
				mata: elasticities_nlogit3("`market'","`el_num'","`g'","`h'","`k'","`p'","`q'","`share'","`sjg'","`sjh'","`sjk'","`_alpha'","`_sigmag'","`_sigmah'","`_sigmak'","`touse'")
			}
			quietly levelsof `el_str' if e(sample), clean local(el_names)
			matrix rownames el = `el_names'
			matrix colnames el = `el_names'
			matrix rownames dr = `el_names'
			matrix colnames dr = `el_names'
			ereturn matrix el=el
			ereturn matrix dr=dr
			if ("`nodisplay'"=="") {
				display ""
				display in gr "Estimated average elasticities (by `elasticities')"
				matlist e(el), format(%10.1f)
				display ""
				display in gr "Estimated average diversion ratios (by `elasticities')"
				matlist e(dr), format(%10.0f)
			}
		}

		********************
		* MERGER SIMULATION
		********************

		if (("`msimulation'"!="" & wordcount("`msimulation'")>1) | ("`msimulation'"!="" & "`onlymc'"!="") | ("`msimulation'"!="" & "`noestimation'"!="") | "`ssnip'"!="") {
			timer clear 1
			timer on 1
			if ("`onlymc'"=="" & "`msimulation'"!="") {
				if ("`nodisplay'"=="") {
					display ""
					display in gr "Merger simulation"
				}
			}
			local xksi=0								/* check whether there is user given structural error term, ksi, for non-estimation based simulation (ksi option) */
			local xxb0=0								/* check whether there is user given non-price specific mean observed utility component, xb0, for non-estimation based simulation (xb0 option) */
			if ("`noestimation'"!="" & "`ksi'"!="") {
				local xksi=1
				tempvar xxksi
				quietly generate `xxksi'=`ksi'
			}
			if ("`noestimation'"!="" & "`xb0'"!="") {
				local xxb0=1
				tempvar xxxb0
				quietly generate `xxxb0'=`xb0'
			}
			tempvar _alpha _sigmag _sigmah _sigmak obs xb ksi cc
			capture drop `_alpha'
			capture drop `_sigmag'
			capture drop `_sigmah'
			capture drop `_sigmak'
			local p=word("`endog'",1)
			if ("`noestimation'"=="") {
				generate `_alpha'=-_b["`p'"]
			}
			if ("`noestimation'"!="") {
				generate `_alpha'=`alpha'
			}
			if ("`msimulation'"!="") {
				local firm=word("`msimulation'",1)
				if (wordcount("`msimulation'")>1) {
					local firm_post=word("`msimulation'",2)
				}
				if (wordcount("`msimulation'")==1) {
					local firm_post `firm'
				}
			}
			if ("`ssnip'"!="") {
				local segment=word("`ssnip'",1)
				tempvar _isnumvar segment_num segment_str 
				mata: st_numscalar("`_isnumvar'",st_isnumvar("`segment'"))
				if (`_isnumvar'==0) {
					quietly generate `segment_str'=`segment'
					quietly encode `segment', generate(`segment_num')
				}
				if (`_isnumvar'==1) {
					quietly generate `segment_num'=`segment'
					capture quietly decode `segment', generate(`segment_str')
					if (_rc==182) {
						capture quietly tostring `segment', generate(`segment_str')
					}
				}
				if ("`msimulation'"=="") {
					local firm=word("`ssnip'",2)
					local firm_post `firm'
					if ("`onlymc'"=="") {
						local onlymc onlymc
					}
				}
			}
			if ("`vat'"=="") {
				tempvar vat
				generate `vat'=0
			}
			if ("`noestimation'"=="") {
				if ("`eqestimation'"=="" & "`xp'"=="") {
					quietly predict `ksi', res
				}
				if ("`eqestimation'"!="" | "`xp'"!="") {
					quietly generate `ksi'=__ksi
					if ("`mc'"=="") {
						tempvar mc
						quietly generate `mc'=__mc
					}
				}
			}
			if ("`noestimation'"!="") {
				quietly generate `ksi'=0
			}
			quietly generate `xb'=`lnss0'-`ksi'
			quietly replace `xb'=`xb'+`_alpha'*`p'
			if ("`noestimation'"!="" & `xksi'==1) {
				quietly replace `ksi'=`xxksi'
				if (`xxb0'==0) {
					quietly replace `xb'=`lnss0'-`ksi'
					quietly replace `xb'=`xb'+`_alpha'*`p'
				}
			}
			if ("`noestimation'"!="" & `xxb0'==1) {
				quietly replace `xb'=`xxxb0'
				if (`xksi'==0) {
					quietly replace `ksi'=`lnss0'-`xb'+`_alpha'*`p'
				}
			}
			if ("`noestimation'"!="" & `xksi'==1 & `xxb0'==1) {
				quietly replace `lnss0'=-`_alpha'*`p'+`xb'+`ksi'
			}
			sort `market', stable
			capture drop `cc'
			generate `cc'=1
			tempvar touse
			quietly generate `touse'=(e(sample) & `p'>=0)
			capture drop `obs'
			quietly generate `obs'=sum(`cc') if `touse'
			* call merger simulation function
			if ("`dmodel'"=="logit") {
				mata: merger_simulation_logit("`market'","`firm'","`firm_post'","`msize'","`p'","`share'","`xb'","`ksi'","`_alpha'","`obs'","`mc'","`vat'","`onlymc'","`nodisplay'","`cmce'","`touse'")
				if ("`ssnip'"!="") {
					local mc_ssnip `mc'
					if ("`mc'"=="") {
						local mc_ssnip __mc
					}
					mata: ssnip_logit("`market'","`firm'","`segment_num'","`msize'","`p'","`share'","`xb'","`ksi'","`_alpha'","`obs'","`mc_ssnip'","`vat'","`nodisplay'","`touse'")
				}
			}
			if ("`dmodel'"=="nlogit") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnsjg'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
				}
				if (`xxb0'==0) {
					quietly replace `xb'=`xb'-`_sigmag'*`lnsjg'
				}
				mata: merger_simulation_nlogit("`market'","`firm'","`firm_post'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`_alpha'","`_sigmag'","`obs'","`mc'","`vat'","`onlymc'","`nodisplay'","`cmce'","`touse'")
				if ("`ssnip'"!="") {
					local mc_ssnip `mc'
					if ("`mc'"=="") {
						local mc_ssnip __mc
					}
					mata: ssnip_nlogit("`market'","`firm'","`segment_num'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`_alpha'","`_sigmag'","`obs'","`mc_ssnip'","`vat'","`nodisplay'","`touse'")
				}
			}
			if ("`dmodel'"=="nlogit2") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnshg'"]
					generate `_sigmah'=_b["`lnsjh'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
					generate `_sigmah'=`sigmah'
				}
				if (`xxb0'==0) {
					quietly replace `xb'=`xb'-`_sigmag'*`lnshg'-`_sigmah'*`lnsjh'
				}
				mata: merger_simulation_nlogit2("`market'","`firm'","`firm_post'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`h'","`_alpha'","`_sigmag'","`_sigmah'","`obs'","`mc'","`vat'","`onlymc'","`nodisplay'","`cmce'","`touse'")
				if ("`ssnip'"!="") {
					local mc_ssnip `mc'
					if ("`mc'"=="") {
						local mc_ssnip __mc
					}
					mata: ssnip_nlogit2("`market'","`firm'","`segment_num'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`h'","`_alpha'","`_sigmag'","`_sigmah'","`obs'","`mc_ssnip'","`vat'","`nodisplay'","`touse'")
				}
			}
			if ("`dmodel'"=="nlogit3") {
				if ("`noestimation'"=="") {
					generate `_sigmag'=_b["`lnshg'"]
					generate `_sigmah'=_b["`lnskh'"]
					generate `_sigmak'=_b["`lnsjk'"]
				}
				if ("`noestimation'"!="") {
					generate `_sigmag'=`sigmag'
					generate `_sigmah'=`sigmah'
					generate `_sigmak'=`sigmak'
				}
				if (`xxb0'==0) {
					quietly replace `xb'=`xb'-`_sigmag'*`lnshg'-`_sigmah'*`lnskh'-`_sigmak'*`lnsjk'
				}
				mata: merger_simulation_nlogit3("`market'","`firm'","`firm_post'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`h'","`k'","`_alpha'","`_sigmag'","`_sigmah'","`_sigmak'","`obs'","`mc'","`vat'","`onlymc'","`nodisplay'","`cmce'","`touse'")
				if ("`ssnip'"!="") {
					local mc_ssnip `mc'
					if ("`mc'"=="") {
						local mc_ssnip __mc
					}
					mata: ssnip_nlogit3("`market'","`firm'","`segment_num'","`msize'","`p'","`share'","`xb'","`ksi'","`g'","`h'","`k'","`_alpha'","`_sigmag'","`_sigmah'","`_sigmak'","`obs'","`mc_ssnip'","`vat'","`nodisplay'","`touse'")
				}
			}
			if ("`onlymc'"=="") {
				capture drop __xb0
				capture drop __ksi
				capture drop __delta
				quietly generate __xb0=`xb' if `touse'
				quietly generate __ksi=`ksi' if `touse'
				quietly generate __delta=`lnss0' if `touse'
			}
			timer off 1
			quietly timer list
			local computation_time_msimul=r(t1)
			local time_ms=msofseconds(r(t1))
			ereturn scalar computation_time_msimul=`computation_time_msimul'
			* display results
			if ("`nodisplay'"=="") {
				if ("`onlymc'"=="") {
					display ""
					tempname _isnumvar firm_num firm_str
					mata: st_numscalar("`_isnumvar'",st_isnumvar("`firm'"))
					if (`_isnumvar'==0) {
						quietly generate `firm_str'=`firm'
						quietly encode `firm', generate(`firm_num')
					}
					if (`_isnumvar'==1) {
						quietly generate `firm_num'=`firm'
						capture decode `firm', generate(`firm_str')
						if (_rc==182) {
							capture tostring `firm', generate(`firm_str')
						}
					}
					preserve
						tempvar pmarket __mc
						quietly bys `market': egen `pmarket'=max(abs(__foc_post)) if e(sample)
						quietly replace `pmarket'=(`pmarket'>0.027)
						if ("`mc'"=="") {
							quietly generate `__mc'=__mc
						}
						if ("`mc'"!="") {
							quietly generate `__mc'=`mc'
							capture confirm variable __mrkp
							if (_rc==0) {
								capture drop __mrkp
							}
							quietly generate __mrkp=(`p'/(1+`vat'))-`__mc' if e(sample)
						}
						quietly keep if e(sample) & __p_post!=. & __foc_post!=. & __s_post!=. & `pmarket'==0 & `__mc'>0 & `__mc'<=`p' & __mrkp>=0 & __mrkp<=`p'
						quietly count
						if (r(N)>0) {
							tempname q
							capture drop `q'
							quietly generate `q'=`share'*`msize'
							* weighting by "quantity"
							quietly replace __mrkp=__mrkp*`q'
							quietly replace `p'=`p'*`q'
							quietly replace __p_post=__p_post*`q'
							local nmce=0
							if ("`cmce'"!="") {
								* compensating marginal cost efficiencies
								tempname dmc mce
								capture drop `dmc'
								quietly generate `mce'=(`__mc'-__mce)*`q'
								local nmce=1
								local cnmce cmp
								local tmce , compensating marginal cost reduction
							}
							* results aggregated to the level of "firms"
							collapse (sum) `p' __p_post __mrkp `q' `mce', by(`firm_str')
							quietly replace `p'=`p'/`q'
							quietly replace __p_post=__p_post/`q'
							quietly replace __mrkp=100*__mrkp/(`p'*`q')
							quietly generate dp=100*(__p_post-`p')/`p'
							if ("`cmce'"!="") {
								quietly replace `mce'=100*`mce'/(`p'*`q')
							}
							mkmat dp __mrkp `mce' `p', matrix(dp) rownames(`firm_str')
							local rnames: rowfullnames dp
							quietly replace `p'=`p'*`q'
							quietly replace __p_post=__p_post*`q'
							quietly replace __mrkp=__mrkp*`p'/100
							* results aggregated to overall level
							collapse (sum) `p' __p_post __mrkp `q'
							quietly replace `p'=`p'/`q'
							quietly replace __p_post=__p_post/`q'
							quietly replace __mrkp=100*__mrkp/(`p'*`q')
							quietly generate dp=100*(__p_post-`p')/`p'
							mkmat dp __mrkp, matrix(dp_overall)
							matrix dp_overall=dp_overall,J(1,1+`nmce',.)
							* combining results into one display matrix and displaying
							matrix dp=dp\dp_overall
							local rnames `rnames' overall
							matrix rownames dp = `rnames'
							matrix colnames dp = dp mrg `cnmce' p
							display ""
							display "Predicted price changes, pre-merger implied margin`tmce' (%) and price"
							matlist dp, format(%6.1f) linesize(100)
							scalar dp=dp[rowsof(dp),1]
							ereturn scalar dp=dp
						}
					restore
				}
			}
			if ("`ssnip'"!="") {
				* performing SSNIP tests
				quietly levelsof `segment_str', local(ssegments) clean
				local ns: list sizeof ssegments
				matrix rownames ssnip = `ssegments'
				matrix colnames ssnip = 1% 5% 10%
				if ("`nodisplay'"=="") {
					display ""
					display "SSNIP test of groups (% change in group's total profit due to a 1-5-10% price increase)"
					matlist ssnip, format(%8,1f)
				}
				ereturn matrix ssnip=ssnip
			}
			if ("`nodisplay'"=="") {
				di in gr "Computation time: " %1.0f = hh(`time_ms') "h " %1.0f = mm(`time_ms') "m " %4.3f = ss(`time_ms') "s"
			}
		}

	}	/* end of nested logit model */

end

********************
* Stata subroutines
********************

* Stock-Yogo weak ID test critical values (from ivreg2)
capture program drop cdsy1
program define cdsy1, rclass
	version 8.2
	syntax , type(string) k2(integer) nendog(integer)

* type() can be ivbias5   (k2<=100, nendog<=3)
*               ivbias10  (ditto)
*               ivbias20  (ditto)
*               ivbias30  (ditto)
*               ivsize10  (k2<=100, nendog<=2)
*               ivsize15  (ditto)
*               ivsize20  (ditto)
*               ivsize25  (ditto)
*               fullrel5  (ditto)
*               fullrel10 (ditto)
*               fullrel20 (ditto)
*               fullrel30 (ditto)
*               fullmax5  (ditto)
*               fullmax10 (ditto)
*               fullmax20 (ditto)
*               fullmax30 (ditto)
*               limlsize10 (ditto)
*               limlsize15 (ditto)
*               limlsize20 (ditto)
*               limlsize25 (ditto)

	tempname temp cv

* Initialize critical value as MV
	scalar `cv'=.

	if "`type'"=="ivbias5" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	13.91	,	.	,	.	\ /*
	*/	16.85	,	11.04	,	.	\ /*
	*/	18.37	,	13.97	,	9.53	\ /*
	*/	19.28	,	15.72	,	12.20	\ /*
	*/	19.86	,	16.88	,	13.95	\ /*
	*/	20.25	,	17.70	,	15.18	\ /*
	*/	20.53	,	18.30	,	16.10	\ /*
	*/	20.74	,	18.76	,	16.80	\ /*
	*/	20.90	,	19.12	,	17.35	\ /*
	*/	21.01	,	19.40	,	17.80	\ /*
	*/	21.10	,	19.64	,	18.17	\ /*
	*/	21.18	,	19.83	,	18.47	\ /*
	*/	21.23	,	19.98	,	18.73	\ /*
	*/	21.28	,	20.12	,	18.94	\ /*
	*/	21.31	,	20.23	,	19.13	\ /*
	*/	21.34	,	20.33	,	19.29	\ /*
	*/	21.36	,	20.41	,	19.44	\ /*
	*/	21.38	,	20.48	,	19.56	\ /*
	*/	21.39	,	20.54	,	19.67	\ /*
	*/	21.40	,	20.60	,	19.77	\ /*
	*/	21.41	,	20.65	,	19.86	\ /*
	*/	21.41	,	20.69	,	19.94	\ /*
	*/	21.42	,	20.73	,	20.01	\ /*
	*/	21.42	,	20.76	,	20.07	\ /*
	*/	21.42	,	20.79	,	20.13	\ /*
	*/	21.42	,	20.82	,	20.18	\ /*
	*/	21.42	,	20.84	,	20.23	\ /*
	*/	21.42	,	20.86	,	20.27	\ /*
	*/	21.41	,	20.88	,	20.31	\ /*
	*/	21.41	,	20.90	,	20.35	\ /*
	*/	21.41	,	20.91	,	20.38	\ /*
	*/	21.40	,	20.93	,	20.41	\ /*
	*/	21.40	,	20.94	,	20.44	\ /*
	*/	21.39	,	20.95	,	20.47	\ /*
	*/	21.39	,	20.96	,	20.49	\ /*
	*/	21.38	,	20.97	,	20.51	\ /*
	*/	21.38	,	20.98	,	20.54	\ /*
	*/	21.37	,	20.99	,	20.56	\ /*
	*/	21.37	,	20.99	,	20.57	\ /*
	*/	21.36	,	21.00	,	20.59	\ /*
	*/	21.35	,	21.00	,	20.61	\ /*
	*/	21.35	,	21.01	,	20.62	\ /*
	*/	21.34	,	21.01	,	20.64	\ /*
	*/	21.34	,	21.02	,	20.65	\ /*
	*/	21.33	,	21.02	,	20.66	\ /*
	*/	21.32	,	21.02	,	20.67	\ /*
	*/	21.32	,	21.03	,	20.68	\ /*
	*/	21.31	,	21.03	,	20.69	\ /*
	*/	21.31	,	21.03	,	20.70	\ /*
	*/	21.30	,	21.03	,	20.71	\ /*
	*/	21.30	,	21.03	,	20.72	\ /*
	*/	21.29	,	21.03	,	20.73	\ /*
	*/	21.28	,	21.03	,	20.73	\ /*
	*/	21.28	,	21.04	,	20.74	\ /*
	*/	21.27	,	21.04	,	20.75	\ /*
	*/	21.27	,	21.04	,	20.75	\ /*
	*/	21.26	,	21.04	,	20.76	\ /*
	*/	21.26	,	21.04	,	20.76	\ /*
	*/	21.25	,	21.04	,	20.77	\ /*
	*/	21.24	,	21.04	,	20.77	\ /*
	*/	21.24	,	21.04	,	20.78	\ /*
	*/	21.23	,	21.04	,	20.78	\ /*
	*/	21.23	,	21.03	,	20.79	\ /*
	*/	21.22	,	21.03	,	20.79	\ /*
	*/	21.22	,	21.03	,	20.79	\ /*
	*/	21.21	,	21.03	,	20.80	\ /*
	*/	21.21	,	21.03	,	20.80	\ /*
	*/	21.20	,	21.03	,	20.80	\ /*
	*/	21.20	,	21.03	,	20.80	\ /*
	*/	21.19	,	21.03	,	20.81	\ /*
	*/	21.19	,	21.03	,	20.81	\ /*
	*/	21.18	,	21.03	,	20.81	\ /*
	*/	21.18	,	21.02	,	20.81	\ /*
	*/	21.17	,	21.02	,	20.82	\ /*
	*/	21.17	,	21.02	,	20.82	\ /*
	*/	21.16	,	21.02	,	20.82	\ /*
	*/	21.16	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.82	\ /*
	*/	21.15	,	21.02	,	20.83	\ /*
	*/	21.14	,	21.01	,	20.83	\ /*
	*/	21.14	,	21.01	,	20.83	\ /*
	*/	21.13	,	21.01	,	20.83	\ /*
	*/	21.13	,	21.01	,	20.83	\ /*
	*/	21.12	,	21.01	,	20.84	\ /*
	*/	21.12	,	21.01	,	20.84	\ /*
	*/	21.11	,	21.01	,	20.84	\ /*
	*/	21.11	,	21.01	,	20.84	\ /*
	*/	21.10	,	21.00	,	20.84	\ /*
	*/	21.10	,	21.00	,	20.84	\ /*
	*/	21.09	,	21.00	,	20.85	\ /*
	*/	21.09	,	21.00	,	20.85	\ /*
	*/	21.08	,	21.00	,	20.85	\ /*
	*/	21.08	,	21.00	,	20.85	\ /*
	*/	21.07	,	21.00	,	20.85	\ /*
	*/	21.07	,	20.99	,	20.86	\ /*
	*/	21.06	,	20.99	,	20.86	\ /*
	*/	21.06	,	20.99	,	20.86	)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

 	if "`type'"=="ivbias10" {
		matrix input `temp' = 	/*
	*/	(.,.,.			\	/*
	*/	.,.,.			\	/*
	*/	9.08,.,.		\	/*
	*/	10.27,7.56,.		\	/*
	*/	10.83,8.78,6.61		\	/*
	*/	11.12,9.48,7.77		\	/*
	*/	11.29,9.92,8.5		\	/*
	*/	11.39,10.22,9.01	\	/*
	*/	11.46,10.43,9.37	\	/*
	*/	11.49,10.58,9.64	\	/*
	*/	11.51,10.69,9.85	\	/*
	*/	11.52,10.78,10.01	\	/*
	*/	11.52,10.84,10.14	\	/*
	*/	11.52,10.89,10.25	\	/*
	*/	11.51,10.93,10.33	\	/*
	*/	11.5,10.96,10.41	\	/*
	*/	11.49,10.99,10.47	\	/*
	*/	11.48,11,10.52		\	/*
	*/	11.46,11.02,10.56	\	/*
	*/	11.45,11.03,10.6	\	/*
	*/	11.44,11.04,10.63	\	/*
	*/	11.42,11.05,10.65	\	/*
	*/	11.41,11.05,10.68	\	/*
	*/	11.4,11.05,10.7		\	/*
	*/	11.38,11.06,10.71	\	/*
	*/	11.37,11.06,10.73	\	/*
	*/	11.36,11.06,10.74	\	/*
	*/	11.34,11.05,10.75	\	/*
	*/	11.33,11.05,10.76	\	/*
	*/	11.32,11.05,10.77	\	/*
	*/	11.3,11.05,10.78	\	/*
	*/	11.29,11.05,10.79	\	/*
	*/	11.28,11.04,10.79	\	/*
	*/	11.27,11.04,10.8	\	/*
	*/	11.26,11.04,10.8	\	/*
	*/	11.25,11.03,10.8	\	/*
	*/	11.24,11.03,10.81	\	/*
	*/	11.23,11.02,10.81	\	/*
	*/	11.22,11.02,10.81	\	/*
	*/	11.21,11.02,10.81	\	/*
	*/	11.2,11.01,10.81	\	/*
	*/	11.19,11.01,10.81	\	/*
	*/	11.18,11,10.81		\	/*
	*/	11.17,11,10.81		\	/*
	*/	11.16,10.99,10.81	\	/*
	*/	11.15,10.99,10.81	\	/*
	*/	11.14,10.98,10.81	\	/*
	*/	11.13,10.98,10.81	\	/*
	*/	11.13,10.98,10.81	\	/*
	*/	11.12,10.97,10.81	\	/*
	*/	11.11,10.97,10.81	\	/*
	*/	11.1,10.96,10.81	\	/*
	*/	11.1,10.96,10.81	\	/*
	*/	11.09,10.95,10.81	\	/*
	*/	11.08,10.95,10.81	\	/*
	*/	11.07,10.94,10.8	\	/*
	*/	11.07,10.94,10.8	\	/*
	*/	11.06,10.94,10.8	\	/*
	*/	11.05,10.93,10.8	\	/*
	*/	11.05,10.93,10.8	\	/*
	*/	11.04,10.92,10.8	\	/*
	*/	11.03,10.92,10.79	\	/*
	*/	11.03,10.92,10.79	\	/*
	*/	11.02,10.91,10.79	\	/*
	*/	11.02,10.91,10.79	\	/*
	*/	11.01,10.9,10.79	\	/*
	*/	11,10.9,10.79		\	/*
	*/	11,10.9,10.78		\	/*
	*/	10.99,10.89,10.78	\	/*
	*/	10.99,10.89,10.78	\	/*
	*/	10.98,10.89,10.78	\	/*
	*/	10.98,10.88,10.78	\	/*
	*/	10.97,10.88,10.77	\	/*
	*/	10.97,10.88,10.77	\	/*
	*/	10.96,10.87,10.77	\	/*
	*/	10.96,10.87,10.77	\	/*
	*/	10.95,10.86,10.77	\	/*
	*/	10.95,10.86,10.76	\	/*
	*/	10.94,10.86,10.76	\	/*
	*/	10.94,10.85,10.76	\	/*
	*/	10.93,10.85,10.76	\	/*
	*/	10.93,10.85,10.76	\	/*
	*/	10.92,10.84,10.75	\	/*
	*/	10.92,10.84,10.75	\	/*
	*/	10.91,10.84,10.75	\	/*
	*/	10.91,10.84,10.75	\	/*
	*/	10.91,10.83,10.75	\	/*
	*/	10.9,10.83,10.74	\	/*
	*/	10.9,10.83,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.89,10.82,10.74	\	/*
	*/	10.88,10.81,10.74	\	/*
	*/	10.88,10.81,10.73	\	/*
	*/	10.87,10.81,10.73	\	/*
	*/	10.87,10.81,10.73	\	/*
	*/	10.87,10.8,10.73	\	/*
	*/	10.86,10.8,10.73	\	/*
	*/	10.86,10.8,10.72	\	/*
	*/	10.86,10.8,10.72)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	if "`type'"=="ivbias20" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	6.46	,	.	,	.	\ /*
	*/	6.71	,	5.57	,	.	\ /*
	*/	6.77	,	5.91	,	4.99	\ /*
	*/	6.76	,	6.08	,	5.35	\ /*
	*/	6.73	,	6.16	,	5.56	\ /*
	*/	6.69	,	6.20	,	5.69	\ /*
	*/	6.65	,	6.22	,	5.78	\ /*
	*/	6.61	,	6.23	,	5.83	\ /*
	*/	6.56	,	6.23	,	5.87	\ /*
	*/	6.53	,	6.22	,	5.90	\ /*
	*/	6.49	,	6.21	,	5.92	\ /*
	*/	6.45	,	6.20	,	5.93	\ /*
	*/	6.42	,	6.19	,	5.94	\ /*
	*/	6.39	,	6.17	,	5.94	\ /*
	*/	6.36	,	6.16	,	5.94	\ /*
	*/	6.33	,	6.14	,	5.94	\ /*
	*/	6.31	,	6.13	,	5.94	\ /*
	*/	6.28	,	6.11	,	5.93	\ /*
	*/	6.26	,	6.10	,	5.93	\ /*
	*/	6.24	,	6.08	,	5.92	\ /*
	*/	6.22	,	6.07	,	5.92	\ /*
	*/	6.20	,	6.06	,	5.91	\ /*
	*/	6.18	,	6.05	,	5.90	\ /*
	*/	6.16	,	6.03	,	5.90	\ /*
	*/	6.14	,	6.02	,	5.89	\ /*
	*/	6.13	,	6.01	,	5.88	\ /*
	*/	6.11	,	6.00	,	5.88	\ /*
	*/	6.09	,	5.99	,	5.87	\ /*
	*/	6.08	,	5.98	,	5.87	\ /*
	*/	6.07	,	5.97	,	5.86	\ /*
	*/	6.05	,	5.96	,	5.85	\ /*
	*/	6.04	,	5.95	,	5.85	\ /*
	*/	6.03	,	5.94	,	5.84	\ /*
	*/	6.01	,	5.93	,	5.83	\ /*
	*/	6.00	,	5.92	,	5.83	\ /*
	*/	5.99	,	5.91	,	5.82	\ /*
	*/	5.98	,	5.90	,	5.82	\ /*
	*/	5.97	,	5.89	,	5.81	\ /*
	*/	5.96	,	5.89	,	5.80	\ /*
	*/	5.95	,	5.88	,	5.80	\ /*
	*/	5.94	,	5.87	,	5.79	\ /*
	*/	5.93	,	5.86	,	5.79	\ /*
	*/	5.92	,	5.86	,	5.78	\ /*
	*/	5.91	,	5.85	,	5.78	\ /*
	*/	5.91	,	5.84	,	5.77	\ /*
	*/	5.90	,	5.83	,	5.77	\ /*
	*/	5.89	,	5.83	,	5.76	\ /*
	*/	5.88	,	5.82	,	5.76	\ /*
	*/	5.87	,	5.82	,	5.75	\ /*
	*/	5.87	,	5.81	,	5.75	\ /*
	*/	5.86	,	5.80	,	5.74	\ /*
	*/	5.85	,	5.80	,	5.74	\ /*
	*/	5.85	,	5.79	,	5.73	\ /*
	*/	5.84	,	5.79	,	5.73	\ /*
	*/	5.83	,	5.78	,	5.72	\ /*
	*/	5.83	,	5.78	,	5.72	\ /*
	*/	5.82	,	5.77	,	5.72	\ /*
	*/	5.81	,	5.77	,	5.71	\ /*
	*/	5.81	,	5.76	,	5.71	\ /*
	*/	5.80	,	5.76	,	5.70	\ /*
	*/	5.80	,	5.75	,	5.70	\ /*
	*/	5.79	,	5.75	,	5.70	\ /*
	*/	5.78	,	5.74	,	5.69	\ /*
	*/	5.78	,	5.74	,	5.69	\ /*
	*/	5.77	,	5.73	,	5.68	\ /*
	*/	5.77	,	5.73	,	5.68	\ /*
	*/	5.76	,	5.72	,	5.68	\ /*
	*/	5.76	,	5.72	,	5.67	\ /*
	*/	5.75	,	5.72	,	5.67	\ /*
	*/	5.75	,	5.71	,	5.67	\ /*
	*/	5.75	,	5.71	,	5.66	\ /*
	*/	5.74	,	5.70	,	5.66	\ /*
	*/	5.74	,	5.70	,	5.66	\ /*
	*/	5.73	,	5.70	,	5.65	\ /*
	*/	5.73	,	5.69	,	5.65	\ /*
	*/	5.72	,	5.69	,	5.65	\ /*
	*/	5.72	,	5.68	,	5.65	\ /*
	*/	5.71	,	5.68	,	5.64	\ /*
	*/	5.71	,	5.68	,	5.64	\ /*
	*/	5.71	,	5.67	,	5.64	\ /*
	*/	5.70	,	5.67	,	5.63	\ /*
	*/	5.70	,	5.67	,	5.63	\ /*
	*/	5.70	,	5.66	,	5.63	\ /*
	*/	5.69	,	5.66	,	5.62	\ /*
	*/	5.69	,	5.66	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.62	\ /*
	*/	5.68	,	5.65	,	5.61	\ /*
	*/	5.67	,	5.65	,	5.61	\ /*
	*/	5.67	,	5.64	,	5.61	\ /*
	*/	5.67	,	5.64	,	5.61	\ /*
	*/	5.66	,	5.64	,	5.60	\ /*
	*/	5.66	,	5.63	,	5.60	\ /*
	*/	5.66	,	5.63	,	5.60	\ /*
	*/	5.65	,	5.63	,	5.60	\ /*
	*/	5.65	,	5.63	,	5.59	\ /*
	*/	5.65	,	5.62	,	5.59	\ /*
	*/	5.65	,	5.62	,	5.59	)

		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivbias30" {
		matrix input `temp' = (	/*
	*/	.	,	.	,	.	\ /*
	*/	.	,	.	,	.	\ /*
	*/	5.39	,	.	,	.	\ /*
	*/	5.34	,	4.73	,	.	\ /*
	*/	5.25	,	4.79	,	4.30	\ /*
	*/	5.15	,	4.78	,	4.40	\ /*
	*/	5.07	,	4.76	,	4.44	\ /*
	*/	4.99	,	4.73	,	4.46	\ /*
	*/	4.92	,	4.69	,	4.46	\ /*
	*/	4.86	,	4.66	,	4.45	\ /*
	*/	4.80	,	4.62	,	4.44	\ /*
	*/	4.75	,	4.59	,	4.42	\ /*
	*/	4.71	,	4.56	,	4.41	\ /*
	*/	4.67	,	4.53	,	4.39	\ /*
	*/	4.63	,	4.50	,	4.37	\ /*
	*/	4.59	,	4.48	,	4.36	\ /*
	*/	4.56	,	4.45	,	4.34	\ /*
	*/	4.53	,	4.43	,	4.32	\ /*
	*/	4.51	,	4.41	,	4.31	\ /*
	*/	4.48	,	4.39	,	4.29	\ /*
	*/	4.46	,	4.37	,	4.28	\ /*
	*/	4.43	,	4.35	,	4.27	\ /*
	*/	4.41	,	4.33	,	4.25	\ /*
	*/	4.39	,	4.32	,	4.24	\ /*
	*/	4.37	,	4.30	,	4.23	\ /*
	*/	4.35	,	4.29	,	4.21	\ /*
	*/	4.34	,	4.27	,	4.20	\ /*
	*/	4.32	,	4.26	,	4.19	\ /*
	*/	4.31	,	4.24	,	4.18	\ /*
	*/	4.29	,	4.23	,	4.17	\ /*
	*/	4.28	,	4.22	,	4.16	\ /*
	*/	4.26	,	4.21	,	4.15	\ /*
	*/	4.25	,	4.20	,	4.14	\ /*
	*/	4.24	,	4.19	,	4.13	\ /*
	*/	4.23	,	4.18	,	4.13	\ /*
	*/	4.22	,	4.17	,	4.12	\ /*
	*/	4.20	,	4.16	,	4.11	\ /*
	*/	4.19	,	4.15	,	4.10	\ /*
	*/	4.18	,	4.14	,	4.09	\ /*
	*/	4.17	,	4.13	,	4.09	\ /*
	*/	4.16	,	4.12	,	4.08	\ /*
	*/	4.15	,	4.11	,	4.07	\ /*
	*/	4.15	,	4.11	,	4.07	\ /*
	*/	4.14	,	4.10	,	4.06	\ /*
	*/	4.13	,	4.09	,	4.05	\ /*
	*/	4.12	,	4.08	,	4.05	\ /*
	*/	4.11	,	4.08	,	4.04	\ /*
	*/	4.11	,	4.07	,	4.03	\ /*
	*/	4.10	,	4.06	,	4.03	\ /*
	*/	4.09	,	4.06	,	4.02	\ /*
	*/	4.08	,	4.05	,	4.02	\ /*
	*/	4.08	,	4.05	,	4.01	\ /*
	*/	4.07	,	4.04	,	4.01	\ /*
	*/	4.06	,	4.03	,	4.00	\ /*
	*/	4.06	,	4.03	,	4.00	\ /*
	*/	4.05	,	4.02	,	3.99	\ /*
	*/	4.05	,	4.02	,	3.99	\ /*
	*/	4.04	,	4.01	,	3.98	\ /*
	*/	4.04	,	4.01	,	3.98	\ /*
	*/	4.03	,	4.00	,	3.97	\ /*
	*/	4.02	,	4.00	,	3.97	\ /*
	*/	4.02	,	3.99	,	3.96	\ /*
	*/	4.01	,	3.99	,	3.96	\ /*
	*/	4.01	,	3.98	,	3.96	\ /*
	*/	4.00	,	3.98	,	3.95	\ /*
	*/	4.00	,	3.97	,	3.95	\ /*
	*/	3.99	,	3.97	,	3.94	\ /*
	*/	3.99	,	3.97	,	3.94	\ /*
	*/	3.99	,	3.96	,	3.94	\ /*
	*/	3.98	,	3.96	,	3.93	\ /*
	*/	3.98	,	3.95	,	3.93	\ /*
	*/	3.97	,	3.95	,	3.93	\ /*
	*/	3.97	,	3.95	,	3.92	\ /*
	*/	3.96	,	3.94	,	3.92	\ /*
	*/	3.96	,	3.94	,	3.92	\ /*
	*/	3.96	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.93	,	3.91	\ /*
	*/	3.95	,	3.92	,	3.90	\ /*
	*/	3.94	,	3.92	,	3.90	\ /*
	*/	3.94	,	3.92	,	3.90	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.93	,	3.91	,	3.89	\ /*
	*/	3.92	,	3.91	,	3.89	\ /*
	*/	3.92	,	3.90	,	3.88	\ /*
	*/	3.92	,	3.90	,	3.88	\ /*
	*/	3.91	,	3.90	,	3.88	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.91	,	3.89	,	3.87	\ /*
	*/	3.90	,	3.89	,	3.87	\ /*
	*/	3.90	,	3.88	,	3.86	\ /*
	*/	3.90	,	3.88	,	3.86	\ /*
	*/	3.89	,	3.88	,	3.86	\ /*
	*/	3.89	,	3.87	,	3.86	\ /*
	*/	3.89	,	3.87	,	3.85	\ /*
	*/	3.89	,	3.87	,	3.85	\ /*
	*/	3.88	,	3.87	,	3.85	\ /*
	*/	3.88	,	3.86	,	3.85	)
	
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	if "`type'"=="ivsize10" {
		matrix input `temp' = /*
	*/	(16.38,.	\	/*
	*/	19.93,7.03	\	/*
	*/	22.3,13.43	\	/*
	*/	24.58,16.87	\	/*
	*/	26.87,19.45	\	/*
	*/	29.18,21.68	\	/*
	*/	31.5,23.72	\	/*
	*/	33.84,25.64	\	/*
	*/	36.19,27.51	\	/*
	*/	38.54,29.32	\	/*
	*/	40.9,31.11	\	/*
	*/	43.27,32.88	\	/*
	*/	45.64,34.62	\	/*
	*/	48.01,36.36	\	/*
	*/	50.39,38.08	\	/*
	*/	52.77,39.8	\	/*
	*/	55.15,41.51	\	/*
	*/	57.53,43.22	\	/*
	*/	59.92,44.92	\	/*
	*/	62.3,46.62	\	/*
	*/	64.69,48.31	\	/*
	*/	67.07,50.01	\	/*
	*/	69.46,51.7	\	/*
	*/	71.85,53.39	\	/*
	*/	74.24,55.07	\	/*
	*/	76.62,56.76	\	/*
	*/	79.01,58.45	\	/*
	*/	81.4,60.13	\	/*
	*/	83.79,61.82	\	/*
	*/	86.17,63.51	\	/*
	*/	88.56,65.19	\	/*
	*/	90.95,66.88	\	/*
	*/	93.33,68.56	\	/*
	*/	95.72,70.25	\	/*
	*/	98.11,71.94	\	/*
	*/	100.5,73.62	\	/*
	*/	102.88,75.31	\	/*
	*/	105.27,76.99	\	/*
	*/	107.66,78.68	\	/*
	*/	110.04,80.37	\	/*
	*/	112.43,82.05	\	/*
	*/	114.82,83.74	\	/*
	*/	117.21,85.42	\	/*
	*/	119.59,87.11	\	/*
	*/	121.98,88.8	\	/*
	*/	124.37,90.48	\	/*
	*/	126.75,92.17	\	/*
	*/	129.14,93.85	\	/*
	*/	131.53,95.54	\	/*
	*/	133.92,97.23	\	/*
	*/	136.3,98.91	\	/*
	*/	138.69,100.6	\	/*
	*/	141.08,102.29	\	/*
	*/	143.47,103.97	\	/*
	*/	145.85,105.66	\	/*
	*/	148.24,107.34	\	/*
	*/	150.63,109.03	\	/*
	*/	153.01,110.72	\	/*
	*/	155.4,112.4	\	/*
	*/	157.79,114.09	\	/*
	*/	160.18,115.77	\	/*
	*/	162.56,117.46	\	/*
	*/	164.95,119.15	\	/*
	*/	167.34,120.83	\	/*
	*/	169.72,122.52	\	/*
	*/	172.11,124.2	\	/*
	*/	174.5,125.89	\	/*
	*/	176.89,127.58	\	/*
	*/	179.27,129.26	\	/*
	*/	181.66,130.95	\	/*
	*/	184.05,132.63	\	/*
	*/	186.44,134.32	\	/*
	*/	188.82,136.01	\	/*
	*/	191.21,137.69	\	/*
	*/	193.6,139.38	\	/*
	*/	195.98,141.07	\	/*
	*/	198.37,142.75	\	/*
	*/	200.76,144.44	\	/*
	*/	203.15,146.12	\	/*
	*/	205.53,147.81	\	/*
	*/	207.92,149.5	\	/*
	*/	210.31,151.18	\	/*
	*/	212.69,152.87	\	/*
	*/	215.08,154.55	\	/*
	*/	217.47,156.24	\	/*
	*/	219.86,157.93	\	/*
	*/	222.24,159.61	\	/*
	*/	224.63,161.3	\	/*
	*/	227.02,162.98	\	/*
	*/	229.41,164.67	\	/*
	*/	231.79,166.36	\	/*
	*/	234.18,168.04	\	/*
	*/	236.57,169.73	\	/*
	*/	238.95,171.41	\	/*
	*/	241.34,173.1	\	/*
	*/	243.73,174.79	\	/*
	*/	246.12,176.47	\	/*
	*/	248.5,178.16	\	/*
	*/	250.89,179.84	\	/*
	*/	253.28,181.53)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize15" {
		matrix input `temp' = ( /*
	*/	8.96	,	.	\ /*
	*/	11.59	,	4.58	\ /*
	*/	12.83	,	8.18	\ /*
	*/	13.96	,	9.93	\ /*
	*/	15.09	,	11.22	\ /*
	*/	16.23	,	12.33	\ /*
	*/	17.38	,	13.34	\ /*
	*/	18.54	,	14.31	\ /*
	*/	19.71	,	15.24	\ /*
	*/	20.88	,	16.16	\ /*
	*/	22.06	,	17.06	\ /*
	*/	23.24	,	17.95	\ /*
	*/	24.42	,	18.84	\ /*
	*/	25.61	,	19.72	\ /*
	*/	26.80	,	20.60	\ /*
	*/	27.99	,	21.48	\ /*
	*/	29.19	,	22.35	\ /*
	*/	30.38	,	23.22	\ /*
	*/	31.58	,	24.09	\ /*
	*/	32.77	,	24.96	\ /*
	*/	33.97	,	25.82	\ /*
	*/	35.17	,	26.69	\ /*
	*/	36.37	,	27.56	\ /*
	*/	37.57	,	28.42	\ /*
	*/	38.77	,	29.29	\ /*
	*/	39.97	,	30.15	\ /*
	*/	41.17	,	31.02	\ /*
	*/	42.37	,	31.88	\ /*
	*/	43.57	,	32.74	\ /*
	*/	44.78	,	33.61	\ /*
	*/	45.98	,	34.47	\ /*
	*/	47.18	,	35.33	\ /*
	*/	48.38	,	36.19	\ /*
	*/	49.59	,	37.06	\ /*
	*/	50.79	,	37.92	\ /*
	*/	51.99	,	38.78	\ /*
	*/	53.19	,	39.64	\ /*
	*/	54.40	,	40.50	\ /*
	*/	55.60	,	41.37	\ /*
	*/	56.80	,	42.23	\ /*
	*/	58.01	,	43.09	\ /*
	*/	59.21	,	43.95	\ /*
	*/	60.41	,	44.81	\ /*
	*/	61.61	,	45.68	\ /*
	*/	62.82	,	46.54	\ /*
	*/	64.02	,	47.40	\ /*
	*/	65.22	,	48.26	\ /*
	*/	66.42	,	49.12	\ /*
	*/	67.63	,	49.99	\ /*
	*/	68.83	,	50.85	\ /*
	*/	70.03	,	51.71	\ /*
	*/	71.24	,	52.57	\ /*
	*/	72.44	,	53.43	\ /*
	*/	73.64	,	54.30	\ /*
	*/	74.84	,	55.16	\ /*
	*/	76.05	,	56.02	\ /*
	*/	77.25	,	56.88	\ /*
	*/	78.45	,	57.74	\ /*
	*/	79.66	,	58.61	\ /*
	*/	80.86	,	59.47	\ /*
	*/	82.06	,	60.33	\ /*
	*/	83.26	,	61.19	\ /*
	*/	84.47	,	62.05	\ /*
	*/	85.67	,	62.92	\ /*
	*/	86.87	,	63.78	\ /*
	*/	88.07	,	64.64	\ /*
	*/	89.28	,	65.50	\ /*
	*/	90.48	,	66.36	\ /*
	*/	91.68	,	67.22	\ /*
	*/	92.89	,	68.09	\ /*
	*/	94.09	,	68.95	\ /*
	*/	95.29	,	69.81	\ /*
	*/	96.49	,	70.67	\ /*
	*/	97.70	,	71.53	\ /*
	*/	98.90	,	72.40	\ /*
	*/	100.10	,	73.26	\ /*
	*/	101.30	,	74.12	\ /*
	*/	102.51	,	74.98	\ /*
	*/	103.71	,	75.84	\ /*
	*/	104.91	,	76.71	\ /*
	*/	106.12	,	77.57	\ /*
	*/	107.32	,	78.43	\ /*
	*/	108.52	,	79.29	\ /*
	*/	109.72	,	80.15	\ /*
	*/	110.93	,	81.02	\ /*
	*/	112.13	,	81.88	\ /*
	*/	113.33	,	82.74	\ /*
	*/	114.53	,	83.60	\ /*
	*/	115.74	,	84.46	\ /*
	*/	116.94	,	85.33	\ /*
	*/	118.14	,	86.19	\ /*
	*/	119.35	,	87.05	\ /*
	*/	120.55	,	87.91	\ /*
	*/	121.75	,	88.77	\ /*
	*/	122.95	,	89.64	\ /*
	*/	124.16	,	90.50	\ /*
	*/	125.36	,	91.36	\ /*
	*/	126.56	,	92.22	\ /*
	*/	127.76	,	93.08	\ /*
	*/	128.97	,	93.95	)
	
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize20" {
		matrix input `temp' = ( /*
	*/	6.66	,	.	\ /*
	*/	8.75	,	3.95	\ /*
	*/	9.54	,	6.40	\ /*
	*/	10.26	,	7.54	\ /*
	*/	10.98	,	8.38	\ /*
	*/	11.72	,	9.10	\ /*
	*/	12.48	,	9.77	\ /*
	*/	13.24	,	10.41	\ /*
	*/	14.01	,	11.03	\ /*
	*/	14.78	,	11.65	\ /*
	*/	15.56	,	12.25	\ /*
	*/	16.35	,	12.86	\ /*
	*/	17.14	,	13.45	\ /*
	*/	17.93	,	14.05	\ /*
	*/	18.72	,	14.65	\ /*
	*/	19.51	,	15.24	\ /*
	*/	20.31	,	15.83	\ /*
	*/	21.10	,	16.42	\ /*
	*/	21.90	,	17.02	\ /*
	*/	22.70	,	17.61	\ /*
	*/	23.50	,	18.20	\ /*
	*/	24.30	,	18.79	\ /*
	*/	25.10	,	19.38	\ /*
	*/	25.90	,	19.97	\ /*
	*/	26.71	,	20.56	\ /*
	*/	27.51	,	21.15	\ /*
	*/	28.31	,	21.74	\ /*
	*/	29.12	,	22.33	\ /*
	*/	29.92	,	22.92	\ /*
	*/	30.72	,	23.51	\ /*
	*/	31.53	,	24.10	\ /*
	*/	32.33	,	24.69	\ /*
	*/	33.14	,	25.28	\ /*
	*/	33.94	,	25.87	\ /*
	*/	34.75	,	26.46	\ /*
	*/	35.55	,	27.05	\ /*
	*/	36.36	,	27.64	\ /*
	*/	37.17	,	28.23	\ /*
	*/	37.97	,	28.82	\ /*
	*/	38.78	,	29.41	\ /*
	*/	39.58	,	30.00	\ /*
	*/	40.39	,	30.59	\ /*
	*/	41.20	,	31.18	\ /*
	*/	42.00	,	31.77	\ /*
	*/	42.81	,	32.36	\ /*
	*/	43.62	,	32.95	\ /*
	*/	44.42	,	33.54	\ /*
	*/	45.23	,	34.13	\ /*
	*/	46.03	,	34.72	\ /*
	*/	46.84	,	35.31	\ /*
	*/	47.65	,	35.90	\ /*
	*/	48.45	,	36.49	\ /*
	*/	49.26	,	37.08	\ /*
	*/	50.06	,	37.67	\ /*
	*/	50.87	,	38.26	\ /*
	*/	51.68	,	38.85	\ /*
	*/	52.48	,	39.44	\ /*
	*/	53.29	,	40.02	\ /*
	*/	54.09	,	40.61	\ /*
	*/	54.90	,	41.20	\ /*
	*/	55.71	,	41.79	\ /*
	*/	56.51	,	42.38	\ /*
	*/	57.32	,	42.97	\ /*
	*/	58.13	,	43.56	\ /*
	*/	58.93	,	44.15	\ /*
	*/	59.74	,	44.74	\ /*
	*/	60.54	,	45.33	\ /*
	*/	61.35	,	45.92	\ /*
	*/	62.16	,	46.51	\ /*
	*/	62.96	,	47.10	\ /*
	*/	63.77	,	47.69	\ /*
	*/	64.57	,	48.28	\ /*
	*/	65.38	,	48.87	\ /*
	*/	66.19	,	49.46	\ /*
	*/	66.99	,	50.05	\ /*
	*/	67.80	,	50.64	\ /*
	*/	68.60	,	51.23	\ /*
	*/	69.41	,	51.82	\ /*
	*/	70.22	,	52.41	\ /*
	*/	71.02	,	53.00	\ /*
	*/	71.83	,	53.59	\ /*
	*/	72.64	,	54.18	\ /*
	*/	73.44	,	54.77	\ /*
	*/	74.25	,	55.36	\ /*
	*/	75.05	,	55.95	\ /*
	*/	75.86	,	56.54	\ /*
	*/	76.67	,	57.13	\ /*
	*/	77.47	,	57.72	\ /*
	*/	78.28	,	58.31	\ /*
	*/	79.08	,	58.90	\ /*
	*/	79.89	,	59.49	\ /*
	*/	80.70	,	60.08	\ /*
	*/	81.50	,	60.67	\ /*
	*/	82.31	,	61.26	\ /*
	*/	83.12	,	61.85	\ /*
	*/	83.92	,	62.44	\ /*
	*/	84.73	,	63.03	\ /*
	*/	85.53	,	63.62	\ /*
	*/	86.34	,	64.21	\ /*
	*/	87.15	,	64.80	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize25" {
		matrix input `temp' = ( /*
	*/	5.53	,	.	\ /*
	*/	7.25	,	3.63	\ /*
	*/	7.80	,	5.45	\ /*
	*/	8.31	,	6.28	\ /*
	*/	8.84	,	6.89	\ /*
	*/	9.38	,	7.42	\ /*
	*/	9.93	,	7.91	\ /*
	*/	10.50	,	8.39	\ /*
	*/	11.07	,	8.85	\ /*
	*/	11.65	,	9.31	\ /*
	*/	12.23	,	9.77	\ /*
	*/	12.82	,	10.22	\ /*
	*/	13.41	,	10.68	\ /*
	*/	14.00	,	11.13	\ /*
	*/	14.60	,	11.58	\ /*
	*/	15.19	,	12.03	\ /*
	*/	15.79	,	12.49	\ /*
	*/	16.39	,	12.94	\ /*
	*/	16.99	,	13.39	\ /*
	*/	17.60	,	13.84	\ /*
	*/	18.20	,	14.29	\ /*
	*/	18.80	,	14.74	\ /*
	*/	19.41	,	15.19	\ /*
	*/	20.01	,	15.64	\ /*
	*/	20.61	,	16.10	\ /*
	*/	21.22	,	16.55	\ /*
	*/	21.83	,	17.00	\ /*
	*/	22.43	,	17.45	\ /*
	*/	23.04	,	17.90	\ /*
	*/	23.65	,	18.35	\ /*
	*/	24.25	,	18.81	\ /*
	*/	24.86	,	19.26	\ /*
	*/	25.47	,	19.71	\ /*
	*/	26.08	,	20.16	\ /*
	*/	26.68	,	20.61	\ /*
	*/	27.29	,	21.06	\ /*
	*/	27.90	,	21.52	\ /*
	*/	28.51	,	21.97	\ /*
	*/	29.12	,	22.42	\ /*
	*/	29.73	,	22.87	\ /*
	*/	30.33	,	23.32	\ /*
	*/	30.94	,	23.78	\ /*
	*/	31.55	,	24.23	\ /*
	*/	32.16	,	24.68	\ /*
	*/	32.77	,	25.13	\ /*
	*/	33.38	,	25.58	\ /*
	*/	33.99	,	26.04	\ /*
	*/	34.60	,	26.49	\ /*
	*/	35.21	,	26.94	\ /*
	*/	35.82	,	27.39	\ /*
	*/	36.43	,	27.85	\ /*
	*/	37.04	,	28.30	\ /*
	*/	37.65	,	28.75	\ /*
	*/	38.25	,	29.20	\ /*
	*/	38.86	,	29.66	\ /*
	*/	39.47	,	30.11	\ /*
	*/	40.08	,	30.56	\ /*
	*/	40.69	,	31.01	\ /*
	*/	41.30	,	31.47	\ /*
	*/	41.91	,	31.92	\ /*
	*/	42.52	,	32.37	\ /*
	*/	43.13	,	32.82	\ /*
	*/	43.74	,	33.27	\ /*
	*/	44.35	,	33.73	\ /*
	*/	44.96	,	34.18	\ /*
	*/	45.57	,	34.63	\ /*
	*/	46.18	,	35.08	\ /*
	*/	46.78	,	35.54	\ /*
	*/	47.39	,	35.99	\ /*
	*/	48.00	,	36.44	\ /*
	*/	48.61	,	36.89	\ /*
	*/	49.22	,	37.35	\ /*
	*/	49.83	,	37.80	\ /*
	*/	50.44	,	38.25	\ /*
	*/	51.05	,	38.70	\ /*
	*/	51.66	,	39.16	\ /*
	*/	52.27	,	39.61	\ /*
	*/	52.88	,	40.06	\ /*
	*/	53.49	,	40.51	\ /*
	*/	54.10	,	40.96	\ /*
	*/	54.71	,	41.42	\ /*
	*/	55.32	,	41.87	\ /*
	*/	55.92	,	42.32	\ /*
	*/	56.53	,	42.77	\ /*
	*/	57.14	,	43.23	\ /*
	*/	57.75	,	43.68	\ /*
	*/	58.36	,	44.13	\ /*
	*/	58.97	,	44.58	\ /*
	*/	59.58	,	45.04	\ /*
	*/	60.19	,	45.49	\ /*
	*/	60.80	,	45.94	\ /*
	*/	61.41	,	46.39	\ /*
	*/	62.02	,	46.85	\ /*
	*/	62.63	,	47.30	\ /*
	*/	63.24	,	47.75	\ /*
	*/	63.85	,	48.20	\ /*
	*/	64.45	,	48.65	\ /*
	*/	65.06	,	49.11	\ /*
	*/	65.67	,	49.56	\ /*
	*/	66.28	,	50.01	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel5" {
		matrix input `temp' = ( /*
	*/	24.09	,	.	\ /*
	*/	13.46	,	15.50	\ /*
	*/	9.61	,	10.83	\ /*
	*/	7.63	,	8.53	\ /*
	*/	6.42	,	7.16	\ /*
	*/	5.61	,	6.24	\ /*
	*/	5.02	,	5.59	\ /*
	*/	4.58	,	5.10	\ /*
	*/	4.23	,	4.71	\ /*
	*/	3.96	,	4.41	\ /*
	*/	3.73	,	4.15	\ /*
	*/	3.54	,	3.94	\ /*
	*/	3.38	,	3.76	\ /*
	*/	3.24	,	3.60	\ /*
	*/	3.12	,	3.47	\ /*
	*/	3.01	,	3.35	\ /*
	*/	2.92	,	3.24	\ /*
	*/	2.84	,	3.15	\ /*
	*/	2.76	,	3.06	\ /*
	*/	2.69	,	2.98	\ /*
	*/	2.63	,	2.91	\ /*
	*/	2.58	,	2.85	\ /*
	*/	2.52	,	2.79	\ /*
	*/	2.48	,	2.73	\ /*
	*/	2.43	,	2.68	\ /*
	*/	2.39	,	2.63	\ /*
	*/	2.36	,	2.59	\ /*
	*/	2.32	,	2.55	\ /*
	*/	2.29	,	2.51	\ /*
	*/	2.26	,	2.47	\ /*
	*/	2.23	,	2.44	\ /*
	*/	2.20	,	2.41	\ /*
	*/	2.18	,	2.37	\ /*
	*/	2.16	,	2.35	\ /*
	*/	2.13	,	2.32	\ /*
	*/	2.11	,	2.29	\ /*
	*/	2.09	,	2.27	\ /*
	*/	2.07	,	2.24	\ /*
	*/	2.05	,	2.22	\ /*
	*/	2.04	,	2.20	\ /*
	*/	2.02	,	2.18	\ /*
	*/	2.00	,	2.16	\ /*
	*/	1.99	,	2.14	\ /*
	*/	1.97	,	2.12	\ /*
	*/	1.96	,	2.10	\ /*
	*/	1.94	,	2.09	\ /*
	*/	1.93	,	2.07	\ /*
	*/	1.92	,	2.05	\ /*
	*/	1.91	,	2.04	\ /*
	*/	1.89	,	2.02	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.87	,	2.00	\ /*
	*/	1.86	,	1.98	\ /*
	*/	1.85	,	1.97	\ /*
	*/	1.84	,	1.96	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.82	,	1.94	\ /*
	*/	1.81	,	1.92	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.90	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.78	,	1.88	\ /*
	*/	1.77	,	1.87	\ /*
	*/	1.76	,	1.87	\ /*
	*/	1.75	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.84	\ /*
	*/	1.73	,	1.83	\ /*
	*/	1.72	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.66	,	1.76	\ /*
	*/	1.65	,	1.76	\ /*
	*/	1.65	,	1.75	\ /*
	*/	1.64	,	1.75	\ /*
	*/	1.64	,	1.74	\ /*
	*/	1.63	,	1.74	\ /*
	*/	1.63	,	1.73	\ /*
	*/	1.62	,	1.73	\ /*
	*/	1.61	,	1.73	\ /*
	*/	1.61	,	1.72	\ /*
	*/	1.60	,	1.72	\ /*
	*/	1.60	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.58	,	1.70	\ /*
	*/	1.57	,	1.70	\ /*
	*/	1.57	,	1.70	\ /*
	*/	1.56	,	1.69	\ /*
	*/	1.56	,	1.69	\ /*
	*/	1.55	,	1.69	\ /*
	*/	1.55	,	1.69	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel10" {
		matrix input `temp' = ( /*
	*/	19.36	,	.	\ /*
	*/	10.89	,	12.55	\ /*
	*/	7.90	,	8.96	\ /*
	*/	6.37	,	7.15	\ /*
	*/	5.44	,	6.07	\ /*
	*/	4.81	,	5.34	\ /*
	*/	4.35	,	4.82	\ /*
	*/	4.01	,	4.43	\ /*
	*/	3.74	,	4.12	\ /*
	*/	3.52	,	3.87	\ /*
	*/	3.34	,	3.67	\ /*
	*/	3.19	,	3.49	\ /*
	*/	3.06	,	3.35	\ /*
	*/	2.95	,	3.22	\ /*
	*/	2.85	,	3.11	\ /*
	*/	2.76	,	3.01	\ /*
	*/	2.69	,	2.92	\ /*
	*/	2.62	,	2.84	\ /*
	*/	2.56	,	2.77	\ /*
	*/	2.50	,	2.71	\ /*
	*/	2.45	,	2.65	\ /*
	*/	2.40	,	2.60	\ /*
	*/	2.36	,	2.55	\ /*
	*/	2.32	,	2.50	\ /*
	*/	2.28	,	2.46	\ /*
	*/	2.24	,	2.42	\ /*
	*/	2.21	,	2.38	\ /*
	*/	2.18	,	2.35	\ /*
	*/	2.15	,	2.31	\ /*
	*/	2.12	,	2.28	\ /*
	*/	2.10	,	2.25	\ /*
	*/	2.07	,	2.23	\ /*
	*/	2.05	,	2.20	\ /*
	*/	2.03	,	2.17	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.99	,	2.13	\ /*
	*/	1.97	,	2.11	\ /*
	*/	1.95	,	2.09	\ /*
	*/	1.93	,	2.07	\ /*
	*/	1.92	,	2.05	\ /*
	*/	1.90	,	2.03	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.87	,	2.00	\ /*
	*/	1.86	,	1.98	\ /*
	*/	1.84	,	1.96	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.82	,	1.93	\ /*
	*/	1.81	,	1.92	\ /*
	*/	1.79	,	1.91	\ /*
	*/	1.78	,	1.89	\ /*
	*/	1.77	,	1.88	\ /*
	*/	1.76	,	1.87	\ /*
	*/	1.75	,	1.86	\ /*
	*/	1.74	,	1.85	\ /*
	*/	1.73	,	1.84	\ /*
	*/	1.72	,	1.83	\ /*
	*/	1.71	,	1.82	\ /*
	*/	1.70	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.67	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.75	\ /*
	*/	1.64	,	1.74	\ /*
	*/	1.64	,	1.73	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.62	,	1.71	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.60	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.59	,	1.68	\ /*
	*/	1.59	,	1.67	\ /*
	*/	1.58	,	1.67	\ /*
	*/	1.58	,	1.66	\ /*
	*/	1.57	,	1.66	\ /*
	*/	1.57	,	1.65	\ /*
	*/	1.56	,	1.65	\ /*
	*/	1.56	,	1.64	\ /*
	*/	1.56	,	1.64	\ /*
	*/	1.55	,	1.63	\ /*
	*/	1.55	,	1.63	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.54	,	1.62	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.53	,	1.61	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.60	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.59	\ /*
	*/	1.51	,	1.58	\ /*
	*/	1.50	,	1.58	)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel20" {
		matrix input `temp' = ( /*
	*/	15.64	,	.	\ /*
	*/	9.00	,	9.72	\ /*
	*/	6.61	,	7.18	\ /*
	*/	5.38	,	5.85	\ /*
	*/	4.62	,	5.04	\ /*
	*/	4.11	,	4.48	\ /*
	*/	3.75	,	4.08	\ /*
	*/	3.47	,	3.77	\ /*
	*/	3.25	,	3.53	\ /*
	*/	3.07	,	3.33	\ /*
	*/	2.92	,	3.17	\ /*
	*/	2.80	,	3.04	\ /*
	*/	2.70	,	2.92	\ /*
	*/	2.61	,	2.82	\ /*
	*/	2.53	,	2.73	\ /*
	*/	2.46	,	2.65	\ /*
	*/	2.39	,	2.58	\ /*
	*/	2.34	,	2.52	\ /*
	*/	2.29	,	2.46	\ /*
	*/	2.24	,	2.41	\ /*
	*/	2.20	,	2.36	\ /*
	*/	2.16	,	2.32	\ /*
	*/	2.13	,	2.28	\ /*
	*/	2.10	,	2.24	\ /*
	*/	2.06	,	2.21	\ /*
	*/	2.04	,	2.18	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.99	,	2.12	\ /*
	*/	1.96	,	2.09	\ /*
	*/	1.94	,	2.07	\ /*
	*/	1.92	,	2.04	\ /*
	*/	1.90	,	2.02	\ /*
	*/	1.88	,	2.00	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.85	,	1.96	\ /*
	*/	1.83	,	1.94	\ /*
	*/	1.82	,	1.93	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.78	,	1.88	\ /*
	*/	1.76	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.84	\ /*
	*/	1.73	,	1.82	\ /*
	*/	1.72	,	1.81	\ /*
	*/	1.71	,	1.80	\ /*
	*/	1.70	,	1.79	\ /*
	*/	1.69	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.65	,	1.73	\ /*
	*/	1.64	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullrel30" {
		matrix input `temp' = ( /*
	*/	12.71	,	.	\ /*
	*/	7.49	,	8.03	\ /*
	*/	5.60	,	6.15	\ /*
	*/	4.63	,	5.10	\ /*
	*/	4.03	,	4.44	\ /*
	*/	3.63	,	3.98	\ /*
	*/	3.33	,	3.65	\ /*
	*/	3.11	,	3.39	\ /*
	*/	2.93	,	3.19	\ /*
	*/	2.79	,	3.02	\ /*
	*/	2.67	,	2.88	\ /*
	*/	2.57	,	2.77	\ /*
	*/	2.48	,	2.67	\ /*
	*/	2.41	,	2.58	\ /*
	*/	2.34	,	2.51	\ /*
	*/	2.28	,	2.44	\ /*
	*/	2.23	,	2.38	\ /*
	*/	2.18	,	2.33	\ /*
	*/	2.14	,	2.28	\ /*
	*/	2.10	,	2.23	\ /*
	*/	2.07	,	2.19	\ /*
	*/	2.04	,	2.16	\ /*
	*/	2.01	,	2.12	\ /*
	*/	1.98	,	2.09	\ /*
	*/	1.95	,	2.06	\ /*
	*/	1.93	,	2.03	\ /*
	*/	1.90	,	2.01	\ /*
	*/	1.88	,	1.98	\ /*
	*/	1.86	,	1.96	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.83	,	1.92	\ /*
	*/	1.81	,	1.90	\ /*
	*/	1.79	,	1.88	\ /*
	*/	1.78	,	1.87	\ /*
	*/	1.76	,	1.85	\ /*
	*/	1.75	,	1.83	\ /*
	*/	1.74	,	1.82	\ /*
	*/	1.72	,	1.80	\ /*
	*/	1.71	,	1.79	\ /*
	*/	1.70	,	1.78	\ /*
	*/	1.69	,	1.77	\ /*
	*/	1.68	,	1.75	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.73	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.60	,	1.66	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.47	\ /*
	*/	1.42	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.41	,	1.46	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax5" {
		matrix input `temp' = ( /*
	*/	23.81	,	.	\ /*
	*/	12.38	,	14.19	\ /*
	*/	8.66	,	10.00	\ /*
	*/	6.81	,	7.88	\ /*
	*/	5.71	,	6.60	\ /*
	*/	4.98	,	5.74	\ /*
	*/	4.45	,	5.13	\ /*
	*/	4.06	,	4.66	\ /*
	*/	3.76	,	4.30	\ /*
	*/	3.51	,	4.01	\ /*
	*/	3.31	,	3.77	\ /*
	*/	3.15	,	3.57	\ /*
	*/	3.00	,	3.41	\ /*
	*/	2.88	,	3.26	\ /*
	*/	2.78	,	3.13	\ /*
	*/	2.69	,	3.02	\ /*
	*/	2.61	,	2.92	\ /*
	*/	2.53	,	2.84	\ /*
	*/	2.47	,	2.76	\ /*
	*/	2.41	,	2.69	\ /*
	*/	2.36	,	2.62	\ /*
	*/	2.31	,	2.56	\ /*
	*/	2.27	,	2.51	\ /*
	*/	2.23	,	2.46	\ /*
	*/	2.19	,	2.42	\ /*
	*/	2.15	,	2.37	\ /*
	*/	2.12	,	2.33	\ /*
	*/	2.09	,	2.30	\ /*
	*/	2.07	,	2.26	\ /*
	*/	2.04	,	2.23	\ /*
	*/	2.02	,	2.20	\ /*
	*/	1.99	,	2.17	\ /*
	*/	1.97	,	2.14	\ /*
	*/	1.95	,	2.12	\ /*
	*/	1.93	,	2.10	\ /*
	*/	1.91	,	2.07	\ /*
	*/	1.90	,	2.05	\ /*
	*/	1.88	,	2.03	\ /*
	*/	1.87	,	2.01	\ /*
	*/	1.85	,	1.99	\ /*
	*/	1.84	,	1.98	\ /*
	*/	1.82	,	1.96	\ /*
	*/	1.81	,	1.94	\ /*
	*/	1.80	,	1.93	\ /*
	*/	1.79	,	1.91	\ /*
	*/	1.78	,	1.90	\ /*
	*/	1.76	,	1.88	\ /*
	*/	1.75	,	1.87	\ /*
	*/	1.74	,	1.86	\ /*
	*/	1.73	,	1.85	\ /*
	*/	1.73	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.79	\ /*
	*/	1.68	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.65	,	1.74	\ /*
	*/	1.64	,	1.73	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.61	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.59	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.57	\ /*
	*/	1.50	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.48	,	1.55	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.47	,	1.54	\ /*
	*/	1.47	,	1.54	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.46	,	1.53	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax10" {
		matrix input `temp' = ( /*
	*/	19.40	,	.	\ /*
	*/	10.14	,	11.92	\ /*
	*/	7.18	,	8.39	\ /*
	*/	5.72	,	6.64	\ /*
	*/	4.85	,	5.60	\ /*
	*/	4.27	,	4.90	\ /*
	*/	3.86	,	4.40	\ /*
	*/	3.55	,	4.03	\ /*
	*/	3.31	,	3.73	\ /*
	*/	3.12	,	3.50	\ /*
	*/	2.96	,	3.31	\ /*
	*/	2.83	,	3.15	\ /*
	*/	2.71	,	3.01	\ /*
	*/	2.62	,	2.89	\ /*
	*/	2.53	,	2.79	\ /*
	*/	2.46	,	2.70	\ /*
	*/	2.39	,	2.62	\ /*
	*/	2.33	,	2.55	\ /*
	*/	2.28	,	2.49	\ /*
	*/	2.23	,	2.43	\ /*
	*/	2.19	,	2.38	\ /*
	*/	2.15	,	2.33	\ /*
	*/	2.11	,	2.29	\ /*
	*/	2.08	,	2.25	\ /*
	*/	2.05	,	2.21	\ /*
	*/	2.02	,	2.18	\ /*
	*/	1.99	,	2.14	\ /*
	*/	1.97	,	2.11	\ /*
	*/	1.94	,	2.08	\ /*
	*/	1.92	,	2.06	\ /*
	*/	1.90	,	2.03	\ /*
	*/	1.88	,	2.01	\ /*
	*/	1.86	,	1.99	\ /*
	*/	1.85	,	1.97	\ /*
	*/	1.83	,	1.95	\ /*
	*/	1.81	,	1.93	\ /*
	*/	1.80	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.77	,	1.88	\ /*
	*/	1.76	,	1.86	\ /*
	*/	1.75	,	1.85	\ /*
	*/	1.74	,	1.83	\ /*
	*/	1.72	,	1.82	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.70	,	1.80	\ /*
	*/	1.69	,	1.78	\ /*
	*/	1.68	,	1.77	\ /*
	*/	1.67	,	1.76	\ /*
	*/	1.66	,	1.75	\ /*
	*/	1.66	,	1.74	\ /*
	*/	1.65	,	1.73	\ /*
	*/	1.64	,	1.72	\ /*
	*/	1.63	,	1.71	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.69	\ /*
	*/	1.60	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.57	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.63	\ /*
	*/	1.55	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.53	,	1.60	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.46	,	1.52	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.44	,	1.50	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.42	,	1.48	\ /*
	*/	1.42	,	1.47	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax20" {
		matrix input `temp' = ( /*
	*/	15.39	,	.	\ /*
	*/	8.16	,	9.41	\ /*
	*/	5.87	,	6.79	\ /*
	*/	4.75	,	5.47	\ /*
	*/	4.08	,	4.66	\ /*
	*/	3.64	,	4.13	\ /*
	*/	3.32	,	3.74	\ /*
	*/	3.08	,	3.45	\ /*
	*/	2.89	,	3.22	\ /*
	*/	2.74	,	3.03	\ /*
	*/	2.62	,	2.88	\ /*
	*/	2.51	,	2.76	\ /*
	*/	2.42	,	2.65	\ /*
	*/	2.35	,	2.56	\ /*
	*/	2.28	,	2.48	\ /*
	*/	2.22	,	2.40	\ /*
	*/	2.17	,	2.34	\ /*
	*/	2.12	,	2.28	\ /*
	*/	2.08	,	2.23	\ /*
	*/	2.04	,	2.19	\ /*
	*/	2.01	,	2.15	\ /*
	*/	1.98	,	2.11	\ /*
	*/	1.95	,	2.07	\ /*
	*/	1.92	,	2.04	\ /*
	*/	1.89	,	2.01	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.85	,	1.96	\ /*
	*/	1.83	,	1.93	\ /*
	*/	1.81	,	1.91	\ /*
	*/	1.79	,	1.89	\ /*
	*/	1.77	,	1.87	\ /*
	*/	1.76	,	1.85	\ /*
	*/	1.74	,	1.83	\ /*
	*/	1.73	,	1.82	\ /*
	*/	1.72	,	1.80	\ /*
	*/	1.70	,	1.79	\ /*
	*/	1.69	,	1.77	\ /*
	*/	1.68	,	1.76	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.73	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.69	\ /*
	*/	1.61	,	1.68	\ /*
	*/	1.60	,	1.67	\ /*
	*/	1.59	,	1.66	\ /*
	*/	1.58	,	1.65	\ /*
	*/	1.58	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.56	,	1.62	\ /*
	*/	1.55	,	1.61	\ /*
	*/	1.54	,	1.60	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.53	,	1.59	\ /*
	*/	1.52	,	1.58	\ /*
	*/	1.52	,	1.57	\ /*
	*/	1.51	,	1.57	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.52	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.46	,	1.51	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.50	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.44	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.43	,	1.48	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.37	,	1.41	\ /*
	*/	1.37	,	1.41	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax30" {
		matrix input `temp' = ( /*
	*/	12.76	,	.	\ /*
	*/	6.97	,	8.01	\ /*
	*/	5.11	,	5.88	\ /*
	*/	4.19	,	4.78	\ /*
	*/	3.64	,	4.12	\ /*
	*/	3.27	,	3.67	\ /*
	*/	3.00	,	3.35	\ /*
	*/	2.80	,	3.10	\ /*
	*/	2.64	,	2.91	\ /*
	*/	2.52	,	2.76	\ /*
	*/	2.41	,	2.63	\ /*
	*/	2.33	,	2.52	\ /*
	*/	2.25	,	2.43	\ /*
	*/	2.19	,	2.35	\ /*
	*/	2.13	,	2.29	\ /*
	*/	2.08	,	2.22	\ /*
	*/	2.04	,	2.17	\ /*
	*/	2.00	,	2.12	\ /*
	*/	1.96	,	2.08	\ /*
	*/	1.93	,	2.04	\ /*
	*/	1.90	,	2.01	\ /*
	*/	1.87	,	1.97	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.82	,	1.92	\ /*
	*/	1.80	,	1.89	\ /*
	*/	1.78	,	1.87	\ /*
	*/	1.76	,	1.84	\ /*
	*/	1.74	,	1.82	\ /*
	*/	1.73	,	1.80	\ /*
	*/	1.71	,	1.79	\ /*
	*/	1.70	,	1.77	\ /*
	*/	1.68	,	1.75	\ /*
	*/	1.67	,	1.74	\ /*
	*/	1.66	,	1.72	\ /*
	*/	1.64	,	1.71	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.68	\ /*
	*/	1.61	,	1.67	\ /*
	*/	1.60	,	1.66	\ /*
	*/	1.59	,	1.65	\ /*
	*/	1.58	,	1.64	\ /*
	*/	1.57	,	1.63	\ /*
	*/	1.57	,	1.62	\ /*
	*/	1.56	,	1.61	\ /*
	*/	1.55	,	1.60	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.54	,	1.59	\ /*
	*/	1.53	,	1.58	\ /*
	*/	1.52	,	1.57	\ /*
	*/	1.52	,	1.56	\ /*
	*/	1.51	,	1.56	\ /*
	*/	1.50	,	1.55	\ /*
	*/	1.50	,	1.54	\ /*
	*/	1.49	,	1.54	\ /*
	*/	1.49	,	1.53	\ /*
	*/	1.48	,	1.53	\ /*
	*/	1.48	,	1.52	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.47	,	1.51	\ /*
	*/	1.46	,	1.50	\ /*
	*/	1.46	,	1.50	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.45	,	1.49	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.48	\ /*
	*/	1.44	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.43	,	1.47	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.46	\ /*
	*/	1.42	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.45	\ /*
	*/	1.41	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.44	\ /*
	*/	1.40	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.43	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.39	,	1.42	\ /*
	*/	1.38	,	1.42	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.38	,	1.41	\ /*
	*/	1.37	,	1.41	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.37	,	1.40	\ /*
	*/	1.36	,	1.40	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.39	\ /*
	*/	1.36	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.38	\ /*
	*/	1.35	,	1.37	\ /*
	*/	1.34	,	1.37	\ /*
	*/	1.34	,	1.37	\ /*
	*/	1.34	,	1.37	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize10" {
		matrix input `temp' = ( /*
	*/	16.38	,	.	\ /*
	*/	8.68	,	7.03	\ /*
	*/	6.46	,	5.44	\ /*
	*/	5.44	,	4.72	\ /*
	*/	4.84	,	4.32	\ /*
	*/	4.45	,	4.06	\ /*
	*/	4.18	,	3.90	\ /*
	*/	3.97	,	3.78	\ /*
	*/	3.81	,	3.70	\ /*
	*/	3.68	,	3.64	\ /*
	*/	3.58	,	3.60	\ /*
	*/	3.50	,	3.58	\ /*
	*/	3.42	,	3.56	\ /*
	*/	3.36	,	3.55	\ /*
	*/	3.31	,	3.54	\ /*
	*/	3.27	,	3.55	\ /*
	*/	3.24	,	3.55	\ /*
	*/	3.20	,	3.56	\ /*
	*/	3.18	,	3.57	\ /*
	*/	3.21	,	3.58	\ /*
	*/	3.39	,	3.59	\ /*
	*/	3.57	,	3.60	\ /*
	*/	3.68	,	3.62	\ /*
	*/	3.75	,	3.64	\ /*
	*/	3.79	,	3.65	\ /*
	*/	3.82	,	3.67	\ /*
	*/	3.85	,	3.74	\ /*
	*/	3.86	,	3.87	\ /*
	*/	3.87	,	4.02	\ /*
	*/	3.88	,	4.12	\ /*
	*/	3.89	,	4.19	\ /*
	*/	3.89	,	4.24	\ /*
	*/	3.90	,	4.27	\ /*
	*/	3.90	,	4.31	\ /*
	*/	3.90	,	4.33	\ /*
	*/	3.90	,	4.36	\ /*
	*/	3.90	,	4.38	\ /*
	*/	3.90	,	4.39	\ /*
	*/	3.90	,	4.41	\ /*
	*/	3.90	,	4.43	\ /*
	*/	3.90	,	4.44	\ /*
	*/	3.90	,	4.45	\ /*
	*/	3.90	,	4.47	\ /*
	*/	3.90	,	4.48	\ /*
	*/	3.90	,	4.49	\ /*
	*/	3.90	,	4.50	\ /*
	*/	3.90	,	4.51	\ /*
	*/	3.90	,	4.52	\ /*
	*/	3.90	,	4.53	\ /*
	*/	3.90	,	4.54	\ /*
	*/	3.90	,	4.55	\ /*
	*/	3.90	,	4.56	\ /*
	*/	3.90	,	4.56	\ /*
	*/	3.90	,	4.57	\ /*
	*/	3.90	,	4.58	\ /*
	*/	3.90	,	4.59	\ /*
	*/	3.90	,	4.59	\ /*
	*/	3.90	,	4.60	\ /*
	*/	3.90	,	4.61	\ /*
	*/	3.90	,	4.61	\ /*
	*/	3.90	,	4.62	\ /*
	*/	3.90	,	4.62	\ /*
	*/	3.90	,	4.63	\ /*
	*/	3.90	,	4.63	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.64	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.65	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.89	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.88	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.87	,	4.66	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.65	\ /*
	*/	3.86	,	4.64	\ /*
	*/	3.85	,	4.64	\ /*
	*/	3.85	,	4.64	\ /*
	*/	3.85	,	4.63	\ /*
	*/	3.85	,	4.63	\ /*
	*/	3.84	,	4.62	\ /*
	*/	3.84	,	4.62	\ /*
	*/	3.84	,	4.61	\ /*
	*/	3.84	,	4.60	\ /*
	*/	3.83	,	4.60	\ /*
	*/	3.83	,	4.59	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize15" {
		matrix input `temp' = ( /*
	*/	8.96	,	.	\ /*
	*/	5.33	,	4.58	\ /*
	*/	4.36	,	3.81	\ /*
	*/	3.87	,	3.39	\ /*
	*/	3.56	,	3.13	\ /*
	*/	3.34	,	2.95	\ /*
	*/	3.18	,	2.83	\ /*
	*/	3.04	,	2.73	\ /*
	*/	2.93	,	2.66	\ /*
	*/	2.84	,	2.60	\ /*
	*/	2.76	,	2.55	\ /*
	*/	2.69	,	2.52	\ /*
	*/	2.63	,	2.48	\ /*
	*/	2.57	,	2.46	\ /*
	*/	2.52	,	2.44	\ /*
	*/	2.48	,	2.42	\ /*
	*/	2.44	,	2.41	\ /*
	*/	2.41	,	2.40	\ /*
	*/	2.37	,	2.39	\ /*
	*/	2.34	,	2.38	\ /*
	*/	2.32	,	2.38	\ /*
	*/	2.29	,	2.37	\ /*
	*/	2.27	,	2.37	\ /*
	*/	2.25	,	2.37	\ /*
	*/	2.24	,	2.37	\ /*
	*/	2.22	,	2.38	\ /*
	*/	2.21	,	2.38	\ /*
	*/	2.20	,	2.38	\ /*
	*/	2.19	,	2.39	\ /*
	*/	2.18	,	2.39	\ /*
	*/	2.19	,	2.40	\ /*
	*/	2.22	,	2.41	\ /*
	*/	2.33	,	2.42	\ /*
	*/	2.40	,	2.42	\ /*
	*/	2.45	,	2.43	\ /*
	*/	2.48	,	2.44	\ /*
	*/	2.50	,	2.45	\ /*
	*/	2.52	,	2.54	\ /*
	*/	2.53	,	2.55	\ /*
	*/	2.54	,	2.66	\ /*
	*/	2.55	,	2.73	\ /*
	*/	2.56	,	2.78	\ /*
	*/	2.57	,	2.82	\ /*
	*/	2.57	,	2.85	\ /*
	*/	2.58	,	2.87	\ /*
	*/	2.58	,	2.89	\ /*
	*/	2.58	,	2.91	\ /*
	*/	2.59	,	2.92	\ /*
	*/	2.59	,	2.93	\ /*
	*/	2.59	,	2.94	\ /*
	*/	2.59	,	2.95	\ /*
	*/	2.59	,	2.96	\ /*
	*/	2.60	,	2.97	\ /*
	*/	2.60	,	2.98	\ /*
	*/	2.60	,	2.98	\ /*
	*/	2.60	,	2.99	\ /*
	*/	2.60	,	2.99	\ /*
	*/	2.60	,	3.00	\ /*
	*/	2.60	,	3.00	\ /*
	*/	2.60	,	3.01	\ /*
	*/	2.60	,	3.01	\ /*
	*/	2.60	,	3.02	\ /*
	*/	2.61	,	3.02	\ /*
	*/	2.61	,	3.02	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.03	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.61	,	3.04	\ /*
	*/	2.60	,	3.04	\ /*
	*/	2.60	,	3.04	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.60	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.05	\ /*
	*/	2.59	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.04	\ /*
	*/	2.58	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.03	\ /*
	*/	2.57	,	3.02	\ /*
	*/	2.56	,	3.02	\ /*
	*/	2.56	,	3.02	)
	
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize20" {
		matrix input `temp' = ( /*
	*/	6.66	,	.	\ /*
	*/	4.42	,	3.95	\ /*
	*/	3.69	,	3.32	\ /*
	*/	3.30	,	2.99	\ /*
	*/	3.05	,	2.78	\ /*
	*/	2.87	,	2.63	\ /*
	*/	2.73	,	2.52	\ /*
	*/	2.63	,	2.43	\ /*
	*/	2.54	,	2.36	\ /*
	*/	2.46	,	2.30	\ /*
	*/	2.40	,	2.25	\ /*
	*/	2.34	,	2.21	\ /*
	*/	2.29	,	2.17	\ /*
	*/	2.25	,	2.14	\ /*
	*/	2.21	,	2.11	\ /*
	*/	2.18	,	2.09	\ /*
	*/	2.14	,	2.07	\ /*
	*/	2.11	,	2.05	\ /*
	*/	2.09	,	2.03	\ /*
	*/	2.06	,	2.02	\ /*
	*/	2.04	,	2.01	\ /*
	*/	2.02	,	1.99	\ /*
	*/	2.00	,	1.98	\ /*
	*/	1.98	,	1.98	\ /*
	*/	1.96	,	1.97	\ /*
	*/	1.95	,	1.96	\ /*
	*/	1.93	,	1.96	\ /*
	*/	1.92	,	1.95	\ /*
	*/	1.90	,	1.95	\ /*
	*/	1.89	,	1.95	\ /*
	*/	1.88	,	1.94	\ /*
	*/	1.87	,	1.94	\ /*
	*/	1.86	,	1.94	\ /*
	*/	1.85	,	1.94	\ /*
	*/	1.84	,	1.94	\ /*
	*/	1.83	,	1.94	\ /*
	*/	1.82	,	1.94	\ /*
	*/	1.81	,	1.95	\ /*
	*/	1.81	,	1.95	\ /*
	*/	1.80	,	1.95	\ /*
	*/	1.79	,	1.95	\ /*
	*/	1.79	,	1.96	\ /*
	*/	1.78	,	1.96	\ /*
	*/	1.78	,	1.97	\ /*
	*/	1.80	,	1.97	\ /*
	*/	1.87	,	1.98	\ /*
	*/	1.92	,	1.98	\ /*
	*/	1.95	,	1.99	\ /*
	*/	1.97	,	2.00	\ /*
	*/	1.99	,	2.00	\ /*
	*/	2.00	,	2.01	\ /*
	*/	2.01	,	2.09	\ /*
	*/	2.02	,	2.11	\ /*
	*/	2.03	,	2.18	\ /*
	*/	2.04	,	2.23	\ /*
	*/	2.04	,	2.27	\ /*
	*/	2.05	,	2.29	\ /*
	*/	2.05	,	2.31	\ /*
	*/	2.06	,	2.33	\ /*
	*/	2.06	,	2.34	\ /*
	*/	2.07	,	2.35	\ /*
	*/	2.07	,	2.36	\ /*
	*/	2.07	,	2.37	\ /*
	*/	2.08	,	2.38	\ /*
	*/	2.08	,	2.39	\ /*
	*/	2.08	,	2.39	\ /*
	*/	2.08	,	2.40	\ /*
	*/	2.09	,	2.40	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.41	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.42	\ /*
	*/	2.09	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.43	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.10	,	2.44	\ /*
	*/	2.09	,	2.44	\ /*
	*/	2.09	,	2.44	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.09	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.08	,	2.45	\ /*
	*/	2.07	,	2.44	\ /*
	*/	2.07	,	2.44	\ /*
	*/	2.07	,	2.44	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize25" {
		matrix input `temp' = ( /*
	*/	5.53	,	.	\ /*
	*/	3.92	,	3.63	\ /*
	*/	3.32	,	3.09	\ /*
	*/	2.98	,	2.79	\ /*
	*/	2.77	,	2.60	\ /*
	*/	2.61	,	2.46	\ /*
	*/	2.49	,	2.35	\ /*
	*/	2.39	,	2.27	\ /*
	*/	2.32	,	2.20	\ /*
	*/	2.25	,	2.14	\ /*
	*/	2.19	,	2.09	\ /*
	*/	2.14	,	2.05	\ /*
	*/	2.10	,	2.02	\ /*
	*/	2.06	,	1.99	\ /*
	*/	2.03	,	1.96	\ /*
	*/	2.00	,	1.93	\ /*
	*/	1.97	,	1.91	\ /*
	*/	1.94	,	1.89	\ /*
	*/	1.92	,	1.87	\ /*
	*/	1.90	,	1.86	\ /*
	*/	1.88	,	1.84	\ /*
	*/	1.86	,	1.83	\ /*
	*/	1.84	,	1.81	\ /*
	*/	1.83	,	1.80	\ /*
	*/	1.81	,	1.79	\ /*
	*/	1.80	,	1.78	\ /*
	*/	1.78	,	1.77	\ /*
	*/	1.77	,	1.77	\ /*
	*/	1.76	,	1.76	\ /*
	*/	1.75	,	1.75	\ /*
	*/	1.74	,	1.75	\ /*
	*/	1.73	,	1.74	\ /*
	*/	1.72	,	1.73	\ /*
	*/	1.71	,	1.73	\ /*
	*/	1.70	,	1.73	\ /*
	*/	1.69	,	1.72	\ /*
	*/	1.68	,	1.72	\ /*
	*/	1.67	,	1.71	\ /*
	*/	1.67	,	1.71	\ /*
	*/	1.66	,	1.71	\ /*
	*/	1.65	,	1.71	\ /*
	*/	1.65	,	1.71	\ /*
	*/	1.64	,	1.70	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.63	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.62	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.61	,	1.70	\ /*
	*/	1.60	,	1.70	\ /*
	*/	1.60	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.59	,	1.70	\ /*
	*/	1.58	,	1.70	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.58	,	1.71	\ /*
	*/	1.57	,	1.71	\ /*
	*/	1.59	,	1.71	\ /*
	*/	1.60	,	1.71	\ /*
	*/	1.63	,	1.72	\ /*
	*/	1.65	,	1.72	\ /*
	*/	1.67	,	1.72	\ /*
	*/	1.69	,	1.72	\ /*
	*/	1.70	,	1.76	\ /*
	*/	1.71	,	1.81	\ /*
	*/	1.72	,	1.87	\ /*
	*/	1.73	,	1.91	\ /*
	*/	1.74	,	1.94	\ /*
	*/	1.74	,	1.96	\ /*
	*/	1.75	,	1.98	\ /*
	*/	1.75	,	1.99	\ /*
	*/	1.76	,	2.01	\ /*
	*/	1.76	,	2.02	\ /*
	*/	1.77	,	2.03	\ /*
	*/	1.77	,	2.04	\ /*
	*/	1.78	,	2.04	\ /*
	*/	1.78	,	2.05	\ /*
	*/	1.78	,	2.06	\ /*
	*/	1.79	,	2.06	\ /*
	*/	1.79	,	2.07	\ /*
	*/	1.79	,	2.07	\ /*
	*/	1.79	,	2.08	\ /*
	*/	1.80	,	2.08	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.09	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.10	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	\ /*
	*/	1.80	,	2.11	)

		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	return scalar cv=`cv'
end /* end of cdsy program definition */

capture program drop dispbreak
program define dispbreak
	syntax , initial(string) todisplay(string) mlength(integer) tab(integer)
	local todisplay_1 "`initial'"
	local i=1
	foreach td of local todisplay {
		if (`i'==1) {
			if (length("`todisplay_`i''")<=`mlength' & length("`todisplay_`i'' `td'")>`mlength') {
				local i=`i'+1
				local todisplay_`i' `td'
			}
			if (length("`todisplay_`i''")<=`mlength' & length("`todisplay_`i'' `td'")<=`mlength') {
				local todisplay_`i' `todisplay_`i'' `td'
			}
		}
		if (`i'>1) {
			if (length("`todisplay_`i''")<=`mlength'-`tab' & length("`todisplay_`i'' `td'")>`mlength'-`tab') {
				local i=`i'+1
				local todisplay_`i' `td'
			}
			if (length("`todisplay_`i''")<=`mlength'-`tab' & length("`todisplay_`i'' `td'")<=`mlength'-`tab') {
				local todisplay_`i' `todisplay_`i'' `td'
			}
		}
	}
	noisily display "`todisplay_1'"
	forvalues ii=2/`i' {
		noisily display _col(`tab') "`todisplay_`ii''"
	}
end	/* end of dispbreak program definition */

capture program drop collincheck	/* from ivreg2 */
program define collincheck, rclass
	syntax , lhs(varname) [endog(varlist)] iexog(varlist) [exexog(varlist)] [weight(varname)] [wtexp(string)] touse(varname)
	* I. collinearities check using canonical correlations approach
	* eigenvalue=1 => included endog is really included exogenous
	* eigenvalue=0 => included endog collinear with another included endog
	* corresponding column names give name of variable
	if ("`exexog'"!="") {
		tempname XX X1X1 X1Z ZZ Z2Z2 XZ Z1Z2 Xy Zy YY yy yyc ZY Z2y Z2Y XXinv ZZinv XPZXinv wvar
		generate `wvar'=1
		quietly sum `wvar' if `touse' `wtexp', meanonly
		if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
			* effective number of observations is sum of weight variable.
			* if weight is "", weight var must be column of ones and N is number of rows
			local wf=1
			local N=r(sum_w)
		}
		* save commonly used matrices
		mata: s_crossprods	("`lhs'","`endog'","`iexog'","`exexog'","`touse'","","`wvar'",`wf',`N')
		mat `X1X1'=r(X1X1)
		mat `X1Z'=r(X1Z)
		mat `ZZ'=r(ZZ)
		mat `ZZinv'=r(ZZinv)
		local endog_ct : word count endog
		if `endog_ct' > 0 {
			tempname ccmat
			mata: s_cccollin	("`ZZ'","`X1X1'","`X1Z'","`ZZinv'","`endog'")
			mat `ccmat'=r(ccmat)
			* loop through endog to find eigenvalues=0 or 1
			local i=1
			foreach vn of varlist `endog' {
				if round(`ccmat'[`i',`i'],10e-7)==0 {
					* collinear with another endog, so remove from endog list
					local endog : list endog-vn
					local ncollin "`ncollin' `vn'"
				}
				if round(`ccmat'[`i',`i'],10e-7)==1 {
					* collinear with exogenous, so remove from endog and add to inexog
					local endog : list endog-vn
					local iexog "`iexog' `vn'"
					local ecollin "`ecollin' `vn'"
				}
				local i=`i'+1
			}
		}
	}
	* II. using _rmcollright
	* _rmcollright crashes with _rc=100 if no arguments supplied but =908 if matsize not big enough.
	* can continue with former but must exit with latter.
	capture _rmcollright `iexog' `exexog' if `touse', noconstant
	if _rc == 908 {
		di as err "matsize too small"
		exit 908
	}
	* endog has had within-endo collinear removed, so non-colllinear list is _rmcoll result + endog
	local ncvars `r(varlist)' `endog'
	local allvars `endog' `iexog' `exexog'
	* collin gets collinear variables to be removed
	local collin  : list allvars-ncvars
	* remove collin from exexog
	local exexog : list exexog-collin
	* remove collin from iexog
	local iexog : list iexog-collin
		if ("`_cns'"!="" & regexm("`iexog'","`_cns'")==1) {
			local iexog: list iexog - _cns
			local iexog `iexog' `_cns'
		}
	* add dropped endogenous to collinear list, trimming down to "" if empty
	local collin "`collin' `ncollin'"
	local collin : list clean collin
	* collinearity warning messages, if necessary
	if "`ecollin'" != "" {
		di in gr "Warning - endogenous variable(s) collinear with instruments"
		local mlength=78
		local tab=23
		local init "Vars now exogenous: "
		dispbreak , initial("`init'") todisplay("`ecollin'") mlength(78) tab(23)
		*di in gr "Vars now exogenous: " _c
		*disp "`ecollin'", _col(21)
	}
	if "`collin'" != "" {
		di in gr "Warning - collinearities detected"
		local mlength=78
		local tab=23
		local init "Vars dropped:        "
		dispbreak , initial("`init'") todisplay("`collin'") mlength(78) tab(23)
		*di in gr "Vars dropped: " _c
		*disp "`collin'", _col(21)
	}
	/*capture _rmcollright `endog' `iexog' `exexog' if `touse', noconstant
	if _rc == 908 {
		di as err "matsize too small"
		exit 908
	}
	if ("`r(dropped)'"!="") {
		local dropped=r(dropped)
		local iexog: list iexog - dropped
		local endog: list endog - dropped
		local exexog: list exexog - dropped
	}
	local iexog: list iexog - _cns
	local iexog `iexog' `_cns'
	if ("`dropped'"!="") {
		di in gr "Warning - collinearities detected"
		di in gr "Vars dropped: " _c
		disp "`dropped'", _col(21)
	}*/
	*display "`endog'"
	*display "`iexog'"
	*display "`exexog'"
	return local endog `endog'
	return local iexog `iexog'
	return local exexog `exexog'
	return local collin `collin'
end	/* end of collincheck program definition */

capture program drop rranktest	/* from ivreg2 */
program define rranktest, eclass
	syntax , [endog(varlist)] iexog(varlist) [exexog(varlist)] exexog_ct(real) endog_ct(real) rhs_ct(real) iv_ct(real) [robust(string)] [cluster(varname)] [noconstant(string)]
	if (`exexog_ct'!=0) {
		* check that -ranktest- is installed
		local ranktestversion 01.2.02
		local ranktest_cmd "ranktest"
		capture `ranktest_cmd', version
		if _rc != 0 {
			di as err "Error: must have ranktest version `ranktestversion' or greater installed"
			di as err "To install, from within Stata type " _c
			di in smcl "{stata ssc install ranktest :ssc install ranktest}"
			exit 601
		}
		local vernum "`r(version)'"
		if ("`vernum'" < "`ranktestversion'") | ("`vernum'" > "09.9.99") {
			di as err "Error: must have ranktest version `ranktestversion' or greater installed"
			di as err "Currently installed version is `vernum'"
			di as err "To update, from within Stata type " _c
			di in smcl "{stata ssc install ranktest, replace :ssc install ranktest, replace}"
			exit 601
		}
		if (`endog_ct'!=0) {
			* id=underidentification statistic, wid=weak identification statistic
			tempname idrkstat widrkstat iddf idp
			tempname ccf cdf rkf cceval cdeval cd cc
			tempname idstat widstat

			* Anderson canon corr underidentification statistic if homo, rk stat if not
			* need only id stat for testing full rank=(#cols-1)
			qui `ranktest_cmd' (`endog') (`exexog') /*`wtexp' */if e(sample), partial(`iexog') full `robust' `noconstant' /*`clopt' `bwopt' `kernopt'*/
			if "`cluster'"=="" {
				scalar `idstat'=r(chi2)/r(N)*(e(N)/*-`dofminus'*/)
			}
			else {
				* no dofminus adjustment needed for cluster-robust
				scalar `idstat'=r(chi2)
			}
			mat `cceval'=r(ccorr)
			mat `cdeval' = J(1,`endog_ct',.)
			forval i=1/`endog_ct' {
				mat `cceval'[1,`i'] = (`cceval'[1,`i'])^2
				mat `cdeval'[1,`i'] = `cceval'[1,`i'] / (1 - `cceval'[1,`i'])
			}
			local iddf = `iv_ct' - (`rhs_ct'-1)
			scalar `idp' = chiprob(`iddf',`idstat')

			* Cragg-Donald F statistic.
			* under homoskedasticity, Wald cd eigenvalue = cc/(1-cc) Anderson canon corr eigenvalue.
			scalar `cd'=`cdeval'[1,`endog_ct']
			scalar `cdf'=`cd'*(e(N)/*-`sdofminus'*/-`iv_ct'/*-`dofminus'*/)/`exexog_ct'

			* weak id statistic is Cragg-Donald F stat, rk Wald F stat if not
			if "`robust'"!="robust" {
				scalar `widstat'=`cdf'
				scalar `rkf'=.
			}
			else {
				* need only test of full rank
				qui `ranktest_cmd' (`endog') (`exexog') /*`wtexp' */if e(sample), partial(`iexog') full wald `robust' /*`noconstant' `clopt' `bwopt' `kernopt'*/
				* sdofminus used here so that F-stat matches test stat from regression with no partial
				if "`cluster'"=="" {
					scalar `rkf'=r(chi2)/r(N)*(e(N)-`iv_ct'/*-`sdofminus'-`dofminus'*/)/`exexog_ct'
				}
				else {
					scalar `rkf'=r(chi2)/(e(N)-1) /**/	*(e(N)-`iv_ct'/*-`sdofminus'*/) /**/	*(e(N_clust)-1)/e(N_clust) /`exexog_ct'
				}
				scalar `widstat'=`rkf'
			}
			
			* save into e()
			ereturn scalar rkf=`rkf'
			ereturn scalar cdf=`cdf'
			ereturn scalar cd=`cd'
			ereturn scalar idstat=`idstat'
			ereturn scalar idp=`idp'
			ereturn scalar iddf=`iddf'
			ereturn scalar widstat=`widstat'
		}
	}
end	/* end of rranktest program definition */

capture program drop display_results
program define display_results, eclass
	syntax , exexog_ct(real) endog_ct(real) [elasticities(string)] [el_str(varname)]
	* header
	di in gr _n "`e(title)'"
	local tlen=length("`e(title)'")
	di in gr "{hline `tlen'}"
	di in gr "`e(estimator_name)'" _continue
	di in gr _col(55) "Number of obs = " in ye %8.0f e(N)
	*display "`e(clustvar)'"
	if ("`e(clustvar)'"!="") {
		di in gr "Number of clusters (`e(clustvar)') = " in ye %5.0f e(N_clust) _continue
	}
	di in gr _c _col(55) "F(" in ye %3.0f e(Fdf1) in gr ","  in ye %5.0f e(Fdf2) in gr ")  = "
	di in ye %8.2f e(F)
	di in gr _col(55) "Prob > F      = " in ye %8.4f e(Fp)
	di in gr _col(55) "R2 (m. utility) = " in ye %6.4f e(r2)
	* main estimates
	ereturn display, nolstretch
	* underidentification test
	if ("`e(endog)'"!="" & "`e(idstat)'"!="" & `exexog_ct'!=0) {
		di in smcl _c "Underidentification test"
		if "`e(vcetype)'"=="nonrobust" {
			di in gr _c " (Anderson canon. corr. LM statistic):"
		}
		else {
			di in gr _c " (Kleibergen-Paap rk LM statistic):"
		}
		di in ye _col(71) %8.3f e(idstat)
		di in gr _col(52) "Chi-sq(" in ye e(iddf) in gr ") P-val =  " in ye _col(73) %6.4f e(idp)
		di in smcl in gr "{hline 78}"
	}
	* weak identification test
	if ("`e(endog)'"!="" & "`e(widstat)'"!="" & `exexog_ct'!=0) {
		di in smcl _c "Weak identification test"
		di in gr " (Cragg-Donald Wald F statistic):" in ye _col(71) %8.3f e(cdf)
		if "`e(vcetype)'"!="nonrobust" {
			di in gr "                         (Kleibergen-Paap rk Wald F statistic):" in ye _col(71) %8.3f e(widstat)
		}
		di in gr _c "Stock-Yogo weak ID test critical values:"
		local cdmissing=1
		cdsy1, type(ivbias5) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(43) "5% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivbias5=r(cv)
		}
		cdsy1, type(ivbias10) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "10% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivbias10=r(cv)
		}
		cdsy1, type(ivbias20) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "20% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivbias20=r(cv)
		}
		cdsy1, type(ivbias30) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "30% maximal IV relative bias" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivbias30=r(cv)
		}
		cdsy1, type(ivsize10) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "10% maximal IV size" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivsize10=r(cv)
		}
		cdsy1, type(ivsize15) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "15% maximal IV size" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivsize15=r(cv)
		}
		cdsy1, type(ivsize20) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "20% maximal IV size" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivsize20=r(cv)
		}
		cdsy1, type(ivsize25) k2(`exexog_ct') nendog(`endog_ct')
		if "`r(cv)'"~="." {
			di in gr _col(42) "25% maximal IV size" in ye _col(73) %6.2f r(cv)
			local cdmissing=0
			ereturn scalar sy_ivsize25=r(cv)
		}
		if `cdmissing' {
			di in gr _col(64) "<not available>"
		}
		else {
			di in gr "Source: Stock-Yogo (2005)."/*  Reproduced by permission."*/
			if "`e(vcetype)'"~="nonrobust" {
				di in gr "NB: Critical values are for Cragg-Donald F statistic and i.i.d. errors."
			}
		}
		di in smcl in gr "{hline 78}"
	}
	* overidentification test
	if (`exexog_ct'!=0) {
		di in gr _c "Hansen J statistic (overidentification test of all instruments):"
		di in ye _col(71) %8.3f e(j)
		if (e(jdf)>0) {
			di in gr _col(52) "Chi-sq(" in ye e(jdf) in gr ") P-val =  " in ye _col(73) %6.4f e(jp)
		}
		else {
			di in gr _col(50) "(equation exactly identified)"
		}
		di in smcl in gr "{hline 78}"
	}
	* variable lists
	local mlength=78
	local tab=23
	if "`e(endog)'" != "" {
		local init "Instrumented:        "
		dispbreak , initial("`init'") todisplay("`e(endog)'") mlength(78) tab(23)
	}
	if "`e(iexog)'" != "" {
		local diexog: list iexog - _cns
		if "`diexog'" != "" {
			local init "Included instruments:"
			dispbreak , initial("`init'") todisplay("`diexog'") mlength(78) tab(23)
		}
	}
	if "`e(exexog)'" != "" {
		local init "Excluded instruments:"
		dispbreak , initial("`init'") todisplay("`e(exexog)'") mlength(78) tab(23)
	}
	if "`e(dups)'" != "" {
		local init "Duplicates:		"
		dispbreak , initial("`init'") todisplay("`e(dups)'") mlength(78) tab(23)
	}
	if "`e(collin)'" != "" {
		local init "Dropped collinear:   "
		dispbreak , initial("`init'") todisplay("`e(collin)'") mlength(78) tab(23)
	}
	di in smcl in gr "{hline 78}"
	di in gr "Estimation time: " %1.0f = hh(e(estimation_time_ms)) "h " %1.0f = mm(e(estimation_time_ms)) "m " %1.0f = ss(e(estimation_time_ms)) "s"
	* elasticity and diversion ratio matrices
	if ("`elasticities'"!="") {
		quietly levelsof `el_str' if e(sample), local(elabels) clean
		matrix colnames el = `elabels'
		matrix rownames el = `elabels'
		matrix colnames dr = `elabels'
		matrix rownames dr = `elabels'
		ereturn matrix el=el
		ereturn matrix dr=dr
		display ""
		display in gr "Estimated average elasticities (by `elasticities')"
		matlist e(el), format(%10.1f)
		display ""
		display in gr "Estimated average diversion ratios (by `elasticities')"
		matlist e(dr), format(%10.0f)
	}
end	/* end of display_results */
