*! version 0.6.5 09jan2014 MJC

/* History
MJC 09jan2013: version 0.6.5 - fixed bug in survival prediction when #rcs(df(1)) specified
							 - fixed bug when specifying noorthog within #rcs()
MJC 30oct2013: version 0.6.4 - time-dependent effects with user-defined function of time caused an error when using predict. This has been fixed.
MJC 26jun2013: version 0.6.3 - bug fix for if/in
MJC 19mar2013: version 0.6.2 - gaussquad moved to separate ado file
MJC 20feb2013: version 0.6.1 - fixed bug in predicting hazard function turning :> to > etc.
MJC 28jun2012: syntax for covariates changed - each equation name is now it's own option to include covariates etc.
MJC 23Apr2012: added offset to #fp and synched offset options with predictions
MJC 10Feb2012: version 0.1.0
*/

program stgenreg, eclass byable(onecall)
	version 11.2
	if _by() {
		local BY `"by `_byvars'`_byrc0':"'
	}
	syntax [fw pw iw aw] [if] [in] [, LOGHAZard(string) HAZard(string) *]
	if "`loghazard'"=="" & "`hazard'"=="" {
		if "`e(cmd)'" != "stgenreg" { 
			error 301
		}
		if _by() {
			error 190
		}
		Replay `0' 
		exit
	}
	else {
		`BY' Estimate `0'
	}
end


