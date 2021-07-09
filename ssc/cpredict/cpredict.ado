capture program drop cpredict
*! version 1.1 15Feb2017 F. Chavez-Juarez 
program define cpredict , rclass 
version 9.2
syntax newvarname , [Manip(varlist) Keep(varlist) Stat(str) POPT(str) GRaph(varlist) GROpt(str) GRType(str)]

// CHECK IF NOT BOTH 'keep' AND 'mean' are used
if("`manip'"!="" & "`keep'"!=""){
	di as error "You cannot specify both 'manip' and 'keep'." _n ///
		"Please choose either of the two." _n ///
		"Consult {help cpredict:help cpredict} for more information"
	exit
}
if("`manip'"=="" & "`keep'"==""){
	di as error "You must specify either 'manip' or 'keep'." _n ///
		"Consult {help cpredict:help cpredict} for more information"
	exit
}

// Start with computing the mean of the variables
		tempvar id
		tempfile file
		gen `id'=_n
		preserve
		

if("`stat'"==""){
	local stat="mean";
}
		
if("`keep'"!=""){
	// Get all the dependent variables
	local cmdline 	= e(cmdline)
	tokenize "`cmdline'",parse(",")
	local cmdline = "`1'"
	
	local depvar 	= e(depvar)
	local cmd		= e(cmd)
	
	local indep : colnames e(b)
	
	di as error "`indep'"
	local indep = subinstr("`indep'","_cons","",5)

	foreach var of local keep{
		local indep=subinstr("`indep'","`var' "," ",5)
	}
	
	di as text "I set the following variables to their sample statistic '`stat'': "
	foreach var of local indep{
			di as text _col(5) "`var'" _col(20) "=" _c
			qui: sum  `var' if e(sample), detail
			local result=r(`stat')
			qui: replace `var'=`result' if e(sample)
			//sum `var' if e(sample)
			
			di as result " `result'"
	}
	
} //end if keep!=""
else{

		foreach var of local manip{
			sum `var', detail
			replace `var'=r(`stat') if e(sample)
		}
} // end mean!=""


predict `varlist' if e(sample), `popt'
noisily di as text "I saved the conditional prediction as {stata sum `varlist':`varlist'}" 
qui{
local label: var la `varlist'
la var `varlist' "cpredict: `label'"
keep `id' `varlist' 

save `file'
restore 

merge 1:1 `id' using `file', nogen
drop `id' 
erase `file'
}
// CHECK IF OPTION GRAPH
if("`graph'"!=""){
	if("`grtype'"==""){
		local grtype="scatter"
	}	
	twoway `grtype' `varlist' `graph', `gropt'
}
end


********************
*!
*!--------------------- VERSION HISTORY -------------------
*! Version 1.1: Bugfix: the use of if/in in the regression caused problem. Now solved.
*! Version 1.0: First release
