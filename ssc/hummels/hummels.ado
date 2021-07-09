*Version September 23, 2013

program drop _all
program define hummels
version 9
syntax varlist(max=1),j(varlist) m(varlist) i(varlist) [,by(varlist)  outfile  replace]

marksample touse

qui sum `varlist'
        if r(min)<0{
                display as error "Negative values in varlist"
                exit 198
                    }

tempvar imports bilat imports_cat w_imex total ratio im

*Total imports of country m
qui egen `imports' = sum(`varlist'), by(`m' `by')

*Bilateral Trade value
qui egen `bilat' = sum(`varlist'), by( `j' `m' `by' )

qui gen `ratio' =`bilat'/(`imports' - `bilat')

*Total imports of country m (category level)
egen  `imports_cat'=sum(`varlist'), by( `i' `m' `by')

*Rest of the world exports to J (for common set of products traded b/w J & M)
egen `w_imex'=sum(`imports_cat'- `varlist'), by( `j' `m' `by')

*Intensive Margin
qui gen `im'=`bilat'/`w_imex'
qui gen `varlist'_im=`im'
qui label var `varlist'_im "Hummels & Klenow Intensive Margin"

*Extensive Margin
qui gen `varlist'_em=`ratio'/`im'
qui label var `varlist'_em "Hummels & Klenow Extensive Margin"

if "`outfile'"=="outfile" { 
sort `j' `m' `by'
preserve
qui egen tag=tag(`j' `m' `by')
qui keep if tag==1 

qui outsheet `j' `m' `by' `varlist'_* using "HK_decompostion.csv",comma `replace'
di in gr "output has been saved in default directory"
pwd
restore
}
end
