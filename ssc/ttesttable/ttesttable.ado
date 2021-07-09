capture program drop ttesttable
*! version 1.3 11Feb2015 F. Chavez Juarez
program define ttesttable , rclass 
version 9.2
syntax varlist(min=2 max=2 ) [if] [in] [, UNEQual TEX(str) HTML(str) XML(str) PREtable(str) POSTtable(str) force Reference(str) Format(str) TEXFormat(str)] 
marksample touse, strok
preserve
qui: keep if `touse'
tokenize `varlist'
tempvar GV
gen `GV'=`2'
capture: tostring `GV', replace

qui: levelsof `GV', local(levels)
qui: tab `GV'
local K=r(r)

if("`reference'"!=""){
		local REFS=wordcount("`reference'")
		if((`REFS'>10 | `K'>100) & "`force'"==""){
			di as error "Too many categories (max allowed = 10 (in the reference option) and 100 in the variable of interest)." _n "Make sure you use a categorical variable for the groups or use the option 'force'"
			exit
		}
}

** CHECK if not excessively many groups
if(`K'>10 & "`force'"=="" & "`reference'"=="") {
	di as error "Too many categories (max allowed = 10)." _n "Make sure you use a categorical variable for the groups or use the option 'force'"
	exit
	}

tempvar v1 v2
local stats="p t diff"

if("`reference'"==""){
foreach stat of local stats{
			matrix cttab_`stat'=J(`K',`K',.)
			matrix colname cttab_`stat'=`levels'
			matrix rowname cttab_`stat'=`levels'
		}
		local I=0

// Standard case

