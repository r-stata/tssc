*! version 9.2  20oct2015 Author : Jay Dev Dubey 
*! input recieved by Pritam Datta,  (PHFI)


*The Ellison and Glaser's index; 


cap program drop egi
program define egi
version 9
syntax varlist(max=1), in(varlist) st(varlist) index(name)  [,mult(varlist) by(varlist)]


qui sum `varlist'
        if r(min)<0{
                display as error "Negative values in varlist"
                exit 198
                    }


if "`index'"!="EG" & "`index'"!="HHI" & "`index'"!="GI" {
di as err "Please select appropriate concentration index"
	exit 198
	}
if "`mult'"=="" {
tempvar mult
qui gen `mult' = 1
}

if "`by'"=="" {
tempvar by
qui gen `by' = 1 
}

tempvar sipc sipc1 Sist spc spc1 Sst Git pc pc1 pc2 Hit

*****Group wise total worker********
tempvar  alpha1 alpha2 alpha3 alpha4

qui egen `alpha1' = sum(`varlist'*`mult') , by(`in' `st' `by')
qui egen `alpha2' = sum(`varlist'*`mult') , by(`in' `by')
qui egen `alpha3' = sum(`varlist'*`mult') , by(`st' `by')
qui egen `alpha4' = sum(`varlist'*`mult') , by(`by')

*****Direct Ratios for Ss and Gi********
tempvar alpha12 alpha34

qui bysort `by': gen `alpha12' = `alpha1'/`alpha2'
qui bysort `by': gen `alpha34' = `alpha3'/`alpha4' 


********State Wise and total Ss********
tempvar alpha5 order1 Ss

qui bysort `by' :  gen `alpha5' = (`alpha34')^2 
qui  bysort `st' `by' : gen  `order1' = _n 
qui replace `order1' = 0 if `order1' > 1
qui replace `alpha5' = `alpha5'*`order1'
qui egen `Ss' = sum(`alpha5') , by(`by')

*******Calculation of Gi**********
tempvar Gdev order2 Gi GI

qui bysort `by' : gen `Gdev' = (`alpha12' - `alpha34')^2 
bysort `in' `st' `by' : gen `order2' = _n 
qui replace `order2' = 0 if `order2' > 1
qui replace `Gdev' = `Gdev'*`order2' 
qui egen `Gi' = sum(`Gdev') , by(`in' `by')
qui gen `GI' = `Gi'/(1-`Ss')
*su `GI'
************************************


********Herfindhal Style Index********
tempvar her1 her2 her3 HI

qui gen `her1' = `varlist'/`alpha2'
qui gen `her2' = (`her1')^2
qui gen `her3' = `her2'*`mult'
qui egen `HI' = sum(`her3') , by(`in' `by')

*********************

**********Final Step For GE index calculation***********

if "`index'"=="EG" {
qui gen `varlist'_GEI = (`GI'-`HI')/(1-`HI')
label var `varlist'_GEI "Ellison and Glaser's Index" 
}

if "`index'"=="HHI" {
qui gen `varlist'_HHI = `HI' 
label var `varlist'_HHI "Herfindhal style measure of plant level concentration" 
}

if "`index'"=="GI" {
qui gen `varlist'_GI = `Gi' 
label var `varlist'_GI "Sum of square deviation of industry - state employment share" 
}


end












