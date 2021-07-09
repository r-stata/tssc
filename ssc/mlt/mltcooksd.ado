* version 1.4beta  25Jan2013
*alexander.schmidt@wiso.uni-koeln.de; moehring@wiso.uni-koeln.de
*following Rense Nieuwenhuis, Manfred te Grotenhuis and Ben Pelzer "influence.ME: Tools for Detecting Influential Data in Mixed Effects Models"


* new in version 1.4 beta
* there was a bug that occured when the random slope variables had names with an underscore --> solved
* the command now has the option: approx. This option is for use with xtmelogit and xtmepoisson.
*     if approx is specified, the models are not completely estimated but we run only one iteration
*     starting from the coefficient vector of the full model. More iterations than one are run if
*     convergence is not achieved.

version 11.0, missing
capture program drop mltcooksd		
program define mltcooksd, rclass	


*syntax
syntax [, keepvar(string) counter graph slabel fixed random approx]


*Display error messages and terminate program if necessary
**1. error if command != xtmelogit or xtmixed or xtmepoisson
if regexm(e(cmd), "xtmixed")==0 & regexm(e(cmd), "xtmelogit")==0 & regexm(e(cmd), "xtmepoisson")==0 {
 di as error "mltcooksd works only after xtmixed, xtmelogit or xtmepoisson"
 exit
 }

**2. error if number of levels > 2
local lvl2var = e(ivars)
local lvl2vardis = e(ivars)		
tokenize "`lvl2var'"
if "`2'" !="" {
 di as error "mltcooksd works only with 2-level models"
 exit
}


* store estimation results of user 
capture drop userest
_est hold userest, copy restore
est store FULL		
drop _est_FULL		


* timer back to the start
timer clear

*Erase variables
capture drop DFB_*
capture drop L2ID
capture drop Cooks*
capture drop mltcdsample
capture drop mltl2idstr

** Convert string L2ID into nummeric L2ID
capture confirm numeric v `e(ivars)'
if _rc {
	encode `lvl2var', gen(mltl2idstr)
	local lvl2var = "mltl2idstr"
	}



*Check and display user-defined variable name prefix
local keepvar1=substr("`keepvar'",1,1)
capture confirm number `keepvar1'
if !_rc {
 local falsevarname=1
 dis as error "Varname prefix `keepvar' not allowed"
 dis as error "Variables will not be stored"
 dis " "
}
else {
 local falsevarname=0
}


*Save sample
tempvar mltcdsample
gen mltcdsample=e(sample)


*Get lvl2-values
dis as text "Level 2 variable is" as result " `lvl2vardis' "
dis " "
qui levelsof `lvl2var' if mltcdsample==1, local(lvl2values) 
gettoken l2v1 l2v2: lvl2values, parse(" ")

*Get commandline and options
local cmdline  `e(cmdline)'		
gettoken rest options: cmdline, parse(",")


