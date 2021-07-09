/* 	Updates History
	1. 22-10-2014
	- Fixing ftt when almost all studies have p almost zero.
	
	2. 03-02-2015
	- sgweight bug fix.
	- Other bug fix.
	
	3. 23-02-2015
	- Fix dp.
	- power enabled.
	
	4. 09-03-2015
	- Weight displayed to reflect sgweights.
	- Return appropriate values after ftt.
	
	5. 27-04-2015
	- Allow user-specified x-ranges
	
	6. 26-11-2015
	- Fix rdfist with ftt
	
	7. 20-07-2016
	- Fix noOverall and NoSubroup
	
	8. 21-09-2015
	- Include one-sized stratum in the between group test of heterogeneity
	
	9. 24-03-2020
*/
/*===============================================================================================*/
/*==================================== METAPROP  ================================================*/
/*===============================================================================================*/

capture program drop metaprop
program define metaprop, rclass
version 10.1



#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,  FTT CIMETHOD(string) BY(string)
ILevel(integer $S_level) OLevel(integer $S_level) CC(string) POWER(string)
FIXED RANDOM noOVERALL noSUBGROUP SGWEIGHT
SORTBY(passthru) noKEEP noGRAPH noTABLE LABEL(string) noBOX
XLAbel(passthru) XTick(passthru) FORCE BOXSCA(real 100.0) BOXSHA(integer 4)
texts(real 100.0) noWT noSTATS COUNTS WGT(varlist numeric max=1)
/* new additions */
LCOLS(varlist) RCOLS(varlist) ASTEXT(integer 50) DOUBLE NOHET  RFDIST SUMMARYONLY
SECOND(string) NOSECSUB  FIRST(string) 
BOXOPT(string) DIAMOPT(string) POINTOPT(string) CIOPT(string) OLINEOPT(string)

CLASSIC NOWARNING  RFLevel(integer $S_level) DP(integer 2) 
*];

#delimit cr
global MA_OTHEROPTS `"`options'"'

global MA_BOXOPT `"`boxopt'"'
global MA_DIAMOPT `"`diamopt'"'
global MA_POINTOPT `"`pointopt'"'
global MA_CIOPT `"`ciopt'"'
global MA_OLINEOPT `"`olineopt'"'

global MA_DOUBLE  "`double'"
global MA_nohet "`nohet'"
global MA_rfdist "`rfdist'"
global MA_summaryonly "`summaryonly'"
global MA_classic "`classic'"
global MA_nowarning "`nowarning'"

global MA_dp = "`dp'"

global MA_FBSC `boxsca'
global MA_ESLA "`effect'"
global MA_params = 0		// set as appropriate in variable set-up



if "`legend'"!="" {
	global S_TX "`legend'"
}
else {
	global S_TX "Study"
}

global MA_AS_TEXT `astext' 	// new option- percentage of graph as text
global MA_TEXT_SCA `texts'	// oops, that was in already

if `astext' > 90 | `astext' < 10 {
	di as error "Percentage of graph as text (ASTEXT) must be within 10-90%"
	di as error "Must have some space for text and graph"
	exit
}
if `texts' < 20 | `texts' > 500 {
	di as error "Text scale (TEXTSize) must be within 20-500"
	di as error "Value is character size relative to graph"
	di as error "Outside range will either be unreadable or too large"
	exit
}
global MA_FTSI `texts'
if ("`by'"=="" & "`overall'"!="") {
	local wt "nowt"
}
if `ilevel'<1 {
	local ilevel `ilevel'*100
}
if `ilevel'>99 | `ilevel'<10 {
	local ilevel $S_level
}

global ZIND -invnorm((100-`ilevel')/200)

if `olevel'<1 {
local olevel `olevel'*100
}
if `olevel'>99 | `olevel'<10 {
local olevel $S_level
}

global ZOVE -invnorm((100-`olevel')/200)
global IND `ilevel'
global OVE `olevel'

if `rflevel'<1 {
local rflevel `rflevel'*100
}
if `rflevel'>99 | `olevel'<10 {
local rflevel $S_level
}
global RFL `rflevel'

forvalues i = 1/12{  /**************Here I create the global scalar macros S_i*/
global S_`i' .
}
global MA_rjhby "`by'"

if "`power'" != "" {
	global power "`power'"
	}
else {
	global power "0"
}

*If not using own weights set fixed as default

if "`fixed'`random'"=="" & ( "`wgt'"=="" ) {
local fixed "fixed"
}

if "`wgt'"!="" {
*User defined weights verification
	confirm numeric variable `wgt'
	local wgt "`wgt'"
}
*declare study labels for display
if "`label'"!="" {
tokenize "`label'", parse("=,")
while "`1'"!="" {

cap confirm var `3'
if _rc!=0  {
di as err "Variable `3' not defined"
exit
}

local `1' "`3'"
mac shift 4
}
}

tempvar code

qui {
*put name/year variables into appropriate macros

if "`namevar'"!="" {
local lbnvl : value label `namevar'
if "`lbnvl'"!=""  {
quietly decode `namevar', gen(`code')
}
else {
gen str10 `code'=""
cap confirm string variable `namevar'
if _rc==0 {
replace `code'=`namevar'
}
else if _rc==7 {
replace `code'=string(`namevar')
}
}
}
if "`namevar'"=="" & "`lcols'" != ""{
local var1 = word("`lcols'",1)
cap confirm var `var1'
if _rc!=0  {
di in re "Variable `var1' not defined"
exit _rc
}
local namevar "`var1'"
local lbnvl : value label `namevar'
if "`lbnvl'"!=""  {
quietly decode `namevar', gen(`code')
}
else {
gen str10 `code'=""
cap confirm string variable `namevar'
if _rc==0 {
replace `code'=`namevar'
}
else if _rc==7 {
replace `code'=string(`namevar')
}
}	
}
if "`namevar'"=="" & "`lcols'" == ""{
gen str3 `code'=string(_n)
}

if "`yearvar'"!="" {
local yearvar "`yearvar'"
cap confirm string variable `yearvar'
if _rc==7 {
local str "string"
}
if "`namevar'"=="" {
replace `code'=`str'(`yearvar')
}
else {
replace `code'=`code'+" ("+`str'(`yearvar')+")"
}
}

if "`wgt'"!="" {
*User defined weights verification
if "`fixed'`random'"!="" {
di as err "Option invalid with user-defined weights"
exit
}
confirm numeric variable `wgt'
local wgt "wgt(`wgt')"
}

} /* End of quietly loop */

tokenize "`varlist'", parse(" ")

	cap assert `2' >= `1' if (`1' ~= .)
	if _rc != 0{
		di in bl " order should be {n, N}"
		exit _rc
	}
global MA_params = 2

if "`wgt'"!="" {
local method "*"
}
else {
if "`random'"!="" {
local randomi
local random "random"
local method  "Random"
}
if "`fixed'"!="" {
local fixed "fixed"
local method  "Fixed"
}
cap assert ("`random'"=="") + ("`fixed'"=="")==1
if _rc!=0 {
di as err "Specify fixed or random effect/s model"
exit _rc
}
}

if "`cc'" != "" {
cap assert `cc'>= 0 
	

if _rc!=0 {
di as err "Continuity correction must be positive"
exit _rc
}
}
if "`cc'" != "" & "`ftt'" != "" {
cap assert "`cc'" = ""  & "`ftt'" = "" 
if _rc!=0 {


di as err "CC and FTT should not be used together"
exit _rc
}
}





















local callalg "iv_init"





local sumstat "ES" /*Whats is this*/

if "`by'"!="" {
	cap confirm var `by'
	if _rc!=0 {
		di in red "Variable `by' does not exist"
		exit _rc
	}
	local by "by(`by')"
	local nextcall "nextcall(`callalg')"
	local callalg "metanby"
	local sstat "sumstat(`sumstat')"
}

if "`second'" != ""{
	if "`second'" == "random" {
		local method_2 "Random"
	}
	else if "`second'" == "fixed" {
		local method_2 "Fixed"
	}
	}

global MA_method1 "`method'"
global MA_method2 "`method_2'"
global MA_SECOND_ES .
global MA_SECOND_LCI .
global MA_SECOND_UCI .
global MA_SECOND_SE_ES .
global MA_SECOND_TAU2 .
global MA_first_TAU2 .
global MA_SECOND_DF .
global MA_first_DF .	

/*===============================================================================================*/
/*====================================    MAIN   ================================================*/
/*===============================================================================================*/
	
if "`second'" != ""{
	if "`callalg'" != "metanby"{		// just run through twice

		`callalg' `varlist' `if' `in',  `ftt' cimethod(`cimethod') cc(`cc') `by' label(`code') `keep' /*
		*/ method(`method_2') `randomi' `cont'  /*
		*/  `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat' notable nograph rjhsecond
	
		global MA_second_ES = $S_1			// IF NO BY JUST KEEP ESTIMATES AND STICK IN SOMEWHERE LATER
		global MA_second_SE_ES = $S_2
		global MA_second_LCI = $S_3
		global MA_second_UCI = $S_4
		global MA_second_TAU2 = $S_12
		global MA_second_DF = $S_8
		global MA_second_hmean = $hmean

		`callalg' `varlist' `if' `in', `ftt' cimethod(`cimethod') cc(`cc') `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont'   /*
		*/ `wgt' `overall' `subgroup' `sgweight' /*
			*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'

	}

	if "`callalg'" == "metanby"{		// if by, then send to metanby and sort out there

		`callalg' `varlist' `if' `in', `ftt' cimethod(`cimethod') cc(`cc') `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') method2(`method_2') `randomi' `cont'   /*
		*/ `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat' `nosecsub'
	}

}

if "`second'" == ""{

	if "`callalg'" != "metanby"{
		`callalg' `varlist' `if' `in', `ftt' cimethod(`cimethod') cc(`cc') `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont'  /*
		*/  `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'

	}
	if "`callalg'" == "metanby"{
		`callalg' `varlist' `if' `in', `ftt' cimethod(`cimethod') cc(`cc') `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont'  /*
		*/  `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'
	}

}


if $S_8<0 {
	di as err "Insufficient data to perform this meta-analysis"
}



/*===============================================================================================*/
/*==================================== FTT back transformation ==================================*/
/*===============================================================================================*/

if "`ftt'" != "" & "`by'" == "" {
	tempname mintes1 maxtes1 mintes2 maxtes2 effect1 lci1 uci1 effect2 lci2 uci2 
	
	scalar `mintes1' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
	scalar `maxtes1' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
	
	if $S_1 < `mintes1' {
		local effect1 = 0 
	} 
	else if $S_1 > `maxtes1' {
		local effect1 = 1 
	}
	else {
		local effect1 = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) 
	}

	if $S_3 < `mintes1' {
		local lci1 = 0 
	} 
	else if $S_3 > `maxtes1' {
		local lci1  = 1 
		}
	else {
		local lci1  = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) 
		}

	if $S_4 < `mintes1' {
		local uci1  = 0 
	} 
	else if $S_4 > `maxtes1' {
		local uci1  = 1 
	}
	else {
		local uci1  = 0.5 * (1 - sign(cos($S_4 )) * sqrt(1 - (sin($S_4 ) + (sin($S_4 ) - 1/sin($S_4))/($hmean))^2)) 
	}
	
	return scalar ES=`effect1'

	return scalar ci_low=`lci1'
	return scalar ci_upp=`uci1'
	
	if "$MA_method2" != ""{
		scalar `mintes2' = asin(sqrt(0/($MA_second_hmean + 1))) + asin(sqrt((0 + 1)/($MA_second_hmean + 1 )))
		scalar `maxtes2' = asin(sqrt($MA_second_hmean/($MA_second_hmean + 1))) + asin(sqrt(($MA_second_hmean + 1)/($MA_second_hmean + 1 )))
		if $MA_second_ES < `mintes2' {
			local effect2 = 0 
		} 
		else if $MA_second_ES > `maxtes2' {
			local effect2 = 1 
		}
		else {
			local effect2 = 0.5 * (1 - sign(cos($MA_second_ES)) * sqrt(1 - (sin($MA_second_ES) + (sin($MA_second_ES) - 1/sin($MA_second_ES))/($MA_second_hmean))^2)) 
		}

		if $MA_second_LCI < `mintes2' {
			local lci2 = 0 
		} 
		else if $MA_second_LCI > `maxtes2' {
			local lci2  = 1 
			}
		else {
			local lci2  = 0.5 * (1 - sign(cos($MA_second_LCI)) * sqrt(1 - (sin($MA_second_LCI) + (sin($MA_second_LCI) - 1/sin($MA_second_LCI)/($MA_second_hmean))^2)) 
			}

		if $MA_second_UCI < `mintes2' {
			local uci2  = 0 
		} 
		else if $MA_second_UCI > `maxtes2' {
			local uci2  = 1 
		}
		else {
			local uci2  = 0.5 * (1 - sign(cos($MA_second_UCI)) * sqrt(1 - (sin($MA_second_UCI) + (sin($MA_second_UCI) - 1/sin($MA_second_UCI))/($MA_second_hmean))^2)) 
		}
		return scalar ES_2=`effect2'
		return local method_2 "$MA_method2"

		return scalar fttseES_2= $MA_second_SE_ES
		return scalar ci_low_2=`lci2'
		return scalar ci_upp_2=`uci2'	


	}
}
else {

	return scalar ES=$S_1
	if "`ftt'" == "" {
		return scalar seES=$S_2
	}
	else {
		return scalar fttseES= $S_2
	}
	return scalar ci_low=$S_3
	return scalar ci_upp=$S_4
	if "$MA_method2" != ""{
		if "`ftt'" == "" {
			return scalar ES_2=$MA_second_ES
		}
		else {
			return scalar fttseES_2= $MA_second_ES
		}
		return local method_2 "`$MA_method2'"
		return scalar seES_2=$MA_second_SE_ES
		return scalar ci_low_2=$MA_second_LCI
		return scalar ci_upp_2=$MA_second_UCI
	}
}
/*===============================================================================================*/
/*==================================== Return values   ==========================================*/
/*===============================================================================================*/

return scalar z=$S_5
return scalar p_z=$S_6
*return scalar i_sq=$S_51		// ADDED I2 IN RETURN
return scalar het=$S_7
return scalar df=$S_8
return scalar p_het=$S_9
return scalar chi2=$S_10
return scalar p_chi2=$S_11
return scalar tau2=$S_12
return local  measure "`sumstat'"
return local method1 "$MA_method1"

if "`keep'" =="nokeep" {
	cap drop _ES
	cap drop _seES
	cap drop _LCI 
	cap drop _UCI
	cap drop _WT
	}

end

/*===============================================================================================*/
/*==================================== METANBY   ================================================*/
/*===============================================================================================*/
capture program drop metanby
program define metanby

