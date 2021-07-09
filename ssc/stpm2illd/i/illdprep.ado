capture pr drop illdprep
program define illdprep, rclass
	syntax [if] [in], id(varname) statevar(varlist) statetime(varlist) [status(string)]
	

*** Error checks ***
if "`status'"!="" {	
	capture confirm variable `status'
	if _rc==0 {
		di as err "`status' already exists in the dataset" 
		exit
	}
}

if "`status'"=="" {	
	local status status
	capture confirm variable `status'
	if _rc==0 {
		di as err "`status' already exists in the dataset" 
		exit
	}
}

tokenize `statevar'
local i=1
while "`1'"!="" {
	local i=`i'+1
	local state`i' `1'
	mac shift 1
}

tokenize `statetime'
local i=1
while "`1'"!="" {
	local i=`i'+1
	local statetime`i' `1'
	mac shift 1
}

*** Expand the dataset ***
qui expand 3
qui bysort `id': gen trans= _n

*** Generate transition variables ***
qui gen trans1=trans==1
qui gen trans2=trans==2
qui gen trans3=trans==3
 
*** Generate event indicator for transitions ***
qui gen `status'=0
qui replace `status'=1 if trans==1 & `state2'==0 & `state3'==1
qui replace `status'=1 if trans==2 & `state2'==1 
qui replace `status'=1 if trans==3 & `state2'==1 & `state3'==1

*** Generate start and stop times for each transition ***
qui gen start=0
qui gen stop=min(`statetime2', `statetime3')
qui replace start=`statetime2' if trans==3 & `state2'==1
qui replace stop=`statetime3' if trans==1 & `status'==1
qui replace stop=`statetime3' if trans==3 & `status'==1
qui replace stop=`statetime3' if trans==3 & `state2'==1 & `state3'==0

*** Drop transitions if patient is not at risk of them ***
*** E.g. if patient dies straight away then transition from relapse to dead is not possible ***
qui drop if trans==3 & `state2'==0 

end
 

 
 
 
 
 
 
 
	
