{smcl}

{title:Title}

{p2colset 9 22 20 2}{...}
{p2col :{opt phmoment} {hline 2}}Moments Estimation for Heterogeneous Panel Data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt phmoment} {it:panelvar} {ifin}[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Order}
{synopt :{opt acov_order(#)}}set order of the autocovariance; default is 0.{p_end}
{synopt :{opt acor_order(#)}}set order of the autocorrelation; default is 1.{p_end}
{synopt :{opt boot(#)}}set number of bootstrap replication; default is 200.{p_end}

{syntab:Method}
{synopt :{opth method(string)}}{it:string} must be one of three estimation methods {it:"naive", "hpj", "toj"}.{p_end}
{synoptline}

{p 4 6 2}{it:panelvar} must be {help xtset} and strongly balanced.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:phmoment} performs estimation of 9 moments({it:1.mean of mean, 2.mean of autocovariance, 3.mean of autocorrelation,}
{it:4.variance of mean, 5.variance of autocovariance, 6 variance of autocorrelation,}
{it:7.correlation between mean and autocovariance, 8.correlation between mean and autocorrelation, and 9.correlation between autocovariance and autocorrelation})
when the panel data exhibits heterogeneity across its cross-sectional units.

{marker dependencies}
{title:Dependencies}

{pstd}
{cmd:phmoment} requires the {cmd:moremata}
package. Type

        {com}. {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}{txt}
		
{marker options}{...}
{title:Options}

{dlgtab:Order}

{phang}
{opt acov_order} non-negative integer {it:k} for the order of autocovariance. The default is 0. 

{phang}
{opt acor_order} positive integer {it:k} for the order of autocorrelation. The default is 1. 

{phang}
{opt boot} positive interger {it:k} for the number of bootstrap replication. The default is 200.

{dlgtab:Method}

{phang}
{opth method:(strings:string)} specifies how the densities of moments are estimated. 
{it:"naive"} stands for naive estimation without bias-correction, {it:"hpj"} for half panel jackknife and {it:"toj"} for third order jackknife.

{marker results}
{title:Stored results} 

{pstd}
{cmd:phmoment} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(ci)}} 95% confidence intervals for the moments based on cross-sectional bootstrap.{p_end}
{synopt:{cmd:e(se)}} standard errors for the estimators based on cross-sectional bootstrap. {p_end}
{synopt:{cmd:e(est)}} estimates for the moments.{p_end}

{pstd}
All these are ordered by {it:1. mean of mean, 2. mean of autocovariance, 3. mean of autocorrelation, 4. variance of mean, 5. variance of autocovariance, 6. variance of autocorrelation,}
{it:7. correlation between mean and autocovariance, 8. correlation between mean and autocorrelation, and 9. correlation between autocovariance and autocorrelation.}{p_end}


{marker example}{...}
{title:Examples:  moments estimation}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse pig}{p_end}
{phang2}{cmd:. xtset id week}{p_end}

{pstd}Estimate the moments of the variable {it:weight} about mean, autocovariance of order 2 and autocorrelation of order 3 using Half Panel Jackknife with 300 bootstrap replications.{p_end}
{phang2}{cmd:. phmoment weight, method("hpj") boot(300) acov_order(2) acor_order(3)}{p_end}


{marker reference}{...}
{title:Reference}

{marker DM1993}{...}
{phang}
Ryo Okui. and Takahide Yanagi. 2019.
{browse "https://doi.org/10.1016/j.jeconom.2019.04.036":{it:Panel Data Analysis with Heterogeneous Dynamics}.}
{it:Journal of Econometrics}.
{p_end}
