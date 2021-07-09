*Version April 10, 2013

program drop _all
program define ksi
version 9
syntax [,i(varname) j(varname) by(varlist),  outfile  replace]


marksample touse

tempvar rmin

qui egen `rmin'=rowmin(`i' `j')
qui sum `rmin', detail
    if r(min)<0 {
    display as error "Negative values in varlist"
    exit 198
   }

qui count if `i'==. | `j'==.
if r(N) != 0 {
            di as err "missing values in varlist"
            exit 198
	}

tempvar ishare refshare diff
qui egen `ishare'=pc(`i'), by(`by') prop
qui egen `refshare'=pc(`j'), by(`by') prop
gen `diff'=abs(`ishare'-`refshare')
qui egen `i'_ksi=sum(`diff'), by(`by')
capture sort `by'


if "`outfile'"=="outfile" { 
sort `by'
preserve
qui egen tag=tag(`by') 
qui keep if tag==1 

qui outsheet `by' `i'_ksi using "krugman_Index.csv",comma `replace'
di in gr "output has been saved in default directory"
pwd
restore
}
end
