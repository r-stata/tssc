*! 3.04 21Sep2010
* fixed small bug in counts option (`rawcounts' var truncated as str20)
* 3.03 19May2009
* fixes prediction interval calculation for non-ratio measures and change of variable type in lcols() rcols()
* think latter is ok actually- check download, perhaps was using old version!
* Based on 3.01 07Jul2008
* Based on 2.34 11May2007
* Based on previous version: 1.86 1Apr2004

/*Revision list at end

Syntax:
a) binary data:
	metan #events_group1 #nonevents_group1 #events_group2 #nonevents_group2 , ...
b) cts data:     
	metan #group1 mean1 sd1  #group2 mean2 sd2 , ...
c) generic effect size+st error: 
	metan theta se_theta , ...
d) generic effect size+ci: 
	metan theta lowerlimit upperlimit , ...

*/


program define metan, rclass

version 9.0
#delimit ;
syntax varlist(min=2 max=6 default=none numeric) [if] [in] [, BY(string)
	ILevel(integer $S_level) OLevel(integer $S_level) CC(string) 
	OR RR RD FIXED FIXEDI RANDOM RANDOMI PETO COHEN HEDGES GLASS noSTANDARD 
	CHI2 CORNFIELD LOG BRESLOW EFORM noINTeger noOVERALL noSUBGROUP SGWEIGHT 
	SORTBY(passthru) noKEEP noGRAPH noTABLE LABEL(string) noBOX
	XLAbel(passthru) XTick(passthru) FORCE BOXSCA(real 100.0) BOXSHA(integer 4) 
	TEXTSize(real 100.0) noWT noSTATS COUNTS WGT(varlist numeric max=1) 
	GROUP1(string) GROUP2(string) EFFECT(string) 
	/* new additions */ 
	LCOLS(varlist) RCOLS(varlist) ASTEXT(integer 50) DOUBLE NOHET NULL(real 999) RFDIST SUMMARYONLY
	SECOND(string) NOSECSUB SECONDSTATS(string) FAVOURS(string) FIRST(string) FIRSTSTATS(string)
	BOXOPT(string) DIAMOPT(string) POINTOPT(string) CIOPT(string) OLINEOPT(string) 
	CLASSIC NOWARNING NULLOFF EFFICACY RFLevel(integer $S_level) DP(integer 2)
	* ];

#delimit cr

global MA_OTHEROPTS `"`options'"'
global MA_BOXOPT `"`boxopt'"'
global MA_DIAMOPT `"`diamopt'"'
global MA_POINTOPT `"`pointopt'"'
global MA_CIOPT `"`ciopt'"'
global MA_OLINEOPT `"`olineopt'"'

global MA_DOUBLE  "`double'"
global MA_FAVOURS "`favours'"
global MA_secondstats "`secondstats'"
global MA_firststats "`firststats'"
global MA_nohet "`nohet'"
global MA_rfdist "`rfdist'"
global MA_summaryonly "`summaryonly'"
global MA_classic "`classic'"
global MA_nowarning "`nowarning'"
global MA_nulloff "`nulloff'"
global MA_efficacy "`efficacy'"
global MA_dp = "`dp'"

if `null' != 999{
	global MA_NULL = "`null'"
}
else{
	global MA_NULL = ""
}

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
global MA_TEXT_SCA `textsize'	// oops, that was in already

if `astext' > 90 | `astext' < 10 {
	di as error "Percentage of graph as text (ASTEXT) must be within 10-90%"
	di as error "Must have some space for text and graph"
	exit
}
if `textsize' < 20 | `textsize' > 500 {
	di as error "Text scale (TEXTSize) must be within 20-500"
	di as error "Value is character size relative to graph"
	di as error "Outside range will either be unreadable or too large"
	exit
}
    
*label groups 
if "`group1'"=="" { 
	global MA_G1L "Treatment" 
}
else { 
	global MA_G1L "`group1'"  
}
if "`group2'"=="" { 
	global MA_G2L "Control"   
}
else { 
	global MA_G2L "`group2'"  
}
if "`legend'"!="" { 
	global S_TX "`legend'" 
}

global MA_FTSI `textsize'
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

forvalues i = 1/12{
	global S_`i' .
}
global MA_rjhby "`by'"
	
*If not using own weights set fixed as default 

if "`fixed'`random'`fixedi'`randomi'`peto'"=="" & ( "`wgt'"=="" ) { 
	local fixed "fixed" 
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
	if "`fixed'`random'`fixedi'`randomi'`peto'"!="" { 
		di as err "Option invalid with user-defined weights"
		exit
	}
	confirm numeric variable `wgt'
	local wgt "wgt(`wgt')"
}

} /* End of quietly loop */


tokenize "`varlist'", parse(" ")

