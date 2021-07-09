*******************************************************************************
/* 
PROJECT: TWOWAY STACK

OUTPUT OF THIS DO FILE:  
- builds a chart of contributions of real GDP growth 

INSTRUCTIONS
- the command -genstack- needs to be loadable
	
WRITTEN BY: Gregorio Impavido (gimpavido@imf.org)

WRITTEN WHEN: 22 November, 2014
*/
*******************************************************************************
use "mystack.dta", clear

genstack CP_R_CTR CG_R_CTR FCF_R_CTR ST_R_CTR NX_R_CTR, generate(c1 c2 c3 c4 c5)  

label var c1 "Private Consumption"
label var c2 "Public Consumption"
label var c3 "Fixed Capital Formation"
label var c4 "Changes in Stocks"
label var c5 "Net Exports"

graph twoway 																///
	(bar c* time, pstyle(p5bar p4bar p3bar p2bar p1bar) barwidth(0.8 0.8 0.8 0.8 0.8))	///
	(scatter total time, pstyle(p6dot))										///
	(line total time, pstyle(p6dot)) 										///
	if total<. & inrange(time,q(2006q1), q(2014q3)), scheme() 			///
title(`"{fontface "Segoe UI":{bf:Figure X. Turkey: Real GDP Growth Decomposition}}"', 	///
	span ring(7) position(11) size(*0.8) color(75 130 173))					///
subtitle(`"{fontface "Segoe UI":({it:2006Q1-2014Q3, percent YoY}})"',		///
	span ring(6) position(11) size(small)) 									///
ytitle("") 																	///
yscale(lcolor(gs12)) 														///
ylabel(, labsize(*0.8) ang(h) gstyle() glcolor() notick)					///
xtitle("") 																	///
xscale(lcolor(gs12)) 														///
xlabel(, labsize(*0.8) format(%tqCCYY!Qq) notick)							///
yline(0, lcolor(gs12)) 														///
legend(order(1 2 3 4 5 6) 													///
	cols() rows(3) size(vsmall) symxsize(vsmall) symysize(vsmall) 			///
	ring(0) position(4) region(style(none) fcolor() lcolor() lwidth()) 		///
	bmargin() nobox)  														///
note(`"{fontface "Segoe UI":{bf:Sources}: TURKSTAT and authors' calculations.}"'	///
	`"{fontface "Segoe UI":{bf:Notes}: Seasonally and working day adjusted by source.}"', size(vsmall))											
