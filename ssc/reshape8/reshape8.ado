*! version 4.2.0  December 19, 2003 @ 15:49:39
program define reshape8
	/* 4.2.0 - swiched to modern syntax, more straightforward style, version 8 */
	/* 4.1.5 - allows variable labels to be carried back and forth when going long to wide to long*/
	version 8

	global ReS_Clear "ReS_ver ReS_i ReS_j ReS_jv ReS_jv2 ReS_Xij ReS_Xi ReS_atwl ReS_str ReS_Xij_long"
	global ReS_Keep  "ReS_j_lab ReS_Xij_lab ReS_Xi_lab"
	if "`1'"=="clear" {
		foreach name of global ReS_Clear {
			char _dta[`name']
			}
		if "`2'"=="all" {
			foreach name of global ReS_Keep {
				char _dta[`name']
				}
			}
		exit
		}

	if "`1'"=="wide" | "`1'"=="long" {
		DoNew `*'
		exit
		}

	local syntax : char _dta[ReS_ver]

	if index("query","`1'") {
		if "`syntax'"=="" | "`syntax'"=="v.2" {
			Query
			exit
			}
		local 1 "query"
		}

	if "`syntax'"=="" {
		IfOld `1'
		if `s(oldflag)' {
			DoOld `*'
			char _dta[ReS_ver] "v.1"
			}
		else {
			DoNew `*'
			char _dta[ReS_ver] "v.2"
			}
		exit
	}

	if "`syntax'"=="v.1" {
		DoOld `*'
		}
	else 	DoNew `*'
end

program define IfOld, sclass
	if "`1'"=="" {
		sret local oldflag 0
		exit
		}
	sret local oldflag ///
	  = index("groups","`1'") | index("vars","`1'") | index("cons","`1'") | index("query","`1'")
end

program define IfNew, sclass
	sret local newflag = "`1'"=="i" | "`1'"=="j" | "`1'"=="xij" | "`1'"=="xi" | "`1'"=="error"
end

program define DoNew
	local cmd "`1'"
	mac shift
	/* reshape w/o arguments */
	if "`cmd'"=="" Query
	/* reshape mini-commands */
	else if "`cmd'"=="i" {
		unab ivars : `*', min(1) name(i variable is required)
		char _dta[ReS_i] "`ivars'"
		}
	else if "`cmd'"=="j"	J `*'
	else if "`cmd'"=="xij" Xij `*'
	else if "`cmd'"=="xi" {
		local xivars : unab `*', min(0)
		char _dta[ReS_Xi] `xivars'
		}
	/* reshape wide/long */
	else if "`cmd'"=="long" {
		if "`1'" != "" Simple long `*'
		capture noisily Long `*'
		Macdrop
		exit _rc
		}
	else if "`cmd'"=="wide" {
		if "`1'" != "" Simple wide `*'
		else {
			/* stupid hack... */
			global ReS_Xij : char _dta[ReS_Xij]
			global ReS_atwl : char _dta[ReS_atwl]
			reshape8 xij $ReS_Xij , atwl($ReS_atwl)
			global ReS_j : char _dta[ReS_j]
			local theLab: var lab $ReS_j
			char _dta[ReS_j_lab] `theLab'
			}
		capture noisily Wide `*'
		Macdrop
		exit _rc
		}
	/* reshape error */
	else if "`cmd'"==substr("error",1,max(3,length("`cmd'"))) {
		capture noisily Qerror `*'
		Macdrop
		}
	else {
		IfOld `cmd'
		if `s(oldflag)' {
			di as err "may not mix old and new syntax;"
			di as err `"either use new syntax or "reshape8 clear" and start over using old syntax."'
			exit 198
			}
		error 198
		}
end

program define DoOld
	local cmd "`1'"
	local l = length("`cmd'")
	mac shift

	if "`cmd'"==substr("groups",1,`l') {
		if "`2'" == "" {
			error 198
			}
		DoNew j `*'
		exit
		}
	
	if "`cmd'"==substr("vars",1,`l') {
		DoNew xij `*'
		exit
		}
	
	if "`cmd'"==substr("cons",1,`l') {
		DoNew i `*'
		exit
		}
	
	if "`cmd'"==substr("query",1,`l') {
		local cons   : char _dta[ReS_i]
		local grpvar : char _dta[ReS_j]
		local values : char _dta[ReS_jv]
		local vars   : char _dta[ReS_Xij]
		local car    : char _dta[ReS_Xi]
		di "group var:  `grpvar'"
		di "values:     `values'"
		di "cons:       `cons'"
		di "vars:       `vars'"
		exit
		}
	
	if "`cmd'"=="wide" {
		DoNew wide `*'
		exit
		}
	if "`cmd'"=="long" {
		DoNew long `*'
		exit
		}
	
	IfNew `cmd'
	if `s(newflag)' {
		di as err "may not mix old and new syntax;"
		di as err `"either use old syntax or "reshape8 clear" and start over using new syntax."'
		exit 198
		}
	error 198
end
	
program define Simple /* {wide|long} <funnylist>, i(varlist)
					[j(varname [values])] */
	syntax anything(name=xvarlist id="[Simple]:extended varlist") , i(varlist) [j(str) ATwl(passthru) String ]
			
	tokenize "`xvarlist'", parse(" ,")
	local cmd "`1'"
	mac shift
	local xvarlist `*'
	if "`xvarlist'"=="" {
		display as err "[Simple]: xvarlist empty"
		exit 198
		}
	if "`j'" != "" {
		tokenize "`j'"
		local jvar "`1'"
		mac shift
		local jvals "`*'"
		}
	else {
		local jvar "_j"						 /* place-holder for error checking */
		}
	
	if "`cmd'"=="wide" {
		/* When reshaping wide we can -unab- the variable list  and the jvar*/
		capture unab xvarlist : `xvarlist' /* ignore _rc, error caught later */
		capture unab jvar : `jvar' , max(1) /* use -unab- not -ConfVar- here */

		if _rc {
			if _rc==111 {
				di as error "`jvar' not found -- " _continue
				if "`jvar'"=="_j" {
					di as error "j() option needed"
					}
				else	di as error "data already wide"
				exit 111
				}
			display as error "i'm confused..."
			error _rc
			/* ConfVar `jvar' */
			/* exit 198	*/ /* just in case */
			}
		}
	else { 										 /* cmd is "long" */
		capture confirm new var `jvar'
		if _rc {
			if _rc==110 {
				di as error "`jvar' already defined -- data already long"
				exit 110
				}
			confirm new var `jvar'
			exit 666	/* should never happen */
			}
		}

	reshape8 clear
	reshape8 i `i'
	reshape8 j `jvar' `jvals', `string'
	reshape8 xij `xvarlist' , `atwl'
