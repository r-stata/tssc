{smcl}
{* *! version 1.0  31 March 2018}{...}
{cmd:help moransi}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:moransi} {hline 2}}Moran's I statistic{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:moransi} {varname} {ifin}{cmd:,}
{opth lat(varname)}
{opth lon(varname)}
{opt swm(swmtype)}
{opt dist(#)}
{opt dunit}{cmd:(km}|{cmd:mi)}
[{it:options}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opth lat(varname)}}specify the variable of latitude{p_end}
{p2coldent:* {opth lon(varname)}}specify the variable of longitude{p_end}
{p2coldent:* {opt swm(swmtype)}}specify a type of spatial weight matrix{p_end}
{p2coldent:* {opt dist(#)}}specify the threshold distance for the spatial weight matrix{p_end}
{p2coldent:* {opt dunit}{cmd:(km}|{cmd:mi)}}specify the unit of distance (kilometers or miles){p_end}
{synopt:{opt dms}}convert the degrees, minutes, and seconds format to a decimal format{p_end}
{synopt:{opt app:rox}}use bilateral distance approximated by the simplified version of the Vincenty formula{p_end}
{synopt:{opt d:etail}}display summary statistics of the bilateral distance{p_end}
{synopt:{opt nomat:save}}does not save the bilateral distance matrix on the memory{p_end}
{synoptline}
{p2colreset}{...}
{pstd}* {cmd:lat()}, {cmd:lon()}, {cmd:swm()}, {cmd:dist()}, and {cmd:dunit()}
are required.

{marker description}{...}
{title:Description}

{pstd}
{cmd:moransi} calculates Moran's {it:I} statistic. 
{p_end}

{marker options}{...}
{title:Options}

{phang}
{opth lat(varname)} specifies the variable of latitude in the dataset.  The
decimal format is expected in the default setting.  A positive value denotes
the north latitude, whereas a negative value denotes the south latitude.
{cmd:lat()} is required.

{phang}
{opth lon(varname)} specifies the variable of longitude in the dataset.  The
decimal format is expected in the default setting.  A positive value denotes
the east longitude, whereas a negative value denotes the west longitude.
{cmd:lon()} is required.

{phang}
{opt swm(swmtype)} specifies a type of spatial weight matrix.  One of the
following three types of spatial weight matrix must be specified: {opt bin}
(binary), {opt exp} (exponential), or {opt pow} (power).  The distance decay
parameter {it:#} must be specified for the exponential and power function
types of spatial weight matrix as follows: {cmd:swm(exp} {it:#}{cmd:)} and
{cmd:swm(pow} {it:#}{cmd:)}.  {cmd:swm()} is required.

{phang}
{opt dist(#)} specifies the threshold distance {it:#} for the spatial weight
matrix.  The unit of distance is specified by the {opt dunit()} option.
Regions located within the threshold distance {it:#} take a value of 1 in the
binary spatial weight matrix or a positive value in the nonbinary spatial
weight matrix, and take 0 otherwise.  {cmd:dist()} is required.

{phang}
{opt dunit}{cmd:(km}|{cmd:mi)} specifies the unit of distance.  Either {cmd:km}
(kilometers) or {cmd:mi} (miles) must be specified.  {cmd:dunit()} is required.

{phang}
{opt dms} converts the degrees, minutes, and seconds format to a decimal
format.

{phang}
{opt app:rox} uses the bilateral distance approximated by the simplified
version of the Vincenty formula.

{phang}
{opt d:etail} displays summary statistics of the bilateral distance.

{phang}
{opt nomat:save} does not save the bilateral distance matrix {bf:r(D)} on the memory.


{marker examples}{...}
{title:Examples}

{pstd}
Case 1: Binary spatial weight matrix{p_end}
{phang2}{cmd:. moransi MFIL59, lat(y_cntrd) lon(x_cntrd) swm(bin) dist(50) dunit(km) approx detail}{p_end}

{pstd}
Case 2: Nonbinary spatial weight matrix by exponential function{p_end}
{phang2}{cmd:. moransi MFIL59, lat(y_cntrd) lon(x_cntrd) swm(exp 0.03) dist(.) dunit(km) approx detail}{p_end}

{pstd}
Case 3: Nonbinary spatial weight matrix by power function{p_end}
{phang2}{cmd:. moransi MFIL59, lat(y_cntrd) lon(x_cntrd) swm(pow 1) dist(.) dunit(km) approx detail}{p_end}

{pstd}
Results can be displayed in a map using the {cmd:shp2dta} and {cmd:spmap} commands. 


{title:Stored results}

{pstd}
{cmd:moransi} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(I)}}Moran's I statistic{p_end}
{synopt:{cmd:r(EI)}}Expected value of I{p_end}
{synopt:{cmd:r(seI)}}Standard Error of I{p_end}
{synopt:{cmd:r(zI)}}z-value of I{p_end}
{synopt:{cmd:r(pI)}}p-value of I{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(td)}}threshold distance{p_end}
{synopt:{cmd:r(dd)}}distance decay parameter{p_end}
{synopt:{cmd:r(dist_mean)}}mean of distance{p_end}
{synopt:{cmd:r(dist_sd)}}standard deviation of distance{p_end}
{synopt:{cmd:r(dist_min)}}minimum value of distance{p_end}
{synopt:{cmd:r(dist_max)}}maximum value of distance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:moransi}{p_end}
{synopt:{cmd:r(varname)}}name of variable{p_end}
{synopt:{cmd:r(swm)}}type of spatial weight matrix{p_end}
{synopt:{cmd:r(dunit)}}unit of distance{p_end}
{synopt:{cmd:r(dist_type)}}exact or approximation{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(D)}}lower triangle distance matrix{p_end}


{marker author}{...}
{title:Author}

{pstd}Keisuke Kondo{p_end}
{pstd}Research Institute of Economy, Trade and Industry{p_end}
{pstd}Tokyo, Japan{p_end}
{pstd}kondo-keisuke@rieti.go.jp


{marker references}{...}
{title:References}

{phang}
Kondo, K. (2016). "Hot and cold spot analysis using Stata," {it:Stata Journal}, volume 16, number 3: {browse "http://www.stata-journal.com/article.html?article=st0446":st0446}
{p_end}

{phang}
Kondo, K. (2017). "SPGEN: Stata module to generate spatially lagged variables,"
 Statistical Software Components, Boston College. {browse "https://ideas.repec.org/c/boc/bocode/s458105.html"}
{p_end}

