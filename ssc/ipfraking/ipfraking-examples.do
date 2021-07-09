* Examples for ipfraking article -- Stas Kolenikov

clear
discard
set more off
set rmsg off

version 10

* Example 1: general input requirements
sjlog using ipfr.example1.prep, replace
webuse nhanes2, clear
generate byte _one = 1

svy : total _one , over( sex, nolabel )
matrix NHANES2_sex = e(b)
matrix rownames NHANES2_sex = sex

svy : total _one , over( race, nolabel )
matrix NHANES2_race = e(b)
matrix rownames NHANES2_race = race

matrix NHANES2_sex[1,1] = NHANES2_sex[1,1]*1.25
matrix NHANES2_race[1,1] = NHANES2_race[1,1]*1.4

sjlog close, replace

sjlog using ipfr.example1.list, replace
matrix list NHANES2_sex, f(%12.0g)
matrix list NHANES2_race, f(%12.0g)
sjlog close, replace

sjlog using ipfr.example1.run, replace
ipfraking [pw=finalwgt], ctotal( NHANES2_sex NHANES2_race ) gen( rakedwgt1 )
sjlog close, replace

graph export ipfraking_example1.eps, replace

* Example 2: define variables and matrices
sjlog using ipfr.example2.prep, replace
generate byte age_grp = 1 + (age>=40) + (age>=60) if !mi(age)
generate sex_age = sex*10 + age_grp
sjlog close, replace

sjlog using ipfr.example2.mat, replace
matrix ACS2011_sex_age = ( ///
    153267860*0.274, 153267860*0.275, 153267860*0.173, /// males
    158324057*0.260, 158324057*0.276, 158324057*0.207  /// females
)
matrix colnames ACS2011_sex_age = 11 12 13 21 22 23
matrix coleq    ACS2011_sex_age = _one
matrix rownames ACS2011_sex_age = sex_age

scalar ACS2011_total_pop = 311591917
matrix ACS2011_adult_pop = ACS2011_sex_age * J(colsof(ACS2011_sex_age),1,1)

matrix Census2011_region = ///
    (55521598, 67158835, 116046736, 72864748 )
matrix Census2011_region = Census2011_region * ACS2011_adult_pop / ACS2011_total_pop
matrix colnames Census2011_region = 1 2 3 4
matrix coleq    Census2011_region = _one
matrix rownames Census2011_region = region

matrix Census2011_race = ///
    (243470497, 40750746, 27370674 )
matrix Census2011_race = Census2011_race * ACS2011_adult_pop / ACS2011_total_pop
matrix colnames Census2011_race = 1 2 3
matrix coleq    Census2011_race = _one
matrix rownames Census2011_race = race
sjlog close, replace

sjlog using ipfr.example2.list, replace
matrix list ACS2011_sex_age, f(%10.0g)
matrix list Census2011_region, f(%10.0g)
matrix list Census2011_race, f(%11.0g)
sjlog close, replace

sjlog using ipfr.example2.run, replace
ipfraking [pw=finalwgt], gen( rakedwgt2 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race )
sjlog close, replace

graph export ipfraking_example2.eps, replace

