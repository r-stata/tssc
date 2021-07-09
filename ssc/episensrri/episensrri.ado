*! v 1.0.0 N.Orsini 25Spep2006

capture program drop episensrri
program  episensrri, rclass
	version 8.2

syntax anything  [ , PEXp(string) PUNexp(string) rrcd(string)  ROut Format(string)  ]

// check apparent or observed relative riks

capture confirm number `anything'

if _rc != 0 {
	di as err "relative risks has to be a number >= 0 and < ."
	exit 198
	}
else {
	if  `anything' <= 0 {
	di as err "relative risks has to be a number > 0 and < ."
	exit 198
	}
}

tempname arrdx
scalar `arrdx' = `anything'

// check display format

if "`format'" == "" {
local format = "%3.2f"
}   
else {
local format = "`format'"
}
 
// check options
local unmeasured 0

if "`pexp'" != "" & "`punexp'" != "" & "`rrcd'" != "" {
	local unmeasured 1
}

* check rule-out approach

if "`rout'" != "" & `unmeasured' == 0 {
di as err "specify the option pexp(), punexp(), and rrcd()"
exit 198
}

/* Sebastian approach
if "`rout'" != ""  {
tokenize "`rout'"
tempname pe pc
scalar `pe' = `1'
scalar `pc' = `2'
}   
*/ 

// check adjustment for unmeasured confounding 

if "`pexp'" != "" & "`punexp'" != "" & "`rrcd'" != "" {

* check ranges of prevalences of the binary unmeasured confounding 

numlist "`pexp'" , range(>0 <1) sort 
local lpexp `r(numlist)'
local nlexp :  word count `r(numlist)'
numlist "`punexp'" , range(>0 <1) sort
local lpunexp  "`r(numlist)'"
local nlpunexp :  word count `r(numlist)'
numlist "`rrcd'" , range(>0 <=100) sort min(1) max(1)
local lrrcd  `r(numlist)'

tempname rr bias

// loop for sensitivity analysis

local new_obs = `nlexp'*`nlpunexp'*2

if `c(N)' < `new_obs' qui set obs `new_obs'

tempvar prz1 prz0 rrxz rrdz bias id

quietly {
gen `id' = .
gen `prz1' = .
gen `prz0' = .
gen `rrxz' = .
gen `rrdz' = .
gen `bias' = .
}

local i 1

foreach pz1 of local lpexp {

	foreach pz0 of local lpunexp {

				qui replace  `id' = `i' in `i'
				qui replace `prz1' = `pz1' in `i'
				qui replace `prz0' = `pz0' in `i'
				qui replace `rrxz' = [(`pz1')*(1-`pz0')]/[(1-`pz1')*(`pz0')] in `i'
			      scalar `rr' = (`arrdx') / [ (`pz1'*(`lrrcd'-1)+1 )/(`pz0'*(`lrrcd'-1)+1 ) ]
				qui replace `rrdz' = (`arrdx') / [ (`pz1'*(`lrrcd'-1)+1 )/(`pz0'*(`lrrcd'-1)+1 ) ] in `i'
				qui replace `bias' = (`arrdx'-`rr')/(`rr')*100 in `i'
				local `i' = `++i'
	}
}

// format

format `format' `prz1' `prz0'  `rrxz'  `rrdz' `bias'

// label variables

char `id'[varname]   "Nr."
char `prz1'[varname] "Pr C Exp"
char `prz0'[varname] "Pr C UnExp" 
char `rrxz'[varname] "OR E-C"
char `rrdz'[varname] "RR E-D"
char `bias'[varname] "Bias(%)"

list  `id' `prz1'  `prz0'  `rrxz'  `rrdz' `bias' if  `prz1' != . , subvarname sep(0) clean noobs
}


// Rule-out approach 

if "`rout'" != "" {

di _n _col(4) as text "Rule-out approach (Pr C Exp = " as res `format' `prz1'[1] as text ", Pr C UnExp = " as res `format' `prz0'[1] as text ")"
	
preserve 	
tempvar rrcdv rrdz1 diff
qui range `rrcdv' 0 50 1000
qui gen `rrdz1' = (`arrdx') / [ (`prz1'[1]*(`rrcdv'-1)+1 )/(`prz0'[1]*(`rrcdv'-1)+1 ) ]  
qui gen `diff' = abs(`rrdz1'-1)
qui su `diff' 
qui keep if `diff' == r(min)
tempname rrdzrule 
scalar `rrdzrule' = `rrcdv'[1]
  
if `rrdzrule' == 0 | `rrdzrule' == 50 {
	di _col(4) "The rule-out RR C-D is outside of the range(0, 50)"
}
else {
	di _col(4) "RR C-D = " as res `format' `rrdzrule' 
}

}

/*
tempvar rrcdv pc1v orecv 
 
qui range `rrcdv' 0 20 20

qui gen `pc1v' =  (`pe'-(`pe'*`pe')-(`pe'*`arrdx'*`pc'*`rrcdv')+(`pe'*`arrdx'*`pc')+(`arrdx'*(`pe'*`pe'))-`arrdx'*`pe')/((`arrdx'*`pe')-(`arrdx'*`pe'*`rrcdv')-`rrcdv'+1+(`pe'*`rrcdv')-`pe')
qui gen `orecv' = [ `pc1v'*(1-`pc'-`pe'+`pc1v') ] / [ (`pc'-`pc1v')*(`pe'-`pc1v') ]

qui replace `orecv' = . if  `orecv' < 0 

char  `rrcdv'[varname] "RR C-D"
char  `orecv'[varname] "OR C-E"

  format `rrcdv' `orecv' %3.2f 

 list  `rrcdv'   `orecv'  if  `orecv' != .  , subvarname sep(0) clean noobs
  format `rrcdv' `orecv'  %9.0g

// limit the range to 1 to 10 

tw scatter `orecv'  `rrcdv'  if `orecv' <= 10, c(l) ms(i)  xlabel(0(1)10, grid) ylabel(0(1)10, grid)   ///
 xtitle("RR Confounder-Disease") ytitle("OR Confounder-Exposure") xscale(range(0 10))  yscale(range(0 10)) aspect(1) ysize(4) xsize(4)
*/

 end

* episensrri 1.86 , pexp(0.6) punexp(.2) rrcd(1.5) ro

* episensrri 1.86 , pexp(0.6) punexp(.2) rrcd(1.5) ro(0.4 0.1)
* episensrri 1.57 , pexp(0.1) punexp(.01)  rrcd(2.5)  ro(0.01 0.1)
* episensrri 1.3  , pexp(0.1) punexp(.01)  rrcd(2.5)  ro(0.01 0.1)