version 10.1

#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,  FTT CIMETHOD(string) BY(string) CC(string)
	LABEL(string) SORTBY(string) noGRAPH noTABLE noKEEP NEXTCALL(string) 
	METHOD(string) METHOD2(string) SUMSTAT(string) RANDOMI WGT(passthru) noSUBGROUP SGWEIGHT
	STANDARD(passthru) noOVERALL  
	XLAbel(passthru) XTICK(passthru) FORCE SAVING(passthru) T1(string) T2(string) 
	B1(string) B2(string) LCOLS(string) RCOLS(string) noWT noSTATS COUNTS noBOX noGROUPLA NOSECSUB	] ;

#delimit cr

local dp = $MA_dp

if ("`subgroup'"!="" & "`overall'`sgweight'"!="") { 
	local wt "nowt" 
}





tempvar n N use by2 newby incr r1 r2 rawdata effect se lci uci weight wtdisp  mean weightrandom weightedest hmean fttes fttlci fttuci  /*
	*/ hetc hetdf hetp i2 tau2 df tsig psig expand tlabel id weightedsquare_first weightedsquare_second mintes maxtes teffect tlci tuci

tempname mintes maxtes teffect tlci tuci sumweights sumweightedest


qui {
gen `use'=1 `if' `in'
replace `use'=9 if `use'==.

tokenize `varlist'
gen `n' = `1' 
gen `N' = `2' 

gen double `incr' = . 
if "`cc'" != "" {
	replace `incr' = `cc' if  (`n' == 0 | `n'==`N') 
	} 
replace `use'=9 if (`n'==. | `N'==.)
if ("`ftt'" == ""  & "`logit'" == "") {
	if (`incr' == . | `incr' == 0 ) {
		replace `use' = 2 if (`n' == 0 | `n'==`N') & `use'==1 
		}
	}
replace `use' = 2 if `N'==0 & `use'==1 

local h0=0

*RJH- second estimate

if "`method2'" != ""{

	  `nextcall' `varlist' if `use'==1, `ftt' cimethod(`cimethod') nograph notable method(`method2') `randomi' /*
        	*/ label(`label') `wgt' cc(`cc') `standard' rjhsecond	




	  global MA_second_ES = $S_1			// KEEP ESTIMATES AND STICK IN SOMEWHERE LATER
	  global MA_second_SE_ES = $S_2
	  global MA_second_LCI = $S_3
	  global MA_second_UCI = $S_4
	  global MA_second_TAU2 = $S_12
	  global MA_second_DF = $S_8
	  global MA_second_hmean = $hmean

}

*Get the individual trial stats 
`nextcall' `varlist' if `use'==1, `ftt' cimethod(`cimethod') nograph notable method(`method') `randomi' /*	
*/ label(`label') `wgt'  cc(`cc') `standard'  

if $S_8 < 0 {
	*no trials - bomb out
	exit
}

local nostud = $S_8 + 1
global MA_first_ES = $S_1
global MA_first_hmean = $hmean

gen `effect'=(`n')/(`N')
gen double `se' = sqrt((`effect'*(1 - `effect'))/`N')
replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)

gen `lci'=_LCI
gen `uci'=_UCI


gen `weight'=_WT

*put overall weight into var if requested
if ("`sgweight'"=="" & "`overall'"=="" )  {
	gen `wtdisp'=_WT
}
else {
	gen `wtdisp'=.

}






gen `id'=_n
gen `hmean' = .
gen `fttes' = .
gen `fttlci' = .
gen `fttuci' = .

preserve

cap confirm numeric var `by'
if _rc == 0{
	tempvar by_num 
	cap decode `by', gen(`by_num')
	if _rc != 0{
		local f: format `by'
		gen `by_num' = string(`by', "`f'")
	}
	qui drop `by'
	rename `by_num' `by'
}
cap confirm numeric var `by'

* This replaces the old encode statement
* The _by variable is generated according to the original
* sort order of the data, and not done alpha-numerically

qui count
local N = r(N)
gen `by2' = 1 in 1
local lab = `by'[1]
cap label drop bylab
if "`lab'" != ""{
	label define bylab 1 "`lab'"
}
local found1 "`lab'"
local max = 1
forvalues i = 2/`N'{

	local thisval = `by'[`i']
	local already = 0
	forvalues j = 1/`max'{
		if "`thisval'" == "`found`j''"{
			local already = `j'
		}
	}
	if `already' > 0{
		replace `by2' = `already' in `i'
	}
	else{
		local max = `max' + 1
		replace `by2' = `max' in `i'
		local lab = `by'[`i']
		if "`lab'" != ""{
			label define bylab `max' "`lab'", modify
		}
		local found`max' "`lab'"
	}
}

label values `by2' bylab

*Keep only neccesary data 
sort `by2' `sortby' `id'
qui drop if `use' == 9

*Can now forget about the if/in conditions specified: unnecc rows have been removed

*subgroup component of heterogeneity
gen `hetc'=.
gen `hetdf'=.
gen `hetp'=.
gen `i2'=.
gen `tau2'=.
gen `df' = .
gen `tsig'=.
gen `psig'=.

*Create new "by" variable to take on codes 1,2,3.. 
gen `newby'=(`by2'>`by2'[_n-1])
replace `newby'=1+sum(`newby')
local ngroups=`newby'[_N]

if "`overall'"=="" {

	*If requested, add an extra line to contain overall stats
	local nobs1=_N+1
	set obs `nobs1'
	replace `use'=5 in `nobs1'
	replace `newby'=`ngroups'+1 in `nobs1'
	replace `hmean' = $hmean in `nobs1'
	
/*===============================================================================================*/
/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
/*===============================================================================================*/
	if "`ftt'"  != ""  {
	
			qui replace `fttes' = $S_1 in `nobs1'
			qui replace `fttlci' = $S_3 in `nobs1'
			qui replace `fttuci' = $S_4 in `nobs1'
		
			scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
			scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1)))		



			if $S_1 < `mintes' {
				qui replace `effect' = 0 in `nobs1'


			}
			else if $S_1 > `maxtes' {
				qui replace `effect' = 1 in `nobs1'


			}
			else {
				qui replace `effect' = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) in `nobs1' 


			}
			
			if $S_3 < `mintes' {
				qui replace `lci' = 0 in `nobs1'


			}
			else if $S_3 > `maxtes' {
				qui replace `lci' = 1 in `nobs1'
			}
			else {
				qui replace `lci' = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) in `nobs1' 
			}
			
			if $S_4 < `mintes' {
				qui replace `uci' = 0 in `nobs1'
			}
			else if $S_4 > `maxtes' {
				qui replace `uci' = 1 in `nobs1'
			}
			else {
				qui replace `uci' = 0.5 * (1 - sign(cos($S_4)) * sqrt(1 - (sin($S_4) + (sin($S_4) - 1/sin($S_4))/($hmean))^2)) in `nobs1' 
			}
/*===============================================================================================*/
/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
/*===============================================================================================*/			
		} 
	else {
		replace `effect'= ($S_1) in `nobs1'
		if $S_8 > 0 {
			replace `lci'=($S_3) in `nobs1'
			replace `uci'=($S_4) in `nobs1'
		}
		else {
			replace `effect'= ($es) in `nobs1'
			replace `lci'=($ill) in `nobs1'
			replace `uci'=($iul) in `nobs1'
		}
	}
	*RJH plus another line if second estimate
	if "`method2'" != ""{
		local nobs2=_N+1
		set obs `nobs2'
		replace `use'=17 in `nobs2'
		replace `newby'=`ngroups'+1 in `nobs2'
/*===============================================================================================*/
/*==================    Begin the Freeman Tukey Back tranformation      ========================*/
/*===============================================================================================*/
		if "`ftt'"  != "" {
		
				replace `hmean' = $hmean in `nobs2'
				qui replace `fttes' = $S_1 in `nobs2'
				qui replace `fttlci' = $S_3 in `nobs2'
				qui replace `fttuci' = $S_4 in `nobs2'
			
				scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
				scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
				
				if $S_1 < `mintes' {
					qui replace `effect' = 0 in `nobs2'
				}
				else if $S_1 > `maxtes' {
					qui replace `effect' = 1 in `nobs2'
				}
				else {
					qui replace `effect' = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) in `nobs2' 
				}
				
				if $S_3 < `mintes' {
					qui replace `lci' = 0 in `nobs2'
				}
				else if $S_3 > `maxtes' {
					qui replace `lci' = 1 in `nobs2'
				}
				else {
					qui replace `lci' = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) in `nobs2' 
				}
				
				if $S_4 < `mintes' {
					qui replace `uci' = 0 in `nobs2'
				}
				else if $S_4 > `maxtes' {
					qui replace `uci' = 1 in `nobs2'
				}
				else {
					qui replace `uci' = 0.5 * (1 - sign(cos($S_4)) * sqrt(1 - (sin($S_4) + (sin($S_4) - 1/sin($S_4))/($hmean))^2)) in `nobs2' 
				}
/*===============================================================================================*/
/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
/*===============================================================================================*/				
			}  


		else {
			replace `effect'= ($S_1) in `nobs2'
			if $S_8 > 0 {
				replace `lci'=($S_3) in `nobs2'
				replace `uci'=($S_4) in `nobs2'
			}
			else {
				replace `effect'= ($es) in `nobs2'
				replace `lci'=($ill) in `nobs2'
				replace `uci'=($iul) in `nobs2'
			}
	}	
		if "`method2'" == "Random"{
			replace `tau2' = $MA_second_TAU2 in `nobs2'
			replace `hetdf' = $MA_second_DF in `nobs2'
		}
	} 
	replace `hetc' =($S_7) in `nobs1'
	replace `hetdf'=($S_8) in `nobs1'
	replace `hetp' =($S_9) in `nobs1'
	replace `i2'=max(0, ( 100*($S_7-$S_8))/($S_7) ) in `nobs1'

	if $S_8 < 3 { 
	replace `hetc' =. in `nobs1'
	replace `hetdf'=. in `nobs1'
	replace `hetp' =. in `nobs1'
	replace `i2' = . in `nobs1' 
	}
	replace `tau2' = $S_12 in `nobs1'
	replace `df' = $S_8 in `nobs1'
	replace `se'=$S_2 in `nobs1'
	if "`chi2'"!="" { 
		replace `tsig'=$S_10 in `nobs1'
		replace `psig'=$S_11 in `nobs1'
		local z=$S_5
		local pz=$S_6
	}
	else { 
		replace `tsig'=$S_5 in `nobs1'
		replace `psig'=$S_6 in `nobs1'
		local echi2 =$S_10
		local pchi2=$S_11
	}
	replace `label' = "Overall" in `nobs1'
	if "`sgweight'"=="" { 
		replace `wtdisp'=100 in `nobs1' 
	}

} /* end if overall */


*Create extra 2 or 3 lines per bygroup: one to label, one for gap
*and one for overall effect size (unless no subgroup combining is done)
*RJH- add another line if SECOND sub estimates

sort `newby' `use' `sortby' `id'

by `newby': gen `expand'=1 + 2*(_n==1) + (_n==1 & "`subgroup'"=="") ///
	  + (_n==1 & "`method2'"!="" & "`nosecsub'"=="")
replace `expand'=1 if `use'==5 | `use' == 17
expand `expand'
gsort `newby' -`expand' `use' `sortby' `id'
by `newby': replace `use'=0 if `expand'>1 & _n==2   /* row for by label */
by `newby': replace `use'=4 if `expand'>1 & _n==3   /* row for blank line */
by `newby': replace `use'=3 if `expand'>1 & _n==4   /* (if specified) row to hold subgp effect sizes */
by `newby': replace `use'=19 if `expand'>1 & _n==5   /* (if specified) RJH extra line for second estimate */

* blank out effect sizes in new rows
replace `effect'=.  if `expand'>1 & `use'!=1
replace `se'=.  if `expand'>1 & `use'!=1    
replace `lci'=. if `expand'>1 & `use'!=1  
replace `uci'=. if `expand'>1 & `use'!=1  
replace `hmean'=. if `expand'>1 & `use'!=1   
replace `weight' =. if `expand'>1 & `use'!=1   
 
