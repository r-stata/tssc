* prody.ado
* Author: Stephan Huber (University of Regensburg)
* Version 17Mar2017
* please report bugs to stephan.huber@wiwi.uni-regensburg.de


//cap program drop prody
//cap program drop noi_prody

program define prody
version 12

syntax  [if] [in] using/ , 	TRade(varname) gdp(varname) id(varname) ///
							PRODuct(varname) ///
							[Time(varname) REPlace VERsion(namelist min=1 max=8) ///
							BALance(namelist min=1 max=1) sample(str)]
	
	if substr("`using'",-3,.)!="dta" local using `using'.dta
	if "`replace'"==""{
		cap confirm file `using' // we check this before calculating all indices
		if !_rc {
			di as err "file `using' already exists"
			exit 602
			}
		}
	if "`sample'"!=""{
		if substr("`sample'",-3,.)!="dta" local sample `sample'.dta
		if "`replace'"=="" {
			cap confirm file `sample'
			if !_rc {
				di as err "file `sample' already exists"
				exit 602
				}
			}
		}
	
	preserve
	
	qui noi_prody `0'
	
	if "`sample'"!=""{
		if substr("`sample'",-3,.)!="dta" local sample `sample'.dta
		di as text "file `sample' saved"
		}
	save `using', `replace'
end



program define noi_prody
version 12

syntax  [if] [in] using/ , 	TRade(varname) gdp(varname) id(varname) ///
							PRODuct(varname) ///
							[Time(varname) REPlace VERsion(namelist min=1 max=8) ///
							BALance(namelist min=1 max=1) sample(str)]
							
							// possible VERsions: meangdp meantrade timevarying mean1 mean2
							// possible BALance: none weak strong
					

*************************************************************
***************
* parse version : hausmann, mean_before, mgdp, mtrde, tvar
	local n_ver=wordcount("`version'")
	
	local hausmann = 0
	local mgdp     = 0
	local mtrde    = 0
	local tvar     = 0
	local mean_before = 0
	local lall     = 0
	local michaely = 0
	local michaely1 = 0
	tokenize `version'
	forval l=1/`n_ver'{
		if "``l''" == "mean1" local mean_before = 1
		if "``l''" == "mean2" {
			if "`time'"=="" & `mean_before' noi di as txt "In cross-section the versions mean1 and mean2 are the same, hence only mean1 will be calculated"
			else local hausmann = 1
			}
		if "``l''" == "meangdp" {
			if "`time'"=="" di as err "The meangdp-version is only calculated in panel case"
			else local mgdp = 1
			}
		if "``l''" == "meantrade" {
			if "`time'"=="" di as err "The meantrade-version is only calculated in panel case"
			else local mtrde = 1
			}
		if "``l''" == "timevarying" {
			if "`time'"=="" di as err "The timevarying-version is only calculated in panel case"
			else local tvar = 1
			}
		if "``l''" == "lall" local lall = 1
		if "``l''" == "mic1" local michaely = 1
		if "``l''" == "mic2" local michaely1 = 1
		}
	if `n_ver'==0{
		if "`time'"!="" local hausmann    = 1
		local mean_before = 1
		if "`time'"!="" local mgdp        = 1
		if "`time'"!="" local mtrde       = 1
		if "`time'"!="" local tvar        = 1
		local lall        = 1
		local michaely    = 1
		local michaely1   = 1
		}
		
******** check wheter balance() is correctly specified
	if "`balance'"!=""&("`balance'"=="weak" | "`balance'"=="none" | "`balance'"=="strong"){
		}
	*if "`balance'"!=""
	else if "`balance'"!=""{
		di as err "option balance()  not correctly specified" 
		di as err "accaptable specifications are: 'none', 'weak' and 'strong'"
		exit 198
		}
		
****************************************
* Check if time variable should be specified
	tempvar dup
	if "`time'"=="" {
		duplicates tag `id' `product', generate(`dup')
		su `dup'
		if `r(max)'>=1 {
			di as err "`id' and `product' do not uniquely identify observations."
			di as err "Perhaps you should specify a time-variable?"
			exit 459
			}
		}
*****************************************


