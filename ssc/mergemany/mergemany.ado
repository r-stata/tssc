* mergemany 1.00                 dh:2012-07-03                  Damian C. Clarke
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

capture program drop mergemany
program define mergemany
        vers 10.0
	
	// COMMAND SYNTAX
	#delimit ;
        syntax anything(name=bases), 
	Match(string) //Required: these are the variables to match on
	[SAVing(string)
	NUMerical(numlist)
	all
	keep
	VERbose
	IMPort(string)
	INOPtion(string)
	];
	#delimit cr
	
	if length("`keep'") != 0 preserve
	clear
	
	//Replace user defined merge parameter as mm (can be 1:1, 1:m, m:m, m:1)
	local mm=`"`1'"'
	
	//Process depends upon whether user specifies numerical, all, or normal
	//error due to choosing both numerical and all
	if length(`"`numerical'"') != 0 & (length("`all'") > 0) {
		di in yellow "You cannot specify both numerical and all.  You may only choose one of these options."
	}

	//numerical()
	else if length(`"`numerical'"') != 0 {
		di in yellow "You have specified a numerical file appendix"
		local name = reverse(subinstr(reverse(`"`2'"'), ",", "",1))
		
		//First block is to import data not saved as .dta formats
		if length(`"`import'"') != 0 {
		foreach num of numlist `numerical' {
			tempfile temp_`name'`num'
			if length(`"`inoption'"') == 0 qui insheet using "`name'`num'.`import'", clear
			if length(`"`inoption'"') != 0 qui insheet using "`name'`num'.`import'", clear `inoption'
			qui save "`temp_`name'`num''"
			}
		tokenize `numerical'
		use "`temp_`name'`1''"
		local i=2
		di in green "The Result of your merge is:"
		while "`2'" != "" {
			di in yellow "Merging Base `name'`i'"
			merge `mm' `match' using "`temp_`name'`i''", generate(_merge_`name'`i')
			if length(`"`verbose'"') == 0 drop _merge*
			mac shift
			local ++i
			}
		}
		
		//Second block is to import data saved as .dta format
		else if length(`"`import'"') == 0 {
			tokenize `numerical'
			use "`name'`1'.dta"
			local i=2
			di in green "The Result of your merge is:"
			while "`2'" != "" {
				di in yellow "Merging Base `name'`i'"
				merge `mm' `match' using "`name'`i'.dta", generate(_merge_`name'`i')
				if length(`"`verbose'"') == 0 drop _merge*
				mac shift
				local ++i
				}
			}
	}
		
	//all
	else if length(`"`numerical'"') == 0 & (length("`all'") > 0) {
		if length(`"`import'"') != 0 {
		
			di in yellow "You have specified that you want to merge all .`import' files from the current folder."
			di in yellow "If a list of files does not appear below, your working directory contains no .`import' files" 
			local dir `c(pwd)'
			local list : dir `"`dir'"' files "*.`import'"
			dis `"`list'"'
			
			local i=1
			foreach file of local list {
				local file`i' "`file'"
				tempfile temp_file`i'
				if length(`"`inoption'"') == 0 qui insheet using `file', clear
				if length(`"`inoption'"') != 0 qui insheet using `file', clear `inoption'
				qui save "`temp_file`i''" 
				local ++i
				}
		//Merge bases with all files from the folder
			di in green "The Result of your merge is:"
			use "`temp_file1'"
			local --i 
			
			foreach num of numlist 2(1)`i' {	
				local savename = reverse(subinstr(reverse(`"`file`num''"'), "vsc.", "",1))
				di in yellow "Merging Base `file`num''"
				merge `mm' `match' using `"`temp_file`num''"', gen(_merge_`savename')
				if length(`"`verbose'"') == 0 drop _merge*
			}

		}
		
		else if	length(`"`import'"') == 0 {
			di in yellow "You have specified that you want to merge all files from the current folder."
			di in yellow "If a list of files does not appear below, your working directory contains no .dta files" 
			local dir `c(pwd)'
			local list : dir `"`dir'"' files "*.dta"
			dis `"`list'"'
			
			tempvar x
			gen `x'=.
			local i=1
			foreach file of local list {
				local file`i' "`file'"
				local ++i
				}
			drop `x'

			//Merge bases with all files from the folder
			di in green "The Result of your merge is:"
			use "`file1'"
			local --i
			foreach num of numlist 2(1)`i' {
				local savename = reverse(subinstr(reverse(`"`file`num''"'), "atd.", "",1))
				di in yellow "Merging Base `savename'"
				merge `mm' `match' using `"`file`num''"', gen(_merge_`savename')
				if length(`"`verbose'"') == 0 drop _merge*
			}
		}
	}
	
	
	//normal
	else if length(`"`numerical'"') == 0 & (length("`all'") == 0){
		



		if length(`"`import'"') != 0 {
			tokenize `bases'
			while "`2'" != "" {
				local a=strpos(reverse("`2'"), "/")-1 //correct for files which are specified using their directory structure
				local filename=reverse(substr(reverse("`2'"), 1, `a'))
				local a1=strpos(reverse("`2'"), "\")-1 //correct for files which are specified using their directory structure
				local filename1=reverse(substr(reverse("`2'"), 1, `a1'))
				
				if length("`filename1'") != 0 & length("`filename'") !=0 {
					if length("`filename'") < length("`filename1'") {
						tempfile temp_`filename'
						if length(`"`inoption'"') == 0 qui insheet using "`2'.`import'", clear
						if length(`"`inoption'"') != 0 qui insheet using "`2'.`import'", clear `inoption'
						qui save "`temp_`filename''"
						mac shift
					}
					
					if length("`filename'") > length("`filename1'") {
						tempfile temp_`filename1'
						if length(`"`inoption'"') == 0 qui insheet using "`2'.`import'", clear
						if length(`"`inoption'"') != 0 qui insheet using "`2'.`import'", clear `inoption'
						qui save "`temp_`filename1''"
						mac shift
					}
				}
				else if length("`filename1'") == 0 & length("`filename'") !=0 {
					tempfile temp_`filename'
					if length(`"`inoption'"') == 0 qui insheet using "`2'.`import'", clear
					if length(`"`inoption'"') != 0 qui insheet using "`2'.`import'", clear `inoption'
					qui save "`temp_`filename''"
					mac shift
				}
				else if length("`filename1'") != 0 & length("`filename'") ==0 {
					tempfile temp_`filename1'
					if length(`"`inoption'"') == 0 qui insheet using "`2'.`import'", clear
					if length(`"`inoption'"') != 0 qui insheet using "`2'.`import'", clear `inoption'
					qui save "`temp_`filename1''"
					mac shift
				}
				else if length("`filename1'") == 0 & length("`filename'") ==0 {
					tempfile temp_`2'
					if length(`"`inoption'"') == 0 qui insheet using "`2'.`import'", clear
					if length(`"`inoption'"') != 0 qui insheet using "`2'.`import'", clear `inoption'
					qui save "`temp_`2''"
					mac shift
				}

				
				}
			
			tokenize `bases'
			di in green "The Result of your merge is:"
			use "`temp_`2''"
			while "`3'" != "" {
				di in yellow "Merging Base `3'"
				local a=strpos(reverse("`3'"), "/")-1 //correct for files which are specified using their directory structure
				local filename=reverse(substr(reverse("`3'"), 1, `a'))
				local a1=strpos(reverse("`3'"), "\")-1 //correct for files which are specified using their directory structure
				local filename1=reverse(substr(reverse("`3'"), 1, `a1'))
				
				if length("`filename1'") != 0 & length("`filename'") !=0 {
					if length("`filename'") < length("`filename1'") merge `mm' `match' using "`temp_`filename''", gen(_merge_`filename')
					if length("`filename'") > length("`filename1'") merge `mm' `match' using "`temp_`filename1''", gen(_merge_`filename1')
				}
				else if length("`filename1'") == 0 & length("`filename'") !=0 {
					merge `mm' `match' using "`temp_`filename1''", gen(_merge_`filename')
				}
				else if length("`filename1'") != 0 & length("`filename'") ==0 {
					merge `mm' `match' using "`temp_`filename1''", gen(_merge_`filename1')
				}
				else if length("`filename1'") == 0 & length("`filename'") ==0 {
					merge `mm' `match' using "`temp_`3''", gen(_merge_`3')
				}

				if length(`"`verbose'"') == 0 drop _merge*
				mac shift
				}
			}

		else if length(`"`import'"') == 0 {
			//Merge bases which the user has listed in the list anything 
			tokenize `bases'
			di in green "The Result of your merge is:"
			use "`2'.dta"
			while "`3'" != "" {
				di in yellow "Merging Base `3'"
				local a=strpos(reverse("`3'"), "/")-1 //correct for files which are specified using their directory structure
				local filename=reverse(substr(reverse("`3'"), 1, `a'))
				local a1=strpos(reverse("`3'"), "\")-1 //correct for files which are specified using their directory structure
				local filename1=reverse(substr(reverse("`3'"), 1, `a1'))
				
				if length("`filename1'") != 0 & length("`filename'") !=0 {
					if length("`filename'") < length("`filename1'") merge `mm' `match' using "`3'", gen(_merge_`filename')
					if length("`filename'") > length("`filename1'") merge `mm' `match' using "`3'", gen(_merge_`filename1')
				}
				else if length("`filename1'") == 0 & length("`filename'") !=0 {
					merge `mm' `match' using "`3'", gen(_merge_`filename')
				}
				else if length("`filename1'") != 0 & length("`filename'") ==0 {
					merge `mm' `match' using "`3'", gen(_merge_`filename1')
				}
				else if length("`filename1'") == 0 & length("`filename'") ==0 {
					merge `mm' `match' using "`3'", gen(_merge_`3')
				}

				if length(`"`verbose'"') == 0 drop _merge*
				mac shift
			}
		}
	}


	//Saves created do file as name defined by user if user specifies option
	if length(`"`verbose'"') !=0 order _merge*
	if length(`"`saving'"') != 0 save "`saving'.dta", replace
	if length("`keep'") != 0 restore

end
