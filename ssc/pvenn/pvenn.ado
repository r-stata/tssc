*! Date        : 26 Oct 2011
*! Version     : 1.00
*! Authors     : Wenfeng Gong; Jan Osterman (Duke Center for Health Policy)
*! Email       : gongwenf@gmail.com
*! Description : Proportional Venn Diagrams

/* Future ideas
1. treat problem when a population is involved in the overlap part of 
   the other two populations. eg. pvenn pA(45) pB(25) pC(50) pAB(18) pAC(24) pBC(3) ang(120)
2. fill color in circles. 
*/

* capture program drop pvenn
pr pvenn
version 11.0
preserve
set more off

/* data input */
syntax [varlist(default=none)] [, plabel(namelist min=1 max=3) ///
	pA(real 0) pB(real 0) pC(real 0) pAB(real 0) pAC(real 0) pBC(real 0) ///
	ptotal(real 0) ang(real 0) pos(integer 1) drawtotal(integer 1) drawlabel(integer 1) ///
	lc(string) lp(string) lw(string) n(integer 20000) *]

local gopt "`options'"
*di "options: ""`options'"
local popA=`pA'
local popB=`pB'
local popC=`pC'
local popAB=`pAB'
local popAC=`pAC'
local popBC=`pBC'
local angle=`ang'
local popt=`ptotal'
local nameA="Population A"
local nameB="Population B"
local nameC="Population C"

local i 0
foreach nam of local plabel {
  if `++i'==1 local nameA "`nam'"
  if `i'==2 local nameB "`nam'"
  if `i'==3 local nameC "`nam'"
  
}
local i 0
foreach v of local varlist {
	confirm numeric variable `v'
	local vtab`++i'= "`v'"
	*di "vtab`i'= " "`vtab`i''"
}
if `i'>3 {
	di "too many variables selected"
	exit
}
else{
	if `i'>=1 {
		tab `vtab1', matcell(cellvals)
		* matrix list cellvals
		* di cellvals[2,1]
		local popA=cellvals[2,1]
		local popt=`r(N)'
		local nameA "`vtab1'"
	}
	if `i'>=2 {
		tab `vtab1' `vtab2', matcell(cellvals)
		local popB=cellvals[1,2]+cellvals[2,2]
		local popAB=cellvals[2,2]
		local nameB "`vtab2'"
	}
	if `i'==3{
		tab `vtab1' `vtab3', matcell(cellvals)
		local popC=cellvals[1,2]+cellvals[2,2]
		local popAC=cellvals[2,2]
		local nameC "`vtab3'"
		tab `vtab2' `vtab3', matcell(cellvals)
		local popBC=cellvals[2,2]
	}
}

display "`nameA': " "`popA'"
display "`nameB': " "`popB'"
display "`nameC': " "`popC'"
display "AB Overlap: " "`popAB'"
display "AC Overlap: " "`popAC'"
display "BC Overlap: " "`popBC'"
display "Total population: " "`popt'"
display "Draw total population rectangle (0,not; 1, yes): " "`drawtotal'"
display "Rotation angle of circle B: " "`angle'" 
display "Relative position of circle C (1,clockwise; -1,counterclockwise): " "`pos'" 

if `drawtotal'==0 local popt=0

/* Set up line color, pattern, width */
if "`lc'"=="" local lc="cranberry emerald brown lavender"
if "`lw'"=="" local lw="0.8 0.8 0.8 0.8"
if "`lp'"=="" local lp="solid solid solid solid"

forvalues z=1/4  {
	local xopt`z'=" n(`n') `gopt'"
	local conlc`z': word `z' of `lc'
	*di "conlc`z' " "`conlc`z''"
	if "`conlc`z''"~="" local xopt`z' "`xopt`z'' lc(`conlc`z'')"
		else local xopt`z' "`xopt`z'' lc(`conlc1')"
	local conlp`z': word `z' of `lp'
	if "`conlp`z''"~="" local xopt`z' "`xopt`z'' lp(`conlp`z'')"
		else local xopt`z' "`xopt`z'' lp(`conlp1')"
	local conlw`z': word `z' of `lw'
	if "`conlw`z''"~="" local xopt`z' "`xopt`z'' lw(`conlw`z'')"
		else local xopt`z' "`xopt`z'' lw(`conlw1')"
	*di "xopt`z'= " "`xopt`z''"
}