program Estimate, eclass byable(recall) properties(st)
		syntax [fw pw iw aw] [if] [in] 	[,									///
											LOGHAZard(string)				///	-User defined log hazard functionn-
											HAZard(string)					///	-User defined hazard function-
											BHazard(varname)				///	-Backgroung hazard rate for relative survival-
																			///
											SHOWCOMPonent					///	-Display each parameter component-
											MATALOGHazard					/// -Show global macro passed to Mata for lohazard function-
											MATAKeep						/// -Don't drop data from mata after fitting model
											EFORM							///	-Exponentiate coefficients of first ml equation-
																			///
											NODES(numlist max=1)			///	-Number of quadrature nodes-
																			///
											SEARCH(string)					///	-Pass to ml-
											INITMAT(string)					///	-Pass initial values matrix to ml-
											COPY							///	-Pass to ml-
											SKIP							///	-Pass to ml-
											Level(cilevel)					///	-Confidence level-
											NOLOG							///	-Pass to ml-
											*								///	-ML opts-
										]

		marksample touse
		qui replace `touse' = 0 if _st==0
		
		/*  Weights */
        if "`weight'" != "" {
			display as err "weights must be stset"
			exit 101
        }
        local wt: char _dta[st_w]       
        local wtvar: char _dta[st_wv]
		
		/***************************************************************************************************************************************************/
		/* Error checks */
		
		if "`loghazard'"!="" & "`hazard'"!="" {
			di as error "Can only specify one of loghazard and hazard"
			exit 198
		}
		
		if "`loghazard'"=="" & "`hazard'"=="" {
			di as error "One of loghazard and hazard must be specified"
			exit 198
		}
		
		if "`mataloghazard'"!="" {
			local show 
		}
		else local show quietly
		
		local ns = 1
		if "`nodes'"=="" {
			local nodes 15
		}
		else {
			local nodeslistn : word count `nodes'
			if `nodeslistn'!=1 {
				di as error "nodes must be a single number"
				exit 198
			}
			cap confirm integer num `nodes'
			if _rc>0 | `nodes'<2{
				di as error "nodes must be an integer greater than 1"
				exit 198
			}
		}
		
		/***************************************************************************************************************************************************/
		/* Equation name prep. */
		
			mata: st_local("rest",subinstr("`loghazard'`hazard'"," ","",.))
			mata: st_local("restind", substr("`rest'",1,1))

			gettoken first rest : rest, parse("[")
			if "`rest'"=="" {
				di as error "At least one equation must be specified: possible missing parenthesis ["
				exit 198
			}

			if "`restind'"!="[" {
				gettoken first rest : rest, parse("[")
				if "`rest'"=="" {
					di as error "At least one equation must be specified: possible missing parenthesis ["
					exit 198
				}
			}
			gettoken first rest : rest, parse("]")
			mata: st_local("restind", substr(strtrim("`rest'"),1,1))
			if "`restind'"!="]" {
				di as error "Missing closed parenthesis ]"
				exit 198
			}

			local eq_names "`first'"
			
			while "`rest'"!="" {
				gettoken first rest : rest, parse("[")
				if "`rest'"!="" {
					gettoken first rest : rest, parse("[")
					gettoken first rest : rest, parse("]")
					
					local ind = 0
					foreach eq in `eq_names' {
						if "`eq'"==trim("`first'") {
							local ind = 1
						}
					}
					if `ind'==0 local eq_names "`eq_names' `first'"
				}
				
			}
			
			//di in g "`eq_names'"	
			global eq_names `eq_names'
		
			// Number of parameters
			local np : word count `eq_names'
			
			// Parsing linear predictors for each parameter
			// di "`options'"
			foreach p in `eq_names' {
				local eq_syntax `eq_syntax' `p'(string) 
			}
			
			local 0 ,`options'
			syntax [, `eq_syntax' *]
			
			mlopts mlopts , `options'

		/***************************************************************************************************************************************************/
		/* Prep */
		
			/* Clear global macros */
			macro drop matasyntax coefficientmats arraysyntax arraynames mataloghazard mataloghazard1 mataloghazard2 mataloghazard21 mataloghazard22 tdeind codeline matatdecovssyntax matatdecovsnames bhazvar
					
			if "`bhazard'"!="" {
				global bhazvar "`bhazard'"
			}
						
			if "`initmat'"!="" {
				local initopt init(`initmat',`copy' `skip')			
			}
			
			if "`search'"!="" {
				local searchopt search(`search')
			}
			
			if "`showcomponent'"==""{
				local showcompid quietly
			}
			
			/* Pass any variables found in cov's to Mata */ 			//needed for tde's
			foreach p in `eq_names' {
				local pcovlist `pcovlist' ``p''
			}
			
			gettoken first rest : pcovlist, parse("[ ,\^\*\(\)-\+/:]")
			while "`rest'"!="" {
				if trim("`first'")!="," {
					cap confirm var `first'
					if !_rc {
						local test1 = 0
						foreach var in `covlist' {
							if "`first'"=="`var'" local test1 = 1
						}
						if `test1'==0 local covlist `covlist' `first'					//contains a list of all varnames specified, be they time-indep or time-dependent
					}
				}
				gettoken first rest : rest, parse("[ ,\^\*\(\)-\+/:]")
			}
			markout `touse' `covlist'									//update touse and chuck things in Mata
			if "`covlist'"!="" {
				foreach _covvar in `covlist' {
					mata: st_view(`_covvar'=.,.,"`_covvar'","`touse'")
				}
			}

			qui count if `touse'==1
			local nobs = r(N)

			/* Pass stuff to Mata */
			mata: touse = st_local("`touse'")

			/* Check rcsgen is installed if needed */
			mata: st_local("test",strofreal(regexm("`pcovlist'","#rcs"))) 
			if `test'==1 {
				capture which rcsgen
				if _rc >0 {
					display in yellow "You need to install the command rcsgen. This can be installed using,"
					display in yellow ". {stata ssc install rcsgen}"
					exit 198
				}
			}
			
		/***************************************************************************************************************************************************/
		/* Quadrature nodes and weights */
			
			mata: _stime = st_data(.,"_t","`touse'")
			
			mata: t01 = st_data(.,"_t0","`touse'")
			mata: _stime1 = st_data(.,"_t","`touse'")

			tempvar t1
			gen double `t1' = _t
			if "`jacobi'"=="" {
				local quadopt1 legendre
			}
			else {
				local quadopt1 jacobi
				local d0file _jacobi
			}
			
			forvalues i=1/`ns' {
				local nnodes`i' : word `i' of `nodes'
				tempname knodes`i' kweights`i'
				stgenreg_gaussquad, n(`nnodes`i'') `quadopt`i''
				matrix `knodes`i'' = r(nodes)'
				matrix `kweights`i'' = r(weights)'
				
				/* Pass to Mata */
				mata: nnodes`i' = `nnodes`i''				
				mata: kweights`i'  = ((_stime`i':-t0`i'):/2):*J(`nobs',1,st_matrix("`kweights`i''"))
				mata: knewnodes`i' = J(`nobs',1,st_matrix("`knodes`i''")):*((_stime`i':-t0`i'):/2) :+ ((_stime`i':+t0`i'):/2)
			}
			
		/***************************************************************************************************************************************************/
		/* Log hazard function global macro */
			
			mata: st_global("mataloghazard",subinstr("`loghazard'`hazard'"," ","",.))
			forvalues i=1/`np' {
				local eqname : word `i' of `eq_names'
				mata: st_global("mataloghazard", subinstr("$mataloghazard","[`eqname']","p`i'",.))
			}
			
			if "`loghazard'"!="" {
				global mataloghazard1 $mataloghazard
				global mataloghazard2 exp($mataloghazard)
				local hazpred "exp($mataloghazard)"
			}
			else {
				global mataloghazard1 log($mataloghazard)
				global mataloghazard2 $mataloghazard
				local hazpred "$mataloghazard"
			}
			
			mata: st_global("mataloghazard1", subinstr("$mataloghazard1","#t","_stime",.))					
			
			/* global macro for cumulative hazard */
			forvalues i=1/`ns' {
				mata: st_local("mataloghazard2`i'", subinstr("$mataloghazard2","#t","knewnodes`i'[,j]",.))
				mata: st_global("mataloghazard2`i'", "`mataloghazard2`i''")
			}

			/* special case if single parameter with no covariates(i.e. exp model */
			local cov1 : word 1 of `eq_names'
			if "$mataloghazard1"=="p1" & "``cov1''"=="" {
				global mataloghazard1 J(`nobs',1,$mataloghazard1)
			}
			`show' di in g "Mata log hazard function: " in y "$mataloghazard1"
						
		/***************************************************************************************************************************************************/
		/* Partition each equation into components and generate components */
		
			cap drop _eq*
			
			/* Loop over parameter ml equations */
			forvalues i = 1/`np' {
				
				local eqn`i'tde = 0				//identifies whether each equation contains a #t or #rcs function in any component
				local iscov : word `i' of `eq_names'
				
				if "``iscov''"!="" {
				
					/* For each equation, need to partition into components parsed on | */
					local k = 1					//index component
					local loop = 0				//loop exit
					local rest "``iscov''"		//equation covariate option
					local eqncovind = 0			//used to check time-indep covs are in one component
					while `loop'==0 {
					
						/* Parsing */
						gettoken first rest: rest, parse("|")
						if `k'!=1 {
							gettoken first rest: rest, parse("|")
						}
						local eqn`i'comp`k' = trim("`first'")
						
						/* Error check that :* has been specified for time-dependent effect */
						/* comment out as cause problems with multiple time-scales */
						/*
						if regexm("`first'","#")==1 {
							foreach var in `covlist' {
								if regexm("`first'","`var'")==1 {
									if regexm("`first'",":\*")==0 {
										di as error "Error in component: `first'"
										di as error `"Expected time-dependent effect but ":*" not found"'
										exit 198
									}								
								}
							}
						}
						*/
						/* Indicator macro to show whether time is included in any component of an equation */
						if regexm("`first'","#t")==1 | regexm("`first'","#rcs")==1 | regexm("`first'","#fp")==1 {
							local eqn`i'tde = 1
						}
						
						/* Show components */
						`showcompid' di in g "Equation `i', comp. `k': " in y "`eqn`i'comp`k''"
						
						/* Component contains variables and/or nocons option */
						if regexm("`first'","#")==0 {
						
							if `eqncovind'==1 {
								di as error "All time-independent covariates should be specified in the same component varlist"
								exit 198
							}
							
							/* see if nocons specified */
							gettoken covs`i' comma : first, parse(",")
							if "`comma'"!="" {
								gettoken comma noc : comma, parse(",")
								if trim("`noc'")=="nocons" {
									local nocons`i' ,nocons
								}
								else {
									di as error "`noc' invalid"
									exit 198
								}
							}
							/* confirm variables */
							confirm var `covs`i''
							local compcovind_`i' "`compcovind_`i'' 0"
							local eqncovind = 1								//used for error check above
						}
						
						/* see if #rcs() has been specified */
						else if regexm("`eqn`i'comp`k''","#rcs")==1 {
							gettoken rcsfirst rcsrest : eqn`i'comp`k', match(test) parse("(")
							gettoken rcssyntax_`i'_`k' rcsrest : rcsrest, match(test) parse(")")
							stgenreg_rcsgen _t, `rcssyntax_`i'_`k'' newgen(_eq`i'_cp`k'_rcs) tousevar(`touse')
							local noorthog_`i'_`k' `e(noorthog)'
							local bhknots_`i'_`k' `e(bhknots)'
							local df_`i'_`k' = `e(df)'
							local time_`i'_`k' "`e(time)'"
							local offsetrcs_`i'_`k' "`e(offset)'"
							if "`offsetrcs_`i'_`k''" != "" {
								local addrcsoffset_`i'_`k' offset(`offsetrcs_`i'_`k'')
							}
							tempname rmat_`i'_`k'
							matrix `rmat_`i'_`k'' = e(rmatrix)
							
							//time dependent effects
							foreach var in `covlist' {
								if regexm("`eqn`i'comp`k''","`var'")==1 & "`var'"!="`offsetrcs_`i'_`k''"{
									forvalues rcsi = 1/`df_`i'_`k'' {
										qui replace _eq`i'_cp`k'_rcs`rcsi' = _eq`i'_cp`k'_rcs`rcsi' * `var' if `touse'
									}
								}
							}
							forvalues rcsi = 1/`df_`i'_`k'' {
								local eqn`i'varlist "`eqn`i'varlist' _eq`i'_cp`k'_rcs`rcsi'"
							}
							mata: st_local("eqn`i'comp`k'", subinstr("`eqn`i'comp`k''","#rcs(`rcssyntax_`i'_`k''`rcsrest')","_stime1",.))	// EDIT FOR SPLIT, replace #rcs() with t for arrays below - this allows time dependent effects
							local compcovind_`i' "`compcovind_`i'' 1"
						}
						
						/* Fractional polynomials */
						else if regexm("`eqn`i'comp`k''","#fp")==1{
							gettoken fpfirst fprest : eqn`i'comp`k', match(test) parse("(")
							gettoken fpsyntax_`i'_`k' fprest : fprest, match(test) parse(")")
							gettoken test1 test2 : fpsyntax_`i'_`k', parse(",")
							if "`test2'"=="" local addcomma_`i'_`k' ","
							stgenreg_fp `fpsyntax_`i'_`k'' `addcomma_`i'_`k'' stub(_eq`i'_cp`k'_fp) var(_t) tousevar(`touse')
							local fps_`i'_`k' `e(fps)'
							local nfps_`i'_`k' = `e(nfps)'
							local offsetfps_`i'_`k' "`e(offset)'"
							if "`offsetfps_`i'_`k''" != "" {
								local addfpsoffset_`i'_`k' offset(`offsetfps_`i'_`k'')
							}
							/* Establish whether time-dependent effect */
							local tdeeffect_var
							foreach var in `covlist' {
								if regexm("`eqn`i'comp`k''","`var'")==1 & "`var'"!="`offsetfps_`i'_`k''" {
									local tdeeffect_var "`var'"
								}
							}
							/* Display text and time dependent effects */
							if "`offsetfps_`i'_`k''"!="" {
								local addoffsetditxt_`i'_`k' "+ `offsetfps_`i'_`k''"
								local lb_`i'_`k' "("
								local rb_`i'_`k' ")"
							}
							forvalues fp = 1/`nfps_`i'_`k'' {
								local pow : word `fp' of `fps_`i'_`k''
								if "`tdeeffect_var'"=="" {
									if "`pow'"=="0" {
										di in green "gen double _eq`i'_cp`k'_fp_`fp' = log(_t`addoffsetditxt_`i'_`k'')"
									}
									else {
										di in green "gen double _eq`i'_cp`k'_fp_`fp' = `lb_`i'_`k''_t`addoffsetditxt_`i'_`k''`rb_`i'_`k''^(`pow')"
									}								
								}
								else {
									if "`pow'"=="0" {
										di in green "gen double _eq`i'_cp`k'_fp_`fp' = `tdeeffect_var' * log(_t`addoffsetditxt_`i'_`k'')"
									}
									else {
										di in green "gen double _eq`i'_cp`k'_fp_`fp' = `tdeeffect_var' * `lb_`i'_`k''_t`addoffsetditxt_`i'_`k''`rb_`i'_`k''^(`pow')"
									}								
									qui replace _eq`i'_cp`k'_fp_`fp' = _eq`i'_cp`k'_fp_`fp' * `tdeeffect_var' if `touse'
								}
								local eqn`i'varlist "`eqn`i'varlist' _eq`i'_cp`k'_fp_`fp'"
							}
							mata: st_local("eqn`i'comp`k'", subinstr("`eqn`i'comp`k''","#fp(`fps_`i'_`k''`fprest')","_stime1",.))	//EDIT FOR SPLIT, replace #fp() with t for arrays below - this allows time dependent effects
							local compcovind_`i' "`compcovind_`i'' 2"
						}
						
						/* user defined function of #t */
						else if regexm("`eqn`i'comp`k''","#t")==1{
							qui gen double _eq`i'_cp`k' = . if `touse'
							mata: st_local("newcovform", subinstr("`eqn`i'comp`k''","#t","_stime1",.))	//EDIT FOR SPLIT
							cap mata: component = `newcovform'
							if _rc>0 {
								di as error "Error in `eqn`i'comp`k''"
								error 198
							}
							mata: st_store(.,"_eq`i'_cp`k'","`touse'",component)
							local eqn`i'varlist "`eqn`i'varlist' _eq`i'_cp`k'"
							local compcovind_`i' "`compcovind_`i'' 3"
							/* Display text */
							mata: st_local("ditextdummy", subinstr("`eqn`i'comp`k''","#t","_t",.))
							mata: st_local("ditextdummy", subinstr("`ditextdummy'",":*","*",.))							
							mata: st_local("ditextdummy", subinstr("`ditextdummy'",":+","+",.))
							mata: st_local("ditextdummy", subinstr("`ditextdummy'",":/","/",.))
							mata: st_local("ditextdummy", subinstr("`ditextdummy'",":-","-",.))
							mata: st_local("ditextdummy", subinstr("`ditextdummy'",":^","^",.))
							di in green "gen double _eq`i'_cp`k' = `ditextdummy'"
							label var _eq`i'_cp`k' "`ditextdummy'"
						}
						
						if trim("`rest'")=="" {
							local loop = 1
							local ncomp_eqn`i' = `k'
							local ncomps "`ncomps' `k'"
						}
						local `++k'
					}			
				
				}
				else {
					local ncomp_eqn`i' = 0
					local ncomps "`ncomps' 0"
				}
				
				global tdeind "$tdeind `eqn`i'tde'"

			}
			
		/***************************************************************************************************************************************************/
		/* Generate component variables and asarrays in Mata */
	
			/* Create nodes in Stata */
			forvalues i = 1/`nodes' {
				tempvar node`i'_1
				qui gen double `node`i'_1' =  0.5*(_t - _t0)*(el(`knodes1',1,`i')) + 0.5*(_t + _t0) if `touse'
			}
			
			tempvar intercept
			qui gen `intercept' = 1 if `touse'
			
			/* Loop over equations */
			forvalues i = 1/`np' {
			
				if `eqn`i'tde'==1 {
						
						forvalues sp = 1/`ns' {
						
								mata: nodes`i'_`sp' = asarray_create("real",1)
						
								/* Loop over nodes, asarray's are indexed by node */
								forvalues j = 1/`nnodes`sp'' {
									/* Loop over components */
									forvalues k = 1/`ncomp_eqn`i'' {
										local covidentifier : word `k' of `compcovind_`i''
										/* #rcs */
										if `covidentifier'==1 {
											cap drop _rcs_`k'_*
											qui stgenreg_rcsgen `node`j'_`sp'', `time_`i'_`k'' `noorthog_`i'_`k'' newknots(`bhknots_`i'_`k'') newgen(_rcs_`k'_) newrmat(`rmat_`i'_`k'') tousevar(`touse') `addrcsoffset_`i'_`k''
											local eqn`i'_node_`j'_`sp'_newcompvars "`eqn`i'_node_`j'_`sp'_newcompvars' _rcs_`k'_*"

											//time-dependent effects
											foreach var in `covlist' {
												if regexm("`eqn`i'comp`k''","`var'")==1 & "`var'"!="`offsetrcs_`i'_`k''" {
													forvalues rcsi = 1/`df_`i'_`k'' {
														qui replace _rcs_`k'_`rcsi' = _rcs_`k'_`rcsi' * `var' if `touse'
													}
												}
											}
											
										}
										/* fp's */
										else if `covidentifier'==2 {
											cap drop `node`j''_`sp'_`k'_*
											tempvar `node`j''_`sp'_`k'
											stgenreg_fp `fpsyntax_`i'_`k'' `addcomma_`i'_`k'' stub(``node`j''_`sp'_`k'') var(`node`j'_`sp'') tousevar(`touse') //offset included in syntax
											
											local ind = 1
											forvalues fp = 1/`nfps_`i'_`k'' {
												//time-dependent effects
												foreach var in `covlist' {
													if regexm("`eqn`i'comp`k''","`var'")==1 & "`var'"!="`offsetfps_`i'_`k''" {
														qui replace ``node`j''_`sp'_`k''_`ind' = ``node`j''_`sp'_`k''_`ind' * `var' if `touse'
													}
												}
												local `++ind'
											}								
											local eqn`i'_node_`j'_`sp'_newcompvars "`eqn`i'_node_`j'_`sp'_newcompvars' ``node`j''_`sp'_`k''_*"
										}
										/* user-defined function of #t */
										else if `covidentifier'==3 {
											tempvar eqn`i'node`j'cov`k'_`sp'
											qui gen double `eqn`i'node`j'cov`k'_`sp'' = . if `touse'
											mata: _stime`sp' = st_data(.,"`node`j'_`sp''","`touse'")
											mata: st_local("newcovform", subinstr("`eqn`i'comp`k''","#t","_stime`sp'",.))
											mata: component = `newcovform'
											mata: st_store(.,"`eqn`i'node`j'cov`k'_`sp''","`touse'",component)
											local eqn`i'_node_`j'_`sp'_newcompvars "`eqn`i'_node_`j'_`sp'_newcompvars' `eqn`i'node`j'cov`k'_`sp''"
										}
									}
								
									if "`nocons`i''"=="" local consvar`i' `intercept'
									mata: asarray(nodes`i'_`sp',`j',st_data(.,tokens("`covs`i'' `eqn`i'_node_`j'_`sp'_newcompvars' `consvar`i''"),"`touse'"))
								}	
								
								/* Need to adapt mata global macro containing log hazard function to replace with asarray * p*mat' */
								local newcode "asarray(nodes`i'_`sp',j)*(p`i'coefmat')"
								mata: st_global("mataloghazard2`sp'", subinstr("`mataloghazard2`sp''","p`i'","`newcode'",.))
								
								/* Stuff for d0 file */
								global arraysyntax "$arraysyntax ,transmorphic nodes`i'_`sp'"	//syntax for passing arrays
								global arraynames "$arraynames , nodes`i'_`sp'"
						
						}
						
					global matasyntax $matasyntax , numeric matrix p`i'
					global coefficientmats $coefficientmats , numeric matrix p`i'coefmat
				}
				else {
					if "`covs`i''"!="" {
						global matasyntax $matasyntax , numeric matrix p`i'
					}
					else {				
						global matasyntax $matasyntax , real scalar p`i'
					}
				}
			}

		/***************************************************************************************************************************************************/
		/* Define ml equation syntax */
			
			forvalues i = 1/`np' {
				local eqname : word `i' of `eq_names'
				if "``eqname''"!="" {
					local mlequations "`mlequations' (`eqname': `covs`i'' `eqn`i'varlist' `nocons`i'')"
					local mlevalid "`mlevalid' 1"
				}
				else {
					local mlequations "`mlequations' /`eqname'"
					local mlevalid "`mlevalid' 0"
				}			
			}
			
			global mlevalid `mlevalid'
			global np = `np'
			
			forvalues i=1/`ns' {
				mata: _stime`i' = st_data(.,"`t`i''","`touse'")	//reset t to _t
			}
			
			/* Error check on log hazard function */
			/*cap mata: logh = $mataloghazard1
			if _rc>0 {
				di as error "Error in (log) hazard function specification. Check Mata code."
				exit 198
			}*/
			
			//n di "$mataloghazard21"
			//n di "$mataloghazard22"
			
			cap pr drop stgenreg_d0`d0file'
			ml model d0 stgenreg_d0`d0file'						///
									`mlequations'				///
									if `touse'					///
									`wt',						///
									`mlopts'					///
									waldtest(0)					///
									`nolog'						///
									`searchopt'					///
									`initopt'					///
									maximize
			
			ereturn local cmd stgenreg
			ereturn local predict stgenreg_pred
			ereturn local hazard `hazpred'
			ereturn local nparams = `np'
			forvalues i=1/`ns' {	
				ereturn local nodes`i' = `nnodes`i''
			}
			ereturn local varlist `covlist'
			ereturn local ncomps = trim("`ncomps'") 		//no. of components in each equation
			ereturn local eqnames "`eq_names'"
			ereturn local quadrature legendre
			ereturn local ns = `ns'
			
			/* Store components etc. */
			forvalues i=1/`np' {
				local eqname : word `i' of `eq_names'
				if "``eqname''"!="" {
					
					local k = 1					//index component
					local loop = 0				//loop exit
					local rest ``eqname''		//equation covariate option
					while `loop'==0 {
					
						/* Parsing */
						gettoken first rest: rest, parse("|")
						if `k'!=1 {
							gettoken first rest: rest, parse("|")
						}
						
						/* Post full component */
						ereturn local eqn`i'comp`k' = trim("`first'")
						
						/* Post spline knots */
						if regexm("`first'","#rcs")==1 {
							ereturn local eqn`i'comp`k'bhknots `bhknots_`i'_`k''			//knot locations
							ereturn local eqn`i'comp`k'noorthog `noorthog_`i'_`k''
							if "`noorthog_`i'_`k''"=="" {
								ereturn matrix eqn`i'comp`k'rcsmat = `rmat_`i'_`k''				//orthog matrix
							}
							ereturn local eqn`i'comp`k'rcstime `time_`i'_`k''				//timescale
							foreach var in `covlist' {
								if regexm("`first'","`var'")==1 & "`var'"!="`offsetrcs_`i'_`k''" {
									ereturn local eqn`i'comp`k'tde "`var'"					//variable name for time-dependent effect
								}
							}	
							ereturn local eqn`i'comp`k'rcsoffset `offsetrcs_`i'_`k''
						}
						
						/* Post fracpoly powers */
						if regexm("`first'","#fp")==1 {
							ereturn local eqn`i'comp`k'fps "`fps_`i'_`k''"
							foreach var in `covlist' {
								if regexm("`first'","`var'")==1 & "`var'"!="`offsetfps_`i'_`k''" {
									ereturn local eqn`i'comp`k'tde "`var'"
								}
							}			
							ereturn local eqn`i'comp`k'fpsoffset `offsetfps_`i'_`k''
						}						
						
						if trim("`rest'")=="" {
							local loop = 1
						}
						local `++k'
					}
 
				}
			}
			
			
			
			Replay, level(`level') `eform' 
			
			/* Clear global macros */
			macro drop matasyntax coefficientmats arraysyntax arraynames mataloghazard mataloghazard1 mataloghazard2 tdeind codeline matatdecovssyntax matatdecovsnames bhazvar
			
			/* drop data from mata */
			if "`matakeep'" == "" {
				mata mata drop logh touse
				forvalues i=1/`ns' {
					mata mata drop _stime`i' knewnodes`i' kweights`i' nnodes`i'  t0`i'
				}
				if "`covlist'" != "" mata mata drop `covlist'
				forvalues i = 1/`np' {
					mata mata drop p`i'
					if `eqn`i'tde'==1 {
						//mata mata drop nodes`i' 
					}
				}
				capture mata mata drop component
			}
			
