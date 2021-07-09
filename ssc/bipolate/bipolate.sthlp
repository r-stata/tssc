{smcl}
{* 12aug2014}{...}
{cmd:help bipolate}{right:Version 1.3}
{hline}

{title:Title}

{p 4 11 2}
{hi:bipolate} {hline 2} To provide bivariate interpolation and smooth surface fitting for 
values given at irregularly distributed points.{p_end}


{marker syntax}{title:Syntax}

{p 8 27 2}
{cmdab:bipolate}
{it:zvar yvar xvar}
[{it:if}]
[{it:in}]
[{it:using}]
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt saving}(filename[, replace ])} saves the resulting data set to a specified file name.{p_end}
{synopt:{opt {ul on}meth{ul off}od}(string)} specifies the interpolation method to be used.{p_end}
{synopt:{opt {ul on}xg{ul off}rid}(numlist)} specifies the x-axis values at which to interpolate points.{p_end}
{synopt:{opt {ul on}xl{ul off}evels}(numlist)} specifies the the number of x-axis levels at which to interpolate points.{p_end}
{synopt:{opt {ul on}yg{ul off}rid}(numlist)} specifies the y-axis values at which to interpolate points.{p_end}
{synopt:{opt {ul on}yl{ul off}evels}(numlist)} specifies the number of y-axis levels at which to interpolate points.{p_end}
{synopt:{opt {ul on}convex{ul off}hull}} only interpolate points that reside within a convex hull around the data.{p_end}
{synopt:{opt {ul on}fill{ul off}using}(string)} specifies a data set containing a list of points to fill in.{p_end}
{synopt:{opt {ul on}near{ul off}}(numlist)} specifies the number of nearest neighbor points to use in calculating partial derivatives.{p_end}
{synopt:{opt {ul on}smooth{ul off}}(real)} specifies the amount of smoothing for thin plate spline interpolation.{p_end}
{synopt:{opt {ul on}contour{ul off}method}(string)} specifies the interpolation method to use with method(contour).{p_end}
{synopt:{opt {ul on}coll{ul off}apse}(string)} specifies the statistic to use if there are multiple z values for a given (x,y) pair.{p_end}
{synopt:{opt {ul on}reps{ul off}}(integer)} repeats the interpolation with randomly-generated z values to account for variability in z.{p_end}
{synopt:{opt {ul on}seed{ul off}}(integer)} specifies the random-number seed to use when doing repeated interpolations.{p_end}
{synopt:{opt {ul on}keepmiss{ul off}ing}} keeps (x,y) pairs that have missing z values.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
This command has two possible modes:{break}
1. If the user desires the interpolated data to be output at all possible combinations of the xgrid and ygrid values or based on values implied
by xlevels and ylevels.  This is useful for generating an interpolating surface. This mode is meant to be used in conjunction with a 3-D graphing 
command such as surface ({ado ssc install surface:SSC}) or {help twoway contour}. If the xgrid/ygrid or xlevels/ylevels options are not
specified, all possible combinations of the x and y values are used.{break}
2. The user can specify a list of points to fill in.  This is useful if the x-y plane is an irregular shape and the user wishes to avoid
extrapolating outside of the range of the data.  In this case, the user specifies "fillusing(filename)", where "filename" is a data set 
containing a list of points, or "convexhull", in which case a convex hull is constructed and all points inside the convex hull are used.{break}{break}
In both cases, the command does not modify existing data; only missing data points are interpolated.

{pstd}
Several interpolation methods are available for both of the above modes. The default method was first implemented by Akima, and is described below. 
Other available methods include thin plate spline, described by Green and Silverman in 1994, and Shepard's method, described in the Stata manual and 
in various locations online.  As a convenience, the thin plate spline and Shepard methods included in Stata's {help twoway contour} are
also available.

