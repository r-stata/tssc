*xtcaec: Common correlated effects (cce) estimation in mean-group error correction models

*Version v2.0 (Second release version)

*Last revision: Apr 2017

*Email: xtcaec@korbinian-nagel.de

***Updates by Apr 2017 (v2):***
*Avoid xtmg and moremata
*Add group-specific and average long-run coefficients
*Add the avlr, cavars(), noca, det(), mg, lrplot() options
*Pesaran 2015 test on cross-sectional dependence now applied to demeaned variables (excluding residuals) in order to meet the assumption of zero mean

capture program drop xtcaec

program xtcaec, eclass

*set tracedepth 1
*set trace on

syntax varlist [if] [in] [,  lags(numlist integer min=1 max=2 >=0) select calags(integer 0) cavars(namelist) NOCA TREND det(namelist) AVLR MG lrplot(numlist) res(string)   ]

	version 13.1 

_xt, i(`i') t(`t')

local ivar "`r(ivar)'"

local tvar "`r(tvar)'"

marksample touse

local avlr2 `avlr'

**********************
***Prepare Variables**
**********************

****Identify variables*****

local numindepvar=wordcount("`varlist'")-1

if `numindepvar' > 4 {

	di as err "No more than 5 covariates can be specified."

	exit 459

}

if "`select'" != "" & "`robust'" != "" {

	di as err "The options robust and select may not be combined."

exit 184

} 

tokenize `varlist'

local depvar `1'

macro shift 1

local indepvar `*'

tokenize `indepvar'

if `numindepvar' == 1 {

	local indepvar1 `1'
	
}

else if `numindepvar' == 2 {

	local indepvar1 `1'

	local indepvar2 `2'

}

else if `numindepvar' == 3 {

	local indepvar1 `1'

	local indepvar2 `2'

	local indepvar3 `3'

}

else {

	local indepvar1 `1'

	local indepvar2 `2'

	local indepvar3 `3'

	local indepvar4 `4'

}

local variables `depvar' `indepvar'


***Number of lags***

if "`lags'" != "" {

	local nlags: word count `lags'

	if `nlags' > 1 {

		tokenize `lags'

		local llag = `1'

		local ulag = `2'

		if `llag' > `ulag' {

			local bus = `ulag'

			local ulag = `llag'

			local llag = `bus'

		}

	}

	else {

		local llag = 0

		local ulag = `lags'

	}

	local nllag = `llag'+1

}

else {

	local ulag = 0

}

*****Count number of regvars*****

local regvarnum = 1 + 2*`numindepvar' + `ulag'*(`numindepvar'+1) + (2+`calags')*(`numindepvar'+1)


*****Drop countries with few observations****

tempvar idobs

sort `touse' `ivar' `tvar'

qui {

by `touse' `ivar': gen `idobs' = _N if `touse'

by `touse' `ivar': replace `touse' = 0 if `idobs'[_N]<=`regvarnum'

}

***Count number of groups***

tempvar groups

qui egen `groups' = group(`ivar') if `touse'

qui summ `groups' if `touse'

local ng = r(max)

local id `groups'

sort `ivar' `tvar'



*********Cross-Sectional Averages*************

if "`cavars'" == "" {

local cavars `variables'

}

if "`noca'" != "" {

local cavars

}

foreach var of local cavars {

	tempvar ca`var'

	qui egen `ca`var'' = mean(`var'), by(`tvar')

	**!!!!! Touse

	local caregvars `caregvars' `ca`var''

}

foreach var of local caregvars {

	tempvar diffca`var'

	qui gen `diffca`var'' = d.`var' 

	local cadiffs `cadiffs' `diffca`var''

}


********local of lagged differences********

if "`lags'" != "" {

	foreach var of varlist `variables' {

		forvalues lagnum = 1 / `ulag' {

			local lagdiffs `lagdiffs' l`lagnum'.d.(`var')

		}

	}

}


*****Trend****

if "`trend'" != "" {

	qui sum `tvar'

	tempvar trend

	qui gen `trend' = `tvar'-r(min)

}


*****get regvarnames****

tempname bum

qui reg d.`depvar' l.(`depvar' `indepvar') d.(`indepvar') `lagdiffs' l.(`caregvars') l(0/`calags').(`cadiffs') `trend' `det' if `touse'

mat `bum' = get(_b)

local regvarnames: colfullnames(`bum')

local regvarnum = colsof(`bum')

************************
***Indicate to wait*****
************************

di ""

if `ng' > 20 {

	dis _con as txt "Please wait...."

	di""

}

else if `ng' > 15 & "`select'" != "" {

	dis _con as txt "Please wait...."

	di""
	
}


