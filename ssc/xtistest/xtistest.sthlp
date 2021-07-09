{smcl}
{* *! Version 1.1.0 06apr2018}{...}
{findalias asfradohelp}{...}
{title:xtistest}

{phang}
{bf:xtistest} {hline 2} Portmanteau test for panel serial correlation, see Inoue & Solon (2006) and Wursten (2018)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: xtistest}
{varlist}
[if] [in]
[{cmd:,} {it:{ul:l}ags(integer or "all", default = 2) {ul:orig}inal}] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt l:ags}}check for serial correlation up to order {it:lags}{p_end}
{synopt:{opt orig:inal}}uses Inoue & Solon calculation (should give same result){p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtistest} calculates the Portmanteau test for panel serial correlation described in Inoue & Solon (2006) for {varlist} of e-residuals.

{pstd}
The IS-test is the panel counterpart to the Q-test for time series. It tests for serial correlation of any order, but can be restricted to only consider autocorrelation up to a certain lag. 
The test rapidly loses power as T gets larger if no maximum is given. In general, N should be large relative to T for this test to function.

{marker options}{...}
{title:Options}

{phang}
{opt l:ags} The test looks for autocorrelation up to order {it:lags}. Set to 2 by default, to get the full portmanteau test specify {it:lags(all)}.

{phang}
{opt orig:inal} The test by default uses the Born & Breitung (2016) implementation, which is many times faster than the description in IS (2006). 
However, we include the original computation option in case anyone were to find a difference in outcomes between the two.


{marker remarks}{...}
{title:Remarks}

{pstd}
Only valid for fixed effect models. Unbalanced panels of any sort are allowed (unlike {cmd:xtqptest} and {cmd:xthrtest}, this test allows gaps in the data).

{pstd}
Any mistakes are my own.

{pstd}
Just like academic papers, coding software takes time and effort. As a result, {bf:please cite the Stata Journal article}, Wursten (2018), when you make use of this command, just like you would cite a useful paper. A full reference can be found below.
This article contains additional information about the tests, its usage and its strengths, as well as some Monte Carlo evidence.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. ** Example 1}{p_end}
{phang}{cmd:. sysuse xtline1.dta, clear}{p_end}

{phang}{cmd:. xtreg calories, fe}{p_end}
{phang}{cmd:. predict residuals_1, e}{p_end}
{phang}{cmd:. xtistest residuals_1, lags(1)}{p_end}

{phang}{cmd:. ** Example 2}{p_end}
{phang}{cmd:. clear}{p_end}
{phang}{cmd:. local N = 200}{p_end}
{phang}{cmd:. local T = 5}{p_end}
{phang}{cmd:. set obs `=`N'*`T''}{p_end}

{phang}{cmd:. *** Panel structure}{p_end}
{phang}{cmd:. egen i = seq(), from(1) to(`N')}{p_end}
{phang}{cmd:. egen t = seq(), from(1) block(`N')}{p_end}
{phang}{cmd:. xtset i t}{p_end}

{phang}{cmd:. *** Variables}{p_end}
{phang}{cmd:. **** Fixed effect}{p_end}
{phang}{cmd:. gen c = rnormal(0, 5)}{p_end}
{phang}{cmd:. bysort i (t): replace c = c[1]}{p_end}

{phang}{cmd:. **** Regressors}{p_end}
{phang}{cmd:. gen x1 = rnormal()}{p_end}
{phang}{cmd:. gen x2 = rnormal()}{p_end}

{phang}{cmd:. **** Independent variable}{p_end}
{phang}{cmd:. gen ea = rnormal()}{p_end}
{phang}{cmd:. gen eb = rnormal()}{p_end}
{phang}{cmd:. replace eb = 0.4*L.eb + 0.2*L2.eb + rnormal() if ~missing(L.eb, L2.eb)}{p_end}
{phang}{cmd:. gen ya = c + 0.03*x1 + 0.6*x2 + ea}{p_end}
{phang}{cmd:. gen yb = c + 0.03*x1 + 0.6*x2 + eb}{p_end}

{phang}{cmd:. *** Regress}{p_end}
{phang}{cmd:. xtreg ya x1 x2, fe}{p_end}
{phang}{cmd:. predict res_a, e}{p_end}
{phang}{cmd:. xtreg yb x1 x2, fe}{p_end}
{phang}{cmd:. predict res_b, e}{p_end}

{phang}{cmd:. *** Test residuals}{p_end}
{phang}{cmd:. xtistest res*, lags(2)}{p_end}

{phang}{cmd:. *** Test as postestimation}{p_end}
{phang}{cmd:. xtreg ya x1 x2, fe}{p_end}
{phang}{cmd:. xtistest, lags(2)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtistest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(p)}}p values{p_end}
{synopt:{cmd:r(IS)}}values of the IS statistics{p_end}

{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pvalue{it:i})}}The p-values are also stored as scalars (often more convenient){p_end}
{synopt:{cmd:r(is{it:i})}}Same for the is-statistics{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{pstd}
{it:Testing for Serial Correlation in Fixed-Effects Panel Data Models}, Benjamin Born and Jörg Breitung, Econometric Reviews 2016

{pstd}
{it:A Portmanteau Test for Serially Correlated Errors in Fixed Effects Models}, Atsushi Inoue and Gary Solon, Econometric Theory 2006

{pstd}{it:Testing for serial correlation in fixed-effects panel models}, Jesse Wursten, Stata Journal 2018

{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 
