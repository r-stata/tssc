*! domin version 3.2 4/8/2016 Joseph N. Luchman

program define domin, eclass //history and version information at end of file

version 12.1

if replay() { //replay results - error if "by"

	if ("`e(cmd)'" != "domin") error 301
	
	if _by() error 190
	
	Display `0'
	
	exit 0
	
}

syntax varlist(min = 1 ts) [in] [if] [aw pw iw fw] , [Reg(string) Fitstat(string) Sets(string) /// define syntax
All(varlist fv ts) noCOMplete noCONditional EPSilon mi miopt(string) CONSmodel REVerse]

/*defaults and warnings*/
if !strlen("`reg'") { //if no "reg" option specified - notify and use default "regress"

	local reg "regress"	
	
	display "{err}Regression type not entered in {opt reg()}. " _newline ///
	"{opt reg(regress)} assumed." _newline
	
}

if !strlen("`fitstat'") & !strlen("`epsilon'") { //if no "fitstat" and "epsilon" options specified - notify and make default "e(r2)"

	local fitstat "e(r2)"
	
	display "{err}Fitstat type not entered in {opt fitstat()}. " _newline ///
	"{opt fitstat(e(r2))} assumed." _newline
	
}

if strlen("`epsilon'") & strlen("`fitstat'") {	//warning if any "reg" or "fitstat" option specified with "epsilon"

	display "{err}Option {opt epsilon} cannot be used with {opt fitstat(e(r2))}." _newline ///
	"Entries in {opt fitstat()} ignored." _newline

}

if !strlen("`mi'") & strlen("`miopt'") {	//warning if "miopt" is used without "mi"

	local mi "mi"
	
	display "{err}You have added {cmd:mi estimate} options without adding the {opt mi} option.  {opt mi} assumed." _newline

}

/*exit conditions*/
if strlen("`epsilon'") & strlen("`sets'") {	//"epsilon" and "sets" cannot go together 

	display "{err}Options {opt epsilon} and {opt sets()} not allowed together."
	
	exit 198

}

if strlen("`epsilon'") & strlen("`all'") {	//"epsilon" and "all" cannot go together

	display "{err}Options {opt epsilon} and {opt all()} not allowed together."
	
	exit 198

}

if strlen("`epsilon'") & strlen("`consmodel'") {	//"epsilon" and "consmodel" cannot go together

	display "{err}Options {opt epsilon} and {opt consmodel} not allowed together."
	
	exit 198

}

if strlen("`epsilon'") & strlen("`reverse'") 	///"epsilon" and "reverse" cannot go together
display "{err}Options {opt epsilon} and {opt reverse} not allowed together." _newline ///
"{opt reverse} ignored."
	

if strlen("`epsilon'") & strlen("`weight'") {	//"epsilon" disallows weights

	display "{err}Option {opt epsilon} does not allow {opt weight}s."
	
	exit 198

}

if strlen("`epsilon'") & strlen("`mi'") {	//"epsilon" and multiple imputation options cannot go together

	display "{err}Options {opt epsilon} and {opt mi} not allowed together."
	
	exit 198

}

if strlen("`mi'") {	//are data actually mi set?

	capture mi describe

	if _rc {	//if data are not mi set

		display "{err}Data are not {cmd:mi set}."
	
		exit `=_rc'
		
	}
	
	if !r(M) {	//exit if no imputations
	
		display "{err}No imputations for {cmd:mi estimate}." _newline
		
		exit 2001
	
	}

}

capture which lmoremata.mlib	//is moremata present?

if _rc {	//if moremata cannot be found, tell user to install it.

	display "{err}Module {cmd:moremata} not found.  Install {cmd:moremata} here {stata ssc install moremata}."
	
	exit 198

}

/*disallow complete and conditional with epsilon option*/
if strlen("`epsilon'") {

	local conditional "conditional"
	
	local complete "complete"
	
}

/*general set up*/
if strlen("`mi'") tempfile mifile	//produce a tempfile to store imputed fitstats for retreival

tempname ranks domwgts sdomwgts	cdldom cptdom //temporary matrices for results

gettoken dv ivs: varlist	//parse varlist line to separate out dependent from independent variables

gettoken reg regopts: reg, parse(",")	//parse reg() option to pull out estimation command options

if strlen("`regopts'") gettoken erase regopts: regopts, parse(",")	//parse out comma if one is present

local diivs "`ivs'"	//create separate macro to use for display purposes

local mkivs "`ivs'"	//create separate macro to use for sample marking purposes

if `:list sizeof sets' {	//parse and process the sets if included

	/*pull out set #1 from independent variables list*/
	gettoken one two: sets, bind	//pull out the first set
	
	local setcnt = 1	//give the first set a number that can be updated as a macro
	
	local one = regexr("`one'", "[/(]", "")	//remove left paren
			
	local one = regexr("`one'", "[/)]", "")	//remove right paren
	
	local set1 `one'	//name and number set
	
	local ivs "`ivs' <`set1'>"	//include set1 into list of independent variables, include characters for binding in Mata
	
	local mkivs `mkivs' `set1'	//include variables in set1 in the mark sample independent variable list
	
	local diivs "`diivs' set1"	//include the name "set1" into list of variables
	
	
	while strlen("`two'") {	//continue parsing beyond set1 so long at sets remain to be parsed (i.e., there's something in the macro "two")

		gettoken one two: two, bind	//again pull out a set
			
		local one = regexr("`one'", "[/(]", "")	//remove left paren
		
		local one = regexr("`one'", "[/)]", "")	//remove right paren
	
		local set`++setcnt' `one'	//name and number set - advance set count by 1
		
		local ivs "`ivs' <`set`setcnt''>"	//include further sets - separated by binding characters - into independent variables list
		
		local mkivs `mkivs' `set`setcnt''	//include sets into mark sample independent variables list
		
		local diivs "`diivs' set`setcnt'"	//include set number into display list
				
	}
			
}


