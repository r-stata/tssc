*! mkdat.ado   Version 1.6   05/Mar/2004
	
* Update-Log
* ----------
	
* 1.6
	* File-Type pequiv included
	
* 1.5.
* Bug for Filetype "kind". Corrected 
	
	
program define mkdat
version 5.0
	
*	   		                          				PARSING
#delimit ;
	local options "Waves(string) Netto(string) Files(string) Keep(string) clear
	  uc hhgr" ;
#delimit cr
	local using "req"
	local varlist "req new"
	parse "`*'"
	parse "`options'", parse(" ")
	
*                                                                 ERROR CHECK
	if "`files'"=="" {
		di in red "files(#) not optional"
		exit
	}
	if "`waves'"=="" {
		di in red "waves(#,[#],..[#]) not optional"
		exit
	}

*								CHECK VARLIST
	parse "`varlist'", parse(" ")
	if "`uc'"~="" {
		while "`1'"~="" {
			local var =lower("`1'")
			local varl1 "`varl1' `var'"
			mac shift
		}
		local varlist "`varl1'"
	}
	local nvars : word count `varlist'
	local nwaves : word count `waves'
	local rows = `nvars'/`nwaves'                /* Variablenzahl pro File */
*                                                                   TEMPVAR
	parse "`waves'", parse(" ")
	while "`1'"~="" {
		local ufiles "`ufiles' u`1'"
		mac shift
	}
	tempfile master `ufiles'
	tempvar valid

	if "`clear'" ~= "" {clear}

