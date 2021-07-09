*! 2.0 Oct 10th Jan Brogger
capture program drop svmatf
program define svmatf
	version 6.0
	syntax , mat(string) fil(string) [verb row(string)]
	preserve


	if "`row'"=="" {local row "row"}

	if "`verb'"~="" {di "Variable  names: `varn'"}
	
	if "`varn'" ~= "" {matname `mat' `varn' , col(.) expl }
	if "`varn'" == "" {local varn: rownames `mat' }


	drop _all
	qui svmat2 `mat' , names(col) rn(`row')
	tempfile tmpf
	qui save "`tmpf'"

	capture confirm new file "`fil'"
	if _rc ~= 0 {
		if "`verb'"~="" { di "File `fil'  exists.Appending"}
		use "`fil'"
		append using "`tmpf'"
	} /* _rc */

	if "`verb'"~="" { di "Saving file `fil'  "}
	qui save "`fil'" , replace

	restore
end

