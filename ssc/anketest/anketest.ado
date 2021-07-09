*! Program to test for spatial autocorrelation in the residuals from OLS, IV, SAR, and IV-SAR models
*! Author P. Wilner Jeanty
*! Version 1.0 Born: Date October 17, 2008
*! Version 1.2 Updated January 2009
*! Version 1.3 January 2010: Test after spatial lag model estimated by ML added
program define anketest, rclass
	version 9.2
	if "`e(cmd)'"=="" {
		di
		di as err "The model has not been estimated. Please estimate a model"
		exit 301
	}
	else if !inlist("`e(cmd)'", "ivregress", "ivreg29", "regress", "spmlreg") {
		di
		di as err "ANKETEST does not work after the `e(cmd)' command"
		exit 198
	}
	if ("`e(cmd)'"=="spmlreg" & "`e(title)'"!="Spatial Lag Model") {
		di
		di as err "ANKETEST does not work after a `e(title)'"
		exit 198
	} 
	syntax, Wname(str) WFrom(str) model(str) [favor(str)]
	if !inlist("`wfrom'", "Stata", "Mata") {
		di 
		di as err "Either Stata or Mata must specified with the {bf:wfrom()} option"
		exit 198
	}
	if !inlist("`model'", "ols", "iv", "sar", "iv-sar") {  // sar if for both ML-sar and IV-sar
		di 
		di as err "One of {bf:ols}, {bf:iv}, {bf:sar}, and {bf:iv-sar} must be specified with the {bf:model()} option"
		exit 198
	}
	if "`model'"=="ols" & "`e(cmd)'"!="regress" {
		di as err "An OLS model was not estimated"
		exit 301
	}
	if inlist("`model'", "iv", "iv-sar") & !inlist("`e(cmd)'", "ivregress", "ivreg29") {
		di as err "An iv or iv-sar model was not estimated"
		exit 301
	}
	if "`model'"=="sar" & !inlist("`e(cmd)'", "ivregress", "ivreg29", "spmlreg") {
		di as err "A SAR model was not estimated either by ML or spatial 2SLS"
		exit 301
	}
	if "`favor'"!="" & inlist("`favor'", "space", "speed")==0 {
		di as err " Option {bf:favor(`favor')} not allowed"
		exit 198
	}
	mata: anketest_lagml=0
	local sarml=0
	if "`e(cmd)'"== "spmlreg" & "`e(title)'"== "Spatial Lag Model" {
		local rho_cons=[rho]_cons
		local Vrho=([rho]_se[_cons])^2
		local sigma_cons=[sigma]_cons
		mata: anketest_rho=`rho_cons'; anketest_Vrho=`Vrho'; anketest_sigma=`sigma_cons'; anketest_lagml=1; anketest_W1="`e(wname)'"
		local sarml=1
		local wname1 `e(wname)'
		local wfrom1 `e(wfrom)'	
		local depv "`e(depvar)'"	
	}
	tempvar resreg
	if `sarml' {
      	tempvar yhat wy
        qui predict `yhat'
		qui gen double `wy'=.
		mata: wm=Anketest_ReadWght("wfrom1", "wname1"); st_view(y=., ., st_local("depv")); ylag=wm*y; st_store(., st_local("wy"), ylag)	
        qui replace `yhat'=`yhat'+ [rho]_b[_cons]*`wy'
		qui gen double `resreg'=`depv'-`yhat'
	}
	else predict `resreg', res
	if "`model'"!="ols" {
		local inst "`e(insts)'"
		local insted "`e(instd)'"
	}
	else if "`model'"=="ols" {
		tempname bmat bmatshort
		mat `bmat'=e(b)
		local col=colsof(`bmat')
		mat `bmatshort'=`bmat'[1,1..`col'-1] 
		local xvs : colnames(`bmatshort')
		local depv "`e(depvar)'"
	}
	if "`favor'"=="" & c(matafavor)=="space" mata: mata set matafavor speed
	if "`favor'"=="speed" & c(matafavor)=="space" mata: mata set matafavor speed
	if "`favor'"=="space" & c(matafavor)=="speed" mata: mata set matafavor space	
	mata: Anketest_CalcStat()
	matlist testres, nob row(Tests) title("`title'") cspec(| b %16s | %10.2f & %7.4f |) `rspec'  
	if `sarml' di as txt "*: Test based on maximum likelihood estimation of Rho and Sigma"
	return matrix Diagmat=testres