/*===============================================================================================*/
/*=================================    Subgroup Analyses      ===================================*/
/*===============================================================================================*/
local j=1
	while `j'<=`ngroups' {		// HUGE LOOP THROUGH EACH SUBGROUP
	if "`subgroup'"=="" {
		*First ensure the by() category has any data
		count if (`newby'==`j' & `use'==1)

		if r(N)==0 {
			*No data in subgroup=> fill variables with missing and move on
			replace `effect'=. if (`use'==3 & `newby'==`j')
			replace `se'=. if (`use'==3 & `newby'==`j')
			replace `lci'=. if (`use'==3 & `newby'==`j')
			replace `uci'=. if (`use'==3 & `newby'==`j')
			replace `hmean'=. if (`use'==3 & `newby'==`j')
			replace `fttes'=. if (`use'==3 & `newby'==`j')
			replace `fttlci'=. if (`use'==3 & `newby'==`j')
			replace `fttuci'=. if (`use'==3 & `newby'==`j')
			replace `wtdisp'=0 if `newby'==`j'
			replace `weight'=0 if `newby'==`j'
			replace `hetc'=. if `newby'==`j'
			replace `hetdf'=. if `newby'==`j'
			replace `hetp'=. if `newby'==`j'
			replace `i2'=. if `newby'==`j'
			replace `tsig'=. if `newby'==`j'
			replace `psig'=. if `newby'==`j'
			replace `tau2'=. if `newby'==`j'
		}
		else {

			/* SECOND SUB-ESTIMATES */
			if "`method2'" != "" & "`nosecsub'" == ""{
				`nextcall' `varlist' if (`newby'==`j' & `use'==1) , `ftt' cimethod(`cimethod') nograph /*
				  */ notable label(`label') method(`method2') `randomi' `wgt'  /*
				  */ cc(`cc') `standard' 
				  
/*===============================================================================================*/
/*==================    Start the Freeman Tukey Back tranformation       ========================*/
/*===============================================================================================*/			

					if "`ftt'"  != ""  {  
					
						qui replace `fttes' = $S_1 if `use'==19 & `newby'==`j'
						qui replace `fttlci' = $S_3 if `use'==19 & `newby'==`j'
						qui replace `fttuci' = $S_4 if `use'==19 & `newby'==`j'
						replace `hmean'=($hmean) if `use'==19 & `newby'==`j'
						
						scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
						scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
						
						if $S_1 < `mintes' {
							replace `effect' = 0 if `use'==19 & `newby'==`j'


						} 
						else if $S_1 > `maxtes' {
							replace `effect' = 1 if `use'==19 & `newby'==`j'
						}
						else {
							replace `effect' = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) if `use'==19 & `newby'==`j'
						}
		
						if $S_3 < `mintes' {
							replace `lci' = 0 if `use'==19 & `newby'==`j'
						} 
						else if $S_3 > `maxtes' {
							replace `lci' = 1 if `use'==19 & `newby'==`j'
							}
						else {
							replace  `lci' = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) if `use'==19 & `newby'==`j'
							}


						if $S_4 < `mintes' {
							replace `uci' = 0 if `use'==19 & `newby'==`j'
						} 
						else if `uci'[`i'] > `maxtes' {
							replace `uci' = 1 if `use'==19 & `newby'==`j'
						}
						else {

							replace `uci' = 0.5 * (1 - sign(cos($S_4 )) * sqrt(1 - (sin($S_4 ) + (sin($S_4 ) - 1/sin($S_4))/($hmean))^2)) if `use'==19 & `newby'==`j'
						}
/*===============================================================================================*/
/*==================    Finish the Freeman Tukey Back tranformation      ========================*/
/*===============================================================================================*/				

					} 


					else {
						replace `effect'=($S_1) if `use'==19 & `newby'==`j'

						if $S_8 > 0 {
							replace `lci'=($S_3) if `use'==19 & `newby'==`j'

							replace `uci'=($S_4) if `use'==19 & `newby'==`j'
						}
						else {
							replace `effect'=($es) if `use'==19 & `newby'==`j'
							replace `lci'=($ill) if `use'==19 & `newby'==`j'
							replace `uci'=($iul) if `use'==19 & `newby'==`j'
						}
					}
					replace `se'=($S_2) if `use'==19 & `newby'==`j'
					replace `hetdf' = $S_8 if `use'==19 & `newby'==`j'
					if "`method2'"=="Random" {
						replace `tau2' = $S_12 if `use'==19 & `newby'==`j'
					}
				}

			/* THEN GET REGULAR ESTIMATES AS USUAL */
			`nextcall' `varlist' if (`newby'==`j' & `use'==1) , `ftt' cimethod(`cimethod') nograph /*
			  */ notable label(`label') method(`method') `randomi' `wgt'  /*
			  */ cc(`cc') `standard' 
/*===============================================================================================*/
/*==================    Start the Freeman Tukey Back tranformation       ========================*/
/*===============================================================================================*/							  
				if "`ftt'"  != ""  {
				
					qui replace `fttes' = $S_1 if `use'==3 & `newby'==`j'
					qui replace `fttlci' = $S_3 if `use'==3 & `newby'==`j'
					qui replace `fttuci' = $S_4 if `use'==3 & `newby'==`j'
					replace `hmean'=($hmean) if `use'==3 & `newby'==`j'
										
					scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
					scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
					if $S_1 < `mintes' {
						replace `effect' = 0 if `use'==3 & `newby'==`j'
					} 
					else if $S_1 > `maxtes' {
						replace `effect' = 1 if `use'==3 & `newby'==`j'
					}
					else {
						replace `effect' = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) if `use'==3 & `newby'==`j'
					}
	
					if $S_3 < `mintes' {
						replace `lci' = 0 if `use'==3 & `newby'==`j'
					} 
					else if $S_3 > `maxtes' {
						replace `lci' = 1 if `use'==3 & `newby'==`j'
						}
					else {
						replace  `lci' = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) if `use'==3 & `newby'==`j'
						}

					if $S_4 < `mintes' {
						replace `uci' = 0 if `use'==3 & `newby'==`j'
					} 
					else if $S_4 > `maxtes' {
						replace `uci' = 1 if `use'==3 & `newby'==`j'
					}
					else {
						replace `uci' = 0.5 * (1 - sign(cos($S_4 )) * sqrt(1 - (sin($S_4 ) + (sin($S_4 ) - 1/sin($S_4))/($hmean))^2)) if `use'==3 & `newby'==`j'
					}
/*===============================================================================================*/
/*==================    Finish the Freeman Tukey Back tranformation       ========================*/
/*===============================================================================================*/				
				} 
				else {
					replace `effect'=($S_1) if `use'==3 & `newby'==`j'
					if $S_8 > 0 {
						replace `lci'=($S_3) if `use'==3 & `newby'==`j'
						replace `uci'=($S_4) if `use'==3 & `newby'==`j'
					}
					else {
						replace `effect'=($es) if `use'==3 & `newby'==`j'
						replace `lci'=($ill) if `use'==3 & `newby'==`j'
						replace `uci'=($iul) if `use'==3 & `newby'==`j'
					}
				} 
		
			replace `se'=($S_2) if `use'==3 & `newby'==`j'	
			replace `hmean'=($hmean) if `use'==3 & `newby'==`j'
		
			*Put within-subg weights in if nooverall or sgweight options specified


			if ("`overall'`sgweight'"!="" )  {
				replace `wtdisp'=_WT if `newby'==`j'
				replace `wtdisp'=100 if (`use'==3 & `newby'==`j')
			}
			else {
				qui sum `wtdisp' if (`use'==1 & `newby'==`j')
				replace `wtdisp'=r(sum) if (`use'==3 & `newby'==`j')
			}
	
			sum `weight' if `newby'==`j'
			replace `weight'= r(sum) if `use'==3 & `newby'==`j'

			replace `hetc' =($S_7) if `use'==3 & `newby'==`j'
			replace `hetdf'=($S_8) if `use'==3 & `newby'==`j'
			replace `hetp' =($S_9) if `use'==3 & `newby'==`j'

			replace `i2'=max(0, ( 100*($S_7-$S_8))/($S_7) ) if `use'==3 & `newby'==`j'
			replace `psig'=($S_6) if `use'==3 & `newby'==`j'
			replace `tsig'=($S_5) if `use'==3 & `newby'==`j'
	
			if $S_8 < 3 { 
				replace `i2' = . if `use'==3 & `newby'==`j' 
				replace `hetc' =. if `use'==3 & `newby'==`j'
				replace `hetp' = . if `use'==3 & `newby'==`j'
			}

			if "`method'"=="Random" {
				replace `tau2' = $S_12 if `use'==3 & `newby'==`j'
			}
	
		} /* END OF IF SUBGROUP N > 0 */

		*Whether data or not - put cell counts in subtotal row if requested (will be 0/n1;0/n2 or blank if all use>1)
	} /* END OF if "`subgroup'" == "" */

	*Label attatched (if any) to byvar

	local lbl: value label `by2'
	sum `by2' if `newby'==`j'
	local byvlu=r(mean)
	
	if "`lbl'"=="" { 
		local lab "`by2'==`byvlu'" 
	}
	else { 
		local lab: label `lbl' `byvlu' 
	}

	replace `label' = "`lab'" if ( `use'==0 & `newby'==`j')
	replace `label' = "Subtotal" if ( `use'==3 & `newby'==`j')

	/* RMH I^2 added in next line 
		RJH- also p-val as recommended by Mike Bradburn */



	replace `label' = "Subtotal  (I^2 = " + string(`i2', "%10.`dp'f")+ "%, p = " + ///
		string(`hetp', "%10.`dp'f") + ")" if ( `use'==3 & `newby'==`j' & "$MA_nohet" == "")

	replace `label' = "" if ( `use'==3 & `newby'==`j' & `hetdf' == 0)

		
	local j=`j'+1

} /* 	FINALLY, THE END OF THE WHILE LOOP! */



replace `label' = "Overall  (I^2 = " + string(`i2', "%10.`dp'f")+ "%, p = " + ///
	string(`hetp', "%10.`dp'f") + ")" if ( `use'==5 & "$MA_nohet" == "")

replace `label' = "" if ( `use'==5 & `hetdf' == 0)
} /*End of quietly loop*/
*Put table up (if requested)

tempvar rjhorder
qui gen `rjhorder' = `use'
qui replace `rjhorder' = 3.5 if `use' == 19	// SWAP ROUND SO BLANK IN RIGHT PLACE
sort `newby' `rjhorder' `sortby'  `id'

// need to ditch this if SECOND specified
if "`subgroup'" != ""{
	qui drop if `use' == 3 | `use' == 19
}


if "`table'"=="" {




	qui gen str20 `tlabel'=`label'
	if "`overall'`wt'"=="" { 
		local ww  "% Weight" 
	}
	di _n in gr _col(12) "Study" _col(22) "|" _col(24) " " _col(29) "`sumstat'" /*
		 */  _col(38) "[$IND% Conf. Interval]"  _col(60) "`ww'"
	di  _dup(21) "-" "+" _dup(51) "-"


	*legend for pooled confidence intervals

	local i=1
	while `i'<= _N {

		if (`use'[`i'])==0 { 
			*by label
			di _col(6) in gr `tlabel'[`i'] 
		}
		if "`overall'`wt'"=="" { 
			local ww=`wtdisp'[`i'] 
		}
		else { 
			local ww 
		}

		if (`use'[`i'])==1 { 
			*trial results
			di in gr `tlabel'[`i'] _col(22) "|  " in ye %10.`dp'f `effect'[`i']*(10^$power) /* 
				*/ _col(35) %10.`dp'f `lci'[`i']*(10^$power) "   "  %10.`dp'f `uci'[`i']*(10^$power) _col(60)  %10.`dp'f  `ww' 
		}

		if (`use'[`i'])==2 {
			*excluded trial
			di in gr `tlabel'[`i'] _col(22) "|  (Excluded)"
		}

		if ((`use'[`i']==3 | `use'[`i']==19) & "`subgroup'"=="") | (`use'[`i']==5 | `use'[`i']==17) {

			*Subgroup effect size or overall effect size
			if (`use'[`i'])==3 & (`hetdf'[`i'] != 0) { 
				di in gr " Sub-total" _col(22) "|"
			}
			if `use'[`i']==17 | `use'[`i']==5{ 
				if $IND!=$OVE { 
					local insert "[$OVE% Conf. Interval]" 
				}
				if `use'[`i'] == 5{
					di in gr "Overall"  _col(22) "|" _col(34) "`insert'"
				}
			}

			if "`ww'"=="." { 
				local ww 
			}

			// RJH

				if (`use'[`i'] == 3 | `use'[`i'] == 5) & (`hetdf'[`i'] > 0 )  {
				
					di in gr "  `method' pooled  `sumstat'" _col(22) "|  " in ye  %10.`dp'f /*
					*/ `effect'[`i']*(10^$power) _col(35) %10.`dp'f `lci'[`i']*(10^$power) "   "  %10.`dp'f `uci'[`i']*(10^$power) _col(60) %10.`dp'f `ww'

				} 
				if (`use'[`i'] == 19 | `use'[`i'] == 17) & (`hetdf'[`i'] > 0 ) {
					di in gr "  $MA_method2 pooled  `sumstat'" _col(22) "|  " in ye  %10.`dp'f /*

					*/ `effect'[`i']*(10^$power) _col(35) %10.`dp'f `lci'[`i']*(10^$power) "   "  %10.`dp'f `uci'[`i']*(10^$power)
				}


			if (`use'[`i'])==5 & "$MA_method2" == "" | `use'[`i'] == 17{ 
				di in gr _dup(21) "-" "+" _dup(51) "-" 
			}
		}

		if (`use'[`i'])==4 { 
			*blank line separator (need to put line here in case nosubgroup was selected)
			di in gr _dup(21) "-" "+" _dup(51) "-" 
		}

		local i=`i'+1

	} /* END OF WHILE LOOP */

	*Skip next bits if nooverall AND nosubgroup
	if ("`subgroup'"=="" | "`overall'"=="") {

		*part 2: user defined weight notes and heterogeneity 
		if ("`method'"=="*" | "`var3'"!="") {
			if "`method'"=="*" { 
				di in gr "* note: trials pooled by user defined weight `wgt'"
			}
			di in bl " Heterogeneity calculated by formula" _n  /*
				*/ "  Q = SIGMA_i{ (1/variance_i)*(effect_i - effect_pooled)^2 } "
			if "`var3'"!="" {
				di in bl "where variance_i = ((upper limit - lower limit)/(2*z))^2 "
			}
		}

	if "$MA_method1" == "Random" {



		di in gr _n "Test(s) of heterogeneity:" _n _col(16) "Heterogeneity  degrees of"
		di in gr _col(18) "statistic     freedom      	    P       I^2**" _cont
		if "`method'"=="RANDOM" { 
			di in gr "   Tau^2" 
		}		







		local maxHet = 0
		local i=1
		while `i'<= _N {
			if ("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5) {
				if `use'[`i'] != 5{
					di in gr _n `tlabel'[`i'] _cont 
				}
				else{
					di in gr _n  "Overall" _cont 
				}
			}


			if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 

				di in ye _col(20) %10.`dp'f `hetc'[`i'] _col(35) %2.0f `hetdf'[`i']   /*
				  */  _col(43) %10.`dp'f `hetp'[`i'] _col(51) %10.`dp'f `i2'[`i'] "%" _cont
				if `use'[`i'] == 3{
					local maxHet = max(`maxHet',`i2'[`i'])
				}
				if `use'[`i'] == 5{
					local ovHet = `i2'[`i']
				}
				if "`method'"=="RANDOM" { 
					di in ye "      " %10.`dp'f `tau2'[`i'] _cont
				}
			}




















			local i=`i'+1
		}
		di _n in gr "** I^2: the variation in `sumstat' attributable to heterogeneity)" _n


	}
		
		qui count if `hetdf' !=. &  `use'==3
		local df = r(N) - 1	
		if "`subgroup'"=="" {
			tempvar est
			if "`ftt'" != "" {
				qui gen double `est' = `fttes'
			}
			else{
				qui gen double `est' = `effect'
			}
		
		if "$MA_method1" == "Fixed" {
			scalar `mean' = $MA_first_ES
			}
		else {
			qui gen `weightedest' = `est'/(`se'^2)
			qui sum `weightedest' if `use'==3
			scalar `sumweightedest' = r(sum)
			qui gen `weightrandom' = 1/(`se'^2)
			qui sum `weightrandom' if `use'==3
			scalar `sumweights' = r(sum)
			scalar `mean' = `sumweightedest'/`sumweights'
		}
		qui gen `weightedsquare_first' = (1/(`se')^2)*(`est' - `mean')^2 
		qui sum `weightedsquare_first' if `use' == 3
		global btwghet_first = r(sum)
		global rjhHetGrp = chiprob(`df', $btwghet_first)
				di _n in gr "$MA_method1: Test for heterogeneity between sub-groups: " _n   /*
		*/ in ye _col(20) %10.`dp'f $btwghet_first _col(35) %2.0f `df'  _col(43) %10.`dp'f  /*
		*/ 	(chiprob(`df', $btwghet_first))
		if ("`method2'" != ""){
			if "method2" == "Fixed" {
				scalar `mean' = $MA_second_ES


				}
			else {
				qui gen `weightedest' = `est'/(`se'^2)
				qui sum `weightedest' if `use'==19
				scalar `sumweightedest' = r(sum)
				qui gen `weightrandom' = 1/(`se'^2)
				qui sum `weightrandom' if `use'==19
				scalar `sumweights' = r(sum)
				scalar `mean' = `sumweightedest'/`sumweights'
			}
			qui gen `weightedsquare_second' = (1/(`se')^2)*(`est' - `mean')^2 
			qui sum `weightedsquare_second' if `use' == 19
			global btwghet_second = r(sum)	
			di _n in gr "$MA_method2: Test for heterogeneity between sub-groups: " _n   /*
			*/ in ye _col(20) %10.`dp'f $btwghet_second _col(35) %2.0f `df'  _col(43) %10.`dp'f  /*
			*/ 	(chiprob(`df', $btwghet_second))
		}
		}





		// DISPLAY BETWEEN-GROUP TEST WARNINGS
		if "`overall'" == ""{
		if "`maxHet'" == "" {
				local maxHet = 0
			}
		if `maxHet' < 50 & `maxHet' > 0 & ("$MA_method1" == "Fixed"){
			di in gr "Some heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups may be invalid"						
		}
		if `maxHet' < 75 & `maxHet' >= 50 & ("$MA_method1" == "Fixed"){
			di in gr "Moderate heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups likely to be invalid"
		}
		if `maxHet' < . & `maxHet' >= 75 & ("$MA_method1" == "Fixed"){
			di in gr "Considerable heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups likely to be invalid"
		}
		}
		*part 3: test statistics
		di _n in gr "Significance test(s) of  `sumstat'=`h0'" 

		local i=1
		while `i'<= _N {

			if ("`subgroup'"=="" & (`use'[`i'])==0) | ( (`use'[`i'])==5) { 
				if `use'[`i'] != 5{
					di in gr _n `tlabel'[`i'] _cont 
				}
				else{
					di in gr _n  "Overall" _cont 
				}
			}

			if ( ((`use'[`i'])==3) | ((`use'[`i'])==5) ) { 
				if "`chi2'"!="" {  
					di in gr _col(20) "chi^2 = " in ye %10.`dp'f `tsig'[`i'] /*
						*/ in gr  _col(35) " (d.f. = 1) p = "  in ye %10.`dp'f `psig'[`i'] _cont
	  			}
				else { 
			   		di in gr _col(23) "z= " in ye %-10.`dp'f `tsig'[`i'] _col(35) in gr  /*
						*/ " p = "  in ye %-10.`dp'f `psig'[`i'] _cont
				}
			}
			local i=`i'+1
		}
		di _n in gr _dup(73) "-" 

	} /* end of if ("`subgroup'"=="" | "`overall'"=="") */

} /* end of table display */