{pstd}
The default interpolation method was adapted from from a Fortran program called BIVAR. The original version of BIVAR was written by Hiroshi Akima
in August 1975 and rewritten by him in late 1976.  It was incorporated into NCAR's public software libraries in January 1977.  
In August 1984 a new version of BIVAR, incorporating changes described in the Rocky Mountain Journal of Mathematics article cited below was
obtained from Dr Akima by Michael Pernice of NCAR's Scientific Computing Division, who evaluated it and made it available in February, 1985.

{pstd}
The author(s) of the original program provide the following description of the algorithm used:

{pstd}
Method:
{break}
1. The XY plane is divided into triangular cells, each cell having projections of three data points in the plane as its vertices, 
and
 a bivariate quintic polynomial in X and Y is fitted to each 
triangular cell.
 The coefficients in the fitted quintic polynomials are determined
by continuity requirements and by estimates of partial derivatives at the vertices and along the edges of the triangles.  The method 
described in the Rocky Mountain Journal reference guarantees that 
the generated surface depends continuously on the triangulation.
{break}
2. The resulting interpolating function is invariant under the following types of linear coordinate transformations:
{break}
{tab}a) a rotation of the XY coordinate system{break}
{tab}b) linear scale transformation of the Z axis{break}
{tab}c) tilting of the XY plane, i.e. new coordinates (u,v,w) given by          {break}
{tab}{tab}u = x
{break}
{tab}{tab}v = y{break}
{tab}{tab}w = z + a*x + b*y{break}
{tab}{tab}where a, b are arbitrary constants.

{pstd}
Notes: {break}
1. The resulting interpolating function and its first-order partial derivatives are continuous.{break}
2. The method employed is local, i.e. a change in the data in one area of the plane does not affect the interpolating function except in
 that local area.  
This is advantageous over global interpolation methods.{break}
3.
 The method gives exact results when all points lie in a plane. This is advantageous over other methods such as two-dimensional Fourier series interpolation. 
 
{pstd}
References:{break}
1. Hiroshi Akima. A Method of Bivariate Interpolation and Smooth Surface Fitting for Values Given at Irregularly Distributed Points.
ACM Transactions on Mathematical Software. Volume 4, Number 2, June 1978.{break}
2. Hiroshi Akima. On Estimating Partial Derivatives for Bivariate Interpolation of Scattered Data. Rocky Mountain Journal of Mathematics.
Volume 14, Number 1, Winter 1984.{break}
3. P.J. Green and B.W. Silverman. Nonparametric Regression and Generalized Linear Models: A roughness penalty approach. Chapman & Hall, London, 1994.{break}
4. Stata Graphics Reference Manual, Release 12. StataCorp, College Station, TX, page 200.{break}
5. Donald Shepard. A two-dimentional interpolation function for irregularly-spaced data. Proceedings of the 1968 ACM National Conference, pp 517-524.{break}

{title:Options}

{phang}
{cmdab:saving}{cmd:(}{it:filename} {it:[, replace ]}{cmd:)} will save the resulting data set in filename.dta. If the file already exists then use the {it:replace} suboption. 
This data set will contain the x and y variables from the original data set and the collapsed z variable.  There will be observations in the data set
for all interpolated or filled in points.  The name of the z variable will be the name from the original data set with the name of the statistics
from the {cmd:collapse} option concatenated.

{phang}
{cmdab:method}{cmd:(}{it:akima}{cmd:)} uses Akima's bivariate quintic polynomial method for interpolation. The default.

{phang}
{cmdab:method}{cmd:(}{it:{ul on}thin{ul off}platespline}{cmd:)} uses thin plate spline method for interpolation. This method may produced better
results than the default method, but is slower than the default method, although the difference will probably not be noticeable unless you have a 
large data set or are using the {cmd:rep()} options.