if "`6'"=="" {

	if "`4'"=="" {

		*Input is {theta setheta} or {theta lowerci upperci} => UDW, IV or D+L weighting
		if "`3'"!="" {
		*input is theta lci uci
			cap assert ((`3'>=`1') & (`1'>=`2'))
			if _rc!=0 {
				di in bl "Effect size and confidence intervals invalid:"
				di in bl "order should be {effect size, lower ci limit, upper ci limit}"
				exit _rc
		  	}
			global MA_params = 3
		}
		else{
			global MA_params = 2
		}

		cap assert "`log'"==""
		if _rc!=0 {
			di in bl "Log option not available without raw data counts: if necessary, transform both"
			di in bl "effect and standard error using " in wh "generate" in bl " and re-issue the metan command"
			exit _rc
		}

 		cap assert "`chi2'`cornfield'`peto'`breslow'`counts'`or'`rr'`rd'`standard'`hedges'`glass'`cohen'"==""
		if _rc!=0 {
			di as err "Option not available without raw data counts" 
			exit _rc
		}
		if "`wgt'"!="" { 
			local method "*" 
		}
		else {
			if "`random'`randomi'"!="" {
				local randomi
				local random "random"
				local method  "D+L" 
			}
			if "`fixed'`fixedi'"!="" {
				local fixedi
				local fixed "fixed"
				local method  "I-V" 
			}
		cap assert ("`random'"=="") + ("`fixed'"=="")==1
		if _rc!=0 {
			di as err "Specify fixed or random effect/s model"
			exit _rc
		}
	}

	cap assert "`cc'"=="" 
	if _rc!=0 {
		di as err "Continuity correction not valid with unless individual counts specified" 
		exit _rc
	}

	local callalg "iv_init"
	local sumstat "ES"  

}	/*end of 2&3-variable set-up */

	if "`4'"!="" {
	*Input is 2x2 tables: MH, Peto, IV, D+L or user defined weighting allowed
		cap assert "`5'"==""
		if _rc!=0 {
			di as err "Wrong number of variables specified" 
			exit _rc
		}
		if "`integer'"=="" {
			cap { 
				assert int(`1')==`1'
				assert int(`2')==`2'
				assert int(`3')==`3'
				assert int(`4')==`4'
			}
			if _rc!=0 {
				di as err "Non integer cell counts found" 
				exit _rc
			}

		}
		cap assert ( (`1'>=0) & (`2'>=0) & (`3'>=0) & (`4'>=0) )
		if _rc!=0 {
			di as err "Non-positive cell counts found" 
			exit _rc
		}
		if "`cc'"!="" {
			*Ensure Continuity correction is valid
			if "`peto'"!="" {
				di as err "Peto method not valid with continuity correction"
				exit
			}
			*Currently, allows user to define own constant [0,1) to add to all cells
			cap confirm number `cc'
			if _rc!=0 {
				di as err "Invalid continuity correction: specify a constant number eg metan ... , cc(0.166667)"
				exit
			}
			cap assert (`cc'>=0) & (`cc'<1)
			if _rc!=0 {
				di as err "Invalid continuity correction: must be in range [0,1)"
				exit
			}
		}
		else { 
			local cc "0.5" 
		}
		if "`peto'"=="" { 
			local cont "cc(`cc')" 
		}
		if "`peto'"!="" { 
			local or "or" 
		}
		capture {
			assert ( ("`or'"!="")+("`rr'"!="")+("`rd'"!="") <=1 )
			assert ("`fixed'"!="")+("`fixedi'"!="")+("`random'"!="")+ /* 
			*/ ("`randomi'"!="")+("`peto'"!="")+("`wgt'"!="") <=1
			assert "`standard'`hedges'`glass'`cohen'"==""
 		}
		if _rc!=0 {
			di as err "Invalid specifications for combining trials" 
			exit
		}
		*Default is set at pooling RRs. 
		if "`or'"!="" {
			local sumstat "OR"  
		}
		else if "`rd'"!="" {
			local sumstat "RD"  
		}
		else {
			local sumstat "RR"  
		}
		if "`wgt'"!="" { 
			local method "*" 
		}
		else if "`random'`randomi'"!="" {
			local method  "D+L" 
		}
		else if "`peto'"!="" {
			local method  "Peto"
		}
		else if "`fixedi'"!="" {
			local method  "I-V"
		}
		else {
			local method  "M-H" 
		}
		if "`peto'"!="" {
			local callalg "Peto"
		}
		else {
			local callalg "`sumstat'"
		}
		if ("`sumstat'"!="OR" | "`method'"=="D+L") & "`chi2'"!="" {
			di as err "Chi-squared option invalid for `method' `sumstat'"
			exit
		}
		if ("`sumstat'"!="OR" | "`method'"=="D+L" | "`method'"=="Peto" ) & "`breslow'"!="" {
			di as err "Breslow-Day heterogeneity option not available for `method' `sumstat'"
			exit
		}
		if ("`sumstat'"!="OR" & "`sumstat'"!="RR") & "`log'"!="" {
			di as err "Log option not appropriate for `sumstat'"
			exit
	  	}	
		if "`keep'"=="" { 
			cap drop _SS
			qui gen _SS =`1'+`2'+`3'+`4' 
		}
		
		global MA_params = 4

	} /* end of binary variable setup */

} /* end of all non-6 variable set up */


if "`6'"!="" {

	*Input is form N mean SD for continuous data: IV, D+L or user defined weighting allowed
	cap assert "`7'"==""
	if _rc!=0 {
		di as err "Wrong number of variables specified" 
		exit _rc
	}
	if "`integer'"=="" {
		cap assert ((int(`1')==`1') & (int(`4')==`4'))
		if _rc!=0 {
			di as err "Non integer sample sizes found" 
			exit _rc
		}
	}
	cap assert (`1'>0 & `4'>0)
	if _rc!=0 {
		di as err "Non positive sample sizes found" 
		exit _rc
	}
	if "`random'`randomi'"!="" {
		local randomi
		local random "random"
	}
	if "`fixed'`fixedi'"!="" {
		local fixedi
		local fixed "fixed"
	}
	cap{
		assert ("`hedges'"!="")+ ("`glass'"!="")+ ("`cohen'"!="")+ ("`standard'"!="")<=1
		assert ("`random'"!="")+ ("`fixed'"!="") <=1
		assert "`or'`rr'`rd'`peto'`log'`cornfield'`chi2'`breslow'`eform'"==""
	}
	if _rc!=0 {
		di as err "Invalid specifications for combining trials" 
		exit
	}	
	if  "`standard'"!="" {
		local sumstat "WMD"  
		local stand "none"  
	}
	else {
		if "`hedges'"!="" {
			local stand "hedges"
		}
		else if "`glass'"!="" {
			local stand "glass" 
		}
		else {
			local stand "cohen"
		}
		local sumstat "SMD"  
	}
	local stand "standard(`stand')"
	if "`wgt'"!="" {
		local method  "*" 
	}
	else if "`random'"!="" { 
		local method  "D+L" 
	}
	else { 
		local method  "I-V" 
	}
	/* CAN NOW HAVE THIS
	if "`counts'"!="" {
		di in bl "Data option counts not available with continuous data"	
		local counts
	}
	*/
	if  "`cc'"!="" {
		di as err "Continuity correction not available with continuous data"	
		exit 
	}
	local callalg "MD"
	if "`keep'"=="" { 
		cap drop _SS
		qui gen _SS =`1'+`4' 
	}
	global MA_params = 6

} /*end of 6-var set-up*/


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

if "$MA_efficacy" != ""{
	cap assert "`sumstat'" == "RR" | "`sumstat'" == "OR"
	if _rc!=0 {
		di in red "Efficacy statistics only possible with odds ratios and risk ratios"
		exit _rc
	}
}

// RJH- code for second effect estimate 
global MA_method1 ""
global MA_method2 ""	// MAKE BLANK OR MAY BE KEPT FROM PREV


// CODE AND CONDITIONS FOR USER DEFINED "FIRST" ANALYSIS
// FIRST DITCH ANY MACROS WE DON'T WANT

foreach globule in MA_userES MA_userCIlow MA_userCIupp MA_userDesc MA_userESM ///
  MA_userCIlowM MA_userCIuppM MA_userDescM MA_ODC {
	global `globule' = .
}

if "`first'" != ""{
	cap assert real(word("`first'",1)) != . & real(word("`first'",2)) != . ///
		& real(word("`first'",3)) != .
	if _rc != 0{
		di as err "Must supply estimate with confidence intervals: ES CIlow CIupp"
		di as err "with user-defined main analysis"
		exit
	}
	cap assert "`wgt'" != ""
	if _rc != 0{
		di as err "Must supply weight variable with option WGT(varname)"
		di as err "with user-defined main analysis"
		exit
	}
	cap assert "`by'"==""
	if _rc != 0{
		di as err "Cannot use option BY() with user-defined main analysis"
		exit
	}
	cap assert $MA_params == 2 | $MA_params == 3
	if _rc != 0{
		di as err "Variable input must be 2 or 3 parameters, i.e., 
		di as err "{theta se_theta}  or  {ES CIupp CIlow}"
		di as err "with user-defined main analysis"
		exit
	}
	
	global MA_userESM = real(word("`first'",1))
	global MA_userCIlowM = real(word("`first'",2))
	global MA_userCIuppM = real(word("`first'",3))
	if "`eform'" != ""{
		foreach glob in MA_userESM MA_userCIlowM MA_userCIuppM{
			global `glob' = exp($`glob')
		}
	}
	if $MA_userESM < $MA_userCIlowM | $MA_userESM > $MA_userCIuppM{
		di as err "Must supply estimate with confidence interval in the order: ES CIlow CIupp"
		exit
	}
	global MA_userDescM = substr("`first'", (strpos("`first'",word("`first'",4))), ///
		(length("`first'")-strpos("`first'",word("`first'",4))+1) )
	if word("`first'",4) == "" {
		global MA_userDescM = "USER DEFN"
	}
	local method "USER"

}


if "`second'" != ""{

	// METHODS
	// RANDOM- D+L
	// FIXED- M-H	only available with cell counts
	// RANDOMI- D+L
	// FIXEDI- I-V

	if "`second'" == "random" | "`second'" == "randomi" {
		local method_2 "D+L"
	}
	else if "`second'" == "fixed" & "`4'" != "" & "`6'" == ""{
		local method_2 "M-H"
	}
	else if "`second'" == "peto" & "`4'" != "" & "`6'" == ""{
		local method_2 "Peto"
	}
	else if "`second'" == "fixedi" | ( ("`4'" == "" | "`6'" != "") & "`second'" == "fixed" ) ///
	  | ( ("`4'" == "" | "`6'" != "") & "`second'" == "peto" ){
		local method_2 "I-V"
	}
	else{
		cap assert real(word("`second'",1)) != . & real(word("`second'",2)) != . ///
			& real(word("`second'",3)) != .
		if _rc != 0{
			di as err "Choose appropriate method for second analysis, or supply user-"
			di as err "defined estimate with confidence intervals: ES CIlow CIupp"
			exit
		}
		global MA_userES = real(word("`second'",1))
		global MA_userCIlow = real(word("`second'",2))
		global MA_userCIupp = real(word("`second'",3))
		if "`eform'" != ""{
			foreach glob in MA_userES MA_userCIlow MA_userCIupp{
				global `glob' = exp($`glob')
			}
		}
		if $MA_userES < $MA_userCIlow | $MA_userES > $MA_userCIupp{
			di as err "Must supply estimate with confidence interval in the order: ES CIlow CIupp"
		}
		global MA_userDesc = substr("`second'", (strpos("`second'",word("`second'",4))), ///
			(length("`second'")-strpos("`second'",word("`second'",4))+1) )
		if word("`second'",4) == ""{
			global MA_userDesc = "USER DEFN"
		}
		local nosecsub "nosecsub"
		local method_2 "USER"
	}
}

if "`method'" == "USER" & "`method_2'" != "USER" & "`method_2'" != ""{
	di as err "Cannot have user defined analysis as main analysis and standard analysis
	di as err "as second analysis. You can do it the other way round, or have two user"
	di as err "defined analyses, but you can't do this particular thing."
	di as err "Sorry, that's just the way it is."
	exit
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

if "`second'" != ""{
	if "`callalg'" != "metanby"{		// just run through twice

		`callalg' `varlist' `if' `in',  `by' label(`code') `keep' /*
		*/ method(`method_2') `randomi' `cont' `stand' `chi2' `cornfield'  /*
		*/ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat' notable nograph rjhsecond
	
		global MA_second_ES = $S_1			// IF NO BY JUST KEEP ESTIMATES AND STICK IN SOMEWHERE LATER
		global MA_second_SE_ES = $S_2
		global MA_second_LCI = $S_3
		global MA_second_UCI = $S_4
		global MA_second_TAU2 = $S_12
		global MA_second_DF = $S_8

		`callalg' `varlist' `if' `in',  `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont' `stand' `chi2' `cornfield'  /*
		*/ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
			*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'

	}

	if "`callalg'" == "metanby"{		// if by, then send to metanby and sort out there

		`callalg' `varlist' `if' `in',  `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') method2(`method_2') `randomi' `cont' `stand' `chi2' `cornfield'  /*
		*/ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat' `nosecsub'
	}

}

if "`second'" == ""{

	if "`callalg'" != "metanby"{
		`callalg' `varlist' `if' `in',  `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont' `stand' `chi2' `cornfield'  /*
		*/ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'

	}
	if "`callalg'" == "metanby"{
		`callalg' `varlist' `if' `in',  `by' label(`code') `keep' `table' `graph' /*
		*/ method(`method') `randomi' `cont' `stand' `chi2' `cornfield'  /*
		*/ `log' `breslow' `eform' `wgt' `overall' `subgroup' `sgweight' /*
		*/ `sortby' `saving' `xlabel' `xtick' `force' `wt' `stats' `counts' `box' /*
		*/ t1(".`t1title'") t2(".`t2title'") b1(".`b1title'") b2(".`b2title'") lcols("`lcols'") rcols("`rcols'")   /*
		*/ `groupla' `nextcall' `sstat'
	}

}

if $S_8<0 {
	di as err "Insufficient data to perform this meta-analysis" 
}

*return log or eform as appropriate for OR/RR

return scalar ES=$S_1
if "$MA_method2" != ""{
	return scalar ES_2=$MA_second_ES
	return local method_1 "$MA_method1"
	return local method_2 "$MA_method2"
}

if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { 
	return scalar selogES=$S_2 
	if "$MA_method2" != ""{
		return scalar selogES_2=$MA_second_SE_ES 
	}
}

else if ("`sumstat'"=="ES" & "`eform'"!="") { 
	return scalar selogES=$S_2 
	if "$MA_method2" != ""{
		return scalar selogES_2=$MA_second_SE_ES 
	}
}

else { 
	return scalar seES=$S_2
	if "$MA_method2" != ""{
		return scalar seES_2=$MA_second_SE_ES 
	}
}

return scalar ci_low=$S_3
return scalar ci_upp=$S_4
if "$MA_method2" != ""{
	return scalar ci_low_2=$MA_second_LCI
	return scalar ci_upp_2=$MA_second_UCI
}
return scalar z=$S_5
return scalar p_z=$S_6
return scalar i_sq=$S_51		// ADDED I2 IN RETURN
return scalar het=$S_7
return scalar df=$S_8
return scalar p_het=$S_9
return scalar chi2=$S_10
return scalar p_chi2=$S_11
return scalar tau2=$S_12
return local  measure "`log'`sumstat'"
if ("`sumstat'"=="RR" | "`sumstat'"=="OR" | "`sumstat'"=="RD") {
	return scalar tger=$S_13
	return scalar cger=$S_14
}

end




program define OR

version 9.0
#delimit ;
syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
	LABEL(string) SORTBY(passthru) noGRAPH noTABLE CHI2 RANDOMI CC(string)
	METHOD(string) XLAbel(passthru) XTICK(passthru) FORCE CORNFIELD noKEEP 
	SAVING(passthru) noBOX T1(string) T2(string) B1(string) B2(string) LCOLS(string) RCOLS(string) 
	noOVERALL noWT noSTATS LOG BRESLOW COUNTS WGT(varlist numeric max=1) noGROUPLA RJHSECOND] ;

#delimit cr

qui {

tempvar a b c d use zeros r1 r2 c1 c2 t or lnor es v se ill iul ea /*
  */ va weight qhet id rawdata cont_a cont_b cont_c cont_d
tempname ernum erden R S PR PS QR QS W OR lnOR selnOR A EA VA 
tokenize "`varlist'", parse(" ")
if "`log'"!="" { 
	local exp 
}
else { 
	local exp "exp"
}
gen double `a' =`1'
gen double `b' =`2'
gen double `c' =`3'
gen double `d' =`4'
gen double `r1'=`a'+`b'
gen double `r2'=`c'+`d'
gen double `c1'=`a'+`c'
gen double `c2'=`b'+`d'
gen byte `use'=1 `if' `in'
replace `use'=9 if `use'==.
replace `use'=9 if (`r1'==.) | (`r2'==.)
replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 )
replace `use'=2 if (`use'==1) & (`c1'==0 | `c2'==0 )
count if `use'==1
global S_8  =r(N)-1 
if $S_8<0 { 
	exit 
}
if "`counts'"!="" { 
	*Display raw counts 
	gen `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
	  */  string(`c') + "/"+ string(`r2') if `use'!=9
	replace `rawdata'= trim(`rawdata')
	if "`overall'"=="" {	
		sum `a' if (`use'==1 | `use'==2)
		local sum1 = r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2 = r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3 = r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4 =r(sum)
		global MA_ODC "`sum1'/`sum2';`sum3'/`sum4'" 
 	}
}
else {
	gen str1 `rawdata'="."
}

if "`method'"=="D+L" & ($S_8==0) { 
	local method "M-H"
}

*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
sum `a' if `use'<3
scalar `ernum'=r(sum)
sum `r1' if `use'<3
scalar `erden'=r(sum)
global S_13=`ernum'/`erden'
sum `c' if `use'<3
scalar `ernum'=r(sum)
sum `r2' if `use'<3
scalar `erden'=r(sum)
global S_14=`ernum'/`erden'

*Remove "uninformative" studies
replace `a'=. if `use'!=1
replace `b'=. if `use'!=1
replace `c'=. if `use'!=1
replace `d'=. if `use'!=1
replace `r1'=. if `use'!=1
replace `r2'=. if `use'!=1
gen double `t' =`r1'+`r2'

* Chi-squared test for effect
sum `a',meanonly
scalar `A'=r(sum)
gen double `ea'=(`r1'*`c1')/`t' 
gen double `va'=`r1'*`r2'*`c1'*(`b'+`d')/(`t'*`t'*(`t'-1)) 
sum `ea',meanonly
scalar `EA'=r(sum)
sum `va',meanonly
scalar `VA'=r(sum)
global S_10=( (`A'-`EA')^2 )/`VA' /* chi2 effect value */
global S_11=chiprob(1,$S_10)      /*  p(chi2)  */

if "`cornfield'"!="" {
	*Compute Cornfield CI
	gen `ill'=.
	gen `iul'=.
	local j = 1
	tempname i al aj c1j r1j r2j alold
	while `j'<=_N {
		if `use'[`j']==1 {
			scalar `i'  = 0 
			scalar `al' =`a'[`j']
			scalar `aj' =`a'[`j']
			scalar `c1j'=`c1'[`j']
			scalar `r1j'=`r1'[`j']
			scalar `r2j'=`r2'[`j']
			scalar `alold'= .
			while abs(`al'-`alold')>.001 & `al'!=. { 
				scalar `alold' = `al'
				scalar `al'=`aj'-($ZIND)/sqrt( (1/`al') + 1/(`c1j'-`al') + /*
 				  */   1/(`r1j'-`al') +  1/(`r2j'-`c1j'+`al') ) 
				if `al'==. {
					scalar `i'=`i'+1
					scalar `al'=`aj'-`i'
					if (`al'<0 | (`r2j'-`c1j'+`al')<0) {scalar `al'= . }
				}
			}

			if `al'==. { 
				scalar `al'= 0 
			} 
	 		replace `ill'=`log'( `al'*(`r2j'-`c1j'+`al')/((`c1j'-`al')*(`r1j'-`al')) ) in `j'
			scalar `al'= `a'[`j']
			scalar `alold'= . 
			scalar `i'= 0 
			while abs(`al'-`alold')>.001 & `al'!=. {
				scalar `alold'= `al'
				scalar `al'=`aj'+($ZIND)/sqrt( (1/`al')+ 1/(`c1j'-`al') + /*
				 */  1/(`r1j'-`al') +  1/(`r2j'-`c1j'+`al') )
				if `al'==. {
					scalar `i'=`i'+1
					scalar `al'=`aj'+`i'
					if (`al'>`r1j' | `al'>`c1j' ) { 
						scalar `al' = . 
					}
				}
			}
	 
			replace `iul'=`log'( `al'*(`r2j'-`c1j'+`al')/((`c1j'-`al')*(`r1j'-`al')) ) in `j'
		}

		local j=`j'+1

	} // end while

} // end Cornfield


*Adjustment for zero cells in calcn of OR and var(OR)
gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
gen `cont_a'=`cc'
gen `cont_b'=`cc'
gen `cont_c'=`cc'
gen `cont_d'=`cc'
replace `a'=`a'+`cont_a' if `zeros'==1
replace `b'=`b'+`cont_b' if `zeros'==1
replace `c'=`c'+`cont_c' if `zeros'==1
replace `d'=`d'+`cont_d' if `zeros'==1
replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1
replace `t' =`t' +(`cont_a'+`cont_b')+(`cont_c'+`cont_d') if `zeros'==1
gen double `or'  =(`a'*`d')/(`b'*`c')
gen double `lnor'=log(`or') 
gen double `v'   =1/`a' +1/`b' +1/`c' + 1/`d' 
gen double `es'  =`log'(`or') 
gen double `se'  =sqrt(`v')

if "`cornfield'"=="" {
	gen `ill' =`exp'(`lnor'-$ZIND*`se')
	gen `iul' =`exp'(`lnor'+$ZIND*`se')
}

if "`method'"=="M-H" | ( "`method'"=="D+L" & "`randomi'"=="" ) {
	tempname p q r s pr ps qr qs
	gen double `r'   =`a'*`d'/`t'
	gen double `s'   =`b'*`c'/`t'
	sum `r', meanonly
	scalar `R'  =r(sum)
	sum `s', meanonly
	scalar `S'  =r(sum)

	*Calculate pooled MH- OR 
	scalar `OR' =`R'/`S'
	scalar `lnOR'=log(`OR') 

	*Calculate variance/SE of lnOR and weights
	gen double `p'   =(`a'+`d')/`t'
	gen double `q'   =(`b'+`c')/`t'
	gen double `pr'  =`p'*`r' 
	gen double `ps'  =`p'*`s'
	gen double `qr'  =`q'*`r'
	gen double `qs'  =`q'*`s'
	sum `pr', meanonly
	scalar `PR' =r(sum)
	sum `ps', meanonly
	scalar `PS' =r(sum)
	sum `qr', meanonly
	scalar `QR' =r(sum)
	sum `qs', meanonly
	scalar `QS' =r(sum)
	scalar `selnOR'= sqrt( (`PR'/(`R'*`R') + (`PS'+`QR')/(`R'*`S') + /*
	  */ `QS'/(`S'*`S'))/2 )
	gen  `weight'=100*`s'/`S' 

	*Store results in global macros, on log scale if requested
	global S_1  =`log'(`OR')
	global S_2  =`selnOR' 
	global S_3  =`exp'(`lnOR' -$ZOVE*`selnOR')
	global S_4  =`exp'(`lnOR' +$ZOVE*`selnOR')
	global S_5  =abs(`lnOR')/(`selnOR') 
	global S_6  =normprob(-abs($S_5))*2    
	drop `p' `q' `r' `pr' `ps' `qr' `qs' 

	*Calculate heterogeneity
	if "`breslow'"=="" {
		gen double `qhet' =( (`lnor'-`lnOR')^2 )/`v'
		sum `qhet', meanonly
		global S_7 =r(sum)              /*Chi-squared */
		global S_9 =chiprob($S_8,$S_7)  /*p(chi2 het) */
		global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
	}
} /* end M-H method */

if "`wgt'"!="" {
	cap gen `weight'=.
	udw `lnor' `v' , wgt(`wgt') `exp'
	replace `weight'=`wgt'*100/$MA_W
	local udwind "wgt(`wgt')"
 }
else if "`method'"!="M-H" & "`method'"!= "USER"{
	cap gen `weight'=.
	iv `lnor' `v', method(`method') `randomi' `exp'
	replace `weight'=100/( (`v'+$S_12)*($MA_W) )
}

if "`breslow'"!="" {

	*Calculate heterogeneity by Breslow-Day test: need to reset zero cells and margins
	if "`log'"=="" {
		local bexp 
	}
	else {
		local bexp "exp" 
	}

	replace `a'=`a'-`cont_a' if `zeros'==1
	replace `b'=`b'-`cont_b' if `zeros'==1
	replace `c'=`c'-`cont_c' if `zeros'==1
	replace `d'=`d'-`cont_d' if `zeros'==1
	replace `r1'=`r1'-(`cont_a'+`cont_b') if `zeros'==1
	replace `r2'=`r2'-(`cont_c'+`cont_d') if `zeros'==1
	replace `t' =`t' -(`cont_a'+`cont_b')-(`cont_c'+`cont_d') if `zeros'==1

	if abs(`bexp'($S_1) - 1)<0.0001 {
		gen afit = `r1'*`c1'/`t'
		gen bfit = `r1'*`c2'/`t'
		gen cfit = `r2'*`c1'/`t'
		gen dfit = `r2'*`c2'/`t'
	}
	else {
		tempvar sterm cterm root1 root2 afit bfit cfit dfit bresd_q
		tempname qterm
		scalar `qterm' = 1-`bexp'($S_1)
		gen `sterm' = `r2' - `c1' + (`bexp'($S_1))*(`r1'+`c1')
		gen `cterm' = -(`bexp'($S_1))*`c1'*`r1'
		gen `root1' = (-`sterm' + sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
		gen `root2' = (-`sterm' - sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
		gen `afit' = `root1' if `root2'<0
		replace `afit' = `root2' if `root1'<0
		replace `afit' = `root1' if (`root2'>`c1') | (`root2'>`r1') 
		replace `afit' = `root2' if (`root1'>`c1') | (`root1'>`r1') 
		gen `bfit' = `r1' - `afit'
		gen `cfit' = `c1' - `afit'
		gen `dfit' = `r2' - `cfit'
	}

	gen `qhet' = ((`a'-`afit')^2)*((1/`afit')+(1/`bfit')+(1/`cfit')+(1/`dfit'))
	sum `qhet', meanonly
	global S_7 =r(sum)            /*Het. Chi-squared */
	global S_9 =chiprob($S_8,$S_7)    /*p(chi2 het) */
	global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
}

if "`method'" == "USER"{
	forvalues i = 1/15{
		global S_`i' = .
	}
	cap drop `weight'
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
replace `weight'=0 if `weight'==.


}  /* End of "quietly" loop  */    


_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
*/ `table' method(`method') sumstat(OR) `chi2' `xlabel' `xtick' `force' `graph' /*
*/ `box' `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt'  /*
*/ `stats' `counts' `log' `groupla' `udwind' `cornfield' `rjhsecond'

end



program define Peto

version 9.0

#delimit ;
syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
	LABEL(string) ORDER(string) noGRAPH METHOD(string) CHI2 XLAbel(passthru) 
	XTICK(passthru) FORCE noKEEP SAVING(passthru) noBOX noTABLE SORTBY(passthru) T1(string)
	T2(string) B1(string) B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS LOG COUNTS RJHSECOND] ;

#delimit cr

qui {

tempvar a b c d use r1 r2 t ea olesse v lnor or es se /*
 */ ill iul p weight id rawdata
tempname ernum erden OLESSE V SE P lnOR A C R1 R2 

tokenize "`varlist'", parse(" ")      

if "`log'"!="" { 
	local exp 
}
else {
	local exp "exp"
}

gen double `a'  =`1' `if' `in'
gen double `b'  =`2' `if' `in'
gen double `c'  =`3' `if' `in'
gen double `d'  =`4' `if' `in'
gen double `r1'  =`a'+`b'
gen double `r2'  =`c'+`d'
gen byte `use'=1   `if' `in' 
replace `use'=9 if `use'==.
replace `use'=9 if (`r1'==.) | (`r2'==.)
replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 )
replace `use'=2 if (`use'==1) & ((`a'==0 & `c'==0 ) | (`b'==0 & `d'==0))
count if `use'==1
global S_8  =r(N)-1  

if $S_8<0 { 
	exit 
}

if "`counts'"!="" { 
	*Display raw counts 
	gen `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
		*/  string(`c') + "/"+ string(`r2') if `use'!=9
	replace `rawdata'= trim(`rawdata')
	if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1 =r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2 =r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3 =r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4 =r(sum)
		global MA_ODC "`sum1'/`sum2';`sum3'/`sum4'" 
	}
} 