if "`overall'"=="" {

	*need to return overall effect to $S_1 macros and so on...
	local N = _N
	if "$MA_method2" != ""{
		local N = _N-1
	}

	global S_1=`effect'[`N']*(10^$power)
	global S_2=`se'[`N']
	global S_3=`lci'[`N']*(10^$power)
	global S_4=`uci'[`N']*(10^$power)
	global S_7=`hetc'[`N'] 
	global S_8=`hetdf'[`N']
	global S_9=`hetp'[`N'] 
	global S_51 =`i2'[`N']

	if "`chi2'"!="" {
		global S_10=`tsig'[`N']
		global S_11=`psig'[`N']
		global S_5=`z'
		global S_6=`pz'
	}
	else {
		global S_5=`tsig'[`N']
		global S_6=`psig'[`N']
		global S_10=`echi2'
		global S_11=`pchi2'
	}

	global S_12=`tau2'[`N'] 

} /* end if overall */

else {
	forvalues i = 1/14{
		global S_`i' .
	}
}


if "`graph'"=="" {
	_dispgby `effect' `lci' `uci' `weight' `use' `label'  `hetdf' `tau2' `hmean' `fttes' `fttlci' `fttuci' `wtdisp',  /*
	  */ `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") `ftt' /*
	  */ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `counts'   /*
	  */ `groupla' 

}

	qui{
	cap drop _ES 
	cap drop _seES	
	gen _ES  =`effect'*(10^$power)
	label var _ES "`sumstat'"

	gen _seES=`se'
	label var _seES "se(`sumstat')"

	#delimit ;
	cap drop _LCI ; cap drop _UCI; cap drop _WT;
	gen _LCI =`lci'*(10^$power);   label var _LCI "Lower CI (`sumstat')";
	gen _UCI =`uci'*(10^$power);   label var _UCI "Upper CI (`sumstat')";
	#delimit cr
       
	*correct weight if subgroup weights given	
	if ("`sgweight'"=="" & "`overall'"=="" )  { 
		gen _WT=`weight' 
	}
      else if "`subgroup'"=="" & ("`overall'`sgweight'"!="" )  {
		tempvar tempsum ordering
		gen `ordering' = _n
		bysort `by2': gen `tempsum'=sum(`weight')
	
		local N = _N
		if "$MA_method2" != ""{
			local N = _N-1
		}
		bysort `by2': replace `tempsum'=`tempsum'[`N']
		gen _WT=`weight'*100/`tempsum'
		local sg "(subgroup) "
		sort `ordering'
	}
	cap label var _WT "`method' `sg'% weight"


      } /* end qui */







restore

end
/*===============================================================================================*/
/*====================================  IV_INIT  ================================================*/
/*===============================================================================================*/













































































































































capture program drop iv_init
program define iv_init

version 10.1

#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [, FTT CIMETHOD(string) BY(string) CC(string)
LABEL(string) SORTBY(passthru) noGRAPH METHOD(string) noKEEP SAVING(passthru)  noBOX 
noTABLE XLAbel(passthru) XTICK(passthru) FORCE T1(string) T2(string) B1(string)
B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS WGT(string) RJHSECOND ] ;

#delimit cr

qui {

tempvar n N incr es est se use v ill iul weight id rawdata
tokenize "`varlist'", parse(" ")
gen double `n' = `1'
gen double  `N' = `2'

gen double `incr' = . 
if "`cc'"  != "" {
	replace `incr' = `cc' if  (`n' == 0 | `n'==`N')
	}
/*===============================================================================================*/
/*======================= Begin the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/

if "`ftt'" != "" { /**************************Begin the freeman tukey arcsine transformation*/

	gen double `es' = asin(sqrt(`n'/(`N' + 1))) + asin(sqrt((`n' + 1)/(`N' + 1 )))
	gen double `se' = sqrt(1/(`N' + .5)) if (`n' != . & `N' > 0)
/*===============================================================================================*/
/*======================= Finish the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/

} 
else {
	gen double  `es'=`n'/`N'
	gen double `se' = sqrt((`es'*(1 - `es'))/`N')
	replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)
}

gen double `use'=1 `if' `in'
replace `use'=9 if `use'==.
replace `use'=9 if (`es'==. | `se'==.)
replace `use'=2 if (`use'==1 & `se'<=0 )
count if `use'==1
global S_8 = r(N)-1


if $S_8<0 {
	exit
}

ameans `N' if `use'==1 
global hmean = r(mean_h)
	
if "`method'"=="Random" & ($S_8<2) { /*Random-effects for more than 3 studies*/




	local method "Fixed"
}
replace `es' =. if `use'!=1
replace `se' =. if `use'!=1
gen double `v'=(`se')^2




/*****************Score or Exact confidence intervals********************************/
if "`cimethod'" == "exact" {
	exci `N' `n', ul(ul) ll(ll) 
	gen double  `ill' = ll
	gen double  `iul' = ul
	drop ul ll 
} 
else {
gen `est' =`n'/`N'
gen  `ill'  = ((`est' + (($ZIND)^2)/(2*(`N'))) - ($ZIND)*sqrt((`est'*(1 - `est') + (($ZIND)^2)/(4*(`N')))/(`N')))/(1 + (($ZIND)^2)/(`N'))
gen  `iul' = ((`est' + (($ZIND)^2)/(2*(`N'))) + ($ZIND)*sqrt((`est'*(1 - `est') + (($ZIND)^2)/(4*(`N')))/(`N')))/(1 + (($ZIND)^2)/(`N'))
}

/*********************** Controlling for decimals and precision **********************************/
replace `iul' = 1 if `iul' > 1.0000000000 
replace `ill' = 0 if `ill' < 0.0000000000 

/********   If U have only one study, then the pooled estimate should be as the one study with not transformation************/

cap drop `est'
gen `est' =`n'/`N'
sum `ill' if `use'==1
global ill `r(sum)'
sum `iul' if `use'==1
global iul `r(sum)'
sum `est' if `use'==1
global es  `r(sum)'


iv  `es' `v', method(`method') `ftt'  randomi `rjhsecond' wgt(`wgt') 



if "`wgt'" == "" {
	gen `weight'=100/((`v'+$S_12)*($MA_W))
} 
else {
	gen `weight'=100*`wgt'/($MA_W) 
}

/*********************Ensure that the parameters passed are free of transformation*/

if "`ftt'" == "" {
	drop `es' `se'
	gen double  `es'=`n'/`N'
	gen double `se' = sqrt((`es'*(1 - `es'))/`N')
	replace `se' = sqrt((`n' + `incr') * (`N' - `n' + `incr')/(`N' + 2 * `incr')^3) if  (`n' != . & `N' > 0 & `incr' !=.)
	}
else {
	replace `es' = 0.5 * (1 - sign(cos(`es')) * sqrt(1 - (sin(`es') + (sin(`es') - 1/sin(`es'))/(`N'))^2))
}



}  /* End of quietly loop  */

_disptab `es' `se' `ill' `iul' `weight' `use' `label', `keep' `sortby' `ftt' /*
*/`table' method(`method') sumstat(ES) `xlabel' `xtick' `force' `graph' `box' /*
*/ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' /*
*/ `var3' `udwind' `rjhsecond'

end

/*===============================================================================================*/
/*====================================    IV     ================================================*/
/*===============================================================================================*/




capture program drop iv
program define iv

version 10.1

#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,
METHOD(string) RANDOMI 	WGT(string) RJHSECOND FTT ] ;

#delimit cr

tempvar stat v w qhet w2 wnew e_w e_wnew
tempname W W2 C T2 E_W E_WNEW OV OVL OVU vOV QHET mintes maxtes

