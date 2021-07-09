*! -table1_mc_dta2docx - version 1.0 Mark Chatfield    2017-11-29

cap program drop table1_mc_dta2docx

program define table1_mc_dta2docx, sclass
version 15.1
syntax using/ [, PAGEsize(string) LANDscape TABLENUMber(string) TABLETItle(string) FOOTnote(string) font(string asis) datafont(string asis) datahalign(string) tabopts(string asis) REPLACE APPEND FINSIDE ]
local Dapa "`s(Dapa)'"  //  r() result not available lower down this program. perhaps because putdocx is a return command
local origDapa "`s(Dapa)'"

*Defaults
if `"`font'"' == `""' local font `" "Calibri", 11 "'
if `"`datafont'"' == `""' local datafont `" "Calibri", 10 "'
if `"`datahalign'"' == `""' local datahalign "center"
*"Courier New",9    


capture putdocx clear
if `"`pagesize'"' !=`""' local pagesize `"pagesize(`pagesize')"'
putdocx begin, `pagesize' `landscape' font(`font')


***Main table
if `"`tabletitle'"' !=`""' | `"`tablenumber'"' !=`""' {
	putdocx paragraph
	putdocx text (`"`tablenumber' "'), bold	
	putdocx text (`"`tabletitle'"')
}

cap ds N_*
if _rc == 0 local vlistN "N_*"
cap ds m_*
if _rc == 0 local vlistm "m_*"
cap ds _column*
if _rc == 0 local vlist_c "_column*"
tempvar a_var
qui gen `a_var' = ""
qui ds `a_var' `vlistN' `vlistm' `vlist_c', not
local vlist "`r(varlist)'"
local nvars = wordcount(r(varlist))
if "`finside'" != "" & `"`Dapa'"' != `""' {
	local note1 = `" note(`"`Dapa'"') "'
	local Dapa ""
	if `"`footnote'"' != `""' {
		local note2 = `"note(`"`footnote'"')"'
		local footnote = ""
	}
}

putdocx table T1 = data(`vlist'), layout(autofitcontents) ///
 border(start, nil) border(insideH, nil) border(insideV, nil) border(end, nil) border(bottom, nil) `note1' `note2' `tabopts' 
qui count
local nrows = r(N)
putdocx table T1(1,.), bold
putdocx table T1(2,.), bold border(bottom)
putdocx table T1(`nrows',.), border(bottom)
*above works nicely if tabopts(note()) option used or not used. Doesn't work if tabopts(title()) is used.


**Aligning columns
if `"`datahalign'"' != `""' {
	*center/right align columns after the first one 
	putdocx table T1(., 2/`nvars'), halign(`datahalign') 

	* but make sure level (if it exists) & pvalue column(s) are left aligned
	local i = 1
	foreach v of local vlist {
		if (substr("`v'", 1,6) == "pvalue") | ("`v'" == "level")  putdocx table T1(.,`i'), halign(left)
		local i = `i' + 1
	}
}


**Vertically align contents of all cells to be in the center (rather than at the top[default])
putdocx table T1(1/`nrows',.), valign(center)


**Apply datafont for rows 3 to end
putdocx table T1(3/`nrows',.), font(`datafont')


**footnote(s) - outside the table
putdocx paragraph
if `"`footnote'"' != `""' | `"`Dapa'"' != `""' {
		putdocx text ("`Dapa'")
	if `"`footnote'"' != `""' {
		if `"`Dapa'"' != `""' putdocx text (""), linebreak
		putdocx text (`"`footnote'"')
	}
}



***Table of records used and/or not used
if "`vlistN'`vlistm'" != "" {
	putdocx text (""), linebreak(3)
	local text "N_ ... #records used,   m_ ... #records not used:"
	if "`vlistN'" == "" local text "#records not used:"
	if "`vlistm'" == "" local text "#records used:"
	if "`vlistN'" != "" & "`vlistm'" != "" {
		local ending `"  & factor!=" "   "'
		local vnames "varnames"
	}
	putdocx text ("`text'")
	putdocx table T2 = data(factor `vlistN' `vlistm') if factor!="" & !(substr(factor,1,3) == "   ") `ending' , `vnames' ///
	 layout(autofitcontents) border(start, nil) border(insideH, nil) border(insideV, nil) border(end, nil) 
	putdocx table T2(1,.), border(bottom) bold


	*Vertically align contents of all cells to be in the center (rather than at the top[default])
	qui count if factor!="" & !(substr(factor,1,3) == "   ")
	local nrows = r(N) 
	putdocx table T2(1/`nrows',.), valign(center) 

	*makes this cell blank
	putdocx table T2(1,1) = ("")

	*right align columns after the first in T2
	qui ds factor `vlistN' `vlistm'
	local nvars = wordcount(r(varlist))
	putdocx table T2(., 2/`nvars'), halign(right) 
}

putdocx save "`using'", `replace' `append'

di as text "file " "`using'" " saved"

sreturn local Dapa "`origDapa'"

end


/*  Examples:
 sysuse auto, clear
 table1_mc, by(foreign) vars(price conts \ price contln %5.0f %4.2f \ weight contn %5.0f \ rep78 cate) clear
 table1_mc_dta2docx using "N:\example Table 1.docx", replace 

 sysuse auto, clear
 table1_mc, by(foreign) vars(price conts \ price contln %5.0f %4.2f \ weight contn %5.0f \ rep78 cate) clear
 drop pvalue   // to prevent a pvalue column appearing in the main table in the coming .docx file
 drop N_*   // to prevent the table of records used and not used appearing in the .docx file
 *sreturn clear
 table1_mc_dta2docx using "N:\example Table 1.docx", replace tablenumber("Table 1.") tabletitle("Characteristics by group.") footnote("BMI = Body Mass Index.") 
 *tabopts(note("z ")) 
 finside 
*/