else {
	gen str1 `rawdata'="."
} /* end counts */

*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
sum `a' if `use'<3
scalar `ernum'=r(sum)
sum `r1' if `use'<3
scalar `erden'=r(sum)
global S_13=`ernum'/`erden'
sum `c' if `use'<3
scalar `ernum'=r(sum)
sum `r2' if `use'<3
scalar `erden'=r(sum)
global S_14=`ernum'/`erden'

*Remove "uninformative" studies
replace `a'=. if `use'!=1
replace `b'=. if `use'!=1
replace `c'=. if `use'!=1
replace `d'=. if `use'!=1
replace `r1'=. if `use'!=1
replace `r2'=. if `use'!=1
gen double `t'     =`r1'+`r2'  
gen double `ea'    =`r1'*(`a'+`c')/`t'  
gen double `olesse'=`a'-`ea'
gen double `v'     =`r1'*`r2'*(`a'+`c')*(`b'+`d')/( `t'*`t'*(`t'-1) ) 
gen double `lnor'  =`olesse'/`v'   
gen double `es'    = `exp'(`lnor')
gen double `se'    = 1/(sqrt(`v'))
gen double `ill'   = `exp'(`lnor'-$ZIND*`se')
gen double `iul'   = `exp'(`lnor'+$ZIND*`se')
gen double `p'     =(`olesse')*(`olesse')/`v'
sum `olesse', meanonly
scalar `OLESSE'=r(sum)
sum `v', meanonly
scalar `V' =r(sum)
sum `p', meanonly
scalar `P'    =r(sum)
scalar `lnOR' =`OLESSE'/`V'
global S_1 =`exp'(`lnOR')
global S_2 =1/sqrt(`V')
global S_3 =`exp'(`lnOR'-$ZOVE*($S_2))
global S_4 =`exp'(`lnOR'+$ZOVE*($S_2))
sum `a', meanonly
scalar `A'  =r(sum)
sum `c', meanonly
scalar `C'  =r(sum)
sum `r1', meanonly
scalar `R1' =r(sum)
sum `r2', meanonly
scalar `R2' =r(sum)
global S_10 =(`OLESSE'^2)/`V'  /*Chi-squared effect*/
global S_11 =chiprob(1,$S_10)
global S_5  =abs(`lnOR')/($S_2)
global S_6  =normprob(-abs($S_5))*2

/*Heterogeneity */
global S_7=`P'-$S_10
global S_9 =chiprob($S_8,$S_7) 
global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
gen `weight' =100*`v'/`V' 

if "`method'" == "USER"{
	forvalues i = 1/15{
		global S_`i' = .
	}
	cap drop `weight'
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
replace `weight'=0 if `weight'==.

}  /* End of quietly loop */

_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata' , `keep' `sortby' /*
 */ `table' method(`method') sumstat(OR) `chi2' `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") /*
 */ `rjhsecond' `overall' `wt' `stats' `counts' `log'

end




program define RR
version 9.0
#delimit ;
syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
	LABEL(string) SORTBY(passthru) noGRAPH noTABLE RANDOMI METHOD(string) CC(string)
	XLAbel(passthru) XTICK(passthru) FORCE noKEEP SAVING(passthru) noBOX T1(string)
	T2(string) B1(string) B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS LOG COUNTS RJHSECOND 
	WGT(varlist numeric max=1) ] ;
#delimit cr

qui {

tempvar a b c d use zeros r1 r2 t p r s rr lnrr es v se ill iul q /*
 */ weight id rawdata cont_a cont_b cont_c cont_d
tempname ernum erden P R S RR lnRR vlnRR 

tokenize "`varlist'", parse(" ")

if "`log'"!="" { 
	local exp 
}
else { 
	local exp "exp"
}

gen double `a'  =`1'
gen double `b'  =`2'
gen double `c'  =`3'
gen double `d'  =`4'
gen double `r1' =`a'+`b'
gen double `r2' =`c'+`d'
gen byte `use'=1   `if' `in' 
replace `use'=9 if `use'==.
replace `use'=9 if (`r1'==.) | (`r2'==.)
replace `use'=2 if (`use'==1) & (`r1'==0 | `r2'==0 ) 
replace `use'=2 if (`use'==1) & ((`a'==0 & `c'==0 ) | (`b'==0 & `d'==0))
count if `use'==1
global S_8  =r(N)-1  
if $S_8<0 { 
	exit 
}

if "`counts'"!="" { 
	*Display raw counts 
	gen `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
		*/  string(`c') + "/"+ string(`r2') if `use'!=9
	replace `rawdata'= trim(`rawdata')
	if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1 =r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2 =r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3 =r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4 =r(sum)
		global MA_ODC "`sum1'/`sum2';`sum3'/`sum4'" 
	 }
} 

else {
	gen str1 `rawdata'="."
} /* end counts */

if "`method'"=="D+L" & ($S_8==0) { 
	local method "M-H"
}

*Get average event rate for each group (before any 0.5 adjustments or excluding 0-0 studies) 
sum `a' if `use'<3
scalar `ernum'=r(sum)
sum `r1' if `use'<3
scalar `erden'=r(sum)
global S_13=`ernum'/`erden'
sum `c' if `use'<3
scalar `ernum'=r(sum)
sum `r2' if `use'<3
scalar `erden'=r(sum)
global S_14=`ernum'/`erden'

*Adjustment for zero cells in calcn of OR and var(OR)
gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
gen `cont_a'=`cc'
gen `cont_b'=`cc'
gen `cont_c'=`cc'
gen `cont_d'=`cc'
replace `a'=`a'+`cont_a' if `zeros'==1
replace `b'=`b'+`cont_b' if `zeros'==1
replace `c'=`c'+`cont_c' if `zeros'==1
replace `d'=`d'+`cont_d' if `zeros'==1
replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1

*Remove "uninformative" studies
replace `a'=. if `use'!=1
replace `b'=. if `use'!=1
replace `c'=. if `use'!=1
replace `d'=. if `use'!=1
replace `r1'=. if `use'!=1
replace `r2'=. if `use'!=1

