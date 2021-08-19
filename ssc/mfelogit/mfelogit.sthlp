{smcl}
{* *! version 1  2021-07-01}{...}
{viewerjumpto "Syntax" "mfelogit##syntax"}{...}
{viewerjumpto "Description" "mfelogit##description"}{...}
{viewerjumpto "Options" "mfelogit##options"}{...}
{viewerjumpto "Examples" "mfelogit##examples"}{...}
{viewerjumpto "Saved results" "mfelogit##saved_results"}{...}

{title:Title}

{p 4 8}{cmd:mfelogit} {hline 2} Estimation of average marginal effects (AME) and average treatment effects (ATE) in fixed effect logit models.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:mfelogit varlist} {ifin} 
{cmd:id(}{it:string}{cmd:)}
{cmd:time(}{it:string}{cmd:)}
[{cmd:,} 
{cmd:method(}{it:string}{cmd:)}
{cmd:listT(}{it:string}{cmd:)}
{cmd:listX(}{it:string}{cmd:)}
{cmd:level(}{it:string}{cmd:)}
{cmd:eps(}{it:string}{cmd:)}
{cmd:ratio(}{it:string}{cmd:)}]{p_end}

{synoptset 28 tabbed}{...}

{marker description}{...}
{title:Description}

{p 4 4}{cmd:mfelogit} implements the estimators of the sharp bounds on the AME and the related confidence intervals on the AME and ATE from Davezies et al. (DDL hereafter). 
It also implements the second method proposed in DDL, which is faster to compute but may result in larger confidence intervals. When the covariate is binary, the command computes the ATE; otherwise it computes the AME. {p_end}

{p 4 4}{cmd:id} specifies the variable used as identifier for the individuals. {p_end}

{p 4 4}{cmd:time} specifies the variable used as identifier for the different periods. {p_end}

{marker options}{...}
{title:Options}

{p 4 8}  {cmd:method}  specifies the method used. Its argument must be one of: "sharp" or "quick" (the default). 
Argument "sharp" stands for the first method in DDL. 
Argument "quick" stands for the second method in DLL, which is faster. 
Note that only the second "quick" method is available for the ATE. {p_end}

{p 4 8}  {cmd:listT}  specifies at which period the AME/ATE is computed, see Section 5.4 in DDL. It can take the following values:
1) if empty, then the AME/ATE is computed at the last period at which all individuals in the sample are observed. It is indexed by "Tinf" in the final output table. It is the default option; 2) 
if a a list with elements in 1 to the maximal number of observed periods is provided, then for each value in this list, 
we compute the AME/ATE at the corresponding periods for all the selected covariates. In the final output table the column "T" recalls the values of the periods.
3) if "all": this computes the AME/ATE for all the observed periods similarly to the case above, plus the average over all the periods. 
This last case is indexed by "Average" in the final output table.  {p_end}


{p 4 8}  {cmd:listX} specifies the list of the selected variables for which the AME/ATE is computed. By default, the AME/ATE is computed for all covariates.
 Default is to compute it for all.   {p_end}


{p 4 8}  {cmd:level} sets the value of the level of the confidence intervals (by default, 0.95).   {p_end}


{p 4 8}  {cmd:eps} specifies the type of confidence interval selected for the first method. 
It can be empty, in which case we use CI2, as defined in DDL. If set to a given value different from 0, then CI3 is used with this value for epsilon.
 Finally, if set to 0, then CI3 is used with epsilon= ln(ln(n)).  {p_end}


{p 4 8}  {cmd:ratio} sets the value of the bias/variance ratio in the nonparametric estimator of the first method in DDL (see their Appendix C for more details). The default value is 10.  {p_end}


{hline}

{marker Table}{...}
{title:Table}

{p 4 4} the command mfelogit returns two tables with the results of the CMLE estimation and the DDL bounds on the AME/ATE.  {p_end}


{marker saved_results}{...}
{title:Saved results}

{p 4 8} {cmd:mfelogit} saves the following in {cmd:e()}:

{p 4 8} {cmd:e(ndiscard)}, {cmd:e(n)}, and {cmd:e(maxT)} refer respectively to the number of observations, discarded observations, and maximal number of observed periods among all the individuals. {p_end}

{p 4 8} The matrices {cmd:e(mat_results_CMLE)} and {cmd:e(mat_results)} refer respectively to the results of the CMLE estimation and the DDL bounds on the AME/ATE. {p_end}

{p 4 8}  Finally, the macros  {cmd:e(alpha_rep)} and  {cmd:e(vardiscard)} save the contents of the footnotes of the tables describing the level used for the confidence intervals and the names of the discarded variables.  {cmd:e(cmd_arguments)} contains the mfelogit arguments. {p_end}

{hline}

{marker Example}{...}
{title:Example: Average marginal effect of age on union membership using panel data.}

{p 4 8}ssc install mfelogit{p_end}
{p 4 8}use "https://www.stata-press.com/data/r17/union.dta", clear{p_end}
{p 4 8}mfelogit union age  black if (year <=78), id("idcode") time("year") method("quick"){p_end}

{hline}

{title:References}

{p 4 8} Davezies L, D’Haultfoeuille X, Laage L (2021).
{browse "https://arxiv.org/abs/2105.00879":Identification and Estimation of average marginal effects infixed effect logit models}.{p_end}


{title:Authors}

{p 4 8} Laurent Davezies,  CREST, Palaiseau, France.
{browse "laurent.davezies@ensae.fr":laurent.davezies@ensae.fr}.{p_end}
{p 4 8} Xavier D'Haultfoeuille, CREST, Palaiseau, France.
{browse "mailto:xavier.dhaultfoeuille@ensae.fr":xavier.dhaultfoeuille@ensae.fr}.{p_end}
{p 4 8} Christophe Gaillac, CREST, Palaiseau, France.
{browse "mailto:christophe.gaillac@ensae.fr":christophe.gaillac@ensae.fr}.{p_end}
{p 4 8} Louise Laage, Georgetown University, Washington, USA.
{browse "mailto:louise.laage@georgetown.edu":louise.laage@georgetown.edu}.{p_end}

