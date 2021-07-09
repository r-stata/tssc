*! version 1.0.3 Stephen P. Jenkins, March 2020
*! 		 Address a version 14 formatting issue in -tabdisp-
*! version 1.0.2 Stephen P. Jenkins, January 2020
*!       Add Hplus and Hminus options 
*! version 1.0.1 Stephen P. Jenkins, January 2020
*!       Address -levelsof- version issue 
*! version 1.0.0 Stephen P. Jenkins, December 2019
*!   Indices for inequality and polarization with ordinal data



program ineqord, sortpreserve rclass byable(recall)

version 14

syntax varname(numeric) [aweight fweight pweight iweight] [if] [in] 		///
	[, Alpha(real 99) NLevels(integer 999) MINLevel(integer 1) 		///
	USTatusvar(string) DSTatusvar(string)  					///
	CATVals(string) CATProps(string) CATCprops(string) GLDvar(string) 	///
	CATSprops(string) GLUvar(string) HPlus(string) HMinus(string)  ] 

local cat "`varlist'"

if "`ustatusvar'" != "" & _bylastcall()  confirm new variable `ustatusvar'
if "`dstatusvar'" != "" & _bylastcall()  confirm new variable `dstatusvar'
if "`catvals'" != "" & _bylastcall()  confirm new variable `catvals'
if "`catprops'" != "" & _bylastcall()  confirm new variable `catprops'
if "`catcprops'" != "" & _bylastcall()  confirm new variable `catcprops'
if "`gldvar'" != "" & _bylastcall()  confirm new variable `gldvar'
if "`catsprops'" != "" & _bylastcall()  confirm new variable `catsprops'
if "`gluvar'" != "" & _bylastcall()  confirm new variable `gluvar'
if "`hplus'" != "" & _bylastcall()  confirm new variable `hplus'
if "`hminus'" != "" & _bylastcall()  confirm new variable `hminus'


tempvar wi fi nls ds_i us_i i0d ioneqd ihalfd ithreeqd i0u ionequ ihalfu ithreequ ixd ixu
  

if "`weight'" == "" gen byte `wi' = 1
else gen `wi' `exp'

marksample touse
markout `touse'
if _by() quietly replace `touse' = 0 if `_byindex' != _byindex()


