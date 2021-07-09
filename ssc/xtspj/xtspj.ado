// main caller
program define xtspj, eclass
	version 13.1
	syntax anything  [if] [in], MOdel(string) MEthod(string) [Level(real 95) *]
	
	quietly {
		// sanity check
		if "`method'"!="parm" & "`method'"!="like" & "`method'"!="none" {
			noisily display in red "option method incorrectly specified (should be 'parm', 'like', or 'none')"
			exit 198
		} 
		
		if ("`model'"=="regress") {
			noisily xtspjregress `anything' `if' `in', method(`method') level(`level') `options'
			ereturn local cmdline="xtspj `0'"
			ereturn local cmd="xtspj"	
			ereturn local model="`model'"
			exit
		}
		
		// deal with if and in
		tempvar touse
		if "`if'"=="" & "`in'"=="" {
			quietly generate `touse'=1
		}
		else {
			marksample touse
		}
				
		preserve
		keep if `touse'
		xtset
		restore
		
		if (r(gaps)==1) {
			noisily display in red "panel has gaps in some time series"
			exit 416
		}
		
		// gen consecutive N
		local groupvar=r(panelvar)
		tempvar N
		egen `N'=group(`groupvar') if `touse'
		
		capture xtspj`model'Initial `anything'
		
		if _rc==0 {
			local initialTheta=r(Theta)
			local initialAlpha=r(Alpha)
		}		
		else {
			local initialTheta="."
			local initialAlpha="."
		}
		
		capture xtspj`model'Varlist `anything'		
		
		if _rc==0 {
			local anything=r(equation)
		}
		else {
			capture ml model lf Test `anything'
			if _rc!=0 {
				preserve
				noisily ml model lf Test `anything'
				restore
			}
		}
	}	
	
	if "`method'"=="parm" {
		xtspj_parm `anything', model(`model') n(`N') initialTheta(`initialTheta') initialAlpha(`initialAlpha') touse(`touse') panelvar(`groupvar') `options'
	}
	else if "`method'"=="like" | "`method'"=="none" {
		xtspj_like `anything', method(`method') model(`model') n(`N') touse(`touse') initialTheta(`initialTheta') initialAlpha(`initialAlpha') panelvar(`groupvar') `options'
	}
	
	ereturn local cmdline="xtspj `0'"
	ereturn local cmd="xtspj"	
	ereturn local model="`model'"
	
	if e(empty)==0 {
		_prefix_display, level(`level')
	}
	else {
		mata: display("{text:note: the model has no covariates}")
	}
	
end

// estimation programs
program define xtspj_like, eclass
	syntax anything, method(string) model(string) n(string) touse(string) [nocoll initialTheta(string) initialAlpha(string) panelvar(string) ltol(real 1e-4) ptol(real 1e-4) MAXIter(real 100) DIAGnosis VERBose Alpha(namelist min=1 max=1)]
	
	if "`verbose'"=="" {
		local display="No"
	}
	else {
		local display="Yes"
	}
	
	if "`diagnosis'"=="" {
		local diagnosis="No"
	}
	else {
		local diagnosis="Yes"
	}
	
	if "`robust'"=="" {
		local robust="OIM"
	}
	else {
		local robust="Robust"
	}
	
	if "`method'"=="like" {
		local method="Objective"
	}
	else if "`method'"=="none" {
		local method="None"
	}
	
	if "`coll'"=="" {
		local coll="Yes"
	}
	else {
		local coll="No"
	}
		
	tempname handle
	tempname Model
	tempname XList
	tempname YList
	tempname b
	mata: `handle'=xtspjMaxiLike()
	
	mata: `handle'.Settings.LikeTol=`ltol'
	mata: `handle'.Settings.ThetaTol=`ptol'
	mata: `handle'.Settings.MaxIter=`maxiter'
	mata: `handle'.Settings.Diagnosis="`diagnosis'"
	mata: `handle'.Settings.Display="`display'"
	mata: `Model'=xtspj`model'()
	mata: `handle'.Prepare("`method'",&`Model',"`n'","`touse'","`anything'","`panelvar'","`coll'","`display'")
	mata: `handle'.LikeCaller.Estimator.VCEType="`robust'"
	mata: `handle'.SetEstimator(`initialTheta',`initialAlpha')
	mata: `handle'.Maximize()
	mata: `handle'.LikeCaller.Covariance(`ltol',`ptol',`maxiter')
	
	mata: `XList'="";`YList'=""
	mata: `handle'.LikeCaller.CreateVarlist(`XList',`YList')
	
	if "`alpha'"!="" {
		quietly generate `alpha'=.
		mata: `handle'.LikeCaller.Predict("alpha","`alpha'",`ltol',`ptol',`maxiter')
	}
	
	mata: `b'=.
	mata: `handle'.LikeCaller.GetEstimator(`b')
	mata: st_matrix("b",(`b')')
	mata: st_matrix("V",`handle'.LikeCaller.Estimator.Covariance)
	mata: st_local("Obs",strofreal(`handle'.LikeCaller.EffectiveNumOfObs))
	mata: st_local("HasDrop",`handle'.LikeCaller.HasDrop)
	mata: st_local("Converged",`handle'.LikeCaller.Estimator.Status)
	mata: st_numscalar("Likelihood",`handle'.LikeCaller.Evaluation.Likelihood*`handle'.LikeCaller.EffectiveNumOfObs)
	mata: st_local("x",`XList')
	mata: st_local("y",`YList')
	
	//local x=regexr("`x'","__[0-9]+","L.`y'")
	
	if colsof(b)>0 {
		mat colnames b=`x'
		mat colnames V=`x'
		mat rownames V=`x'
		ereturn post b V, findomitted depname("`y'") esample(`touse') obs(`Obs') 
		ereturn scalar empty=0
	} 
	else {
		ereturn scalar empty=1
		ereturn post, depname("`y'") esample(`touse') obs(`Obs') 
	}	
	
	if "`Converged'"=="Converged" {
		ereturn scalar converged=1
	}
	else {
		ereturn scalar converged=0
	}
	
	ereturn scalar ll=Likelihood
	
	if "`method'"=="Objective" {
		ereturn local method="like"
		ereturn local title="xtspj - `model' - Jackknifed log-likelihood"
	} 
	else if "`method'"=="None" {
		ereturn local method="none"
		ereturn local title="xtspj - `model' - ML"
	}
	
	ereturn local vce=lower("`robust'")
	mata: mata drop `handle' `Model' `XList' `YList' `b'
end

program define xtspj_parm, eclass
	syntax anything, model(string) n(string) touse(string) [nocoll initialTheta(string) initialAlpha(string) panelvar(string) ltol(real 1e-4) ptol(real 1e-4) MAXIter(real 100) DIAGnosis VERBose Alpha(namelist min=1 max=1)]
	
	if "`verbose'"=="" {
		local display="No"
	}
	else {
		local display="Yes"
	}
	
	if "`diagnosis'"=="" {
		local diagnosis="No"
	}
	else {
		local diagnosis="Yes"
	}
	
	if "`coll'"=="" {
		local coll="Yes"
	}
	else {
		local coll="No"
	}
	
	tempname handle
	tempname Model
	tempname XList
	tempname YList
	tempname b
	mata: `handle'=xtspjCorrector()
	mata: `Model'=xtspj`model'()
	mata: `handle'.Setup("Parameter",&`Model',"`n'","`touse'","`anything'","`panelvar'","`coll'","`display'")
	mata: `handle'.Parameter(`ltol',`ptol',`maxiter',"`display'","`diagnosis'",`initialTheta',`initialAlpha')
	mata: `handle'.Covariance(`ltol',`ptol',`maxiter')
	mata: `XList'="";`YList'=""
	mata: `handle'.CreateVarlist(`XList',`YList')
	
	if "`alpha'"!="" {
		quietly generate `alpha'=.
		mata: `handle'.Predict("alpha","`alpha'",`ltol',`ptol',`maxiter')
	}
	
	mata: `b'=.
	mata: `handle'.GetEstimator(`b')
	mata: st_matrix("b",(`b')')
	mata: st_matrix("V",`handle'.Estimator.Covariance)
	mata: st_local("Obs",strofreal(`handle'.EffectiveNumOfObs))
	mata: st_local("HasDrop",`handle'.HasDrop)
	mata: st_local("Converged",`handle'.Estimator.Status)
	mata: st_local("x",`XList')
	mata: st_local("y",`YList')
	
	if colsof(b)>0 {
		mat colnames b=`x'
		mat colnames V=`x'
		mat rownames V=`x'
		ereturn post b V, findomitted depname("`y'") esample(`touse') obs(`Obs') 
		ereturn scalar empty=0
	} 
	else {
		ereturn post, depname("`y'") esample(`touse') obs(`Obs') 
		ereturn scalar empty=1
	}	
	
	if "`Converged'"=="Converged" {
		ereturn scalar converged=1
	} 
	else {
		ereturn scalar converged=0
	}	
	
	ereturn local title="xtspj - `model' - Jackknifed ML"
	ereturn local vce="oim"
	ereturn local method="parm"
	mata: mata drop `handle' `Model' `XList' `YList' `b'
end

program define xtspjregress, nclass byable(recall)
	syntax varlist(min=2 numeric ts fv) [if] [in], MEthod(string) [Alpha(namelist min=1 max=1) VERBose ltol(string) ptol(string) MAXIter(string) DIAGnosis Level(real 95) *]
	// check method spec
	if "`method'"!="parm" & "`method'"!="like" & "`method'"!="none" {
		display in red "option method incorrectly specified (should be 'parm', 'like', or 'none')"
		exit 198
	} 
	
	if "`verbose'"=="" {
		local display="No"
	}
	else {
		local display="Yes"
	}
	
	// deal with if and in
	tempvar touse
	quietly marksample touse
	
	// gen consecutive N
	preserve
	quietly keep if `touse'
	quietly xtset
	restore
		
	if (r(gaps)==1) {
		display in red "panel has gaps in some time series"
		exit 416
	}
	
	tempvar N
	tempvar T
	local panelvar=r(panelvar)
	local timevar=r(timevar)
	quietly egen `N'=group(`panelvar') if `touse'
	quietly egen `T'=group(`timevar') if `touse'
	
	fvexpand `varlist'
	local varlist=r(varlist)
	
	// do the job
	tempname handle
	mata: `handle'=xtspjRegress()
	mata: `handle'.Setup("`varlist'","`touse'","`N'","`panelvar'","`T'","`method'","`display'")
	
	if ("`method'"=="like") {
		mata: `handle'.Likelihood()
	}
	else if ("`method'"=="parm") {
		mata: `handle'.Parameter()
	}
	else {
		mata: `handle'.OLS()
	}
	
	mata: st_matrix("b",`handle'.GetEstimates()')
	xtspjregress_create_result `varlist', handle(`handle') touse(`touse') method(`method') panelvar(`N') cmdline(`0') `options'
	
	if ("`alpha'"!="") {
		xtspjregress_predict_alpha `alpha', panelvar(`N')
	}
	
	mata: mata drop `handle'
end

// dirty work programs
program define xtspjregress_predict_alpha, nclass
	syntax newvarname(min=1 max=1 generate), panelvar(string)
	tempvar xb
	tempvar fitted
	local depvar=e(depvar)
	
	quietly predict `xb' if e(sample), xb
	quietly generate `fitted'=`depvar'-`xb'

	quietly sum `panelvar'
	local maxN=r(max)
	
	foreach i of numlist 1(1)`maxN' {
		quietly sum `fitted' if `panelvar'==`i' & e(sample)
		quietly replace `varlist'=r(mean) if `panelvar'==`i' & e(sample)
	}
end

program define xtspjregress_create_result, eclass
	syntax varlist(min=2 numeric ts fv), handle(string) touse(varname numeric) method(string) panelvar(string) cmdline(string) [nocons Level(real 95) *]
	
	if "`method'"=="like" {
		local method="Objective"
		local title=" - Jackknifed log-likelihood"
	}
	else if "`method'"=="none" {
		local method=""
		local title=" - ML"
	}
	else if "`method'"=="parm" {
		local method="Parameter"
		local title=" - Jackknifed ML"
	}
	
	mata: st_local("varlist",`handle'.GetVarLiat())
	fvrevar `varlist'
	local revarlist=r(varlist)
	preserve
	foreach var of varlist `revarlist' {
		tempvar tempmean
		quietly egen `tempmean'=mean(`var') if `touse', by(`panelvar')
		quietly replace `var'=`var'-`tempmean'
	}
	quietly regress `revarlist' if `touse', nocons `options'
	restore
	
	matrix define V=e(V)
	local y=word("`varlist'",1)
	local x=subinstr("`varlist'","`y'","",1)
	local vce=e(vce)
	local vcetype=e(vcetype)
	
	local df=e(df_m)
	local obs=e(N)
	ereturn clear

	matrix colnames b=`x'
	matrix rownames b=`y'
	tempname V
	mata: `V'=st_matrix("V")
	mata: `V'[`handle'.GetExcludeList(),`handle'.GetExcludeList()]=J(length(`handle'.GetExcludeList()),length(`handle'.GetExcludeList()),0)
	mata: st_matrix("V",`V')
	mata: mata drop `V'
	
	matrix colnames V=`x'
	matrix rownames V=`x'
	
	capture ereturn post b V, properties(b V) findomitted esample(`touse') obs(`obs') depname(`y') 
	ereturn scalar converged=1
	if (_rc!=0) {
		ereturn scalar converged=0
		display in red "estimates or covariance matrix contain missing values"
		error 430
	}
	
	ereturn local vce="`vce'"
	if ("`vcetype'"!=".") {
		ereturn local vcetype="`vcetype'"
	}
	ereturn local title="xtspj - regress`title'"
	
	if "`method'"=="Objective" {
		ereturn local method="like"
	}
	else if "`method'"=="" {
		ereturn local method="none"
	}
	else if "`method'"=="Parameter" {
		ereturn local method="parm"
	}
	
	
	
	if `df'<=0 {
		ereturn scalar empty=1
	}
	else {
		ereturn scalar empty=0
	}
	ereturn local cmd="xtspj"
	
	_prefix_display, level(`level')
	
end

/*
program define  xtspjweibullInitial, rclass
	syntax anything
	regress `anything'
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",.))
	
	matrix p=colsof(e(b))
	local p=p[1,1]
	matrix b=e(b)
	local result=""
	foreach i of numlist 1/`p' {
		if (b[1,`i']==_b[_cons]) {
			continue
		}
		if `i'==1 {
			local result=b[1,`i']
		}
		else {
			local b=b[1,`i']
			local result="`result',`b'"
		}
	}
	
	return local Theta="(`result',1)'"
	return local Alpha=_b[_cons]
end
*/
program define xtspjweibullVarlist, rclass
	syntax anything
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",.))
	local equation="(main: `Y'=`X', nocons) (ln_k: =)"
	display "`equation'"
	return local equation="`equation'"
end

program define xtspjexponentialVarlist, rclass
	syntax anything
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",.))
	local equation="(main: `Y'=`X', nocons)"
	return local equation="`equation'"
end

program define  xtspjnegbinInitial, rclass
	syntax anything
	poisson `anything'
	 
	matrix p=colsof(e(b))
	local p=p[1,1]
	matrix b=e(b)
	local result=""
	foreach i of numlist 1/`p' {
		if (b[1,`i']==_b[_cons]) {
			continue
		}
		if `i'==1 {
			local result=b[1,`i']
		}
		else {
			local b=b[1,`i']
			local result="`result',`b'"
		}
	}
	
	if "`result'"!="" {		
		return local Theta="(`result',1)'"
		return local Alpha=_b[_cons]
	}
	else {
		error 1
	}
end

program define xtspjnegbinVarlist, rclass
	syntax anything
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",.))
	local equation="(main: `Y'=`X', nocons) (lnalpha: =)"
	return local equation="`equation'"
end

program define xtspjgammaInitial, rclass
	syntax anything
	poisson `anything'
	
	matrix p=colsof(e(b))
	local p=p[1,1]
	matrix b=e(b)
	local result=""
	foreach i of numlist 1/`p' {
		if (b[1,`i']==_b[_cons]) {
			continue
		}
		if `i'==1 {
			local result=b[1,`i']
		}
		else {
			local b=b[1,`i']
			local result="`result',`b'"
		}
	}
	
	return local Theta="(`result',1)'"
	return local Alpha=_b[_cons]
end

program define xtspjgammaVarlist, rclass
	syntax varlist(fv ts)
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",1))
	local equation="(main: `Y'=`X', nocons) (k: =)"
	return local equation="`equation'"
end

program define xtspjpoissonVarlist, rclass
	syntax varlist(fv ts)
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",1))
	local equation="(main: `Y'=`X', nocons)"
	return local equation="`equation'"
end

program define xtspjprobitVarlist, rclass
	syntax varlist(fv ts)
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",1))
	local equation="(main: `Y'=`X', nocons)"
	return local equation="`equation'"
end

program define xtspjlogitVarlist, rclass
	syntax varlist(fv ts)
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",1))
	local equation="(main: `Y'=`X', nocons)"
	return local equation="`equation'"
end

program define xtspjlinearVarlist, rclass
	syntax varlist(fv ts)
	local Y=word("`0'",1)
	local X=trim(subinstr("`0'","`Y'","",1))
	local equation="(main: `Y'=`X', nocons) (ln_sigma^2: =)"
	return local equation="`equation'"
end
