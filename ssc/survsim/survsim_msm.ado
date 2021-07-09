
program define survsim_msm
	version 14.2
	syntax newvarname(min=3 max=3), 								///
										HAZARD1(string)				///
										MAXTime(string)				///
																	///
									[								///
										TRANSMATrix(name)			///
										LTruncated(string)			///
										STARTSTATE(string)			///
										NODES(int 30)				///
																	///
										*							///	hazard#()
									]								//
		
		local stime  : word 1 of `varlist'
		local state  : word 2 of `varlist'
		local event  : word 3 of `varlist'
		
		cap which lmoremata.mlib
		if _rc {
			display in yellow "You need to install the moremata package. This can be installed using,"
			display in yellow ". {stata ssc install moremata}"
			exit 198
		}

		//====================================================================================================================//
		//parse hazard#()s

			local opts `options'
			local Nhazards = 2
			while "`opts'"!="" & `Nhazards'<51 {
				local 0 , `opts'
				syntax , [HAZARD`Nhazards'(string) * ]
				local opts `options'
				local Nhazards = `Nhazards' + 1
			}
			if `Nhazards'==51 {
				di as error "hazard#() limit reached, or unknown options found"
				exit 198
			}
			local Nhazards = `Nhazards' - 1
			if `Nhazards'==1 {
				di as error "hazard2() required"
				exit 198
			}

			forvalues i=1/`Nhazards' {
				
				local 0 , `hazard`i''
				syntax , 									///
							[								///
								User(string)				///
								Distribution(string)		///
								Lambda(numlist max=1 >0)	///
								Gamma(numlist max=1 >0)		///
															///
								COVariates(string)			///
								TDE(string)					///
								TDEFUNCtion(string)			///
															///
								RESET						///
															///
							]								//
			
				if "`user'"!="" & "`distribution'"!="" {
					di as error "user() and distribution() cannot both be specified in hazard`i'()"
					exit 198
				}
				else if "`user'"=="" & "`distribution'"=="" {
					di as error "One of user() or distribution() must be specified in hazard`i'()"
					exit 198
				}
				
				local user`i' `user'
				
				if "`distribution'"!="" {
					local ld = length("`distribution'")
					if 		substr("exponential",1,max(1,`ld'))=="`distribution'" {
						local dist`i' "exp"
					}
					else if substr("gompertz",1,max(3,`ld'))=="`distribution'" {
						local dist`i' "gompertz"
						if "`gamma'"=="" {
							di as error "gamma() required"
							exit 198
						}
					}
					else if substr("weibull",1,max(1,`ld'))=="`distribution'" {
						local dist`i' "weibull"
						if "`gamma'"=="" {
							di as error "gamma() required"
							exit 198
						}
					}
					else {
						di as error "Unknown distribution"
						exit 198
					}				
					local l`i' `lambda'
					local g`i' `gamma'
				}
				local cov`i' `covariates'
				local tde`i' `tde'
				local tdefunction`i' `tdefunction'
				local reset`i' = "`reset'"!=""
				local resetind `resetind' `reset`i''
			
			}
			
		//====================================================================================================================//
		//transition matrix
			
			if "`transmatrix'"!="" {
				cap confirm matrix `transmatrix'
				if _rc>0  {
					di as error "transmatrix(`transmatrix') not found"
					exit 198
				}
				mata: check_transmatrix()
				//leaves behind `Ntrans'
				local Nstates = rowsof(`transmatrix')
				
				if `Ntrans'!=`Nhazards' {
					di as error "Number of hazard#() specifications does not match number of transitions in transmatrix()"
					exit 198
				}
				
				//get start and stop states for each transition
				local ind = 1
				forvalues i=1/`Nstates' {
					forvalues j=1/`Nstates' {
						if `transmatrix'[`i',`j']!=. {
							local startstate`ind' = `i' 
							local ind = `ind' + 1
						}
					}
				}
			}
			else {
				
				//competing risks
				local Nstates = `Nhazards' + 1
				local Ntrans = `Nhazards'
				tempname transmatrix
				mat `transmatrix' = J(`Nstates',`Nstates',.)
				forvalues i=2/`Nstates' {
					local transind = `i' - 1
					mat `transmatrix'[1,`i'] = `transind'
					local startstate`transind' = 1
				}
			
			}

		//====================================================================================================================//
		//starting state	
			
			if "`startstate'"!="" {
				
				cap confirm integer number `startstate'
				if _rc {
					cap confirm numeric variable `startstate'
					if _rc {
						di as error "Invalid startstate()"
						exit 198
					}
				}
				else {
					if `startstate'<1 {
						di as error "startstate() must be >0"
						exit 198
					}
				}
				
				tempvar ssvar
				gen `ssvar' = `startstate'
				
			}	
			
		//====================================================================================================================//
		//baseline covariates
		
			forvalues z = 1/`Nhazards' {
			
				tempvar expxb`z'
				if "`cov`z''"!="" {

					tokenize `cov`z''
					local ncovlist : word count `cov`z''
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
							local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...) in hazard`z'()"
							local error = 1
						}
						cap confirm num ``=`ind'+1''
						if _rc {
							local errortxt "invalid covariates(... ``ind'' ``=`ind'+1'' ...) in hazard`z'()"
							local error = 1
						}
						tempvar vareffect`z'`i'
						qui gen double `vareffect`z'`i'' = ``ind''*``=`ind'+1''
						local ind = `ind' + 2
					}
					if `error' {
						di as error "`errortxt'"
						exit 198
					}
					local cov_linpred "`vareffect`z'1'"
					if `ncovvars'>1 {
						forvalues k=2/`ncovvars' {
							local cov_linpred "`cov_linpred' + `vareffect`z'`k''"
						}
					}
					
					qui gen double `expxb`z'' = exp(`cov_linpred')
				}
				else qui gen byte `expxb`z'' = 1
				
				local expxb `expxb' `expxb`z''
			}
		
		//====================================================================================================================//
		// Time-dependent effects
	
			forvalues z = 1/`Nhazards' {
			
				tempvar tdexb`z'
				if "`tde`z''"!="" {
					tokenize `tde`z''
					local ntde : word count `tde`z''	
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
							local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...) in hazard`z'()"
							local error = 1
						}
						cap confirm num ``=`ind'+1''
						if _rc {
							local errortxt "invalid tde(... ``ind'' ``=`ind'+1'' ...) in hazard`z'()"
							local error = 1
						}
						tempvar tdeeffect`z'`i'
						qui gen double `tdeeffect`z'`i'' = ``ind''*``=`ind'+1''

						local ind = `ind' + 2
					}
					if `error' {
						di as error "`errortxt'"
						exit 198
					}
					local tde_linpred "`tdeeffect`z'1'"
					if `ntdevars'>1 {
						forvalues k=2/`ntdevars' {
							local tde_linpred "`tde_linpred' + `tdeeffect`z'`k''"
						}
					}
					
					qui gen double `tdexb`z'' = `tde_linpred'
				}
				else qui gen double `tdexb`z'' = 0
				
				local tdexb `tdexb' `tdexb`z''
			}
		
		//====================================================================================================================//
		//core 
		
			gaussquad_ss, n(`nodes')	//Gauss-Legendre nodes and weights
		
			//first pass to turn distributions into user functions
			forvalues z = 1/`Nhazards' {
				
				if "`dist`z''"!="" {
					if "`dist`z''"=="exp" {
						local user`z' "`l`z''"
					}
					else if "`dist`z''"=="weibull" {
						local user`z' "`l`z'' :* `g`z'' :* {t} :^ (`g`z'' :- 1)"
					}
					else {
						local user`z' "`l`z'' :* exp(`g`z'' :* {t})"
					}
				}
				
			}
		
			//mata-fy the user functions
			local Nhvars = 0
			
			forvalues i = 1/`Nhazards' {
				
				local hazard `user`i''
				
				//#t0s
				mata: st_local("matahazard`i'",subinstr("`hazard'","{t0}","time0[,`startstate`i'']"))
				forvalues j=1/`Nhazards' {
					mata: st_local("matahazard`i'",subinstr("`matahazard`i''","{t0`j'}","time0[,`startstate`j'']"))
				}
				
				//#t
				if `reset`i'' {
					mata: st_local("matahazard`i'",subinstr("`matahazard`i''","{t}","(tnodes:-lt)"))
				}
				else {
					mata: st_local("matahazard`i'",subinstr("`matahazard`i''","{t}","tnodes"))
				}
				
				local matahazard`i' "(`matahazard`i'') :* expxb[,`i']"
				
				if "`tde`i''"!="" {
					if "`tdefunction`i''"=="" {
						if `reset`i'' {
							local tdefunction tnodes :- lt
						}
						else {
							local tdefunction tnodes
						}
					}
					else {
						//{t0}s
						mata: st_local("tdefunction`i'",subinstr("`tdefunction`i''","{t0}","time0[,`startstate`i'']"))
						forvalues j=1/`Nhazards' {
							mata: st_local("tdefunction`i'",subinstr("`tdefunction`i''","{t0`j'}","time0[,`startstate`j'']"))
						}
						//{t}
						if `reset`i'' {
							mata: st_local("tdefunction",subinstr("`tdefunction`i''","{t}","tnodes:-lt"))
						}
						else {
							mata: st_local("tdefunction",subinstr("`tdefunction`i''","{t}","tnodes"))
						}
					}
					
					local matahazard`i' "`matahazard`i'' :* exp(tdexb[,`i'] :* (`tdefunction'))"
				}
				
				//push any variables found in the function into Mata
				if "`dist`i''"=="" {
					gettoken first rest : matahazard`i', parse("[ ,\^\*\(\)-\+/:<>=]")
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
									mata: st_local("matahazard`i'",subinstr("`matahazard`i''","`first'","hvars[,`Nhvars']"))
								}
								else {
									mata: st_local("matahazard`i'",subinstr("`matahazard`i''","`first'","hvars[,`refhvarindex']"))
								}
							}
						}
						gettoken first rest : rest, parse("[ ,\^\*\(\)-\+/:<>=]")
					}			
				}
				
			}
			
			//now get total hazards for each starting state
			
			forvalues i=1/`Nstates' {
				
				local totalhazard`i' 
				
				forvalues j=1/`Nstates' {
					
					local trans = `transmatrix'[`i',`j']
					if `trans'!=. {
						if "`totalhazard`i''"=="" {
							local totalhazard`i' `matahazard`trans''
						}
						else {
							local totalhazard`i' `totalhazard`i'' :+ `matahazard`trans''
						}
					}
					
				}
// 				n di "`totalhazard`i''"
			}
		
		//====================================================================================================================//
		//define Mata functions & pointers
			
			quietly {
				
				//transition-specific hazards
				mata: Phfs = J(`Nhazards',1,NULL)
				forvalues i=1/`Nhazards' {
					mata: function hf`i'(tnodes,expxb,tdexb,hvars,lt,time0) return(`matahazard`i'')
					mata: Phfs[`i'] = &hf`i'()
				}
				
				//total hazard from each state
				mata: Ptotalhfs = J(`Nstates',1,NULL)
				forvalues i=1/`Nstates' {
					if "`totalhazard`i''"!="" {
						
						mata: function totalhf`i'(tnodes,expxb,tdexb,hvars,lt,time0) return(`totalhazard`i'')
						mata: Ptotalhfs[`i'] = &totalhf`i'()
					}
				}
				
			}
			
			mata: survsim_msm(Phfs,Ptotalhfs)
			
	//done
	mata mata drop Phfs Ptotalhfs
		
end

program define gaussquad_ss, rclass
	syntax [, N(int 30)]
	tempname weights nodes
	mata ss_gq("`weights'","`nodes'")
	return matrix weights = `weights'
	return matrix nodes = `nodes'
end

local RS real scalar
local RC real colvector
local RM real matrix
local SS string scalar
local PC pointer colvector 
local PS pointer scalar
local opts "o1, o2, o3, o4, o5, o6, o7, o8, o9, o10"

mata:

void survsim_msm(`PC' Phfs, `PC' Ptotalhfs)
{
	N 			= st_nobs()
	tmat 		= st_matrix(st_local("transmatrix"))
	Nstates 	= rows(tmat)
	Nnextstates	= rownonmissing(tmat)
	reset		= strtoreal(tokens(st_local("resetind")))

	st_view(maxt = .,.,st_local("maxtime"))
	if (st_local("ltruncated")!="") {
		st_view(lt=.,.,st_local("ltruncated"))
	}
	else lt = J(N,1,0)
	
	if (st_local("startstate")!="") {
		st_view(ss=.,.,st_local("ssvar"))
	}
	else ss = J(N,1,1)
	
	st_view(expxb = .,.,st_local("expxb"))
	st_view(tdexb = .,.,st_local("tdexb"))

	Nhvars = strtoreal(st_local("Nhvars"))
	if (Nhvars) st_view(hvars=.,.,tokens(st_local("covlist")))
	else		hvars = J(N,1,.)
	
	//time of entry to each state: obs x state
	//-> gets updated so can be used in user() functions
	time0 = J(N,Nstates,.)
	for (i=1;i<=Nstates;i++) {
		sindex 	= selectindex(ss:==i)
		Ns		= rows(sindex)
		if (Ns) time0[sindex,i] = lt[sindex]
	}
	
	//newvarname stubs
	stime = st_local("stime")
	state = st_local("state")
	event = st_local("event")
	
	nodes 	= st_matrix("r(nodes)")'
	weights = st_matrix("r(weights)")
	
	done  = J(N,1,0)
	
	states 		= J(1,2,ss)
	times		= J(1,2,lt)
	coreindex 	= 1::N
	tol 		= 0
	maxit		= 1000

	//initial variables
	varindex = 0
	id1 = st_addvar("double", stime+strofreal(varindex))
	id2 = st_addvar("int", state+strofreal(varindex))
	st_store(.,id1,.,times[,1])
	st_store(.,id2,.,states[,1])

	//handle time = 0
	anyt0 = selectindex(times[,1]:==0)
	Nanyt0 = rows(anyt0)\cols(anyt0)
	if (Nanyt0[1] & Nanyt0[2]) times[anyt0,2] = J(Nanyt0[1],1,smallestdouble()) 

	while (sum(done)<N) {

		// until they're all done, for each move need to loop over all states as obs. could be in any of them
		// start time and state gets updated
		states[,1] 	= states[,2]
		times[,1]  	= times[,2]
		events		= J(N,1,.)

		for (i=1; i<=Nstates; i++) {
			
			if (Nnextstates[i]) {

				index 	= select(coreindex,(states[,1]:==i) :* (done:==0))		//update index vector
				Nsim 	= rows(index),cols(index)								//number of obs to simulate
				if (!(Nsim[1] & Nsim[2])) continue								//no one in current state so carry on
				
				newstate = J(Nsim[1],1,.)

				// simulate event time

					logu		= log(runiform(Nsim[1],1))
					rc 			= survsim_mm_root(	t=J(Nsim[1],1,.),&survsim_msm_sim(),	///
													times[index,1],maxt[index],				///
													tol,maxit,								///
													rindex=1::Nsim[1],						///
													logu,									///
													nodes,									///
													weights,								///
													Ptotalhfs[i],							///
													times[index,1],							///
													time0[index,],							///
													expxb[index,],							///
													tdexb[index,],							///
													hvars[index,])							//

					//right censored are done
					tempdoneindex = selectindex(t:==maxt[index])
					Ntempdone = rows(tempdoneindex)\cols(tempdoneindex)
					if (Ntempdone[1] & Ntempdone[2]) done[index[tempdoneindex]] = J(Ntempdone[1],1,1)
					
					times[index,2] = t

				// simulate event indicator
					
					events[index] = J(Nsim[1],1,0)
					
					// update index to take out right censored
					index 	= select(index,done[index]:==0)
					Nsim 	= rows(index)\cols(index)
					if (!(Nsim[1] & Nsim[2])) continue	
					
					events[index] = J(Nsim[1],1,1)

					stateid = J(Nnextstates[i],1,.)
					ind 	= 1
					for (s=1;s<=Nstates;s++) {
						if (tmat[i,s]!=.) {
							stateid[ind++] = s
						}
					}

					if (Nnextstates[i]>1) {
						pmatrix = J(Nsim[1],Nnextstates[i],.)
						for (s=1;s<=Nnextstates[i];s++) {
							pmatrix[,s] = (*Phfs[tmat[i,stateid[s]]])(times[index,2],expxb[index,],tdexb[index,],hvars[index,],times[index,1],time0[index,])
						}
						pmatrix 	= pmatrix :/ quadrowsum(pmatrix)
						newstates 	= J(Nsim[1],1,.)
						for (s=1;s<=Nsim[1];s++) {
							newstates[s] = rdiscrete(1,1,pmatrix[s,])
						}
						states[index,2] = stateid[newstates]
					}
					else states[index,2] = J(Nsim[1],1,stateid)

			}
			
		}
		
		// update done for those now in an absorbing state		
		// and new times of entry into each state
		notdoneindex = selectindex(done:==0)
		Nnotdone = rows(notdoneindex)\cols(notdoneindex)
		
		if (Nnotdone[1] & Nnotdone[2]) {
			for (j=1;j<=Nstates;j++) {
				//entry times
				toupdate 		= select(notdoneindex,states[notdoneindex,2]:==j)
				Ntoupdate		= rows(toupdate)\cols(toupdate)
				if (Ntoupdate[1] & Ntoupdate[2]) {
					time0[toupdate,j] = times[toupdate,2]
					//done index
					if (!Nnextstates[j]) done[toupdate] = J(Ntoupdate[1],1,1)
				}
				
			}
		}
	
		//post new variables
		varindex++
		id1 = st_addvar("double", stime+strofreal(varindex))
		id2 = st_addvar("int", state+strofreal(varindex))
		id3 = st_addvar("byte", event+strofreal(varindex))
		st_store(.,id1,.,times[,2])
		st_store(.,id2,.,states[,2])
		st_store(.,id3,.,events)
		
		//now update done to missing, so not carried forward
		doneindex = selectindex(done:==1)
		Ndone = rows(doneindex)\cols(doneindex)
		if (Ndone[1] & Ndone[2]) {
			times[doneindex,2] = states[doneindex,2] = J(Ndone[1],1,.)
		}

	}
	
	printf("variables "+stime+"0 to "+stime+strofreal(varindex)+" created\n" )
	printf("variables "+state+"0 to "+state+strofreal(varindex)+" created\n" )
	printf("variables "+event+"1 to "+event+strofreal(varindex)+" created\n" )

}

function survsim_msm_sim(	`RC' t, `RC' logu, `RM' nodes, `RM' weights, `PS' hfunc, 	///
							`RC' lt, `RM' time0, 										///
							`RM' expxb, `RM' tdexb, `RM' hvars)
{
	tnodes 		= (t :- lt) :* 0.5 :* J(rows(t),1,nodes) :+ (t :+ lt) :/ 2
	chq 		= (*hfunc)(tnodes,expxb,tdexb,hvars,lt,time0)
	_editmissing(chq,0)
	return((t :- lt) :/2 :* chq * weights :+ logu)
}

void ss_gq(`SS' weightsname, `SS' nodesname)
{
	n 	= strtoreal(st_local("n"))
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

`RC' survsim_mm_root(	transmorphic x,      					/// bj: will be replaced by solution
						pointer(real matrix function) scalar f,	/// Address of the function whose zero will be sought for
						`RC' ax,      							/// Root will be sought for within a range [ax,bx]
						`RC' bx,      							///
						real scalar tol,   						/// Acceptable tolerance for the root value (default 0)
						real scalar maxit, 						/// maximum # of iterations (default: 1000)
						`RC' index,| 							/// 
						`opts')									//  additional args to pass on to f
{
    transmorphic  fs            // setup for f
    `RC'   a, b, c       		// Abscissae, descr. see above
    `RC'   fa, fb, fc  			// f(a), f(b), f(c)
    real scalar   prev_step     // Distance from the last but one
    real scalar   tol_act       // Actual tolerance
    real scalar   p             // Interpolation step is calcu-
    real scalar   q             // lated in the form p/q; divi-
                                // sion operations is delayed
                                // until the last moment
    real scalar   new_step      // Step at this iteration
    real scalar   t1, cb, t2
    real scalar   itr

	`RS' nobs

    fs = mm_callf_setup(f, args()-7, `opts') 	// bj: prepare function call

    //x = .                       				// bj: initialize output
	
	//copy everything that gets indexed and subsequently updated
	tempo1 	= o1
	tempo5 	= o5
	tempo6 	= o6
	tempo7 	= o7
	tempo8 	= o8
	tempo9  = o9
	nobs = rows(x)

	result = J(nobs,1,.)	
	x = J(nobs,1,.)

    a = ax
	b = bx

	fa = mm_callf(fs, a);  fb = mm_callf(fs, b)
    c = a;  fc = fa

    //if ( fa==. ) return(0)      // bj: abort if fa missing
	tempindex = selectindex(fa:==.)
	nti = rows(tempindex)
	if (nti & cols(tempindex)) result[tempindex,] = J(nti,1,0)

	//remove tempindex as they are done 
	index = select(index,fa:!=.)

	if (rows(index)) { //not done

		tempindex = select(index,((fa[index]:>0) :* (fb[index]:>0))) 
		if (cols(tempindex)) {			
			
			flag1 = abs(fa[tempindex]) :< abs(fb[tempindex])
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,2)
				x[tempindex2] = a[tempindex2]
			}
			tempindex2 = select(tempindex,flag2)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,3)
				x[tempindex2] = b[tempindex2]
			}
			//update index
			index = select(index,x[index]:==.)	
			if (rows(index)==0) return(result)
		}

		tempindex = select(index,((fa[index]:<0) :* (fb[index]:<0)))
		if (cols(tempindex)) {			

			flag1 = abs(fa[tempindex]) :< abs(fb[tempindex])
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,2)
				x[tempindex2] = a[tempindex2]
			}
			
			tempindex2 = select(tempindex,flag2)
			nti = rows(tempindex2)
			if (nti) {
				result[tempindex2] = J(nti,1,3)
				x[tempindex2] = b[tempindex2]
			}
			//update index
			index = select(index,x[index]:==.)	
			if (rows(index)==0) return(result)
		}
	}
	else return(result)

	for (itr=1; itr<=maxit; itr++) {

		tempindex = index[selectindex(fb[index]:==.)]

		if (cols(tempindex)) result[tempindex] = J(rows(tempindex),1,0)

		//remove tempindex as they are done 
		index = select(index,fb[index]:!=.)

		if (!cols(index)) return(result)

		tempindex = select(index,abs(fc[index]) :< abs(fb[index]))

		if (cols(tempindex)) {
			a[tempindex] = b[tempindex];  b[tempindex] = c[tempindex];  c[tempindex] = a[tempindex];         // best approximation
            fa[tempindex] = fb[tempindex];  fb[tempindex] = fc[tempindex];  fc[tempindex] = fa[tempindex]
		}

		tol_act = 2 :* survsim_epsilon_vec(b[index]) :+ tol:/2
        new_step = (c[index]:-b[index]):/2

		flag1 = (abs(new_step):<=tol_act) :+ (fb[index]:==0)
		flag2 = (flag1:==0)
		tempindex = select(index,flag1)

		if (cols(tempindex)) {
			x[tempindex] = b[tempindex]
			result[tempindex] = J(rows(tempindex),1,0)
		}

		index = select(index,flag2)  
		if (!cols(index) | !rows(index)) return(result)

		//update stuff
		tol_act = select(tol_act,flag2)
		new_step = select(new_step,flag2)

        // Decide if the interpolation can be tried
		prev_step = b[index]:-a[index]

		tempindex11 = (abs(prev_step) :>= tol_act) :* (abs(fa[index]) :> abs(fb[index]))
		tempindex = select(index,tempindex11)

		if (cols(tempindex)) {
		
			cb = c[tempindex] :- b[tempindex]
			
			p = q  = cb:*0					//fix

			flag1 = a[tempindex] :== c[tempindex]
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			if (cols(tempindex2)) {
				t1 = fb[tempindex2]:/fa[tempindex2]
				p[selectindex(flag1)] = select(cb,flag1) :* t1
				q[selectindex(flag1)] = 1:- t1
			}
			tempindex2 = select(tempindex,flag2)
			if (cols(tempindex2)) {			
				q[selectindex(flag2)] = fa[tempindex2]:/fc[tempindex2]; t1 = fb[tempindex2]:/fc[tempindex2]; t2 = fb[tempindex2]:/fa[tempindex2]
				p[selectindex(flag2)] = t2 :* ( select(cb,flag2) :* q[selectindex(flag2)] :* (q[selectindex(flag2)] :- t1) :- (b[tempindex2]:-a[tempindex2]):*(t1:-1) )
                q[selectindex(flag2)] = (q[selectindex(flag2)]:-1) :* (t1:-1) :* (t2:-1)
			}
			flag1 = p:>0
			flag2 = 1:-flag1
			tempindex = selectindex(flag1)
			if (cols(tempindex)) q[tempindex] = -q[tempindex]
			tempindex = selectindex(flag2)
			if (cols(tempindex)) p[tempindex] = -p[tempindex]

			tempindex = (p :< (0.75:*cb:*q:-abs(select(tol_act,tempindex11):*q):/2))  :* (p :< abs(select(prev_step,tempindex11):*q:/2))
			if (cols(tempindex)) {
				//update tempindex11
				tempindex22 = select(selectindex(tempindex11),tempindex)
				if (cols(tempindex22) & rows(tempindex22)) new_step[tempindex22] = p[selectindex(tempindex)]:/q[selectindex(tempindex)]
			}
			
		}

		tempindex = selectindex(abs(new_step) :< tol_act)
		if (rows(tempindex)) {
			flag1 = new_step[tempindex] :> 0
			flag2 = 1:-flag1
			tempindex2 = select(tempindex,flag1)
			if (rows(tempindex2)) new_step[tempindex2] = tol_act[tempindex2]
			tempindex2 = select(tempindex,flag2)
			if (rows(tempindex2)) new_step[tempindex2] = -tol_act[tempindex2]
        }

        a[index] = b[index];  fa[index] = fb[index]                   // Save the previous approx.
        b[index] = b[index] :+ new_step

		o1 = tempo1[index]
		o5 = tempo5[index]
		o6 = tempo6[index,]
		o7 = tempo7[index,]
		o8 = tempo8[index,]
		o9 = tempo9[index,]
		
		fb[index] = mm_callf(fs, b[index]) // Do step to a new approxim.

		tempindex1 = select(index,((fb[index]:>0) :* (fc[index]:>0)))
		tempindex2 = select(index,((fb[index]:<0) :* (fc[index]:<0)))

		if (cols(tempindex1)) {			
			c[tempindex1] = a[tempindex1]
			fc[tempindex1] = fa[tempindex1]
		}
		if (cols(tempindex2)) {			
			c[tempindex2] = a[tempindex2]
			fc[tempindex2] = fa[tempindex2]
		}
    }

	x[index] = b[index]
	result[index] = J(rows(index),1,0)
    return(result)                             // bj: convergence not reached
}


real colvector survsim_epsilon_vec(real colvector y)
{
	res = J(rows(y),1,.)
	for (i=1;i<=rows(y);i++) res[i] = epsilon(y[i])
	return(res)
}


end
