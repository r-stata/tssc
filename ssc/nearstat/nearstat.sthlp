{smcl}
{* December 2008}{...}
{hline}
{cmd:help for nearstat} 
{hline}

{title:Title}

{p 2 8 2}
{bf:nearstat --- Calculates distances, generates distance-based variables, and exports distance matrix to files.}

{marker contents}{dlgtab: Table of Contents}
{p 2 16 2}

{p 2}{help nearstat##syntax:Syntax}{p_end}
{p 2}{help nearstat##description:General description}{p_end}
{p 2}{help nearstat##options:Description of the options}{p_end}
{p 2}{help nearstat##results:Saved scalars}{p_end}
{p 2}{help nearstat##examples:Examples}{p_end}
{p 2}{help nearstat##refs:References}{p_end}
{p 2}{help nearstat##citat:Citation}{p_end}
{p 2}{help nearstat##author:Author information}{p_end}
{hline}

{marker syntax}{title:Syntax}

{phang}
{cmdab: nearstat} {varlist:1} [{help if}] [{help in}]{cmd:,} {cmd:near({varlist:2})} {cmdab:dist:var(}{newvar:1}{cmd:)} [ {it:Other options} ] 

{synoptset 32 tabbed}
{synopthdr}
{synoptline}
{syntab:Options}   
     
{synopt :{cmd:near({varlist:2})}}indicate latitudes and longitudes for the neighboring observations or areal units; this option is required{p_end}

{synopt :{cmdab:dist:var(}{it:{help newvar:newvar1}}{cmd:)}}calculate distance to nearest neighbors; this option is required{p_end}

{synopt :{opt kth(#)}}specify the order of the nearest neighbors to which distance needs to be calculated; default is kth(1){p_end}

{synopt :{cmd:nid(}{varname} {newvar:2}{cmd:)}}request the identity or name of the specified nearest neighbors{p_end}

{synopt :{opt cart}}request distance calculation for Cartesian coordinates.{p_end}

{synopt :{opt r(#)}}indicate the earth radius value to be used in case of spherical coordinates; 
default is r(6371.009), i.e., 6371.009 km{p_end}

{synopt :{cmdab:contv:ar(}{it:{help varlist:varlist3}}{cmd:)}}specify a list of variables to be used in calculation of descriptive statistics{p_end}

{synopt :{opth statv:ar(newvarlist)}}specify a list of new variable names to hold calculated descriptive statistics or to hold the variable values corresponding 
		to nearest neighbors{p_end}

{synopt :{opt statn:ame(stats)}}indicate the descriptive statistics to be calculated{p_end}
	  : where {it:stats} is either {it:min}, {it:max}, {it:mean}, {it:std}, or {it:sum}

{synopt :{opt knn(#>=2)}}request statistics for nearest neighbors{p_end}

{synopt :{opth db:and(numlist)}}specify a distance band when requesting statistics, a neighbor count variable, or a dummy variable for neighbors falling in 
		 the specified distance band{p_end}

{synopt :{opt all:nei}}request descriptive statistics for all neighbors{p_end}

{synopt :{cmdab:dn:ame(}{newvar:3}{cmd:)}}request a dummy variable equal to 1 if the specified nearest neighbors are within the distance band 
		  specified with {opt dband()}{p_end}

{synopt :{cmdab:nc:ount(}{newvar:4}{cmd:)}}request a variable holding the number of neighbors falling in ring {opt dband()}{p_end}

{synopt :{cmdab:inc:dist(}{newvar:5}{cmd:)}}request a variable holding incremental distance to reach a metropolitan area with a specified population threshold{p_end}

{synopt :{opt atpop(#)}}specify the metropolitan area population threshold{p_end}

{synopt :{opt alpha(#)}}request distance weighted statistics{p_end}

{synopt :{cmd:iidist(}{newvar:6}{cmd:)}}request a variable holding one-to-one distance between input and near features{p_end}

{synopt :{cmdab:minm:axd(}{newvar:7} {it:mmtype}{cmd:)}}request a variable holding the mininimu or maximum 
distance for each observation, where {it:mmtype} must equal to {it:min} or {it:max}{p_end}

{synopt :{opt exp:dist(distname)}}export a matrix containing the distances between each input feature and all near features{p_end}
	  
{synopt :{opt expto(Stata|tab|csv|Mata)}}specify a file format for the distance matrix{p_end}

{synopt :{opt spa:rse(tab|csv|Mata)}}export the distance matrix in sparse form{p_end}

{synopt :{opt noz:ero}}remove zeros from sparse distance matrix{p_end}

{synopt :{cmd:des(}{it:des_option,}[{it:des_suboption}]{cmd:)}}display descriptive statistics for the distances between input and near features, 
	   distance to the kth-nearest neighbors (k=1,..., N-1), and neighbor count within a distance band{p_end}
	  : where {it:des_option=stat} to request {it:Min, Mean, Std, Max, and Sum}
	    and {it:des_suboption=quart} to request {it:quartiles}

{synopt :{opt replace}}overwrite existing variables and files{p_end}

{synopt :{opt favor(speed|space)}}favor speed or space{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{dlgtab:Description}

{pstd}
Using Mata, the Stata’s new matrix language, {cmd:nearstat} calculates distances, generates distance-based variables, and exports the distances
to a Stata matrix, a Mata file, or a text file. To generate the variables, {cmd:nearstat} performs, for each observation in a Stata dataset, 
a series of computational tasks including, but not limited to, calculating distance-weighted descriptive statistics over all neighbors, nearest 
neighbors, and neighbors falling in a specified distance band; calculating distance to nearest neighbors; counting the number of neighbors 
falling in a specified distance band; and determining whether a specified (e.g., first, second, third,…) nearest neighbor falls within a certain 
distance band. Distance is calculated as the Great Circle or crow-fly distance depending on whether spherical or Cartesian coordinates are 
supplied to {cmd:nearstat}.

{pstd}
Spherical coordinates can be obtained from any shapefiles using the Stata command {cmd:shp2dta} written by Kevin Crow (see {help shp2dta} 
if installed). If not installed, a copy of {cmd:shp2dta} can be found {stata "ssc describe shp2dta":here}. 

{pstd}
{hi:T}opologically {hi:I}ntegrated {hi:G}eographic {hi:E}ncoding and {hi:R}eferencing (TIGER)- LINE shapefiles for metropolitan areas, counties, 
census tracts, etc., are available from the U.S. Census Bureau's website (see the references below). One way to obtain Cartesian or projected 
coordinates is to project the shapefiles in the ArcGIS software using appropriate projected coordinate systems. 

{pmore}{cmd:nearstat} requires Stata 10.1 or higher.


{marker options}{dlgtab:Options}

{phang}
{cmd:near({varlist:2})} specifies the variables holding latitudes and longitudes for the observations or areal units
to which distance needs to be calculated. This option is required. 

{pmore}{varlist:1} holds latitudes and longitudes for the observations or areal units from which distance needs to be calculated.

{pmore}Observations or areal units in {varlist:1} are referred to as input features and those in {varlist:2} are referred to as near features.

{pmore}{bf:Note 1:} {varlist:1} and {varlist:2} may contain the same areal units. For example, you might want to calculate the distance 
from each county to its nearest neighboring county or to obtain for each county the average per capita income for the eight nearest 
counties. In this case, the two variables supplied in {varlist:1} would be exactly the same as those supplied in {varlist:2}.

{pmore}Different areal units are also allowed. For instance, you might want to calculate the distance from each rural county 
to its nearest metropolitan area. In this case, {varlist:1} would hold the latitudes and longitudes of the rural counties while {varlist:2} 
would contain the population weighted latitudes and longitudes of the metropolitan areas. Although the areal units supplied in {varlist:1} 
and {varlist:2} may be different, their coordinates must be of the same type. 

{phang}
{cmd:distvar(}{newvar:1}{cmd:)} specifies the name of a variable for holding distance from each input feature to its nearest neighbor 
specified with the {opt kth(#)} option. This option is required. 

{phang}
{opt kth(#)} indicates the order of the nearest neighbors to which distance is to be calculated. For example, specifying {opt kth(2)}
indicates the second nearest neighbors. The default is to calculate distance to the first nearest neighbors, i.e., {opt kth(1)}.

{phang}
{cmd:nid(}{varname} {newvar:2}{cmd:)} requests the identification numbers or names of the nearest neighbors specified with {opt kth(#)}. This 
option requires two variable names. The first one should be the name of the identifier variable for the near features. The other one is the name 
of a variable to hold the requested identitification numbers or names. Obviously, if {varlist:1} = {varlist:2} then there is only one identifier 
variable for both input and near features. If an observation has two or more equidistant neighbors, given the order considered, {cmd:nearstat} 
will report the first one encountered.

{phang}
{opt cart} indicates that coordinates are projected and that crow-fly distance should be calculated using the Pythagorean formula: 
{bf:dij=sqrt((xj-xi)^2+(yj-yi)^2)}. When {opt cart} is specified, the distance unit is the same as that of the projected coordinates. 
Option {opt cart} may be specified if the coordinates are in arbitrary digitizing units.

{pmore} By default, distance is calculated for spherical non-projected coordinates. In such a case, {cmd:nearstat} calculates the "Great Circle" 
distance using the Haversine formula, which yields more accurate distance than the Law of Cosines or Vincenty formula due to problems related to 
small distances.

{pmore}The Haversine formula to calculate distance between two points is given as follows:

{pmore}{ul:Haversine Formula}{p_end}
{pmore2}{it:dlong = long2 - long1}{p_end}
{pmore2}{it:dlat = lat2 - lat1}{p_end}
{pmore2}{it:z = sin^2(dlat/2) + cos(lat1) * cos(lat2) * sin^2(dlong/2)}{p_end}
{pmore2}{it:c = 2 * arcsin(min(1,sqrt(z)))}{p_end}
{pmore2}{it:dist = r * c},{p_end}
{pmore2}where {it:c} is the Great Circle distance in radians and {it:r} is the radius of the earth. {it:dist} is in the same unit as {it:r}.
By default, {it:r} is set to 6371.009 km considered to be the Earth's mean radius by the International Union of Geodesy and Geophysics (IUGG).
The IUGG's corresponding value in miles is 3958.761, which users can supply with the {opt r()} option to obtain distance in miles.{p_end}

{pmore}Spherical coordinates must be measured in decimal degrees. If your coordinates are in a degrees, minutes, and seconds format, 
you can convert them into decimal degrees using the following formula:{p_end}

{pmore2}{it:Decimal value = Degrees + (Minutes/60) + (Seconds/3600)}{p_end}

{pmore}For instance, a latitude of 122 degrees 45 minutes 45 seconds north is equal to 122.7625 degrees north. 

{phang}
{opt r(#)} indicates the value to be used for the Earth radius or mean radius in case of spherical coordinates. The Earth radius usually refers 
to various fixed distances and to various mean radii since only a sphere has a true radius. Fortunately, the numerical differences among different 
radii vary by far less than one percent, making the choice of # less of a concern.

{pmore}{opt r(#)} and {opt cart} may not be combined.

{phang}
{cmd:contvar(}{varlist:3}{cmd:)} specifies the variables to be used in calculating the statistics or the variables whose values associated with 
the nearest neighbors need to be reported.

{pmore}{bf:Note 2:} {varlist:3} must have the same number of valid (non-missing) observations as {varlist:2}.

{phang}
{opth statvar(newvarlist)} provides a list of names for the variables to hold the calculated descriptive statistics or to hold the values of the 
variables in {varlist:3} corresponding to the nearest neighbors. Specify one variable name for each variable in {varlist:3}.

{pmore}{bf:Note 3:} Options {opt contvar()} and {opt statvar()} must be combined.
 
{phang}
{opt statname(stats)} indicates the statistics to be calculated. {it:stats} may be either min, max, mean, std, or sum. 
When variables listed in {varlist:3} are dummies, mean is equivalent to proportion or percentage if multiplied by 100.

{pmore}{bf:Note 4:} If {opt contvar()} and {opt statvar()} are specified, but {opt statname()} is not, then each variable in listed 
{it:{help newvarlist}} will contain the values of the corresponding variable listed in {varlist:3} associated with the nearest neighbors, 
given the order specified with {opt kth()} (see {help nearstat##examples:examples} 2 and 4).

{phang}
{opt knn(#)} indicates the number of nearest neighbors to be used when calculating the descriptive statistics. # cannot be less than 2 or 
greater than the number of valid observations contained in {varlist:2}. 

{phang}
{opth dband(numlist)} indicates the distance band to be used with option {opt dname()} and/or {opt ncount()}, or requests that statistics be 
calculated for near features falling in the ring specified with {bf:dband()}. 

{pmore}{bf:Note 5:} When {opt dband()} is specified, by default, the distance unit is assumed to be kilometers, but that can be overridden
with option {opt cart} or {opt r(#)}. 

{phang}
{opt allnei} requests that statistics be calculated using all near features. {opt allnei} and {opt knn()} may not be combined.

{phang}
{opt alpha(#)} requests distance-weighted statistics. For instance, if {opt alpha(1)} is specified, {cmd:nearstat} will divide the values of 
the variables listed in {varlist:3} by distance prior to calculating the statistics. Specifying {opt alpha(2)} entails dividing by distance 
squared.

{phang}
{cmd:dname(}{newvar:3}{cmd:)} provides the name for a dummy variable equal to one if a nearest neighbor specified with {opt kth()} 
is within the distance band specified with {opt dband()} and zero otherwise.

{phang}
{cmd:ncount(}{newvar:4}{cmd:)} specifies the name of a variable to hold, for each observation, the number of neighbors falling in the distance 
band specified with {opt dband()}.

{pmore}{bf:Note 6:} When {opt allnei} or {opt knn(#)} is specified, specifying {opt dband()} implies a request for a neighbor count variable or 
for a dummy variable. As a result, either {opt ncount()} or {opt dname()} must be specified.

{phang}
{cmd:incdist(}{newvar:5}{cmd:)} specifies the name of a variable for holding incremental distance to reach the threshold population specified 
with {opt atpop()} (see Partridge and Rickman, 2008). {opt incdist()} and {opt statvar()} may not be combined. 

{phang}
{opt atpop(#)} specifies a metropolitan area population threshold for which incremental distance needs to be calculated. {opt atpop()} and 
{opt incdist()} must be combined.

{phang}
{cmd:iidist(}{newvar:6}{cmd:)} specifies the name of a variable to hold one-to-one distance between input and near features when they 
are different but have the same number of non-missing observations. Essentially, this variable holds the diagonal elements of the distance 
matrix.

{phang}
{cmdab:minm:axd(}{newvar:7} {it:mmtype}{cmd:)} requests that a variable for holding the minimum or maximum distance from each observation to its neighbors 
be generated. {it:mmtype} should be equal to {it:min} or {it:max} to request the minimum or maximum distance respectively.
 
{phang}
{opt expdist(distname)} requests that distance between input and near features be exported as a matrix to the permanent file or temporary matrix 
{it:distname}.

{phang}
{opt expto(Stata|tab|csv|Mata)} indicates whether the distance matrix should be exported to a Stata matrix loaded in memory or to a file in a tab 
delimited, csv, or Mata format. Note that if {opt expto(Stata)} is specified, a Stata matrix loaded in memory will be created only if the matrix size 
does not exceed the {help matsize} limit of your Stata flavor.

{phang}
{opt sparse(tab|csv|Mata)} specifies that the distance matrix be written as a three-column matrix (row, column, value) to a tab delimited, 
a csv, or a Mata file. {opt expto()} and {opt sparse()} may not be combined, but you must specify one of them when {opt expdist()} is specified. 

{phang}
{opt nozero} specifies that the diagonal zeros be removed from the sparse distance matrix. By default, the diagonal zeros are not removed.

{phang}
{cmd:des(}{it:des_option,}[{it:des_suboption}]{cmd:)} requests that descriptive statistics for the distances between input and near features
and the distances to the nearest neighbors specified with {opt kth(#)} be displayed. {it:des_option} is required when {opt des()} is specified. 

{pmore}If {it:des_suboption} is not specified, then statistics include number of location pairs, minimum, mean, standard deviation, and maximum 
distance. Otherwise, lower quartile, median or second quartile, and upper quartile will be displayed as well. With or without the {opt des()} option 
specified, these statistics are returned as saved scalars.

{pmore}Descriptive statistics for the number of neighbors falling in ring {opt dband()} will also be displayed if {opt ncount()} is specified.

{phang}
{opt replace} overwrites existing variables {newvar:1}, {newvar:2}, {newvar:3}, {newvar:4}, {newvar:5}, {newvar:6}, {newvar:7} and any 
variables listed in {it:{help newvarlist}} and existing file {it:distname}.

{phang}
{opt favor(speed|space)} instructs {cmd:nearstat} to favor speed or space when performing all the calculations.
{opt favor(speed)} is the default. This option provides a trade-off between speed and memory use. See {help mata_set:[M-3] mata set}.

{marker results}{dlgtab:Saved scalars}
{phang}

  r(nearest_min) =  Minimum of the distance to the kth nearest neighbors
  r(nearest_max) =  Maximum of the distance to the kth nearest neighbors
 r(nearest_mean) =  Average of the distance to the kth nearest neighbors
       r(n_near) =  Number of near features
      r(n_input) =  Number of input features
     r(max_dist) =  maximum distance between input and near features
      r(Q3_dist) =  Upper quartile distance between input and near features 
      r(Q2_dist) =  Median or middle quartile distance between input and near features
    r(mean_dist) =  Average distance between input and near features
      r(Q1_dist) =  Lower quartile distance between input and near features
     r(min_dist) =  Minimum distance between input and near features
          r(Obs) =  Number of location pairs between which distance was calculated


{marker examples}{dlgtab:Examples}

{phang}
1) Calculate average test score and proportion of nonwhite for the first 3 nearest neighbors 
using Cartesian coordinates

{pmore}{cmd:. nearstat latitude longitude, near(latitude longitude) distvar(distname) ///}{p_end}
          {bf:cart contvar(testscore nonwhite) statvar(avtest pctnwhite) knn(3) ///}
	  {bf:statname(mean)}

{phang}
Note that in this case, {varlist:1} is the same as {varlist:2}

{synoptline}

{phang}
2) Determine the identification number, test score, and race of each observation's nearest neighbor

{pmore}{cmd:. nearstat latitude longitude, near(latitude longitude) distvar(distname) ///}{p_end}
          {bf:cart contvar(testscore nonwhite) statvar(near_score near_race) ///}
	  {cmd:nid(id nei_id) replace}

{phang}
Here option {opt replace} is specified to replace the variable {opt distname} already created.

{synoptline}

{phang}
3) Calculate distance from each county to the nearest metropolitan area using spherical coordinates

{p 6 8 2}a) First, load the county level data

{pmore}{cmd:. use mycountydata}

{p 6 8 2}b) Second, merge your metropolitan level data

{pmore}{cmd:. merge using mymetrodata}

{pmore}{cmd:. drop _merge}

{p 6 8 2}c) Now you are ready to run {cmd:nearstat}

{pmore}{cmd:. nearstat latvar1 longvar1, near(latvar2 longvar2) distvar(distmetro)}

{phang}
Here {hi:latvar1} and {hi:longvar1} hold latitudes and longitudes of the counties and {hi:latvar2} and {hi:longvar2} 
contain population weighted latitudes and longitudes of the metropolitan areas.

{synoptline}

{phang}
4) Calculate distance from each rural county to its nearest metropolitan area and record population of the nearest
metropolitan area using spherical coordinates
 
{pmore}{cmd:. nearstat latvar1 longvar1, near(latvar2 longvar2) distvar(distmetro) ///}{p_end}
	 {cmd: contvar(popmetro) statvar(popnear)}

{phang}
Here popmetro is the variable holding population in each metropolitan area and popnear is the name of a variable to hold  
population in the nearest metropolitan area.

{synoptline}

{phang}
5) Calculate incremental distance to reach a metropolitan area with a population of at least 500,000

{pmore}{cmd:. nearstat latvar1 longvar1, near(latvar2 longvar2) distvar(distmetro) ///}{p_end}
          {cmd:contvar(popmetro) incdist(incd5) atpop(500000)}  

{phang}
Here incd5 is the name of a variable for holding the calculated incremental distance

{synoptline}

{phang}
6) Create a variable (nearmetro) holding the population of a county if the county is part of a defined metropolitan
 area or the population of the nearest metropolitan area if the county is a non-metropolitan one.

{p 6 8 2}In addition to the variables in Example 4, you need a variable holding county population and 
a dummy variable equal to 1 if the county is part of a metropolitan area and zero otherwise.

{p 6 8 2}a) First, set the variable nearmetro equal to the county population variable:

{pmore}{cmd:. gen nearmetro=pop2000} // where pop2000 is a variable holding county population in 2000

{p 6 8 2}b) Second, calculate population in the nearest metropolitan area as in Example 4

{p 6 8 2}c)Third, replace nearmetro values with popnear values if the county is non-metro.

{pmore}{cmd:. replace nearmetro=popnear if metro==0} // where popnear is a variable holding population in the nearest metropolitan area

{synoptline}

{phang}
7) Calculate average income for 200 nearest neighbors of each county using spherical coordinates

{pmore}{cmd:. nearstat lat long, near(lat long) distvar(distname) contvar(income) ///}{p_end}
          {cmd:statvar(avincome) statname(mean) knn(200) replace}

{synoptline}

{phang}
8) Obtain a dummy variable (dum1_150) equal to 1 if the first nearest neighbor is within 150 kilometers and zero otherwise

{pmore}{cmd:. nearstat lat long, near(lat long) distvar(distname) dname(dum1_150) ///}{p_end}
	  {cmd:dband(0 150) replace}

{synoptline}

{phang}
9) Obtain a dummy variable (dum3_150m) equal to one if the third nearest neighbor is within 150 miles and zero otherwise

{pmore}{cmd:. nearstat lat long, near(lat long) distvar(distvar3) kth(3) r(3958.761) ///}{p_end}
	  {cmd:dname(dum3_150m) dband(0 150)}

{synoptline}

{phang}
10) Request a variable (nbnei) that holds (for each observation) the number of neighbors located within a two-mile radius
 
{pmore}{cmd:. nearstat lat long, near(lat long) distvar(mydist) ncount(nbnei) dband(0 2) ///}{p_end}
	 {cmd: r(3958.761)} 

{synoptline}

{phang}
11) Display descriptive statistics for distance (in miles) between input and near features, assuming spherical coordinates

{pmore}{cmd:. nearstat lat long, near(lat long) distvar(mydist) des(stat) r(3958.761)} 

{phang}
This line of code will generate a table containing two rows. The second row reports, for example, the maximum distance from the
first nearest neighbor, which is the minimum distance (or distance cut-off) to obtain at least one neighbor for each observation.

{synoptline}

{phang}
12) Display descriptive statistics for the distances between input and near features and for the number of neighbors falling in the distance band: 0<dij<=9

{pmore}{cmd:. nearstat latitude longitude, near(latitude longitude) distvar(distname) ///}{p_end}
	  {cmd:des(stat) db(0 9) ncount(neicount) replace} 

{synoptline}

{phang}
13) Calculate for each county the proportion of surrounding counties with high poverty rate (poverty rate >=20%) in 2000

{p 6 8 2}a) Create a dummy variable (pov20_00) equal to one if a county has a poverty rate >=20% and zero otherwise

{pmore}{cmd:. gen pov20_00=(povrt00>=20)}

{p 6 8 2}b) Calculate the proportion variable (neipov00) for which eight neighbors are considered.

{pmore}{cmd:. nearstat latitude longitude, near(latitude longitude) distvar(nearestnei) ///}{p_end}
	  {cmd:contvar(pov20_00) statvar(neipov00) statname(mean) knn(8)} 

{synoptline}

{phang}
14) Calculate distance from each observation to District of Columbia (DC) to analyze housing values for example

{p 6 8 2}a) First, create a one-observation dataset with the latitude and longitude of DC:

{pmore}{cmd:. set obs 1}

{pmore}{cmd:. gen lat_dc=38.8964}

{pmore}{cmd:. gen lon_dc=-77.0262}

{pmore}{cmd:. save dc_coord}

{p 6 8 2}b) Second, load your housing value dataset:

{pmore}{cmd:. use mydataset, clear}

{p 6 8 2}c) Third, merge your data with the DC coordinates:

{pmore}{cmd:. merge using dc_coord}

{p 6 8 2}d) Finally, calculate distance from each observation to DC:

{pmore}{cmd:. nearstat lat long, near(lat_dc lon_dc) distvar(distodc)}  // where lat and long are variables holding the housing coordinates

{synoptline}

{phang}
15) Generate a variable (called dmax) for holding the maximum distance for each observation

{pmore}{cmd:. nearstat latitude longitude, near(latitude longitude) distvar(nearestnei) minmaxd(dmax max)} 

{synoptline}


{marker refs}{title:References}

{bf:de Smith, M.J., M.F. Goodchild, and P.A. Longley}, 2007. {it:Geospatial Analysis: A comprehensive Guide to Principles, Techniques, and Software Tools}. Matador: Leicester, UK
{browse "http://www.spatialanalysisonline.com":http://www.spatialanalysisonline.com}

{bf:Gould, W.} 2007. "Mata Matters: Subscripting". {it:The Stata Journal} 7: 106-116.

{bf:Gould, W.} 2006. "Mata Matters: Creating New Variables—Sounds Boring, Isn't". {it:The Stata Journal} 6: 112-123. 
Available at {browse "http://www.stata-journal.com/article.html?article=pr0021":http://www.stata-journal.com/article.html?article=pr0021}

{bf:Jeanty, P.W., M. Partridge, and E. Irwin}. 2010. Estimation of a Spatial Simultaneous Equation Model of Population Migration and Housing Price Dynamics.
{it:Journal of Regional Science and Urban Economics} 40(5): 343-352.

{bf:Partridge, M. and R.S. Dan}. 2008. Distance from Urban Agglomeration Economies and Rural Poverty. 
{it:Journal of Regional Science} 48(2):285-310.

{bf:U.S. Census Bureau Geographic Information Systems FAQ.} {it:What is the best way to calculate the distance between 2 points}
{browse "http://www.movable-type.co.uk/scripts/gis-faq-5.1.html":http://www.movable-type.co.uk/scripts/gis-faq-5.1.html.}

{bf:U.S. Census Bureau}. 2012. {it:Cartographic Boundary Files.} {browse "http://www.census.gov/geo/www/cob/bdy_files.html":http://www.census.gov/geo/www/cob/bdy_files.html}
   
{bf:U.S. Census Bureau}. 2011. {it:Using the TIGER/Line Shapefiles and Census Data.} {browse "http://www.census.gov/geo/www/tiger/wwtl/wwtl.html":http://www.census.gov/geo/www/tiger/wwtl/wwtl.html}

{bf:U.S. Census Bureau}. 2011. {it:TIGER Products.} {browse "http://www.census.gov/geo/www/tiger/index.html#tl":http://www.census.gov/geo/www/tiger/index.html#tl}

{bf:U.S. Census Bureau}. 2010. {it:Census 2000 Gazetteer Files.} {browse "http://www.census.gov/geo/www/gazetteer/places2k.html":http://www.census.gov/geo/www/gazetteer/places2k.html}

{bf:Wikipedia}. 2012. {it:Great-Circle Distance}. {browse "http://en.wikipedia.org/wiki/Great-circle_distance":http://en.wikipedia.org/wiki/Great-circle_distance}

{bf:---------}. 2012. {it:Earth Radius}. {browse "http://en.wikipedia.org/wiki/Earth_radius#Mean_radii":http://en.wikipedia.org/wiki/Earth_radius#Mean_radii.}


{marker citat}{title:Citation}

Thanks for citing {cmd:nearestat} as follows:

{bf:Jeanty, P.W.}, 2010. nearstat: Stata module to calculate distances, generate distance-based variables, and export distance matrix to text files. 
Available from http://ideas.repec.org/c/boc/bocode/s457110.html.


{marker author}{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, The Kinder Institute for Urban Research/Hobby Center for the Study of Texas, Rice University, Houston, Texas
			
			
{p 4 4 2}Email to {browse "mailto:pwjeanty@rice.edu":pwjeanty@rice.edu} 
			

{p 4 4 2}{bf:N.B.:} Previous versions of {bf:nearstat} were written when the author was a Research Economist with the Dept. of Agricultural, Environmental, and Development Economics,{break} 
    	   The Ohio State University{break}
	   

{title:Also see}

{p 4 13 2}Online: {helpb vincenty}, {helpb nearest}, {helpb distmatch} (if installed) 


