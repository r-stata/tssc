* weakiv cert script MS 15June2015

cscript weakiv adofile weakiv

clear all
capture log close
set more off
set rmsg on

log using cs_weakiv_2405, replace
about
which weakiv
which ivreg2
which avar
which livreg2.mlib
* expect condivreg version:		*! Version 2.0.6  17may2006
which condivreg
* expect surface version:		*! Date    : 31 Jul 2013
*								*! Version : 1.06
which surface
weakiv, version
assert "`e(version)'" == "02.4.05"
* weakiv cert script may run correctly with earlier or later versions, hence "cap noi"
ivreg2, version
cap noi assert "`e(version)'" == "04.1.02"
avar, version
cap noi assert "`r(version)'" == "01.0.06"
xtivreg2, version
cap noi assert "`e(version)'" == "01.0.16"

**********************************************************************
************************ CX AND CLUSTER ******************************
**********************************************************************

use http://www.stata.com/data/jwooldridge/eacsap/mroz.dta, clear
cap drop poshours
gen byte poshours=(hours>0)
gen byte one=1

**********************************************************************
* VCE and other opts
* Wald and LM AR stats by hand
tempvar ytilda
gen double `ytilda'=.
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small"	{
		foreach null of numlist 0 0.1 {
			foreach wt in " " "[fw=educ]" "[aw=unem]" "[pw=unem]" {
				di "opt=`opt' null=`null' `small' weight=`wt'"
				qui ivreg2 lwage exper expersq (educ = fatheduc motheduc) `wt', `opt' `small'
				qui test (educ=`null')
				scalar Wa=r(chi2)
				if Wa==. {
					scalar Wa=r(F)
				}
				qui weakiv, null(`null') md
				scalar ARa=e(ar_chi2)
				qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc) `wt', `opt' `small' null(`null') md noci
				assert reldif(Wa,e(wald_chi2))< 1e-7
				scalar ARb=e(ar_chi2)
				qui replace `ytilda' = lwage - `null'*educ
				qui ivreg2 `ytilda' exper expersq fatheduc motheduc `wt', `opt' `small'
				qui test fatheduc motheduc
				scalar ARc=r(chi2)
				if ARc==. {
					scalar ARc = r(F)*r(df)
				}
				assert reldif(ARa,ARc)< 1e-7
				assert reldif(ARb,ARc)< 1e-7
				qui ivreg2 `ytilda' exper expersq (=fatheduc motheduc) `wt', `opt' `small'
				scalar ARd=e(j)
				if "`small'"=="small" & "`e(clustvar)'"=="" {
					scalar ARd = ARd * (e(N)-e(inexog_ct)-e(exexog_ct)-e(cons))/e(N)
				}
				else if "`small'"=="small" {
					scalar ARd = ARd * (e(N)-e(inexog_ct)-e(exexog_ct)-e(cons))/(e(N)-1)*(e(N_clust)-1)/e(N_clust)
				}
				qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc) `wt', `opt' `small' null(`null') noci
				scalar ARe=e(ar_chi2)
				assert reldif(ARd,ARe)< 1e-7
			}
		}
	}
}
**********************************************************************
* ivreg2 vs ivregress
foreach opt in " " "rob" "cluster(age)"							///
				"nocons" "nocons rob" "nocons cluster(age)"		{
	foreach small in " " "small"	{
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null' `small'"
			qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`null') md
			savedresults save wivreg2 e()
			qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`null') md
			savedresults comp wivreg2 e(), tol(1e-10) exclude(macros: waldcmd)
		}
	}
}
**********************************************************************
* ivreg2 vs xtivreg2
cap drop id*
cap drop t
gen id=ceil(_n/8)
gen t=8*id-_n
xtset id t
qui tab id if inlf, gen(id_)
* Fixed effects
local dofminus = r(r)
foreach opt in " " "rob" "cluster(id)"	{
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null'"
* use partial to eliminate error message when estimating main model
			qui weakiv ivreg2 lwage exper expersq id_* (educ = fatheduc motheduc), `opt' null(`null') partial(id_*) nocons dofminus(`dofminus') md
			savedresults save wivreg2 e()
			qui weakiv xtivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' null(`null') fe md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: inexog xtmodel waldcmd scalars: N_g singleton)
	}
}
* First differences
foreach opt in " " "rob" "cluster(id)"	{
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null'"
			qui weakiv ivreg2 D.lwage D.exper D.expersq (D.educ = D.fatheduc D.motheduc), `opt' null(`null') md
			savedresults save wivreg2 e()
			qui weakiv xtivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' null(`null') fd md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: xtmodel waldcmd scalars: N_g singleton)
	}
}
* Compared with official xtivreg - requires small option - iid only
* Also checks small option
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null'"
			qui weakiv ivreg2 lwage exper expersq id_* (educ = fatheduc motheduc), null(`null') partial(id_* exper expersq) nocons small md
			savedresults save wivreg2 e()
			qui weakiv xtivreg2 lwage exper expersq (educ = fatheduc motheduc), null(`null') fe small md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: inexog xtmodel waldcmd scalars: N_g singleton)
			qui weakiv xtivreg lwage exper expersq (educ = fatheduc motheduc), null(`null') fe small md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: inexog xtmodel waldcmd scalars: N_g singleton)
	}
* First differences
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null'"
			qui weakiv ivreg2 D.lwage D.exper D.expersq (D.educ = D.fatheduc D.motheduc), `opt' null(`null') small md
			savedresults save wivreg2 e()
			qui weakiv xtivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' null(`null') fd small md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: inexog xtmodel waldcmd scalars: N_g singleton)
			qui weakiv xtivreg lwage exper expersq (educ = fatheduc motheduc), `opt' null(`null') fd small md
			savedresults comp wivreg2 e(), tol(1e-7) exclude(macros: inexog xtmodel waldcmd scalars: N_g singleton)
	}

**********************************************************************
* forcerobust option causes general robust code to calculate stats for iid case
* Compare with results produced by iid-specific code
foreach small in " " "small"	{
	foreach null of numlist 0 0.1 {
		di "null=`null' `small'"
		qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), `small' null(`null') md
		scalar wald_chi2=e(wald_chi2)
		scalar ar_chi2=e(ar_chi2)
		scalar k_chi2=e(k_chi2)
		scalar clr_stat=e(clr_stat)
		scalar kj_p=e(kj_p)
		qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), forcerobust `small' null(`null') md
		assert reldif(wald_chi2,e(wald_chi2))< 1e-7
		assert reldif(ar_chi2,e(ar_chi2))< 1e-7
		assert reldif(k_chi2,e(k_chi2))< 1e-7
		assert reldif(clr_stat,e(clr_stat))< 1e-7
		assert reldif(kj_p,e(kj_p))< 1e-7
	}
}
**********************************************************************
* Vs. condivreg (homoskedastic case)
* condivreg uses different (wrong) df - double-counts constant - so use explicit constant+nocons
foreach null of numlist 0 0.1 {
	di "null=`null'"
	qui condivreg lwage exper expersq one (educ = fatheduc motheduc), ar lm nocons noinstcons test(`null')
	scalar ar_chi2=invchi2tail(2, e(p_AR))
	scalar k_chi2=invchi2tail(1, e(p_LM))
	scalar clr_p=e(p_LR)
	qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), small null(`null') md
	assert reldif(ar_chi2,e(ar_chi2))< 1e-7
	assert reldif(k_chi2,e(k_chi2))< 1e-7
	assert reldif(clr_p,e(clr_p))<1e-7
}
**********************************************************************
* K=0 and CLR=0 at LIML and CUE b0
qui ivreg2 lwage exper expersq (educ = fatheduc motheduc), cue
local b0=_b[educ]
qui weakiv, null(`b0') md
assert reldif(e(k_chi2),0)< 1e-10
assert reldif(e(clr_stat),0)< 1e-10
* Diff model and low-ish tolerance because of numerical accuracy issues with cluster VCV
foreach opt in " " "rob" "cluster(age)" "cluster(age exper)" {
	di "opt=`opt'"
	qui ivreg2 exper (educ = fatheduc motheduc), `opt' cue
	local b0=_b[educ]
	qui weakiv, null(`b0') md
	assert reldif(e(k_chi2),0)< 1e-4
	assert reldif(e(clr_stat),0)< 1e-4
}
**********************************************************************
* Numerical vs. grid search
* Check grid options too
qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), md
savedresults save numerical e()
qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), usegrid gridpoints(800) md
assert "`e(grid_descript)'"=="[-.061256, .184049]"
savedresults comp numerical e(), include(		///
	scalar: ar_chi2 clr_stat k_chi2 j_chi2)		///
	tol(1e-7)
qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), usegrid gridpoints(800) gridmult(1) md
assert "`e(grid_descript)'"=="[  .00007, .122723]"
savedresults comp numerical e(), include(		///
	scalar: ar_chi2 clr_stat k_chi2 j_chi2)		///
	tol(1e-7)
qui ivreg2 lwage exper expersq (educ = fatheduc motheduc)
qui weakiv, md
savedresults save numerical e()
qui ivreg2 lwage exper expersq (educ = fatheduc motheduc)
qui weakiv, usegrid gridpoints(800) md
savedresults comp numerical e(), include(		///
	scalar: ar_chi2 clr_stat k_chi2 j_chi2)		///
	tol(1e-7)
qui weakiv ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), gridmin(-1) gridmax(1) md
assert "`e(grid_descript)'"=="[      -1,       1]"
**********************************************************************
* Vs. original rivtest
* Linear model, various VCVs, ivreg2 and ivregress
foreach opt in " " "rob" "cluster(age)" {
	foreach small in " " "small"	{
		foreach null of numlist 0 0.1 {
			di "opt=`opt' null=`null' `small'"
			qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' null(`null') `small' md
			scalar Wald_chi2=e(wald_chi2)
			scalar AR_chi2=e(ar_chi2)
			scalar K_chi2=e(k_chi2)
			scalar CLR_chi2=e(clr_chi2)
			qui ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small'
			qui rivtest, null(`null')
			assert reldif(Wald_chi2,r(wald_chi2))< 1e-7
			assert reldif(AR_chi2,r(ar_chi2))< 1e-7
			assert reldif(K_chi2,r(lm_chi2))< 1e-7
			assert reldif(CLR_chi2,r(clr_chi2))< 1e-7
			qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), `opt' `small'
			qui rivtest, null(`null')
			assert reldif(Wald_chi2,r(wald_chi2))< 1e-7
			assert reldif(AR_chi2,r(ar_chi2))< 1e-7
			assert reldif(K_chi2,r(lm_chi2))< 1e-7
			assert reldif(CLR_chi2,r(clr_chi2))< 1e-7
		}
	}
}
* ivprobit
qui weakiv ivprobit poshours exper expersq (educ = fatheduc motheduc), twostep
scalar Wald_chi2=e(wald_chi2)
scalar AR_chi2=e(ar_chi2)
scalar K_chi2=e(k_chi2)
scalar CLR_chi2=e(clr_chi2)
local CLR_cset "`e(clr_cset)'"
local K_cset "`e(k_cset)'"
local AR_cset "`e(ar_cset)'"
qui ivprobit poshours exper expersq (educ = fatheduc motheduc), twostep
qui rivtest, ci
assert reldif(Wald_chi2,r(wald_chi2))< 1e-6
assert reldif(AR_chi2,r(ar_chi2))< 1e-6
assert reldif(K_chi2,r(lm_chi2))< 1e-6
assert reldif(CLR_chi2,r(clr_chi2))< 1e-6
assert "`CLR_cset'"=="`r(clr_cset)'"
assert "`K_cset'"=="`r(lm_cset)'"
assert "`AR_cset'"=="`r(ar_cset)'"
* ivtobit
qui weakiv ivtobit hours exper expersq (educ = fatheduc motheduc), ll
scalar Wald_chi2=e(wald_chi2)
scalar AR_chi2=e(ar_chi2)
scalar K_chi2=e(k_chi2)
scalar CLR_chi2=e(clr_chi2)
local CLR_cset "`e(clr_cset)'"
local K_cset "`e(k_cset)'"
local AR_cset "`e(ar_cset)'"
qui ivtobit hours exper expersq (educ = fatheduc motheduc), ll
qui rivtest, ci
assert reldif(Wald_chi2,r(wald_chi2))< 1e-8
assert reldif(AR_chi2,r(ar_chi2))< 1e-8
assert reldif(K_chi2,r(lm_chi2))< 1e-8
assert reldif(CLR_chi2,r(clr_chi2))< 1e-8
assert "`CLR_cset'"=="`r(clr_cset)'"
assert "`K_cset'"=="`r(lm_cset)'"
assert "`AR_cset'"=="`r(ar_cset)'"
**********************************************************************
* Check non-graphics options work
* estadd after previous estimation
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, estadd
assert "`e(cmd)'"=="ivregress"
assert "`e(clr_cset)'"=="[-.008238, .125776]"
weakiv, estadd(prefix_) level(90) eststore(mymodel)
assert "`e(cmd)'"=="ivregress"
assert "`e(prefix_clr_cset)'"=="[ .002957, .115426]"
* display Wald model
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, display md
* use stored model
est drop _all
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
est store mymodel
ereturn clear
ereturn list
est dir
* store wald model
est drop _all
est dir
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, eststore(mymodel) md
est dir
* Misc
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, noci md
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, ci md		// legacy option, has no effect in 1-endog-regressor case
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, md retmat	// legacy option, has no effect
**********************************************************************
* Check graphics options work
qui ivreg2 lwage exper expersq (educ = fatheduc motheduc)
weakiv, graph(wald ar k j kj clr) md
weakiv, graph(wald ar k j kj clr) graphxrange(0 0.1)
weakiv, graph(wald ar k j kj clr) graphopt(title("All 6 stats"))
weakiv, level(95 90 80) graph(wald ar k) graphopt(title("3 stats only, 3 levels"))
qui ivregress 2sls lwage exper expersq (educ = fatheduc motheduc), rob
weakiv, graph(wald ar k j kj clr) graphopt(title("All 6 stats")) md
qui ivprobit poshours exper expersq (educ = fatheduc motheduc), twostep
weakiv, graph(wald ar k j kj clr) graphopt(title("All 6 stats")) md
qui ivtobit hours exper expersq (educ = fatheduc motheduc), ll
weakiv, graph(wald ar k j kj clr) graphopt(title("All 6 stats")) md
**********************************************************************
* Check intervals vs. condivreg
* condivreg has bug in df code with constant so use col of ones and nocons options
qui condivreg lwage exper expersq one (educ = fatheduc motheduc), ar lm nocons noinstcons
scalar AR_x1=e(AR_x1)
scalar AR_x2=e(AR_x2)
scalar CLR_x1=e(LR_x1)
scalar CLR_x2=e(LR_x2)
scalar K_x1=e(LM_x1)
scalar K_x2=e(LM_x2)
qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), small md
tokenize "`e(clr_cset)'", parse(" [,]")
local nulla_clr = `2'
local nullb_clr = `4'
tokenize "`e(ar_cset)'", parse(" [,]")
local nulla_ar = `2'
local nullb_ar = `4'
tokenize "`e(k_cset)'", parse(" [,]")
local nulla_k = `2'
local nullb_k = `4'
assert reldif(AR_x1,`nulla_ar')< 1e-5
assert reldif(AR_x2,`nullb_ar')< 1e-5
assert reldif(CLR_x1,`nulla_clr')< 1e-5
assert reldif(CLR_x2,`nullb_clr')< 1e-5
assert reldif(K_x1,`nulla_k')< 1e-5
assert reldif(K_x2,`nullb_k')< 1e-5
**********************************************************************
* Check endpoints of confidence intervals
* Non-iid case uses grid search so tolerance is set low.
foreach opt in " " "rob" "cluster(age)" {
	foreach small in " " "small"	{
		if "`opt'"==" " {
			qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `small' md
		}
		else {
			qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' gridpoints(800) md
		}
		tokenize "`e(clr_cset)'", parse(" [,]")
		local nulla_clr = `2'
		local nullb_clr = `4'
		tokenize "`e(ar_cset)'", parse(" [,]")
		local nulla_ar = `2'
		local nullb_ar = `4'
		tokenize "`e(k_cset)'", parse(" [,]")
		local nulla_k = `2'
		local nullb_k = `4'
		di "opt=`opt' `small' nulla_clr=`nulla_clr'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nulla_clr') noci md
		if "`opt'"==" " {
			assert reldif(e(clr_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(clr_p),0.05)< 5e-2
		}
		di "opt=`opt' `small' nullb_clr=`nullb_clr'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nullb_clr') noci md
		if "`opt'"==" " {
			assert reldif(e(clr_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(clr_p),0.05)< 5e-2
		}
		di "opt=`opt' `small' nulla_ar=`nulla_ar'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nulla_ar') noci md
		if "`opt'"==" " {
			assert reldif(e(ar_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(ar_p),0.05)< 5e-2
		}
		di "opt=`opt' `small' nullb_ar=`nullb_ar'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nullb_ar') noci md
		if "`opt'"==" " {
			assert reldif(e(ar_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(ar_p),0.05)< 5e-2
		}
		di "opt=`opt' `small' nulla_l=`nulla_k'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nulla_k') noci md
		if "`opt'"==" " {
			assert reldif(e(k_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(k_p),0.05)< 5e-2
		}
		di "opt=`opt' `small' nullb_k=`nullb_k'"
		qui weakiv ivreg2 lwage exper expersq (educ = fatheduc motheduc), `opt' `small' null(`nullb_k') noci md
		if "`opt'"==" " {
			assert reldif(e(k_p),0.05)< 1e-5
		}
		else {
			assert reldif(e(k_p),0.05)< 5e-2
		}
	}
}

**********************************************************************
* Catch various errors
* ivprobit requires twostep option
qui ivprobit poshours exper expersq (educ = fatheduc motheduc)
cap noi weakiv
rcof "weakiv" == 198
cap noi weakiv ivprobit poshours exper expersq (educ = fatheduc motheduc)
rcof "weakiv" == 198
* ivprobit and ivtobit require iid - no robust or cluster
foreach opt in "rob" "cluster(age)" {
	di "opt=`opt'"
	rcof "weakiv ivprobit poshours exper expersq (educ = fatheduc motheduc), twostep `opt'" == 198
	qui ivtobit hours exper expersq (educ = fatheduc motheduc), ll `opt'
	rcof "weakiv" == 198
	rcof "weakiv ivtobit hours exper expersq (educ = fatheduc motheduc), ll `opt'
}

**********************************************************************

**********************************************************************
******************************* K=2 **********************************
**********************************************************************
* VCE and other opts
* Wald AR stat by hand
tempvar ytilda
gen double `ytilda'=.
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small"	{
		foreach null1 of numlist 0 0.1 {
			foreach null2 of numlist 0 0.1 {
				di "opt=`opt' `small' null1=`null1' null2=`null2'"
				qui ivreg2 lwage exper expersq (educ hours = fatheduc motheduc hushrs), `opt' `small'
				qui test (educ=`null1') (hours=`null2')
				scalar Wa=r(chi2)
				if Wa==. {
					scalar Wa=r(F)*r(df)
				}
				qui weakiv, null(`null1' `null2') md
				scalar ARa=e(ar_chi2)
				qui weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc hushrs),	///
					`opt' `small' null(`null1' `null2') md
				assert reldif(Wa,e(wald_chi2))< 1e-7
				scalar ARb=e(ar_chi2)
				qui replace `ytilda' = lwage - `null1'*educ - `null2'*hours
				cap ivreg2 `ytilda' exper expersq fatheduc motheduc hushrs, `opt' `small'		// cap because of non-full-rank warning
				qui test fatheduc motheduc hushrs
				scalar ARc=r(chi2)
				if ARc==. {
					scalar ARc = r(F)*r(df)
				}
				assert reldif(ARa,ARc)< 1e-7
				assert reldif(ARb,ARc)< 1e-7
			}
		}
	}
}
**********************************************************************
* forcerobust option forces robust code to calculate iid stat - should match
foreach small in " " "small"	{
	foreach null1 of numlist 0 0.1 {
		foreach null2 of numlist 0 0.1 {
			di "null1=`null1' null2=`null2'"
			qui weakiv ivregress 2sls lwage exper expersq (educ hours = fatheduc motheduc hushrs), `small' null(`null1' `null2') md
			scalar wald_chi2=e(wald_chi2)
			scalar ar_chi2=e(ar_chi2)
			scalar k_chi2=e(k_chi2)
			scalar clr_stat=e(clr_stat)
			scalar kj_p=e(kj_p)
			qui weakiv ivregress 2sls lwage exper expersq (educ hours = fatheduc motheduc hushrs), forcerobust `small' null(`null1' `null2') md
			assert reldif(wald_chi2,e(wald_chi2))< 1e-7
			assert reldif(ar_chi2,e(ar_chi2))< 1e-7
			assert reldif(k_chi2,e(k_chi2))< 1e-7
			assert reldif(clr_stat,e(clr_stat))< 1e-7
			assert reldif(kj_p,e(kj_p))< 1e-7
		}
	}
}
**********************************************************************
* strong(.) option; replicate by hand.
* H0: beta1=0.01, 1 weak 1 strong
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	di "opt=`opt'"
	qui ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), `opt'
	qui test hours=0.01
	scalar wald_chi2=r(chi2)
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours
	qui ivreg2 ytilda exper expersq (educ = fatheduc motheduc hushrs), `opt' gmm2s
	global b2=_b[educ]
	qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01 $b2) `opt' md noci
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01) strong(educ) `opt' md noci
	assert reldif(wald_chi2,e(wald_chi2))< 1e-7
	assert reldif(ar_chi2,e(ar_chi2))< 1e-7
	assert reldif(k_chi2,e(k_chi2))< 1e-7
	assert reldif(j_chi2,e(j_chi2))< 1e-7
}

* H0: beta1=0.01, 1 weak 2 strong
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	di "opt=`opt'"
	qui ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), `opt'
	qui test hours=0.01
	scalar wald_chi2=r(chi2)
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours
	qui ivreg2 ytilda (educ exper = fatheduc motheduc hushrs expersq), `opt' gmm2s
	global b2=_b[educ]
	global b3=_b[exper]
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 $b3) `opt' md noci
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01) strong(educ exper) `opt' md noci
	assert reldif(wald_chi2,e(wald_chi2))< 1e-7
	assert reldif(ar_chi2,e(ar_chi2))< 1e-7
	assert reldif(k_chi2,e(k_chi2))< 1e-7
	assert reldif(j_chi2,e(j_chi2))< 1e-7
}