if `:list sizeof ivs' < 2 {	//exit if too few predictors/sets (otherwise prodices cryptic Mata error)

	display "{err}{cmd:domin} requires at least 2 independent variables or independent variable sets."
	
	exit 198

}

/*finalize setup*/
tempvar touse keep	//declare sample marking variables

tempname obs allfs consfs	//declare temporary scalars

mark `touse'	//declare marking variable

quietly generate byte `keep' = 1 `if' `in' //generate tempvar that adjusts for "if" and "in" statements

markout `touse' `dv' `mkivs' `all' `keep'	//do the sample marking

local nobindivs = subinstr("`ivs'", "<", "", .)	//take out left binding character(s) for use in adjusting e(sample) when obs are dropped by an anslysis

local nobindivs = subinstr("`nobindivs'", ">", "", .)	//take out right binding character(s) for use in adjusting e(sample) when obs are dropped by an anslysis

if !strlen("`epsilon'") {	//don't invoke program checks if epsilon option is invoked

	if !strlen("`mi'") capture `reg' `dv' `nobindivs' `all' [`weight'`exp'] if `touse', `regopts'	//run overall analysis - probe to check for e(sample) and whether everything works as it should

	else {

		capture mi estimate, saving(`mifile') `miopt': `reg' `dv' `nobindivs' `all' [`weight'`exp'] if `keep', `regopts'	//run overall analysis with mi prefix - probe to check for e(sample) and whether everything works as it should

		if _rc {	//if something's amiss with mi...
		
			display "{err}Error in {cmd:mi estimate: `reg'}. See return code."
		
			exit `=_rc'
			
		}
		
		else estimates use `mifile', number(`:word 1 of `e(m_est_mi)'')	//if touse doesn't equal e(sample) - use e(sample) from first imputation and proceed
	
	}
	
	quietly count if `touse'	//tally up observations from count based on "touse"

	if r(N) > e(N) & !strlen("`mi'") quietly replace `touse' = e(sample)	//if touse doesn't equal e(sample) - use e(sample) and proceed; not possible with multiple imputation though

	if _rc {	//exit if regression is not estimable or program results in error - return the returned code

		display "{err}{cmd:`reg'} resulted in an error."
	
		exit `=_rc'

	}
	
	capture assert `fitstat' != .	//is the "fitstat" the user supplied actually returned by the command?
	
	if _rc {	//exit if fitstat can't be found

		display "{err}{cmd:`fitstat'} not returned by {cmd:`reg'} or {cmd:`fitstat'} is not scalar valued. See {help return list}."
	
		exit 198

	}

	capture assert sign(`fitstat') != -1	//what is the sign of the fitstat?  domin works best with positive ones - warn and proceed

	if _rc {

		display "{err}{cmd:`fitstat'} returned by {cmd:`reg'}." _newline ///
		"is negative.  {cmd:domin} is programmed to work best" _newline ///
		"with positive {opt fitstat()} summary statistics." _newline

	}
	
}

if !inlist("`weight'", "iweight", "fweight") & !strlen("`mi'") {	//if weights don't affect obs
	
	quietly count if `touse'	//tally up "touse" if not "mi"
	
	scalar `obs' = r(N)	//pull out the number of observations included
	
}

else if inlist("`weight'", "iweight", "fweight") & !strlen("`mi'") {	//if the weights do affect obs

	quietly summarize `=regexr("`exp'", "=", "")' if `touse'	//tally up "touse" by summing weights
	
	scalar `obs' = r(sum)	//pull out the number of observations included
	
}

else {

	quietly mi estimate, `miopt': regress `dv' `nobindivs' `all' [`weight'`exp'] if `keep'	//obtain estimate of obs when multiply imputed
	
	scalar `obs' = e(N)	//pull out the number of observations included

}
 
