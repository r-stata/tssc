*! version 2.0.3 PR 03apr2007.
program define byvar, rclass sortpreserve
version 8

tokenize `"`0'"', parse(":")
if "`2'"!=":" {
	di as err "syntax error - maybe missing colon, or unmatched quotes somewhere"
	exit 198
}
local 0 `1'
mac shift 2	// skip the colon
local command `*'

syntax varlist [if] [in], [ E(str) R(str) B(str) SE(str) GRoup(str) GEnerate ///
 Tabulate REturn Missing Pause noLabel Unique SEParator(string) ]

if "`group'"!="" confirm new var `group'

if "`unique'"!="" & "`generate'"=="" {
	di as err "unique requires generate"
	exit 198
}

local bylist `varlist'

local s1 `e'
local L1 E
local s2 `r'
local L2 R
local s3 `b'
local L3 B
local s4 `se'
local L4 S
local tostore=`"`s1'`s2'`s3'`s4'"'!=""
if !`tostore' & "`generate'`return'`tabulate'"!="" {
	di as err "nothing to generate, return or tabulate"
	exit 198
}
if `tostore' & "`generate'`return'`tabulate'"=="" {
	di as txt "(tabulate assumed)"
	local tabulat tabulate
}

local tab="`tabulate'"!="" & `tostore'

* Extract multiple commands
local ncmd 0
if "`separator'"!="" local sep=substr("`separator'",1,1)
else local sep @
tokenize `"`command'"', parse("`sep'")
while `"`1'"'!="" {
	if `"`1'"'!="@" {
		local ++ncmd
		local command`ncmd' `1'
	}
	mac shift
}
forvalues i=1/`ncmd' {
	tokenize `"`command`i''"', parse(",")
	local cmd1 `1'
	mac shift
	local cmd2`i' `*'
	local pif=index(`"`cmd1'"', " if ")
	if `pif'>0 {
		local cmd11`i'=substr(`"`cmd1'"',1,`pif')
		local cmd12`i'=substr(`"`cmd1'"',`pif'+4,.)
		local ifalso`i' " & "
	}
	else local cmd11`i' `cmd1'
}

/* Number and count the groups	*/
quietly {
/*
	Default is to exclude missing groups in bylist from analysis.
	Their corresponding group codes are set to missing and sorted to
	end of data.
*/
	tempvar grp first
	marksample touse, strok
	if "`missing'"=="" {
		markout `touse' `bylist', strok
		replace `touse'=. if `touse'==0
	}
	sort `touse' `bylist'
	by `touse' `bylist': gen byte `first'=1 if _n==1 & `touse'==1
	gen int `grp'=sum(`first') if `touse'==1
	drop `touse'
	sum `grp'
	local GRP=r(max)
	if `GRP'==0 noisily error 2000

	local itemlen 14
