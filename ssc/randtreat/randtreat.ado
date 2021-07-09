*! 1.4 Alvaro Carril 05apr2017
program define randtreat, sortpreserve
	version 11

syntax [if] [in] [ , ///
	STrata(varlist numeric) ///
	MULTiple(integer -1) ///
	UNequal(string) ///
	MIsfits(string) ///
	SEtseed(integer -1) ///
	Generate(name) ///
	replace ///
]

*-------------------------------------------------------------------------------
* Input checks
*-------------------------------------------------------------------------------

* stratvars()
local stratvars `strata'

* unequal()
// If not specified, complete it to be equal fractions according to mult()
if missing("`unequal'") {
	// If multiple() is also empty, set to 2 treatments
	if `multiple'==-1 local multiple 2
	// Create fractions in unequal with even treatments
	forvalues i = 1/`multiple' {
		local unequal `unequal' 1/`multiple'
	}
}
// If unequal() is specified, perform various checks
else {
	// If mult() is empty, replace it with the number of fractions in unequal()
	if `multiple'==-1  {
		local multiple : list sizeof unequal
	}
	// Check that unequal() has same number of fractions as the number of treatments specified in mult()
	else {
		if `: word count `unequal'' != `multiple' {
			display as error "mult() has to match the number of fractions in unequal()"
			exit 121
		}
	}
	// Check range of fractions
	tokenize `unequal'
	while "`1'" != "" {
		if (`1' <= 0 | `1'>=1) {
			display as error "unequal() must contain a list of fractions each between 0 and 1"
			exit 125
		}
		macro shift
	}
}

* replace
// If specified, check if 'treatment' variable exists and drop it before the show starts
if !missing("`replace'") {
	capture confirm variable `generate'
	if !_rc drop `generate'
}

* misfits()
// If specified, check that a valid option was passed
if !missing("`misfits'") {
	_assert inlist("`misfits'", "missing", "strata", "wstrata", "global", "wglobal"), rc(7) ///
	msg("misfits() argument must be either {it:missing}, {it:strata}, {it:wstrata}, {it:global} or {it:wglobal}")
}

*-------------------------------------------------------------------------------
* Pre-randomization stuff
*-------------------------------------------------------------------------------

// Initial setup
tempvar treatment strata randnum rank_treat misfit cellid obs
marksample touse, novarlist
quietly count if `touse'
if r(N) == 0 error 2000

// Create strata tempvar and local with levels
egen `strata' = group(`stratvars') if `touse'
qui levelsof `strata', local(Nstrata)

// Set seed
if `setseed' != -1 set seed `setseed'

// local with all treatments (B vector)
forvalues i = 1/`multiple' {
	local treatments `treatments' `i'
}

// local with number of treatments (T)
local T = `multiple'

* Construct randpack
*-------------------------------------------------------------------------------

// local `unequal2' with spaces instead of slashes
local unequal2 = subinstr("`unequal'", "/", " ", .)

// simplify fractions
foreach f of numlist 1/`T' {
	local a : word `=2*`f'-1' of `unequal2'
	local b : word `=2*`f'' of `unequal2'
	gcd `a' `b'
	local a = `a'/`r(gcd)'
	local b = `b'/`r(gcd)'
	local unequal_reduc `unequal_reduc' `a' `b'
}

// tokenize unequal() fractions with 'u' stub
tokenize `unequal'
local i = 1
while "``i''" != "" { 
	local u`i' `"``i''"'
	local i = `i' + 1
}

// tokenize denominators of unequal() with 'den' stub
tokenize `unequal_reduc'
local n = 1
forvalues i = 2(2)`=`T'*2' {
	local den`n' `"``i''"'
	local n = `n' + 1
}
local n = `n' - 1

// local 'denoms' with all denominators
forvalues i = 1/`T' {
	local denoms `denoms' `den`i''
}

// compute least common multiple of all denominators (J)
lcmm `denoms'
local lcm = `r(lcm)'

// auxiliary macro randpack1 with the number of times each treatment should be repeated in the randpack
forvalues i = 1/`T' {
	local randpack1 `randpack1' `lcm'*`u`i''
}

// tokenize randpack1 with 'aux' stub --> three loops may be inefficient
tokenize `randpack1'
forvalues i = 1/`T' {
	local aux`i' = ``i''
}
forvalues i = 1/`T' {
	local randpack2 `randpack2' `aux`i''
}

// generate randpack
forvalues k = 1/`T' {
	forvalues i = 1/`aux`k'' {
		local randpack `randpack' `k'
	}
}
local J `lcm' // size of randpack

* random shuffle of randpack and treatments
mata : st_local("randpackshuffle", invtokens(jumble(tokens(st_local("randpack"))')'))
mata : st_local("treatmentsshuffle", invtokens(jumble(tokens(st_local("treatments"))')'))

* Check sum of fractions
*-------------------------------------------------------------------------------
tokenize `unequal'
while "`1'" != "" {
	local unequal_sum = `unequal_sum'+`1'*`lcm'
	macro shift
}
local unequal_sum = `unequal_sum'/`lcm'
if `unequal_sum' != 1 {
	display as error "fractions in unequal() must add up to 1"
	exit 121
}

*-------------------------------------------------------------------------------
* The actual randomization stuff
*-------------------------------------------------------------------------------

* Create some locals and tempvar for randomization
local first : word 1 of `randpack'
gen double `randnum' = runiform()

* First-pass randomization
*-------------------------------------------------------------------------------

// Random sort on strata
sort `touse' `stratvars' `randnum', stable
gen long `obs' = _n

