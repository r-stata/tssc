*! version 1.1  13jan2015
/*
mycd10 is an update of the Stata icd9 command
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Version 1.0.0 May 19, 2014
  * Original version
Version 1.1 January 13, 2015
  * Allows use of myicd10 and myicd10p as aliases
  * Removed some debugging steps
  * Add desciptions of chapters and block groups to generate and loookup subcommands (which requires extra prepares as well)
  * Reorganized help file
*/

program define mycd10
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
        gettoken subcmd 0 : 0
		local ll = length("`subcmd'")
		if "`subcmd'" == substr("codes",1,max(2,`ll')) {
    	    Lookup `0'
		}
		else if "`subcmd'" == substr("blocks",1,max(1,`ll')) {
		    Lookup_blocks `0'
		}
		else if "`subcmd'" == substr("chapters",1,max(2,`ll')) {
		    // Since chapters are just integers, use Stata numlist option syntax
		    Lookup_chapters , chapters(`0')
		}
		else {
    	    Lookup `subcmd'
		}
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
	else if `"`cmd'"' == substr("prepare",1,max(1,`l')) {
	    gettoken subcmd 0 : 0
		local ll = length("`subcmd'")
		if "`subcmd'" == "using" {
    	    Prepare using `0'
		}
		else if "`subcmd'" == substr("codes",1,max(2,`ll')) {
    	    Prepare `0'
		}
		else if "`subcmd'" == substr("blocks",1,max(1,`ll')) {
		    Prepare_blocks `0'
		}
		else if "`subcmd'" == substr("chapters",1,max(2,`ll')) {
		    Prepare_chapters `0'
		}

	}
	else 	di in red "invalid mycd10 subcommand"
end

* ---
* mycd10 prepare
program define Prepare
syntax using

preserve

qui insheet `using', delimiter(";") clear

// In order to maintain compatibility back to Stata 9 can't use group rename
//rename (v1-v14) (Level NodeType  Terminal Chapter Block CodeNoDagger CodeNoAsterisk CodeNoDot Title SpecialMortality1 SpecialMortality2 SpecialMortality3 SpecialMortality4 SpecialMorbidity)
local v=1
foreach var of newlist Level NodeType  Terminal Chapter Block CodeNoDagger CodeNoAsterisk CodeNoDot Title SpecialMortality1 SpecialMortality2 SpecialMortality3 SpecialMortality4 SpecialMorbidity {
  rename v`v' `var'
  local ++v
}

label var Level "Level in the hierarchy of the classification" 
label var NodeType "Place in the classification tree" 
label var Terminal "Type of terminal node" 
label var Chapter "Chapter number" 
label var Block "First three character code of a block" 
label var CodeNoDagger "Code without possible dagger" 
label var CodeNoAsterisk "Code without possible asterisk" 
label var CodeNoDot "Code without dot" 
label var Title "Title" 
label var SpecialMortality1 "Reference to special tabulation list for mortality 1" 
label var SpecialMortality2 "Reference to special tabulation list for mortality 2" 
label var SpecialMortality3 "Reference to special tabulation list for mortality 3" 
label var SpecialMortality4 "Reference to special tabulation list for mortality 4" 
label var SpecialMorbidity  "Reference to special tabulation list for morbidity" 

local adodir : sysdir PLUS
local rawfile="`adodir'"+"m/mycd10_raw"

save "`rawfile'", replace

qui replace Title=Title+"*" if Level==3

keep Chapter Block CodeNoDot Title
rename CodeNoDot __code10
rename Title __desc10
rename Chapter __chapter10
rename Block __block10

sort __code10

note: The mycd10 prepare command was based on data from ICD-10 2nd edition, downloaded from WHO in May, 2014. 
note: If you have problems with mycd10 attributable to changes in the file format from WHO, please contact the author of mycd10.

local codfile="`adodir'"+"m/mycd10_cod"
save "`codfile'", replace

restore

end

* mycd10 prepare blocks
* New with mycd10 (not in icd9): Define block groups
program define Prepare_blocks
syntax using

preserve

qui insheet `using', delimiter(";") clear

// Find correct variable names
local v=1
foreach var of newlist Block_Start Block_End Chapter Title {
  rename v`v' `var'
  local ++v
}

