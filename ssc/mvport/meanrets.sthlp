{smcl}
{* *! version 1.0.0  23jun2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "meanrets##syntax"}{...}
{viewerjumpto "Description" "meanrets##description"}{...}
{viewerjumpto "Options" "meanrets##options"}{...}
{viewerjumpto "Remarks" "meanrets##remarks"}{...}
{viewerjumpto "Examples" "meanrets##examples"}{...}
{viewerjumpto "Results" "meanrets##results"}{...}
{title:Title}

{phang}
{bf:meanrets} {hline 2} Calculates the expected simple return of a series of financial returns. 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt meanrets} {varlist} {ifin} 
{cmd:} {it:[,options]} 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt simple:return}}if {it:simplereturn} is specified then {varlist} is expected to be a list of simple returns. If {it:simplereturn} is not specified, 
{varlist} is expected to be a list of continuously compounded returns.{p_end}
{synopt :{opt we:ightvar(varname)}}if this option is specified, then the variable {it:varname} will be used as the specific weights for each observations, which
will be used to compute the expected returns of the variables specified in {varlist}.{p_end}
{synopt :{opt lew:eight(#)}}indicates the {it:lamda} value to be used to calculate weights for all observations according to the exponentially 
weighted moving average (EWMA) method. The values for lamda must be greater than 0 and less than 1. (1-lamda) will be the initial weight for the 
more recent observation, while the lamda value will be exponentially assigned to all other observations. The weights will decay 
exponentially for old observations, so the most recent observations will have more weight for the calculation of the expected return. 
See Alexander(2008) for details of the EWMA method. If the options {it:weightvar(varname)} and {it:leweight(#)} are not used, then equal weights will be used for each observation.{p_end}
{synopt :{opt case:wise}}if {it:casewise} is specified then observations with at least one missing value will be deleted (casewise deletion). 
If {it:casewise} is not specified, then the missing values will be dropped variable by variable (not casewise deletion).{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:meanrets} calculates the expected simple return given a set of financial instrument or returns specified in 
{varlist}. The {varlist} is expected to be list of continuously compounded returns. If the option {it:simplereturn} is specified, then the 
{varlist} must be simple returns. The expected mean return can be calculated assigning weights for each period/observation. 
With the {it:leweight(#)} option, weights for each period are generated according to the EWMA method, and these weights are used 
to calculate the expected returns. If the {it:weightvar(varname)} is used, then the an existing variable can be used to weight 
each period/observation and then estimate the expected mean return.
When weight options are not used, the expected simple return is calculated as the geometric return of the simple historical returns.

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.
If the leweight(#) and the weightvar(varname) options are specified, the command will ONLY consider the leweight option. 

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Calculates the expected simple returns from continuously compounded (cc) return variables: {p_end}
{phang}{cmd:. meanrets r_AAPL r_MSFT r_GE}{p_end}

{pstd} Calculates the expected simple returns from simple return variables: {p_end}
{phang}{cmd:. meanrets R_AAPL R_MSFT R_GE, simplereturn}{p_end}

{pstd} Calculates the expected simple returns from cc return variables, and using the exponentially weighted moving average method with a lamda=0.94: {p_end}
{phang}{cmd:. meanrets r_AAPL r_MSFT r_GE, leweight(0.94)}{p_end}
{pstd} The weights for each observation according to the EWMA method were stored in the r(W) matrix. The weights are adjusted so that the sum of all weights must be equal to one. {p_end}
{phang}{cmd:. matrix list r(W)}{p_end}

{pstd} Calculates the expected simple returns from cc return variables. An existing variable is used to weight each observation to compute a weighted average: {p_end}
{phang}{cmd:. meanrets r_AAPL r_MSFT r_GE, weightvar(vol_MSFT)}{p_end}


     {hline}
	 
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:meanrets} saves results in {cmd:r()} in the following scalars, matrices/vectors:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N): }} number of observations used for computations{p_end}
{synopt:{cmd:r(numvar): }}  number of variables or return series used {p_end}
{synopt:{cmd:r(maxret): }} maximum expected return of the series{p_end}
{synopt:{cmd:r(minret): }} minimum expected return of the series{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(meanrets): }} (n x 1) vector of expected simple returns for each return series {p_end}
{synopt:{cmd:r(W): }} (n x 1) vector of weights used to compute the expected simple returns {p_end}

{p2colreset}{...}


{title:References:}

Alexander, Carol (2008): Moving Average Models for Volatility and Correlation, and Covariance Matrices. Handbook of Finance. III:5:62.

{title:Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