* H0: beta1=0.01, beta2=0.01, 2 weak 1 strong
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	di "opt=`opt'"
	qui ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), `opt'
	qui test (hours=0.01) (exper=0.01)
	scalar wald_chi2=r(chi2)
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours-0.01*exper
	qui ivreg2 ytilda (educ = fatheduc motheduc hushrs expersq), `opt' gmm2s
	global b2=_b[educ]
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 0.01) `opt' md noci
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 0.01) strong(educ) `opt' md noci
	assert reldif(wald_chi2,e(wald_chi2))< 1e-7
	assert reldif(ar_chi2,e(ar_chi2))< 1e-7
	assert reldif(k_chi2,e(k_chi2))< 1e-7
	assert reldif(j_chi2,e(j_chi2))< 1e-7
}

**********************************************************************
* strong(.) + cuestrong option; replicate by hand.
* H0: beta1=0.01, 1 weak 1 strong
* LIML
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours
qui ivreg2 ytilda exper expersq (educ = fatheduc motheduc hushrs), liml partial(exper expersq)
global b2=_b[educ]
qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01 $b2) md noci
scalar ar_chi2=e(ar_chi2)
scalar k_chi2=e(k_chi2)
scalar j_chi2=e(j_chi2)
qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01) strong(educ) md noci cuestrong
assert reldif(ar_chi2,e(ar_chi2))< 1e-7
assert reldif(k_chi2,e(k_chi2))< 1e-7
assert reldif(j_chi2,e(j_chi2))< 1e-7
* CUE
foreach opt in	"rob" "cluster(age)" "cluster(age exper)"		///
				{
	di "opt=`opt'"
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours
	qui ivreg2 ytilda exper expersq (educ = fatheduc motheduc hushrs), `opt' cue partial(exper expersq)
	global b2=_b[educ]
	qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01 $b2) `opt' noci
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01) strong(educ) `opt' noci cuestrong
	assert reldif(ar_chi2,e(ar_chi2))< 1e-7
	assert reldif(k_chi2,e(k_chi2))< 1e-7
	assert reldif(j_chi2,e(j_chi2))< 1e-7
}

* H0: beta1=0.01, 1 weak 2 strong
* LIML
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours
qui ivreg2 ytilda (educ exper = fatheduc motheduc hushrs expersq), liml
global b2=_b[educ]
global b3=_b[exper]
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 $b3) noci
scalar ar_chi2=e(ar_chi2)
scalar k_chi2=e(k_chi2)
scalar j_chi2=e(j_chi2)
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01) strong(educ exper) noci cuestrong
assert reldif(ar_chi2,e(ar_chi2))< 1e-7
assert reldif(k_chi2,e(k_chi2))< 1e-7
assert reldif(j_chi2,e(j_chi2))< 1e-7
* CUE - TOLERANCE SET VERY LOW
foreach opt in	"rob" "cluster(age)" "cluster(age exper)"	///
				{
	di "opt=`opt'"
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours
	qui ivreg2 ytilda (educ exper = fatheduc motheduc hushrs expersq), `opt' cue
	global b2=_b[educ]
	global b3=_b[exper]
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 $b3) `opt' noci cue
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01) strong(educ exper) `opt' noci cuestrong
	assert reldif(ar_chi2,e(ar_chi2))< 1e-2
	assert reldif(k_chi2,e(k_chi2))< 1e-2
	assert reldif(j_chi2,e(j_chi2))< 1e-2
}

* H0: beta1=0.01, beta2=0.01, 2 weak 1 strong
* LIML
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours-0.01*exper
qui ivreg2 ytilda (educ = fatheduc motheduc hushrs expersq), liml
global b2=_b[educ]
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 0.01) md noci
scalar ar_chi2=e(ar_chi2)
scalar k_chi2=e(k_chi2)
scalar j_chi2=e(j_chi2)
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 0.01) strong(educ) cuestrong md noci
assert reldif(ar_chi2,e(ar_chi2))< 1e-7
assert reldif(k_chi2,e(k_chi2))< 1e-7
assert reldif(j_chi2,e(j_chi2))< 1e-7
* CUE - TOLERANCE SET VERY LOW (ill-conditioned example)
foreach opt in	"rob" "cluster(age)" "cluster(age exper)"	///
				{
	di "opt=`opt'"
	cap drop ytilda
	qui gen double ytilda=lwage-0.01*hours-0.01*exper
	qui ivreg2 ytilda (educ = fatheduc motheduc hushrs expersq), `opt' cue
	global b2=_b[educ]
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 $b2 0.01) `opt' noci cuestrong
	scalar ar_chi2=e(ar_chi2)
	scalar k_chi2=e(k_chi2)
	scalar j_chi2=e(j_chi2)
	qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 0.01) strong(educ) `opt' noci cuestrong
	assert reldif(ar_chi2,e(ar_chi2))< 1
	assert reldif(k_chi2,e(k_chi2))< 1
	assert reldif(j_chi2,e(j_chi2))< 1
}

**********************************************************************
* subset(.) option; replicate by hand.  Valid only for IID case.
* H0: beta1=0.01, subset=1, complement=1
qui ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs)
qui test hours=0.01
scalar wald_chi2=r(chi2)
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours
qui ivreg2 ytilda exper expersq (educ = fatheduc motheduc hushrs), liml
global sargan = e(N)*(1-1/e(lambda))
global basmann = (e(N)-e(rankzz))*(e(lambda)-1)
qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01) subset(hours) lm noci
assert reldif($basmann,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7
qui weakiv ivreg2 lwage exper expersq (hours educ = fatheduc motheduc hushrs), null(0.01) subset(hours) md noci
assert reldif($sargan,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7

* H0: beta1=0.01, subset=1, complement=2
qui ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq)
qui test hours=0.01
scalar wald_chi2=r(chi2)
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours
qui ivreg2 ytilda (educ exper = fatheduc motheduc hushrs expersq), liml
global sargan = e(N)*(1-1/e(lambda))
global basmann = (e(N)-e(rankzz))*(e(lambda)-1)
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01) subset(hours) lm noci
assert reldif($basmann,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01) subset(hours) md noci
assert reldif($sargan,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7

* H0: beta1=0.01, beta2=0.01, subset=2, complement=1
qui ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq)
qui test (hours=0.01) (educ=0.01)
scalar wald_chi2=r(chi2)
cap drop ytilda
qui gen double ytilda=lwage-0.01*hours-0.01*educ
qui ivreg2 ytilda (exper = fatheduc motheduc hushrs expersq), liml
global sargan = e(N)*(1-1/e(lambda))
global basmann = (e(N)-e(rankzz))*(e(lambda)-1)
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 0.01) subset(hours educ) lm noci
assert reldif($basmann,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7
qui weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), null(0.01 0.01) subset(hours educ) md noci
assert reldif($sargan,e(ar_chi2))< 1e-7
assert reldif(wald_chi2,e(wald_chi2))< 1e-7
**********************************************************************
* testexog(.) option
* Wald AR stat by hand
* 2-way clustering reports a not-full-rank warning - not a problem.
tempvar ytilda
gen double `ytilda'=.
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small"	{
		foreach null1 of numlist 0 0.1 {
			foreach null2 of numlist 0 0.1 {
				di "opt=`opt' `small' null1=`null1' null2=`null2'"
				qui ivreg2 lwage exper expersq hours (educ = fatheduc motheduc hushrs), `opt' `small'
				qui test (educ=`null1') (hours=`null2')
				scalar Wa=r(chi2)
				if Wa==. {
					scalar Wa=r(F)*r(df)
				}
				qui weakiv, null(`null1' `null2') md testexog(hours)
				scalar ARa=e(ar_chi2)
				qui weakiv ivreg2 lwage exper expersq hours (educ = fatheduc motheduc hushrs),	///
					`opt' `small' null(`null1' `null2') md testexog(hours)
				assert reldif(Wa,e(wald_chi2))< 1e-7
				scalar ARb=e(ar_chi2)
				qui replace `ytilda' = lwage - `null1'*educ - `null2'*hours
				cap ivreg2 `ytilda' exper expersq fatheduc motheduc hushrs hours, `opt' `small'		// cap because of non-full-rank warning
				qui test fatheduc motheduc hushrs hours
				scalar ARc=r(chi2)
				if ARc==. {
					scalar ARc = r(F)*r(df)
				}
				assert reldif(ARa,ARc)< 1e-7
				assert reldif(ARb,ARc)< 1e-7
			}
		}
	}
}

**********************************************************************
* cuepoint option
foreach opt in	" " "rob" "cluster(age)" "cluster(age exper)"	///
				{
	di "opt=`opt'"
	qui ivreg2 lwage exper expersq hours (educ = fatheduc motheduc hushrs), `opt' cue partial(_cons exper expersq hours)
	mat cuebeta=e(b)
	mat cuebeta=cuebeta[1,1]
	qui weakiv ivreg2 lwage exper expersq hours (educ = fatheduc motheduc hushrs), `opt' cuepoint
	assert mreldif(cuebeta,e(cuebeta))< 1e-7
	qui ivreg2 lwage hours (educ exper = fatheduc motheduc hushrs), `opt' cue partial(_cons hours)
	mat cuebeta=e(b)
	mat cuebeta=cuebeta[1,1..2]
	qui weakiv ivreg2 lwage hours (educ exper = fatheduc motheduc hushrs), `opt' cuepoint
	assert mreldif(cuebeta,e(cuebeta))< 1e-7
}

**********************************************************************
* project(.) option
* Check output (VCE opts don't matter)
* K=2, exactly-ID
weakiv ivreg2 lwage (educ exper = fatheduc motheduc), project(educ exper)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc), project(educ)
mat m=e(p1citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc), project(exper)
mat m=e(p2citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc), project(_all)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
* K=2, overid, all stats reported except CLR (and reduce gridpoints)
weakiv ivreg2 lwage (educ exper = fatheduc motheduc hushrs expersq), project(educ exper) gridpoints(10 10)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc hushrs expersq), project(educ) gridpoints(10 10)
mat m=e(p1citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc hushrs expersq), project(exper) gridpoints(10 10)
mat m=e(p2citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper = fatheduc motheduc hushrs expersq), project(_all) gridpoints(10 10)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
* K=3, robust (and reduce gridpoints)
weakiv ivreg2 lwage (educ exper hours = fatheduc motheduc hushrs expersq), rob project(educ exper) gridpoints(10 10 10)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper hours = fatheduc motheduc hushrs expersq), rob project(exper hours) gridpoints(10 10 10)
mat m=e(p2citable)
assert m[1,1]~=.
mat m=e(p3citable)
assert m[1,1]~=.
weakiv ivreg2 lwage (educ exper hours = fatheduc motheduc hushrs expersq), rob project(_all) gridpoints(10 10 10)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
mat m=e(p3citable)
assert m[1,1]~=.
* K=1, check that projection-based is same as main table
weakiv ivreg2 lwage (educ = fatheduc motheduc), project(educ)
* K=3, robust, project2(.) option
weakiv ivreg2 lwage (educ exper hours = fatheduc motheduc hushrs expersq),	///
	rob project(educ exper) project2(educ exper) gridpoints(10 10 10)		///
	graph(ar)
mat m=e(p12citable)
assert m[1,1]~=.
weakiv, graph(k j) project2(hours exper)
mat m=e(p32citable)
assert m[1,1]~=.

**********************************************************************
* Legality of options
* in subset but not in endog
cap noi weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), subset(hours repwage)
assert _rc==198
* in strong but not in endog
cap noi weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), strong(hours repwage)
assert _rc==198
* in project but not in weakly endog
cap noi weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), project(hours repwage)
assert _rc==198
* in project but not weakly endog
cap noi weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), project(hours) strong(hours)
assert _rc==198

