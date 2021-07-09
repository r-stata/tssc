**************************************
**          Sylvain Weber           **
**     University of Neuchâtel      **
**  Institute of Economic Research  **
**   mail: sylvain.weber@unine.ch   **
**    This version: Nov 12, 2012    **
**************************************


*! version 1.0 Sylvain Weber 12nov2012
program tdpd, rclass
version 8.0



**************************************************************************************
*** Program solving the third-degree price discriminating (tdpd) monopoly problem  ***
**************************************************************************************

syntax anything(name=param), [invd]

/*
Syntax: tdpd a1 b1 a2 b2 c1 c2 c3, [invd]

Compulsory arguments: a1, b1, a2, b2, c1, c2, c3
         ai and bi define the equation of the demand for the ith category of consumers: Qi = ai - biPi, i = 1,2
	 c1, c2 and c3 define the equation of the total cost: TC = c1 + c2Q + c3Q^2

Option: invd is used if the inverse demand equations [Pi = f(Qi)] are introduced instead of the direct demands 
	[Qi = f(Pi)]: Pi = ai - biQi --> Qi = ai/bi - 1/biPi, i = 1,2
*/

gettoken a1 param : param
gettoken b1 param : param
gettoken a2 param : param
gettoken b2 param : param
gettoken c1 param : param
gettoken c2 param : param
gettoken c3 param : param



*******************************************
*** Tests on the validity of parameters ***
*******************************************

