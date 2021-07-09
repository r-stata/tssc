*! version 1.0.0 Juni 9, 2016 @ 07:46:42
*! Creates Levenshtein-Matrix for String Variables
program sqstrlev
version 14
	syntax varname(string)   ///
	  [ , INDELcost(int 1) SUBcost(string) k(int 0) standard(string) ///
	  IGNOREcase ASCIILETTERSonly SOUNDex]
	
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

	quietly {

	tempvar SQis
	gen `SQis' = trim(itrim(`varlist')) 
	if "`ignorecase'" != "" {
		replace `SQis' = ustrupper(`SQis') 
	}
	if "`asciilettersonly'" != "" {
		replace `SQis' = regexr(`SQis',"[^0-9A-Za-z ]+","") 
	}

	if "`soundex'" != "" {
		replace `SQis' = soundex(`SQis') if `touse'
	}

	
	// Handle Standardisation Option
	capture confirm integer number `standard'
	if !_rc {
		replace `SQis' = usubstr(`SQis',1,`standard') 
		local standard none
	}
	else if "`standard'" == "cut" {
		tempvar length
		gen `length' = ustrlen(`SQis') if `touse'
		summarize `length'
		replace `SQis' = usubstr(`SQis',1,r(min)) 
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
	tempvar N
	keep `varlist' `SQis' 
	by `varlist', sort: gen `N' = _N
	quietly by `varlist', sort: keep if _n==1

	// Mata
	mata: sqstrlev("`SQis'",`indelcost',"`standard'",`k',`subcost')
	mata: sqexpand()

	restore
	noi di "{txt}Distance matrix saved as {res}SQdist" _n ///
	  "{txt}Note: Sort data by `varlist' for analyses on SQdist{res}"

	}
end


	