marksample touse
keep if `touse'
cap drop _merge

tempfile result
	
**************************************************************
* routine for balancing the sample:
	if "`balance'"==""{
		drop if `gdp'==. | `trade'==.
		tempvar ncount
		tempvar diff
		by `id' `product' , sort:  gen `ncount'=_N
		by `product' , sort:  egen `diff'=max(`ncount')
		replace `diff'=`diff'-`ncount'
		su `diff'
		if `r(min)'!=`r(max)' {
			di as err "your dataset doesn't seem to be balanced, please specify how data shall be balanced"
			exit 459
			}
		}
		
		
	if "`balance'"=="none"{
		drop if `gdp'==. | `trade'==.
		}
		
	else if "`balance'"=="strong" |"`balance'"=="weak"{
		if "`time'"!="" {
			drop if `gdp'==. | `trade'==.
			fillin `time' `id'
			levelsof `id' if _fillin==1, local(out)
			cap confirm string var `id'
			if !_rc{
				foreach drop of local out{
					drop if `id'=="`drop'"
					}
				}
			else {
				foreach drop of local out{
					drop if `id'==`drop' // only `id's without gaps over `time'
					}
				}
				
			if "`balance'"=="strong"{
				tempvar ncount 
				tempvar diff
				by `id' `product' , sort:  gen `ncount' = _N
				tab `time'
				local max = `r(r)'
				drop if `ncount' != `max' // every `id' owns a homogenous subsample of `product' over `time'
				}
			}
		**********************************************************************************
		if "`time'"==""& "`balance'"=="strong" { // use a rectangular dataset in that case
			fillin `id' `product'
			levelsof `product' if _fillin==1, local(out)
			cap confirm string var `product'
			if !_rc{
				foreach drp of local out{
					drop if `product'=="`drp'"
					}
				}
			else {
				foreach drp of local out{
					drop if `product'==`drp'
					}
				}
			}
		**********************************************************************************
		if "`time'"==""& "`balance'"=="weak" {
			di as err "no time-variable specified: balancing a sample with respect to a time-variable is not possible"
			exit 459
			}
		}
*****************************************************************************
* write the sample in a seperate file
	if "`sample'" != "" {
		preserve
		keep `id' `time' `product'
		qui save `sample' , `replace'
		restore
		}
	
	local t_ident = 0
	local first = 0

******************************************
* Mean GDP, time varying TRADE and Hausmann-Version
if `mgdp'==1 | `hausmann'==1{
	preserve
	if "`time'"=="" & `mgdp'==1 {
		di as err "the 'meangdp'-version of prody can only be calculated having a time-variable specified"
		exit 495
		}
	tempvar meangdp
	tempvar tot_exp
	tempvar prod_share
	bys `id' :  egen `meangdp' = mean(`gdp')
	bys `time' `id' :  egen `tot_exp' = total(`trade')
	bys `time' `product' :  egen `prod_share' = total(`trade'/`tot_exp')
	bys `time' `product' :  egen prody = total(((`trade'/`tot_exp')/`prod_share')*`meangdp')
	duplicates drop `product' `time', force
	keep `product' `time' prody
	rename prody prody_mgdp
	label var prody "PRODY, mean GDP"
	
	if `hausmann'!=1 {
		save `result', replace
		}
	else if `hausmann'==1 {
		if `mgdp'!=1 {
			collapse (mean) prody_mgdp , by(`product')
			rename prody_mgdp prody_mean2
			}
		else {
			egen prody_mean2 = mean(prody_mgdp) , by(`product')
			}
		label var prody_mean2 "PRODY, Hausmann-Version (mean of tvar) "
		save `result', replace
		}
	if `mgdp'==1 {
		local t_ident = 1
		}
	local first = 1
	restore
	}
