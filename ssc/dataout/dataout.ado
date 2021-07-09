* version 1.0.4 26oct2009 dataout by roywada@hotmail.com
* exports dataset or tab-delimited file into various formats
* codes ripped from outreg/outreg2/logout/xmlsave

program define dataout

syntax [using/], [save(string) excel tex word NOHEAD HEAD replace NOAUTO auto(integer 3) dec(numlist int >=0 <=11) /*
	*/ MIDborder(int 1) ]
version 7

if `"`using'"'=="" & "`save'"=="" {
		noi di in red "must specify {opt using} or {opt save( )}"
		exit 198
}

if "`using'"~="" {
	* attach .txt if nothing attached
	local beg_dot = index(`"`using'"',".")
	if `beg_dot'==0 {
		local using `"`using'.txt"'
	}
}

if "`save'"=="" {
	* assign save name
	local beg_dot = index(`"`using'"',".")
	local strippedname = substr(`"`using'"',1,`=`beg_dot'-1')
	local save "`strippedname'_logout.txt"
}
else {
	* assign save name
	local beg_dot = index(`"`save'"',".")
	if `beg_dot'~=0 {
		local strippedname = substr(`"`save'"',1,`=`beg_dot'-1')
		local save `"`strippedname'.txt"'
	}
	else {
		* `save' has no extension
		local strippedname `"`save'"'
		local save `"`save'.txt"'
	}
	
	
	if `"`using'"'=="" {
		* if using file was not specified but save was:
		local beg_dot = index(`"`save'"',".")
		if `beg_dot'~=0 {
			local strippedname = substr(`"`save'"',1,`=`beg_dot'-1')
		}
		else {
			local strippedname `"`save'"'
		}
	}
}


qui {

if `"`using'"'~="" {
	preserve
	qui insheet using `"`using'"', noname clear
}


cap preserve
*foreach var of varlist _all {
*	tostring `var', replace force
*}
stringMaker



if "`dec'"~="" {
	* apply decimals
	foreach var of varlist _all {
		local N=_N
		forval num=1/`N' {
			local content=`var'[`num']
			
			capture confirm number `content'
			if _rc==0 {
				* only if a number
				replace `var' = string(`content',"%12.`dec'fc") in `num'
			}
			else {
				* only if not a number
				*replace `var'=`"`content'"' in `num'
			}
		}
	}
}



if "`noauto'"~="noauto" & "`dec'"=="" {
	* apply autodigits
	foreach var of varlist _all {
		local N=_N
		forval num=1/`N' {
			local content=`var'[`num']
			
			capture confirm number `content'
			if _rc==0 {
				* only if a number
				autodigits2 `content' `auto' `less'
			replace `var' = string(`content',"%12.`r(valstr)'") in `num'
			}
			else {
				* only if not a number
				*replace `var'=`"`content'"' in `num'
			}
		}
	}
}


