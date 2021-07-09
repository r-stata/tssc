*! mcmccqreg 1.0.0 30May2013
*! author Matthew J. Baker
program mcmccqreg
	version 11.2
	if replay() {
		if (`"`e(cmd)'"' != "mcmccqreg") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass
	syntax varlist [if] [in], 				///
			[DRAWs(int 1000)				///
			BURN(int 0)						///
			ARATE(real .234)                ///
			SAMPLER(string)					///
			DAMPPARM(real 1)				///
			FROM(string)					///
			FROMVariance(string)			///
			SAVING(string)					///
			REPLACE							///
			APPEND							///
			THIN(int 1)						///
			JUMBLE							///
			NOISY							///
			TAU(real .5)					///
			MEDIAN							///
			CENSORvar(varname)]				

	marksample touse
	gettoken lhs rhs : varlist

	markout `touse' `lhs' `rhs'
	 
/* Option checking for conformity, etc. */

	/* Burn-in less than draws */
		
	if (`burn'>=`draws') {
		di as error "Error: The # of burn in draws must be less than # draws"
		exit
	}	
			   
	if "`sampler'"!="mwg" {
		local sampler "global"
	}

	if ("`censorvar'"=="`'") {
		tempname censorvar
		gen double `censorvar'=0 if `touse'
	}

/* Another thing to check - whether or not there are "too many" */
/* zeros in the data */

	tempname tauTooLow
	tempvar censorCheck
	gen double `censorCheck' = `lhs' <= `censorvar'
	quietly sum `censorCheck'
	scalar `tauTooLow' = r(mean) > `tau'
	if (`tauTooLow') {
		disp as err "Caution!!! Observations censored at tau-th percentile!\n"
		disp as err "Interpret results with extreme caution..."
	}

	/* Read in the data */
	
	mata: noisy   =st_local("noisy")
	mata: sampler =st_local("sampler")	
	mata: tau     =strtoreal(st_local("tau"))
	mata: arate   =strtoreal(st_local("arate"))
	mata: alginfo ="standalone",st_local("sampler")
	mata: draws   =strtoreal(st_local("draws"))
	mata: dampparm=strtoreal(st_local("dampparm"))
	mata: burn    =strtoreal(st_local("burn"))
	mata: thin    =strtoreal(st_local("thin"))
	mata: jumble  =st_local("jumble")

	/* If the earlier powell estimator actually described in Powell '84 is desired */
	/* Overwrite tau and multiply by two to get 1                                  */
	
	if "`median'"=="median" {
		mata: weight=2
		mata: tau = .5
	}
	else {
		mata: weight=1
	}
	
	/* Set starting values */
	
	if ("`from'"!="") {
		mata: from=st_matrix("`from'")
	}
	else {
        qui reg `lhs' `rhs' if `touse'
		mata: from=st_matrix("e(b)")
		tempname from 
		mata: st_matrix("`from'",from)
	}
	
	if ("`fromvariance'"!="") {
		mata: W=st_matrix("`fromvariance'")
	}
	else {
		mata: W=I(cols(from))*cols(from)
		tempname fromvariance
		mata: st_matrix("`fromvariance'",W)
	}

	/* Begin estimation process */
	
	mata: M=moptimize_init()
	mata: moptimize_init_evaluator(M,&quan())
	mata: moptimize_init_touse(M,"`touse'")	
	mata: moptimize_init_evaluatortype(M,"gf0")
	mata: moptimize_init_depvar(M,1,"`lhs'")
	mata: moptimize_init_eq_indepvars(M,1,"`rhs'")
	
	mata: st_view(C=.,.,"`censorvar'","`touse'")		
	mata: moptimize_init_userinfo(M,1,tau)	   
	mata: moptimize_init_userinfo(M,2,C)  
	mata: moptimize_init_userinfo(M,3,weight)

	mata: moptimize_init_eq_coefs(M,1,from)	// Not necessary, but... 
	mata: junk=moptimize_evaluate(M)

	/* set up and execute the amcmc run */
	
	mata: alginfo=sampler,"gf0","moptimize"
	mata: Draws = amcmc(alginfo,&quan(),from,W,draws,burn,dampparm,arate,ar=.,vals=.,lam=.,.,M,noisy)
	
	/* process all of the information that does not need further */
	/* manipulation */
	
	tempname arates arates_mean arates_min arates_max
	mata: st_matrix("`arates'",ar)
	mata: st_numscalar("`arates_mean'",mean(ar'))
	mata: st_numscalar("`arates_min'",min(ar))
	mata: st_numscalar("`arates_max'",max(ar))

	/* A function to process draws after they are done */
	
	tempname dof
	mata: mcmccqreg_process_draws(Draws,vals,jumble,thin,0,betaf=.,valsf=.)
	mata: st_numscalar("`dof'",rows(betaf))

	local dof=`dof'

	tempname b V valMean valMax valMin drawsKept
	mata: st_matrix("`b'",mean(betaf))
	mata: st_matrix("`V'",variance(betaf))	
	
	mata: st_numscalar("`valMean'",mean(valsf))
	mata: st_numscalar("`valMax'",max(valsf))
	mata: st_numscalar("`valMin'",min(valsf))
	mata: st_numscalar("`drawsKept'",rows(valsf))	
	
	mat colnames `b' = `rhs' _cons
	mat colnames `V' = `rhs' _cons
	mat rownames `V' = `rhs' _cons
	
	tempname nobs
	quietly tab `touse' if `touse'
	local nobs=`r(N)'

	ereturn clear
	ereturn post `b' `V', esample(`touse') obs(`nobs') dof(`dof')
	
	ereturn local title "Powell's mcmc-estimated censored quantile regression"
	ereturn local cmd "mcmccqreg"
	ereturn local indepvars `rhs'
	ereturn local depvar `lhs'
	ereturn local sampler `sampler'
	ereturn local saving `saving'
	ereturn local jumble `jumble'
	
	ereturn scalar draws=`draws'
	ereturn scalar burn=`burn'
	ereturn scalar thin=`thin'
	ereturn scalar damper=`dampparm'
	ereturn scalar opt_arate=`arate'
	ereturn scalar arates_mean=`arates_mean'
	ereturn scalar f_mean=`valMean'
	ereturn scalar f_max =`valMax'
	ereturn scalar f_min =`valMin'
	ereturn scalar draws_retained = `drawsKept'
	ereturn matrix arates=`arates'
	ereturn matrix b_init=`from'
	ereturn matrix V_init=`fromvariance'

		if "`saving'"!="" {
		preserve
		clear

		local exnames "`rhs' cons"
		getmata (`exnames')=betaf
		getmata (fun_val)=valsf
		
		gen t=_n
		if "`append'"=="append" {
			append using "`saving'"

		}
		else {
			qui save "`saving'", `replace'
		}
		restore
	}		
	
	di _newline
	di as txt "`e(title)'" 
	di as txt "     Observations:         " as res %10.0f `e(N)'
	di as txt "     Mean acceptance rate: " as res %10.3f `e(arates_mean)'
	di as txt "     Total draws:          " as res %10.0f `e(draws)'
	di as txt "     Burn-in draws:        " as res %10.0f `e(burn)'
	di as txt "     Draws retained:       " as res %10.0f `e(draws_retained)'
	if `e(thin)'!=1		{
	di as txt	_col(10) "*One of every " %1.0f `e(thin)' " draws kept"
				} 
	if "`e(jumble)'"=="jumble" {
	di as txt			   _col(10) "*Draws Jumbled"
				} 
				
	ereturn display
	di as txt " Value of objective function:   "
	di as txt "             Mean:         " as res %12.2f `e(f_mean)'
	di as txt "             Min:          " as res %12.2f `e(f_max)'
	di as txt "             Max:          " as res %12.2f `e(f_min)'
	if "`e(saving)'"!="" {
	di as txt "   Draws saved in: " "`e(saving)'"
						}
	di _newline
	di as txt "    *Results are presented to conform with Stata covention, but "
	di as txt "     are summary statistics of draws, not coefficient estimates. "  
end
	
program Replay
	syntax 
	ereturn display
end
	
mata:
void quan(M,todo,b,crit,g,H) {
	real colvector u,Xb,y,C
	real scalar tau
	
	Xb    =moptimize_util_xb(M,b,1)		 /* Xb linear combinations */
	y     =moptimize_util_depvar(M,1)	 /* dependent variable     */
	tau   =moptimize_util_userinfo(M,1) /* value for tau          */	
	C     =moptimize_util_userinfo(M,2)	 /* Censoring points       */
	weight=moptimize_util_userinfo(M,3)
	u     =weight:*(y:-rowmax((C,Xb)))
	crit  =-(u:*(tau:-(u:<0))) /* Use neg. to get minimum */
}	
void mcmccqreg_process_draws(real matrix Draws,
							 real matrix vals,
							 string scalar jumble,
							 real scalar thin,
							 real scalar burn,
							 transmorphic betaf,
							 transmorphic valsf)
{
	real scalar i
	real matrix ordVec

	Draws = Draws[burn+1::rows(Draws),]

	if (thin!=1) {
		keep=J(0,1,.)
		for (i=thin;i<=rows(Draws);i=i+thin) keep=keep \ i
	}
	else keep=(1::rows(Draws))

	if (jumble=="jumble") _jumble(keep)
	betaf=Draws[keep,]
	valsf=vals[keep,]
}	
end	
