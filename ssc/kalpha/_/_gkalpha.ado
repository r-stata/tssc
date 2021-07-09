*! version 1.3.0 29dec2017 daniel klein
program _gkalpha
	version 11.2
	
	gettoken type 0 : 0
	gettoken varn 0 : 0
	gettoken eqsn 0 : 0
	
	syntax varlist [ if ] [ in ] 	///
	[ , 							///
		Scale(passthru) 			///
		Transpose 					///
		XPOSE 						///
		BY(varlist) 				///
	]
	
	if (c(stata_version) < 12.1) {
		mata : st_local("EGEN_SVarname", st_global("EGEN_SVarname"))
		local varlist : list varlist - EGEN_SVarname
	}
	
	marksample touse , novarlist
	
	quietly {
		tempvar level
		bys `touse' `by' : generate long `level' = 1 if ((_n == 1) & `touse')
		replace `level' = sum(`level')
		summarize `level' , meanonly
		local max = r(max)
		generate `type' `varn' = .
		forvalues j = 1/`max' {
			kalpha `varlist' if (`level' == `j') , `scale' `transpose' `xpose'
			replace `varn' = r(kalpha) if (`level' == `j')
		}
	}
end
exit

1.3.0	29dec2017	new option abbreviations
					code polish
1.2.0	11jul2014	no bootstrap options allowed
1.1.0	07jun2014	allow string variables
1.0.0	05jun2014	initial version
