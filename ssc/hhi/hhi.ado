*Version August 2012
program drop _all
program define hhi
version 9
syntax varlist(min=1) [if] [in][, by(varlist) outfile , replace]
marksample touse

tokenize `if' `in'

tempvar rowmin
qui egen `rowmin'=rmin(`varlist')
qui sum `rowmin'
        if r(min)<0{
                display as error "Negative values in varlist"
                exit 198
                    }

foreach var of local varlist  {
tempvar pc
qui egen `pc'_`var' = pc(`var'), prop by(`by') , `if' `in'
qui egen hhi_`var' = sum(`pc'_`var'^2), by(`by') , `if' `in'
drop `pc'
}
if "`outfile'"=="outfile" { 
preserve
qui egen tag=tag(`by') `if' `in'
qui keep if tag==1 
qui outsheet `by' hhi_*  using "hhi.csv",comma `replace'
di in gr "output has been saved in default directory"
pwd
restore
}
end
