
program odk2doc
	version 15.0
	
	syntax using/, to(string) [keep(string)] [DROPType(string)] [DROPVar(string)] [max(integer 30)] [fill] [DELete(string)] [clean] [mark(string)] [doc(string asis)] [fmt(string asis)] [tfmt(string asis)] [qfmt(string asis)] [afmt(string asis)] [replace]
	
	if !inlist("`mark'","","multiple","single","both") {
		di in red `"Option "mark" must contain either "multiple", "single", or "both""'
		exit
	}
	if `max'<0 {
		di in red `"Option "max" must be positive"'
		exit
	}

preserve
	
quietly {
	
	tempfile temp_choices temp_vars
	
import excel "`using'", sh("choices") first all clear
 
	// Rename choices, ignore blank rows
	cap rename list list_name
	cap rename listname list_name
	keep list_name name label*
	drop if list_name==""
	
	tempvar Nobs nobs
	gen `nobs' = _n
	bysort list_name: gen `Nobs' = _N
	drop if `Nobs'>`max'
	sort list_name `nobs'
	drop `Nobs' 
	
	rename label* answer*
	compress

save "`temp_choices'"

import excel "`using'", sh("survey") first all clear

	// Error check
	foreach k in `keep' {
		ds, has(varl "`k'*")
		if wordcount("`r(varlist)'")==0 {
			noisily di in red `"Column labeled "`k'" not found"'
			exit(0)
		}
	}
	
	// Keep labeled questions only
	drop if name==""
	ds label*
	local w: word 1 of `r(varlist)'
	drop if `w'==""
	
	// Split question type and list name
	tempvar qtype other dummy
	gen `qtype' = word(type,1)
	gen list_name = word(type,2)
	gen `other' = ""
	gen `dummy' = wordcount(type)
	su `dummy', meanonly
	if `r(max)'>2 {
		replace `other' = word(type,3)
	}
	replace `qtype' = list_name if inlist(`qtype',"begin","end")
	foreach d of local droptype {
		drop if inlist(`qtype',"`d'")
		if r(N_drop)>0 noisily di as text `"Dropped questions of type "`d'""'
	}
	
	// Drop unwanted elements
	local count = 0
	foreach var in `dropvar' {
		drop if strmatch(name,"`var'")
		if r(N_drop)>0 local count = `count'+1
	}
	if "`dropvar'"!="" & `count'==0 noisily di as text `"No variable specified in option "drovar" could be dropped"'

	// Collect all columns which should be kept.
	foreach k in `keep' {
		ds, has(varl "`k'*")
		local klist `klist' `r(varlist)'
	}
	
	// Number questions
	tempvar question_no
	gen `question_no' = _n
	
	// Display warranted input below questions
	if "`fill'"!="" {
		tempvar dup1 dup2 dup3 dup4
		expand 2 if type=="range", gen(`dup1')
		expand 2 if (type=="integer" | type=="decimal"), gen(`dup2')
		expand 2 if regexm(`other',"other"), gen(`dup3')
		expand 2 if inlist(type,"text","image","geopoint"), gen(`dup4')
		sort `question_no' `dup1' `dup2' `dup3' `dup4'
		foreach v of varlist label* {
			replace `v' = parameter if type=="range" & `dup1' == 1
			replace `v' = "[Number]" if type=="range" & `dup1' == 1 & missing(`v')	
			replace `v' = constraint if (type=="integer" | type=="decimal") & `dup2' == 1
			replace `v' = "[Number]" if (type=="integer" | type=="decimal") & `dup2' == 1 & missing(`v')	
			replace `v' = "Other, specify" if `other'!="" & `dup3' == 1
			replace `v' = "[" + strproper(type) + "]" if `dup4' == 1
		}
		foreach k in `klist' {
			replace `k' = "" if `dup1'==1 | `dup2'==1 | `dup3'==1 | `dup4'==1
		}
		replace name = "" if `dup1'==1 | `dup2'==1 | `dup4'==1
		replace `qtype' = "" if `dup3'==1
	}
	
	// Mark single/multiple select
	if inlist("`mark'","multiple","both") {
		foreach w of varlist label* {
			replace `w' = `w' + " [Multiple select]" if `qtype'=="select_multiple"
		}		
	}
	if inlist("`mark'","single","both") {
		foreach w of varlist label* {
			replace `w' = `w' + " [Single select]" if `qtype'=="select_one"
		}		
	}

	// Order & keep only relevant columns
	order `question_no' type list_name name label* `klist'
	keep `question_no' type list_name name label* `klist' `dup1' `dup2' `dup3' `dup4'
	tempvar q code
	gen `code' = name
	drop name
	gen `q' = 1
	compress

save "`temp_vars'"

	if "`fill'"!="" drop if `dup3'==1
	keep `question_no' `code' list_name `dup1' `dup2' `dup4'

