*capture program drop appendgz
*! version 0.3.0 25sep2019
program define appendgz
	version 11
  
    // check for 7-Zip
	capture macro list gziputil_path_7z
	if _rc != 0 {
		check7z
		if !r(sevenz_available) {
			display as error "7-Zip was not found in within PATH and PeaZip is not installed in the standard directory!"
			display as error "Please check if either is installed and add the respective path to the PATH environment variable if necessary."
			display as error "See {help check7z} for details."
			exit
		}
	}
	
	syntax [anything(everything)] [, GENerate(name) keep(name) Nolabel Nonotes force]
	
	gettoken using filenames : anything
	
	if (`"`using'"' != "using") {
		display as error "using required"
		exit 100
	}
	
	local filecounter = 0
	local tempfiles   = ""
	
	foreach file of local filenames {
	
		// without file extension --> add dta.gz
		if (!regexm("`file'", "\.[a-zA-z]+$")) {
			local dta_gz_file = "`file'.dta.gz"
		}
		// with allowed (dta.gz) file extension
		else if (regexm("`file'", "\.dta.gz$")) {
			local dta_gz_file = "`file'"
		} 
		// with file extension other than dta.gz --> error
		else {
			display as error "the provided file is not a gzipped Stata (.dta.gz) file: `file'"
			exit 603
		}
		
		capture confirm file "`dta_gz_file'"
		if (_rc != 0) {
			display as error "file `dta_gz_file' not found"
			exit 601
		}
		
		local filecounter = `filecounter' + 1
		tempfile temp`filecounter'
		
		if c(os) == "Windows" {
			local orig_shell = "${S_SHELL}"
			global S_SHELL "powershell.exe -WindowStyle Hidden"
			display "'`temp`filecounter''"
			shell ${gziputil_path_7z} e '`dta_gz_file'' -o'`temp`filecounter'''
			global S_SHELL "`orig_shell'"
		}
		else {
			shell ${gziputil_path_7z} e '`dta_gz_file'' -o'`temp`filecounter'''
		}
		
		local bare_name = ustrregexra("`dta_gz_file'", "(^.+\\|\.gz$)", "")
		local tempfiles = `"`tempfiles'"' + " " + `""`temp`filecounter''\\`bare_name'""'
	}
	
	append using `tempfiles', generate(`generate') keep(`keep') `nolabel' ///
		`nonotes' `force'
	
	// clean up
	foreach tempfile of local tempfiles {
		rm "`tempfile'"
	}
	
	local some_temp : word 1 of `tempfiles'
	quietly display ustrregexm("`some_temp'",  "^.+\\")
	local temp_dir : display ustrregexs(0)
	rmdir "`temp_dir'"
end
