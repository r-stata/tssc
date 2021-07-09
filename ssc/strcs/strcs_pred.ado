*! version 1.3 13Jan2016


program strcs_pred
	version 13.1
	syntax newvarname [if] [in], [	Survival 									///
									Hazard 										///
									CUMHazard									///
									XB 											///
									XBNOBaseline 								///
									HRNumerator(string) HRDenominator(string) 	///
									AT(string) ZEROs 							///
									noOFFset 									///
									SDIFF1(string) SDIFF2(string) 				///
									HDIFF1(string) HDIFF2(string) 				///
									CI LEVel(real `c(level)') 					///
									TIMEvar(varname) 							///
									STDP 										///
									NODes(integer 30)							///
									PER(real 1)  								///
									HRSCALE(integer 1)							///
								]	
	marksample touse, novarlist
	local newvarname `varlist'
	qui count if `touse'
	if r(N)==0 {
		error 2000          /* no observations */
	}

	if "`hrdenominator'" != "" & "`hrnumerator'" == "" {
		display as error "You must specifiy the hrnumerator option if you specifiy the hrdenominator option"
		exit 198
	}

	if "`sdiff2'" != "" & "`sdiff1'" == "" {
		display as error "You must specifiy the sdiff1 option if you specifiy the sdiff2 option"
		exit 198
	}

	if "`hdiff2'" != "" & "`hdiff1'" == "" {
		display as error "You must specifiy the hdiff1 option if you specifiy the hdiff2 option"
		exit 198
	}

	local hratiotmp = substr("`hrnumerator'",1,1)
	local sdifftmp = substr("`sdiff1'",1,1)
	local hdifftmp = substr("`hdiff1'",1,1)
	if wordcount(`"`survival' `hazard' `meansurv' `hratiotmp' `sdifftmp' `hdifftmp' `xb' `xbnobaseline' `cumhazard'"') > 1 {
		display as error "You have specified more than one option for predict"
		exit 198
	}
	if wordcount(`"`survival' `hazard' `meansurv' `hrnumerator' `sdiff1'  `hdifftmp' `xb' `xbnobaseline' `cumhazard'"') == 0 {
		display as error "You must specify one of the predict options"
		exit 198
	}
	
	if `per' != 1 & "`hazard'" == "" & "`hdiff1'" == "" {
		display as error "You can only use the per() option in combinaton with the hazard or hdiff1()/hdiff2() options."
		exit 198		
	}

	if "`stdp'" != "" & "`ci'" != "" {
		display as error "You can not specify both the ci and stdp options."
		exit 19
	}
** CHECK STDP OPTION **
** CHECK CI OPTION **

	if "`zeros'" != "" & ("`hrnumerator'" != "" | "`hdiff1'" != "" | "`sdiff1'" != "") {
		display as error "You can not specify the zero option with the hrnumerator, hdiff or sdiff options."
		exit 198
	}
	if "`at'" != "" & "`hrnumerator'" != "" {
		display as error "You can not use the at option with the hrnumerator option"
		exit 198
	}

	if "`at'" != "" & "`sdiff1'" != "" {
		display as error "You can not use the at option with the sdiff1 and sdiff2 options"
		exit 198
	}
	
	if "`at'" != "" & "`hdiff1'" != "" {
		display as error "You can not use the at option with the hdiff1 and hdiff2 options"
		exit 198
	}

/* store time-dependent effects and main varlist */
	local etvc `e(tvc)'
	local main_varlist `e(varlist)'

/* Use _t or ln(_t) if option timevar not specified */
	tempvar t lnt timescale
	if "`timevar'" == "" {
		local timevar _t
		qui gen double `timescale' = cond("`e(bhtime)'"=="",ln(_t),_t) if `touse'
	}
	else {
		local usertimevar usertimevar
		qui gen double `timescale' = cond("`e(bhtime)'"=="",ln(`timevar'),`timevar') if `touse'
		summ `timevar', meanonly
	}

/* Check to see if nonconstant option used */
	if "`e(noconstant)'" == "" {
		tempvar cons
		qui gen `cons' = 1 if `touse'
	}	
