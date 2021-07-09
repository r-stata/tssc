********************************************************************************
* NON-PARAMETRIC SYNTHETIC CONTROL METHOD ("npsynth")
*! npsynth v10 - GCerulli 03/03/2020
********************************************************************************

********************************************************************************
* SIMULATION OF "npsynth"
********************************************************************************
clear
set obs 20
set seed 101
drawnorm e
********************************************************************************
generate x1_1=invnorm(uniform())
generate x2_1=invnorm(uniform())
generate x3_1=invnorm(uniform())
********************************************************************************
generate x1_2=invnorm(uniform())
generate x2_2=invnorm(uniform())
generate x3_2=invnorm(uniform())
********************************************************************************
generate x1_3=invnorm(uniform())
generate x2_3=invnorm(uniform())
generate x3_3=invnorm(uniform())
********************************************************************************
generate x1=invnorm(uniform())+x1_1^2+abs(x2_1)^(0.5)+x3_1^3
generate x2=invnorm(uniform())+exp(x1_2)+exp(1/x2_2)+(x3_2)^(2)
generate x3=invnorm(uniform())+(x1_3)/x2_3+exp(x2_3)+(x3_3)^(-5)
********************************************************************************
drop in 9
drop in 13
drop in 5
********************************************************************************
generate y1=x1+x2+x3+e
gen year=2000+_n-1
tw (connected y1 year , xlabel(2000(5)2016))
********************************************************************************
generate y0=y1 if year<=2010
replace y0=-100+x1+x2^0.7+ln(abs(x3))+e if year>2010
gen y=y1
gen id=1
********************************************************************************
gen y_1=y1+rnormal(0,2) if year<=2010
replace y_1=-100+x1+x2^0.7+ln(abs(x3))+rnormal(15,30) if year>2010
********************************************************************************
gen y_2=y1+rnormal(0,3) if year<=2010
replace y_2=-100+x1+x2^0.7+ln(abs(x3))+rnormal(10,15) if year>2010
********************************************************************************
gen y_3=y1+rnormal(0,4) if year<=2010
replace y_3=-100+x1+x2^0.7+ln(abs(x3))+rnormal(5,10) if year>2010
drop if year==2007
replace year=2000+_n-1
gen TE=y1-y0
order id year y y1 y0 TE
********************************************************************************
sort year
tw (connected y1 year , sort(year)) (connected y0 year , sort(year) lp(dash)) , ///
xline(2009 , lp(solid)) scheme(s2mono) ///
legend(label(1 "Factual") label(2 "Counterfactual"))

line TE year , sort(year) xline(2009 , lp(solid)) ylabel(-150(50)200) scheme(s1mono) 
********************************************************************************
tw (line y year) (line y_1 year) (line y_2 year) (line y_3 year) , xline(2009 , lp(solid)) scheme(s2mono) ///
legend(label(1 "Treated") label(2 "Donor 1") label(3 "Donor 2") label(4 "Donor 3"))
********************************************************************************
preserve
keep year y0 
rename y0 _y_0_dgp 
save DGP , replace
restore
********************************************************************************
gen id_1=2
gen id_2=3
gen id_3=4
********************************************************************************
order id year y x1 x2 x3 ///
id_1 y_1 x1_1 x2_1 x3_1  ///
id_2 y_2 x1_2 x2_2 x3_2  ///
id_3 y_3 x1_3 x2_3 x3_3  
********************************************************************************
keep id year y x1 x2 x3 ///
id_1 y_1 x1_1 x2_1 x3_1  ///
id_2 y_2 x1_2 x2_2 x3_2  ///
id_3 y_3 x1_3 x2_3 x3_3  
********************************************************************************
save data , replace
********************************************************************************
preserve
keep id year y x1 x2 x3
save data , replace
restore
********************************************************************************
preserve
keep id_1 year y_1 x1_1 x2_1 x3_1
rename id_1 id
rename y_1 y
rename x1_1 x1
rename x2_1 x2
rename x3_1 x3
save data1, replace
restore
********************************************************************************
preserve
keep id_2 year y_2 x1_2 x2_2 x3_2
rename id_2 id
rename y_2 y
rename x1_2 x1
rename x2_2 x2
rename x3_2 x3
save data2 , replace
restore
********************************************************************************
preserve
keep id_3 year y_3 x1_3 x2_3 x3_3
rename id_3 id
rename y_3 y
rename x1_3 x1
rename x2_3 x2
rename x3_3 x3
save data3 , replace
restore
********************************************************************************
use data , clear
append using data1 data2 data3
********************************************************************************

tsset id year
global xvars "x1 x2 x3"

* PARAMETRIC 
synth y  $xvars , trunit(1) trperiod(2009) figure keep(SYNTH_data , replace)

* NON-PARAMETRIC 
label define LAB 1 "ITALY" 2 "GERMANY" 3 "FRANCE" 4 "UK"  , replace
label val id LAB
npsynth y $xvars ,  npscv panel_var(id) time_var(year) trperiod(2009)  trunit(1) bandw(1.55) kern(triangular) gr1 gr2 gr3  ///
save_gr1(gr1) save_gr2(gr2) save_gr3(gr3) gr_y_name("graph") gr_tick(5) save_res(NPSYNTH_data) 
ereturn list

*
preserve
use NPSYNTH_data , clear
keep year _Y0_
rename _Y0_ _y_0_npsynth
save NPSYNTH_data , replace
restore
*
preserve
use SYNTH_data , clear
keep _Y_synthetic _time
rename _time year
rename _Y_synthetic _y_0_synth
save SYNTH_data , replace
restore
*
use DGP , clear
merge 1:1 year using SYNTH_data
cap drop _merge
merge 1:1 year using NPSYNTH_data
*
tw (line _y_0_dgp year) (line _y_0_synth year) (line _y_0_npsynth year) if year>=2009 , scheme(s2mono) ///
legend(label(1 "DGP") label(2 "SYNTH") label(3 "NPSYNTH")) xlabel(2009(1)2015)
*
gen DEV_gdp_synth=(_y_0_dgp - _y_0_synth)^2
qui sum DEV_gdp_synth
global RMSPE_gdp_synth=sqrt(r(mean))
*
gen DEV_gdp_npsynth=(_y_0_dgp - _y_0_npsynth)^2
qui sum DEV_gdp_npsynth
global RMSPE_gdp_npsynth=sqrt(r(mean))
*
di  $RMSPE_gdp_synth
di  $RMSPE_gdp_npsynth
********************************************************************************
