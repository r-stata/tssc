*!chaid version 2.2 2/12/2015 - Joseph N. Luchman										
program define chaid, eclass	//version history at end of file								//program declarations

version 12.1																					//version declaration

if (replay()) {																					//replay syntax

	if ("`e(cmd)'" != "chaid") error 301
	
	if (_by()) error 190
	
	Display
	
	exit 0
	
}																					

syntax varlist(numeric min=1 max=1) [in] [if] [fw], ///											//only one dv and max 1 dv - allows if and in
[MINNode(integer 100) ///																		//minimum number of observations in a terminal node
MINSplit(integer 200) ///																		//minimum number of observations to allow splitting a node
MAXBranch(integer -1) ///																		//maximum number of splits/interactions stemming from the root node
UNOrdered(varlist numeric) ///																	//variable list for unordered splitting treatment in CHAID
ORDered(varlist numeric) ///																	//variable list for ordered splitting treatment in CHAID
MISsing ///																						//treat missing values as floating category
MERGAlpha(real .95) ///																			//alpha level for merging 2 allowable categories									
RESPAlpha(real -1) ///																			//alpha level for respliting 2 allowable, merged categories
SPLTAlpha(real .05) ///																			//alpha level for implementing a split in the data
NOIsily ///																						//shows a lot of output - if the user is interested
DVOrdered ///																					//declares that the outcome is ordered and uses ologit instead of mlogit
noadj ///																						//no Bonferroni adjustment - more permissive splitting
noDisplay	///																					//don't display the results
PREDicted ///																					//obtain predicted values - modal value for category
IMPortance ///																					//obtain permutation importance for input splitting variables
Permute ///																						//use permute to obtain p-values
svy ///																							//incorporate svy design to obtain p-values
///mi(string)	///																				//incorporate multiple imputation to obatain p-values (next relaease?)
XTile(string) ///																				//convenience command for obtaining ordered quantiles of predictors
EXhaust]																						//use exhaustive CHAID (binary split) instead of default multi-way splits

/*exit and warning conditions*/
if ((`:list sizeof unordered' == 0) & (`:list sizeof ordered' == 0) & ///
(`:list sizeof xtile' == 0)) {																	//exit if no splitting vars entered

	display "{err}No independent variables entered."
	
	exit 111
	
}

if (`minsplit' < `minnode') {																	//exit if you tell chaid that the minnode/cluster size is larger than the min size to make a split

	display "{err}{opt minsplit()} cannot be smaller than " ///
	"{opt minnode()}."

	exit 198
	
}

if ((`mergalpha' <= 0) | (`mergalpha' >= 1) | (`spltalpha' <= 0) | ///
(`spltalpha' >= 1)) {																			//ensure that the alphas are possible

	display "{err}{opt mergalpha()} and {opt spltalpha()} must range " ///
	"betweeen (but not include) 0 and 1."
	
	exit 198

} 

if (`minnode' <= 0) {																			//ensure that min cluster size is a possible number

	display "{err}{opt minnode()} must be a positive integer value."
	
	exit 198

}

if ((`respalpha' >= 1) | (`respalpha' > 1 - `mergalpha') | (`respalpha' == 0)) {				//ensure that alphas are possible values that don't induce splitting forever

	display "{err}{opt resplapha()}, when invoked, must range between (but not include)" _newline ///
	"0 and 1 and must be less than 1 - {opt mergalpha()} to prevent infinite merging and resplitting."
	
	exit 198

}

if (("`weight'" != "") & (("`permute'" != "") | ("`svy'" != ""))) {

	display "{err}{cmd:fweight}s not allowed with {opt permute} or {opt svy}."

	exit 198

}

if (("`permute'" != "") & ("`svy'" != "")) {

	display "{err}{opt permute} and {opt svy} not allowed together."

	exit 198

}

//1) no fw and permute, 2) no fw and svy, 3) no permute and svy

capture which lmoremata.mlib																	//is moremata present?

if (_rc != 0) {																					//if moremata cannot be found, tell user to install it.

	display "{err}Module {cmd:moremata} not found.  Install {cmd:moremata} here {stata ssc install moremata}."
	
	exit 198

}

if strlen("`permute'") local noadj "noadj"

/*begin data processing*/
//mark the estimation sample
tempvar keep touse stop cluster useob dv														//tempvar declarations - begin using "touse"; add "keep" markout variables in unordered() and ordered()

tempname cellcount fit																			//tempname declaration for matrix

quietly generate `keep' = 1 `if' `in'															//allows keeping of missings as valid category, but still adjusting for "if"s and "in"s

if strlen("`xtile'") {

	gettoken xtile xtile_opt: xtile, parse(",")

	foreach x of varlist `xtile' {																//convenience command for creating binned continuous predictors in CHAID

		capture inspect xt`x'
	
		if !_rc quietly drop xt`x'

		quietly xtile xt`x' = `x' if `keep' [`weight'`exp'] `xtile_opt'
	
		local ordered "`ordered' xt`x'"

	}
	
}

mark `touse'																					//mark estimation sample

if ("`missing'" == "") markout `touse' `varlist' `unordered' `ordered' `keep'					//markout all variables when missings as category is not desired

else if ("`missing'" != "") & ("`dvordered'" == "") markout `touse' `keep'						//markout only "if" and "in" when missings are a valid category

else if ("`missing'" != "") & ("`dvordered'" != "") markout `touse' `varlist' `keep'			//markout only "if" and "in" and on dv when missings are valid category and dv is declared ordered

drop `keep'																						//"keep" tempvar is dropped so that it does not find its way into mata

foreach x of varlist `varlist' `unordered' `ordered' {											//exit if too many categories (20 is max) or categories are negative integers

	quietly inspect `x' if `touse'
	
	if (r(N_unique) > 20) {
	
		display "{err}Number of distinct values in {cmd:`x'} is larger than allowed. " _newline ///
		"Consider collapsing across similar categories for unordered or using " _newline ///
		"{opt xtile()} option/command for ordered variables to reduce the number of levels."
		
		exit 198
	
	}
	
	else if (r(N) != r(N_0) + r(N_posint)) {
	
		display "{err}Levels of each variable must be non-negative integer values." _newline ///
		" Variable {cmd:`x'} contains negative or decimal values."
		
		exit 198
	
	}

}

//identify and process variables to use
quietly tab `varlist' [`weight'`exp'], matrow(`cellcount')										//identify levels of dependent/outcome variable to create inidicator varaibles

mata: st_local("dvlevs", invtokens(strofreal(st_matrix("`cellcount'")')))						//put levels into a macro for use
		
local dvlist "`varlist'"																		//produce local macro that's updated with tempvar names for use in mata

local dvdisp "`varlist'"																		//produce local macro that's updated with displayed names of outcome and levels
	
local type "`type' d"																			//note "type" of variable for dv

quietly generate `dv' = `varlist'																//local macro to denote variable type for splitting purposes - here "d" denotes dependent variable that will not be split

if ("`missing'" != "") quietly count if missing(`dv')											//discern whether outcome is missing values if missings are of interest

if (("`missing'" != "") & (r(N) > 0) & ("`dvordered'" == "")) {									//if "missing" invoked and dv is not ordered, turn missing into last category
	
	quietly summarize `dv' [`weight'`exp']														//find out what the larget category is
	
	quietly recode `dv' (missing = `=r(max)+1')													//make all missings one bigger than the biggest category													 
	
}

