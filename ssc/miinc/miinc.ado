*! miinc (Multi-model Inference using INformation Crieria version 2.0 August 7th, 2014 J. N. Luchman

program define miinc, properties(mi)
/*history and version information at end of file*/

version 12.1

/*replay*/
if (replay()) {

	if !inlist("`e(cmd)'", "miinc") error 301
	
	if (_by()) error 190
	
	Display
	
	exit 0
	
}

/*decipher miinc se vs. miinc me*/
gettoken test rest: 0	

if ("`test'" == "se") miinc_`0'

else if ("`test'" != "me") miinc_se `0'

else {

	capture mata: st_varindex("`test'")
	
	if (_rc == 0) {
	
		gettoken test rest: rest
		
		capture mata: st_varindex("`test'")
		
		if (_rc == 0) {
		
			display "{res}me{err} appears to be a dependent variable. " _newline ///
			"{cmd:miinc se} assumed." _newline
		
			miinc_se `0'
			
		}
		
		else miinc_`0'
	
	}
	
	else miinc_`0'

}

end

program define miinc_se, eclass properties(mi)

syntax varlist(min = 1 fv) [in] [if] [aw pw iw fw] , [Reg(string) ic(string) Sets(string) ///
All(varlist fv) Bestmodels(numlist >=0 max=1 integer) pip ttest ll(string) parm(string) obs(string)]

/*defaults and warnings*/
if ("`reg'" == "") {	//if no "reg" option specified - notification

	local reg "regress"	//make default analysis "regress"
	
	display "{err}Regression type not entered in {opt reg()}. " _newline ///
	"{opt reg(regress)} assumed." _newline
	
}

if (!inlist("`ic'", "aicc", "aic", "bic", "noic")) {	//if invalid "ic" option specified - notification

	local ic "aicc"	//make default ic the AICc
	
	display "{err}Valid information criterion type not entered in {opt ic()}. " _newline ///
	"{opt ic(aicc)} assumed." _newline
	
}

//disallow "i(numlist). FVs here

if ("`bestmodels'" == "") local bestmodels = 0	//default for # of bestmodels to display

if ("`ic'" == "noic") {	//best models and pip in thie "noic" situation are uninformative -disallow them

	local bestmodels = 0
	
	local pip ""

}

if !strlen("`ll'") local ll "e(ll)"	//if the log-likelihood is called something else...

if !strlen("`parm'") local parm "e(rank)"	//if the degrees of freedom are called something else...

if !strlen("`obs'") local obs "e(N)"	//if the # of obs are called something else...

/*general set up*/
if strlen("`exp'") & strlen("`weight'") {	//without this, some commands have odd behavior in single eq miinc

	local wtpre "["
	
	local wtpost "]"

}

tempfile base_ests

gettoken dv ivs: varlist	//parse varlist line to separate out dependent from independent variables

gettoken reg regopts: reg, parse(",")	//parse reg() option to pull out estimation command options

if ("`regopts'" != "") gettoken erase regopts: regopts, parse(",")	//parse out comma if one is present

local mkivs "`ivs'"	//create separate macro to use for sample marking purposes

if (`:list sizeof sets' > 0) {	//parse and process the sets if included

	/*pull out set #1 from independent variables list*/
	gettoken one two: sets, bind	//pull out the first set
	
	local setcnt = 1	//give the first set a number that can be updated as a macro
	
	local one = regexr("`one'", "[/(]", "")	//remove left paren
			
	local one = regexr("`one'", "[/)]", "")	//remove right paren
	
	local set1 `one'	//name and number set
	
	local ivs "`ivs' <`set1'>"	//include set1 into list of independent variables, include characters for binding in Mata
	
	local mkivs `mkivs' `set1'	//include variables in set1 in the mark sample independent variable list
	
	
	while ("`two'" != "") {	//continue parsing beyond set1 so long at sets remain to be parsed (i.e., there's something in the macro "two")

		gettoken one two: two, bind	//again pull out a set
			
		local one = regexr("`one'", "[/(]", "")	//remove left paren
		
		local one = regexr("`one'", "[/)]", "")	//remove right paren
	
		local set`++setcnt' `one'	//name and number set - advance set count by 1
		
		local ivs "`ivs' <`set`setcnt''>"	//include further sets - separated by binding characters - into independent variables list
		
		local mkivs `mkivs' `set`setcnt''	//include sets into mark sample independent variables list
				
	}
			
}

if (`:list sizeof ivs' < 2) {	//exit if too few predictors/sets (otherwise prodices cryptic Mata error)

	display "{err}{cmd:miinc se} requires at least 2 independent variables or" _newline ///
	"independent variable sets."
	
	exit 198

}

/*finalize setup*/
tempvar touse keep	//declare sample marking variables

tempname estmat	bestic //declare temporary scalars/matrices

mark `touse'	//declare marking variable

quietly generate byte `keep' = 1 `if' `in' //generate tempvar that adjusts for "if" and "in" statements

markout `touse' `dv' `mkivs' `all' `keep'	//do the sample marking

local nobindivs = subinstr("`ivs'", "<", "", .)	//take out left binding character(s) for use in adjusting e(sample) when obs are dropped by an anslysis

local nobindivs = subinstr("`nobindivs'", ">", "", .)	//take out right binding character(s) for use in adjusting e(sample) when obs are dropped by an anslysis

//check regression program
capture `reg' `dv' `nobindivs' `all' [`weight'`exp'] if `touse', `regopts'	//run overall analysis - probe to check for e(sample) and whether everything works as it should
	
if ("`e(cmd)'" == "xtgee" & !missing(r(qic)) & ("`ic'" != "noic")) {	//if the command used is the user written qic (SSC) command - change ic() to qic and notify

	local ic "qic"
	
	display "{txt}{cmd:qic} detected.  Switching to {opt ic(qic)}."
	
}

else if (("`e(prefix)'" == "svy") & ("`ic'" != "noic")) {	//if svy prefix is found in reg(), change to ic(aicw) cpx survey aic and notify

	local ic "aicw"
	
	display "{txt}{cmd:svy} prefix detected.  Switching to {opt ic(aicw)}."
	
	foreach try in "e(V)" "e(V_srs)" "e(ilog)" {	//be sure these matrices exist - otherwise aicw won't work
		
		capture mata: assert(length(st_matrix("`try'"))>0)
		
		if (_rc != 0) {
		
			display "{err}{opt ic(aicw)} requires {cmd:`try'}.  {cmd:`try'} not found."
			
			exit 198
		
		}
	
	}
	
}
	
quietly estimates save `base_ests'	//save estimates of base model - add miinc estimates to these

capture mata: assert(length(st_matrix("e(b)"))>0)

if (_rc != 0) {

	display "{err}{cmd:`reg'} does not return e(b) matrix.  No model averaging is possible."
	
	exit 198

}

capture mata: assert(length(st_matrix("e(V)"))>0)

if (_rc != 0) {

	display "{err}{cmd:`reg'} does not return e(V) matrix.  No model averaging is possible."
	
	exit 198

}
	
matrix `estmat' = e(b)
	
getic, type(`ic') ll(`ll') parm(`parm') obs(`obs')
	
matrix `estmat' = (r(ic), `estmat')
	
local matcher "`: colfullnames e(b)'"
	
quietly count if `touse'	//tally up observations from count based on "touse"

if (r(N) > `=`obs'') quietly replace `touse' = e(sample)	//if touse doesn't equal e(sample) - use e(sample) and proceed; not possible with multiple imputation though

if (_rc != 0) {	//exit if regression is not estimable or program results in error - return the returned code

	display "{err}{cmd:`reg'} resulted in an error."
	
	exit `=_rc'

}
	
capture assert ((`ll' != .) & (`parm' != .) & (`obs' != .))	//is the "fitstat" the user supplied actually returned by the command?
	
if ((_rc != 0) & !inlist("`ic'", "noic", "qic", "aicw")) {	//exit if fitstat can't be found and should be

	display "{err}{cmd:`ll'}, {cmd:`parm'}, or {cmd:`obs'} not returned by {cmd:`reg'}."
	
	exit 198

}
 
/*begin estimation*/
mata: miinc(`"`ivs'"', "`matcher'", "`ic'", `bestmodels', "", "`all'")	//invoke miinc() function in Mata

/*display results - this section will not be extensively explained*/
/*name matrices*/
matrix colnames coeffs = `matcher'

matrix colnames vcov = `matcher'	

matrix rownames vcov = `matcher'

if ("`pip'" != "") matrix colnames import = `impnames'	

if (`bestmodels' > 0) matrix colnames best_mods = `ic' `matcher'

/*return values*/
estimates use `base_ests'

ereturn repost b = coeffs V = vcov [`weight'`exp'], esample(`touse') rename

if (`:list sizeof all' > 0)	ereturn local all "`all'"

ereturn hidden scalar sets = 0

if ("`setcnt'" != "") {

	ereturn hidden scalar sets = `setcnt'

	forvalues x = `setcnt'(-1)1 {
	
		ereturn local set`x' "`set`x''"
		
	}
	
}

if ("`ttest'" == "ttest") ereturn local test "t"

else ereturn local test "z"

ereturn local reg `"`reg'"'

ereturn local ic "`ic'"

ereturn local miinc `"se"'

ereturn local cmd `"miinc"'

ereturn local title `"Multi-model inference"'

ereturn local cmdline `"miinc `0'"'

if ("`pip'" != "") ereturn matrix pip = import
	
ereturn hidden scalar impo = `=strlen("`pip'")'

if (`bestmodels' > 0) ereturn matrix best_models = best_mods

ereturn scalar bestic = `bestic'

ereturn hidden scalar nobest = `bestmodels'

/*begin display*/
Display

end


**


program define miinc_me, eclass properties(mi)

syntax [anything(id="equation names" equalok)], Reg(string) [ic(string) Sets(string) ///
Bestmodels(numlist >=0 max=1 integer) pip ttest ll(string) parm(string) obs(string)]

/*defaults and warnings*/
if (!inlist("`ic'", "aicc", "aic", "bic", "noic")) {	//if invalid "ic" option specified - notification

	local ic "aicc"	//make default ic the AICc
	
	display "{err}Valid information criterion type not entered in {opt ic()}. " _newline ///
	"{opt ic(aicc)} assumed." _newline
	
}

//disallow "i(numlist). FVs here

if ("`bestmodels'" == "") local bestmodels = 0

if ("`ic'" == "noic") {	//best models and pip in thie "noic" situation are uninformative

	local bestmodels = 0
	
	local pip ""

}

if !strlen("`ll'") local ll "e(ll)"

if !strlen("`parm'") local parm "e(rank)"

if !strlen("`obs'") local obs "e(N)"

/*general set up*/
tempfile base_ests

gettoken one two: anything, bind

if (strlen("`one'") > 0) {

	if !regexm("`one'", "=") {
	
		display "{err}Equation {cmd:`one'} is missing an {cmd:=} to distinguish equation" _newline ///
		"and independent variable names."
		
		exit 198
	
	}

	local one = regexr("`one'", "[/(]", "")	//remove left paren
			
	local one = regexr("`one'", "[/)]", "")	//remove right paren

	gettoken dv ivlist: one, parse("=")
	
	if ((`: list sizeof dv' != 1) | regexm("`dv'", "="))  {
	
		display "{err}Invalid equation name specified for {cmd:(`dv'`ivlist')}."
		
		exit 198
	
	}
	
	local ivlist = regexr("`ivlist'", "=", "")
	
	local dv = trim("`dv'")

	local count = 0
	
	foreach iv of local ivlist {
	
		local proceed = 1
	
		while ((`count' < 2000) & (`proceed')) {
	
			constraint get `++count'
			
			if !r(defined) {

				constraint `count' _b[`dv':`iv'] = 0
		
				local add "`dv':`iv'"
		
				local ivs = "`ivs' `add'"
				
				local constrs "`constrs' `count'"
				
				local proceed = 0
				
			}
			
		}
		
		if (`count' >= 2000) {
		
			display "{err}{cmd:miinc me} cannot make any more constraints as the {help constraint dir}" _newline ///
			"is full (see {help constraint drop}."
			
			exit 198
		
		}
		
	}
	
	while ("`two'" != "") {
	
		gettoken one two: two, bind	//again pull out an equation
		
		if !regexm("`one'", "=") {
	
			display "{err}Equation {cmd:`one'} is missing an {cmd:=} to distinguish equation" _newline ///
			"and independent variable names."
		
			exit 198
	
		}
	
		local one = regexr("`one'", "[/(]", "")	//remove left paren
			
		local one = regexr("`one'", "[/)]", "")	//remove right paren

		gettoken dv ivlist: one, parse("=")
		
		if ((`: list sizeof dv' != 1) | regexm("`dv'", "=")) {
	
			display "{err}Invalid equation name specified for {cmd:(`dv'`ivlist')}."
		
			exit 198
	
		}
	
		local ivlist = regexr("`ivlist'", "=", "")
		
		local dv = trim("`dv'")
	
		foreach iv of local ivlist {
	
			local proceed = 1
	
			while ((`count' < 2000) & (`proceed')) {
	
				constraint get `++count'
			
				if !r(defined) {

					constraint `count' _b[`dv':`iv'] = 0
		
					local add "`dv':`iv'"
		
					local ivs = "`ivs' `add'"
				
					local constrs "`constrs' `count'"
				
					local proceed = 0
				
				}
			
			}
			
			if (`count' >= 2000) {
		
				display "{err}{cmd:miinc me} cannot make any more constraints as the {help constraint dir}" _newline ///
				"is full (see {help constraint drop}."
			
				exit 198
		
			}
		
		}
		
	}

}

	
if (`:list sizeof sets' > 0) {	//parse and process the sets if included

	/*pull out set #1 from independent variables list*/
	gettoken one two: sets, bind	//pull out the first set
	
	local setcnt = 1	//give the first set a number that can be updated as a macro
	
	local one = regexr("`one'", "[/(]", "")	//remove left paren
			
	local one = regexr("`one'", "[/)]", "")	//remove right paren
	
	local set1 `one'	//name and number set
	
	local ivs "`ivs' <`set1'>"	//include set1 into list of independent variables, include characters for binding in Mata
	
	foreach eq of local set1 {
	
		local proceed = 1
	
		while ((`count') < 2000 & (`proceed')) {
	
			constraint get `++count'
			
			if !r(defined) {

				constraint `count' _b[`eq'] = 0
				
				local cset "`cset' `count'"
				
				local proceed = 0
				
			}
							
		}
		
		if (`count' >= 2000) {
		
			display "{err}{cmd:miinc me} cannot make any more constraints as the {help constraint dir}" _newline ///
			"is full (see {help constraint drop}."
			
			exit 198
		
		}
	
	}
	
	local constrs "`constrs' <`cset'>"	//include set1 into list of independent variables, include characters for binding in Mata
	
	while ("`two'" != "") {	//continue parsing beyond set1 so long at sets remain to be parsed (i.e., there's something in the macro "two")

		gettoken one two: two, bind	//again pull out a set
			
		local one = regexr("`one'", "[/(]", "")	//remove left paren
		
		local one = regexr("`one'", "[/)]", "")	//remove right paren
	
		local set`++setcnt' `one'	//name and number set - advance set count by 1
		
		local ivs "`ivs' <`set`setcnt''>"	//include sets beyond 1 into list of independent variables, include characters for binding in Mata
		
		local cset ""
		
		foreach eq of local set`setcnt' {
	
			local proceed = 1
	
			while ((`count') < 2000 & (`proceed')) {
	
				constraint get `++count'
			
				if !r(defined) {

					constraint `count' _b[`eq'] = 0
				
					local cset "`cset' `count'"
				
					local proceed = 0
				
				}
							
			}
			
			if (`count' >= 2000) {
		
				display "{err}{cmd:miinc me} cannot make any more constraints as the {help constraint dir}" _newline ///
				"is full (see {help constraint drop}."
			
				exit 198
		
			}
	
		}
	
		local constrs "`constrs' <`cset'>"	//include set1 into list of independent variables, include characters for binding in Mata
				
	}
			
}

if (`:list sizeof constrs' < 2) {	//exit if too few parameters/sets (otherwise prodices cryptic Mata error)

	display "{err}{cmd:miinc me} requires at least 2 uncertian parameters or" _newline ///
	"uncertian parameter sets."
	
	exit 198

}

/*finalize setup*/
tempname estmat bestic //declare temporary scalars/matrices

//check estimation model
capture `reg' constraints()	//run overall analysis - probe to check for e(sample) and whether everything works as it should

if (_rc != 0) {	//exit if regression is not estimable or program results in error - return the returned code

	display "{err}The model: " _newline ///
	"{res}`reg'{err} " _newline ///
	"resulted in an error." _newline ///
	"Check to see if the estimation command is missing a comma to separate the command from the options." _newline ///
	"A comma is necessary to allow {cmd:constraints()} to work properly within {cmd:miinc me}."
	
	exit `=_rc'

}

quietly estimates save `base_ests'	//save estimates of base model - add miinc estimates to these

capture mata: assert(length(st_matrix("e(b)"))>0)

if (_rc != 0) {

	display "{err}{cmd:`reg'} does not return e(b) matrix.  No model averaging is possible."
	
	exit 198

}

capture mata: assert(length(st_matrix("e(V)"))>0)

if (_rc != 0) {

	display "{err}{cmd:`reg'} does not return e(V) matrix.  No model averaging is possible."
	
	exit 198

}

matrix `estmat' = e(b)

if (("`e(prefix)'" == "svy") & ("`ic'" != "noic")) {

	local ic "aicw"
	
	display "{txt}{cmd:svy} prefix detected.  Switching to {opt ic(aicw)}."
	
	foreach try in "e(V)" "e(V_srs)" "e(ilog)" {
		
		capture mata: assert(length(st_matrix("`try'"))>0)
		
		if (_rc != 0) {
		
			display "{err}{opt ic(aicw)} requires {cmd:`try'}.  {cmd:`try'} not found."
			
			exit 198
		
		}
	
	}
	
}
	
getic, type(`ic') ll(`ll') parm(`parm') obs(`obs')
	
matrix `estmat' = (r(ic), `estmat')
	
local matcher "`: colfullnames e(b)'"

local matchivs = subinstr("`ivs'", "<", "", .)

local matchivs = subinstr("`matchivs'", ">", "", .)

local all: list matcher - matchivs

foreach eq of local matchivs {

	if !regexm("`matcher'", "`eq'") {
	
		display "{err}{cmd:`eq'} not found among parameter estimates."
		
		exit 198
	
	}

}
	
capture assert ((`ll' != .) & (`parm' != .) & (`obs' != .))	//is the "fitstat" the user supplied actually returned by the command?
	
if (_rc != 0) & !inlist("`ic'", "noic", "aicw") {	//exit if fitstat can't be found

	display "{err}{cmd:`ll'}, {cmd:`parm'}, or {cmd:`obs'} not returned by {cmd:`reg'}."
	
	exit 198

}
 
/*begin estimation*/
mata: miinc(`"`ivs'"', "`matcher'", "`ic'", `bestmodels', "`constrs'", "`all'")	//invoke miinc() function in Mata

local constrs = subinstr(subinstr("`constrs'", "<", "", .), ">", "", .)

foreach cns of local constrs {

	constraint drop `cns'

}

/*display results - this section will not be extensively explained*/
/*name matrices*/
matrix colnames coeffs = `matcher'

matrix colnames vcov = `matcher'	

matrix rownames vcov = `matcher'

if ("`pip'" != "") matrix colnames import = `impnames'	

if (`bestmodels' > 0) matrix colnames best_mods = `ic' `matcher'

/*return values*/
estimates use `base_ests'

ereturn repost b = coeffs V = vcov [`weight'`exp'], esample(`touse') rename

if (`:list sizeof all' > 0)	ereturn local all "`all'"

ereturn hidden scalar sets = 0

if ("`setcnt'" != "") {

	ereturn hidden scalar sets = `setcnt'

	forvalues x = `setcnt'(-1)1 {

		ereturn local set`x' "`set`x''"
		
	}
	
}

if ("`ttest'" == "ttest") ereturn local test "t"

else ereturn local test "z"

ereturn local reg `"`reg'"'

ereturn local ic "`ic'"

ereturn local miinc `"me"'

ereturn local cmd `"miinc"'

ereturn local title `"Multi-equation multi-model inference"'

ereturn local cmdline `"miinc me `0'"'

if ("`pip'" != "") ereturn matrix pip = import
	
ereturn hidden scalar impo = `=strlen("`pip'")'

if (`bestmodels' > 0) ereturn matrix best_models = best_mods

ereturn scalar bestic = `bestic'

ereturn hidden scalar nobest = `bestmodels'

/*begin display*/
Display

end


/*Display program*/
program define Display

local diivs: colnames e(b)

tokenize `diivs'

local dieqs: coleq e(b)

local dv = abbrev("`e(depvar)'", 12)

display _newline "{txt}Model averaged coefficients" _newline ///
"{txt}{col 56}Number of obs{col 70}={res}{col 72}" %7.0f e(N) 

display "{txt}{col 56}Best `e(ic)'{col 70}={res}{col 72}" %7.1f e(bestic)

display _newline "{txt}{hline 13}{c TT}{hline 64}"

if ("`e(miinc)'" == "se") display "{txt}{ralign 12:`e(depvar)'}{txt}{col 14}{c |}{col 21}Coef.{col 29}Std. Err.{col 44}`e(test)'{col 49}P>|`e(test)'|" ///
"{col 59}[95% Conf. Interval]"

else display "{txt}{ralign 12:}{txt}{col 14}{c |}{col 21}Coef.{col 29}Std. Err.{col 44}`e(test)'{col 49}P>|`e(test)'|" ///
"{col 59}[95% Conf. Interval]"

display "{txt}{hline 13}{c +}{hline 64}"

forvalues x = 1/`:list sizeof diivs' {

	local di`x' = abbrev("``x''", 12)
	
	if ((("`:word 1 of `dieqs''" != "") & (`:word count `:list uniq dieqs'' > 1)) | ("`e(miinc)'" == "me")) {
	
		if ("`currenteq'" != "`: word `x' of `dieqs''") {
		
			if ("`currenteq'" != "") display "{txt}{hline 13}{c +}{hline 64}"
		
			local eq = abbrev("`: word `x' of `dieqs''", 12)
		
			display "{res}`eq'{col 14}{txt}{c |}" 
			
		}
		
		local currenteq "`: word `x' of `dieqs''"
		
		local `x' "`currenteq':``x''"
	
	}
	
	local pval "normal(-abs(`=_b[``x'']/_se[``x'']'))"

	local ci_low "`=_b[``x'']+_se[``x'']*invnormal(.025)'"

	local ci_high "`=_b[``x'']+_se[``x'']*invnormal(.975)'"

	if ("`e(test)'" == "t") {

		local pval "ttail(e(N)-2, abs(`=_b[``x'']/_se[``x'']'))*2"
	
		local ci_low "`=_b[``x'']-_se[``x'']*invttail(e(N)-2, .025)'"
	
		local ci_high "`=_b[``x'']+_se[``x'']*invttail(e(N)-2, .025)'"
	
	}
	
	if (!regexm("``x''", "b\.") & !regexm("``x''", "o\.")) display "{txt}{ralign 12:`di`x''}{col 14}{c |}{res}{col 17}" %9.0g _b[``x''] ///
	"{col 28}" %9.0g _se[``x''] "{col 39}" %7.2f `=_b[``x'']/_se[``x'']' "{col 49}" %4.3f `pval' ///
	"{col 58}" %9.0g `ci_low' "{col 70}" %9.0g `ci_high'
}

display "{txt}{hline 13}{c BT}{hline 64}"

if (e(impo)) {

	display "{txt}`=e(ic)'-weight posterior inclusion probability" _newline "{hline 78}"
	
	matrix list e(pip), noheader format(%10.9f)
	
	display "{txt}{hline 78}"
	
}

if (e(nobest)) {

	display "{txt}Best models based on `=e(ic)'" _newline "{hline 78}"
	
	matrix list e(best_models), noheader format(%12.4f)
	
	display "{txt}{hline 78}"
	
}

if (e(sets)) {

	forvalues x = 1/`=e(sets)' {

		display "{txt}Set`x': `e(set`x')'"
		
	}
	
}

if strlen("`e(all)'") display "{txt}Included in all subsets: `e(all)'"

end

/*Mata function to compute all tuples of predictors or predictor sets
run all subsets regression, and compute all dominance criteria*/
version 12.1

mata: 

//mata clear - adversely affects mi estimate functionality and is now omitted

mata set matastrict on

void miinc(string scalar ivs, string scalar matcher, string scalar ic, real scalar models, string scalar constrs, ///
string scalar all) 
{
	/*object declarations*/
	real matrix include, noinclude, design, coeffs, vcov, v_mat, mavcov, sumvcov

	string matrix tuples, modnames, cns_tuples

	real rowvector fits, counts, combsinc, combsinc2, b_vec, macoeffs, ics, takecoeff, t_base, t_combin

	string rowvector preds, matchnames, modelnames, impnames, t_tuple

	real colvector base, combin, combincpt, indicator, rowcol

	string colvector iv_mat, tuple, fvtuple, cns_mat, alltokens
	
	real scalar nvars, ntuples, display, countmodel, keeptuple, keep, count

	string scalar ivuse
	
	/*parse the predictor inputs*/	
	t = tokeninit(wchars = (" "), pchars = (" "), qchars = ("<>"))
	
	tokenset(t, ivs)
	
	iv_mat = tokengetall(t)'
	
	if (strlen(constrs)) {
	
		tokenset(t, constrs)
	
		cns_mat = tokengetall(t)'
	
	}
	
	if (strlen(all)) alltokens = tokens(all)'	//neues
	
	/*remove characters binding sets together*/
	for (i = 1; i <= rows(iv_mat); i++) {
	
		if (substr(iv_mat[i], 1, 1) == "<") {
		
			iv_mat[i] = substr(iv_mat[i], 1, strlen(iv_mat[i]) - 1)
			
			iv_mat[i] = substr(iv_mat[i], 2, strlen(iv_mat[i]))
			
			if (strlen(constrs)) {
			
				cns_mat[i] = substr(cns_mat[i], 1, strlen(cns_mat[i]) - 1)
			
				cns_mat[i] = substr(cns_mat[i], 2, strlen(cns_mat[i]))
				
			}
			
		}
		
	}
	
	/*set-up and compute all n-tuples of predictors and predictor sets*/
	nvars = rows(iv_mat)
	
	if (nvars > 4) printf("\n{txt}Computing all predictor combinations\n")

	tuples = J(rows(iv_mat), 1, "")
	
	if (strlen(constrs)) cns_tuples = J(rows(cns_mat), 1, "")

	for (x = nvars; x >= 1; x--) {

		base = J(x, 1, 1)
	
		base = (base \ J(nvars - x, 1, 0))
	
		basis = cvpermutesetup(base)
	
		for (y = 1; y <= comb(nvars, x); y++) {
		
			keeptuple = 1
	
			combin = cvpermute(basis)
		
			tuple = iv_mat:*combin
			
			if (sum(regexm(tuple, "#")) > 0) {
			
				if (strlen(all)) tuple = (alltokens \ tuple)
			
				keeptuple = 0
			
				fvtuple = select(tuple, regexm(tuple, "#"))
			
				for (z = 1; z <= rows(fvtuple); z++) {
			
					t = tokeninit(wchars = (" "), pchars = ("#"))
	
					tokenset(t, fvtuple[z])
	
					fv_mat = tokengetall(t)
				
					if (cols(fv_mat) == 3) {
						
						if (strlen(constrs)) keep = sum(strmatch(tuple, subinstr(fv_mat[1], "c.", "")) ///
						+ strmatch(tuple, tokens(fv_mat[1], ":")[1] + ":" + subinstr(fv_mat[3], "c.", "")))
						
						else keep = sum(strmatch(tuple, subinstr(fv_mat[1], "c.", "")) ///
						+ strmatch(tuple, subinstr(fv_mat[3], "c.", "")))
						
						if (keep == ceil(cols(fv_mat)/2)) keep = 1
					
						else keep = 0
				
					}
				
					else {			
					
						keep = 0
				
						fv_mat = select(fv_mat, fv_mat:!="#")
						
						for (w = cols(fv_mat); w >= 1; w--) {				
						
							t_base = J(1, w, 1)
	
							t_base = (t_base, J(1, cols(fv_mat) - w, 0))
	
							t_basis = cvpermutesetup(t_base')
							
							for (v = 1; v <= comb(cols(fv_mat), w); v++) {
							
								t_combin = cvpermute(t_basis)'
								
								t_tuple = select(fv_mat, t_combin)
								
								if (sum(t_combin) > 1) {
								
									count = 2
								
									while (count <= cols(t_tuple)) {
								
										t_tuple[1] = t_tuple[1] + "#" + t_tuple[count++]
										
										if ((strlen(constrs)) & !regexm(t_tuple[1], tokens(fv_mat[1], ":")[1])) ///
										t_tuple[1] = tokens(fv_mat[1], ":")[1] + ":" + t_tuple[1]
								
									}
																	
									keep = keep + sum(strmatch(tuple, t_tuple[1]))
									
								}
								
								else if ((sum(t_combin) == 1) & !regexm(t_tuple[1], ":") & regexm(fv_mat[1], ":")) {
								
									keep = keep + sum(strmatch(tuple, tokens(fv_mat[1], ":")[1] + ":" + ///
									subinstr(t_tuple[1], "c.", "")))
									
									
								}
								
								else {
								
									keep = keep + sum(strmatch(tuple, subinstr(t_tuple[1], "c.", "")))
									
									
								}
							
							}
						
						}
						
						if (keep == 2^cols(fv_mat) - 1) keep = 1
						
						else keep = 0
				
					}
					
					keeptuple = keeptuple + keep
					
				}
				
				if (keeptuple == rows(fvtuple)) keeptuple = 1
				
				else keeptuple = 0
				
				if (strlen(all)) tuple = tuple[rows(alltokens)+1..rows(tuple), .]
			
			}
			
			if ((keeptuple == 1) & !(strlen(constrs))) tuples = (tuples, tuple)
			
			else if ((keeptuple == 1) & (strlen(constrs))) {
			
				tuple = cns_mat:*abs(combin:-1)
				
				cns_tuples = (cns_tuples, tuple)
			
			}
		
		}
	
	}
	
	if (strlen(constrs)) tuples = (cns_tuples[., 2..cols(cns_tuples)], cns_mat)
	
	else tuples = (tuples[., 2..cols(tuples)], J(nvars, 1, ""))
	
	ntuples = cols(tuples)
	
	printf("\n{txt}Total of {res}%f {txt}regressions\n", ntuples)
	
	/*all subsets regressions and progress bar syntax if predictors or sets of predictors is above 5*/
	display = 1
	
	countmodel = 0
	
	if (ntuples > 19) {
	
		printf("\n{txt}Progress in running all regression subsets\n{res}0%%{txt}{hline 6}{res}50%%{txt}{hline 6}{res}100%%\n")
		
		printf(".")
		
		displayflush()
		
	}

	fits = (.)
	
	matchnames = ("", tokens(matcher))
	
	coeffs = J(1, cols(matchnames), .)
	
	vcov = J(1, cols(matchnames) + 1, .)
	
	for (x = 1; x <= ntuples; x++) {
	
		countmodel++
	
		if (ntuples > 19) {
	
			if (floor(x/ntuples*20) > display) {
			
				printf(".")
				
				displayflush()
				
				display++	
				
			}
			
		}

		preds = tuples[., x]'
	
		ivuse = invtokens(preds)
	
		st_local("ivuse", ivuse)
	
		coeffs = (coeffs \ J(1, cols(coeffs), 0))
			
		vcov = (vcov \ J(cols(coeffs) - 1, cols(vcov), 0))
		
		if (strlen(constrs)) stata("\`reg' constraints(\`ivuse')", 1)

		else stata("\`reg' \`dv' \`all' \`ivuse' \`wtpre'\`weight'\`exp'\`wtpost' if \`touse', \`regopts'", 1)
			
		stata("getic, type(\`ic') ll(\`ll') parm(\`parm') obs(\`obs')", 1)
		
		coeffs[rows(coeffs), 1] = st_numscalar("r(ic)")
			
		vcov[rows(vcov)-cols(coeffs)+2..rows(vcov), 2] = J(cols(coeffs) - 1, 1, 1):*st_numscalar("r(ic)")
			
		vcov[rows(vcov)-cols(coeffs)+2..rows(vcov), 1] = J(cols(coeffs) - 1, 1, 1):*countmodel
			
		b_vec = st_matrix("e(b)")
			
		v_mat = st_matrix("e(V)")
			
		modelnames = tokens(st_macroexpand("\`: colfullnames e(b)'"))	
		
		vcov[rows(vcov)-cols(vcov)+3..rows(vcov), 3..cols(vcov)] ///
		= (strmatch(modelnames', matchnames[2..cols(matchnames)])#J(rows(v_mat),1,1))'*(strmatch(J(rows(v_mat), ///
		1, modelnames'), matchnames[2..cols(matchnames)]):*vec(v_mat))
		
		coeffs[rows(coeffs), 2..cols(coeffs)] = colsum(strmatch(modelnames', matchnames[2..cols(matchnames)]):*b_vec')

	}
	
	st_numscalar(st_macroexpand("\`bestic'"), min(coeffs[2..., 1]))
	
	if (models > 0) {
	
		include = (coeffs[2..rows(coeffs), 1], coeffs[2..rows(coeffs), 2..cols(coeffs)])
		
		include = select(sort(include, 1), (1::rows(include)):<=models)
		
		st_matrix("best_mods", (include[., 1]:-min(coeffs[2..., 1]), ///
		exp(ln(abs(include[., 2..cols(include)]))):*sign(include[., 2..cols(include)])))
	
	}
	
	coeffs[2..., 1] = coeffs[2..., 1]:-min(coeffs[2..., 1])

	if (ic == "noic") coeffs[2..., 1] = coeffs[2..., 1] = coeffs[2..., 1]:+1
	
	else coeffs[2..., 1] = exp(coeffs[2..., 1]:*-1/2)
	
	coeffs[2..., 1] = coeffs[2..., 1]:*sum(coeffs[2..., 1])^-1
	
	macoeffs = coeffs[2..., 2..cols(coeffs)]:*coeffs[2..., 1] 	
	
	macoeffs = colsum(macoeffs)
	
	mavcov = J(cols(coeffs) - 1, cols(coeffs) - 1, 0)
	
	for (x = 1; x <= countmodel; x++) {
	
		ics = J(rows(mavcov), 1, 1):*coeffs[x+1, 1]
	
		sumvcov = select(vcov[., 3..cols(vcov)], vcov[., 1]:==x)
		
		sumvcov = sumvcov + (coeffs[x+1, 2..cols(coeffs)] - macoeffs)'*(coeffs[x+1, 2..cols(coeffs)] - macoeffs)
		
		sumvcov = sumvcov:*ics
		
		mavcov = mavcov + sumvcov
	
	}
	
	//determining pip - first, take out any ests in "all" models
	include = coeffs[2..rows(coeffs), 2..cols(coeffs)]:!=0
	
	impnames = select(tokens(matcher), colsum(include):<rows(include))
	
	include = coeffs[2..rows(coeffs), 1]:*select(include, colsum(include):<rows(include))
	
	include = colsum(include)
	
	st_matrix("coeffs", macoeffs)
	
	st_matrix("vcov", mavcov)
	
	if (import != "") {
	
		st_matrix("import", include)
	
		st_local("impnames", invtokens(impnames))
		
	}
	
}

end


//program to obtain information criteria
program define getic, rclass

syntax, type(string) ll(string) parm(string) obs(string)

if ("`type'" == "aicc") return scalar ic = -2*`ll'+2*`parm'+(2*`parm'*`parm' + 1)/(`obs' - `parm' - 1)

else if ("`type'" == "aic") return scalar ic = -2*`ll'+2*`parm'

else if ("`type'" == "bic") return scalar ic = -2*`ll'+`parm'*ln(`obs')

else if ("`type'" == "noic") return scalar ic = 1

else if ("`type'" == "qic") return scalar ic = r(qic)

else if ("`type'" == "aicw") {

	tempname ilog gdeff
	
	matrix `ilog' = e(ilog)
	
	mata: ilog = select(st_matrix("`ilog'"), abs(sign(st_matrix("`ilog'"))))
	
	mata: st_matrix("`ilog'", ilog[1, cols(ilog)])
	
	matrix `gdeff' = trace(invsym(e(V_srs))*e(V))
	
	return scalar ic = -2*`ilog'[1,1]*(e(N)/e(N_pop))+2*`gdeff'[1,1]

}

else exit 198

end

/* programming notes and history

- miinc version 1.0 - date - May 5, 2014

Basic version

-----

- miinc version 2.0 - date - August 7, 2014

//notable changes\\
a] - addition of multiple equation (miinc me) option for models, estimated with ml and accepting constraints()
b] - expanded ll, parm and N options to allow the user to specify which  scalars (of any kind) correspond to each number used 
to compute information criteria
c] - option to allow parameters to be tested against t distribution instead of z (option ttest)
d] - xtgee models are now allowed to be used in miinc with the qic - which requires the user-written qic command
e] - svy prefixed estimates now allowed to be model averaged with an approximate Rao-Scott adjustment
f] - fixed issue with factor var's in miinc se in which factor variables are dropped unexpectedly
g] - fixed mata error issue with mi estimate

-----

*/