label var Block_Start "Starting block of block group"
label var Block_End "Ending block of block group"
label var Chapter "Chapter number" 
label var Title "Title" 

local adodir : sysdir PLUS
local rawfile="`adodir'"+"m/mycd10_blocks_raw"

save "`rawfile'", replace

keep Block_Start Block_End Title
rename Block_Start __block10
rename Block_End __lastblock10
rename Title __blockdesc10

sort __block10

note: The mycd10 prepare command was based on data from ICD-10 2nd edition, downloaded from WHO in May, 2014. 
note: If you have problems with mycd10 attributable to changes in the file format from WHO, please contact the author of mycd10.

local codfile="`adodir'"+"m/mycd10_blk"
save "`codfile'", replace

restore

end

* mycd10 prepare chapters
* New with mycd10 (not in icd9): Define chapter headings
program define Prepare_chapters
syntax using

preserve

qui insheet `using', delimiter(";") clear

local v=1
foreach var of newlist Chapter Title {
  rename v`v' `var'
  local ++v
}

label var Chapter "Chapter number" 
label var Title "Title" 

local adodir : sysdir PLUS
local rawfile="`adodir'"+"m/mycd10_chapters_raw"

save "`rawfile'", replace

rename Chapter __chapter10
rename Title __chapterdesc10

sort __chapter10

note: The mycd10 prepare command was based on data from ICD-10 2nd edition, downloaded from WHO in May, 2014. 
note: If you have problems with mycd10 attributable to changes in the file format from WHO, please contact the author of mycd10.

local codfile="`adodir'"+"m/mycd10_chp"
save "`codfile'", replace

restore

end


