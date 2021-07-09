*! version 1.0, Chao Wang, 25/09/2018
program geninteract

version 13.1
syntax varlist(min=2 numeric) [, n(integer 2) Separate(string) max(integer -1)]

if (missing(`"`separate'"')) {
        local separate "_"
    }
    
if `n'<2 | `n'>wordcount("`varlist'") {
 di "{err}Value of n not valid"
 exit
}

preserve
clear
local numberofvars=wordcount("`varlist'")

quietly {
 set obs 1
 generate str inputvar = word("`varlist'",1) in 1

 forvalues i=2/`numberofvars' {
  set obs `i'
  replace inputvar = word("`varlist'",`i') in `i'
 }
}

encode inputvar, gen(var1)

forvalues i=2/`n' {
 gen var`i'=var1
 label values var`i' var1
}
fillin var*

// remove duplicates
quietly sum var1
forvalues i=1/`r(max)' {
 egen count`i'=anycount(var*), values(`i')
 quietly drop if count`i'>=2
}

quietly duplicates drop count*, force
drop count* _fillin inputvar

forvalues i=1/`n' {
 decode var`i', gen(v`i')
 drop var`i'
 quietly gen term`i'=real(word(subinstr(v`i',"_"," ",.),-1))
 quietly gen originalvarname`i'=substr(v`i',1,strrpos(v`i',"_")-1)
}

if (`max'>0) {
        quietly egen diff=diff(originalvarname*)
		quietly drop if diff==0
		quietly egen term_overall=rowtotal(term*)
		quietly drop if term_overall>`max'
    }

egen outvarname=concat(v*), punct("`separate'")
egen formula1=concat(v*), punct("*")
gen formula=outvarname+"="+formula1

quietly levelsof formula, local(formulas) clean
// quietly count

restore

/*
forvalues i=1/`r(N)' {
 local f=word("`formulas'",`i')
 gen `f'
}
*/

foreach f of local formulas {
 gen `f'
}
end