if (`:list sizeof unordered' > 0) {																//process unordered splitting variables when present

	foreach x of varlist `unordered' {

		quietly tabulate `x' if `touse' [`weight'`exp'], matrow(`cellcount') `missing'			//discern levels of each unordered variable for creating binary variables
	
		mata: st_local("`x'levs", invtokens(strofreal(st_matrix("`cellcount'")')))				//put levels of unordered variable into local macro
		
		foreach y of numlist ``x'levs' {
		
			if (`:list posof "`y'" in `x'levs' == 1) {
			
				local type "`type' ("
				
				local unorddisp "`unorddisp' ("
			
			}
		
			if ("`y'" != ".") {
			
				tempvar `x'`y'																	//create tempvars with name of level of unordered, binary variable
				
				quietly generate byte ``x'`y'' = `x' == `y'										//generate binaries for each level of unordered variable
	
				label variable ``x'`y'' "`x' @ `y'"												//label the tempvar for later processing
	
				local unorderedlist "`unorderedlist' ``x'`y''"									//include name of unordered binary variable in list of tempvar names
			
				local unorddisp "`unorddisp' `x'`y'"											//include displayed name of unordered binary variable in list of tempvar names
			
				local type "`type' u"															//include variable type in type macro
	
			} 

			else {																				//if missing option invoked count missings to see whether following syntax needs to be run
			
				tempvar `x'ms																	//assuming missings are present, create tempvar for unordered varible indicating missing
				
				quietly generate byte ``x'ms' = cond(missing(`x'), 1, 0)						//generate indicator for missing category
				
				label variable ``x'ms' "`x' @ missing"											//label the tempvar for later processing
				
				local unorderedlist "`unorderedlist' ``x'ms'"									//include missing tempvar name in unordered list
			
				local unorddisp "`unorddisp' `x'ms"												//include missing display name in unordered display list
				
				local type "`type' f"															//include type "floating"
					
			}
			
			if (`: list posof "`y'" in `x'levs' == `: list sizeof `x'levs') {
			
				local type "`type')"
				
				local unorddisp "`unorddisp')"
			
			}
				
		}
			
	}
			
}
	
if (`:list sizeof ordered' > 0) {

	foreach x of varlist `ordered' {

		quietly tab `x' if `touse' [`weight'`exp'], matrow(`cellcount') `missing'				//if ordered variables present, discern their levels/values
	
		mata: st_local("`x'levs", invtokens(strofreal(st_matrix("`cellcount'")')))				//put levels of ordered variable into local macro
	
		foreach y of numlist ``x'levs' {
		
			if (`: list posof "`y'" in `x'levs' == 1) {
			
				local type "`type' ("
				
				local orddisp "`orddisp' ("
			
			}
		
			if ("`y'" != ".") {
			
				tempvar `x'`y'																	//declare tempvar for each value of ordered variable
				
				quietly generate byte ``x'`y'' = `x' == `y'										//generate binary for each level of ordered variable
		
				label variable ``x'`y'' "`x' @ `y'"												//label the tempvar for later processing
		
				local orderedlist "`orderedlist' ``x'`y''"										//include ordered tempvar in orderedlist 
			
				local orddisp "`orddisp' `x'`y'"												//include display name of variable in ordered display macro
			
				local type "`type' o"															//include variable type in type macro
				
			}
	
			else {																				//if missing option invoked count missings to see whether following syntax needs to be run
			
				tempvar `x'ms																	//assuming missings are present, create tempvar for ordered varible indicating missing
				
				quietly generate byte ``x'ms' = cond(missing(`x'), 1, 0)						//generate indicator for missing category
					
				label variable ``x'ms' "`x' @ missing"											//label the tempvar for later processing					
					
				local orderedlist "`orderedlist' ``x'ms'"										//include missing tempvar name in ordered list
			
				local orddisp "`orddisp' `x'ms"													//include missing display name in unordered display list
						
				local type "`type' f"															//include type "floating"
			
			}
			
			if (`: list posof "`y'" in `x'levs' == `: list sizeof `x'levs') {
			
				local type "`type')"
				
				local orddisp "`orddisp')"
			
			}
					
		}
		
	}

}

/*process estimation options*/
if ("`permute'" != "") local permute "permute `dv' e(chi2) e(ll) e(df_m) e(N):"

local test "e(chi2)"

if ("`svy'" != "") local test "e(F)"

local quietly "quietly"																			//is the chaid process going to display everything?

if ("`noisily'" != "") local quietly ""															//make it non-quiet

quietly generate byte `stop' = 1 if `touse'														//indicator telling chaid to not look for splits on this observation

quietly generate byte `cluster' = 1 if `touse'													//cluster membership - everyone starts in same cluster #1

quietly generate byte `useob' = 0 if `touse'													//indicator for "use this ob" in current analysis

`quietly' summarize `stop' `cluster' [`weight'`exp']											//look at data if non-quiet

local reg "mlogit"																				//default analysis is mlogit

if ("`dvordered'" ! = "") local reg "ologit"													//if dvordered then ologit

/*begin chaid algorithm in Mata*/
`quietly' mata: CHAIDsplit = chaid("`unorderedlist'", "`orderedlist'", "`type'", ///
"`dvdisp' `unorddisp' `orddisp'", "`dv' `unordered' `ordered'", `mergalpha', ///
`spltalpha', `minsplit', `minnode', `maxbranch', `respalpha', "`adj'", "`svy'", ///
"`exhaust'")																					//pass arguments to Mata

/*process chaid results*/
capture xi: count																				//nix xi: used in chaid - cleans up dataset														

capture inspect _CHAID																			//is there already a _CHAID variable?

if (_rc == 0) drop _CHAID																		//if there is a _CHAID variable, drop it

rename `cluster' _CHAID																			//rename the current tempvar "cluster" _CHAID

label variable _CHAID "CHAID-defined cluster"													//label the clustering variable

perm_import if `touse', dv("`varlist'") list(0) wexp("`exp'") `svy'

scalar `fit' = r(fit)

if ("`importance'" != "") mata: ifstmnts = J(rows(CHAIDsplit)-1, cols(CHAIDsplit), "")

mata: st_local("clusters", strofreal(rows(CHAIDsplit)-1))

if (`clusters' > 0) {

	forvalues x = 1/`clusters' {

		if ("`noisily'" == "noisily") mata: CHAIDsplit[`=`x'+1', .]
		
		local path`x' ""
	
		mata: st_local("search", strofreal(cols(CHAIDsplit)))
	
		forvalues z = 2/`search' {
	
			mata: st_local("currentname", CHAIDsplit[`=`x'+1', `z'])
	
			local vallist ""
		
			if ("`currentname'" != "") {
	
				foreach y of local currentname {
		
					local name "`:variable label ``y'''"
			
					gettoken varnam level: name, parse("@")
			
					gettoken atsign level: level, parse("@")
			
					if ("`level'" != "") local vallist "`vallist'`level'"
		
				}
			
				local varnam = trim("`varnam'")
			
				local vallist = trim("`vallist'")
		
				local path`x' "`path`x''`varnam'@`vallist';"
		
				if ("`importance'" != "") {
		
					if regexm("`vallist'", "missing") local vallist = subinword("`vallist'", "missing", ".", .)
		
					local ifcomma = subinstr("`vallist'", " ", ",", .)
				
					if (`z' == 2) mata: ifstmnts[`x', `=`z'-1'] = " inlist(" + st_local("varnam") + "," + st_local("ifcomma") + ")"
				
					else mata: ifstmnts[`x', `=`z'-1'] = " & inlist(" + st_local("varnam") + "," + st_local("ifcomma") + ")"
			
				}
			
			}
	
		}
	
	}
	
}


if ("`importance'" != "") & (`clusters' > 0) {
	
	tempname imp_v
	
	mata: imp_n = ""
	
	mata: imp_v = .
	
	foreach x of varlist `ordered' `unordered' {
	
		perm_import if `touse', permvar("`x'") dv("`varlist'") list(`clusters') ///
		predlist(`ordered' `unordered') wexp("`exp'") `missing' `svy'
		
		mata: imp_n = (imp_n, "`x'")
		
		mata: imp_v = (imp_v, st_numscalar("r(fit)"))
	
	}
	
	mata: imp_v = st_numscalar("`fit'"):-imp_v
	
	mata: imp_v = imp_v:/rowsum(imp_v)
	
	mata: imp_v = (imp_v \ (., mm_ranks((imp_v[1, 2..cols(imp_v)]:*-1)',1,3)'))
	
	mata: st_local("imp_n", invtokens(imp_n))
	
	mata: st_matrix("`imp_v'", imp_v[., 2..cols(imp_v)])
	
	matrix colnames `imp_v' = `imp_n'
	
	matrix rownames `imp_v' = "raw" "rank"

}

ereturn post , depname(`varlist') esample(`touse')												//clear ereturned values, post dv and obs

mata: st_local("search", strofreal(cols(CHAIDsplit)))

local splitcount = 1

forvalues x = 2/`search' {
	
	mata: t = tokeninit("", pchars=(","))														//set up processing CHAIDsplit matrix

	mata: tokenset(t, CHAIDsplit[1, `x'])

	mata: nameslist = tokengetall(t)
	
	mata: st_local("search_name", strofreal(cols(nameslist)))
	
	forvalues y = 1/`search_name' {
	
		local levels ""
	
		mata: st_local("currentname", nameslist[`y'])
		
		if !regexm("`currentname'", ",") {
		
			foreach z of local currentname {
		
				local name "`:variable label ``z'''"
			
				gettoken name level : name, parse("@")
			
				local level = subinstr("`level'", "@", "", .)
			
				local levels = rtrim("`levels' `level'")
				
			}
			
			local alllevels "`alllevels' (`levels')"
			
			if ("`quietly'" == "") {
		
				display "`name'"	//
			
				display "`alllevels'"	//
			
			}
			
		}
		
	}
			
	ereturn local split`splitcount++' = itrim("`name' `alllevels'")
			
	local alllevels ""	
	
}

ereturn matrix branches = `branchmat'

quietly summarize _CHAID if e(sample) [`weight'`exp'], meanonly

ereturn scalar N = r(N)

quietly inspect _CHAID

ereturn scalar N_clusters = r(N_unique)

forvalues x = 1/`=e(N_clusters)' {

	ereturn local path`x' "`path`x''"

}

quietly tabulate _CHAID, matcell(`cellcount')

matrix `cellcount' = `cellcount''

ereturn matrix sizes = `cellcount'

if ("`importance'" != "") & (`clusters' > 0) ereturn matrix importance = `imp_v'

if ("`predicted'" == "predicted") {

	tempvar order
	
	tempname maxcell maxval
	
	capture inspect CHAID_predict

	if (_rc == 0) drop CHAID_predict

	quietly inspect _CHAID
	
	quietly generate long CHAID_predict = .
	
	forvalues x = 1/`=r(N_unique)' {
	
		quietly tabulate `varlist' [`weight'`exp'] if _CHAID == `x', matcell(`maxcell') matrow(`maxval') `missing'
		
		mata: predicted = select(st_matrix("`maxval'"), st_matrix("`maxcell'"):==max(st_matrix("`maxcell'")))
		
		mata: st_numscalar("`maxcell'", rows(predicted))
		
		if (`maxcell' == 1) mata: st_numscalar("`maxval'", predicted)
		
		else mata: st_numscalar("`maxval'", min(predicted))
		
		quietly replace CHAID_predict = `maxval' if _CHAID == `x'
	
	}
	
	label variable CHAID_predict "predicted `varlist' values by CHAID"
	
}

ereturn scalar fit = `fit'

ereturn local title = "Chi-Square Automated Interaction Detection (CHAID)"

ereturn local cmd = "chaid"

ereturn local cmdline = "chaid `0'"


if ("`display'" != "nodisplay") Display

end

/*model fit program*/
program perm_import, rclass

syntax if, dv(string) list(integer) [permvar(varlist) predlist(string) wexp(string) missing svy]

tempvar temp_chaid rand_perm

tempfile chaid_perm

preserve
		
if (!strlen("`svy'")) quietly keep `if'

if strlen("`wexp'") quietly expand `wexp'

quietly generate int `temp_chaid' = .

if (`list' == 0) {

	quietly replace `temp_chaid' = _CHAID

}

else {

	local notpermvar: list predlist-permvar
	
	if (!strlen("`svy'")) quietly keep `predlist' `dv' `temp_chaid'
		
	quietly save `chaid_perm'
		
	quietly keep `permvar'
		
	quietly generate `rand_perm' = runiform()
		
	quietly sort `rand_perm'
	
	if (strlen("`svy'")) quietly merge 1:1 _n using `chaid_perm', nogenerate
		
	else quietly merge 1:1 _n using `chaid_perm', nogenerate keepusing(`notpermvar' `dv' `temp_chaid')

	forvalues x = 1/`list' {

		mata: stata("quietly replace \`temp_chaid' = \`x' if" + invtokens(ifstmnts[`x', .]))

	}
	
}

if (strlen("`svy'")) {

	tempvar svy
	
	tempname best_F
	
	quietly clonevar `svy' = `dv'
	
	quietly svy: tabulate `dv' `svy', `missing'
	
	scalar `best_F' = e(F_Full)
	
	quietly svy: tabulate `dv' `temp_chaid', `missing'
	
	capture scalar `best_F' = e(F_Full)/`best_F'
	
	if (!_rc) return scalar fit = `best_F'
	
	else return scalar fit = 0

}

else {

	quietly tabulate `dv' `temp_chaid', V `missing'

	capture assert r(CramersV) != .
	
	if (!_rc) return scalar fit = abs(r(CramersV))

	else return scalar fit = 0
	
}

restore

end

/*replayable display*/
program Display

display _newline "{res}Chi-Square Automated Interaction Detection (CHAID)" ///
" Tree Branching Results" _newline "{txt}{hline 80}" _newline

if (e(N_clusters) == 1) display "{res}No clusters uncovered.  Cluster #1 is null."

else {

	preserve
	
	clear
	
	mata: st_addobs(st_numscalar("e(N_clusters)"))
	
	quietly mata: labels = st_tempname(max(st_matrix("e(branches)")) + 1)
	
	quietly mata: st_addvar("str100", labels)
	
	forvalues x = 1/`=e(N_clusters)' {
		
		local parse "`e(path`x')'"
		
		gettoken first second: parse, parse(";")
		
		local count = 0
		
		while ("`second'" != "") {
		
			mata: st_local("labvar", labels[1, `++count'])
		
			quietly replace `labvar' = "`first'" in `x'
			
			gettoken first second: second, parse(";")
			
			gettoken first second: second, parse(";")
		
		}
		
		mata: st_local("labvar", labels[1, cols(labels)])
		
		quietly replace `labvar' = "Cluster #`x'" in `x'
	
	}
	
	mata: st_local("all", invtokens(labels))
	
	sort `all'
	
	quietly putmata namemat = (`all'), replace
	
	mata: namemat'
	
	mata: namemat =  namemat[., 1..cols(namemat)-1]'

	mata: namemat = (J(1, cols(namemat), "root") \ namemat)
	
	clear
	
	mata: count = 0
	
	mata: column = 1

	local column = 1

	mata: st_local("totcol", strofreal(cols(namemat)))
	
	quietly {

		generate long x = .
	
		generate long y = .

		generate int col = .

		generate byte down = .
	
		generate str100 label = ""

	}
	
	local justup = 0
	
	forvalues y = 1/`totcol' {

		mata: currentvec = namemat[., column]
	
		if (`y' == 1) {
	
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = 1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}
		
			quietly replace down = 1 if missing(down)
		
			mata: countback = st_data(2::count-1, (st_varindex("x"), st_varindex("y")))
		
			mata: countback = sort(((rows(countback)::1), countback), 1)
		
			mata: st_addobs(rows(countback))
		
			mata: st_store(count+1::count+rows(countback), (st_varindex("x"), st_varindex("y")), countback[., 2..cols(countback)])
		
			mata: count = count + rows(countback)
		
			quietly replace down = 0 if missing(down)
		
			quietly replace col = `y' if missing(col)
		
			mata: column++
	
		}
	
		else if (`y' == `totcol') {
	
			mata: prevvec = namemat[., column-1]
		
			mata: retrace1 = currentvec:==prevvec
		
			mata: retrace2 = currentvec:!=""
		
			mata: retrace = retrace1:*retrace2
		
			mata: obsvd = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: obsvd = select(obsvd[., (1..2,4)], obsvd[.,3]:==column-1)
		
			mata: obsvd = select(obsvd[., 1..2], obsvd[.,3]:==1)
		
			mata: obsvd = select((obsvd \ J(rows(retrace)-rows(obsvd), 2, .)), retrace)
		
			mata: st_addobs(rows(obsvd))
		
			mata: st_store(count+1::count+rows(obsvd), (st_varindex("x"), st_varindex("y")), obsvd)
		
			mata: count = count + rows(obsvd)
		
			mata: currentvec = select(currentvec, abs(retrace:-1))
		
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = rows(obsvd)+1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}	
		
			quietly replace col = `y' if missing(col)
		
			quietly replace down = 1 if missing(down)
	
		}
	
		else {
	
			mata: prevvec = namemat[., column-1]
		
			mata: retrace1 = currentvec:==prevvec
		
			mata: retrace2 = currentvec:!=""
		
			mata: retrace = retrace1:*retrace2
		
			mata: obsvd = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: obsvd = select(obsvd[., (1..2,4)], obsvd[.,3]:==column-1)
		
			mata: obsvd = select(obsvd[., 1..2], obsvd[.,3]:==1)
		
			mata: obsvd = select((obsvd \ J(rows(retrace)-rows(obsvd), 2, .)), retrace)
		
			mata: st_addobs(rows(obsvd))
		
			mata: st_store(count+1::count+rows(obsvd), (st_varindex("x"), st_varindex("y")), obsvd)
		
			mata: count = count + rows(obsvd)
		
			mata: currentvec = select(currentvec, abs(retrace:-1))
		
			mata: currentvec = select(currentvec, currentvec:!="")
		
			mata: st_local("row", strofreal(rows(currentvec)))
		
			mata: row = rows(obsvd)+1
		
			forvalues x = 1/`row' {
		
				mata: st_addobs(1)
			
				mata: st_store(++count, st_varindex("x"), column)
			
				mata: st_store(count, st_varindex("y"), row)
			
				mata: st_sstore(count, st_varindex("label"), namemat[row++, column])
		
			}
		
			quietly replace col = `y' if missing(col)
		
			quietly replace down = 1 if missing(down)
		
			mata: countback = st_data(., (st_varindex("x"), st_varindex("y"), st_varindex("col"), st_varindex("down")))
		
			mata: countback = select(countback[., (1..2,4)], countback[.,3]:==column)
		
			mata: countback = select(countback[., 1..2], countback[.,3]:==1)
		
			mata: countback = sort(((rows(countback)::1), countback), 1)
		
			mata: st_addobs(rows(countback))
		
			mata: st_store(count+1::count+rows(countback), (st_varindex("x"), st_varindex("y")), countback[., 2..cols(countback)])
		
			mata: count = count + rows(countback)
		
			quietly replace down = 0 if missing(down)
		
			quietly replace col = `y' if missing(col)
		
			mata: column++
	
		}
	
	}

	quietly summarize y

	quietly replace y = (y - r(min))*-1 + r(max)

	tempname max

	scalar `max' = r(max)

	quietly summarize x

	quietly replace x = `=r(max)/2+r(min)' if y == `max'

	quietly generate int group = .

	forvalues x = `=`max'-1'(-1)1 {

		quietly replace group = y == `x' & label != ""
	
		quietly replace group = group + group[_n-1] in 2/`=_N'
	
		quietly summarize group
	
		forvalues y = `=r(min)'/`=r(max)' {
	
			quietly summarize x if group == `y' & y <= `x'
		
			quietly replace x = `=r(max)/2+r(min)' if group == `y' & y == `x'
	
		}
	
		quietly replace group = .

	}
	
	graph twoway scatter y x, mlabel(lab) connect(direct)

	capture matrix list e(importance)

	if !_rc {

		display _newline "{res}Splitting variable permutation importance"

		matrix list e(importance), noheader
	
	}
	
	restore
	
}

