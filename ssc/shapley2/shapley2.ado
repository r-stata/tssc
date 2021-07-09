capture program drop shapley2 
*!version 1.5 10jun15 -  F. Chavez Juarez
program define shapley2 , eclass 
version 9.2
syntax [anything] , stat(str) [Command(str) Indepvars(str) Depvars(str) GRoup(str) MEMory FORCE Noisily]

// CHECK FIRST THAT THE USER DOESN'T USE TWICE THE shapley2 command in a row
capture confirm matrix e(shapley)
if(_rc==0){
	di as error "You must not use twice shapley2 in a row. Restore first your regression (See {help estimates store:estimates store} for help)"
	exit
	}
qui{
tempfile orgdb temp
save `orgdb'

est store myreg
//keep if e(sample)
gen _mysample=e(sample)
tempfile usedb
save `usedb'

local full=e(`stat')


if("`command'"==""){
	local command=e(cmd)
	}
if("`depvar'"==""){
	local depvar=e(depvar)
	
	
	}
if("`indepvars'"==""){
	local indepvarstemp:colnames e(b)		// load indepvars
	
	// control if all is ok (this eliminates some additional columns like _cons
	local indepvars=""
	foreach var of local indepvarstemp{
		capture confirm variable `var'
			if(_rc==0){
				local indepvars="`indepvars' `var'"	
			}
		}
	}
	
	// CHECK THAT NO FACTOR VARIABLES ARE USED
	local cmdline=e(cmdline)
	local cmdline=subinstr(lower("`cmdline'"),lower("`command'"),"",1)
	local cmdline=subinstr(lower("`cmdline'"),lower("`depvar'"),"",1)
	
	if(strpos("`cmdline'","i.")>0 | strpos("`cmdline'","l.")>0 | strpos("`cmdline'","f.")>0 | strpos("`cmdline'","#")>0){
		noisily display as error "Factor variables are not supported" _n "Please create the variables manually"
		use `orgdb', clear
		exit
	}
	
if("`group'"!=""){ // this is the algorithm for the group specific shapley value
	gl stop=0
	local g=1
	
	tokenize "`group'", parse(",")
	
	while($stop==0){
		local group`g' `1'
		
		macro shift
		if("`1'"==","){ // ANOTHER "," more groups are expected
			local g=`g'+1
			macro shift
		} //end if
		else{
			gl stop=1
		} // end else
	} // end while
	
	
	if(`g'<=12 & c(version)<12){ // for stata version <12, adapt matsize 
		local newmatsize=max(2^`g'+200,c(matsize))
		capture set matsize `newmatsize'
		}
	if(`g'>12){
		local runs=2^`K'
		noisily di as error "Too many groups defined (`runs' needed)"
		noisily di as error "A maximum of 12 groups is allowed"
		exit
	}
	
	preserve
			drop _all
			set obs 2
			forvalues j=1/`g'{
				gen _group`j'=1 in 1/1
				replace _group`j'=0 in 2/2
				}
			fillin _group*
			
			local allvars ""
			forvalues j=1/`g'{
				foreach var of local group`j'{
					gen `var'=_group`j'
					local allvars "`allvars' `var'"
				}
			}
			
			drop _fillin
			gen result=.
			mkmat * , matrix(combinations) 
			matrix list combinations
			restore
	

		local numcomb=rowsof(combinations)
		local numcols=colsof(combinations)

		
		matrix combinations[1,`numcols']=0
			
		forvalues i=2/`numcomb'{
		local thisvars=""
			foreach var of local allvars{
				
				matrix mymat=combinations[`i',"`var'"]
				local test=mymat[1,1]
				
				if(`test'==1){
					
					local thisvars "`thisvars' `var'"
					
					}
				}
			//di "`thisvars'"
			
			
			`noisily' `command' `depvar' `thisvars' if _mysample
			matrix combinations[`i',`numcols']=e(`stat')
			
		}
		matrix list combinations
		preserve
		drop _all
		matrix list combinations
		svmat combinations,names(col) 


}
else{ // no group variable, hence use all indepvars individually
local K=wordcount("`indepvars'")

if(`K'>20 & "`force'"==""){
	local runs=2^`K'
	noisily di as error "Too many independent variables (`runs' needed)"
	noisily di as error "If you really want to proceed, use the option 'force'"
	exit
	}
if(`K'<=12 & c(version)<12){
	local newmatsize=max(2^`K'+200,c(matsize))
	capture set matsize `newmatsize'
	
}

if(2^`K'<=c(matsize)){

		preserve
			drop _all
			set obs 2

			foreach var of local indepvars {
				gen `var'=1 in 1/1
				replace `var'=0 in 2/2
				}
				
			fillin `indepvars'
			drop _fillin
			gen result=.
			mkmat `indepvars' result , matrix(combinations) 
			matrix list combinations
		restore

		local numcomb=rowsof(combinations)
		local numcols=colsof(combinations)

		//di as error "I have to perform `numcomb' regressions"
		matrix combinations[1,`numcols']=0
		forvalues i=2/`numcomb'{
		local thisvars=""
			foreach var of local indepvars{
				matrix mymat=combinations[`i',"`var'"]
				local test=mymat[1,1]
				
				if(`test'==1){
					local thisvars "`thisvars' `var'"
					}
				}
			//di "`thisvars'"
			`noisily' `command' `depvar' `thisvars' if _mysample
			matrix combinations[`i',`numcols']=e(`stat')
			
		}
		preserve
		drop _all
		matrix list combinations
		svmat combinations,names(col) 
}
else{ // if the matsize is to big

	if("`mem'"=="mem"){
		clear
		capture set mem 5000m
		while(_rc!=0){
		capture set mem `i'm
		local i=round((`i')*0.9)
		}
		use `usedb'
		}


	di as error "Slow algorithm chosen. Try to increase matsize to enable the faster algorithm"
	drop _all
	set obs 2

	foreach var of local indepvars {
		gen `var'=1 in 1/1
		replace `var'=0 in 2/2
		}
	compress	
	fillin `indepvars'
	drop _fillin
	gen result=.
	
	
	
	local numcomb=_N
	
	di "`numcomb' combinations!"
	qui:replace result=0 in 1/1
	forvalues i=2/`numcomb'{
		local thisvars=""
			foreach var of local indepvars{
				local test=`var' in `i'/`i'
					if(`test'==1){
						local thisvars "`thisvars' `var'"
					}
		}
	
	//di "`thisvars'"
	preserve
	use `usedb', clear
	di "`command' `depvar' `thisvars'"
	qui: `command' `depvar' `thisvars'
	restore
	
	qui: replace result=e(`stat') in `i'/`i'
	
}


}
}

/* Start computing the shapley value*/


if("`group'"!=""){
	foreach var of varlist _group*{
		local IVlist "`IVlist' `var'"
		}
	egen t=rowtotal(_group*)
	sum t
	local Kgroup=r(max)
	replace t=t-1
	
	gen _weight = round(exp(lnfactorial(abs(t))),1) * round(exp(lnfactorial(`Kgroup'-abs(t)-1)),1)
	drop t
	
	keep _group* _weight result
	save `temp', replace
	matrix newshapley=[.]
	foreach var of local IVlist{
		local i=subinstr("`IVlist'","`var'","",1)
		reshape wide result _weight, i(`i') j(`var')
		gen _diff = result1-result0
		sum _diff [iweight = _weight1]
		use `temp',clear
		
		matrix newshapley = (newshapley \ r(mean))
	}
	matrix newshapley = newshapley[2...,1]
	matrix shapley=newshapley
	matrix shapley_rel=shapley/`full'
	
	

} // end if group
else{

egen t=rowtotal(`indepvars')
replace t=t-1
gen _weight = round(exp(lnfactorial(abs(t))),1) * round(exp(lnfactorial(`K'-abs(t)-1)),1)
drop t



 save `temp', replace

matrix newshapley=[.]
foreach var of local indepvars{
	local i=subinstr("`indepvars'","`var'","",1)
	reshape wide result _weight, i(`i') j(`var')
	gen _diff = result1-result0
	sum _diff [iweight = _weight1]
	use `temp',clear
	
	matrix newshapley = (newshapley \ r(mean))
}
matrix newshapley = newshapley[2...,1]

	matrix shapley=newshapley
	matrix shapley_rel=shapley/`full'
	
}


// GENERATE THE NORMALIZED VERSION



matrix result=(shapley'\shapley_rel')



restore


} // end quietly



// START OUTPUT
//di as text  "---------1---------2---------3---------4---------5---------6---------7---------8---------9---------10--------+"
di as text "Factor" _col(12) "{c |}" " Shapley value " _col(23) "{c |}  Per cent " //_col(40) "{c |} Shapley value" _col(45) "{c |}   Per cent  "
di as text  _col(12) "{c |}" "  (estimate)   " _col(23) "{c |} (estimate)" //_col(40) "{c |} (normalized) " _col(45) "{c |} (normalized)"
di as text "{hline 11}{c +}{hline 15}{c +}{hline 11}{c +}" //{hline 14}{c +}{hline 13}"
local i=0
if("`group'"!=""){
	forvalues j=1/`g'{
	local i=`i'+1
	local varname="Group `j'" 
	di as text "`varname'" _col(12) "{c |}" as result %6.5f _col(15) el(result,1,`i') as text _col(28) "{c |}" _col(31) as result %6.2f 100*el(result,2,`i') as text " %" ///
	_col(40) "{c |}" //as result %6.5f _col(42) el(result,3,`i') as text _col(55) "{c |}" _col(57) as result %6.2f 100*el(result,4,`i') as text " %"
	}
}
else{
	foreach var of local indepvars{
		local i=`i'+1
		local varname=abbrev("`var'",10)
		di as text "`varname'" _col(12) "{c |}" as result %6.5f _col(15) el(result,1,`i') as text _col(28) "{c |}" _col(31) as result %6.2f 100*el(result,2,`i') as text " %" ///
		_col(40) "{c |}" //as result %6.5f _col(42) el(result,3,`i') as text _col(55) "{c |}" _col(57) as result %6.2f 100*el(result,4,`i') as text " %"
	}
	}
di as text "{hline 11}{c +}{hline 15}{c +}{hline 11}{c +}"
//di as text "Residual" _col(12) "{c |}" as result %6.5f _col(15) `full'-`sum' as text _col(28) "{c |}" _col(31) as result %6.2f 100*(1-`sum'/`full') as text " %" _col(40) "{c |}" _col(55) "{c |}"
//di as text "{hline 11}{c +}{hline 15}{c +}{hline 11}{c +}{hline 14}{c +}{hline 13}"
di as text "TOTAL" _col(12) "{c |}" as result %6.5f _col(15) `full' as text _col(28) "{c |}" _col(31) as result %6.2f 100 as text " %" ///
				   _col(40) "{c |}" //as result %6.5f _col(42) `full' as text _col(55) "{c |}" _col(57) as result %6.2f 100 as text " %"
di as text "{hline 11}{c +}{hline 15}{c +}{hline 11}{c +}"
if("`group'"!=""){ //display the groups
di as text "Groups are:"
forvalues j=1/`g'{
	di as text "Group `j':" _col(10) as result "`group`j''"
}
}

quietly{
use `orgdb', clear
est restore myreg
est drop myreg
ereturn matrix shapley shapley
ereturn matrix shapley_rel shapley_rel
ereturn local estat_cmd="shapley2"

}
end

********************
*!
*!--------------------- VERSION HISTORY -------------------
*! Version 1.5: It is now possible to use f. and l. factor variables as dependent variables
*! Version 1.4: Small bugfix: sometimes the program did not execute in protected working directories. Change does not affect result.
*! Version 1.3: Small bugfix: shapley2 did not work with oprobit. The fix does not affect the results. 
*! Version 1.2: Change in the computation, now closer to similar routines. Bugfix: now accepts very long group-statements
*! Version 1.1: Bugfix to ensure no changes are made to the current database. 
*! Version 1.0: First release on 06nov2012