***********************
******Estimate*********
***********************

******matrix for coefficients

tempname bindiv bseindiv lrindiv resid vlrindiv

qui gen `resid' = .

matrix `bindiv' = J(`ng',`regvarnum',.)

matrix colnames `bindiv' = `regvarnames'

matrix `bseindiv' = J(`ng',`regvarnum',.)

matrix colnames `bseindiv' = `regvarnames'

matrix `lrindiv' = J(`ng',`numindepvar',.)

matrix colnames `lrindiv' = `indepvar'

matrix `vlrindiv' = J(`ng',`numindepvar',.)

matrix colnames `vlrindiv' = `indepvar'

****begin country loop

forvalues i = 1 / `ng' {

	tempname bx`i' tab bse`i' blist`i' blist2`i' `resid`i''

	qui reg d.`depvar' l.(`depvar' `indepvar') d.(`indepvar') `lagdiffs' l.(`caregvars') l(0/`calags').(`cadiffs') `trend' `det' if `touse' & `id'==`i'

***begin select

	if "`select'" != "" {

		local lowlag = `llag'+1

		local lagdiffs`i' `lagdiffs'

		local countselect = 1

		while `countselect' > 0 {

			local countselect = 0

			qui mat `blist`i'' = r(table)

			foreach var of varlist `variables' {

				forvalues l = `ulag' (-1) `lowlag' {

					capture mat drop `blist2`i''

					capture mat `blist2`i'' = `blist`i''[4,"L`l'D.`var'"]

					capture confirm mat `blist2`i''

					if !_rc {

						if `blist2`i''[1,1]>=0.1 {

							local remove l`l'.d.(`var')
			
							local lagdiffs`i': list lagdiffs`i' - remove

							local countselect = 1
						}

						else if `blist2`i''[1,1]<0.1 {

							continue, break

						}

					}

				}

			}

		qui reg d.`depvar' l.(`depvar' `indepvar') d.(`indepvar') `lagdiffs`i'' l.(`caregvars') l(0/`calags').(`cadiffs') `trend' `det' if `touse' & `id'==`i'

		}

	}

	qui predict double `resid'`i' if `touse' & `id'==`i' , residuals

	qui replace `resid' = `resid'`i' if `touse' & `id'==`i' 

	****Aggregate results****

	local nobsi = e(N)

	local nobs = `nobs' + `nobsi'

	qui mat `bx`i'' = get(_b)

	qui mat `tab' = r(table)

	mat `bse`i'' = `tab'[2,1...]

	local regselectvarnames: colfullnames(`bx`i'')

	foreach var of local regselectvarnames {

		capture matrix `bindiv'[`i',colnumb(`bindiv',"`var'")] = `bx`i''[1,"`var'"]

		capture matrix `bseindiv'[`i',colnumb(`bseindiv',"`var'")] = `bse`i''[1,"`var'"]
		

	}

	****long-run coefficients****

	foreach var of local indepvar {

		tempname bxlr`i' vlr`i'

		mat `bxlr`i'' = .

		mat `vlr`i'' = .

		qui capture nlcom (`var': - _b[l.`var'] / _b[l.`depvar'])

		mat `bxlr`i'' = `bxlr`i'',r(b)

		mat `vlr`i'' = `vlr`i'', r(V)

		capture matrix `lrindiv'[`i',colnumb(`lrindiv',"`var'")] = `bxlr`i''[1,"`var'"]

		capture matrix `vlrindiv'[`i',colnumb(`vlrindiv',"`var'")] = `vlr`i''[1,"`var'"]

	}

}

******************************
***Prepare Estimates**********
******************************


tempname bmg bmg2 ebmg vbmg tin am lrmg lrmg2 elrmg vlrmg seindiv selrindiv tlrindiv

mata: `bindiv' = st_matrix("`bindiv'")

mata: `am' = editmissing(`bindiv', 0)

mata: `seindiv' = st_matrix("`bseindiv'")

mata: `tin' = `bindiv':/`seindiv'

mata: `bmg' = colsum(`am') / `ng'

mata: `bmg2' = J(`ng',1,`bmg')

mata: `ebmg' = `am'-`bmg2'

mata: `vbmg' = `ebmg''*`ebmg'/(`ng'*(`ng'-1))

mata: `lrindiv' = st_matrix("`lrindiv'")

mata: `lrmg' = colsum(`lrindiv') / `ng'

mata: `lrmg2' = J(`ng',1,`lrmg')

mata: `elrmg' = `lrindiv' - `lrmg2'

mata: `vlrmg' = `elrmg''*`elrmg'/(`ng'*(`ng'-1))

