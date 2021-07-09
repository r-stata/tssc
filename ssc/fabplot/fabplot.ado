*! 1.0.0 NJC 10 June 2018 
program fabplot
	version 9     
	gettoken cmd 0 : 0 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(str asis) ///
	[ front(str) frontopts(str asis) NEEDvars(str) ADDPLOT(str asis) * ] 
	
	gettoken byvar byopts : by, parse(,) 
	gettoken comma byopts : byopts, parse(,) 
	confirm variable `byvar' 
	
	marksample touse
	markout `touse' `byvar', strok 
	quietly count if `touse' 
	if r(N) == 0 error 2000
		
	preserve 
	
	quietly { 
		keep if `touse' 
		keep `varlist' `byvar' `needvars' 
	
		tempvar id panel group 
		gen long `id' = _n
		egen `panel' = group(`byvar'), label 
		su `panel', meanonly 
		expand `r(max)' 
		bysort `id' : gen long `group' = _n
		label val `group' `panel' 
	
		tokenize `varlist' 
		args y x 
		separate `y', by(`panel' == `group')
	}
	
	local ytitle : variable label `y' 
	if `"`ytitle'"' == "" local ytitle "`y'" 
	if "`front'" == "" local front "`cmd'" 
	sort `group' `byvar' `x'

	if inlist("`cmd'", "line", "connected") local lopts lc(gs10) c(L)  
	if inlist("`front'", "line", "connected") local flopts lc(blue) 

	twoway  `cmd' `y'0 `x', mc(gs10) ms(+)                    ///
	by(`group', note("`note'") legend(off) `byopts')          ///
	subtitle(, fcolor(ltblue*0.5))                            ///
	ytitle(`"`ytitle'"') yla(, ang(h)) `lopts' `options'      ///
	|| `front' `y'1 `x', mc(blue) ms(oh) `flopts' `frontopts' ///
	|| `addplot' 
	
end 