* ---
* mycd9 check
program define Check, rclass
	syntax varname [, ANY List SYStem(string) Generate(string) ]
	local typ : type `varlist'
	if substr("`typ'",1,3)!="str" {
		di in red "`varlist' does not contain ICD-10 codes; " /*
		*/ "ICD-10 codes must be stored as a string"
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


				/* 1.  invalid placement of period 	*/
				/* 2.  too many periods 		*/
		capture assert index(`c', ".") == 0
		if _rc { 
			gen byte `l' = index(`c', ".")
			replace `c' = (trim( /*
			*/ substr(`c',1,`l'-1) + substr(`c',`l'+1,.) /* 
			*/ )) if `l'
			compress `c'
			replace `prob' = 1 if `l'>0 & `l' < 4
			replace `prob' = 2 if index(`c', ".")
			drop `l'
		}

				/* 3.  code too short			*/
				/* 4.  code too long			*/
		gen byte `l' = length(`c')
		replace `prob'=3 if `l'<3 & `prob'==.
		replace `prob'=4 if `l'>5 & `prob'==.
		drop `l'

				/* 5.  1st char must be A-Z	*/
		gen str1 `l' = substr(`c',1,1)
		replace `prob'=5 if (`l'<"A" | `l'>"Z")  & `prob'==.

				/* 6.  2nd char must be 0-9	*/
		replace `l' = substr(`c',2,1)
		replace `prob' = 6 if (`l'<"0" | `l'>"9") & `prob'==.
		
				/* 7.  3rd char must be 0-9	*/
		replace `l' = substr(`c',3,1)
		replace `prob' = 7 if (`l'<"0" | `l'>"9") & `prob'==.
		
				/* 8.  4th char must be 0-9 or "" */
		replace `l' = substr(`c',4,1)
		replace `prob' = 8 if (`l'<"0" | `l'>"9") & `l'!="" & `prob'==.

				/* 9.  5th char must be 0-9 or "" */
				/*
		replace `l' = substr(`c',5,1)
		replace `prob' = 9 if (`l'<"0" | `l'>"9") & `l'!="" & `prob'==.
		drop `l' 
*/
				/* 3.  code too short			*/
				/*     (if 1st char E, length is 4-5)	*/
				/*
		gen byte `l' = length(`c')
		replace `prob' = 3 if substr(`c',1,1)=="E" & `l'<4 & `prob'==.
*/

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
		di in red "`varlist' contains invalid ICD-10 codes"
		exit 459
	}

				/* 9.  invalid code			*/
	qui count if `c'==""
	local miss = r(N)
	preserve
	if `miss' != _N & "`any'"=="" { 
		quietly {
			keep `varlist' `prob' `c'
			Merge `c'
			replace `prob' = 9 if _merge!=3 & `prob'==0 & `c'!=""
		}
	}
		

	qui count if `prob'
	local bad = r(N)
	return scalar esum = r(N)
	if `bad'==0 {
		if `miss'==_N { 
			di in gr "(`varlist' contains all missing values)"
		}
		else if `miss'==0 { 
			di in gr "(`varlist' contains valid ICD-10 codes; " /*
			*/ "no missing values)"
		}
		else {
			local s = cond(`miss'==1, "", "s")
			di in gr "(`varlist' contains valid ICD-10 codes; " /*
			*/ "`miss' missing value`s')"
		}
		ret scalar e1 = 0 
		ret scalar e2 = 0 
		ret scalar e3 = 0 
		ret scalar e4 = 0 
		ret scalar e5 = 0 
		ret scalar e6 = 0 
		ret scalar e7 = 0 
		ret scalar e8 = 0 
		//ret scalar e9 = 0 
		ret scalar e9 = .  /* sic */
	}
	else {

		di /* not in red, no extra line if output suppressed */
		di in red "`varlist' contains invalid codes:"
		di /* not in red, no extra line if output suppressed */

		qui count if `prob'==1
		di in gr "    1.  Invalid placement of period" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e1 = r(N)

		qui count if `prob'==2
		di in gr "    2.  Too many periods" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e2 = r(N)

		qui count if `prob'==3
		di in gr "    3.  Code too short" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e3 = r(N)

		qui count if `prob'==4
		di in gr "    4.  Code too long" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e4 = r(N)

		qui count if `prob'==5
		di in gr "    5.  Invalid 1st char (not A-Z)" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e5 = r(N)

		qui count if `prob'==6
		di in gr "    6.  Invalid 2nd char (not 0-9)" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e6 = r(N)

		qui count if `prob'==7
		di in gr "    7.  Invalid 3rd char (not 0-9)" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e7 = r(N)

		qui count if `prob'==8
		di in gr "    8.  Invalid 4th char (not 0-9)" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e8 = r(N)
/*
		qui count if `prob'==9
		di in gr "    9.  Invalid 5th char (not 0-9)" /*
			*/ _col(49) in ye %11.0gc r(N)
		ret scalar e9 = r(N)
*/
		if "`any'"=="" {
			qui count if `prob'==9
			di in gr "    9.  Code not defined" /*
				*/ _col(49) in ye %11.0gc r(N)
			ret scalar e9 = r(N)
		}
		else	ret scalar e9 = .

		di in smcl in gr _col(49) "{hline 11}"
		di in gr _col(9) "Total" /*
			*/ _col(49) in ye %11.0gc `bad'

		local s = cond(`bad'>1, "s", "")
		if "`list'" != "" { 
			quietly { 
				gen str27 __prob = "" 
				replace __prob = /*
					*/ "Invalid placement of period" /* 
					*/ if `prob'==1
				replace __prob = "Too many periods" /*
					*/ if `prob'==2
				replace __prob = "Code too short"   /*
					*/ if `prob'==3
				replace __prob = "Code too long"    /*
					*/ if `prob'==4
				replace __prob = "Invalid 1st char" /*
					*/ if `prob'==5
				replace __prob = "Invalid 2nd char" /*
					*/ if `prob'==6
				replace __prob = "Invalid 3rd char" /*
					*/ if `prob'==7
				replace __prob = "Invalid 4th char" /*
					*/ if `prob'==8
				//replace __prob = "Invalid 5th char"  if `prob'==9
				replace __prob = "Code not defined" /*
					*/ if `prob'==9
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
* mycd10 clean 

program define Clean 
	syntax varname [, Dots Pad]

	tempvar c l
	Check `varlist', system(`c')
	quietly { 
		if "`dots'" != "" { 
			replace `c' = substr(`c',1,3) + "." + substr(`c',4,.) if `c'!=""
			gen byte `l' = length(`c')
			replace `c' = substr(`c',1,`l'-1) if substr(`c',`l',1)=="."
			drop `l'
			local len 6
		}
		else	local len 5
		if "`pad'"!="" {
			replace `c' = " " + `c' 
			replace `c' = substr(`c' + "       ",1,`len')
			replace `c' = trim(`c') if trim(`c')==""
		}
		gen byte `l' = length(`c')
		summ `l', meanonly 
		local len = max(7,cond(length("`varlist'")>r(max), length("`varlist'"), r(max)) + 1)
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