end

program define Xi /* simple variable names */
	syntax [varlist]
/* 	foreach var of local varlist { */
/* 		local theLab : var lab `var' */
/* 		local lablist "`lablist' `"`theLab'"'" */
/* 		} */
	char _dta[ReS_Xi] "`varlist'"
	char _dta[ReS_Xi_lab] `"`lablist'"'
end
	
program define Xij /* <names-maybe-with-@>[, atwl(string) */
	syntax anything(name=xvarlist id="[Xij]: extended varlist") [, ATwl(string)]
	if "`xvarlist'"=="" {
		display as result "[Xij]: Warning, xij list empty"
		}
	foreach item of local xvarlist {
		local item = cond(index("`item'","@"),subinstr("`item'","@","`atwl'",1),"`item'")
		capture local theLab : var lab `item'
		if !_rc {
			local lablist "`lablist' `"`theLab'"'"
			}
		}
	char _dta[ReS_Xij] "`xvarlist'"
	char _dta[ReS_Xij_lab] `"`lablist'"'
	char _dta[ReS_atwl] "`atwl'"
end

program define J /* reshape j [ #[-#] [...] | <str> <str> ...] [, string] */
	syntax anything(name=jvals id="J value list") [, string]	
	if "`jvals'"=="" {
		display as error "[J]: empty j value list"
		exit 198
		}
	tokenize "`jvals'", parse(" -")
	local grpvar "`1'"
	mac shift

	local isstr 0
	while "`1'"!="" {
		if "`2'" == "-" {
			local i1 `1'
			local i2 `3'
			confirm integer number `i1'
			confirm integer number `i2'
			if `i1' > `i2' {
				di as error "`i1'-`i2':  invalid range"
				exit 198
				}
			forvalues value = `i1'/`i2' {
				local values `values' `value'
				}
			mac shift 3
			}
		else {
			capture confirm integer number `1'
			local isstr = `isstr' | _rc
			local values `values' `1'
			mac shift
			}
		}

	if `isstr' & "`string'"=="" {
		di as err "must also specify string option if string values are to be specified"
		exit 198
		}
	if "`string'"!="" {
		local isstr 1
		}

	Chkj `grpvar' `isstr'
	capture ConfVar `grpvar'
	if !_rc {
		local theLab: var label `grpvar'
		char _dta[ReS_j_lab] `"`theLab'"'
		}
	char _dta[ReS_j] "`grpvar'"
	char _dta[ReS_jv] "`values'"
	char _dta[ReS_str] `isstr'
end

program define Chkj /* j whether-string */
	local grpvar "`1'"
	local isstr `2'

	/* grpvar already checked */

	capture confirm string var `grpvar'
	if _rc==0 {
		if !`isstr' {
			di as error "`grpvar' is string; specify string option"
			exit 109
			}
		}
	else {
		if `isstr' {
			di as error "`grpvar' is numeric but string option specified"
			exit 109
			}
		}
