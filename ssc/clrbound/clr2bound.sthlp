{smcl}
{* *! version 1.0.0 30jul2013}{...}
{cmd:help clr2bound}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:clr2bound} {hline 2}}Compute two-sided bound estimates using Bonferroni's inequality{p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmdab:clr2:bound ((}{it:lowerdepvar1 indepvars1 range1})
	( {it: lowerdepvar2 indepvars2 range2} ) ...
	( {it: lowerdepvarN indepvarsN rangeN} ))
	(( {it: upperdepvarN+1 indepvarsN+1 rangeN+1} )
	( {it: upperdepvarN+2 indepvarsN+2 rangeN+2} ) ...
	( {it: upperdepvarN+M indepvarsN+M rangeN+M} ))
	{ifin}
	[{cmd:,}
	{cmdab:met:hod(}"series"|"local"{cmd:)}
	{cmd:notest}
	{cmd:null(}{it:real}{cmd:)}
	{cmdab:lev:el(}{it:numlist}{cmd:)}
	{cmd:noais}
	{cmdab:mins:mooth(#)}
	{cmdab:maxs:mooth(#)}
	{cmdab:nounders:mooth}
	{cmdab:band:width(}{it:numlist}{cmd:)}
	{cmd:rnd(#)}
	{cmd:norseed}
	{cmdab:se:ed(#)}
	]	

{title:Description}

{pstd}{cmd:clr2bound} estimates two-sided intersection bounds of a parameter.
The variables called {it:lowerdepvar1}...{it:lowerdepvarN} are the dependent variables for the lower bounding functions
and the {it:upperdepvarN+1}...{it:upperdepvarN+M} are the dependent variables for the upper bounding functions, respectively.
The variables {it:indepvars1}...{it:lowerdepvarN+M} in the syntax refer to explanatory variables for the corresponding dependent variables.
Recall that {cmd:clr2bound} allows for multidimensional {it:indepvars} for parametric estimation, but only for a one dimensional independent variable for series and local linear estimation.{p_end}

{pstd}The variables {it:range1}...{it:rangeN+M} are sets of grid points over which the bounding function is estimated. The number of observations for the {it:range} is not necessary the same as
the number of observations for the {it:depvar} and {it:indepvars}. The latter is the sample size, whereas the former is the number of grid points to evaluate the maximum or minimum values of the bounding functions.{p_end}

{pstd}It should be noted that the parentheses must be used properly. Variables for lower bounds and upper bounds must be put in additional parentheses separately. For example, if there are two variable sets, ({it:ldepvar1} {it:indepvars1} 
{it:range1}) and ({it:ldepvar2 indepvars2 range2}), for the lower bounds estimation and one variable set, ({it:udepvar1 indepvars3 range3}), for the upper bounds estimation, the right syntax for two-sided intersection bounds estimation is 
(({it:ldepvar1 indepvars1 range1})({it:ldepvar2 indepvars2 range2}))(({it:udepvar1 indepvars3 range3})).{p_end}

{pstd}The {cmd:clr2bound} requires the package {cmd:moremata}. A user can install this package by typing {cmd:ssc install moremata, replace} in the Stata command window; see {help moremata}.{p_end}

{title:Options}

{phang}{opt method(string)} specifies the method of estimation. By default, {cmd:clr2bound} will conduct parametric estimation. Specifying {opt method("series")}, {cmd:clr2bound} will conduct series estimation with cubic B-splines. Specifying 
{opt method("local")}, will result in local linear estimation.

{phang}{opt notest} determines whether {cmd:clr2bound} conducts a test or not. {cmd:clr2bound} provides a test for the null hypothesis that the specified value is in the intersection bounds at the confidence levels specified in the {opt level} 
option below. By default, {cmd:clr2bound} conducts the test. Specifying this option causes {cmd:clr2bound} to output Bonferroni bounds only.

{phang}{opt null(real)} specifies the value for the parameter under the null hypothesis of the test we described above. The default value is {opt null(0)}. 

{phang}{opt level(numlist)} specifies confidence levels. {it:numlist} has to be filled with real numbers between 0 and 1. In particular, if this option is specified as {opt level(0.5)}, the result is the half-median-unbiased estimator of the parameter of the interest. The default is {opt level(0.5 0.9 0.95 0.99)}. 

{phang}{opt noais} determines whether the adaptive inequality selection would be applied or not. The adaptive inequality selection (AIS) helps to get sharper bounds by using the problem-dependent cutoff to drop irrelevant grid points of the 
{it:range}. The default is to use AIS.

{phang}{opt minsmooth(#)} and
{opt maxsmooth(#)}
specify the minimum and maximum possible numbers of approximating functions considered in the cross validation procedure for B-splines.
Specifically, the number of approximating functions is set to the minimizer of the leave-one-out least squares cross validation score within this range.
For example, if a user inputs {opt minsmooth(5)} and {opt maxsmooth(9)}, the number of approximating functions is chosen from the set {c -(}5,6,7,8,9{c )-}.
The procedure calculates this number separately for each inequality. The default is {opt minsmooth(5)} and {opt maxsmooth(20)}. If under-smoothing is performed, the number of approximating functions ultimately used will be given by the largest integer smaller than ( the number of approximating functions times the under-smoothing factor ), see option {opt noundersmooth} below. This option is only available for series estimation. 

{phang}{opt bandwidth(#)} specifies the value of the bandwidth used in the local linear estimation. By default, {cmd:clr2bound} calculates a bandwidth for each inequality. With undersmoothing, we use the rule of thumb bandwidth When the {opt bandwidth(#)} is specified, {cmd:clr2bound} uses the given bandwidth as the global bandwidth for every inequality. This option is only available for local linear estimation.

{phang}{opt noundersmooth} determines whether under-smoothing is carried out, with the default being to under-smooth. In series estimation, under-smoothing is implemented by first computing the number of approximating functions as the minimizer of the leave-one-out least squares cross validation score. The {opt noundersmooth} option simply uses this number. Without this option, we then set the number of approximating functions to K, given by the largest integer which is smaller than or equal to ( the number of approximating functions times n^1/5 times n^-2/7. For local linear estimation under-smoothing is done by using the bandwidth which is multiplied by n^1/5 times n^-2/7 from origianl bandwith. This option is only available for series and local linear estimation.

{phang}{opt rnd(#)} specifies the number of columns of the random matrix generated from the standard normal distribution. This matrix is used for computation of critical values. For example, if the number is 10000 and the level is 0.95, we choose the 0.95 quantile from 10000 randomly generated elements. The default is {opt rnd(10000)}.

{phang}{opt norseed} determines whether the seed number for the simulation used in the calculation would be reset. If a user wants to use this command for simulations such as Monte Carlo method, he can prevent the command from resetting the seed number every lap by using this option. The default is to reset the seed number.

{phang}{opt seed(#)} specifies the seed number for the random number generation described above. To prevent the estimation result from changing one particular values to another randomly, {cmd:clr2bound} always conducts {opt set seed #} initially. 
The default is {opt seed(0)}. 