if (`alpha')==0 | (`alpha')==0.25  | (`alpha')==0.5  | (`alpha')==0.75 {
	local alpha = 99
}
if `alpha' <  0 | (`alpha' >= 1  & `alpha' != 99) {
	di as error "alpha must be at least 0 and less than 1"
	error 198
}

qui count if `touse'
if r(N) == 0 error 2000
	
lab var `touse' "All obs"
lab def `touse' 1 " "
lab val `touse' `touse'

set more off
	
quietly {

	levelsof `cat'  if `touse', local(catslist)

* 	local n_distinct_cats = r(r)   // version 16 syntax doesn't work for version < 15.1
	local n_distinct_cats = wordcount(r(levels))  

	return scalar n_distinct_cats = `n_distinct_cats'
	return local cats_list  `catslist'

	sum `cat' [aw = `wi'] if `touse', de

	local sumwi = r(sum_w)
	local mean = r(mean)
	local median = r(p50)
	local sd = r(sd)
	local var = r(Var)
	local min = r(min)
	local max = r(max)
	
	if (`nlevels' < `n_distinct_cats')   {
		di as error "For correct calculation of Apouey indices, the total number" 
		di as error "of possible levels of the response variable must be specified."
		di as error "You've specified a value less than the number observed." 
		di as error "The total is being reset to the observed number."
		local nlevels = `n_distinct_cats'
	}
	if `nlevels' == 999 local nlevels = `n_distinct_cats'
	
	return scalar mean = r(mean)
	return scalar median = r(p50)
	return scalar Var = r(Var)
	return scalar sd = r(sd)
	return scalar sumw = r(sum_w)
	return scalar N = r(N)
	return scalar min = r(min)
	return scalar max = r(max)
	return scalar nlevels = `nlevels'
	return scalar minlevel = `minlevel'
	
	* weights (in normalised form)
	gen double `fi' = `wi' / `sumwi' if `touse'

	* Dutta-Foster index
	
	tempvar cat_fi cat_Fi catval dfF lterm1 lterm1x avbelow hterm1 hterm1x avabove 

	ge `catval' = . in 1/`n_distinct_cats'
	ge `cat_fi' = . in 1/`n_distinct_cats'
	ge `cat_Fi' = 0 in 1/`n_distinct_cats'
	ge `dfF' = 0 in 1/`n_distinct_cats'
	local jmedian = 0   // is the median among the observed categories
	local medfirst = 0
	local j = 1
	foreach i of local catslist {
		sum `cat' [aw = `wi'] if `touse' & `cat' == `i', meanonly
		replace `cat_fi' = r(sum_w)/`sumwi' in `j'
		replace `catval' = r(mean) in `j'
		replace `cat_Fi' = `cat_fi' in 1 if `j' == 1  // cumulative sum
		replace `cat_Fi' = `cat_fi' + `cat_Fi'[_n-1] in `j' if `j' > 1  // cumulative sum
		if `median' == `i'  local jmedian = 1
		if `median' == `i' & `j' == 1  local medfirst = 1
		local j = `j' + 1
	}


	egen `lterm1' = total( 2 * `catval' * `cat_fi' ) if `catval' < `median'
	replace `lterm1' = 0 if missing(`lterm1') & `catval' < `median'
	su `lterm1', meanonly
	local l1 = r(mean)
	if `medfirst' == 1 local l1 = 0	
	ge `lterm1x' = .
	replace `lterm1x' = 2*`catval' * (0.5 - `cat_Fi'[_n-1] ) if `catval' == `median' & `medfirst' == 0
	replace `lterm1x' = 2*`catval' * (0.5 ) if `catval' == `median' & `medfirst' == 1
	su `lterm1x', meanonly
	local l1x = r(mean)
	if `jmedian' == 0  local l1x = 0	
	local dfmeanbelow = `l1' + `l1x'
	
	egen `hterm1' = total( 2 * `catval' * `cat_fi' ) if `catval' > `median' 
	replace `hterm1' = 0 if missing(`hterm1') & `catval' > `median'	
	ge `hterm1x' = .
	replace `hterm1x' = 2*`catval' * (`cat_Fi' - 0.5) if `catval' == `median'
	su `hterm1', meanonly
	local h1 = r(mean)
	su `hterm1x', meanonly
	local h1x = r(mean)
	if `jmedian' == 0  local h1x = 0		
	local dfmeanabove = `h1' + `h1x'
	
	local allisonfoster = `dfmeanabove' - `dfmeanbelow'
	return scalar dfmeanabove = `dfmeanabove'
	return scalar dfmeanbelow = `dfmeanbelow'
	return scalar s_H = `dfmeanabove' - `median'
	return scalar s_L = `median' - `dfmeanbelow'
	return scalar allisonfoster = `allisonfoster'

	
	*  Normalised average absolute jump (to median)
	*    [Allison-Foster 2004, p. 514 refer to unnormalised version of this
	* 			for linear scale]
	* 
		
	tempvar aj
	egen `aj' = total( 2 * `cat_fi' * abs(`catval' - `median')/(`nlevels' - 1))
	local AJ = `aj'[1]
	return scalar avjump = `AJ'

	gsort -`touse' `cat' 
	tempvar sortorder
	ge long `sortorder' = _n


		// downward-looking status 
		// 	(with upward-looking status calculated at end so as 
		// 	not to muck up sort order with its sort order change

	cumul `cat' [aw = `wi'] if `touse', gen(`ds_i') equal  
	sort `sortorder'

	if "`dstatusvar'" != "" { 
		ge `dstatusvar' = `ds_i'
		lab var `dstatusvar' "Downward-looking status"
	}

	
	* Blair-Lacy index = 1 - l-squared
	* Apouey index with alpha = 0.5 [B-L index is Apouey's P2(alpha) with alpha=2]
	
	tempvar F F2 D2 D2adj cat2 g A A2

	clonevar `cat2' = `cat'
	if `minlevel' != 1  {
		replace `cat2' = `cat' - `minlevel' + 1 
		noi di "Note: `cat' rescaled for calculation of Apouey indices (see help file)"
		noi 
	}
	sum `cat2' [aw = `wi'] if `touse', de
	return scalar mean_rescaled = r(mean)
	return scalar median_rescaled = r(p50)
	return scalar  sd_rescaled = r(sd)
	return scalar  var_rescaled = r(Var)
	return scalar  min_rescaled = r(min)
	return scalar  max_rescaled = r(max)
	
	local newmedian = r(p50)
	

		// calculations here in order to deal with case of zero obs in a category
		//	(as in complete polarization case, for example)
	
	ge `F' = 0 in 1/`nlevels'
	forvalues k = 1/`nlevels' {
		su `ds_i' if `cat2' == `k' , meanonly  
			// don't need weights; same value for all in same cat
		if r(N) > 0 replace `F' = r(mean) in `k'
	}
	replace `F' = `F'[_n-1] if `F' == 0 & `F'[_n-1] > 0 & !missing(`F'[_n-1])
	ge `F2' = (`F' - 0.5)^2
	capture egen `D2' = total(`F2') in 1/`=`nlevels'-1' 
	if _rc {
		noi tab `cat'
		di as error "Check distribution of responses on `cat' and consider use of nlevels() option"
		exit 198
	}	

	ge `A' = sqrt( abs(`F' - 0.5) )
	capture egen `A2' = total(`A') in 1/`=`nlevels'-1' 
	
	if _rc {
		noi tab `cat'
		di as error "Check distribution of responses on `cat' and consider use of nlevels() option"
		exit 198
	}
	ge `D2adj' = (4/`=`nlevels'-1')*`D2'
	local D2 = `D2'[1]
	local DsqOverDmaxsq = `D2adj'[1]
	local BL = 1 - `DsqOverDmaxsq'
	* BL = 1 - l-squared 
	*      where l-squared = (d-squared / (dmax-squared) and dmax = (`nlevels'-1)/4
