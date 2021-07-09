{smcl}
{* *! version 1.0  09mar2015}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:syncmrates} {hline 2} child mortality rates using synthetic cohort probabilities


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:syncmrates}
[{varlist}]
{if}
{weight}
[{cmd:,} {it:options} {it:bootstrap_options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt t0(#)}}start of time interval in months{p_end}
{synopt:{opt t1(#)}}end of time interval in months{p_end}
{synopt:{opt test:by(varname)}}test the difference in mortality rates between the two groups specified in {it:varname}{p_end}
{synopt:{opt trend(#)}}calculates monthly series of mortality rates for # months before the survey{p_end}
{synopt:{opt plot(string)}}plot monthly series of the mortality rate specified in {it:string}, where {it:string} can be nmr, pmr, imr, cmr, or u5mr {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd: only iweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:syncmrates} calculates the following mortality rates:

{synoptset 20 tabbed}{...}
{synoptline}
{synopt:{opt nmr}}neo-natal mortality rate{p_end}
{synopt:{opt pmr}}post-neonatal mortality rate{p_end}
{synopt:{opt imr}}infant mortality rate{p_end}
{synopt:{opt cmr}}child mortality rate{p_end}
{synopt:{opt u5mr}}under-5 mortality rate{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{pstd}
{cmd:syncmrates} calculates mortality rates using the synthetic cohort probability method employed in Demographic and Health
Surveys(DHS) and described in Rutstein and Rojas(2003). This method is based on the full birth history survey approach, whereby women are 
asked for the date of birht of each of their children, whether the child is still alive, 
and if not the age at death.
By default mortality rates are calculated over the 5 years preceding the month interview.
 
{pstd} 
Three variables must be included in {it:varlist} after issuing the {cmd:syncmrates} command in exactly the following order: 
date of interview, date of birth, and age at death. 
All three variables must be expressed in months and, following DHS convention,
date of of interview and date of birth must be expressed 
in Century Months Codes (CMC). The CMC code takes the value of 1 in January 1900. When using non-DHS data, the date of interview,
and the date of birth have to be transformed using this code. For example, the CMC code for May 1968 is (1968-1900)*12+5. {p_end}

{pstd}
{cmd:syncmrates} allows users to replicate exactly the mortality rates reported by DHS surveys. In addition:
1) it allows a flexible range for the time interval over which mortality rates are calculated. 
While the default for the calculation of mortality rates is 5 years before the survey, 
users can calculate mortality rates over 1 or 10 years before the survey or over any
other desired interval specified in the options  {opt t0(#)} and {opt t1(#)}; 
2) it allows the calculation of mortality rates for geographic or socio-economic subgroups specified using {opt if}; 
3) it calculates bootstrapped standard errors and 95% confidence intervals; 
4) it calculates and tests the difference in mortality rates between two groups specified in {opt test:by(varname)}; 
and 5) it builds monthly time series of monthly mortality rates and confidence intervals, it saves the series 
in the current directory, and plots the mortality rate specified in {opt plot(string)} for exploratory data analysis{p_end}



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt t0(#)} set the start of the time interval in number of months before the survey,
the default is t0(61), corresponding to 5 years before the survey.

{phang}
{opt t1(#)} set the end of the time interval in number of months before the survey,
the default is t1(1), corresponding to the first month before survey.

{phang}
{opt test:by(varname)} tests the difference in mortality rates between the two groups 
specified in {it:varname} using boostrapped standard errors.

{phang}
{opt trend(#)} produces monthly series of mortality rates  and their confidence intervals 
for the number of months before the survey specified in #. By default mortality rates are 
calculated over a 5-year time interval before the survey but this interval can be changed
using the {opt t0(#)} and {opt t1(#)} options. The mortality rates for # monhts before the survey
are saved in the current directory in syncmrates.dta together with their 95% confidence intervals.

{phang}
{opt plot(string)} can only be used with {opt trend(#)}. It plots the monthly series of the mortality rate 
specified in {opt plot(string)}, where {it:string} can be either nmr, pmr, imr, cmr or u5mr.
The series are plotted for the number of months before the survey specified in {opt trend(#)}.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:syncmrates} calculates bootstrapped standard errors and confidence intervals for the mortality rates
and allows all stata {help bootstrap_options}. The following options are of particular relevance in the 
estimation of mortality rates:{p_end}

{pstd}
{opt reps(#)}: by default {cmd: syncmrates} uses 50 sample replications. The number can be increased in order
to obtain more accurate standard erros. The number can be reduced to speed computer calculations (down to a minimum of reps(2)) when 
the user is interested in estimation of mortality rates but not in their confidence interval. In particular, 
calculations employing the {opt trend(#)} option may require a long time using the default number of replications.{p_end}

{pstd}
{opt cluster(varname)}: by default, {cmd: syncmrates} calculates standard errors assuming the observations are independent.
More conservative standard errors can be obtained by assuming that observations are correlated within clusters and 
independent across clusters. These standard errors are obtained using the option {opt cluster(varname)}.{p_end}

{pstd}
{cmd: estat bootstrap}: by default, {cmd: syncmrates} calculates normal-based confidence intervals that are symmetric around the mean 
by 2 standard deviations. Non-symmetric percentile and bias-corrected confidence intervals can be obtained 
by issuing the {cmd: estat bootstrap} command after {cmd: syncmrates}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Mortality rates using DHS data{p_end}

{phang}{cmd:. syncmrates v008 b3 b7 [iw=v005]}{p_end}

{pstd}
Calculate more accurate and conservative standard errors{p_end}

{phang}{cmd:. syncmrates v008 b3 b7 [iw=v005], reps(1000) cluster(v021)}{p_end}

{pstd}
Mortality rates over 10 years before the survey{p_end}

{phang}{cmd:. syncmrates v008 b3 b7 [iw=v005], t0(121) t1(1)}{p_end}

{pstd}
Test difference in mortality rates between boys and girls{p_end}

{phang}{cmd:. syncmrates v008 b3 b7 [iw=v005], testby(b4)}{p_end}

{pstd}
Calculate trends over 10 years before the survey and plot trend of imr{p_end}

{phang}{cmd:. syncmrates v008 b3 b7 [iw=v005], trend(120) plot(imr)}{p_end}


{title:References}

{p 0 2} Rutstein, S.0. and G.Rojas (2003). {it:Guide to DHS Statistics},
Demographic and Healt Surveys, ORC Macro, Calvert, MD.



{title:Author}

{pstd}
Edoardo Masset{p_end}
{pstd}
Institute of Development Studies{p_end}
{pstd}
University of Sussex{p_end}
{pstd}
Brighton, UK.{p_end}
{pstd}
e.masset@ids.ac.uk{p_end}