* mycd10 generate
* New with mycd10 (not in icd9): added support for chapters and blocks
program define Gen
	gettoken newvar 0 : 0, parse(" =")
	gettoken eqsign 0 : 0, parse(" =") 
	if `"`eqsign'"' != "=" { 
		error 198 
	}
	syntax varname [, Main Description Chapter Block Range(string) Long End ]
	confirm new var `newvar'

	local nopt = ("`main'"!="") + ("`description'"!="") + (`"`range'"'!="") + (`"`chapter'"'!="") + (`"`block'"'!="")

	if `nopt'!=1 { 
		di in red /*
	*/ "must specify one of options -main-, -description-, -chapter-, -block-, or -range()-"
		exit 198
	}

	if "`description'" == "" & "`chapter'" == "" & "`block'" == "" { 
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
    else if "`chapter'" != "" {
	    GenChap `new' `c' `varlist' "`long'" "`end'"
	}
	else if "`block'" != "" {
		GenBlock `new' `c' `varlist' "`long'" "`end'"
	}
	else	GenRange `new' `c' `varlist' `"`range'"'

	rename `new' `newvar'
end

program define GenMain
	args new c userv

	quietly {
		gen str3 `new' = substr(`c',1,3) if `c'!="" 
		compress `new'
		label var `new' "main ICD10 from `userv'"
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
		drop `merge' __chapter10 __block10

		if "`long'" != "" {
			mycd10 clean `c', dots
			replace `c' = " " + `c' 
			replace `c' = substr(`c'+"       ",1,7)
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
		di in gr "(`unlab' nonmissing values invalid and so could not be labeled)"
	}
end