end

program Replay
	syntax [, EFORM Level(int `c(level)')]
	ml display, `eform' level(`level')
/* Display text */
	if "`e(split)'" !="" {
		di in green " Quadrature method: Gauss-Jacobi and Gauss-Legendre with `e(nodes1)' and `e(nodes2)' nodes"
		di in green " Split point at _t = `e(split)'"
	}
	else {
		local quad = proper("`e(quadrature)'")
		di in green " Quadrature method: Gauss-`quad' with `e(nodes1)' nodes"
	}
end

program stgenreg_rcsgen, eclass
	syntax varlist(min=1 max=1), [DF(string) NOOrthog NEWGen(string) OFFset(varname) NEWKNOTS(string) NEWRMATrix(string) TIME TOUSEVAR(varname)]
	
	if "`noorthog'"=="" {
		local orthog orthog
	}
	else {
		local orthog
	}
	if "`offset'" != "" {
		local addoffset +`offset'
	}
	
	tempvar temptime
	if "`time'"!="" {
		qui gen double `temptime' = `varlist' `addoffset' if `tousevar'
	}
	else {
		qui gen double `temptime' = ln(`varlist' `addoffset') if `tousevar'
	}
	
	if "`df'"!="" {
		rcsgen `temptime' if `tousevar', df(`df') gen(`newgen') if2(_d==1) `orthog'
		if "`orthog'"!="" {
			tempname matR
			mat `matR' = r(R)
			ereturn matrix rmatrix = `matR'
		}
		ereturn local noorthog `noorthog'
		ereturn local bhknots `r(knots)'
		ereturn local df `df'
		ereturn local time `time'
		ereturn local offset `offset'
	}
	else {
		local rmat 
		if "`noorthog'"=="" {
			local rmat rmatrix(`newrmatrix')
		}
		qui rcsgen `temptime' if `tousevar', knots(`newknots') gen(`newgen') `rmat'
	}

end

pr define stgenreg_fp, eclass
	syntax anything , [OFFSET(varname) STUB(string) VAR(varname) TOUSEVAR(varname)]
	
	numlist "`anything'", sort
	local fps `r(numlist)'
	
	if "`offset'"!="" {
		local addoffset "+ `offset'"
	}	
	
	if trim("`fps'")=="1" {
		qui gen double `stub'_1 = `var' `addoffset'  if `tousevar'
		local nfps = 1
		local nfps_`i'_`k' = 1
	}
	else {
		qui gen double `stub' = `var' `addoffset' if `tousevar'
		qui fracgen `stub' `fps' if `tousevar', stub(20) noscaling center(no)
		local nfps : word count `r(names)'
		drop `stub'
	}
	
	ereturn local fps `fps'
	ereturn local nfps = `nfps'
	ereturn local offset `offset'
end
