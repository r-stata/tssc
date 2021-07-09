*! version 2.0, 13Oct2004, John_Hendrickx@yahoo.com
/*
Direct comments to: John Hendrickx <John_Hendrickx@yahoo.com>

Iteratively re-estimate while adding noise to selected variables.
Stata version of the SPSS macro
by Ben Pelzer, Manfred te Grotenhuis, Jan Lammers, John Hendrickx
at http://www.xs4all.nl/~jhckx/spss/perturb/perturb.html

Version 2, October 13, 2004
Added -pcnttabs- option, specify the percentages wanted, let -reclass-
find a suitable model
Added -nobestmod- to skip finding a suitable model
Added -noadjust- to skip equal marginals in the expected table
Added -distlist- for a distance model as an alternative to uniform association
Summary statistics are printed using variable labels,
statistics can be requested to be passed on to -tabstat-,
r(StatTab) from -tabstat- is saved
-format- option (for -tabstat- and -reclass-)
Option to save the parameters as dataset
-desmat- friendly, doesn't use -desrep- during iterations,
-desrep- and -defcon- options are recognized
Version 1, July 11, 2004
Initial version
*/


program define perturb, rclass
	version 7
	preserve
	gettoken colon 0 : 0, parse(":")
	if `"`colon'"' ~= ":" {
		display as error "Syntax: perturb: -cmd- -model-, poptions(-options-) -cmdoptions-"
		exit
	}

	* split argument string in segments to take length > 80 into account
	local i 1
	local p=.
	local seg`i' : piece `i' 80 of `"`0'"'
	while `"`seg`i''"' ~= "" {
		* find first occurence of keywords as delimiter for the model
		if `p' == . | `p' == 0 {
			local p1=index(`" `seg`i'' "'," in ")
			if `p1'==0 {local p1=. }
			local p2=index(`" `seg`i'' "'," if ")
			if `p2'==0 {local p2=. }
			local p3=index(`" `seg`i'' "'," using ")
			if `p3'==0 {local p3=. }
			local p4=index(`"`seg`i''"',"[")
			if `p4'==0 {local p4=. }
			local p5=index(`"`seg`i''"',",")
			if `p5'==0 {local p5=. }
			local p=min(`p1',`p2',`p3',`p4',`p5')
			local pseg `i'
		}
		local i=`i'+1
		local seg`i' : piece `i' 80 of `"`0'"'
	}
	local nsegs=`i'-1

	if `p' ~= . & `p' > 0 {
		local model=substr(`"`seg`pseg''"',1,`p'-1)
		local 0=substr(`"`seg`pseg''"',`p',.)
		local i 1
		while `i' < `pseg' {
			local model `"`seg`i'' `model'"'
			local i=`i'+1
		}
		if `nsegs' > `pseg' {
			local i=`pseg'+1
			while `i' <= `nsegs' {
			  local 0 `"`0' `seg`i''"'
			  local i=`i'+1
			}
		}

		* Filter out the poptions
		syntax [if][in][using][fweight pweight aweight iweight] , /*
		*/ POPTions(string) [DEFCON(string) DESREP(string) *]
		if `"`weight'"' ~= "" {
			local wgtexp=`"[`weight'`exp']"'
		}
		if "`options'" ~= "" {
			local options `", `options'"'
		}
	}
	* reassemble the model statement without -potions-
	gettoken frstword model : model ,parse(":")
	if `"`frstword'"' == "desmat" {
		gettoken colon model : model ,parse(":")
		gettoken proc model : model ,parse(" ")
		gettoken depvar model : model ,parse(" ")
		local model `"desmat `model'"'
		if `"`defcon'"' ~= "" {
			local model `"`model', defcon(`defcon')"'
		}
		local modela `"`proc' `depvar' _x_* `if' `in' `wgtexp' `options'"'
		if `"`desrep'"' ~= "" {
			local desrep `", `desrep'"'
		}
	}
	else {
		local model `"`frstword' `model' `if' `in' `wgtexp' `options'"'
	}

	* Parse -poptions-
	local 0 `", `poptions'"'
	#delimit ;
	syntax [, PVars(varlist) PRange(numlist) Uniform
		PFactors(varlist) Misclass(numlist) Qlist(numlist) Ulist(numlist) Distlist(numlist) Assoc(string)
		PCnttabs(string) noADjust noBestmod Statistics(string) Format(string)
		Niter(integer 100) SAVE(string) Verbose];
	#delimit cr
	if "`verbose'" == "" {
		local how "quietly"
	}

	* check for a valid format option
	*-- taken from -tabstat.ado-
	if `"`format'"' != "" {
		capt local tmp : display `format' 1
		if _rc {
			di as err `"invalid %fmt in format(): `format'"'
			exit 120
		}
	}
	*--
	else {
		local format "%8.3f"
	}
	if "`statistics'" == "" {
		local statistics "mean sd min max"
	}
	else {
		local 0 `", `statistics'"'
		syntax [, n MEan sd Variance SUm COunt MIn MAx Range SKewness Kurtosis /*
			*/  SDMean SEMean p1 p5 p10 p25 p50 p75 p90 p95 p99 iqr q MEDian *]
		if `"`options'"' ~= "" {
			display as error `"Invalid statitics options: `options'"'
			exit 198
		}
	}
	if `"`save'"' ~= "" {
		if index(`"`save'"',".") == 0 {
			local save `"`save'.dta"'
		}
		if `"`replace'"' == "" {
			confirm new file `"`save'"'
			di _rc
		}
		else {
			confirm file `"`save'"'
		}
	}

	* estimate the model as specified, store coeffients in matrix -allb-
	if "`modela'" ~= "" {
		`how' `model'
		`how' `modela'
		matrix allb=e(b)
		desrep `desrep'
	}
	else {
		`model'
		matrix allb=e(b)
	}

	* save the variable labels for replacement in -pertsumm-
	tempname paras
	mat `paras'=e(b)
	local nms: colnames `paras'

	local i 0
	foreach nm of local nms {
		local i=`i'+1
		capture local varlb`i' : variable label `nm'
		if "`varlb`i''" == "" {
			local varlb`i' `nm'
		}
	}


	* initialize new standin variables, create modified model statement -model2-
	local model2 "`model'"
	* add spaces before and after interaction symbols
	local model2: subinstr local model2 "*"  " * ", all
	local model2: subinstr local model2 "."  " . ", all
	local model2: subinstr local model2 "|"  " | ", all
	local model2: subinstr local model2 "@"  " @ ", all

	local npvar 0

	if "`pvars'" ~= "" {
		display as text _newline "Perturb variables:" _n "{hline 50}"
		local n_pvar: word count `pvars'
		local n_prng: word count `prange'
		if `n_pvar' ~= `n_prng' {
			display as err _newline "`n_pvar' perturb variables were specified and `n_prng' perturb values"
			display as err "Ensure that a value is specified in the {input:prange} option for each variable in the {input:pvars} list"
			exit
		}

		forval i=1/`n_pvar' {
			local pv: word `i' of `pvars'
			local pr: word `i' of `prange'
			display "`pv'" _continue
			if "`uniform'" ~= "" {
				local prdis=`pr'/2
				display _col(35) "uniform(-`prdis',`prdis')"
			}
			else {
				display _col(35) "normal(0,`pr')"
			}
			tempvar pv`i'
			`how' gen `pv`i'' = .
			local model2: subinstr local model2 "`pv'"  "`pv`i''", all word
		}
	}

	* perturb factors:
	local n_pfac 0
	if "`pfactors'" ~= "" {
		local n_pfac: word count `pfactors'
		local n_p: word count `pcnttabs'
		local n_m: word count `misclass'

		local n_q: word count `qlist'
		local n_u: word count `ulist'
		local n_d: word count `distlist'
		local n_a: word count `assoc'

		* option -misclass- has the highest priority; if it is specified,
		* -assoc-, -qlist- and -ulist- will be ignored.
		* option -assoc- has next highest priority, -qlist- and -ulist- will be ignored.
		if `n_m' ~= 0 {
			if `n_pfac' ~= `n_m' {
				display as error _newline "The number of pfactors (`n_pfac') is not the same as the number of values specified in the {hi:misclass} option (`n_m')"
				exit
			}
		}
		else if `n_p' ~= 0 {
			if `n_pfac' ~= `n_p' {
				display as error _newline "The number of pfactors (`n_pfac') is not the same as the number of values specified in the {hi:pcnttabs} option (`n_p')"
				exit
			}
		}
		else if `n_a' ~= 0 {
			if `n_pfac' ~= `n_a' {
				display as error _newline "The number of pfactors (`n_pfac') is not the same as the number of values specified in the -assoc- option (`n_a')"
				exit
			}
		}
		else if `n_q' ~= 0 | `n_u' ~= 0 | `n_d' ~= 0 {
			if `n_q' ~= 0 & `n_pfac' ~= `n_q' {
				display as error _newline "The number of pfactors (`n_pfac') is not the same as the number of values specified in the -qlist- option (`n_q')"
				display as error "Enter values of 1 as standins"
				exit
			}
			if `n_d' ~= 0 & `n_pfac' ~= `n_d' {
				display as error _newline "The number of pfactors (`n_pfac') is not the same as the number of values specified in the -distlist- option (`n_d')"
				display as error "Enter values of 1 as standins"
				exit
			}
			if `n_u' ~= 0 & `n_pfac' ~= `n_u' {
				display as error _newline "The number of pfactors `n_pfac' is not the same as the number of values specified in the -ulist- options (`n_u')"
				display as error "Enter values of 1 as standins"
				exit
			}
		}
		else {
			display as error _newline "You must specify either {hi:pcnttabs}, {hi:assoc} or at least one of {hi:qlist}, {hi:ulist} or {hi:distlist}."
			exit
		}

		tempvar rndm
		`how' gen `rndm' = .
		display as text _newline "Perturb factors:" _n "{hline 50}"
		forval i=1/`n_pfac' {
			local pfac: word `i' of `pfactors'
			local qval: word `i' of `qlist'
			local uval: word `i' of `ulist'
			local dval: word `i' of `distlist'
			local aval: word `i' of `assoc'
			local mval: word `i' of `misclass'
			local pval: word `i' of `pcnttabs'
			if "`qval'" ~= "" {
				local opts "q(`qval')"
			}
			if "`uval'" ~= "" {
				local opts "`opts' u(`uval')"
			}
			else if "`dval'" ~= "" {
				local opts "`opts' dist(`dval')"
			}
			* call program -reclass- to create a matrix of reclassification probabilities
			if "`mval'" ~= "" {
				reclass `pfac', misclass(`mval') format(`format')
			}
			else if "`pval'" ~= "" {
				reclass `pfac', pcnttab(`pval') `adjust' `bestmod' format(`format')
			}
			else if "`aval'" ~= "" {
				reclass `pfac', assoc(`aval') format(`format')
			}
			else {
				reclass `pfac', `opts' format(`format')
			}
			tempname rcl`i'
			matrix `rcl`i''=r(classprob)
			tempvar pfac`i'
			`how' gen `pfac`i'' = .
			local model2: subinstr local model2 "`pfac'"  "`pfac`i''", all word
		}
	}

	* transformations
	local i 1
	local pt "${ptrans`i'}"
	if "`pt'" ~= "" {
		display as text _newline "Transformations:" _n "{hline 50}"
	}
	while "`pt'" ~= "" {
		display "`pt'"
		tokenize "`pt'", parse("=")
		tempvar pt`i'
		`how' gen `pt`i'' = .
		local model2: subinstr local model2 "`1'"  "`pt`i''", all word
		local ptrans`i' "`pt'"
		local ptrans`i': subinstr local ptrans`i' "`1'" "`pt`i''", all
		forval j=1/`n_pvar' {
			local pv: word `j' of `pvars'
			local ptrans`i': subinstr local ptrans`i' "`pv'" "`pv`j''", all word
		}
		forval j=1/`n_pfac' {
			local pfac: word `j' of `pfactors'
			local ptrans`i': subinstr local ptrans`i' "`pfac'" "`pfac`j''", all word
		}
		local i=`i'+1
		local pt="${ptrans`i'}"
	}
	local n_trans=`i'-1

	if "`uniform'" ~= "" {
		local perturb "(uniform()-.5)"
	}
	else {
		local perturb "invnorm(uniform())"
	}

	* remove the extra spaces added earlier
	local model2: subinstr local model2 " * "  "*", all
	local model2: subinstr local model2 " . "  ".", all
	local model2: subinstr local model2 " | "  "|", all
	local model2: subinstr local model2 " @ "  "@", all
	* iteratively estimate the model, adding random perturbations to the specified -pvars-
	forval k=1/`niter' {
		forval i=1/`n_pvar' {
			local pv: word `i' of `pvars'
			local pr: word `i' of `prange'
			`how' replace `pv`i'' = `pv'+`perturb'*`pr'
		}

		forval i=1/`n_pfac' {
			local ncat=rowsof(`rcl`i'')
			local pfac: word `i' of `pfactors'
			`how' replace `rndm'=uniform()
			`how' replace `pfac`i'' = 1
			forval j=1/`ncat' {
				`how' replace `pfac`i''=`j'+1 if `rndm' > el(`rcl`i'',`pfac',`j')
			}
		}
		forval i=1/`n_trans' {
			`how' replace `ptrans`i''
		}
		`how' `model2'
		if "`modela'" ~= "" {
			`how' `modela'
		}
		matrix allb=allb\e(b)
	}

	* produce summary statistics of -allb- with pertsumm
	* transform the -allb- matrix to a dataset, summarize, to show impact of perturbations
	drop _all
	* -names(col)- can't be used because "_cons" would be an invalid variable name
	capture `how' svmat allb, names(eqcol)
	if _rc ~= 0 {
		`how' svmat allb
	}
	else {
		capture rename __cons __cons_
		capture renpfix _
	}

	* replace the variable labels
	local vrnms: colnames allb
	local i 0
	foreach el of local vrnms {
		local i=`i'+1
		label var `el' `"`varlb`i''"'
	}

	display _newline "Impact of perturbations on coefficients after `niter' iterations:"
	* extra trouble to display summary statistics with variable labels
	* determine the column width based on the format
	if `"`format'"' ~= "" {
		tokenize "`format'", parse("%-.")
		if "`2'" == "-" {
			local fw=`3'+1
		}
		else {
			local fw=`2'+1
		}
	}
	else {
		local fw 10
		local format "%9.0g"
	}

	`how' tabstat *,columns(statistics) statistics(`statistics') format(`format') save

	mat stats=r(StatTot)
	matrix stats=stats'
	local cname : colnames stats
	local nstats : word count `cname'
	local R=rowsof(stats)
	local C=colsof(stats)

	* run through the variable labels, find the longest
	local rname : rownames stats
	local mxlngth 0
	foreach nm of local rname {
		local lbl : variable label `nm'
		if `"`lbl'"' == "" {local lbl `nm'}
		local mxlngth=max(`mxlngth',length(`"`lbl'"'))
	}
	local maxw : set linesize
	local maxstub=`maxw'-`fw'*`nstats'-2
	local mxlngth=min(`mxlngth',`maxstub')
	local mxlngth=`mxlngth'+1
	local seppos=`mxlngth'+1
	local linerest=`fw'*`nstats'

	display as text _newline "{ralign `mxlngth':variable}{space 1}{c |}" _continue
	local i 0
	foreach collb of local cname {
		display "{ralign `fw':`collb'}" _continue
	}
	display _newline as text "{hline `seppos'}{c +}{hline `linerest'}"
	forval i=1/`R' {
		local nm : word `i' of `rname'
		local lbl : variable label `nm'
		if `"`lbl'"' == "" {local lbl `nm'}
		display `"{text}{ralign `mxlngth':`lbl'}{space 1}{c |}"' _continue
		forval j=1/`C' {
			display as result _skip `format' stats[`i',`j'] _continue
		}
		display
	}
	display as text `"{hline `seppos'}{c BT}{hline `linerest'}"'

	if `"`save'"' ~= "" {
		if "`replace'" ~= "" {
			local save `"`save' ,replace"'
		}
		save `save'
	}

	return matrix perturb allb
	matrix stats=stats'
	return matrix StatTot stats
	restore
end