foreach x in `a1' `b1' `a2' `b2' `c1' `c2' `c3' {
	capture confirm number `x'
	if _rc!=0 {
		di as error "All arguments must be numerical."
		exit 109
	}
}
capture confirm existence `c3'
if _rc!=0 {
	di as error "The number of arguments to give is 7."
	exit 102
}
if "`param'" != "" {
	di as error "The number of arguments to give is 7."
	exit 103
}
if `a1'<=0 | `b1'<=0 | `a2'<=0 | `b2'<=0 {
	di as err "Arguments a1, b1, a2 and b2 must be positive."
	exit
}
if `c1'<0 | `c2'<0 | `c3'<0 {
	di as err "Arguments c1, c2 and c3 must be non-negative."
	exit
}



***********************************
*** Relabeling of the arguments ***
***********************************

if "`invd'"!="invd" {
	local aq1 = `a1'
	local bq1 = `b1'
	local aq2 = `a2'
	local bq2 = `b2'
	local ap1 = `a1'/`b1'
	local bp1 = 1/`b1'
	local ap2 = `a2'/`b2'
	local bp2 = 1/`b2'
}
if "`invd'"=="invd" {
	local ap1 = `a1'
	local bp1 = `b1'
	local ap2 = `a2'
	local bp2 = `b2'
	local aq1 = `a1'/`b1'
	local bq1 = 1/`b1'
	local aq2 = `a2'/`b2'
	local bq2 = 1/`b2'
}



******************************************
*** Definition of necessary parameters ***
******************************************

local aqmax = max(`aq1',`aq2')
local aqtot = `aq1'+`aq2'
local aqtot2 = `aqtot'/2
local bqtot = `bq1'+`bq2'
local apmax = max(`ap1',`ap2')
local apmin = min(`ap1',`ap2')
local aptot = (`aq1'+`aq2')/(`bq1'+`bq2')
local bptot = 1/(`bq1'+`bq2')
local 2bptot = 2*`bptot'
local mcmax = `c2'+2*`c3'*`aqtot'
if `mcmax'>`apmax' {
	local mcmax=`apmax'
}
local qmcmax = (`mcmax'-`c2')/(2*`c3')
if `c3'==0 {
	local qmcmax = `aqtot'
}
local qsupind = 1.1*`aqmax'
local qsuptot = 1.1*`aqtot'
local psup = 1.1*`apmax'
local aq12 = `aq1'/2
local aq22 = `aq2'/2

local bpmax = `bp1'
local bqmax = `bq1'
local qcross = `aq1'-`bq1'*`ap2'
if `ap2'>`ap1' {
	local bpmax = `bp2'
	local bqmax = `bq2'
	local qcross = `aq2'-`bq2'*`ap1'
}
local 2bpmax = 2*`bpmax'
local 2bp1 = 2*`bp1'
local 2bp2 = 2*`bp2'
local qcross2 = `qcross'/2
local pgapdn = `apmax'-2*`bpmax'*`qcross'
local pgapup = `aptot'-2*`bptot'*`qcross'



***********************************************************
*** Equilibrium of the market WITH price discrimination ***
***********************************************************

local qtot = ((`ap1'*`bp2'+`ap2'*`bp1')/(`bp1'+`bp2')-`c2')/(2*`bp1'*`bp2'/(`bp1'+`bp2')+2*`c3')
local MC = `c2'+2*`c3'*`qtot'

if `MC'>=`apmin' {
	local qtot = (`apmax'-`c2')/(2*`bpmax'+2*`c3')
}
local MC = `c2'+2*`c3'*`qtot'

local q1 = max(0,(`ap1'-`MC')/(2*`bp1'))
local q2 = max(0,(`ap2'-`MC')/(2*`bp2'))
local p1 = `ap1'-`bp1'*`q1'
local p2 = `ap2'-`bp2'*`q2'
local TR1 = `p1'*`q1'
local TR2 = `p2'*`q2'
local TR = `TR1'+`TR2'
local TC = `c1'+`c2'*`qtot'+`c3'*`qtot'^2
local profit = `TR'-`TC'
local ep1 = -`bq1'*`p1'/`q1'
local ep2 = -`bq2'*`p2'/`q2'
if `q1'==0 {
	local p1=.
	local ep1=.
}
if `q2'==0 {
	local p2=.
	local ep2=.
}



**************************************************************
*** Equilibrium of the market WITHOUT price discrimination ***
**************************************************************

local qnda = ((`ap1'*`bp2'+`ap2'*`bp1')/(`bp1'+`bp2')-`c2')/(2*`bp1'*`bp2'/(`bp1'+`bp2')+2*`c3')
local MCnda = `c2'+2*`c3'*`qnda'

local qndb = (`apmax'-`c2')/(2*`bpmax'+2*`c3')
local MCndb = `c2'+2*`c3'*`qndb'

if `MCnda'>=`pgapup' {
	local qnd = `qndb'
	local pnd = `apmax'-`bpmax'*`qnd'

}

if `MCndb'<`pgapdn' {
	local qnd = `qnda'
	local pnd = `aptot'-`bptot'*`qnd'
}


if `MCnda'<`pgapup'&`MCndb'>=`pgapdn' {
	local pnda = `aptot'-`bptot'*`qnda'
	local pndb = `apmax'-`bpmax'*`qndb'
	local TRa = `pnda'*`qnda'
	local TRb = `pndb'*`qndb'
	local TCa = `c1'+`c2'*`qnda'+`c3'*`qnda'^2
	local TCb = `c1'+`c2'*`qndb'+`c3'*`qndb'^2
	local profita = `TRa'-`TCa'
	local profitb = `TRb'-`TCb'
	if `profita' >= `profitb' {
		local qnd = `qnda'
		local pnd = `pnda'
	}
	if `profita' < `profitb' {
		local qnd = `qndb'
		local pnd = `pndb'
	}	
}


local TRnd = `pnd'*`qnd'
local TCnd = `c1'+`c2'*`qnd'+`c3'*`qnd'^2
local MCnd = `c2'+2*`c3'*`qnd'
local profitnd = `TRnd'-`TCnd'

local qnd1 = max(0,`aq1'-`bq1'*`pnd')
local mrnd1 = `ap1'-2*`bp1'*`qnd1'
local qnd2 = max(0,`aq2'-`bq2'*`pnd')
local mrnd2 = `ap2'-2*`bp2'*`qnd2'


************************************
*** Print the starting equations ***
************************************

#d ;
foreach x in 	qtot TR TC profit MC q1 p1 TR1 ep1 q2 p2 TR2 ep2 qnd qnd1 mrnd1 qnd2 mrnd2 
		pnd TRnd TCnd profitnd MCnd pgapup pgapdn 
		aq1 bq1 ap1 bp1 aq2 bq2 ap2 bp2 aqmax bqmax apmin aqtot bqtot apmax bpmax 
		aptot bptot qcross qcross2 ap12 aq12 ap22 aq22 aqtot2 2bp1 2bp2 2bpmax 2bptot {; 
	local r_`x' = string(round(``x'',.01));
};
#d cr

di as input _n(3) "Demand + Marginal revenue equations:"
di as txt _dup(60) "-"
di as txt "Demand 1:" _col(25) as res "Q1 = " `r_aq1' " - " `r_bq1' "P1"
di as txt "Inverse demand 1:" _col(25) as res "P1 = " `r_ap1' " - " `r_bp1' "Q1"
di as txt "Marginal revenue 1:" _col(25) as res "MR1 = " `r_ap1' " - " `r_2bp1' "Q1"
di as txt _dup(60) "-"
di as txt "Demand 2:" _col(25) as res "Q2 = " `r_aq2' " - " `r_bq2' "P2"
di as txt "Inverse demand 2:" _col(25) as res "P2 = " `r_ap2' " - " `r_bp2' "Q2"
di as txt "Marginal revenue 2:" _col(25) as res "MR2 = " `r_ap2' " - " `r_2bp2' "Q2"
di as txt _dup(60) "-"
di as txt "Total Demand:" _col(25) as res "Qtot = " `r_aqmax' " - " `r_bqmax' "P if P>" `r_apmin'
di as txt "(Simple monopoly)" _col(32) as res `r_aqtot' " - " `r_bqtot' "P if P<=" `r_apmin'
di as txt "Total inverse demand:" _col(25) as res "P = " `r_apmax' " - " `r_bpmax' "Qtot if Qtot<" `r_qcross'
di as txt "(Simple monopoly)" as res _col(29) `r_aptot' " - " `r_bptot' "Qtot if Qtot>=" `r_qcross'
di as txt _dup(60) "-"
di as txt "Total marginal revenue:" 
di as txt _col(3) "1. Discriminating" as res _col(25) "MRtot = " `r_apmax' " - " `r_2bpmax' "Qtot if Qtot<" `r_qcross2'
di as txt _col(6) "monopoly:" as res _col(33) `r_aptot' " - " `r_2bptot' "Qtot  if Qtot>=" `r_qcross2'
di as txt _col(3) "2. Non-discriminating" as res _col(25) "MRtot = " `r_apmax' " - " `r_2bpmax' "Qtot if Qtot<" `r_qcross'
di as txt _col(6) "monopoly:" as res _col(33) `r_aptot' " - " `r_2bptot' "Qtot  if Qtot>=" `r_qcross'
di as txt "{hline 60}"

di as input _n(3) "Cost equations:"
di as txt _dup(60) "-"
di as txt "Total cost:" _col(25) as res "TC = " `c1' " + " `c2' "Q + " `c3' "Q^2"
di as txt "Marginal cost:" _col(25) as res "MC = " `c2' " + " 2*`c3' "Q"
di as txt "{hline 60}"


if `apmax' <= `c2' {
	di as err "No equilibrium on this market: Costs too high compared to demand."
	di as err "See graph."

	local mcmax = `c2' + 2*`c3'*`aqtot'
	local psup = 1.1*`mcmax'
	#d ;
	tw fun y = `apmax' - `bpmax'*x, range(0 `qcross') lc(blue) lw(*2)
	|| fun y = `aptot' - `bptot'*x, range(`qcross' `aqtot') lc(blue) lw(*2)
	|| fun y = `c2' + 2*`c3'*x, range(0 `qsuptot') lc(red) lw(*2)
	|| pcarrowi 0 0 0 `qsuptot' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci `apmin' 0 `apmin' `qcross' 0 `qcross' `apmin' `qcross', lc(gs0) lp(-) lw(*.5)
	xti("Qtot", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsuptot')) 
	yti("P," "MR," "MC", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(0 `aqtot' "Dtot", place(ne) c(blue) size(large) m(b=1))
	text(`mcmax' `aqtot' "MC", place(se) c(red) size(large) m(t=1))
	text(`c2' 0 "`c2'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(0 `qcross' "`r_qcross'", place(s) m(t=1))
	text(0 `aqtot' "`r_aqtot'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off);
	#d cr
	exit
}



*************************
*** Print the results ***
*************************

di as input _n(3) "Market equilibrium with price discrimination:"
di as txt _dup(60) "-"
di as input "Total market:"
di as txt "Total quantity:" _col (25) as res "Qtot = "`r_qtot'
di as txt "Total revenue:" _col(25) as res "TR = "`r_TR'
di as txt "Total cost:" _col(25) as res "TC = "`r_TC'
di as txt "Profit:" _col(25) as res "Profit = "`r_profit'
di as txt "Marginal cost:" _col (25) as res "MC = "`r_MC'
di as txt _dup(60) "-"
di as input "Group 1:"
di as txt "Quantity:" _col (25) as res "Q1 = "`r_q1'
di as txt "Price:" _col(25) as res "P1 = "`r_p1'
di as txt "Total revenue:" _col(25) as res "TR1 = "`r_TR1'
di as txt "Price-elasticity:" _col(25) as res "Ep1 = "`r_ep1'
di as txt _dup(60) "-"
di as input "Group 2:"
di as txt "Quantity:" _col (25) as res "Q2 = "`r_q2'
di as txt "Price:" _col(25) as res "P2 = "`r_p2'
di as txt "Total revenue:" _col(25) as res "TR2 = "`r_TR2'
di as txt "Price-elasticity:" _col(25) as res "Ep2 = "`r_ep2'
di as txt "{hline 60}"

di as input _n(3) "Market equilibrium without price discrimination:"
di as txt _dup(60) "-"
di as txt "Quantity:" _col (25) as res "Qtot = "`r_qnd'
di as txt _col(6) "- Group 1:" _col(25) as res "Q1 = "`r_qnd1'
di as res _col(25) "MR1 = "`r_mrnd1'
di as txt _col(6) "- Group 2:" _col(25) as res "Q2 = "`r_qnd2'
di as res _col(25) "MR2 = "`r_mrnd2'
di as txt "Price:" _col (25) as res "P = "`r_pnd'
di as txt "Total revenue:" _col(25) as res "TR = "`r_TRnd'
di as txt "Total cost:" _col(25) as res "TC = "`r_TCnd'
di as txt "Profit:" _col(25) as res "Profit = "`r_profitnd'
di as txt "Marginal cost:" _col (25) as res "MC = "`r_MCnd'
di as txt "{hline 60}"

return scalar TR = `TR'
return scalar TC = `TC'
return scalar ptofit = `profit'
return scalar qtot = `qtot'


**************
*** Graphs ***
**************

if `q1'>0 & `q2'>0 {
forvalues i=1/2 {
*Group i WITH discrimination
#d ;
	tw fun y = `ap`i'' - `bp`i''*x, range(0 `aq`i'') lc(blue) lw(*2)
	|| fun y = `ap`i'' - 2*`bp`i''*x, range(0 `aq`i'2') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci 0 `q`i'' `p`i'' `q`i'' `p`i'' 0 `p`i'' `q`i'', lc(gs0) lp(-) lw(*.5)
	|| scatteri `MC' `q`i'' `p`i'' `q`i'', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	yline(`MC', lc(red) lp(-) lw(*.5))
	xti("Q`i'", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P`i'," "MR`i'", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`p`i'' 0 "`r_p`i''", place(w) m(r=1))
	text(`ap`i'' 0 "`r_ap`i''", place(w) m(r=1))
	text(`MC' 0 "`r_MC'", place(w) m(r=1))
	text(0 `aq`i'' "D`i'", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq`i'2' "MR`i'", place(ne) c(green) size(large) m(b=1))
	text(0 `q`i'' "`r_q`i''", place(s) m(t=1))
	text(0 `aq`i'' "`r_aq`i''", place(s) m(t=1))
	text(0 `aq`i'2' "`r_aq`i'2'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group`i'd, replace) nodraw;
#d cr
}
}

if `q1'==0 & `q2'>0 {
*Group i WITH discrimination
#d ;
	tw fun y = `ap1' - `bp1'*x, range(0 `aq1') lc(blue) lw(*2)
	|| fun y = `ap1' - 2*`bp1'*x, range(0 `aq12') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	yline(`MC', lc(red) lp(-) lw(*.5))
	xti("Q1", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P1," "MR1", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(`MC' 0 "`MC'", place(w) m(r=1))
	text(0 `aq1' "D1", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq12' "MR1", place(ne) c(green) size(large) m(b=1))
	text(0 `aq1' "`r_aq1'", place(s) m(t=1))
	text(0 `aq12' "`r_aq12'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group1d, replace) nodraw;

	tw fun y = `ap2' - `bp2'*x, range(0 `aq2') lc(blue) lw(*2)
	|| fun y = `ap2' - 2*`bp2'*x, range(0 `aq22') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci 0 `q2' `p2' `q2' `p2' 0 `p2' `q2', lc(gs0) lp(-) lw(*.5)
	|| scatteri `MC' `q2' `p2' `q2', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	yline(`MC', lc(red) lp(-) lw(*.5))
	xti("Q2", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P2," "MR2", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`p2' 0 "`r_p2'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(`MC' 0 "`MC'", place(w) m(r=1))
	text(0 `aq2' "D2", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq22' "MR2", place(ne) c(green) size(large) m(b=1))
	text(0 `q2' "`r_q2'", place(s) m(t=1))
	text(0 `aq2' "`r_aq2'", place(s) m(t=1))
	text(0 `aq22' "`r_aq22'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group2d, replace) nodraw;
#d cr
}

if `q1'>0 & `q2'==0 {
*Group i WITH discrimination
#d ;
	tw fun y = `ap1' - `bp1'*x, range(0 `aq1') lc(blue) lw(*2)
	|| fun y = `ap1' - 2*`bp1'*x, range(0 `aq12') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci 0 `q1' `p1' `q1' `p1' 0 `p1' `q1', lc(gs0) lp(-) lw(*.5)
	|| scatteri `MC' `q1' `p1' `q1', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	yline(`MC', lc(red) lp(-) lw(*.5))
	xti("Q1", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P1," "MR1", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`p1' 0 "`r_p1'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(`MC' 0 "`MC'", place(w) m(r=1))
	text(0 `aq1' "D1", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq12' "MR1", place(ne) c(green) size(large) m(b=1))
	text(0 `q1' "`r_q1'", place(s) m(t=1))
	text(0 `aq1' "`r_aq1'", place(s) m(t=1))
	text(0 `aq12' "`r_aq12'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group1d, replace) nodraw;

	tw fun y = `ap2' - `bp2'*x, range(0 `aq2') lc(blue) lw(*2)
	|| fun y = `ap2' - 2*`bp2'*x, range(0 `aq22') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	yline(`MC', lc(red) lp(-) lw(*.5))
	xti("Q2", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P2," "MR2", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(`MC' 0 "`r_MC'", place(w) m(r=1))
	text(0 `aq2' "D2", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq22' "MR2", place(ne) c(green) size(large) m(b=1))
	text(0 `aq2' "`r_aq2'", place(s) m(t=1))
	text(0 `aq22' "`r_aq22'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group2d, replace) nodraw;
#d cr
}

#d ;
*Total market WITH price discrimination;
	tw /*fun y = `apmax' - `bpmax'*x, range(0 `qcross') lc(blue) lw(*2)  lp(_##)
	|| fun y = `aptot' - `bptot'*x, range(`qcross' `aqtot') lc(blue) lw(*2) lp(_##)
	|| */fun y = `c2' + 2*`c3'*x, range(0 `qmcmax') lc(red) lw(*2)
	|| fun y = `apmax' - 2*`bpmax'*x, range(0 `qcross2') lc(green) lw(*2) lp(_)
	|| fun y = `aptot' - 2*`bptot'*x, range(`qcross2' `aqtot2') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsuptot' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1)
	|| pci `apmin' 0 `apmin' `qcross2' /*0 `qcross' `apmin' `qcross'*/ 
	   0 `qtot' `MC' `qtot' `MC' 0 `MC' `qtot' 0 `qcross2' `apmin' `qcross2', lc(gs0) lp(-) lw(*.5)
	|| scatteri `MC' `qtot', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	xti("Qtot", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsuptot')) 
	yti("MRtot," "MC", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	/*text(0 `aqtot' "Dtot", place(ne) c(blue) size(large) m(b=1))*/
	text(`mcmax' `qmcmax' "MC", place(ne) c(red) size(large) m(b=1))
	text(0 `aqtot2' "MRtot", place(ne) c(green) size(large) m(b=1))
	text(`c2' 0 "`c2'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(`MC' 0 "`r_MC'", place(w) m(r=1))
	/*text(0 `qcross' "`r_qcross'", place(s) m(t=1))*/
	text(0 `qcross2' "`r_qcross2'", place(s) m(t=1))
	text(0 `qtot' "`r_qtot'", place(s) m(t=1))
	text(0 `aqtot' "`r_aqtot'", place(s) m(t=1))
	text(0 `aqtot2' "`r_aqtot2'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(marketd, replace) nodraw;
#d cr

if `qnd1'>0 & `qnd2'>0 {
forvalues i=1/2 {
*Group i WITHOUT discrimination
#d ;
	tw fun y = `ap`i'' - `bp`i''*x, range(0 `aq`i'') lc(blue) lw(*2)
	|| fun y = `ap`i'' - 2*`bp`i''*x, range(0 `aq`i'2') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci 0 `qnd`i'' `pnd' `qnd`i'' `pnd`i'' 0 `pnd`i'' `qnd`i'', lc(gs0) lp(-) lw(*.5)
	|| scatteri `pnd' `qnd`i'', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	yline(`pnd', lc(gs0) lp(-) lw(*.5))
	xti("Q`i'", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P," "MR`i'", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`ap`i'' 0 "`r_ap`i''", place(w) m(r=1))
	text(0 `aq`i'' "D`i'", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq`i'2' "MR`i'", place(ne) c(green) size(large) m(b=1))
	text(0 `qnd`i'' "`r_qnd`i''", place(s) m(t=1))
	text(0 `aq`i'' "`r_aq`i''", place(s) m(t=1))
	text(0 `aq`i'2' "`r_aq`i'2'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group`i'nd, replace) nodraw;
#d cr
}
}

if `qnd1'==0 & `qnd2'>0 {
*Group i WITHOUT discrimination
#d ;
	tw fun y = `ap1' - `bp1'*x, range(0 `aq1') lc(blue) lw(*2)
	|| fun y = `ap1' - 2*`bp1'*x, range(0 `aq12') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	yline(`pnd', lc(gs0) lp(-) lw(*.5))
	xti("Q1", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P," "MR1", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(0 `aq1' "D1", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq12' "MR1", place(ne) c(green) size(large) m(b=1))
	text(0 `aq1' "`r_aq1'", place(s) m(t=1))
	text(0 `aq12' "`r_aq12'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group1nd, replace) nodraw;

	tw fun y = `ap2' - `bp2'*x, range(0 `aq2') lc(blue) lw(*2)
	|| fun y = `ap2' - 2*`bp2'*x, range(0 `aq22') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	yline(`pnd', lc(gs0) lp(-) lw(*.5))
	xti("Q2", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P," "MR2", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(0 `aq2' "D2", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq22' "MR2", place(ne) c(green) size(large) m(b=1))
	text(0 `qnd2' "`r_qnd2'", place(s) m(t=1))
	text(0 `aq2' "`r_aq2'", place(s) m(t=1))
	text(0 `aq22' "`r_aq22'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group2nd, replace) nodraw;
#d cr
}

if `qnd1'>0 & `qnd2'==0 {
*Group i WITHOUT discrimination
#d ;
	tw fun y = `ap1' - `bp1'*x, range(0 `aq1') lc(blue) lw(*2)
	|| fun y = `ap1' - 2*`bp1'*x, range(0 `aq12') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci 0 `qnd1' `pnd' `qnd1' `pnd1' 0 `pnd1' `qnd1', lc(gs0) lp(-) lw(*.5)
	|| scatteri `pnd' `qnd1', msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	yline(`pnd', lc(gs0) lp(-) lw(*.5))
	xti("Q1", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P," "MR1", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(0 `aq1' "D1", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq12' "MR1", place(ne) c(green) size(large) m(b=1))
	text(0 `qnd1' "`r_qnd1'", place(s) m(t=1))
	text(0 `aq1' "`r_aq1'", place(s) m(t=1))
	text(0 `aq12' "`r_aq12'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group1nd, replace) nodraw;

	tw fun y = `ap2' - `bp2'*x, range(0 `aq2') lc(blue) lw(*2)
	|| fun y = `ap2' - 2*`bp2'*x, range(0 `aq22') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsupind' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	yline(`pnd', lc(gs0) lp(-) lw(*.5))
	xti("Q2", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsupind')) 
	yti("P," "MR2", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(0 `aq2' "D2", place(ne) c(blue) size(large) m(b=1))
	text(0 `aq22' "MR2", place(ne) c(green) size(large) m(b=1))
	text(0 `aq2' "`r_aq2'", place(s) m(t=1))
	text(0 `aq22' "`r_aq22'", place(s) m(t=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(group2nd, replace) nodraw;
#d cr
}

#d ;
*Total market WITHOUT price discrimination;
	tw fun y = `apmax' - `bpmax'*x, range(0 `qcross') lc(blue) lw(*2)
	|| fun y = `aptot' - `bptot'*x, range(`qcross' `aqtot') lc(blue) lw(*2)
	|| fun y = `c2' + 2*`c3'*x, range(0 `qmcmax') lc(red) lw(*2)
	|| fun y = `apmax' - 2*`bpmax'*x, range(0 `qcross') lc(green) lw(*2) lp(_)
	|| fun y = `aptot' - 2*`bptot'*x, range(`qcross' `aqtot2') lc(green) lw(*2) lp(_)
	|| pcarrowi 0 0 0 `qsuptot' 0 0 `psup' 0, lc(gs0) mc(gs0) mfc(gs0) msize(*1.5) barbsize(1) 
	|| pci `apmin' 0 `apmin' `qcross' 0 `qcross' `apmin' `qcross' 
	   0 `qnd' `pnd' `qnd' `pnd' 0 `pnd' `qnd' `MCnd' 0 `MCnd' `qnd' `pgapup' 0 `pgapup' `qcross'
	   `pgapdn' 0 `pgapdn' `qcross', lc(gs0) lp(-) lw(*.5)
	|| scatteri `MCnd' `qnd' `pnd' `qnd',  msize(medlarge) mlc(gs0) mlw(*1.5) mfc(ltblue)
	|| scatteri `pgapdn' `qcross' `pgapup' `qcross',  msize(medlarge) mlc(gs0) mlw(*1.5) mfc(gs16)
	xti("Qtot", place(e) m(t=4) size(large)) xlab(none) xsc(range(0 `qsuptot')) 
	yti("P," "MRtot," "MC", orientation(horizontal) place(n) m(r=6) justification(left) size(large))
	ylab(none) ysc(range(0 `psup'))
	text(0 `aqtot' "Dtot", place(ne) c(blue) size(large) m(b=1))
	text(`mcmax' `qmcmax' "MC", place(ne) c(red) size(large) m(b=1))
	text(0 `aqtot2' "MRtot", place(ne) c(green) size(large) m(b=1))
	text(`c2' 0 "`c2'", place(w) m(r=1))
	text(`ap1' 0 "`r_ap1'", place(w) m(r=1))
	text(`ap2' 0 "`r_ap2'", place(w) m(r=1))
	text(`MCnd' 0 "`r_MCnd'", place(w) m(r=1))
	text(0 `qcross' "`r_qcross'", place(s) m(t=1))
	text(0 `qnd' "`r_qnd'", place(s) m(t=1))
	text(0 `aqtot' "`r_aqtot'", place(s) m(t=1))
	text(0 `aqtot2' "`r_aqtot2'", place(s) m(t=1))
	text(`pnd' 0 "`r_pnd'", place(w) m(r=1))
	text(`pgapup' 0 "`r_pgapup'", place(w) m(r=1))
	text(`pgapdn' 0 "`r_pgapdn'", place(w) m(r=1))
	graphr(c(gs16)) plotr(m(zero)) legend(off) name(marketnd, replace) nodraw;

#d cr


gr combine group1d group2d marketd, col(3) row(1) plotr(m(zero)) graphr(c(gs16)) name(DM, replace) title(Discriminating monopoly)
gr combine group1nd group2nd marketnd, col(3) row(1) plotr(m(zero)) graphr(c(gs16)) name(NDM, replace) title(Non-discriminating monopoly)

end

