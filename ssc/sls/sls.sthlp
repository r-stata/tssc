{smcl}
{* *! version 1.0  01dec2012}{...}
{cmd:help sls}
{hline}


{title:Title}

{phang}
{bf:sls} {hline 2} Semiparametric Least Squares from Ichimura, 1993.


{title:Syntax}

{p 8 17 2}
{cmd:sls}
{depvar} {indepvars}
{ifin}
[{cmd:,} {it:options}] 

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt tr:im(#,#)}}lower and upper trimming centiles. Default is trim(1,99).{p_end}
{synopt:{opt pilot}}use pilot bandwidth only. Default is simultaneous bandwidth estimation.{p_end}
{synopt:{cmdab:init(}{it:{help sls##init_options:init_options}}{cmd:)}}specify moptimize_init options for minimization.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:sls} performs semi-parametric estimation as described in Ichimura's 1993 paper. 
Kernel density estimates are calculated using a gaussian kernel{*:, as described in Newey, Hsieh, and Robins, 2004}. 
The bandwidth parameter is estimated using a two-step
procedure. First, the index parameters are estimated using a plug-in optimal bandwidth 
estimate. The bandwidth and index parameter estimates from this preliminary estimation are
used to construct bounds on the final bandwidth estimate. The final optimal bandwidth 
parameter is estimated simultaneously with the index parameters. The bandwidth parameter 
is chosen as the minimizer of the squared error objective function, 
as described in Hardle, Hall, & Ichimura, 1993. 

{pstd}
Because no functional form is assumed, parameters are not identified in location or scale. Only 
ratios of coefficients are identified. To achieve identification, a normalization assumption
is required. This estimator does not estimate a constant term and restricts the coefficient 
on the first independent variable to 1. At least two independent variables are required
to run the estimator. At least one independent variable must be continuous.


{title:Options}

{dlgtab:Main}

{phang}
{opt tr:im(#,#)} sets the percentile bounds that identify boundary observations. These
observations are excluded from the value function in each iteration of the minimization 
procedure. They are also excluded from variance estimates. Trimmed observations are included 
in the the estimation of conditional expectation for non-trimmed observation. Users who 
wish to completely exclude certain observations should use {ifin} statements. The default
trimming centiles are (1,99). Bounds of 0 or 100 may be specified if no trimming is desired
on the lower or upper tail, respectively. 

{phang}
{opt pilot} specifies that the pilot bandwith calculation be used for the entire estimation 
procedure. The pilot bandwidth is a plug-in estimate that follows the Silverman rule-of-thumb.
For actual bandwidth values, I used values given in lecture notes by Bruce E. Hansen. 
The default procedure first goes through several iterations using the pilot bandwidth,
then minimizes bandwidth simultaneously with the squared error objective function.
This option follows the same procedure, but constrains the bandwidth to the final pilot
bandwidth estimate during the simultaneous minimization procedure.

{marker init_options}{...}
{phang}
{opt init(init_options)} passes {help mf_moptimize##syn_step2:moptimize_init} options directly to moptimize problem.

{pmore}
Passing {help mf_moptimize##syn_step2:moptimize_init} options directly provides total control over the optimization procedure. 
These options take precedence over all pre-set minimization options.  
These options may be used to specify initial values, add linear coefficient constraints, or change the optimization technique. 
Because the bandwidth parameter is estimated simultaneously, the moptimize problem has two equations. The first equation 
estimates index parameters and the second estimates the bandwidth. Equation number should be specified with setting
equation specific {help mf_moptimize##syn_step2:moptimize_init} options. 

{pmore}
{it:init_options} may contain one or more {help mf_moptimize##syn_step2:moptimize_init} options, separated by spaces or commas.  
In each option, the name of the moptimize problem, along with the subsequent comma, should be omitted. 
Similarly, the characters "moptimize_init_" should be omitted from each {it:init_option}. 
For example, the moptimize option, {...} 
{cmd:moptimize_init_search(M,} {c -(}{cmd:"on"}|{cmd:"off"}{c )-}{cmd:)} {...}
would be specified as {cmd:search("on")} or {cmd:search("off")}. 


{title:Example: Predicted Values}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. sls mpg weight length displacement}{p_end}
{phang}{cmd:. predict mpghat, ey}{p_end}
{phang}{cmd:. predict Index , xb}{p_end}
{phang}{cmd:. twoway (scatter mpg Index) (line mpghat Index , sort) , xtitle("Index") ytitle("MPG") legend(label(1 "Actual") label(2 "Predicted")) }{p_end}


{title:Example: Init Options}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. sls mpg weight length displacement, init( trace_coefs("on"), eq_coefs(1, (20,5)) , search("off") , conv_maxiter(50) )}{p_end}


{marker references}{...}
{title:References}

{p 0 4}Hansen, Bruce E. (2009). 
“Lecture Notes on Nonparametrics 2: Kernel Density Estimation.” 
University of Wisconsin.

{p 0 4}Hardle, W., Hall, P., & Ichimura, H. (1993). 
Optimal Smoothing in Single-Index Models. 
The Annals of Statistics, 21(1), 157–178.

{p 0 4}Ichimura, H. (1993). 
Semiparametric least squares (SLS) and weighted SLS estimation of single-index models. 
Journal of Econometrics, 58(1-2), 71–120. 
{* }
{* {p 0 4}Newey, W. K., Hsieh, F., & Robins, J. M. (2004).}
{* Twicing Kernels and a Small Bias Property of Semiparametric Estimators.} 
{* Econometrica, 72(3), 947–962.}

{p 0 4}Silverman, B. W. (1986). 
Density Estimation. 
London: Chapman and Hall.


{title:Author}

{pstd} Michael Barker {p_end}
{pstd} Georgetown University {p_end}
{pstd} mdb96@georgetown.edu {p_end}
{pstd} https://github.com/michaelbarker/stata-sls {p_end}


{title:Also see}

{pstd}
{help sls_postestimation:sls postestimation}