end

/*mata function to recursively partition data based on CHAID algorithm*/
version 12.1

mata:

mata set matastrict on

string matrix chaid(string rowvector unordvar, string rowvector ordvar, string scalar type, ///
string scalar names, string scalar vars, real scalar alpha1, real scalar alpha3, ///
real scalar minsplit, real scalar minnode, real scalar maxbranch, real scalar alpha2, ///
string scalar bfadj, string scalar svy, string scalar exhaust)
{
	real matrix selectvar, select2var, countcheck, comparecount
	
	real rowvector var1, var2, merger_ps, merger_aic, withinselect, randresolve, ///
	branches
	
	real colvector unordpcomp
	
	real scalar position, moresplit, compare_p, current_p, compare_aic, current_aic, ///
	moremerge, clustercount, currentcluster, adj_p, countmerge, temploc1, temploc2, ///
	mergeruns, floating, match_p
	
	string matrix splits, CHAIDsplit
	
	string rowvector varsvec, namesvec, typevec, selecttype, collapsevec, selectnames, ///
	clusnames, comparenames, select2names, select2vec
	
	string scalar temploc1s, temploc2s
	
	transmorphic basis																				
	
	tokens(vars)		//																																						
	
	position = 2																						//updatable position of data to find in varsvec
	
	varsvec = tokens(vars)																				//vectorize the tempvars																		
	
	varsvec[position]	//
	
	moresplit = 1																						//scalar to indicate continue splitting process between-variable process
	
	compare_p = 1																						//currently lowest p-value for deciding which variable will be splitting variable
	
	compare_aic = .																						//currently lowesr AIC value for deciding which variable will be splitting variable
	
	clustercount = 1
	
	currentcluster = 1
	
	comparenames = ("")
	
	branches = (0)
	
	splits = ("")
	
	q = tokeninit(wchars = (" "), pchars = (" "), qchars = ("()"))										//vectorize the display names
		
	tokenset(q, names)
	
	namesvec = tokengetall(q)
	
	namesvec	//
	
	q = tokeninit(wchars = (" "), pchars = (" "), qchars = ("()"))										//vectorize the type inputs
		
	tokenset(q, type)
	
	typevec = tokengetall(q)
	
	typevec	//
	
	CHAIDsplit = ("Splits")
	
	while (moresplit == 1) {																			//do following process at least once - continue if between-variable splitting process is to continue (i.e., moresplit == 1)
	
		stata("replace \`useob' = \`stop' & \`cluster' == " + strofreal(currentcluster) + " if \`touse'")	
		
		selectnames = tokens(subinstr(subinstr(namesvec[position], ")", ""), "(", ""))					//pull out names for first independent variable (i.e., in position = 2] binaries using same procedure as with dependent variable - select() to pull out data - strpos() to create	vector of 1's, substr() to truncate names, strlen() to truncate substr() statement at length of focal independent variable to match												
		
		selectnames	//
		
		selecttype = tokens(subinstr(subinstr(typevec[position], ")", ""), "(", ""))					//pull out types for first independent variable using same procedure as with dependent variable - select() to pull out data - strpos() to create	vector of 1's, substr() to truncate names, strlen() to truncate substr() statement at length of focal independent variable to match												
		
		selecttype	//
		
		moremerge = 1																					//updatable scalar to indicate continute merging within-variable process
		
		stata("tabulate \`dv' \`useob' if \`touse' [\`weight'\`exp'], matcell(\`cellcount')") 			//tabulate dv with the current cluster set, keep the resulting matrix
		
		stata("ereturn matrix cellcount = \`cellcount'")												//ereturn the matrix to pull it into Mata - probably unnecessary, but it works
		
		countcheck = st_matrix("e(cellcount)")'															//pull matrix of counts into Mata, transposed
		
		countcheck	//
		
		if (rows(countcheck) > 1) countcheck = countcheck[2,]											//keep only the rows corresponding to the "useob" values if there are some that got a 0 on useob
		
		countcheck = select(countcheck, sign(countcheck))												//keep only the rows with some value (omit thosw with 0's)
		
		countcheck	//
		
		stata("summarize \`stop' [\`weight'\`exp']")													//quick summarize on stopping indicator
		
		if (st_numscalar("r(mean)") == 0) {																//if no-one has a 1 on stop, then end chaid as the process is now over
		
			moresplit = 0																				//don't split anymore - chaid is done
			
			moremerge = 0																				//don't merge anymore on this variable
			
		}
		
		else if ((rowsum(sign(countcheck)) == 1) | (rowsum(countcheck) <= minsplit)) {					//if there is only one value left in a cluster (i.e., it's pure) or it's size is below the minimum splitting size
			
			moremerge = 0																				//stop merging on this variable
			
			stata("replace \`stop' = 0 if \`useob' & \`touse'")											//update cluster to stop using this variable
			
			currentcluster++																			//increment current cluster - start using the next cluster up, look for splits there
			
			position = 2																				//restart "position" used in merging
			
		}
																										
		/*begin splitting variable category merging*/
		else {
		
			stata("tabulate " + varsvec[position] + ///
			" \`useob' if \`touse' [\`weight'\`exp'], \`missing' matcell(\`cellcount')") 
		
			stata("ereturn matrix cellcount = \`cellcount'")
		
			countcheck = st_matrix("e(cellcount)")'
		
			countcheck	//
		
			if (rows(countcheck) > 1) countcheck = countcheck[2,]
		
			selectnames = select(selectnames, sign(countcheck))
		
			selectnames	//
		
			while (moremerge == 1) {
		
				collapsevec = ("")																			//replace/generate collapsevec including names of variables to be collapsed into single variable
			
				merger_ps = (.)
				
				merger_aic = (.)
				
				floating = 0
			
				if (cols(selectnames) > 2)  {																//if there are more than 2 categories and the type of variabel is "unordered" then proceed
		
					/*Unordered merging*/
					if (selecttype[1] == "u") {
										
						base = (J(2, 1, 1) \ J(cols(selectnames) - 2, 1, 0))								//setup vector for use in cvpermute() to select all sets of 2 variables
			
						base	//
						
						basis = cvpermutesetup(base)														//register "base" vector with cvpermute()
				
						mergeruns = comb(cols(selectnames), 2)
				
					}
					
					else if (
					(selecttype[cols(selecttype)] == "f") & ///
					(colsum(regexm(selectnames[cols(selectnames)], "ms$")) == 1) & ///
					(colsum(cols(tokens(selectnames[cols(selectnames)]))) == 1)) {
					
						mergeruns = (cols(selectnames) - 1)*2 - 1
						
						floating = 1
						
						base = (J(1, 1, 1) \ J(cols(selectnames) - 2, 1, 0))								//setup vector for use in cvpermute() to select all sets of 2 variables
			
						base	//
						
						basis = cvpermutesetup(base)
					
					}
					
					else {
					
						mergeruns = cols(selectnames) - 1
					
					}
				
					countmerge = 1
				
					while (countmerge <= mergeruns) {														//go through all different combinations of predictor levels to find best levels to collapse
			
						if (selecttype[1] == "u") select2var = cvpermute(basis)'							//invoke cvpermute for selector vector
				
						else if (((selecttype[1] == "o") & (floating == 0)) | ///
						((floating == 1) & (sign(countmerge*2 - mergeruns) != 1))) {
						
							select2var = (J(countmerge - 1, 1, 0) \ J(2, 1, 1) \ ///
							J(cols(selectnames) - countmerge - 1, 1, 0))'
						
						}
						
						else if ((floating == 1) & (sign(countmerge*2 - mergeruns) == 1)) {
						
							select2var = (cvpermute(basis)', 1)
									
						}
				
						select2var	//
				
						collapsevec = (collapsevec, invtokens(strofreal(select2var)))						//create string vector indicating position of variabels to test
				
						collapsevec	//
				
						select2names = select(selectnames, select2var)										//proceed to select 2 columns of predictor to evaluate for potentially collapsing
				
						select2names	//
					
						select2names[1]	//
					
						select2vec = tokens(select2names[1])
					
						temploc1 = st_addvar("byte", st_tempname())
					
						temploc1s = st_varname(temploc1)
						
						stata("replace " + temploc1s + "=0")
					
						for (y = 1; y <= cols(tokens(select2names[1])); y++) {
						
							stata("replace " + temploc1s + "=`" ///
							+ select2vec[y] + "' + " + temploc1s)
								
						}
					
						select2names[2]	//
					
						select2vec = tokens(select2names[2])
					
						temploc2 = st_addvar("byte", st_tempname())
					
						temploc2s = st_varname(temploc2)
						
						stata("replace " + temploc2s + "=0")
					
						for (y = 1; y <= cols(tokens(select2names[2])); y++) {
						
							stata("replace " + temploc2s + "=`" ///
							+ select2vec[y] + "' + " + temploc2s)
								
						}
					
						stata("summarize " + temploc1s + " " + temploc2s + " if \`touse'" ///
						+ " & \`useob' [\`weight'\`exp']")	//
						 
						st_macroexpand("\`permute'version 10: \`reg' \`dv' " + temploc1s + ///
						" if \`touse' & \`useob' & (" + temploc1s + " | " + temploc2s + ") [\`weight'\`exp']")	//
						
						if (strlen(svy)) stata("capture version 10: svy, subpop(if \`touse' & \`useob' & (" + temploc1s + ///
						" | " + temploc2s + ")): \`reg' \`dv' " + temploc1s)
						
						else stata("capture \`permute'version 10: \`reg' \`dv' " + temploc1s + ///
							" if \`touse' & \`useob' & (" + temploc1s + " | " + temploc2s + ") [\`weight'\`exp']")
						
						if ((st_numscalar("c(rc)") == 0)) {
						
							if ((strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0))) {
						
								stata("\`reg'")	//
																
								merger_ps = (merger_ps, Ftail(st_numscalar("e(df_m)"), ///
								st_numscalar("e(df_r)"), st_numscalar(st_local("test"))))
								
								stata("getic, type(aicw) ll(1) parm(1) obs(1)")
								
								merger_aic = (merger_aic, st_numscalar("r(ic)"))

						
							}
							
							else if (!(strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0)) & ///
							!(rows(st_matrix("r(p)")))) {
					
								stata("\`reg'")	//
								
								merger_ps = (merger_ps, chi2tail(st_numscalar("e(df_m)"), ///
								st_numscalar(st_local("test"))))
								
								stata("getic, type(aicc) ll(\`=e(ll)') parm(\`=e(df_m)') obs(\`=e(N)')")
								
								merger_aic = (merger_aic, st_numscalar("r(ic)"))
						
							}
							
														
							else if (!(strlen(svy)) & (rows(st_matrix("r(p)")))) {
							
								merger_ps = (merger_ps, st_matrix("r(p)")[1,1])
								
								stata("getic, type(aicc) ll(" + strofreal(st_matrix("r(b)")[1, 2]) + ///
								") parm(" + strofreal(st_matrix("r(b)")[1, 3]) + ") obs(" ///
								+ strofreal(st_matrix("r(b)")[1, 4]) + ")")
								
								merger_aic = (merger_aic, st_numscalar("r(ic)"))
								
							}
					
							else { 
								
								merger_ps = (merger_ps, 1)
								
								merger_aic = (merger_aic, .)
								
							}
							
						}
						
						else {
						
							merger_ps = (merger_ps, 1)
							
							merger_aic = (merger_aic, .)
							
						}
						
						countmerge++
					
						countmerge	//
						
						st_dropvar((temploc1s, temploc2s))
				
					}
			
					if ((max(merger_ps) > 1 - alpha1) | (strlen(exhaust))) {								//if at least one p-value doesn't the "respalpha" limit offered by the user, collapse the levels as they appear sufficiently homogeneous - also ensures that, when the DV is a constant, the algorithm stops
					
						merger_ps = strmatch(strofreal(merger_ps), strofreal(max(merger_ps)))				//find the position of the largest p-value that passed the spltalpha criterion
				
						merger_ps	//
					
						if (rowsum(merger_ps) > 1) {
						
							merger_ps = (0, strmatch(strofreal(merger_aic[2..cols(merger_aic)]), ///
							strofreal(max(merger_aic[2..cols(merger_aic)]))))								//find the position of the largest aic value
				
							merger_ps	//
											
							if (rowsum(merger_ps) > 1) {
							
								randresolve = runiform(1, cols(merger_ps))
					
								merger_ps = strmatch(strofreal(merger_ps), strofreal(max(merger_ps)))
						
								merger_ps = randresolve:*merger_ps
						
								merger_ps = strmatch(strofreal(merger_ps), strofreal(max(merger_ps)))
								
								merger_ps	//
								
							}
					
						}
				
						withinselect = strtoreal(tokens(select(collapsevec, merger_ps)))					//pull out variables associated with largest p-value
						
						withinselect	//
						
						if (selecttype[1] == "u") selectnames = (invtokens(select(selectnames, withinselect)), ///
						select(selectnames, abs(withinselect:-1)))
						
						else if (selecttype[1] == "o") {
						
							countmerge = (strpos(invtokens(strofreal(withinselect)), "1") + 1)/2
							
							countmerge	//
							
							if (withinselect[countmerge] == withinselect[countmerge + 1]) { 
						
								if (countmerge == 1) selectnames = (invtokens(select(selectnames, withinselect)), ///
								select(selectnames[countmerge + 2..cols(withinselect)], ///
								abs(withinselect[countmerge + 2..cols(withinselect)]:-1)))
							
								else if (countmerge == cols(withinselect) - 1) selectnames = ///
								(select(selectnames[1..countmerge - 1], abs(withinselect[1..countmerge - 1]:-1)), ///
								invtokens(select(selectnames, withinselect)))
							
								else selectnames = (select(selectnames[1..countmerge - 1], abs(withinselect[1..countmerge - 1]:-1)), ///
								invtokens(select(selectnames, withinselect)), ///
								select(selectnames[countmerge + 2..cols(withinselect)], ///
								abs(withinselect[countmerge + 2..cols(withinselect)]:-1)))
							
							}
							
							else {
							
								if (countmerge == 1) selectnames = (invtokens(select(selectnames, withinselect)), ///
								select(selectnames[countmerge + 1..cols(withinselect) - 1], ///
								abs(withinselect[countmerge + 1..cols(withinselect) - 1]:-1)))
							
								else if (countmerge == cols(withinselect) - 1) selectnames = ///
								(select(selectnames[1..countmerge - 1], abs(withinselect[1..countmerge - 1]:-1)), ///
								invtokens(select(selectnames, withinselect)))
							
								else selectnames = (select(selectnames[1..countmerge - 1], abs(withinselect[1..countmerge - 1]:-1)), ///
								invtokens(select(selectnames, withinselect)), ///
								select(selectnames[countmerge + 1..cols(withinselect) - 1], ///
								abs(withinselect[countmerge + 1..cols(withinselect) - 1]:-1)))
							
							}
						
						}
					
						selectnames	//
						
						if (alpha2 > 0) {
						
							if (strlen(exhaust)) match_p = 1 - max(merger_ps)
							
							else match_p = -1
						
							selectnames = chaidsplit(selectnames, withinselect, selecttype[1], alpha2, svy, match_p)
							
							selectnames	//
							
						}
				
					}
			
					else moremerge = 0
				
				}
			
				else moremerge = 0
				
				adj_p = 0
						
				if (!strlen(bfadj)) {
					
					if (selecttype[1] == "u") {
						
						if (strlen(exhaust)) adj_p = cols(selectnames)*(cols(selectnames) - 1)/2
								
						else {
						
							unordpcomp = (0::cols(selectnames))
					
							for (y = 1; y <= cols(selectnames) - 1; y++) {
					
								adj_p = adj_p + (-1)^unordpcomp[y]*((cols(selectnames) - ///
								unordpcomp[y])^cols(selecttype)/(factorial(unordpcomp[y])* ///
								factorial(cols(selectnames) - unordpcomp[y])))
										
							}
								
						}
																						
					}
						
					else if (selecttype[1] == "o") {
						
						if (strlen(exhaust)) adj_p = cols(selectnames)*(cols(selectnames)^2 - 1)/2
						
						else adj_p = comb(cols(selecttype) - 1, cols(selectnames) - 1)
						
					}
					
					else if (selecttype[cols(selecttype)] == "f") {
						
						if (strlen(exhaust)) adj_p = cols(selectnames)*(cols(selectnames) - 1)/2
							
						else {
						
							comb(cols(selecttype) - 1, cols(selectnames) - 1)* ///
							((cols(selectnames) - 1) + cols(selectnames)*(cols(selecttype) - ///
							cols(selectnames)))/(cols(selecttype) - 1)
									
						}
							
					}
							
				}
						
				else adj_p = 1
						
				adj_p	//
			
				"Completed One Merging Session"	//
			
			}
		
			/*Compute chi-square used for splitting*/
		
			countmerge = 1
		
			temploc1 = st_addvar("byte", st_tempname())
		
			temploc1s = st_varname(temploc1)
						
			stata("replace " + temploc1s + "=0 if \`touse' & \`useob'")
			
			for (x = 1; x <= cols(selectnames); x++) {
			
				select2vec = tokens(selectnames[x])					
					
				for (y = 1; y <= cols(select2vec); y++) {
					
					st_macroexpand("replace " + temploc1s + "=`" ///
					+ select2vec[y] + "'*" + strofreal(countmerge) + " if `" ///
					+ select2vec[y] + "' & \`touse' & \`useob'")
						
					stata("replace " + temploc1s + "=`" ///
					+ select2vec[y] + "'*" + strofreal(countmerge) + " if `" ///
					+ select2vec[y] + "' & \`touse' & \`useob'")
						
				}
				
				countmerge++
				
				stata("summarize " + temploc1s + " if \`touse' & \`useob' [\`weight'\`exp']")	//
				
			} 
				
			stata("tabulate " + temploc1s + ///
			" \`useob' if \`touse' [\`weight'\`exp'], \`missing' matcell(\`cellcount')") 
		
			stata("ereturn matrix cellcount = \`cellcount'")
		
			countcheck = st_matrix("e(cellcount)")'
		
			countcheck	//
			
			if (selecttype[1] == "u") {
			
				st_local("xi", "xi:")
				
				st_local("i", "i.")
			
			}
			
			if (selecttype[1] == "o") {
			
				st_local("xi", "")
				
				st_local("i", "")
			
			}
			
			if (strlen(svy)) stata("capture version 10:svy, subpop(if \`touse' & \`useob'):\`xi' \`reg' \`dv' \`i'" + temploc1s)
			
			else stata("capture \`permute'version 10:\`xi' \`reg' \`dv' \`i'" + temploc1s + " if \`touse' & \`useob' [\`weight'\`exp']")
			
			if ((st_numscalar("c(rc)") == 0) & (cols(countcheck) > 1)) {
			
				if ((strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0))) {
			
					stata("\`reg'")	//
				
					current_p = Ftail(st_numscalar("e(df_m)"), st_numscalar("e(df_r)"), st_numscalar(st_local("test")))
					
					stata("getic, type(aicw) ll(1) parm(1) obs(1)")
								
					current_aic = st_numscalar("r(ic)")
			
				}
			
				else if (!(strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0)) ///
				& !(rows(st_matrix("r(p)")))) {
			
					stata("\`reg'")	//
			
					current_p = chi2tail(st_numscalar("e(df_m)"), st_numscalar(st_local("test")))
					
					stata("getic, type(aicc) ll(\`=e(ll)') parm(\`=e(df_m)') obs(\`=e(N)')")
								
					current_aic = st_numscalar("r(ic)")
				
				}
			
				else if (!(strlen(svy)) & (rows(st_matrix("r(p)")))) {
				
					current_p = st_matrix("r(p)")[1,1]
					
					stata("getic, type(aicc) ll(" + strofreal(st_matrix("r(b)")[1, 2]) + ///
					") parm(" + strofreal(st_matrix("r(b)")[1, 3]) + ") obs(" ///
					+ strofreal(st_matrix("r(b)")[1, 4]) + ")")
								
					current_aic = st_numscalar("r(ic)")
					
				}
			
				else {
				
					current_p = 1
					
					current_aic = .
					
				}
				
			}
			
			else {
			
				current_p = 1
				
				current_aic = .
				
			}
				
			st_dropvar(temploc1s)
			
			current_p = current_p*adj_p
				
			current_p	//
			
			current_aic	//
		
			compare_p	//
			
			compare_aic	//
		
			if (current_p < compare_p) {
		
				"better!"	//
		
				compare_p = current_p
		
				compare_p	//
				
				compare_aic = current_aic
				
				current_aic	//
			
				comparenames = selectnames 
			
				comparenames	//
				
				comparecount = countcheck
				
				comparecount	//
			
			}
		
			else if (current_p == compare_p) {	
		
				if (current_aic < compare_aic) {
				
					"better!"	//
		
					compare_p = current_p
		
					compare_p	//
					
					compare_aic = current_aic
				
					current_aic	//
			
					comparenames = selectnames 
			
					comparenames	//
				
					comparecount = countcheck
				
					comparecount	//
					
				}
					
				else {	
				
					randresolve = runiform(1, 2)
			
					if (randresolve[1] < randresolve[2]) {
		
						"better!"	//
		
						compare_p = current_p
		
						compare_p	//
						
						compare_aic = current_aic
				
						current_aic	//
			
						comparenames = selectnames 
			
						comparenames	//
						
						comparecount = countcheck
						
						comparecount	//
						
					}
						
				}
		
			}
		
			position =  position + 1
		
			position	//
		
			"Completed Merging Run"	//
		
			comparenames	//
	
			if (position == cols(varsvec) + 1) {
		
				if ((cols(tokens(invtokens(comparenames))) > 1) & (compare_p < alpha3) & ///
				(min(comparecount) >= minnode) & ///
				((branches[currentcluster] < maxbranch) | (maxbranch < 0))){
		
					"split!"	//
					
					branches[currentcluster] = branches[currentcluster] + 1
					
					branches //
					
					selectnames = (" ")
					
					for (x = 1; x <= cols(comparenames); x++) {
					
						comparenames[x]	// 
					
						selectnames = (selectnames, comparenames[x], ",")
					
					}
					
					selectnames	//
					
					if (branches[currentcluster] > cols(splits)) splits = (splits, J(rows(splits), 1, ""))
					
					splits[currentcluster, branches[currentcluster]] = comparenames[1]
					
					splits	//
					
					CHAIDsplit = (CHAIDsplit, invtokens(selectnames))
					
					for (x = 2; x <= cols(comparenames); x++) {
					
						clustercount++
						
						clustercount	//
						
						branches = (branches, branches[currentcluster])
						
						branches	//
						
						splits = (splits \ splits[currentcluster, .])
						
						splits[clustercount, branches[clustercount]] = comparenames[x]
						
						splits	//
																		
						selectnames = tokens(comparenames[x])
					
						for (y = 1; y <= cols(selectnames); y++) {
							
							st_macroexpand("replace \`cluster' = " + strofreal(clustercount)+ " if `" + ///
							selectnames[y] + "' & \`touse' & \`useob'")	//
				
							stata("replace \`cluster' = " + strofreal(clustercount)+ " if `" + ///
							selectnames[y] + "' & \`touse' & \`useob'")	//	
					
						}
					
					}
					
					position = 2
					
					comparenames = ("")
					
					compare_p = 1
					
					compare_aic = .
				
				}
				
				else {
				
					position = 2
				
					stata("replace \`stop'=0 if \`cluster' == " + strofreal(currentcluster))
					
					currentcluster++
				
					stata("summarize \`cluster'")
				
					if (st_numscalar("r(max)") < currentcluster) moresplit = 0
				
					currentcluster	//
				
					compare_p = 1
					
					compare_aic = .
					
					comparenames = ("")
						
				}
		
			}	
		
		}
	
	}
	
	currentcluster = 0
	
	for (x = 1; x <= rows(splits); x++) {
	
		currentcluster++
		
		if (cols(CHAIDsplit) > 1) CHAIDsplit = (CHAIDsplit \ ("path" + strofreal(currentcluster), splits[x, .], J(1, cols(CHAIDsplit)-cols(splits)-1, "")))
	
	}
	
	branchmat = st_tempname()
	
	st_matrix(branchmat, branches)
	
	st_local("branchmat", branchmat)
	
	"Finished Execution"	//
	
	return(CHAIDsplit)

}  