joinby list_name using "`temp_choices'"
	sort `question_no' `dup1' `dup2' `dup4' `nobs'
	if "`fill'"!="" gen `dup3' = 0
	drop list_name

append using "`temp_vars'"

	// Match questions with answer options	
	ds answer*
	local a `r(varlist)'
	tokenize `a'
	local n = 1
	foreach w of varlist label* {
		replace `w' = ``n'' if `w'=="" & ``n''!=""
		local n = `n' +1
	}
	
	// Clean
	if `"`delete'"'!="" {	
		foreach w of varlist label* {
			foreach c of local delete {
				replace `w' = ustrregexrf(`w',`"`c'"',"")
			}
			replace `w' = ustrtrim(stritrim(`w'))
		}
	}
	
	if "`clean'"!="" {
		if "`fill'"!="" {
			foreach w of varlist label* {
				replace `w' = ustrregexra(`w',"<.[^>]+>"," ") 		if `dup1'!=1 & `dup2'!=1
				replace `w' = ustrregexra(`w',"[\*_#]","") 			if `dup1'!=1 & `dup2'!=1
				replace `w' = usubinstr(`w',"${","_",.)		 		if `dup1'!=1 & `dup2'!=1			
				replace `w' = ustrregexra(`w',"_.[^\}]+\}","___",.)	if `dup1'!=1 & `dup2'!=1			
				replace `w' = ustrtrim(stritrim(`w'))			
			}
		}
		if "`fill'"=="" {
			foreach w of varlist label* {
				replace `w' = ustrregexra(`w',"<.[^>]+>"," ")
				replace `w' = ustrregexra(`w',"[\*_#]","")
				replace `w' = usubinstr(`w',"${","_",.)	
				replace `w' = ustrregexra(`w',"_.[^\}]+\}","___",.)
				replace `w' = ustrtrim(stritrim(`w'))			
			}
		}
	}
	
	replace `code' = name if name!=""
	if "`fill'"!="" replace `code' = `code' + "_other" if `dup3'==1
	sort `question_no' `dup1' `dup2' `dup3' `dup4' `q' `nobs'
	
	// Only give question number to question, not answers
	tempvar dummy question
	by `question_no': gen `dummy'=_n
	replace `question_no' = . if `dummy'>1
	gen `question' = strofreal(`question_no')
	replace `question' = "" if `question'=="."
	drop `question_no'
	
	keep `question' label* `code' `klist'
	order `question' label* `code' `klist'

	// Clean "relevant" and "constraint" column
	foreach v in relevant constraint {
		cap confirm var `v'
		if !_rc {
			replace `v' = usubinstr(`v',"${","",.)
			replace `v' = usubinstr(`v',"},'","=",.) 					if ustrregexm(`v',"selected(")
			replace `v' = usubinstr(`v',"}, '","=",.) 					if ustrregexm(`v',"selected(")
			replace `v' = usubinstr(`v',"')","",.) 						if ustrregexm(`v',"selected(")
			replace `v' = usubinstr(`v',"count-selected(","count(",.)	if ustrregexm(`v',"count-selected(")
			replace `v' = usubinstr(`v',"selected(","",.) 				if ustrregexm(`v',"selected(")
			replace `v' = usubinstr(`v',"}","",.)
		}
	}
	
	// Create column headers
	la var `question' Question
	la var `code' Code
	ds, not(varl *::*) 
	local lab_list1 `r(varlist)'
	foreach l of local lab_list1 {
		local lab: var lab `l' 
		local lab = ustrtitle(ustrtrim(ustrregexrf("`lab'","_"," ")))
		la var `l' "`lab'"
	}
	ds, has(varl *::*)
	local lab_list2 `r(varlist)'
	foreach l of local lab_list2 {
		local lab: var lab `l' 
		local lab = ustrregexrf("`lab'","::"," ")
		local type: word 1 of `lab'
		local type = ustrtitle(ustrtrim(ustrregexrf("`type'","_"," ",.)))		
		local lab: word 2 of `lab'
		if "`type'"=="Label" la var `l' "`lab'"
		if "`type'"!="Label" la var `l' "`type' `lab'"
	}

}


	cap putdocx clear

putdocx begin, `doc'

	putdocx table Q = data(*), varnames `fmt'
	
	// Put column headers in first row
	local n = 1
	foreach var of varlist * {
		local lab: var l `var'
		putdocx table Q(1,`n') = ("`lab'")
		local n = `n'+1
	}
	
	// Format column headers
	if `"`tfmt'"'!="" {
		putdocx table Q(1,.), `tfmt'
	}
	
	// Format questions & answers
	if `"`qfmt'"'!="" {
		forv n = 1/`=_N' {
			if `question'[`n']!="" {
				putdocx table Q(`=`n'+1',.), `qfmt'
			}	
		}
	}
	
	// Format answers
	if `"`afmt'"'!="" {
		forv n = 1/`=_N' {
			if `question'[`n']=="" {
				putdocx table Q(`=`n'+1',.), `afmt'
			}	
		}
	}

putdocx save `"`to'"', replace
	
restore
	
end
