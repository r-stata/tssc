{smcl}
{* *! version 1.0  28march2018}{...}
{cmd:help twgravity} {right: (Koen Jochmans and Vincenzo Verardi)}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:twgravity} {hline 2}}{title: Method-of-moment estimators from Jochmans (2017) for estimating exponential-regression models with two-way fixed effects from a cross-section of data on dyadic interactions }{p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 12 2}
{cmd:twgravity} {varlist} {ifin} {cmd:,} {opt indm(varname)} {opt indn(varname)} {opt model(GMM1|GMM2)} [{opt initial(vector)}]

{synoptset 19 tabbed}
{marker semiparopts}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt indm(varname)}}Specifies the first agent in the dyad  (akin to a panel identifier){p_end}
{synopt:{opt indn(varname)}}Specifies the second agent in the dyad (akin to time identifier){p_end}
{synopt:{opt model(GMM1|GMM2)}}Specifies estimator to use - see Jochmans and Verardi (2019){p_end}
{synopt:{opt initial(vector)}}Specifies a column vector of initial values for coefficients{p_end}

{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
twgravity computes Jochmans' (2017) method-of-moment estimators in a computationally-efficient manner.

{title:Examples}

Download Log of gravity.dta at: "http://personal.lse.ac.uk/tenreyro/regressors.zip"
{phang2}{cmd:. use "Log of Gravity.dta"}{p_end}
{phang2}{cmd:. twgravity trade ldist border comlang colony comfrt_wto , indm( s1_im ) indn( s2_ex ) model(GMM2)}{p_end}


{title:Authors}

{pstd}Koen Jochmans, University of Cambridge; and Vincenzo Verard, FNRS-UNamur{p_end}


{title:Also see}

{p 7 14 2}Help:  {helpb twexp} (if installed){p_end}

{title:References}

{phang}Jochmans, K. and V. Verardi (2019).  twexp and twgravity: Estimating exponential   regression models with two-way fixed effects.
{it:Mimeo}.
{phang}Jochmans, K. (2017), Two-way models for gravity, Review of Economics and Statistics 99: 478-485


