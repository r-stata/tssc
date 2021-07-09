*! version 2.0.3  04sep2019 Robert Picard, robertpicard@gmail.com
program define geonear

	version 9
	
	syntax varlist(min=3 max=3) using/ , ///
		Neighbors(namelist min=3 max=3) ///
		[ 								/// version 1 options
		MIles 							///
		Ellipsoid 						///
		a(string) 						///
		f(string) 						///
		Ignoreself 						///
		RAdius(string) 					///
		NEArcount(integer 1)			///
		Genstub(name)					///
		REport(numlist max=1 >=0)		///
		MAxbases(string) 				/// stay backward compatible!
		///
		WIDe							/// version 2 options
		LOng							///
		Ops(numlist max=1 integer >0)	///
		WIThin(numlist max=1 >0)		///
		LImit(numlist max=1 integer >0)	///
		]

	if "`wide'" != "" & "`long'" != "" {
		dis as err "wide and long cannot be combined"
		exit 198
	}
	local wide = cond("`long'" == "", 1, 0)
		
	if `wide' {
		if `nearcount' < 1 {
			dis as err "value must be >= 1 : option nearcount(`nearcount')"
			exit 198
		}
		
		if "`genstub'" == "" local genstub nid
		
		if "`within'`limit'" != "" {
			dis as err "long form option(s) not allowed"
			exit 198
		}
		
	}
	else {
		if `nearcount' < 0 {
			dis as err "value must be >= 0 : option nearcount(`nearcount')"
			exit 198
		}
		
		if "`genstub'" != "" {
			dis as err "genstub(`genstub') not allowed in long form mode"
			exit 198
		}
	}
	
	if "`limit'" == "" local limit .
	if `limit' < `nearcount' {
		dis as err "limit(`limit') < nearcount(`nearcount')"
		exit 198
	}
		
	if "`miles'" != "" local units mi
	else local units km
	local mi2km 1.609344
	
	if "`ops'" == "" local ops = cond(`wide', 15000, 7000)

	local ignore = "`ignoreself'" != ""
	local minnbor = `nearcount' + `ignore'
	
	tempname R ell_a ell_f
	if "`ellipsoid'`a'`f'" != "" {
		if "`radius'" != "" {
			dis as err "Sphere and ellipsoid model cannot be combined"
			exit 198
		}
		if "`a'`f'" != "" {
			cap confirm number `a'
			local rc = _rc
			cap confirm number `f'
			if _rc | `rc' {
				dis as err "reference ellipsoid parameters incorrectly specified"
				dis as err "use option a() for the semi-major axis, in meters"
				dis as err "use option f() for the reciprocal of flattening ratio"
				dis as err "e.g. a(6378249.145) f(293.465) for Clarke 1880"
				exit 7
			}
			if `a' <= 0 {
				dis as err "semi-major axis (in meters) <= 0 : option a(`a')"
				exit 198
			}
			if `f' <= 0 {
				dis as err "reciprocal of flattening ratio <= 0 : option f(`f')"
				exit 198
			}
			scalar `ell_a' = `a'		// semi-major axis
			scalar `ell_f' = 1 / `f'	// Flattening
		}
		else {
			// default to WGS 1984 ellipsoid
			scalar `ell_a' = 6378137				// semi-major axis
			scalar `ell_f' = 1 / 298.257223563	// Flattening
		}
		local sphere 0
	}
	else {
		if "`radius'" == "" scalar `R' = 6371
		else {
			cap confirm number `radius'
			if _rc {
				dis as err "was expecting a number: option radius(`radius')"
				exit 7
			}
			scalar `R' = `radius'
			if `R' <= 0 {
				dis as err "radius must be > 0"
				exit 198
			}
		}
		local sphere 1
	}

	tempname dwithin
	if "`within'" == "" scalar `dwithin' = 0
	else  scalar `dwithin' = `within'
	if "`units'" == "mi" scalar `dwithin' = `dwithin' * `mi2km'
		
	if "`report'" == "" local report 10
	
	// track run time, this also allows to estimate time remaining
	timer clear 56
	timer on 56

	preserve
	
	geonear_prep_locations base `varlist'
	local baseid : word 1 of `varlist'
	local baseN = _N
	tempfile fbase
	qui save "`fbase'"
		
	qui use "`using'", clear
	if !`wide' {
		unab neighbors: `neighbors'
		local nborid : word 1 of `neighbors'
		
		if "`baseid'" == "`nborid'" {
			dis as err "identifier variables names must not be the same"
			exit 198
		}
	}

	geonear_prep_locations nbor `neighbors'
	local nborN = _N
	tempfile fnbor
	qui save "`fnbor'"	

	if `nborN' < `minnbor' {
		dis as err "not enough observations to satisfy nearcount" 
		dis as err "number of nbor locations = " `nborN'
		error 2001
	}
	
	tempname nregion ndone sum_ops rtime 
	scalar `nregion' = 0
	scalar `ndone' = 0
	scalar `sum_ops' = 0
	scalar `rtime' = 0


	geonear_recur `wide' `sphere' `ops' `report' `ignore' `nearcount' `limit' `dwithin' ///
		`R' `ell_a' `ell_f' "`fbase'" "`fnbor'" `baseN' `nregion' `ndone' `sum_ops' `rtime'


	if `wide' {
		forvalues i = 1/`nearcount' {
			if `sphere' qui replace cd`i' = cd`i' * `R'
			if "`units'" == "mi" qui replace cd`i' = cd`i' / `mi2km'
			if `nearcount' > 1 local j `i'
			rename cd`i' `units'_to_`genstub'`j'
			rename idc`i' `genstub'`j'
		}
		rename idb `baseid'
		sort `baseid'
		tempfile results
		qui save "`results'"
		nobreak {
			restore
			sort  `baseid'
			qui merge `baseid' using "`results'"
			drop _merge
		}

	}
	else {
		if "`units'" == "mi" qui replace d = d / `mi2km'
		sort idb d idn
		order idb idn d
		rename idb `baseid'
		rename idn `nborid'
		rename d `units'_to_`nborid'
		restore, not
	}
	
	
	timer off 56
	qui timer list 56
	
	dis as txt _n "{hline 79}"
	dis as txt "Unique base locations   = " ///
		as res %-10.0fc `baseN' ///
		_col(42) as txt "Unique neighbor locations = " ///
		as res %-10.0fc `nborN'
	dis as txt "Bases * Neighbors  " _cont
	if `baseN' * `nborN' > 1e6 ///
		dis as txt  "(M)  = " ///
		as res %-12.1fc `baseN' * `nborN' / 1e6 _cont
	else dis as txt "     = " ///
		as res %-12.0fc `baseN' * `nborN' _cont
	dis _col(42) as txt "Number of regions         = " ///
		as res %-10.0fc `nregion'
	dis as txt "Computed distances " _cont
	if `sum_ops' > 1e6 ///
		dis as txt  "(M)  = " as res %-12.2fc `sum_ops' / 1e6 _cont
	else dis as txt "     = " as res %-12.0fc `sum_ops' _cont
	dis _col(42) as txt "Total run time (seconds)  = " ///
		as res r(t56)
	dis "{hline 79}"
	
