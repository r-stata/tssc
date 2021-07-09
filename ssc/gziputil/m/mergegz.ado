capture program drop mergegz
*! version 0.2.3 24sep2019
program define mergegz
	version 11
	
	// check for 7-Zip
	capture macro list gziputil_path_7z
	if _rc != 0 {
		check7z
		if !r(sevenz_available) {
			display as error "7-Zip was not found in within PATH!"
			display as error "Please check if it is installed and add the respective path to the PATH environment variable."
			exit
		}
	}
	
	syntax anything(everything) [, keepusing(name) generate(name) Nogenerate ///
								 Nolabel Nonotes update replace Noreport force]
	
	local anything = subinstr(`""`anything'""', `"""', "", .)
	
	if (!ustrregexm("`anything'", "^(1|m)")) {
		display as error "mergegz only accepts the new merge syntax as of version 11; see {help merge} for new syntax"
		exit 197
	}
	if (!ustrregexm("`anything'", "using")) {
		display as error "using required"
		exit 100
	}
	
	quietly display ustrregexm("`anything'", "^(1|m):(1|m)")
	local mergetype = ustrregexs(0)
	quietly display ustrregexm("`anything'", "(?<=(1 |m )).+(?=using)")
	local mergevars = ustrregexs(0)
	quietly display ustrregexm("`anything'", "(?<=using ).+")
	local mergefile = ustrregexs(0)
	
		// without file extension --> add dta.gz
	if (!regexm("`mergefile'", "\.[a-zA-z]+$")) {
		local dta_gz_file = "`mergefile'.dta.gz"
	}
	// with allowed (dta.gz) file extension
	else if (regexm("`mergefile'", "\.dta.gz$")) {
		local dta_gz_file = "`mergefile'"
	} 
	// with file extension other than dta.gz --> error
	else {
		display as error "The provided file is not a gzipped Stata (.dta.gz) file: `mergefile'"
		exit 603
	}
		
	tempfile temp_dta
		
	if c(os) == "Windows" {
		local orig_shell = "${S_SHELL}"
		global S_SHELL "powershell.exe -WindowStyle Hidden"
		shell ${gziputil_path_7z} e '`dta_gz_file'' -o'`temp_dta''
		global S_SHELL "`orig_shell'"
	}
	else {
		shell 7z e '`dta_gz_file'' -o'`temp_dta''
	}
	
	*shell 7z e "`dta_gz_file'" -so > `temp_dta'
	local bare_name = ustrregexra("`dta_gz_file'", "(^.+\\|\.gz$)", "")
	merge `mergetype' `mergevars' using "`temp_dta'\\`bare_name'", ///
		keepusing(`keepusing') generate(`generate') `nogenerate' `nolabel' ///
		`nonotes' `update' `replace' `noreport' `force'
	
	capture rm "`temp_dta'\\`bare_name'"
	capture rm "`temp_dta'\\`bare_name'.dta"
	rmdir `temp_dta'
end