end

program define Query
	if "`*'"!="" {
		error 198
	}
	local cons   : char _dta[ReS_i]
	local grpvar : char _dta[ReS_j]
	local values : char _dta[ReS_jv]
	local vars   : char _dta[ReS_Xij]
	local car    : char _dta[ReS_Xi]
	local atwl   : char _dta[ReS_atwl]
	local isstr  : char _dta[ReS_str]

	display
	if "`grpvar'"!="" {
		capture ConfVar `grpvar'
		if _rc {
			di as result " (dataset is wide)"
			}
		else	di as result " (dataset is long)"
		}

	if "`cons'"=="" {
		local ccons "as text"
		local cons "<varlist>"
		}

	if "`grpvar'"=="" {
		local cgrpvar "as text"
		local grpvar "<varname>"
		if "`values'"=="" {
			local values "[<#> - <#>]"
			}
		}
	else if `isstr' {
		local values "`values', string"
		}

	if "`vars'"=="" {
		local cvars "as text"
		local vars "<varnames-without-#j-suffix>"
		}
	else {
		if "`atwl'" != "" {
			local vars "`vars', atwl(`atwl')"
			}
		}
	if "`car'"=="" {
		local ccar "as result"
		local car "<varlist>"
		}

	di in smcl as text "{c TLC}{hline 30}{c TT}{hline 46}{c TRC}" _n ///
	  "{c |} Xij" _col(32) "{c |} Command/contents" _col(79) "{c |}" _n ///
	  as text "{c LT}{hline 30}{c +}{hline 46}{c RT}"

	di in smcl as text /*
	*/ "{c |} Subscript i,j definitions:" _col(32) "{c |}" _col(79) "{c |}"

	di in smcl as text /*
	*/ "{c |}  group id variable(s)" _col(32) "{c |} reshape8 i " _c
	Qlist 44 "`ccons'" `cons'

	di in smcl as text /*
	*/ "{c |}  within-group variable" _col(32) "{c |} reshape8 j< " _c

	Qlist 44 "`cgrpvar'" `grpvar' `values'
	di in smcl as text /*
	*/ "{c |}   and its range" _col(32) "{c |}" _col(79) "{c |}"

	di in smcl as text "{c |}" _col(32) "{c |}" _col(79) "{c |}"

	di in smcl as text /*
	*/ "{c |} Variable X definitions:" _col(32) "{c |}" _col(79) "{c |}"

	di in smcl as text /*
	*/ "{c |}  varying within group" _col(32) "{c |} reshape8 xij " _c
	Qlist 46 "`cvars'" `vars'

	di in smcl as text /*
	*/ "{c |}  constant within group (opt) {c |} reshape8 xi  " _c
	Qlist 46 "`ccar'" `car'

	di in smcl as text "{c BLC}{hline 30}{c BT}{hline 46}{c BRC}"

	local cons   : char _dta[ReS_i]
	local grpvar : char _dta[ReS_j]
	local values : char _dta[ReS_jv]
	local vars   : char _dta[ReS_Xij]
	local car    : char _dta[ReS_Xi]

	if "`cons'"=="" {
		di as text `"First type ""' as input "reshape8 i" as text `"" to define the i variable."'
		exit
		}
	if "`grpvar'"=="" {
		di as text `"Type ""' as input "reshape8 j" as text `"" to define the j variable and, optionally, its values."'
			exit
			}
	if "`vars'"=="" {
		di as text `"Type ""' as input "reshape8 xij" as text `"" to define variables that vary within i."'
		exit
		}
	if "`car'"=="" {
		di as text `"Optionally type ""' as input "reshape8 xi" as text `"" to define variables that are constant within i."'
		}
	capture ConfVar `grpvar'
	if _rc {
		di as text `"Type ""' as input "reshape8 long" as text `"" to convert the data to long form."'
		exit
		}
	di as text `"Type ""' as input "reshape8 wide" as text `"" to convert the data to wide form."'
