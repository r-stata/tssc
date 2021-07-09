*! ralpha.ado - Stata module to generate random letters/characters
*! Author: Eric A. Booth <ebooth@tamu.edu>
*! Version 1.0.1  Modified:  Jan. 2010  

		
program define ralpha, rclass
syntax  [namelist] [, Length(str asis) * ]
version 9.2
qui{
if "`namelist'"=="" local namelist ralpha
cap confirm variable `namelist'
	if !_rc {
		di as err "Variable {bf:`namelist'} already exists, please specify new variable name!"
		exit 198
		}
qui cap drop __ralpha
if `"`length'"' == "" | `"`length'"' == "1" {
	qui __ralpha `namelist', `options'
	}
if `"`length'"' != "" & `"`length'"' != "1"  {
	 if `length' >= 244 {
		noi di as err `"Length option must be less than 244 characters"'
		exit 198
		}
		
		qui cap drop __`namelist'
		qui g __`namelist' = ""
	forval n = 1/`length' {
		qui tempvar place`n'
		qui __ralpha `place`n'', `options'
		qui replace __`namelist' = __`namelist' + `place`n'' 
		qui cap drop `place`n''
		}
	qui cap drop `namelist'	
	qui g `namelist' = __`namelist'	
	qui cap drop __`namelist'
	qui cap drop `place`n''
	}
	qui cap drop __`namelist'
	qui cap drop __ralpha
	}
end


program define __ralpha, rclass
syntax  [namelist] [, LOWeronly UPperonly Range(string)]
version 9.2

qui {
if "`namelist'"=="" local namelist ralpha
	cap confirm variable `namelist'
	if !_rc {
		di as err "Variable {bf:`namelist'} already exists, please specify new variable name!"
		exit 198
		}
	noi di in r "`length'" 
**error checking**
	if "`loweronly'"!="" & "`upperonly'" != "" {
		di as error	"Must Specify only one of lower or upper, not both"
		exit 198
		}
	if ("`loweronly'" != "" | "`upperonly'"!="") & "`range'" !="" {
		di as error	"Must Specify only one of lower, upper, or range()"
		exit 198
		}
	if "`strpos(`range', "-")'"!="" {
		di as error "range() option must be specified as "a/z", "A/z", etc"
		exit 198
		}

**main part: random alpha from upper and lower chars**
qui {
	if "`loweronly'" == "" & "`upperonly'"=="" & "`range'"=="" {
		loc newvarname `namelist'
		tempvar newnewvarname
			qui  g  `newnewvarname' = 0+int((25-0+1)*runiform())
			qui  replace `newnewvarname' = `newnewvarname'+97
			qui  tostring `newnewvarname', g(`newvarname') force
			qui  replace `newvarname' = char(`newnewvarname')
		di "{stata describe `newvarname':`newvarname'} created with lowercase chars only"
			}
**lower only (char 97 - 122)**
	if "`loweronly'" != "" & "`upperonly'"=="" & "`range'"=="" {
		loc newvarname `namelist'
		tempvar newnewvarname
			qui  g  `newnewvarname' = 0+int((25-0+1)*runiform())
			qui  replace `newnewvarname' = `newnewvarname'+97
			qui  tostring `newnewvarname', g(`newvarname')  force
			qui  replace `newvarname' = char(`newnewvarname')
		di "{stata describe `newvarname':`newvarname'} created with lowercase chars only"
		}
**upper only (char 65 - 91) **
	if "`loweronly'" == "" & "`upperonly'"!="" & "`range'"=="" {
		loc newvarname `namelist'
		tempvar newnewvarname
			qui  g  `newnewvarname' = 0+int((25-0+1)*runiform())
			qui  replace `newnewvarname' = `newnewvarname'+65
			qui  tostring `newnewvarname', g(`newvarname') force
			qui  replace `newvarname' = char(`newnewvarname')
			di "{stata describe `newvarname':`newvarname'} created with uppercase chars only"
		}
**range specified**
	if "`loweronly'"=="" & "`upperonly'"=="" & "`range'" != "" {
										*noi di in yellow "range"
		loc original `range'
	**parse the range to obtain the start & end values**
		loc range:subinstr local range "-" "/", all
		loc range:subinstr local range "/" " ", all count(local count)
		if `count'>1  di as error "Only one range may be specified - second range ignored"	
		loc start:word 1 of `range'
		*loc start = char(`start')
			**find char for `start'**
			forval n = 65/122 {
				loc x = char(`n')
				if "`x'"=="`start'" loc start `n'
				}
	**	noi di in yellow "`start'"
		loc end:word 2 of `range'
			**find char for `end'**
			forval n =  65/122 {
				loc x = char(`n')
				if "`x'" == "`end'"  loc end `n'
				}		
		*loc end = char(`end')
		**noi di in green "`end'"
		if `start'>`end' {
			di as err "Range must go from Uppercase to Lowercase (A/g, G/z)"
			exit 198
			}
	**create numlist**
		numlist "65/91  97/122"
		local all `r(numlist)'
	**create trimend numlist**
		loc start2 = `start'-1
		loc end2 = `end'+1
		numlist "64/`start2'"
		local begin `r(numlist)'
		numlist "`end2'/123"
		local ending "`r(numlist)'"
		*numlist "91/96"
		*local remove "`r(varlist)'"
		local trimrange:list local(all)-local(begin)
		local trimrange:list local(trimrange)-local(ending)
		*local trimrange:list local(trimrange)- local(remove)
		
			**noi di in red "`trimrange'"
	**store range in `r(num_range)' 
		return local num_range `trimrange'
	**create random strings**
		loc newvarname `namelist'
		tempvar newnewvarname
			**create new end to leave out 91/96
			local end2 `end'-6
			qui  g  `newnewvarname' = `start'+int((`end2'-`start'+1)*runiform())
			qui replace `newnewvarname' = `newnewvarname'+6 if `newnewvarname'>=91
			*qui  replace `newnewvarname' = `newnewvarname'
			qui  tostring `newnewvarname', g(`newvarname') force
			qui  replace `newvarname' = char(`newnewvarname')
		noi di "Variable {stata describe `newvarname':`newvarname'} created for range: " in yellow `""`original'""'    
	}
}
	lab var `newvarname' "Random Alpha String"
	qui cap drop __`namelist'
	qui cap drop __`newvarname'
	qui cap drop __ralpha
	}
end


/*  Examples
clear 
set obs 200
ralpha  test 
ralpha lversion
ralpha uversion, upperonly
ralpha range1, range(B/g)
ralpha range2, range(X/z) l(10)
g newword = proper(range2)
*/








