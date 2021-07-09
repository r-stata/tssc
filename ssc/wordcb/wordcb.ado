*! 1.2 TCP 3 Dec 2019
// codebook to word
// Troy Payne
// Associate Director, Alaska Justice Information Center (AJiC)
// tpayne9@alaska.edu
 


cap program drop wordcb
program define wordcb

version 15.1, born(06jun2018)

syntax [varlist] using/ [, replace append VALues(integer 5) Freqonly(varlist) nodta  SORTFrequency(varlist) SORTValues(varlist)]


// input error checking
	// make sure freqonly vars were included in complete varlist spec
		foreach v of local freqonly {
			if strmatch("`varlist'", "*`v'*") == 0 {
				di as error "freqonly() vars must be included in main varlist"
				di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
				error 111
				}
			}
			
	// make sure sortf and sortv vars are included in complete varlist
		foreach v of local sortfrequency {
			if strmatch("`varlist'", "*`v'*") == 0 {
				di as error "sortfrequency() vars must be included in main varlist"
				di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
				error 111
				}
			}
		
		foreach v of local sortvalues {
			if strmatch("`varlist'", "*`v'*") == 0 {
				di as error "sortvalues() vars must be included in main varlist"
				di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
				error 111
				}
			}
	// make sure sortf and sortv vars are mutually exclusive
		foreach v of local sortfrequency {
			if strmatch("`sortvalues'", "*`v'*") == 1 {
				di as error "sortfrequency() vars and sortvalues() are mutually exclusive;" as result "  `v'" as error " is in both."
				di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
				error 111
				}
			}
		
		foreach v of local sortvalues {
			if strmatch("`sortfrequency'", "*`v'*") == 1 {
				di as error "sortfrequency() vars and sortvalues() are mutually exclusive;" as result "  `v'" as error " is in both."
				di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
				error 111
				}
			}
	// make sure values is > 0
		if `values' < 0 {
			di as error "values must be greater than zero."
			di as error "For more details, see {help ajicbook:on-line help for ajicbook}"
			error 111
			}
	
// add docx to filename if not present
	if !strmatch(`"`using'"', "*.docx*") local using = `"`using'.docx"'
	

preserve

// document header

	putdocx clear
	putdocx begin