mata: `vlrindiv' = st_matrix("`vlrindiv'")

mata: `selrindiv' = sqrt(`vlrindiv')

mata: `tlrindiv' = `lrindiv' :/ `selrindiv'

mata: st_matrix("`selrindiv'",`selrindiv')

mata: st_matrix("`tlrindiv'", `tlrindiv')

tempname b V tindiv avlr vavlr b2 V2 ilr

mata: st_matrix("`b'",`bmg')

mata: st_matrix("`V'",`vbmg')

mata: st_matrix("`seindiv'", `seindiv')

mata: st_matrix("`tindiv'", `tin')

mata: st_matrix("`avlr'", `lrmg')

mata: st_matrix("`vavlr'", `vlrmg')

mata: st_matrix("`ilr'", `lrindiv')

mat colnames `b' = `regvarnames'

mat colnames `V' = `regvarnames'

mat rownames `V' = `regvarnames' 

mat colnames `avlr' = `indepvar'

mat colnames `vavlr' = `indepvar'

mat rownames `vavlr' = `indepvar'

mat colnames `ilr' = `indepvar'

mat `b2' = `b'

mat `V2' = `V'

tempname bindiv2

mat `bindiv2' = `bindiv'

******************************
****Calculate Statistics******
******************************

*****RMSE****

tempvar r2

qui gen `r2' = `resid'^2

qui sum `r2' 

local sigma2 = r(mean)

****Ec-Coefficient****

tempname ecc ectbar ectbarm ectbarmat

scalar `ecc' = `b'[1,1]

mata: `ectbarm' = colsum(`tin'[1...,1]) / `ng'

mata: st_matrix("`ectbarmat'", `ectbarm')

scalar `ectbar' = `ectbarmat'[1,1]

****Gengenbach Critical values******

tempname crit trange eccresult

if `numindepvar' == 1 & "`trend'" == "" {

mat `crit' = (	- 2.658	,	- 2.772	,	- 2.971	\ /*
*/	- 2.603	,	- 2.698	,	- 2.866	\	/*
*/	- 2.568	,	- 2.653	,	- 2.796	\	/*
*/	- 2.544	,	- 2.623	,	- 2.773	\	/*
*/	- 2.530	,	- 2.601	,	- 2.735	\	/*
*/	- 2.504	,	- 2.574	,	- 2.694	\	/*
*/	- 2.492	,	- 2.554	,	- 2.672	\	/*
*/	- 2.477	,	- 2.536	,	- 2.650	\	/*
*/	- 2.458	,	- 2.517	,	- 2.611	)

}


else if `numindepvar' == 1 & "`trend'" != "" {

mat `crit' = (	- 3.085	,	- 3.188	,	- 3.382	\	/*
*/	- 3.026	,	- 3.112	,	- 3.276	\	/*
*/	- 2.980	,	- 3.060	,	- 3.212	\	/*
*/	- 2.965	,	- 3.041	,	- 3.189	\	/*
*/	- 2.948	,	- 3.013	,	- 3.130	\	/*
*/	- 2.921	,	- 2.982	,	- 3.095	\	/*
*/	- 2.906	,	- 2.964	,	- 3.067	\	/*
*/	- 2.892	,	- 2.946	,	- 3.045	\	/*
*/	- 2.875	,	- 2.925	,	- 3.010	)

}

if `numindepvar' == 2 & "`trend'" == "" {

mat `crit' = (	- 3.056	,	- 3.167	,	- 3.377	\	/*
*/	- 2.993	,	- 3.083	,	- 3.265	\	/*
*/	- 2.948	,	- 3.033	,	- 3.196	\	/*
*/	- 2.925	,	- 3.000	,	- 3.139	\	/*
*/	- 2.909	,	- 2.981	,	- 3.120	\	/*
*/	- 2.885	,	- 2.949	,	- 3.071	\	/*
*/	- 2.863	,	- 2.924	,	- 3.032	\	/*
*/	- 2.848	,	- 2.903	,	- 3.016	\	/*
*/	- 2.835	,	- 2.886	,	- 2.983	)

}

else if `numindepvar' == 2 & "`trend'" != "" {

mat `crit' = (	- 3.410	,	- 3.514	,	- 3.707	\	/*
*/	- 3.351	,	- 3.441	,	- 3.616	\	/*
*/	- 3.306	,	- 3.389	,	- 3.531	\	/*
*/	- 3.286	,	- 3.361	,	- 3.490	\	/*
*/	- 3.269	,	- 3.337	,	- 3.460	\	/*
*/	- 3.244	,	- 3.306	,	- 3.420	\	/*
*/	- 3.227	,	- 3.282	,	- 3.395	\	/*
*/	- 3.210	,	- 3.258	,	- 3.355	\	/*
*/	- 3.193	,	- 3.237	,	- 3.319	)

}

else if `numindepvar' == 3 & "`trend'" == "" {

mat `crit' = (	- 3.393	,	- 3.513	,	- 3.728	\	/*
*/	- 3.325	,	- 3.420	,	- 3.599	\	/*
*/	- 3.283	,	- 3.370	,	- 3.525	\	/*
*/	- 3.258	,	- 3.331	,	- 3.468	\	/*
*/	- 3.238	,	- 3.305	,	- 3.438	\	/*
*/	- 3.221	,	- 3.285	,	- 3.404	\	/*
*/	- 3.200	,	- 3.259	,	- 3.374	\	/*
*/	- 3.181	,	- 3.234	,	- 3.332	\	/*
*/	- 3.162	,	- 3.213	,	- 3.301	)

}
	
else if `numindepvar' == 3 & "`trend'" != "" {

mat `crit' = (	- 3.709	,	- 3.820	,	- 4.021	\	/*
*/	- 3.644	,	- 3.737	,	- 3.904	\	/*
*/	- 3.595	,	- 3.677	,	- 3.827	\	/*
*/	- 3.577	,	- 3.657	,	- 3.784	\	/*
*/	- 3.563	,	- 3.632	,	- 3.756	\	/*
*/	- 3.535	,	- 3.594	,	- 3.706	\	/*
*/	- 3.519	,	- 3.576	,	- 3.681	\	/*
*/	- 3.500	,	- 3.548	,	- 3.645	\	/*
*/	- 3.485	,	- 3.526	,	- 3.606	)

}

else if `numindepvar' == 4 & "`trend'" == "" {

mat `crit' = (	- 3.692	,	- 3.804	,	- 4.010	\	/*
*/	- 3.624	,	- 3.714	,	- 3.887	\	/*
*/	- 3.588	,	- 3.670	,	- 3.820	\	/*
*/	- 3.560	,	- 3.643	,	- 3.784	\	/*
*/	- 3.538	,	- 3.607	,	- 3.746	\	/*
*/	- 3.515	,	- 3.579	,	- 3.702	\	/*
*/	- 3.496	,	- 3.551	,	- 3.658	\	/*
*/	- 3.475	,	- 3.523	,	- 3.620	\	/*
*/	- 3.459	,	- 3.507	,	- 3.584	)

}

else if `numindepvar' == 4 & "`trend'" != "" {

mat `crit' = (	- 3.983	,	- 4.098	,	- 4.299	\	/*
*/	- 3.921	,	- 4.009	,	- 4.185	\	/*
*/	- 3.878	,	- 3.955	,	- 4.108	\	/*
*/	- 3.853	,	- 3.927	,	- 4.064	\	/*
*/	- 3.831	,	- 3.898	,	- 4.025	\	/*
*/	- 3.805	,	- 3.865	,	- 3.972	\	/*
*/	- 3.785	,	- 3.845	,	- 3.953	\	/*
*/	- 3.764	,	- 3.817	,	- 3.906	\	/*
*/	- 3.749	,	- 3.793	,	- 3.881	)

}

mat `trange' = (10 \ 15 \ 20 \ 25 \ 30 \ 40 \ 50 \ 70 \ 999)

forvalues p = 1 / 9 {

if `ng' <= `trange'[`p',1] {

forvalues q = 1 / 3 {

if `ectbar' <= `crit'[`p',`q'] {

local geng = `q'

}

}

continue,break

}

}

