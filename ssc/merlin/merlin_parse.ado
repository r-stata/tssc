*! version 1.0.0 

program merlin_parse, rclass
        version 14.1
        // syntax:
        //      <mname> [, touse()] : <modellist> [if] [in] [, options]

        _on_colon_parse `0'
        local 0 `"`s(before)'"'

        syntax name(name=GML) , TOUSE(name)

        confirm new var `touse'

        local ZERO `"`s(after)'"'
        
        local 0 : copy local ZERO
        syntax [anything(equalok)] [if] [in] [, *]
        
		local ZERO `"`anything' `if' `in', `options'"'
        
        local DVOPTS                                    ///
                        Family(passthru)                ///
						Link(passthru)					///
                        EXPosure(passthru)              ///
                        OFFset(passthru)                ///
						MWeight(passthru)				///
						TIMEvar(passthru)				///
                        NOCONStant      CONStant	    ///
                                                         // blank

        local DIOPTS                                    ///
                        noHeader                        ///
                        noDVHeader                      ///
                        noLegend                        ///
                        notable                         ///
						Level(cilevel)					///
                                                         // blank

        local OPTS                                      ///
                        TECHnique(passthru)             ///
                        CONSTraints(string)             ///
                        FROM(string)                    ///
                        METHod(string)                  ///
                        NOLOg           LOg             ///
                                                         // blank

        
        local EVALTYPE                                  ///
                        EVALTYPE(string)       	        /// NODOC
						NONnested						/// NODOC
						BLUPS(varlist)					/// NODOC
						SEBLUPS(varlist)				/// NODOC
                        DNUMERICAL                      /// NODOC
                                                         // blank

        local COMMON                                    ///
                        COVSTRucture(passthru)          /// NODOC
                        COVariance(passthru)            ///
                        VARiance(passthru)              /// NODOC
						INTPoints(passthru)				///
						INTMethod(passthru)				///
						UPDATEMC						/// NODOC
						ADAPTopts(passthru)				///
						REDISTribution(passthru)		///
						DF(string)						///
						RESTARTValues(string)			///
						APSTARTValues(string)			///
						ZEROS							///
						RANDOM							/// 
														///
						DEBUG							/// NODOC
														///
						Weights(passthru)				/// 
						PREDICTMS						/// NODOC
						PENalty(string)					/// NODOC
						LAMBDA(string)					/// NODOC
						LOSS							/// NODOC
														///
						DEVCODE1(string)				///						
						DEVCODE2(string)				///
						DEVCODE3(string)				///
						DEVCODE4(string)				///
						DEVCODE5(string)				///
						DEVCODE6(string)				///
						DEVCODE7(string)				///
														///
						PREDICT							/// NODOC
						NOGEN							/// NODOC
						NPREDICT(string)				/// NODOC
						PTVAR(varname)					/// NODOC
														///
                        `EVALTYPE'                      ///
														///
						ARTHUR							/// NODOC
						EXCALIBUR						/// NODOC
						TRANSMATrix(string)				/// NODOC
						ICCRfudge						/// NODOC
						MORGANA(string)					/// NODOC
						IINTPoints(passthru)			/// NODOC
                                                         // blank

        _parse expand EQ GL : ZERO,                     ///
                common(                                 ///
                        `DIOPTS'                        ///
                        `OPTS'                          ///
                        `COMMON'                        ///
                )                                       ///
                gweight

        // prelim parse; make global the 'if'/'in'
        // specifications and all non-equation-specific options

        forvalues i = 1/`EQ_n' {
		
			local 0 : copy local EQ_`i'
			syntax [anything(equalok)] [if] [in]   ///
			[,			                           ///
					`DVOPTS'                       ///
			]
			ParseDist, `family' `link' `timevar' `mweight' 
			local family`i' `"`s(family)'"'
			local familylist `familylist' `family`i''
			local linklist `linklist' `"`s(link)'"'
			local mweight`i' `s(mweight)'
			local failure`i' `s(failure)'
			local ltruncated`i' `s(ltruncated)'
			local linterval`i' `s(linterval)'
			local rcsopts`i' `s(rcsopts)'
			local loglfunction`i' `s(loglfunction)'
			local hazfunction`i' `s(hazfunction)'
			local loghazfunction`i' `s(loghazfunction)'
			local chazfunction`i' `s(chazfunction)'
			local nap`i' `s(nap)'
			local qtile`i' `s(qtile)'
			local bhaz`i' `s(bhazard)'
			local timevar`i' `s(timevar)'
			local re`i' `s(re)'
			local noresidual`i' `s(noresidual)'
			local dapmodel`i' `s(dapmodel)'
			
			opts_exclusive "`noconstant' `constant'"
			local constant`i' "`noconstant'`constant'"
			opts_exclusive "`offset' `exposure'"
			local offset`i' `offset' `exposure'
			
			if `:length local if' {
					local if`i' : copy local if
			}
			if `:length local in' {
					if `:length local GL_in' {
							di as err ///
							"multiple 'in' specifications not allowed"
							exit 198
					}
					local GL_in : copy local in
			}
			local EQ_`i' `"`anything', `family' `noconstant' `offset'"'
			if `:length local options' {
					local GL_op `"`GL_op' `options'"'
			}
			if "`family`i''"=="null" | "`family`i''"=="re" {
				local response`i' 
				local indepvars`i' `anything'
			}
			else {
				ParseVars `anything'
				local response`i' `s(response)' `failure`i'' `ltruncated`i'' `linterval`i''
				local indepvars`i' `s(indepvars)'
			}
			
        }

		local neq = `EQ_n'
		local options : copy local GL_op

        _get_diopts diopts options, `options'
        local 0 `", `NOSTART' `options'"'
        syntax [, `DIOPTS' *]
        local diopts    `diopts'        ///
                        `header'        ///
                        `dvheader'      ///
                        `legend'        ///
                        `table'         ///
                                         // blank

        // parse globally specified equation options
        local 0 `", `options'"'
        syntax [, `DVOPTS' `OPTS' `EVALTYPE' NOVCE *]			//novce fudge
        if !inlist("`method'", "", "ml") {
                di as err "invalid {bf:method()} option;"
                di as err "option {bf:`method'} not allowed"
                exit 198
        }
     
		if "`evaltype'"=="" local evaltype gf0

        mlopts mlopts options, `options' `technique'
        local collinear "`s(collinear)'"
        local mlopts : list mlopts - collinear
        local mlopts `mlopts' `crittype' `novce'
        local options   `noanchor'      ///
                        `listwise'      ///
                        `collinear'     ///
                        `evaltype'      ///
                        `options'
       
        mark `touse' `GL_if' `GL_in' `GL_wt'

        qui count if `touse'
        if (r(N)==0) error 2000
        if (r(N)==1) error 2001
		local Nobs = `r(N)'
		
		//globalopts
		local 0 `", `GL_op'"'
		syntax [, 	INTmethod(string) INTPoints(string) COVariance(string) 			///
					REDISTribution(string) DF(string) ADAPTopts(string) 			///
					DEVCODE1(string) DEVCODE2(string) 								///
					DEVCODE3(string) DEVCODE4(string)								///
					DEVCODE5(string) DEVCODE6(string)								///
					DEVCODE7(string) IINTPoints(int 35)								///
					WEIGHTS(varlist) SHOWinit UPDATEMC DEBUG PREDICTMS				///
					RANDOM PENalty(string) LAMBDA(string) LOSS 						///
					ARTHUR EXCALIBUR TRANSMATrix(string) ICCRfudge MORGANA(string)	///
					PREDICT PTVAR(string) NPREDICT(string) NOGEN					/// -predictions-
					RESTARTValues(string) APSTARTValues(string) ZEROS				///
					* ]
		
		local eqnnamexb `options'

		if "`covariance"!="" {
			foreach struct in `covariance' {
				local 0 , `struct'
				syntax , [DIAGonal UNstructured IDENtity EXchangeable]
				local covariance2 `covariance2' `diagonal'`unstructured'`identity'`exchangeable'
			}
		}

		if "`adaptopts'"!="" {
			local 0 , `adaptopts'
			syntax [, LOG ITERATE(string)]
			local showadapt `log'
			local adaptiterations `iterate'
		}
		
		//Setup
		mata: merlin_setup("`GML'","`touse'")		
		
		if "`predict'"!="" | "`c(prefix)'"=="morgana" {
			exit
		}
		
		if "`debug'"!="" {
			di "ML equations are:"
			di "`mlspec'"
		}
		
		return local mlfrom			= "`from'"
		if "`from'"!="" {
			return matrix b			= `from'
		}
		
		return local mltype		`"`evaltype'"'
		if "`loss'"=="" {
			return local mleval		`"merlin_gf()"'
		}
		else {
			return local mleval		`"nn_merlin_loss()"'
		}
		return local mlspec		`"`mlspec'"'
		return local mlprolog	`"`mlprolog'"'
        return local mlopts     `"`nolog' `mlopts'"'
        return local mlvce      `"`vce'"'
        return local nolog      `"`nolog'"'
        return local diopts     `"`diopts'"'
		return local constr		`"`constraints'"'
		return local mftodrop 	`mftodrop'
		return local mfzeros 	"`zeros'"
end

program ParseDist, sclass
        syntax ,       	Family(string)      ///
					[ 						///
						Link(string)        ///
						TIMEvar(varname)	///
						MWeight(string)		///
                       *                   	///
					]
		
		//second parse on family()
		local 0 `family'
		syntax anything, [										///
								FAILure(varname) 				///
								LTruncated(varname)				///
								LInterval(varname)				///
								LLFunction(string) 				///
								HFunction(string) 				///
								CHFunction(string)				///
								LOGHFunction(string)			///
								DAPModel(string)				///
								NAP(string) 					///
								BHazard(varname) 				///
								RE(string) 						///
								Quantile(string) 				///
								NORESIDual						///	-gp-
								*								/// rp aft opts
							]
		sreturn local failure `failure'
		sreturn local ltruncated `ltruncated'
		sreturn local linterval `linterval'
		sreturn local rcsopts `options'
		sreturn local dapmodel `dapmodel'
		local family `anything'
		
		local dapnotallowed = 0
		
		local tag = 0
		if "`nap'"=="" {
			local nap = 0
		}
		local l = length("`family'")
		if substr("user",1,max(1,`l'))=="`family'" {
			local family user
			//local link identity
			if "`llfunction'"=="" & "`hfunction'"=="" & "`loghfunction'"=="" {
				di as error "family(user, llfunction()), family(user, hfunction()) or family(user, loghfunction()) required"
				exit 198
			}
			if "`bhazard'"!="" & "`llfunction'"!="" {
				di as error "bhazard() not allowed with family(user, lfunction())"
				exit 198
			}
		}
		else if substr("exponential",1,max(1,`l'))=="`family'" {
			local family exponential	
			local tag = 1
			local dapnotallowed = 1
		}
		else if substr("weibull",1,max(1,`l'))=="`family'" {
			local family weibull
			local tag = 1
		}
		else if substr("gompertz",1,max(2,`l'))=="`family'" {
			local family gompertz
			local tag = 1
		}
		else if "logchazard"=="`family'" {
			local family logchazard
			local tag = 1
		}
		else if "rp"=="`family'" {
			local family rp
			local tag = 1
		}
		else if "plogchazard"=="`family'" {
			local family plogchazard
			local tag = 1
		}
		else if "loghazard"=="`family'" {
			local family loghazard
			local tag = 1
		}
		else if "`family'"=="aft" {
			local family aft
			local tag = 1
		}
		else if "`family'"=="cox" {
			local family cox
			local tag = 1
		}
		else if substr("gaussian",1,max(3,`l'))=="`family'" {
			local family gaussian
			if "`link'"=="" {
				local link identity
			}
			else if "`link'"!="identity" & "`link'"!="log" {
				di as error "invalid link(`link') with family(`family')"
				exit 198
			}
		}
		else if substr("igaussian",1,max(3,`l'))=="`family'" {
			local family igaussian
			if "`link'"=="" {
				local link identity
			}
			else if "`link'"!="identity" & "`link'"!="log" {
				di as error "invalid link(`link') with family(`family')"
				exit 198
			}
		}
		else if substr("poisson",1,max(1,`l'))=="`family'" {
			local family poisson
			local link log
			local dapnotallowed = 1
		}
		else if substr("bernoulli",1,max(4,`l'))=="`family'" {
			local family bernoulli
			if "`link'"=="" {
				local link logit
			}
			else if "`link'"!="probit" & "`link'"!="logit" & "`link'"!="cloglog" {
				di as error "invalid link(`link') with family(`family')"
				exit 198
			}
			local dapnotallowed = 1
		}
		else if substr("ibernoulli",1,max(5,`l'))=="`family'" {
			local family ibernoulli
			if "`link'"=="" {
				local link logit
			}
			else if "`link'"!="probit" & "`link'"!="logit" & "`link'"!="cloglog" {
				di as error "invalid link(`link') with family(`family')"
				exit 198
			}
			local dapnotallowed = 1
		}
		else if substr("beta",1,max(3,`l'))=="`family'" {
			local family beta
			local link identity
		}
		else if substr("nbinomial",1,max(2,`l'))=="`family'" {
			local family negbinomial
			local link identity
		}
		else if substr("ologit",1,max(2,`l'))=="`family'" {
			local family ordinal
			local link logit
		}
		else if substr("oprobit",1,max(2,`l'))=="`family'" {
			local family ordinal
			local link probit
		}
		else if substr("lquantile",1,max(2,`l'))=="`family'" {
			local family lquantile
			local link identity
			local qtile = `quantile'
		}
		else if substr("gamma",1,max(3,`l'))=="`family'" {
			local family gamma
			local link log
		}
		else if "null"=="`family'" {
			local family null
			if "`link'"=="" {
				local link identity
			}
			else if "`link'"!="identity" & "`link'"!="logit" & "`link'"!="atanh" {
				di as error "invalid link(`link') with family(`family')"
				exit 198
			}
			local dapnotallowed = 1
		}
		else if "re"=="`family'" {
			local family re
			local link identity
			local dapnotallowed = 1
		}
		else if "gp"=="`family'" {
			local link identity
			local dapnotallowed = 1
		}
		else {
			di as error "Unknown family()"
			exit 198
		}
		
		if `dapnotallowed' & "`dapmodel'"!="" {
			di as error "dapmodel() not allowed"
			exit 198
		}
		
		if `tag' & "`failure'"=="" {
			di as error "failure() must be specified"
			exit 198
		}
		
		if !`tag' & "`bhazard'"!="" {
			di as error "bhazard() only allowed with survival models"
			exit 198
		}
		
		if `tag' {
			local link log
		}
		
		if "`link'"=="" {
			local link identity
		}
		
        sreturn local family    `"`family'"'
        sreturn local link      `"`link'"'
		sreturn local loglfunction `"`llfunction'"'
		sreturn local hazfunction `"`hfunction'"'
		sreturn local loghazfunction `"`loghfunction'"'
		sreturn local chazfunction `"`chfunction'"'
		sreturn local nap `"`nap'"'
		sreturn local qtile `"`qtile'"'
		sreturn local bhazard `"`bhazard'"'
		sreturn local mweight `"`mweight'"'
		sreturn local timevar `"`timevar'"'
		sreturn local re `"`re'"'
		sreturn local noresidual `"`noresidual'"'
end

program ParseVars, sclass
	syntax anything [if] [in] 
	
	gettoken lhs rhs : anything
	
	sreturn local response `lhs' 
	sreturn local indepvars `rhs'
	
end

exit
