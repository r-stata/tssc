{smcl}
{* *! version 1.0.10  15aug2015}{...}
{cmd:help geoinpoly}
{hline}

{title:Title}

{phang}
{cmd:geoinpoly} {hline 2} Match geographic locations to shapefile polygons


{title:Syntax}

{p 8 14 2}
{cmd:geoinpoly} {it:latitude} {it:longitude} {ifin} 
{cmd:using} {help filename:{it:coordinates_file}}
[{cmd:,} 
{opt u:nique} 
{opt ring}
{opt inside}
{opt noproj:ection}]


{title:Description}

{pstd}
{cmd:geoinpoly} returns, in a variable named {it:_ID}, 
the identifier of a polygon from
{help filename:{it:coordinates_file}}
that spatially overlays a point
defined by {it:latitude} and {it:longitude}.
If there is more than one overlaying polygon,
the observation is duplicated as needed so that all
matching polygon identifiers can be stored in {it:_ID}.
The {opt u:nique} option can be used to limit each point to
a single matching polygon, in which case the lowest identifier
in terms of sort order is returned in {it:_ID}.

{pstd}
The {help filename:{it:coordinates_file}} must follow the format
used by
{cmd:shp2dta}
(from SSC, {it:{stata ssc install shp2dta:click to install}})
when converting shapefiles to Stata datasets.
It must contain the following 3 variables: {it:_ID} (polygon identifier),
{it:_X} (longitude), and {it:_Y} (latitude).

{pstd}
All coordinates ({it:latitude} {it:longitude} and {it:_Y} {it:_X})
must be 
based on the same
geographic coordinate system. 
Latitudes range from -90 to 90
and longitudes range from -180 to 180.
{cmd:geoinpoly} assumes that polygon segments represent
lines of constant bearing (also referred to as rhumb lines or loxodromes).
To precisely calculate the latitude at which a
polygon segment intersects the meridian, 
{cmd:geoinpoly} transforms all geographic coordinates to ({it:x-coor}, {it:y-coor}) using an
ellipsoid Mercator projection.
This projection has the property of representing lines of
constant bearing as straight lines on the
projected plane.

{pstd}
If {opt noproj:ection} is specified, {cmd:geoinpoly} skips the
Mercator projection step and uses 
{it:latitude} {it:longitude} and {it:_Y} {it:_X}
without any further transformation.

{pstd}
By default, {cmd:geoinpoly} will return a match if
the point falls either inside or on the polygon. 
With the {opt inside} option, a match on a vertex
or on a side is excluded. 
With the {opt ring} option, a polygon is a match
only if the point is located on a vertex or exactly
on a side. 


{title:Rules for polygons}

{pstd}
Polygons with different
identifiers ({it:_ID}) may be adjacent or even overlap
other polygons. 

{pstd}
A polygon may consist of one or more rings.
A ring starts with an observation where _X and _Y are missing
followed by a sequence of at least four points that form
a closed loop. 
So rings are also polygons but they all have the same
identifier value in {it:_ID} (e.g. Hawaii is described
as a single polygon that contains several
rings, one for each island). 

{pstd}
A ring cannot self-intersect and multiple rings within the same polygon cannot
intersect either.
A ring may be completely inside another ring of the same polygon, in which
case the inside ring describes a hole in the polygon.
A polygon's rings
 may touch each others at vertices but not along
segments.

