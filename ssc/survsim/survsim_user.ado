
program define survsim_user
	version 14.2
	
	syntax newvarname(min=2 max=2), 								///
										MAXTime(string)				///	
																	///
									[								///
										LTruncated(string)			///	
																	///
										LOGHazard(string)			///	
										Hazard(string)				///	
										LOGCHazard(string)			/// 
										CHazard(string)				/// 
										NODES(int 30)				///
																	///
										MIXTURE						///
										Distribution(string)		///
										Lambdas(numlist)			///
										Gammas(numlist)				///
										PMIX(real 0.5)				///
																	///
										COVariates(string)			///
										TDE(string)					///
										TDEFUNCtion(string)			///
																	///
									]								//
		
		local stime : word 1 of `varlist'
		local died  : word 2 of `varlist'
		
		cap which lmoremata.mlib
		if _rc {
			display in yellow "You need to install the moremata package. This can be installed using,"
			display in yellow ". {stata ssc install moremata}"
			exit 198
		}
		
		//====================================================================================================================//
		//mixture - build hazard/chazard and continue as user
			
			if "`mixture'"!="" {
				
				local Nls  : word count `lambdas'
				local Ngs  : word count `gammas'
				
				if `Nls'!=2 | `Ngs'!=2  {
					di as error "Number of lambdas() and gammas() must be 2 under a mixture model"
					exit 198
				}
			
				local l = length("`distribution'")
				if `l'==0 {
					di as error "distribution() required"
					exit 198
				}
				if 		substr("exponential",1,max(1,`l'))=="`distribution'" 	local dist "exp"
				else if substr("gompertz",1,max(3,`l'))=="`distribution'" 		local dist "gompertz"
				else if substr("weibull",1,max(1,`l'))=="`distribution'" 		local dist "weibull"
				else {
					di as error "Unknown distribution"
					exit 198
				}
				
				local l1 : word 1 of `lambdas'
				local l2 : word 2 of `lambdas'
				if "`dist'"=="weibull" | "`dist'"=="gompertz" {
					local g1 : word 1 of `gammas'
					local g2 : word 2 of `gammas'
				}
				
				if "`tde'"=="" {
				
					if "`dist'"=="exp" {
						local chazard "-log(`pmix':*exp(-`l1':*{t}) :+ (1:-`pmix'):*exp(-`l2':*{t}))"
					}
					else if "`dist'"=="weibull" {
						local chazard "-log(`pmix':*exp(-`l1':*{t}:^(`g1')) :+ (1:-`pmix'):*exp(-`l2':*{t}:^(`g2')))"
					}
					else {
						local chazard "-log(`pmix':*exp((`l1':/`g1'):*(1:-exp(`g1':*{t}))) :+  (1:-`pmix'):*exp((`l2':/`g2'):*(1:-exp(`g2':*{t}))))"
					}
					
				}
				else {
				
					if 		"`dist'"=="exp" {
						local base_surv "(`pmix':*exp(-`l1':*{t}) :+ (1:-`pmix'):*exp(-`l2':*{t}))"
						local numer 	"(`l1':*`pmix':*exp(-`l1':*{t}) :+ `l2':*(1:-`pmix'):*exp(-`l2':*{t}))"
						local hazard 	"`numer' :/ `base_surv'"
					}
					else if "`dist'"=="weibull" {
						local base_surv "(`pmix':*exp(-`l1':*{t}:^(`g1')) :+ (1:-`pmix'):*exp(-`l2':*{t}:^(`g2')))"
						local numer 	"(`l1':*`g1':*`pmix':*{t}:^(`g1':-1):*exp(-`l1':*{t}:^(`g1')) :+ `l2':*`g2':*(1:-`pmix'):*{t}:^(`g2':-1):*exp(-`l2':*{t}:^(`g1')))"
						local hazard 	"`numer' :/ `base_surv'"
					}
					else {
						local base_surv "(`pmix':*exp((`l1':/`g1'):*(1:-exp(`g1':*{t}))) :+  (1:-`pmix'):*exp((`l2':/`g2'):*(1:-exp(`g2':*{t}))))"
						local numer 	"`pmix':*exp((`l1':/`g1'):*(1:-exp(`g1':*{t}))) :* (-`l1':*exp(`g1':*{t})) + (1:-`pmix'):*exp((`l2':/`g2'):*(1:-exp(`g2':*{t}))) :* (-`l2':*exp(`g2':*{t}))"
						local hazard 	"(`numer') :/ `base_surv'"
					}
					
				}
				
				//now continues as user function
			}			
			
			
		//====================================================================================================================//
		//baseline covariates
		
			tempvar expxb
			if "`covariates'"!="" {
				
				tokenize `covariates'
				local ncovlist : word count `covariates'
				local ncovvars = `ncovlist'/2
				cap confirm integer number `ncovvars'
				if _rc>0 {
					di as error "Variable/number missing in covariates"
					exit 198
				}
				local ind = 1
				local error = 0
				forvalues i=1/`ncovvars' {
					cap confirm numeric var ``ind'', exact
					if _rc {
						local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...)"
						local error = 1
					}
					cap confirm num ``=`ind'+1''
					if _rc {
						local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...)"
						local error = 1
					}
					tempvar vareffect`i'
					qui gen double `vareffect`i'' = ``ind''*``=`ind'+1''
					local ind = `ind' + 2
				}
				if `error' {
					di as error "`errortxt'"
					exit 198
				}
				local cov_linpred "`vareffect1'"
				if `ncovvars'>1 {
					forvalues k=2/`ncovvars' {
						local cov_linpred "`cov_linpred' + `vareffect`k''"
					}
				}
				
				qui gen double `expxb' = exp(`cov_linpred')
			}
			else qui gen byte `expxb' = 1
		
		//====================================================================================================================//
		// Time-dependent effects
	
			tempvar tdexb
			if "`tde'"!="" {
				tokenize `tde'
				local ntde : word count `tde'	
				local ntdevars = `ntde'/2
				cap confirm integer number `ntdevars'
				if _rc>0 {
					di as error "Variable/number missing in tde"
					exit 198
				}

				local ind = 1
				local error = 0
				forvalues i=1/`ntdevars' {
					cap confirm var ``ind'', exact
					if _rc {
						local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...)"
						local error = 1
					}
					cap confirm num ``=`ind'+1''
					if _rc {
						local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...)"
						local error = 1
					}
					tempvar tdeeffect`i'
					qui gen double `tdeeffect`i'' = ``ind''*``=`ind'+1''

					local ind = `ind' + 2
				}
				if `error' {
					di as error "`errortxt'"
					exit 198
				}
				local tde_linpred "`tdeeffect1'"
				if `ntdevars'>1 {
					forvalues k=2/`ntdevars' {
						local tde_linpred "`tde_linpred' + `tdeeffect`k''"
					}
				}
				
				qui gen double `tdexb' = `tde_linpred'
			}
			else qui gen double `tdexb' = 0
		
		//====================================================================================================================//
		//setup stuff
		
			quietly {
				
				gen double `stime' = .
				
				tempvar logu
				gen double `logu' = log(runiform())
				
				cap drop _survsim_rc
				gen _survsim_rc = 0
				
			}
		
		//====================================================================================================================//
		//core 
		
			if "`loghazard'"!="" | "`hazard'"!="" {
				
				gaussquad_ss, n(`nodes')	//Gauss-Legendre nodes and weights
									
				if "`loghazard'"!="" {
					local hazard exp(`loghazard')
				}
				
				mata: st_local("matahazard",subinstr("`hazard'","{t}","tnodes"))
				
				local matahazard "(`matahazard') :* expxb"
				
				if "`tde'"!="" {
					if "`tdefunction'"=="" {
						local tdefunction tnodes
					}
					else {
						mata: st_local("tdefunction",subinstr("`tdefunction'","{t}","tnodes"))
					}
					
					local matahazard "`matahazard' :* exp(tdexb :* (`tdefunction'))"
				}
				
				//push variables found in loghazard()/hazard() into Mata
				if "`mixture'"=="" {
					
					local Nhvars = 0
					macro drop overallsyntax1 overallsyntax2 mmrootsyntax1 mmrootsyntax2				
					
					gettoken first rest : matahazard, parse("[ ,\^\*\(\)-\+/:<>=]")
					while "`rest'"!="" {
						if trim("`first'")!="," {
							cap confirm var `first', exact
							if !_rc {
								local test1 = 0
								local hvarindex = 0
								foreach var in `covlist' {
									local hvarindex = `hvarindex' + 1
									if "`first'"=="`var'" {
										local test1 = 1
										local refhvarindex = `hvarindex'
									}
								}
								if `test1'==0 {
									local covlist `covlist' `first'		//contains a list of all varnames specified, be they time-indep or time-dependent
									local Nhvars = `Nhvars' + 1
									mata: st_local("matahazard",subinstr("`matahazard'","`first'","hvars[,`Nhvars']"))
								}
								else {
									mata: st_local("matahazard",subinstr("`matahazard'","`first'","hvars[,`refhvarindex']"))
								}
							}
						}
						gettoken first rest : rest, parse("[ ,\^\*\(\)-\+/:<>=]")
					}			
					if `Nhvars' {
						mata: st_view(hvars=.,.,tokens("`covlist'"))
						global overallsyntax1 real matrix hvars
						global overallsyntax2 hvars
						global mmrootsyntax1 , hvars[i,]
						global mmrootsyntax2 , hvars
					}
				}

				//test the hazard function
				if `Nhvars'==0 {
					mata: tnodes = expxb = tdexb = 0.1
					cap mata: test1 = `matahazard'
					if _rc {
						di as error "Error in loghazard()/hazard()"
						exit 198
					}
					mata mata drop tnodes expxb tdexb test1
				}		
				
				//push function into global
				global chaz `matahazard'
				cap pr drop survsim_user_core
				
				survsim_user_core, 	stime(`stime') 				///
									maxtime(`maxtime') 			///
									logu(`logu') 				///
									expxb(`expxb')				///
									tdexb(`tdexb')				///
									ltruncated(`ltruncated') 	//
				
				//tidy up
				cap macro drop cumhaz
				if `Nhvars' {
					cap macro drop overallsyntax1 overallsyntax2 mmrootsyntax1 mmrootsyntax2
				}
			}
			
			//cumulative hazard
			else {
			
				if "`logchazard'"!="" {
					local chazard exp(`logchazard')
				}
				mata: st_local("matachazard",subinstr("`chazard'","{t}","t"))
				local matachazard "(`matachazard') :* expxb"
				if "`ltruncated'"!="" {
					mata: st_local("matachazard0",subinstr("`chazard'","{t}","lt"))
					local matachazard0 "(`matachazard0') :* expxb"
				}
				
				//tde's
				if "`tde'"!="" {
					if "`tdefunction'"=="" {
						local tdefunction1 t
					}
					else {
						mata: st_local("tdefunction1",subinstr("`tdefunction'","{t}","t"))
					}	
					local matachazard "`matachazard' :* exp(tdexb :* (`tdefunction1'))"
					if "`ltruncated'"!="" {
						if "`tdefunction'"=="" {
							local tdefunction0 lt
						}
						else {
							mata: st_local("tdefunction0",subinstr("`tdefunction'","{t}","lt"))
						}	
						local matachazard0 "`matachazard0' :* exp(tdexb :* (`tdefunction0'))"
					}
				}
			
				//any variables in ch() or logch()
				local nhazvars = 0
				macro drop overallsyntax1 overallsyntax2 mmrootsyntax1 mmrootsyntax2				
				gettoken first rest : tempcumhaz, parse("[ ,\^\*\(\)-\+/:<>=]")
				while "`rest'"!="" {
					if trim("`first'")!="," {
						cap confirm var `first', exact
						if !_rc {
							local test1 = 0
							foreach var in `covlist' {
								if "`first'"=="`var'" local test1 = 1
							}
							if `test1'==0 {
								local covlist `covlist' `first'		//contains a list of all varnames specified, be they time-indep or time-dependent
								local nhazvars = `nhazvars' + 1
								mata: st_local("matachazard",subinstr(st_local("matachazard"),"`first'","hvars[1,`nhazvars']"))
								if "`ltruncated'"!="" {
									mata: st_local("matachazard0",subinstr(st_local("matachazard0"),"`first'","hvars[1,`nhazvars']"))
								}
							}
						}
					}
					gettoken first rest : rest, parse("[ ,\^\*\(\)-\+/:<>=]")
				}			
				if `nhazvars' {
					mata: st_view(hvars=.,.,tokens("`covlist'"))
					global overallsyntax1 real matrix hvars
					global overallsyntax2 hvars
					global mmrootsyntax1 , hvars[i,]
					global mmrootsyntax2 , hvars
				}
						
				//test
				if `nhazvars'==0 {
					mata: t = expxb = tdexb = 0.1
					cap mata: test1 = `matachazard'
					if _rc {
						di as error "Error in logchazard()/chazard()"
						exit 198
					}
					mata mata drop t expxb tdexb test1
				}
				
				//push function into global
				global chaz `matachazard'
				if "`ltruncated'"!="" {
					global chaz ${chaz} :- `matachazard0'
				}
				cap pr drop survsim_user_core
				
				survsim_user_core, 	stime(`stime') 				///
									maxtime(`maxtime') 			///
									logu(`logu') 				///
									expxb(`expxb')				///
									tdexb(`tdexb')				///
									ltruncated(`ltruncated') 	///
									chazard						//
				
				//tidy up
				cap macro drop chaz
				if `nhazvars' {
					cap macro drop overallsyntax1 overallsyntax2 mmrootsyntax1 mmrootsyntax2
				}
				
			}
			
	//done
		
end

program define gaussquad_ss, rclass
	syntax [, N(int 30)]
	tempname weights nodes
	mata ss_gq("`weights'","`nodes'")
	return matrix weights = `weights'
	return matrix nodes = `nodes'
end

mata:
void ss_gq(string scalar weightsname, string scalar nodesname)
{
	n 	=  strtoreal(st_local("n"))
	i 	= range(1,n,1)'
	i1 	= range(1,n-1,1)'
		
	muzero = 2
	a = J(1,n,0)
	b = i1:/sqrt(4 :* i1:^2 :- 1)

	A= diag(a)
	for(j=1;j<=n-1;j++){
		A[j,j+1] = b[j]
		A[j+1,j] = b[j]
	}
	symeigensystem(A,vec,nodes)
	weights = (vec[1,]:^2:*muzero)'
	weights = weights[order(nodes',1)]
	nodes = nodes'[order(nodes',1)']
	st_matrix(weightsname,weights)
	st_matrix(nodesname,nodes)
}
		
end
