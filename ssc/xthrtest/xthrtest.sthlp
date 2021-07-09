{smcl}
{* *! version 1.1.2  06apr2018}{...}
{findalias asfradohelp}{...}
{title:xthrtest}

{phang}
{bf:xthrtest} {hline 2} Heteroskedasticity-robust HR-test for first order panel serial correlation, see Born & Breitung (2016) and Wursten (2018)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: xthrtest}
{varlist}
[if] [in]
[{cmd:,} {it:force}] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt force}}skips checking if residuals include the fixed effect{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xthrtest} calculates the (time dependent) heteroskedasticity-robust HR statistic for serial correlation described in Born & Breitung (2016) for {varlist} of ue-residuals.

{pstd}
The underlying concept of the test boils down to regressing backwards demeaned residuals on lagged forward demeaned residuals using a heteroskedasticity and autocorrelation robust estimator. 
An F-test is then performed on the estimated coefficients. {bf:xthrtest} calculates the HR statistic that is asymptotically equivalent to this F-test.


{marker options}{...}
{title:Options}

{phang}{opt force} The test only works if the dataset contains no gaps and the residuals provided include the fixed effect. Force skips testing if the latter is true.


{marker remarks}{...}
{title:Remarks}

{pstd}
Only valid for fixed effect models without gaps. Unbalanced panels (different starts/ends) are allowed.

{pstd}
You must use the {bf:ue}-option when predicting the residuals. That is, this test requires the fixed effect-included residuals (ci + eit).

{pstd}
Any mistakes are my own.

{pstd}
Just like academic papers, coding software takes time and effort. As a result, {bf:please cite the Stata Journal article}, Wursten (2018), when you make use of this command, just like you would cite a useful paper. A full reference can be found below.
This article contains additional information about the tests, its usage and its strengths, as well as some Monte Carlo evidence.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse xtline1.dta, clear}{p_end}

{phang}{cmd:. xtreg calories, fe}{p_end}
{phang}{cmd:. predict ue_residuals_1, ue}{p_end}
{phang}{cmd:. xthrtest ue_residuals_1}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xthrtest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(p)}}p values{p_end}
{synopt:{cmd:r(HR)}}values of the Q(P) statistics{p_end}

{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pvalue{it:i})}}The p-values are also stored as scalars (often more convenient){p_end}
{synopt:{cmd:r(hr{it:i})}}Same for the hr-statistics{p_end}
{p2colreset}{...}

{marker references}{...}
{title:References}

{pstd}
{it:Testing for Serial Correlation in Fixed-Effects Panel Data Models}, Benjamin Born and Jörg Breitung, Econometric Reviews 2016

{pstd}{it:Testing for serial correlation in fixed-effects panel models}, Jesse Wursten, Stata Journal 2018


{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 