/*
	Extract group-defining values of bylist variables
	and store in macros
*/
	local nby : word count `bylist'
	if `tab' {
		noi di
		local dashes
	}
	tempvar index
	gen long `index'=.
	forvalues i=1/`GRP' {
		replace `index'=sum(_n*(`grp'==`i' & `first'==1))
		local j=`index'[_N]
		forvalues k=1/`nby' {
			local byvar`k' : word `k' of `bylist'
			local vallab: value label `byvar`k''
			local byval=`byvar`k''[`j']
			if "`vallab'"!="" & "`label'"!="nolabel" {
				local by`i'`k': label `vallab' `byval'
			}
			else local by`i'`k' `byval'
			if `i'==1 & `tab' {
				local dashes "`dashes'---------"
				noi di as txt %-9s "`byvar`k''" _c
			}
		}
	}
	drop `index'
}
if `tab' {
	di as txt " |" _c
	local dashes "`dashes'-+"
}
/*
	Parse and record items for storage
*/
forvalues j=1/4 {
	local i 1
	if `"`s`j''"'!="" {
		tokenize `"`s`j''"'
		* take care of embedded quotes
		local k 1
		while `"`1'"'!="" {
			local sk`k' `sk`k'' `1'
			* Count number of quotes in `1' - should be 2. Do not actually change `1' (discard `z').
			local z: subinstr local 1 `"""' "Q", all count(local nquote)	// "
			if `nquote'>0 & `nquote'!=2 {
				di as err "unmatched quotes in " `"`s`j''"'
				exit 198
			}
			local ++k
			mac shift
		}
		local l 1
		while `l'<`k' {
			* 1=item, [ 2="=", 3=description of item ], 4=null
			tokenize `"`sk`l''"', parse("=")
			local sk`l'
			if `"`4'"'!="" {
				di as err "invalid " `"`sk`l''"'
				exit 198
			}
			local st`j'`i' `1'
			if `"`3'"'=="" {
				if      `j'==1 local lab e(`1')
				else if `j'==2 local lab r(`1')
				else if `j'==3 local lab _b[`1']
				else if `j'==4 local lab _se[`1']
			}
			else {
				local lab=substr(`"`3'"',1,`itemlen'-1)
			}
			if "`generate'"!="" {
				mk_name `L`j'' `1' 6
				local `L`j''_`i' `s(name)'
				qui gen double ``L`j''_`i''=.
				lab var ``L`j''_`i'' `"`lab' by `bylist'"'
			}
			if `tab' {
				local dashes "`dashes'--------------"
				local skip=`itemlen'-length(`"`lab'"')
				di as txt _skip(`skip') `"`lab'"' _c
			}
			local ++i
			local ++l
		}
	}		
	local n`j'=`i'-1
}
if `tab' di _n as txt "`dashes'"

/* Perform calcs		*/
if `tab' local show quietly
else local show noisily
tempname thing
forvalues i=1/`GRP' { // i indexes members of groups implied by bylist
	if !`tab' {
		di as txt _n "-> " _c
		forvalues k=1/`nby' {
			di as txt "`byvar`k''==`by`i'`k'' " _c
		}
		di
	}
	forvalues j=1/`ncmd' {
*di `"capture `show' `cmd11`j'' if `grp'==`i' `ifalso`j'' `cmd12`j'' `cmd2`j''"'
		capture `show' `cmd11`j'' if `grp'==`i' `ifalso`j'' `cmd12`j'' `cmd2`j''
		local rc=_rc
	}

	if "`pause'"!="" more

	if `tab' {
		forvalues k=1/`nby' {
			di as res %-9s substr("`by`i'`k''",1,8) _c
		}
		di as txt " |" _c
	}
	forvalues k=1/4 { 	// k indexes the 4 types of thing to be stored
		if `n`k''>0 {
			forvalues l=1/`n`k'' { /* l indexes # of thing */
				
				if `rc'==0 {
					if `k'==1 	scalar `thing'=e(`st`k'`l'')
					else if `k'==2 	scalar `thing'=r(`st`k'`l'')
					else if `k'==3 	scalar `thing'=_b[`st`k'`l'']
					else if `k'==4 	scalar `thing'=_se[`st`k'`l'']
				}
				else scalar `thing'=.
				if "`generate'"!="" {
					if "`unique'"=="" qui replace ``L`k''_`l''=`thing' if `grp'==`i'
					else qui replace ``L`k''_`l''=`thing' if `grp'==`i' & `first'==1
				}
				if "`return'"!="" {
		  			* gp refers to subgroup (level) of the byvar(s)
		   			local r `L`k''`l'gp`i'
					return scalar `r'=`thing'
				}
				if `tab' di _skip(4) as res %10.0g `thing' _c
			}
		}
	}
	if `tab' di
}
quietly if "`generate'"!="" {
	forvalues k=1/4 {			/* k indexes type of thing stored */
		if `n`k''>0 {
			forvalues i=1/`n`k'' { /* i indexes item in list of things */
				compress ``L`k''_`i''
				// if "`firstonly'"!="" bysort `grp': replace ``L`k''_`i''=. if _n>1
				return local `L`k''_`i' ``L`k''_`i''
			}
		}
	}
}
if "`group'"!="" {
	cap drop `group'
	rename `grp' `group'
	lab var `group' "group by `bylist'"
}
return scalar byvar_g=`GRP'
end

program define mk_name, sclass
/* meaning make_unique_name <letter> <suggested_name> <#_chars> */
	version 8
	args letter base numchar
	sret clear
	local name = substr("`letter'`base'",1,`numchar'+1)
	xi_mkun2 `name'_
end

program define xi_mkun2, sclass
version 8
/* meaning make_unique_name <suggested_name> */
	args name

	local totry "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local lentot=length("`totry'")
	local l 0
	local len = length("`name'")
	capture list `name'* in 1		/* try name out */
	while _rc==0 {
		if `l'==`lentot' {
			di as err "too many terms---limit is " `lentot'+1
			exit 499
		}
		local l=`l'+1
		local name = substr("`name'",1,`len'-1)+substr("`totry'",`l',1)
		capture list `name'* in 1
	}
	sret local name "`name'"
end