end

program define Qlist /* col <optcolor> stuff */
	local col `1'
	local clr "`2'"
	mac shift 2
	while "`1'" != "" {
		local l = length("`1'")
		if `col' + `l' + 1 >= 79 {
			local skip = 79 - `col'
			di in smcl as text _skip(`skip') "{c |}" _n /*
			*/ "{c |}" _col(32) "{c |} " _c
			local col 34
		}
		di as res `clr' "`1' " _c
		local col = `col' + `l' + 1
		mac shift
	}
	local skip = 79 - `col'
	di in smcl as text _skip(`skip') "{c |}"
end

program define Qerror
	MacroSet1
	MacroSet2
	capture ConfVar $ReS_j
	if _rc==0 QerrorW
	else	QerrorL
end


/* -------------------Wide Specific---------------------------------------- */
program define Wide		/* reshape wide */
	local oldobs = _N
	quietly describe, short
	local oldvars = r(k)

	MacroSet1
	capture ConfVar $ReS_j
	if _rc {
		di as text "(already wide)"
		exit
		}

	confirm var $ReS_Xij_long $ReS_i $ReS_Xi

	MacroSet2

	confirm var $ReS_j $ReS_Xi

	Veruniq

*	if "$ReS_Xi"!="" reshape8 xi $ReS_Xi

	preserve
	capture {
		if "$ReS_Xi" != "" {
			tempfile id2xi

			keep $ReS_i $ReS_Xi
			by $ReS_i, sort: keep if _n==1
			save `id2xi'
			restore, preserve
			}

		tempfile dsvars dsnew hold
		keep $ReS_j $ReS_Xij_long $ReS_i
		sort $ReS_i $ReS_j
		save `dsvars'

		keep $ReS_i
		by $ReS_i: keep if _n==1
		save "`dsnew'", replace

		/* datasets initialized, now step through each value: */

		tempvar useless
		global ReS_jv2
		local useflag 1
		foreach jval of global ReS_jv {
			if `useflag' use "`dsvars'", clear
			if $ReS_str keep if $ReS_j=="`1'"
			else 	keep if $ReS_j == `jval'
			if _N==0 {
				local useflag 0
				noi di as text "(note: no data for $ReS_j == `val')"
				}
			else {
				local useflag 1
				global ReS_jv2 $ReS_jv2 `jval'
				drop $ReS_j
				local cnt 1
				foreach xvarname of global ReS_Xij {
					local newvar = cond(index("`xvarname'","@"),subinstr("`xvarname'","@","`jval'",1),"`xvarname'`jval'")
					capture confirm new var `newvar'
					if _rc {
						capture confirm var `newvar'
						if _rc {
							n di as error "`newvar' invalid name"
							exit 198
							}
						else {
							n di as error "`newvar' already defined"
							exit 110
							}
						}
					local oldvar = cond(index("`xvarname'","@"),subinstr("`xvarname'","@","$ReS_atwl",1),"`xvarname'$ReS_atwl")
					rename `oldvar' `newvar'
					local theLab : word `cnt' of $ReS_Xij_lab
					if "`theLab'"!="" label var `newvar' "`theLab' - `jval'"
					else label var `newvar' "`oldvar' - `jval'"
					local cnt = `cnt' + 1
					}
				save "`hold'", replace
				use "`dsnew'"
				merge $ReS_i using "`hold'", _merge(`useless')
				drop `useless'
				sort $ReS_i
				save "`dsnew'", replace
				}
			}
		if "`id2xi'" != "" {
			merge $ReS_i using "`id2xi'", _merge(`useless')
			drop `useless'
			}
		global S_FN
		global S_FNDATE
		}	/* end big capture block */
	if _rc {
		restore
		error _rc
		}
	restore, not
	if "`syntax'" != "v.1" {
		sort $ReS_i
		}

	local syntax: char _dta[ReS_ver]
	if "`syntax'" != "v.1" {
		ReportW `oldobs' `oldvars'
		}
end

program define Veruniq
	capture by $ReS_i $ReS_j, sort: assert _N==1
	if _rc {
		di as err "$ReS_j not unique within $ReS_i;"
		di as err "there are multiple observations at the same $ReS_j within $ReS_i."
		di as err `"Type "reshape8 error" for a listing of the problem observations."'
		exit 9
		}
	if "$ReS_Xi"=="" {
		exit
		}
	sort $ReS_i $ReS_Xi $ReS_j
	tempvar cnt1 cnt2
	quietly by $ReS_i: gen long `cnt1' = _N
	quietly by $ReS_i $ReS_Xi: gen long `cnt2' = _N
	capture assert `cnt1' == `cnt2'
	if _rc==0 {
		exit
		}
	foreach xivar of global ReS_Xi {
		capture by $ReS_i: assert `xivar'==`xivar'[1]
		if _rc {
			di as err "`xivar' not constant within $ReS_i"
			}
		} 
	di as err  `"Type "reshape8 error" for a listing of the problem observations."'
	exit 9
end

program define QerrorW
	ConfVar $ReS_j
	confirm var $ReS_j $ReS_Xij $ReS_i $ReS_Xi
	capture by $ReS_i $ReS_j, sort: assert _N==1
	if _rc {
		QerrMsg1
		di as text /*
	*/ "The data are in long form;  j should be unique within i." _n
		di as text /*
		*/ "There are multiple observations for the same " /*
		*/ as res "$ReS_j" as text " within " /*
		*/ as res "$ReS_i" as text "." _n

		tempvar bad
		quietly by $ReS_i $ReS_j: gen `bad' = _N!=1
		quietly count if `bad'
		di as text /*
		*/ "The following " r(N) /*
		*/ " out of " _N /*
		*/ " observations have repeated $ReS_j values:"
		list $ReS_i $ReS_j if `bad'
		di as text _n "(data now sorted by $ReS_i $ReS_j)"
		exit
		}
	if "$ReS_Xi"=="" {
		di as text "$ReS_j is unique within $ReS_i;"
		di as text `"there is no error with which "reshape8 error" can help."'
		exit
		}
	sort $ReS_i $ReS_Xi $ReS_j
	tempvar cnt1 cnt2
	quietly by $ReS_i: gen long `cnt1' = _N
	quietly by $ReS_i $ReS_Xi: gen long `cnt2' = _N
	capture assert `cnt1' == `cnt2'
	if _rc==0 {
		di as text "$ReS_j is unique within $ReS_i and"
		di as text `"all the "reshape8 xi" variables are constant within $ReS_j;"'
		di as text `"there is no error with which "reshape8 error" can help."'
		exit
	}

	QerrMsg1
	local n : word count $ReS_Xij
	if `n'==1 {
		di as text "xij variable is " as res "$ReS_Xij" as text "."
	}
	else	di as text "xij variables are " as res "$ReS_Xij" as text "."
	di as text "Thus, the following variable(s) should be constant within i:"
	di as res _col(7) "$ReS_Xi"

	sort $ReS_i $ReS_j
	tempvar bad
	parse "$ReS_Xi", parse(" ")
	while "`1'"!=""  {
		capture by $ReS_i: assert `1'==`1'[1]
		if _rc {
			qui by $ReS_i: gen long `bad' = /*
				*/ cond(_n==_N,sum(`1'!=`1'[1]),0)
			qui count if `bad'
			di _n as res "`1'" as text " not constant within i (" /*
				*/ as res "$ReS_i" as text ") for " /*
				*/ r(N) " value" _c
			if r(N)==1 {
				di as text " of i:"
			}
			else	di as text "s of i:"
			qui by $ReS_i: replace `bad' = `bad'[_N]
			list $ReS_i $ReS_j `1' if `bad'
			drop `bad'
		}
		mac shift
	}
	di as text _n "(data now sorted by $ReS_i $ReS_j)"
end

program define QerrMsg1
	di _n as text "i (" as res "$ReS_i"  ///
	  as text ") indicates the top-level grouping such as subject id."
	di as text "j (" as res "$ReS_j"  ///
	  as text ") indicates the subgrouping such as time."
end

/* ------------------------Long Specific----------------------------------- */

program define Long 		/* reshape long */
	local oldobs = _N
	quietly d,s
	local oldvars = r(k)

	MacroSet1
	confirm var $ReS_i $ReS_Xi
	capture confirm new var $ReS_j
	if _rc {
		di as text "(already long)"
		exit
		}
	MacroSet2

	confirm var $ReS_i $ReS_Xi
	
	Verluniq
	TypeCk
	Longdo2
	
	local syntax: char _dta[ReS_ver]
	if "`syntax'" != "v.1" {
		order $ReS_i $ReS_j
		sort $ReS_i $ReS_j
		}
	if "`syntax'" != "v.1" {
		ReportL `oldobs' `oldvars'
		}
