**************************************
* This is corrtex.ado beta version
* Date : 8 Nov 06
* Version : 1.1
* 
* Questions, comments and bug reports : 
* couderc@univ-paris1.fr
*
* Version history :
* v1.1 (8 Nov 2006) : feature additions
*	- nbobs options + rewriting of the table writing procedure (speed up...)
* v1.02 (21 oct 2006): feature additions
*       - output in the result window (noscreen option added)
* v1.01 (21 Aug 2006): Bug fixes and feature additions
*	- French option added
*	- Bugs with landscape fixed
*	- corrtex.hlp added (smcl format)
* v1.00 (14 Aug 2006): Initial release
**************************************

set more off
cap prog drop corrtex
program corrtex, byable(recall)
version 8.0

syntax [varlist(default=none)] [if] [in], [FR] [LANDscape] [LONGtable] [FILE(string)] ///
[Append] [Replace] [DIGits(integer 3)] [Sig] [CASEwise] [PLacement(string)] [TITle(string)] ///
[KEY(string)] [NA(string)] [NOscreen] [NBobs]

********************
* Verifying syntax
********************
if "`varlist'"=="" {
	di as error "varlist required"
	exit
}
if "`file'"=="" {
	di as error "An output file must be specified"
	exit
}
if `digits'<0 | `digits' >20 {
	di as error "DIGits must be between 0 and 20"
	exit
}
if "`append'"!="" & "`replace'"!="" {
	di as error "APPEND or REPLACE (not both)"
	exit
}
tempvar touse
mark `touse' `if' `in'
if _by() {
	qui replace `touse'=0 if `_byindex'!=_byindex()
}
tempname fich

************************
* Internationalization
************************

if "`fr'"!="" {
	local titre="Tableau de corrélations croisées"
	local headlong="... Suite du tableau \thetable{}"
	local footlong="Suite page suivante..."
	set dp comma
}
if "`fr'"=="" {
	local titre="Cross-correlation table"
	local headlong="... table \thetable{} continued"
	local footlong="Continued on next page..."
}

**********************
* setting file extension
**********************

if _byindex()>1 {
	local replace=""
	local append="append"
}
tokenize "`file'", parse(.)
if "`3'"=="" {
	local file="`1'.tex"
}

file open `fich' using `file' ,write `append' `replace'  text

***********************
* Formats
***********************

local width=`digits'+2
local cformat "%`width'.`digits'f"
local n_rows:list sizeof varlist
local n_cols: list sizeof varlist
local tablelong=" l "	
forvalues cols=1/`n_cols' {
    local tablelong="`tablelong'" + " c "	
}

************************
* Table heads
************************

if "`placement'"=="" {
	local placement="htbp"
}

if _by() {
	local by=_byindex()
}

local z="`na'"
if "`na'"!="" {
	local na2="na(`z')"
}

if "`title'"=="" {
	local title="`titre'"
}

if "`key'"=="" {
	local key="corrtable"
}

if _by()!=0 {
	local title="`title' `by'"
	local key="`key'`by'"
}

**************
* Casewise option
**************

if "`casewise'"~="" {
	marksample touse
	if "`if'"~="" {
		local if="`if'" + " & \`touse'"
	}
	else {
		local if "if \`touse'"
	}
}	

***************
* Table building
***************

* Headers

if "`landscape'"!="" {
		file write `fich' "\begin{landscape} " _n
	}
if "`longtable'"=="" {
	file write `fich' "\begin{table}[`placement']\centering \caption{`title'\label{`key'}}" _n
	file write `fich' "\begin{tabular}{`tablelong'}\hline\hline" _n
}

