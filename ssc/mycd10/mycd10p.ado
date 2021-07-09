*! version 1.0.0  19may2014
/*
mycd10p is an update of the Stata icd9p command
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Version 1.0.0 May  19, 2014
*/

program define mycd10p
	version 9
	gettoken cmd 0 : 0, parse(" ,")
	local l = length("`cmd'")
	if "`cmd'"=="check" { 
		Check `0'
	}
	else if "`cmd'"=="clean" { 
		Clean `0'
	}
	else if "`cmd'" == substr("generate",1,max(3,`l')) {
		Gen `0'
	}
	else if "`cmd'" == substr("lookup",1,max(1,`l')) { 
		Lookup `0'
	}
	else if "`cmd'" == substr("search",1,max(3,`l')) {
		Search `0'
	}
	else if "`cmd'" == substr("tabulate",1,max(3,`l')) { 
		Tabulate `0'
	}
	else if `"`cmd'"' == "table" { 
		Table `0'
	}
	else if `"`cmd'"' == substr("query",1,max(1,`l')) {
		Query `0'
	}
	else 	di in red "invalid mycd10p subcommand"
end

* ---
* mycd10p check
program define Check, rclass
	syntax varname [, ANY List SYStem(string) Generate(string) ]
	local typ : type `varlist'
	if substr("`typ'",1,3)!="str" {
		di in red "`varlist' does not contain ICD-10 procedure codes;" /*
		*/ _n "ICD-10 procedure codes must be stored as a string"
		exit 459
	}
	if "`generate'"!="" {
		confirm new var `generate'
	}

	if "`system'"=="" {
		tempvar c
	}
	else	local c "`system'"

	quietly { 
		local typ : type `varlist'
		quietly gen `typ' `c' = upper(trim(`varlist'))
		compress `c'

		tempvar prob l

				/* 0.  code may contain "", missing */
		gen byte `prob' = cond(`c'=="", 0, .)


				/* 1. Contains periods 		*/
		replace `prob'=1 if strpos(`c',".") & `prob'==.		

				/* 2.  code too short			*/
				/* 3.  code too long			*/
		gen byte `l' = length(`c')
		replace `prob'=2 if `l'<3 & `prob'==.
		replace `prob'=3 if `l'>7 & `prob'==.
		drop `l'

				/* 4-10.  each char must be 0-9, A-H, J-N, P-Z 	*/
		forvalues pos=1/7 {
          gen str1 `l' = substr(`c',`pos',1)
		  
		  replace `prob'=`pos'+3 if !inrange(`l',"0","9") & !inrange(`l',"A","H") & !inrange(`l',"J","N") & !inrange(`l',"P","Z") & `prob'==.

		  drop `l' 

		}
				/* clean up prob			*/
		replace `prob' = 0 if `prob'==.
	}

				/* Early exit if system() option	*/
	if "`system'"!="" {
		capture assert `prob'==0
		if _rc==0 {
			exit
		}
		drop `c'
		di in red "`varlist' contains invalid ICD-10 procedure codes"
		exit 459
	}

				/* 11.  invalid code			*/
	qui count if `c'==""
	local miss = r(N)
	preserve
	if `miss' != _N & "`any'"=="" { 
		quietly {
			keep `varlist' `prob' `c'
			Merge `c'
			replace `prob' = 11 if _merge!=3 & `prob'==0 & `c'!=""
		}
	}
		

	qui count if `prob'
	local bad = r(N)
	ret scalar esum = r(N)
	if `bad'==0 {
		if `miss'==_N { 
			di in gr "(`varlist' contains all missing values)"
		}
		else if `miss'==0 { 
			di in gr "(`varlist' contains valid ICD-10 procedure codes; no missing values)"
		}
		else {
			local s = cond(`miss'==1, "", "s")
			di in gr "(`varlist' contains valid ICD-10 procedure codes;`miss' missing value`s')"
		}
		ret scalar e1 = 0
		ret scalar e2 = 0
		ret scalar e3 = 0
		ret scalar e4 = 0
		ret scalar e5 = 0
		ret scalar e6 = 0
		ret scalar e7 = 0
		ret scalar e8 = 0
		ret scalar e9 = 0
		ret scalar e10 = 0
		ret scalar e11 = . /* sic */
	}
	else {

		di /* not in red, no extra line if output suppressed */
		di in red "`varlist' contains invalid codes:"
		di /* not in red, no extra line if output suppressed */

		qui count if `prob'==1
		di in gr "    1.  Invalid use of period" _col(50) in ye %11.0gc r(N)
		ret scalar e1 = r(N)

		qui count if `prob'==2
		di in gr "    2.  Code too short" _col(50) in ye %11.0gc r(N)
		ret scalar e2 = r(N)

		qui count if `prob'==3
		di in gr "    3.  Code too long" _col(50) in ye %11.0gc r(N)
		ret scalar e3 = r(N)

        qui count if `prob'==4
        di in gr "    4.  Invalid 1st char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)

		qui count if `prob'==5
		di in gr "    5.  Invalid 2nd char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)
		
		qui count if `prob'==6
		di in gr "    6.  Invalid 3rd char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)
		
		qui count if `prob'==7
		di in gr "    7.  Invalid 4th char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)
		
		qui count if `prob'==8
		di in gr "    8.  Invalid 5th char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)
		
		qui count if `prob'==9
		di in gr "    9.  Invalid 6th char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)
		
		qui count if `prob'==10
		di in gr "   10.  Invalid 7th char (not 0-9, A-H, J-N, P-Z)" _col(50) in ye %11.0gc r(N)
		ret scalar e4 = r(N)

		ret scalar e9 = 11/* sic */

		if "`any'"=="" {
			qui count if `prob'==11
			di in gr "   11.  Code not defined" _col(50) in ye %11.0gc r(N)
			ret scalar e11 = r(N)
		}
		else	ret scalar e11 = .

		di in smcl in gr _col(50) "{hline 11}"
		di in gr _col(9) "Total" _col(50) in ye %11.0gc `bad'

		local s = cond(`bad'>1, "s", "")
		if "`list'" != "" { 
			quietly { 
				gen str27 __prob = "" 
				replace __prob = /*
					*/ "Invalid use of period" /* 
					*/ if `prob'==1
				replace __prob = "Code too short"   /*
					*/ if `prob'==2
				replace __prob = "Code too long"    /*
					*/ if `prob'==3
				replace __prob = "Invalid 1st char" /*
					*/ if `prob'==4
				replace __prob = "Invalid 2nd char" /*
					*/ if `prob'==5
				replace __prob = "Invalid 3rd char" /*
					*/ if `prob'==6
				replace __prob = "Invalid 4th char" /*
					*/ if `prob'==7
				replace __prob = "Invalid 5th char" /*
					*/ if `prob'==8
				replace __prob = "Invalid 6th char" /*
					*/ if `prob'==9
				replace __prob = "Invalid 7th char" /*
					*/ if `prob'==10
				replace __prob = "Code not defined" /*
					*/ if `prob'==11
			}
			di _n in gr "Listing of invalid codes"
			format __prob %-27s
			list `varlist' __prob if `prob'!=0 & `prob'!=.
		}
	}
	if "`generate'" != "" {
		quietly {
			keep `prob'
			rename `prob' `generate' 
			tempfile one 
			save `"`one'"'
			restore, preserve
			tempvar x 
			merge using `"`one'"', _merge(`x') nonotes
			assert `x'==3
			restore, not
		}
	}
end

program define Merge 
	args c
	tempvar n 
	quietly { 
		gen long `n' = _n
		rename `c' __code10
	}
	FindFile
	local fn `"`r(fn)'"'
	quietly {
		sort __code10
		merge __code10 using `"`fn'"', nokeep keep(__code10) nonotes
		sort `n'
		rename __code10 `c'
	}
end
		

* ---
* mycd10p clean 

program define Clean 
	syntax varname [, Pad]

	tempvar c l
	Check `varlist', system(`c')
	quietly { 
    	local len 7
		if "`pad'"!="" {
			replace `c' = substr(`c' + "       ",1,`len')
			replace `c' = trim(`c') if trim(`c')==""
		}
		gen byte `l' = length(`c')
		summ `l', meanonly 
		local len = max(9,cond(length("`varlist'")>r(max), length("`varlist'"), r(max)) + 1)
		count if `varlist' != `c'
		local ch = r(N)
		local s = cond(`ch'==1, "", "s")
		replace `varlist' = `c'
		compress `varlist'
		format `varlist' %-`len's
	}
	di in gr "(`ch' change`s' made)"
end

* ---

* mycd10p generate
program define Gen
	gettoken newvar 0 : 0, parse(" =")
	gettoken eqsign 0 : 0, parse(" =") 
	if `"`eqsign'"' != "=" { 
		error 198 
	}
	syntax varname [, Main Description Range(string) Long End ]
	confirm new var `newvar'

	local nopt = ("`main'"!="") + ("`description'"!="") + (`"`range'"'!="")

	if `nopt'!=1 { 
		di in red /*
	*/ "must specify one of options -main-, -description-, or -range()-"
		exit 198
	}

	if "`description'" == "" { 
		if "`long'"!="" { 
			di in red "option -long- not allowed"
			exit 198
		}
		if "`end'"!="" { 
			di in red "option -end- not allowed"
			exit 198
		}
	}


	tempvar new c
	Check `varlist', system(`c')
	if "`main'"!="" {
		GenMain `new' `c' `varlist'
	}
	else if "`description'" != "" {
		GenDesc `new' `c' `varlist' "`long'" "`end'"
	}
	else	GenRange `new' `c' `varlist' `"`range'"'

	rename `new' `newvar'
end

program define GenMain
	args new c userv

	quietly {
		gen str3 `new' = substr(`c',1,3)
		label var `new' "main ICD10/proc. from `userv'"
	}
end
	
	
program define GenDesc
	args new c userv long end

	if "`end'" != "" {
		local long "long"
	}

	FindFile
	local fn `"`r(fn)'"'

	tempname merge
	quietly {
		sort `c'
		rename `c' __code10
		merge __code10 using `"`fn'"', nokeep _merge(`merge') nonotes
		rename __code10 `c'
		rename __desc10 `new'
		label var `new' "label for `userv'"
		count if `merge'!=3 & `c'!=""
		local unlab = r(N)
		drop `merge'

		if "`long'" != "" {
			mycd10p clean `c', dots pad
			if "`end'"=="" {
				replace `new' = `c' + " " + `new'
			}
			else {
				replace `new'= `new'+" "+`c'
				local f : format `new'
				if substr(`"`f'"',2,1)=="-" {
					local f = "%" + substr(`"`f'"',3,.)
					format `new' `f'
				}
			}
			replace `new' = "" if trim(`new')==""
		}
	}
	if `unlab' { 
		local s = cond(`unlab'==1, "", "s")
		di in gr "(`unlab'" /*
		*/ " nonmissing values invalid and so could not be labeled)"
	}
end

program define GenRange
	args new c userv range

	P_ilist `"`range'"' ","
	local list `"`s(list)'"'
	local rest = trim(`"`s(rest)'"')
	if `"`rest'"' != "" { 
		error 198 
	}

	X_ilist `new' `c' `"`list'"'
end

* ---
* mycd10p lookup
program define Lookup
	P_ilist `"`0'"' ","
	local list `"`s(list)'"'
	local rest = trim(`"`s(rest)'"')
	if `"`rest'"' != "" { 
		error 198 
	}

	FindFile
	local fn `"`r(fn)'"'
	tempvar use 

	preserve 
	quietly { 
		use `"`fn'"', clear 
		X_ilist `use' __code10 `"`list'"'
		keep if `use'
	}

	if _N == 0 {
		di in gr "(no matches found)"
		exit
	}
	local es = cond(_N==1, "", "es")
	qui mycd10p clean __code10
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __code10[`i'] _col(14) in gr __desc10[`i']
		local i = `i' + 1
	}
end

* ---
* mycd10p search

program define Search
	local i 1
	gettoken s1 0 : 0, parse(" ,")
	while `"`s`i''"' != "" & `"`s`i''"' != "," {
		local i = `i' + 1
		gettoken s`i' 0 : 0, parse(" ,")
	}
	local n = `i' - 1
	if `n'==0 {
		error 198
	}

	local 0 `", `0'"'
	syntax [, OR ]

	FindFile
	local fn `"`r(fn)'"'

	tempvar use
	preserve 
	quietly { 
		use `"`fn'"', clear 
		gen byte `use' = 0 
		local i 1
		while `i' <= `n' { 
			replace `use' = `use' + 1 /*
			*/ if index(lower(__desc), lower(`"`s`i''"'))
			local i = `i' + 1
		}
	}
	if "`or'" == "" { 
		qui replace `use' = 0 if `use' != `n' 
	}
	qui keep if `use'
	if _N == 0 {
		di in gr "(no matches found)"
		exit
	}
	local es = cond(_N==1, "", "es")
	qui mycd10p clean __code10
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __code10[`i'] _col(14) in gr __desc10[`i']
		local i = `i' + 1
	}

end


* ---
* mycd10p tabulate

program define Tabulate
	syntax varlist(min=1 max=2) [fw aw iw] [if] [in] [, /*
		*/ Generate(string) SUBPOP(string) * ]
	if `"`subpop'"' != "" { 
		di in red "option subpop() not allowed with mycd10p tabulate"
		exit 198
	}
	if `"`generate'"' != "" {
		di in red "option generate() not allowed with mycd10p tabulate"
		exit 198
	}

	tokenize `varlist'
	tempvar c desc
	Check `1', system(`c')
	preserve 
	quietly {
		if `"`if'"'!="" | "`in'"!="" {
			keep `if' `in'
		}
		if "`weight'" != "" {
			tempname wgtv
			gen double wgtv = `exp'
			compress wgtv
			local w "[`weight'=`wgtv']"
		}
		local lbl : var label `1'
		if `"`lbl'"' == "" {
			local lbl "`1'"
		}
		keep `2' `wgtv' `c'
		mycd10p genp `desc' = `c', desc long end
		label var `desc' `"`lbl'"'
	}
	tabulate `desc' `2' `w', `options'
end

* ---
* mycd10p table

program define Table
	syntax varlist(min=1 max=3) [fw pw aw iw] [if] [in] [, /*
		*/ Contents(string) BY(varlist) * ] 

	tokenize `varlist'
	tempvar c desc
	Check `1', system(`c')

	if "`contents'" != "" {
		ConList `contents'
		local list `s(list)'
		local contopt contents(`contents')
	}
	if "`by'"!="" {
		local byopt by(`byopt')
	}

	preserve 
	quietly {
		if `"`if'"'!="" | "`in'"!="" {
			keep `if' `in'
		}
		if "`weight'" != "" {
			tempname wgtv
			gen double wgtv = `exp'
			compress wgtv
			local w "[`weight'=`wgtv']"
		}
		local lbl : var label `1'
		if `"`lbl'"' == "" {
			local lbl "`1'"
		}
		keep `2' `wgtv' `c' `list' `by'
		mycd10p gen `desc' = `c', desc long end
		label var `desc' `"`lbl'"'
	}
	table `desc' `2' `3' `w', `contopt' `byopt' `options'
end

program define ConList, sclass
	sret clear
	while "`1'" != "" { 
		if "`1'" != "freq" { 
			mac shift 
			sret local list `list' `1'
		}
		mac shift
	}