/* Adjust scale of parameters */
local r1= 1
local r2= ((`popB'/`popA')^(0.5))* `r1'
local r3= ((`popC'/`popA')^(0.5))* `r1'
local p1= _pi * `r1' * `r1'
local p2= (`popB'/`popA') * `p1'
local p3= (`popC'/`popA') * `p1'
local p12= (`popAB'/`popA') * `p1'
local p13= (`popAC'/`popA') * `p1'
local p23= (`popBC'/`popA') * `p1'
local popt= (`popt'/`popA') * `p1'

if `popA'<=0 {
  local r1= 0
  local r2= 1
  local r3= ((`popC'/`popB')^(0.5))* `r2'
  local p1= 0
  local p2= _pi * `r2' * `r2'
  local p3= (`popC'/`popB') * `p2'
  local p12= (`popAB'/`popB') * `p2'
  local p13= (`popAC'/`popB') * `p2'
  local p23= (`popBC'/`popB') * `p2'
  local popt= (`popt'/`popB') * `p2'
  }
if `popA'<=0 & `popB'<=0 {
  local r1=0
  local r2=0
  local r3=1
  local p1= 0
  local p2= 0
  local p3= _pi * `r3' * `r3'
  local p12= (`popAB'/`popC') * `p3'
  local p13= (`popAC'/`popC') * `p3'
  local p23= (`popBC'/`popC') * `p3'
  local popt= (`popt'/`popC') * `p3'
}
*di "r1= " "`r1'"
*di "r2= " "`r2'"
*di "r3= " "`r3'"
*di "p1= " "`p1'"
*di "p2= " "`p2'"
*di "p3= " "`p3'"
*di "p12= " "`p12'"
*di "p13= " "`p13'"
*di "p23= " "`p23'"

/* Estimate a1 a2*/
local a1=`r1'
local a2=`r2'
local tp12=0
if `p12'>0 {
	if `r1'>= `r2' {
		while (abs(`tp12'-`p12')/`p12')> 0.01 {
			local a2= `a2'-`r2'/1000
			local a1= (`r1'^2-`r2'^2+`a2'^2)^(0.5)
			if `a2'< ((-1)*`r2') {
				di "cannot find appropriate location for Circle B"
				exit
			}
			else {	
					local tp12 = (`r1'^2)*(acos(`a1'/`r1'))- `a1'*((`r1'^2-`a1'^2)^(0.5)) + (`r2'^2)*(acos(`a2'/`r2'))- `a2' * ((`r2'^2-`a2'^2)^(0.5))
			} 
		}
	}
	else{
		while (abs(`tp12'-`p12')/`p12')> 0.01 {
			local a1= `a1'-`r1'/1000
			local a2= (`r2'^2-`r1'^2+`a1'^2)^(0.5)
			if `a1'< ((-1)*`r1') {
				di "cannot find appropriate location for Circle A"
				exit
			}
			else {	
					local tp12 = (`r1'^2)*(acos(`a1'/`r1'))- `a1'*((`r1'^2-`a1'^2)^(0.5)) + (`r2'^2)*(acos(`a2'/`r2'))- `a2' * ((`r2'^2-`a2'^2)^(0.5))
			} 
		}
	}
}
*di "a1= " "`a1'"
*di "a2= " "`a2'"
*di "tp12= " "`tp12'"

if `r3'>0 & `r3'!=. {
	/* Estimate a13 a31*/
	local a13=`r1'
	local a31=`r3'
	local tp13=0
	if `p13'>0 {
		if `r1'>= `r3' {
			while (abs(`tp13'-`p13')/`p13')> 0.01 {
				local a31= `a31'-`r3'/1000
				local a13= (`r1'^2-`r3'^2+`a31'^2)^(0.5)
				if `a31'< ((-1)*`r3') {
					di "cannot find appropriate location for Circle C"
					exit
				}
				else {	
						local tp13 = (`r1'^2)*(acos(`a13'/`r1'))- `a13'*((`r1'^2-`a13'^2)^(0.5)) + (`r3'^2)*(acos(`a31'/`r3'))- `a31' * ((`r3'^2-`a31'^2)^(0.5))
				} 
			}
		}
		else{
			while (abs(`tp13'-`p13')/`p13')> 0.01 {
				local a13= `a13'-`r1'/1000
				local a31= (`r3'^2-`r1'^2+`a13'^2)^(0.5)
				if `a13'< ((-1)*`r1') {
					di "cannot find appropriate location for Circle C"
					exit
				}
				else {	
						local tp13 = (`r1'^2)*(acos(`a13'/`r1'))- `a13'*((`r1'^2-`a13'^2)^(0.5)) + (`r3'^2)*(acos(`a31'/`r3'))- `a31' * ((`r3'^2-`a31'^2)^(0.5))
				} 
			}
		}
	}
	*di "a13= " "`a13'"
	*di "a31= " "`a31'"
	*di "tp13= " "`tp13'"

	/* Estimate a23 a32*/
	local a23=`r2'
	local a32=`r3'
	local tp23=0
	if `p23'>0 {
		if `r2'>= `r3' {
			while (abs(`tp23'-`p23')/`p23')> 0.01 {
				local a32= `a32'-`r3'/1000
				local a23= (`r2'^2-`r3'^2+`a32'^2)^(0.5)
				if `a32'< ((-1)*`r3') {
					di "cannot find appropriate location for Circle C"
					exit
				}
				else {	
						local tp23 = (`r2'^2)*(acos(`a23'/`r2'))- `a23'*((`r2'^2-`a23'^2)^(0.5)) + (`r3'^2)*(acos(`a32'/`r3'))- `a32' * ((`r3'^2-`a32'^2)^(0.5))
				} 
			}
		}
		else{
			while (abs(`tp23'-`p23')/`p23')> 0.01 {
				local a23= `a23'-`r2'/1000
				local a32= (`r3'^2-`r2'^2+`a23'^2)^(0.5)
				if `a23'< ((-1)*`r2') {
					di "cannot find appropriate location for Circle C"
					exit
				}
				else {	
						local tp23 = (`r2'^2)*(acos(`a23'/`r2'))- `a23'*((`r2'^2-`a23'^2)^(0.5)) + (`r3'^2)*(acos(`a32'/`r3'))- `a32' * ((`r3'^2-`a32'^2)^(0.5))
				} 
			}
		}
	}
	*di "a23= " "`a23'"
	*di "a32= " "`a32'"
	*di "tp23= " "`tp23'"
}

