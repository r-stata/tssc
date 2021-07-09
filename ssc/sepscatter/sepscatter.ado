*! 1.1.0 NJC 5 December 2018 
*! 1.0.2 NJC 9 May 2014 
*! 1.0.1 NJC 8 May 2014 
*! 1.0.0 NJC 29 April 2014 
program sepscatter 
	version 9 

	capture syntax anything [if] [in] [aweight fweight pweight] ///
	, seperate(varname) [ * ] 

	if _rc == 0 { 
		noisily di _n "note: sep" as err "a" as  txt "rate() is correct spelling" 

		local 0 `anything' `if' `in' [`weight' `exp'] ///
                , separate(`seperate') `options' 
	} 

	syntax varlist(numeric min=2 max=2) [if] [in] ///
	[aweight fweight pweight] , SEParate(varname) ///
	[MYLAbel(varname) MYNUmeric(varname) MISSing addplot(str asis) *]

	capture noisily {  
	
	quietly { 
		if "`mylabel'" != "" & "`mynumeric'" != "" { 
			di as err "choose mylabel() or mynumeric()" 
			exit 198 
		} 

		tokenize `varlist' 
		args y x 

		marksample touse 
		if "`missing'" == "" markout `touse' `separate', strok  
		count if `touse' 
		if r(N) == 0 exit 2000 

		tempname stub 
		separate `y' if `touse', `missing' by(`separate') ///
		gen(`stub') veryshortlabel 
		local Y `r(varlist)' 
		local nY : word count `Y' 
	}

	local ytitle : var label `y' 
	if `"`ytitle'"' == "" local ytitle "`y'"

	if "`mylabel'`mynumeric'" != "" { 

		if "`mynumeric'" != "" { 
			if "`: value label `mynumeric''" != "" { 
				tempvar mylabel 
				gen `mylabel' = `mynumeric' 
			}
			else local mylabel `mynumeric' 
		} 
				
		local mylabel : di _dup(`nY') "`mylabel' " 
		local mypos : di _dup(`nY') "0 " 
		local mynone : di _dup(`nY') "none " 
		local mylabel ///
		ms(`mynone') mla(`mylabel') mlabpos(`mypos') legend(off)   
	} 
 
	scatter `Y' `x' if `touse' [`weight' `exp'], ///
		ytitle(`"`ytitle'"') ms(Oh plus X Th Sh Dh) `mylabel' ///
		`options' || `addplot' 
	} 

	drop `Y' 
end 
	