/* Preserve data for out of sample prediction  */	
	tempfile newvars 
	preserve

	if "`e(orthog)'" != "" {
		tempname rmatrix
		matrix `rmatrix' = e(R_bh)
		local rmatrixopt rmatrix(`rmatrix')
		foreach tvcvar in `e(tvc)' {
			tempname rmatrix_`tvcvar'
			matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
			local rmatrixopt_`tvcvar' rmatrix(`rmatrix_`tvcvar'')
		}
	}
	
	
	
/* Calculate new spline terms if timevar option specified */
	if "`timevar'" != "" {
		capture drop __s* 
		qui rcsgen `timescale' if `touse', knots(`e(bhknots)') gen(__s) `rmatrixopt' `e(reverse)'
	}

/* calculate new tvc spline terms if timevar option or hrnumerator option is specified */

	if "`timevar'" != "" | "`hrnumerator'" != "" | "`sdiff1'" != "" | "`hdiff1'" != "" {
		foreach tvcvar in `e(tvc)' {
			if (("`hrnumerator'" != "" | "`sdiff1'" != "" | "`hdiff1'" != "") & "`timevar'" == "") | "`e(rcsbaseoff)'" != "" {
				capture drop __s_`tvcvar'* 
			}
			qui rcsgen `timescale' if `touse',  gen(__s_`tvcvar') knots(`e(tvcknots_`tvcvar')') `rmatrixopt_`tvcvar'' `e(reverse)'
			if "`hrnumerator'" == "" & "`sdiff1'"  == "" & "`hdiff1'" == "" {
				forvalues i = 1/`e(df_`tvcvar')'{
					qui replace __s_`tvcvar'`i' = __s_`tvcvar'`i'*`tvcvar' if `touse'
				}
			}
		}
	}	
	
/* zeros */
	if "`zeros'" != "" {
		local tmptvc `e(tvc)'
		foreach var in `e(varlist)' {
			_ms_parse_parts `var'
			if `"`: list posof `"`r(name)'"' in at'"' == "0" { 
				qui replace `r(name)' = 0 if `touse'
				if `"`: list posof `"`r(name)'"' in tmptvc'"' != "0" { 
				forvalues i = 1/`e(df_`r(name)')' {
						qui replace __s_`r(name)'`i' = 0 if `touse'
					}
				}
			}
		}
	}

/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			fvunab tmpfv: `1'
			local 1 `tmpfv'
			_ms_parse_parts `1'
			if "`r(type)'"!="variable" {
				display as error "level indicators of factor" /*
								*/ " variables may not be individually set" /*
								*/ " with the at() option; set one value" /*
								*/ " for the entire factor variable"
				exit 198
			}
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di as err "invalid at(... `1' `2' ...)"
					exit 198
				}
			}
			qui replace `1' = `2' if `touse'
			if `"`: list posof `"`1'"' in etvc'"' != "0" {
				local tvcvar `1'
				if "`e(orthog)'" != "" {
					tempname rmatrix_`tvcvar'
					matrix `rmatrix_`tvcvar'' = e(R_`tvcvar')
					local rmatrixopt_`tvcvar' rmatrix(`rmatrix_`tvcvar'')
				}
				capture drop __s_`tvcvar'* 
				qui rcsgen `timescale' if `touse', knots(`e(tvcknots_`tvcvar')') gen(__s_`tvcvar') `rmatrixopt_`tvcvar'' `e(reverse)'
				forvalues i = 1/`e(df_`tvcvar')'{
					qui replace __s_`tvcvar'`i' = __s_`tvcvar'`i'*`tvcvar' if `touse'
				}
			}
			mac shift 2
		}
	}

/* Add offset term if exists unless no offset option is specified */
	if "`e(offset2)'" !=  "" &  "`offset'" != "nooffset" {
		local addoff "+ `e(offset2)'" 
	}

/*****************************
** predict linear predictor **
** (including baseline)     **
*****************************/
if "`e(k_eq)'" == "1" {
	local xb_eq 
}
else if "`e(k_eq)'" == "2" {
	local xb_eq  + xb(xb)
}

