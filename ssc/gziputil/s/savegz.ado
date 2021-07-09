capture program drop savegz
*! version 0.2.6 24sep2019
program define savegz
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
	
	syntax [anything] [, Nolabel replace all orphans emptyok]	
	
	local file = subinstr(`""`anything'""', `"""', "", .)
	
	// with allowed (dta.gz) file extension
	if (regexm("`file'", "\.dta.gz$")) {
		local dta_gz_file = "`file'"
	}
	// with file extension other than dta.gz
	else {
		local dta_gz_file = "`file'.dta.gz"
	}
		
	capture confirm file "`dta_gz_file'"
	if _rc == 0 {
		if ("`replace'" == "") {
			display as error `"file `dta_gz_file' already exists"'
			exit 602
		} 
		else {
			rm "`dta_gz_file'"
		}
	}
	
	tempfile temp_dta
	mkdir `temp_dta'
	local basename_temp_dta = ustrregexra("`temp_dta'", "^.+\\", "")
	local bare_name = ustrregexra("`file'", "(.*\\|\.dta\.gz$)", "")
	
	quietly save "`temp_dta'\\`bare_name'.dta", `nolabel' `all' `orphans' `emptyok'	
	
	if c(os) == "Windows" {
		local orig_shell = "${S_SHELL}"
		
		global S_SHELL "powershell.exe -WindowStyle Hidden -noninteractive"
		shell ${gziputil_path_7z} a '`dta_gz_file'' '`temp_dta'\\`bare_name'.dta'
		// | Out-File -FilePath 'C:\Users\s1504gl\Desktop\log.txt' -Force
		global S_SHELL "`orig_shell'"
	}
	else {
		shell 7z a "`dta_gz_file'" "`temp_dta'\\`bare_name'.dta"
	}
		
	
	rm "`temp_dta'\\`bare_name'.dta"
	rmdir "`temp_dta'"
end