end

program define Verluniq
	local id : char _dta[ReS_i]
	sort `id'
	capture by `id': assert _N==1
	if _rc {
		di as err "i=`id' does not uniquely identify the observations;"
		di as err "there are multiple observations with the same value of `id'."
		di as err `"Type "reshape8 error" for a listing of the problem observations."'
		exit 9
	}
end

program define QerrorL
	confirm var $ReS_i
	local id "$ReS_i"
	sort `id'
	tempvar bad
	quietly by `id': gen byte `bad' = _N!=1
	capture assert `bad'==0
	if _rc==0 {
		di as text "`id' is unique; there is no problem on this score"
		exit
	}
	di _n as text "i (" as res "`id'" as text /*
	*/ ") indicates the top-level grouping such as subject id."
	di _n as text /*
*/ "The data are currently in the wide form; there should be be a single" /*
	*/ _n "observation per i".
	quietly count if `bad'
	di _n as text r(N) " out of " _N /*
	*/ " observations have duplicate i values:"
	list `id' if `bad'
	di as text _n "(data now sorted by `id')"
end

program define TypeCk
	/* optimization not needed any more, since it it built in to Stata */
	/*   --> just check that there is no mix of numeric and non-numeric */
	foreach xijvar of global ReS_Xij {
		foreach val of global ReS_jv {
			local var = cond(index("`xijvar'","@"),subinstr("`xijvar'","@","`val'",1),"`xijvar'`val'")
			capture confirm var `var'
			if _rc==0 {
				capture confirm str var `var'
				if "`isanum'" =="" {
					local isanum = !_rc
					}
				else {
					if `isanum'!=!_rc {
						noi di as err "`var' has type mismatch with other `xijvar' variables"
						exit 198
						}
					}
				}
			else {
				capture confirm new var `var'
				if _rc {
					di as err "`var' implied name too long"
					exit 198
					}
				}
			}
 		} 