* get some values used for the counter
matrix G = e(N_g)
local g = G[1,1]		
local g1 = `g'-2


*Get number of fixed and random parameters and number of independent variables
local fixpar = e(k_f)
local ranpar = e(k_r)
local niv = `fixpar'-1
local nrp1 = ((`ranpar'-1)/2)-1		 
local nrp = `ranpar'-1			



gettoken com rest: cmdline 
gettoken dvarn rest: rest
local command="`com' "+"`dvarn' "	
mat VARn=e(b)					 
mat VARn=VARn[1,1..`niv']			 
local ivars:colnames(VARn)			

* get names of the random slope variables
if `nrp'>1 {
local re = e(revars)
gettoken re rest1: re  
}
dis as text "Calculating DFBETAs for the fixed effects of "
dis as result " `ivars' _cons " 
dis " "


* $ new option approx: start from the coefficient vector of the full model and then do only one iteration
* More iterations are only done if convergence is not achieved.
if "`approx'"=="approx" & "`com'" != "xtmixed" {
local app = "from(FULL_b) tolerance(10000000) nrtolerance(10000000)"
}

* check for weighting and construct the weighting command
if "`e(wtype)'"!="" {
local weight = "[`e(wtype)'`e(wexp)']"
} 

* Save the VCE matrix of the random effects of the full model
	local c
	local d
	
	mat VCEre = e(V)
	local a : rowfullnames(VCEre)		// get names of columns of VCE matrix
	 
	foreach n of numlist 1/`fixpar' {	// delete column names of fixed parameters
		gettoken first a: a
	}
 
	local b : word count `a'
	foreach n of numlist 1/`b' {		// generate a local (string) for each random effect that can be used with the nlcom command 
		gettoken re`n' a: a
		gettoken re`n'help : re`n', parse("_")
		if "`re`n'help'" == "lns1"	{
			local re`n' = "(re`n': exp(_b["+"`re`n''"+"])) "	
			}
		if "`re`n'help'" == "atr1"	{
			local re`n' = "(re`n': tanh(_b["+"`re`n''"+"])) "	
			}
		if "`re`n'help'" == "lnsig"	{
			local re`n' = "(re`n': exp(_b["+"`re`n''"+"]))"	
			}
		local c  `c' re`n'
		}

		foreach n of local c {
		local d `d' ``n''
		}
	qui nlcom `d'		// tramsform VCE matrix  
	mat FULL_b_re = r(b)


*Calculate DFBETAs
matrix FULL_b   = get(_b)	// save the coefficient matrix from the full model as FULL_b
foreach num in `lvl2values' {
	
	if "`counter'" == "counter" {
	timer clear 1				  
	timer on 1				 
	}
qui `command' `ivars' `weight' || `lvl2var': `re' if mltcdsample==1 & `lvl2var' !=`num' `options' `app' // estimate model without Level-Two-Unit 'num' 
		* saving estimation results for later use
		estimates store WJ`num' 
		drop _est_WJ`num'

matrix WJ`num'_b = get(_b) 									
matrix WJ`num'_VCE = get(VCE) 								
capture matrix WJ`num'_SE = cholesky(diag(vecdiag(WJ`num'_VCE)))	
	local rc = _rc
	if `rc' == 506 {
		dis as error "Cook's D and DFBETAs cannot be estimated for the level-two unit " as result "`lvl2var'==`num' " 
		dis as error  "because the model is not identified without unit."
		exit 2000 
		}
matrix WJ`num'_b_diff = FULL_b-WJ`num'_b					
matrix WJ`num'_SE_inv = syminv(WJ`num'_SE)					
matrix DFB`num' = WJ`num'_b_diff*WJ`num'_SE_inv				
matrix rownames DFB`num' = `lvl2var'_`num'



	* save VCE matrix of random part of the model
	local c
	local d
	
	mat VCEre = e(V)
	local a : rowfullnames(VCEre)		// get names of columns of VCE matrix
	 
	foreach n of numlist 1/`fixpar' {	// delete column names of fixed parameters
		gettoken first a: a
	}
 
	local b : word count `a'
 	foreach n of numlist 1/`b' {		// generate a local (string) for each random effect that can be used with the nlcom command 
		gettoken re`n' a: a
		gettoken re`n'help : re`n', parse("_")
		if "`re`n'help'" == "lns1"	{
			local re`n' = "(re`n': exp(_b["+"`re`n''"+"])) "	
			}
		if "`re`n'help'" == "atr1"	{
			local re`n' = "(re`n': tanh(_b["+"`re`n''"+"])) "	
			}
		if "`re`n'help'" == "lnsig"	{
			local re`n' = "(re`n': exp(_b["+"`re`n''"+"]))"	
			}
		local c  `c' re`n'
		}
		foreach n of local c {
		local d `d' ``n''
		}

	qui nlcom `d'  		// transform VCE matrix
	mat WJ`num'_br_diff = FULL_b_re-r(b)
	mat WJ`num'_VCEr = r(V)

				
	
	* timer
	if "`counter'" == "counter" {
	timer off 1		 
	qui timer list		
	local g = `g'-1		
	
		local t = r(t1)	
		if `g' > `g1' {
		local tm = `t'*`g'
		}
		if `g' < `g1'+2 {
		local tm = (`tm'+`t'*`g')/2
		}
	
		if `g' > `g1' {
		display as text "Estimated time until mltcooksd is finished:"
		}
	
		if `g' > 0 {
			if `tm' < 60 {
			display %2.0f as result `tm' as text " seconds" 
			}
			if `tm' > 60 & `tm' <= 3600 {
			display %3.1f as result `tm'/60 as text " minutes" 
			}
			if `tm' > 3600 & `tm' < 216000 {
			display %3.1f as result `tm'/3600 as text " hours" 
			}
		}
	}
}


* Combining all single matrices from above into one matrix
mat DFBETAs = DFB`l2v1'
foreach num in `l2v2' {
mat DFBETAs = DFBETAs \ DFB`num'
}



* get number of level two units
local c = rowsof(DFBETAs)
	
* generate column with Level-two IDs
qui gen L2ID = . in 1/`c'
local i = 0
foreach num in `lvl2values' {
	local i = `i'+1
	if `i'>`c' {
		continue, break
		}
	qui replace L2ID = `num' in `i'
	}	

	label variable L2ID "Level Two ID"
	local vl :value label `lvl2var'		
	label values L2ID `vl'					
	