gen double `t'   =`r1'+`r2'
gen double `r'   =`a'*`r2'/`t'
gen double `s'   =`c'*`r1'/`t'
gen double `rr'  =`r'/`s'
gen double `lnrr'=log(`rr') 
gen double `es'  =`log'(`rr')
gen double `v'   =1/`a' +1/`c' - 1/`r1' - 1/`r2' 
gen double `se'  =sqrt(`v')
gen double `ill' =`exp'(`lnrr'-$ZIND*`se')
gen double `iul' =`exp'(`lnrr'+$ZIND*`se')

if "`method'"=="M-H" | "`method'"=="D+L" & "`randomi'"=="" {
	*MH method for pooling/calculating heterogeneity in DL method
	gen double `p'  =`r1'*`r2'*(`a'+`c')/(`t'*`t') - `a'*`c'/`t'
	sum `p', meanonly
	scalar `P'  =r(sum)
	sum `r', meanonly
	scalar `R'  =r(sum)
	sum `s', meanonly
	scalar `S'  =r(sum)
	scalar `RR'=`R'/`S'
	scalar `lnRR'=log(`RR')

	*  Heterogeneity
	gen double `q'   =( (`lnrr'-`lnRR')^2 )/`v'
	sum `q', meanonly
	global S_7 =r(sum)
	global S_9 =chiprob($S_8,$S_7) 
	global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
	gen `weight'=100*`s'/`S' 
	global S_1 =`log'(`RR')
	global S_2 =sqrt( `P'/(`R'*`S') )
	global S_3 =`exp'(`lnRR' -$ZOVE*($S_2)) 
	global S_4 =`exp'(`lnRR' +$ZOVE*($S_2))
	global S_5 =abs(`lnRR')/($S_2)      
	global S_6 =normprob(-abs($S_5))*2
}

if "`wgt'"!="" {
	cap gen `weight'=.
	udw `lnrr' `v' , wgt(`wgt') `exp'
	replace `weight'=`wgt'*100/$MA_W
	local udwind "wgt(`wgt')"
}

else if "`method'"!="M-H" & "`method'"!="USER"{
	cap gen `weight'=.
	iv `lnrr' `v', method(`method') `randomi' `exp'
	replace `weight'=100/( (`v'+$S_12)*($MA_W) )
}


if "`method'" == "USER"{
	forvalues i = 1/15{
		global S_`i' = .
	}
	cap drop `weight'
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
replace `weight'=0 if `weight'==.




}  /* End of "quietly" loop  */ 


_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata' , `keep' `sortby' /*
 */ `table' method(`method') sumstat(RR) `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' /*
 */  `stats' `counts' `log' `udwind' `rjhsecond'

end



program define RD

version 9.0

#delimit ;
syntax varlist(min=4 max=4 default=none numeric) [if] [in] [,
	LABEL(string) SORTBY(passthru) noGRAPH noTABLE RANDOMI METHOD(string) CC(string) noKEEP 
	SAVING(passthru) XLAbel(passthru) XTICK(passthru) noBOX FORCE T1(string) T2(string)
	B1(string) B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS COUNTS WGT(varlist numeric max=1) RJHSECOND ] ;
#delimit cr

qui {

tempvar a b c d use zeros r1 r2 t rd weight rdnum v se ill iul vnum q /*
	*/ id w rawdata cont_a cont_b cont_c cont_d
tempname ernum erden RDNUM VNUM W 

tokenize "`varlist'", parse(" ")      
gen double `a'  =`1'
gen double `b'  =`2'
gen double `c'  =`3'
gen double `d'  =`4'
gen double `r1'  =`a'+`b'
gen double `r2'  =`c'+`d'
gen byte `use'=1   `if' `in' 
replace `use'=9 if `use'==.
replace `use'=9 if (`r1'==.) | (`r2'==.)
replace `use'=2 if ( `use'==1) & (`r1'==0 | `r2'==0 )
count if `use'==1
global S_8  =r(N)-1  

if $S_8<0 { 
	exit 
}

if "`counts'"!="" { 
	*Display raw counts 
	gen `rawdata'= string(`a') + "/" + string(`r1') +";" + /*
		*/  string(`c') + "/"+ string(`r2') if `use'!=9
	replace `rawdata'= trim(`rawdata')

	if "`overall'"=="" {	
		sum `a'  if (`use'==1 | `use'==2)
		local sum1 =r(sum)
		sum `r1' if (`use'==1 | `use'==2)
		local sum2 =r(sum)
		sum `c'  if (`use'==1 | `use'==2)
		local sum3 =r(sum)
		sum `r2' if (`use'==1 | `use'==2)
		local sum4 =r(sum)
		global MA_ODC "`sum1'/`sum2';`sum3'/`sum4'" 
	}
} 

else {
	gen str1 `rawdata'="."
} /* end counts */

if "`method'"=="D+L" & ($S_8==0) { 
	local method "M-H"
}

*Get average event rate for each group (before any cont adjustments or excluding 0-0 studies) 
sum `a' if `use'<3
scalar `ernum'=r(sum)
sum `r1' if `use'<3
scalar `erden'=r(sum)
global S_13=`ernum'/`erden'
sum `c' if `use'<3
scalar `ernum'=r(sum)
sum `r2' if `use'<3
scalar `erden'=r(sum)
global S_14=`ernum'/`erden'

*Remove "uninformative" studies
replace `a'=. if `use'!=1
replace `b'=. if `use'!=1
replace `c'=. if `use'!=1
replace `d'=. if `use'!=1
replace `r1'=. if `use'!=1
replace `r2'=. if `use'!=1
gen double `t'   =`r1'+`r2'
gen double `rd'  =`a'/`r1' - `c'/`r2'
gen `weight'=`r1'*`r2'/`t'
sum `weight',meanonly
scalar `W'  =r(sum)
gen double `rdnum'=( (`a'*`r2')-(`c'*`r1') )/`t'

*  Zero cell adjustments, placed here to ensure 0/n1 v 0/n2 really IS RD=0
*Adjustment for zero cells in calcn of OR and var(OR)

gen `zeros'=1 if `use'==1 & (`a'==0 | `b'==0 | `c'==0 | `d'==0 )
gen `cont_a'=`cc'
gen `cont_b'=`cc'
gen `cont_c'=`cc'
gen `cont_d'=`cc'
replace `a'=`a'+`cont_a' if `zeros'==1
replace `b'=`b'+`cont_b' if `zeros'==1
replace `c'=`c'+`cont_c' if `zeros'==1
replace `d'=`d'+`cont_d' if `zeros'==1
replace `r1'=`r1'+(`cont_a'+`cont_b') if `zeros'==1
replace `r2'=`r2'+(`cont_c'+`cont_d') if `zeros'==1
replace `t' =`t' +(`cont_a'+`cont_b')+(`cont_c'+`cont_d') if `zeros'==1

gen double `v'   =`a'*`b'/(`r1'^3)+`c'*`d'/(`r2'^3)
gen double `se'  =sqrt(`v')
gen double `ill' = `rd'-$ZIND*`se'
gen double `iul' = `rd'+$ZIND*`se'

if "`method'"=="M-H" | ("`method'"=="D+L" & "`randomi'"=="" ) {
	sum `rdnum',meanonly
	scalar `RDNUM'=r(sum)
	global S_1 =`RDNUM'/`W'
	gen double `q' =( (`rd'-$S_1)^2 )/`v'
	sum `q', meanonly
	global S_7 =r(sum)
	global S_9 =chiprob($S_8,$S_7)
	global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )
	gen double `vnum'=( (`a'*`b'*(`r2'^3) )+(`c'*`d'*(`r1'^3)))  /*
		*/ /(`r1'*`r2'*`t'*`t')
	sum `vnum',meanonly
	scalar `VNUM'=r(sum)
	global S_2 =sqrt( `VNUM'/(`W'*`W') )
	replace `weight'=`weight'*100/`W'
	global S_3 =$S_1 -$ZOVE*($S_2)
	global S_4 =$S_1 +$ZOVE*($S_2)
	global S_5 =abs($S_1)/($S_2)
	global S_6 =normprob(-abs($S_5))*2
}

if "`wgt'"!="" {
	udw `rd' `v' ,wgt(`wgt')
	replace `weight'=`wgt'*100/$MA_W
	local udwind "wgt(`wgt')"
}
else if "`method'"!="M-H" & "`method'"!= "USER" {
	iv `rd' `v', method(`method') `randomi'
	replace `weight'=100/( (`v'+$S_12)*($MA_W) )
}

if "`method'" == "USER"{
	forvalues i = 1/15{
		global S_`i' = .
	}
	cap drop `weight'
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
replace `weight'=0 if `weight'==.

}  /* End of "quietly" loop  */    


_disptab `rd' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep'  `sortby' /*
 */ `table' method(`method') sumstat(RD) `xlabel' `xtick'`force' `graph' `box' /* 
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") /*
 */ `rjhsecond' `overall' `wt' `stats' `counts' `udwind'

end




program define MD

version 9.0

#delimit ;

syntax varlist(min=6 max=6 default=none numeric) [if] [in] [,
	LABEL(string) SORTBY(passthru) noGRAPH METHOD(string) noKEEP SAVING(passthru) noBOX
	noTABLE STANDARD(string) XLAbel(passthru) XTICK(passthru) FORCE T1(string) T2(string)
	B1(string) B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS COUNTS WGT(string) RJHSECOND ] ;

#delimit cr

qui {

tempvar n1 x1 sd1 n2 x2 sd2 use n s md v se ill iul weight id qhet rawdata
tokenize "`varlist'", parse(" ")      
gen double `n1' =`1' 
gen double `x1' =`2'
gen double `sd1'=`3'
gen double `n2' =`4'
gen double `x2' =`5'
gen double `sd2'=`6'

gen `use'=1 `if' `in' 

replace `use'=9 if `use'==.
replace `use'=9 if (`n1'==.) | (`n2'==.) | (`x1'==.) | (`x2'==.) | /*
	*/  (`sd1'==.) | (`sd2'==.)
replace `use'=2 if ( `use'==1) & (`n1' <2  | `n2' <2  )
replace `use'=2 if ( `use'==1) & (`sd1'<=0 | `sd2'<=0 )
count if `use'==1
global S_8  =r(N)-1  

if $S_8<0 { 
	exit 
}

if "`counts'"!="" { 
	*Display raw counts instead of default 
	gen `rawdata'= string(`n1') + ", " + string(`x1',"%7.3g") +" (" + string(`sd1',"%7.3g") +  /*
 		*/ ") ; " + string(`n2') + ", " + string(`x2',"%7.3g") +" (" + string(`sd2',"%7.3g") +") "  
	replace `rawdata'= trim(`rawdata')
	qui summ `n1'
	local sum1 = r(sum)
	qui summ `n2'
	local sum2 = r(sum)
	global MA_ODC = string(`sum1') + "; " + string(`sum2')
}
else {
	gen str1 `rawdata'="."
} /* end counts */

if "`method'"=="D+L" & ($S_8==0) { 
	local method "I-V"
}

replace `n1' =. if `use'!=1
replace `x1' =. if `use'!=1
replace `sd1'=. if `use'!=1
replace `n2' =. if `use'!=1
replace `x2' =. if `use'!=1
replace `sd2'=. if `use'!=1
gen double `n'  =`n1'+`n2'

if "`standard'"=="none" {
	gen double `md' =`x1'-`x2'
	gen double `v'=(`sd1'^2)/`n1' + (`sd2'^2)/`n2'
	local prefix "W"
}
else {
	gen double `s'=sqrt( ((`n1'-1)*(`sd1'^2)+(`n2'-1)*(`sd2'^2) )/(`n'-2) )
	if "`standard'"=="cohen" {
		gen double `md' = (`x1'-`x2')/`s' 
		gen double `v'= ( `n'/(`n1'*`n2') )+( (`md'^2)/(2*(`n'-2)) )
	}
	else if "`standard'"=="hedges" {
		gen double `md' =( (`x1'-`x2')/`s' )*( 1-  3/(4*`n'-9) )
		gen double `v'=( `n'/(`n1'*`n2') ) + ( (`md'^2)/(2*(`n'-3.94)) )
	}
	else if "`standard'"=="glass" {
		gen double `md' =  (`x1'-`x2')/`sd2' 
		gen double `v'= (`n'/(`n1'*`n2')) + ( (`md'^2)/(2*(`n2'-1)) )
	}
	local prefix "S"
}

gen double `se'  =sqrt(`v')
gen double `ill'  =`md'-$ZIND*`se' 
gen double `iul'  =`md'+$ZIND*`se' 
if "`wgt'"!="" {
	udw `md' `v' , wgt(`wgt')
	gen `weight'=`wgt'*100/$MA_W
	local udwind "wgt(`wgt')"
}

else {
	iv `md' `v', method(`method') randomi 
	gen `weight'=100/( (`v'+$S_12)*($MA_W) )
}


if "`method'" == "USER"{
	forvalues i = 1/15{
		global S_`i' = .
	}
	cap drop `weight'
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
replace `weight'=0 if `weight'==.

}  /* End of quietly loop  */


_disptab `md' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
 */ `table' method(`method') sumstat(`prefix'MD) `xlabel' `xtick' `force' `graph'  /*
 */ `box' `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") /*
 */ `rjhsecond' `overall' `wt' `stats' `udwind' `counts'

end



program define iv_init

version 9.0

#delimit ;

syntax varlist(min=2 max=3 default=none numeric) [if] [in] [,
	LABEL(string) SORTBY(passthru) noGRAPH METHOD(string) noKEEP SAVING(passthru)  noBOX
	noTABLE XLAbel(passthru) XTICK(passthru) FORCE T1(string) T2(string) B1(string)
	B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS EFORM WGT(string) RJHSECOND ] ;

#delimit cr

qui {

tempvar es se use v ill iul weight id rawdata
tokenize "`varlist'", parse(" ")      
gen `es'=`1'
if "`eform'"!="" { 
	local exp "exp" 
}

if "`3'"=="" {
	gen double `se'=`2'
	gen double `ill'  =`exp'(`es'-$ZIND*`se' )
	gen double `iul'  =`exp'(`es'+$ZIND*`se' )
}

if "`3'"!="" {
	gen double `se'=(`3'-`2')/($ZIND*2)
	gen double `ill'  =`exp'(`2')
	gen double `iul'  =`exp'(`3')
	local var3 "var3" 
}

gen double `use'=1 `if' `in' 
replace `use'=9 if `use'==.
replace `use'=9 if (`es'==. | `se'==.)
replace `use'=2 if (`use'==1 & `se'<=0 )
count if `use'==1
global S_8  =r(N)-1  

if $S_8<0 { 
	exit 
}

if "`method'"=="D+L" & ($S_8==0) { 
	local method "I-V"
}

