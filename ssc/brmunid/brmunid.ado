
*! brmunid v11.3 A.Bigoni 8jul2019
capture program drop brmunid

program brmunid, sortpreserve
		version 10.1
		syntax varlist(max=1 numeric) [, SIXTOSEVEN]


qui if "`sixtoseven'" == "sixtoseven" {

preserve
findfile geocodetable.dta
use `r(fn)' , clear
rename geocodsi `varlist'
tempfile tempfile1
save `tempfile1'
restore

merge m:m `varlist' using `tempfile1', nogen

replace geocodci = `varlist' if geocodci ==.
replace geocodci = geocodci*10 if geocodci < 999999

rename geocodci padr_`varlist'
format %9.0g padr_`varlist'
noi di as result "New var padr_`varlist' created"
}

qui if "`sixtoseven'" != "sixtoseven" {
tempvar temp1
tempvar newmuncodes 

gen `newmuncodes' =.
gen `temp1' =int(`varlist'/10)
replace `newmuncodes' = `temp1' if `varlist' > 999999
replace `newmuncodes' = `varlist' if `varlist' < 999999

gen padr_`varlist' = `newmuncodes'

noi di as result "New var padr_`varlist' created"
}


end