/*begin estimation*/
scalar `allfs' = 0	//begin by defining the fitstat of the "all" variables as 0 - needed for dominance() function

if `:list sizeof all' {	//if there are variables in the "all" list
	
	if !strlen("`mi'") {	//when there is no "mi" option specified
	
		quietly `reg' `dv' `all' [`weight'`exp'] if `touse', `regopts'	//run analysis with "all" independent variables only
	
		scalar `allfs' = `fitstat'	//the resulting "fitstat" is then registered as the value to remove from other fitstats
		
	}
	
	else {	//if "mi" is specified
	
		quietly mi estimate, saving(`mifile', replace) `miopt': `reg' `dv' `all' [`weight'`exp'] if `keep', `regopts'	//run mi analysis with "all" independent variables only
	
		mi_dom, name(`mifile') fitstat(`fitstat') list(`=e(m_est_mi)')	//call mi_dom program to average fitstats
		
		scalar `allfs' = r(passstat)	//the resulting average fitstat is then registered as the value to remove from other fitstats
	
	}

}

scalar `consfs' = 0	//begin by defining the fitstat of the constant-only model as 0 - needed for dominance() function

if strlen("`consmodel'") {	//if the user desires to know what the baseline fitstat is
	
	if !strlen("`mi'") {	//if "mi" is not declared
	
		quietly `reg' `dv' [`weight'`exp'] if `touse', `regopts'	//conduct analysis without independent variables
	
		scalar `consfs' = `fitstat'	//return baseline fitstat
		
	}
	
	else {	//if "mi" is declared
	
		quietly mi estimate, saving(`mifile', replace) `miopt': `reg' `dv' [`weight'`exp'] if `keep', `regopts'	//conduct mi analysis without independent variables
	
		mi_dom, name(`mifile') fitstat(`fitstat') list(`=e(m_est_mi)')	//compute average fitstat
		
		scalar `consfs' = r(passstat)	//return average baseline fitstat
	
	}
	
	if `:list sizeof all' scalar `allfs' = `allfs' - `consfs'
	
}

if strlen("`epsilon'") { //primary analysis when "epsilon" is invoked

	if ("`reg'" == "mvdom") `reg' `dv' `ivs' if `touse', `regopts' `epsilon'	//invoke the epsilon version of mvdom

	else mata: eps_ri("`dv' `ivs'", "`reg'", "`touse'", "`regopts'") //mata function to obtain epsilon-based estimates
	
	matrix `domwgts' = r(domwgts) //translate r-class matrix into temp matrix that domin expects
	
	matrix `sdomwgts' = `domwgts'*(1/r(fs))	//produce standardized relative weights (i.e., out of 100%)
	
	mata: st_matrix("`ranks'", mm_ranks(st_matrix("r(domwgts)")':*-1, 1, 1)')	//rank the relative weights

}

else {

	mata: dominance(`"`ivs'"', "`conditional'", "`complete'", `=`allfs'', `=`consfs'', "`mi'")	//invoke "dominance()" function in Mata
	
	/*translate r-class results into temp results*/
	matrix `domwgts' = r(domwgts)
	
	matrix `sdomwgts' = r(sdomwgts)
	
	matrix `ranks' = r(ranks)
	
	if !strlen("`conditional'") matrix `cdldom' = r(cdldom)
	
	if !strlen("`complete'") matrix `cptdom' = r(cptdom)
	
}

/*display results - this section will not be extensively explained*/
/*name matrices*/
matrix colnames `domwgts' = `diivs'	

if strlen("`reverse'") {	//reverse the direction and interpretation of rank and standardized weights

	mata: st_matrix("`sdomwgts'", (st_matrix("`domwgts'"):*-1):/sum(st_matrix("`domwgts'"):*-1))
	
	mata: st_matrix("`ranks'", ((st_matrix("`ranks'"):-1):*-1):+cols(st_matrix("`ranks'")))

}

matrix colnames `sdomwgts' = `diivs'	

matrix colnames `ranks' = `diivs'	

if !strlen("`complete'") { 	

	if strlen("`reverse'") mata: st_matrix("`cptdom'", st_matrix("`cptdom'"):*-1)

	matrix colnames `cptdom' = `diivs'	
	
	matrix coleq `cptdom' = dominated?	
	
	matrix rownames `cptdom' = `diivs'	
	
	matrix roweq `cptdom' = dominates?	
	
}

if !strlen("`conditional'") { 
	
	matrix rownames `cdldom' = `diivs'
	
	local colcdl `:colnames `cdldom''
	
	local colcdl = subinstr("`colcdl'", "c", "", .)
	
	matrix colnames `cdldom' = `colcdl'
	
	matrix coleq `cdldom' = #indepvars
	
}	

if !strlen("`epsilon'") & strlen("`e(title)'") local title "`e(title)'"

else if strlen("`epsilon'") & strlen("`e(title)'") local title "Epsilon-based `reg'"

else local title "Custom user analysis"

/*return values*/
ereturn post `domwgts' [`weight'`exp'], depname(`dv') obs(`=`obs'') esample(`touse')

if strlen("`setcnt'") {

	ereturn hidden scalar setcnt = `setcnt'

	forvalues x = 1/`setcnt' {
	
		fvunab set`x': `set`x''

		ereturn local set`x' "`set`x''"
		
	}
	
}

else ereturn hidden scalar setcnt = 0

ereturn hidden local dtitle "`title'"

ereturn hidden local reverse "`reverse'"

if `:list sizeof all' {

	fvunab all: `all'

	ereturn local all "`all'"
	
}

if strlen("`epsilon'") ereturn local estimate "epsilon" 

else ereturn local estimate "dominance"

if strlen("`mi'") {

	if strlen("`miopt'") ereturn local miopt "`miopt'"

	ereturn local mi "mi"

}

if strlen("`regopts'") ereturn local regopts `"`regopts'"'

ereturn local reg `"`reg'"'

ereturn local fitstat "`fitstat'"

ereturn local cmd `"domin"'

ereturn local title `"Dominance analysis"'

ereturn local cmdline `"domin `0'"'

ereturn scalar fitstat_o = r(fs)

if `:list sizeof all' ereturn scalar fitstat_a = `allfs'

if strlen("`consmodel'") ereturn scalar fitstat_c = `consfs'

if !strlen("`conditional'") ereturn matrix cdldom `cdldom'
	
if !strlen("`complete'") ereturn matrix cptdom `cptdom'

ereturn matrix ranking `ranks'

ereturn matrix std `sdomwgts'

/*begin display*/
Display

end

/*Display program*/
program define Display

version 12.1

tempname domwgts sdomwgts ranks

matrix `domwgts' = e(b)

matrix `sdomwgts' = e(std)

matrix `ranks' = e(ranking)

local diivs: colnames e(b)

mata: st_local("cdltest", strofreal(cols(st_matrix("e(cdldom)"))))

mata: st_local("cpttest", strofreal(cols(st_matrix("e(cptdom)"))))

tokenize `diivs'

local dv = abbrev("`e(depvar)'", 10)

display _newline "{txt}General dominance statistics: `e(dtitle)'" _newline ///
"{txt}Number of obs{col 27}={res}{col 40}" %12.0f e(N) 

display "{txt}Overall Fit Statistic{col 27}={res}{col 36}" %16.4f e(fitstat_o)

if !missing(e(fitstat_a)) display "{txt}All Subsets Fit Stat.{col 27}={res}{col 36}" %16.4f e(fitstat_a)

if !missing(e(fitstat_c)) display "{txt}Constant-only Fit Stat.{col 27}={res}{col 36}" %16.4f e(fitstat_c)

display _newline "{txt}{col 13}{c |}{col 20}Dominance{col 35}Standardized{col 53}Ranking"

display "{txt}{lalign 9: `dv'}{col 13}{c |}{col 20}Stat.{col 35}Domin. Stat." 

display "{txt}{hline 12}{c +}{hline 72}"

forvalues x = 1/`:list sizeof diivs' {

	local `x' = abbrev("``x''", 10)
	
	display "{txt}{col 2}{lalign 11:``x''}{c |}{col 14}{res}" %15.4f `domwgts'[1,`x'] ///
	"{col 29}" %12.4f `sdomwgts'[1,`x'] "{col 53}" %-2.0f `ranks'[1,`x']
	
}

display "{txt}{hline 12}{c BT}{hline 72}"

if `cdltest' {

	display "{txt}Conditional dominance statistics" _newline "{hline 85}"
	
	matrix list e(cdldom), noheader format(%12.4f)
	
	display "{txt}{hline 85}"
	
}

if `cpttest' {

	display "{txt}Complete dominance designation" _newline "{hline 85}"
	
	matrix list e(cptdom), noheader
	
	display "{txt}{hline 85}"
	
}

if e(estimate) == "dominance" & `=`cpttest'*`cdltest'' {

	display _newline "{res}Strongest dominance designations" _newline 

	tempname bestdom cdl gen decision
	
	if strlen("`e(reverse)'") mata: st_matrix("`bestdom'", st_matrix("e(cptdom)"):*-1)
	
	else matrix `bestdom' = e(cptdom)
	
	forvalues x = 1/`=colsof(e(cdldom))-1' {
	
		forvalues y = `=`x'+1'/`=colsof(e(cdldom))' {
		
			scalar `cdl' = 0
			
			scalar `gen' = 0
	
			mata: st_numscalar("`cdl'", (sum(st_matrix("e(cdldom)")[`x', .]:>st_matrix("e(cdldom)")[`y', .])):==rows(st_matrix("e(cdldom)"))) 
			
			if !`cdl' mata: st_numscalar("`cdl'", -1*((sum(st_matrix("e(cdldom)")[`x', .]:<st_matrix("e(cdldom)")[`y', .])):==rows(st_matrix("e(cdldom)"))))
			
			mata: st_numscalar("`gen'", st_matrix("e(b)")[1, `x']>st_matrix("e(b)")[1, `y'])
			
			if !`gen' mata: st_numscalar("`gen'", (st_matrix("e(b)")[1, `x']<st_matrix("e(b)")[1, `y'])*-1)
			
			local reverse_adj = cond(strlen("`e(reverse)'"), -1, 1)
			
			scalar `decision' = ///
			cond(abs(`bestdom'[`x', `y']) == 1, `bestdom'[`x', `y'], cond(abs(`cdl') == 1, `cdl'*2, cond(abs(`gen') == 1, `gen'*3, 0)))
			
			matrix `bestdom'[`x', `y'] = `decision'*`reverse_adj'
			
			matrix `bestdom'[`y', `x'] = -`decision'*`reverse_adj'
			
		}
	
	}
	
	local names `:colnames e(b)'
	
	mata: display((select(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==1):*" completely dominates "):+tokens(st_local("names")))', ///
	regexm(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==1):*" completely dominates "):+tokens(st_local("names")))', ///
	"completely dominates")) , ///
	select(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==2):*" conditionally dominates "):+tokens(st_local("names")))', ///
	regexm(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==2):*" conditionally dominates "):+tokens(st_local("names")))', ///
	"conditionally dominates")), ///
	select(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==3):*" generally dominates "):+tokens(st_local("names")))', ///
	regexm(vec(tokens(st_local("names"))':+((st_matrix("`bestdom'"):==3):*" generally dominates "):+tokens(st_local("names")))', ///
	"generally dominates")))')
	
	display ""

}

if `=e(setcnt)' {

	forvalues x = 1/`=e(setcnt)' {

		display "{txt}Variables in set`x': `e(set`x')'"
		
	}
	
}