replace `es' =. if `use'!=1
replace `se' =. if `use'!=1
gen double `v'=(`se')^2
gen str1 `rawdata'="."

if "`wgt'"!=""{ 
	cap drop `weight'
	gen `weight' = `wgt' if `use'==1
	udw `es' `v', wgt(`weight') `exp' `rjhsecond'
	replace `weight'=100*`wgt'/($MA_W) 
	local udwind "wgt(`wgt')"
}
else {
	iv  `es' `v', method(`method') `exp' randomi `rjhsecond'
	*NB randomi necc to calculate heterogeneity
	gen `weight'=100/( (`v'+$S_12)*($MA_W) )
}


replace `weight'=0 if `weight'==.
replace `es'=`exp'(`es')

}  /* End of quietly loop  */

_disptab `es' `se' `ill' `iul' `weight' `use' `label' `rawdata', `keep' `sortby' /*
 */`table' method(`method') sumstat(ES) `xlabel' `xtick' `force' `graph' `box' /*
 */ `saving' t1("`t1'") t2("`t2'") b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `eform' /*
 */ `var3' `udwind' `rjhsecond'

end




program define iv

version 9.0

#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,
	METHOD(string) RANDOMI EXP RJHSECOND ] ;

#delimit cr

tempvar stat v w qhet w2 wnew e_w e_wnew 
tempname W W2 C T2 E_W E_WNEW OV vOV QHET

tokenize "`varlist'", parse(" ")
gen `stat'=`1'
gen `v'   =`2'
gen `w'   =1/`v'
sum `w',meanonly
scalar `W'=r(sum)
global S_12=0
global MA_W =`W'

if ("`randomi'"=="" & "`method'"=="D+L") { 
	scalar `QHET'=$S_7 
}
else {
	gen `e_w' =`stat'*`w'
	sum `e_w',meanonly
	scalar `E_W'=r(sum)
	scalar `OV' =`E_W'/`W'

	*  Heterogeneity
	gen `qhet' =( (`stat'-`OV')^2 )/`v'
	sum `qhet', meanonly
	scalar `QHET'=r(sum)
	global S_7=`QHET'
}

if "`method'"=="D+L" {
	gen `w2'  =`w'*`w'
	sum `w2',meanonly
	scalar `W2' =r(sum)
	scalar `C'  =`W' - `W2'/`W'
	global S_12 =max(0, ((`QHET'-$S_8)/`C') )
	global RJH_TAU2 = $S_12
	gen `wnew'  =1/(`v'+$S_12)
	gen `e_wnew'=`stat'*`wnew'
	sum `wnew',meanonly
	global MA_W =r(sum)
	sum `e_wnew',meanonly
	scalar `E_WNEW'=r(sum)
	scalar `OV' =`E_WNEW'/$MA_W
}