tokenize "`varlist'", parse(" ")
gen `stat'=`1'
gen `v'   =`2'
if "`wgt'" == ""{
	gen `w' = 1/`v'
} 
else {
gen `w' = `wgt' if `stat' !=.
sum `w',meanonly
scalar `W'=r(sum)
if `W'==0 {
	di as err "Usable weights sum to zero: the table below will probably be nonsense"
}

}

sum `w', meanonly /*Summarize but suppress the output*/
scalar `W'=r(sum) /*This is a temporal scalar*/






if ("`method'"=="Fixed") { 	
	gen `e_w' =`stat'*`w'
	sum `e_w',meanonly
	scalar `E_W'=r(sum)
	global MA_W =`W'
	global  S_1 =`E_W'/`W'
	global S_12 = 0
}
else {
	gen `e_w' =`stat'*`w'
	sum `e_w',meanonly
	scalar `E_W'=r(sum)
	global S_1 =`E_W'/`W'

	*  Heterogeneity
	gen `qhet' =( (`stat'- $S_1)^2 )/`v'
	sum `qhet', meanonly
	scalar `QHET'=r(sum)
	global S_7=`QHET'

	gen `w2'  =`w'*`w'
	sum `w2',meanonly
	scalar `W2' =r(sum)
	scalar `C'  =`W' - `W2'/`W'
	global S_12 = max(0, ((`QHET'-$S_8)/`C') )
	global RJH_TAU2 = $S_12
	gen `wnew'  =1/(`v'+$S_12)
	gen `e_wnew'=`stat'*`wnew'
	sum `wnew',meanonly
	global MA_W =r(sum)
	sum `e_wnew',meanonly
	scalar `E_WNEW'=r(sum)
	global S_1 =`E_WNEW'/$MA_W
}

global S_2 = sqrt( 1/$MA_W )

global S_3 = $S_1 - $ZOVE*($S_2)
global S_4 = $S_1 + $ZOVE*($S_2)



if "`ftt'" != "" {
	scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
	if $S_1 > `mintes' {
		global S_5 =abs($S_1 - `mintes')/($S_2)
	} 
	else{
		global S_5 = 0
	}
}
else{
	global S_5 =abs($S_1)/($S_2)
}

global S_6 =normprob(-abs($S_5))*2
global S_9 =chiprob($S_8,$S_7)
global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
	
	if "`method'" == "USER"{
	    forvalues i = 1/15{
	        global S_`i' = .
			}
		cap drop `weight'
	    tempvar weight
	    gen `weight'=.
		if "`rjhsecond'" != ""{
			global S_1 = $MA_userES
			global S_3 = $MA_userCIlow
			global S_4 = $MA_userCIupp
		}
		else{
			global S_1 = $MA_userESM
			global S_3 = $MA_userCIlowM
			global S_4 = $MA_userCIuppM
		}
	}

end

/*===============================================================================================*/
/*==================================== _DISPTAB  ================================================*/
/*===============================================================================================*/
capture program drop _disptab
program define _disptab

version 10.1

#delimit ;

syntax varlist(min=5 max=8 default=none) [if] [in] [, FTT
XLAbel(passthru) XTICK(passthru) FORCE noKEEP SAVING(passthru)  noBOX noTABLE 
noGRAPH METHOD(string) SUMSTAT(string) T1(string) T2(string) B1(string)
B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS COUNTS noGROUPLA SORTBY(string)
WGT(string) VAR3  /* RJH */ RJHSECOND ] ;

#delimit cr

tempvar effect se lci uci weight use label tlabel rawdata id tau2 df hmean fttes fttlci fttuci
tempname OVL OVU mintes maxtes
tokenize "`varlist'", parse(" ")

local dp = $MA_dp






qui {



	gen `effect'=`1'
	gen `se'    =`2'
	gen `lci'   =`3'
	gen `uci'   =`4'
	gen `weight'=`5'
	gen byte `use'=`6'
	format `weight' %5.1f
	gen str10 `label'=""

	replace `label'=`7'













	global IND:  displ %2.0f $IND


	gen `tau2' = .
	gen `df' = .
	
	gen `hmean' = .
	gen `fttes' = `1'
	gen `fttlci' = `3'
	gen `fttuci' = `4'
	

	cap drop _ES
	cap drop _seES


	gen _ES  =`effect'
	label var _ES "`sumstat'"




	gen _seES=`se'
	label var _seES "se(`sumstat')"

	cap drop _LCI
	cap drop _UCI
	cap drop _WT


	gen _LCI =`lci'
	label var _LCI "Lower CI (`sumstat')"
	gen _UCI =`uci'
	label var _UCI "Upper CI (`sumstat')"
	gen _WT=`weight'
	label var _WT "`method' weight"
preserve

if "`overall'"=="" & "`rjhsecond'" == ""{		// only do this on main run

**If overall figure requested, add an extra line to contain overall stats

local nobs1=_N+1
set obs `nobs1'
replace `weight'=100 in `nobs1'


/*===============================================================================================*/
/*=======================  Start the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/
if "`ftt'"  != "" {

				replace `hmean'=$hmean in `nobs1'
				qui replace `fttes' = $S_1 in `nobs1'
				qui replace `fttlci' = $S_3 in `nobs1'
				qui replace `fttuci' = $S_4 in `nobs1'
	
				scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
				scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
				
				if $S_1 < `mintes' {
					qui replace `effect' = 0 in `nobs1'
				}
				else if $S_1 > `maxtes' {
					qui replace `effect' = 1 in `nobs1'
				}
				else {
					qui replace `effect' = 0.5 * (1 - sign(cos($S_1)) * sqrt(1 - (sin($S_1) + (sin($S_1) - 1/sin($S_1))/($hmean))^2)) in `nobs1' 
				}
				
				if $S_3 < `mintes' {
					qui replace `lci' = 0 in `nobs1'
				}
				else if $S_3 > `maxtes' {
					qui replace `lci' = 1 in `nobs1'
				}
				else {
					qui replace `lci' = 0.5 * (1 - sign(cos($S_3)) * sqrt(1 - (sin($S_3) + (sin($S_3) - 1/sin($S_3))/($hmean))^2)) in `nobs1' 
				}
				
				if $S_4 < `mintes' {
					qui replace `uci' = 0 in `nobs1'
				}
				else if $S_4 > `maxtes' {
					qui replace `uci' = 1 in `nobs1'
				}
				else {
					qui replace `uci' = 0.5 * (1 - sign(cos($S_4)) * sqrt(1 - (sin($S_4) + (sin($S_4) - 1/sin($S_4))/($hmean))^2)) in `nobs1' 
				}	
			}
/*===============================================================================================*/
/*======================= Finish the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/
		else {
			replace `effect'= ($S_1) in `nobs1'
			if $S_8 > 0 {
				replace `lci'=($S_3) in `nobs1'
				replace `uci'=($S_4) in `nobs1'
			}
			else {
				replace `effect'= ($es) in `nobs1'
				replace `lci'=($ill) in `nobs1'
				replace `uci'=($iul) in `nobs1'
			}
}
replace `use'=5 in `nobs1'
replace `tau2' = $S_12 in `nobs1'
replace `df' = $S_8 in `nobs1'

local i2=max(0, (100*($S_7-$S_8)/($S_7)) )

local hetp=$S_9

if ($S_8 > 0) & ($S_8 != .) {

	replace `label' = "Overall  (I^2 = " + string(`i2', "%10.`dp'f")+ "%, p = " + ///
	string(`hetp', "%10.`dp'f") + ")" in `nobs1'

}
* RJH code for second method
if "$MA_method2" != "" {
local nobs1=_N+1
set obs `nobs1'
replace `weight'=100 in `nobs1'

/*===============================================================================================*/
/*=======================  Start the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/
if "`ftt'"  != ""  {

				qui replace `hmean'=$hmean in `nobs1'
				qui replace `fttes' = $MA_second_ES in `nobs1'
				qui replace `fttlci' = $MA_second_LCI in `nobs1'
				qui replace `fttuci' = $MA_second_UCI in `nobs1'
				
				scalar `mintes' = asin(sqrt(0/($hmean + 1))) + asin(sqrt((0 + 1)/($hmean + 1 )))
				scalar `maxtes' = asin(sqrt($hmean/($hmean + 1))) + asin(sqrt(($hmean + 1)/($hmean + 1 )))
				
				if $MA_second_ES < `mintes' {
					qui replace `effect' = 0 in `nobs1'
				}
				else if $MA_second_ES > `maxtes' {
					qui replace `effect' = 1 in `nobs1'
				}
				else {
					qui replace `effect' = 0.5 * (1 - sign(cos($MA_second_ES)) * sqrt(1 - (sin($MA_second_ES) + (sin($MA_second_ES) - 1/sin($MA_second_ES))/($hmean))^2)) in `nobs1' 
				}
				
				if $MA_second_LCI < `mintes' {
					qui replace `lci' = 0 in `nobs1'
				}
				else if $MA_second_LCI > `maxtes' {
					qui replace `lci' = 1 in `nobs1'
				}
				else {
					qui replace `lci' = 0.5 * (1 - sign(cos($MA_second_LCI)) * sqrt(1 - (sin($MA_second_LCI) + (sin($MA_second_LCI) - 1/sin($MA_second_LCI))/($hmean))^2)) in `nobs1' 
				}
				
				if $MA_second_UCI < `mintes' {
					qui replace `uci' = 0 in `nobs1'
				}
				else if $MA_second_UCI > `maxtes' {
					qui replace `uci' = 1 in `nobs1'
				}
				else {
					qui replace `uci' = 0.5 * (1 - sign(cos($MA_second_UCI)) * sqrt(1 - (sin($MA_second_UCI) + (sin($MA_second_UCI) - 1/sin($MA_second_UCI))/($hmean))^2)) in `nobs1' 
				}	
			} 
/*===============================================================================================*/
/*======================= Finish the Freeman Tukey Back tranformation ===========================*/
/*===============================================================================================*/
		else {
			replace `effect'= $MA_second_ES in `nobs1'
			replace `lci'=$MA_second_LCI in `nobs1'
			replace `uci'=$MA_second_UCI in `nobs1'
		}
replace `use'=17 in `nobs1'
if "$MA_second_TAU2" != ""{
replace `tau2' = $MA_second_TAU2 in `nobs1'
replace `df' = $MA_second_DF in `nobs1'
}
if ($S_8 > 0) & ($S_8 != .) {
	replace `label' = "Overall" in `nobs1'
}
}

} /* end overall stuff */

local usetot=$S_8+1

count if `use'==2
local alltot=r(N)+`usetot'
gen `id'=_n

tempvar rjhorder
qui gen `rjhorder' = `use'
qui replace `rjhorder' = 3.5 if `use' == 19	// SWAP ROUND SO BLANK IN RIGHT PLACE
sort `rjhorder' `sortby'  `id'


} /* End of quietly loop */


if "`table'"=="" {

qui gen str20 `tlabel'=`7'  /*needs to be own label so as not to overrun!*/

if "`overall'`wt'"=="" {
local ww "% Weight"
}

if $IND!=$OVE {
global OVE: displ %2.0f $OVE
local insert "[$OVE% Conf. Interval]"
}
else {
local insert "--------------------"
}

di _n in gr _col(12) "Study" _col(22) "|" _col(24) " " _col(28) "`sumstat'" /*
*/  _col(34) "[$IND% Conf. Interval]"  _col(59) "`ww'" _n _dup(21) "-" "+" _dup(51) "-"


local i=1
while `i'<=_N {	// BEGIN WHILE LOOP

if "`overall'`wt'"=="" {
local ww=`weight'[`i']
}
else {
local ww
}
if (`use'[`i'])==2 {
*excluded trial
di in gr `tlabel'[`i'] _col(22) "|  (Excluded)"
}

* IF NORMAL TRIAL, OR OVERALL EFFECT
if ( (`use'[`i']==1) | (`use'[`i']==5) | `use'[`i'] == 17 ) {
	if (`use'[`i'])==1 {
		*trial results
		di in gr `tlabel'[`i']  _cont
	}
	else {
		if (`df'[`i']!=0 & `df'[`i']!=.){
			*overall
			// RJH
			if `use'[`i'] == 5 {
			local dispM1 = "$MA_method1"
			if "$MA_method1" == "USER"{
			local dispM1 = "$MA_userDescM"
			}
			di in gr _dup(21) "-" "+" _dup(11) "-"  "`insert'" _dup(20) "-" _n /*
			*/   "`dispM1' pooled  `sumstat'" _cont
			}
			if `use'[`i'] == 17{	// SECOND EST
			local dispM2 = "$MA_method2"
			if "$MA_method2" == "USER"{
			local dispM2 = "$MA_userDesc"
			}
			di in gr "`dispM2' pooled  `sumstat'" _cont
			}
		}
	} 
	if (`use'[`i'])==1 {
		*trial results
		di in gr _col(22) "|" in ye  %10.`dp'f `effect'[`i']*(10^$power) /*
		*/ _col(35) %10.`dp'f  `lci'[`i']*(10^$power) "   " %10.`dp'f  /*
		*/ `uci'[`i']*(10^$power) _col(60)  %6.2f `ww' 
	}
	else{
		if  (`df'[`i']!=0 & `df'[`i']!=.){

			di in gr _col(22) "|" in ye  %10.`dp'f `effect'[`i']*(10^$power) /*
			*/ _col(35) %10.`dp'f  `lci'[`i']*(10^$power) "   " %10.`dp'f  /*
			*/ `uci'[`i']*(10^$power) _col(60)  %6.2f `ww' 
		}
	}
}
local i=`i'+1

} /* END WHILE */

di in gr _dup(21) "-" "+" _dup(51) "-"

if "`overall'"=="" & "$MA_method1" != "USER"{

if ("`method'"=="*" | "`var3'"!="") {

if "`method'"=="*" {
di in gr "* note: trials pooled by user defined weight `wgt'"
}

di in gr " Heterogeneity calculated by formula" _n  /*
*/ "  Q = SIGMA_i{ (1/variance_i)*(effect_i - effect_pooled)^2 } "

if "`var3'"!="" {
di in gr "where variance_i = ((upper limit - lower limit)/(2*z))^2 "
}

}

*Heterogeneity etc
local h0=0

if "`method'"=="Random" {




	di _n in gr "  Heterogeneity chi^2 = " in ye %10.`dp'f $S_7 in gr /*
	*/  " (d.f. = " in ye $S_8 in gr  ") p = "   in ye %10.`dp'f $S_9
	local i2=max(0, (100*($S_7-$S_8)/($S_7)) )
	if $S_8<1 {
	local i2=.
	}
	di in gr "  I^2 (variation in `sumstat' attributable to " /*
	*/  "heterogeneity) =" in ye %10.`dp'f `i2' "%"

	di in gr "  Estimate of between-study variance " /*
	*/ "Tau^2 = " in ye %10.`dp'f $S_12
}

di _n in gr "  Test of `sumstat'=`h0' : z= " in ye %10.`dp'f $S_5  /*
*/  in gr  " p = "  in ye %10.`dp'f $S_6

}

*capture only 1 trial scenario

qui {
count

if r(N)==1 {
set obs 2
replace `use'=99 in 2
		replace `weight'=0 if `use'==99
	}

	} /*end of qui. */

} // end if table

if "`graph'"=="" & `usetot'>0 {

qui drop if `use' == 9

	_dispgby `effect' `lci' `uci' `weight' `use' `label' `df' `tau2' `hmean' `fttes' `fttlci' `fttuci', /*
	  */ `ftt' `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") /*
	  */ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `counts'  /*
*/ `groupla' 

}

restore

end
/*===============================================================================================*/
/*==================================== _DISPGBY  ================================================*/
/*===============================================================================================*/
**********************************************************
***                                                    ***
***                        NEW                         ***
***                 _DISPGBY PROGRAM                   ***
***                    ROSS HARRIS                     ***
***                     JULY 2006                      ***
***                       * * *                        ***
***                                                    ***
**********************************************************

capture program drop _dispgby
program define _dispgby
version 10.1	

//	AXmin AXmax ARE THE OVERALL LEFT AND RIGHT COORDS
//	DXmin dxMAX ARE THE LEFT AND RIGHT COORDS OF THE GRAPH PART

#delimit ;
syntax varlist(min=6 max=13 default=none ) [if] [in] [, 
  XLAbel(string) XTICK(string) FORCE SAVING(string) noBOX SUMSTAT(string) 
  T1(string) T2(string) B1(string) B2(string) LCOLS(string) /* JUNK NOW */
  RCOLS(string) noOVERALL noWT noSTATS EFORM FTT
  noGROUPLA CORNFIELD];
#delimit cr

tempvar effect lci uci weight wtdisp use label tlabel id yrange xrange Ghsqrwt  i2 mylabel tau2 df hmean fttes fttlci fttuci
tokenize "`varlist'", parse(" ")

qui{

gen `effect'=`1'*(10^$power)
gen `lci'   =`2'*(10^$power)
gen `uci'   =`3'*(10^$power)
gen `weight'=`4'	// was 4
gen byte `use'=`5'
gen str `label'=`6'
gen str `mylabel'=`6'
gen `df' = `7'
gen `tau2' = `8'

gen `hmean' = `9'
gen `fttes' = `10'
gen `fttlci' = `11'
gen `fttuci' = `12'

if "`lcols'" == ""{
	local lcols "`mylabel'"
	label var `mylabel' "Study"
}


if "`13'"!="" & "$MA_rjhby" != ""{
	gen `wtdisp'=`13' 
}
else { 
	gen `wtdisp'=`weight' 
}








if "$MA_summaryonly" != ""{
	drop if `use' == 1
}

// SET UP EXTENDED CIs FOR RANDOM EFFECTS DISTRIBUTION
// THIS CODE IS A BIT NASTY AS I SET THIS UP BARandomY INITIALLY
// REQUIRES MAJOR REWORK IDEALLY...

tempvar tauLCI tauUCI SE tauLCIinf tauUCIinf

replace `tau2' = .b if `df' - 1 < 2	// inestimable predictive distribution
replace `tau2' = . if (`use' == 5 | `use' == 3) & "$MA_method1" != "Random"
replace `tau2' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "Random"

/*===============================================================================================*/
/*====================================  RFDIST   ================================================*/
/*===============================================================================================*/

gen `tauLCI' = .
gen `tauUCI' = .
gen `tauLCIinf' = .
gen `tauUCIinf' = .
gen `SE' = .


// modified so rf CI (rflevel) used
if "$MA_rfdist" != ""{
	if "`ftt'" != "" {
		tempvar ftttauLCI ftttauUCI
		
		replace `SE' = (`fttuci'-`fttlci') / (invnorm($RFL/200+0.5)*2)
		gen `ftttauLCI' = `fttes'-invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		gen `ftttauUCI' = `fttes'+invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		
		tempvar mintes maxtes
		qui gen `mintes' = asin(sqrt(0/(`hmean' + 1))) + asin(sqrt((0 + 1)/(`hmean' + 1 )))
		qui gen `maxtes' = asin(sqrt(`hmean'/(`hmean' + 1))) + asin(sqrt((`hmean' + 1)/(`hmean' + 1 )))
		
		replace `tauLCI' = 0 if `ftttauLCI' < `mintes'
		replace `tauLCI' = 1 if `ftttauLCI' > `maxtes' 
		replace `tauLCI' = 0.5 * (1 - sign(cos(`ftttauLCI')) * sqrt(1 - (sin(`ftttauLCI') + (sin(`ftttauLCI') - 1/sin(`ftttauLCI'))/(`hmean'))^2)) if (`ftttauLCI' <= `maxtes') & (`ftttauLCI' >= `mintes')
		
		replace `tauUCI' = 0 if `ftttauUCI' < `mintes'
		replace `tauUCI' = 1 if `ftttauUCI' > `maxtes'
		replace `tauUCI' = 0.5 * (1 - sign(cos(`ftttauUCI')) * sqrt(1 - (sin(`ftttauUCI') + (sin(`ftttauUCI') - 1/sin(`ftttauUCI'))/(`hmean'))^2)) if (`ftttauUCI' <= `maxtes') & (`ftttauUCI' >= `mintes')
		
		replace `tauLCI' = -1e9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b
		
	
	}
	else{
		replace `SE' = (`uci'-`lci') / (invnorm($RFL/200+0.5)*2)
		replace `tauLCI' = `effect'-invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauUCI' = `effect'+invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauLCI' = -1e9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b
	}
	
	/*Truncate to 0 1 interval*/
	replace `tauLCI' = 0 if `tauLCI' < 0
	replace `tauUCI' = 1 if `tauUCI' > 1
}


