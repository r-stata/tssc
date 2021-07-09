*! NJC 1.1.1 23 Sept 2004
* NJC 1.1.0 19 Sept 2004
* NJC 1.0.0 6 Sept 2004
*! -gr3- wwg STB-12 
program scat3
	version 8 

	// set defaults 
	Defaults

	// syntax check 
	syntax varlist(min=3 max=3) [if] [in] [ , /// 
	Rotate(int `rotate') Elevate(int `elevate') ///
	axistype(string) shadow SHADOW2(passthru) ///
	titlex(str asis) titley(str asis) titlez(str asis) /// 
	variablenames SEParate(passthru) * ]

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000

	// axistype choice 
	local at "`axistype'" 
	if "`at'" == "" local axistype "`axis'" 
	else { 
		local badaxis 1 
		foreach c in minimum zero outside table { 
			if "`at'" == substr("`c'", 1, length("`at'")) { 
				local badaxis 0 
				local axistype "`c'" 
			} 	
		}
		if `badaxis' { 
			di as err "invalid axis type `axistype'" 
			exit 198 
		} 
	} 	

	// prepare dataset 
	if _N < 9 { 
		preserve 
		set obs 9
	} 	
	
	quietly { 
		tokenize "x y z" 
		local i = 1 

		// variables rescaled: minimum 0, maximum 1  
		foreach v of local varlist { 
				su `v' if `touse', meanonly 
				local range = r(max) - r(min)
				if `range' == 0 local range 1 
				tempvar ``i''
				gen ```i''' = (`v' - r(min)) / `range' 
				local ``i''zero = -r(min) / `range' 
				local ++i 
		} 
		
		// set up axes
/* axis information: 

one of: table outside zero minimum 

axis == table 
		adds "table-top" axis to the data.
		adds to data:
				 x y z
			1	 1 1 0         
			2	 0 1 0 
			3	 0 0 0 
			4	 0 0 1 
			5	 1 0 1
			6	 1 0 0 
			7	 0 0 0 
			8	 1 0 0 
			9	 1 1 0 

axis == outside 
		adds "outside" axis to data.  
		adds to data: 
			         x y z
			1	 1 1 0 
			2	 0 1 0 
			3	 0 0 0 
			4	 0 0 1 

axis == zero		
		adds an axis meeting at (0,0,0) to the data.
		adds to data:
				x y z
			1	0 . .
			2	. . .
			3	. . 1
			4	. . 0
			5	. . .
			6	. 0 .
			7	. 1 .
			8	. . .
			9	1 . .

		The missings are converted to the scaled number corresponding 
		to zero (xzero yzero zzero).
	
axis == minimum 			
		adds an axis centred on the minimum of the data.
		adds to data:
				x y z
			1	0 1 0
			2	0 0 0
			3	0 0 1
			4	0 0 0
			5	1 0 0
				
*/
		tempvar xaxis yaxis zaxis  
		
		if "`axistype'" == "table" {
			gen `xaxis' = 1 if inlist(_n, 1, 5, 6, 8, 9) 
			replace `xaxis' = 0 if inlist(_n, 2, 3, 4, 7)
			gen `yaxis' = 1 if inlist(_n, 1, 2, 9) 
			replace `yaxis' = 0 in 3/8                   
			gen `zaxis' = 0 in 1/9 
			replace `zaxis' = 1 in 4/5 
		} 
		else if "`axistype'" == "outside" { 
			gen `xaxis' = _n == 1 in 1/4 
			gen `yaxis' = _n <= 2 in 1/4
			gen `zaxis' = _n == 4 in 1/4
		}
		else if "`axistype'" == "zero" { 
			gen `xaxis' = ///
			cond(_n == 1,0,cond(_n == 9,1,`xzero')) in 1/9 
			gen `yaxis' = ///
			cond(_n == 6,0,cond(_n == 7,1,`yzero')) in 1/9 
			gen `zaxis' = /// 
			cond(_n == 3,1,cond(_n == 4,0,`zzero')) in 1/9 
		} 
		else if "`axistype'" == "minimum" { 
			gen `xaxis' = cond(_n == 5,1,0) in 1/5 
			gen `yaxis' = cond(_n == 1,1,0) in 1/5 
			gen `zaxis' = cond(_n == 3,1,0) in 1/5
		} 

		// add titles (by default variable labels) to data	
		tempvar title xtitle ytitle ztitle   

		foreach v in x y z { 
			parse `"`title`v''"', parse(",") 
			if `"`1'"' != "" & `"`1'"' != "," { 
				local text`v' `1' 
				local title`v' `"`3'"' 
			} 	
			else if "`1'" == "," { 
				local title`v' "`2'" 
			} 	
		} 	
		
		tokenize `varlist' 

		gen `title' = `"`textx'"' in 1 
		if mi(`title'[1]) { 
			if "`variablenames'" == "" { 
				replace `title' = `"`: var label `1''"' in 1 
			} 
			if mi(`title'[1]) replace `title' = "`1'" in 1 
		} 
		replace `title' = `"`texty'"' in 2 
		if mi(`title'[2]) { 
			if "`variablenames'" == "" { 
				replace `title' = `"`: var label `2''"' in 2 
			} 	
			if mi(`title'[2]) replace `title' = "`2'" in 2 
		} 
		replace `title' = `"`textz'"' in 3 
		if mi(`title'[3]) { 
			if "`variablenames'" == "" { 
				replace `title' = `"`: var label `3''"' in 3 
			} 	
			if mi(`title'[3]) replace `title' = "`3'" in 3 
		} 
		
		gen `xtitle' = cond(_n == 1,.5,-.1) in 1/3
		gen `ytitle' = cond(_n == 1,1.1,cond(_n == 2,.5,0)) in 1/3
		gen `ztitle' = cond(_n == 3,.5,0) in 1/3
		
		// convert the angles into radians, store as scalars `SC*'
		tempname SC1 SC2 SC3 SC4 SC5 SC6 SC7 SC8 SC9
		
		scalar `SC1' = (360 - `rotate') * _pi/180 
		scalar `SC2' = (270 - `elevate') * _pi/180
		scalar `SC3' = `tilt' * _pi/180
		scalar `SC4' = sin(`SC1') 
		scalar `SC5' = cos(`SC1') 
		scalar `SC6' = sin(`SC2') 
		scalar `SC7' = cos(`SC2') 
		scalar `SC8' = sin(`SC3') 
		scalar `SC9' = cos(`SC3')

		tempvar newy newytitle newyaxis 
		tempvar vybase vy vyaxis vytitle vx vxaxis vxtitle 
	
		// rotate about z-axis (rotation)
		gen `newy' = `x' * `SC4' + `y' * `SC5'
		gen `newyaxis' = `xaxis' * `SC4' + `yaxis' * `SC5'
		gen `newytitle' = `xtitle' * `SC4' + `ytitle' * `SC5'
		
		// rotate about x-axis (elevation) and y-axis (tilt)
		gen `vybase' = `newy' * `SC7'
		gen `vy' = `vybase' - `z' * `SC6'
		gen `vyaxis' = (`newyaxis' * `SC7') - `zaxis' * `SC6' 
		gen `vytitle' = (`newytitle' * `SC7') - `ztitle' * `SC6' 
		gen `vx' = (`x' * `SC5' - `y' * `SC4') * ///
		`SC9' + (`newy' * `SC6' + `z' * `SC7') * `SC8'
		gen `vxaxis' = (`xaxis' * `SC5' - `yaxis' * `SC4') * ///
		`SC9' + (`newyaxis' * `SC6' + `zaxis' * `SC7') * `SC8'
		gen `vxtitle' = (`xtitle' * `SC5' - `ytitle' * `SC4') * ///
		`SC9' + (`newytitle' * `SC6' + `ztitle' * `SC7') * `SC8'

		drop `x' `y' `z' 
		drop `xaxis' `yaxis' `zaxis' 
		drop `xtitle' `ytitle' `ztitle'  
		drop `newy' `newytitle' `newyaxis'
        }	

	
	local vars "`touse' `vx' `vy' `vybase' `vxaxis' `vyaxis'"
	local vars "`vars' `vxtitle' `vytitle' `title'"  
	Show `vars', rot(`rotate') elev(`elevate') `shadow' `shadow2' ///
	titlex(`titlex') titley(`titley') titlez(`titlez') `separate' `options' 
end

program Show
	version 8 
	syntax varlist [ , ///
	axes(str asis) spikes(str asis) ///  
	titlex(str asis) titley(str asis) titlez(str asis) ///
	shadow shadow2(str asis) Rot(int 999) Elev(int 999) separate(varname) * ] 

	tokenize `varlist' 
	args touse vx vy vybase vxaxis vyaxis vxtitle vytitle title 

	local VY "`vy'" 
	
	qui if "`separate'" != "" { 
		separate `vy', by(`separate') shortlabel 
		local vy "`r(varlist)'" 
		foreach v of local vy { 
			local label : variable label `v' 
			local label = substr(`"`label'"', index(`"`label'"',"==") + 2, .) 
			label var `v' `"`label'"' 
		} 	
		numlist "6/`= 5 + `: word count `vy'''"
		local legend "legend(order(`r(numlist)'))" 
	}
	else local legend "legend(off)" 
	
	di as txt "note: projecting at rotate(" as res "`rot'" ///
	as txt ") elevate(" as res "`elev'" as txt ")"

	if "`shadow'`shadow2'" != "" {
		twoway scatter `vybase' `vx' if `touse', msize(*0.5) `shadow2' || ///
		line `vyaxis' `vxaxis', clp(solid) `axes' || /// 
		scatter `vytitle' `vxtitle' in 1, ///
		ms(none) mlabel(`title') mlabp(0) mlabc(black) `titlex' || ///
		scatter `vytitle' `vxtitle' in 2, ///
		ms(none) mlabel(`title') mlabp(0) mlabc(black) `titley' || /// 
		scatter `vytitle' `vxtitle' in 3, ///
		ms(none) mlabel(`title') mlabang(vertical) mlabp(0) mlabc(black) `titlez' || /// 
		scatter `vy' `vx' if `touse', /// 
		plotregion(style(none)) yla(, nogrid) xla(, nogrid)  ///
		yscale(r(.,.) off) xscale(r(.,.) off) `legend' `options'
	} 	
	else twoway rspike `VY' `vybase' `vx' if `touse', `spikes' || ///
	line `vyaxis' `vxaxis', clp(solid) `axes' || /// 
	scatter `vytitle' `vxtitle' in 1, ///
	ms(none) mlabel(`title') mlabp(0) mlabc(black) `titlex' || ///
	scatter `vytitle' `vxtitle' in 2, ///
	ms(none) mlabel(`title') mlabp(0) mlabc(black) `titley' || /// 
	scatter `vytitle' `vxtitle' in 3, ///
	ms(none) mlabel(`title') mlabang(vertical) mlabp(0) mlabc(black) `titlez' || /// 
	scatter `vy' `vx' if `touse', /// 
	plotregion(style(none)) yla(, nogrid) xla(, nogrid)  ///
	yscale(r(.,.) off) xscale(r(.,.) off) `legend' `options'
end

program Defaults 
	version 8
	c_local rotate   45 
	c_local elevate  45 
	c_local tilt     0  
	c_local axis "table" 
end

