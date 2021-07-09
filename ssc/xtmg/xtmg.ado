***************************************************************************************************
*!version 1.0.1 8Feb2011
*!xtmg   - 	Estimating panel time series models with heterogeneous slopes 
* 		by Markus Eberhardt, CSAE, Department of Economics, University of Oxford
* 		For feedback please email me at markus.eberhardt@economics.ox.ac.uk
* 		Visit http://sites.google.com/site/medevecon/ for macro panel data 
*			and other Stata routines
***************************************************************************************************
* xtmg
***************************************************************************************************
* Known Bugs: 	
*		-none
*
* Planned extensions:
*		-optional density plot or histogram for specified set of group-specific coefficients
*
* Revisions made:
* v.1.0.1 (7Feb2011)
*		-corrected some typos which prevented xtmg from running under -varabbrev off-
*		-changed parts of aug-routine first stage to mata to avoid large matsize
*		-nocons now works in the standard MG estimator
*		-added error messages for cce and aug options if -nocons- selected
*
***************************************************************************************************

capture program drop xtmg
program define xtmg, eclass prop(xt) sort
version 10

      syntax varlist [if] [in] [, I(varname) T(varname) TREND noCONstant AUGment IMPose CCE ///
		FULL Level(cilevel) ROBUST RES(namelist)]

      _xt, i(`i') t(`t')
      local ivar "`r(ivar)'"
      local tvar "`r(tvar)'"
	marksample touse
	markout `touse' `offset' `t' 
	markout `touse' `ivar', strok

quietly{

/* Tokenize varlist and determine dimensions */
		tokenize `varlist'
            local dep "`1'"
		local depname "`1'"
            mac shift
            local ind "`*'"
            noi _rmcoll `ind' if `touse', `constant'
            local ind "`r(varlist)'"
            local p : word count `ind'
		local rhs = `p'
		if ("`augment'" != "") & ("`cce'" != "") {
			display as error _col(2) ""
			display as error _col(2) "You can only select one of options -cce- or -augment-."
			exit
		} 
		if ("`impose'" != "") & ("`augment'" == "") {
			display as error _col(2) ""
			display as error _col(2) "You cannot select option -impose- without -augment-."
			exit
		} 
		if ("`cce'"!="" & "`constant'" != "") {
			display as error ""
			display as error _col(2) "The CCEMG routine requires a group-specific intercept."
			display as error _col(2) "Please drop the -nocons- option."
			exit
		}
		if ("`augment'"!="" & "`constant'" != "") {
			display as error ""
			display as error _col(2) "The Augmented MG estimator requires a group-specific intercept."
			display as error _col(2) "Please drop the -nocons- option."
			exit
		}


		if ("`constant'" == "") { 
			local rhs = `rhs'+1 
		}
		if ("`trend'" != "") { 
			local rhs = `rhs'+1 
		}
		if ("`augment'" != "" & "`impose'"== "") { 
			local rhs = `rhs'+1 
		}
		else local rhs = `rhs'

            tempvar t T Tall
            sort `touse' `ivar' 
            by `touse' `ivar': gen int `t' = _n if `touse'
            by `touse' `ivar': gen int `T' = _N if `touse'
		count if `touse' 
		local nobso = r(N)
		by `touse' `ivar' : replace `touse' = 0 if `T'[_N] <= `rhs'
		replace `T' = . if `touse'==0
		count if `touse' 
		local nobs = r(N)

		if `nobs' < `nobso' {
			noi di as text _col(2) "Note: " as res `nobso'-`nobs' as text " obs. dropped (panels too small)" 
		}

/* Create group variable and time trend */
		tempvar g gall timevar 
*`timevar'_t
		egen `g' = group(`ivar') if `touse'
		summ `g' if `touse'
		local ng = r(max)
		egen `gall' = group(`ivar')
		summ `gall'
		local ngall = r(max)
		summ `tvar' 
            local Tall = r(max)
		gen `timevar'_t=`tvar'-r(min)
		summ `timevar'_t
		local gmax = r(max)+1

            summarize `T' if `touse' & `ivar'~=`ivar'[_n-1], meanonly
            local n = r(N)
            local g1 = r(min)
            local g2 = r(mean)
            local g3 = r(max)
*           summ `Tall'

		if `c(matsize)' <`ng'{
			noi display in smcl  _col(2) "{help matsize##|_new:matsize} " ///
			as error "must be at least as large as the number" _n ///
			as error "of panels in the current estimation sample (`ng')."
			exit 908
		}




/* Compute country-estimates */
		tempname bols vari bbar vce  depT indT tmp tmp2 r r1 sig2 beta names
		generate `r'=.
		if ("`cce'" != ""){
			if ("`trend'" != ""){
			mat `bols' = J(`ng', 2*(`rhs'-1)+1, 0)
			mat `vari' = J(`ng', 2*(`rhs'-1)+1, 0)
			mat `bbar' = J(`ng', 2*(`rhs'-1)+1, 0)
			mat `vce' = J(2*(`rhs'-1)+1, 2*(`rhs'-1)+1, 0)
			}			
			else {
			mat `bols' = J(`ng', 2*(`rhs'-1)+2, 0)
			mat `vari' = J(`ng', 2*(`rhs'-1)+2, 0)
			mat `bbar' = J(`ng', 2*(`rhs'-1)+2, 0)
			mat `vce' = J(2*(`rhs'-1)+2, 2*(`rhs'-1)+2, 0)
			}
		}
		else {
			mat `bols' = J(`ng', `rhs', 0)
			mat `vari' = J(`ng', `rhs', 0)
			mat `bbar' = J(`ng', `rhs', 0)
			mat `vce' = J(`rhs', `rhs', 0)
		}

		local i = 1


	/* Augmented MG estimator: first stage */
		if ("`augment'" != ""){
			tsset `ivar' `tvar'
			tempvar yr year ddep 
			tempname comdyn zeros comdyn2  aug `aug'_c
			tab `tvar', gen(`yr')
			forvalues l=1/`gmax'{
				tsset `ivar' `tvar'
				gen `year'`l'=d.`yr'`l'
			}
			gen `ddep'=d.`dep' if `touse'
			reg `ddep' d.(`ind') `year'2-`year'`gmax', nocons
			mat `comdyn'=e(b)'
			mat comdyn=`comdyn'
			mat `zeros'=J(1,1,0)
			if ("`impose'" == ""){
				if ("`trend'" != ""){
					mat `comdyn'=`zeros' \ `comdyn'[(`rhs'-2)...,1]
				} 
				else mat `comdyn'=`zeros' \ `comdyn'[(`rhs'-1)...,1]
			}
			if ("`impose'" != ""){
				if ("`trend'" != ""){
					mat `comdyn'=`zeros' \ `comdyn'[(`rhs'-1)...,1]
				} 
				else mat `comdyn'=`zeros' \ `comdyn'[(`rhs')...,1]
			}
			mata: `comdyn' = st_matrix("`comdyn'")
			mata: `comdyn2' = J(`ngall',1,1)#`comdyn'
			gen `aug'_c=0
			mata: st_store(.,"`aug'_c",`comdyn2')
			sort `ivar' `tvar'
		}
		if ("`augment'" != "" & "`impose'" != "") {
			tempvar depaug
			gen `depaug'=`dep'-`aug'_c if `touse'
		}
		if ("`augment'" != "" & "`impose'" != ""){
				if ("`trend'" != ""){		
					reg `depaug' `ind' `timevar'_t if `touse' & `g'==`i', `constant'
				}
				if ("`trend'" == ""){	
					reg `depaug' `ind' if `touse' & `g'==`i', `constant' 
				} 
		}
		if ("`augment'" != "" & "`impose'" == ""){
				if ("`trend'" != ""){
					reg `dep' `ind' `aug'_c `timevar'_t if  `touse' & `g'==`i', `constant'
				}
				if ("`trend'" == ""){
					reg `dep' `ind' `aug'_c if `g'==`i', `constant'
				}
		}

	/* CCEMG estimator: group 1 */

		if ("`cce'" != ""){
			tempvar indT depT
*			tempvar `indT'_`m' `depT'_`m'
			tokenize `varlist'
			sort `tvar' `ivar' 
			local m = 1
			tempvar `depT'_`m'
			by `tvar': egen `depT'_``m''=mean(``m'') if `touse' 
		      local coefs : word count `varlist'
			forvalues m = 2/`coefs'{
				tempvar `indT'_`m'
				by `tvar': egen `indT'_``m''=mean(``m'') if `touse'  	
			}
			sort `ivar' `tvar'
			if ("`trend'" != ""){
				reg `dep' `ind' `timevar'_t `depT'_* `indT'_* if `touse' & `g'==1, `constant'
			}
			else {
				reg `dep' `ind' `depT'_* `indT'_* if `touse' & `g'==1, `constant'
			}
	
		}


	/* Standard MG estimator: group 1 */
		if  ("`cce'" == "" & "`augment'" == ""){
			if ("`trend'" != ""){
				reg `dep' `ind' `timevar'_t if `touse' & `g'==1, `constant'
			}
			else {
				reg `dep' `ind' if `touse' & `g'==1, `constant'
			}
		}
		mat `tmp' = get(_b)	
		local colstr : colnames `tmp'
		mat colnames `bols' = `colstr'
		mat `tmp2' = get(VCE)	
		predict double `r1' if `touse' & `g'==1, res
		if ("`trend'" != ""){
			test `timevar'_t
			local waldtrend=0
				if r(p)<(100-`level')/100{
					 local waldtrend=`waldtrend'+1
				}
		}
		replace `r'=`r1' if `touse' & `g'==1
		mat `bols'[1, 1] = `tmp'
		mat `vari'[1, 1] =  vecdiag(`tmp2')
		mat `bbar' = `bols'[1, 1...]


	/* Groups 2 to N */

		local i = 2
		while `i' <= `ng'{
			tempvar `r'`i'

	/* AMG estimator: groups 2 to N */
			if ("`augment'" != "" & "`impose'" == "") {
				if ("`trend'" != ""){
					reg `dep' `ind' `aug'_c `timevar'_t if `touse' & `g'==`i', `constant'
				}
				else reg `dep' `ind' `aug'_c if  `touse' & `g'==`i'
			}
			if ("`augment'" != "" & "`impose'" != "") {
				if ("`trend'" != ""){		
					reg `depaug' `ind' `timevar'_t if `touse' & `g'==`i', `constant'
				}
				else reg `depaug' `ind' if `touse' & `g'==`i', `constant'
			}

	/* CCEMG estimator: groups 2 to N */
			if ("`cce'" != ""){
				if ("`trend'" != ""){		
					reg `dep' `ind' `timevar'_t `depT'_*  `indT'_* if `touse' & `g'==`i', `constant'
				}
				else reg `dep' `ind' `depT'_*  `indT'_* if `touse' & `g'==`i', `constant'
			}

	/* Standard MG estimator: groups 2 to N */
			if ("`augment'" == "" & "`cce'" == "") {
				if ("`trend'" != ""){		
					reg `dep' `ind' `timevar'_t if `touse' & `g'==`i', `constant'
				}
				else reg `dep' `ind' if `touse' & `g'==`i', `constant'
			}

			predict double `r'`i' if `touse' & `g'==`i', res
			mat `tmp' = get(_b)	
			mat `tmp2' = get(VCE)	
			if ("`trend'" != ""){
				qui test `timevar'_t
				if r(p)<(100-`level')/100{
					 local waldtrend=`waldtrend'+1
				}
			}
			replace `r'=`r'`i' if `touse' & `g'==`i'
			mat `bols'[`i', 1] = `tmp'
			mat `vari'[`i', 1] =  vecdiag(`tmp2')
			mat `bbar' = `bbar' + `bols'[`i', 1...]
			local i = `i' + 1
		}
	/* End of group 2 to N estimation */

		local ngg = 1/`ng'
		mat `bbar' = `bbar' * `ngg'
		mat colnames `bbar' = `colstr'
		mat colnames `vce' = `colstr'
		mat rownames `vce' = `colstr'
		if ("`res'" != ""){		
			capture confirm new variable `res'
			if _rc!=0{
				display as error  _col(2) "Variable `res' to hold residuals already exists."
				display as error  _col(2) "Either drop this variable or specify another name for residuals."
				exit
			}
			gen `res'=`r' if `touse'
		}
		replace `r'=`r'^2 if `touse'
		sum `r' if `touse'
		scalar `sig2'=r(mean)

/* Standard errors */
		tempname names nn rnn tmp vce Xm stei tbetas Xn Xq
		local nn = rowsof(`bols')
		local names: colfullnames `bbar'
		scalar `rnn'=1/`nn'
		matrix `tmp'=`bols'-J(`nn',1,1)#(J(1,`nn',`rnn')*`bols')
		matrix coleq `tmp'=:
		matrix roweq `tmp'=:
		matrix `vce'=`tmp''*`tmp'/(`nn'*(`nn'-1))
		matrix rownames `vce'=`names'
		matrix colnames `vce'=`names'
		matrix colnames `vari'=`names'
		mata: `Xm' = st_matrix("`vari'")
		mata: `Xn' = st_matrix("`bols'")
		mata: `Xm' = sqrt(`Xm')
		mata: st_matrix("`stei'", `Xm')
		matrix colnames `stei'=`names'
		mata: `Xq' = `Xn' :/ `Xm'
		mata: st_matrix("`tbetas'", `Xq')
		matrix colnames `tbetas'=`names'

/* Robust means */
	tempname rb rV temp est vcv names vcvm colms
	if ("`robust'" != ""){		
		local colms = colsof(`bols')
		svmat double `bols', names(`temp')
		matrix `rb'=J(1,`colms',0)
		matrix `rV'=J(`colms',`colms',0)
		local names: colfullnames `bols'
		forvalues i=1/`colms'{
			tempname `est'`i' `vcv'`i'
			rreg `temp'`i'
			matrix `est'`i'=e(b)
			matrix `vcv'`i'=e(V)
			matrix `rb'[1,`i']=`est'`i'[1,1]
			matrix `rV'[`i',`i']=`vcv'`i'[1,1]
		}
		matrix colnames `rb'=`names'
		matrix colnames `rV'=`names'
		matrix rownames `rV'=`names'
		mat `beta'=`rb'
		mat `vcvm'=`rV'
	}
	else {
		mat `beta'=`bbar'
		mat `vcvm'=`vce'
	}


/* Post the results */
		tempvar waldt 
		ereturn post `beta' `vcvm', obs(`nobs') depname(`depname') esample(`touse')
		capture test `ind', min `constant'
		ereturn scalar sigma=`sig2'
		if ("`trend'" != ""){
			local waldtrend = `waldtrend'/`ng'
			ereturn scalar trend_sig = `waldtrend'
			capture test `ind' `timevar'_t, min `constant'
			if _rc == 0 {
				ereturn scalar chi2 = r(chi2)
				ereturn scalar df_m = r(df)
			}
			else    est scalar df_m = 0
		}
		capture test `ind', min `constant'
		if _rc == 0 {
			ereturn scalar chi2 = r(chi2)
			ereturn scalar df_m = r(df)
		}
		else    est scalar df_m = 0
		ereturn scalar g_min  = `g1'
		ereturn scalar g_avg  = `g2'
		ereturn scalar g_max  = `g3'
		ereturn scalar N_g = `ng'
		ereturn matrix tbetas = `tbetas'
		ereturn matrix stebetas = `stei'
		ereturn matrix betas = `bols'
		ereturn matrix varbetas = `vari'
*		ereturn scalar chi2_c = `chival'
		ereturn local chi2type "Wald"
*		ereturn local vce "`vcetype'"
		if ("`augment'" != "" & "`impose'" != ""){
			ereturn local depvar "adjusted `depname'"
		}
		else	ereturn local depvar "`depname'"		
		if ("`augment'" != "") ereturn local title2 "AMG"
		if ("`cce'" != "") ereturn local title2 "CCEMG"
		if ("`augment'" == "" & "`cce'" == "") ereturn local title2 "MG"
		ereturn local title "Mean Group type estimation"
		ereturn local tvar "`tvar'"
		ereturn local ivar "`ivar'"
		ereturn local cmd "xtmg"
}


display ""
display ""
if ("`cce'" != ""){
	display in gr "Pesaran (2006) Common Correlated Effects Mean Group estimator"
display ""
}
if ("`augment'" != "") {
	display in gr "Augmented Mean Group estimator (Bond & Eberhardt, 2009; Eberhardt & Teal, 2010)"
	display ""
	if ("`impose'" !="") {
		display in gr as text "Common dynamic process " in ye "imposed" in gr " with unit coefficient " 
		display in gr "    Dependent variable" in ye " adjusted `depname'"
	}
	else {
		display in gr as text "Common dynamic process " in ye "included" in gr " as additional regressor" 
	}
}
if ("`augment'" == "" & "`cce'"=="") {
	display in gr "Pesaran & Smith (1995) Mean Group estimator"
	display ""
}
display in gr "All coefficients present represent averages across groups (" in ye "`ivar'" in gr ")"
if ("`robust'" != ""){		
	display in gr "Coefficient averages computed as" in ye " outlier-robust" in gr " means (using rreg)" 
}
else {
	display in gr "Coefficient averages computed as " in ye "unweighted" in gr " means" 
}

_crcphdr
_coef_table, level(`level')
display in gr "Root Mean Squared Error (sigma): " in ye %5.4f sqrt(`sig2') 
if ("`robust'" != ""){
	display in gr "(RMSE uses residuals from group-specific regressions: unaffected by 'robust')."
	}
if ("`augment'" != "" & "`impose'"==""){
	display in gr "Variable " in ye "`aug'_c" in gr " refers to the common dynamic process."
}
if ("`cce'" !=""){
	display in gr "Cross-section averaged " in ye "regressors" in gr " are marked by the suffix: " 
	display in ye "   _`1'" _continue
	forvalues m=2/`coefs' {
		display in ye ", _``m''"  _continue
	}
	display in gr " respectively."
}
if ("`res'" != "") {
	display in gr "Residual series based on country regressions stored in variable: " in ye "`res'"
}
if ("`trend'" != ""){
	display in gr "Variable " in ye "`timevar'_t" in gr " refers to a group-specific linear trend."
	display in gr "Share of group-specific trends significant at " (100-`level') "% level: " ///
		in ye %5.3f `waldtrend' " (= " (`waldtrend'*`ng') " trends)"
}
if ("`trend'" != "") & ("`cce'" != "") {
	display in gr "Note that augmentation of the CCEMG estimator should account for the impact of"
	display in gr "group-specific linear trends. The latter are unidentified."
}
if ("`full'" != ""){
	di
	di
	di _col(25) "Group-specific coefficients"
	di as text "{hline 78}"
	di as text _col(21) ///
		`"Coef.   Std. Err.      z    P>|z|`spaces'[`=strsubdp("`level'")'% Conf. Interval]"'	
	di as text "{hline 13}{c TT}{hline 64}"

	tempname b se tstat pval cv coefs names name col sei
      mat `b' = e(betas)
      mat `se' = e(stebetas)
	mat `tstat' = e(tbetas)	
      scalar `cv' = invnorm(1 - ((100-`level')/100)/2)
      local names : colnames e(betas)
      local coefs : word count `names'
      forvalues i = 1/`ng'{
      	di as text %12s "Group `i'" " {c |} "
            di as text "{hline 13}{c +}{hline 64}"
		forvalues m = 1/`coefs' {
            	local col = 17
            	local name : word `m' of `names'
            	di as text %12s abbrev("`name'",12) " {c |}" as result _col(`col') %9.7g `b'[`i',`m'] _c    
                  local col = `col' + 11
                  if (`se'[`i',`m'] > 0 & `se'[`i',`m'] < .) {
                  	di as res _col(`col') %9.7g `se'[`i',`m'] "   " _c
                  	di as result %6.2f `tstat'[`i',`m'] "   " _continue 
                 		scalar `pval'= 2*(1 - normal(abs(`tstat'[`i',`m'])))
				di as result %5.3f `pval' "    " _c
				di as result %9.7g ( `b'[`i',`m'] - `cv'*`se'[`i',`m']) "   " _continue
				di as result %9.7g ( `b'[`i',`m'] + `cv'*`se'[`i',`m']) _continue
                  	di   
                  }
                  else {
                        di as text _col(36) ///
				".        .       .            .           ."
                  }
           }
	if (`i' < `ng') {
      	di as text "{hline 13}{c +}{hline 64}"
      }
	else {
      	di as text "{hline 13}{c BT}{hline 64}"
		}
}

}


end

exit