if ("`nohead'"~="nohead" & `"`using'"'=="") | "`head'"=="head" {
	* moves the variable names down
	local N=_N+1
	tempvar id
	gen `id'=_n
	set obs `N'
	replace `id'=0 in `N'
	sort `id'
	drop `id'
	local num 1
	foreach var of varlist _all {
		replace `var'="`var'" in 1
	}
	local num 1
	foreach var of varlist _all {
		ren `var' v`num'
		local num=`num'+1
	}
}

local titleWide 0
local headBorder `midborder'
local N=_N
local bottomBorder `N'
local totrows `N' /* for wordout only */

*** Excel xml file thing
if "`excel'"=="excel" {
	tempfile file1
	
	cap confirm file `"`strippedname'.xml"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.xml exists; specify {opt replace}"'
		exit 198
	}
	
	save `file1', replace
	if "`raw'"=="raw" {
		replace raw=`"""' + raw + `"""'
	}
	
	
	
	*use `outing',clear
*	_xmlout using `"`strippedname'"', excelFile(`excelFile') nonames titleWide(`titleWide') /*
*		*/ headBorder(`headBorder') bottomBorder(`bottomBorder') 
	
	local N=_N
	
	_xmlout using `"`strippedname'"',  nonames headBorder(`midborder') bottomBorder(`N')
	local usingTerm `"`strippedname'.xml"'
	local cl `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl'"'
	
	use `file1', clear
}


if "`word'"=="word" | "`tex'"=="tex" {
	cap preserve
	if ("`nohead'"=="nohead" & `"`using'"'~="") & "`head'"~="head" {
		* `using' indicates
		* files not yet named v*
		local num 1
		foreach var of varlist _all {
			ren `var' v`num'
			local num=`num'+1
		}
	}

*** Word rtf file thing
if "`word'"=="word" {

	cap confirm file `"`strippedname'.rtf"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.rtf exists; specify {opt replace}"'
		exit 198
	}
	
	
	* there must be varlist to avoid error
	*_wordout v* `"`using'"',  titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
	_wordout v* using `"`strippedname'"', wordFile(`wordFile') titleWide(`titleWide') /*
		*/ headBorder(`headBorder') bottomBorder(`bottomBorder') replace nopretty
	local temp `r(documentname)'
	
	* strip off "using" and quotes
	gettoken part rest: temp, parse(" ")
	gettoken usingTerm second: rest, parse(" ")
	
	local cl_word `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl_word'"'

}

*** LaTeX thing
*** (will mess up the original file)
if "`tex'"=="tex" {
	cap confirm file `"`strippedname'.tex"'
	if !_rc & "`replace'"~="replace" {
		* it exists
		noi di in red `"`strippedname'.tex exists; specify {opt replace}"'
		exit 198
	}
	
	* make certain `1' is not `"`using'"' (another context)
	
	_texout v* using `"`strippedname'"', texFile(`texFile') titleWide(`titleWide') headBorder(`headBorder') bottomBorder(`bottomBorder') `texopts' replace
	
	if `"`texFile'"'=="" {
		local endName "tex"
	}
	else {
		local endName "`texFile'"
	}
	
	local usingTerm `"`strippedname'.`endName'"'
	local cl_tex `"{browse `"`usingTerm'"'}"'
	noi di as txt `"`cl_tex'"'

}
}

noi _cdout

} /* quietly */

end


********************************************************************************************


*** ripped from outreg2 Mar 2008
program define autodigits2, rclass
version 7.0

* getting the significant digits
args input auto less

if `input'~=. {
	local times=0
	local left=0
	
	* integer checked by modified mod function
	if round((`input' - int(`input')),0.0000000001)==0 {
		local whole=1
	}
	else {
		local whole=0
		* non-interger
		 if `input'<. {
			
			* digits that need to be moved if it were only decimals: take the ceiling of log 10 of absolute value of decimals
			local times=abs(int(ln(abs(`input'-int(`input')))/ln(10)-1))	
			
			* the whole number: take the ceiling of log 10 of absolute value
			local left=int(ln(abs(`input'))/ln(10)+1)
		}
	}
	
	
	* assign the fixed decimal values into aadec
	if `whole'==1 {
		local aadec=0
	}
	else if .>`left' & `left'>0 {
		* reduce the left by one if more than zero to accept one extra digit
		if `left'<=`auto' {
			local aadec=`auto'-`left'+1
		}
		else {
			local aadec=0
		}
	}
	else {
		local aadec=`times'+`auto'-1
	}
	
	if "`less'"=="" {
		* needs to between 0 and 11
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<11 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	else {
		* needs to between 0 and 11
		local aadec=`aadec'-`less'
		if `aadec'<0 {
			local aadec=0
		}
		*if `aadec'<10 {
		if `aadec'<7 {
			* use fixed
			local valstr "`aadec'f"
		}
		else {
			* use exponential
			local valstr "`=`auto'-1'e"
		}
	}
	
	* make it exponential if too big
	if `input'>1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	* make it exponential if too negative (small)
	if `input'<-1000000 & `input'<. {
		local valstr "`=`auto'-0'e"		
	}
	
	return scalar value=`aadec'
	return local valstr="`valstr'"
}
else {
	* it is a missing value
	return scalar value=.
	return local valstr="missing"
}
end


********************************************************************************************


* ripped from outreg2 on Apr2009
* 26oct2009 nopretty for _texout fixed

program define _texout, sortpreserve
* based on out2tex version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
version 7.0
	
	* add one if only one v* column exists
	unab list: v*
	local count: word count `list'
	if `count'==1 {
		gen str v2=""
		order v*
	}
	if `count'==0 {
		exit
	}
	
	if "`1'" == "using" {
		syntax using/ [, texFile(string) Landscape Fragment NOPRetty PRetty	/*
		*/	Fontsize(numlist integer max=1 >=10 <=12) noBorder Cellborder	/*
		*/	Appendpage noPAgenum a4 a5 b5 LETter LEGal EXecutive replace	/*
		*/	Fast											]
		
		if "`pretty'"=="pretty" {
			local nopretty ""		
		}
		
		if "`fast'" == "" {
			preserve
		}
		
		loadout using `"`using'"', clear
		local numcol	= `r(numcol)'
		local titleWide  = `r(titleWide)'
		local headBorder = `r(headBorder)'
		local bottomBorder	= `r(bottomBorder)'
		local totrows	= _N
		
		local varname "v1"
		unab statvars : v2-v`numcol'
	}
	else {
		syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)		/*
		*/	[texFile(string) TOtrows(int 0) Landscape Fragment NOPRetty PRetty	/*
		*/	Fontsize(numlist integer max=1 >=10 <=12) noBorder Cellborder		/*
		*/	Appendpage noPAgenum a4 a5 b5 LETter LEGal EXecutive replace		]
		if `totrows'==0 {
			local totrows = _N
		}
		local numcols : word count `varlist'
		gettoken varname statvars : varlist
		local fast 1
	}
	
	if "`pretty'"=="pretty" {
		local pretty ""
	}
	else {
		local pretty "NOT PRETTY AT ALL"
	}
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	* insert $<$ to be handled in LaTeX conversion
	local N=_N
	forval num=`bottomBorder'/`N' {
		local temp=v1[`num']
		tokenize `"`temp'"', parse (" <")
		local count 1
		local newTex ""
		local noSpace 0
		while `"``count''"'~="" {
			if `"``count''"'=="<" {
				local `count' "$<$"
				local newTex `"`newTex'``count''"'
				local noSpace 1
			}
			else {
				if `noSpace'~=1 {
					local newTex `"`newTex' ``count''"'
				}
				else {
					local newTex `"`newTex'``count''"'					
					local noSpace 0
				}
			}
			local count=`count'+1
		}
		replace v1=`"`newTex'"' in `num'
	}
	
	*** replace if equation column present
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		tempvar myvar
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 `myvar' =""
		replace `myvar' =v2
		drop v2
		ren `myvar' v2
		order v1 v2
	}
	
	/* if file extension specified in `"`using'"', replace it with ".tex" for output
	local next_dot = index(`"`using'"', ".")
	if `next_dot' {
		local using = substr("`using'",1,`=`next_dot'-1')
	}
	*/
	
	if `"`texFile'"'=="" {
		local endName "tex"
	}
	else {
		local endName "`texFile'"
	}
	
	local using `"using "`using'.`endName'""'
	local fsize = ("`fontsize'" != "")
	if `fsize' {
		local fontsize "`fontsize'pt"
	}
	local lscp = ("`landscape'" != "") 
	if (`lscp' & `fsize') {
		local landscape ",landscape"
	}
	local pretty	= ("`pretty'" == "")
	local cborder  = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local nopagen  = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	local nopt : word count `a4' `a5' `b5' `letter' `legal' `executive'
	if `nopt' > 1 {
		di in red "choose only one of a4, a5, b5, letter, legal, executive"
		exit 198 
	}
	local pagesize "`a4'`a5'`b5'`letter'`legal'`executive'"
	if "`pagesize'"=="" | "`letter'"!="" {
		local pwidth  "8.5in"
		local pheight "11in"
	}
	else if "`legal'"!="" {
		local pwidth  "8.5in"
		local pheight "14in"
	}
	else if "`executive'"!="" {
		local pwidth  "7.25in"
		local pheight "10.5in"
	}
	else if "`a4'"!="" {
		local pwidth  "210mm"
		local pheight "297mm"
	}
	else if "`a5'"!="" {
		local pwidth  "148mm"
		local pheight "210mm"
	}
	else if "`b5'"!="" {
		local pwidth  "176mm"
		local pheight "250mm"
	}
	if `lscp' {
		local temp	 "`pwidth'"
		local pwidth  "`pheight'"
		local pheight "`temp'"
	}
	if "`pagesize'"!="" {
		local pagesize "`pagesize'paper"
		if (`lscp' | `fsize') {
			local pagesize ",`pagesize'"
		}
	}
	if `cborder' & `noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	quietly {
		tempvar has_eqn st2_row last_st pad0 pad1 pad2_n padN order
		
		* replace % with \%, and _ with \_ if <2 $'s (i.e. not an inline equation: $...$
		* has_eqn indicates that varname has 2+ $'s
		
		gen byte `has_eqn' = index(`varname',"$")
		
		* make sure there are 2+ "$" in varname
		replace `has_eqn' = index(substr(`varname',`has_eqn'+1,.),"$")>0 if `has_eqn'>0
		replace `varname'= subinstr(`varname',"_", "\_", .) if !`has_eqn'
		replace `varname'= subinstr(`varname',"%", "\%", .)
		
		if `pretty' {
			replace `varname'= subinword(`varname',"R-squared", "\$R^2$", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " \em t \em stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " \em z \em stat", 1) in `bottomBorder'/`totrows'
		}
		
		foreach svar of local statvars { /* make replacements for column headings rows of statvars */
			replace `has_eqn' = index(`svar',"$") in `colhead1'/`headBorder'
			replace `has_eqn' = index(substr(`svar',`has_eqn'+1,.),"$")>0 in `colhead1'/`headBorder' if `has_eqn'>0
			replace `svar'= subinstr(`svar',"_", "\_", .) in `colhead1'/`headBorder' if !`has_eqn'
			replace `svar'= subinstr(`svar',"%", "\%", .) in `colhead1'/`headBorder'
			
			/* replace <, >, {, }, | with $<$, $>$, \{, \}, and $|$ in stats rows */
			/* which can be used as brackets by outstat */
			replace `svar'= subinstr(`svar',"<", "$<$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',">", "$>$", .) in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"{", "\{", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"}", "\}", .)  in `strow1'/`bottomBorder'
			replace `svar'= subinstr(`svar',"|", "$|$", .) in `strow1'/`bottomBorder'
		}
		
		if `pretty' {  /* make title fonts large; notes & t stats small */
			local blarge "\begin{large}"
			local elarge "\end{large}"
			local bfnsize "\begin{footnotesize}"
			local efnsize "\end{footnotesize}"
		}
		if `cborder' {
			local vline "|"
		}
		gen str20 `pad0' = ""
		gen str20 `padN' = ""
		if `titleWide' {
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`blarge'" in 1 / `titleWide'
			replace `padN' = "`elarge'} \\\" in 1 / `titleWide'
		}
		if `bottomBorder' < `totrows' {
			local noterow1 = `bottomBorder' + 1
			replace `pad0' = "\multicolumn{`numcols'}{`vline'c`vline'}{`bfnsize'" in `noterow1' / l
			replace `padN' = "`efnsize'} \\\" in `noterow1' / l
		}
		
		gen str3 `pad1' = " & " in `colhead1' / `bottomBorder'
		if `numcols' > 2 {
			gen str3 `pad2_n' = `pad1'
		}
		if `pretty' { /* make stats 2-N small font */
			local strow1 = `headBorder' + 1
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			if !`cborder' {
				replace `pad0'	= "\vspace{4pt}" if `last_st'
			}
				replace `pad1'	= `pad1' + "`bfnsize'" if `st2_row'
				if `numcols' > 2 {
					replace `pad2_n' = "`efnsize'" + `pad2_n' + "`bfnsize'" if `st2_row'
				}
				replace `padN'	= "`efnsize'" if `st2_row'
			}
		
			replace `padN' = `padN' + " \\\" in `colhead1' / `bottomBorder'
			if `cborder' {
				replace `padN' = `padN' + " \hline"
			}
			else {
			if !`noborder' {
				if `headBorder' {
					if `titleWide' {
						replace `padN' = `padN' + " \hline" in `titleWide'
					}
					replace `padN' = `padN' + " \hline" in `headBorder'
				}
				replace `padN' = `padN' + " \hline" in `bottomBorder'
			}
		}
		
		local vlist "`pad0' `varname' `pad1'"
		tokenize `statvars'
		local ncols_1 = `numcols' - 1
		local ncols_2 = `ncols_1' - 1
		forvalues v = 1/`ncols_2' {
			local vlist "`vlist' ``v'' `pad2_n'"
		}
		local vlist "`vlist' ``ncols_1'' `padN'"
		
		local texheadfootrows = `nofrag' + `pretty' + 1	/* in both headers and footers */ 
		local texheadrow = 2 * `nofrag' + `nopagen' + `texheadfootrows'
		local texfootrow = `texheadfootrows'
		local newtotrows = `totrows' + `texheadrow' + `texfootrow'
		if `newtotrows' > _N {
			local oldN = _N
			set obs `newtotrows'
		}
		else {
			local oldN = 0
		}
		gen long `order' = _n + `texheadrow' in 1 / `totrows'
		local newtexhrow1 = `totrows' + 1
		local newtexhrowN = `totrows' + `texheadrow'
		replace `order' = _n - `totrows' in `newtexhrow1' / `newtexhrowN'
		sort `order'
		
		
		* insert TeX header lines
		local ccc : display _dup(`ncols_1') "`vline'c"
		if `nofrag' {
			replace `pad0' = "\documentclass[`fontsize'`landscape'`pagesize']{article}" in 1
			replace `pad0' = "\setlength{\pdfpagewidth}{`pwidth'} \setlength{\pdfpageheight}{`pheight'}" in 2
			replace `pad0' = "\begin{document}" in 3
			replace `pad0' = "\end{document}" in `newtotrows'  
		}
		if `nopagen' {
			local row = `texheadrow' - 1 - `pretty'
			replace `pad0' = "\thispagestyle{empty}" in `row'
		}
		if `pretty' {
			local row = `texheadrow' - 1
			replace `pad0' = "\begin{center}" in `row'
			local row = `newtotrows' - `texfootrow' + 2
			replace `pad0' = "\end{center}"	in `row'
		}
		local row = `texheadrow'
		replace `pad0' = "\begin{tabular}{`vline'l`ccc'`vline'}" in `row'
		if (!`titleWide' | `cborder') & !`noborder' {
			replace `pad0' = `pad0' + " \hline" in `row'
		}
		local row = `newtotrows' - `texfootrow' + 1
		replace `pad0' = "\end{tabular}" in `row'
		
		outfile `vlist' `using' in 1/`newtotrows', `replace' runtogether
		
		* delete new rows created for TeX table, if any
		if `oldN' {
			keep in 1/`totrows'
		}
	} /* quietly */
end  /* end _texout */


********************************************************************************************


* ripped from outreg2 on Mar2009
program define _wordout, sortpreserve rclass
version 7.0
* based on version 0.9 4oct01 by john_gallup@alum.swarthmore.edu
	if "`1'" == "using" {
		syntax using/ [, wordFile(string) Landscape Fragment noPRetty	/*
		*/	Fontsize(numlist max=1 >0) noBorder Cellborder			/*
		*/	Appendpage PAgesize(string)						/*
		*/	Lmargin(numlist max=1 >=0.5) Rmargin(numlist max=1 >=0.5) 	/*
		*/	Tmargin(numlist max=1 >=0.5) Bmargin(numlist max=1 >=0.5) 	/*
		*/	replace Fast]
		
		if "`fast'" == "" {preserve}
		loadout using `"`using'"', clear
		local numcol	= `r(numcol)'
		local titleWide  = `r(titleWide)'
		local headBorder = `r(headBorder)'
		local bottomBorder	= `r(bottomBorder)'
		local totrows	= _N
		local varname "v1"
		unab statvars : v2-v`numcol'
	}
	else {
		syntax varlist using/, titleWide(int) headBorder(int) bottomBorder(int)		/*
		*/	[wordFile(string) TOtrows(int 0) Landscape Fragment noPRetty	/*
		*/	Fontsize(numlist max=1 >0) noBorder Cellborder				/*
		*/	Appendpage PAgesize(string)							/*
		*/	Lmargin(numlist max=1 >=0.5) Rmargin(numlist max=1 >=0.5)		/*
		*/	Tmargin(numlist max=1 >=0.5) Bmargin(numlist max=1 >=0.5)		/*
		*/	replace]
		if `totrows'==0 {
			local totrows = _N
		}
		local numcols : word count `varlist'
		gettoken varname statvars : varlist
		local fast 1
	}
	
	local colhead1 = `titleWide' + 1
	local strow1 = `headBorder' + 1
	
	
	*** replace if equation column present
	local hack 0
	count if v1=="EQUATION"
	if `r(N)'~=0 {
		* use v2 instead
		replace v1 = v2 in `=`bottomBorder'+1'/`totrows'
		replace v2 = "" in `=`bottomBorder'+1'/`totrows'
		
		* change the string length
		gen str5 myvar =""
		replace myvar =v2
		drop v2
		ren myvar v2
		order v1 v2
		
		local hack 1
	}
	
	/* if file extension specified in `"`using'"', replace it with ".rtf" for output
	local next_dot = index(`"`using'"', ".")
	if `next_dot' {
		local using = substr(`"`using'"',1,`=`next_dot'-1')
	}
	*/
	
	if `"`wordFile'"'=="" {
		local endName "rtf"
	}
	else {
		local endName "`wordFile'"
	}
	
	local using `"using "`using'.`endName'""'
	return local documentname `"`using'"'
	
	if "`fontsize'" == "" {
		local fontsize "12"
	}
	
	local lscp = ("`landscape'" != "") 
	local pretty	= ("`pretty'" == "")
	local cborder  = ("`cellborder'" != "")
	local noborder = ("`border'" != "")
	local stdborder = (!`noborder' & !`cborder')
	local nopagen  = ("`pagenum'" != "")
	local nofrag	= ("`fragment'" == "")
	
	
	if `cborder' & !`noborder' {
		di in red "may not specify both cellborder and noborder options"
		exit 198
	}
	
	* reformat "R-squared" and italicize "t" or "z"
	if `pretty' {
		quietly {
			replace `varname'= subinword(`varname',"R-squared", "{\i R{\super 2}}", 1) in `strow1'/`bottomBorder'
			replace `varname'= subinstr(`varname'," t stat", " {\i t} stat", 1) in `bottomBorder'/`totrows'
			replace `varname'= subinstr(`varname'," z stat", " {\i z} stat", 1) in `bottomBorder'/`totrows'
		}
	}
	
	* font sizes in points*2
	local font2 = int(`fontsize'*2)
	if `pretty' {
		/* make title fonts large; notes & t stats small */
		local fslarge = "\fs" + string(int(`font2' * 1.2))
		local fsmed	= "\fs" + string(`font2')
		local fssmall = "\fs" + string(int(`font2' * 0.8))
		local sa0 "\sa0"	/* put space after t stats rows */
		local gapsize = int(`fontsize'*0.4*20)  /* 40% of point size converted to twips */
		local sa_gap "\sa`gapsize'"
	}
	else {
		local fs0 = "\fs" + string(`font2')
	}
	
	local onecolhead = (`headBorder' - `titleWide' == 1)
			/* onecolhead = true if only one row of column headings */
	*local onecolhead 0
	if `stdborder' {
		if !`onecolhead' {
			* runs here
			*local trbrdrt "\clbrdrt\brdrs"			/* table top is overlined */
			*local trbrdrt "\trbrdrt\brdrs"			/* table top is overlined */
			
			local clbrdr_uo "\clbrdrt\brdrs"			/* cells are overlined */
			local clbrdr_ul "\clbrdrb\brdrs"			/* cells are underlined */
		}
		else {
			local clbrdr_both "\clbrdrt\brdrs\clbrdrb\brdrs"	/* cells are over- and underlined */
			local clbrdr_uo "\clbrdrt\brdrs"				/* cells are overlined */
			local clbrdr_ul "\clbrdrb\brdrs"				/* cells are underlined */
			
			*local clbrdr_ul "\clbrdrt\brdrs\clbrdrb\brdrs"		/* cells are over- and underlined */
		}
		local trbrdrb "\trbrdrb\brdrs"
	}
	if `cborder' {
		/* if !cborder then clbrdr is blank */
		local clbrdr "\clbrdrt\brdrs\clbrdrb\brdrs\clbrdrl\brdrs\clbrdrr\brdrs"
	}
	
	* figure out max str widths to make cell boundaries
	* cell width in twips = (max str width) * (pt size) * 12
	* (12 found by trial and error)
	local twipconst = int(`fontsize' * 12 )
	tempvar newvarname
	qui gen str80 `newvarname' = `varname' in `strow1'/`bottomBorder'
	
	local newvarlist "`newvarname' `statvars'"
	qui compress `newvarlist'
	local cellpos = 0
	foreach avar of local newvarlist {
		local strwidth : type `avar'
		local strwidth = subinstr("`strwidth'", "str", "", .)
		local strwidth = `strwidth' + 1  /* add buffer */
		local cellpos = `cellpos' + `strwidth'*`twipconst'

		* hacking
		if `hack'==1 & "`avar'"=="`newvarname'" & `cellpos'<1350 {
			local cellpos=1350 
		}
		local clwidths "`clwidths'`clbrdr'\cellx`cellpos'"
		
		* put in underline at bottom of header in clwidth_ul
		local clwidth_ul "`clwidth_ul'`clbrdr_ul'\cellx`cellpos'"
		
		* put in overline
		local clwidth_ol "`clwidth_ol'`clbrdr_uo'\cellx`cellpos'"
		
		* put in both
		local clwidth_both "`clwidth_both'`clbrdr_both'\cellx`cellpos'"
	}
	
	if `stdborder' {
		if `onecolhead' {
			local clwidth1 "`clwidth_ul'"
		}
		else {
			local clwidth1 "`clwidths'"
			local clwidth2 "`clwidth_ul'"
		}
		local clwidth3 "`clwidths'"
	}
	else{
		local clwidth1 "`clwidths'"
	}
	
	* statistics row formatting
	tempvar prettyfmt
	qui gen str12 `prettyfmt' = ""  /* empty unless `pretty' */
	if `pretty' {
		* make stats 2-N small font
		tempvar st2_row last_st
		quietly {
			gen byte `st2_row' = 0
			replace `st2_row' = (trim(`varname') == "") in `strow1' / `bottomBorder'	 /* only stats 2+ */
			gen byte `last_st' = (`st2_row' & `varname'[_n+1] != "")			 /* last stats row */
			replace `prettyfmt' = "`sa0'" in `strow1' / `bottomBorder'
			replace `prettyfmt' = "`sa_gap'"  if `last_st' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fsmed'" if !`st2_row' in `strow1' / `bottomBorder'
			replace `prettyfmt' = `prettyfmt' + "`fssmall'"  if `st2_row' in `strow1' / `bottomBorder'
		}
	}
	
	* create macros with file write contents
	
	forvalues row = `colhead1'/`bottomBorder' { 
		local svarfmt`row' `"(`prettyfmt'[`row']) "\ql " (`varname'[`row']) "\cell""'
		foreach avar of local statvars {
			local svarfmt`row' `"`svarfmt`row''"\qc " (`avar'[`row']) "\cell""' 
		}
		local svarfmt`row' `"`svarfmt`row''"\row" _n"'
	}
	
	* write file
	tempname rtfile
	file open `rtfile' `using', write `replace'
	file write `rtfile' "{\rtf1`fs0'" _n  /* change if not roman: \deff0{\fonttbl{\f0\froman}} */
	
	* title
	if `titleWide' {
		file write `rtfile' "\pard\qc`fslarge'" _n
		forvalues row = 1/`titleWide' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* The top line
	if `onecolhead' {
		file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth_both'" _n
		file write `rtfile' `svarfmt1' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth_both'" _n
	}
	else {
		file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth_ol'" _n
		*file write `rtfile' "\trowd\trgaph75\trleft-75\intbl\trqc`fsmed'`trbrdrt'`clwidth1'" _n
		local headBorder_1 = `headBorder' - 1
		
		* write header rows 1 to N-1
		forvalues row = `colhead1'/`headBorder_1' {
			file write `rtfile' `svarfmt`row''
			* turn off the overlining the first time it's run
			file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
		}
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth2'" _n
		
		* write last header row
		file write `rtfile' `svarfmt`headBorder''
	}
	
	local bottomBorder_1 = `bottomBorder' - 1
	/* turn off cell underlining */
	file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`clwidth3'" _n
	
	* table contents
	forvalues row = `strow1'/`bottomBorder_1' {
		file write `rtfile' `svarfmt`row''
	}
	
	if `stdborder' {
		/* write last row */
		*file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidths'" _n
		* make it underline
		file write `rtfile' "\trowd\trgaph75\trleft-75\trqc`trbrdrb'`clwidth_ul'" _n
		file write `rtfile' `svarfmt`bottomBorder''
	}
	
	/* write notes rows */
	if `bottomBorder' < `totrows' {
		local noterow1 = `bottomBorder' + 1
		file write `rtfile' "\pard\qc`fssmall'" _n
		forvalues row = `noterow1'/`totrows' {
			file write `rtfile' (`varname'[`row']) "\par" _n
		}
	}
	
	* write closing curly bracket
	file write `rtfile' "}"
end  /* end _wordout */


********************************************************************************************


* ripped from outreg2 on Mar2009
program define _xmlout
version 7.0

* invisible to Stata 7
local Version7 ""
cap local Version7 `c(stata_version)'

if "`Version7'"=="" {
	* it is version 7
	*noi di in yel "limited functions under Stata 7"
}
else if `Version7'>=8.2 {
	version 8.2
}

* emulates the output produced by xmlsave:
* xmlsave myfile, replace doctype(excel) legible

syntax using/ [, excelFile(string) LEGible noNAMes titleWide(integer 0) /*
	*/ headBorder(integer 10) bottomBorder(integer 10)  ]

* assumes all columns are string; if numbers, then the format needs to be checked

*local legible legible

if "`legible'"=="legible" {
	local _n "_n"
}

tempname source saving

if `"`excelFile'"'=="" {
	local endName "xml"
}
else {
	local endName "`excelFile'"
}
	
local save `"`using'.`endName'"'

*file open `source' using `"`using'"', read
file open `saving' using `"`save'"', write text replace

*file write `saving' `"`macval(line)'"'
file write `saving' `"<?xml version="1.0" encoding="US-ASCII" standalone="yes"?>"' `_n'
file write `saving' `"<?mso-application progid="Excel.Sheet"?>"' `_n'
file write `saving' `"<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:o="urn:schemas-microsoft-com:office:office""' `_n'
file write `saving' `" xmlns:x="urn:schemas-microsoft-com:office:excel""' `_n'
file write `saving' `" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet""' `_n'
file write `saving' `" xmlns:html="http://www.w3.org/TR/REC-html40">"' `_n'
file write `saving' `"<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">"' `_n'
file write `saving' `"<Author></Author>"' `_n'
file write `saving' `"<LastAuthor></LastAuthor>"' `_n'
file write `saving' `"<Created></Created>"' `_n'
file write `saving' `"<LastSaved></LastSaved>"' `_n'
file write `saving' `"<Company></Company>"' `_n'
file write `saving' `"<Version></Version>"' `_n'
file write `saving' `"</DocumentProperties>"' `_n'
file write `saving' `"<ExcelWorkbook  xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectStructure>False</ProtectStructure>"' `_n'
file write `saving' `"<ProtectWindows>False</ProtectWindows>"' `_n'
file write `saving' `"</ExcelWorkbook>"' `_n'
file write `saving' `"<Styles>"' `_n'

* styles
file write `saving' `"<Style ss:ID="Default" ss:Name="Normal">"' `_n'
file write `saving' `"<Alignment ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"<Font/>"' `_n'
file write `saving' `"<Interior/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Protection/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bold & (center)
file write `saving' `"<Style ss:ID="s1">"' `_n'
*file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<Font ss:Bold="1" ss:Size='12'/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border & center
file write `saving' `"<Style ss:ID="s21">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* main body (no border) & center
file write `saving' `"<Style ss:ID="s22">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s23">"' `_n'
file write `saving' `"<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* goldfish (no border, left-justified)
file write `saving' `"<Style ss:ID="s24">"' `_n'
file write `saving' `"<NumberFormat/>"' `_n'
file write `saving' `"</Style>"' `_n'

* top border
file write `saving' `"<Style ss:ID="s31">"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

* main body (no border)
file write `saving' `"<Style ss:ID="s32">"' `_n'
file write `saving' `"<Borders/>"' `_n'
file write `saving' `"</Style>"' `_n'

* bottom border & center
file write `saving' `"<Style ss:ID="s33">"' `_n'
file write `saving' `"<Borders>"' `_n'
file write `saving' `"<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>"' `_n'
file write `saving' `"</Borders>"' `_n'
file write `saving' `"</Style>"' `_n'

file write `saving' `"</Styles>"' `_n'
file write `saving' `"<Names>"' `_n'
file write `saving' `"</Names>"' `_n'
file write `saving' `"<Worksheet ss:Name="Sheet1">"' `_n'

* set up file size
qui describe, short

local N=_N
local tableN `N'

if "`names'"~="nonames" {
	* add one if variable names are to be inserted
	local tableN=`N'+1
}
else {
	* add one for the look
	local tableN=`N'+1
}

file write `saving' `"<Table ss:ExpandedColumnCount="`r(k)'" ss:ExpandedRowCount="`tableN'""' `_n'
file write `saving' `" x:FullColumns="1" x:FullRows="1">"' `_n'

* should be tostring and format here if dealing with numbers
	
	ds8
	
	* write the variable names at the top or empty row
	if "`names'"~="nonames" {
		file write `saving' `"<Row>"' `_n'
		foreach var in  `dsVarlist' {
			if "`Version7'"~="" {
				file write `saving' `"<Cell ss:StyleID="s1"><Data ss:Type="String">`macval(var)'</Data></Cell>"' _n
			}
			else {
				file write `saving' `"<Cell ss:StyleID="s1"><Data ss:Type="String">`var'</Data></Cell>"' _n				
			}
		}
		file write `saving' `"</Row>"' `_n'
	}
	else {
		file write `saving' `"<Row>"' `_n'
		file write `saving' `"</Row>"' `_n'
	}

* title
local count `titleWide'
local total 1
while `count'~=0 {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`total') n(`N') style(`" ss:StyleID="s1""') style1(`" ss:StyleID="s1""')
	local count=`count'-1
	local total=`total'+1
}

* top border
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""')
	local total=`total'+1
}

* ctitle
local count=`total'
forval num=`count'/`headBorder' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""')
	local total=`total'+1
}

* top border (closes ctitle)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s21""') style1(`" ss:StyleID="s31""')
	local total=`total'+1
}

* body
local count=`total'
forval num=`count'/`=`bottomBorder'-1' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s22""') style1(`" ss:StyleID="s32""')
	local total=`total'+1
}

* bottom border (closes body)
local count=`total'
forval num=`count'/`count' {
	xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s23""') style1(`" ss:StyleID="s33""')
	local total=`total'+1
}

* goldfish
if `N'>`total' {
	local count=`total'
	forval num=`count'/`N' {
		xmlstack, saving(`saving') dsVarlist(`dsVarlist') num(`num') n(`N') style(`" ss:StyleID="s24""') style1(`" ss:StyleID="s24""') 
		local total=`total'+1
	}
}

/*
forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`style'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			file write `saving' `"<Cell`style'><Data ss:Type="String">`stuff'</Data></Cell>"' `_n'
		}
	}
	file write `saving' `"</Row>"' `_n'
}
*/

file write `saving' `"</Table>"' `_n'
file write `saving' `"<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">"' `_n'
file write `saving' `"<ProtectedObjects>False</ProtectedObjects>"' `_n'
file write `saving' `"<ProtectedScenarios>False</ProtectedScenarios>"' `_n'
file write `saving' `"</WorksheetOptions>"' `_n'
file write `saving' `"</Worksheet>"' `_n'
file write `saving' `"</Workbook>"' `_n'

* close out with the last line
*file write `saving' _n
*file close `source'

file close `saving'

end /* _xmlout */


********************************************************************************************

* ripped from outreg2 on Mar2009
program define xmlstack

syntax, saving(string) dsVarlist(string) num(numlist) n(numlist) style(string) style1(string)

local N `n'

*forval num=1/`N' {
	
	file write `saving' `"<Row>"' `_n'
	
	local count 0
	
	*foreach var in  `=r(varlist)' {
	foreach var in  `dsVarlist' {
		
		if `count'==0 {
			local STYLE `"`style1'"'
		}
		else {
			local STYLE `"`style'"'
		}
		
		*local stuff `=`var'[`num']'
		local stuff=`var' in `num'
		
		local stuff : subinstr local stuff "<" "&lt;", all
		local stuff : subinstr local stuff ">" "&gt;", all
		
		* the main body
		if "`Version7'"~="" {
			file write `saving' `"<Cell`STYLE'><Data ss:Type="String">`macval(stuff)'</Data></Cell>"' `_n'
		}
		else {
			file write `saving' `"<Cell`STYLE'><Data ss:Type="String">`stuff'</Data></Cell>"' `_n'
		}
		
		local count=`count'+1
	}
	file write `saving' `"</Row>"' `_n'
*}

end /* xmlstack */


********************************************************************************************


*** ripped from outreg2 Mar 2009
program define ds8
	* get you the list of variable like -ds- does for version 8
	version 7.0
	qui ds
	if "`r(varlist)'"=="" {
		local dsVarlist ""
		foreach var of varlist _all {
			local dsVarlist "`dsVarlist' `var'"
		}
		c_local dsVarlist `dsVarlist'
	}
	else {
		c_local dsVarlist `r(varlist)'
	}
end


********************************************************************************************


program define stringMaker
	* makes a string out variables
	tempvar temp
	foreach var of varlist _all {
		cap confirm string var `var'
		if _rc {
			* not a string
			gen str2 `temp'=""
			replace  `temp' = string(`var')
			move `var' `temp'
			drop `var'
			ren `temp' `var'
		}
	}
end


********************************************************************************************


* cdout 1.0.1 Apr2009 by roywada@hotmail.com
* opens the current directory for your viewing pleasure

* the following disabled 14oct2009: cap winexec cmd /c start .
* displays "current directory" instead of cdout or the folder location
* displays dir" instead of cdout or the folder location

program define _cdout
cap version 7.0

*cap winexec cmd /c start .
*cap !start cmd /c start .

if _rc~=0 {
        * version 6 or earlier
        di `"{stata `"cdout"':dir}"'
}
else {
        * invisible to Stata 7
        local Version7
        local Version7 `c(stata_version)'
        
        if "`Version7'"=="" {
                * it is version 7 or earlier
                di `"{stata `"cdout"':dir}"'
        }
        else if `Version7'>=8.0 {
                version 8.0
                di `"{browse `"`c(pwd)'"':dir}"'
        }
}

end


exit

* version 1.0.1 Mar2009
replace option added per Kit B.

* version 1.0.2 Mar2009
tostring replace with stringMaker

* version 1.0.3 Mar2009
_texout now accepts single column
automatically formatted digits
auto( )
noauto
dec( )

* version 1.0.4 26oct2009
midborder option
nopretty for _texout fixed
_cdout inserted






