*! holrein.ado   Version 1.3   06/Jan/2003
	
* Update-Log
* ----------
	
* 1.4 Filtype "pequiv" included
* 1.3. Bug for Filetype "kind". Corrected 
	
program define holrein
version 5.0
* 		     						      PARSING
	local options "Waves(string) Files(string) uc"
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
*                                                               CHECK VARLIST
	drop `varlist'
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

	quietly save `master'
*                                                                 USING DATA
	local i 1
	while `i' <= `nwaves' {
		if "`files'"=="p" | "`files'"=="pgen" | "`files'"=="pbrutto"  /*
		*/ | "`files'"=="kind" | "`files'"=="pausl" | "`files'"=="pkal" /*
		*/ | "`files'"=="peigen" |  "`files'"=="pequiv" {
			local vars "hhnr hhnrakt persnr"
		}
		else if "`files'"=="h" | "`files'"=="hgen" | "`files'"=="hbrutto" {
			local vars "hhnr hhnrakt"
		}
		else {
			di in red "filetype not valid"
        	exit
		}
		parse "`varlist'", parse(" ")
		local j `i'
		while `j'<=`nvars' {                  /* Variablenlisten pro File */
			if substr("``j''",1,1) ~= "_" {
				local vars "`vars' ``j''"
			}
			local j=`j'+`nwaves'
		}
		parse "`waves'", parse(" ")
		if "``i''"=="gost" {
			capture use `vars' `using'/g`files'ost
		}
		else if "``i''"=="host" {
			capture use `vars' `using'/h`files'ost
		}
		else {
			capture use `vars' `using'/``i''`files'
		}
		if _rc~=0 {
			use `master', clear
			di in red "varlist invalid"
			exit _rc
		}
		if "`files'"=="p" | "`files'"=="pgen" | "`files'"=="pbrutto"  /*
		*/ | "`files'"=="pkind" | "`files'"=="pausl" | "`files'"=="pkal" /*
		*/ | "`files'"=="peigen" | "`files'"=="pequiv" {
			sort hhnr hhnrakt persnr
		}
		else if "`files'"=="h" | "`files'"=="hgen" | "`files'"=="hbrutto" {
			sort hhnr hhnrakt
		}
		quietly save `u``i''', replace
		local i=`i'+1
	}
*                                                                       MERGE
	use `master', clear
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
			merge hhnr hhnrakt using `u`1'', nokeep
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
			merge hhnr hhnrakt persnr using `u`1'', nokeep
			drop _merge
			macro shift
		}
	}
	drop hhnrakt
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