// Assign treatments randomly and according to specified proportions in unequal()
quietly bysort `touse' `stratvars' (`_n') : gen `treatment' = `first' if `touse'
quietly by `touse' `stratvars' : replace `treatment' = ///
	real(word("`randpack'", mod(_n - 1, `J') + 1)) if _n > 1 & `touse'
	
// Mark misfits as missing values and display that count
quietly by `touse' `stratvars' : replace `treatment' = . if _n > _N - mod(_N,`J')
quietly count if mi(`treatment') & `touse'
di as text "assignment produces `r(N)' misfits"

* Dealing with misfits
*-------------------------------------------------------------------------------
// wglobal
if "`misfits'" == "wglobal" {
	quietly replace `treatment' = ///
		real(word("`randpackshuffle'", mod(_n - 1, `J') + 1)) if mi(`treatment') & `touse'
}
// wstrata
if "`misfits'" == "wstrata" {
	foreach s in `Nstrata' {
		mata : st_local("randpackshuffle", invtokens(jumble(tokens(st_local("randpack"))')'))
		quietly bys `touse' : replace `treatment' = ///
			real(word("`randpackshuffle'", mod(_n - 1, `J') + 1)) if mi(`treatment') & `strata'==`s' & `touse'
	}
}
// global
if "`misfits'" == "global" {
	quietly replace `treatment' = ///
		real(word("`treatmentsshuffle'", mod(_n - 1, `T') + 1)) if mi(`treatment') & `touse'
}
// strata
if "`misfits'" == "strata" {
	foreach s in `Nstrata' {
		mata : st_local("treatmentsshuffle", invtokens(jumble(tokens(st_local("treatments"))')'))
		quietly bys `touse' : replace `treatment' = ///
			real(word("`treatmentsshuffle'", mod(_n - 1, `T') + 1)) if mi(`treatment') & `strata'==`s' & `touse' 
	}
}
*-------------------------------------------------------------------------------
* Closing the curtains
*-------------------------------------------------------------------------------

gen `generate' = `treatment'-1
end

*-------------------------------------------------------------------------------
* Define auxiliary programs
*-------------------------------------------------------------------------------

* Greatest Common Denominator (GCD) of 2 integers
program define gcd, rclass
    if "`2'" == "" {
        return scalar gcd = `1'
    }
    else {
        while `2' {
            local temp2 = `2'
            local 2 = mod(`1',`2')
            local 1 = `temp2'
        }
        return scalar gcd = `1'
    }
end

* Least Common Multiple (LCM) of 2 integers
program define lcm, rclass
    if "`2'" == "" {
        return scalar lcm = `1'
    }
    else {
        gcd `1' `2'
        return scalar lcm = `1' * `2' / r(gcd)
    }
end

* LCM of arbitrarily long list of integers
program define lcmm, rclass
    clear results
    foreach i of local 0 {
        lcm `i' `r(lcm)'
    }
    return scalar lcm = r(lcm)
end

********************************************************************************

/* 
CHANGE LOG
1.4
	- Fix major bug where the randpack was only shuffled once for all strata,
	causing systematic allocation of misfits to one particular treatment
	- Allow to generate(newvar) for treatment var and replace
	- Set default value of multiple() to -1 and fix cross checks with uneven
1.3
	- sortpreserve as default program option
	- Improve unequal() fractions sum check to be more precise and account for
	sums greater than 1
	- Improvements in setseed option: accept only integers and only set seed if
	option is specified
	- Implement stratification varlist as strata() option with `stratvars' local
	- Rename mult() option to multiple() for consistency and improve efficiency
	of checks related to the option
	- Allow "if" and "in" in syntax
1.2
	- Added separate sub-programs for GCD and LCM (thanks to Nils Enevoldsen)
	- Simplified fractions in unequal()
1.1.1
	- Changed all instances of uneven to unequal, to match paper
	- Minor improvemnts in input checks
	- Lots of edits to comments
1.1.0
	- Reimplemented misfits() w-methods
	- Reimplemented randpack shuffling in Mata
	- Implemented unweighted misfits() methods
	- Implemented sortpreserve option
	- Implemented setseed() option
	- Error messages more akin to official errors
	- Deleted check for varlist with misfits, made no sense (?)
1.0.5
	- Much improved help file
1.0.4
	- No longer need sortlistby module
1.0.3
	- Added misfits() options: overall, strata, missing
	- Depends on sortlistby module
1.0.2
	- Stop the use of egenmore() repeat for the sequence filling (thanks to Nick
	Cox).
	- Code for treatment assignment is now case-independent of wether a varlist 
	is specified or not
	- Fixed an bug in which the assignment without varlist would not be
	reproducible, even after setting the seed
1.0.1
	- Minor code improvements
1.0.0
	- First working version

TODOS (AND IDEAS TO MAKE RANDTREAT EVEN COOLER)
- Use gen(varname) instead of hard-wired 'treatment'. Would loose 'replace' though (?)
- Add support for [if] and [in].
- Support for [by](?) May be redundant/confusing.
- Store in e() and r(): seed? seed stage?
*/