* Combinations of options
* subset(.) + project(.)
weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), subset(hours educ) project(_all)
* strong(.) + project(.)
weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), strong(educ) project(_all)
* subset+strong: not allowed
cap noi weakiv ivreg2 lwage (hours educ exper = fatheduc motheduc hushrs expersq), strong(educ) subset(hours)
assert _rc==198

**********************************************************************
************************ FACTOR VARS *********************************
**********************************************************************

* Excluded exogenous
cap drop _I*
qui xi i.fatheduc
foreach opt in	" " "rob" "cluster(age)"						///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small" {
		foreach estimator in "ivregress 2sls" "ivreg2" {
			di "opt=`opt' small=`small' estimator=`estimator'"
			qui weakiv `estimator' lwage exper expersq (educ = i.fatheduc), `opt' `small' md
			savedresults save wivfv e()
			qui weakiv `estimator' lwage exper expersq (educ = _If*), `opt' `small' md
			savedresults comp wivfv e(), tol(1e-10) exclude(macros: exexog)
		}
	}
}
* Included exogenous
cap drop _I*
qui xi i.fatheduc
foreach opt in	" " "rob" "cluster(age)"						///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small" {
		foreach estimator in "ivregress 2sls" "ivreg2" {
			di "opt=`opt' small=`small' estimator=`estimator'"
			qui weakiv `estimator' lwage exper expersq i.fatheduc (educ = motheduc hushrs), `opt' `small' md
			savedresults save wivfv e()
			qui weakiv `estimator' lwage exper expersq _If* (educ = motheduc hushrs), `opt' `small' md
			savedresults comp wivfv e(), tol(1e-10) exclude(macros: inexog)
		}
	}
}
* Endogenous, excluded exogenous
cap drop _I*
qui xi i.fatheduc i.city
foreach opt in	" " "rob" "cluster(age)"						///
				"nocons" "nocons rob" "nocons cluster(age)"		///
				{
	foreach small in " " "small" {
		foreach estimator in "ivregress 2sls" "ivreg2" {
			di "opt=`opt' small=`small' estimator=`estimator'"
			qui weakiv `estimator' lwage exper expersq (educ i.city = motheduc hushrs i.fatheduc), `opt' `small' md
			savedresults save wivfv e()
			qui weakiv `estimator' lwage exper expersq (educ _Ic* = motheduc hushrs _If*), `opt' `small' md
			savedresults comp wivfv e(), tol(1e-10) exclude(macros: exexog endo wendo)
		}
	}
}

