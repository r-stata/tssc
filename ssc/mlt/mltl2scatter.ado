*! version 1.2 beta  25Jan2013
*alexander.schmidt@wiso.uni-koeln.de; 

version 11.0, missing
capture program drop mltl2scatter
program define mltl2scatter, rclass

*syntax
syntax varlist (min=2 max=2 numeric) [if]  [aweight fweight iweight]  , l2id(varname) [keepvars labels qfit lfit]

* check whether l2id  is numeric or string
capture confirm numeric v `l2id'
if !_rc {
	local l2idn = 1 
	}
else {
	local l2idn = 0
}


	


* get dependent and independent variable
gettoken yvar xvar : varlist , parse(" ")


* weights specified?
capture confirm existence  `weight'
if !_rc {
	local w=1
	}
else {
	local w=0
	}



*Erase variables
capture drop `yvar'_mlt
capture drop `xvar'_mlt
capture drop L2ID_mlt
capture drop mlthelp
capture drop mlthelp1


* remember the ordering of the data when the program starts
qui gen mlthelp = _n		
qui bys `l2id': gen mlthelp1 = 1 if _n == 1
sort mlthelp1, stable	

* Get values from level two ID
dis as text "Level 2 variable is" as result " `l2id' "
dis " "

* get values of level-2 id
	qui levelsof `l2id' `if', local(l2idvalues) 

* generate new Level2ID Variable
local i=0
if `l2idn' == 1 {
	qui gen L2ID_mlt = .
	}
if `l2idn' == 0 {
	qui gen L2ID_mlt  = ""
	}
	
qui label variable L2ID_mlt "Level-2 ID"
foreach x of local l2idvalues {
	local i=`i'+1
	if `l2idn' == 1 {
		qui replace L2ID = `x' in `i' 
		}	
	if `l2idn' == 0 {
		qui replace L2ID = "`x'" in `i'
	}
}
	* get labels of original level-2 two ID and use them for the new variable L2ID
	local vl :value label `l2id'		
	if `l2idn' == 1 {
		label values L2ID `vl'
		}

* calculate means for each higher-level unit 

	* change string of the if - condition
	capture confirm existence `if'
	if !_rc {
	gettoken if rest : if
	*dis "`if'" "`rest'"
	local rest = "`rest' &" 
	}
qui gen `yvar'_mlt = .
qui label variable `yvar'_mlt "Level-2 mean of `yvar' "
qui gen `xvar'_mlt = .
qui label variable `xvar'_mlt "Level-2 mean of `xvar' "
local i=0
foreach x of local l2idvalues {
local i=`i'+1
if `l2idn' == 1 {
	if `w'==1 {
		qui sum `yvar' if `rest' `l2id'==`x'  [`weight'`exp']
		qui replace `yvar'_mlt = r(mean) in `i'
		qui sum `xvar' if `rest' `l2id'==`x' [`weight'`exp']
		qui replace `xvar'_mlt = r(mean) in `i'
		}
	if `w'==0 {
		qui sum `yvar' if `rest' `l2id'==`x'
		qui replace `yvar'_mlt = r(mean) in `i'
		qui sum `xvar' if `rest' `l2id'==`x'
		qui replace `xvar'_mlt = r(mean) in `i'
		}
	}



if `l2idn' == 0 {
	if `w'==1 {
		qui sum `yvar' if `rest' `l2id'=="`x'" [`weight'`exp']
		qui replace `yvar'_mlt = r(mean) in `i'
		qui sum `xvar' if `rest' `l2id'=="`x'" [`weight'`exp']
		qui replace `xvar'_mlt = r(mean) in `i'
		}
	if `w'==0 {
		qui sum `yvar' if `rest' `l2id'=="`x'"
		qui replace `yvar'_mlt = r(mean) in `i'
		qui sum `xvar' if  `rest' `l2id'=="`x'"
		qui replace `xvar'_mlt = r(mean) in `i'
		}
	}
}

	
* get y-axis title
local varl : variable label `yvar'_mlt

if "`lfit'"=="lfit" {
	if "`qfit'"!="qfit" { 
		if "`labels'"=="labels" {
			scatter `yvar'_mlt `xvar'_mlt, mlabel(L2ID) || lfit `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl')
			}
		if "`labels'"!="labels" {
			scatter `yvar'_mlt `xvar'_mlt || lfit `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl')
			}
		}
	if "`qfit'"=="qfit" {	
		if "`labels'"=="labels" {
			scatter `yvar'_mlt `xvar'_mlt, mlabel(L2ID) || lfit `yvar'_mlt `xvar'_mlt || qfit `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl') 
			}
		if "`labels'"!="labels" {
			scatter `yvar'_mlt `xvar'_mlt || lfit `yvar'_mlt `xvar'_mlt || qfit `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl')
			}
		}	
	}
	
if "`lfit'"!="lfit"  {
	if "`qfit'"=="qfit" {
		if "`labels'"=="labels" {
			scatter `yvar'_mlt `xvar'_mlt, mlabel(L2ID) || qfit `yvar'_mlt `xvar'_mlt ||  , legend(off) ytitle(`varl')
			}
		if "`labels'"!="labels" {
			scatter `yvar'_mlt `xvar'_mlt || qfit `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl')
			}
		}
	if "`qfit'"!="qfit" {
		if "`labels'"=="labels" {
			scatter `yvar'_mlt `xvar'_mlt, mlabel(L2ID) || , legend(off) ytitle(`varl')
			}
		if "`labels'"!="labels" {
			scatter `yvar'_mlt `xvar'_mlt || , legend(off) ytitle(`varl')
			}
		}
	}
	


	
if "`keepvars'"!="keepvars" {
drop `yvar'_mlt
drop `xvar'_mlt
drop L2ID_mlt 
}


sort mlthelp
capture drop mlthelp
capture drop mlthelp1

end