if "`dta'" == "" {	
	putdocx paragraph, style(Heading1)
	
	 

	putdocx text (`"Codebook for `c(filename)'"'), smallcaps
	putdocx paragraph
	putdocx text (`"Last saved: `c(filedate)'"'), linebreak
	putdocx text ("obs:   ")
	putdocx text (`c(N)'), nformat(%-15.0gc) linebreak
	putdocx text ("vars:   "), 
	putdocx text (`c(k)'), nformat(%-15.0gc) linebreak
	local totalvars `c(k)'
	local datalabel : data label
	putdocx text (`"Data label: `datalabel'"')
	putdocx paragraph
	
	notes _dir notedir
	if strmatch("`notedir'", "_dta*") {
		notes _count notecount : _dta
		forval notenumber = 1/`notecount' {
			notes _fetch notefetch : _dta `notenumber'
			putdocx text (`"Data note `notenumber': `notefetch'"')
			putdocx paragraph
			}
		}
	
	putdocx pagebreak 
}
	putdocx save `"`using'"', `replace' `append'


	local progress 0
	local tableno 0
	putdocx begin


	di as text "Progress:"
	di as text _skip(6) "0%" _skip(6) "20%" _skip(6) "40%" _skip(6) "60%" _skip(6) "80%" _skip(6) "100%"  
	

	
	local tenpercent = round(wordcount(`"`varlist'"') / 10) 
	
	foreach varname of varlist `varlist' {
		local ++tableno
		local ++progress
		cap drop `uniq' `touse' `numgroup' `sumgroup' `rowhead'
		
		if `progress' == 1 di as result _skip(6) _dup(4) "." _continue
		else if mod(`progress',`tenpercent') == 0 di as result _dup(4) "." _continue
		
		// save every 100 vars
		if mod(`tableno',100) ==0 {
			putdocx save `"`using'"', append
			putdocx clear
			putdocx begin
			local tableno 1
			
			}

		
		putdocx paragraph
		
		// get variable type
			local vartype: type `varname'
		
	
		// get number of unique values, obs, format, and label
			marksample touse, strok novarlist
			tempvar uniq
			quietly bysort `varname': gen byte `uniq' = (`touse' & _n==_N)
			quietly su `uniq' , meanonly
			local uniquevals = `r(sum)'
			quietly count if missing(`varname')
			local numissing = `r(N)'
			local nobs = _N
			local varformat: format `varname'
			local varlab: variable label `varname'
			local vallab: value label `varname' 
			
		
				
			tempvar group
			tempvar numgroup
			tempvar sumgroup
			tempvar rowhead
			tempvar pergroup
			tempvar rowvallab
			
			quietly egen `group' = group(`varname')
			qui bysort `group': gen `numgroup' = _N

***** sort
	if `values' > 0	{
	if strmatch("`sortvalues'", "*`varname'*") {
		qui gsort -`uniq'  `varname'
		local sort "(sorted by values)"
		}
		
	else if strmatch("`sortfrequency'", "*`varname'*") {	
		qui gsort -`uniq' -`numgroup' `varname'
		local sort "(sorted by frequency)"
		}
	else {
		tempvar rand 
		qui gen `rand' = runiform()
		qui gsort -`uniq' `rand'
		local sort "(`values' examples shown)"
		}
			
			
			if !strmatch("`vartype'", "str*") {
				quietly su `varname', meanonly
				local varmin `r(min)'
				local varmax `r(max)'
				qui gen `rowhead' = strofreal(`varname', "`varformat'") in 1/`values'
				}
			else qui gen `rowhead' = `varname' in 1/`values'			
			
			qui gen `sumgroup' = sum(`numgroup') if `uniq'
			if `uniquevals' > `values' {
				local lastvalue = `values' + 1
				qui replace `numgroup' = _N - `sumgroup' in `lastvalue' 
				local nfreqs = `lastvalue'
				qui replace `rowhead' = "All other values" in `lastvalue'
				}
			else local nfreqs `uniquevals'
			
		qui gen `pergroup' = strofreal(100* `numgroup' / _N, "%3.1f") +"%" if !mi(`sumgroup')
		
		qui gen `rowvallab' = ""
		
		if ("`vartype'" == "byte" | "`vartype'" ==  "int" | "`vartype'" ==  "long" | "`vartype'" == "float" | "`vartype'" == "double")  {
			forval i = 1/`values' {
				local rowvalue = `varname'[`i']
				local rl: label (`varname') `rowvalue' ,strict
				qui replace `rowvallab' = `"`rl'"' in `i'
				}
			}
		
	
		putdocx table d`tableno' = data(`rowhead' `rowvallab' `numgroup' `pergroup' )  in 1/`nfreqs' , border(all, nil) 
		}
	
	else putdocx table d`tableno' = (1,4), border(all, nil) 
		
		putdocx table d`tableno'(.,1), halign(right)
		putdocx table d`tableno'(.,3), halign(right)
		putdocx table d`tableno'(.,4), halign(right)
		putdocx table d`tableno'(.,.), valign(center)
		
	
		// write table headers

			if `values' > 0 putdocx table d`tableno'(1,.), addrows(11, before)
			else {
				putdocx table d`tableno'(1,.), addrows(7, before)
				putdocx table d`tableno'(8,1) = ("    (values omitted from output)"), colspan(4)
				}
			
			putdocx table d`tableno'(1,1) = ("Name:"), 
			putdocx table d`tableno'(1,2) = ("`varname'"), 
			
			putdocx table d`tableno'(1,.), border(top, single, black, 2 pt)
			
			putdocx table d`tableno'(2,1) = ("Type:"), 
			putdocx table d`tableno'(2,2) = ("`vartype'"), 
			
			putdocx table d`tableno'(3,1) = (`"Variable label:"'), 
			putdocx table d`tableno'(3,2) = (`"`varlab'"'), 
			
			putdocx table d`tableno'(4,1) = (`"Value label:"')
			putdocx table d`tableno'(4,2) = (`"`vallab'"')
			
			putdocx table d`tableno'(5,1) = ("Variable format:"), 
			putdocx table d`tableno'(5,2) = ("`varformat'"), 
			
			putdocx table d`tableno'(6,1) = ("Unique values:  "),  
			putdocx table d`tableno'(6,2) = (`uniquevals'), nformat(%-15.0gc)  
			
			putdocx table d`tableno'(7,1) = ("Missing values:  "),  
			putdocx table d`tableno'(7,2) = (`numissing'), nformat(%-15.0gc) 

		
		if `values' > 0	{	
			putdocx table d`tableno'(11,1) = ("Value"), border(bottom, single, black) halign(right) linebreak
			putdocx table d`tableno'(11,1) = (`"`sort'"'), append
			putdocx table d`tableno'(11,2) = ("Label"), border(bottom, single, black) linebreak
			putdocx table d`tableno'(11,3) = ("Freq."), border(bottom, single, black) halign(right) linebreak
			putdocx table d`tableno'(11,4) = ("Percent"), border(bottom, single, black) halign(right) linebreak
			putdocx table d`tableno'(11,.), valign(center)
		}	
			
		
			
			
		// means and percentiles	
			
			qui putdocx describe  d`tableno'
			if ("`vartype'" == "byte" | "`vartype'" ==  "int" | "`vartype'" ==  "long" | "`vartype'" == "float" | "`vartype'" == "double") & !strmatch("`freqonly'", "*`varname'*") & `values' != 0 { 
				
				
*				putdocx table d`tableno'(`r(nrows)',.), border(bottom, single, black)
				
				putdocx table m`tableno' = (3,5), border(all, nil) 
				quietly su `varname',det
				
				putdocx table d`tableno'(8,1) = ("Mean: ") ,  halign(left)
				putdocx table d`tableno'(8,2) = ("`r(mean)'"), nformat(`varformat')  
				putdocx table d`tableno'(9,1) = ("sd: "), halign(left)
				putdocx table d`tableno'(9,2) = ("`r(sd)'"),   nformat(`varformat') 
				putdocx table d`tableno'(9,.), border(bottom, single, lightgray)
				
				putdocx table m`tableno'(1,1) = ("     Percentiles:"),  
						
				putdocx table m`tableno'(2,1) = ("10%"), halign(right)
				putdocx table m`tableno'(2,2) = ("25%"), halign(right)
				putdocx table m`tableno'(2,3) = ("50%"), halign(right)
				putdocx table m`tableno'(2,4) = ("75%"), halign(right)
				putdocx table m`tableno'(2,5) = ("90%"), halign(right)
						
				putdocx table m`tableno'(3,1) = ("`r(p10)'"), nformat(`varformat') halign(right)
				putdocx table m`tableno'(3,2) = ("`r(p25)'"), nformat(`varformat') halign(right)
				putdocx table m`tableno'(3,3) = ("`r(p50)'"), nformat(`varformat') halign(right)
				putdocx table m`tableno'(3,4) = ("`r(p50)'"), nformat(`varformat') halign(right)
				putdocx table m`tableno'(3,5) = ("`r(p90)'"), nformat(`varformat') halign(right)
				
				putdocx table m`tableno'(1,.), border(top, single, lightgray)
				putdocx table m`tableno'(3,.), border(bottom, single, black, 2 pt)
				} 
			
			else putdocx table d`tableno'(`r(nrows)',.), border(bottom, single, black, 2 pt)
					
		
			// add variable notes, save file 
				
				notes _count notecount : `varname'
				if `notecount' > 0 {
				
				putdocx table d`tableno'(7,.), addrows(`notecount', after)
				putdocx table d`tableno'(7,.), border(bottom, single, lightgray)
				local row = 7
				
				putdocx table d`tableno'(8,1) = (""), linebreak(1)
				putdocx table d`tableno'(8,1) = ("Variable notes:"), append linebreak(1) border(bottom, single, lightgray)
				
				forval notenumber = 1/`notecount' {
					notes _fetch notefetch : `varname' `notenumber'
					putdocx table d`tableno'(8,1) = (`"    `notenumber': `notefetch'"'),  append linebreak(1)
					}
					
					putdocx table d`tableno'(8,1), colspan(4)
				
				

				
				
				}
				
				
	

}	
		putdocx save `"`using'"',append 	
		di _newline(2) as text "Microsoft Word file " as result "`using'" as text " written."

restore
	
end
	
//eof