end

program define Longdo2 /* reshapes long */
	preserve
	capture {
		if "$ReS_Xi"!="" {
			tempfile idxi
			keep $ReS_i $ReS_Xi
			sort $ReS_i
			save `idxi'
			restore, preserve
			drop $ReS_Xi
			tempfile idxij
			save `idxij'
			local useme "use `idxij'"
			local skipread 0
			}
		else {
			local useme "restore, preserve"
			local skipread 1
			}
		
		if $ReS_str {
			local type str
			}
		else {
			local type long
			}
		foreach val of global ReS_jv {
			foreach xijvar of global ReS_Xij {
				if `skipread' local skipread 0
				else `useme'
				local newvar = cond(index("`xijvar'","@"),subinstr("`xijvar'","@","$ReS_atwl",1),"`xijvar'$ReS_atwl")
				local oldvar = cond(index("`xijvar'","@"),subinstr("`xijvar'","@","`val'",1),"`xijvar'`val'")
				capture confirm var `oldvar'
				if _rc {
					noi display as text "(note: `oldvar' not found)"
					}
				else {
					keep $ReS_i `oldvar'
					drop if missing(`oldvar')
					rename `oldvar' `newvar'
					gen `type' $ReS_j = `val'
					tempfile `newvar'
					local filelist `filelist' ``newvar''
					save ``newvar''
					}
				}
			}
		gettoken firstfile filelist : filelist
		use `firstfile'
		foreach file of local filelist {
			append using `file'
			}
		local theLab : char _dta[ReS_j_lab]
		label var $ReS_j `"`theLab'"'
		local theLabList : char _dta[ReS_Xij_lab]
		local vnum 1
		foreach var of global ReS_Xij_long {
			local theLab : word `vnum' of `theLabList'
			label var `var' `"`theLab'"'
			}
		sort $ReS_i
		if "$ReS_Xi"!="" {
			tempname foo
			merge $ReS_i using `idxi', _merge(`foo')
			capture assert `foo'>1
			if _rc {
				display as result "Hmmm... something messed up on the long remerge"
				}
			}
		global S_FN
		global S_FNDATE
		}
	if _rc {
		restore
		error _rc
		}
	else restore, not
end
	

program define MacroSet1	/* reshape macro check utility */
	global ReS_j       : char _dta[ReS_j]
	global ReS_jv      : char _dta[ReS_jv]
	global ReS_jv2
	global ReS_j_lab   : char _dta[ReS_j_lab]
	global ReS_i       : char _dta[ReS_i]
	global ReS_Xij     : char _dta[ReS_Xij]
	global ReS_Xij_lab : char _dta[ReS_Xij_lab]
	global ReS_Xi      : char _dta[ReS_Xi]
	global ReS_Xi_lab  : char _dta[ReS_Xi_lab]
	global ReS_atwl    : char _dta[ReS_atwl]
	global ReS_str     : char _dta[ReS_str]
	local syntax       : char _dta[ReS_ver]

	if "$ReS_j"=="" {
		if "`syntax'"=="v.1" {
			ErrNotDefd "reshape8 groups"
			}
		else ErrNotDefd "reshape8 j"
		}

	/* error indicates that $ReS_j is new */
	capture ConfVar $ReS_j
	if _rc==0 {
		Chkj $ReS_j $ReS_str
		if $ReS_str==0 {
			capture assert $ReS_j<.
			if _rc {
				di as error "$ReS_j contains missing values"
				exit 498
				}
			}
		else {
			capture assert trim($ReS_j)!=""
			if _rc {
				di as error "$ReS_j contains missing values"
				exit 498
				}
			capture assert $ReS_j==trim($ReS_j)
			if _rc {
				di as error "$ReS_j has leading or trailing blanks"
				exit 498
				}
			}
		}

	if "$ReS_jv"=="" {
		if "`syntax'"=="v.1" {
			ErrNotDefd "reshape8 groups"
			}
		}
	
	if "$ReS_i"=="" {
		if "`syntax'"=="v.1" {
			ErrNotDefd "reshape8 cons"
			}
		else	ErrNotDefd "reshape8 i"
		}
	
	if "$ReS_Xij"=="" {
		if "`syntax'"=="v.1" {
			ErrNotDefd "reshape8 vars"
			}
		else ErrNotDefd "reshape8 xij"
		}

	foreach xijvar of global ReS_Xij {
		local newname = cond(index("`xijvar'","@"),subinstr("`xijvar'","@","$ReS_atwl",1),"`xijvar'$ReS_atwl")
		local vlist `vlist' `newname'
		}

	global ReS_Xij_long `vlist'
end

program define MacroSet2
	/* determine what to do	*/
	capture ConfVar $ReS_j
	local islong = !_rc
	local dovalW 0
	local dovalL 0
	local docar 0
	
	if "$ReS_jv"=="" {
		if `islong' local dovalL 1
		else local dovalW 1
		}

	if "$ReS_Xi"=="" {
		local syntax : char _dta[ReS_ver]
		if "`syntax'"=="v.2" {
			local docar 1
			}
		}

	if `dovalL' {
		FillvalL
		}

	if `dovalW' {
		FillvalW
		}

	if `docar' {
		FillXi `islong'
		}