global S_1 =`exp'(`OV')
global S_2 =sqrt( 1/$MA_W )
global S_3 =`exp'(`OV' -$ZOVE*($S_2))
global S_4 =`exp'(`OV' +$ZOVE*($S_2))
global S_5 =abs(`OV')/($S_2) 
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


program define udw

* user defined weights to combine trials

version 9.0
#delimit ;

syntax varlist(min=2 max=2 default=none numeric) [if] [in] [,
	METHOD(string)  EXP   WGT(varlist numeric max=1) RJHSECOND ] ;

#delimit cr
tempvar stat v w e_w varcomp qhet  
tempname W E_W OV W2 Vnum V QHET

tokenize "`varlist'", parse(" ")
gen `stat'=`1' 
gen `v'   =`2'
gen `w'   =`wgt' if `stat'!=.
sum `w',meanonly
scalar `W'=r(sum)
if `W'==0 {
	di as err "Usable weights sum to zero: the table below will probably be nonsense"
}

global MA_W =`W'

*eff size = SIGMA(wi * thetai)/SIGMA(wi)
gen `e_w' =`stat'*`w'
sum `e_w',meanonly
scalar `E_W'=r(sum)
scalar `OV' =`E_W'/`W'

*VAR = SIGMA{wi^2 * var(thetai) }/[SIGMA(wi)]^2
sum `w',meanonly
scalar `W2'=(r(sum))^2
gen `varcomp' =	`w'*`w'*`v'
sum `varcomp' ,meanonly
scalar `Vnum'=r(sum)
scalar `V'  =`Vnum'/`W2' 

*Heterogeneity (need to use variance weights here - BUT use ES=wgt*es/wgt, not necc var wts)
gen `qhet' =( (`stat'-`OV')^2 )/`v'
sum `qhet', meanonly
scalar `QHET'=r(sum)

global S_1 =`exp'(`OV')
global S_2 =sqrt( `V' )
global S_3 =`exp'(`OV' -$ZOVE*($S_2))
global S_4 =`exp'(`OV' +$ZOVE*($S_2))
global S_5 =abs(`OV')/($S_2) 
global S_6 =normprob(-abs($S_5))*2
global S_7=`QHET'
global S_9 =chiprob($S_8,$S_7)
global S_51 =max(0, ( 100*($S_7-$S_8))/($S_7) )

if "$MA_method1" == "USER"{
	cap drop `weight'
	tempvar weight
	gen `weight'=.
	forvalues i = 1/15{
		global S_`i' = .
	}
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
	global S_8 = 0
}

end


program define _disptab

version 9.0

#delimit ;

syntax varlist(min=7 max=8 default=none) [if] [in] [,
	XLAbel(passthru) XTICK(passthru) FORCE noKEEP SAVING(passthru)  noBOX noTABLE 
	noGRAPH METHOD(string) SUMSTAT(string) CHI2 T1(string) T2(string) B1(string) 
	B2(string) LCOLS(string) RCOLS(string) noOVERALL noWT noSTATS COUNTS LOG EFORM noGROUPLA SORTBY(string) 
	WGT(string) VAR3 CORNFIELD /* RJH */ RJHSECOND ] ;

#delimit cr

tempvar effect se lci uci weight use label tlabel rawdata id tau2 df
tokenize "`varlist'", parse(" ")

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
gen `rawdata' = `8' 
gen `tau2' = .
gen `df' = .

if "`keep'"=="" {

	if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { 
		local ln "log"
	}
	else { 
		local ln  
	}

	cap drop _ES 
	cap drop _seES
	cap drop _selogES 

	if "`sumstat'"!="ES" {
		replace _SS  =. if `use'!=1
		label var _SS "Sample size"
		gen _ES  =`effect'
		label var _ES "`log'`sumstat'"
		gen _se`ln'ES=`se'
		label var _se`ln'ES "se(`ln'`log'`sumstat')"
	}

	cap drop _LCI
	cap drop _UCI
	cap drop _WT
	gen _LCI =`lci'
	label var _LCI "Lower CI (`log'`sumstat')"
	gen _UCI =`uci'
	label var _UCI "Upper CI (`log'`sumstat')"
	gen _WT=`weight'
	label var _WT "`method' weight"

} /* end if-keep */

preserve

if "`overall'"=="" & "`rjhsecond'" == ""{		// only do this on main run

	**If overall figure requested, add an extra line to contain overall stats

	local nobs1=_N+1
	set obs `nobs1'
	replace `weight'=100 in `nobs1' 
	replace `effect'= ($S_1) in `nobs1'
	replace `lci'=($S_3) in `nobs1'
	replace `uci'=($S_4) in `nobs1'
	replace `use'=5 in `nobs1'
	replace `tau2' = $S_12 in `nobs1'
	replace `df' = $S_8 in `nobs1'

	if "`counts'"!="" {
		replace `rawdata'="$MA_ODC" in `nobs1' 
	}
	local i2=max(0, (100*($S_7-$S_8)/($S_7)) )
	local hetp=$S_9
	replace `label' = "Overall  (I-squared = " + string(`i2', "%5.1f")+ "%, p = " + ///
		string(`hetp', "%5.3f") + ")" in `nobs1'

	* RJH code for second method
	if "$MA_method2" != "" {
		local nobs1=_N+1
		set obs `nobs1'
		replace `weight'=100 in `nobs1' 
		replace `effect'= $MA_second_ES in `nobs1'
		replace `lci'=$MA_second_LCI in `nobs1'
		replace `uci'=$MA_second_UCI in `nobs1'
		replace `use'=17 in `nobs1'
		if "$MA_second_TAU2" != ""{
			replace `tau2' = $MA_second_TAU2 in `nobs1'
			replace `df' = $MA_second_DF in `nobs1'
		}
		replace `label' = "Overall" in `nobs1'
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

	di _n in gr _col(12) "Study" _col(22) "|" _col(24) "`log'" _col(28) "`sumstat'" /*
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
				*overall
				// RJH
				if `use'[`i'] == 5 {
					local dispM1 = "$MA_method1"
					if "$MA_method1" == "USER"{
						local dispM1 = "$MA_userDescM"
					}
					di in gr _dup(21) "-" "+" _dup(11) "-"  "`insert'" _dup(20) "-" _n /*
						*/   "`dispM1' pooled `log'`sumstat'" _cont
				}
				if `use'[`i'] == 17{	// SECOND EST
					local dispM2 = "$MA_method2"
					if "$MA_method2" == "USER"{
						local dispM2 = "$MA_userDesc"
					}
			 		di in gr "`dispM2' pooled `log'`sumstat'" _cont
				}
			} // end else

			di in gr _col(22) "|" in ye  %7.3f  `effect'[`i'] /* 
				 */ _col(35) %7.3f `lci'[`i'] "   " %7.3f `uci'[`i'] _col(60)  %6.2f `ww' 
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
		if  ( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & "`log'"=="") {
			local h0=1
		}
		else if ("`sumstat'"=="ES" & "`eform'"!="") {
			local h0=1
		}
	   	else {
			local h0=0
		}

		di _n in gr "  Heterogeneity chi-squared = " in ye %6.2f $S_7 in gr /*
			*/  " (d.f. = " in ye $S_8 in gr  ") p = "   in ye %4.3f $S_9
		local i2=max(0, (100*($S_7-$S_8)/($S_7)) )
		if $S_8<1 { 
			local i2=. 
		}
	  	di in gr "  I-squared (variation in `sumstat' attributable to " /*
			*/  "heterogeneity) =" in ye %6.1f `i2' "%"

		if "`method'"=="D+L" { 
			di in gr "  Estimate of between-study variance " /*
				*/ "Tau-squared = " in ye %7.4f $S_12 
		}

		if "`chi2'"!="" {  
			di _n in gr "  Test of OR=1: chi-squared = " in ye %4.2f /*
				*/  $S_10 in gr  " (d.f. = 1) p = "  in ye %4.3f $S_11 
		}
		else { 
			di _n in gr "  Test of `log'`sumstat'=`h0' : z= " in ye %6.2f $S_5  /*
				*/  in gr  " p = "  in ye %4.3f $S_6 
		}
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


	_dispgby `effect' `lci' `uci' `weight' `use' `label' `rawdata' `tau2' `df', `log'    /*
	  */  `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'") /*
	  */ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `counts' `eform' /*
	  */ `groupla' `cornfield'

}


restore

end


program define metanby

version 9.0

#delimit ;

syntax varlist(min=2 max=6 default=none numeric) [if] [in] [, BY(string)
	LABEL(string) SORTBY(string) noGRAPH noTABLE noKEEP NEXTCALL(string) 
	METHOD(string) METHOD2(string) SUMSTAT(string) RANDOMI WGT(passthru) noSUBGROUP SGWEIGHT
	CORNFIELD CHI2 CC(passthru) STANDARD(passthru) noOVERALL LOG EFORM BRESLOW 
	XLAbel(passthru) XTICK(passthru) FORCE SAVING(passthru) T1(string) T2(string) 
	B1(string) B2(string) LCOLS(string) RCOLS(string) noWT noSTATS COUNTS noBOX noGROUPLA NOSECSUB	] ;

#delimit cr

if ("`subgroup'"!="" & "`overall'`sgweight'"!="") { 
	local wt "nowt" 
}

tempvar use by2 newby r1 r2 rawdata effect se lci uci weight wtdisp  /*
	*/ hetc hetdf hetp i2 tau2 df tsig psig expand tlabel id

qui {

gen `use'=1 `if' `in'
replace `use'=9 if `use'==.

gen str1 `rawdata'="."

tokenize `varlist'

if ("`nextcall'"=="RR" | "`nextcall'"=="OR" | "`nextcall'"=="RD" |"`nextcall'"=="Peto" ) {

	*Sort out r1 & r2 for 2x2 table: might be needed in counts and mh/use
	gen `r1' = `1'+`2'
	gen `r2' = `3'+`4'
	replace `use'=2 if ((`use'==1) & (`r1'==0 | `r2'==0 ))
	replace `use'=2 if ((`use'==1) & ((`1'+`3'==0) | (`2'+`4'==0) ) & "`nextcall'"!="RD")
	replace `use'=9 if (`r1'==.) | (`r2'==.)

	if "`counts'"!="" { 
		*create new variable with count data (if requested)
		replace `rawdata'= trim( string(`1') + "/" + string(`r1') +";" + /*
			*/  string(`3') + "/"+ string(`r2') ) if `use'!=9
 	}

}

if "`nextcall'"=="MD" {

	*Sort out n1 & n2 
	replace `use'=9 if (`1'==.) | (`2'==.) | (`3'==.) | (`4'==.) | (`5'==.) | (`6'==.)
	replace `use'=2 if ( `use'==1) & (`1' <2 | `4' <2  )
	replace `use'=2 if ( `use'==1) & (`3'<=0 | `6'<=0 )	   

	if "`counts'"!="" { 
		replace `rawdata'= string(`1') + ", " + string(`2',"%7.3g") +" (" + string(`3',"%7.3g") +  /*
	 		*/ ") ; " + string(`4') + ", " + string(`5',"%7.3g") +" (" + string(`6',"%7.3g") +") "  
		replace `rawdata'= trim(`rawdata') if `use' != 9
	}
}

if "`nextcall'"=="iv_init" {
	replace `use'=9 if (`1'==. | `2'==.)
	if "`3'"=="" {
		replace `use'=2 if (`use'==1 & `2'<=0 )
	}
	else {
		replace `use'=9 if (`3'==.)
		replace `use'=2 if ( `2'>`1' | `3'<`1' | `3'<`2')
	}
}

if  (("`sumstat'"=="OR" | "`sumstat'"=="RR") & "`log'"=="" ) {
	local h0=1
}
else if ("`sumstat'"=="ES" & "`eform'"!="") {
	local h0=1
}
else {
	local h0=0
}


if "`eform'"!="" { 
	local exp "exp" 
}


*RJH- second estimate

if "`method2'" != ""{

	  `nextcall' `varlist' if `use'==1, nograph notable method(`method2') `randomi' /*
        	*/ label(`label') `wgt' `cornfield' `chi2' `cc' `standard' `log' `eform' `breslow' rjhsecond

	  global MA_second_ES = $S_1			// KEEP ESTIMATES AND STICK IN SOMEWHERE LATER
	  global MA_second_SE_ES = $S_2
	  global MA_second_LCI = $S_3
	  global MA_second_UCI = $S_4
	  global MA_second_TAU2 = $S_12
	  global MA_second_DF = $S_8

}

*Get the individual trial stats 
`nextcall' `varlist' if `use'==1, nograph notable method(`method') `randomi' /*	
*/ label(`label') `wgt' `cornfield' `chi2' `cc' `standard' `log' `eform' `breslow' 

if $S_8<0 {
	*no trials - bomb out
	exit
}

local nostud=$S_8


*need to calculate from variable itself if only 2 variables (ES, SE(ES) syntax used)
if "`sumstat'"=="ES" { 
	gen `effect'=`exp'(`1')
	if "`3'"=="" {
		gen `se'=`2'
	}
	else {
		gen `se'=.
		local var3 "var3"  
	}
}
else { 
	gen `effect'=_ES 
	if `h0'<0.01 { 
		gen `se'=_seES 
	}
	else { 
		gen `se'=_selogES 
	}
}

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

*Convert "by" variable to string
* modified July 2008- keeps original order if by variable is numeric (was ignored before)	
* 2009 05 11 - put preserve here a bit earlier as below modifies the actual variable!

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

*Keep tger and cger here (otherwise it ends up in last subgroup only)
if ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="RD"  ) {
	local tger=$S_13
	local cger=$S_14
}

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
	replace `effect'= ($S_1) in `nobs1'
	replace `lci'=($S_3) in `nobs1'
	replace `uci'=($S_4) in `nobs1'
	*RJH plus another line if second estimate
	if "`method2'" != ""{
		local nobs2=_N+1
		set obs `nobs2'
		replace `use'=17 in `nobs2'
		replace `newby'=`ngroups'+1 in `nobs2'
		replace `effect'= ($MA_second_ES) in `nobs2'
		replace `lci'=($MA_second_LCI) in `nobs2'
		replace `uci'=($MA_second_UCI) in `nobs2'
		if "`method2'" == "D+L"{
			replace `tau2' = $MA_second_TAU2 in `nobs2'
			replace `hetdf' = $MA_second_DF in `nobs2'
		}
	}   

	*Put cell counts in subtotal row
	if ("`counts'"!="") { 
		if "`nextcall'"!="MD"{
			*put up overall binary count data
			sum `1'  if (`use'==1 | `use'==2)
			local sum1 =r(sum)
			sum `r1' if (`use'==1 | `use'==2)
			local sum2 =r(sum)
			sum `3'  if (`use'==1 | `use'==2)
			local sum3 =r(sum)
			sum `r2' if (`use'==1 | `use'==2)
			local sum4 =r(sum)
			replace `rawdata'= "`sum1'/`sum2';`sum3'/`sum4'" in `nobs1'
		}
		if "`nextcall'"=="MD" {
			sum `1'  if (`use'==1 | `use'==2)
			local sum1 =r(sum)
			sum `4' if (`use'==1 | `use'==2)
			local sum2 =r(sum)
			replace `rawdata'= "`sum1'; `sum2'" in `nobs1'
	     }
	}
	replace `hetc' =($S_7) in `nobs1'
	replace `hetdf'=($S_8) in `nobs1'
	replace `hetp' =($S_9) in `nobs1'
	replace `i2'=max(0, ( 100*($S_7-$S_8))/($S_7) ) in `nobs1'
	if $S_8<1 { 
		replace `i2'=. in `nobs1' 
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
replace `lci'=. if `expand'>1 & `use'!=1  
replace `uci'=. if `expand'>1 & `use'!=1    
replace `weight' =. if `expand'>1 & `use'!=1   
replace `rawdata' ="." if `expand'>1 & `use'!=1   


*Perform subgroup analyses 

local j=1
while `j'<=`ngroups' {		// HUGE LOOP THROUGH EACH SUBGROUP

	if "`subgroup'"=="" {
		*First ensure the by() category has any data
		count if (`newby'==`j' & `use'==1)

		if r(N)==0 {
			*No data in subgroup=> fill variables with missing and move on
			replace `effect'=. if (`use'==3 & `newby'==`j')
			replace `lci'=. if (`use'==3 & `newby'==`j')
			replace `uci'=. if (`use'==3 & `newby'==`j')
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
				`nextcall' `varlist' if (`newby'==`j' & `use'==1) , nograph /*
				  */ notable label(`label') method(`method2') `randomi' `wgt' `cornfield' `chi2' /*
				  */ `cc' `standard' `log' `eform' `breslow'
				replace `effect'=($S_1) if `use'==19 & `newby'==`j'
				replace `lci'=($S_3) if `use'==19 & `newby'==`j'
				replace `uci'=($S_4) if `use'==19 & `newby'==`j'
				replace `hetdf' = $S_8 if `use'==19 & `newby'==`j'
				if "`method2'"=="D+L" {
					replace `tau2' = $S_12 if `use'==19 & `newby'==`j'
				}
			}

			/* THEN GET REGULAR ESTIMATES AS USUAL */
			`nextcall' `varlist' if (`newby'==`j' & `use'==1) , nograph /*
			  */ notable label(`label') method(`method') `randomi' `wgt' `cornfield' `chi2' /*
			  */ `cc' `standard' `log' `eform' `breslow'
			replace `effect'=($S_1) if `use'==3 & `newby'==`j'
			replace `lci'=($S_3) if `use'==3 & `newby'==`j'
			replace `uci'=($S_4) if `use'==3 & `newby'==`j'
		
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
	
			if $S_8<1 { 
				replace `i2'=. if `use'==3 & `newby'==`j' 
			}
			if "`chi2'"!="" {  
				replace `tsig'=($S_10) if `use'==3 & `newby'==`j'
				replace `psig'=($S_11) if `use'==3 & `newby'==`j'
			}
			else {
				replace `tsig'=($S_5) if `use'==3 & `newby'==`j'
				replace `psig'=($S_6) if `use'==3 & `newby'==`j'
			}
			if "`method'"=="D+L" {
				replace `tau2' = $S_12 if `use'==3 & `newby'==`j'
			}
	
		} /* END OF IF SUBGROUP N > 0 */

		*Whether data or not - put cell counts in subtotal row if requested (will be 0/n1;0/n2 or blank if all use>1)
		if "`counts'"!="" { 
	
		*don't put up anything for MDs:
		*1 Cochrane just put up N_gi. Not sure whether weighted mean should be in..
		*2 justifying N_gi is tedious!
			if "`nextcall'"!="MD" {
				sum `1'  if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum1 =r(sum)
				sum `r1' if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum2 =r(sum)
				sum `3'  if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum3 =r(sum)
				sum `r2' if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum4 =r(sum)
				replace `rawdata'= "`sum1'/`sum2';`sum3'/`sum4'" if (`use'==3 & `newby'==`j')
		     }
			if "`nextcall'"=="MD" {
				sum `1'  if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum1 =r(sum)
				sum `4' if (`use'==1 | `use'==2) & (`newby'==`j')
				local sum2 =r(sum)
				replace `rawdata'= "`sum1'; `sum2'" if (`use'==3 & `newby'==`j')
		     }
		}

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

	/* RMH I-squared added in next line 
		RJH- also p-val as recommended by Mike Bradburn */

	replace `label' = "Subtotal  (I-squared = " + string(`i2', "%5.1f")+ "%, p = " + ///
		string(`hetp', "%5.3f") + ")" if ( `use'==3 & `newby'==`j' & "$MA_nohet" == "")
	local j=`j'+1

} /* 	FINALLY, THE END OF THE WHILE LOOP! */

replace `label' = "Overall  (I-squared = " + string(`i2', "%5.1f")+ "%, p = " + ///
	string(`hetp', "%5.3f") + ")" if ( `use'==5 & "$MA_nohet" == "")

if "`subgroup'"==""{
	qui sum `hetc' if `use' == 5
	local rjhet = r(mean)
	qui sum `hetc' if `use'==3
	local btwghet = (`rjhet') -r(sum)
	local df = `ngroups'-1
	global rjhHetGrp = chiprob(`df',`btwghet')
}

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
	di _n in gr _col(12) "Study" _col(22) "|" _col(24) "`log'" _col(28) "`sumstat'" /*
		 */  _col(34) "[$IND% Conf. Interval]"  _col(59) "`ww'"
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
			di in gr `tlabel'[`i'] _col(22) "|  " in ye  %7.3f  `effect'[`i'] /* 
				*/ _col(35) %7.3f `lci'[`i'] "   " %7.3f `uci'[`i'] _col(60)  %6.2f `ww' 
		}

		if (`use'[`i'])==2 {
			*excluded trial
			di in gr `tlabel'[`i'] _col(22) "|  (Excluded)"
		}

		if ((`use'[`i']==3 | `use'[`i']==19) & "`subgroup'"=="") | (`use'[`i']==5 | `use'[`i']==17) {

			*Subgroup effect size or overall effect size
			if (`use'[`i'])==3 { 
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
			if `use'[`i'] == 3 | `use'[`i'] == 5{
				di in gr "  `method' pooled `log'`sumstat'" _col(22) "|  " in ye  %7.3f /*
					*/ `effect'[`i'] _col(35) %7.3f  `lci'[`i'] "   "  %7.3f `uci'[`i'] _col(60) %6.2f `ww'
			}
			if `use'[`i'] == 19 | `use'[`i'] == 17{
				di in gr "  $MA_method2 pooled `log'`sumstat'" _col(22) "|  " in ye  %7.3f /*
					*/ `effect'[`i'] _col(35) %7.3f  `lci'[`i'] "   "  %7.3f `uci'[`i']
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

		di in gr _n "Test(s) of heterogeneity:" _n _col(16) "Heterogeneity  degrees of"
		di in gr _col(18) "statistic     freedom      P    I-squared**" _cont
		if "`method'"=="D+L" { 
			di in gr "   Tau-squared" 
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
				di in ye _col(20) %6.2f `hetc'[`i'] _col(35) %2.0f `hetdf'[`i']   /*
				  */  _col(43) %4.3f `hetp'[`i'] _col(51) %6.1f `i2'[`i'] "%" _cont
				if `use'[`i'] == 3{
					local maxHet = max(`maxHet',`i2'[`i'])
				}
				if `use'[`i'] == 5{
					local ovHet = `i2'[`i']
				}
				if "`method'"=="D+L" { 
					di in ye "      " %7.4f `tau2'[`i'] _cont
				}
				if (`use'[`i']==5) & ("`subgroup'"=="") & ("$MA_method1" == "I-V") {  // FIXED I-V ONLY
					qui sum `hetc' if `use'==3
		   			local btwghet = (`hetc'[`i']) -r(sum)
		   			local df = `ngroups'-1
		   			di _n in gr "Overall Test for heterogeneity between sub-groups: " _n   /*
						*/ in ye _col(20) %6.2f `btwghet' _col(35) %2.0f `df'  _col(43) %4.3f  /*
						*/ (chiprob(`df',`btwghet'))

				}
			}
			local i=`i'+1
		}

		di _n in gr "** I-squared: the variation in `sumstat' attributable to heterogeneity)" _n

		// DISPLAY BETWEEN-GROUP TEST WARNINGS
		if "`overall'" == ""{
		if `maxHet' < 50 & `maxHet' > 0 & ("$MA_method1" == "I-V"){
			di in gr "Some heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups may be invalid"						
		}
		if `maxHet' < 75 & `maxHet' >= 50 & ("$MA_method1" == "I-V"){
			di in gr "Moderate heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups likely to be invalid"
		}
		if `maxHet' < . & `maxHet' >= 75 & ("$MA_method1" == "I-V"){
			di in gr "Considerable heterogeneity observed (up to "%4.1f `maxHet' "%) in one or more sub-groups,"
			di in gr "Test for heterogeneity between sub-groups likely to be invalid"
		}
		if "$MA_method1" != "I-V"{
			di in gr "Note: between group heterogeneity not calculated;"
			di in gr "only valid with inverse variance method"
		}
		}
		*part 3: test statistics
		di _n in gr "Significance test(s) of `log'`sumstat'=`h0'" 

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
					di in gr _col(20) "chi-squared = " in ye %5.2f `tsig'[`i'] /*
						*/ in gr  _col(35) " (d.f. = 1) p = "  in ye %4.3f `psig'[`i'] _cont
	  			}
				else { 
			   		di in gr _col(23) "z= " in ye %5.2f `tsig'[`i'] _col(35) in gr  /*
						*/ " p = "  in ye %4.3f `psig'[`i'] _cont
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

	global S_1=`effect'[`N']
	global S_2=`se'[`N']
	global S_3=`lci'[`N']
	global S_4=`uci'[`N']
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
	if ("`sumstat'"=="OR" | "`sumstat'"=="RR" | "`sumstat'"=="RD"  ) {
		global S_13=`tger'
		global S_14=`cger'
	}

} /* end if overall */

else {
	forvalues i = 1/14{
		global S_`i' .
	}
}


if "`graph'"=="" {

	_dispgby `effect' `lci' `uci' `weight' `use' `label' `rawdata' `wtdisp' `tau2' `hetdf',  /*
	  */ `log' `xlabel' `xtick' `force' sumstat(`sumstat') `saving' `box' t1("`t1'")  /*
	  */ t2("`t2'")  b1("`b1'") b2("`b2'") lcols("`lcols'") rcols("`rcols'") `overall' `wt' `stats' `counts' `eform'    /*
	  */ `groupla'  `cornfield'

}

if "`keep'"=="" {

	qui{

	if ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") { 
		local ln "log"
	}
	else { 
		local ln  
	}

	cap drop _ES 
	cap drop _seES
	cap drop _selogES 

	if "`sumstat'"!="ES" {
		#delimit ;
		replace _SS  =. if `use'!=1; label var _SS "Sample size";
		gen _ES  =`effect';label var _ES "`log'`sumstat'";
		gen _se`ln'ES=`se';label var _se`ln'ES "se(`ln'`log'`sumstat')";
		#delimit cr
	}
	#delimit ;
	cap drop _LCI ; cap drop _UCI; cap drop _WT;
	gen _LCI =`lci';   label var _LCI "Lower CI (`log'`sumstat')";
	gen _UCI =`uci';   label var _UCI "Upper CI (`log'`sumstat')";
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

} /* end if keep */

restore

end



**********************************************************
***                                                    ***
***                        NEW                         ***
***                 _DISPGBY PROGRAM                   ***
***                    ROSS HARRIS                     ***
***                     JULY 2006                      ***
***                       * * *                        ***
***                                                    ***
**********************************************************

program define _dispgby
version 9.0	

//	AXmin AXmax ARE THE OVERALL LEFT AND RIGHT COORDS
//	DXmin dxMAX ARE THE LEFT AND RIGHT COORDS OF THE GRAPH PART

#delimit ;
syntax varlist(min=6 max=10 default=none ) [if] [in] [,
  LOG XLAbel(string) XTICK(string) FORCE SAVING(string) noBOX SUMSTAT(string) 
  T1(string) T2(string) B1(string) B2(string) LCOLS(string) /* JUNK NOW */
  RCOLS(string) noOVERALL noWT noSTATS COUNTS EFORM 
  noGROUPLA CORNFIELD];
#delimit cr
tempvar effect lci uci weight wtdisp use label tlabel id yrange xrange Ghsqrwt rawdata i2 mylabel
tokenize "`varlist'", parse(" ")

qui{

gen `effect'=`1'
gen `lci'   =`2'

gen `uci'   =`3'
gen `weight'=`4'	// was 4
gen byte `use'=`5'
gen str `label'=`6'
gen str `mylabel'=`6'

if "`lcols'" == ""{
	local lcols "`mylabel'"
	label var `mylabel' "Study ID"
}

gen str80 `rawdata' = `7'
compress `rawdata'

if "`8'"!="" & "$MA_rjhby" != ""{
	gen `wtdisp'=`8' 
}
else { 
	gen `wtdisp'=`weight' 
}

if "`10'" != "" & "$MA_rjhby" != ""{
	tempvar tau2 df
	gen `tau2' = `9'
	gen `df' = `10'
}
if "`9'" != "" & "$MA_rjhby" == ""{	// DIFFERENT IF FROM metan OR metanby
	tempvar tau2 df
	gen `tau2' = `8'
	gen `df' = `9'
}
replace `weight' = `wtdisp'	// bodge solu for SG weights

if "$MA_summaryonly" != ""{
	drop if `use' == 1
}

// SET UP EXTENDED CIs FOR RANDOM EFFECTS DISTRIBUTION
// THIS CODE IS A BIT NASTY AS I SET THIS UP BADLY INITIALLY
// REQUIRES MAJOR REWORK IDEALLY...

tempvar tauLCI tauUCI SE tauLCIinf tauUCIinf
*replace `tau2' = .a if `tau2' == 0	// no heterogeneity
replace `tau2' = .b if `df'-1 == 0	// inestimable predictive distribution
replace `tau2' = . if (`use' == 5 | `use' == 3) & "$MA_method1" != "D+L"
replace `tau2' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"

gen `tauLCI' = .
gen `tauUCI' = .
gen `tauLCIinf' = .
gen `tauUCIinf' = .
gen `SE' = .


// modified so rf CI (rflevel) used
if "$MA_rfdist" != ""{
	if ( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") ) | ("`eform'"!="") {
		replace `SE' = (ln(`uci')-ln(`lci')) / (invnorm($RFL/200+0.5)*2)
		replace `tauLCI' = exp( ln(`effect') - invttail((`df'-1), 0.5-$RFL/200)*sqrt( `tau2' +`SE'^2 ) )
		replace `tauUCI' = exp( ln(`effect') + invttail((`df'-1), 0.5-$RFL/200)*sqrt( `tau2' +`SE'^2 ) )
		replace `tauLCI' = 1e-9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b 
	}
	else{
		replace `SE' = (`uci'-`lci') / (invnorm($RFL/200+0.5)*2)
		replace `tauLCI' = `effect'-invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauUCI' = `effect'+invttail((`df'-1), 0.5-$RFL/200)*sqrt(`tau2'+`SE'^2)
		replace `tauLCI' = -1e9 if `tau2' == .b
		replace `tauUCI' = 1e9 if `tau2' == .b
	}
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

// don't show effect size again, just CI
gen `RFdistLabel' = "with estimated predictive interval" if `use' == 4 & `tau2' < .
gen `RFdistText' = /* string(`effect', "%10.`dp'f") + */ ".       (" + string(`tauLCI', "%10.`dp'f") + ", " +string(`tauUCI', "%10.`dp'f") ///
	+ ")" if `use' == 4 & `tau2' < .

/* not used
replace `RFdistLabel' = "No observed heterogeneity" if `use' == 4 & `tau2' == .a
replace `RFdistText' = string(`effect', "%10.`dp'f") + " (" + string(`lci', "%10.`dp'f") + ", " +string(`uci', "%10.`dp'f") ///
	+ ")" if `use' == 4 & `tau2' == .a
*/

// don't show effect size again, just CI
replace `RFdistLabel' = "Inestimable predictive distribution with <3 studies"  if `use' == 4 & `tau2' == .b
replace `RFdistText' = /* string(`effect', "%4.2f") + */ ".       (  -  ,  -  )" if `use' == 4 & `tau2' == .b


qui replace `estText' = " " +  `estText' if `effect' >= 0 & `use' != 4
gen str `weightText' = string(`weight', "%4.2f")

replace `weightText' = "" if `use' == 17 | `use' == 19 // can cause confusion and not necessary
replace `rawdata' = "" if `use' == 17 | `use' == 19 

if "`counts'" != ""{
	if $MA_params == 6{
		local type "N, mean (SD);"
	}
	else{
		local type "Events,"
	}
	tempvar raw1 raw2
	gen str `raw1' = substr(`rawdata',1,(strpos(`rawdata',";")-1) )
	gen str `raw2' = substr(`rawdata',(strpos(`rawdata',";")+1), (length(`rawdata')-strpos(`rawdata',";")) )
	label var `raw1' "`type' $MA_G1L"
	label var `raw2' "`type' $MA_G2L"
}


/* RJH - probably a better way to get this but I've just used globals from earlier */

if "`overall'" == "" & "$MA_nohet" == ""{
	if "$MA_method1" == "USER"{
		if "$MA_firststats" != ""{
			replace `label' = "Overall ($MA_firststats)" if `use'==5
		}
		else{
			replace `label' = "Overall" if `use'==5
		}
	}
	replace `label' = "Overall ($MA_secondstats)" if `use' == 17 & "$MA_method2" == "USER" & "$MA_secondstats" != ""
	replace `label' = "Overall" if `use' == 17 & "$MA_method2" == "USER" & "$MA_secondstats" == ""
}
if "`overall'" == "" & "$MA_nohet" != ""{
	replace `label' = "Overall" if `use' == 5 | `use' == 17
}

tempvar hetGroupLabel expandOverall orderOverall
if "$MA_rjhby" != "" & "$MA_nohet" == "" & "$MA_method1" == "I-V"{
*	replace `label' = `label' + ";" if `use' == 5
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
// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIDDLED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!

qui summ `lci', detail
local DXmin = r(min)
qui summ `uci', detail
local DXmax = r(max)
local h0 = 0

// MIKE MAKES A MAX VALUE IF SOMETHING EXTREME OCCURS...
if (( ("`sumstat'"=="OR" | "`sumstat'"=="RR") & ("`log'"=="") ) | ("`eform'"!="")) {
	local h0=1
	local Glog "xlog"
	local xlog "log" 
	local xexp "exp"
	replace `lci'=1e-9 if `lci'<1e-8
	replace `lci'=1e9  if `lci'>1e8 & `lci'!=.
	replace `uci'=1e-9 if `uci'<1e-8
	replace `uci'=1e9  if `uci'>1e8 & `uci'!=.
	if `DXmin'<1e-8 {
		local DXmin=1e-8
	}
	if `DXmax'>1e8 {
		local DXmax=1e8
	}
}
if "$MA_NULL" != ""{
	local h0 = $MA_NULL
}
if `h0' != 0 & `h0' != 1{
	noi di "Null specified as `h0' in graph- for most effect measures null is 0 or 1"
}

if "`cornfield'"!="" {
	replace `lci'=`log'(1e-9) if ( (`lci'==. | `lci'==0) & (`effect'!=. & `use'==1) )
	replace `uci'=`log'(1e9)  if ( (`uci'==.) & (`effect'!=. & `use'==1) )
}

// THIS BIT CHANGED- THE USER CAN PUT ANYTHING IN

local flag1=0
if ("`xlabel'"=="" | "`xtick'" == "") & "$MA_nulloff" == ""{ 		// if no xlabel or tick
	local xtick  "`h0'"
}

if "`xlabel'"==""{
	local Gmodxhi=max( abs(`xlog'(`DXmin')),abs(`xlog'(`DXmax')))
	if `Gmodxhi'==. {
		local Gmodxhi=2
	}
	local DXmin=`xexp'(-`Gmodxhi')
	local DXmax=`xexp'( `Gmodxhi')
	if "$MA_nulloff" == ""{
		local xlabel "`DXmin',`h0',`DXmax'"
	}
	else{
		local xlabel "`DXmin',`DXmax'"
	}
}

local DXmin2 = min(`xlabel',`DXmin')
local DXmax2 = max(`xlabel',`DXmax')
if "`force'" == ""{
	local Gmodxhi=max( abs(`xlog'(`DXmin')), abs(`xlog'(`DXmax')), ///
		abs(`xlog'(`DXmin2')), abs(`xlog'(`DXmax2')) )
	if `Gmodxhi'==. {
		local Gmodxhi=2
	}
	local DXmin=`xexp'(-`Gmodxhi')
	local DXmax=`xexp'( `Gmodxhi')
	if "`xlabel'" != "" & "$MA_nulloff" == ""{
		local xlabel "`h0',`xlabel'"
	}
}

if "`force'" != ""{
	local DXmin = min(`xlabel')
	local DXmax = max(`xlabel')
	if "$MA_nulloff" == ""{
		local xlabel "`h0',`xlabel'"
	}
}

// LABELS- DON'T ALLOW SILLY NO. OF DECIMAL PLACES

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

local DXmin=`xlog'(min(`xlabel',`xtick',`DXmin'))
local DXmax=`xlog'(max(`xlabel',`xtick',`DXmax'))

if ("`eform'" != "" | "`xlog'" != "") {
	local lblcmd ""
	tokenize "`xlabel'", parse(",")
	while "`1'" != ""{
		if "`1'" != ","{
			local lbl = string(`1',"%7.3g")
			local val = ln(`1')
			local lblcmd `lblcmd' `val' "`lbl'"
		}
		mac shift
	}
	
	replace `effect' = ln(`effect')
	replace `lci' = ln(`lci')
	replace `uci' = ln(`uci')
	replace `tauLCI' = ln(`tauLCI')
	replace `tauUCI' = ln(`tauUCI')
	local xtick2 ""
	tokenize "`xtick'", parse(",")
	while "`1'" != ""{
		if "`1'" != ","{
			local ln = ln(`1')
			local xtick2 "`xtick2' `ln'"
		}
		if "`1'" == ","{
			local xtick2 "`xtick2'`1'"
		}
		mac shift
	}
	local xtick "`xtick2'"
	local h0 = 0
}

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

************************
**      COLUMNS       **
************************

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

*effect lci uci tempvars
if "$MA_efficacy" != ""{
	tempvar vetemp ucivetemp lcivetemp vaccine_efficacy
	qui {
	 gen `vetemp'=100*(1-exp(`effect'))
	 tostring `vetemp', replace force format(%4.0f)

	 gen `ucivetemp'=100*(1-exp(`lci'))
	 tostring `ucivetemp', replace force format(%4.0f)

	 gen `lcivetemp'=100*(1-exp(`uci'))
	 tostring `lcivetemp', replace force format(%4.0f)

	 gen str30 `vaccine_efficacy'=`vetemp'+" ("+`lcivetemp'+", "+`ucivetemp'+")" if `effect' != .
	 label var `vaccine_efficacy' "Vaccine efficacy (%)"
	
	 local rcols = "`vaccine_efficacy' " + "`rcols' "

	}
}

if "`wt'" == ""{
	local rcols = "`weightText' " + "`rcols'"
	if "$MA_method2" != ""{
		label var `weightText' "% Weight ($MA_method1)"
	}
	else{
		label var `weightText' "% Weight"
	}
}
if "`counts'" != ""{
	local rcols = "`raw1' " + "`raw2' " + "`rcols'"
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
if "`counts'" != ""{
	local skip = `skip' + 2
}
if "$MA_efficacy" != ""{
	local skip = `skip' + 1
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
	
	replace `tauLCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "D+L"
	replace `tauUCI`inf'' = . if (`use' == 3 | `use' == 5) & "$MA_method1" != "D+L"
	replace `tauLCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"
	replace `tauUCI`inf'' = . if (`use' == 17 | `use' == 19) & "$MA_method2" != "D+L"
}


// DIAMONDS TAKE FOREVER...I DON'T THINK THIS IS WHAT MIKE DID
tempvar DIAMleftX DIAMrightX DIAMbottomX DIAMtopX DIAMleftY1 DIAMrightY1 DIAMleftY2 DIAMrightY2 DIAMbottomY DIAMtopY

gen `DIAMleftX' = `lci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftX' = `DXmin' if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftX' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMleftY1' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY1' = `id' + 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY1' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
gen `DIAMleftY2' = `id' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMleftY2' = `id' - 0.4*( abs((`DXmin'-`lci')/(`effect'-`lci')) ) if `lci' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMleftY2' = . if `effect' < `DXmin' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)

gen `DIAMrightX' = `uci' if `use' == 3 | `use' == 5 | `use' == 17 | `use' == 19
replace `DIAMrightX' = `DXmax' if `uci' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
replace `DIAMrightX' = . if `effect' > `DXmax' & (`use' == 3 | `use' == 5 | `use' == 17 | `use' == 19)
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

local textSize = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )
local textSize2 = `adj' * $MA_TEXT_SCA / (`approx_chars' * sqrt(`aspectRat') )

forvalues i = 1/`lcolsN'{
	local lcolCommands`i' "(scatter `id' `left`i'' if `use' != 4, msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}
forvalues i = 1/`rcolsN'{
	local rcolCommands`i' "(scatter `id' `right`i'' if `use' != 4, msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}
if "$MA_rfdist" != ""{
	if "`stats'" == ""{
		local predIntCmd "(scatter `id' `right1' if `use' == 4, msymbol(none) mlabel(`RFdistText') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
	}
	if "$MA_nohet" == ""{
		local predIntCmd2 "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`RFdistLabel') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
	}	
}
if "$MA_nohet" == "" & "$MA_rjhby" != ""{
	local hetGroupCmd  "(scatter `id' `left1' if `use' == 4, msymbol(none) mlabel(`hetGroupLabel') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
}

// OTHER BITS AND BOBS

local dispBox "none"
if "`nobox'" == ""{
	local dispBox "square	"
}

local boxsize = $MA_FBSC/150

if "$MA_FAVOURS" != ""{
	local pos = strpos("$MA_FAVOURS", "#")
	local leftfav = substr("$MA_FAVOURS",1,(`pos'-1))
	local rightfav = substr("$MA_FAVOURS",(`pos'+1),(length("$MA_FAVOURS")-`pos'+1) )
}
if `h0' != . & "$MA_nulloff" == ""{
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



if "$MA_method1" == "D+L"{
	tempvar noteposx noteposy notelab
	qui{
	summ `id'
		gen `noteposy' = r(min) -1.5 in 1
		summ `left1'
		gen `noteposx' = r(mean) in 1
		gen `notelab' = "NOTE: Weights are from random effects analysis" in 1
		local notecmd "(scatter `noteposy' `noteposx', msymbol(none) mlabel(`notelab') mlabcolor(black) mlabpos(3) mlabsize(`textSize')) "
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

local nullCommand " (pcspike `ovMin' `h0Line' `ovMax' `h0Line', lwidth(thin) lcolor(black) ) "

// gap if "favours" used
if "`leftfav'" != "" | "`rightfav'" != ""{
	local gap = "labgap(5)"
}

// if summary only must not have weights
local awweight "[aw= `weight']"
if "$MA_summaryonly" != ""{
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
	if "$MA_method1" == "D+L"{
		replace `rfarrow' = 1 if `use' == 3 | `use' == 5
	}
	if "$MA_method2" == "D+L"{
		replace `rfarrow' = 1 if `use' == 17 | `use' == 19
	}
}
}	// end qui


// final addition- if aspect() given but not xsize() ysize(), put these in to get rid of gaps
// need to fiddle to allow space for bottom title
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

// switch off null if wanted
if "$MA_nulloff" != ""{
	local nullCommand ""
}

***************************
***        GRAPH        ***
***************************

#delimit ;

twoway
/* NOTE FOR RF, OVERALL AND NULL LINES FIRST */ 
	`notecmd' `overallCommand' `nullCommand' `predIntCmd' `predIntCmd2' `hetGroupCmd'
/* PLOT BOXES AND PUT ALL THE GRAPH OPTIONS IN THERE */ 
	(scatter `id' `effect' `awweight' if `use' == 1, 
	  `boxopt' 
	  yscale(range(`DYmin' `DYmax') noline )
	  ylabel(none) ytitle("")
	  xscale(range(`AXmin' `AXmax'))
	  xlabel(`lblcmd', labsize(`textSize2') )
	  yline($borderline, lwidth(thin) lcolor(gs12))
/* THIS BIT DOES favours. NOTE SPACES TO SUPPRESS IF THIS IS NOT USED */
	  xmlabel(`leftfp' "`leftfav' " `rightfp' "`rightfav' ", noticks labels labsize(`textSize') 
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
/* COLUMN VARIBLES */
	`lcolCommands1' `lcolCommands2' `lcolCommands3' `lcolCommands4' `lcolCommands5' `lcolCommands6'
	`lcolCommands7' `lcolCommands8' `lcolCommands9' `lcolCommands10' `lcolCommands11' `lcolCommands12'
	`rcolCommands1' `rcolCommands2' `rcolCommands3' `rcolCommands4' `rcolCommands5' `rcolCommands6'
	`rcolCommands7' `rcolCommands8' `rcolCommands9' `rcolCommands10' `rcolCommands11' `rcolCommands12'
	(scatter `id' `right1' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB1') mlabcolor("0 0 0") mlabpos(3) mlabsize(`textSize'))
	(scatter `id' `right2' if `use' != 4 & `use' != 0,
	  msymbol(none) mlabel(`rightLB2') mlabcolor("0 0 0") mlabpos(3) mlabsize(`textSize'))
/* 	(scatter `id' `right2', mlabel(`use'))   JUNK, TO SEE WHAT'S WHERE */
/* LAST OF ALL PLOT EFFECT MARKERS TO CLARIFY AND OVERALL EFFECT LINE */
	(scatter `id' `effect' if `use' == 1, `pointopt' )
	, $MA_OTHEROPTS /* RMH added */ plotregion(margin(zero));

#delimit cr

end





program define getWidth
version 9.0

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



exit

//	METAN UPDATE
//	ROSS HARRIS, DEC 2006
//	MAIN UPDATE IS GRAPHICS IN THE _dispgby PROGRAM
//	ADDITIONAL OPTIONS ARE lcols AND rcols
//	THESE AFFECT DISPLAY ONLY AND ALLOW USER TO SPECIFY
//	VARIABLES AS A FORM OF TABLE. THIS EXTENDS THE label(namevar yearvar)
//	SYNTAX, ALLOWING AS MANY LEFT COLUMNS AS REQUIRED (WELL, LIMIT IS 10)
//	IF rcols IS OMMITTED DEFAULT IS THE STUDY EFFECT (95% CI) AND WEIGHT
//	AS BEFORE- THESE ARE ALWAYS IN UNLESS OMITTED USING OPTIONS
//	ANYTHING ADDED TO rcols COMES AFTER THIS.

//	v1.4 WAS GETTING THERE
// 	v1.5 SORT OUT EXTRA LINE AT THE TOP AND ALLOW "DOUBLE LINES"
//	FOR FIXED AND RANDOM EFFECTS

//	SOMETHING TO ADD- RETURN ES_2?
//	v1.7 - TRY TO SORT OUT LABELLING
//	CHANGED LABELS TO 7.3g -WORKS NICELY
//	"FAVOURS" NOW WORKS- USES xmlabel
//	v1.8 ADDED IN COUNTS OPTION, SORTED OUT TEXTSIZE, PROPER DEFINITION AND SPLIT OF VAR LABELS

// 	v1.9 DELETE UNECESSARY OPTIONS
//	OH, AND ADD effect OPTION
//	v1.10 FINAL TIDYING, USED Jeff Pitblado's SUGGESTION FOR getWidth

//	v1.11 USE label() OPTIONS IF NO lcols rcols, WORK ON AUTO FIT TEXT
//	v1.12 FURTHER WORK...

//	v1.14 DONE ON 12TH OCTOBER, FINALLY DISCOVERED WHAT IS CAUSING PROBLEM
//	WITH "NON-MATCHING CLOSE BRACE" AT END OF FILE- NO v7 STYLE IF STATEMENTS!
//	EVERYTHING GOES ON A SEPARATE LINE NOW. PHEW.

//	v1.15 NOW ADDING IN OPTIONS TO CONTROL BOXES, CI LINES, OVERALL
//	TITLES WEREN'T SPREADING ACROSS SINCE OPTION TO CONTROL OVERALL TEXT- FIXED AGAIN

//	v1.16 LAST ATTEMPT TO GET TEXT SIZE RIGHT! WORK OUT WHAT ASPECT SHOULD BE AND USE
//	IF ASPECT DEFINED THEN DECREASE TEXT SIZE BY RATIO TO IDEAL ASPECT

//	TEXT SCALING WORKING BETTER NOW
//	LAST THING TO TRY TO SORT IS LOOK FOR LEFT OF DIAMOND AND MOVE HET STATS
//	COULD PUT UNDERNEATH IF NOT MUCH SPACE? THIS WOULD BE GOOD v1.17
//	STILL DEBATING WHETHER TO PUT favours BIT BELOW xticks...

//	V19 LOTS OF COMMENTS FROM JONATHAN AND BITS TO DO. SUMMARY:
//	aspect 				Y
//	note if random weights		Y
//	update to v8			Y
//	graph in mono			Y
//	extend overall text into plot	Y
//	labels				Y
//	help file				not v8 yet

//	v1.21 EVERY PROGRAM NOW CONVERTED TO v9.0, NO "CODE FOLLOWS BRACES!"

//	WHAT ELSE DID PATRICK DO TO UPDATE TO v8?

//	NO "#delimit ;" 					- I QUITE LIKE THIS THOUGH!
//	GLOBALS ARE DECLARED WITHOUT = SIGN		- EXCEPT WHEN USING STRING FUNCTION ETC. IT DOESN'T LIKE THIS!
//								- WILL THIS EVER CAUSE PROBLEMS?
//								- CAN'T BE BOTHERED TO CHANGE ALL THE NUMERIC ONES
//	USE TOKENIZE INSTEAD OF PARSE			- DONE
//	USE di as err NOT in red, EXIT		- DONE, PROPER RETURN CODES STILL NEEDED, MAYBE SOMEDAY!
//	DECENT HELP FILE					- USED, JUST ADD IN NEW BITS

//	v1.22 ENCODE STUFF FOR metanby NOW LABORIOUSLY RECODED SO THAT GROUPS ARE IN ORIGINAL SORT ORDER
//	THIS IS USEFUL IF YOU DON'T WANT STUFF IN ALPHA-NUMERIC ORDER, OR TO PUT "1..." "2..." ETC.

//	counts OPTION DOES NOT WORK WITH MEAN DIFFERENCES- AND LOOKS LIKE IT NEVER DID- PUT IN
//	DO OWN LINES FOR OVERALL ETC. EXTENDS TOO FAR
//	LABELS NEVER RUN TO FOUR LINES- SORT OUT- QUICK SOLU- DO FIVE TIMES AND DROP ONE!

//	v1.23 USES pcspike FOR OVERALL AND NULL LINES TO PREVENT OVER-EXTENDING
//	NOW HAS OPTION FOR USER DEFINED "SECOND" ANALYSIS

//	v1.24 ALLOW USER TO COMPLETELY DEFINE ANALYSIS WITH WEIGHTS

// 	v2.34 problem with nosubgroup nooverall sorted out (this combination failed)

********************
** May 2007 fixes **
********************

//	"nostandard" had disappeared from help file- back in
//	I sq. in return list
//	sorted out the extra top line that appears in column labels
//	fixed when using aspect ratio using xsize and ysize so inner bit matches graph area- i.e., get rid of spaces for long/wide graphs
//	variable display format preserved for lcols and rcols
//	abbreviated varlist now allowed
//	between groups het. only available with fixed
//	warnings if any heterogeneity with fixed (for between group het if any sub group has het, overall est if any het)
// 	nulloff option to get rid of line

// May 2009
//	prediction interval sorted out. Note error in Higgins presentation (too wide- there is no heterogeneity in data!)
//	so don't check with this! George Kelley has sent example data