if "`xb'" != "" {

	qui predictnl double `newvarname' = xb(rcs) `xb_eq' `addoff'  if `touse', ///
		ci(`newvarname'_lci `newvarname'_uci)

}
	
/*****************************
** predict linear predictor **
** (excluding baseline)     **
*****************************/
if "`xbnobaseline'" != "" {
	qui predictnl double `newvarname' = xb(xb) `addoff'  if `touse', ///
		ci(`newvarname'_lci `newvarname'_uci)
}

/******************************
** predict cumulative hazard **
******************************/
if "`cumhazard'" != "" {
		tempvar tousesurv
		tempname kweights knodes
		local Ntime `r(N)'
		qui gen `tousesurv' = !missing(`timescale')

/* Quadrature Points */
		tempname kweights knodes
		gaussquad, n(`nodes') leg
		matrix `kweights' = r(weights)'
		matrix `knodes' = r(nodes)'

		/* splines */
		qui gen double __tmpnode = .
		if "`e(tvc)'" != "" {
			qui gen double __tmptvcgen = .
			qui gen double __tmpnodetvc = .
		}

		tempvar lowt includefirstint includesecondint hight includethirdint ln_hight ln_lowt lowerb upperb

		local firstknot = `e(minknot)'
		local lastknot = `e(maxknot)'

		qui gen double `lowt' = cond(`timevar'>=`firstknot',`firstknot',`timevar') if `tousesurv'

		qui gen double `lowerb' = `lowt' if `tousesurv'
		qui gen double `upperb' = cond(`timevar'>=`lastknot',`lastknot',`timevar') if `tousesurv'

		qui gen double `hight' = `lastknot' if `tousesurv'
		qui gen byte `includefirstint' = 1 if `tousesurv'
		qui gen byte `includesecondint' = (`timevar'>`firstknot') if `tousesurv'
		qui gen byte `includethirdint' = `timevar'>`hight' if `tousesurv'

// needed for calculation of slope after last knot
		if "`bhtime'" == "" {
			qui gen double `ln_hight' = ln(`hight') if `touse'
			qui gen double `ln_lowt' = ln(`lowt') if `touse'
		}
	
		tempname ch 
		qui mata: cumhazpred("`tousesurv'")
		qui gen double `newvarname' = `ch'
		
		if "`ci'" != "" {
			foreach opt in timevar at {
				if "`opt'" != "" {
					local `opt'opt `opt'(``opt'')
				}
			}
			tempvar tempch
			cap drop __tmptvcgen
			qui predictnl `tempch' = predict(cumhazard nodes(`nodes') `timevaropt' `atopt') if `touse', ci(`newvarname'_lci `newvarname'_uci) force
		}
}

/****************************
** predict hazard function **
****************************/
	if "`hazard'" != "" {
		tempvar lnh 
		if "`ci'" != "" {
			tempvar lnh_lci lnh_uci
			local prednlopt ci(`lnh_lci' `lnh_uci')
		}
		qui predictnl double `lnh' = xb(rcs) `xb_eq' `addoff'  if `touse', `prednlopt' 

/* Transform back to hazard scale */
		qui gen double `newvarname' = exp(`lnh')*`per' if `touse'
		if "`ci'" != "" {
			qui gen `newvarname'_lci = exp(`lnh_lci')*`per'  if `touse'
			qui gen `newvarname'_uci =  exp(`lnh_uci')*`per' if `touse'
		}
	}

/*********************
** predict survival **
*********************/
	if "`survival'" != "" {
		foreach opt in timevar at {
			if "`opt'" != "" {
					local `opt'opt `opt'(``opt'')
				}
		}
		if "`ci'" == "" {
			tempname ch 
			qui predict `ch' if `touse', cumhazard nodes(`nodes') `timevaropt' `atopt'

			qui gen double `newvarname' = exp(-`ch') if `touse'
		}
		else if "`ci'" != "" {
			tempname ch ch_lci ch_uci 
			qui predictnl `ch' = predict(cumhazard nodes(`nodes') `timevaropt' `atopt') if `touse', ci(`ch_lci' `ch_uci') force
			qui gen double `newvarname' = exp(-`ch')
			qui gen double `newvarname'_lci = exp(-`ch_uci')
			qui gen double `newvarname'_uci = exp(-`ch_lci')
		}
	}	
	
