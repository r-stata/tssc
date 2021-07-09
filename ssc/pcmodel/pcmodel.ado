/********************************************************************************/
/* v1.1 : Bug fixed regarding the estimation of the latent trait standard error */
/********************************************************************************/

program define pcmodel, eclass
version 11.0
syntax varlist [if][, CATegorical(string) CONTinuous (string) DIFficulties(string) ITerate(string)  ADapt RObust From(string) RSM ESTimateonly]

preserve
tokenize `varlist' `categorical' `continuous'
local nbit: word count `varlist'
local nbcov: word count `categorical'
local nbcovquant: word count `continuous'
local nbit2:word count `difficulties'
if `nbit2'==0{
	local itest=1
}
else{
	local itest=0
}
if "`from'"!=""{
	local verifFrom=colsof(`from')
}
tempfile bddini
qui{
	save `bddini'pre,replace
	if "`if'"=="" {
		local if "if 1"
	}
	else{
		keep `if'
	}
	local ordre=0
	forvalues i=1/`nbit'{
		tab ``i'', matrow(rep__`i')
		local ordre=`ordre'+`=rowsof(rep__`i')'-1
		forvalues j=1/`=rowsof(rep__`i')'{
			replace ``i''=`j'-1 if ``i''==rep__`i'[`j',1]
		}
	}
	save `bddini'_b,replace
	q memory
}
local matsizeini=r(matsize)
if "`rsm'"!=""{
	local nbtotmodait=rowsof(rep__1)
	forvalues i=2/`nbit'{
		if `=rowsof(rep__`i')'!=`nbtotmodait'{
			noi di in red "The number of item response categories must be equal for each item when using Rating Scale models"
			use `bddini'pre,replace 
			error 100
		}
	}
	if "`difficulties'"!=""{
		noi di in red "RSM option only available for unknow difficulties"
		use `bddini'pre,replace 
		error 100
	}
}
if "`from'"!=""{
	if "`difficulties'"!=""{
		noi di in red "From option only available for unknow difficulties"
		use `bddini'pre,replace 
		error 100
	}
	if "`rsm'"!=""{
		noi di in red "From option only available for the Partial Credit model"
		use `bddini'pre,replace 
		error 100
	}
}

  /*************************************/
 /*		   Verifications			  */
/*************************************/

if "`iterate'"==""{
	local it=""
}
else{
	local iterateII="it(`iterate')"
}
tempvar one id item reponse obs wt x choix it covariable covverytemp
qui save `bddini'_b, replace
if "`difficulties'"!=""{
	if `nbit2'!=`nbit'{
		noi di in red "Not the same number of difficulty vectors and of items"
		use `bddini'pre,replace 
		error 100
	}
	forvalues i=1/`nbit'{
		if strpos("`varlist'",word("`difficulties'",`i'))==0{
			noi di in red "The item difficulty vectors must have the same names than the item variables"
			use `bddini'pre,replace 
			error 100
		}
	}
}
  /*************************************/
 /*	Estimation of the parameters	  */