program define GenChap
    version 10
	args new c userv long end

	FindFile
	local fn `"`r(fn)'"'

	FindChapterFile
	local chpfn `"`r(fn)'"'

	tempname merge
	quietly {
		sort `c'
		rename `c' __code10
		
		// First merge with code database to get chapter number
		merge m:1 __code10 using `"`fn'"',  gen(`merge') nonotes
		drop if `merge'==2
		drop `merge'
		drop __desc10 __block10 
		rename __code10 `c'
		
		// Then merge with chapter database to get chapter title
		merge m:1 __chapter10 using `"`chpfn'"', gen(`merge') nonotes
		drop if `merge'==2
		
		if "`long'" != "" {
		  if "`end'"=="" {
    		  replace __chapterdesc10=string(__chapter10)+") "+__chapterdesc10 if !mi(__chapter10)
		  }
		  else {
      		  replace __chapterdesc10=__chapterdesc10+" ("+string(__chapter10)+")" if !mi(__chapter10)
		  }
		}

		drop __chapter10
		rename __chapterdesc10 `new'
		label var `new' "Chapter for `userv'"   
		count if `merge'!=3 & `c'!=""
		local unlab = r(N)
		drop `merge'
	}
	if `unlab' { 
		local s = cond(`unlab'==1, "", "s")
		di in gr "(`unlab' nonmissing values invalid and so could not be labeled)"
	}
end

program define GenBlock
    version 10
	args new c userv long end

	FindFile
	local fn `"`r(fn)'"'

	FindBlockFile
	local blkfn `"`r(fn)'"'

	tempname merge
	quietly {
		sort `c'
		rename `c' __code10
		
		// First merge with code database to get code group
		merge m:1 __code10 using `"`fn'"', gen(`merge') nonotes
		drop if `merge'==2
		drop `merge' 
		drop __desc10 __chapter10
		rename __code10 `c'
	
		// Then merge with block database to get block group title
		merge m:1 __block10 using `"`blkfn'"', gen(`merge') nonotes
		drop if `merge'==2
		
		if "`long'" != "" {
		  if "`end'"=="" {
            	replace __blockdesc10=__block10+"-"+__lastblock10+") "+__blockdesc10 if !mi(__block10)
		  }
		  else {
	    		replace __blockdesc10=__blockdesc10+" ("+__block10+"-"+__lastblock10+")" if !mi(__block10)
		  }
		}

		drop __block10 __lastblock10
		rename __blockdesc10 `new'
		label var `new' "Block group for `userv'"
		count if `merge'!=3 & `c'!=""
		local unlab = r(N)
		drop `merge'
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
* mycd10 lookup
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
	qui mycd10 clean __code10, dots
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __code10[`i'] _col(14) in gr __desc10[`i']
		local i = `i' + 1
	}
end

* ---
* New with mycd10 (not in icd9): mycd10 lookup chapters
program define Lookup_chapters
    syntax , chapters(numlist)
	
	FindChapterFile
	local fn `"`r(fn)'"'
	tempvar use 

	preserve 
	quietly { 
		use `"`fn'"', clear 
		tempvar use
		gen byte `use' = 0 
		foreach i of numlist `chapters' {
		  replace `use' = 1 if __chapter10 == `i'
		}
		keep if `use'
	}

	if _N == 0 {
		di in gr "(no matches found)"
		exit
	}
	local es = cond(_N==1, "", "es")
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __chapter10[`i'] _col(14) in gr __chapterdesc10[`i']
		local i = `i' + 1
	}
end

* ---
* New with mycd10 (not in icd9): mycd10 lookup blocks
program define Lookup_blocks
	P_ilist `"`0'"' ","
	local list `"`s(list)'"'
	local rest = trim(`"`s(rest)'"')
	if `"`rest'"' != "" { 
		error 198 
	}

	FindBlockFile
	local fn `"`r(fn)'"'
	tempvar use 

	preserve 
	quietly { 
		use `"`fn'"', clear 
		X_blist `use' __block10 __lastblock10 `"`list'"'
		keep if `use'
	}

	if _N == 0 {
		di in gr "(no matches found)"
		exit
	}
	local es = cond(_N==1, "", "es")
	//qui mycd10 clean __code10, dots
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __block10[`i'] "-" __lastblock10[`i'] _col(17) in gr __blockdesc10[`i']
		local i = `i' + 1
	}
end

* ---
* mycd10 search

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
			replace `use' = `use' + 1  if index(lower(__desc), lower(`"`s`i''"'))
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
	qui mycd10 clean __code10, dots
	di _n in gr _N " match`es' found:"

	local i 1 
	while `i' <= _N { 
		di in ye _col(5) __code10[`i'] _col(14) in gr __desc10[`i']
		local i = `i' + 1
	}

end


* ---
* mycd10 tabulate

program define Tabulate
	syntax varlist(min=1 max=2) [fw aw iw] [if] [in] [, /*
		*/ Generate(string) SUBPOP(string) * ]
	if `"`subpop'"' != "" { 
		di in red "option subpop() not allowed with mycd10 tabulate"
		exit 198
	}
	if `"`generate'"' != "" {
		di in red "option generate() not allowed with mycd10 tabulate"
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
		mycd10 gen `desc' = `c', desc long end
		label var `desc' `"`lbl'"'
	}
	tabulate `desc' `2' `w', `options'
end

* ---
* mycd10 table

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
		mycd10 gen `desc' = `c', desc long end
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
* utility to parse and execute an icd10 rangelist (ilist)

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
		di in red "<nothing> invalid ICD-10 code"
		exit 198
	}
	if index(`"`c'"', ".") { 
		local l = index(`"`c'"', ".")
		local c = (trim( /*
			*/ substr(`"`c'"',1,`l'-1) + substr(`"`c'"',`l'+1,.) /*
			*/ ))
		if `l'>0 & `l'<4 {
			Invalid `"`c'"' "invalid placement of period"
		}
		if index(`"`c'"', ".") {
			Invalid `"`c'"' "too many periods"
		}
	}
	if length(`"`c'"') < 1 {
		Invalid `"`c'"' "code too short"
	}
	if length(`"`c'"') > 4 {
		Invalid `"`c'"' "code too long"
	}

	local l = substr(`"`c'"', 1, 1)
	if (`"`l'"'<"A" | `"`l'"'>"Z") { 
		Invalid `"`c'"' "1st character must be A-Z"
	}

	local l = substr(`"`c'"', 2, 1)
	if (`"`l'"'<"0" | `"`l'"'>"9") & `"`l'"'!="" { 
		Invalid `"`c'"' "2nd character must be 0-9"
	}

	local l = substr(`"`c'"', 3, 1)
	if (`"`l'"'<"0" | `"`l'"'>"9") & `"`l'"'!="" { 
		Invalid `"`c'"' "3rd character must be 0-9"
	}

	local l = substr(`"`c'"', 4, 1)
	if (`"`l'"'<"0" | `"`l'"'>"9") & `"`l'"'!="" { 
		Invalid `"`c'"' "4rd character must be 0-9"
	}
