*! version 0.1.2  2017-04-20
*! Bug when using stcox and icp fixed
version 11


program define icp, rclass
	local input_ok = regexm(`"`0'"', "(.*):(.*)$")
	if "`input_ok'" == "1" {
		local options = regexs(1)
		local code = regexs(2)
	}
	else {
		display as error `"Input is not proper for prefixes. input=`0'"'
		exit //111
	}

	local referenceA = 0
	if regexm(`"`options'"', "referenceA\(([0-9]+)\)") {
		local referenceA = regexs(1)
	}
	local referenceB = 0
	if regexm(`"`options'"', "referenceB\(([0-9]+)\)") {
		local referenceB = regexs(1)
	}
	local exposedA = 1
	if regexm(`"`options'"', "exposedA\(([0-9]+)\)") {
		local exposedA = regexs(1)
	}
	local exposedB = 1
	if regexm(`"`options'"', "exposedB\(([0-9]+)\)") {
		local exposedB = regexs(1)
	}

	if regexm(`"`code'"', "(logistic|binreg|poisson|logit) ([^ ,]+) ([^ ,]+) ([^ ,]+)(.*)$") {
		local method = regexs(1)
		local outcome  = regexs(2)
		local A  = regexs(3)
		local B  = regexs(4)
		local rest = regexs(5)
	}
	else if regexm(`"`code'"', "(stcox) ([^ ,]+) ([^ ,]+)(.*)$") {
		local method = regexs(1)
		local outcome  = ""
		local A  = regexs(2)
		local B  = regexs(3)
		local rest = regexs(4)
	}
	else {
		di as error "The regression is not of the proper layout"
		display `"code=|`code'|"'
		exit //111
	}
	tempvar marker
	generate `marker' = inlist(`A', `referenceA', `exposedA') & inlist(`B', `referenceB', `exposedB')
	
	quietly capture drop _`A'_AND_`B' _`A'_NOT_`B' _`B'_NOT_`A'
	quietly generate _`A'_AND_`B' = (`A' == `exposedA' & `B' == `exposedB') if `marker'
	quietly generate _`A'_NOT_`B' = (`A' == `exposedA' & `B' == `referenceB') if `marker'
	quietly generate _`B'_NOT_`A' = (`A'== `referenceA' & `B' == `exposedB') if `marker'
	quietly  replace _`A'_AND_`B' = 0 if !`marker' & !missing(`A', `B')
	quietly  replace _`A'_NOT_`B' = 0 if !`marker' & !missing(`A', `B')
	quietly  replace _`B'_NOT_`A' = 0 if !`marker' & !missing(`A', `B')

	local regression `method' `outcome' _`A'_NOT_`B' _`B'_NOT_`A' _`A'_AND_`B' `rest'

	if regexm(`"`options'"', "show|SHOW") {
		`regression'
	}
	else {
		quietly `regression'
		quietly drop _`A'_AND_`B' _`A'_NOT_`B' _`B'_NOT_`A'
	}

	tempname est var output
	matrix `est' = e(b)'
	matrix roweq `est' = ""
	matrix `est' = `est'[1..3, 1]
	matrix `var' = e(V)
	matrix roweq `var' = ""
	matrix coleq `var' = ""
	matrix `var' = `var'[1..3, 1..3]
	
	ici `est' `var' `"`A'_NOT_`B' `B'_NOT_`A' `A'_AND_`B'"'
	matrix `output' = r(output)
	
	return matrix output = `output'
	return local labels = `"`A'_NOT_`B' `B'_NOT_`A' `A'_AND_`B'"'
	return matrix est = `est'
	return matrix var = `var'
end
