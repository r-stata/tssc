*! version 3.0.1 Januar 31, 2012 @ 17:14:23 UK
* This is -holrein- reloaded

// 1.0.0 Initial version
// 1.0.1 File type kind does not work -> fixed.
// 1.0.2 Blanks positions in varlist returned an error -> fixed.
// 2.0 Updated to Stata 11
// 3.0 Updated to GSOEP after wave "z" 
// 3.0.1. Bug-fix

program soepadd
version 11
	
	// Option clear
	// ------------

	syntax anything ,  ///
	  Ftyp(string) Waves(numlist >= 1984 integer sort) ///  
	  [ Ost(string) onlyost uc fast ]
	
	// Additional syntax checks
	// ------------------------
	
	if strpos("`ost'","g") & !strpos("`waves'","1990") {
		di as error "ost(g) requires waves() to include 1990"
		exit 198
	}
	if strpos("`ost'","h") & !strpos("`waves'","1991") {
		di as error "ost(h) requires waves() to include 1991"
		exit 198
	}
	
	if "`onlyost'" != "" & "`ost'" == "" {
		di as error "onlyost() requires ost()"
		exit 198
	}

	// Catch dirname from soepuse
	// --------------------------

	local using: char _dta[soepusedir]

	
	// Set up alhanumerical wavelists
	// -----------------------------
	
	foreach year of local waves {
		local token: word `=`year'-1983' of `c(alpha)'
		if `year' == 1990 & strpos("`ost'","g") local token "g gost"
		if `year' == 1991 & strpos("`ost'","h") local token "h host"
		if `year' >= 2010 local token "b`:word `=max(1,`=`year'-2009')' of `c(alpha)''"
		local wavelist "`wavelist' `token'"
	}
	if "`onlyost'" != "" {
		local wavelist: subinstr local wavelist "g" "", word
		local wavelist: subinstr local wavelist "h" "", word
	}
	local shortwlist: subinstr local wavelist "gost" "", word
	local shortwlist: subinstr local shortwlist "host" "", word

	// Set identifier
	// --------------
	
	if substr("`ftyp'",1,1) =="p" | "`ftyp'" == "kind" 	{
		local identif  "hhnr hhnrakt persnr"
		local match "1:1"
	}
	else if substr("`ftyp'",1,1) =="h" {
		local identif  "hhnr hhnrakt"
		local match "n:1"
	}
	else {
		di in red "filetype not valid"
        exit 198
	}
	
	// Value for interview
	// -------------------
	
	local intvalue = cond("`oldnetto'"=="",10,1) 
	
	// Check Namelist
	// -------------
	
	// Namelist can only be complete, if the number of variables is 
	// a multiple of the numbers of waves. This is only necassary
	// but not sufficent. However it is an indicator and very fast to control
	
	local nwaves: word count `wavelist'
	local nvars: word count `anything'
	if mod(`nvars',`nwaves') {
		di as error "namelist does not seem to fit wavelist"
	}
	
	// Build Filenames
	// ---------------
	
	foreach w of local wavelist {
		if "`w'" == "gost" | "`w'" == "host" {
			local token = substr("`w'",1,1)
			local filelist "`filelist' `token'`ftyp'ost"
		}
		else local filelist "`filelist' `w'`ftyp'"
	}
	
	// Option UC 
	// ---------
	
	if "`uc'"~="" {
        foreach var of local anything {
			local varl "`varl' `=lower("`var'")'"
		}
		local anything "`varl'"
	}
	
	// Option fast
	// -----------
	
	// By default we run an addtional check before starting
	if "`fast'" == "" {
		local i 1 
		foreach file of local filelist {
			tokenize `anything'  
			forv j = `i++'(`nwaves')`nvars' {        
				if "``j''" ~= "-" local vars "`vars' ``j''"
			}
			quietly describe `identif' `vars' using `"`using'/`file'"'
			macro drop _vars
		}
	}
	
	// Prepare using data
	// ------------------
	
	// Fast check if vars are available
	local i 1 
	foreach file of local filelist {
		tokenize `anything'  
		forv j = `i++'(`nwaves')`nvars' {        
			if "``j''" ~= "-" local vars "`vars' ``j''"
		}
	quietly describe `identif' `vars' using `"`using'/`file'"'
		macro drop _vars
	}
	
	preserve
	drop _all
	
	// Use vars and save files
	local i 1 
	foreach file of local filelist {
		tokenize `anything'  
		forv j = `i++'(`nwaves')`nvars' {        
			if substr("``j''",1,1) ~= "-" {
				local vars "`vars' ``j''"
			}
		}
		qui use `identif' `vars' using `"`using'/`file'"'
		sort `identif'
		tempfile `file'
		quietly save ``file''
		macro drop _vars
	}
	
	restore

	// Merge Using files
	// -----------------
	
	quietly {
		gen long hhnrakt = .
		foreach file of local filelist {
			local i = strlen("`file'")-strlen("`ftyp'")
			replace hhnrakt = `=substr("`file'",1,`i')'hhnr
			sort `identif'
			merge `match' `identif' using ``file'', keep(1 3) nogen
		}
		drop hhnrakt
	}
	
end
exit

Author: Ulrich Kohler
Tel +49 (0)30 25491 361
Fax +49 (0)30 25491 360
Email kohler@wzb.eu