/*
	local l = substr(`"`c'"', 5, 1)
	if (`"`l'"'<"0" | `"`l'"'>"9") & `"`l'"'!="" { 
		Invalid `"`c'"' "5th character must be 0-9"
	}
*/
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

// Variation of X_ilist to deal with block groups
// Single blocks must be matched to a block group (range) in the block database
// Blocks with * wildcard must be matched to a similar substring range in the block database
// Block ranges (e.g., A00/A09) must only overlap a block group in the block database
program define X_blist
	args newvar vn1 vn2 list
	quietly { 
		gen byte `newvar' = 0 
		tokenize `"`list'"'
		while "`1'" != "" { 
			if index("`1'", "-") { 
				local l = index("`1'", "-")
				local lb = substr("`1'",1,`l'-1)
				local ub = substr("`1'",`l'+1,.)
				replace `newvar' = 1  if (`vn1'>="`lb'" & `vn1'<="`ub'") | (`vn2'>="`lb'" & `vn2'<="`ub'")
			}
			else if index("`1'", "*") { 
				local sub = substr("`1'",1,length("`1'")-1)
				local l = length("`sub'")
				replace `newvar' = 1  if "`sub'">=substr(`vn1',1,`l') & "`sub'"<=substr(`vn2',1,`l')
			}
			else 	replace `newvar' = 1 if "`1'">=`vn1' & "`1'"<=`vn2'
			mac shift 
		}
	}
end


	
	
program define FindFile
	capture noi quietly mycd10_ff mycd10_cod.dta, ado
	if _rc==0 {
		exit
	}
	local rc = _rc 
	di
	di in gr "mycd10 needs a dataset that records the valid ICD-10 codes."
	di in gr "The procedure code dataset is stored with the mycd10 program."
	di in gr "The diagnosis code dataset needs to be downloaded from WHO first."
	di in gr `"Type "help mycd10" and see the installation instructions, "'
	di in gr "particulary the mycd10 prepare command."
	exit `rc'
end


program define FindChapterFile
	capture noi quietly mycd10_ff mycd10_chp.dta, ado
	if _rc==0 {
		exit
	}
	local rc = _rc 
	di
	di in gr "mycd10 needs a dataset that records the valid ICD-10 chapters."
	di in gr "The procedure code dataset is stored with the mycd10 program."
	di in gr "The diagnosis code dataset needs to be downloaded from WHO first."
	di in gr `"Type "help mycd10" and see the installation instructions, "'
	di in gr "particulary the mycd10 prepare command."
	exit `rc'
end

program define FindBlockFile
	capture noi quietly mycd10_ff mycd10_blk.dta, ado
	if _rc==0 {
		exit
	}
	local rc = _rc 
	di
	di in gr "mycd10 needs a dataset that records the valid ICD-10 block groups."
	di in gr "The procedure code dataset is stored with the mycd10 program."
	di in gr "The diagnosis code dataset needs to be downloaded from WHO first."
	di in gr `"Type "help mycd10" and see the installation instructions, "'
	di in gr "particulary the mycd10 prepare command."
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