*                                                              MASTER DATA
	parse "`waves'", parse(" ")                     	  /* laden */
	local pfadvar "hhnr persnr `keep' psample"
	while "`1'"~="" {
		if "`1'"=="g" & "`2'" == "gost"  {
			macro shift
		}
		if "`1'"=="h" & "`2'" == "host"  {
			macro shift
		}
		if "`1'" == "gost" {
			local 1 g
		}
		if "`1'" == "host" {
			local 1 h
		}
		local pfadvar "`pfadvar' `1'hhnr `1'netto"
      local nettvar "`nettvar' _`1'netto"
      macro shift
	}
	di in green "preparing master data"
	quietly use `pfadvar' `using'/ppfad

	parse "`waves'", parse(" ")
	while "`1'"~="" {
		if "`1'"=="g" & "`2'" == "gost"  {
			macro shift
		}
		if "`1'"=="h" & "`2'" == "host"  {
			macro shift
		}
		if "`1'" == "gost" {
			local 1 g
		}
		if "`1'" == "host" {
			local 1 h
		}
      gen _`1'netto=`1'netto
      macro shift
	}

	if "`hhgr'"~="" {                                    /* Haushaltsgroesse */
		parse "`waves'", parse(" ")
		while "`1'"~="" {
			sort `1'hhnr persnr
			quietly by `1'hhnr: gen `1'hhgr=_n if `1'hhnr>0
			quietly by `1'hhnr: replace `1'hhgr=`1'hhgr[_N] if `1'hhnr>0
			macro shift
		}
	}
	if "`netto'"=="" {                                             /* Design */
		local netto "1"
		di in blue "Note: balanced panel design assumed"
	}
	parse "`netto'", parse(",")
	while "`1'"~="" {
		quietly mvdecode `nettvar', mv(`1')
		macro shift
		macro shift
	}

	quietly egen `valid' = rmiss(`nettvar')
	parse "`waves'", parse(" ")
	local nvalid `nwaves'
	while "`1'"~="" {
		if "`1'"=="g" & "`2'" == "gost"  {
			local nvalid=`nvalid'-1
		}
		if "`1'"=="h" & "`2'" == "host"  {
			local nvalid=`nvalid'-1
		}
		macro shift
	}
*sum `valid'
	quietly keep if `valid'==`nvalid'
	drop `nettvar'           /* Check */

	parse "`waves'", parse(" ")
	if "`1'"=="gost" & "`2'" == ""  {
		keep if psample==3
	}
	if "`1'"=="gost" & "`2'" == "host"  {
		keep if psample==3
	}
	if "`1'"=="host" & "`2'" == ""  {
		keep if psample==3
	}
	quietly save `master'

*                                                                 USING DATA
	di in gr "preparing using data"
	local i 1
	while `i' <= `nwaves' {
		if "`files'"=="p" | "`files'"=="pgen" | "`files'"=="pbrutto" /*
		*/ | "`files'"=="kind" | "`files'"=="pausl" | "`files'"=="pkal" /*
		*/ | "`files'"=="peigen" | "`files'"=="pequiv" {
			local vars  "hhnr hhnrakt persnr"
		}
		else if "`files'"=="h" | "`files'"=="hgen" | "`files'"=="hbrutto" {
			local vars  "hhnr hhnrakt"
		}
		else {
			di in red "filetype not valid"
        	exit
		}
		parse "`varlist'", parse(" ")
		local j `i'
		local ntotal=`nvars'*`nwaves'
		while `j'<=`ntotal' {                  /* Variablenlisten pro File */
			if substr("``j''",1,1) ~= "_" {
				local vars "`vars' ``j''"
			}
			local j=`j'+`nwaves'
		}
		parse "`waves'", parse(" ")
		if "``i''"=="gost" {
			di in gr "looking up " in ye "g`files'ost.dta" in gr " for" _newline in /*
			*/ ye "`vars'"
			quietly use `vars' `using'/g`files'ost
		}
		else if "``i''"=="host" {
			di in gr "looking up " in ye "h`files'ost.dta" in gr " for" _newline in /*
			*/ ye "`vars'"
			quietly use `vars' `using'/h`files'ost
		}
		else {
			di in gr "looking up " in ye "``i''`files'.dta" in gr " for" _newline in /*
			*/ ye "`vars'"
			quietly use `vars' `using'/``i''`files'
		}
      if "`files'"=="p" | "`files'"=="pgen" | "`files'"=="pbrutto"  /*
      */ | "`files'"=="kind" | "`files'"=="pausl" | "`files'"=="pkal" /*
      */ | "`files'"=="peigen" | "`files'"=="pequiv" {
			sort hhnr hhnrakt persnr
      }
      else if "`files'"=="h" | "`files'"=="hgen" | "`files'"=="hbrutto" {
			sort hhnr hhnrakt
      }
      quietly save `u``i''', replace
		local i=`i'+1
	}

*								        MERGE
	di in green "merge data sets"
	quietly use `master', clear
	quietly gen hhnrakt=.
	if "`files'"=="h" | "`files'"=="hgen" | "`files'"=="hbrutto" {
		while "`1'"~="" {
			if "`1'"=="gost" {
				quietly replace hhnrakt=ghhnr
			}
			else if "`1'"=="host" {
				quietly replace hhnrakt=hhhnr
			}
			else {
				quietly replace hhnrakt=`1'hhnr
			}
			sort hhnr hhnrakt persnr
			quietly merge hhnr hhnrakt using `u`1'', nokeep
	     	drop _merge
			macro shift
		}
	}
	else {
		while "`1'"~="" {
			if "`1'"=="gost" {
				quietly replace hhnrakt=ghhnr
			}
			else if "`1'"=="host" {
				quietly replace hhnrakt=hhhnr
			}
			else {
				quietly replace hhnrakt=`1'hhnr
			}
			sort hhnr hhnrakt persnr
			quietly merge hhnr hhnrakt persnr using `u`1'', nokeep
	     	drop _merge
			macro shift
		}
		drop hhnrakt
	}
end
	exit



	Author: Ulrich Kohler
	LS fr Methoden der empirischen Sozialforschung
	und angewandte Soziologie
	Universit„t Mannheim
	D-68131 Mannheim

	Tel (0621) 292 2929
	Fax (0621) 292 5194
	email ukohler@mlsowi.sowi.uni-mannheim.de
