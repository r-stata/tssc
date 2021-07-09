*! version 2.0.2  29may2015 Robert Picard, picard@netbox.com
program define geoinpoly

	version 11
	
	syntax varlist(min=2 max=2 numeric) [if] [in] using/ ///
		, [	///
		Unique					///
		noPROJection			///
		RING					///
		INSIDE					///
		]


	marksample touse
	qui count if `touse'
	if r(N) == 0 error 2000
	
	
	tokenize `varlist'
	local lat `1'
	local lon `2'
	
	
	if "`projection'" != "noprojection" {
	
		sum `lat' if `touse', meanonly
		if r(max) > 90 | r(min) < -90 {
			dis as err "latitude `lat' must be between -90 and 90"
			exit 198
		}	
	
		sum `lon' if `touse', meanonly
		if r(max) > 180 | r(min) < -180 {
			dis as err "longitude `lon' must be between -180 and 180"
			exit 198
		}
				
	}


	// by default, match point on a polygon ring (vertex or segment) and inside
	if "`ring'`inside'" == "" local match_what ringinside
	else local match_what `ring'`inside'
	
	
	cap confirm var _ID, exact
	if _rc == 0 {
		dis as err "polygon identifier _ID already exists"
		exit 198		
	}
	
	
	// uses the reference ellipsoid of the WGS 84 datum for the Mercator projection
	local a 6378137
	local f 298.257223563
	
	
	tempvar ptobs
	gen long `ptobs' = _n
	
	
	preserve

	
	qui keep if `touse'
	
	keep `ptobs' `lat' `lon'
	
	if "`projection'" != "noprojection" {
	
		// use the same projection origin for all projections
		tempname pt_y pt_x
		geo2xy_mercator 1 `lat' `lon' `pt_y' `pt_x' `a' `f' -180
	
		// The amount of stretch for lat at the poles is infinite; use largest non-missing
		qui replace `pt_y' = cond(`lat' < 0, c(mindouble), c(maxdouble)) ///
			if mi(`pt_y') & !mi(`lat')
		
		mata: geoinpoly_points = st_data(.,"`ptobs' `pt_y' `pt_x'")
		
	}
	else {
		mata: geoinpoly_points = st_data(.,"`ptobs' `lat' `lon'")
	}
		
	
	// polygons are expected to follow the format used by -shp2dta-.
	qui use "`using'", clear
	
	cap confirm numeric var _ID _Y _X
	if _rc {
		dis as err "was expecting variables _ID _Y _X in coordinates file"
		exit _rc
	}
	
	keep _ID _Y _X
	
	cap assert !mi(_ID)
	if _rc {
		dis as err "_ID cannot be missing in the coordinates file"
		exit _rc
	}
	
	// make sure that this is a shapefile with polygon(s)
	cap assert mi(_Y[1]) & mi(_X[1])
	if _rc {
		dis as err "a polygon must start with missing coordinates"
		exit _rc
	}
	
	if "`projection'" != "noprojection" {
	
		sum _Y, meanonly
		if r(max) > 90 | r(min) < -90 {
		noi dis  r(max) " " r(min)
			dis as err "Y (latitude) must be between -90 and 90 in coordinates file"
			exit 198
		}	
	
		sum _X, meanonly
		if r(max) > 180 | r(min) < -180 {
			dis as err "X (longitude) must be between -180 and 180 in coordinates file"
			exit 198
		}
		
		// use the same projection origin for all projections
		tempname pt_y pt_x
		geo2xy_mercator 1 _Y _X `pt_y' `pt_x' `a' `f' -180
	
		// The amount of stretch for lat at the poles is infinite; use largest non-missing
		qui replace `pt_y' = cond(_Y < 0, c(mindouble), c(maxdouble)) ///
			if mi(`pt_y') & !mi(_Y)
		
		mata: geoinpoly_main(geoinpoly_points, "_ID `pt_y' `pt_x'", "`match_what'")
		
	}
	else {		
		mata: geoinpoly_main(geoinpoly_points, "_ID _Y _X", "`match_what'")
	}
	
	mata: mata drop geoinpoly_points
	
	
	rename ptobs `ptobs'
	tempfile results
	qui save "`results'"
	

	restore
	

	qui merge 1:m `ptobs' using "`results'", nogen
	
	sort `ptobs' _ID
	if "`unique'" != "" {
		qui by `ptobs': keep if _n == 1
	}
	
	
end


// -geo2xy- is not required since we use a local copy of our routine
program define geo2xy_mercator, rclass

/*
-------------------------------------------------------------------------------

Mercator (ellipsoid)
====================

Source:

  Snyder, John Parr. Map projections--A working manual. No. 1395. USGPO, 1987. 

Available from http://pubs.usgs.gov/pp/1395/report.pdf.

Formulas on pages 44. Certified using numerical example at pp. 267

Projection arguments:

a     = semi-major axis of reference ellipsoid
f     = inverse flattening of reference ellipsoid
lon0  = projection's origin

Defaults if no projection arguments supplied

a     = 6378137 semi-major axis of WGS84
f     = 298.257223563 inverse flattening of WGS84
lon0  = relative; set to mid longitude range

-------------------------------------------------------------------------------
*/

	args touse lat lon y x a f lon0 whatsthis
	
	if !mi("`whatsthis'") | (!mi("`a'") & mi("`lon0'")) {
		dis as err "expected arguments are: a f lon0"
		exit 198
	}

	if "`a'" == "" {
	
		local a 6378137
		local f 298.257223563
	
		sum `lon' if `touse', meanonly
		local lon0 =  (r(min) + r(max)) / 2
		
	}
	
	// semi-minor axis
	tempname b
	scalar `b' = `a' - `a' / `f'
	
	// eccentricity, see Snyder, p. 13
	tempname e e2
	scalar `e2' = 2 * (1/`f') - (1/`f')^2
	scalar `e' = sqrt(`e2') 
	
	tempname d2r
	scalar `d2r' = _pi / 180
	
	tempname lambda0 
	scalar `lambda0' = `lon0' * `d2r'

	qui nobreak {
	
		local genrep = cond("`lon'" == "`x'","replace","gen double")
		
		// Snyder, p. 44, equation 7-6
		`genrep' `x' = `a' * (`lon' * `d2r' - `lambda0')  if `touse'
		
		// Snyder, p. 44, equation 7-7
		`genrep' `y' = `a' * log( ///
			tan(_pi / 4 + `lat' * `d2r' / 2) * ///
			((1 -`e' * sin(`lat' * `d2r')) / ///
			(1 + `e' * sin(`lat' * `d2r')))^(`e' / 2)) if `touse'
		
	}

	return local a `a'
	return local f `f'
	return local lon0 `lon0'
	return local pname = "Mercator"
	return local model = "Ellipsoid (`a',`f')"
	
	sum `y' if `touse', meanonly
	tempname height
	scalar `height' = r(max) - r(min)
	sum `x' if `touse', meanonly
	return local aspect = `height' / (r(max) - r(min))

end


version 11
mata:
mata set matastrict on

void matrix2data(real matrix m, string scalar polyvars)
{
	
	st_dropvar(.)
	st_addobs(rows(m))
	st_store(., st_addvar("double", tokens(polyvars)), m)
	exit(0)

}



void geoinpoly_main(

	real matrix points,			// points in memory: "obs_id y x"
	string scalar polyvars,		// "_ID _Y _X" from shapefile's coordinates dataset
	string scalar match_what	// "ring", "inside", or "ringinside"
	
)
{

	real matrix ///
		poly,		// line segments
		nextp,		// coordinates of next point
		ringbounds, // y-coor of polygon ring bounds: "rymin rymax"
		ringinfo,	// polygon ring's first and last row index
		mm, 		// min and max
		sidebounds, // x,y bounds of line segments: "ymin ymax xmin xmax"
		result		// point id with matching polygon id: "obs_id _ID"
	
	real colvector ///
		ring,		// polygon ring identifier
		slope,		// slope of line segment
		yintercept	// y-intercept of line segment
		
	real scalar ///
		i, 
		N,
		first,
		last,
		bad,
		badring,
		polyxmin,
		polyxmax


	// the raw shapefile's polygon coordinates from "`using'" are in memory
	poly = st_data(.,polyvars)	// "_ID _Y _X"

	// coordinates of the next point
	nextp = poly[|2,2 \ .,3|] \ (.,.)
	
	
	// precompute slope and y-intercept for each line segment
	slope = (poly[.,2] :- nextp[.,1]) :/ (poly[.,3] :- nextp[.,2])
	yintercept = poly[.,2] :- slope :* poly[.,3]
	
	
	// missing coordinates indicate a ring start
	ring = runningsum(poly[.,3] :== .)
	
	// y-coordinate bounds for each ring
	ringbounds = J(rows(ring),2,.)
	ringinfo = panelsetup(ring,1)
	for (i=1; i<=rows(ringinfo); i++) {
	
		first = ringinfo[i,1]
		last  = ringinfo[i,2]
		N  = last - first + 1
		
		mm = colminmax(poly[|first,2\last,2|])

		// "rymin rymax"
		ringbounds[|first,1\last,2|] = J(N,1,mm[1,1]), J(N,1,mm[2,1])
	}


	// organize line segment coordinates as "ymin ymax xmin xmax"
	sidebounds = rowminmax((poly[.,2],nextp[.,1])), rowminmax((poly[.,3],nextp[.,2]))
	
	
	// mark out rings that do not meet ESRI specs for polygons
	badring = 0
	for (i=1; i<=rows(ringinfo); i++) {
	
		first = ringinfo[i,1]
		last  = ringinfo[i,2]
		N  = last - first + 1
		
		// a polygon must contain at least 5 points
		bad = N < 5
		
		// must be a closed loop
		bad = bad + !((poly[last,3] == poly[first+1,3]) & (poly[last,2] == poly[first+1,2]))

		// blank out _ID for the whole ring if bad
		if (bad) {
			poly[|first,1\last,1|] = J(N,1,.)
			badring = badring + 1
		}
		
	}
	if (badring) {
		printf("(note: dropped %f shapes that are not polygons)\n", badring)
	}

	
	// mark out first obs of a ring
	poly[.,1] = poly[.,1] :/ (poly[.,3] :!= .)
	
	// mark out last segment of a ring
	poly[.,1] = poly[.,1] :/ (nextp[.,2] :!= .)
	
	// mark out consecutive points
	poly[.,1] = poly[.,1] :/ !((poly[.,2] :== nextp[.,1]) :& (poly[.,3] :== nextp[.,2]))
	

	// polygon data to use, i.e.
	// "_ID ymin ymax xmin xmax slope yintercept rymin rymax"
	poly = select((poly[.,1],sidebounds,slope,yintercept,ringbounds), (poly[.,1] :!= .))


	// overall x-bounds of polygon sides
	polyxmin = colmin(poly[.,4])
	polyxmax = colmax(poly[.,5])
	
	
	// drop points that are outside the x-bounds of polygon sides
	points = select(points, (points[.,3] :>= polyxmin :& points[.,3] :<= polyxmax))


	// order points by x-coordinate to make the recursion efficient
	_sort(points,3)


	result = geoinpoly_recur(points, poly, match_what)
	
	// we are done, more the results to Stata memory
	st_dropvar(.)
	st_addobs(rows(result))
	st_store(., st_addvar("long", ("ptobs","_ID")), result)
	
}


