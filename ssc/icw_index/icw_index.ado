// According to Michael L. Anderson Multiple Inference and Gender Differences in the Effects of Early Intervention: AReevaluation of the Abecedarian, Perry Preschool, and Early Training Projects Journal of the American Statistical Association, Vol. 103, No. 484 (Dec., 2008), pp.1481-1495
// 
version 16.1
cap program drop icw_index
program define icw_index
pause on
syntax varlist, GENerate(name)
quiet{
    * here I identify the observation with available info to speed up the code. 
tempvar  `generate'_mi
egen ``generate'_mi'=rowmiss(`varlist')
local c= wordcount("`varlist'")
replace ``generate'_mi'=(``generate'_mi'==`c')

*** establishing the pattern of missing values: for each observation, I create a tempvar mi_pattern that indicates which variable is non-missing

* I start my loop by assigning 1 to the observation with non missing for variable 1
local first= ustrword("`varlist'",1)
tempvar mi_pattern
gen `mi_pattern'="1" if mi(`first')==0 & ``generate'_mi'==0
local varlist_1: list varlist - first

* I continue my loop for 2 and + 
local j=2
foreach i of local varlist_1 { 
	
replace `mi_pattern'=`mi_pattern' +" "+ "`j'" if mi(`i')==0 & ``generate'_mi'==0
replace `mi_pattern'=strtrim(`mi_pattern') if ``generate'_mi'==0

local ++j
}

* I create a new varlist including the non missing patterns

levelsof `mi_pattern',  local(levels) 
local error= wordcount(`"`levels'"')
if `error'>1000 { 
	
	noisily dis  as result "Beware the command needs to inverse `error' matrices: it will take some time!"
}
local c=1
foreach i of local levels {
	
	foreach k in `i' {
 	local newlist`c'= "`newlist`c'' `=ustrword("`varlist'",`k')'"
	local newvarlist`c'= "`newvarlist`c'' `k'"

	}
	dis "`newlist`c''"
	local newvarlist`c'=strtrim("`newvarlist`c''")

	local ++c
}


** for each missing pattern, I geneate the weights
gen  	`generate'=. 
forval  i=1/`=`c'-1' { 
    
	corr `newlist`i''  , cov
	mat CV=r(C)
	matrix invCV=inv(CV)
	mata : st_matrix("S", rowsum(st_matrix("invCV")))	
** assigning weights to variables
	local j=1 
	foreach k of local newlist`i' { 
	   
		tempvar  w_`k'
		tempvar  i_`k'
		gen `w_`k''=S[`j',1] if ``generate'_mi'==0
		gen `i_`k''=(`w_`k''*`k') if ``generate'_mi'==0
		replace `w_`k''=.  if ``generate'_mi'==0 & `i_`k''==.
		local listk "`listk' `i_`k''"
		local listw "`listw' `w_`k''"
		local ++j
		
	}
** Calculating the final index 

	tempvar y
	egen `y'=rowtotal(`listk') if `generate'==., mi 
	replace  	`generate'=`y' if  `mi_pattern'=="`newvarlist`i''" & ``generate'_mi'==0
	drop `y'
** divide the index by the sum of weights
	tempvar W
	egen `W'=rowtotal(`listw'), mi
	replace `generate'=`generate'/`W' if ``generate'_mi'==0  &  `mi_pattern'=="`newvarlist`i''"
	drop  `W'
	local listk "" 
	local listw ""
	
	foreach k of local newlist`i' { 
	    
	drop `w_`k'' `i_`k''
	}
	
}
}
end
