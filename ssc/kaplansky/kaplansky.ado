*! NJC 2.0.0 25 May 2007 
*! NJC 1.0.0 22 Nov 2004 
program kaplansky 
	version 8 
	syntax [, show(numlist >= 1 <= 5 int min=1 max=4) ///
	RAnge(numlist min=2 max=2)  * ]

	if "`show'" == "" local show "1 2 3 4" 
	if "`range'" == "" local range "0 4" 

	local 1 y1 = (1/ (3 * sqrt(_pi))) * (9/4 + x^4) * exp(-x^2) ///
	, ra(`range') clp(shortdash) 
	local k1 "2.75"  

	local 2	y2 = (3 / (2 * sqrt(2 * _pi))) * ///
	exp(-0.5 * x^2) - (1 / (6 * sqrt(_pi))) * (9/4 + x^4) * exp(-x^2) ///
	, ra(`range') clp(longdash) 
	local k2 "3.125"

	local 3 y3 = (1 / (6 * sqrt(_pi))) * (exp(-0.25 * x^2) + 4 * exp(-x^2))  ///
	, ra(`range') clp(dot) 
	local k3 "4.5" 

	local 4 y4 = ((3 * sqrt(3)) / (16 * sqrt(_pi))) * (2 + x^2) * exp(-0.75 * x^2) ///
	, ra(`range') clp(dash) 
	local k4 "2.667" 

	local i = 1 
	foreach s of local show { 
		local call "`call' function ``s'' ||" 
		local legend `"`legend' `i' "`k`s''" "' 
		local ++i 
	}

	twoway `call' /// 
	function y5 = normden(x), ra(`range') clp(solid) ///
	legend(order(- "kurtosis" `legend' `i' "3") ///
	pos(1) ring(0) col(1)) ytitle(probability density) yla(, ang(h)) ///  
	subtitle("Irving Kaplansky. 1945. A common error concerning kurtosis." "Journal, American Statistical Association 40: 259", pos(6)) ///
	`options' 
end	
