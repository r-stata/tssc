{smcl}
{* *! version 1.0.0  10-05-2019}{...}
{viewerjumpto "Data" "rdexo##data"}{...}
{viewerjumpto "Syntax" "rdexo##syntax"}{...}
{viewerjumpto "Examples" "rdexo##examples"}{...}

{title:Title}

{p 4 8}{cmd:xtpsse} {hline 2} runs a conditional fixed-effects Poisson panel regression, computes sandwich and spatial standard errors, and tests for time-invariant spatial
dependence according to Bertanha and Moser (2016).{p_end}


{marker data}{...}
{title:Data}

{p 4 8}You need to have a panel dataset with one dependent count data variable and explanatory variables,
besides coordinate information on how cross-section units are located in the R^2 space.
You also need a cross section ID variable and a time variable for your panel. You may either specify the panel using 
the {cmd:xtset} <panelvar> <timevar> before you run {cmd:xtpsse}, or your can specify these directly through the i() and t() options.
If you do not have coordinate variables but have information on how far apart observations are, you may want to use commands like {cmd:mdsmat} and {cmd:mds} to generate coordinate variables.{p_end} 


{marker syntax}{...}
{title:Syntax}

{p 4 8}{cmd:xtpsse } {it:varlist(numeric)} {ifin} 
{cmd:,} 
COORDinates(varlist)
CUToffs(numlist >0)
[I(varname)]
[T(varname)]
[TEst(integer)]

{p 4 8} where capital letters indicate how you can abbreviate option names.{p_end}


{p 8 12}{cmd:varlist}: (required)  enter the list of variables you want to regress, starting by the dependent variable. 
You can use abbreviation rules like time_dum* or class1-class20, but only variables that contain numeric values are allowed.
Variables that are constant across time are not allowed. {p_end}

{p 8 12}{cmd:[if]} or {cmd:[in]}: (optional) like in any other STATA command, to restrict the sample you want to obtain your estimates from. {p_end}


{p 8 12}{cmd:coordinates(varlist)} or {cmd:coord(varlist)}: (required) enter the two variable names that contain the coordinates.
E.g. you could have coordx and coordy as variables names. The coordinate variables should 
contain numeric real values only, they vary across i but are constant across t, and they should be non-missing for all (i,t) observations.

 

{p 8 12}{cmd:cutoffs(numlist) or cut(numlist)}: (required) max. distance along each coordinate (x,y) that defines neighborhood of a
cross-sectional unit; this is used to compute the spatial standard error estimates; cross-sectional units are located on R^2 space,
so an example of cutoff would be cut(100.5 123). Cutoffs should be strictly positive.{p_end}

 
{p 8 12}{cmd:i(varname)}: (optional only if you use {cmd:xtset} before {cmd:xtpsse}) specify which variable identifies cross-section units in your panel.
You either specify it through this option OR using {cmd:xtset} <panelvar> <timevar> command, before you run {cmd:xtpsse}.
Either way, you DO need to specify both a cross-section and time index variables before you run {cmd:xtpsse}.{p_end}


{p 8 12}{cmd:t(varname)}: (optional only if you use {cmd:xtset} before {cmd:xtpsse}) specify which variable identifies time units in your panel.
You either specify it through this option OR using {cmd:xtset} <panelvar> <timevar> command, before you run {cmd:xtpsse}.
Either way, you DO need to specify both a cross-section and time index variables before you run {cmd:xtpsse}.{p_end}


{p 8 12}{cmd:test(integer) or te(integer)}: (optional) integer should be between 0 to K, where K is the number of explanatory variables.
If option test is not inputted, the default value for this option is test(K); 
if option test is inputted with integer=0, 
the code does not compute the test-statistic; 
if option test is inputted with integer>0, the code does compute the test-statistic, and will use at most
the first 'integer' elements of the score vector to construct the test-statistic. 
If 'integer' is too large compared to the number of observations, the Jacobian or variance-covariance matrices may be singular.
In this case, the code will automatically reduce the number of score
elements being used in order to have invertible matrices.
The number of spatial lags (used to calculate averages of spatially lagged score functions) is fixed at the 'cutoff' values;
the cutoff value for computing the spatial covariance matrix of the estimated vector of coefficients 'Theta' is fixed at twice the value of 'cutoff'.{p_end}


{marker examples}{...}
{title:Examples}

 
{p 4 8}(1){p_end}
{p 8 8}{cmd:. xtset cross_id year}{p_end}
{p 8 8}{cmd:. xtpsse y x1-x50 age* if year<2000, coord(xcoord ycoord) cut(1000 2000)}{p_end} 

{p 4 8}(2){p_end}
{p 8 8}{cmd:. xtpsse y x1-x50 age* if year<2000, coord(xcoord ycoord) cut(1000 2000) i(cross_id) t(year)}{p_end} 

{p 4 8}(3){p_end}
{p 8 8}{cmd:. xtpsse y x1-x50 age* if year<2000, coord(xcoord ycoord) cut(1000 2000) i(cross_id) t(year) te(0)}{p_end} 

{p 4 8}(4){p_end}
{p 8 8}{cmd:. xtpsse y x1 x2 x3, coord(xcoord ycoord) cut(1000 2000) i(cross_id) t(year) te(3)}{p_end} 




{title:Reference}

{p 4 8}Bertanha, M., and Moser, Petra. (2016),
Spatial Errors in Count Data Regressions.
{it:Journal of Econometric Methods} 5(1), Jan 2016, pg 49-69. 







