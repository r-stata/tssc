*! version 1.0.1  06jul2021  hendri.adriaens@centerdata.nl
program define runcd

	splitpath "`1'"

	local current "`c(pwd)'" 
	
	// Change the working directory to the path of the do-file
	capture cd "`r(directory)'"
	if _rc != 0 {
		display as error `"error changing directory to "`r(directory)'""'
		exit _rc
	}
	
	// We want to be able to restore the working directory at
	// the end of the program, even if an error occurs. So we
	// need to capture the error.
	capture run "`r(filename)'" `2' `3' `4' `5' `6' `7' `8' `9' `10' `11'

	// Remember the error
	local error = _rc

	// Restore the working directory
	capture cd "`current'"

	// Exit in case the do-file produced an error
	if `error' != 0 {
		exit `error'
	}

end
