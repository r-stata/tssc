{smcl}
{* NJC 16jul2015/26jul2015/2sep2015} 
{viewerjumpto "Syntax" "mipolate##syntax"}{...}
{viewerjumpto "Description" "mipolate##description"}{...}
{viewerjumpto "Remarks" "mipolate##remarks"}{...}
{viewerjumpto "Options" "mipolate##options"}{...}
{viewerjumpto "Examples" "mipolate##examples"}{...}
{title:Title}

{p2colset 5 18 18 2}{...}
{p2col :mipolate{space 2}{hline 2}}  Interpolate (extrapolate) values{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:mipolate}
{it:yvar}
{it:xvar}
{ifin}
{cmd:,}
{opth gen:erate(newvar)} 
[
{opt l:inear}
{opt c:ubic}
{opt s:pline}
{opt p:chip} 
{opt i:dw}[{cmd:(}{it:power}{cmd:)}] 
{opt f:orward}
{opt b:ackward}
{opt n:earest} 
{opt g:roupwise} 
{opt ties(ties_rule)} 
{opt e:polate}
]

{phang}
{opt by} is allowed; see {manhelp by D}.


{marker description}{...}
{title:Description}

{pstd}
{opt mipolate} creates in {newvar} an interpolation of {it:yvar} on
{it:xvar} for missing values of {it:yvar}.

{pstd}
{opt mipolate} uses one of the following methods: linear, cubic, cubic
spline, pchip (piecewise cubic Hermite interpolation), idw (inverse 
distance weighted), forward, backward, 
nearest neighbour, groupwise. The default method is linear.  

{pstd}
Interpolation requires that {it:yvar} be a function of {it:xvar}, so
{it:yvar} is also interpolated for tied values of {it:xvar}.  When
{it:yvar} is not missing and {it:xvar} is neither missing nor repeated,
the value of {it:newvar} is just {it:yvar}.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:mipolate} does not require {help tsset} or {help xtset} data and makes no
check for, or use of, any such settings. With panel data, it will be essential
to specify a panel identifier to {cmd:by:}. 

{pstd}
{cmd:mipolate} pays no special attention to extended missing values {cmd:.a}
to {cmd:.z}. 


{marker options}{...}
{title:Options}

{phang}{opth generate(newvar)} is required and specifies the name of the
new variable to be created.

{phang}{opt linear} specifies linear interpolation using the known
values of {it:yvar} before and after any missing values. This is the 
default method. 

{phang}{opt cubic} specifies cubic interpolation, using exact fitting of
a cubic curve to two data points before and two data points after each
observation for which {it:yvar} is missing. Missing values are thus
produced whenever fewer than two data points are present on either side.
Note that this is not a spline method.  

{phang}{opt spline} specifies natural cubic spline interpolation.  The
method uses Mata functions {cmd:spline3()} and {cmd:spline3eval()}. If
desired see help and in turn Mata source code {help mf_spline3:here}.
That code is a translation of code originally given by Herriot and
Reinsch (1973). 

{phang}{opt pchip} specifies piecewise cubic Hermite interpolation.  For
a lucid account, see Moler (2004, Ch.3). This method uses piecewise
cubics that join smoothly, so that both the interpolated function and
its first derivative are continuous. In addition, the interpolant is
shape-preserving in the sense that it cannot overshoot locally; sections
in which observed {it:yvar} is increasing, decreasing or constant with
{it:xvar} remain so after interpolation, and local extremes (maxima,
maxima) also remain so.  This interpolation method also extrapolates.

{phang}{opt idw}[{cmd:(}{it:power}{cmd:)}] specifies inverse distance
weighted interpolation.  This method uses a weighted average of
non-missing values, the weights being reciprocals of the powered
distance between values, the power being zero or positive. The default
power is 2; any other choice must be specified. Thus with power 2,
values at distance 1 from a point with unknown values have weight 1,
values at distance 2 from a point have weight 1/4, distance 3 weight
1/9, and so forth.  If the power is 0, all known points have equal
weight and the interpolant reduces to the average of all values. As the
power becomes large, only those values that are nearest have appreciable
weight.  This interpolation method also extrapolates.

{phang}{opt forward} specifies forward interpolation, so that any known 
value just before one or more missing values is copied in cascade to 
provide interpolated values, constant within any such block. 

{phang}{opt backward} specifies backward interpolation, so that any known 
value just after one or more missing values is copied in cascade to 
provide interpolated values, constant within any such block. 

{phang}{opt nearest} specifies nearest neighbour interpolation, which
means using known values of {it:yvar} either before or after missing 
values, depending on which is nearer in terms of {it:xvar}.
When values before and after are equally distant from a known value,
there is a choice of rules that may be applied. The default rule uses
the mean of the two values.  The {opt ties()} option provides
alternative rules.  This method also extrapolates, as unknown values
before the first known value and unknown values after the last known
value are replaced by those respective known values. 

{phang}{opt groupwise} specifies that non-missing values be copied to
missing values if, and only if, just one distinct non-missing value
occurs in each group. Thus a group of values ., 42, ., . qualifies as 42
is not missing and is the only non-missing value in the group. Hence the
missing values in the group will be replaced with 42 in the new
variable.  By the same rules 42, ., 42, . qualifies but 42, ., 43, .
does not.  Normally, but not necessarily, this option is used in
conjunction with {cmd:by:}, which is how groups are specified; otherwise
the (single) group is the entire set of observations being used. 

{pmore}Note that {it:xvar} is strictly irrelevant for this method, as
order of values is immaterial. To keep syntax consistent, it should be
specified any way. 

