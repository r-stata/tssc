{smcl}
{* *! version 1.0  4 October 20119}{...}
{cmd:help ivgravity} {right: (Koen Jochmans and Vincenzo Verardi)}
{hline}

{title:Title}

{p2colset 5 15 2 2}{...}
{p2col:{hi:ivgravity}} {hline 2}  Method-of-moment IV estimators from Jochmans and Verardi (2019) for estimating exponential-regression models with two-way fixed effects from a cross-section of data on dyadic interactions and endogenous covariates{p_end}
{p2colreset}{...}

{title:Syntax}


{p 4 12 2}
{cmd:ivgravity} {depvar} [{it:{help varlist:varlist1}}]
{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
        {it:{help varlist:varlist_iv}}{cmd:)}  {cmd:,} {opt indm(varname)} {opt indn(varname)} [{opt initial(vector)} {opt level(#)}]

{phang}
{it:depvar} is the dependent variable.{p_end}
{phang}
{it:varlist1} is the list of exogenous variables.{p_end}
{phang}
{it:varlist2} is the list of endogenous variables.{p_end}
{phang}
{it:varlist_iv} is the list of exogenous variables used with {it:varlist1}
   as instruments for {it:varlist2}.

{synoptset 19 tabbed}
{marker semiparopts}{...}
{synopthdr}
{synoptline}
{synopt:{opt indm(varname)}}Specifies the first agent in the dyad  (akin to a panel identifier){p_end}
{synopt:{opt indn(varname)}}Specifies the second agent in the dyad (akin to time identifier){p_end}
{synopt:{opt initial(vector)}}Specifies a column vector of initial values for coefficients{p_end}
{synopt:{opt level(#)}}Set confidence level; default is level(95){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
ivgravity computes Jochmans and Verardi (2019) generalisation to the IV case of Jochmans' (2017) method-of-moment estimators in a computationally-efficient manner.

{title:Examples}

{phang}{cmd:. ivgravity trade dist colony bord (pta lang= common_pta common_bord smctry lang), indn( importer) indm( exporter)}{p_end}

{phang}{cmd:. matrix A=J(5,1,0)}{p_end}
{phang}{cmd:. ivgravity trade dist colony bord (pta lang= common_pta common_bord smctry lang), indn( importer) indm( exporter) init(A)}{p_end}

{title:Output}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(sargan)}}Sargan overidentification test statistic{p_end}
{synopt:{cmd:e(psargan)}}p-value{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}


{title:Authors}

{pstd}Koen Jochmans, University of Cambridge; and Vincenzo Verard, FNRS-UNamur{p_end}


{title:Also see}

{p 5 14 2}Help:  {helpb twgravity} {helpb twexp} (if installed){p_end}

{title:References}

{phang}Jochmans, K. and V. Verardi (2019).  Instrumental variable estimation of gravity equations.
{it:Mimeo}.
{phang}Jochmans, K. (2017), Two-way models for gravity, Review of Economics and Statistics 99: 478-485


