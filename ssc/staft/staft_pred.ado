*! version 0.1.0 23jun2017 MJC

/*
History
MJC 27jun2017: version 0.1.2 - af prediction fixed for tvcs
MJC 26jun2017: version 0.1.1 - bug fix for xb prediction
MJC 23jun2017: version 0.1.0
*/

/*
Notes
-> check intercept when calculating standard error
-> add variable labels
*/

/*
To add
-> afnum() and afdenom() options
*/


program staft_pred
	version 12.1
	syntax newvarname [if] [in], 	[									///
										XB								///
										Hazard 							///
										CUMHazard						///
										Survival						///
										AF								///
										AFNUM(string)					/// -not documented-
										AFDENOM(string)					/// -not documented-
																		///
										CI 								///
										STDP							///
										Level(cilevel) 					///
										TIMEvar(varname) 				///
										AT(string)						///
										ZEROS							///
																		///
									]

		marksample touse, novarlist
		local newvarname `varlist'
		qui count if `touse'
		local nobs = `r(N)'
		if `nobs'==0 {
			error 2000
		}

		if wordcount(`"`xb' `af' `hazard' `cumhazard' `survival' `failure' `afnum'"')<1 {
			di as error "You must specify one of the predict options"
			exit 198
		}
		if wordcount(`"`xb' `af' `hazard' `cumhazard' `survival' `failure' `afnum'"')>1 {
			di as error "You have specified more than one prediction option"
			exit 198
		}
		
		if "`afdenom'"!="" & "`afnum'"=="" {
			di as error "afnum() needed with afdenom()"
			exit 198
		}
		
		if "`afnum'"!="" & "`at'"!="" {
			di as error "Can't use both afnum() and at()"
			exit 198
		}
		
		//Preserve data for out of sample prediction
		tempfile newvars 
		preserve	
	
		//Baseline predictions
		if "`zeros'"!="" {
			foreach var in `e(varlist)' `e(tvc)' {
				if `"`: list posof `"`var'"' in at'"' == "0" { 
					qui replace `var' = 0 if `touse'
				}
			}
		}	
	
		//Out of sample predictions using at()
		if "`at'" != "" {
			tokenize `at'
			while "`1'"!="" {
				unab 1: `1'
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di in red "invalid at(... `1' `2' ...)"
						exit 198
					}
				}
				qui replace `1' = `2' if `touse'
				mac shift 2
			}
		}	
	
		//CI option
		if "`ci'"!="" {
			local ciopt "ci(`newvarname'_lci `newvarname'_uci)"
		}
		
		if "`stdp'"!="" {
			local ciopt "se(`newvarname'_se)"
		}
	
	//====================================================================================================================================================//
	// Rebuild variables and time-dep effects etc.
			
		tempvar t
		if "`timevar'"!="" {
			gen double `t' = `timevar' if `touse'
		}
		else {
			gen double `t' = _t if `touse'
		}
		
		//need linear predictor, before rcsgen call for splines
		
		if "`e(tvc)'"!="" {
			tempvar lnt
			gen double `lnt' = log(`t') if `touse'
		
			//rebuild tvc splines first
			foreach tvcvar in `e(tvc)' {
				local ln_tvcknots_`tvcvar' `e(ln_tvcknots_`tvcvar')'
				if "`ln_tvcknots_`tvcvar''"=="" {
					local ln_lowerknot = log(`: word 1 of `e(boundary_knots_`tvcvar')'')
					local ln_upperknot = log(`: word 2 of `e(boundary_knots_`tvcvar')'')
					local ln_tvcknots_`tvcvar' `ln_lowerknot' `ln_upperknot'
				}
				
				if "`e(noorthog)'"=="" {
					tempname rmatrix_`tvcvar'
					mat `rmatrix_`tvcvar'' = e(R_`tvcvar')
					local rmat_`tvcvar' rmatrix(`rmatrix_`tvcvar'')
				}
				
				cap drop _rcs_`tvcvar'* _d_rcs_`tvcvar'*
				qui rcsgen `lnt', gen(_rcs_`tvcvar') dgen(_d_rcs_`tvcvar') knots(`ln_tvcknots_`tvcvar'') `rmat_`tvcvar''
				
				local df_`tvcvar' = `: word count `ln_tvcknots_`tvcvar''' - 1
				forvalues i=1/`df_`tvcvar'' {
					qui replace _rcs_`tvcvar'`i' = _rcs_`tvcvar'`i' * `tvcvar'
					qui replace _d_rcs_`tvcvar'`i' = _d_rcs_`tvcvar'`i' * `tvcvar'
				}
				
			}
					
		}
		
		//splines calculated on log(t*exp(-xb))
		//if linear predictor (xb) then don't need main splines
		if "`xb'"=="" & "`af'"=="" {										
			tempvar lntxb	
			predictnl double `lntxb' = log(`t' * exp(-xb(xb))) if `touse'
			
			//Calculate core splines
			local ln_bknots `e(ln_bknots)'
			local Nsplines : word count `e(rcsterms)'
			if "`e(noorthog)'"=="" {
				tempname rmat
				mat `rmat' = e(R)
				local rmatrix rmatrix(`rmat')
			}		
		
			forvalues i=1/`Nsplines' {
				cap drop _rcs`i'
				cap drop _d_rcs`i'
			}
			qui rcsgen `lntxb' if `touse', gen(_rcs) dgen(_d_rcs) knots(`ln_bknots') `rmatrix'
			
			if "`hazard'"!="" & ("`ci'"!="" | "`stdp'"!="") {
				//need d2splines
				rcsgen2 `lntxb' if `touse', gen(_d2_rcs) knots(`ln_bknots') `rmatrix'
				local d2rcslist `r(d2rcslist)'
			}
		}
	
	//====================================================================================================================================================//
	// Linear predictor or AF
	
		if "`xb'"!="" {
			predictnl double `newvarname' = xb(xb) if `touse', `ciopt'
		}
		
		if "`af'"!="" {
			if "`e(tvc)'"=="" {
				predictnl double `newvarname' = -xb(xb) if `touse', `ciopt'
			}
			else {
				predictnl double `newvarname' = -xb(xb) + log(1-xb(dxb)) if `touse', `ciopt'
			}
		}
	
	//====================================================================================================================================================//
	// afnum and afdenom
	
		if "`afnum'"!="" {
		
			if "`afdenom'"=="" {
				predictnl double `newvarname' = predict(af at(`afnum') timevar(`t'))/predict(af zeros timevar(`t')) if `touse', `ciopt'
			}	
			else {
				predictnl double `newvarname' = predict(af at(`afnum') timevar(`t'))/predict(af at(`afdenom') timevar(`t')) if `touse', `ciopt'
			}
		
		}	
		
	
	//====================================================================================================================================================//
	// Hazard function
	
		if "`hazard'"!="" {
			
			local Nsplines : word count `e(rcsterms)'
			local linpred xb(cons)
			local linpred2 0
			local dxbpred 0
			forvalues i=1/`Nsplines' {
				local linpred `linpred' + xb(rcs`i')*_rcs`i'
				local linpred2 `linpred2' + xb(rcs`i')*_d_rcs`i'
			}
			if "`e(tvc)'"!="" {
				local dxbpred xb(dxb)
			}
			//log hazard

			predictnl double `newvarname' = `linpred' + log(`linpred2') - log(`t') + log(`dxbpred' + 1) if `touse'
			
			if "`ci'"!="" | "`stdp'"!="" {
				tempvar se
				qui gen double `se' = .
				qui count if `touse'==1 
				local Nobs = r(N)
				tempname emat ematxb
				mat `emat' = e(b) 
				mat `ematxb' = `emat'[1,"xb:"]
								
				if "`e(tvc)'"!="" {
				
					tempvar tvcdxb
					predictnl double `tvcdxb' = xb(dxb) if `touse'
				
					local Nsplines : word count `e(rcsterms)'
					local Ntvcparams = 0
					foreach var in `e(tvc)' {
						local Ntvcparams = `Ntvcparams' + `: word count `e(drcsterms_`var')''
						local tvcvars `tvcvars' `e(rcsterms_`var')'
					}
				}
							
				mata: staft_pred_get_se_logh()
				
				if "`ci'"!="" {
					local siglev = abs(invnormal((100-`level')/200)) 
					tempvar surv_lci surv_uci
					gen double `newvarname'_lci = `newvarname' - `siglev'*`se'
					gen double `newvarname'_uci = `newvarname' + `siglev'*`se'
				}
				else gen double `newvarname'_se = `se' if `touse'
			}
				
		}
	
	//====================================================================================================================================================//
	// Cumulative hazard function and survival
	
		if ("`cumhazard'"!="" | "`survival'"!="") {
		
			local Nsplines : word count `e(rcsterms)'
			local linpred xb(cons)
			forvalues i=1/`Nsplines' {
				local linpred `linpred' + xb(rcs`i')*_rcs`i'
			}
			//log cumhazard or log(-log(survival))
			qui predictnl double `newvarname' = `linpred' if `touse'
			
			if "`ci'"!="" | "`stdp'"!="" {
				tempvar se
				qui gen double `se' = .
				qui count if `touse'==1 
				local Nobs = r(N)
				tempname emat ematxb
				mat `emat' = e(b) 
				mat `ematxb' = `emat'[1,"xb:"]
				
				if "`e(tvc)'"!="" {
					local Nsplines : word count `e(rcsterms)'
					local Ntvcparams = 0
					foreach var in `e(tvc)' {
						local Ntvcparams = `Ntvcparams' + `: word count `e(drcsterms_`var')''
						local tvcvars `tvcvars' `e(rcsterms_`var')'
					}
				}
							
				mata: staft_pred_get_se_logch()
				
				if "`ci'"!="" {
					local siglev = abs(invnormal((100-`level')/200)) 
					if "`survival'"!="" {
						tempvar surv_lci surv_uci
						gen double `surv_lci' = `newvarname' - `siglev'*`se'
						gen double `surv_uci' = `newvarname' + `siglev'*`se'
					}
					else {
						gen double `newvarname'_lci = `newvarname' - `siglev'*`se'
						gen double `newvarname'_uci = `newvarname' + `siglev'*`se'					
					}
				}
				else gen double `newvarname'_se = `se' if `touse'
			}
		}
	
	//====================================================================================================================================================//
	// Restore original data and merge in new variables 
	
		if "`xb'`hazard'`cumhazard'`survival'`af'"!="" {
			local keep `newvarname'
		}
		if "`ci'" != "" { 
			if "`survival'"!="" {
				local keep `keep' `surv_lci' `surv_uci'
			}
			else {
				local keep `keep' `newvarname'_lci `newvarname'_uci 
			}
		}
		if "`stdp'"!="" {
			local keep `keep' `newvarname'_se
		}

		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport
		
		if ("`hazard'"!="" | "`cumhazard'"!="" | "`af'"!="") & "`stdp'"=="" {
			qui replace `newvarname' = exp(`newvarname')
			if "`ci'" != "" { 
				qui replace `newvarname'_lci = exp(`newvarname'_lci)
				qui replace `newvarname'_uci = exp(`newvarname'_uci)
			}
		}
		
		if "`survival'"!="" & "`stdp'"=="" {
			qui replace `newvarname' = exp(-exp(`newvarname'))
			if "`ci'" != "" { 
				qui gen double `newvarname'_lci = exp(-exp(`surv_uci'))
				qui gen double `newvarname'_uci = exp(-exp(`surv_lci'))
			}		
		}
	
end


mata:

//get standard error of log cumulative hazard for prediction using delta method
void staft_pred_get_se_logch() 
{
	betas = st_matrix("e(b)")'
	V= st_matrix("e(V)")	
	
	touse = st_local("touse")
	Nobs = strtoreal(st_local("Nobs"))
	covs = st_data(.,tokens(st_global("e(varlist)")),touse)	
	mainrcs = st_data(.,tokens(st_global("e(rcsterms)")),touse),J(Nobs,1,1)
	maindrcs = st_data(.,tokens(st_global("e(drcsterms)")),touse)
		
	Nparams = rows(betas)
	Ncovs = cols(st_matrix(st_local("ematxb")))			//includes tvc vars in xb

	//extract betas and V when tvcs
	if (st_global("e(tvc)")!="") {
		Nsplines = strtoreal(st_local("Nsplines")) + 1 		//+1 for intercept
		index = 1
		if (Ncovs>1) for (i=2;i<=Ncovs;i++) index = index,i		
		for (i=(Nparams-Nsplines+1);i<=Nparams;i++) index = index,i
		betas = betas[index,]
		V = V[index,index]
		Nparams = rows(betas)	
		covs = covs,st_data(.,tokens(st_local("tvcvars")),touse)
	}
	rcsbetas = betas[(Ncovs+1)..(Nparams-1),] //no intercept
	G = (maindrcs * rcsbetas :* (-covs)),mainrcs
	se = sqrt(quadrowsum((G*V):*G))
	st_store(.,st_local("se"),touse,se)
}

//get standard error of log hazard for prediction using delta method
void staft_pred_get_se_logh() 
{
	betas = st_matrix("e(b)")'
	V= st_matrix("e(V)")	
	
	touse = st_local("touse")
	Nobs = strtoreal(st_local("Nobs"))
	covs = st_data(.,tokens(st_global("e(varlist)")),touse)	
	mainrcs = st_data(.,tokens(st_global("e(rcsterms)")),touse),J(Nobs,1,1)
	maindrcs = st_data(.,tokens(st_global("e(drcsterms)")),touse)
	maind2rcs = st_data(.,tokens(st_local("d2rcslist")),touse)
	
	Nparams = rows(betas)
	Ncovsinxb = cols(st_matrix(st_local("ematxb")))			//includes tvc vars in xb
	if (st_global("e(tvc)")!="") {
		Nsplines = strtoreal(st_local("Nsplines")) + 1 		//+1 for intercept
		index = 1
		if (Ncovsinxb>1) for (i=2;i<=Ncovsinxb;i++) index = index,i		
		for (i=(Nparams-Nsplines)+1;i<=Nparams;i++) index = index,i
		betas = betas[index,]
		V = V[index,index]
		Nparams = rows(betas)	
	}

	rcsbetas = betas[(Ncovsinxb+1)..(Nparams-1),] //no intercept
	//covariates (non-tvcs)
	G = (maindrcs * rcsbetas :+ (maind2rcs * rcsbetas):/(maindrcs * rcsbetas)) :* (-covs) 

	//covariates (tvcs)
	if (st_global("e(tvc)")!="") {
		G = G,(G :+ (1:/(st_data(.,st_local("tvcdxb"),touse):+1)) :* st_data(.,tokens(st_local("tvcvars")),touse) )
	}

	//main splines
	G = G,(mainrcs :+ mainrcs:/(maindrcs * rcsbetas))

	se = sqrt(quadrowsum((G*V):*G))
	st_store(.,st_local("se"),touse,se)
}

end



