{smcl}
{* *! version 1.1 March 11 2015 J. N. Luchman}{...}
{cmd:help mvdom}
{hline}{...}

{title:Title}

{pstd}
Wrapper program for {cmd:domin} to conduct multivariate regression-based dominance analysis{p_end}

{title:Syntax}

{phang}
{cmd:mvdom} {it:depvar1} {it:indepvars} {it:{help if} {weight}} {cmd:,} 
{opt dvs(varlist)} [{opt {ul on}noc{ul off}onstant} {opt pxy}]

{phang}{cmd:aweight}s and {cmd:fweight}s are allowed (see help {help weights:weights}).  {help fvvarlist: Factor} and 
{help tsvarlist:time series variables} are not allowed.  Use the {help xi} prefix for factor variables.

{title:Description}

{pstd}
{cmd:mvdom} sets the data up in a way to allow for the dominance analysis of a multivariate regression by utilizing {help canon}ical correlation.
The default metric used is the Rxy metric described by Azen and Budescu (2006). 

{pstd}
{cmd:mvdom} uses the first variable in the varlist as the first dependent variable in the multivariate regression.  All other variables in the 
varlist are used as independent variables.  All other dependent variables are entered into the regression in an option. The output of the dominance
analysis (i.e., in {cmd:domin}) will only show the first dependent variable in the output.

{marker options}{...}
{title:Options}

{phang}{opt dvs()} specifies the second through {it:n}th other dependent variables to be used in the multivariate regression.  The first dependent 
variable is put in the varlist.

{phang}{opt noconstant} does not subtract means when obtaining correlations (see option {opt noconstant} of {help canon}).

{phang}{opt pxy} uses the Pxy metric outlined by Azen and Budescu instead of the default Rxy metric.

{title:Saved results}

{phang}{cmd:mvdom} saves the following results to {cmd: e()}:

{synoptset 16 tabbed}{...}
{p2col 5 15 19 2: scalars}{p_end}
{synopt:{cmd:e(r2)}}Rxy metric (default) or Pxy metric (with option {opt pxy}){p_end}

{title:References}

{p 4 8 2}Azen, R., & Budescu, D. V. (2006). Comparing predictors in multivariate regression models: An extension of dominance analysis. {it:Journal of Educational and Behavioral Statistics, 31(2)}, 157-180.{p_end}

{title:Author}

{p 4}Joseph N. Luchman{p_end}
{p 4}Senior Scientist{p_end}
{p 4}Fors Marsh Group LLC{p_end}
{p 4}Arlington, VA{p_end}
{p 4}jluchman@forsmarshgroup.com{p_end}

{title:Also see}

{psee}
{manhelp mvreg R},
{manhelp canon R}.
{p_end}