if "`longtable'"!="" {
	local llong=`n_cols'+1
	file write `fich'  _n "\begin{center}"_newline "\begin{longtable}{`tablelong'}" _n
	file write `fich' "\caption{`title'\label{`key'}}\\\ " _newline " \hline\hline" _n
	file write `fich' "\endfirsthead" _n
	file write `fich' "\multicolumn{`llong'}{l}{\emph{`headlong'}}" _newline" \\\ \hline " _n
	file write `fich' "\endhead" _n
	file write `fich' "\hline" _n
	file write `fich' "\multicolumn{`llong'}{r}{\emph{`footlong'}}\\\" _n
	file write `fich' "\endfoot" _n
	file write `fich' "\hline\hline"  _n
	file write `fich' "\endlastfoot" _n
}

* First line (variable names)
file write `fich' "\multicolumn{1}{c}{Variables} " _char(38) 
local compt=1
foreach var of local varlist{
	local lab: variable label `var'
	if `"`lab'"'=="" {
		local lab `var'
	}
	latres ,name(`lab')
	local lab="$nom"
	file write `fich' "`lab'" 
	if `compt'<`n_cols' {
		file write `fich' _char(38) 
	}
	local compt=`compt'+1
}
file write `fich' _char(92) _char(92) " \hline" _n

* Next lines (one row at a time, starting with the variable name and then the values)

forvalues row=1/`n_rows' {
	* Computation of correlations, p val, etc.
	forvalues col=1/`row' {     /*only doing the bottom half of the matrix*/
		local var1:word `row' of `varlist'
		local var2:word `col' of `varlist'
		qui corr(`var1' `var2') `if' `in'
		local val_`row'`col'=r(rho)
		local n_`row'`col'=`r(N)'
		local p_`row'`col'=min(tprob(r(N)-2,r(rho)*sqrt(r(N)-2)/sqrt(1-r(rho)^2)),1)
	} 
}

forvalues row=1/`n_rows' {
	* Table

	* First row : variable names
	
	local var: word `row' of `varlist'
	local lab: variable label `var'
	if `"`lab'"'==""{
		local lab `var'
	}
	latres ,name(`lab')
	local lab="$nom"
	file write `fich' "`lab'"
	
	* Next rows
	forvalues col=1/`row' {     /*only doing the bottom half of the matrix*/
		if `col'<=(`n_cols') {
			file write `fich' _char(38) 
		}
		file write `fich' `cformat' (`val_`row'`col'') 
	}
	file write `fich' _char(92) _char(92) _n
	if "`sig'"~="" {
		forvalues col=1/`row' {
			if "`row'"=="`col'" {
				if `col'<`n_cols' {
					file write `fich' " " _char(38) 
				}
			}
			else {
				if `col'<`n_cols' {
					file write `fich' _char(38) 
				}
				file write `fich' "(" `cformat' (`p_`row'`col'') ")"
			}
		}
		file write `fich' _char(92) _char(92) _n
	}
	if "`nbobs'"~="" & "`casewise'"=="" {
		file write `fich' "Nb. Obs."
		forvalues col=1/`row' {
			if "`row'"=="`col'" {
				if `col'<`n_cols' {
					file write `fich' " " _char(38) 
				}
			}
			else {
				if `col'<`n_cols' {
					file write `fich' _char(38) 
				}
				file write `fich' %5.0f (`n_`row'`col'')
			}
		}
		file write `fich' _char(92) _char(92) _n
	}
}

* Footers
di "`n_`row'`col''"
if "`longtable'"==""{
	file write `fich' "\hline \hline " _newline " \end{tabular}" _newline "\end{table}" _newline
}
if "`longtable'"!=""{
	file write `fich' "\end{longtable}"_newline "\end{center}" _newline
}
if "`nbobs'"!="" & "`casewise'"!="" {
	file write `fich' "Nb. obs. : " %5.0f (`n_11') _newline
}
if "`landscape'"!="" {
	file write `fich' "\end{landscape} _newline"
}

***************
* End of program
***************

file close `fich'
if "`fr'"!="" {
	set dp period
}
if "`noscreen'"=="" {
	di ""	
	type `file'
	di ""
}
di as result " Output writted successfully in file : " as txt "`file'"
end

***************************************************
*LaTeX special characters search and replace routine
***************************************************

cap prog drop latres
program define latres
version 7.0
syntax ,name(string) [FRE] [sortie(string) nom]

if "`sortie'"=="" {
	local sortie="nom"
}
local cr1="_" 
local crc1="\_"
local cr2="\"
local crc2="$\backslash$ "
local cr3="$"
local crc3="\symbol{36}"
local cr4="{"
local crc4="\{"
local cr5="}"
local crc5="\}"
local cr6="%"
local crc6="\%"
local cr7="#"
local crc7="\#"
local cr8="&"
local crc8="\&"
local cr9="~"
local crc9="\~{}"
local cr10="^"
local crc10="\^{}"
local cr11="<"
local crc11="$<$ "
local cr12=">"
local crc12="$>$ "
local cr13="."
local crc13=","
local nom="`name'"
local t=length("`nom'")
local rg=1
local mot2=""
while `rg'<=`t' {
	local let`rg'=substr("`nom'",`rg',1)
	local num=1
	while `num'<=12 {
		if "`let`rg''"=="`cr`num''" {
			local let`rg'="`crc`num''"
		}
		local num=`num'+1
	}
	if "`let`rg''"=="" {
		local mot2="`mot2'"+" " 
	}
	else if "`let`rg''"!="" {
		local mot2="`mot2'"+"`let`rg''"
	}		
	local rg=`rg'+1
}
global `sortie'="`mot2'"
end