end


program define ErrNotDefd /* <message> */
	di as err `""`*'" not defined"'
	exit 111
end

program define FillXi /* {1|0} */ /* 1 if islong currently */
	local islong `1'
	unab varlist : _all
	local varlist : list varlist - global(ReS_j)
	local varlist : list varlist - global(ReS_i)
	if `islong' {
		local usednamelist $ReS_Xij_long
		}
	else { 					/* wide */
		foreach xijvar of global ReS_Xij {
			foreach jval of global ReS_jv {
				local var= cond(index("`xijvar'","@"),subinstr("`xijvar'","@","`jval'",1),"`xijvar'`jval'")
				local usednamelist `usednamelist' `var'
				}
			}
		}
	local varlist : list varlist - usednamelist
	global ReS_Xi `varlist'
end

program define FillvalL
	Tab $ReS_j
end

program define Tab /* varname */
	/* puts values of j variable in $ReS_jv */
	local v "`1'"
	global ReS_jv
	capture confirm string variable `v'
	if _rc {
		tempname rows
		capture tabulate `v', matrow(`rows')
		if _rc {
			if _rc==1 { exit 1 }
			local bad 1
			}
		else {
			capture mat list `rows'
			local bad = _rc
			}
		if `bad' {
			/* theoretically cannot happen */
			di as err "$ReS_j contains all missing values"
			exit 498
			}
		local n = rowsof(`rows')
		forvalues row=1/`n' {
			local el = `rows'[`row',1]
			global ReS_jv $ReS_jv `el'
			}
		}
	else {				/* string ReS_j	*/
		quietly {
			tempvar one
			by `v', sort: gen byte `one' = _n>1
			sort `one' `v'
			local i 1
			while `one'[`i']==0 {
				local el = `v'[`i']
				global ReS_jv $ReS_jv `el'
				local i = `i' + 1
				}
			}
		}
	di as text "(note: j = $ReS_jv)"
end