end


program define geonear_prep_locations

	args loctype id lat lon
	
	// reduce to relevant variables and skip missing values
	keep `id' `lat' `lon'
	qui keep if !mi(`id',`lat',`lon')
	
	// if multiple records per id, make sure that lat/lon are constant
	sort `id' `lat' `lon'
	capture by `id': assert `lat' == `lat'[1] & `lon' == `lon'[1]
	if _rc {
		dis as err "`lat' or `lon' not constant within `id' group" 
		exit 459
	}
	
	// reduce to one record per unique location
	qui by `id': keep if _n == 1
	if _N == 0 {
		dis as err "no observation for `loctype' locations" 
		exit 459
	}
	
	// convert from decimal degrees to radians
	capture confirm numeric var `lat' `lon'
	if _rc {
		dis as err "lat/lon variables not numeric for `loctype' locations"
		local rc = _rc
		exit `rc'
	}
	sum `lat', meanonly
	if (r(max) > 90 | r(min) < -90) {
		dis as err "`loctype' latitude var `lat' must be between -90 and 90"
		exit 198
	}
	sum `lon', meanonly
	if (r(max) > 180 | r(min) < -180) {
		dis as err "`loctype' longitude var `lon' must be between -180 and 180"
		exit 198
	}
	tempvar dlat dlon
	qui gen double `dlat' = `lat' * _pi / 180
	qui gen double `dlon' = `lon' * _pi / 180
	drop `lat' `lon'
	
	// rename variables to make things simpler
	local s = substr("`loctype'",1,1)	
	geonear_group_rename `id' id`s' `dlat' lat`s' `dlon' lon`s'

