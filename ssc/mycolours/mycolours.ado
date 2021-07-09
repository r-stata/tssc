*! 1.0.0 NJC 10aug2020 
program mycolours  
	version 8 
	syntax [, show ]  

	c_local OK1 230 159 0 
	  local OK1 230 159 0 
	c_local ora 230 159 0
	c_local OK2 86 180 233 
	  local OK2 86 180 233 
	c_local sky 86 180 233	
	c_local OK3 0 158 115
	  local OK3 0 158 115
	c_local bgr 0 158 115
	c_local OK4 240 228 66 
	  local OK4 240 228 66 
	c_local yel 240 228 66 
	c_local OK5 0 114 178 
	  local OK5 0 114 178 
	c_local blu 0 114 178 
	c_local OK6 213 94 0 
	  local OK6 213 94 0 
	c_local ver 213 94 0 
	c_local OK7 204 121 167 
	  local OK7 204 121 167 
	c_local rpu 204 121 167 
	c_local OK8 0 0 0 
	  local OK8 0 0 0 
	c_local bla 0 0 0 

    di _n "locals defined:" 
	di "    OK1 and ora for orange" 
	di "    OK2 and sky for sky blue" 
	di "    OK3 and bgr for bluish green" 
	di "    OK4 and yel for yellow" 
	di "    OK5 and blu for blue"
	di "    OK6 and ver for vermilion" 
	di "    OK7 and rpu for reddish purple" 
	di "    OK8 and bla for black" 

	if "`show'" == "" exit 0 

	preserve 
	clear 
	quietly set obs 8
	gen whatever = _n 
	label def whatever 1 "orange" 2 "sky blue" 3 "bluish green" 4 "yellow" /// 
	5 "blue" 6 "vermilion" 7 "reddish purple" 8 "black" 
	label val whatever whatever

	forval j = 1/8 { 
		local call `call' bar(`j', color("`OK`j''")) 
	} 
	graph hbar (asis) whatever, over(whatever) ytitle(whatever) ///
	asyvars `call' bargap(10) legend(pos(3) col(1)) ysc(off)    
   
end 