********************************************

	
********************************************
* Mean Trade, time varying GDP
if `mtrde'==1 | `mean_before'==1 {
	preserve
	if "`time'"=="" & `mtrde'==1 {
		di as err "the 'meantrade'-version of prody can only be calculated having a time-variable specified"
		exit 495
		}
	tempvar meantrade
	tempvar tot_exp
	tempvar prod_share
	bys `id' `product' :  egen `meantrade'=mean(`trade')
	bys `time' `id' :  egen `tot_exp'=total(`meantrade')
	bys `time' `product' :  egen `prod_share'=total(`meantrade'/`tot_exp')
	bys `time' `product' :  egen prody=total(((`meantrade'/`tot_exp')/`prod_share')*`gdp')
	duplicates drop `product' `time', force
	keep `product' `time' prody
	rename prody prody_mtrd
	label var prody_mtrd "PRODY, mean trade"
	if `mean_before'==1 {
		if `mtrde'!=1 {
			collapse (mean) prody , by(`product')
			rename prody prody_mean1
			}
		else if `mtrde'==1 {
			egen prody_mean1 = mean(prody) , by(`product')
			}
		label var prody_mean1 "PRODY, constant over time (taking mean before)"
		}
	if `first' {
		if (`t_ident' & `mtrde'){
			merge 1:1 `product' `time' using `result', nogenerate
			save `result', replace
			}
		else if (!`t_ident' & !`mtrde'){
			merge 1:1 `product' using `result', nogenerate
			save `result', replace
			}
		else if (!`t_ident' & `mtrde') {
			merge m:1 `product' using `result', nogenerate
			save `result', replace
			}
		else if (`t_ident' & !`mtrde') {
			merge 1:m `product' using `result', nogenerate
			save `result', replace
			}
		}
	else if !`first' save `result', replace
	restore
	if `mtrde' local t_ident = 1
	local first = 1
	}
********************************************

*********************************************
* Lall et al.

if `lall' == 1 {
	tempfile groups
	tempvar inc_groups
	tempvar tot_exp_by_good
	tempvar index
	tempvar n_obs
	
	preserve
	keep `time' `id' `gdp'
	duplicates drop
	sort `time' `gdp'
	if "`time'"!="" {
		by `time' : gen `inc_groups' = int((_n*10-1)/_N)
		}
	else {
		gen `inc_groups' = int((_n*10-1)/_N)
		}
	save `groups' , replace
	restore
	merge m:1 `id' `time' using `groups' , nogenerate
	preserve
	collapse (sum) `trade' (mean) `gdp' , by(`time' `inc_groups' `product')
	bys `time' `product' : egen `tot_exp_by_good' = total(`trade')
	bys `time' `product' : egen `index' = total(`gdp'*`trade'/`tot_exp_by_good')
	duplicates drop `time' `product' , force
	if "`time'"!="" {
		bys `time' : egen max`index' = max(`index')
		bys `time' : egen min`index' = min(`index')
		gen prody_lall = 100 * (`index' - min`index' )/( max`index' - min`index' )
		}
	else {
		qui su `index'
		gen prody_lall = 100 * (`index' - r(min) )/( r(max) - r(min) )
		}
	label var prody_lall "Product Sophistication Index according to Lall et al."
	keep `product' `time' prody_lall
	if `first' {
		if `t_ident'{
			if "`time'"!="" {
				merge 1:1 `product' `time' using `result', nogenerate
				save `result', replace
				}
			else {
				merge 1:m `product' using `result', nogenerate
				save `result', replace
				}
			}
		else {
			if "`time'"!="" {
				cap confirm var `time'
				local rc = _rc
				merge m:1 `product' using `result', nogenerate
				save `result', replace
				local t_ident = 1
				}
			else {
				merge 1:1 `product' using `result', nogenerate
				save `result', replace
				}
			}
		}
	if !`first' save `result', replace
	local first = 1
	if "`time'"!="" local t_ident = 1
	restore
	}

********************************************
* Michaely
if `michaely' == 1 {
	preserve
	tempvar tot_exp
	bys `time' `product' :  egen `tot_exp' = total(`trade')
	bys `time' `product' :  egen prody_mic1 = total(`gdp'*`trade'/`tot_exp')
	label var prody_mic1 "Michaely Index"
	keep `time' `product' prody_mic1
	duplicates drop
	if `first' {
		if `t_ident'{
			if "`time'"!="" {
				merge 1:1 `product' `time' using `result', nogenerate
				save `result', replace
				}
			else {
				merge 1:m `product' using `result', nogenerate
				save `result', replace
				}
			}
		else {
			if "`time'"!="" {
				merge m:1 `product' using `result', nogenerate
				save `result', replace
				local t_ident = 1
				}
			else {
				merge 1:1 `product' using `result', nogenerate
				save `result', replace
				}
			}
		}
	if !`first' save `result', replace
	local first = 1
	if "`time'"!="" local t_ident = 1
	restore
	}

if `michaely1' == 1 {
	preserve
	tempvar tot_exp
	tempvar rel_exp
	collapse (mean) `trade' `gdp' , by(`id' `product')
	bys `product' :  egen `tot_exp' = total(`trade')
	gen `rel_exp' = `trade'/`tot_exp'
	gen prody_mic2 = .
	levelsof `product' , local(prods)
	cap confirm string var `product'
	if !_rc {
		foreach prod of local prods {
			count if `product'=="`prod'"
			if r(N)>1 {
				reg `rel_exp' `gdp' if `product'=="`prod'"
				mat A = r(table)
				replace prody_mic2 = A[1,1] if `product' == "`prod'"
				}
			}
		}
	else {
		foreach prod of local prods {
			count if `product'==`prod'
			if r(N)>1 {
				reg `rel_exp' `gdp' if `product'==`prod'
				mat A = r(table)
				replace prody_mic2 = A[1,1] if `product' == `prod'
				}
			}
		}
	label var prody_mic2 "Michaely Index, estimated coefficient"
	keep `product' prody_mic2
	duplicates drop
	if `first' {
		if `t_ident'{
			merge 1:m `product' using `result', nogenerate
			save `result', replace
			}
		else {
			merge 1:1 `product' using `result', nogenerate
			save `result', replace
			}
		}
	if !`first' save `result', replace
	local first = 1
	restore
	}

********************************************
* Time varying Trade, time varying GDP
if `tvar'==1 {
	if "`time'"=="" {
		di as err "The 'timevarying'-version of prody can only be calculated having a time-variable specified"
		exit 495
		}
	tempvar meangdp
	tempvar tot_exp
	tempvar prod_share
	bys `time' `id' :  egen `tot_exp'=total(`trade')
	bys `time' `product' :  egen `prod_share'=total(`trade'/`tot_exp')
	bys `time' `product' :  egen prody=total(((`trade'/`tot_exp')/`prod_share')*`gdp')
	duplicates drop `product' `time', force
	keep `product' `time' prody
	rename prody prody_tvar
	label var prody "PRODY, time-varying"
	if `first' {
		if `t_ident' {
			merge 1:1 `product' `time' using `result', nogenerate
			save `result', replace
			}
		else {
			merge m:1 `product' using `result', nogenerate
			save `result', replace
			}
		}
	if !`first' save `result', replace
	}
*********************************************

use `result' , clear
if `t_ident' order `product' `time' prody*
else order `product' prody*


end
