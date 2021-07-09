{smcl}
{* *! version 1.0  28march2018}{...}
{cmd:help twexp} {right: (Koen Jochmans and Vincenzo Verardi)}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:twexp} {hline 2}}{title: Method-of-moment estimators from Jochmans (2017) for estimating exponential-regression models with two-way fixed effects from a panel data with self-links}{p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 12 2}
{cmd:twexp} {varlist} {ifin} {cmd:,} {opt indm(varname)} {opt indn(varname)} {opt model(GMM1|GMM2)} [{opt initial(vector)}]

{synoptset 19 tabbed}
{marker semiparopts}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt indm(varname)}}Specifies the cross-section indicator{p_end}
{synopt:{opt indn(varname)}}Specifies the time-series indicator{p_end}
{synopt:{opt model(GMM1|GMM2)}}Specifies estimator to use - see Jochmans and Verardi (2019){p_end}
{synopt:{opt initial(vector)}}Specifies a column vector of initial values for coefficients{p_end}

{synoptline}
{p2colreset}{...}

{title:Description}

twexp computes Jochmans' (2017) method-of-moment estimators in a computationally-efficient manner.

{title:Example}

Download the dataset from http://cameron.econ.ucdavis.edu/mmabook/patr7079.asc and name variables

{phang2}{cmd:.infile CUSIP ARDSSIC SCISECT LOGK SUMPAT LOGR70 LOGR71 LOGR72 LOGR73 ///}{p_end}
{phang2}{cmd:LOGR74 LOGR75 LOGR76 LOGR77 LOGR78 LOGR79 PAT70 PAT71 PAT72 ///}{p_end}
{phang2}{cmd:PAT73 PAT74 PAT75 PAT76 PAT77 PAT78 PAT79 ///}{p_end}
{phang2}{cmd:using "http://cameron.econ.ucdavis.edu/mmabook/patr7079.asc"}{p_end}

{phang2}{cmd:.gen id = _n}{p_end}

{phang2}{cmd:.reshape long PAT LOGR, i(id) j(year)}{p_end}

{phang2}{cmd:.twexp PAT LOGR, indn(id) indm(year) model(GMM1)} {p_end}

{phang2}{cmd:.matrix init=e(b)'}{p_end}
{phang2}{cmd:.twexp PAT LOGR, indn(id) indm(year) model(GMM2) init(init)} {p_end}

{pstd}


{title:Authors}

{pstd}Koen Jochmans, University of Cambridge; and Vincenzo Verard, FNRS-UNamur{p_end}


{title:Also see}

{p 7 14 2}Help:  {helpb twgravity} (if installed){p_end}

{title:References}

{phang}Jochmans, K. and V. Verardi (2019).  twexp and twgravity: Estimating exponential   regression models with two-way fixed effects.
{it:Mimeo}.
{phang}Jochmans, K. (2017), Two-way models for gravity, Review of Economics and Statistics 99: 478-485