/*************************
** predict hazard ratio **
*************************/

	
if "`hrnumerator'" != "" {
	tempvar lhr lhr_lci lhr_uci
	if "`timevar'" != "" {
		local addtimevar timevar(`timevar')
	}
	if "`hrdemoninator'" != "" {
		local addat2 at(`hrdenominator')
	}
	if "`ci'" != "" {
		local addci ci(`lhr_lci' `lhr_uci')
	}
	qui predictnl double `lhr' = `hrscale'* ( predict(xb at(`hrnumerator') `addtimevar' zeros)- predict(xb at(`hrdenominator') `addtimevar' zeros) ) if `touse', `addci' force iter(300)
	gen double `newvarname' = exp(`lhr'/`hrscale')
	if "`ci'" != "" {
		gen double `newvarname'_lci = exp(`lhr_lci'/`hrscale')
		gen double `newvarname'_uci = exp(`lhr_uci'/`hrscale')
	}
}


/******************************
** predict hazard difference **
******************************/
******************************/
	if "`hdiff1'" != "" {
		if "`timevar'" != "" {
			local addtimevar timevar(`timevar')
		}
		if "`hdiff2'" != "" {
			local addat2 at(`hdiff2')
		}
		if "`ci'" != "" {
			local addci ci(`newvarname'_lci `newvarname'_uci) 
		}
		qui predictnl double `newvarname' = predict(hazard at(`hdiff1') `addtimevar' zeros) - predict(hazard `addtimevar' `addat2' zeros) if `touse', `addci' force
	
	}
/********************************
** predict survival difference **
********************************/
	if "`sdiff1'" != "" {
		if "`timevar'" != "" {
			local addtimevar timevar(`timevar')
		}
		if "`sdiff2'" != "" {
			local addat2 at(`sdiff2')
		}
		if "`ci'" != "" {
			local addci ci(`newvarname'_lci `newvarname'_uci) 
		}
		qui predictnl `newvarname' = predict(survival at(`sdiff1') `addtimevar' zeros) - predict(survival `addtimevar' `addat2' zeros) if `touse', `addci' force
	}
/*****************************************************
** restore original data and merge in new variables **
*****************************************************/
	local keep `newvarname'
	if "`ci'" != "" { 
		local keep `keep' `newvarname'_lci `newvarname'_uci
	}
	else if "`stdp'" != "" {
		local keep `keep' `newvarname'_se 
	}
	keep `keep'
	tempfile newvars
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport	
end

mata:
	void cumhazpred(string scalar tousesurv)							// touse survival time

{
	t = st_data(., st_local("timevar"),tousesurv)

	lowt = st_data(., st_local("lowt"),tousesurv)
	hight = st_data(., st_local("hight"),tousesurv)
	upperb = st_data(., st_local("upperb"),tousesurv)
	lowerb = st_data(., st_local("lowerb"),tousesurv)
	includefirstint = st_data(., st_local("includefirstint"),tousesurv)
	includesecondint = st_data(., st_local("includesecondint"),tousesurv)
	includethirdint = st_data(., st_local("includethirdint"),tousesurv)
	Nobs = rows(t)
	
	
	hastvc = st_global("e(tvc)") != ""

	if (hastvc) {
		tvclist = tokens(st_global("e(tvc)"))
		Ntvc = cols(tvclist)
		tvc_df = J(1,Ntvc,.)
		rcstvcname = J(1,Ntvc,"") 
		drcstvcname = J(1,Ntvc,"") 
		for(j=1;j<=Ntvc;j++) {
			tvc_df[1,j] = st_numscalar("e(df_"+tvclist[1,j]+")") 
			rcstvcname[1,j] = "__rcs_"+tvclist[j] 
			drcstvcname[1,j] = "__drcs_"+tvclist[j] 
		}
		
	} 

	if(st_global("e(nocons)") != "") cons=J(Nobs,0,.)
	else cons = J(Nobs,1,1)

	if(st_local("addoff") != "") st_view(offset,.,st_global("e(offset2)"),tousesurv)
	else offset = J(Nobs,1,0) 

	minknot = st_numscalar("e(minknot)")
	maxknot = st_numscalar("e(maxknot)")
	
	bhtime = st_global("e(bhtime)") != ""
	
	weights = J(Nobs,1,st_matrix(st_local("kweights"))):*(upperb :- lowerb):/2
	Nnodes = strtoreal(st_local("nodes"))
	knodes = st_matrix(st_local("knodes"))	
	nodes = asarray_create("real",1)
	


	st_view(tmpnode,.,"__tmpnode",tousesurv)
	

	for(i=1;i<=Nnodes;i++) {	
		tmpnode_i = (0.5:*(upperb :- lowerb):*knodes[1,i] :+ 0.5:*(upperb :+ lowerb)) 

		if (bhtime) tmpnode[,] = tmpnode_i
		else tmpnode[,] = ln(tmpnode_i)

		stata("qui rcsgen __tmpnode if " + tousesurv +", gen(__rcs) knots("+st_global("e(bhknots)")+") " + st_local("rmatrixopt")+ " " + st_global("e(reverse)")) 

		if (hastvc) {
			st_view(tmptvcgen,.,"__tmptvcgen",tousesurv)
			st_view(tmpnodetvc,.,"__tmpnodetvc",tousesurv)

			for(j=1;j<=Ntvc;j++) {
				if (bhtime) tmpnodetvc[,] = tmpnode_i 
				else tmpnodetvc[,] = ln(tmpnode_i) 
					stata("qui rcsgen __tmpnodetvc if " + tousesurv +", gen(__rcs_"+tvclist[j]+") knots("+st_global("e(tvcknots_"+tvclist[j]+")")+") " + st_local("rmatrixopt_"+tvclist[j]) + " " + st_global("e(reverse)")) 
				for(k=1;k<=tvc_df[1,j];k++) {
					stata("qui replace "+rcstvcname[1,j]+strofreal(k)+" =" +rcstvcname[1,j]+strofreal(k)+"*"+tvclist[j]+" if "+tousesurv)
				}
			}
		}

		asarray(nodes,i,(st_data(.,tokens("__rcs*"),tousesurv),cons))
		stata("capture drop __rcs* ")
		
	}

	stata("capture drop __tmpnode*")
	stata("capture drop __rcs*")
	stata("capture drop __drcs*")
	stata("capture drop __tmptvcgen")

// spline at lowt
	rcsfirstknot = asarray_create("real",1) // 1 - splines, 2 - derivatives
	if (bhtime)  stata("qui rcsgen " + st_local("lowt") + " if " + tousesurv +", gen(__rcs) dgen(__drcs) knots("+st_global("e(bhknots)")+") " + st_local("rmatrixopt")+ " " + st_global("e(reverse)")) 
	else stata("qui rcsgen " + st_local("ln_lowt") + " if " + tousesurv +", gen(__rcs) dgen(__drcs) knots("+st_global("e(bhknots)")+") " + st_local("rmatrixopt")+ " " + st_global("e(reverse)"))

	if (hastvc) {
		stata("qui cap drop __tmptvcgen")
		stata("qui gen double __tmptvcgen = .")
		st_view(tmptvcgen,.,"__tmptvcgen",tousesurv)
		for(j=1;j<=Ntvc;j++) {
			if (bhtime) tmptvcgen[,] = lowt 
			else tmptvcgen[,] = ln(lowt) 
			stata("qui rcsgen __tmptvcgen if " + tousesurv +", gen(__rcs_" + tvclist[j]+") dgen(__drcs_" + tvclist[j]+") knots("+st_global("e(tvcknots_"+tvclist[j]+")")+") " + st_local("rmatrixopt_"+tvclist[j]) + " " + st_global("e(reverse)")) 
			for(k=1;k<=tvc_df[1,j];k++) {

				stata("qui replace "+rcstvcname[1,j]+strofreal(k)+" =" +rcstvcname[j]+strofreal(k)+"*"+tvclist[j]+" if "+tousesurv)
				stata("qui replace "+drcstvcname[1,j]+strofreal(k)+" =" +drcstvcname[j]+strofreal(k)+"*"+tvclist[j]+" if "+tousesurv)
			}
		}
	}
	asarray(rcsfirstknot,1,(st_data(.,"__rcs*",tousesurv),cons))
	asarray(rcsfirstknot,2,(st_data(.,"__drcs*",tousesurv),J(Nobs,1,0)))
	stata("capture drop __rcs*")
	stata("capture drop __drcs*")

// spline at hight
	rcslastknot = asarray_create("real",1) // 1 - splines, 2 - derivatives
	
	if (bhtime)  stata("qui rcsgen " + st_local("hight") + " if " + tousesurv +", gen(__rcs) dgen(__drcs) knots("+st_global("e(bhknots)")+") " + st_local("rmatrixopt") + " " + st_global("e(reverse)"))
	else stata("qui rcsgen " + st_local("ln_hight") + " if " + tousesurv +", gen(__rcs) dgen(__drcs) knots("+st_global("e(bhknots)")+") " + st_local("rmatrixopt")+ " " + st_global("e(reverse)"))

	if (hastvc) {
		st_view(tmptvcgen,.,"__tmptvcgen",tousesurv)
		for(j=1;j<=Ntvc;j++) {
			if (bhtime) tmptvcgen[,] = hight 
			else tmptvcgen[,] = ln(hight) 
			
			stata("qui rcsgen __tmptvcgen if " + tousesurv +", gen(__rcs_" + tvclist[j]+") dgen(__drcs_" + tvclist[j]+") knots("+st_global("e(tvcknots_"+tvclist[j]+")")+") " + st_local("rmatrixopt_"+tvclist[j])+ " " + st_global("e(reverse)") )

			for(k=1;k<=tvc_df[1,j];k++) {

				stata("qui replace "+rcstvcname[1,j]+strofreal(k)+" =" +rcstvcname[j]+strofreal(k)+"*"+tvclist[j]+" if "+tousesurv)
				stata("qui replace "+drcstvcname[1,j]+strofreal(k)+" =" +drcstvcname[j]+strofreal(k)+"*"+tvclist[j]+" if "+tousesurv)
			}
		}
	}
	asarray(rcslastknot,1,(st_data(.,"__rcs*",tousesurv),cons))
	asarray(rcslastknot,2,(st_data(.,"__drcs*",tousesurv),J(Nobs,1,0)))
	stata("capture drop __rcs*")
	stata("capture drop __drcs*")	
	
//	beta matrix (deal with omitted variables???)
	beta = st_matrix("e(b)")
	Nxb = cols(tokens(st_global("e(varlist)")))
	rcsbeta = beta[(Nxb+1)..cols(beta)]
	if(Nxb>0) {
		xbbeta = beta[1..Nxb]
		X = st_data(.,tokens(st_global("e(varlist)")),tousesurv)
		xb = X*xbbeta' :+ offset
	}
	else {
		xb = 0
	}

// before the first knot
	b0 =  (asarray(rcsfirstknot,1) * rcsbeta') :+ xb
	b1 = (asarray(rcsfirstknot,2) * rcsbeta') 
	if (bhtime) b0 = b0 :- b1:*lowt
	else b0 = b0 :- b1:*ln(lowt)	
	

// intercept and gradient after last knot
	b0_last = (asarray(rcslastknot,1) * rcsbeta') :+ xb
	b1_last = (asarray(rcslastknot,2) * rcsbeta') 
	if (bhtime) b0_last = b0_last :- b1_last:*hight
	else b0_last = b0_last :- b1_last:*ln(hight)


	if (bhtime) cumhazard = (exp(b0):/b1:*(exp(b1:*lowt) :- 1)):*(includefirstint)
	else cumhazard = (exp(b0):/ (b1:+1):*(lowt:^(b1:+1))):*(includefirstint)


	//cumhazard[1..10,]
	for(j=1;j<=Nnodes;j++) {
		cumhazard = cumhazard :+ (weights[,j]:*exp((asarray(nodes, j)*rcsbeta' :+ xb))):*(includesecondint)
		//(t,cumhazard ,weights[,j],exp((asarray(nodes, j)*rcsbeta' :+ xb)),includesecondint)[1..10,]	
	}
	

	if (bhtime) cumhazard = cumhazard :+ (exp(b0_last):/b1_last:*(exp(b1_last:*t) :- exp(b1_last:*hight))):*(includethirdint)
	else	cumhazard = cumhazard :+ (exp(b0_last):/ (b1_last:+1):*(t:^(b1_last:+1) :- (hight):^(b1_last:+1))):*(includethirdint)	

	
	
	(void) st_addvar("double",st_local("ch"))       
	st_store(., st_local("ch"), tousesurv,cumhazard)
}
end




*********************************
* Gaussian quadrature 

program define gaussquad, rclass
	syntax [, N(integer -99) LEGendre CHEB1 CHEB2 HERmite JACobi LAGuerre alpha(real 0) beta(real 0)]
	
    if `n' < 0 {
        display as err "need non-negative number of nodes"
		exit 198
	}
	if wordcount(`"`legendre' `cheb1' `cheb2' `hermite' `jacobi' `laguerre'"') > 1 {
		display as error "You have specified more than one integration option"
		exit 198
	}
	local inttype `legendre'`cheb1'`cheb2'`hermite'`jacobi'`laguerre' 
	if "`inttype'" == "" {
		display as error "You must specify one of the integration type options"
		exit 198
	}

	tempname weights nodes
	mata gq("`weights'","`nodes'")
	return matrix weights = `weights'
	return matrix nodes = `nodes'
end

mata:
	void gq(string scalar weightsname, string scalar nodesname)
{
	n =  strtoreal(st_local("n"))
	inttype = st_local("inttype")
	i = range(1,n,1)'
	i1 = range(1,n-1,1)'
	alpha = strtoreal(st_local("alpha"))
	beta = strtoreal(st_local("beta"))
		
	if(inttype == "legendre") {
		muzero = 2
		a = J(1,n,0)
		b = i1:/sqrt(4 :* i1:^2 :- 1)
	}
	else if(inttype == "cheb1") {
		muzero = pi()
		a = J(1,n,0)
		b = J(1,n-1,0.5)
		b[1] = sqrt(0.5)
    }
	else if(inttype == "cheb2") {
		muzero = pi()/2
		a = J(1,n,0)
		b = J(1,n-1,0.5)
	}
	else if(inttype == "hermite") {
		muzero = sqrt(pi())
		a = J(1,n,0)
		b = sqrt(i1:/2)
	}
	else if(inttype == "jacobi") {
		ab = alpha + beta
		muzero = 2:^(ab :+ 1) :* gamma(alpha :+ 1) * gamma(beta :+ 1):/gamma(ab :+ 2)
		a = i
		a[1] = (beta - alpha):/(ab :+ 2)
		i2 = range(2,n,1)'
		abi = ab :+ (2 :* i2)
		a[i2] = (beta:^2 :- alpha^2):/(abi :- 2):/abi
		b = i1
        b[1] = sqrt(4 * (alpha + 1) * (beta + 1):/(ab :+ 2):^2:/(ab :+ 3))
        i2 = i1[2..n-1]
        abi = ab :+ 2 :* i2
        b[i2] = sqrt(4 :* i2 :* (i2 :+ alpha) :* (i2 :+ beta) :* (i2 :+ ab):/(abi:^2 :- 1):/abi:^2)
	}
	else if(inttype == "laguerre") {
		a = 2 :* i :- 1 :+ alpha
		b = sqrt(i1 :* (i1 :+ alpha))
		muzero = gamma(alpha :+ 1)
    }

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