real matrix geoinpoly_recur(

	real matrix points,			// "obs_id y x"
	real matrix poly,			// "_ID ymin ymax xmin xmax slope yintercept rymin rymax"
	string scalar match_what	// "ring", "inside", or "ringinside"
	
)
{
	real matrix ///
		res1,		// results from 1st half of recursion
		res2,		// results from 2nd half of recursion
		points1, 	// points for 1st half of recursion
		points2,  	// points for 2nd half of recursion
		poly1,  	// line segments for 1st half of recursion
		poly2,  	// line segments for 2nd half of recursion
		polyp,  	// line segments for a point in base case
		polyinfo	// polygon's first and last row index
		
	real colvector ///
		xminmax, 
		y,			// y-coor of intersection of point's x-meridian with polygon line segments
		polyy,		// subvector of y for a polygon
		onring, 
		touse
		
	real scalar ///
		mid, 
		i, 
		j, 
		first, 
		last, 
		exact, 
		sidesSN, 
		sidesNS

		
	// ------------------------- recursion base case --------------------------
	if (rows(points) < 10) {
	
		res1 = J(0,2,.)
	
		for (i=1; i<=rows(points); i++) {
		
		
			// select line segments if
			//   1. the point's y-coor is within the y-bounds of the ring
			//   2. the point's x-coor is within the segment's x-bound
			polyp = select(poly, (
				poly[.,8] :<= points[i,2] :& poly[.,9] :>= points[i,2] :&
				poly[.,4] :<= points[i,3] :& poly[.,5] :>= points[i,3]))
				
			
			if (rows(polyp))  {
			
					// y-coor of intersection of point's x-meridian with polygon line segments
					y = points[i,3] :* polyp[.,6] :+ polyp[.,7]
					
					
					// flag line segment(s) if point is located on a vertex or a polygon side?
					// make a special case for vertical segments
					onring = points[i,2] :== y :| 
							(y :== . :& points[i,2] :>= polyp[.,2] :& points[i,2] :<= polyp[.,3])
					
					
					// process each polygon separately
					polyinfo = panelsetup(polyp,1)
					for (j=1; j<=rows(polyinfo); j++) {
					
						first = polyinfo[j,1]
						last  = polyinfo[j,2]
						
						polyy = y[|first,1\last,1|]
						
						// is the point on a ring?
						exact = sum(onring[|first,1\last,1|])

						if (exact & match_what != "inside") {
								res1 = res1 \ (points[i,1],polyp[first,1])
						}
						
						if (!exact & match_what != "ring") {
						
							// avoid double-counting if vertices are aligned with the point's x-meridian
							touse = points[i,3] :!= polyp[|first,4\last,4|]

							sidesSN = sum(polyy :< points[i,2] :& touse)
							sidesNS = sum(polyy :> points[i,2] :& touse)
							
							if (mod(sidesSN,2) != mod(sidesNS,2)) {
								printf("{err}Results differ when starting from opposite poles.{txt}\n")
								printf("{err}Problem occurs with _ID == %f{txt}\n",polyp[1,1])
								exit(9)
							}
							
							if (mod(sidesSN,2)) {
								res1 = res1 \ (points[i,1],polyp[first,1])
							}
						}
						
					}				
			
			}
			
		}
			
		return(res1)
		
	}
	else { // ---------------- continue dividing ------------------------------
	
		mid = trunc(rows(points) / 2)
		
		points1 = points[|1,1 \ mid,.|]
		points2 = points[|mid+1,1 \ .,.|]
		
		xminmax = colminmax(points1[.,3])
		poly1 = select(poly, !(poly[.,5] :< xminmax[1] :| poly[.,4] :> xminmax[2]))
		
		xminmax = colminmax(points2[.,3])
		poly2 = select(poly, !(poly[.,5] :< xminmax[1] :| poly[.,4] :> xminmax[2]))

		res1 = geoinpoly_recur(points1, poly1, match_what)
		res2 = geoinpoly_recur(points2, poly2, match_what)

		return(res1\res2)
	}

}


end
