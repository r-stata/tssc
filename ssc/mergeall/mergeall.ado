*! v1 by Ryan Knight 18feb2011

prog def mergeall
	version 10.1

	syntax namelist using/ ///
	[, strings(namelist) force do(string) ///
	double txt csv dta tab comma ///
	showsource format(string) pattern(string)]

	quietly {
	
	cap assert _N == 0
	if _rc {
		noisily di as err "you must start with an empty dataset"
		exit 18
	}
	if "`strings'" !="" & "`force'"=="" {
		noisily di _newline as err "force option must be specified with strings option"
		exit 198
	}
	local id `namelist'
	if "`id'" == "" {
		noisily di as err "unique identifier must be specified"
		exit 198
	}
	
	if "`format'" != "" {
		local format format( `format' )
	}
	else {
		local format format( %37.0g )
	}
	
	* Get lists of files to compare
	local ext `txt'`csv'`dta'
	if "`ext'" == "" & "`pattern'" == "" {
		local pattern *.csv
	}
	else if "`pattern'" == "" {
		local pattern *.`txt'`csv'`dta'
	}
	else {
		local pattern `pattern'
	}

	local files: dir `"`using'"' files `"`pattern'"', respectcase 

	* " Generate an empty dataset to merge into
	clear
	gen `id'=.
	gen _disagreement = .
	if "`showsource'" != "" {
		gen _source = ""
		gen _dissource = ""
	}
	tempfile all thisfile
	save `all', replace

	* Loop through files in each entry, merging into a single master file for each entry
	noisily di as txt "Merging files:"
	local i = 0
	foreach ifile in `files' {
		* Save file name in a global so it can be accessed by the cleaning .do file if necessary
		global filename `ifile'
		noisily di as res "$filename"
		
		if "`ext'" == "dta" | "`ext'" == ".dta" {
			use `"`using'/`ifile'"' , clear			// "
		}
		else {
			insheet using `"`using'/`ifile'"', clear `comma' `tab' `double'		// "
		}
		
		if "`do'" != "" {
			do `"`do'"'			// "
		}

		* List duplicates
		drop if `id' ==.
		cap isid `id'
		if _rc {
			duplicates tag `id' , gen(_iddup)
			di as err "`id' does not uniquely identify the following observations in $filename"
			list `id' if _iddup
			exit 459
		}
		
		if "`strings'" != "" {
			* Set strings/numeric
			ds , has(type string) /* Get a list of all the string vars in the dataset */
			local isstring `r(varlist)'
			local destringers: list isstring - strings /* Finds vars that are string but shouldn't be */
			if "`destringers'" != "" {
				destring `destringers', replace force 
			}
			
			tostring `strings', replace force `format'
			cap confirm string variable `notstring'
			if _rc {
				exiterr
			}
			
			merge `id' using `all', sort update
			
		}
		else {
			* Set every variable that has a string in any file to string
			ds , has(type numeric)
			local numhere `r(varlist)'
			
			ds , has(type string)
			local strhere `r(varlist)'
			
			local stranywhere: list stranywhere | strhere
			
			local notstring: list stranywhere & numhere
			if "`notstring'" != "" {
				tostring `notstring', replace `format'
				cap confirm string variable `notstring'
				if _rc {
					exiterr
				}
			}
						
			* Merge datasets
			save `thisfile', replace
			use `all', clear
			
			local i = `i'+1			
			if `i' > 1 {	
				ds , has(type numeric)
				local numhere `r(varlist)'
				local notstring: list stranywhere & numhere
				if "`notstring'" != "" {
					tostring `notstring', replace `format'
					cap confirm string variable `notstring'
					if _rc {
						exiterr
					}
				}
			}
			merge `id' using `thisfile', sort update
			
			if "`showsource'" != "" {
				replace _source = "$filename" if _merge == 2
				replace _dissource = "$filename" if _merge == 5
			}
		}
		
		replace _disagreement = 1 if _merge == 5
		cap drop _merge			
		save `all', replace 
	}

	count if _disagreement ==1
	if `r(N)' == 0 {
		drop _disagreement
		cap drop _dissource
	}
	else {
		replace _disagreement=0 if _disagreement==.
		noisily di as err "Note: Information may have been lost due to disagreement between datasets"
	}
	
	}
	
end

program def exiterr

di as err "Data cannot be converted to string without loss of information." ///
	_newline "You need to specify an appropraite format using the format() option"
exit 198

end 
				
				