end
version 9.2
mata:
	mata drop *()
	mata set matastrict on
	void Anketest_CalcStat() {
	external real scalar anketest_rho, anketest_Vrho, anketest_lagml, anketest_sigma
	external string scalar anketest_W1, anketest_wfrom
	external real colvector y
	st_view(e=., ., st_local("resreg")); n=rows(e)
	model=st_local("model")

	if (model=="ols") {
		st_view(y=., ., st_local("depv")) 
		st_view(x=., ., tokens(st_local("xvs"))); x=x,J(n,1,1)
	}
	else if (anketest_lagml==0) {
		st_view(exog=., ., tokens(st_local("inst")))
		st_view(endog=., ., tokens(st_local("insted")))
	}
	w=Anketest_ReadWght("wfrom", "wname") // Mata learners: here I pass onto Mata the names of the macros rather than their contents

	t2= trace(w, w) + trace(w, w, 1) // =trace((w*w)+(w'*w))
	if (anketest_lagml==1) {  // SAR estimated by ML
		if (st_local("wname")==anketest_W1)	W1=w		
		else W1=Anketest_ReadWght("wfrom1", "wname1") // user specifies a weights matrix different from the one used for the spatial lag model
		InvA=luinv(I(n)-anketest_rho*W1)
		w2w1=w*W1; w1A=W1*InvA
		T21A=trace(w2w1, InvA) + trace(w, w1A, 1) // trace(w*w1*invA + w'*w1*invA) where w2=w
		TD=(t2 - T21A*T21A*anketest_Vrho)
		sigma2=anketest_sigma^2 // to save some computing time
		esigma=e'*w*y/sigma2
	}
	else {
		ee=quadcross(e, e) // for  ee=e'*e
		sigma2=ee/n // this is equal to sigma^2, where sigma is estimated directly by ML in the lag model 
		ewe=e'*w*e
		esigma=ewe/sigma2
	}
	if (model=="iv" | model=="sar" | model=="ols") {
		if (anketest_lagml==0) LM_err=(esigma^2)/t2
		else LM_err=(esigma^2)/TD
		pLM_err=chi2tail(1,LM_err)
	}
	if (model=="ols") {
		// LM_lag test
		ewy=e'*w*y
		px=x*invsym(quadcross(x, x))*x'
		b=st_matrix(st_local("bmat"))
		wxb=w*x*b' 
		D=(wxb'*(I(n)-px)*wxb)/sigma2 + t2
		invD=1/D
		LM_lag=invD*(ewy/sigma2)^2
		pLM_lag=chi2tail(1,LM_lag)

		// robust LM_err
		RLM_err=((esigma-t2*invD*ewy/sigma2)^2)/(t2-t2*t2*invD)
		pRLM_err=chi2tail(1,RLM_err)

		// Robust LM_lag
		RLM_lag=(((ewy/sigma2)-esigma)^2)/(D-t2)
		pRLM_lag=chi2tail(1,RLM_lag)
		
		// Moran's I for OLS
		MI=ewe/ee
		k=cols(x) 
		m=I(n)-px
		s=sum(w)			
		I=(n/s):*MI
		d=(n-k):*(n-k+2)
		M1=quadcross(m', w); M2=quadcross(m', w') // M1=m*w; M2=m*w'
		t1=trace(m, w)
		t3=trace(M1, M1) // trace(m*w*m*w)
		ex=(n/s)*t1/(n-k)
		vi=((n/s)^2)*(trace(M1, M2)+ t3+ t1*t1)/d
		vi=vi-ex*ex
		zi=(I-ex)/sqrt(vi) // Moran's I z-score 
		pMI=(1-normal(abs(zi)))*2 // p-value for two-tailed test
	}
	if (model=="iv-sar" | (model=="sar" & !anketest_lagml) | model=="iv") {
		MI=ewe/ee
		// Moran's I for models with endogenous regressors and/or spatially lagged dependent variable
		if (model=="iv-sar") {
			z1=exog,endog
			x=exog,J(rows(z1), 1, 1)
			px=x*invsym(quadcross(x, x))*x'
			a1=(e'*w*z1)/n
			a2=n*invsym(z1'*px*z1)
			a3=(1/n)*(z1'*w'*e)
			A=a1*a2*a3 
		}
		if (model=="iv" | model=="sar") A=0 // According to Anselin and Kelejian (1997)
		s1=sum(w)/n; s2=t2/n
		phi2=s2/(2*s1^2) + A*(4/s1^2*sigma2); 
		MI_z=(sqrt(n)*MI)/sqrt(phi2)
		pmiz=(1-normal(abs(MI_z)))*2		
	}
// Now reporting
	if (model=="ols") {
		st_local("rspec", "rspec(--&&&&-)")
		st_local("title", "Tests for Spatial Autocorrelation in the OLS Model residuals")
		olsres=zi,pMI\LM_err, pLM_err\RLM_err, pRLM_err\LM_lag, pLM_lag\RLM_lag, pRLM_lag
		st_matrix("testres", olsres)
		st_matrixrowstripe("testres", ("", "Moran's_I"\"", "LM_Error"\"", "Robust_LM_Error"\"", "LM_Lag"\"", "Robust_LM_Lag"))
		st_matrixcolstripe("testres", ("", "Statistic"\"", "P-Value"))
	}
	if (model=="iv") {
		st_local("rspec", "rspec(--&-)")
		st_local("title", "Tests for Spatial Autocorrelation in the IV-Model Residuals")
		fsres=MI_z,pmiz\LM_err, pLM_err 
		st_matrix("testres", fsres)
		st_matrixrowstripe("testres", ("", "IV_Moran's_I"\"", "IV_LM_Error"))
		st_matrixcolstripe("testres", ("", "Statistic"\"", "P-Value"))
	}
	if (model=="sar" & anketest_lagml==0) {
		st_local("rspec", "rspec(--&-)")
		st_local("title", "Tests for Spatial Autocorrelation in the SAR Model Residuals")
		sar_res=MI_z,pmiz\LM_err, pLM_err 
		st_matrix("testres", sar_res)
		st_matrixrowstripe("testres", ("", "Moran's_I"\"", "LM_Error"))
		st_matrixcolstripe("testres", ("", "Statistic"\"", "P-Value"))
	}
	if (model=="sar" & anketest_lagml==1) {
		st_local("rspec", "rspec(---)")
		st_local("title", "Tests for Spatial Autocorrelation in the SAR (ML) Model Residuals")
		mlsar_res=LM_err,pLM_err
		st_matrix("testres", mlsar_res)
		st_matrixrowstripe("testres", ("","LM_Error*"))
		st_matrixcolstripe("testres", ("", "Statistic"\"", "P-Value"))
	}
	if (model=="iv-sar") {
		st_local("rspec", "rspec(---)")
		st_local("title", "Tests for Spatial Autocorrelation in the IV_SAR Model Residuals")
		endsar_res=MI_z,pmiz
		st_matrix("testres", endsar_res)
		st_matrixrowstripe("testres", ("","IV_Moran's_I"))
		st_matrixcolstripe("testres", ("", "Statistic"\"", "P-Value"))
	}
	""
	stata(`"di as txt "{title:Diagnostic tests for Spatial Dependence}""'); ""
}
real matrix Anketest_ReadWght(string scalar A_from, string scalar A_wname) {
	if (st_local(A_from)=="Mata") {
      	if (!fileexists(st_local(A_wname))) {
            	""
                  errprintf("File %s not found\n", st_local(A_wname))
                  exit(601)
            }
		else {
			fh = fopen(st_local(A_wname), "r") // get the weights matrix from a Mata file
			wmat=fgetmatrix(fh)
			fclose(fh)
		}
	}
	else { // get the weights matrix from Stata
		wmat=st_matrix(st_local(A_wname))
            if (cols(wmat)==0 | rows(wmat)==0) {
            	""
                  errprintf("Matrix %s not found\n", st_local(A_wname))
                  exit(601)
            }  
	}
	return(wmat)
}
end