/* locate the center of circles */


local cx1=0 
local cy1=0
local cx2=0 
local cy2=0
local cx3=0 
local cy3=0
local l12=0
local l13=0
local l23=0
local angle213=0
local l12= `a1'+`a2'
local cx2= `cx1'+(`l12') * cos(_pi*`angle'/180)
local cy2= `cy1'+(`l12') * sin(_pi*`angle'/180)
if `r3'>0 & `r3'!=.{
	local l13= `a13'+`a31'
	local l23= `a23'+`a32'
	if `l12'*`l13'!=0 local angle213= acos((`l12'^2+`l13'^2-`l23'^2)/(2*`l12'*`l13'))
	local angle2=_pi*`angle'/180-`pos'*`angle213'
	local cx3=`cx1'+(`l13') * cos(`angle2')
	local cy3=`cy1'+(`l13') * sin(`angle2')
}

*di "`l12' `l13' `l23'"
*di "angle213= " "`angle213'"
*di "angle2= " "`angle2'"
*di "cx3= " "`cx3'"
*di "cy3= " "`cy3'"

/* locate the place for label */
local lnameA=""
local lnameB=""
local lnameC=""
local xlabel1=`cx1'
local ylabel1=`cy1'
local xlabel2=`cx2'
local ylabel2=`cy2'
local xlabel3=`cx3'
local ylabel3=`cy3'
if `drawlabel'==1 {
	if `r1'>0 local lnameA="`nameA'"
	if `r2'>0 local lnameB="`nameB'"
	if `r3'>0 local lnameC="`nameC'"
	local ll12=`l12'-`r2' 
	local ll13=`l13'-`r3'
	local ll21=`l12'-`r1'
	local ll23=`l23'-`r3'
	local ll31=`l13'-`r1'
	local ll32=`l23'-`r2'
	
	local angles1=(_pi*`angle'/180-`pos'*`angle213'/2)
	local temp= min(`ll12',`ll13',0)*cos(`angles1')
	if `temp'!=0 local xlabel1=`cx1'+ `temp' +0.3 *`temp'/abs(`temp')
	local temp= min(`ll12',`ll13',0)*sin(`angles1')
	if `temp'!=0 local ylabel1=`cy1'+ `temp' +0.3 *`temp'/abs(`temp')
	
	local angle123=0
	if `l12'*`l23'!=0 local angle123= acos((`l12'^2+`l23'^2-`l13'^2)/(2*`l12'*`l23'))
	local angles2=(_pi*`angle'/180+`pos'*`angle123'/2)
	local temp= min(`ll21',`ll23',0)*cos(`angles2')
	if `temp'!=0 local xlabel2=`cx2'- `temp' -0.3 *`temp'/abs(`temp')
	local temp= min(`ll21',`ll23',0)*sin(`angles2')
	if `temp'!=0 local ylabel2=`cy2'- `temp' -0.3 *`temp'/abs(`temp')
	
	local angle132=0
	if `l13'*`l23'!=0 local angle132= acos((`l13'^2+`l23'^2-`l12'^2)/(2*`l13'*`l23'))
	local angles3=_pi*`angle'/180+`pos'*(`angle213'+ `angle132'/2)
	local temp= min(`ll31',`ll32',0)*cos(`angles3')
	if `temp'!=0 local xlabel3=`cx3'+ `temp' +0.3 *`temp'/abs(`temp')
	local temp= min(`ll31',`ll32',0)*sin(`angles3')
	if `temp'!=0 local ylabel3=`cy3'+ `temp' +0.3 *`temp'/abs(`temp')
	*di "`ll12',`ll13'"
	*di "angles1:" "`angles1'"
	*di "xlabel1:" "`xlabel1'"
	*di "`ll21',`ll23'"
	qui local angles2=180* `angles2'/_pi
	*di "angles2:" "`angles2'"
	*di "xlabel2:" "`xlabel2'"
	*di "xlabel3:" "`xlabel3'"
	
}

