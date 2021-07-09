{smcl}
{* *! version 1.0.0 30jul2013}{...}
{cmd:help clr3bound}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:clr3bound} {hline 2}}Compute two-sided bound estimates by inverting {cmd:clrtest}{p_end}
{p2colreset}{...}

{title:Syntax}
{p 8 17 2}
{cmdab:clr3:bound ((}{it:lowerdepvar1 indepvars1 range1})
	( {it: lowerdepvar2 indepvars2 range2} ) ...
	( {it: lowerdepvarN indepvarsN rangeN} ))
	(( {it: upperdepvarN+1 indepvarsN+1 rangeN+1} )
	( {it: upperdepvarN+2 indepvarsN+2 rangeN+2} ) ...
	( {it: upperdepvarN+M indepvarsN+M rangeN+M} ))
	{ifin}
	[{cmd:,}
	{cmdab:step:size(#)}
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

{pstd}{cmd:clr3bound} estimates the two-sided intersection bound of a parameter
by carrying out pointwise tests using the {cmd:clrtest} command.
Note that when one-sided intersection bounds are concerned,
there is no need to implement pointwise tests. In this case, the command {cmd:clrbound} estimates tight bounds.{p_end}

{pstd}Since this command is only relevant for two-sided intersection bounds, a user should input variables for both lower and upper bounds to calculate the bound. The variables are defined similarly as in the {cmd:clr2bound}. This command generally provides tighter bounds than
those provided by the {cmd:clrtest} command over equi-spaced grids, which employ Bonferroni's inequality.
Unlike the previous commands, {cmd:clr3bound} can only deal with one confidence level.
The {cmd:clr3bound} requires package {cmd:moremata}; see {help moremata}.{p_end}

{title:Options}

{phang}{opt stepsize(#)} specifies the distance between two consecutive grid points.
The procedure divides Bonferroni's bound into equi-distanced grids and
implements  the {cmd:clrtest} command for each grid point to determine a possible tighter bound.
The default is {opt stepsize(0.01)}.

{phang}{opt method(string)} specifies the method of estimation. By default, {cmd:clr2bound} will conduct parametric estimation. Specifying {opt method("series")}, {cmd:clr2bound} will conduct series estimation with cubic B-splines. Specifying 
{opt method("local")}, will result in local linear estimation.

{phang}{opt notest} determines whether {cmd:clr2bound} conducts a test or not. {cmd:clr2bound} provides a test for the null hypothesis that the specified value is in the intersection bounds at the confidence levels specified in the {opt level} 
option below. By default, {cmd:clr2bound} conducts the test. Specifying this option causes {cmd:clr2bound} to output Bonferroni bounds only.

{phang}{opt null(real)} specifies the value for the parameter under the null hypothesis of the test we described above. The default value is {opt null(0)}. 

{phang}{opt level(#)} specifies the confidence level of the estimation. Different from previous commands, {cmd:clr3bound} can only deal with one confidence level. The default is {opt level(0.95)}. 

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
