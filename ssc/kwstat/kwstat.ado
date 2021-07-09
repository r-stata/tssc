capture program drop kwstat
*! version 1.0 23jul14 F. Chavez Juarez 
program define kwstat , rclass 
version 9.2
syntax varlist(min=2 max=2) [if] [in], [ Bw(real 0.0) Kernel(str) Stats(str) PREfix(str) AT SAVE GRID(integer 100) LPolybw NOgraph GRAPHTYPE(str) GRAPHOptions(str)]
marksample touse
// Define the dependent and the independent variable
tokenize `varlist'
local depvar `1'
local xvar `2'

capture drop _kwstat_*
qui{

// Define temporary variables
tempvar group X

// Define statistics
if("`stats'"==""){
	local stats="mean"
}

// Define graph type
if(!inlist("`graphtype'","","connected","line","scatter")){
	noisily display as error "Only the following graph types are allowed: " as result "line, scatter, connected"
	noisily display as text "See {stata help kwstat##graphtype:help kwstat} for more help"
	exit 198
}
if("`graphtype'"==""){
	local graphtype="line"
}


// Define the different values
gen `X'=.
if("`at'"==""){
	sum `xvar' if `touse'
	local step = (r(max)-r(min))/(`grid'-1)
	
	forvalues i=1/`grid'{
		replace `X'=r(min)+(`i'-1)*`step' if _n==`i'
	}
}
else{
	replace `X' = `xvar'
	}	
	
egen `group' = group(`X') if `touse' & `X'!=.
sum `group' if `touse'
local maxgroup=r(max)




// Define bandwidth
if("`lpolybw'"=="lpolybw"){
	if("`kernel'"=="normal"){
		lpoly `depvar' `xvar', nograph kernel(gaussian)
		}
	else{
		lpoly `depvar' `xvar', nograph kernel(`kernel')
	}
	
	local bw=r(bwidth)
}

if(`bw'==0){
	noisily di as text "I will define the bandwith automatically." _n as error "Note that the automatically generated bandwith is not necessarily optimal"
	sum `xvar' if `touse'
	local bw=1.06*r(sd)*r(N)^(-1/5)
	noisily di "The chosen bandwith is: `bw'"
	}
	
	

//prepare the output vars
local graph ""
foreach stat of local stats{
		gen _kwstat_`stat'=.
		la var _kwstat_`stat' "`stat'"
		local graph "`graph' (`graphtype' _kwstat_`stat' `X')"
	}


	
// [MAIN BLOC] Loop through all possible values (or grid points) and compute the statistics
forvalues i=1/`maxgroup'{

	sum `X' if `group'==`i'
	qui: kwstat_kernel `xvar' if `touse', bw(`bw') type(`kernel') value(`r(mean)') out(_kwstat_kernel)
	local kerneltype=r(kernel)
	tabstat `depvar' [aweight=_kwstat_kernel] if `touse', stats(`stats') save
	drop _kwstat_kernel
	local runner=1
	matrix result=r(StatTotal)
	foreach stat of local stats{
		replace _kwstat_`stat' = result[`runner',1] if `touse' & `group'==`i'
		local runner= `runner'+1
	}
	
}



// PREPARE THE GRAPH
sort `X'
local bw_round=string(round(`bw',0.00001))
if("`nograph'"==""){
	local xlabel:variable label `xvar'
	local ylabel:variable label `depvar'
	
	if("`xlabel'"==""){
		local xlabel="`xvar'"
		}
	if("`ylabel'"==""){
		local ylabel="`depvar'"
		}
	twoway `graph' , title("Kernel weighted statistics") subtitle("In function of {it:`xlabel'}") ///
			note("Bandwidth: `bw_round', Kernel: `kerneltype'") ytitle("`ylabel'") xtitle("`xlabel'") `graphoptions'
	}

// STORE  VARIABLES
if("`save'"!="save"){
	drop _kwstat_*
}
else{
	gen _kwstat_X=`X'
	if("`prefix'"!=""){
		renpfix _kwstat_ `prefix'
	}
	
	}


}


// Return key values
return scalar bw=`bw'
return local kernel="`kerneltype'"


end

// KERNEL SUBROUTINE (also issued as independent routince called 'kernel' (type ssc install kernel)
capture program drop kwstat_kernel
program define kwstat_kernel , rclass 
version 9.2
syntax varlist(min=1 max=1) [if] [in], Value(real) Bw(real) [Out(string) Type(string)]
marksample touse

tempvar z kernel

// COMPUTE THE VALUE OF Z
gen `z' = (`varlist'-`value')/`bw'


// Compute the kernel itself
gen `kernel' = 0 if `touse'
quietly{
if(inlist("`type'","normal","gaussian")){
	local kname="Normal"
	replace `kernel' = normalden(`z') if `touse'
}
else if("`type'"=="triangle"){
	local kname="Triangle"
	replace `kernel' = 1-abs(`z') if abs(`z')<=1 & `touse'
	local max = 1
}
else if("`type'"=="beta"){
	local kname="Beta"
	replace `kernel' = 0.75*(1-`z')*(1+`z') if abs(`z')<=1 & `touse'
	local max = 1
}
else if("`type'"=="logit"){
	local kname="Logit"
	tempvar logit
	gen `logit' = exp(`z')/(1+exp(`z')) if `touse'
	replace `kernel' = `logit'*(1-`logit') if `touse'
}
else if("`type'"=="uniform"){
	local kname="Uniform"
	replace `kernel' = 0.5 if abs(`z')<=1  & `touse'
	local max = 1
}
else if("`type'"=="cosine"){
	local kname="Cosine"
	replace `kernel' = 1+cos(2*_pi*`z') if abs(`z')<=0.5 & `touse'
	local max = 0.5
}
else if("`type'"=="parzen"){
	local kname="Parzen"
	replace `kernel' = 4/3-8*`z'^2+8*abs(`z')^3 if abs(`z')<=0.5 & `touse'
	replace `kernel' = 8/3*(1-abs(`z'))^3 if inrange(abs(`z'),0.5,1) & `touse'
	local max = 1
}
else{
	if("`type'"!=""){
		noisily di as error "Kernel type '`type'' is not supported. I used the epanechnikov kernel instead"
	}
	local type = "epanechnikov"
	local kname="Epanechnikov"
	replace `kernel' = 0.75*(1-0.2*`z'^2)/sqrt(5) if abs(`z')<=sqrt(5) & `touse' // epanechnikov
	local max = sqrt(5)
}

}


if("`out'"==""){
	local out = "_kernel_`type'"
	}
gen `out' = `kernel'
la var `out' "`kname' kernel of `varlist' around `value'"

// Observations with positive kernel
count if `touse'
local N=r(N)
count if `touse' & `out'>0
local Npos=r(N)
	




// Return values

return local kernel `type'
return scalar bw = `bw'




end


// VERSION HISTORY
*! Version 1.0		First release
