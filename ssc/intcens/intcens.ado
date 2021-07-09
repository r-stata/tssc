*** Last modified 11th October 2005

program define intcens, eclass
version 8.2

if replay(){
	if ("`e(cmd)'"~="intcens") error 301
	syntax [ ,  eform level(integer `c(level)')]
} 
else{
	syntax varlist(min=2 numeric) [if] [in]  [ fweight pweight ] ,  Distribution(string) [ Robust CLuster(varlist) cwien(varlist) eform odds time init(name) level(integer `c(level)') small(real 1E-6) iter(integer 1000) nolog * ]

quietly{
	mlopts mlopts , `options'

	if index("`distribution'", "exp")~=0{
		global intcens_dist "exp"
	}
	else if index("`distribution'", "weib")~=0{
		global intcens_dist "weib"
	}
	else if index("`distribution'", "logl")~=0|index("`dist'", "llo")~=0{
		global intcens_dist "logl"
	}
	else if index("`distribution'", "logn")~=0|index("`dist'", "ln")~=0{
		global intcens_dist "logn"
	}
	else if index("`distribution'", "gam")~=0&index("`distribution'", "gen")==0{
		global intcens_dist "gam"
	}
	else if index("`distribution'", "gen")~=0{
		global intcens_dist "gen"
	}
	else if index("`distribution'", "gom")~=0{
		global intcens_dist "gomp"
	}
	else if index("`distribution'", "invg")~=0{
		global intcens_dist "invg"
	}
	else if index("`distribution'", "wien")~=0&index("`distribution'", "ran")==0{
		global intcens_dist "wien"
	}
	else if index("`distribution'", "wienran")~=0{
		global intcens_dist "wienran"
	}
	else{
		di as error "Distribution is not specified clearly enough" 
		exit
	}

	if "`time'"~=""&inlist("$intcens_dist", "exp", "weib")==0{
		di as error `""time" may not be specified with this distribution"'
		exit
	}
	if "`odds'"~=""&"$intcens_dist"~="logl"{
		di as error `""odds" may only be specified with log-logistic distribution"'
		exit
	}
	if "`cwien'"~=""&inlist("$intcens_dist", "wien", "wienran")==0{
		di as error `""cwien" not allowed with this distribution"'
		exit
	}

	marksample touse, novarlist
	
	if "`cluster'"~=""{
		local clust "cluster(`cluster')"
	}
	if "`weight'"~=""{
		tempvar wvar
		gen double `wvar' `exp' if `touse'
		local wgt "[`weight'=`wvar']"
		if "`weight'"=="pweight"{
			local robust "robust"
		}
	}

	gettoken left covs:varlist
	gettoken right covs:covs
	/* left and right time variables can be missing, this indicates left and right censoring */
	markout `touse' `covs'  `wvar' `cwien'
	markout `touse' `cluster' , strok
	
	tempvar f
	gen byte `f'=.
	replace `f'=1 if abs(`left'-`right')<=`small'&`left'>0&`right'>0&`touse'	/* Point data */
	replace `f'=2 if `right'>=.&`left'>0&`left'<.&`touse'					/* Right-censored */
	replace `f'=3 if (`left'>=.|`left'==0)&`right'>0&`right'<.&`touse'		/* Left-censored */
	replace `f'=4 if `left'>0&`right'<.&`left'<`right'&`f'~=1 &`touse'		/* Interval-censored */
	
	markout `touse' `f'

	forval i=1/4{
		if "`weight'"=="fweight"{
			su `wvar' if `f'==`i', meanonly
			local sum`i'=r(sum)
		}
		else{
			count if `f'==`i'
			local sum`i'=r(N)
		}	
	}
	local N_unc=`sum1'
	local N_rc=`sum2'
	local N_lc=`sum3'
	local N_int=`sum4'
	
	/* generate midpoint time variable for preliminary fitting */

	tempvar t d
	gen double `t'=.
	gen byte `d'=1 if `touse'
	replace `t'=`left' if `f'==1
	replace `t'=`left' if `f'==2
	replace `d'=0 if `f'==2
	replace `t'=`right'/2  if `f'==3
	replace `t'=(`left'+`right')/2  if `f'==4

	local iter0=50
	tempname b
	if inlist("$intcens_dist", "exp", "weib", "logl", "logn", "gen", "gomp"){
		***************************************************************
		***************************************************************
		if "`init'"==""{
			preserve	/* need to preserve to save user's st setting, if any */
			stset `t' if `touse' `wgt' , failure(`d')
		}
		if "$intcens_dist"=="exp"|"$intcens_dist"=="weib"{
			if "`init'"==""{
				streg `covs', dist($intcens_dist) time  iter(`iter0')
				matrix `b'=e(b)
			}
			else{
				matrix `b'=`init'
				if "`time'"==""{ 		// if initial values are given and "time" is not specified then assume initial values
										// are in log HR metric, so they need to be changed to log AF metric for estimation
					if "$intcens_dist"=="exp"{
						matrix `b'=-`b'
					}
					else if "$intcens_dist"=="weib"{
						local k1=colsof(`b')
						local k2=`k1'-1
						matrix `b'=-`b'[1,1..`k2']/exp(`b'[1,`k1']), (`b'[1,`k1'])
					}
				}
			}
			if "$intcens_dist"=="exp"{
				local aux=0
				if "`time'"~=""{
					local metric "time"
				}
				else{
					local metric "hazard"
				}
			}
			else if "$intcens_dist"=="weib"{
				local anc "(ln_p:)"
				local aux=1
				if "`time'"~=""{
					local metric "time"
				}
				else{
					local metric "hazard"
				}
			}
		}
		else if "$intcens_dist"=="gen"{
			if "`init'"==""{
				streg `covs', dist(gam) iter(`iter0')
				matrix `b'=e(b)
			}
			else{
				matrix `b'=`init'
			}
			local anc "(ln_sig:) (kappa:)"
			local aux=2
			local metric "time"
		}
		else if inlist("$intcens_dist", "gomp", "logl", "logn"){
			if "`init'"==""{
				streg `covs', dist($intcens_dist) iter(`iter0')
				matrix `b'=e(b)
			}
			else{
				matrix `b'=`init'
			}
			if "$intcens_dist"=="logl"{
				local anc "(ln_gam:)"
				local aux=1
				if "`odds'"~=""{
					local metric "odds"
				}
				else{
					local metric "time"
				}
				if "`init'"~=""&"`odds'"~=""{
					local k1=colsof(`b')
					local k2=`k1'-1
					matrix `b'=-`b'[1,1..`k2']*exp(`b'[1,`k1']), (`b'[1,`k1'])
				}
			}
			else if "$intcens_dist"=="logn"{
				local anc "(ln_sig:)"
				local aux=1
				local metric "time"
			}
			else if "$intcens_dist"=="gomp"{
				local anc "(gamma:)"
				local aux=1
				local metric "hazard"
			}
		}
		if "`init'"==""{
			restore
		}
		***************************************************************
		***************************************************************
	}
	
	
	/* Stata gamma is generalized gamma, which is "gen" here.
	  	Here, "gam" is 2-parameter gamma distribution. */
	else if "$intcens_dist"=="gam"{
		if "`init'"==""{
			glm `t' `covs' if `touse' `wgt' , family(gamma) link(log) iter(`iter0')
			tempname logalpha
			matrix `b'=e(b)
			scalar `logalpha'=-log(e(phi))
			matrix `b'=`b', (`logalpha')
			if `N_lc'>0|`N_int'>0{
				tempvar t1
				gen double `t1'=`t' if `d'==1&`touse'
				intcens `t' `t1' `covs' if `touse' `wgt' , dist(gam) init(`b') iter(`iter0') 
				global intcens_dist "gam"
				matrix `b'=e(b)
			}
		}
		else{
			matrix `b'=`init'
		}	
		local k1=colsof(`b')
		local k2=`k1'-1
		matrix `b'[1,`k2']=`b'[1,`k2']-`b'[1,`k1']
		local anc "(ln_alpha:)"
		local aux=1
		local metric "time"
		global intcens_maxm "d2"
	}
	
	else if "$intcens_dist"=="invg"{
		if "`init'"==""{
			glm `t' `covs' if `touse' `wgt' , family(ig) link(log) iter(`iter0')
			matrix `b'=e(b)
			matrix `b'=`b', (log(e(dispers)))
			if `N_lc'>0|`N_int'>0{
				tempvar t1
				gen double `t1'=`t' if `d'==1&`touse'
				intcens `t' `t1' `covs' if `touse' `wgt' , dist(invg) init(`b') iter(`iter0')
				global intcens_dist "invg"
				matrix `b'=e(b)
			}
		}
		else{
			matrix `b'=`init'
		}
		local anc "(ln_phi:)"
		local aux=1
	} 
	
	else if "$intcens_dist"=="wien"{
		if "`init'"==""{
			glm `t' `covs' if `touse' `wgt' , family(ig) link(log) iter(`iter0')
			tempname logc
			matrix `b'=e(b)
			local k2=colsof(`b')
			scalar `logc'=-0.5*log(e(dispers))
			matrix `b'=-`b'
			matrix `b'[1, `k2']=`b'[1, `k2']+`logc'
			if "`cwien'"~=""{
				local kc:word count `cwien'
				matrix `b'=`b', J(1, `kc', 0), (`logc')
			}
			else{
				matrix `b'=`b', (`logc')
			}
			if `N_lc'>0|`N_int'>0{
				tempvar t1
				gen double `t1'=`t' if `d'==1&`touse'
				intcens `t' `t1' `covs' if `touse' `wgt' , dist(wien) init(`b') cwien(`cwien') iter(`iter0') 
				global intcens_dist "wien"
				matrix `b'=e(b)
			}
		}
		else{
			matrix `b'=`init'
		}
		local anc "(ln_c:`cwien')"
		local aux=0
	} 
	
	else if "$intcens_dist"=="wienran"{
		intcens `left' `right' `covs' if `touse' `wgt' , dist(wien) cwien(`cwien') iter(`iter')
		tempname ll_c
		scalar `ll_c'=e(ll)
		global intcens_dist "wienran"
		if "`init'"==""{
			tempvar xb
			predict `xb' if `touse',xb
			_pctile `xb' if `touse' `wgt', p(50)
			local logtau=r(r1)-3
			matrix `b'=e(b)
			matrix `b'=`b', (`logtau')
		}
		else{
			matrix `b'=`init'
		}
		local anc "(ln_c:`cwien') (ln_tau:)"
		local aux=1
	} 
		
	if "$intcens_dist"~="gam"{
		global intcens_maxm "lf"
	}

	n ml model $intcens_maxm intcens_ll (xb: `left' `right' `f'=`covs') `anc' if `touse' `wgt' , /*
		*/ missing `robust' `clust' maximize init(`b' , copy) nooutput search(off) iter(`iter') `log' `mlopts'

	matrix `b'=e(b)
	local k1=e(k)
	ereturn scalar k_aux=`aux'
	ereturn local depvar "`left' `right'"
	ereturn scalar k_dv=2
	
	ereturn scalar N_unc=`N_unc'
	ereturn scalar N_rc=`N_rc'
	ereturn scalar N_lc=`N_lc'
	ereturn scalar N_int=`N_int'
		
	if "$intcens_dist"=="gam"{
		ereturn scalar alpha=exp(`b'[1,`k1'])
		local k2=`k1'-1
		matrix `b'[1,`k2']=`b'[1,`k2']+`b'[1,`k1']
		ereturn repost b=`b'
		tempname v w
		matrix `v'=e(V)
		matrix `w'=I(`k1')
		matrix `w'[`k2',`k1']=1
		matrix `v'=`w'*`v'*`w''
		ereturn repost V=`v'
	}
	else if "$intcens_dist"=="gen"{
		local k2=`k1'-1
		ereturn scalar sigma=exp(`b'[1,`k2'])
		ereturn scalar kappa=`b'[1,`k1']
	}
	else if "$intcens_dist"=="gomp"{
		ereturn scalar gamma=`b'[1,`k1']   
	}
	else if "$intcens_dist"=="invg"{
		ereturn scalar phi=exp(`b'[1,`k1'])   
	}
	
	ereturn local frm2 "`metric'"

	if "$intcens_dist"=="wienran"{
		ereturn scalar ll_c=`ll_c'
		ereturn scalar chi2_c=2*(e(ll)-e(ll_c))
		ereturn scalar p_c=0.5*chi2tail(1, e(chi2_c))
	}

	if "$intcens_dist"=="exp"&"`time'"==""{
		matrix `b'=-`b'
		ereturn repost b=`b'
	}
	if "$intcens_dist"=="weib"{
		ereturn scalar aux_p=exp(`b'[1,`k1'])
		if "`time'"==""{ // convert to hazard ratio metric, unless "time" is specified	
			local k2=`k1'-1
			matrix `b'=-`b'[1,1..`k2']*e(aux_p), (`b'[1,`k1'])
			tempname v w
			matrix `v'=e(V)
			matrix `w'=-e(aux_p)*I(`k2'), `b'[1,1..`k2']' \ J(1,`k2',0), J(1,1,1)
			matrix `v'=`w'*`v'*`w'' 
			ereturn repost b=`b'
			ereturn repost V=`v'
		}
	}

 	if "$intcens_dist"=="logl"{
	  	ereturn scalar gamma=exp(`b'[1,`k1'])
		if "`odds'"~=""{ // convert to odds ratio metric if "odds" is specified
			local k2=`k1'-1
			matrix `b'=-`b'[1,1..`k2']/e(gamma), (`b'[1,`k1'])
			tempname v w
			matrix `v'=e(V)
			matrix `w'=-1/e(gamma)*I(`k2'), -`b'[1,1..`k2']' \ J(1,`k2',0), J(1,1,1)
			matrix `v'=`w'*`v'*`w''  
			ereturn repost b=`b'
			ereturn repost V=`v'
		}
	}

	ereturn local dist "$intcens_dist"
	ereturn local left "`left'"
	ereturn local right "`right'"
	ereturn local cmd "intcens" 
	  
	macro drop intcens_dist
	macro drop intcens_maxm
	
} /* end of quietly */
} /* end of estimation */


/* display results */

if "`eform'"==""{
	local log "log"	
}
else if "`e(frm2)'"=="hazard"{
	local eform "eform(hr)"
}
else if "`e(frm2)'"=="odds"{
	local eform "eform(or)"
}

if "`e(frm2)'"=="time"{
	local metric "acceleration factors"
}
else if "`e(frm2)'"=="hazard"{
	local metric "hazard ratios"
}
else if "`e(frm2)'"=="odds"{
	local metric "odds ratios"
}
else if inlist("`e(dist)'", "invg", "wien", "wienran"){
	if "`eform'"==""{
		local metric "link"
	}
	else{
		local metric "log link"
	}
}

if e(dist)=="exp"{
	local fulldist "Exponential distribution"
}
else if e(dist)=="weib"{
	local fulldist "Weibull distribution"
	local dianc "diparm(ln_p, exp label("p"))"
}
else if e(dist)=="logl"{
	local fulldist "Log-logistic distribution"
	local dianc "diparm(ln_gam , exp label("gamma"))"
}
else if e(dist)=="logn"{
	local fulldist "Log-normal distribution"
	local dianc "diparm(ln_sig , exp label("sigma"))"
}
else if e(dist)=="gam"{
	local fulldist "Gamma distribution"
	local dianc "diparm(ln_alpha , exp label("alpha"))"
}
else if e(dist)=="gen"{
	local fulldist "Generalized gamma distribution"
	local dianc "diparm(ln_sig , exp label("sigma"))"
}
else if e(dist)=="gomp"{
	local fulldist "Gompertz distribution"
}
else if e(dist)=="invg"{
	local fulldist "Inverse Gaussian distribution"
	local dianc "diparm(ln_phi , exp label("phi"))"
}
else if e(dist)=="wien"{
	local fulldist "Inverse Gaussian, Wiener process parameterisation" 
}
else if e(dist)=="wienran"{
	local fulldist "Wiener process with random drift"
	local dianc "diparm(ln_tau , exp label("tau"))"
}

di as text _n _col(2) "`fulldist'","-","`log'","`metric'" _n

di as text  _col(2) "Uncensored" _c
di as result _col(20) %8.0f e(N_unc) 
di as text  _col(2) "Right-censored" _c
di as result _col(20) %8.0f e(N_rc)
di as text  _col(2) "Left-censored" _c
di as result _col(20) %8.0f e(N_lc)
di as text  _col(2) "Interval-censored" _c
di as result _col(20) %8.0f e(N_int) 

ml display , `eform' level(`level') `dianc'

if e(dist)=="wienran"{
	di as text _col(2) "Likelihood-ratio test of tau=0: chibar(01) = " _c
	di as result e(chi2_c) 
	di as text _col(2) "Prob > chibar2 = "  _c
	di as result e(p_c)
}

end