/*************************************/
local nbtotmodacov=0
if `nbcov'!=0{
	forvalues i=1/`nbcov'{
		qui tab ``=`nbit'+`i''', matrow(nom) matcell(val)
		local nbModCov`i'=r(r)
		forvalues k=1/`nbModCov`i''{
			local valmod`k'cov`i'=nom[`k',1]
			local nbmod`k'cov`i'=val[`k',1]
		}
		local nbtotmodacov=`nbtotmodacov'+`nbModCov`i''
		if `nbModCov`i''>15{
			noi di in ye "Are you sure that ``=`nbit'+`i''' is a categorical variable? (``=`nbit'+`i''' has `nbModCov`i'' categories)"
			noi di in gr ""
		}
		local tot`i'=r(N)
		forvalues k=1/`nbModCov`i''{
			local sum=0
			forvalues k2=1/`nbModCov`i''{
				if `k2'!=`k'{
					local sum=`sum'+val[`k2',1]
				}
			}
			local a`i'_`k'=round((`sum'-`tot`i'')/`tot`i'',0.01)
			local b`i'_`k'=round((`sum')/`tot`i'',0.01)
		}
	}
}
local nbparcov=`nbtotmodacov'+`nbcovquant'
qui{
	keep `varlist' `categorical' `continuous'
	local nbdifftotbis=0
	local nbdifftot=0
	if "`difficulties'"=="" & "`rsm'"==""{
		forvalues i=1/`nbit'{
			gen `reponse'`i' = ``i''
			drop ``i''
			tab `reponse'`i'
			local moda`i'=`=r(r)'
			local nbdifftot=`nbdifftot'+`moda`i''-1
			local nbdifftotbis=`nbdifftotbis'+`moda`i''-1
		}
	}
	else if "`difficulties'"=="" & "`rsm'"!=""{
		forvalues i=1/`nbit'{
			gen `reponse'`i' = ``i''
			drop ``i''
			tab `reponse'`i'
			local moda`i'=`=r(r)'
			local nbdifftot=`nbdifftot'+1
			local nbdifftotbis=`nbdifftotbis'+`moda`i''-1
		}
		local nbdifftot=`nbdifftot'+`nbtotmodait'-2
	}
	else{
		forvalues i=1/`nbit'{
			gen `reponse'`i' = ``i''
			drop ``i''
			local moda`i'=colsof(``i'')+1
		}
	}
	if "`from'"!=""{
		if `nbcov'!=0{
			if `verifFrom'!=`nbtotmodacov'-`nbcov'+1+`nbdifftot'+`nbcovquant'{
				noi di in red "Mismatch between the number of parameters to estimate and the number of provided parameters"
				use `bddini'pre,replace 
				error 100
			}
		}
		else{
			if `verifFrom'!=1+`nbdifftot'+`nbcovquant'{
				noi di in red "Mismatch between the number of parameters to estimate and the number of provided parameters"
				use `bddini'pre,replace 
				error 100
			}
		}
	}
	gen `one'=1
	su `one'
	local Nbid=r(N)
	collapse (sum) `wt'2=`one', by(`reponse'1-`reponse'`nbit' `categorical' `continuous')
	gen `id'=_n
	reshape long `reponse', i(`id') j(`item')
	drop if `reponse'==.	
	ologit `reponse' [fweight=`wt'2]
	local LLL00=e(ll)
	matrix eBLLL00=e(b)	
	gen `obs'=_n
	su `wt'2
	local ddlssIII=r(sum)-1
	forvalues i=1/`nbit'{
		expand `moda`i'' if `item'==`i'
	}
	by `obs', sort: gen `x'=_n-1
	gen `choix'=`reponse'==`x'
	tab `item', gen(`it')
	forvalues i=1/`nbit'{
		forvalues g=1/`=`moda`i''-1'{
			gen d_``i''_`g'=(-1)*`it'`i'*(`x'>=`g')
		}
	}
	forvalues i=1/`nbit'{
		forvalues g=1/`=`moda`i''-1'{
			capture gen __dd_`g'=0
		}
	}
	forvalues i=1/`nbit'{
		forvalues g=1/`=`moda`i''-1'{
			replace  __dd_`g'=(-1)*`it'`i'*(`x'>=`g') if ((-1)*`it'`i'*(`x'>=`g'))<__dd_`g'
		}
	}
	if "`difficulties'"!=""{
		gen difficulties=0
		forvalues i=1/`nbit'{
			forvalues g=1/`=`moda`i''-1'{
				replace difficulties=difficulties+``i''[1,`g']*d_``i''_`g'
			}
		}
	}
	if `nbcov'!=0{
		forvalues i=1/`nbcov'{
			gen `covverytemp'=``=`nbit'+`i'''
			drop ``=`nbit'+`i'''
			rename `covverytemp' ``=`nbit'+`i'''
			tab ``=`nbit'+`i''', gen(``=`nbit'+`i'''__) matrow(nom)
			local nbModCov`i'=r(r)
			forvalues k=1/`nbModCov`i''{
				gen ``=`nbit'+`i'''__`k'_old=``=`nbit'+`i'''__`k'
				order ``=`nbit'+`i'''__`k'_old, first
				replace ``=`nbit'+`i'''__`k'=``=`nbit'+`i'''__`k'*`x'
				local ident`i'_`k'=nom[`k',1]
				if `k'==1 & `i'==1{
					local ident1=`ident`i'_`k''
				}
				rename ``=`nbit'+`i'''__`k' ``=`nbit'+`i'''_`ident`i'_`k''
			}
		}
		forvalues i=1/`nbcov'{
			drop ``=`nbit'+`i'''
		}
	}
	if `nbcovquant'!=0{
		forvalues i=1/`nbcovquant'{
			gen `covverytemp'=``=`nbit'+`nbcov'+`i'''*`x'
			rename ``=`nbit'+`nbcov'+`i''' ``=`nbit'+`nbcov'+`i'''_old
			rename `covverytemp' ``=`nbit'+`nbcov'+`i'''
		}
	}
	rename `id' theta
	rename `x' estimates
}
eq slope:estimates
gen obs=`obs'
gen choix=`choix'
gen wt=`wt'
local contrainte ""
local contrainteit ""
if "`rsm'"!="" & "`difficulties'"==""{
	forvalues i=2/`nbit'{
		forvalues j=2/`=`nbtotmodait'-1'{
			constraint free
			local con=r(free)
			local contrainteit "`contrainteit' `con'"
			constraint `con' d_`1'_`j'-d_`1'_1=d_``i''_`j'-d_``i''_1
		}
	}
}