svmat DFBETAs
local a = `fixpar'+1
local b = `fixpar'+`ranpar'
drop  DFBETAs`a'-DFBETAs`b'

* rename variables (using names of the independent variables) 
local i = 0
foreach name in `ivars' {
		if `i' < 1  {
		tempvar DFB_cons
		qui rename DFBETAs`fixpar' DFB_cons
		label variable DFB_cons "DFBETAs (Constant)"
		}
	local i = `i'+1
	qui rename DFBETAs`i' DFB_`name'
	label variable DFB_`name' "DFBETAs (`name')"
}	


	
* define display format for these variables 
format DFB_* %5.4f		
	
	

* Now calculate Cooks D
	* fixed part
	foreach num in `lvl2values' {
	mat WJ`num'_bf_diff = WJ`num'_b_diff[1, 1..`fixpar']		
	mat WJ`num'_VCEf = WJ`num'_VCE[1..`fixpar',1..`fixpar']		
	mat CooksDf_J`num' = 1/`fixpar' * WJ`num'_bf_diff * syminv(WJ`num'_VCEf) * WJ`num'_bf_diff'         
	matrix rownames CooksDf_J`num' = Country`num'
	
	* random part
	*mat WJ`num'_br_diff = WJ`num'_b_diff[1, `a'..`b']			
	*mat WJ`num'_VCEr = WJ`num'_VCE[`a'..`b',`a'..`b']			
	mat CooksDr_J`num' = 1/`ranpar' * WJ`num'_br_diff * syminv(WJ`num'_VCEr) * WJ`num'_br_diff'         
	matrix rownames CooksDr_J`num' = Country`num'
	}
	
	* CooksD for fixed part combined in one matrix
	mat CooksD_f = CooksDf_J`l2v1'
	foreach num in `l2v2' {
	mat CooksD_f = CooksD_f \ CooksDf_J`num'
	}
	* CooksD for random part combined in one matrix
	mat CooksD_r = CooksDr_J`l2v1'
	foreach num in `l2v2' {
	mat CooksD_r = CooksD_r \ CooksDr_J`num'
	}
	


* store CooksD in a variable
svmat CooksD_f
rename CooksD_f1 CooksD_f 
svmat CooksD_r
rename CooksD_r1 CooksD_r
label variable CooksD_f "Cook's D (fixed part)"
label variable CooksD_r "Cook's D (random part)"

* calculate CooksD for the whole model
qui gen CooksD = (1/(`fixpar'+`ranpar'))*(`fixpar'*CooksD_f+`ranpar'*CooksD_r)	
label variable CooksD "Cook's D (random+fixed part)" 

		if "`fixed'" != "fixed" {
		drop CooksD_f
		}
		if "`random'" != "random" {
		drop CooksD_r
		}

* calculating cut off values for CooksD and DFBETAs
local DFcut = 2/sqrt(`c')		// Cutoff value for DFBETAs (after Belsley et. al. 1980) 
local CDcut = 4/`c' 			// Cutoff value for CooksD  (after Belsley et. al. 1980)

* display cutoff values
dis as text "Cutoff value for DFBETAs is" 
dis %5.4f as result `DFcut' 
dis as text "Cutoff value for Cook's D is" 
dis %5.4f as result  `CDcut' 


*keep user data-set
preserve


* List countries where estimates exceed the cutoff value
dis " "		
dis as text "Level-two units with Cook's D above the cut off value:"
gsort -CooksD



if "`fixed'" == "fixed" & "`random'" == "random"  {
		if "`slabel'" == "slabel" {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_f >= `CDcut' & CooksD_f !=.  | CooksD_r >= `CDcut' & CooksD_r != ., sep(0)  noobs nol
		}
		else {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_f >= `CDcut' & CooksD_f !=. | CooksD_r >= `CDcut' & CooksD_r !=. , sep(0)  noobs
		}
}		
if "`fixed'" == "fixed" & "`random'" != "random" {
		if "`slabel'" == "slabel" {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_f >= `CDcut' & CooksD_f !=. , sep(0)  noobs nol
		}
		else {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_f >= `CDcut' & CooksD_f !=. , sep(0)  noobs 
		}
}
if "`fixed'" != "fixed" & "`random'" == "random" {
		if "`slabel'" == "slabel" {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_r >= `CDcut' & CooksD_r !=. , sep(0)  noobs nol
		}
		else {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD !=.  | CooksD_r >= `CDcut' & CooksD_r !=. , sep(0)  noobs
		}
}		
if "`fixed'" != "fixed" & "`random'" != "random" {
		if "`slabel'" == "slabel" {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD != ., sep(0)  noobs nol
		}
		else {
		list L2ID CooksD* if CooksD >= `CDcut' & CooksD != ., sep(0)  noobs
		}
}		
dis as text "   Legend: CooksD   = overall Cook's D"
if "`fixed'" == "fixed" {
dis as text "           CooksD_f = Cook's D fixed part" 
}
if "`random'" == "random" {
dis as text "           CooksD_r = Cook's D random part" 
}

*********

* List DFBETAs 
dis " "	
dis " "	
dis as text "Level-two units with DFBETAs above cut off value:"

	* generate a variable that indicates which DFBETAs exceed the cut off value
	qui egen dfb_min = rowmin(DFB_*)
	qui egen dfb_max = rowmax(DFB_*)
	qui replace dfb_min = sqrt(dfb_min^2)
	qui egen dfb_ac = rowmax(dfb_m*)
	qui recode dfb_ac min/`DFcut' = 0 `DFcut'/max = 1

	* list dfbetas with or without labels depending on the option specified
	if "`slabel'" == "slabel" {
	list L2ID DFB_* if dfb_ac == 1  , sep(0) noobs nol ab(10) 
	}
	else {
	list L2ID DFB_* if dfb_ac == 1  , sep(0) noobs ab(10) 
	}
	drop dfb_min dfb_max dfb_ac

	

if "`graph'" == "graph" {
	if "`slabel'" == "slabel" {
	label values L2ID 
	}
		* generate string for the graph command
		local drop opt
		foreach num of numlist 1/`fixpar' { 
			local opt `opt' marker(`num',mlab(L2ID) mlabang(45))
		}
	graph hbox DFB*, yline(`DFcut' -`DFcut', lc(red)) `opt' showyvar legend(off)  ytitle(DFBETAs) text(-`DFcut' 0 "cutoff", placement(w) color(red)) text(`DFcut' 0 "cutoff", placement(e) color(red))
		if "`slabel'" == "slabel" {
		label values L2ID `vl'
		} 
}


* generate the macro that contains all models which cause Cook's D to be above the cutoff
local mcdac = " FULL "
local i = 0
foreach num of numlist  1/`c' {
	local i = `i'+1
	local j = CooksD in `i'
	local id = L2ID in `i'
		if `j' > `CDcut'	{
		local mcdac = " `mcdac' WJ`id'"
		}
		else { 
		continue, break
		}
}


global mcdac = "`mcdac'"	


*back to user data-set
restore


if "`keepvar'" != "" & `falsevarname'==0{
 *Rename variables
 capture drop `keepvar'_DFB_*
 capture drop `keepvar'_L2ID
 capture drop `keepvar'_CooksD
 capture drop `keepvar'_CooksD_f
 capture drop `keepvar'_CooksD_r
 capture drop `keepvar'_sample
 capture drop `keepvar'_DFB_cons
 capture drop `keepvar'_mltcdsample
  
 
 * Store results in data set
 foreach var of varlist  DFB_* CooksD* {
 	qui gen `keepvar'_`var' = .
 	foreach num of numlist `lvl2values' {
 		qui sum `var' if L2ID == `num'
 		qui replace `keepvar'_`var' =r(mean) if `lvl2var' == `num' & mltcdsample == 1
 	}
 }
 
label variable `keepvar'_CooksD "Cook's D (random+fixed part)"
capture label variable `keepvar'_CooksD_f "Cook's D (fixed part)"
capture label variable `keepvar'_CooksD_r "Cook's D (random part)"
foreach var in `ivars' {
label variable `keepvar'_DFB_`var' "DFBETAs(`var')"
}
capture label variable `keepvar'_DFB_cons  "DFBETAs(Constant)"

 rename mltcdsample `keepvar'_mltcdsample
 capture drop mltl2idstr
 capture drop L2ID_
 capture drop L2ID
 capture drop DFB_*
 capture drop CooksD*

 dis as text " "
 dis as text " "
 dis as text "Variables stored as `keepvar'_*" 
}
else {
 *Erase variables
 drop DFB_*
 drop L2ID
 drop Cooks*
 drop mltcdsample
}


* restore the estimation results 
 _est unhold userest
 




end 