/*draw the circles*/
foreach circles in 1 2 3{
local rangel`circles'= (`cx`circles''-`r`circles'')
local rangeh`circles'= (`cx`circles''+`r`circles'')
*local erangel`circles'=floor(2*`rangel`circles'') /2
*local erangeh`circles'=ceil(2*`rangeh`circles'') /2
}
local minX=min(`rangel1',`rangel2', `rangel3')
local maxX=max(`rangeh1',`rangeh2', `rangeh3')
*di "minX= " "`minX'"
*di "maxX= " "`maxX'"
local Xrange=`maxX'-`minX'
foreach circles in 1 2 3{
local rangeb`circles'= (`cy`circles''-`r`circles'')
local ranget`circles'= (`cy`circles''+`r`circles'')
*local erangeb`circles'=floor(2*`rangeb`circles'')/2 
*local eranget`circles'=ceil(2*`ranget`circles'') /2
}
local minY=min(`rangeb1',`rangeb2', `rangeb3')
local maxY=max(`ranget1',`ranget2', `ranget3')
*di "minY= " "`minY'"
*di "maxY= " "`maxY'"
local Yrange=`maxY'-`minY'
local aspectratio=`Yrange'/`Xrange'
local rangearea=`Xrange'*`Yrange' 
*di "rangearea: `rangearea'"
if `rangearea'<=`popt' & `popt'>0 {
	local totalX=sqrt(`popt'/`rangearea')*`Xrange'
	local totalY=sqrt(`popt'/`rangearea')*`Yrange'
}
else {
	if `popt'>0 di "Margin (i.e. subjects outside all the population A, B, and C) is not large enough; total population cannot be represented as outside rectangle."
	local totalX=`Xrange'
	local totalY=`Yrange'
}
local totalminX=`minX'-(`totalX'-`Xrange')/2
local totalmaxX=`maxX'+(`totalX'-`Xrange')/2
local totalminY=`minY'-(`totalY'-`Yrange')/2
local totalmaxY=`maxY'+(`totalY'-`Yrange')/2
local minX=floor(2*`totalminX')/2 
local maxX=ceil(2*`totalmaxX')/2 
local minY=floor(2*`totalminY')/2 
local maxY=ceil(2*`totalmaxY')/2 
local ylabel4=`totalmaxY'-0.1
local xlabel4=`totalminX'+0.1
*di "aspectratio= " "`aspectratio'"
*di "rangel1= " "`rangel1'"
*di "rangel2= " "`rangel2'"
*di "rangel3= " "`rangel3'"

if `rangearea'<=`popt' {
	if `r3'>0 & `r3'!=.{
	twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) ///
			xtitle("") ytitle("") `xopt1' aspectratio(`aspectratio') legend(order(1 "`nameA'" 3 "`nameB'" 5 "`nameC'" 7 "Total Population")) ///
		|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  ///
		|| function y = sqrt(`r2'^2 - (x-`cx2')^2)+`cy2',range(`rangel2' `rangeh2') text(`ylabel2' `xlabel2' "`lnameB'") `xopt2'  ///
		|| function y = -sqrt(`r2'^2 - (x-`cx2')^2)+`cy2', range(`rangel2' `rangeh2') `xopt2'  ///
		|| function y = sqrt(`r3'^2 - (x-`cx3')^2)+`cy3',range(`rangel3' `rangeh3') text(`ylabel3' `xlabel3' "`lnameC'") `xopt3'  ///
		|| function y = -sqrt(`r3'^2 - (x-`cx3')^2)+`cy3',range(`rangel3' `rangeh3') `xopt3'  ///
		|| function y = `totalminX',range(`totalminY' `totalmaxY') horizontal xtitle("") ytitle("")  `xopt4'  ///
		|| function y = `totalmaxX',range(`totalminY' `totalmaxY') horizontal  `xopt4'  ///
		|| function y = `totalminY',range(`totalminX' `totalmaxX')  `xopt4' text(`ylabel4' `xlabel4' "Total", place(se)) ///
		|| function y = `totalmaxY',range(`totalminX' `totalmaxX')  `xopt4' 
	}
	else {
		if `r2'>0 & `r2'!=.{
		twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) ///
				xtitle("") ytitle("") `xopt1'  aspectratio(`aspectratio') legend(order(1 "`nameA'" 3 "`nameB'" 5 "Total Population")) ///
			|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  ///
			|| function y = sqrt(`r2'^2 - (x-`cx2')^2)+`cy2',range(`rangel2' `rangeh2') text(`ylabel2' `xlabel2' "`lnameB'") `xopt2'   ///
			|| function y = -sqrt(`r2'^2 - (x-`cx2')^2)+`cy2', range(`rangel2' `rangeh2') `xopt2'   ///
			|| function y = `totalminX',range(`totalminY' `totalmaxY') xtitle("") ytitle("") horizontal `xopt4'  ///
			|| function y = `totalmaxX',range(`totalminY' `totalmaxY') horizontal `xopt4'  ///
			|| function y = `totalminY',range(`totalminX' `totalmaxX')  `xopt4' text(`ylabel4' `xlabel4' "Total", place(se)) ///
			|| function y = `totalmaxY',range(`totalminX' `totalmaxX')  `xopt4' 
		}
		else {
			twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) ///
				xtitle("") ytitle("") `xopt1'  aspectratio(`aspectratio') legend(order(1 "`nameA'" 3  "Total Population")) ///
			|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  ///
			|| function y = `totalminX',range(`totalminY' `totalmaxY') xtitle("") ytitle("") horizontal `xopt4'  ///
			|| function y = `totalmaxX',range(`totalminY' `totalmaxY') horizontal `xopt4'  ///
			|| function y = `totalminY',range(`totalminX' `totalmaxX')  `xopt4' text(`ylabel4' `xlabel4' "Total", place(se)) ///
			|| function y = `totalmaxY',range(`totalminX' `totalmaxX')  `xopt4' 
			}
	}
	
	exit
}

if `r3'>0 & `r3'!=.{
twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) /// 
		xtitle("") ytitle("")  `xopt1' aspectratio(`aspectratio') legend(order(1 "`nameA'" 3 "`nameB'" 5 "`nameC'" )) ///
	|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  ///
	|| function y = sqrt(`r2'^2 - (x-`cx2')^2)+`cy2',range(`rangel2' `rangeh2') text(`ylabel2' `xlabel2' "`lnameB'") `xopt2'   ///
	|| function y = -sqrt(`r2'^2 - (x-`cx2')^2)+`cy2', range(`rangel2' `rangeh2') `xopt2'  ///
	|| function y = sqrt(`r3'^2 - (x-`cx3')^2)+`cy3',range(`rangel3' `rangeh3') text(`ylabel3' `xlabel3' "`lnameC'") `xopt3'  ///
	|| function y = -sqrt(`r3'^2 - (x-`cx3')^2)+`cy3',range(`rangel3' `rangeh3') `xopt3'  
}
else {
	if `r2'>0 & `r2'!=.{
	twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) ///
			xtitle("") ytitle("") `xopt1' aspectratio(`aspectratio') legend(order(1 "`nameA'" 3 "`nameB'" )) ///
		|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  ///
		|| function y = sqrt(`r2'^2 - (x-`cx2')^2)+`cy2',range(`rangel2' `rangeh2') text(`ylabel2' `xlabel2' "`lnameB'") `xopt2'  ///
		|| function y = -sqrt(`r2'^2 - (x-`cx2')^2)+`cy2', range(`rangel2' `rangeh2') `xopt2' 
	}
	else {
		twoway function y = sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1') text(`ylabel1' `xlabel1' "`lnameA'") xlabel(none) ylabel(none) ///
			xtitle("") ytitle("") `xopt1' aspectratio(`aspectratio') legend(order(1 "`nameA'"  )) ///
		|| function y = -sqrt(`r1'^2 - (x-`cx1')^2)+`cy1', range(`rangel1' `rangeh1')  `xopt1'  
	}
}

end

