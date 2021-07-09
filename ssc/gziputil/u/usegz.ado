capture program drop usegz
*! version 0.2.3 24sep2019
program define usegz
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
	
	gettoken anything options : 0, parse(",")

	// CASE 1: no using in call
	if !ustrregexm(`"`anything'"', "using") {
		local dta_gz_file = `"`anything'"'
	}
	// CASE 2: using in call
	else {
		local clean_anything = ustrregexrf(`"`anything'"', "using", "@")
		gettoken var_if_in dta_gz_file : clean_anything, parse("@")
		local dta_gz_file = ustrregexrf(`"`dta_gz_file'"', "@", "")
	}

	// strip quotes before checking for / adding file extension
	local dta_gz_file = ustrregexra(`"`dta_gz_file'"', `"\""', "")
	
	// without file extension --> add dta.gz
	if (!ustrregexm("`dta_gz_file'", "\.[a-zA-z]+$")) {
		local dta_gz_file = `"`dta_gz_file'.dta.gz"'
	}
	// with allowed (dta.gz) file extension
	else if (ustrregexm("`dta_gz_file'", "\.dta.gz$")) {
		local dta_gz_file = `"`dta_gz_file'"'
	} 
	// with file extension other than dta.gz --> error
	else {
		display as error "the provided file is not a gzipped Stata (.dta.gz) file: `dta_gz_file'"
		exit 603
	}
	
	// add quotes since they are needed sometimes and never hurt
	//local dta_gz_file = `""`dta_gz_file'""'
	
	tempfile temp_dta
	
	if c(os) == "Windows" {
		local orig_shell = "${S_SHELL}"
		global S_SHELL "powershell.exe -WindowStyle Hidden"
		shell ${gziputil_path_7z} e '`dta_gz_file'' -o'`temp_dta''
		global S_SHELL "`orig_shell'"
	}
	else {
		shell 7z e `dta_gz_file'" -o"`temp_dta'
	}
	
	local bare_name = ustrregexra("`dta_gz_file'", "(^.+\\|\.gz$)", "")
	use `var_if_in' using "`temp_dta'\\`bare_name'"`options'

	capture rm "`temp_dta'\\`bare_name'.dta"
	capture rm "`temp_dta'\\`bare_name'"
	rmdir `temp_dta'
end