* Example 3: trimming
sjlog using ipfr.example3.trimabs, replace
ipfraking [pw=finalwgt], gen( rakedwgt3 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs( 200000 ) trimloabs( 2000 )
sjlog close, replace

graph export ipfraking_example3_abs.eps, replace

sjlog using ipfr.example3.trimsum, replace
sum finalwgt
ipfraking [pw=finalwgt], gen( rakedwgt4 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs(`=2.5*r(max)') trimloabs(`=r(min)') trimhirel(6)
sjlog close, replace

graph export ipfraking_example3_sum.eps, replace

* Example 4: tracking convergence
sjlog using ipfr.example4.sometimes, replace
capture drop rakedwgt3
ipfraking [pw=finalwgt], gen( rakedwgt3 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs(200000) trimloabs(2000) trimfreq(sometimes) trace
sjlog close, replace

graph export ipfraking_example4_sometimes.eps, replace

sjlog using ipfr.example4.often, replace
ipfraking [pw=finalwgt], gen( rakedwgt5 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs(200000) trimloabs(2000) trimfreq(often) trace
compare rakedwgt3 rakedwgt5
sjlog close, replace

graph export ipfraking_example4_often.eps, replace

* Example 5: metadata
sjlog using ipfr.example5, replace
capture drop rakedwgt3
ipfraking [pw=finalwgt], gen( rakedwgt3 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) ///
    trimhiabs(200000) trimloabs(2000) meta
char li rakedwgt3[]
sjlog close, replace

* Example 6: replicate weights
sjlog using ipfr.example6.bsw, replace
set rmsg on
set seed 2013
bsweights bsw , reps(310) n(-1) balanced dots ///
    calibrate( ipfraking [pw=@], replace nograph meta ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race ) )
forvalues k=1/310 {
    _dots `k' 0
    assert `: char bsw`k'[converged]' == 1
    assert `: char bsw`k'[maxctrl]' < 10*c(epsfloat)
}
svyset [pw=rakedwgt2], vce(bootstrap) bsrw( bsw* ) dof( 31 )
set rmsg off
sjlog close, replace

sjlog using ipfr.example6.brr, replace
webuse nhanes2brr, clear
svy : proportion highbp
generate byte _one = 1
generate byte age_grp = 1 + (age>=40) + (age>=60) if !mi(age)
generate sex_age = sex*10 + age_grp
ipfraking [pw=finalwgt], gen( rakedwgt2 ) ///
    ctotal( ACS2011_sex_age Census2011_region Census2011_race )
forvalues k=1/32 {
    quietly ipfraking [pw=brr_`k'], gen( brrc_`k' ) nograph ///
        ctotal( ACS2011_sex_age Census2011_region Census2011_race )
    _dots `k' 0
}
svyset [pw=rakedwgt2], vce(brr) brrw( brrc* ) dof( 31 )
svy : proportion highbp
sjlog close, replace

********************************************* UPDATE

sjlog using ipfr.whatsdeff, replace
webuse nhanes2, clear
whatsdeff finalwgt
return list
whatsdeff finalwgt, by(sex)
return list
sjlog close, replace

sjlog using ipfr.report1, replace
ipfraking_report using rakedwgt3-report, raked_weight(rakedwgt3) replace by(_one)
sjlog close, replace

sjlog using ipfr.report2, replace
use rakedwgt3-report, clear
list C_Total_Margin_Variable_Name C_Total_Margin_Category_Label ///
	Category_Total_Target Category_Total_RKDWGT DEFF_SRCWGT DEFF_RKDWGT , ///
	sepby( C_Total_Margin_Variable_Name )
sjlog close, replace

sjlog using ipfr.collapse1, replace
clear
set obs 4
gen byte x = _n
label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"
label values x x_lbl
wgtcellcollapse define, var(x) from(1 2 3) to(123)
wgtcellcollapse report, var(x)
sjlog close, replace

sjlog using ipfr.collapse2, replace
wgtcellcollapse report, var(x) break
wgtcellcollapse define, var(x) clear
wgtcellcollapse define, var(x) from(1 2 3) to(123) label("One through three")
wgtcellcollapse report, var(x) break
sjlog close, replace

sjlog using ipfr.collapse3, replace
clear
set obs 4
gen byte x = _n
label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"
label values x x_lbl
wgtcellcollapse sequence, var(x) from(1 2 3 4) depth(3)
wgtcellcollapse report, var(x)
sjlog close, replace

sjlog using ipfr.collapse4, replace
wgtcellcollapse candidate, var(x) cat(2)
sreturn list
wgtcellcollapse candidate, var(x) cat(2) max(9)
sreturn list
wgtcellcollapse candidate, var(x) cat(212)
sreturn list
wgtcellcollapse candidate, var(x) cat(55)
sreturn list
sjlog close, replace

clear
set obs 4
gen byte x = _n
label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"
label values x x_lbl
sjlog using ipfr.collapse5, replace
wgtcellcollapse define, var(x) clear
wgtcellcollapse sequence, var(x) from(2 4 1 3) depth(2)
wgtcellcollapse report, var(x)
sjlog close, replace

exit