if "$MA_rfdist" != ""{
	qui count
	local prevN = r(N)
	tempvar expTau orderTau
	gen `orderTau' = _n
	gen `expTau' = 1
	replace `expTau' = 2 if `tau2' != .	// but expand if .a or .b
	expand `expTau'
	replace `use' = 4 if _n > `prevN'
	replace `orderTau' = `orderTau' + 0.5 if _n > `prevN'
	sort `orderTau'
}

tempvar estText weightText RFdistText RFdistLabel
local dp = $MA_dp
gen str `estText' = string(`effect', "%10.`dp'f") + " (" + string(`lci', "%10.`dp'f") + ", " +string(`uci', "%10.`dp'f") + ")"
replace `estText' = "(Excluded)" if `use' == 2


replace `estText' = " " if (`use' == 3 | `use' == 5) & `df' == 0 /* Dont display if one study*/

// don't show effect size again, just CI
gen `RFdistLabel' = "with estimated predictive interval" if `use' == 4 & `tau2' < .
gen `RFdistText' =  ".       (" + string(`tauLCI', "%10.`dp'f") + ", " +string(`tauUCI', "%10.`dp'f") ///
	+ ")" if `use' == 4 & `tau2' < .







// don't show effect size again, just CI
replace `RFdistLabel' = "Inestimable predictive distribution with <3 studies"  if `use' == 4 & `tau2' == .b
replace `RFdistText' =  ".       (  -  ,  -  )" if `use' == 4 & `tau2' == .b


qui replace `estText' = " " +  `estText' if `effect' >= 0 & `use' != 4
gen str `weightText' = string(`wtdisp', "%4.2f")

replace `weightText' = "" if `use' == 17 | `use' == 19 // can cause confusion and not necessary
replace `weightText' = " " if (`use' == 3 | `use' == 5) & `df' == 0 /* Dont display if one study*/






/* RJH - probably a better way to get this but I've just used globals from earlier */

if "`overall'" == "" & "$MA_nohet" == ""{
	if "$MA_method1" == "USER"{
			replace `label' = "Overall" if `use'==5
	}
	replace `label' = "Overall" if `use' == 17 & "$MA_method2" == "USER" 
}
if "`overall'" == "" & "$MA_nohet" != ""{
	replace `label' = "Overall" if `use' == 5 | `use' == 17
}

tempvar hetGroupLabel expandOverall orderOverall
if "$MA_rjhby" != "" & "$MA_nohet" == "" {
	replace `label' = `label' + ";" if `use' == 5
	qui count
	local prevMax = r(N)
	gen `orderOverall' = _n
	gen `expandOverall' = 1
	replace `expandOverall' = 2 if `use' == 5
	expand `expandOverall'
	replace `orderOverall' = `orderOverall' -0.5 if _n > `prevMax'
	gen `hetGroupLabel' = "Heterogeneity between groups: p = " + ///
		  string($rjhHetGrp, "%5.3f") if _n > `prevMax'
	replace `use' = 4 if _n > `prevMax'
	sort `orderOverall'
}
else{
	gen `hetGroupLabel' = .
}

replace `label' = "Overall" if `use' == 17 & "$MA_method2" != "USER"
replace `label' = "Subtotal" if `use' == 19




qui count if (`use'==1 | `use'==2)
local ntrials=r(N)
qui count if (`use'>=0 & `use'<=5)
local ymax=r(N)
gen `id'=`ymax'-_n+1 if `use'<9 | `use' == 17 | `use' == 19

if "$MA_method2" != "" | "$MA_method1" == "USER" {
	local dispM1 = "$MA_method1"
	local dispM2 = "$MA_method2"
	if "$MA_method1" == "USER"{
		local dispM1 "$MA_userDescM"
	}
	if "$MA_method2" == "USER"{
		local dispM2 "$MA_userDesc"
	}
	replace `label' = "`dispM1'" + " " + `label' if (`use' == 3 | `use' == 5) & substr(`label',1,3) != "het"
	replace `label' = "`dispM2'" + " " + `label' if `use' == 17 | `use' == 19
}


// GET MIN AND MAX DISPLAY
// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIRandomED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!

qui summ `lci', detail
local DXmin = r(min)
qui summ `uci', detail
local DXmax = r(max)


local lblcmd ""
tokenize "`xlabel'", parse(",")
while "`1'" != ""{
	if "`1'" != ","{
		local lbl = string(`1',"%7.3g")
		local val = `1'
		local lblcmd `lblcmd' `val' "`lbl'"
	}
	mac shift
}

tokenize "`xlabel'", parse(",")
if "`1'" != "" {
	local h0 = "`1'"
} 
else{
	local h0 = 0



}

// THIS BIT CHANGED- THE USER CAN PUT ANYTHING IN

local flag1=0
if ("`xlabel'"=="" | "`xtick'" == "") { 		// if no xlabel or tick
	local xtick  "`h0'"
}

if "`xlabel'"==""{
	local xlabel "`DXmin',`h0',`DXmax'"
}

local DXmin2 = min(`xlabel',`DXmin')
local DXmax2 = max(`xlabel',`DXmax')
if "`force'" == ""{
	if "`xlabel'" != "" {
		local xlabel "`h0',`xlabel'"
	}
}

if "`force'" != ""{
	local DXmin = min(`xlabel')
	local DXmax = max(`xlabel')
	local xlabel "`h0',`xlabel'"
}











if "`xtick'" == ""{
	local xtick = "`xlabel'"
}

local xtick2 = ""
tokenize "`xtick'", parse(",")
while "`1'" != ""{
	if "`1'" != ","{
		local xtick2 = "`xtick2' " + string(`1')
	}
	if "`1'" == ","{
		local xtick2 = "`xtick2'`1'"
	}
	mac shift
}
local xtick = "`xtick2'"

local DXmin= (min(`xlabel',`xtick',`DXmin'))
local DXmax= (max(`xlabel',`xtick',`DXmax'))


// JUNK
*noi di "min: `DXmin', `DXminLab'; h0: `h0', `h0Lab'; max: `DXmax', `DXmaxLab'"
	
local DXwidth = `DXmax'-`DXmin'
if `DXmin' > 0{
	local h0 = 1
}

} // END QUI

// END OF TICKS AND LABLES

// MAKE OFF-SCALE ARROWS

qui{
tempvar offLeftX offLeftX2 offRightX offRightX2 offYlo offYhi

local arrowWidth = 0.02	// FRACTION OF GRAPH WIDTH
local arrowHeight = 0.5/2 // Y SCALE IS JUST ORDERED NUMBER- 2x0.25 IS 0.5 OF AVAILABLE SPACE

gen `offLeftX' = `DXmin' if `lci' < `DXmin' | `tauLCI' < `DXmin'
gen `offLeftX2' = `DXmin' + `DXwidth'*`arrowWidth' if `lci' < `DXmin' | `tauLCI' < `DXmin'

gen `offRightX' = `DXmax' if `uci' > `DXmax' | (`tauUCI' > `DXmax' & `tauLCI' < .)
gen `offRightX2' = `DXmax' - `DXwidth'*`arrowWidth' if `uci' > `DXmax' | (`tauUCI' > `DXmax' & `tauLCI' < .)

gen `offYlo' = `id' - `arrowHeight'
gen `offYhi' = `id' + `arrowHeight'

replace `lci' = `DXmin' if `lci' < `DXmin' & (`use' == 1 | `use' == 2)
replace `uci' = `DXmax' if `uci' > `DXmax' & (`use' == 1 | `use' == 2)
replace `lci' = . if `uci' < `DXmin' & (`use' == 1 | `use' == 2)
replace `uci' = . if `lci' > `DXmax' & (`use' == 1 | `use' == 2)
replace `effect' = . if `effect' < `DXmin' & (`use' == 1 | `use' == 2)
replace `effect' = . if `effect' > `DXmax' & (`use' == 1 | `use' == 2)
}	// end qui

/*===============================================================================================*/
/*==================================== COLUMNS   ================================================*/
/*===============================================================================================*/

// OPTIONS FOR L-R JUSTIFY?
// HAVE ONE MORE COL POSITION THAN NECESSARY, COULD THEN R-JUSTIFY
// BY ADDING 1 TO LOOP, ALSO HAVE MAX DIST FOR OUTER EDGE
// HAVE USER SPECIFY % OF GRAPH USED FOR TEXT?

qui{	// KEEP QUIET UNTIL AFTER DIAMONDS
local titleOff = 0

if "`lcols'" == ""{
	local lcols = "`label'"
	local titleOff = 1
}

// DOUBLE LINE OPTION
if "$MA_DOUBLE" != "" & ("`lcols'" != "" | "`rcols'" != ""){
	tempvar expand orig
	gen `orig' = _n
	gen `expand' = 1
	replace `expand' = 2 if `use' == 1
	expand `expand'
	sort `orig'
	replace `id' = `id' - 0.45 if `id' == `id'[_n-1]
	replace `use' = 2 if mod(`id',1) != 0 & `use' != 5
	replace `effect' = .  if mod(`id',1) != 0
	replace `lci' = . if mod(`id',1) != 0
	replace `uci' = . if mod(`id',1) != 0
	replace `estText' = "" if mod(`id',1) != 0
	cap replace `raw1' = "" if mod(`id',1) != 0
	cap replace `raw2' = "" if mod(`id',1) != 0
	replace `weightText' = "" if mod(`id',1) != 0

	foreach var of varlist `lcols' `rcols'{
	   cap confirm string var `var'
	   if _rc == 0{
		
		tempvar length words tosplit splitwhere best
		gen `splitwhere' = 0
		gen `best' = .
		gen `length' = length(`var')
		summ `length', det
		gen `words' = wordcount(`var')
		gen `tosplit' = 1 if `length' > r(max)/2+1 & `words' >= 2
		summ `words', det
		local max = r(max)
		forvalues i = 1/`max'{
			replace `splitwhere' = strpos(`var',word(`var',`i')) ///
			 if abs( strpos(`var',word(`var',`i')) - length(`var')/2 ) < `best' ///
			 & `tosplit' == 1
			replace `best' = abs(strpos(`var',word(`var',`i')) - length(`var')/2) ///
			 if abs(strpos(`var',word(`var',`i')) - length(`var')/2) < `best' 
		}

		replace `var' = substr(`var',1,(`splitwhere'-1)) if `tosplit' == 1 & mod(`id',1) == 0
		replace `var' = substr(`var',`splitwhere',length(`var')) if `tosplit' == 1 & mod(`id',1) != 0
		replace `var' = "" if `tosplit' != 1 & mod(`id',1) != 0 & `use' != 5
		drop `length' `words' `tosplit' `splitwhere' `best'
	   }
	   if _rc != 0{
		replace `var' = . if mod(`id',1) != 0 & `use' != 5
	   }
	}
}

summ `id' if `use' != 9
local max = r(max)
local new = r(N)+4
if `new' > _N { 
	set obs `new' 
}

