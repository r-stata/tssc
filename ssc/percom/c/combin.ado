*Version August 2012

program drop _all
program define combin
version 9
syntax varlist(min=1 max=1) [if] [in] [, k(integer 5)]

foreach var of local varlist  {
capture count if `var'==.
capture count if `var'=="." | `var'==""
	if r(N) != 0 {
            di as err "missing values in varlist"
            exit 198
	}
}
foreach var of local varlist  {
capture duplicates report `var'
if  r(N) !=r(unique_value) {
	di as err "duplicate values in varlist"
           exit 198
}
}

marksample touse
 if `k'<2 |`k'>5 {
	di in re "k must be between 2 and 5, inclusive"
	exit 198
	}

qui describe `varlist'
 if `k'>r(N) {
	di in re "k must be less than or equal to N"
	exit 198
	}

foreach var of local varlist {
gen `var'_1=`var'
gen `var'_2=`var'

if `k'==3{
gen `var'_3=`var'
}
if `k'==4{
gen `var'_3=`var'
gen `var'_4=`var'
}
if `k'==5{
gen `var'_3=`var'
gen `var'_4=`var'
gen `var'_5=`var'
}
keep `var'_*
qui describe `var'_*
scalar k=r(k)
scalar N=r(N)
scalar list k N

qui fillin `var'_*
qui drop _fillin

tokenize `var'_1 `var'_2 `var'_3 `var'_4 `var'_5
            local first `1'
capture drop if  `1' >= `2' | `2' >= `3' | `3' >= `4' | `4' >= `5'
capture drop if  `1' >= `2' | `2' >= `3' | `3' >= `4'
capture drop if  `1' >= `2' | `2' >= `3'
capture drop if  `1' >= `2'
order `var'_*
sort `var'_*
scalar comb=comb(N, k)
display in yellow "Combinations Formed: " comb
scalar drop _all
}
end



