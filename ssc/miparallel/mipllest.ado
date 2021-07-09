* Program to run -mi estimate- in parallel
* using SSC's -parallel-
* Version 1.0
capture program drop mipllest 
program define mipllest

	capture findfile parallel.ado
	if _rc == 601 {
		di as err "-parallel- not found. Make sure you've installed it."
		di as err `"Try: {stata "view net describe parallel, from(http://fmwww.bc.edu/RePEc/bocode/p)"}"'
		exit 601
	}
	else if _rc > 0 {
		exit _rc
	}
	

	gettoken debug debug_opts : 0 , parse(" ,")
	if `"`debug'"' == "debug" {
		mipllest_debug `debug_opts'
		exit
	}

	gettoken options command : 0, parse(":")
	local dummy : subinstr local 0 ":" "" , count(local test)
	if `test' == 0 {
		di as err `"Missing ":""'
		exit 111
	}
	if substr(`"`command'"',1,1) == ":" local command : subinstr local command ":" ""
	if `"`command'"' == "" {
		di as err `"Missing {it:command}"'
		exit 111
	}
	if `"`options'"' == ":" local options 
		
	preserve
	tempvar originalsort
	qui gen `originalsort' = _n
	mi convert flong, clear
	
	local 0 `options'
	syntax [, Imputations(numlist) stub(name) keep replace PLLopts(string) ] 
	if "`stub'" == "" local stub _mipllest_
	
	if "`imputations'" != "" {
		numlist "`imputations'"
		local nlist `r(numlist)'
		local nlist : subinstr local nlist " " ", ", all
		qui keep if inlist(_mi_m, `nlist')
	}
	else qui keep if _mi_m > 0
	
	** Check if _mipllest_script.do is in existence
	local test: dir . files "_mipllest_script.do"
	if `"`test'"' != "" {
		di as err "Please delete the file _mipllest_script.do"
		di as err "You can click: " _c
		di as err "{stata rm _mipllest_script.do}"
		exit 999
	}
	
	** Check if _mipllest_*.ster files are in existence
	local test: dir . files "_mipllest_*.ster"
	if `"`test'"' != "" {
		di as err "Please delete file starting with _mipllest_"
		di as err "If you're in Windows, you can click: " _c
		di as err "{stata ! erase _mipllest_*.ster}"
		exit 999
	}
	

	** Check if `stub' estimates are in existence
	capture estimate dir `stub'* 
	if _rc != 111 {
		if "`replace'" != "replace" {
			di as err "The estimation results `stub' are still there. " 
			di as err "Either drop them: {stata est drop `stub'*}, or"
			di as err "use the -replace- option"
			exit 999
		}
		else est drop `stub'*
	}
	
	** Create script file
	local script _mipllest_script.do	// I'm avoiding the use of tempfiles. 
										// This cause -parallel- to save its files in the temp folder
										// Rather than the current folder.
	// tempfile script 
	file open script using `script', write text replace
	file write script "************* First line of `script' **************" _newline
	file write script "levelsof _mi_m" _newline
	file write script "foreach level in \`r(levels)' {" _newline
	file write script _tab "keep if _mi_m == \`level'" _newline
	file write script _tab "`command'" _newline
	file write script _tab "est save _mipllest_\`level'" _newline
	file write script _tab "use \`c(filename)', clear" _newline
	// I'm reloading the dataset every loop rather than using preserve-restore, because 
	// preserve-restore appears to cause a bug in parallel -- it interferes with the preserve in the
	// mother program, as well as other instances of Stata that are running in parallel. 
	file write script "}" _newline
	file write script "************* Last line of `script' **************" _newline
	file close script
	
	** use -parallel- to run it
	qui levelsof _mi_m 
	local levelsof_mi_m `r(levels)'

	qui sort _mi_m `originalsort'
	drop `originalsort'
		
	capture noisily break {
		parallel do `script', by(_mi_m) `pllopts' 
	}
	if _rc == 1 {
		di as err "Parallel estimation terminated by -break-"
		di as err "Access temporary files created by -parallel- and -mipllest- in current directory"
		di as err "Current directory is {res:`c(pwd)'}"
		exit 1
	}
		
	if "`keep'" != "keep" rm `script'
	
	** Store estimates
	foreach i in `levelsof_mi_m' {
		est use _mipllest_`i'
		est store `stub'`i'
		if "`keep'" != "keep" rm _mipllest_`i'.ster
	}
	
end
	

capture program drop mipllest_debug
program define mipllest_debug

	syntax [, PLL_id(string) PLL_dir(string) ]
	
	if `"`pll_id'"' == "" local pll_id `r(pll_id)'
	if `"`pll_dir'"' == "" local pll_dir `r(pll_dir)'
	
	if `"`pll_id'"' == "" {
		di as err "r(pll_id) not found. Supply your pll_id with the pll_id() option."
		exit 111
	}
	if `"`pll_dir'"' == ""  local pll_dir .
	
	forval i=1/$PLL_CLUSTERS {
		capture confirm file `"`pll_dir'/__pll`pll_id'_do`i'.log"'
		if _rc == 0 {
			view `"`pll_dir'/__pll`pll_id'_do`i'.log"'
		}
		else {
			di as err `""`pll_dir'/__pll`pll_id'_do`i'.log" not found. "' 
			di as err "To run mipllest debug, you usually need to have specified the "_cont
			di as err "-pllopts(keep)- option when you ran -mipllest-." 
			exit 111
		}
	}
end

