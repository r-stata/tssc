*! version 1.0.0  28mar2015 Robert Picard, picard@netbox.com
program define geocircles

	version 9

	syntax anything [in] [if], ///
		DATAbase(string) ///
		COORdinates(string)	 ///
		[ ///
		replace ///
		SPHEREradius(real 6371) ///
		Npoints(integer 200) ///
		MIles ///
		]
	
	
	tokenize `anything'
	if "`4'" != "" {
		dis as err "unexpected extra text: `4'"
		exit 198
	}
	if "`3'" == "" {
		dis as err "You must provide, in order, lat lon radius"
		exit 198
	}
	local lat `1'
	local lon `2'
	local radius `3'
	
	
	local bad 0
	cap confirm numeric var `lat'
	if !_rc {
		sum `lat' `if' `in', meanonly
		if r(max) > 90 | r(min) < -90 local bad 1
		local var_args lat
	}
	else if abs(`lat') > 90 local bad 1
	
	if `bad' {
		dis as err "latitude `lat' must be between -90 and 90"
		exit 198
	}
	
	
	local bad 0
	cap confirm numeric var `lon'
	if !_rc {
		sum `lon' `if' `in', meanonly
		if r(max) > 180 | r(min) < -180 local bad 1
		local var_args `var_args' lon
	}
	else if abs(`lon') > 180 local bad 1
	
	if `bad' {
		dis as err "longitude `lon' must be between -180 and 180"
		exit 198
	}
	
	
	if "`miles'" != "" local sphereradius = `sphereradius' / 1.609344
	
	local bad 0
	cap confirm numeric var `radius'
	if !_rc {
		sum `radius' `if' `in', meanonly
		if (r(max) >= `sphereradius') | r(min) <= 0 {
			dis as err "values for variable `radius' must be > 0 and < " `sphereradius'
			exit 198
		}
		local var_args `var_args' radius
	}
	else if (`radius' >= `sphereradius') | `radius' <= 0 {
		dis as err "specified radius (`radius') must be > 0 and < " `sphereradius'
		exit 198
	}
	

	preserve
	
	if "`var_args'" == "" {
		drop _all
		qui set obs 1
	}
	else if "`if'`in'" != "" keep `if' `in'
	
	gen long _ID = _n
	local vorder _ID
	
	if strpos("`var_args'","lat") == 0 {
		gen double _LAT = `lat'	
		local vorder `vorder' _LAT
	}
	else local vorder `vorder' `lat'
	
	if strpos("`var_args'","lon") == 0 {
		gen double _LON = `lon'
		local vorder `vorder' _LON
	}
	else local vorder `vorder' `lon'
	
	if strpos("`var_args'","radius") == 0 {
		gen double _RADIUS = `radius'
		local vorder `vorder' _RADIUS
	}
	else local vorder `vorder' `radius'
	
	order `vorder'
	qui save "`database'", `replace'
		
	local rlat `lat' * _pi / 180
	local rlon `lon' * _pi / 180
	
	qui {
		expand `npoints' + 2
		tempvar bearing
		bysort _ID: gen double `bearing' = 2 * _pi * (_n - 2) / (_N-2) if _n > 1
		
		/*
		The equation for calculating a destination point using an initial bearing and
		distance comes from www.movable-type.co.uk/scripts/latlong.html by Chris Veness
		*/
		gen double _Y = asin(sin(`rlat') * cos(`radius'/`sphereradius') + ///
							cos(`rlat') * sin(`radius'/`sphereradius') * cos(`bearing'))
							
		gen double _X = `rlon' + atan2(sin(`bearing') * sin(`radius'/`sphereradius') * cos(`rlat'), ///
											cos(`radius'/`sphereradius') - sin(`rlat') * sin(_Y))
	
		replace _Y = _Y * 180 / _pi
		replace _X = _X * 180 / _pi
		replace _X = _X - 360 if _X > 180
		replace _X = _X + 360 if _X < -180
		
		
		keep _ID _Y _X
		order _ID _Y _X
		save "`coordinates'", `replace'
	}
	
end