*	return scalar DsqOverDmaxsq = `DsqOverDmaxsq'
	return scalar blairlacy = `BL'

	return scalar apouey2 = `BL'
	
	* Apouey index, P2(e) with e = 0.5
	
	local A3 = `A2'[1]
	local Ahalf = 1 - (  ( sqrt(2) /`=`nlevels'-1') * `A3' )
	return scalar apoueypt5 = `Ahalf'

	* Apouey index, P2(e) with e = 1

	tempvar A1 A1s
	ge `A1' = abs(`F' - 0.5)
	capture egen `A1s' = total(`A1') in 1/`=`nlevels'-1' 
	if _rc {
		noi tab `cat'
		di as error "Check distribution of responses on `cat' and consider use of nlevels() option"
		exit 198
	}

	local A1s1 = `A1s'[1]
	local Aone = 1 - (  ( 2 /`=`nlevels'-1') * `A1s1' )
	return scalar apouey1 = `Aone'


	* Jenkins Area-based index, 
	* 	Jd = area under GL curve for peer-inclusive downward-looking status
	* 	Ju = area under GL curve for peer-inclusive upward-looking status
	* 	NB need to use nlevels() option if there are categories with no obs


	tempvar Fdiff FdiffF FdiffFsum S GLd GLu GLlag GLlead Jd Ju   

	ge `Fdiff' = `F' in 1			// `Fdiff' is f_k
	ge `FdiffF' = `F' * `F' in 1

	forvalues k = 2/`nlevels' {

		replace `Fdiff' = (`F' - `F'[_n-1]) in `k'
		
		replace `FdiffF' = `Fdiff' * `F' in `k'

	}

	ge `GLd' = .
	ge `GLlag' = 0 
	ge `FdiffFsum' = sum( `FdiffF' )

	if "`catvals'" != "" { 
		ge `catvals' = .
		lab var `catvals' "Response"
	}


	forvalues k = 1/`nlevels' {

		replace `GLd' = `FdiffFsum' in `k'
		if `k' > 1   replace `GLlag' = `GLd'[_n-1] in `k'

		if "`catvals'" != ""  replace `catvals' = `k' in `k'

	}

	ge `S' = 1 in 1
	ge `GLu' = `FdiffFsum'[`nlevels'] in 1
	ge `GLlead' = 0 in `nlevels'

	forvalues k = 2/`nlevels' {

		replace `S' = (`S'[_n-1] - `Fdiff'[_n-1]) in `k'
		replace `GLu' = `GLu'[_n-1]  -  `Fdiff'[_n-1] * `S'[_n-1] in `k' 

	}

	forvalues k = 1/`=`nlevels'-1' {

		replace `GLlead' = `GLu'[_n+1] in `k'

	}

	egen `Jd' = total( `Fdiff' * ( `GLd' + `GLlag' ) ) if !missing(`GLd')
	replace `Jd' = 1 - `Jd'
	return scalar Jd = `Jd'

	egen `Ju' = total( `Fdiff' * ( `GLu' + `GLlead' ) ) if !missing(`GLu')
	replace `Ju' = 1 - `Ju'
	return scalar Ju = `Ju'

	******* Gravel, Magdalou, Moyes H and Hbar (i.e. H+ and H-, respectively) *******	

	if "hplus" != "" {

		* Hplus(k) for i = 1, ..., K-1
	
		tempvar Hp

		ge `Hp' = .
		replace `Hp' = `F' in 1
		replace `Hp' = 2*`Hp'[_n-1] + `F' - `F'[_n-1] in 2/`nlevels'
	
	}	

	if "hminus" != "" {

		* H_minus(k) for i = 1, ..., K-1
		tempvar S2 Hm
	
		ge `S2' = 1 - `F'
		ge `Hm' = .
	
		replace `Hm' = 0 in `nlevels'
		replace `Hm' = `S2'[_n-1] in `=`nlevels'-1'

		forval i = `=`nlevels'-2'(-1)1  {
	
			replace `Hm' = 2*`Hm'[_n+1] + `S2' - `S2'[_n+1] in `i'
	
		}	

	}

	if "`gldvar'" != "" {
		ge `gldvar' = `GLd'
		lab var `gldvar' "GL ordinate (downward-looking)"
		replace `gldvar' = 0 in `=`nlevels'+1'
	}

	if "`gluvar'" != "" {
		ge `gluvar' = `GLu'
		lab var `gluvar' "GL ordinate (upward-looking)"
		replace `gluvar' = 0 in `=`nlevels'+1'
	}


	if "`hplus'" != "" {
		ge `hplus' = `Hp'
		lab var `hplus' "H+ curve ordinate"
		replace `hplus' = 0 in `=`nlevels'+1'
	}

	if "`hminus'" != "" {
		ge `hminus' = `Hm'
		lab var `hminus' "H- curve ordinate"
		replace `hminus' = 0 in `=`nlevels'+1'
	}


	if "`catprops'" != "" { 
		ge `catprops' = `Fdiff'
		lab var `catprops' "Proportion"
	}

	if "`catcprops'" != "" { 
		ge `catcprops' = `F'
		lab var `catcprops' "Cumulative proportion (same or below)"
		replace `catcprops' = 0 in `=`nlevels'+1'
	}

	if "`catsprops'" != "" { 
		ge `catsprops' = `S'
		lab var `catsprops' "Cumulative proportion (same or above)"
		replace `catsprops' = 0 in `=`nlevels'+1'
	}


	* Abul Naga & Yalcin indices (user needs to ensure nlevels correct)
	
	tempvar any11_l any11_h any21_l any21_h any12_l any12_h  ///
			any41_l any41_h any14_l any14_h


			// ANY: "state m is the median if Pm-1 <= 0.5 and Pm => 0.5"
			//      but the following code leads to error (newmedian empty) if e.g. P in category 1 > .5 !
	/* 
	forval k = 1/`nlevels' {

		if `F'[`=`k'-1'] <= .5 & `F'[`k'] >= .5  local newmedian = `k'

	} 
	*/
	
			// Hence fix-up (which also deals with cases when Stata produces non-integer median
			//			as e.g. can arise with a polarized distribution		
	*	local anymedian = ceil(`median')
	local  anymedian = ceil(`newmedian')
	return scalar anymedian = `anymedian'
	noi if "`minlevel'" != "1" di "Warning: summary statistics for rescaled responses differ from those for observed responses"


		* ANY(1,1)
	egen `any11_l' = total(`F') if _n < `anymedian' & !missing(`F')
	summ `any11_l' , meanonly
	local any11_lx = r(mean)
	if r(N) == 0 local any11_lx = 0
	egen  `any11_h' = total(`F') if _n >= `anymedian' & !missing(`F')
	summ `any11_h', meanonly
	local any11_hx = r(mean)
	local nn = `any11_lx' - `any11_hx' + `nlevels' + 1 - `anymedian'
	local dd = (`anymedian'-1)*(.5) - (1 + (`nlevels'-`anymedian')*(.5)) + `nlevels' + 1 - `anymedian'
	local any11 = `nn' / `dd'
		* ANY(2,1)
	egen `any21_l' = total((`F')^2) if _n < `anymedian' & !missing(`F')
	summ `any21_l' , meanonly
	local any21_lx = r(mean)
	if r(N) == 0 local any21_lx = 0
	egen  `any21_h' = total(`F') if _n >= `anymedian' & !missing(`F')
	summ `any21_h', meanonly
	local any21_hx = r(mean)
	local nn = `any21_lx' - `any21_hx' + `nlevels' + 1 - `anymedian'
	local dd = (`anymedian'-1)*(.5)^2 - (1 + (`nlevels'-`anymedian')*(.5)) + `nlevels' + 1 - `anymedian'
	local any21 = `nn' / `dd'	
		* ANY(1,2)
	egen `any12_l' = total(`F') if _n < `anymedian' & !missing(`F')
	summ `any12_l' , meanonly
	local any12_lx = r(mean)
	if r(N) == 0 local any12_lx = 0
	egen  `any12_h' = total((`F')^2) if _n >= `anymedian' & !missing(`F')
	summ `any12_h', meanonly
	local any12_hx = r(mean)
	local nn = `any12_lx' - `any12_hx' + `nlevels' + 1 - `anymedian'
	local dd = (`anymedian'-1)*(.5) - (1 + (`nlevels'-`anymedian')*(.5)^2) + `nlevels' + 1 - `anymedian'
	local any12 = `nn' / `dd'	
		* ANY(4,1)
	egen `any41_l' = total((`F')^4) if _n < `anymedian' & !missing(`F')
	summ `any41_l' , meanonly
	local any41_lx = r(mean)
	if r(N) == 0 local any41_lx = 0
	egen  `any41_h' = total(`F') if _n >= `anymedian' & !missing(`F')
	summ `any41_h', meanonly
	local any41_hx = r(mean)
	local nn = `any41_lx' - `any41_hx' + `nlevels' + 1 - `anymedian'
	local dd = (`anymedian'-1)*(.5)^4 - (1 + (`nlevels'-`anymedian')*(.5)) + `nlevels' + 1 - `anymedian'
	local any41 = `nn' / `dd'	
		* ANY(1,4)
	egen `any14_l' = total(`F') if _n < `anymedian' & !missing(`F')
	summ `any14_l' , meanonly
	local any14_lx = r(mean)
	if r(N) == 0 local any14_lx = 0
	egen  `any14_h' = total((`F')^4) if _n >= `anymedian' & !missing(`F')
	summ `any14_h', meanonly
	local any14_hx = r(mean)
	local nn = `any14_lx' - `any14_hx' + `nlevels' + 1 - `anymedian'
	local dd = (`anymedian'-1)*(.5) - (1 + (`nlevels'-`anymedian')*(.5)^4) + `nlevels' + 1 - `anymedian'
	local any14 = `nn' / `dd'	
	
	return scalar any11 = `any11'
	return scalar any21 = `any21'
	return scalar any12 = `any12'
	return scalar any41 = `any41'
	return scalar any14 = `any14'		
	

	* Cowell-Flachaire indices

	// upward-looking status variable (downward-looking status variable created and used earlier)

	gen `nls' = - `cat'

	cumul `nls' [aw = `wi'] if `touse', gen(`us_i') equal
	sort `sortorder'

	if "`ustatusvar'" != "" {
		ge `ustatusvar' = `us_i'
		lab var `ustatusvar' "Upward-looking status"
	}

	egen double `i0d' = total( `fi' * -log(`ds_i')  ) if `touse'
	egen double `i0u' = total( `fi' * -log(`us_i')  ) if `touse'

	egen double `ioneqd' = total( `fi' * -(16/3)*((`ds_i')^.25 - 1)  ) if `touse'
	egen double `ionequ' = total( `fi' * -(16/3)*((`us_i')^.25 - 1)  ) if `touse'

	egen double `ihalfd' = total( `fi' * -4*(sqrt(`ds_i')-1)  ) if `touse'
	egen double `ihalfu' = total( `fi' * -4*(sqrt(`us_i')-1)  ) if `touse'

	egen double `ithreeqd' = total( `fi' * -(16/3)*((`ds_i')^.75 - 1)  ) if `touse'
	egen double `ithreequ' = total( `fi' * -(16/3)*((`us_i')^.75 - 1)  ) if `touse'

	if "`alpha'" != "" & `alpha' != 99 {
	
	egen double `ixd' = total( `fi' * (1/(`alpha'*(`alpha'-1)))*((`ds_i')^`alpha' - 1)  ) if `touse'
	egen double `ixu' = total( `fi' * (1/(`alpha'*(`alpha'-1)))*((`us_i')^`alpha' - 1)  ) if `touse'
	return scalar ixd = `ixd'[1] 
	return scalar ixu = `ixu'[1] 
	}

	return scalar i0d = `i0d'[1] 
	return scalar i0u = `i0u'[1] 
	return scalar ioneqd = `ithreeqd'[1] 
	return scalar ionequ = `ithreequ'[1] 
	return scalar ihalfd = `ihalfd'[1] 
	return scalar ihalfu = `ihalfu'[1] 		
	return scalar ithreeqd = `ithreeqd'[1] 
	return scalar ithreequ = `ithreequ'[1] 

	label var `i0d' "I(0)"
	label var `ioneqd' "I(.25)"
	label var `ihalfd' "I(.5)"
	label var `ithreeqd' "I(.75)"
	label var `i0u' "I(0)"
	label var `ionequ' "I(.25)"
	label var `ihalfu' "I(.5)"
	label var `ithreequ' "I(.75)"

	if "`alpha'" != "" & `alpha' != 99 {
		label var `ixd' "I(`alpha')"
		label var `ixu' "I(`alpha')"
	}

	tempvar Median Mean SD Var NCats Min Max AllisonFoster BlairLacy AvJump 
	tempvar	Apoueypt5 Apouey1 Apouey2 ANY11 ANY21 ANY12 ANY41 ANY14 Jdvar Juvar

	ge double `Median' = `median' in 1
	ge double `Mean' = `mean' in 1
	ge double `SD' = `sd' in 1
	ge double `Var' = `var' in 1
	ge `NCats' = `n_distinct_cats' in 1
	ge `Min' = `min' in 1
	ge `Max' = `max' in 1
	ge `AllisonFoster' = `allisonfoster' in 1
	ge `AvJump' = `AJ' in 1
	ge `BlairLacy' = `BL' in 1
	ge `Apouey2' = `BL' in 1
	ge `Apouey1' = `Aone' in 1
	ge `Apoueypt5' = `Ahalf' in 1
	ge `ANY11' = `any11' in 1
	ge `ANY21' = `any21' in 1
	ge `ANY12' = `any12' in 1
	ge `ANY41' = `any41' in 1
	ge `ANY14' = `any14' in 1
	ge `Jdvar' = `Jd' in 1
	ge `Juvar' = `Ju' in 1

	label var `Mean' "mean"
	label var `Median' "median"
	label var `SD' "sd"
	label var `Min' "min"
	label var `Max' "max"
	label var `Var' "variance"
	label var `NCats' "# levels"
	label var `AllisonFoster' "A-F"	    
	label var `BlairLacy' "Blair-Lacy"
	label var `AvJump' "Av. Jump"
	label var `Apouey2' "P2(2)"
	label var `Apouey1' "P2(1)"
	label var `Apoueypt5' "P2(.5)"
	label var `ANY11' "ANY(1,1)"
	label var `ANY21' "ANY(2,1)"
	label var `ANY12' "ANY(1,2)"
	label var `ANY41' "ANY(4,1)"
	label var `ANY14' "ANY(1,4)"
	label var `Jdvar' "Jd"
	label var `Juvar' "Ju"

	noi { 

		di " "
		di as txt "Summary statistics for observed levels" 
		tabdisp `touse' in 1, c(`Min' `Max' `NCats' `Median') f(%9.0f) center

		di " "
		di as txt "Mean, variance, and standard deviation of observed levels"
		tabdisp `touse' in 1, c(`Mean' `Var' `SD') f(%9.5f) 
		
		di " "
		di as txt "Polarization indices: Allison-Foster; Average Jump; Apouey P2(2); Apouey P2(1); Apouey P2(.5) "
		tabdisp `touse' in 1, c(`AllisonFoster' `AvJump' `Apouey2' `Apouey1' `Apoueypt5') f(%9.5f) 
		
		di " "
		di as txt "Polarization indices: Abul Naga-Yalcin(a,b)"
*		if `median' != `anymedian' di as txt "          Note: calculation uses median = `anymedian'"
		tabdisp `touse' in 1, c(`ANY11' `ANY21' `ANY12' `ANY41' `ANY14') f(%9.5f) 

		if "`alpha'" != "" & `alpha' == 99 {
			di "  "
			di as txt "Inequality indices: Cowell-Flachaire, downward-looking status"
			tabdisp `touse' in 1, c(`i0d' `ioneqd' `ihalfd' `ithreeqd' ) f(%9.5f) 

			di "  "
			di as txt "Inequality indices: Cowell-Flachaire, upward-looking status"
			tabdisp `touse' in 1, c(`i0u' `ionequ'  `ihalfu' `ithreequ' ) f(%9.5f)
		}

		if "`alpha'" != "" & `alpha' != 99 {
			di "  "
			di as txt "Inequality indices: Cowell-Flachaire, downward-looking status"
			tabdisp `touse' in 1, c(`i0d' `ioneqd' `ihalfd' `ithreeqd' `ixd') f(%9.5f) 

			di "  "
			di as txt "Inequality indices: Cowell-Flachaire, upward-looking status"
			tabdisp `touse' in 1, c(`i0u' `ionequ' `ihalfu' `ithreequ' `ixu') f(%9.5f)
		}

		di " "
		di as txt "Inequality indices: J_d (downward-looking status); J_u (upward-looking status)"
		tabdisp `touse' in 1, c(`Jdvar' `Juvar') f(%9.5f) 



	}	


}	// end quietly block


end