{pstd}
See {browse "https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf":ESRI's technical specifications} 
for more information about shapefile polygons.


{title:Algorithm}

{pstd}
{cmd:geoinpoly} uses a 
{browse "http://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm":ray casting algorithm} 
to determine if a point falls inside a polygon.
The point's longitude determines the ray used (i.e. meridian or line of longitude
that passes by the point's location).
Starting from both the North Pole and South Pole, {cmd:geoinpoly} counts, by polygon, the number of 
line segments crossed before reaching the latitude of the point.
An odd count indicates that the point is in the polygon; an even count
indicates that the point is located outside the polygon.
If results differ when counting from opposite poles, {cmd:geoinpoly}
will stop and display which polygon triggered the error.

{pstd}
A point is considered on the ring if it matches a vertex
or if it is located exactly at the point where the ray intersects
the segment. For vertical segments, the slope is infinite so
{cmd:geoinpoly} uses the latitude of the segment's vertices 
to determine if the point is on the segment.

{pstd}
{cmd:geoinpoly} incorporates the same divide and conquer strategy
used in {cmd:geonear} (from SSC, {it:{stata ssc install geonear:click to install}})
to significantly reduce the number of polygon segments
that need to be counted. 
The points in memory are initially sorted by longitude and
recursively split in two until the number of points 
falls below a preset cutoff and triggers the recursion's base case. At each step, 
polygon segments are discarded if they are outside the x-bounds
of points at that stage.
When a base case is reached, the number of
points and line segments is very small.
The y-coordinate where the point's longitude line
intersects polygon line segments is then calculated and 
the _ID of matching polygon(s) is returned.


{title:Examples}

{pstd}
The examples below require that you first install {cmd:geo2xy} and its
U.S. state boundaries shapefile datasets. To install {cmd:geo2xy} and 
download its datasets to the current directory:

	{cmd:.} {stata ssc install geo2xy}
	{cmd:.} {stata `"net get geo2xy, from("http://fmwww.bc.edu/repec/bocode/g")"'}


{title:Example 1: Random points over the Midwestern U.S. States}

{pstd}
The following example creates a set of points randomly distributed over the Midwestern U.S.
We use {cmd:geoinpoly} to match each point to a state polygon. We then
merge with the shapefile's database and get the shape's attributes.

	{cmd}set seed 42134123
	clear
	set obs 10000
	gen double _Y = 40 + 8.5 * runiform()
	gen double _X = -90 + 9 * runiform()
	
	geoinpoly _Y _X using "geo2xy_us_coor.dta"
	tab _ID, missing
	
	merge m:1 _ID using "geo2xy_us_data.dta", keep(master match) nogen
	tab NAME{txt}
	{it:({stata geoinpoly_examples ex1:click to run})}
         
{pstd}
Now let's produce a map to visualize the results. We use {cmd:geo2xy}
to project latitude and longitude to (x,y) and highlight
points in Michigan differently. Do the same for points that fall into the
Great lakes or in Canada. 

	{cmd}levelsof _ID, clean sep(",") // polygon identifiers that have matched
	local states `r(levels)'
	
	rename _ID _IDmatched
	append using "geo2xy_us_coor.dta"
	drop if !inlist(_ID , `states') & !mi(_ID)
	
	geo2xy _Y _X, gen(ycoor xcoor) proj(albers)
	
	scatter ycoor xcoor if !mi(_IDmatched), msymbol(point) mcolor(green) || ///
		scatter ycoor xcoor if !mi(_IDmatched) & NAME == "Michigan", msymbol(point) mcolor(cranberry) || ///
		scatter ycoor xcoor if mi(_IDmatched) & mi(_ID), msymbol(point) mcolor(sandb) || ///
		line ycoor xcoor if !mi(_ID) , lwidth(thin) lcolor(gray) cmissing(n)  ///
		ylabel(minmax) yscale(off) ///
		xlabel(minmax) xscale(off) ///
		aspectratio(`=r(aspect)') legend(off){txt}
	{it:({stata geoinpoly_examples ex1b:click to run})}


{title:Example 2: The Four Corners}

{pstd}
The following example illustrates what happens when points are
located on a polygon ring (i.e. on a vertex or exactly on a segment).
We create a set of points around the exact location of the Four Corners,
a point that is at the intersection of 4 U.S. States.

	{cmd}set seed 34124
	clear
	set obs 50
	gen pointid = _n
	gen double lat = 36.99908399999999631
	gen double lon = -109.0452229999999929
	replace lat = lat + runiform() - .5 if _n > 1
	replace lon = lon + runiform() - .5 if _n > 1
	
	geoinpoly lat lon using "geo2xy_us_coor.dta"
	
	bysort pointid (_ID):	gen N = _N
	tab _ID N, missing{txt}
	{it:({stata geoinpoly_examples ex2a:click to run})}

{pstd}
Now let's continue with the points in memory but redo using the {opt u:nique}, 
{opt ring}, and {opt inside} option. Note that {opt u:nique} and {opt ring}
are combined to avoid multiple matches for the Four Corner point.

	{cmd}drop _ID
	bysort pointid: keep if _n == 1
	
	geoinpoly lat lon using "geo2xy_us_coor.dta", unique
	rename _ID _IDunique
	
	geoinpoly lat lon using "geo2xy_us_coor.dta", inside
	rename _ID _IDinside
	
	geoinpoly lat lon using "geo2xy_us_coor.dta", ring unique
	rename _ID _IDringuniq
	
	list in 1/5{txt}
	{it:({stata geoinpoly_examples ex2b:click to run})}

{pstd}
This is what happens if the {opt u:nique} is omitted:

	{cmd}geoinpoly lat lon using "geo2xy_us_coor.dta", ring
	list in 1/10{txt}
	{it:({stata geoinpoly_examples ex2c:click to run})}


{title:Example 3: Overlapping polygons}

{pstd}
The {help filename:{it:coordinates_file}} may contain overlapping
polygons. You can even mix and match polygons from different
shapefiles as long as you don't
get the identifiers mixed-up. In this example, we use {cmd:geocircles}
(from SSC, {it:{stata ssc install geocircles:click to install}})
to create polygons around the University of Michigan and
Ohio State University and append these polygons to the U.S. state boundaries
polygons.

	{cmd}geocircles 42.265864 -83.748694 150, data("data.dta") coor("coor_MI.dta") replace
	geocircles 40.012308 -83.027586 150, data("data.dta") coor("coor_OH.dta") replace
	use "coor_MI.dta", clear
	replace _ID = -1
	append using "coor_OH.dta"
	replace _ID = -2 if _ID != -1
	append using "geo2xy_us_coor.dta"
	save "states_circles.dta", replace{txt}
	{it:({stata geoinpoly_examples ex3a:click to run})}
          
{pstd}
Next we create points over an area that covers the region and 
find matching polygons and note how many polygons matched.

	{cmd}set seed 5234523
	clear
	set obs 10000
	gen double _Y = 38 + 8 * runiform()
	gen double _X = -90 + 9 * runiform()
	
	geoinpoly _Y _X using "states_circles.dta"
	
	bysort _Y _X: gen N_ID = _N
	tab _ID N_ID, missing
	
	merge m:1 _ID using "geo2xy_us_data.dta", keep(master match) keepusing(NAME) nogen
	tab NAME{txt}
	{it:({stata geoinpoly_examples ex3b:click to run})}

          
{pstd}
Finally, we create a map that highlights points in the circles
and points common to both circles. We drop state polygons that do not
overlap the circles.

	{cmd}levelsof _ID if N_ID > 1, clean sep(",")
	local states `r(levels)'
	
	rename _ID _IDmatched
	append using "states_circles.dta"
	drop if !inlist(_ID , `states') & !mi(_ID)
	
	geo2xy _Y _X, gen(ycoor xcoor) proj(albers)
	
	scatter ycoor xcoor if _IDmatched > 0 & !mi(_IDmatched), msymbol(point) mcolor(gs15) || ///
		scatter ycoor xcoor if N_ID == 2 & NAME == "Michigan", msymbol(point) mcolor("blue") || ///
		scatter ycoor xcoor if N_ID == 2 & NAME == "Ohio", msymbol(point) mcolor("red") || ///
		scatter ycoor xcoor if N_ID == 3, msymbol(point) mcolor(green) || ///
		line ycoor xcoor if !mi(_ID) & _ID > 0, lwidth(thin) lcolor(gray) cmissing(n) || ///
		line ycoor xcoor if !mi(_ID) & _ID < 0, lwidth(vthin) lcolor(gray) cmissing(n)  ///
		ylabel(minmax) yscale(off) ///
        xlabel(minmax) xscale(off) ///
        aspectratio(`=r(aspect)') legend(off){txt}
	{it:({stata geoinpoly_examples ex3c:click to run})}


{title:References and acknowledgements}
        
{pstd}
The U.S. state boundaries datasets distributed with
{cmd:geo2xy} and used in the examples above
were generated by {cmd:shp2dta}
using
the {it:2013 Cartographic Boundary File, State for United States, 1:500,000}
shapefile distributed by the U.S. Census Bureau and available from
{it:{browse "http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html":Cartographic Boundary Shapefiles - States}}.
The xml in the shapefile includes the statement: "These products are 
free to use in a product or publication, 
however acknowledgement must be given to the U.S. Census Bureau as the source."

{pstd}
ESRI, {browse "http://support.esri.com/en/knowledgebase/whitepapers/download/fileid/282":ESRI Shapefile Technical Description, An ESRI White Paper - July 1998}.

{pstd}
The ray casting algorithm
is explained in the {browse "http://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm":Point in polygon} 
Wikipedia page.

{pstd}
Darel Rex Finley, 
{browse "http://alienryderflex.com/polygon/":Point-In-Polygon Algorithm - Determining Whether A Point Is Inside A Complex Polygon}.

{pstd}
Eric Haines, 
{browse "http://erich.realtimerendering.com/ptinpoly/":Point in Polygon Strategies}.


{title:Author}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}


{marker also}{...}
{title:Also see}

{psee}
Stata:  {help cross}
{p_end}

{psee}
SSC:  
{stata "ssc des geo2xy":geo2xy},
{stata "ssc des geocircles":geocircles}, {stata "ssc des geodist":geodist}, {stata "ssc des geonear":geonear},
{stata "ssc des shp2dta":shp2dta}, {stata "ssc des spmap":spmap}, {stata "ssc des mergepoly":mergepoly}
{p_end}

{psee}
Others:  {browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/194666-shapefiles-which-points-latitude-longitude-are-within-which-polygon?p=194934#post194934":Maurizio Pisati's -point2poly- on Statalist}
{p_end}