if missing("`geng'") {

local geng = 0

}


if `geng' == 1 {

local peng = "<=0.1"

}

else if `geng' == 2 {

local peng = "<=0.05"

}

else if `geng' == 3 {

local peng = "<=0.01"

}

else {

local peng = ">0.1"

}


*****CD-Statistic*****

tempname cd

mat `cd' = J(`numindepvar'+2,2,.)

mat rownames `cd' = `variables' e

mat colnames `cd' = CD P-val

local cdcount = 0

foreach var of local varlist {

	tempname mean`var' dem`var' cd`var' pcd`var'

	qui egen `mean`var'' = mean(`var') if `touse'

	qui gen `dem`var'' = `var'-`mean`var'' if `touse'

	local cdlist `cdlist' `dem`var''

}

local cdlist `cdlist' `resid'

foreach var of local cdlist {

	qui capture xtcd2 `var', noest

	local cdcount = `cdcount' + 1 

	mat `cd'[`cdcount',1] = r(CD)

	mat `cd'[`cdcount',2] = 2*normal(-abs(r(CD)))

}


**********************************
*****Display and Store Results****
**********************************

***Store residuals****

if ("`res'" != ""){

capture confirm new variable `res'

if _rc!=0{

display as error  "Variable `res' to hold residuals already exists."

exit

}

gen `res' = `resid'

}