forvalues i = 1/4{	// up to four lines for titles
	local multip = 1
	local add = 0
	if "$MA_DOUBLE" != ""{		// DOUBLE OPTION- CLOSER TOGETHER, GAP BENEATH
		local multip = 0.45
		local add = 0.5
	}
	local idNew`i' = `max' + `i'*`multip' + `add'
	local Nnew`i'=r(N)+`i'
	local tmp = `Nnew`i''
	replace `id' = `idNew`i'' + 1 in `tmp'
	replace `use' = 1 in `tmp'
	if `i' == 1{
		global borderline = `idNew`i''-0.25
	}
}

local maxline = 1
if "`lcols'" != ""{
	tokenize "`lcols'"
	local lcolsN = 0

	while "`1'" != ""{
		cap confirm var `1'
		if _rc!=0  {
			di in re "Variable `1' not defined"
			exit _rc
		}
		local lcolsN = `lcolsN' + 1
		tempvar left`lcolsN' leftLB`lcolsN' leftWD`lcolsN'
		cap confirm string var `1'
		if _rc == 0{
			gen str `leftLB`lcolsN'' = `1'
		}
		if _rc != 0{
			cap decode `1', gen(`leftLB`lcolsN'')
			if _rc != 0{
				local f: format `1'
				gen str `leftLB`lcolsN'' = string(`1', "`f'")
				replace `leftLB`lcolsN'' = "" if `leftLB`lcolsN'' == "."
			}
		}
		replace `leftLB`lcolsN'' = "" if (`use' != 1 & `use' != 2)
		local colName: variable label `1'
		if "`colName'"==""{
			local colName = "`1'"
		}

		// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
		// SPREAD OVER UP TO FOUR LINES IF NECESSARY
		local titleln = length("`colName'")
		tempvar tmpln
		gen `tmpln' = length(`leftLB`lcolsN'')
		qui summ `tmpln' if `use' != 0
		local otherln = r(max)
		drop `tmpln'
		// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
		local spread = int(`titleln'/`otherln')+1
		if `spread'>4{
			local spread = 4
		}

		local line = 1
		local end = 0
		local count = -1
		local c2 = -2

		local first = word("`colName'",1)
		local last = word("`colName'",`count')
		local nextlast = word("`colName'",`c2')

		while `end' == 0{
			replace `leftLB`lcolsN'' = "`last'" + " " + `leftLB`lcolsN'' in `Nnew`line''
			local check = `leftLB`lcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

			local count = `count'-1
			local last = word("`colName'",`count')
			if "`last'" == ""{
				local end = 1
			}

			if length(`leftLB`lcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
			  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
				if `end' == 0{
					local line = `line'+1
				}
			}
		}
		if `line' > `maxline'{
			local maxline = `line'
		}

		mac shift
	}
}

if `titleOff' == 1	{
	forvalues i = 1/4{
		replace `leftLB1' = "" in `Nnew`i'' 		// get rid of horrible __var name
	}
}
replace `leftLB1' = `label' if `use' != 1 & `use' != 2	// put titles back in (overall, sub est etc.)

//	STUFF ADDED FOR JS TO INCLUDE EFFICACY AS COLUMN WITH OVERALL
if "`wt'" == ""{
	local rcols = "`weightText' " + "`rcols'"


	if "$MA_method2" != ""{
		label var `weightText' "% Weight ($MA_method1)"
	}
	else{
		label var `weightText' "% Weight"
	}





}

if "`stats'" == ""{
	local rcols = "`estText' " + "`rcols'"
	if "$MA_ESLA" == ""{
		global MA_ESLA = "`sumstat'"
	}
	label var `estText' "$MA_ESLA ($IND% CI)"
}	

tempvar extra
gen `extra' = ""
label var `extra' " "
local rcols = "`rcols' `extra'"

local rcolsN = 0
if "`rcols'" != ""{
	tokenize "`rcols'"
	local rcolsN = 0
	while "`1'" != ""{
		cap confirm var `1'
		if _rc!=0  {
			di in re "Variable `1' not defined"
			exit _rc
		}
		local rcolsN = `rcolsN' + 1
		tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
		cap confirm string var `1'
		if _rc == 0{
			gen str `rightLB`rcolsN'' = `1'
		}
		if _rc != 0{
			local f: format `1'
			gen str `rightLB`rcolsN'' = string(`1', "`f'")
			replace `rightLB`rcolsN'' = "" if `rightLB`rcolsN'' == "."
		}
		local colName: variable label `1'
		if "`colName'"==""{
			local colName = "`1'"
		}

		// WORK OUT IF TITLE IS BIGGER THAN THE VARIABLE
		// SPREAD OVER UP TO FOUR LINES IF NECESSARY
		local titleln = length("`colName'")
		tempvar tmpln
		gen `tmpln' = length(`rightLB`rcolsN'')
		qui summ `tmpln' if `use' != 0
		local otherln = r(max)
		drop `tmpln'
		// NOW HAVE LENGTH OF TITLE AND MAX LENGTH OF VARIABLE
		local spread = int(`titleln'/`otherln')+1
		if `spread'>4{
			local spread = 4
		}

		local line = 1
		local end = 0
		local count = -1
		local c2 = -2

		local first = word("`colName'",1)
		local last = word("`colName'",`count')
		local nextlast = word("`colName'",`c2')

		while `end' == 0{
			replace `rightLB`rcolsN'' = "`last'" + " " + `rightLB`rcolsN'' in `Nnew`line''
			local check = `rightLB`rcolsN''[`Nnew`line''] + " `nextlast'"	// what next will be

			local count = `count'-1
			local last = word("`colName'",`count')
			if "`last'" == ""{
				local end = 1
			}
			if length(`rightLB`rcolsN''[`Nnew`line'']) > `titleln'/`spread' | ///
			  length("`check'") > `titleln'/`spread' & "`first'" == "`nextlast'"{
				if `end' == 0{
					local line = `line'+1
				}
			}
		}
		if `line' > `maxline'{
			local maxline = `line'
		}

		mac shift
	}
}

// now get rid of extra title rows if they weren't used


if `maxline'==3{
	drop in `Nnew4'
}
if `maxline'==2{
	drop in `Nnew3'/`Nnew4'
}
if `maxline'==1{
	drop in `Nnew2'/`Nnew4'
}


/* BODGE SOLU- EXTRA COLS */
while `rcolsN' < 2{
	local rcolsN = `rcolsN' + 1
	tempvar right`rcolsN' rightLB`rcolsN' rightWD`rcolsN'
	gen str `rightLB`rcolsN'' = " "
}


local skip = 1
if "`stats'" == "" & "`wt'" == ""{				// sort out titles for stats and weight, if there
	local skip = 3
}

if "`stats'" != "" & "`wt'" == ""{
	local skip = 2
}
if "`stats'" == "" & "`wt'" != ""{
	local skip = 2
}







/* SET TWO DUMMY RCOLS IF NOSTATS NOWEIGHT */

forvalues i = `skip'/`rcolsN'{					// get rid of junk if not weight, stats or counts
	replace `rightLB`i'' = "" if (`use' != 1 & `use' != 2)
}
forvalues i = 1/`rcolsN'{
	replace `rightLB`i'' = "" if (`use' ==0)
}

local leftWDtot = 0
local rightWDtot = 0
local leftWDtotNoTi = 0

