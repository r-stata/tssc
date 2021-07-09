{smcl}
{* *! version 1.0.0 30jul2013}{...}
{cmd:help clrtest}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:clrtest} {hline 2}}Test the hypothesis that the maximum of lower intersection bounds is nonpositive{p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmd:clrtest (}{it:depvar1 indepvars1 range1})
	( {it: depvar2 indepvars2 range2} ) ...
	( {it: depvarN indepvarsN rangeN} )
	{ifin}
	[{cmd:,}
	{cmdab:low:er} | {cmdab:upp:er}
	{cmdab:met:hod(}"series"|"local"{cmd:)}
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

{pstd}{cmd:clrtest} offers a more comprehensive testing procedure than the {cmd:clr2bound} does. 
It returns the output telling whether the result of the lower intersection bound estimation deducted from the given {it:depvar}'s and confidence levels is smaller than 0 or not. 
For example, suppose that one wants to test the null hypothesis that 0.59 is in the 95% confidence interval for {it:yl} and {it:yu}. 
Then, we can make two inequalities, {cmd:yl_test = yl - 0.59} and {cmd:yu_test = 0.59 - yu}. 
If the resulting estimator is larger than 0, the procedure rejects the null hypothesis.
The variables are defined similarly as in the {cmd:clr2bound}; see {help clr2bound}.
The {cmd:clrtest} requires the package {cmd:moremata}.{p_end}

{title:Options}


{phang}{opt lower} specifies whether the estimation is for the lower bound or the upper bound. By default, it will return the upper intersection bound. Specifying {opt lower}, {cmd:clrbound} will return the lower intersection bound. 

{phang}{opt method(string)} specifies the method of estimation. By default, {cmd:clr2bound} will conduct parametric estimation. Specifying {opt method("series")}, {cmd:clr2bound} will conduct series estimation with cubic B-splines. Specifying 
{opt method("local")}, will result in local linear estimation.

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
