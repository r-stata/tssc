
*! version 1.4  5oct2016 James J Feigenbaum

/*******************************************************************************
James J Feigenbaum
June 10, 2014
jfeigenb@fas.harvard.edu
james.feigenbaum@gmail.com

jarowinkler.ado file
Implements the Jaro-Winkler and Jaro string distance measure.
*******************************************************************************/

version 10.0

*** define program and syntax
program define jarowinkler, rclass
    syntax varlist(min=2 max=2 string) , [GENerate(name) JAROonly(name) Pwinkler(real 0.1)]
	
	*** generate variable name 
    if `"`generate'"' == "" local generate "jarowinkler"
    confirm new variable `generate'
	
	if "`jaroonly'"!="" {
		confirm new variable `jaroonly'
						}
    tokenize "`varlist'"
	
	quietly {

		tempvar s1 s2

		gen `s1' = lower(`1')
		gen `s2' = lower(`2')
				
		tempvar len1 len2 halflen common1 common2 workstr1 workstr2 ass1 ass2 length_ass1 transposition l first1 first2
		tempvar char start end temp index

		tempvar jaro
		
		gen `len1' = length(`s1')
		gen `len2' = length(`s2')

		**first get the Jaro distance
		gen `halflen' = floor(max(`len1',`len2') / 2) - 1

		qui: sum `len1'
		local L1 = r(max)

		qui: sum `len2'
		local L2 = r(max)

		gen `common1' = 0
		gen `common2' = 0

		gen `workstr1' = `s1'
		gen `workstr2' = `s2'

		gen `ass1' = ""
		gen `ass2' = ""

		**first string
		forval i = 1(1)`L1' {

			gen `char' = substr(`s1',`i',1)
			gen `start' = max(1,`i'-`halflen')
			gen `end' = min(`i' + `halflen', `len2')
			gen `temp' = substr(`workstr2',`start',`end'-`start'+1)
			gen `index' = strpos(`temp',`char')
			replace `index' = `index' + max(`start',1)-1 if `index' != 0

			replace `common1' = `common1' + 1 if `index' != 0 & `char' != ""
			replace `ass1' = `ass1' + `char' if `index' != 0 & `char' != ""
			replace `workstr2' = substr(`workstr2',1,`index'-1) + char(64) + substr(`workstr2',`index'+1,.) if `index' != 0 & `char' != ""
			*noisily di `i' "..." `workstr2'[27]
			drop `start' `end' `index' `temp'
			drop `char'

		}

		**second string
		forval i = 1(1)`L2' {
			gen `char' = substr(`s2',`i',1)
			gen `start' = max(1,`i'-`halflen')
			gen `end' = min(`i' + `halflen', `len1')
			gen `temp' = substr(`workstr1',`start',`end'-`start'+1)
			gen `index' = strpos(`temp',`char')
			replace `index' = `index' + max(`start',1)-1 if `index' != 0

			replace `common2' = `common2' + 1 if `index' != 0 & `char' != ""
			replace `ass2' = `ass2' + `char' if `index' != 0 & `char' != ""
			replace `workstr1' = substr(`workstr1',1,`index'-1) + char(64) + substr(`workstr1',`index'+1,.) if `index' != 0 & `char' != ""
			*noisily di `i' "..." `workstr1'[8]
			drop `start' `end' `index' `temp'
			drop `char'

		}

		*count if `common1' != `common2'

		gen `length_ass1' = length(`ass1')
		qui: sum `length_ass1'
		local A1 = r(max)

		gen `transposition' = 0
		forval i = 1(1)`A1' {
			replace `transposition' = `transposition' + 1 if substr(`ass1',`i',1) != substr(`ass2',`i',1)
		}
		replace `transposition' = `transposition' / 2

		gen `jaro' = 1/3 * (`common1' / `len1' + `common1' / `len2' + (`common1' - `transposition') / `common1')
		replace `jaro' = 0 if `jaro' == .
		replace `jaro' = 1 if `s1' == `s2'
		format `jaro' %10.3f
		
		if "`jaroonly'"!="" {
		gen `jaroonly' = `jaro'
		
				}

		**then convert jaro to jarowinkler

		**need the length of the common prefix
		gen `l' = 0
		gen `first1' = ""
		gen `first2' = ""

		forval i = 1(1)4 {
			replace `first1' = substr(`s1',1,`i')
			replace `first2' = substr(`s2',1,`i')
			replace `l' = `i' if `first1' == `first2'	& `len1' >= `i' & `len2' >= `i'
		}

		gen `generate' = `jaro' + (`l' * `pwinkler' * (1- `jaro'))
		format `generate' %10.3f

	}

	return local jarowinkler "`generate'"
	if "`jaroonly'"!="" {
	return local jaro "`jaroonly'"
	}
	
end

