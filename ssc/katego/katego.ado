*! version 1.0 13/08/2014

program define katego
	version 10.0
	args varname newvar instruction

* General error verification
	local glue = 4
	while "``glue''" != "" {
		local instruction `instruction' ``glue''
		local glue = `glue'+1
		}
	if "`instruction'" == "" {
		di as error "Too few arguments, please see help file for details and examples"
		exit 197
		}	

	confirm variable `varname'
	confirm numeric variable `varname'
	confirm new variable `newvar'
	qui summ `varname'
	local minv = r(min)
	local maxv = r(max)
	if r(N) == 0 {
		di as error "`varname' has only missing values"
		exit 459
		}

* Checking instruction and extracting info
	local instruction = itrim(trim("`instruction'")) // I need to verify if this line is actually necessary
	local tkns = wordcount("`instruction'") // tkns is the number of tokens in instruction
	if mod(`tkns',2) == 1 { // an odd number of tokens indicates an incomplete interval
		di as error "Incomplete instruction, please check if intervals are complete and that intervals are separated with spaces"
		exit 459
		}
	
	if regexm("`instruction'","min max") == 1 {
	di as error "Interval [min max] will create a single category"
	exit
	}
	
	tokenize `instruction'
	local tmu = `tkns' - 1
	
	foreach toke of numlist 1(2)`tmu' { // toke is the number of each token in instruction
		if regexm("``toke''",`"^(\[|\()(min|[0-9]+|[0-9]*.[0-9]+|-[0-9]+|-[0-9]*.[0-9]+)$"') == 1 { // checks if odd token has an aperture sequence: symbol+number
			local s`toke' = regexs(1) // saves the symbol in a macro
			if regexs(2) == "min" local n`toke' = `minv' // saves the minimum value in a macro when min is specified
			else local n`toke' = real(regexs(2)) // saves the number in a macro
			}
		else {
			di as error "Instruction was incorrectly specified in ``toke'', please see help for details and examples"
			exit 197
			}
		}

	foreach toke of numlist 2(2)`tkns' { // toke is the number of each token in instruction
		if regexm("``toke''",`"^(max|[0-9]+|[0-9]*.[0-9]+|-[0-9]+|-[0-9]*.[0-9]+)(\]|\))$"') == 1 { // checks if even token has a closure sequecence: number+symbol
			local s`toke' = regexs(2) // saves the symbol in a macro
			if regexs(1) == "max" local n`toke' = `maxv' // saves the maximum value in a macro when max is specified
			else local n`toke' = real(regexs(1)) // saves the number in a macro
			}
		else {
			di as error "Instruction was incorrectly specified in ``toke'', please see help for details and examples"
			exit 197
			}
		}

* Checking gaps and overlaps
	local tmd = `tkns'-2
	if `tkns' > 2 {
		foreach cnt of numlist 2(2)`tmd' {
			local masuno = `cnt' + 1
			local menosuno = `cnt' - 1
			local masdos = `cnt' + 2
			if `n`cnt'' > `n`masuno'' {
				di as error "Overlapping intervals `s`menosuno''`n`menosuno'' `n`cnt''`s`cnt'' `s`masuno''`n`masuno'' `n`masdos''`s`masdos''" 
				exit 459
				}
			if `n`cnt'' < `n`masuno'' {
				di as error "Gap detected between intervals `s`menosuno''`n`menosuno'' `n`cnt''`s`cnt'' `s`masuno''`n`masuno'' `n`masdos''`s`masdos''"
				exit 459
				}
			if `n`cnt'' == `n`masuno'' & "`s`cnt''" == "]" & "`s`masuno''" == "[" {
				di as error "Overlapping intervals `s`menosuno''`n`menosuno'' `n`cnt''`s`cnt'' `s`masuno''`n`masuno'' `n`masdos''`s`masdos''"
				exit 459
				}
			if `n`cnt'' == `n`masuno'' & "`s`cnt''" == ")" & "`s`masuno''" == "(" {
				di as error "Gap detected between intervals `s`menosuno''`n`menosuno'' `n`cnt''`s`cnt'' `s`masuno''`n`masuno'' `n`masdos''`s`masdos''"
				exit 459
				}
			}
		}

* Checking inverse order
	foreach cnt of numlist 1(2)`tmu' {
			local masuno = `cnt' + 1
			if `n`cnt'' > `n`masuno'' {
				di as error "Inverse order in interval `s`cnt''`n`cnt'' `n`masuno''`s`masuno''" 
				exit 459
				}
			if `n`cnt'' == `n`masuno'' & "`s`cnt''" == "(" & "`s`masuno''" == ")" {
				di as error "Interval `s`cnt''`n`cnt'' `n`masuno''`s`masuno'' causes an overlap"
				exit 459
				}
			if `n`cnt'' == `n`masuno'' & "`s`cnt''" == "[" & "`s`masuno''" == ")" {
				di as error "Interval `s`cnt''`n`cnt'' `n`masuno''`s`masuno'' is empty"
				exit 459
				}
			if `n`cnt'' == `n`masuno'' & "`s`cnt''" == "(" & "`s`masuno''" == "]" {
				di as error "Interval `s`cnt''`n`cnt'' `n`masuno''`s`masuno'' is empty"
				exit 459
				}
			}
	
* Determining number of categories
	if regexm("`instruction'","min") == 1 & regexm("`instruction'","max") == 1 local noc = `tkns'/2
	if regexm("`instruction'","min") == 1 & regexm("`instruction'","max") == 0 local noc = (`tkns'/2)+1
	if regexm("`instruction'","min") == 0 & regexm("`instruction'","max") == 1 local noc = (`tkns'/2)+1
	if regexm("`instruction'","min") == 0 & regexm("`instruction'","max") == 0 local noc = (`tkns'/2)+2

* Determining first and last position			
	if regexm("`instruction'","min") == 1 local fir = 2
	else local fir = 1
	if regexm("`instruction'","max") == 1 local las = `tmu'
	else local las = `tkns'

* Creating the variable and categories
	qui generate `newvar' = .
	label var `newvar' "Categories of `varname'"
	
	* first category
	if "`s`fir''" == "(" | "`s`fir''" == "]" local symb "<="
	if "`s`fir''" == "[" | "`s`fir''" == ")" local symb "<"	
	qui replace `newvar' = 0 if `varname' `symb' `n`fir''
	label define `newvar' 0 "`symb' `n`fir''"
	
	* last category
	if "`s`las''" == "(" | "`s`las''" == "]" local symb ">"
	if "`s`las''" == "[" | "`s`las''" == ")" local symb ">="	
	qui replace `newvar' = `noc'-1 if `varname' `symb' `n`las''
	local cmu = `noc'-1
	label define `newvar' `cmu' "`symb' `n`las''", add
	
	* remaining categories in the middle
	if `noc' > 2 {
	local cim = `noc' - 2
	if `fir' == 2 local fir = 3
	local x1 = `fir'
	local x2 = `fir'+1
	foreach catval of numlist 1/`cim' {
		if "`s`x1''" == "(" local sya = ">"
		if "`s`x1''" == "[" local sya = ">="	
		if "`s`x2''" == ")" local syb = "<"	
		if "`s`x2''" == "]" local syb = "<="	
		qui replace `newvar' = `catval' if `varname' `sya' `n`x1'' & `varname' `syb' `n`x2''
		label define `newvar' `catval' "`s`x1''`n`x1'' `n`x2''`s`x2''", add
		local x1 = `x1'+2
		local x2 = `x2'+2
		}
	}
	qui replace `newvar' = . if `varname' == .
	label values `newvar' `newvar'
end