end


program define geonear_recur

	args wide sphere ops report ignore nearcount limit dwithin ///
		R ell_a ell_f fb fn baseN nregion ndone sum_ops rtime
	
	qui use "`fb'", clear
	// midpoint coordinates of the region's base locations
	local n_base = _N
	tempname minlat maxlat midlat minlon maxlon midlon
	sum latb, meanonly
	scalar `minlat' = r(min)
	scalar `maxlat' = r(max)
	scalar `midlat' = (`minlat'+`maxlat') / 2
	sum lonb, meanonly
	scalar `minlon' = r(min)
	scalar `maxlon' = r(max)
	scalar `midlon' = (`minlon'+`maxlon') / 2

	// distance from region's midpoint to the farthest base location
	if `sphere' ///
		qui gen double d = 2 * asin(min(1,sqrt( ///
			sin((latb - `midlat') / 2)^2 + ///
			cos(`midlat') * cos(latb) * ///
			sin((lonb - `midlon') / 2)^2))) * `R'
	else geonear_ellipsoid `midlat' `midlon' latb lonb d `ell_a' `ell_f'
	sum d, meanonly
	tempname dfar
	scalar `dfar' = r(max)
	drop d
	
	
	// distance between region's midpoint to all neighbors
	qui use "`fn'", clear
	
	if `sphere' ///
		qui gen double d = 2 * asin(min(1,sqrt( ///
			sin((latn - `midlat') / 2)^2 + ///
			cos(`midlat') * cos(latn) * ///
			sin((lonn - `midlon') / 2)^2))) * `R'
	else {
		geonear_ellipsoid `midlat' `midlon' latn lonn d `ell_a' `ell_f' 
		// do not drop neighbors with missing distance; these could
		// be needed further down the recursion
		qui replace d = 0 if mi(d)
	}
	
	// reduce set of potential neighbors
	if `nearcount' > 0 {
	
		local minnbor = `nearcount' + `ignore'
	
		// Distance from the midpoint to the `minnbor' nearest neighbor.
		tempname dnear
		if `minnbor' ==  1 {
			sum d, meanonly
			scalar `dnear' = r(min)
		}
		else {
			sort d idn
			scalar `dnear' = d[`minnbor']
		}
		
		// take within target distance into consideration as well
		qui keep if d <= max(2 * `dfar' + `dnear',`dfar' + `dwithin')
	}
	else qui keep if d <= `dfar' + `dwithin'
	
	drop d
	local n_nbor = _N


	// recursion base case
	if (`n_base' * `n_nbor' < `ops') | `n_base' <= 10 | `n_nbor' < 10 {
	
		if `wide' geonear_base_wide `sphere' `ignore' `nearcount' `ell_a' `ell_f' "`fb'"
		else geonear_base_long `sphere' `ignore' `nearcount' `limit' `dwithin' `R' `ell_a' `ell_f' "`fb'"		
		
		timer off 56
		qui timer list 56
		local runtime = r(t56)
		timer on 56
		
		scalar `nregion' = `nregion' + 1
		scalar `ndone' = `ndone' + `n_base'
		scalar `sum_ops' = `sum_ops' + `n_base' * `n_nbor'
		
		local timeleft = `runtime' / `ndone' * (`baseN' - `ndone')
		local do_report = `rtime' + `report' < `runtime'
		
		if `do_report' {
			if `rtime' == 0 {
				dis _n as txt "current   base    nbor      ops in       " /// 
					"cumul   cumul %     remaining"
				dis as txt " region   locs    locs      region     ops (M)" /// 
					"    % done    (hh:mm:ss)"
			}
			geonear_sec2str `timeleft'
			dis as res %6.0f `nregion' ///
				%8.0fc `n_base' ///
				%8.0fc `n_nbor' ///
				%12.0fc `n_base' * `n_nbor' ///
				%12.1fc `sum_ops' / 1e6 ///
				%10.1f `ndone' / `baseN' * 100 ///
				%14s "`r(hhmmss)'"
			scalar `rtime' = `runtime'
			
		}

		
	}
	else {
		tempfile fnbor
		qui save "`fnbor'"
		qui use "`fb'", clear
		
		if `maxlat' - `minlat' > cos(`midlat') * (`maxlon' - `minlon') {
			qui keep if latb < `midlat'
			tempfile split1
			qui save "`split1'"
			
			qui use "`fb'", clear
			qui keep if latb >= `midlat'
			tempfile split2
			qui save "`split2'"
		}
		else {
			local nobs = _N
			qui keep if lonb < `midlon'
			// special case if all points in region are co-located
			if _N == 0 {
				qui use "`fb'", clear
				qui keep if _n < _N / 2
			}
			tempfile split1
			qui save "`split1'"
			
			qui use "`fb'", clear
			qui keep if lonb >= `midlon'
			// special case if all points in region are co-located
			if _N == `nobs' {
				qui use "`fb'", clear
				qui keep if _n >= _N / 2
			}
			tempfile split2
			qui save "`split2'"
		}
		
		geonear_recur `wide' `sphere' `ops' `report' `ignore' `nearcount' `limit' `dwithin' ///
			`R' `ell_a' `ell_f' "`split2'" "`fnbor'" `baseN' `nregion' `ndone' `sum_ops' `rtime'
		tempfile hold
		qui save "`hold'"
		geonear_recur `wide' `sphere' `ops' `report' `ignore' `nearcount' `limit' `dwithin' ///
			`R' `ell_a' `ell_f' "`split1'" "`fnbor'" `baseN' `nregion' `ndone' `sum_ops' `rtime'
		append using "`hold'"
	}
	