**********************************************************************
* Check graphics options work
weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc hushrs), rob gridpoints(25 25) graph(ar)
weakiv, graph(wald ar)
weakiv, graph(wald k) level(95 90 80)
weakiv, graph(wald k) level(95 90 80) contouropt(contourshade)
weakiv, graph(wald k) level(95 90 80) contouropt(scatter)
weakiv ivreg2 lwage exper expersq (educ hours = fatheduc motheduc hushrs), rob gridpoints(25 .) gridmult(4) md
weakiv, graph(wald k) surfaceopt(nowire)
weakiv, graph(wald ar) contouronly
weakiv, graph(wald ar) contouropt(contourshade)
weakiv, graph(wald ar) contouropt(scatter) contouronly
weakiv, graph(wald ar) surfaceonly surfaceopt(nowire)

************************ MISC ********************************
* This generates an npd matrix; the culprit is psi in computetests_robust,
* aux1 = cholsolve(psi,r)
* Output is nonsensical but npd flag captures it.
weakiv ivreg2 lwage (hours educ expersq = fatheduc motheduc hushrs exper), null(0.01 24.12934 0.01) cluster(age exper) noci md

**********************************************************************
************************ AC AND HAC VCV ******************************
**********************************************************************

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year, yearly

**********************************************************************
* VCE and other opts
* Wald AR stat by hand
tempvar ytilda
gen double `ytilda'=.
foreach opt in "bw(3)" "rob bw(3)" {
	foreach small in " " "small"	{
		foreach null of numlist 0 0.1 {
			di "opt=`opt' `small' null=`null'"
			qui ivreg2 cinf (unem = l(1/3).unem), `opt' `small'
			qui test (unem=`null')
			scalar Wa=r(chi2)
			if Wa==. {
				scalar Wa=r(F)*r(df)
			}
			qui weakiv, null(`null') md
			scalar ARa=e(ar_chi2)
			qui weakiv ivreg2 cinf (unem = l(1/3).unem), `opt' `small' null(`null') md
			assert reldif(Wa,e(wald_chi2))< 1e-7
			scalar ARb=e(ar_chi2)
			qui replace `ytilda' = cinf - `null'*unem
			qui ivreg2 `ytilda' l(1/3).unem, `opt' `small'
			qui test L1.unem L2.unem L3.unem
			scalar ARc=r(chi2)
			if ARc==. {
				scalar ARc = r(F)*r(df)
			}
			assert reldif(ARa,ARc)< 1e-7
			assert reldif(ARb,ARc)< 1e-7
		}
	}
}
* ivreg2 vs ivregress
foreach small in " " "small"	{
	qui weakiv ivreg2 cinf (unem = l(1/3).unem), rob bw(3) `small' md
	savedresults save wivreg2 e()
	qui weakiv ivregress 2sls cinf (unem = l(1/3).unem), vce(hac bartlett 2) `small' md
	savedresults comp wivreg2 e(), exclude(macro: waldcmd) tol(1e-10)
}
**********************************************************************
******************************* K=2 **********************************
**********************************************************************
* VCE and other opts
* Wald AR stat by hand
tempvar ytilda
gen double `ytilda'=.
foreach opt in "bw(3)" "rob bw(3)" {
	foreach small in " " "small"	{
		foreach null1 of numlist 0 0.1 {
			foreach null2 of numlist 0 0.1 {
				di "opt=`opt' `small' null1=`null1' null2=`null2'"
				qui ivreg2 cinf (unem l.unem = l(2/4).unem), `opt' `small'
				qui test (unem=`null1') (l.unem=`null2')
				scalar Wa=r(chi2)
				if Wa==. {
					scalar Wa=r(F)*r(df)
				}
				qui weakiv, null(`null1' `null2') md
				scalar ARa=e(ar_chi2)
				qui weakiv ivreg2 cinf (unem l.unem = l(2/4).unem), `opt' `small' null(`null1' `null2') md
				assert reldif(Wa,e(wald_chi2))< 1e-7
				scalar ARb=e(ar_chi2)
				qui replace `ytilda' = cinf - `null1'*unem - `null2'*l.unem
				qui ivreg2 `ytilda' l(2/4).unem, `opt' `small'
				qui test L2.unem L3.unem L4.unem
				scalar ARc=r(chi2)
				if ARc==. {
					scalar ARc = r(F)*r(df)
				}
				assert reldif(ARa,ARc)< 1e-7
				assert reldif(ARb,ARc)< 1e-7
			}
		}
	}
}

**********************************************************************
* Check graphics options work
* Should be default in first dimension and 25 points in 2nd dimesion
qui weakiv ivreg2 cinf (unem l.unem = l(2/4).unem),	///
			rob bw(3) usegrid gridpoints(. 25)
weakiv, graph(wald ar)
weakiv, graph(k)

**********************************************************************
**************************** xtabond2 ********************************
**********************************************************************

webuse abdata, clear
* Factor variable dep var
gen iw=w>3.1

* K=1, factor vars
qui weakiv xtabond2 n w i.year, gmm(n w, lag(2 .)) iv(i.year) nol rob cluster(id)
savedresults save wxtabond2 e()
cap drop _I*
xi i.year
qui weakiv xtabond2 n w _I*, gmm(n w, lag(2 .)) iv(_I*) nol rob cluster(id)
savedresults comp wxtabond2 e(), exclude(macro: ivinsts1 inexog matrix: ideqt Z) tol(1e-6)
cap drop _I*

* K=2, factor vars, #weak=2
qui weakiv xtabond2 n l.n w i.year, gmm(n w, lag(2 .)) iv(i.year) nol rob cluster(id)
savedresults save wxtabond2 e()
cap drop _I*
cap drop Ln
xi i.year
gen double Ln=L.n
qui weakiv xtabond2 n Ln w _I*, gmm(n w, lag(2 .)) iv(_I*) nol rob cluster(id)
savedresults comp wxtabond2 e(), exclude(macro: ivinsts1 inexog endo endo1 wendo scalar: clr_stat clr_p rk matrix: ideqt Z) tol(1e-6)
cap drop _I*
cap drop Ln

* K=2, factor vars, #weak=2, dep var has FV
qui weakiv xtabond2 n l.n i.iw i.year, gmm(n w, lag(2 .)) iv(i.year) nol rob cluster(id)
savedresults save wxtabond2 e()
cap drop _I*
cap drop Ln
xi i.year i.iw
gen double Ln=L.n
qui weakiv xtabond2 n Ln _Iiw_1 _Iy*, gmm(n w, lag(2 .)) iv(_Iy*) nol rob cluster(id)
savedresults comp wxtabond2 e(), exclude(macro: ivinsts1 inexog endo endo1 wendo scalar: clr_stat clr_p rk matrix: ideqt Z) tol(1e-6)
cap drop _I*
cap drop Ln

* K=2, factor vars, #weak=1
qui weakiv xtabond2 n l.n w i.year, gmm(n w, lag(2 .)) iv(i.year) nol rob cluster(id) strong(l.n)
savedresults save wxtabond2 e()
cap drop _I*
cap drop Ln
xi i.year
gen double Ln=L.n
qui weakiv xtabond2 n Ln w _I*, gmm(n w, lag(2 .)) iv(_I*) nol rob cluster(id) strong(Ln)
savedresults comp wxtabond2 e(), exclude(macro: ivinsts1 inexog endo endo1 wendo sendo scalar: clr_stat clr_p rk matrix: ideqt Z citable) tol(1e-6)
cap drop _I*
cap drop Ln

* weakiv and xtabond2 vs. ivreg2
* xtabond2 does not support iweights
* Non-robust
foreach wtopt in " " "[fw=ind]" "[aw=emp]" {
	di "wtopt = `wtopt', non-robust"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci
	savedresults save wxtabond2 e()
	qui weakiv ivreg2 n cap (w = k ys rec) `wtopt', noci
	savedresults comp wxtabond2 e(), exclude(macro: ivinsts1 ivinsts2 inexog waldcmd xtmodel scalar: singleton N_g g_min g_max g_avg matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
}
* Robust => cluster with xtabond2
foreach wtopt in " " "[fw=ind]" "[aw=emp]" "[pw=emp]" {
	qui weakiv ivreg2 n cap (w = k ys rec) `wtopt', noci cluster(id)
	savedresults save wivreg2 e()
	di "wtopt = `wtopt', rob"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci rob
	savedresults comp wivreg2 e(), exclude(macro: exexog inexog waldcmd matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
	di "wtopt = `wtopt', cluster(id)"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci cluster(id)
	savedresults comp wivreg2 e(), exclude(macro: exexog inexog waldcmd matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
	di "wtopt = `wtopt', rob cluster(id)"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci rob cluster(id)
	savedresults comp wivreg2 e(), exclude(macro: exexog inexog waldcmd matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
}

* clustering on non-panel id
foreach wtopt in " " "[fw=ind]" "[aw=emp]" "[pw=emp]" {
	qui weakiv ivreg2 n cap (w = k ys rec) `wtopt', noci cluster(ind)
	savedresults save wivreg2 e()
	di "wtopt = `wtopt', cluster(ind)"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci cluster(ind)
	savedresults comp wivreg2 e(), exclude(macro: exexog inexog waldcmd matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
	di "wtopt = `wtopt', rob cluster(ind)"
	qui weakiv xtabond2 n w cap `wtopt', iv(cap k ys, eq(level)) iv(rec, eq(level)) h(1) noci rob cluster(ind)
	savedresults comp wivreg2 e(), exclude(macro: exexog inexog waldcmd matrix: gmmequation ivequation ideqt Z Y X citable) tol(1e-6)
}

* Check eq(.) option
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep small h(2)
savedresults save wxtabond2 e()
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep small h(2) eq(sys)
savedresults comp wxtabond2 e(), exclude(scalar: clr_stat clr_p rk matrix: ideqt) tol(1e-5)
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep small h(2) eq(diff) noci
assert e(N)==751
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, mz) robust twostep small h(2) eq(lev) noci
assert e(N)==891

* Other options
* subset(.); requires iid; will display CI if #wendo=1
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq subset(L.n)
* strong
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq strong(L.n)
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq strong(L.n w)
* project
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984, gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq project(_all) gridpoints(10 10 10)
mat m=e(p1citable)
assert m[1,1]~=.
mat m=e(p2citable)
assert m[1,1]~=.
mat m=e(p3citable)
assert m[1,1]~=.
weakiv, project2(L.n w) graph(ar)
mat m=e(p12citable)
assert m[1,1]~=.
weakiv, project2(k w) graph(k)
mat m=e(p32citable)
assert m[1,1]~=.
* subset + project
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984,	///
	gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq subset(L.n w) project(_all) gridpoints(5 5)
* strong + project
weakiv xtabond2 n l.n l(0/1).(w k) yr1980-yr1984,	///
	gmm(l.n w k) iv(yr1980-yr1984, passthru) noleveleq strong(L.n) project(_all) gridpoints(5 5)

**********************************************************************
******************** AR, K and J by hand in Mata *********************
**********************************************************************

sysuse auto, clear
mata: mata clear
keep price foreign mpg weight turn displacement gear_ratio
* Mata code simplifies if exogenous regressors incl. constant are partialled out
foreach var of varlist price mpg weight turn displacement gear_ratio {
	qui reg `var' foreign
	qui predict double c_`var', resid
}

****************************** K=1 ***********************************

global y	price
global c_y	c_price
global Z	weight   turn   displacement
global c_Z	c_weight c_turn c_displacement
global X	mpg
global c_X	c_mpg
* Partialled-out exogenous regressors (not including constant)
global X2	foreign

scalar null=-400
global null=null
qui desc
scalar n=r(N)
global n=n

* Mata variables, projection and annihilation matrices
mata: null=st_numscalar("null")
mata: n   =st_numscalar("n")
putmata Z=($c_Z), replace
putmata X=($c_X), replace
putmata y=($c_y), replace
* Demeaning not actually necessary if constant partialled-out
mata: Z=Z :- mean(Z)
mata: X=X :- mean(X)
mata: y=y :- mean(y)
mata: Pz=Z*invsym(Z'Z)*Z'
mata: Mz=I(n) - Pz


mata: ytilda = y - null*X

***** K=1, iid *****

mata: Delta = invsym(Z'Z) * Z' * (X - (ytilda*ytilda'*Mz*X)/(ytilda' * Mz * ytilda))
mata: Ztilda = Z*Delta
mata: Pzt=Ztilda*invsym(Ztilda'Ztilda)*Ztilda'
mata: Mzt=I(n) - Pzt

* MD (Wald)
mata: AR = (ytilda' * Pz * ytilda) / (ytilda' * Mz * ytilda) * n
mata: K = (ytilda' * Pzt * ytilda) / (ytilda' * Mz * ytilda) * n
mata: J = AR-K
mata: st_numscalar("AR",AR)
mata: st_numscalar("K",K)
mata: st_numscalar("J",J)

* LM
mata: ARLM = (ytilda' * Pz * ytilda) / (ytilda' * ytilda) * n
mata: KLM = (ytilda' * Pzt * ytilda) / (ytilda' * ytilda) * n
mata: JLM = ARLM-KLM
mata: st_numscalar("ARLM",ARLM)
mata: st_numscalar("KLM",KLM)
mata: st_numscalar("JLM",JLM)

* MD (Wald), with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null) md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null) md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
* LM with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null)
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null)
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6

***** K=1, rob *****

mata: ehat = Mz*ytilda
mata: vhat = Mz*X

mata: S11_a = 1/n * quadcross(Z:*ytilda, Z:*ytilda)
mata: S11_b = 1/n * quadcross(Z:*ehat, Z:*ehat)
mata: S12_a = 1/n * quadcross(Z:*ytilda, Z:*X)
mata: S12_b = 1/n * quadcross(Z:*ehat, Z:*vhat)

mata: S11_ainv=invsym(S11_a)
mata: S11_binv=invsym(S11_b)

*******************************************

* Deltas, Ztildas, Ks
* LM
mata: Delta_a  = S11_ainv*Z'X  - S11_ainv*S12_a*S11_ainv*Z'ytilda
mata: Ztilda_a = Z*Delta_a
* MD
mata: Delta_b  = S11_binv*Z'X - S11_binv*S12_b*S11_binv*Z'ytilda
mata: Ztilda_b = Z*Delta_b

* MD (Wald)
mata: AR = ytilda' * Z * S11_binv * Z' * ytilda / n
mata: K = ytilda' * Ztilda_b * invsym(Delta_b' * S11_b * Delta_b) * Ztilda_b' * ytilda / n
mata: J = AR-K
mata: st_numscalar("AR",AR)
mata: st_numscalar("K",K)
mata: st_numscalar("J",J)

* LM
mata: ARLM = ytilda' * Z * S11_ainv * Z' * ytilda / n
mata: KLM = ytilda' * Ztilda_a * invsym(Delta_a' * S11_a * Delta_a) * Ztilda_a' * ytilda / n
mata: JLM = ARLM-KLM
mata: st_numscalar("ARLM",ARLM)
mata: st_numscalar("KLM",KLM)
mata: st_numscalar("JLM",JLM)

* MD (Wald), with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null) rob md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null) rob md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
* LM with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null) rob
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null) rob
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6

****************************** K=2 ***********************************

global y	price
global c_y	c_price
global Z	weight   turn   displacement
global c_Z	c_weight c_turn c_displacement
global X	mpg gear_ratio
global c_X	c_mpg c_gear_ratio
* Partialled-out exogenous regressors (not including constant)
global X2	foreign

scalar null_1=100
global null_1=null_1
scalar null_2=100
global null_2=null_2
qui desc
scalar n=r(N)
global n=n

* Mata variables, projection and annihilation matrices
mata: null_1=st_numscalar("null_1")
mata: null_2=st_numscalar("null_2")
* Column vector
mata: null=(null_1 \ null_2)
mata: n     =st_numscalar("n")
putmata Z=($c_Z), replace
putmata X=($c_X), replace
putmata y=($c_y), replace
* Demeaning not actually necessary if constant partialled-out
mata: Z=Z :- mean(Z)
mata: X=X :- mean(X)
mata: y=y :- mean(y)
mata: Pz=Z*invsym(Z'Z)*Z'
mata: Mz=I(n) - Pz


mata: ytilda = y - X*null

***** K=2, iid *****

mata: Delta = invsym(Z'Z) * Z' * (X - (ytilda*ytilda'*Mz*X)/(ytilda' * Mz * ytilda))
mata: Ztilda = Z*Delta
mata: Pzt=Ztilda*invsym(Ztilda'Ztilda)*Ztilda'
mata: Mzt=I(n) - Pzt

* MD (Wald)
mata: AR = (ytilda' * Pz * ytilda) / (ytilda' * Mz * ytilda) * n
mata: K = (ytilda' * Pzt * ytilda) / (ytilda' * Mz * ytilda) * n
mata: J = AR-K
mata: st_numscalar("AR",AR)
mata: st_numscalar("K",K)
mata: st_numscalar("J",J)

* LM
mata: ARLM = (ytilda' * Pz * ytilda) / (ytilda' * ytilda) * n
mata: KLM = (ytilda' * Pzt * ytilda) / (ytilda' * ytilda) * n
mata: JLM = ARLM-KLM
mata: st_numscalar("ARLM",ARLM)
mata: st_numscalar("KLM",KLM)
mata: st_numscalar("JLM",JLM)

* MD (Wald), with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null_1 $null_2) md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null_1 $null_2) md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
* LM with/without ivreg2 partialling-out
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null_1 $null_2)
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6
qui weakiv ivreg2 $y $X2 ($X=$Z), partial($X2) null($null_1 $null_2)
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6

***** K=2, rob *****

mata: ehat = Mz*ytilda
mata: vhat = Mz*X

mata: S11_a  = 1/n * quadcross(Z:*ytilda, Z:*ytilda)
mata: S11_b  = 1/n * quadcross(Z:*ehat, Z:*ehat)
mata: S12_a1 = 1/n * quadcross(Z:*ytilda, (Z:*X[.,1]) )
mata: S12_a2 = 1/n * quadcross(Z:*ytilda, (Z:*X[.,2]) )
mata: S12_b1 = 1/n * quadcross(Z:*ehat, (Z:*vhat[.,1]) )
mata: S12_b2 = 1/n * quadcross(Z:*ehat, (Z:*vhat[.,2]) )

mata: S11_ainv=invsym(S11_a)
mata: S11_binv=invsym(S11_b)

*******************************************

* Deltas, Ztildas, Ks
* LM
mata: Delta_a1 = S11_ainv*Z'X[.,1]  - S11_ainv*S12_a1*S11_ainv*Z'ytilda
mata: Delta_a2 = S11_ainv*Z'X[.,2]  - S11_ainv*S12_a2*S11_ainv*Z'ytilda
mata: Delta_a  = (Delta_a1, Delta_a2)
mata: Ztilda_a = Z*Delta_a
* MD
mata: Delta_b1 = S11_binv*Z'X[.,1] - S11_binv*S12_b1*S11_binv*Z'ytilda
mata: Delta_b2 = S11_binv*Z'X[.,2] - S11_binv*S12_b2*S11_binv*Z'ytilda
mata: Delta_b  = (Delta_b1, Delta_b2)
mata: Ztilda_b = Z*Delta_b

* MD (Wald)
mata: AR = ytilda' * Z * S11_binv * Z' * ytilda / n
mata: K = ytilda' * Ztilda_b * invsym(Delta_b' * S11_b * Delta_b) * Ztilda_b' * ytilda / n
mata: J = AR-K
mata: st_numscalar("AR",AR)
mata: st_numscalar("K",K)
mata: st_numscalar("J",J)

* LM
mata: ARLM = ytilda' * Z * S11_ainv * Z' * ytilda / n
mata: KLM = ytilda' * Ztilda_a * invsym(Delta_a' * S11_a * Delta_a) * Ztilda_a' * ytilda / n
mata: JLM = ARLM-KLM
mata: st_numscalar("ARLM",ARLM)
mata: st_numscalar("KLM",KLM)
mata: st_numscalar("JLM",JLM)

* MD (Wald)
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null_1 $null_2) rob md
assert reldif(AR,e(ar_chi2))< 1e-6
assert reldif(K,e(k_chi2))< 1e-6
assert reldif(J,e(j_chi2))< 1e-6
* LM (partialling-out automatic)
qui weakiv ivreg2 $y $X2 ($X=$Z), null($null_1 $null_2) rob
assert reldif(ARLM,e(ar_chi2))< 1e-6
assert reldif(KLM,e(k_chi2))< 1e-6
assert reldif(JLM,e(j_chi2))< 1e-6


**********************************************************************
****************************** Done **********************************
**********************************************************************


log close
set more on
set rmsg off