end

version 12.1

mata:

mata set matastrict on

string rowvector chaidsplit(string rowvector selectnames, real rowvector withinselect, string scalar type, ///
real scalar cutalpha, string scalar svy, real scalar match_p)
{
	string scalar trysplit, tploc1s, tploc2s
	
	real scalar count, float_miss
	
	real rowvector selectsplit, tploc1, tploc2, mg_ps, mg_aic, repeats
	
	real colvector  base, combin
	
	string rowvector splitvec, namesplit, comparevec
	
	real matrix unordmat
	
	transmorphic basis
	
	"chaidsplit begins"	//

	if (type == "o") {
	
		trysplit = select(selectnames, withinselect[1..cols(withinselect) - 1])
		
		trysplit = trysplit[1]
		
		float_miss = rowsum(strmatch(substr(tokens(trysplit), -2), "ms"))
		
	}
	
	else if (type == "u") trysplit = selectnames[1]
		
	trysplit	//
	
	type	//
	
	splitvec = ("")
	
	mg_ps = (.)
	
	mg_aic = (.)
		
	if (cols(tokens(trysplit)) > 2) {
	
		namesplit = tokens(invtokens(trysplit))
		
		namesplit	//
		
		if (float_miss == 1) {
		
			namesplit = (select(namesplit, abs(strmatch(substr(namesplit, -2), "ms")):-1), ///
			select(namesplit, strmatch(substr(namesplit, -2), "ms")))
			
			namesplit	//
		
		}
		
		if (type == "u") {
		
			repeats = 2^(cols(tokens(trysplit))) - 2
			
			unordmat = J(1, cols(tokens(trysplit)), .)
			
			for (x = 1; x <= cols(tokens(trysplit)); x++) {

				base = J(x, 1, 1)
	
				base = (base \ J(cols(tokens(trysplit)) - x, 1, 0))
	
				basis = cvpermutesetup(base)
	
				for (y = 1; y <= comb(cols(tokens(trysplit)), x); y++) {
	
					combin = cvpermute(basis)
		
					unordmat = (unordmat \ combin')
		
				}
	
			}
			
			unordmat = unordmat[2..rows(unordmat)-1, .]
			
			unordmat	//
			
		}
		
		else if (type == "o") {
		
			repeats = cols(tokens(trysplit)) - 1
			
			if (float_miss == 1) repeats = repeats*2 - 1
			
		}
		
		repeats	//
		
		count = 1
		
		while (count <= repeats) {
			
			if (type == "u") {
				
				selectsplit = unordmat[count, .]
				
			}
			
			else if (type == "o") {
			
				if (count <= cols(namesplit) - 1) selectsplit = (J(1, count, 1), J(1, cols(namesplit) - count, 0))
				
				else if (count > cols(namesplit) - 1) {
				
					selectsplit = (J(1, count - (cols(namesplit) - 1), 1), ///
					J(1, cols(namesplit) - 1 - (count - (cols(namesplit) - 1)), 0), 1)
				
				}
			
			}
	
			selectsplit	//
				
			splitvec = (splitvec, invtokens(strofreal(selectsplit)))						//create string vector indicating position of variables to test
				
			splitvec	//
				
			comparevec = select(namesplit, selectsplit)										//proceed to select 2 columns of predictor to evaluate for potentially collapsing
				
			comparevec	//
				
			tploc1 = st_addvar("byte", st_tempname())
					
			tploc1s = st_varname(tploc1)
						
			stata("replace " + tploc1s + "=0")
					
			for (y = 1; y <= cols(comparevec); y++) {
						
				stata("replace " + tploc1s + "=`" ///
				+ comparevec[y] + "' + " + tploc1s)
								
			}
					
			comparevec = select(namesplit, abs(selectsplit:-1))
			
			comparevec	//
					
			tploc2 = st_addvar("byte", st_tempname())
					
			tploc2s = st_varname(tploc2)
						
			stata("replace " + tploc2s + "=0")
					
			for (y = 1; y <= cols(comparevec); y++) {
						
				stata("replace " + tploc2s + "=`" ///
				+ comparevec[y] + "' + " + tploc2s)
								
			}
					
			stata("summarize " + tploc1s + " " + tploc2s + " if \`touse'" ///
			+ " & \`useob' [\`weight'\`exp']")	//
						 
			st_macroexpand("\`permute'version 10: \`reg' \`dv' " + tploc1s + ///
			" if \`touse' & \`useob' & (" + tploc1s + " | " + tploc2s + ") [\`weight'\`exp']")	//
			
			if (strlen(svy)) stata("capture version 10: svy, subpop(if \`touse' & \`useob' & (" + tploc1s + " | " + ///
			tploc2s + "): \`reg' \`dv' " + tploc1s)
			
			else stata("capture \`permute'version 10: \`reg' \`dv' " + tploc1s + ///
			" if \`touse' & \`useob' & (" + tploc1s + " | " + tploc2s + ") [\`weight'\`exp']")
						
			if ((st_numscalar("c(rc)") == 0)) {
						
				if ((strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0))) {
						
					stata("\`reg'")	//
							
					mg_ps = (mg_ps, Ftail(st_numscalar("e(df_m)"), ///
					st_numscalar("e(df_r)"), st_numscalar(st_local("test"))))
					
					stata("getic, type(aicw) ll(1) parm(1) obs(1)")
								
					mg_aic = (mg_aic, st_numscalar("r(ic)"))
						
				}
							
				else if (!(strlen(svy)) & !((st_numscalar(st_local("test")) == .) | (st_numscalar("df_m") == 0)) & ///
				!(rows(st_matrix("r(p)")))) {
					
					stata("\`reg'")	//
						
					mg_ps = (mg_ps, chi2tail(st_numscalar("e(df_m)"), ///
					st_numscalar(st_local("test"))))
					
					stata("getic, type(aicc) ll(\`=e(ll)') parm(\`=e(df_m)') obs(\`=e(N)')")
								
					mg_aic = (mg_aic, st_numscalar("r(ic)"))
						
				}
							
											
				else if (!(strlen(svy)) & (rows(st_matrix("r(p)")))) {
				
					mg_ps = (mg_ps, st_matrix("r(p)")[1,1])
					
					stata("getic, type(aicc) ll(" + strofreal(st_matrix("r(b)")[1, 2]) + ///
					") parm(" + strofreal(st_matrix("r(b)")[1, 3]) + ") obs(" ///
					+ strofreal(st_matrix("r(b)")[1, 4]) + ")")
								
					mg_aic = (mg_aic, st_numscalar("r(ic)"))
					
				}
					
				else {
				
					mg_ps = (mg_ps, 1)
					
					mg_aic = (mg_aic, .)
					
				}
							
			}
						
			else {
			
				mg_ps = (mg_ps, 1)
				
				mg_aic = (mg_aic, .)
				
			}
						
			st_dropvar((tploc1s, tploc2s))
			
			count++
				
		}
		
		if ((min(mg_ps) < cutalpha) & (min(mg_ps) < match_p)) {
			
			mg_ps = strpos(strofreal(min(mg_ps[2..cols(mg_ps)])), strofreal(mg_ps[2..cols(mg_ps)]))
			
			mg_ps	//
				
			if (rowsum(mg_ps) > 1) {
			
				mg_ps = strpos(strofreal(min(mg_aic[2..cols(mg_aic)])), strofreal(mg_aic[2..cols(mg_aic)]))
			
				mg_ps	//
				
				if (rowsum(mg_ps) > 1) {
			
					randresolve = runiform(1, cols(mg_ps))
				
					mg_ps = strmatch(strofreal(mg_ps), strofreal(max(mg_ps)))
						
					mg_ps = randresolve:*mg_ps
						
					mg_ps = strmatch(strofreal(mg_ps), strofreal(max(mg_ps)))
								
					mg_ps	//
					
				}
	
			}
				
			trysplit = (invtokens(select(namesplit, strtoreal(tokens(select(splitvec[2..cols(splitvec)], mg_ps))))), ///
			invtokens(select(namesplit, abs(strtoreal(tokens(select(splitvec[2..cols(splitvec)], mg_ps))):-1))))
			
			trysplit	//
		
			if (type == "u") selectnames = (trysplit, selectnames[2..cols(selectnames)])
		
			else if (type == "o") {
		
				if (withinselect[1] == 1) selectnames = (trysplit, selectnames[2..cols(selectnames)])
			
				else if (withinselect[cols(withinselect)-1] == 1) selectnames = (selectnames[1..cols(selectnames)-1], trysplit)
			
				else {
			
					count = (strpos(invtokens(strofreal(withinselect)), "1") + 1)/2
					
					count	//
				
					selectnames = (selectnames[1..count-1], trysplit, selectnames[count..cols(selectnames)])
			
				}
				
				if (rowsum(strmatch(substr(selectnames, -2), "ms")) == 1) {
				
					if (cols(tokens((select(selectnames, strmatch(substr(selectnames, -2), "ms")))))) {
					
						selectnames = (select(selectnames, abs(strmatch(substr(selectnames, -2), "ms")):-1), ///
						select(selectnames, strmatch(substr(selectnames, -2), "ms")))
					
					}
					
				}				
				
			}
			
		}
		
	}
	
	"end chaidsplit"	//
	
	return(selectnames)

}