{phang}{opt ties()} specifies an alternative to the default rule for the
{opt nearest} option, whereby previous and next values equally distant
from a given point are averaged. You may choose one of {cmdab:a:fter}
(value after is used), {cmdab:b:efore} (value before is used),
{cmdab:mi:nimum} (smaller value is used), or {cmdab:ma:ximum} (larger
value is used). As indicated, any unambiguous abbreviation is allowed. 

{phang}{opt epolate} specifies that values be both interpolated and
linearly extrapolated.  Interpolation only is the default with 
{opt linear}, {opt cubic} and {opt spline}. This option is ignored 
with {opt pchip}, {opt forward}, {opt backward}, {opt nearest} and 
{opt groupwise}, which apply their own kinds of extrapolation. 


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl1}

{pstd}List the data{p_end}
{phang2}{cmd:. list, sep(0)}

{pstd}Create {cmd:ly1}, {cmd:cy1}, {cmd:sy1}, {cmd:py1}, {cmd:ny1}
containing interpolations of {cmd:y} on {cmd:x} for missing values of
{cmd:y}{p_end}

{phang2}{cmd:. mipolate y x, gen(ly1)}{p_end}
{phang2}{cmd:. mipolate y x, cubic gen(cy1)}{p_end}
{phang2}{cmd:. mipolate y x, spline gen(sy1)}{p_end}
{phang2}{cmd:. mipolate y x, pchip gen(py1)}{p_end}
{phang2}{cmd:. mipolate y x, nearest gen(ny1)}

{pstd}Use alternative rules for handling ties:{p_end}
{phang2}{cmd:. foreach r in after before max min {c -(}}{p_end}
{phang2}{cmd:.     mipolate y x, nearest ties(`r') gen(ny`r')}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}List the results{p_end}
{phang2}{cmd:. list, sep(0)}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. webuse ipolxmpl2}{p_end}

{pstd}Show years for which the circulation data are missing{p_end}
{phang2}{cmd:. tabulate circ year if circ == ., missing}

{pstd}Create {cmd:pchipcirc} containing a pchip interpolation of {cmd:circ} on
{cmd:year} for missing values of {cmd:circ} and perform this calculation
separately for each {cmd:magazine}{p_end}
{phang2}{cmd:. by magazine: mipolate circ year, pchip gen(pchipcirc)}{p_end}

    {hline}
{pstd}Moler's example{p_end}
{phang2}{cmd:. clear }{p_end}
{phang2}{cmd:. set obs 6 }{p_end}
{phang2}{cmd:. matrix y = (16, 18, 21, 17, 15, 12)' }{p_end}
{phang2}{cmd:. gen y = y[_n, 1] }{p_end}
{phang2}{cmd:. gen x = _n }{p_end}
{phang2}{cmd:. set obs 61}{p_end}
{phang2}{cmd:. replace x = (_n + 1)/10 in 7/L}{p_end}
{phang2}{cmd:. mipolate y x, pchip gen(pchip)}{p_end}
{phang2}{cmd:. line pchip x, sort || scatter y x }{p_end}

    {hline}
{pstd}Sandbox for {cmd:groupwise}:{p_end} 
{phang2}{cmd:. clear }{p_end}
{phang2}{cmd:. set obs 10 }{p_end}
{phang2}{cmd:. gen x = _n }{p_end}
{phang2}{cmd:. gen group = 1 in 1 }{p_end}
{phang2}{cmd:. replace group = 2 in 2/3}{p_end}
{phang2}{cmd:. replace group = 3 in 4/6}{p_end}
{phang2}{cmd:. replace group = 4 in 7/10 }{p_end}
{phang2}{cmd:. gen y = . }{p_end}
{phang2}{cmd:. replace y = 2 in 2 }{p_end}
{phang2}{cmd:. replace y = 5 in 5 }{p_end}
{phang2}{cmd:. replace y = 10 in 10 }{p_end}
{phang2}{cmd:. bysort group: mipolate y x, gen(y1) groupwise }{p_end}
{phang2}{cmd:. list, sepby(group) }{p_end}
{phang2}{cmd:. replace y = 9 in 9 }{p_end}
{phang2}{cmd:. * should fail: }{p_end}
{phang2}{cmd:. bysort group: mipolate y x, gen(y2) groupwise }{p_end}

    {hline}


{title:Author}

{pstd}Nicholas J. Cox, Durham University, U.K.{break}  
    n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{pstd}Most of the Mata code for the {opt pchip} option is a translation 
of MATLAB code given by Moler (2004).


{title:References}

{phang}
Hamming, R.W. 1973. {it:Numerical methods for scientists and engineers.}
New York: McGraw-Hill. 

{phang}
Herriot, J.G. and C.H. Reinsch. 1973.    
Algorithm 472: procedures for natural spline interpolation.  
{it:Communications of the Association for Computing Machinery}
16: 763{c -}768.   

{phang}
Lancaster, P. and K. Salkauskas. 1986. 
{it:Curve and surface fitting: an introduction.} 
London: Academic Press. 
[capital S of Salkauskas should bear caron or wedge diacritic]

{phang}
Moler, C. 2004. {it:Numerical Computing with MATLAB.} 
Philadelphia: SIAM. Chapter 3. 
(also available in slightly different form at 
{browse "http://www.mathworks.com/moler/interp.pdf":http://www.mathworks.com/moler/interp.pdf})  

{phang}
Morton, B.R. 1964. {it:Numerical approximation}. 
London: Routledge and Kegan Paul. 

{phang}
Press, W.H., S.A. Teukolsky, W.T. Vetterling, B.P. Flannery. 2007. 
{it:Numerical recipes: the art of scientific computing.} 
Cambridge: Cambridge University Press. 

{vieweralsosee "[D] ipolate" "mansection D ipolate"}{...}
{vieweralsosee "[MI] mi impute" "help mi_impute"}{...}