foreach i of local levels{
	local I=`I'+1
	local J=0
	foreach j of local levels{
	local J=`J'+1
	if ("`j'"<"`i'"){
			qui: g `v1'=`1' if `GV'=="`i'"
			qui: g `v2'=`1' if `GV'=="`j'"
			qui:ttest `v2'=`v1',unpaired `unequal'
			local pvalue=r(p)
			matrix cttab_p[`I',`J']=r(p)
			matrix cttab_t[`I',`J']=r(t)
			matrix cttab_diff[`I',`J']=(r(mu_1)-r(mu_2))
			
			drop `v1' `v2'
			}
		
	}
}
} //end reference==""
else{

foreach stat of local stats{
	
			matrix cttab_`stat'=J(`K',`REFS',.)
			matrix colname cttab_`stat'=`reference'
			matrix rowname cttab_`stat'=`levels'
		}

// With a reference group
	foreach i of local levels{
	local I=`I'+1
	local J=0
	
	
	foreach j of local reference{
	local J=`J'+1
	if("`i'"!="`j'"){
			qui: g `v1'=`1' if `GV'=="`i'"
			qui: g `v2'=`1' if `GV'=="`j'"
			qui:ttest `v2'=`v1',unpaired `unequal'
			matrix cttab_p[`I',`J']=r(p)
			matrix cttab_t[`I',`J']=r(t)
			matrix cttab_diff[`I',`J']=(r(mu_1)-r(mu_2))
			
			drop `v1' `v2'
			}
		
	}
}
	
}


** Start screen output (and TeX-output if required)**
// Load columns

if("`reference'"==""){
	qui: levelsof `GV', local(columns)
	}
else{
	local columns="`reference'"
	}
	
// Define formats
if("`format'"==""){
	local format="%6.3f"
	}
if("`texformat'"==""){
	local texformat="%6.3f"
	}
	
// Get space needed
local length=subinstr("`format'","%","",.)
local length=subinstr("`length'","g","",.)
local length=subinstr("`length'","f","",.)
local length=subinstr("`length'","e","",.)
local length=trim("`length'")
qui: tokenize "`length'", parse(".")

local length=`1'+`3'

local colstep=3+max(12,`length')




if("`tex'"!="")	{
	local numcols=colsof(cttab_p)
	capture file open tex using `tex'.tex, replace write
	file write tex "`pretable'" _n
	file write tex "\begin{tabular}{l*{`numcols'}{l}}" _n "\toprule" _n
	}
if("`html'"!=""){
	local numcols=colsof(cttab_p)
	capture file open html using `html'.html, replace write
	file write html "<html><h1>ttesttable output</h1>" _n "<style>" _n "table, tr, td{border: 1px solid black;border-collapse:collapse;padding:3px;}" _n
	file write html "table tr td:first-child,thead{ background-color:#DDDDDD;font-weight:bold;}</style>" _n "<table><tr>"
}
if("`xml'"!=""){
	local numcols=colsof(cttab_p)
	capture file open xml using `xml'.xml, replace write
	file write xml "<?xml version='1.0'?><?mso-application progid='Excel.Sheet'?>" _n "<ss:Workbook xmlns:ss='urn:schemas-microsoft-com:office:spreadsheet'>" _n 
	file write xml "<ss:Worksheet ss:Name='ttesttable'>" _n "<ss:Table>"
}


***
local i=0
di as text _newline "Cross-table of differences among groups with t-Test"
local xpos=floor((`colstep')/2)
if("`html'"!=""){
	file write html "<tr><thead><td></td>"
	}
if("`xml'"!=""){
	file write xml "<ss:Row><ss:Cell></ss:Cell>"
	}

foreach col of local columns{
local xpos=`xpos'+`colstep'
di _col(`xpos') as text  abbrev("`col'",9) _continue
if("`tex'"!=""){
	local value=abbrev("`col'",12)
	file write tex _col(`xpos') "& `value'"
	}
if("`html'"!=""){
	local value=abbrev("`col'",12)
	file write html "  <td>`value'</td>"
	}
if("`xml'"!=""){
	local value=abbrev("`col'",12)
	file write xml "<ss:Cell>" _n "<ss:Data ss:Type='String'>`value'</ss:Data>" _n "</ss:Cell>"
	}
}
if("`tex'"!=""){
	file write tex "\\\midrule" _n
	}
if("`html'"!=""){
	file write html "</tr></thead>" _n
}
if("`xml'"!=""){
	file write xml "</ss:Row>" _n
}
local xposmax=`xpos'+5
 di as text _newline "{hline `xposmax'}" 

foreach row of local levels{
	local i=`i'+1
	local j=0
	di as text abbrev("`row'",9) _continue
	if("`tex'"!=""){
		local value=abbrev("`row'",12)
		file write tex "`value'"
	} 
	if("`html'"!=""){
		local value=abbrev("`row'",12)
		file write html "<tr><td>`value'</td>"
	} 
	if("`xml'"!=""){
		local value=abbrev("`row'",12)
		file write xml "<ss:Row>" _n "<ss:Cell><ss:Data ss:Type='String'>`value'</ss:Data>" _n "</ss:Cell>"
	} 
	
	local xpos=0
	foreach col of local columns{	
	local j=`j'+1
	local xpos=`xpos'+`colstep'
		if(inrange(cttab_p[`i',`j'],0.05,0.1)) local stars="  *"
		if(inrange(cttab_p[`i',`j'],0.01,0.05)) local stars=" **"
		if(inrange(cttab_p[`i',`j'],0.0,0.01)) local stars="***"
		if(inrange(cttab_p[`i',`j'],0.1,1)) local stars="   "
		if(cttab_diff[`i',`j']!=.){
			di as result _col(`xpos') `format' cttab_diff[`i',`j'] _continue
			di as result  "`stars'" _continue
			if("`tex'"!="") {
				local value=cttab_diff[`i',`j']
				file write tex _col(`xpos') "& " `texformat' (`value') "`stars'"
				
				}
			if("`html'"!="") {
				local value=cttab_diff[`i',`j']
				file write html _col(`xpos') "<td>" `format' (`value') "`stars'</td>"
				
				}
			if("`xml'"!="") {
				local value=cttab_diff[`i',`j']
				file write xml _col(5) "<ss:Cell>" _n _col(10)"<ss:Data ss:Type='String'>" `format' (`value') "`stars'</ss:Data>" _n "</ss:Cell>"
				
				}
			}
		//else if(`i'==`j'){
		else if("`col'"=="`row'"){
		di as result _col(`xpos') %6.0f 0 _continue
		if("`tex'"!="") file write tex _col(`xpos') "& " %6.0f (0)
		if("`html'"!="") file write html _col(`xpos') "<td>" %6.0f (0) "</td>"
		if("`xml'"!="") file write xml _col(5) "<ss:Cell>" _n _col(10) "<ss:Data ss:Type='String'>" %6.0f (0) "</ss:Data>" _n "</ss:Cell>"
		}
		
	}
	di "" 
	if("`tex'"!="") file write tex  _col(`xposmax') "\\" _n
	if("`html'"!="") file write html  _col(`xposmax') "</tr>" _n
	if("`html'"!="") file write xml  _col(`xposmax') "</ss:Row>" _n
	}
 di as text  "{hline `xposmax'}" 
 di as text "Note: Differences defined as column-line"
 di as text "      * p<.1; ** p<.05; *** p<.01"
di as text  "{hline `xposmax'}" 

if("`tex'"!=""){
file write tex "\bottomrule\end{tabular}" _n
file write tex "`posttable'"_n
file close tex
}
if("`html'"!=""){
file write html "</table><p>Note: Differences defined as column-line<br>* p&#60;.1; ** p&#60;.05; *** p&#60;.01</p></html>"
file close html
}

if("`xml'"!=""){
file write xml "<ss:Row>" _col(5) "<ss:Cell>" _n _col(10) "<ss:Data ss:Type='String'>* p&#60;.1; ** p&#60;.05; *** p&#60;.01</ss:Data>" _n "</ss:Cell>" _n "</ss:Row>"
file write xml "</ss:Table>" "</ss:Worksheet>" "</ss:Workbook>"
file close xml
}
 

** Export matrices for use in return list **
local stats="p t diff"
foreach stat of local stats{
	return matrix `stat'=cttab_`stat'
	}
	
	


end

********************
*!
*!--------------------- VERSION HISTORY -------------------
*! Version 1.3:  Additional export possibilities: html and xml (for Excel)
*! Version 1.2:  Bugfix: dropping some unwanted display in the result window. 
*! Version 1.1:  options 'reference', 'format' and 'texformat' added.
*!               thanks to Sarah Necker for the idea
*! Version 1.0:  first release 
