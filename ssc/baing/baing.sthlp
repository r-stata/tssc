{smcl}
{* *! version 1 19jun2020}{...}
{cmd:help baing}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:baing} {hline 2}}Determines and estimates the number of common factors following Bai and Ng (2002).{p_end}

{p2colreset}{...}

{title:Syntax}


{p 8 17 2}
{cmd:baing} {varlist} {ifin} [{cmd:,} {it:options}]

{p 4 6 2}
{cmd:by} is not allowed.{p_end}
{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:baing}; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varlist} may not contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
Sample may not contain gaps.{p_end}


{title:Description}

{pstd}
{cmd:baing} Determines the number of common factors in approximate factor models following Bai and Ng (2002).

{title:Options}

{phang}
{opt crit:eria(integer)} specifies one of the three information criteria (IC) proposed by Bai and Ng (2002, p.201).
By default IC1 is used, that is, crit(1). Otherwise, use crit(2) or crit(3) for IC2 or IC3, respectively.

{phang}
{opt max:pc(integer)} specifies the maximum number of factors.
By default, the number of variables in {varlist} is used.

{phang}
{opt stand} standardises the variables in {varlist}  by subtracting the mean and dividing by the standard deviation of each variable.

{phang}
{opt pre:fix(string)} stores the estimated common factors in string, as {cmd:string1}, {cmd:string2}, .... .
If this option is not used, only the number of common factors is determined.

{title:Examples}

{pstd}
We illustrate the use of {cmd:baing} with the following example:{p_end}

{phang2}{bf:. {stata "clear all":clear all}}{p_end}
{phang2}{bf:. {stata "set obs 50":set obs 50}}{p_end}
{phang2}{bf:. {stata "set seed 123":set seed 123}}{p_end}
{phang2}{bf:. {stata "gen t = _n":gen t = _n}}{p_end}
{phang2}{bf:. {stata "gen x1 = rnormal()":gen x1 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x2 = rnormal()":gen x2 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x3 = rnormal()":gen x3 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x4 = rnormal()":gen x4 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x5 = rnormal()":gen x5 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x6 = rnormal()":gen x6 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x7 = rnormal()":gen x7 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x8 = rnormal()":gen x8 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x9 = rnormal()":gen x9 = rnormal()}}{p_end}
{phang2}{bf:. {stata "gen x10 = rnormal()":gen x10 = rnormal()}}{p_end}
{phang2}{bf:. {stata "tsset t":tsset t}}{p_end}

{pstd}
To determine the number of common factors using the raw variables {cmd:x1}, ..., {cmd:x10} and the first criterion (IC1, which is used as default): {p_end}

{phang2}{bf:. {stata "baing x*":baing x*}}{p_end}

{pstd}
Same as before but using standardised data:{p_end}

{phang2}{bf:. {stata "baing x*, stand":baing x*, stand}}{p_end}

{pstd}
Same as before and setting the maximum number of factors equal to, say, 5:{p_end}

{phang2}{bf:. {stata "baing x*, stand max(5)":baing x*, stand max(5)}}{p_end}
 
{pstd}
Same as before and storing the resulting common factor variables as {cmd:myfactors1}, {cmd:myfactors2}, ...:{p_end}

{phang2}{bf:. {stata "baing x*, stand max(5) prefix(myfactors)":baing x*, stand max(5) prefix(myfactors)}}{p_end}

{pstd}
To use standardised data, maximum number of factors set equal to 5 and IC2:{p_end}

{phang2}{bf:. {stata "baing x*, stand max(5) crit(2)":baing x*, stand max(5) crit(2)}}{p_end}


{title:Stored results}

{pstd}
{cmd:baing} stores:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(baing_ic)}}number of factors{p_end}


{title:References}

{phang}
Bai J., S. Ng. 2002. Determining the number of factors in approximate factor models. {it:Econometrica} 70: 191-221.

{phang}
Chudik A., G. Kapetanios and M. H. Pesaran. 2018. A one covariate at a time, multiple testing approach to variable selection in high-dimensional linear regression models. {it:Econometrica} 86: 1479-1512.

{title:Acknowledgement}

{phang}
The routine to determine the number of factors is based on the Eviews code snippet presented in:

{phang}
{browse "http://blog.eviews.com/2018/11/principal-component-analysis-part-ii.html":http://blog.eviews.com/2018/11/principal-component-analysis-part-ii.html}

{phang}
The routine to estimate the factors is based on the Matlab code {cmd:panelFactorNew.m} developed by Chudik, Kapetanios and Pesaran (2018), included in the supplemental material of their paper. The interested reader is referred to:

{phang}
{browse "http://www.econ.cam.ac.uk/people/emeritus/mhp1/published-articles#2018":http://www.econ.cam.ac.uk/people/emeritus/mhp1/published-articles#2018}


{title:Authors}

{pstd}
H{c e'}ctor M. N{c u'}{c n~}ez{break}
Centro de Investigaci{c o'}n y Docencia Econ{c o'}micas (CIDE){break}
Aguscalientes, M{c e'}xico{break}
hector.nunez@cide.edu{p_end}

{pstd}
Jes{c u'}s Otero{break}
Universidad del Rosario{break}
Bogot{c a'}, Colombia{break}
jesus.otero@urosario.edu.co{p_end}