end

* ---
* utility to parse and execute an icd10rangelist (ilist)

program define P_ilist, sclass
	args str term
	sret clear 

	gettoken tok : str, parse(" *-/`term'")
	while `"`tok'"'!="" & `"`tok'"' != `"`term'"' {
		gettoken tok str : str, parse(" *-/`term'")
		IsEl `"`tok'"'
		local tok `"`s(tok)'"'
		gettoken nxttok : str, parse(" *-/`term'")
		if `"`nxttok'"' == "*" { 
			gettoken nxttok str : str, parse(" *-/`term'")
			local list `"`list' `tok'*"'
		}
		else if `"`nxttok'"'=="-" | `"`nxttok'"'=="/" { 
			gettoken nxttok str : str, parse(" *-/`term'")
			gettoken nxttok str : str, parse(" *-/`term'")
			IsEl `"`nxttok'"'
			local list `"`list' `tok'-`s(tok)'"'
		}
		else	local list `"`list' `tok'"'
		gettoken tok : str, parse(" *-/`term'")
	}
	sret local list `"`list'"'
	sret local rest `"`str'"'
end

program define IsEl, sclass
	args c

	local c = upper(trim(`"`c'"'))
	if `"`c'"' == "" { 
		di in red "<nothing> invalid ICD-10 procedure code"
		exit 198
	}
	if strpos(`"`c'"', ".") { 
		Invalid `"`c'"' "invalid use of period"
	}
	if length(`"`c'"') < 3 {
		Invalid `"`c'"' "code too short"
	}
	if length(`"`c'"') > 7 {
		Invalid `"`c'"' "code too long"
	}
    forvalues pos=1/7 {
    	local l = substr(`"`c'"', `pos', 1)
		if !inrange("`l'","0","9") & !inrange("`l'","A","H") & !inrange("`l'","J","N") & !inrange("`l'","P","Z") {
		    Invalid `"`c'"' "All characters must be 0-9, A-H, J-N, or P-Z"
	    }
	}

	sret local tok `"`c'"'
end

program define Invalid 
	args code msg 
	di in red `""`code'" invalid:  `msg'"'
	exit 198
end

program define X_ilist
	args newvar vn list
	quietly { 
		gen byte `newvar' = 0 
		tokenize `"`list'"'
		while "`1'" != "" { 
			if index("`1'", "-") { 
				local l = index("`1'", "-")
				local lb = substr("`1'",1,`l'-1)
				local ub = substr("`1'",`l'+1,.)
				replace `newvar' = 1 /*
				*/ if `vn'>="`lb'" & `vn'<="`ub'"
			}
			else if index("`1'", "*") { 
				local sub = substr("`1'",1,length("`1'")-1)
				local l = length("`sub'")
				replace `newvar' = 1 /*
				*/ if substr(`vn',1,`l')=="`sub'"
			}
			else 	replace `newvar' = 1 if `vn' == "`1'"
			mac shift 
		}
	}
end

	
program define FindFile
	//capture noi quietly 
	mycd10_ff mycd10_cop.dta, ado
	if _rc==0 {
		exit
	}
	local rc = _rc 
	di
	di in gr "mycd10p needs a dataset that records the valid ICD-10 codes."
	di in gr "That dataset is stored with the mycd10p program."
	di in gr `"Type "help mycd10p" and see the installation instructions."'
	exit `rc'
end

program define Query
	syntax
	FindFile
	local fn `"`r(fn)'"'
	preserve 
	quietly use `"`fn'"', clear
	notes
end
	

exit
