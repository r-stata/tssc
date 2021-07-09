*! Program to estimate the spatial lag, the spatial error, the spatial durbin, and the general spatial models with moderately large datasets               
*! Author: P. Wilner Jeanty 
*! 
*! Version 2.0: January 6, 2014- Help file updated to Stata 12, bug fixed in reporting results for the spatial durbin model and in predict command
*! Version 1.5: January 2013   - Bug involving the if option fixed
*! Version 1.4: November, 2012 - Options if and in and posestimation commands now allowed
*! Version 1.3: October, 2012  - Error message "classdef _b_stat() in use" fixed
*! Version 1.2: February 2010  - Spatial Durbin Model added                              
*! Version 1.1: January 2010   - General Spatial Model also known as Spatial Mixed Model added                                                                                            
*! Version 1.0: Born: December 18, 2009

program define spmlreg
	version 12.0
	if replay() {
      	if "`e(cmd)'"!="spmlreg" {
            	error 301
        }
        Display `0'
	}
	else {
        Estimate `0'
	}
end
program define Estimate, eclass 
	version 12.0
	syntax varlist(numeric min=2) [if] [in], Weights(str) WFrom(str) Eignvar(str) Model(str) ///
           [noLOG Robust Level(passthru) favor(str) wrho(str) EIGWrho(str) ///
		   INITRho(real 0) INITLambda(real 0) sr2 *]
	
	marksample touse

	if !inlist("`model'", "lag", "error", "sac", "durbin") {
   		di as err "Option {bf:model()} accepts one of the following: {bf:lag}, {bf:error}, {bf:sac}, {bf:durbin}"
   		exit
	}
	if "`model'"!="sac" & `:word count `wrho' `eigwrho''!=0 {
		di as err "Options {bf:wrho()} and {bf:eigwrho()} may only be specified with {bf:model(sac)}"
		exit 198
	}
	local usew1 :word count `wrho' `eigwrho'
	if "`model'"=="sac" & !inlist(`usew1',0,2) { 
		di as err "Options {bf:wrho()} and {bf:eigwrho()} must be combined"
		exit 198
	}
	if inlist("`model'", "error", "sac") & "`robust'"!="" {
		di as err "{bf:robust} may not be combined with {bf:model(`model')}"
		exit 198
	}	
	if "`model'"=="error" & "`sr2'"!="" local sr2 "" 
	preserve
	cap mata: mata drop spmlreg_* 
 	cap macro drop spmlreg_*
	cap drop spmlreg_*
	if inlist("`model'", "error", "sac", "durbin") cap drop wx_*
	if "`model'"=="sac" cap drop w2x_*
    
	mlopts mlopts, `options'
	gettoken depv indvar: varlist
	global spmlreg_nv : word count `indvar'
	global spmlreg_sr2=0
	if "`sr2'"!="" global spmlreg_sr2=1
	
	qui count if `touse'
	if r(N) == 0 {
        exit 2000
    }
	else local N=r(N)
	
	cap confirm numeric var `eignvar'
	qui sum `eignvar' if `touse'
	local LOWER=1/r(min)
	local UPPER=1/r(max)
	gen double spmlreg_eigv = `eignvar'
	
	capture drop wy_`depv'
	qui splagvar `depv' if `touse', wn(`weights') wfrom(`wfrom') favor(`favor') // calculate spatial lag for y 
	local a_estimer "spmlreg_lag"
	local titl "Spatial Lag Model"
	global spmlreg_mdf=$spmlreg_nv
	
	if "`model'"=="error" {
		qui splagvar if `touse', wn(`weights') wfrom(`wfrom') ind(`indvar') favor(`favor') // calculate spatial lags for X
		local i=1
		foreach var of local indvar {
			gen double spmlreg_wx`i' = wx_`var'			
			local ++i
		}
		local a_estimer "spmlreg_error"
		local titl "Spatial Error Model"
	}
	
	if "`model'"=="sac" {
		qui splagvar if `touse', wn(`weights') wfrom(`wfrom') ind(`indvar') favor(`favor')
		local i=1
		foreach var of local indvar {
			gen double spmlreg_wx`i' = wx_`var'			
			local ++i
		}
		if `usew1'==2 {
			cap confirm numeric var `eigwrho'
			global spmlreg_w1=1
			qui gen double spmlreg_y=`depv'
			qui splagvar spmlreg_y if `touse', wn(`wrho') wfrom(`wfrom') favor(`favor') 
			gen double spmlreg_w1y=wy_spmlreg_y 
			gen double spmlreg_eigv1=`eigwrho' 
			qui sum `eigwrho' if `touse'
			local LOWER1=1/r(min)
			local UPPER1=1/r(max)
			qui splagvar wy_spmlreg_y if `touse', wn(`weights') wfrom(`wfrom') favor(`favor') 
			gen double spmlreg_w2w1y=wy_wy_spmlreg_y
		}
		else {
			global spmlreg_w1=0
			qui splagvar if `touse', wn(`weights') wfrom(`wfrom') ind(`depv') order(2) favor(`favor')
			qui gen double spmlreg_w2w2y=w2x_`depv'
		}
		local a_estimer "spmlreg_sac"
		local titl "Spatial Mixed Model"
	}
	
	if "`model'"=="durbin" {
		local xxlist `indvar'
		qui splagvar if `touse', wn(`weights') wfrom(`wfrom') ind(`indvar') favor(`favor')
		local titl "Spatial Durbin Model"
		unab wxxs: wx_*
		local indvar `indvar' `wxxs'
		global spmlreg_ldf=1 + $spmlreg_nv
		global spmlreg_mdf=2 * $spmlreg_nv
	}
	
	* Get initial values
	qui _regress `depv' `indvar' if `touse'
	tempname matinit
	if inlist("`model'", "lag", "durbin")  matrix `matinit'=e(b),`initrho',e(rmse)
	if "`model'"=="error" matrix `matinit'=e(b),`initlambda',e(rmse)
	if "`model'"=="sac" matrix `matinit'=e(b),`initrho',`initlambda',e(rmse)
	local initopt init(`matinit', copy) search(off) `log' `mlopts' 
	matrix spmlreg_matols=`matinit'[1,1..$spmlreg_nv]
	
	tempname olsll
	scalar `olsll' = -0.5 * e(N) * (ln(2*_pi) + ln(e(rss)/e(N)) + 1) 

 
	* Estimate the spatial lag or spatial durbin model
	if inlist("`model'", "lag", "durbin") {
		ml model lf `a_estimer' (`depv': `depv'=`indvar') (rho:) (sigma:) if `touse', `robust' ///
		maximize `initopt' title(`titl')  missing 
		
		if $spmlreg_sr2==1 {  		
			tempname bet r2b brho
			matrix `bet'=e(b)
			matrix `r2b'=`bet'[1, "`depv':"]
			scalar `brho'=[rho]_cons
			cap erase spmlreg_filefeig
			cap drop spmlregy_pred
			mata: spmlreg_CalcSR2("`brho'", "`r2b'", "`indvar'", "wfrom", "weights", "`touse'")
			qui sum spmlregy_pred if `touse'
   			local NUM=r(Var)
   			qui summ `depv' if `touse'
   			local DEN=r(Var)
  			local VARRAT=`NUM'/`DEN'
   			qui correlate spmlregy_pred `depv' if `touse'
   			local SQCORR=r(rho)*r(rho)
      		ereturn scalar varRatio=`VARRAT'
      		ereturn scalar sqCorr=`SQCORR'
		}

		qui test [rho]_cons = 0
        local Wald=r(chi2)			

		if "`model'"=="durbin" {			
			qui testparm `wxxs'
			local wald_d=r(chi2)
			local p_wald_d=r(p)
			ereturn scalar wald_durbin=`wald_d'
			ereturn scalar p_durbin=`p_wald_d'
			if "`robust'"=="" ereturn scalar df_d=$spmlreg_ldf
		}
		
		if "`robust'"=="" {
			local chi2_lr= 2 * (e(ll) - `olsll')
			ereturn scalar chi2_lr=`chi2_lr'
		}

		ereturn scalar rho=[rho]_cons
		ereturn scalar df_m=$spmlreg_mdf
		ereturn scalar k_eq=3
        ereturn scalar k_aux=1
	}
			
    forv i=1/$spmlreg_nv  {
      	local ITEM : word `i' of `indvar'
		local MODEL "`MODEL'(`ITEM':) "
		local spmlreg_ARGS "`spmlreg_ARGS' beta`i'"                
   	}
	
	if "`model'"=="error" {
   		local MODEL "`MODEL'(_cons:) (lambda:) (sigma:)"
   		global spmlreg_ARGS "`spmlreg_ARGS' beta0 lambda sigma"
	}
	else if "`model'"=="sac" {
   		local MODEL "`MODEL'(_cons:) (rho:) (lambda:) (sigma:)"
   		global spmlreg_ARGS "`spmlreg_ARGS' beta0 rho lambda sigma"
	}
	
	* Estimate the spatial error model
	if "`model'"=="error" { 
        ml model lf `a_estimer' `MODEL' if `touse', waldtest(1) ///
        maximize continue `initopt' title(`titl') missing 
        ereturn scalar df_m=$spmlreg_mdf		
        ereturn scalar k_eq=3
        ereturn scalar k_aux=1
		
        tempname BETA
        matrix `BETA'=e(b)
        forv i=1/$spmlreg_nv {
			local ITEM : word `i' of `indvar'
			local COLNAME "`COLNAME'`depv':`ITEM' " 
        }
		local COLNAME "`COLNAME'`depv':_cons lambda:_cons sigma:_cons"
   		matrix colnames `BETA'=`COLNAME'
   		ereturn repost b=`BETA', rename
        tempvar YHAT
        qui _predict double `YHAT' if `touse'
		qui summ `YHAT' if `touse'
   		local NUM=r(Var)
   		qui summ `depv' if `touse'		
   		local DEN=r(Var)
   		local VARRAT=`NUM'/`DEN'
   		qui correlate `YHAT' `depv' if `touse'
   		local SQCORR=r(rho)*r(rho)
		
		capture qui	test [`depv']: `indvar', min
		if _rc==0 {
			local chi2=r(chi2)
			eret scalar chi2=`chi2'
		}
		qui test [lambda]_cons = 0
		local Wald=r(chi2)
		
		local chi2_lr= 2 * (e(ll) - `olsll')        
		ereturn scalar chi2_lr=`chi2_lr'

		ereturn scalar lambda=[lambda]_cons
      	ereturn scalar varRatio=`VARRAT'
      	ereturn scalar sqCorr=`SQCORR'		
	}
	
	* Estimate the spatial mixed or the general spatial model
	if "`model'"=="sac" { 
        ml model lf `a_estimer' `MODEL' if `touse',  ///
		maximize continue `initopt' title(`titl') missing 
		ereturn scalar df_m=$spmlreg_mdf 
        ereturn scalar k_eq=4
        ereturn scalar k_aux=1
 		
        tempname BETA
        matrix `BETA'=e(b)
        forv i=1/$spmlreg_nv {
			local ITEM : word `i' of `indvar'
			local COLNAME "`COLNAME'`depv':`ITEM' " 
        }
		
		local COLNAME "`COLNAME'`depv':_cons rho:_cons lambda:_cons sigma:_cons"
   		matrix colnames `BETA'=`COLNAME'
   		ereturn repost b=`BETA', rename
		ereturn scalar w1 =$spmlreg_w1
	
		if $spmlreg_sr2==1 {
			tempname bet r2b brho
			matrix `bet'=e(b)
			matrix `r2b'=`bet'[1, "`depv':"]
			scalar `brho'=[rho]_cons			 
			cap erase spmlreg_filefeig
			cap drop spmlregy_pred
			mata: spmlreg_CalcSR2("`brho'", "`r2b'", "`indvar'", "wfrom", "weights", "`touse'")
			qui sum spmlregy_pred if `touse'
   			local NUM=r(Var)
   			qui summ `depv' if `touse'
   			local DEN=r(Var)
  			local VARRAT=`NUM'/`DEN'
   			qui correlate spmlregy_pred `depv' if `touse'
   			local SQCORR=r(rho)*r(rho)
      		ereturn scalar varRatio=`VARRAT'
      		ereturn scalar sqCorr=`SQCORR'
		}
		
		capture qui	test [`depv']: `indvar', min
		if _rc==0 {
			local chi2=r(chi2)
			eret scalar chi2=`chi2'
		}
		
		qui test ([rho]_cons=0) ([lambda]_cons=0)
		local Wald=r(chi2)			

		local chi2_lr= 2 * (e(ll) - `olsll')
		ereturn scalar chi2_lr=`chi2_lr'

		if $spmlreg_w1==1 {
      		ereturn scalar minEigen1=`LOWER1'
      		ereturn scalar maxEigen1=`UPPER1'
		}
	}
	if "`sr2'"!="" {
		cap drop spmlregy_pred	
		mata: spmlreg_geteigen("`touse'")
	} 
	
	ereturn scalar Wald=`Wald'
	
    ereturn scalar minEigen=`LOWER' 
    ereturn scalar maxEigen=`UPPER' 

	ereturn scalar N=`N'
	ereturn scalar k_dv=1
	ereturn scalar sigma=[sigma]_cons
	ereturn scalar sr2=$spmlreg_sr2
	ereturn local chi2type "Wald"
    ereturn local depvar "`depv'"
	ereturn local indvar "`xxlist'"
	ereturn local wname `weights'
	ereturn local wfrom `wfrom'
	ereturn local model `model'	
	ereturn local eignvar `eignvar'
	ereturn local predict "spmlreg_p"
	ereturn local estat_cmd "spmlreg_estat"
	ereturn local cmd "spmlreg"	
	
	* Display results
	Display, `level' `robust'
	ereturn repost, esample(`touse')
	macro drop spmlreg_*
end
program define Display
	version 12.0
	syntax, [Level(int $S_level) robust]
	di _newline
	
	di as txt "`e(title)'" _col(52) "Number of obs" _col(68) "=" as res %10.0f `e(N)'
	di as txt _col(52) "Wald chi2(" as res `e(df_m)' as txt ")" _col(68) "=" as res %10.3f `e(chi2)'
	di as txt _col(52) "Prob > chi2" _col(68) "=" as res %10.3f chi2tail(`e(df_m)',`e(chi2)')
	if "`e(title)'"=="Spatial Error Model" | `e(sr2)' {		
		di as txt _col(52) "Variance ratio" _col(68) "=" as res %10.3f `e(varRatio)'
		di as txt _col(52) "Squared corr." _col(68) "=" as res %10.3f `e(sqCorr)'
	}
	di as txt "Log likelihood = " as res `e(ll)' as txt _col(52) "Sigma"   /*
     */   _col(68) "=" as res %10.2f [sigma]_cons
	di ""
	if inlist("`e(title)'", "Spatial Error Model", "Spatial Lag Model", "Spatial Durbin Model") {  

		ml display, level(`level') neq(1) plus noheader
		if inlist("`e(title)'", "Spatial Lag Model", "Spatial Durbin Model") {
			_diparm rho, level(`level') label("rho")
			local PARM "rho"
		}
		if "`e(title)'"=="Spatial Error Model" {
			_diparm lambda, level(`level') label("lambda")
			local PARM "lambda"
		}
		di as txt "{hline 13}{c BT}{hline 64}"
		if inlist("`e(title)'", "Spatial Error Model", "Spatial Lag Model") {
			di as txt "Wald test of `PARM'=0:" _col(40) "chi2(1) = "   /*
			*/ as res _col(50) %7.3f `e(Wald)' as txt " ("             /*
			*/ as res %5.3f chi2tail(1,`e(Wald)') as txt ")"
			if "`robust'"=="" {
   				di as txt "Likelihood ratio test of `PARM'=0:" _col(40) "chi2(1) = "   /*
   				*/ as res _col(50) %7.3f `e(chi2_lr)' as txt " ("                         /*
   				*/ as res %5.3f chi2tail(1,`e(chi2_lr)') as txt ")"
			}
		}
		if "`e(title)'"=="Spatial Durbin Model" {
			di as txt "Wald test of `PARM'=0:" _col(50) "chi2(1) = "   /*
			*/ as res _col(58) %7.3f `e(Wald)' as txt " ("             /*
			*/ as res %5.3f chi2tail(1,`e(Wald)') as txt ")"
			di as txt "Wald test for coefficients on lags of X's =0:" _col(50) "chi2(" `e(df_m)' as txt ") = "   /*
			*/ as res _col(58) %7.3f `e(wald_durbin)' as txt " ("             /*
			*/ as res %5.3f chi2tail(`e(df_m)',`e(wald_durbin)') as txt ")"
			if "`robust'"=="" {
   				di as txt "Likelihood ratio test of SDM vs. OLS:" _col(50) "chi2("`e(df_d)' as txt ") = "   /*
   				*/ as res _col(58) %7.3f `e(chi2_lr)' as txt " ("                         /*
   				*/ as res %5.3f chi2tail(`e(df_d)',`e(chi2_lr)') as txt ")"
			}
		}	
		di ""
		di as txt "Acceptable range for `PARM': " as res %5.3f `e(minEigen)'   /*
   		*/   " < `PARM' < " %5.3f `e(maxEigen)' 
	}
	if "`e(title)'"=="Spatial Mixed Model" {
		ml display, level(`level') neq(1) noheader diparm(rho, label("rho")) diparm(lambda, label("lambda"))
		di as txt "Wald test of SAC vs. OLS:" _col(40) "chi2(2) = "   /*
		*/ as res _col(50) %7.3f `e(Wald)' as txt " ("             /*
		*/ as res %5.3f chi2tail(2,`e(Wald)') as txt ")"
		di
   		di as txt "Likelihood ratio test of SAC vs. OLS:" _col(40) "chi2(2) = "   /*
   			*/ as res _col(50) %7.3f `e(chi2_lr)' as txt " ("                         /*
   			*/ as res %5.3f chi2tail(2,`e(chi2_lr)') as txt ")"		
		if `e(w1)'==0 {
			di
			di as txt "Acceptable range for Rho and Lambda: " as res %5.3f `e(minEigen)'   /*
   			*/   " < Rho, Lambda < " %5.3f `e(maxEigen)' 
		}
		else {
			di
			di as txt "Acceptable range for Rho: " as res %5.3f `e(minEigen1)'   /*
   			*/   " < Rho < " %5.3f `e(maxEigen1)' 
			di
			di as txt "Acceptable range for Lambda: " as res %5.3f `e(minEigen)'   /*
   			*/   " < Lambda < " %5.3f `e(maxEigen)'
		}
	}	  
end
version 12.0
mata
mata set matastrict on
void spmlreg_CalcSR2(string scalar brho, string scalar bvec, 
					string scalar xvars, string scalar m_wfrom, 
					string scalar m_wname, string scalar touseobs) 
{
    rho=st_numscalar(brho) 
	real matrix B, C, xxs, invIRW
	st_view(xxs=., ., tokens(xvars), touseobs)
	C=J(nc=rows(xxs),1,1)
    xxs=xxs,C
	if (st_local(m_wfrom)=="Mata") {
        fh = fopen(st_local(m_wname), "r") 
        spmlreg_w=fgetmatrix(fh)
        fclose(fh)
	}
	else spmlreg_w=st_matrix(st_local(m_wname)) 
    nw=rows(spmlreg_w)
	invIRW=luinv(I(nw)-rho*spmlreg_w)
    B=st_matrix(bvec)
    XB=xxs*B'
    ypred=invIRW*XB
    fhh = fopen("spmlreg_filefeig", "w")
    fputmatrix(fhh, ypred)
    fclose(fhh)
    st_store(., st_addvar("double", "spmlregy_pred"), touseobs, ypred)
}
void spmlreg_geteigen(string scalar tousev) {
	fh = fopen("spmlreg_filefeig", "r") 
	predy=fgetmatrix(fh)
	fclose(fh)
	st_store(., st_addvar("double", "spmlregy_pred"), tousev, predy)
	unlink("spmlreg_filefeig")
}
end

