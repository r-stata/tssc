/*
Program creates a one-way tabulation and saves results in a specified matrix with appropriate labels.

Version 1.0
July 2016
Loris Fagioli
lfagioli@ivc.edu
*/
program tab2mat
version 10
syntax varlist(max=1) [if] [in] [fweight aweight] , matrix(string) [NOMISS] [NOFREQ] [NOPERC] [TOTAL]

capture confirm numeric variable `varlist' //check if variable is string or numeric
local string=_rc

preserve 
gen Freq = 1 
collapse (count) Freq `if' `in' [`weight' `exp'], by(`varlist') 

if "`nomiss'"=="nomiss" drop if missing(`varlist')
else if `string'!=0 replace `varlist'="Missing" if missing(`varlist') //create Missing label for correct rownames

egen Percent = pc(Freq) 
if "`nofreq'"=="nofreq" {
				if `string'!=0 mkmat Percent , mat(`matrix') rownames(`varlist')
				else mkmat Percent , mat(`matrix') 
				}
else if "`noperc'"=="noperc" {
				if `string'!=0 mkmat Freq , mat(`matrix') rownames(`varlist')
				else mkmat Freq , mat(`matrix') 
				}
else {
				if `string'!=0 mkmat Freq Percent , mat(`matrix') rownames(`varlist')
				else mkmat Freq Percent , mat(`matrix') 
				}

if `string'==0 {
		forval i = 1/`= rowsof(`matrix')' { 
		local name : label (`varlist') `= `varlist'[`i']'
				if `"`name'"' == "" local name = `varlist'[`i']
				if `"`name'"' == "." local name "missing" 
				local names `"`names' `"`name'"' "' 
			} 	
		}
restore

if "`total'"!="" {
mata : st_matrix("aaa", colsum(st_matrix("`matrix'")))
matrix rownames aaa="Total"
matrix `matrix'=`matrix'\aaa
matrix drop aaa
} 	
if "`total'"=="" & `string'==0 matrix rownames `matrix' = `names'
if "`total'"!="" & `string'==0 matrix rownames `matrix' = `names' "Total"
matrix li `matrix'
end 	
