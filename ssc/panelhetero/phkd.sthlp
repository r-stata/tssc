{smcl}

{title:Title}

{p2colset 9 17 20 2}{...}
{p2col :{opt phkd} {hline 2}}Kernel Density Estimation for Heterogeneous Panel Data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt phkd} {it:panelvar} {ifin}[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Order}
{synopt :{opt acov_order(#)}}set order of the autocovariance; default is 0.{p_end}
{synopt :{opt acor_order(#)}}set order of the autocorrelation; default is 1.{p_end}

{syntab:Method}
{synopt :{opth method:(strings:string)}}{it:string} must be one of three estimation method {it:"naive", "hpj", "toj"}.{p_end}

{syntab:Graph}
{synopt :{opth graph:(strings:string)}}{it:string} must be a list consisting of {it:mean, acov, acor}; default is "mean acov acor".{p_end}
{synopt :{opth ci:(strings:string)}}{it:string} must be either "on" or "off"; default is "on".{p_end}

{synoptline}

{p 4 6 2}{it:panelvar} must be {help xtset} and strongly balanced.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:phkd} performs kernel density estimation when the panel data exhibits heterogeneity across its cross-sectional units. 
Densities of moments(mean, acov, acor) are calculated by usual kernel density estimation 
using gaussian kernel with plug-in bandwidth on equally spaced grid of size 100.

{phang}
Split-panel jackknife {cmd:method} like {it:naive, hpj, toj} are described in
{browse "https://doi.org/10.1093/ectj/utz019":{it:Kernel Estimation for Panel Data with Heterogeneous Dynamics}.}

{marker dependencies}
{title:Dependencies}

{pstd}
{cmd:phkd} requires the {cmd:moremata}
package. Type

        {com}. {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}{txt}
		
{phang}		
{cmd:phkd} requires the {cmd:kdens}
package. Type

        {com}. {net "describe kdens, from(http://fmwww.bc.edu/repec/bocode/k/)":ssc describe kdens}{txt}


{marker options}{...}
{title:Options}

{dlgtab:Order}

{phang}
{opt acov_order} non-negative integer {it:k} for the order of autocovariance. The default is 0. 

{phang}
{opt acor_order} positive integer {it:k} for the order of autocorrelation. The default is 1. 


{dlgtab:Method}

{phang}
{opth method:(strings:string)} specifies how the densities of moments are estimated. 
{it:"naive"} stands for naive estimation without bias-correction, {it:"hpj"} for half panel jackknife and {it:"toj"} for third order jackknife.

{dlgtab:Graph}

{phang}
{opth graph:(strings:string)} specifies which graphs of densities to be plotted. 

{phang}
{opth ci:(strings:string)} specifies whether to present confidence intervals on graphs or not

{marker results}
{title:Results} 

{pstd}{cmd:phkd} gives plots of densities and confidence intervals for mean, autocovariance and autocorrelation chosen by users.


{marker example}{...}
{title:Examples:  kernel density estimation}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse pig}{p_end}
{phang2}{cmd:. xtset id week}{p_end}

{pstd}Kernel Estimate the variable {it:weight} about mean and autocorrelation of order 3 using half panel jackknife{p_end}
{phang2}{cmd:. phkd weight, method("hpj") ci("on") acor_order(3) graph("mean acor")}{p_end}


{marker references}{...}
{title:References}

{marker OY2019}{...}
{phang}
Ryo Okui. and Takahide Yanagi. 2019.
{browse "https://doi.org/10.1093/ectj/utz019":{it:Kernel Estimation for Panel Data with Heterogeneous Dynamics}.}
{it:The Econometrics Journal}.

{marker DM1993}{...}
{phang}
Ryo Okui. and Takahide Yanagi. 2019.
{browse "https://doi.org/10.1016/j.jeconom.2019.04.036":{it:Panel Data Analysis with Heterogeneous Dynamics}.}
{it:Journal of Econometrics}.
{p_end}