end

//program to obtain information criteria
program define getic, rclass

syntax, type(string) ll(real) parm(integer) obs(integer)

if ("`type'" == "aicc") return scalar ic = -2*`ll'+2*`parm'+(2*`parm'*`parm' + 1)/(`obs' - `parm' - 1)

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

- chaid version 1.0 - date - November 18, 2013

Basic version

-----

- chaid version 1.1 - date - March 20, 2014

//notable changes\\
a] added frequency weights
b] updated display to highlight hierarchical tree-structure using Mata matrix and fix errors with original display
c] implemented the remerge process as an option
d] allowed a no Bonferroni adjustment option
e] fixed merging inaccuracy that excluded categories arbitrarily
f] error returning an extra "root" fixed
g] predicted value offered based on mode of node
h] additional returned values
i] updated helpfile - going over collapse option to expedite chaid fitting

-----

- chaid version 2.0 - date - August 22, 2014

//notable changes\\
a] added permutation-based p-values
b] added svy prefix compatability
c] added graphical depiction to display output
d] added accessible mata matrices
e] now can "replay" chaid results again as with other Stata programs
f] added permutation importance metric
g] fixed N-obs issue w/ fweights
h] added fit metric based on cramer's V (and svy compatible version with similar properties)
i] fixed Q1 Q11 nested variable selection issue - also allows to predict itself (dv and iv, though non-sensical, no more error)
j] added exhaustive CHAID algorithm
k] convenience command allows user to "xtile" for continuous predictors

-----

- chaid version 2.1 - date - December 16, 2014

//notable changes\\
a] fixed missing colon for svy with respalpha
b] moved location of bonferroni adjustment (doesn't require "exhaust" or there to have been a merge implemented to compute it) 
	to ensure no missing adjusted p-value
c] use aic for between model comparisons to decide on splitting (p-value has numerical precision issues... just use it to meet 
	the p<.05 threshold and that's it)
d] fix importance w/ missing (extra space added to "ifstmnts" for missings erroneously that was turned into comma
e] fix DV levels check that occurs before markout

-----

- chaid version 2.2 - date - February 12, 2015

//notable changes\\
a] fixed Bonferroni adjustment (was not invoked unless noadj option was used) - had opposite behavior as intended
b] fixed but which prevented splits on splitting variables with a single level

v 3?
- allow custom xtile() for each variable
- save info for all splits (as obj) 
- postestimation for predict & importance
- make interactive fitting - graphing?
- add mi?