forvalues i = 1/`lcolsN'{
	getWidth `leftLB`i'' `leftWD`i''
	qui summ `leftWD`i'' if `use' != 0 & `use' != 4 & `use' != 3 & `use' != 5 & ///
		`use' != 17 & `use' != 19	// DON'T INCLUDE OVERALL STATS AT THIS POINT
	local maxL = r(max)
	local leftWDtotNoTi = `leftWDtotNoTi' + `maxL'
	replace `leftWD`i'' = `maxL'
}
tempvar titleLN				// CHECK IF OVERALL LENGTH BIGGER THAN REST OF LCOLS
getWidth `leftLB1' `titleLN'	
qui summ `titleLN' if `use' != 0 & `use' != 4
local leftWDtot = max(`leftWDtotNoTi', r(max))

forvalues i = 1/`rcolsN'{
	getWidth `rightLB`i'' `rightWD`i''
	qui summ `rightWD`i'' if `use' != 0 & `use' != 4
	replace `rightWD`i'' = r(max)
	local rightWDtot = `rightWDtot' + r(max)
}

// CHECK IF NOT WIDE ENOUGH (I.E., OVERALL INFO TOO WIDE)
// LOOK FOR EDGE OF DIAMOND summ `lci' if `use' == ...

tempvar maxLeft
getWidth `leftLB1' `maxLeft'
qui count if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
if r(N) > 0{
	summ `maxLeft' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19	// NOT TITLES THOUGH!
	local max = r(max)
	if `max' > `leftWDtotNoTi'{
		// WORK OUT HOW FAR INTO PLOT CAN EXTEND
		// WIDTH OF LEFT COLUMNS AS FRACTION OF WHOLE GRAPH
		local x = `leftWDtot'*($MA_AS_TEXT/100)/(`leftWDtot'+`rightWDtot')
		tempvar y
		// SPACE TO LEFT OF DIAMOND WITHIN PLOT (FRAC OF GRAPH)
		gen `y' = ((100-$MA_AS_TEXT)/100)*(`lci'-`DXmin') / (`DXmax'-`DXmin') 
		qui summ `y' if `use' == 3 | `use' == 5
		local extend = 1*(r(min)+`x')/`x'
		local leftWDtot = max(`leftWDtot'/`extend',`leftWDtotNoTi') // TRIM TO KEEP ON SAFE SIDE
											// ALSO MAKE SURE NOT LESS THAN BEFORE!
	}

}

global LEFT_WD = `leftWDtot'
global RIGHT_WD = `rightWDtot'


local ratio = $MA_AS_TEXT		// USER SPECIFIED- % OF GRAPH TAKEN BY TEXT (ELSE NUM COLS CALC?)
local textWD = (`DXwidth'/(1-`ratio'/100)-`DXwidth') /(`leftWDtot'+`rightWDtot')

forvalues i = 1/`lcolsN'{
	gen `left`i'' = `DXmin' - `leftWDtot'*`textWD'
	local leftWDtot = `leftWDtot'-`leftWD`i''
}

gen `right1' = `DXmax'
forvalues i = 2/`rcolsN'{
	local r2 = `i'-1
	gen `right`i'' = `right`r2'' + `rightWD`r2''*`textWD'
}

local AXmin = `left1'
local AXmax = `DXmax' + `rightWDtot'*`textWD'

foreach type in "" "inf"{
	replace `tauLCI`inf'' = `DXmin' if `tauLCI' < `DXmin' & `tauLCI`inf'' != .
	replace `tauLCI`inf'' = . if `lci' < `DXmin'
	replace `tauLCI`inf'' = . if `tauLCI`inf'' > `lci'
	
	replace `tauUCI`inf'' = `DXmax' if `tauUCI`inf'' > `DXmax' & `tauUCI`inf'' != .
	replace `tauUCI`inf'' = . if `uci' > `DXmax'
	replace `tauUCI`inf'' = . if `tauUCI`inf'' < `uci'
	
	replace `tauLCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "RANDOM"
	replace `tauUCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "RANDOM"
	replace `tauLCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "RANDOM"
	replace `tauUCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "RANDOM"
}


// DIAMONDS TAKE FOREVER...I DON'T THINK THIS IS WHAT MIKE DID
tempvar DIAMleftX DIAMrightX DIAMbottomX DIAMtopX DIAMleftY1 DIAMrightY1 DIAMleftY2 DIAMrightY2 DIAMbottomY DIAMtopY

gen `DIAMleftX' = `lci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftX' = `DXmin' if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftX' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

/*If one study, no diamond*/
replace `DIAMleftX' = . if `df' < 1 & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)


gen `DIAMleftY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY1' = `id' + 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY1' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMleftY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY2' = `id' - 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY2' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMrightX' = `uci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightX' = `DXmax' if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMrightX' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

/*If one study, no diamond*/
replace `DIAMrightX' = . if `df' < 1 & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)


gen `DIAMrightY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightY1' = `id' + 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMrightY1' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMrightY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightY2' = `id' - 0.4*( abs((`uci'-`DXmax')/(`uci'-`effect')) ) if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

replace `DIAMrightY2' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMbottomY' = `id' - 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMbottomY' = `id' - 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMbottomY' = `id' - 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMtopY' = `id' + 0.4 if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMtopY' = `id' + 0.4*( abs((`uci'-`DXmin')/(`uci'-`effect')) ) if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopY' = `id' + 0.4*( abs((`DXmax'-`lci')/(`effect'-`lci')) ) if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMtopX' = `effect' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMtopX' = `DXmin' if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopX' = `DXmax' if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMtopX' = . if (`uci' < `DXmin' | `lci' > `DXmax') & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMbottomX' = `DIAMtopX'

} // END QUI

// v1.11 TEXT SIZE SOLU
// v1.16 TRYING AGAIN!
// IF aspect IS USED IN "$MA_OTHEROPTS" (OTHER GRAPH OPTS) THEN THIS HELPS TO CALCULATE TEXT SIZE
// IF NO ASPECT, BUT xsize AND ysize USED THEN FIND RATIO MANUALLY
// STATA ALWAYS TRIES TO PRODUCE A GRAPH WITH ASPECT ABOUT 0.77 - TRY TO FIND "NATURAL ASPECT"

local aspect = .

if strpos(`"$MA_OTHEROPTS"',"aspect") > 0{
	local aspectTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"aspect")), (length(`"$MA_OTHEROPTS"')) )
	local aspectTXT = substr( "`aspectTXT'", 1, ( strpos("`aspectTXT'",")")) )
	local aspect = real( substr(   "`aspectTXT'", ( strpos("`aspectTXT'","(") +1 ), ///
					( strpos("`aspectTXT'",")") - strpos("`aspectTXT'","(") -1   )   ))
}

if strpos(`"$MA_OTHEROPTS"',"xsize") > 0 ///
  & strpos(`"$MA_OTHEROPTS"',"ysize") > 0 ///
  & strpos(`"$MA_OTHEROPTS"',"aspect") == 0{

	local xsizeTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"xsize")), (length(`"$MA_OTHEROPTS"')) )

	// Ian White's bug fix!
	local xsizeTXT = substr( `"`xsizeTXT'"', 1, ( strpos(`"`xsizeTXT'"',")")) )
	local xsize = real( substr(   `"`xsizeTXT'"', ( strpos(`"`xsizeTXT'"',"(") +1 ), ///
                     ( strpos(`"`xsizeTXT'"',")") - strpos(`"`xsizeTXT'"',"(") -1   )   ))
	local ysizeTXT = substr( `"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"ysize")), (length(`"$MA_OTHEROPTS"')) )	
	local ysizeTXT = substr( `"`ysizeTXT'"', 1, ( strpos(`"`ysizeTXT'"',")")) )
	local ysize = real( substr(   `"`ysizeTXT'"', ( strpos(`"`ysizeTXT'"',"(") +1 ), ///
                     ( strpos(`"`ysizeTXT'"',")") - strpos(`"`ysizeTXT'"',"(") -1   )   ))

	local aspect = `ysize'/`xsize'
}
local approx_chars = ($LEFT_WD + $RIGHT_WD)/($MA_AS_TEXT/100)
qui count if `use' != 9
local height = r(N)
local natu_aspect = 1.3*`height'/`approx_chars'


if `aspect' == .{
	// sort out relative to text, but not to ridiculous degree
	local new_asp = 0.5*`natu_aspect' + 0.5*1 
	global MA_OTHEROPTS `"$MA_OTHEROPTS aspect(`new_asp')"'
	local aspectRat = max( `new_asp'/`natu_aspect' , `natu_aspect'/`new_asp' )
}
if `aspect' != .{
	local aspectRat = max( `aspect'/`natu_aspect' , `natu_aspect'/`aspect' )
}
local adj = 1.25
if `natu_aspect' > 0.7{
	local adj = 1/(`natu_aspect'^1.3+0.2)
}

local texts = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )
local texts2 = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )

forvalues i = 1/`lcolsN'{
	local lcolCommands`i' "(scatter `id' `left`i'' if `use' != 4, msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
}
forvalues i = 1/`rcolsN'{
	local rcolCommands`i' "(scatter `id' `right`i'' if `use' != 4, msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
}
if "$MA_rfdist" != ""{
	if "`stats'" == ""{
		local predIntCmd "(scatter `id' `right1' if `use' == 4, msymbol(none) mlabel(`RFdistText') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}
	if "$MA_nohet" == ""{
		local predIntCmd2 "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`RFdistLabel') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}	
}
if "$MA_nohet" == "" & "$MA_rjhby" != ""{
	local hetGroupCmd  "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`hetGroupLabel') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
}

// OTHER BITS AND BOBS

local dispBox "none"
if "`nobox'" == ""{
	local dispBox "square	"
}

local boxsize = $MA_FBSC/150


if `h0' != .{
	local leftfp = `DXmin' + (`h0'-`DXmin')/2
	local rightfp = `h0' + (`DXmax'-`h0')/2
}
else{
	local leftfp = `DXmin'
	local rightfp = `DXmax'
}


// GRAPH APPEARANCE OPTIONS- ADDED v1.15

/*
if `"$MA_OPT"' != "" & strpos(`"$MA_OPT"',"m") == 0{(
	global MA_OPT = `"$MA_OPT m()"' 
}
*/

if `"$MA_BOXOPT"' != "" & strpos(`"$MA_BOXOPT"',"msymbol") == 0{	// make defaults if unspecified
	global MA_BOXOPT = `"$MA_BOXOPT msymbol(square)"'
}
if `"$MA_BOXOPT"' != "" & strpos(`"$MA_BOXOPT"',"mcolor") == 0{	// make defaults if unspecified
	global MA_BOXOPT = `"$MA_BOXOPT mcolor("180 180 180")"'
}
if `"$MA_BOXOPT"' == ""{
	local boxopt "msymbol(`dispBox') msize(`boxsize') mcolor("180 180 180")"
}
else{
	if strpos(`"$MA_BOXOPT"',"mla") != 0{
		di as error "Option mlabel() not allowed in boxopt()"
		exit
	}
	if strpos(`"$MA_BOXOPT"',"msi") != 0{
		di as error "Option msize() not allowed in boxopt()"
		exit
	}
	local boxopt `"$MA_BOXOPT msize(`boxsize')"' 
}
if "$MA_classic" != ""{
	local boxopt "mcolor(black) msymbol(square) msize(`boxsize')"
}
if "`box'" != ""{
	local boxopt "msymbol(none)"
}



if `"$MA_DIAMOPT"' == ""{
	local diamopt "lcolor("0 0 100")"
}
else{
	if strpos(`"$MA_DIAMOPT"',"hor") != 0 | strpos(`"$MA_DIAMOPT"',"vert") != 0{
		di as error "Options horizontal/vertical not allowed in diamopt()"
		exit
	}
	if strpos(`"$MA_DIAMOPT"',"con") != 0{
		di as error "Option connect() not allowed in diamopt()"
		exit
	}
	if strpos(`"$MA_DIAMOPT"',"lp") != 0{
		di as error "Option lpattern() not allowed in diamopt()"
		exit
	}
	local diamopt `"$MA_DIAMOPT"'
}



if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"msymbol") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT msymbol(diamond)"' 
}
if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"msize") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT msize(vsmall)"' 
}
if `"$MA_POINTOPT"' != "" & strpos(`"$MA_POINTOPT"',"mcolor") == 0{(
	global MA_POINTOPT = `"$MA_POINTOPT mcolor(black)"' 
}
if `"$MA_POINTOPT"' == ""{
	local pointopt "msymbol(diamond) msize(vsmall) mcolor("0 0 0")"
}
else{
	local pointopt `"$MA_POINTOPT"'
}
if "$MA_classic" != "" & "`box'" == ""{
	local pointopt "msymbol(none)"
}



if `"$MA_CIOPT"' != "" & strpos(`"$MA_CIOPT"',"lcolor") == 0{(
	global MA_CIOPT = `"$MA_CIOPT lcolor(black)"' 
}
if `"$MA_CIOPT"' == ""{
	local ciopt "lcolor("0 0 0")"
}
else{
	if strpos(`"$MA_CIOPT"',"hor") != 0 | strpos(`"$MA_CIOPT"',"vert") != 0{
		di as error "Options horizontal/vertical not allowed in ciopt()"
		exit
	}
	if strpos(`"$MA_CIOPT"',"con") != 0{
		di as error "Option connect() not allowed in ciopt()"
		exit
	}
	if strpos(`"$MA_CIOPT"',"lp") != 0{
		di as error "Option lpattern() not allowed in ciopt()"
		exit
	}
	local ciopt `"$MA_CIOPT"'
}


// END GRAPH OPTS



if "$MA_method1" == "RANDOM"{
	tempvar noteposx noteposy notelab
	qui{
	summ `id'
		gen `noteposy' = r(min) -1.5 in 1
		summ `left1'
		gen `noteposx' = r(mean) in 1
		gen `notelab' = "NOTE: Weights are from random effects analysis" in 1
		local notecmd "(scatter `noteposy' `noteposx', msymbol(none) mlabel(`notelab') mlabcolor(black) mlabpos(3) mlabsize(`texts')) "
	}
	if "$MA_nowarning" != ""{
		local notecmd
	}
}


if "`overall'" != ""{
	local overallCommand ""
	qui drop if `use' == 5
	qui summ `id'
	local DYmin = r(min)
	cap replace `noteposy' = r(min) -.5 in 1
}

// quick bodge to get overall- can't find log version!
tempvar tempOv ovLine ovMin ovMax h0Line
qui gen `tempOv' = `effect' if `use' == 5
sort `tempOv'
qui summ `id'
local DYmin = r(min)-2
local DYmax = r(max)+1

qui gen `ovLine' = `tempOv' in 1
qui gen `ovMin' = r(min)-2 in 1
qui gen `ovMax' = $borderline in 1
qui gen `h0Line' = `h0' in 1

if `"$MA_OLINEOPT"' == ""{
	local overallCommand " (pcspike `ovMin' `ovLine' `ovMax' `ovLine', lwidth(thin) lcolor(maroon) lpattern(shortdash)) "
}
else{
	local overallCommand `" (pcspike `ovMin' `ovLine' `ovMax' `ovLine', $MA_OLINEOPT) "'
}
if `ovLine' > `DXmax' | `ovLine' < `DXmin' | "`overall'" != ""{	// ditch if not on graph
	local overallCommand ""
}

// if summary only must not have weights
local awweight "[aw = `wtdisp']"

if "$MA_summaryonly" != "" | ("`wt'" != ""){
	local awweight ""
}
qui summ `weight'
if r(N) == 0{
	local awweight ""
}





// rfdist off scale arrows only used when appropriate
qui{
tempvar rfarrow
gen `rfarrow' = 0
if "$MA_rfdist" != ""{
	if "$MA_method1" == "RANDOM"{
		replace `rfarrow' = 1 if `use' == 3 | `use' == 5
	}
	if "$MA_method2" == "RANDOM"{
		replace `rfarrow' = 1 if `use' == 17 | `use' == 19
	}
}
}	// end qui


// final addition- if aspect() given but not xsize() ysize(), put these in to get rid of gaps
// need to fiRandome to allow space for bottom title
// should this just replace the aspect option?
// suppose good to keep- most people hopefully using xsize and ysize and can always change themselves if using aspect

if strpos(`"$MA_OTHEROPTS"',"xsize") == 0 & strpos(`"$MA_OTHEROPTS"',"ysize") == 0 ///
  & strpos(`"$MA_OTHEROPTS"',"aspect") > 0 {

	local aspct = substr(`"$MA_OTHEROPTS"', (strpos(`"$MA_OTHEROPTS"',"aspect(")+7 ) , length(`"$MA_OTHEROPTS"') )
	local aspct = substr(`"`aspct'"', 1, (strpos(`"`aspct'"',")")-1) )
	if `aspct' > 1{
		local xx = (11.5+(2-2*1/`aspct'))/`aspct'
		local yy = 12
	}
	if `aspct' <= 1{
		local yy = 12*`aspct'
		local xx = 11.5-(2-2*`aspct')
	}
	global MA_OTHEROPTS = `"$MA_OTHEROPTS"' + " xsize(`xx') ysize(`yy')"

}
/*===============================================================================================*/
/*====================================  GRAPH    ================================================*/
/*===============================================================================================*/

*`awweight' - This is the problem

#delimit ;

twoway
/* NOTE FOR RF, AND OVERALL LINES FIRST  */
	`notecmd' 
	`overallCommand' 
	`predIntCmd' 
	`predIntCmd2' 
	`hetGroupCmd' 

/* PLOT BOXES AND PUT ALL THE GRAPH OPTIONS IN THERE */ 
	(scatter `id' `effect' `awweight'  if `use' == 1, 
	  `boxopt' 
	  yscale(range(`DYmin' `DYmax') noline )
	  ylabel(none) ytitle("")
	  xscale(range(`AXmin' `AXmax'))
	  xlabel(`lblcmd', labsize(`texts2') )
	  yline($borderline, lwidth(thin) lcolor(gs12))
/* THIS BIT DOES favours. NOTE SPACES TO SUPPRESS IF THIS IS NOT USED */
	  xmlabel(`leftfp' "`leftfav' " `rightfp' "`rightfav' ", noticks labels labsize(`texts') 
	  `gap' /* PUT LABELS UNDER xticks? Yes as labels now extended */ ) 
	  xtitle("") legend(off) xtick("`xtick'") )  
	  
/* END OF FIRST SCATTER */
/* HERE ARE THE CONFIDENCE INTERVALS */
	(pcspike `id' `lci' `id' `uci' if `use' == 1, `ciopt')
/* ADD ARROWS IF OFFSCALE USING offLeftX offLeftX2 offRightX offRightX2 offYlo offYhi */
	(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if `use' == 1, `ciopt')
	(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if `use' == 1, `ciopt')
	(pcspike `id' `offRightX' `offYlo' `offRightX2' if `use' == 1, `ciopt')
	(pcspike `id' `offRightX' `offYhi' `offRightX2' if `use' == 1, `ciopt') 
/* DIAMONDS FOR SUMMARY ESTIMATES -START FROM 9 O'CLOCK */
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMtopY' `DIAMtopX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMtopY' `DIAMtopX' `DIAMrightY1' `DIAMrightX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMrightY2' `DIAMrightX' `DIAMbottomY' `DIAMbottomX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')
	(pcspike `DIAMbottomY' `DIAMbottomX' `DIAMleftY2' `DIAMleftX' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19, `diamopt')  
/* EXTENDED CI FOR RANDOM EFFECTS, SHOW DISTRIBUTION AS RECOMMENDED BY JULIAN HIGGINS 
   DOTTED LINES FOR INESTIMABLE DISTRIBUTION */
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `tauLCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
	(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `tauUCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' < ., `diamopt')
	(pcspike `DIAMleftY1' `DIAMleftX' `DIAMleftY1' `tauLCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash))
	(pcspike `DIAMrightY1' `DIAMrightX' `DIAMrightY1' `tauUCI' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `tau2' ==.b, `diamopt' lpattern(shortdash)) 
/* DIAMOND EXTENSION FOR RF DIST ALSO HAS ARROWS... */
	(pcspike `id' `offLeftX' `offYlo' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offLeftX' `offYhi' `offLeftX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offRightX' `offYlo' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt')
	(pcspike `id' `offRightX' `offYhi' `offRightX2' if (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19) & `rfarrow' == 1, `diamopt') 
/* COLUMN VARIABLES */
	`lcolCommands1' `lcolCommands2' `lcolCommands3' `lcolCommands4' `lcolCommands5' `lcolCommands6'
	`lcolCommands7' `lcolCommands8' `lcolCommands9' `lcolCommands10' `lcolCommands11' `lcolCommands12'
	`rcolCommands1' `rcolCommands2' `rcolCommands3' `rcolCommands4' `rcolCommands5' `rcolCommands6'
	`rcolCommands7' `rcolCommands8' `rcolCommands9' `rcolCommands10' `rcolCommands11' `rcolCommands12'
	(scatter `id' `right1' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB1') mlabcolor("0 0 0") mlabpos(3) mlabsize(`texts'))
	(scatter `id' `right2' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB2') mlabcolor("0 0 0") mlabpos(3) mlabsize(`texts'))
/* 	(scatter `id' `right2', mlabel(`use'))   JUNK, TO SEE WHAT'S WHERE */
/* LAST OF ALL PLOT EFFECT MARKERS TO CLARIFY AND OVERALL EFFECT LINE */
	(scatter `id' `effect' if `use' == 1, `pointopt' )
	, $MA_OTHEROPTS /* RMH added */ plotregion(margin(zero));


#delimit cr
end
/*===============================================================================================*/
/*==================================== GETWIDTH  ================================================*/
/*===============================================================================================*/
capture program drop getWidth
program define getWidth
version 10.1

//	ROSS HARRIS, 13TH JULY 2006
//	TEXT SIZES VARY DEPENDING ON CHARACTER
//	THIS PROGRAM GENERATES APPROXIMATE DISPLAY WIDTH OF A STRING
//	FIRST ARG IS STRING TO MEASURE, SECOND THE NEW VARIABLE

//	PREVIOUS CODE DROPPED COMPLETELY AND REPLACED WITH SUGGESTION
//	FROM Jeff Pitblado

qui{

gen `2' = 0
count
local N = r(N)
forvalues i = 1/`N'{
	local this = `1'[`i']
	local width: _length "`this'"
	replace `2' =  `width' +1 in `i'
}

} // end qui

end

/*===============================================================================================*/
/*====================================   EXCI    ================================================*/
/*===============================================================================================*/
version 10.1
cap program drop exci
program define exci
	syntax varlist [, Ul(str) Ll(str) Se(str) Id(str) Format(str) Cii(str)]
	tokenize `varlist' 
	qui count
	if "`format'"=="" {
		local format "%9.4f"
	}
	if "`ul'"~="" {
		gen `ul'=.
		lab var `ul' "Upper limit"
	}
	if "`ll'"~="" {
		gen `ll'=.
		lab var `ll' "Lower limit"
	}
	if "`se'"~="" {
		gen `se'=.
		lab var `se' "Standard error"
	}
	if "`id'"=="" {
		local id _n
	}
	di _newline in y "REC;`id';N `1';N `2';Prop.;SE;LL;UL"
			
	forvalues i = 1/`r(N)' {
		local N = `1'[`i'] 
		local n = `2'[`i'] 
		if (`n' != . & `N' > 0) {
			qui cii `N' `n' , `cii'
			local rate=r(mean)
			local lli=r(lb)
			local uli=r(ub)
			local ser=r(se)			
		} 
		else	{
			local rate=.
			local lli=.
			local uli=.
			local ser=.
	 	}
		local iRandom=`id' in `i'	
		di in y "`i' ;" in gr "`iRandom' ;`N';`n';" `format' `rate' ";" `format' `ser' ";" `format' `lli' ";" `format' `uli'
		
		if "`ul'"~="" {
			qui replace `ul'=`uli' in `i'
		}
		if "`ll'"~="" {
			qui replace `ll'=`lli' in `i'
		}
		if "`se'"~="" {
			qui replace `se'=`ser' in `i'
		}		
	}
end

exit