{phang}
{cmdab:method}{cmd:(}{it:contour}{cmd:)} interpolates using the methods available in the Stata {help twoway contour} command. This option
automatically uses the levels of x and y to determine where to interpolate. Accordingly, the {cmd:xgrid()}, {cmd:ygrid()}, {cmd:xlevels()}, 
and {cmd:ylevels()} options cannot be used with {cmd: method(contour)}. See the {cmd: contourmethod()} option below to specify the interpolation method to be used.

{phang}
{cmdab:xgrid}{cmd:(}{it:numlist}{cmd:)} specifies the x-axis values at which to interpolate points. Any valid Stata numlist pattern can be used, 
e.g. (1 2 3 4 5), (1(1)10), etc. This option is cannot be used with {cmd:fillusing()}.

{phang}
{cmdab:xlevels}{cmd:(}{it:numlist}{cmd:)} specifies the number of x-axis levels at which to interpolate points. Must be a single integer that is greater than 1. The x-axis 
range will be divided evenly into that many levels. This option cannot be used with {cmd:fillusing()}.

{phang}
{cmdab:ygrid}{cmd:(}{it:numlist}{cmd:)} specifies the y-axis values at which to interpolate points. Any valid Stata numlist pattern can be used,
e.g. (1 2 3 4 5), (1(1)10), etc. This option cannot be used with {cmd:fillusing()}.

{phang}
{cmdab:ylevels}{cmd:(}{it:numlist}{cmd:)} specifies the number of y-axis levels at which to interpolate points. Must be a single integer that is greater than 1. The y-axis 
range will be divided evenly into that many levels. This option cannot be used with {cmd:fillusing()}.

{phang}
{it: Note:}{cmd:xgrid()} and {cmd:xlevels()} are mutually exclusive, as are {cmd:ygrid()} and {cmd:ylevels()}.

{phang}
{cmdab:convexhull} can be used in conjunction with the above options to interpolate only those points that reside within a convext hull around the data.

{phang}
{cmdab:fillusing}{cmd:(}{it:filename}{cmd:)} specifies the name of a dataset that contains a list of points to be filled in. The data set must contain at least two variables:
an x-coordinate and a y-coordinate, which have the same name as the x-coordinate and y-coordinate in the data set in memory (or the {cmd:using} data set). 
This option cannot be used with {cmd:xgrid()}, {cmd:xgrid()}, {cmd:ygrid()}, {cmd:xlevels()}, {cmd:ylevels()}, or {cmd:convexhull}.

{phang}
{cmdab:near}{cmd:(}{it:numlist}{cmd:)} specifies the number of nearest neighbor points to use for calculating partial derivatives.  Specifying this option invokes
the interpolation method originally proposed by Akima in 1978.  The revised method from 1984 uses the three nearest neighbor points and weights
each derivative such that large or "skinny" triangles are given less weight. Must be an integer that is at least 2 and less than 25 or the 
number of data points, whichever is less.  This option is ignored if {cmd:method(thinplatespline)}, {cmd:method(shepard)}, or {cmd:method(contour)} is specified.

{phang}
{cmdab:smooth}{cmd:(}{it:real}{cmd:)} specifies the smoothing parameter to use with {cmd:method(thinplatespline)}.  The parameter must be a real number
that is greater than or equal to zero. The default is zero (no smoothing).  This option is ignored if {cmd:method(thinplatespline)} is not specified.

{phang}
{cmdab:contourmethod}{cmd:(}{it:string}{cmd:)} specifies the interpolation method to be used when the {cmd:method(contour)} option is specified. Values 
are {ul on}thin{ul off}platespline (the default) or shepard.  See the {help twoway contour} help for more details.  

{phang}
{cmdab:collapse}{cmd:(}{it:string}{cmd:)} specifies what method is to be used to collapse multiple z values for a given (x,y) pair into one value. Any statistic available in 
the Stata {help collapse} command can be used.  The default is "mean". Cannot be used with {cmd:reps()}.

