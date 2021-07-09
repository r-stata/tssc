********************************************************************************
* NON-PARAMETRIC SYNTHETIC CONTROL METHOD ("npsynth")
*! npsynth v9 - GCerulli 02/03/2020
********************************************************************************

********************************************************************************
* Application: parametric vs. nonparametric SCM
********************************************************************************
cd "/Users/cerulli/Dropbox/Giovanni/STATA - Commands - Giovanni/NPSYNTH" 
use Ita_exp_euro , clear
tsset reporter year
global xvars "ddva1 log_distw sum_rgdpna comlang contig"

* PARAMETRIC 
synth ddva1  $xvars , trunit(11) trperiod(2000) keep(SYNTH_data , replace) figure // ITA
*ereturn list

* NON-PARAMETRIC 
npsynth ddva1 $xvars , npscv n_grid(50) panel_var(reporter) time_var(year) trperiod(2000)  trunit(11) bandw(0.4) kern(triangular) gr1 gr2 gr3  ///
save_gr1(gr1) save_gr2(gr2) save_gr3(gr3) gr_y_name("Domestic Direct Value Added Export (DDVA)") gr_tick(5) save_res(NPSYNTH_data) 
*ereturn list

*

* TEST BETTER RMPSE OF NONPARAMETRIC SCM CLOSE TO THE TREATMENT TIME
preserve
use NPSYNTH_data , clear
keep year _Y0_ _Y1_
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
use NPSYNTH_data , clear
merge 1:1 year using SYNTH_data
keep if year < 2000 & year>=1996
br

gen DEV_gdp_synth=(_Y1_ - _y_0_synth)^2
qui sum DEV_gdp_synth
global RMSPE_gdp_synth=sqrt(r(mean))
*
gen DEV_gdp_npsynth=(_Y1_ - _y_0_npsynth)^2
qui sum DEV_gdp_npsynth
global RMSPE_gdp_npsynth=sqrt(r(mean))
*
di  $RMSPE_gdp_synth
di  $RMSPE_gdp_npsynth
********************************************************************************