local offset "offset(difficulties)"
local covariablesit ""
if "`difficulties'"==""{
	local covariablesit "d_`1'_1-d_``nbit''_`=`moda`nbit''-1'"
	local offset ""
}
local nbitdiffpara=0
forvalues i=1/`nbit'{
	forvalues j=1/`=`moda`nbit''-1'{
		local nbitdiffpara=`nbitdiffpara'+1
	}
}
local covariables ""
if `nbcov'!=0{
	local covariables "`covariables' ``=`nbit'+1''_`ident1'-``=`nbit'+`nbcov'''_`ident`nbcov'_`nbModCov`nbcov'''"
	forvalues i=1/`nbcov'{
		constraint free
		local con=r(free)
		local contrainte "`contrainte' `con'"
		constraint `con' ``=`nbit'+`i'''_`ident`i'_1'=0
	}
}
if `nbcovquant'!=0{
	local covariables "`covariables' ``=`nbit'+`nbcov'+1''-``=`nbit'+`nbcov'+`nbcovquant'''"
}
matrix a=(0,0)
local skipcopy "skip"
if "`difficulties'"==""{
	if "`from'"!=""{
		matrix a=`from'
		local skipcopy "copy"
	}
}
gen cons=estimates
local varcons ""
if "`difficulties'"!=""{
	local varcons "cons"
}
  /**********************/
 /*Estimation du modèle*/
/**********************/

unab vars : `covariables' , min(0)
local _c1= `: word count `vars''
local _c2= `: word count `contrainte''
gllamm estimates `varcons' `covariablesit' `covariables' , `offset' i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `adapt' `robust' nocons `iterateII'  nodis   constraint(`contrainteit' `contrainte') from(a) `skipcopy'
local convergeance=e(converged)
matrix eB=e(b)
local nbc=colsof(eB)
matrix eV=e(V)
local nbpar=e(k)
local nbN=e(N)
local LLfull=e(ll)
local ccnn=e(cn)
local dfree_ModComp=`ddlssIII'-`=colsof(eB)'+ wordcount("`contrainteit' `contrainte'")
local SS_ModComp=(eB[1,`=colsof(eB)']^2)*`dfree_ModComp'
local dfree_ModSsCov=`dfree_ModComp'+`nbparcov'- wordcount("`contrainte'")
local ordre=`ordre'- wordcount("`contrainteit'")+1

