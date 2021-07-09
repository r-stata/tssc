{smcl}
{* *! version 1.30 22 April 2017}{...}
{viewerjumpto "Syntax" "spgen##syntax"}{...}
{viewerjumpto "Description" "spgen##description"}{...}
{viewerjumpto "Outcome" "spgen##outcome"}{...}
{viewerjumpto "Options" "spgen##options"}{...}
{viewerjumpto "Remarks" "spgen##remarks"}{...}
{viewerjumpto "Examples" "spgen##examples"}{...}
{viewerjumpto "Author" "spgen##author"}{...}
{viewerjumpto "References" "spgen##references"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{bf:spgen} {hline 2}}Generate Spatially Lagged Variable{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:spgen} {varname} {ifin}, {cmd:lon({varname})} {cmd:lat({varname})} {opt swm(swmtype)} {opt dist(#)} {opt dunit}{bf:(km|mi)}
[{opt o:rder(#)}] [{cmd:wvar({varname})}] [{opt nostd}] [{opt nomat:save}] [{opt dms}] [{opt app:rox}] [{opt det:ail}] [{opt large:size}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required Settings for Spatial Weight Matrix}
{synopt:{opt lon(varname)}} specifies the variable of latitude.
{p_end}
{synopt:{opt lat(varname)}} specifies the variable of longitude.
{p_end}
{synopt:{opt swm(swmtype)}} specifies a type of the spatial weight matrix.
{p_end}
{synopt:{opt dist(#)}} specifies the threshold distance for the spatial weight matrix.
{p_end}
{synopt:{opt dunit}{bf:(km|mi)}} specifies the unit of distance ({bf:km}, kilometers; {bf:mi}, miles).
{p_end}
{syntab:Optional Settings for Spatial Weight Matrix}
{synopt:{opt o:rder(#)}} uses #th order of the spatial weight matrix.
{p_end}
{synopt:{opt wvar(varname)}} specifies a weight variable for the spatial weight matrix.
{p_end}
{synopt:{opt nostd}} specifies non row-standardized spatial weight matrix.
{p_end}
{synopt:{opt nomat:save}} does not save the bilateral distance matrix on the memory.
{p_end}
{synopt:{opt dms}} converts DMS format to decimal format.
{p_end}
{synopt:{opt app:rox}} uses bilateral distance approximated by the simplified version of the Vincenty formula.
{p_end}
{synopt:{opt det:ail}} displays descriptive statistics of distance.
{p_end}
{synopt:{opt large:size}} is used for large sized data.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd: spgen} generates the spatially lagged variable of {varname}. 
{p_end}

{marker outcome}{...}
{title:Outcome}

{pstd}
{cmd: spgen} generates the spatially lagged variable, {cmd:splag{it:#}_{it:varname}_{it:swmtype}}[_{it:wvar}], where the {it:varname} is automatically inserted and the suffix {bf:b}, {bf:e}, or {bf:p} is also inserted in accordance with {it:swmtype}: {bf:b} for {cmd:swm(pow)}, {bf:e} for {cmd:swm(exp {it:#})}, and {bf:p} for {cmd:swm(pow {it:#})}. The weight variable name {it:wvar} is inserted if used.
{p_end}

{marker options}{...}
{title:Options}
{dlgtab:Required Settings}
{phang}
{opt lon(varname)} specifies the variable of latitude in the dataset. The decimal format is expected in the default setting. The positive value denotes the north latitude. The negative value denotes the south latitude.
{p_end}

{phang}
{opt lat(varname)} specifies the variable of longitude in the dataset. The decimal format is expected in the default setting. The positive value denotes the east longitude. The negative value denotes the west longitude.
{p_end}

{phang}
{opt swm(swmtype)} specifies a type of the spatial weight matrix. One of the following three types of spatial weight matrix must be specified: {opt bin} (binary), {opt exp} (exponential), or {opt pow} (power).  The distance decay parameter {it:#} must be specified for the exponential and power functional types of spatial weight matrix as follows: {cmd:swm(exp {it:#})} and {cmd:swm(pow {it:#})}. The bilateral distance is calculated by Vincenty formula (Vincenty, 1975).
{p_end}

{phang}
{opt dist(#)} specifies the threshold distance for the spatial weight matrix.

{phang}
{opt dunit}{bf:(km|mi)} specifies the unit of distance. Either {bf:km} (kilometers) or {bf:mi} (miles) must be specified. 
{p_end}

{dlgtab:Optional Settings}
{phang}
{opt o:rder(#)} uses {it:#}th order of spatial weight matrix. The default setting calculates the 1st order of spatially lagged variable.
{p_end}

{phang}
{opt wvar(varname)} specifies a weight variable for the spatial weight matrix. Weight variable is not used in the default setting.
{p_end}

{phang}
{opt nostd} uses the spatial weight matrix that is not row-standardized. The row-standardized spatial weight matrix is used in the default setting.
{p_end}

{phang}
{opt nomat:save} does not save the bilateral distance matrix {bf:r(D)} on the memory. The {opt nomat:save} option is not used in the default setting.
{p_end}

{phang}
{opt dms} converts the DMS (Degrees, Minutes, Seconds) format to a decimal format. The default setting is the decimal format.
{p_end}

{phang}
{opt app:rox} uses bilateral distance approximated by the simplified version of the Vincenty formula. The {opt app:rox} option is not used in the default setting.
{p_end}

{phang}
{opt det:ail} displays descriptive statistics of distance. The {opt d:etail} option is not used in the default setting.
{p_end}

{phang}
{opt large:size} is used for large sized data. When this option is specified, {opt nomat:save}, {opt app:rox}, and {opt order(1)} options are automatically applied. The {opt det:ail} option displays only minimum and maximum distances. The {opt large:size} option is not used in the default setting.
{p_end}

{marker examples}{...}
{title:Examples}

{phang}See Kondo (2017) for the dataset used in this example.{p_end}

{phang}Spatially lagged variable using power functional type of spatial weight matrix{p_end}

{phang2}{cmd:. spgen} CRIME, lat(y_cntrd) {cmd:lon}(x_cntrd) swm(pow 8) dist(.) dunit(km) app{p_end}

{phang}Spatially lagged variable using exponential functional type of spatial weight matrix{p_end}

{phang2}{cmd:. spgen} CRIME, lat(y_cntrd) {cmd:lon}(x_cntrd) swm(exp 0.15) dist(.) dunit(km) app{p_end}

{phang}Spatially lagged variable using binary type of spatial weight matrix{p_end}

{phang2}{cmd:. spgen} CRIME, lat(y_cntrd) {cmd:lon}(x_cntrd) swm(bin) dist(5) dunit(km) app{p_end}

{marker author}{...}
{title:Author}

{pstd}Keisuke Kondo{p_end}
{pstd}Research Institute of Economy, Trade and Industry (RIETI). Tokyo, Japan.{p_end}
{pstd}(URL: https://sites.google.com/site/keisukekondokk/){p_end}

{marker references}{...}
{title:References}

{marker K2017}{...}
{phang}
Kondo, K. (2017) "Introduction to spatial econometric analysis: Creating spatially lagged variable in Stata,"
 Mimeo. (URL: https://sites.google.com/site/keisukekondokk/research)
{p_end}

{marker V1975}{...}
{phang}
Vincenty, T. (1975) "Direct and inverse solutions of geodesics on the ellipsoid with application of nested equations," {it:Survey Review} 23(176), pp. 88-93.
{p_end}