end


program define geonear_base_wide
	
	args sphere ignore nearcount ell_a ell_f fb 

	// unmatched merge to bring base and nbors together
	merge using "`fb'"
	drop _merge
			
	forvalues i = 1/`nearcount' {
		qui gen `:type idn' idc`i' = idn[0]
		qui gen double cd`i' = .
	}

	tempname alat alon

	// If there are more neighbors than base point, loop over base points
	if mi(idb[_N]) {
	
		qui count if !mi(idb)
		local nloop = r(N)
		
		gen long nobs = _n
		
		local i 0
		while `++i' <= `nloop' {

			if `sphere' ///
				qui gen double d = 2 * asin(min(1,sqrt( ///
					sin((latn - latb[`i']) / 2)^2 + ///
					cos(latb[`i']) * cos(latn) * ///
					sin((lonn - lonb[`i']) / 2)^2)))
			else {
				scalar `alat' = latb[`i']
				scalar `alon' = lonb[`i']
				geonear_ellipsoid `alat' `alon' latn lonn d `ell_a' `ell_f' 
			}

			if `ignore' qui replace d = . if idn == idb[`i']
				
			forvalues j = 1/`nearcount' {
				sum d, meanonly
				sum nobs if d == r(min), meanonly
				qui replace idc`j' = idn[r(min)] in `i'
				qui replace cd`j' = d[r(min)] in `i'
				qui replace d = . in `r(min)'
			}
			
			drop d
		}
		
		drop nobs
	}
	else {

		qui count if !mi(idn)
		local nloop = r(N)

		qui gen `:type idn' hold_id = idn[0]
		qui gen double hold_dist = .
		qui gen double swap = .

		local i 0
		while `++i' <= `nloop' {
		
			if `sphere' ///
				qui gen double d = 2 * asin(min(1,sqrt( ///
					sin((latb - latn[`i']) / 2)^2 + ///
					cos(latn[`i']) * cos(latb) * ///
					sin((lonb - lonn[`i']) / 2)^2)))
			else {
				scalar `alat' = latn[`i']
				scalar `alon' = lonn[`i']
				geonear_ellipsoid `alat' `alon' latb lonb d `ell_a' `ell_f' 
			}
		
			if `ignore' qui replace d = . if idb == idn[`i']

			qui replace idc`nearcount' = idn[`i'] if d < cd`nearcount'
			qui replace cd`nearcount' = d if d < cd`nearcount'
			forvalues jj = `nearcount'(-1)2 {
				local j = `jj' - 1
				qui replace swap = cd`jj' < cd`j'
				qui replace hold_id = idc`j' if swap
				qui replace hold_dist = cd`j' if swap
				qui replace idc`j' = idc`jj' if swap
				qui replace cd`j' = cd`jj' if swap
				qui replace idc`jj' = hold_id if swap
				qui replace cd`jj' = hold_dist if swap
			}
			drop d
		}
		drop hold_dist hold_id swap
	}
	
	qui keep if !mi(idb)
	keep idb idc* cd*
	
end


program define geonear_base_long

	args sphere ignore nearcount limit dwithin R ell_a ell_f fb
	
	local n_nbor = _N

	// drop extra vars when no neighbors are within()
	if `n_nbor' == 0 keep idn
	else {
	
		// -expand- and -merge- is faster than -cross-
		gen long merge_id = _n
		sort merge_id
		tempfile fnbors
		qui save "`fnbors'"
		
		qui use "`fb'"
		qui expand `n_nbor'
		sort idb
		qui by idb: gen long merge_id = _n
		sort merge_id
		qui merge merge_id using "`fnbors'"
		drop _merge merge_id

		if `sphere' ///
			qui gen double d = 2 * asin(min(1,sqrt( ///
				sin((latn - latb) / 2)^2 + ///
				cos(latb) * cos(latn) * ///
				sin((lonn - lonb) / 2)^2))) * `R'
		else {
			geonear_ellipsoid latb lonb latn lonn d `ell_a' `ell_f' 
		}
		
		if `ignore' qui drop if idb == idn
		
		// select neighbors
		keep idb idn d
		if `nearcount' > 0 {
			sort idb d idn
			qui by idb: keep if _n <= `nearcount' | d <= `dwithin'
		}
		else qui keep if d <= `dwithin'
		
		// restrict set of neighbors if requested
		if `limit' < . {
			sort idb d idn
			qui by idb: keep if _n <= `limit'
		}
	} 

end


program define geonear_byte2str, rclass

	args b
	
	local n = ceil(`b' / 1024)
	if `n' < 10240 local unit k
	else {
		local unit m
		local n = ceil(`b' / 1048576)
	}
	
	return local s = trim(string(`n',"%16.0fc")) + "`unit'"

end


program define geonear_sec2str, rclass

	args sec
	
	local hh = int(`sec' / 3600)
	local mm = int(mod(`sec',3600) / 60)
	local ss = round(mod(`sec',60))
	
	return local hhmmss = string(`hh',"%02.0f") + ":" + ///
		string(`mm',"%02.0f") + ":" + ///
		string(`ss',"%02.0f")
	
end


program define geonear_group_rename

	// Rename variables while avoiding name conflicts.
	// args are, in order old_name1 new_name1 old_name2 new_name2, etc.
	local i 0
	while "``++i''" != "" {
		tempname tmp`i'
		rename ``i'' `tmp`i++''
	}
	
	local i 0
	while "``++i''" != "" {
		rename `tmp`i'' ``++i''
	}
	
end


program define geonear_ellipsoid

	args lat1 lon1 lat2 lon2 d a f
		
	tempname b
	scalar `b' = `a' - `a' * `f'

	// implement Vincenty's (1975) inverse solution
	// Source: http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
	
	// first approximation, equation 13
	tempvar L lambda
	qui gen double `L' = `lon2' - `lon1'
	qui gen double `lambda' = `L'
	
	// for speed, precompute all sin and cos of U
	tempvar U1 U2 sin_U1 sin_U2 cos_U1 cos_U2
	qui gen double `U1' = atan((1-`f') * tan(`lat1'))
	qui gen double `U2' = atan((1-`f') * tan(`lat2'))
	qui gen double `sin_U1' = sin(`U1')
	qui gen double `sin_U2' = sin(`U2')
	qui gen double `cos_U1' = cos(`U1')
	qui gen double `cos_U2' = cos(`U2')
	drop `U1' `U2'
	
	// Find lambda by iteration; mark out observation when converged
	tempvar cont
	gen `cont' = 1
	foreach v in sin_sigma cos_sigma sigma sin_alpha ///
		cos_sq_alpha cos_2sigma_m C lambda_old {
		tempvar `v'
		qui gen double ``v'' = .
	}
	local iter 0
	local more 1
	while `++iter' < 25 & `more' {
		// equation 14
		qui replace `sin_sigma' = sqrt((`cos_U2' * sin(`lambda'))^2 + ///
			(`cos_U1' * `sin_U2' - `sin_U1' * `cos_U2' * cos(`lambda'))^2) ///
			if `cont'
		// mark out co-incident points
		qui replace `cont' = 0 if `sin_sigma' == 0
		// equation 15
		qui replace `cos_sigma' = `sin_U1' * `sin_U2' + `cos_U1' * ///
			`cos_U2' * cos(`lambda') if `cont'
		// equation 16
		qui replace `sigma' = atan2(`sin_sigma',`cos_sigma') if `cont'
		// equation 17
		qui replace `sin_alpha' = `cos_U1' * `cos_U2' * sin(`lambda') / ///
			`sin_sigma' if `cont'
		// use trig identity to obtain cos^2 alpha
		qui replace `cos_sq_alpha' = 1 - `sin_alpha'^2 if `cont'
		// equation 18
		qui replace `cos_2sigma_m' = `cos_sigma' - 2 * `sin_U1' * ///
			`sin_U2' / `cos_sq_alpha' if `cont'
		// adjust if both points are on the equator
		qui replace `cos_2sigma_m' = 0 if `cos_sq_alpha' == 0 & `cont'
		// compute new lambda and compare to previous one
		qui replace `lambda_old' = `lambda' if `cont'
		// equation 10
		qui replace `C' = `f' / 16 * `cos_sq_alpha' * ///
			(4 + `f' * (4 - 3 * `cos_sq_alpha')) if `cont'
		// equation 11
		qui replace `lambda' = `L' + (1 - `C') * `f' * `sin_alpha' * ///
		  (	`sigma' + `C' * `sin_sigma' * (`cos_2sigma_m' + ///
		  `C'*`cos_sigma' * (-1 + 2* `cos_2sigma_m'^2))) if `cont'
		// mark out observations that have converged
		qui replace `cont' = 0 if abs(`lambda'-`lambda_old') <= 1e-12
		// we are done if all observations have converged
		sum `cont', meanonly
		local more = r(max)
	}
	drop `L' `sin_U1' `sin_U2' `cos_U1' `cos_U2' `lambda' `sin_alpha' `C' `lambda_old'
				
	tempvar u_sq A B delta_sigma
	qui gen double `u_sq' = `cos_sq_alpha' * (`a'^2 - `b'^2) / (`b'^2)
	// equation 3
	qui gen double `A' = 1 + `u_sq' / 16384 * (4096 + ///
		`u_sq' * (-768 + `u_sq' * (320 - 175 * `u_sq')))
	// equation 4
	qui gen double `B' = `u_sq' / 1024 * (256 + ///
		`u_sq' * (-128 + `u_sq' * (74 - 47 * `u_sq')))
	// equation 6
	qui gen double `delta_sigma' = `B' * `sin_sigma' * (`cos_2sigma_m' + ///
		`B' / 4 * (`cos_sigma' * ///
		(-1 + 2 * `cos_2sigma_m'^2) - ///
		`B' / 6 * `cos_2sigma_m' * (-3 + 4 * `sin_sigma'^2) * ///
		(-3 + 4 * `cos_2sigma_m'^2)))
	// equation 19; convert to km
	qui gen double `d' = `b' * `A' * (`sigma' - `delta_sigma') / 1000
	// co-incident points were marked out of the iteration loop
	qui replace `d' = 0 if `sin_sigma' == 0
	
	//  if failed to converge; distance is undefined (could be 100km off)
	qui replace `d' = . if `cont'
	
end

