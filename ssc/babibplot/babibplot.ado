**
*! babibplot v2 Lutz Bornmann October 2017
program def babibplot, rclass
version 11
syntax varlist(min=2 max=2 numeric) [if] [in], plot(string)
marksample touse
quietly count if `touse'
if `r(N)' == 0 {
	error 2000
	}
local journal: word 1 of `varlist'
local paper: word 2 of `varlist'
quietly count if `journal' ~= . & `paper' ~=. & `touse'
display r(N) " papers without missings are considered in the plot"
quietly gen diff =  `paper' - `journal'
quietly gen diff_top_10=diff if `paper'>=90
quietly gen diff_bot_90=diff if `paper'<90
quietly gen avg = (`paper' + `journal')/2 if `touse'
quietly summarize `journal' if `touse'
local obs = r(N)

quietly gen over = 1 if diff >= 0
quietly replace over = 0 if diff < 0
quietly count if over == 1 & `touse'
local nr1 = r(N)
local nr1p = round(`nr1' / `obs' * 100)
quietly count if over == 0 & `touse'
local nr2 = r(N)
local nr2p = round(`nr2' / `obs' * 100)

quietly gen over_2 = 1 if avg >= 50
quietly replace over_2 = 0 if avg < 50
quietly count if over_2 == 1 & `touse'
local nc1 = r(N)
local nc1p = round(`nc1' / `obs' * 100)
quietly count if over_2 == 0 & `touse'
local nc2 = r(N)
local nc2p = round(`nc2' / `obs' * 100)
quietly egen over_3 = group(over over_2), label
quietly by over_3, sort: egen diff_over_3=median(diff) if `touse'
quietly by over_3, sort: egen avg_over_3=median(avg) if `touse'

quietly summarize over if over==1 & over_2==1 & `touse'
local nq1 = r(N)
local nq1p = round(`nq1' / `obs' * 100)
local nq4 = `nc1' - `nq1'
local nq4p = round(`nq4' / `obs' * 100)
local nq2 = `nr1' - `nq1'
local nq2p = round(`nq2' / `obs' * 100)
local nq3 = `nc2' - `nq2'
local nq3p = round(`nq3' / `obs' * 100)

quietly gen over_4 = 4
quietly replace over_4 = 1 if `paper'>=50 & `journal'>=50
quietly replace over_4 = 2 if `paper'>=50 & `journal'<50
quietly replace over_4 = 3 if `paper'<50 & `journal'<50
quietly by over_4, sort: egen p_over_4=median(`paper') if `touse'
quietly by over_4, sort: egen j_over_4=median(`journal') if `touse'
quietly count if over_4==1 & `touse'
local nq1s = r(N)
local nq1ps = round(`nq1s' / `obs' * 100)
quietly count if over_4==4 & `touse'
local nq2s = r(N)
local nq2ps = round(`nq2s' / `obs' * 100)
quietly count if over_4==3 & `touse'
local nq3s = r(N)
local nq3ps = round(`nq3s' / `obs' * 100)
quietly count if over_4==2 & `touse'
local nq4s = r(N)
local nq4ps = round(`nq4s' / `obs' * 100)

local nc1s = `nq1s' + `nq4s'
local nc1ps = round(`nc1s' / `obs' * 100)
local nc2s = `nq2s' + `nq3s'
local nc2ps = round(`nc2s' / `obs' * 100)
local nr1s = `nq1s' + `nq2s'
local nr1ps = round(`nr1s' / `obs' * 100)
local nr2s = `nq3s' + `nq4s'
local nr2ps = round(`nr2s' / `obs' * 100)


if "`plot'" == "average" {

quietly summarize diff if `touse', detail
local d_diff = r(p50)
quietly summarize avg if `touse', detail
local d_avg = r(p50)
quietly twoway (scatter diff_top_10 avg, msymbol(Oh t) mcolor(black)) /*
*/ (scatter diff_bot_90 avg, mcolor(black)) /*
*/ (scatter diff_over_3 avg_over_3, msymbol(Sh) mcolor(red)), /*
*/ xline(50) yline(`d_diff', lpattern(dash)) yline(0) xlabel(0(10)100) /*
*/ xline(`d_avg', lpattern(dash)) ylabel(-100(20)100) /*
*/ l1title("Higher journal impact        Higher paper impact") /*
*/ l2title("Difference(paper impact - journal impact)") /*
*/ b1title("Low impact                                      High impact") /*
*/ b2title("Average of paper impact and journal impact") /*
*/ t2title("n{subscript:c2}=`nc2'; `nc2p'%                                               n{subscript:c1}=`nc1'; `nc1p'%") /*
*/ r2title("n{subscript:r2}=`nr2'; `nr2p'%                              n{subscript:r1}=`nr1'; `nr1p'%")/*
*/ text(100 40 "n{subscript:q2}=`nq2'; `nq2p'%", size(small)) /*
*/ text(100 62 "n{subscript:q1}=`nq1'; `nq1p'%", size(small)) /*
*/ text(-100 40 "n{subscript:q3}=`nq3'; `nq3p'%", size(small)) /*
*/ text(-100 62 "n{subscript:q4}=`nq4'; `nq4p'%", size(small)) /*
*/ legend(off) xtitle(" ")
quietly drop diff diff_top_10 diff_bot_90 avg over over_2 over_3 diff_over_3 avg_over_3 over_4 p_over_4 j_over_4
}


if "`plot'" == "scatter" {
quietly summarize `journal' if `touse', detail
local jou = r(p50)
quietly summarize `paper' if `touse', detail
local pap = r(p50)
twoway (scatter `journal' `paper' if `touse') (function x, range(0 100) lcolor(cranberry)) /*
*/ (scatter j_over_4 p_over_4, msymbol(Sh) mcolor(red)), /*
*/ xline(50) yline(50) xlabel(0(10)100) /*
*/ yline(`jou', lpattern(dash)) xline(`pap', lpattern(dash)) /*
*/ ylabel(0(10)100) xtitle("Paper impact") ytitle("Journal impact") /*
*/ legend(off) /*
*/ text(52 97 "n{subscript:q1}=`nq1s'; `nq1ps'%", size(vsmall)) /*
*/ text(48 97 "n{subscript:q4}=`nq4s'; `nq4ps'%", size(vsmall)) /*
*/ text(48 3 "n{subscript:q3}=`nq3s'; `nq3ps'%", size(vsmall)) /*
*/ text(52 4 "n{subscript:q2}=`nq2s'; `nq2ps'%", size(vsmall)) /*
*/ t2title("n{subscript:c2}=`nc2s'; `nc2ps'%                                             n{subscript:c1}=`nc1s'; `nc1ps'%") /*
*/ r2title("n{subscript:r2}=`nr2s'; `nr2ps'%                        n{subscript:r1}=`nr1s'; `nr1ps'%")
quietly drop diff diff_top_10 diff_bot_90 avg over over_2 over_3 diff_over_3 avg_over_3 over_4 p_over_4 j_over_4
}


if ("`plot'" ~= "scatter") & ("`plot'" ~= "average") {
display "The plot option must be 'scatter' or 'average'"
quietly drop diff diff_top_10 diff_bot_90 avg over over_2 over_3 diff_over_3 avg_over_3 over_4 p_over_4 j_over_4
}

end

