{smcl}

{title:Title}

{p2colset 9 19 20 2}{...}
{p2col :{opt phecdf} {hline 2}}Empirical CDF Estimation for Heterogeneous Panel Data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt phecdf} {it:panelvar} {ifin}[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Order}
{synopt :{opt acov_order(#)}}set order of the autocovariance; default is 0.{p_end}
{synopt :{opt acor_order(#)}}set order of the autocorrelation; default is 1.{p_end}
{synopt :{opt boot(#)}}set number of bootstrap replication; default is 200.{p_end}

{syntab:Method}
{synopt :{opth method:(strings:string)}}{it:string} must be one of three estimation methods {it:"naive", "hpj", "toj"}.{p_end}

{syntab:Graph}
{synopt :{opth graph:(strings:string)}}{it:string} must be a list consisting of {it:mean, acov, acor}; default is "mean acov acor".{p_end}
{synopt :{opth ci:(strings:string)}}{it:string} must be either "on" or "off"; default is "on".{p_end}
{synoptline}

{p 4 6 2}{it:panelvar} must be {help xtset} and strongly balanced.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:phecdf} performs estimation of empirical distribution function when the panel data exhibits heterogeneity across its cross-sectional units.

{marker dependencies}
{title:Dependencies}

{pstd}
{cmd:phecdf} requires the {cmd:moremata}
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
{opth method:(strings:string)} specifies how the empirical CDFs of moments are estimated. 
{it:"naive"} stands for naive estimation without bias-correction, {it:"hpj"} for half panel jackknife and {it:"toj"} for third order jackknife.

{dlgtab:Graph}

{phang}
{opth graph:(strings:string)} specifies which graphs of empirical CDFs to be plotted. 

{phang}
{opth ci:(strings:string)} specifies whether to present confidence intervals on graphs or not

{marker results}
{title:Results} 

{pstd}{cmd:phecdf} gives plots of empirical CDFs of mean, autocovariance and autocorrelation chosen by users.


{marker example}{...}
{title:Examples:  empirical CDF estimation}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse pig}{p_end}
{phang2}{cmd:. xtset id week}{p_end}

{pstd}Estimate the empirical CDFs of the variable {it:weight} about autocovariance of order 1 and autocorrelation of order 2 using naive estimation.{p_end}
{phang2}{cmd:. phecdf weight, method("naive") acov_order(1) acor_order(2) ci("on") boot(300) graph("acov acor")}{p_end}


{marker reference}{...}
{title:Reference}

{marker DM1993}{...}
{phang}
Ryo Okui. and Takahide Yanagi. 2019.
{browse "https://doi.org/10.1016/j.jeconom.2019.04.036":{it:Panel Data Analysis with Heterogeneous Dynamics}.}
{it:Journal of Econometrics}.
{p_end}
