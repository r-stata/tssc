/*******************************************************************************


excelclean automatically loads all excel files in a specified directory, 
organizes variable names and labels, reshapes the dataset if necessary, 
and integrates all files into a cleaned dataset

Author: Lu Han 
Last update: 24 Jul 2018

*******************************************************************************/


capture program drop excelclean 
program define excelclean 

	syntax , Datadir(string) sheet(string) cellrange(string) ///
	         [RESultdir(string) EXtension(string) namerange(integer 1) namelines(string) ///
			 Wordfilter(string) Droplist(string) pivot integrate]

			 
	version 13.1
	
	cd "`datadir'"
	if "`extension'" == "" {
		local extension xlsx
	}
	if "`resultdir'" == "" {
		local resultdir `c(pwd)'
	}
	if "`namelines'" == ""  {
		local namelines "1"
	}
	
	
	local allfiles : dir "." files "*.`extension'"  
		
	tempfile building
	clear    
	qui save `building', emptyok
	foreach f of local allfiles {
		di "Analyzing `f'"
		qui {
		
		import excel using "`f'", clear sheet(`sheet') cellrange(`cellrange') 
		
			local emptyid = 1
			foreach var of varlist _all {
				
				local label = ""
				foreach name of local namelines {
					local label = "`label'" + `var'[`name']	
				}
								
				if "`label'" == "" {
					local label "id`emptyid'_"
					local ++emptyid
				}
				
				local n_chars = length("`label'")					
				forv i = 1/`n_chars' { 
					 local char = substr("`label'", `i', 1) 
					 if inrange("`char'", "a", "z") | inrange("`char'", "A", "Z") | inrange("`char'", "0", "9") | "`char'" == " "   {
					 }
					 else {
						local label = subinstr("`label'","`char'"," ",1)				 
					 }
				}
				
				// debug 1
				di "processing `label'"
				foreach str of local wordfilter {
					local label = subinstr("`label'","`str' ","",.)
				}
				local label = stritrim("`label'")			
				// debug 2
				di "processing 2 `label'"
				
				local n_words : word count `label'           //word must be separated by a space
				local last_word `: word `n_words' of `label''
				local newname = subinstr("`label'","`last_word'","",.)  // delete the last word (may contain year) from the label 
				if regexm("`last_word'","[0-9]$") == 0 {
					local reshape_opt "string"
				}
				// debug 3
				di "new name `newname'"
				// get the first letter of each word and formulate variable name 
				local n_words : word count `newname'
				local newname2 = ""
				forv i = 1(1)`n_words' {
					local name `:word `i' of `newname''
					local name = upper(substr("`name'",1,1))    // (1,1) take the first letter 
					local newname2 = "`newname2'" + "`name'"
				}
				
				local newname2 = "`newname2'"  + "_`last_word'"			

				di "`newname2'"
				rename `var' `newname2'
				label var `newname2' "`newname'"
			}
			
			drop if _n <= `namerange'

			foreach var of varlist _all {
				if strpos("`droplist'","`var' ") != 0  {
					capture drop `var'
				}
			}
			
			if "`pivot'" != "" {
				//get the list of variables to be reshaped 
				local reshapeVarList = ""
				local reshapeLabelList = ""
				local idVarList = ""
				
				tostring *, replace // double check all variables are recorded in string format
				foreach var of varlist _all {
					replace `var' = "." if `var' == "n.a."
					
					if regexm("`var'","[0-9]+[a-zA-Z]?$") {
						local name = regexr("`var'","[0-9]+[a-zA-Z]?$","")   //if variable name contains numbers, delete numbers
						if strpos("`reshapeVarList'"," `name' ") == 0  {
							local label_`name' : variable label `var'
							local reshapeVarList "`reshapeVarList' `name' "
						}
					}
					else {
						if regexm("`var'","id[0-9]+_$") == 0 {
							local idVarList "`idVarList' `var'"
						}
					}
					
				}
			
				noi di "ID Vars: `idVarList'"
				noi di "Reshape Vars: `reshapeVarList'"
				reshape long `reshapeVarList', i(`idVarList') j(time) `reshape_opt'
				compress 
				
				// Recorver Labels 
				foreach var of local reshapeVarList {
					label var `var' "`label_`var''"
				}
			}
			
		foreach var of varlist _all {
			local refinedname = subinstr("`var'","_","",.)
			rename `var' `refinedname'
		}		
		
		local file_name = subinstr("`f'",".`extension'",".dta",.)
		if "`integrate'" == "" {
			destring *, replace 				
		}		
		save "`resultdir'//`file_name'", replace
		
		if "`integrate'" != "" {
			append using `building'
			save `building', replace
		}
		}
	}
	
	if "`integrate'" != "" {
		qui destring *, replace 				
		qui save "`resultdir'//clean.dta", replace 
	}
	
	qui cd ..

end