***Results***

display ""

display in gr "{bf:Mean-group error correction models with variable cross-sectional averages}"

display in gr "Following Chudik & Pesaran (2015); Gengenbach, Urbain & Westerlund (2015); Eberhardt & Presbitero (2015)"

display ""

if ("`select'" !=""){

display in gr "Group-specific lag selection enabled"

} 

if ("`trend'" !=""){

display in gr "Group-specific linear trend included"

} 

if ("`noca'" !=""){

display in gr "No cross-sectional averages included"

} 

display in gr "Dependent variable y: " in ye "`depvar'"

display ""

******Mean-group Ec-model*****

display ""

ereturn post `b2'  `V2' ,  depname(d.`depvar') 

if "`mg'" != "" {

display in gr "{ye:Mean-group error correction model:}"

ereturn display

}

****Gengenbach et al panel test****

display ""

display in gr "{ye:Panel EC-test:}"


display as text  "{hline 15}{c TT}{hline 33}"

display as text _col(12) "d.y {c |}" _col(23) "Coef" _col(32) "T-bar" _col(42) "P-val*"  

display as text  "{hline 15}{c +}{hline 33}"

display as text _col(9) "y(t-1) {c |}" _col(18) as result %9.3f `ecc' _col(28) %9.3f `ectbar' _col(43) %9.3f "`peng'"  

display as text  "{hline 15}{c BT}{hline 33}"

****Long-Run average coefficients****

display ""

display in gr "{ye:Long-run average coefficients:}"

if `numindepvar' == 1 {

qui nlcom (`indepvar1': -_b[l.`indepvar1'] / _b[l.`depvar']), post

}

else if `numindepvar' == 2 {

qui nlcom (`indepvar1': -_b[l.`indepvar1'] / _b[l.`depvar']) (`indepvar2': -_b[l.`indepvar2'] / _b[l.`depvar']) , post

}

else if `numindepvar' == 3 {

qui nlcom (`indepvar1': -_b[l.`indepvar1'] / _b[l.`depvar']) (`indepvar2': -_b[l.`indepvar2'] / _b[l.`depvar']) (`indepvar3': -_b[l.`indepvar3'] / _b[l.`depvar']) , noheader post

}

else if `numindepvar' == 4 {

qui nlcom (`indepvar1': -_b[l.`indepvar1'] / _b[l.`depvar']) (`indepvar2': -_b[l.`indepvar2'] / _b[l.`depvar']) (`indepvar3': -_b[l.`indepvar3'] / _b[l.`depvar']) (`indepvar4': -_b[l.`indepvar4'] / _b[l.`depvar']), noheader post

}

tempname bnlcom Vnlcom

mat `bnlcom' = e(b)

mat `Vnlcom' = e(V)

ereturn post `bnlcom' `Vnlcom', depname(`depvar')

ereturn display

*****Average Long-run coefficients****

if "`avlr2'" != "" {

	display ""

	ereturn post `avlr' `vavlr',  depname(`depvar') 

	display in gr "{ye:Average long-run coefficients:}"

	ereturn display

}

****Cd-test******

display ""

display in gr "{ye:Pesaran (2015) CD-test:}"
matlist `cd', border(rows) noblank rowtitle(Variable)  twidth(14) format(%9.3f)

display ""

display "Root mean square error: " in ye %5.4f sqrt(`sigma2')

display in gr "Number of observations: " in ye `nobs'

display in gr "Number of groups: " in ye `ng'

****Plot long-run coefficients****

if "`lrplot'" != "" {

	if `lrplot' > `numindepvar' {

		di as err "Misspecified number in lrplot()."

		exit 121

	}

	coefplot matrix(`ilr'[,`lrplot']), se(`selrindiv'[,`lrplot']) vertical xtitle(Group id) ytitle(Long-run coefficient)

}


*****Post results*****

ereturn post `b'  `V' , esample(`touse') depname(d.`depvar') obs(`nobs')

qui ereturn display

ereturn scalar ng = `ng'

ereturn scalar rmse = sqrt(`sigma2')

ereturn matrix t_ilr = `tlrindiv'

ereturn matrix se_ilr = `selrindiv'

ereturn matrix ilr = `ilr'

ereturn matrix t_ib = `tindiv'

ereturn matrix se_ib = `seindiv'

ereturn matrix ib = `bindiv2'


end



***end of ado

