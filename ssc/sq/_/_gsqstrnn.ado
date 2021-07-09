*! version 1.0 Juni 6, 2016 @ 22:17:16
*! ukohler@uni-potsdam.de
*! Creates Variable with nearest neigbours of strings

* 1.0: initial version

program _gsqstrnn
version 14.0
	gettoken type 0 : 0
	gettoken h    0 : 0 
	gettoken eqs  0 : 0
	
	syntax [varname] [if] [in] ///
	  [ , INDELcost(int 1) SUBcost(string) k(int 0) standard(string) ///
	  max(int 1) by(varname) ///
	  IGNOREcase ASCIILETTERSonly SOUNDex ]

	marksample touse, novarlist


	quietly {
	
	// Construct the subcost matrix
	// ----------------------------
    
	if "`subcost'" == "" {
		local subcost = `indelcost'*2
	}
	capture confirm number `subcost'
	if _rc {
		capture matrix SQsubcost = `subcost'
		if _rc{
			noi di as error ///
			  "subcost() invalid: specify number or matrix"
			exit 198
		}

		//is subcostmatrix symmetric?
		local issym = issymmetric(SQsubcost)
		if !`issym'{
			noi di as error ///
			  "subcostmatrix invalid: subcostmatrix is not symmetric"
			exit 198
		}
				
		local subcost 0
	}
        
	// Create a working copy of Stringvar
	// ----------------------------------

	tempvar SQis
	gen `SQis' = trim(itrim(`varlist')) if `touse'
	if "`ignorecase'" != "" {
		replace `SQis' = ustrupper(`SQis') if `touse'
	}
	if "`asciilettersonly'" != "" {
		replace `SQis' = regexr(`SQis',"[^0-9A-Za-z ]+","") if `touse'
	}

	if "`soundex'" != "" {
		replace `SQis' = soundex(`SQis') if `touse'
	}

	// Handle Standardisation Option
	capture confirm integer number `standard'
	if !_rc {
		replace `SQis' = usubstr(`SQis',1,`standard') if `touse'
		local standard none
	}
	else if "`standard'" == "cut" {
		tempvar length
		gen `length' = ustrlen(`SQis') if `touse'
		summarize `length'
		replace `SQis' = usubstr(`SQis',1,r(min)) if `touse'
		local standard none
	}
	else if "`standard'" == "" {
		local standard longest
	}
	else if "`standard'" != "none" & "`standard'" != "longer" {
		noi di as error "standard() invalid"
		exit 198
	}

	// Shrink the data for Speeding ...
	// --------------------------------

	preserve 
	keep `varlist' `SQis' `touse' `by'
	keep if `touse'
	bys `by' `SQis': keep if _n==1

	// Byvar
	// ----------

	if "`by'" != "" {
		quietly levelsof `by', local(K)
		if `:word count `K'' != 2 {
			di "{err} Byvar does not have 2 categories"
			exit 198
		}
		count if `by' == `:word 1 of `K''
		local splitat = r(N)+1 
	}
	else local splitat . 

	// Mata
	display `"mata: sqstrnn("`varlist'","`SQis'",`indelcost',"`standard'",`k',`subcost',`max',`splitat')"'
	mata: sqstrnn("`varlist'","`SQis'",`indelcost',"`standard'",`k',`subcost',`max',`splitat')

	// Bring Back Mata-Results to Orignal Data
	sort `by' `SQis'
	tempfile x
	save `x'

	restore 
	merge m:1 `by' `SQis' using `x'
	assert _merge != 2
	drop _merge
	gen `h' = _SQstrnn
	drop _SQstrnn

	label variable `h' "Strings most similar to `varlist'"
}
end
		


exit
	
