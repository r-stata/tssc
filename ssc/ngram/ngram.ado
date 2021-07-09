// Main purpose is to call ngram_core
program define ngram   
*! 1.0.0   April 2017 
	version 13
	syntax varlist (min=1 max=1) [if] [in],  [ * ]
	
	//  obs excluded by [if] [in]
	marksample touse , novarlist
	qui count if `touse' 
	if r(N) == 0 { 
		error 2000 
	} 
	
	ngram_core  `varlist' if `touse', `options'

	
end
