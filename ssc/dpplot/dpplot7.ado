* renamed 3 June 2004 
*! 1.0.0 NJC 19 June 2002
program define dpplot7, sort
	version 7
	syntax varname [if] [in] /* 
	*/ [, Symbol(string) Connect(string) L1title(str asis) /* 
	*/ T1title(str asis) XLAbel(string) YLAbel(string) Gap(int 4) *          /* 
	*/ dist(string) param(numlist) a(real 0.5) ]

	* observations to use 
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 { error 2000 } 
	qui replace `touse' = - `touse' 
	sort `touse' `varlist' 

	* plotting positions (i - a ) / (n - 2a + 1) 
	* e.g. default a = 0.5: (i - 0.5) / n 
	*              a = 0: i / (n + 1) 
	tempvar P ft fo 
	qui gen `P' = (_n - `a') / (`r(N)' - 2 * `a' + 1) if `touse' 
	
	* TLAs allowed for distribution options 
	local l = max(3, length("`dist'"))
	
	* distribution defaults to normal (Gaussian) 
	if "`dist'" == "" { local dist normal } 
	else if "`dist'" == substr("normal", 1, `l') | /* 
	*/ "`dist'" == substr("Gaussian", 1,`l') | /* 
	*/ "`dist'" == substr("gaussian", 1, `l') { 
		local dist normal 
	}	
	else if "`dist'" == substr("exponential", 1, `l') { 
		local dist exponential 
	} 
	
	* `dist' calculates theoretical and "observed" densities
	qui `dist' `ft' `fo' `P' `varlist' `touse' `param' 

	* graph defaults 
	* t1 set by called program 
	if `"`t1title'"' == "" { local t1title "`t1'" } 
	if "`symbol'" == "" { local symbol "oi" }
	else local symbol "`symbol'i" 
	if "`connect'" == "" { local connect ".s" }
	else local connect "`connect's" 
	if `"`l1title'"' == "" { local l1title "Probability density" } 
	if "`xlabel'" == "" { local xlabel "xla" } 
	else local xlabel "xla(`xlabel')" 
	if "`ylabel'" == "" { local ylabel "yla" } 
	else local ylabel "yla(`ylabel')" 

	* graph 
	gra `fo' `ft' `varlist' if `touse', sy(`symbol') c(`connect') /* 
	*/ l1(`"`l1title'"') t1(`"`t1title'"') `xlabel' `ylabel' gap(`gap') /* 
	*/ `options' 
end

program def normal 
	args ft fo P varlist touse mean sd garbage 
	if "`garbage'" != "" { 
		di as err "too many parameters specified"
		exit 198 
	}
	su `varlist' if `touse' 
	if "`mean'" == "" { local mean = `r(mean)' } 
	if "`sd'" == "" { local sd = `r(sd)' } 
	gen `ft' = normden((`varlist' - `mean') / `sd') if `touse' 
	gen `fo' = normden(invnorm(`P')) if `touse' 
	c_local t1 : /* 
	*/ di "reference is normal, mean" %8.0g `mean' " sd" %8.0g  `sd'
end 

program def exponential
	args ft fo P varlist touse mean garbage 
	if "`garbage'" != "" { 
		di as err "too many parameters specified"
		exit 198 
	}
	su `varlist' if `touse' 
	if "`mean'" == "" { local mean = `r(mean)' } 
	gen `ft' = (1 / `mean') * exp(-(`varlist' / `mean')) if `touse' 
	gen `fo' = (1 - `P') / `mean' if `touse'
	c_local t1 : /* 
	*/ di "reference is exponential, mean" %8.0g `mean'
end 