{phang}
{cmdab:reps}{cmd:(}{it:integer}{cmd:)} specifies the number of times to repeat the interpolation. If this number is more than one, a different set of z values 
is generated for each repetition.  For each (x,y) pair with more than one z value, the z value is set to a random number chosen from a normal 
distribution with mean and standard deviation equal to the mean and standard deviation of all z values for that (x,y) pair. If the standard deviation
for a given (x,y) pair is zero (i.e, all values are the same for a given (x,y) pair) or missing (i.e., there is only one z value for a given (x,y) pair), 
the mean is used and no random numbers are generated for that (x,y) pair.  The interpolation results from each repetition are accumulated in a 
temporary data set and at the completion of all repetitions the results are summarized using the mean and 
standard deviation of all repetitions. The default is one (no repetitions). Cannot be used with {cmd:collapse()}.

{phang}
{cmdab:seed}{cmd:(}{it:integer}{cmd:)} specifies a random number seed for use with {cmd:reps()}. If {cmd:seed()} is not specified or is negative, 
the Stata default is used. If {cmd:seed()} is specified without the {cmd:reps()} option, the seed is ignored.

{phang}
{cmdab:keepmissing} keeps observations for which a non-missing (x,y) pair has a missing z value.  This is useful for ensuring that the x and y values are
represented in the interpolated data set.  Accordingly, this option will have no effect when {cmd:fillusing()} or {cmd:xgrid()}/{cmd:ygrid()} and {cmd:xlevels()}/{cmd:ylevels()}
are used, since these options determine what (x,y) pairs will be included in the interpolated data set.  The default is to drop observations which
contain missing z values. Note that observations with missing x or y values will always be removed from the data set before interpolation.


{title:Examples}

{phang}
{inp:bipolate z y x, collapse(median) xgrid(1(0.1)5) ygrid(1(0.1)5) saving(myfile,replace)}

{phang}
{inp:bipolate z y x, collapse(median) xlevels(10) ylevels(5) saving(myfile,replace)}

{phang}
{inp:bipolate z y x, method(thinplatespline)}

{phang}
{inp:bipolate z y x, method(thinplatespline) smooth(3)}

{phang}
{inp:bipolate z y x, method(akima) near(4)}

{phang}
{inp:bipolate z y x, fillusing(fillpoints.dta)}

{phang}
{inp:bipolate z y x, reps(50)}

{phang}
{inp:bipolate z y x, reps(50) seed(1357924680)}

{phang}
{inp:bipolate z y x, xgrid(1(0.1)5) ygrid(1(0.1)5) convexhull}

{phang}
{inp:bipolate z y x, method(contour) contour(shepard)}

{title:Example using actual data}

{pstd}
{inp:. sysuse sandstone}
{break}
{inp:. drop if type==3 // Drop previously interpolated values}
{break}
{inp:. bipolate east north depth, method(interp) collapse(median) xlevels(80) ylevels(80) saving(sand_bip,replace)}
{break}
{inp:. use sand_bip, clear}
{break}
{inp:. surface east north depth}

{pstd}
{inp:. bipolate east north depth, method(contour) keepmissing collapse(min)  saving(sand_contour,replace)}
{break}
{inp:. use sand_contour, clear}
{break}
{inp:. twoway contour east north depth, interp(none)} //Note: The data set resulting from this command should be the same as the entire sandstone data set (i.e., including all interpolated
points).


{title:Acknowledgments} 

{pstd}
Thank you to Nicholas J. Cox for helpful comments and suggestions and to Hua Peng at StataCorp for assistance with the twoway contour interpolation
method. The convex hull procedure is adapted from the {cmd:cvxhull} command ({ado ssc install cvxhull:SSC})
written by R. Allan Reese.

{title:Author}

{pstd}
Joseph Canner{break}
Center for Surgical Trials and Outcomes Research{break}
Department of Surgery{break}
Johns Hopkins University School of Medicine{break}

{pstd}
Email: jcanner1@jhmi.edu




 