if "`rsm'"!=""{
	forvalues i=2/`=`moda1'-1'{
		qui lincom d_`1'_`i'-d_`1'_1
		local tau`i'=r(estimate)
		local setau`i'=r(se)
	}
}
qui{
	capture su difficulties
	if _rc==0{
		gen difficultiespost=difficulties
	}
	else{
		gen difficultiespost=0
		local indent=1
		forvalues i=1/`nbit'{
			forvalues g=1/`=`moda`i''-1'{
				replace difficultiespost=difficultiespost+eB[1,`indent']*d_``i''_`g'
				local indent=1+`indent'
			}
		}
	}
	qui gllamm estimates cons , offset(difficultiespost) i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `adapt' `robust' nocons from(eB) skip
	matrix eB_tot=e(b)
	local SS_ModSsCov=(eB_tot[1,`=colsof(eB_tot)']^2)*`dfree_ModSsCov'
}
local mugauss=eB_tot[1,1]
local sdgauss=abs(eB_tot[1,2])
if "`estimateonly'"==""{
	noi di in gr " "
	if `nbcov'+`nbcovquant'!=0{
		noi di "McFadden's pseudo R square and type III Sums of squares computation"
	}
	else{
		noi di "McFadden's pseudo R square computation"
	}

  /**********************************************************/
 /* Modèle nul (juste intercept et effets aléatoires -> R2 */
/**********************************************************/

	qui gllamm estimates __dd_*  , i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `adapt' `robust' nocons `iterateII'  /*nodis*/ from(a) skip
	local LLinterSS=e(ll)
	matrix eB4=e(b)
	local R2Nag=1-(`LLfull'/`LLinterSS')

  /*****************/
 /* Calcul des SS */
/*****************/
	qui{
		local covariables2 ""
		forvalues covs=`=`nbit'+1'/`=`nbit'+`nbcov''{
			local covariables2 "`covariables2' ``covs''_`ident`=`covs'-`nbit''_1'-``covs''_`ident`=`covs'-`nbit''_`nbModCov`=`covs'-`nbit''''"
		}
		forvalues covs=`=`nbit'+`nbcov'+1'/`=`nbit'+`nbcov'+`nbcovquant''{
			local covariables2 "`covariables2' ``covs''"
		}
		if `nbcov'+`nbcovquant'!=0{
			forvalues covs=`=`nbit'+1'/`=`nbit'+`nbcov'+`nbcovquant''{
				noi di "                        for " in ye "``covs''" in gr " covariate"
				if strpos("`categorical'","``covs''")!=0 & "``covs''"!=""{
					local covsans= subinword("`covariables2'","``covs''_`ident`=`covs'-`nbit''_1'-``covs''_`ident`=`covs'-`nbit''_`nbModCov`=`covs'-`nbit''''","",.)
					local dfree_Mss``covs''=`dfree_ModComp'+ `nbModCov`=`covs'-`nbit'''-1
				}
				else{
					local covsans= subinword("`covariables2'","``covs''","",.)
					local dfree_Mss``covs''=`dfree_ModComp'+1
				}
				capture constraint drop `contrainterep' 
				local contrainterep ""
				if `nbcov'!=0{
					forvalues i=1/`nbcov'{
						if `=`nbit'+`i''!=`covs'{
							constraint free
							local con=r(free)
							local contrainterep "`contrainterep' `con'"
							constraint `con' ``=`nbit'+`i'''_`ident`i'_1'=0
						}
					}
				}
				gllamm estimates cons `covsans' , offset(difficultiespost) i(theta) eqs(slope) link(mlogit) expand(`obs' `choix' o) weight(`wt') `adapt' `robust' nocons `iterateII'  /*nodis*/   constraint(`contrainterep') from(eB) skip
				matrix eB``covs''=e(b)
				local SS_Mss``covs''=(eB``covs''[1,`=colsof(eB``covs'')']^2)*`dfree_Mss``covs'''
				local LLfullmoin=e(ll)
				matrix eB4=e(b)
				local R2N_``covs''=1-(`LLfullmoin'/`LLinterSS')
				matrix eB2=e(b)
				local nbpar2=e(k)				
			}
		}
	}
	noi di in gr " "
}
di in gr ""
if "`rsm'"!=""{
	di in gr "Model : " in ye "Rating Scale Model"
}
else{
	di in gr "Model : " in ye "Partial Credit Model"
}
di in gr ""
di in gr "			  log likelihood: " in ye "`LLfull'"
local lll=e(ll)
if "`estimateonly'"==""{
	di in gr "			  Marginal McFadden's pseudo R2: " in ye %4.1f `=`R2Nag'*100' "%"
}
di in gr "			  Number of individuals: "in ye "`Nbid'"
di in gr "			  Number of items: "in ye "`nbit'"
if `=`nbcov'+`nbcovquant''!=0{
	di in gr "			  Number of covariates: "in ye "`=`nbcov'+`nbcovquant''"
}
di in gr ""
di ""
di in gr "Parameters of the Latent trait distribution:"
di ""
if "`difficulties'"==""{
	if `=`nbcov'+`nbcovquant''!=0{
		local subgroup0 ""
		if `nbcov'!=0{
			forvalues i=1/`nbcov'{
				local subgroup0 "`subgroup0'``=`nbit'+`i''' = `ident`i'_1', "
			}	
		}
		if `nbcovquant'!=0{
			forvalues i=1/`nbcovquant'{
				local subgroup0 "`subgroup0'``=`nbit'+`nbcov'+`i''' = 0, "
			}
		}
		local subgroup0b "`=reverse(subinstr(reverse("`subgroup0'"), ",", ":", 1))'"
		
		di in gr "			  Identifiability constraint: latent trait for `subgroup0b'set to 0"
	}
	else{
		di in gr "			  Identifiability constraint: overall latent trait mean set to 0"
	}
}
di in gr "			  Variance of the Latent trait: Sigma²=" in ye %8.5f (`=`=eB[1,`nbc']'')^2 in gr " (SE:"in ye %8.5f `= sqrt((2*`=eB[1,`nbc']')^2 *`=eV[`nbc',`nbc']'	)' in gr ")"
local varTheta=(`=`=eB[1,`nbc']'')^2
local Varvartheta=(2*`=eB[1,`nbc']')^2 *`=eV[`nbc',`nbc']'
di ""
if `nbcov'+`nbcovquant'!=0{
	di in gr "Latent trait group effect:"
	di ""
	di in gr "{hline 101}"
	di _col(20) in gr "Coef." _col(30) in gr "S.E." _col(41) in gr "z" _col(45) in gr "P>|z|" _col(57) in gr "[95% C.I.]" /*_col(71) in gr "D.St."*/ _col(73) in gr "SS.III" _col(81) in gr "df" _col(85) in gr "V.exp." _col(95) in gr "R2.exp."
	di in gr "{hline 101}"
	local compteur=1
	if "`difficulties'"==""{
		local compteur=`nbdifftotbis'
	}
if `nbcov'!=0{
	forvalues i=`=`nbit'+1'/`=`nbit'+`nbcov''{
		local ss3=.
		local df=.
		local vexp=.
		local r2exp=.
		if "`estimateonly'"==""{
			local ss3=`SS_Mss``i'''-`SS_ModComp'
			local df=`dfree_Mss``i'''-`dfree_ModComp'
			local vexp=(`SS_Mss``i'''-`SS_ModComp')/`SS_Mss``i'''*100
			local r2exp=(`R2Nag'-`R2N_``i''')/`R2Nag'*100
		}
		local compteur=`compteur'+1
		noi{
			di _col(1) in gr "``i'':"  _col(72) in ye %6.3f `ss3'	 _col(81) in ye %2.0f  `df'  _col(84) in ye %6.1f `vexp' "%"    _col(94) in ye %6.1f  `r2exp' "%"
			di _col(4) in gr "`=abbrev("``i''",10)':" in ye " `ident`=`i'-`nbit''_1'" _col(24) in ye  "0" _col(33) in ye "." _col(41) in ye "." _col(49) in ye "." _col(57) in ye "." _col(66) in ye "."	/*_col(75) in ye "."*/   
		}
		forvalues k=2/`nbModCov`=`i'-`nbit'''{
			local compteur=`compteur'+1
			local estimate_e=eB[1,`compteur']
			local se_e=sqrt(`=eV[`compteur',`compteur']')
			noi{
				di _col(4) in gr "`=abbrev("``i''",10)':" in ye " `ident`=`i'-`nbit''_`k''" _col(19) in ye %6.3f `estimate_e' _col(28) in ye %6.3f `se_e' _col(37) in ye %5.2f `=`estimate_e'/`se_e'' _col(44) in ye %6.3f `=2*(1-normal(abs(`estimate_e'/`se_e')))'  _col(52) in ye %6.3f `=`estimate_e'-1.96*`se_e'' _col(61) in ye %6.3f `=`estimate_e'+1.96*`se_e''	 /*_col(70) in ye %6.3f `ESit`=`i'+`nbit''mod`k''*/
			}
		}
		di in gr "{hline 101}"
	}
}	
if `nbcovquant'!=0{
	forvalues i=`=`nbit'+`nbcov'+1'/`=`nbit'+`nbcov'+`nbcovquant''{
		local ss3=.
		local df=.
		local vexp=.
		local r2exp=.
		if "`estimateonly'"==""{
			local ss3=`SS_Mss``i'''-`SS_ModComp'
			local df=`dfree_Mss``i'''-`dfree_ModComp'
			local vexp=(`SS_Mss``i'''-`SS_ModComp')/`SS_Mss``i'''*100
			local r2exp=(`R2Nag'-`R2N_``i''')/`R2Nag'*100
		}
		local compteur=`compteur'+1
			local estimate_e=eB[1,`compteur']
			local se_e=sqrt(`=eV[`compteur',`compteur']')
		noi{		
			di _col(1) in gr "``i'':" _col(19) in ye %6.3f `estimate_e' _col(28) in ye %6.3f `se_e' _col(37) in ye %5.2f `=`estimate_e'/`se_e'' _col(44) in ye %6.3f `=2*(1-normal(abs(`estimate_e'/`se_e')))'  _col(52) in ye %6.3f `=`estimate_e'-1.96*`se_e'' _col(61) in ye %6.3f `=`estimate_e'+1.96*`se_e''   _col(72) in ye %6.3f `ss3'	 _col(81) in ye %2.0f  `df'  _col(84) in ye %6.1f `vexp' "%"    _col(94) in ye %6.1f  `r2exp' "%"
		}
		di in gr "{hline 101}"
	}
}	
if "`difficulties'"!=""{
	di _col(1) in gr "_Cons" _col(19) in ye %6.3f `=eB[1,1]' _col(28) in ye %6.3f `=sqrt(eV[1,1])' _col(37) in ye %5.2f `=`=eB[1,1]'/`=sqrt(eV[1,1])'' _col(44) in ye %6.3f `=2*(1-normal(abs(`=eB[1,1]'/`=sqrt(eV[1,1])')))'  _col(52) in ye %6.3f `=`=eB[1,1]'-1.96*`=sqrt(eV[1,1])'' _col(61) in ye %6.3f `=`=eB[1,1]'+1.96*`=sqrt(eV[1,1])''
	di in gr "{hline 101}"
}
		local sssc=.
		local dfsc=.
		local ssac=.
		local dfac=.
		if "`estimateonly'"==""{
			local sssc=`SS_ModSsCov'
			local dfsc=`dfree_ModSsCov'
			local ssac=`SS_ModComp'
			local dfac=`dfree_ModComp'
		}
	di _col(73) in gr "SS.res" _col(84) in gr "df"
	di _col(45) in gr "Model without covariates" _col(72) in ye %6.3f `sssc'  _col(81) in ye %5.0f `dfsc'
	di _col(59) in gr "Full model" _col(72) in ye %6.3f `ssac'  _col(81) in ye %5.0f `dfac'
	di in gr "{hline 101}"
	di ""
}
else if "`difficulties'"!=""{
	di in gr "Latent trait distribution"
	di in gr "{hline 85}"
	di _col(23) in gr "Coef." _col(36) in gr "S.E." _col(48) in gr "z" _col(57) in gr "P>|z|" _col(66) in gr "[95% Conf. Interval]"
	di in gr "{hline 85}"
	di _col(1) in gr "Mu" _col(20) in ye %8.5f `=eB[1,1]' _col(32) in ye %8.5f `=sqrt(eV[1,1]) ' _col(44) in ye %5.2f `=`=eB[1,1]'/`=sqrt(eV[1,1]) '' _col(56) in ye %6.3f `=2*(1-normal(abs(`=eB[1,1]'/`=sqrt(eV[1,1]) ')))'  _col(66) in ye %8.5f `=`=eB[1,1]'-1.96*`=sqrt(eV[1,1]) '' _col(78) in ye %8.5f `=`=eB[1,1]'+1.96*`=sqrt(eV[1,1]) ''
	
	di _col(1) in gr "Sigma" _col(20) in ye %8.5f `=eB[1,`nbc']' _col(32) in ye %8.5f `=sqrt(`=eV[`nbc',`nbc']')' _col(44) in ye %5.2f `=eB[1,`nbc']/sqrt(`=eV[`nbc',`nbc']')' _col(56) in ye %6.3f `=2*(1-normal(abs(eB[1,`nbc']/sqrt(`=eV[`nbc',`nbc']'))))'  _col(66) in ye %8.5f `=eB[1,`nbc']-1.96*sqrt(`=eV[`nbc',`nbc']')' _col(78) in ye %8.5f `=eB[1,`nbc']+1.96*sqrt(`=eV[`nbc',`nbc']')'
	di in gr "{hline 85}"
	di ""
}	
if "`difficulties'"==""{ 
	di in gr "Items difficulty parameters:"
	di ""
	di in gr "{hline 52}"
	di _col(1) in gr "Item"  _col(21) in gr "Coef." _col(31) in gr "S.E."   _col(43) in gr "[95% C.I.]" _col(66) 
	di in gr "{hline 52}"
	local compteur=1
	if "`rsm'"==""{
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'':" 
			forvalues g=1/`=`moda`i''-1'{
				di _col(4) in gr "response:" in ye " `=round(`=rep__`i'[`=`g'+1',1]',0.1)'" _col(20) in ye %6.3f `=eB[1,`compteur']' _col(29) in ye %6.3f `=sqrt(`=eV[`compteur',`compteur']')'   _col(38) in ye %6.3f `=eB[1,`compteur']-1.96*sqrt(`=eV[`compteur',`compteur']')' _col(47) in ye %6.3f `=eB[1,`compteur']+1.96*sqrt(`=eV[`compteur',`compteur']')' 
				local compteur=`compteur'+1
			}
			di in gr "{hline 52}"
		}
		di ""
	}
	else{
		forvalues i=1/`nbit'{
			di _col(1) in gr "``i'':"   _col(20) in ye %6.3f `=eB[1,`compteur']' _col(29) in ye %6.3f `=sqrt(`=eV[`compteur',`compteur']')'   _col(38) in ye %6.3f `=eB[1,`compteur']-1.96*sqrt(`=eV[`compteur',`compteur']')' _col(47) in ye %6.3f `=eB[1,`compteur']+1.96*sqrt(`=eV[`compteur',`compteur']')' 
			local compteur=`compteur'+`=`moda1'-1'
		}
		di in gr "{hline 52}"
		forvalues i=2/`=`moda1'-1'{
			di _col(1) in gr "tau`=`i'-1':"  _col(20) in ye %6.3f `tau`i'' _col(29) in ye %6.3f `setau`i''   _col(38) in ye %6.3f `=`tau`i''-1.96*`setau`i''' _col(47) in ye %6.3f `=`tau`i''+1.96*`setau`i''' 
		}
		di in gr "{hline 52}"
	}
}
else{
	di in gr "Items difficulty parameters: fixed for the analysis"
}

  /*************************************/
 /*	             ereturn              */
/*************************************/

qui{
	if "`difficulties'"==""{ 

		matrix Varbeta=eV
		local Varsigma=Varbeta[`=colsof(Varbeta)',`=colsof(Varbeta)']
		matrix Vardelta=Varbeta[1..`nbdifftotbis',1..`nbdifftotbis']
		matrix beta=eB
		local sigma=abs(beta[1,`=colsof(beta)'])
		matrix delta=beta[1,1..`nbdifftotbis']
		if `=`nbcov'+`nbcovquant''!=0{
			matrix Vartheta=Varbeta[`=`nbdifftotbis'+1'..`=colsof(Varbeta)-1',`=`nbdifftotbis'+1'..`=colsof(Varbeta)-1']
			matrix theta=beta[1,`=`nbdifftotbis'+1'..`=colsof(beta)-1']
		}
		else{
			local theta=0
			local Vartheta=0
		}
	}
	else{ 
		if `=`nbcov'+`nbcovquant''!=0{
			matrix Vartheta=eV
			local Varsigma=Vartheta[`=colsof(Vartheta)',`=colsof(Vartheta)']
			matrix Vartheta=Vartheta[1..`=colsof(Vartheta)-1',1..`=colsof(Vartheta)-1']
			matrix theta=eB
			local sigma=abs(theta[1,`=colsof(theta)'])
			matrix theta=theta[1,1..`=colsof(theta)-1']
		}
		else{
			matrix theta=eB
			local sigma=abs(theta[1,`=colsof(theta)'])
			matrix Vtheta=eV
			local Varsigma=Vtheta[`=colsof(Vtheta)',`=colsof(Vtheta)']
			local theta=theta[1,1]
			local vartheta=Vtheta[1,1]
		}
	}
	ereturn clear
	if `=`nbcov'+`nbcovquant''!=0{
		matrix b=theta
		matrix V=Vartheta
		ereturn post b V, depname(theta)
	}
	else{
		if "`difficulties'"==""{
			matrix V=(0)
			matrix coleq V=estimates
			matrix coln V=mu
			matrix roweq V=estimates
			matrix rown V=mu
			matrix b=(0)
			matrix coleq b=estimates
			matrix coln b=mu
			matrix rown b=y1
			ereturn post b V, depname(theta)
		}
		else{
			matrix V=(`vartheta')
			matrix coleq V=estimates
			matrix coln V=mu
			matrix roweq V=estimates
			matrix rown V=mu
			matrix b=(`theta')
			matrix coleq b=estimates
			matrix coln b=mu
			matrix rown b=y1
			ereturn post b V, depname(theta)
		}
	}
	ereturn scalar mll=`LLfull'
	ereturn scalar cn=`ccnn'
	ereturn scalar N=`Nbid'
	ereturn scalar Nit=`nbit'
	ereturn scalar converged=`convergeance'
	ereturn local items `varlist'
	ereturn local itest `itest'
	ereturn local datatest `bddini'_b
	ereturn local mugauss `mugauss'
	ereturn local sdgauss `sdgauss'
	ereturn local cmd "pcmodel"
	ereturn local order `ordre'
	if `=`nbcov'+`nbcovquant''!=0{
		ereturn scalar Ncat=`nbcov'
		ereturn scalar Ncont=`nbcovquant'
	}
	if "`difficulties'"==""{
		ereturn matrix Vardelta=Vardelta
		ereturn matrix delta=delta
		ereturn scalar sigma=`sigma'
		ereturn scalar Varsigma=`Varsigma'
	}
	else{ 
		if `=`nbcov'+`nbcovquant''!=0{
			ereturn scalar sigma=`sigma'
			ereturn scalar Varsigma=`Varsigma'
		}
		else{
			ereturn scalar sigma=`sigma'
			ereturn scalar Varsigma=`Varvartheta'
		}
	}
}
use `bddini'pre, replace
restore
end
