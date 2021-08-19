{smcl}
{* *! version 1.0.1  14jul2021}{...}

{cmd:help hetsar postestimation} {right:also see: {helpb hetsar}  }
{hline}

{title:Title}

{p 4 16 2}
{cmd:hetsar postestimation} {hline 2} Postestimation tools for hetsar{p_end}



{title:Description}

{pstd}
The following postestimation commands are available after {cmd:hetsar}:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt:{bf:{help estat}}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb hetsar postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}



{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{synoptset 28 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt rf:orm}}reduced-form predicted values; the default{p_end}
{synopt :{opt na:ive}}predictions based on the observed values of {bf:y}{p_end}
{synopt :{opt res:iduals}}residuals. By adding {cmd:naive}, the residuals will be computed using naive fitted values{p_end}
{synoptline}
{p2colreset}{...}



{title:Options for predict}

{dlgtab:Main}

{phang}
{opt rform} predicted values calculated from the reduced-form equation,
y_it = (I-{it:rho}_i*W)^(-1)*(x_it*beta_i + a_i).

{phang}
{opt naive} predicted values based on the observed values of y_it,
{it:rho}_i*W*y_it + x_it*beta_i + a_i.

{phang}
{opt residuals} based on reduced form (default) or naive fitted values.



{marker remarks}{...}
{title:Remarks}

{pstd}
See Aquaro, Bailey and Pesaran (2021) for more details.



{title:Examples}

{pstd}Load and summarize the spatial weights matrix{p_end}
{phang2}{stata "spmat import w using https://raw.github.com/fbelotti/Stata/master/txt/Wrook_25.txt, replace noid normalize(row)":spmat import w using Wrook_25.txt, replace noid normalize(row)}{p_end}
{phang2}{stata "spmat summarize w"}{p_end}

{pstd}Load data and set-up the panel{p_end}
{phang2}{stata "import delimited https://raw.github.com/fbelotti/Stata/master/csv/hetsar_demo.csv, clear":import delimited hetsar_demo.csv, clear}{p_end}
{phang2}{stata "xtset id time"}{p_end}

{pstd}Estimate a Static heterogenous SAR model{p_end}
{phang2}{stata "hetsar y x, wmatrix(w) technique(nr 3 bfgs 10)"}{p_end}

{pstd}Reduced form fitted values{p_end}
{phang2}{stata "predict y_hat"}{p_end}

{pstd}"Observed" fitted values{p_end}
{phang2}{stata "predict y_hat_naive, naive"}{p_end}

{pstd}Residuals from observed fitted values{p_end}
{phang2}{stata "predict residuals, residual naive"}{p_end}



{title:References}

{phang}
Aquaro, M, Bailey, N and Pesaran, M.H., 2021
"Estimation and inference for spatial models with heterogeneous coefficients: An application to US house prices", Journal of Applied Econometrics, 36, pp. 18-44.


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}



{title:Also see}

{psee}
Online:  {helpb hetsar}, {helpb spxtregress}{p_end}