if strlen("`e(all)'") display "{txt}Variables included in all subsets: `e(all)'"

end

/*Mata function to compute all tuples of predictors or predictor sets
run all subsets regression, and compute all dominance criteria*/
version 12.1

mata: 

mata set matastrict on

void dominance(string scalar ivs, string scalar cdlcompu, string scalar cptcompu, ///
real scalar allfs, real scalar consfs, string scalar mi) 
{
	/*object declarations*/
	real matrix include, noinclude, cdl, cdl1, cdl2, design, cpt, focus, rest, compare, eval, ///
	selector1, selector2, eval2, selector3, selector4, indicators

	string matrix tuples

	real rowvector fits, counts, combsinc, combsinc2, domwgts, sdomwgts

	string rowvector preds

	real colvector combin, cdl3, basecpt, combincpt, indicator, rowcol, basecpt2, combincpt2, ///
	revind

	string colvector iv_mat
	
	real scalar nvars, ntuples, display, fs, cptsum, comparecount, var1, var2, cptdom, x, y

	string scalar ivuse
	
	transmorphic basiscpt, basiscpt2, t, wchars, pchars, qchars
	
	/*parse the predictor inputs*/	
	t = tokeninit(wchars = (" "), pchars = (" "), qchars = ("<>")) //set up parsing rules
	
	tokenset(t, ivs) //register the "ivs" matrix as the one to be parsed
	
	iv_mat = tokengetall(t)' //obtain all IV sets and IVs
	
	/*remove characters binding sets together (i.e., "<>")*/
	for (x = 1; x <= rows(iv_mat); x++) {
	
		if (substr(iv_mat[x], 1, 1) == "<") { //if any entry begins with "<"...
		
			iv_mat[x] = substr(iv_mat[x], 1, strlen(iv_mat[x]) - 1) //first character removed ("<")
			
			iv_mat[x] = substr(iv_mat[x], 2, strlen(iv_mat[x])) //last character removed (">")
			
		}
		
	}
	
	/*set-up and compute all n-tuples of predictors and predictor sets*/
	nvars = rows(iv_mat) //compute total # of IV sets and IVs
	
	ntuples = 2^nvars - 1 //compute total # of regressions
	
	printf("\n{txt}Total of {res}%f {txt}regressions\n", ntuples)
	
	if (nvars > 12) printf("\n{txt}Computing all predictor combinations\n")

	indicators = J(nvars, 2^nvars, .)	//set up matrix to be filled in which will generate all subsets 
	
	for (x = 1; x <= rows(indicators); x++) {	//for each row in indicators matrix...
	
		combin = J(1, 2^(x-1), 0), J(1, 2^(x-1), 1)	//make a binary matrix - start small, a zero and a 1, then 2 0's and 2 1's, etc...
		
		indicators[x, .] = J(1, 2^(nvars-x), combin)	//spread the binary matrix just created across all rows - net effect is staggering all binaries to obtain all subsets in the final matrix
		
	}
	
	indicators = indicators[|., 2\ ., .|]	//omit the first, null column
	
	indicators = (colsum(indicators) \ indicators)'	//create a "counts" column on which to sort
	
	indicators = sort(indicators, (1..cols(indicators)))	//sort, beginning with counts, followed by all other rows - net effect results in same sort order as cvpermute()
	
	indicators = indicators[|1, 2\ ., .|]'	//omit count's column created before
	
	indicators = sort(((cols(indicators)::1), indicators'), 1)[., 2..rows(indicators)+1]'	//reverse sort order, dominance() expects reversed order
	
	tuples = indicators:*iv_mat	//apply string variable names to all subsets indicator matrix
	
	/*all subsets regressions and progress bar syntax if predictors or sets of predictors is above 5*/
	display = 1 //for the display of dots during estimation - keeps track of where the regressions are - every 5% there is another "." added
	
	if (nvars > 4) {
	
		printf("\n{txt}Progress in running all regression subsets\n{res}0%%{txt}{hline 6}{res}50%%{txt}{hline 6}{res}100%%\n")
		
		printf(".")
		
		displayflush()
		
	}

	fits = (.) //dummy vector that will contain fitstats across all 
	
	for (x = 1; x <= ntuples; x++) { //here all regressions 
	
		if (nvars > 4) {
	
			if (floor(x/ntuples*20) > display) {
			
				printf(".")
				
				displayflush()
				
				display++	
				
			}
			
		}

		preds = tuples[., x]' //take the names in column "x" and transpose into row
	
		ivuse = invtokens(preds) //collpase names into single string separated by spaces
	
		if (strlen(mi) == 0) { //regular regression
		
			stata("\`reg' \`dv' \`all' " + ivuse + " [\`weight'\`exp'] if \`touse', \`regopts'", 1) //conduct regression
		
			fs = st_numscalar(st_local("fitstat")) - allfs - consfs //record fitstat omitting constant and "all" subsets values
			
		}
		
		else { //regression with "mi estimate:"
		
			stata("mi estimate, saving(\`mifile', replace) \`miopt': \`reg' \`dv' \`all' " + ivuse + ///
			" [\`weight'\`exp'] if \`keep', \`regopts'", 1) //conduct regression with "mi estimate:"
		
			stata("mi_dom, name(\`mifile') fitstat(\`fitstat') list(\`=e(m_est_mi)')", 1) //use built-in program to obtain average fitstat across imputations
			
			fs = st_numscalar("r(passstat)") - allfs - consfs //record fitstat omitting constant and "all" subsets values with "mi estimate:"
		
		}
	
		fits = (fits, fs) //add fitstat to vector of fitstats

	}
	
	fits = fits[2..ntuples + 1] //only keep non-empty fitstats (i.e., omit the first empty one)

	/*define the incremental prediction matrices and combination rules*/
	include = sign(strlen(tuples)) // matrix indicating whether variable included in any regression associated with the "fits" vector

	counts = colnonmissing(exp(ln(include))) //# of variables in each regression

	noinclude = (include:-1) //matrix indicating whether variable not included in any regression associated with the "fits" vector
	
	combsinc = J(1, ntuples, 1):*comb(nvars, counts) //matrix indicating the number of combinations at each "order"/# of predictors
	
	combsinc2 = J(1, ntuples, 1):*comb(nvars - 1, counts) //matrix indicating the number of combinations at each "order"/# of predictors - 1
	
	combsinc2 = (0, combsinc2[., 2..ntuples]) //add a 0 to # combinations.. omit first "." value
	
	combsinc = combsinc - combsinc2 //remove # of combinations for the "order" less the value at "order" - 1
	
	include = include:*combsinc //put all the adjusted combination counts into matrix when the variable is included
	
	noinclude = noinclude:*combsinc2 //put all the "order" - 1 combination counts into matrix when the variable is not included
	
	/*compute conditional dominance*/
	if (strlen(cdlcompu) == 0) {
	
		if (nvars > 5) printf("\n\n{txt}Computing conditional dominance\n")
	
		cdl = J(nvars, nvars, 0) //dummy matrix to hold conditional dominance stats
		
		/*loop over orders (i.e., # of predictors) to obtain average incremental prediction within order*/
		for (x = 1; x <= nvars; x++) { //proceed order by order
		
			cdl1 = include:^-1 //invert the counts for indluded (as it makes the within-order averages)
				
			cdl2 = noinclude:^-1 //invert the counts for non-indluded (as it makes the within-order averages)
			
			cdl1 = select(cdl1:*fits, counts:==x) //at the focal order, obtain weighted fitstats
			
			if (x > 1) { // at all orders (>1) where the marginal contribution != to the fitstat itself
			
				cdl2 = select(cdl2:*fits, counts:==x-1) //weighted marginal contribution to fitstat at order - 1
				
				cdl3 = rowsum(cdl1) + rowsum(cdl2) //sum the marginal contributions (cdl2 values are negative)
				
			}
				
			else cdl3 = rowsum(cdl1) //sum the marginal contributions @ order 1
						
			cdl[., x] = cdl3 //replace the entries in cdl with the current values of cdl3, these are the within-order averages
		
		}
		
		st_matrix("r(cdldom)", cdl) //return r-class matrix "cdldom"
	
	}
	
	/*define the full design matrix - compute general dominance (average conditional dominance across orders)*/
	design = (include + noinclude):*nvars //create matrix that will have positive and negative signs in the correct places to obtain marginals - weight by number of variables total (between-order average of within-order averages)
	
	design = design:^-1 //invert design matrix to create weights
	
	domwgts = colsum((design:*fits)') //general dominance weights created by computing product of weights and fitstats and summing for each IV
	
	fs = rowsum(domwgts) + allfs + consfs //total fitstat is then sum of gen. dom. wgts replacing the constant-only model and the "all" subsets stat

	st_matrix("r(domwgts)", domwgts) //return the general dom. wgts as r-class matrix

	sdomwgts = domwgts:*fs^-1 //generate the standardized gen. dom. wgts
	
	st_matrix("r(sdomwgts)", sdomwgts) //return the stdzd general dom. wgts as r-class matrix
	
	st_matrix("r(ranks)", mm_ranks(domwgts'*-1, 1, 1)') //return the ranks of the general dom. wgts as r-class matrix

	st_numscalar("r(fs)", fs) //return overall fit statistic in r-class scalar
	
	/*compute complete dominance*/
	if (strlen(cptcompu) == 0) {
	
		if (nvars > 5) printf("\n{txt}Computing complete dominance\n")

		cpt = J(nvars, nvars, 0) //dummy matrix for complete dominance
		
		basecpt = (J(2, 1, 1) \ J(nvars - 2, 1, 0)) //generate the "base" of the compare each 2 IVs
	
		basiscpt = cvpermutesetup(basecpt) //setup for the permutations
		
		indicator = (1::nvars) //generate "indicator" for which variables are being compared
		
		for (x = 1; x <= comb(nvars, 2); x++) {  
		
			combincpt = cvpermute(basiscpt) //invoke the current combination of 2 variables
		
			rowcol = select(combincpt:*indicator, combincpt:==1) //note the row in which both variables being comapred are located
		
			focus = select(sign(strlen(tuples)), combincpt:==1) //make a selector (1 vs. 0) matrix for pulling out all fitstats, only on focal IVs
		
			rest = select(sign(strlen(tuples)), combincpt:==0) //make a selector (1 vs. 0) matrix for pulling out all fitstats, only on non-focal IVs
			
			cptsum = 0 //used as a index for determining complete dominance for the current comparison of 2 IVs
			
			compare = focus:*fits //create matrix of fitstats that correspond only to the focal comparisons
			
			for (y = 1; y <= nvars - 1; y++) { //for each order (up to # IVs - 1)
			
				eval = select(compare, counts:==y) //on the filtered fitstat matrix, pull out comparisons at a specific order
				
				selector1 = select(focus, counts:==y) //on the indicator matrix, pull out comparisons at a specific order
				
				selector1 = colsum(selector1) //on the filtered indicator matrix of order "y", enumerate # of IVs in each model
				
				selector2 = select(rest, counts:==y) //on the indicator matrix of non-focal vars, pull out comparisons at a specific order
				
				comparecount = 1 //counter to keep track of # of comparisons
				
				basecpt2 = (J(y - 1, 1, 1) \ J(nvars - y - 1, 1, 0)) //another looped permutation to make all the specific comparisons w/in order
				
				/*make comparisons between fitstat's - matching on predictors*/
				while ((comparecount <= comb(nvars - 2, y - 1)) & (nvars > 2)) { //so long as there are > 2 IVs... loop for all comparisons
					
					if (y == 1) eval2 = select(eval, selector2[comparecount, .]:==0) //fitstats when only focal IV is in the model (y = 1 per row, i.e., the focal IVs)
					
					else if (y == 2) { //fitstats when 1 other non-focal variable is in the model
					
						eval2 = select(eval, selector1:==1)	//select the fitstats when only the focal IVs are in the model (i.e., not both IVs)
						
						selector3 = select(selector2, selector1:==1) //pull out the columns where there also the other non-focal IV
					
						eval2 = select(eval2, selector3[comparecount, .]:==1) //then select the fitstats where there are only the focal IVs (alone) with the non-focal IV
					
					}
					
					else { //fitstats when >=2 variables are in the model
						
						eval2 = select(eval, selector1:==1) //select the fitstats when only the focal IVs are in the model (i.e., not both IVs)
						
						selector3 = select(selector2, selector1:==1) //pull out the columns where there also the other non-focal IV
						
						basiscpt2 = cvpermutesetup(basecpt2) //set-up permutation of >1 variable to select all possible combinations
						
						combincpt2 = cvpermute(basiscpt2)*10 //activate permutation of >1 variable to select all possible combinations (rescaled by 10 for use in exponentiating)
										
						revind = (nvars - 2::1) //used for exponentiation below
						
						selector4 = J(nvars - 2, 1, 10) //base matrix to use for selecting fitstats - adjusted below
						
						combincpt2 = combincpt2:^revind*(1/10) //matrix which now indicates location of a variable positionally by # of 0s (re-scaled back down by 10)
						
						selector4 = selector4:^revind*(1/10) //obtain a selection matrix which is scaled the sdame as the combination matrix above
						
						selector4 = selector3:*selector4 //rescale the "selector3" matrix with only the current non-focal IVs are selected
						
						selector4 = colsum(selector4) //make selector4 a rowmat so select() can use it
						
						combincpt2 = colsum(combincpt2)	//make combincpt2 a rowmat so select() can use it
						
						eval2 = select(eval2, selector4:==combincpt2) //obtain only one specific combination of the non-focal IVs for the comparison				
					
					}
				
					/*here the comparison is actually made and "cptsum" is updated*/
					var1 = rowsum(eval2[1, .]) //all the fitstats in row 1 call "var1" - sum them (there should only be 1)
				
					var2 = rowsum(eval2[2, .]) //all the fitstats in row 2 call "var2" - sum them (there should only be 1)
				
					cptdom = sign(var1 - var2) //is one bigger than the other? Keep sign only 
								
					cptsum = cptsum + cptdom //add sign to current sum
					
					comparecount++ //increment comparecount and evaluate the while statement above...
					
				}
				
			}
			
			/*determine completely dominate, dominated by or none*/
			if (nvars == 2) cptsum = sign(rowsum(compare[1, .]) - rowsum(compare[2, .])) //simple situation w/ 2 predictors
		
			if (cptsum == 2^(nvars - 2)) cpt[rowcol[1, 1], rowcol[2, 1]] = 1 //if all the cptdom comarisons were "+" then, there is complete dominance for "var1"
		
			else if (cptsum == -2^(nvars - 2)) cpt[rowcol[1, 1], rowcol[2, 1]]= -1 //if all the cptdom comarisons were "-" then, there is complete dominance for "var2"
		
			else cpt[rowcol[1, 1], rowcol[2, 1]] = 0 //otherwise no complete dominance
	
		}
		
		cpt = cpt + cpt'*-1 ///*make cptdom matrix symmetric in what it is telling the user*/
	
		st_matrix("r(cptdom)", cpt) //return r-class matrix "cptdom"
	
	}
	
}

end

/*program to average fitstat across all multiple imputations for use in domin*/
program define mi_dom, rclass

version 12.1

syntax, name(string) fitstat(string) list(numlist)

tempname passstat

scalar `passstat' = 0 //placeholder scalar to hold the sum

foreach x of numlist `list' {

	estimates use `name', number(`x') //find the focal estimates
	
	scalar `passstat' = `passstat' + `fitstat'*`:list sizeof list'^-1 //add in the weighted fitstat value

}

return scalar passstat = `passstat' //average fitstat = the MI'd fitstat

end

/*Mata function to execute epsilon-based relative importance*/
version 12.1

mata: 

mata set matastrict on

void eps_ri(string scalar varlist, string scalar reg, string scalar touse, string scalar regopts) 
{
	/*object declarations*/
	real matrix X, L, R, Lm, glmdat, glmdats, L2, R2, orth

	real rowvector V, Bt, V2, glmwgts, varloc
	
	string rowvector orthnames
	
	real scalar sd_yhat, cor_yhat
	
	string scalar predmu
	
	/*begin processing*/
	X = correlation(st_data(., tokens(varlist), st_varindex(touse))) //obtain correlations
	
	L = R = X[2..rows(X), 2..cols(X)] //set-up for svd()
	
	V = J(1, cols(X)-1, .) //placeholder for eigenvalues
	
	svd(X[2..rows(X), 2..cols(X)], L, V, R) //conduct singular value decomposition
	
	Lm = (L*diag(sqrt(V))*R) //process orthogonalized predictors
	
	if (reg == "regress") Bt = invsym(Lm)*X[2..rows(X), 1] //obtain adjusted regression weights
	
	else if (reg == "glm") { //if glm-based...
	
		glmdat = st_data(., tokens(varlist), st_varindex(touse)) //pull data into Mata
		
		L2 = R2 = glmdat[., 2..cols(glmdat)] //set-up for svd()
		
		V2 = V //placeholder for eigenvalues
		
		glmdats = (glmdat[., 2..cols(glmdat)]:-mean(glmdat[., 2..cols(glmdat)])):/sqrt(diagonal(variance(glmdat[., 2..cols(glmdat)])))' //standardize the input data
	
		svd(glmdats, L2, V2, R2) //conduct singular value decomposition on full data
		
		orth = L2*R2 //produce the re-constructed orthogonal predictors for use in regression
		
		orth = (orth:-mean(orth)):/sqrt(diagonal(variance(orth)))' //standardize the orthogonal predictors
		
		orthnames = st_tempname(cols(orth))
		
		varloc = st_addvar("double", orthnames) //generate some tempvars for Stata
		
		st_store(., orthnames, st_varindex(touse), orth) //put the orthogonalized variables in Stata
		
		stata("capture " + reg + " " + tokens(varlist)[1] + " " + invtokens(orthnames) + " if " + touse + ", " + regopts) //conduct the analysis

		if (st_numscalar("c(rc)")) {
		
			display("{err}{cmd:" + reg + "} failed when executing {cmd:epsilon}.")
		
			exit(st_numscalar("c(rc)"))
			
		}
		
		glmwgts = st_matrix("e(b)") //record the regression weights to standardize
		
		predmu = st_tempname() //generate some more tempvars for Stata
		
		sd_yhat = sqrt(variance(orth*glmwgts[1, 1..cols(glmwgts)-1]')) //SD of linear predictor
		
		stata("quietly predict double " + predmu + " if " + touse + ", mu") //translated with link function
		
		cor_yhat = correlation((glmdat[., 1], st_data(., st_varindex(predmu), st_varindex(touse))))
		
		Bt = (glmwgts[1, 1..cols(glmwgts)-1]:*((cor_yhat[2, 1])/(sd_yhat)))'

	}
	
	else { //asked for invalid reg
	
		display("{err}{opt reg(" + reg + ")} invalid with {opt epsilon}.")
	
		exit(198)
		
	}
	
	Bt = Bt:^2 //square values of regression weights
	
	Lm = Lm:^2 //square values of orthogonalized predictors

	st_matrix("r(domwgts)", (Lm*Bt)')	//produce proportion of variance explained and put into Stata
	
	st_numscalar("r(fs)", sum(Lm*Bt))	//sum relative weights to obtain R2
	
}

end

/* programming notes and history

- domin version 1.0 - date - April 4, 2013

Basic version

-----

- domin version 1.1 - date - April 13, 2013

//notable changes\\
-fixed incorrect e(cmd) and e(cmdline) entries
-fixed markout variables for sets greater than 1

-----

- domin version 1.2 - date - April 16, 2013

//notable changes\\ 
-version 12.1 declared to ensure compatability with factor variables and other advertised features (thanks to Nick Cox for advice on this issue)
-fixed markout problem that kept unwanted characters in markout statement (thanks to Ariel Linden for pointing this out)
-analytic weights disallowed; importance weights allowed in dominance analysis consistent with underlying linear and logit-based regressions

-----

- domin version 2.0 - date - Aug 25, 2013

//notable changes\\
-tuples, all subset regression, and dominance computations migrated to Mata (thanks to all individuals who pointed out the errors tuples caused when interfacing with domin)
-incorporates complete and conditional dominance criteria
-ranking of predictors returned as a matrix, e(ranking)
-bug related to if and in qualifiers resolved
-dots representing each regression replaced with a progress bar for predictors/sets >6 or >4 (for logits)
-piechart dropped as option
-altered adjusted domin weight computation to result in decomposition of adjusted r2's from full regression
-incorporates "epsilon" or relative weights approach to general dominance (for regress only)
-McFadden's pseudo-R2 used for logit-based models (for consistency with Azen & Traxel, 2009)

-----

- domin version 3.0 - date - Jan 15, 2014

//notable changes\\
-R2-type metrics no longer default.  Any valid model fit metric can be used.  Consequently, adj R2 was also removed.
-increased flexibility of estimation commands to be used by domin.  Any command that follows standard syntax could potentially be used.
-wrapper program mvdom and mixdom incorporated into domin package to demonstrate command's flexibility.
-due to flexibility in fitstat, constant-only model adjustment incorporated (similar to Stas Kolenikov's -shapley- on SSC) 
-error related to reported number of observations fixed when strongly collinear variables dropped.
-added multiple imputation support
-greatly expanded, clarified, and updated the help file
 
 -----

- domin version 3.1 - date - Apr 14, 2015

//notable changes\\
-updated epsilon - works with glm, mvdom, and regress; also migrated to Mata (though not recommended approach - weights nixed for esplilon)
-reverse option to reverse "coding" of fitstat in ranks, standardized metric and complete dominance
-fixed tied ranks (used to randomly assign, - now share highest number)
-added "best dominance" - Com, Cond, Gen - in display (works with "reverse")
-removed unnecessary mata clear in dominance()
-time series operators allowed (for commands that allow them)
-tempfile error fixed for mi
-tempnames used for matrices
-fixed object declarations in dominance() function
-returns unabbreviated each variable in set and all sets lists
-added more ereturned information
-fixed error where all subsets fitstat was not adjusted for the constant-only fitstat
 
 -----

- domin version 3.2 - date - Apr 8, 2016
  
 //notable changes\\
 -fixed use of total with mi to obtain N, doesn't work with tsvars and fvars, changed to regress
 -update predictor combination computation - use tuples' approach
 

 
 
 for v. 4
  -will incorporate miinc's interaction engine - adjusts averages to only include valid interaction combination w/ factor variables (or allow tuples' combination eliminator - later version, needs a pub to justify maybe... for now make fixes)
  -will save info from all regressions for user to access in Mata object
  -multi-equations (make a separate program)
  -built in mcF and Estrella r2?
*/