program define FillvalW
	foreach xvar of global ReS_Xij {
		local l = index("`xvar'","@")
		local l = cond(`l'==0, length("`xvar'")+1,`l')
		local left = substr("`xvar'",1,`l'-1)
		local right = substr("`xvar'",`l'+1,.)
		local newname "`left'`right'"

		capture confirm new var `newname'
		if _rc {
			display as error "variable `newname' already defined"
			}
		unab varlist : `left'*`right'
		foreach var of local varlist {
			local value = substr("`var'",length("`left'")+1,length("`var'")-length("`left'")-length("`right'"))
			local valuelist `valuelist' `value'
			}
		}
	if "`valuelist'"=="" {
		di as err "no xij variables found"
		exit 111
		}
	global ReS_jv `valuelist'
	di as text "(note: j = $ReS_jv)"
end

/*-------------------- reporting programs --------------------*/

program define ReportL /* old_obs old_vars */
	Report1 `1' `2' wide long

	local n : word count $ReS_jv
	di as text "j variable (`n' values)" _col(43) "->" _col(48) /*
	*/ as result "$ReS_j"
	di as text "xij variables:"
	foreach xijvar of global ReS_Xij {
		RepF "`xijvar'"
		local skip = 39 - length("`r(start)'")
		di as result _skip(`skip') "`r(start)'" _col(43)  ///
		  as text  "->"  ///
		  as result _col(48) "`r(last)'"
		mac shift
	}
	di in smcl as text "{hline 77}"
end

program define RepF, rclass /* element from ReS_Xij */
	local v "`1'"
	if "$ReS_jv2" != "" {
		local n : word count $ReS_jv2
		tokenize "$ReS_jv2"
		}
	else {
		local n : word count $ReS_jv
		tokenize "$ReS_jv"
		}
	if `n'>=1 local list=cond(index("`v'","@"),subinstr("`v'","@","`1'",1),"`v'`1'")
	if `n'>=2 {
		local next = cond(index("`v'","@"),subinstr("`v'","@","`2'",1),"`v'`2'")
		local list `list' `next'
		}
	if `n'==3 {
		local next = cond(index("`v'","@"),subinstr("`v'","@","``n''",1),"`v'``n''")
		local list `list' `next'
		}
	else if `n'>3 {
		local next = cond(index("`v'","@"),subinstr("`v'","@","``n''",1),"`v'``n''")
		local list `list' ... `next'
		}
	return local last = cond(index("`v'","@"),subinstr("`v'","@","$ReS_atwl",1),"`v'$ReS_atwl") 
	return local start `list'
end


program define Report1 /* <#oobs> <#ovars> {wide|long} {long|wide} */
	local oobs "`1'"
	local ovars "`2'"
	local wide "`3'"
	local long "`4'"

	di in smcl _n as text /*
	*/ "Data" _col(36) "`wide'" _col(43) "->" _col(48) "`long'" /*
	*/ _n "{hline 77}"

	di as text "Number of obs." _col(32) as res %8.0g `oobs' /*
	*/ as text _col(43) "->" as res %8.0g _N

	quietly desc, short

	di as text "Number of variables" _col(32) as res %8.0g `ovars' /*
	*/ as text _col(43) "->" as res %8.0g r(k)
end

program define ReportW /* old_obs old_vars */
	Report1 `1' `2' long wide

	local n : word count $ReS_jv2
	local col = 31+(9-length("$ReS_j"))
	di as text "j variable (`n' values)" /*
		*/ _col(`col') as res "$ReS_j" as text _col(43) "->" /*
		*/ _col(48) "(dropped)"
	di as text "xij variables:"
	foreach xijvar of global ReS_Xij {
		RepF "`xijvar'"
		local skip = 39 - length("`r(start)'")
		di as res _skip(`skip') "`r(start)'" _col(43) as text "->" /*
		*/ as res _col(48) "`r(last)'"
		}
	di in smcl as text "{hline 77}"
end

/* utility programs */
/* ConfVar confirms a variable exists and is not an abbreviation */
program define ConfVar 
	capture syntax varname
	if _rc == 0 & (`"`1'"' == "`varlist'") exit 0
	di as error `"`0' not found literally -- abbreviations not allowed"'
	exit 111
end

program define Macdrop
	foreach gmac in $ReS_Clear $ReS_Keep {
		global `gmac'
		}
	global ReS_Clear
	global ReS_Keep
end

program define FixName, rclass /* <name-maybe-with-@> <tosub> */
	local name "`1'"
	local sub "`2'"
	local l = index("`name'","@")
	local l = cond(`l'==0, length("`name'")+1,`l')
	local a = substr("`name'",1,`l'-1)
	local c = substr("`name'",`l'+1,.)
	return local newname "`a'`sub'`c'"
	return local left `a'
	return local right `c'
end

