{smcl}
{* *! version 1.0.0  03may2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "simport" "help simport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "varrets##syntax"}{...}
{viewerjumpto "Description" "varrets##description"}{...}
{viewerjumpto "Options" "varrets##options"}{...}
{viewerjumpto "Remarks" "varrets##remarks"}{...}
{viewerjumpto "Examples" "varrets##examples"}{...}
{title:Title}

{phang}
{bf:varrets} {hline 2} Calculates the expected variance-covariance matrix of a series of financial returns. 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt varrets} {varlist} {ifin} 
{cmd:} {it:[,options]} 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt we:ightvar(varname)}}if this option is specified, then the variable {it:varname} will be used as the specific weights for each observations, which
will be used to compute the expected returns of the variables specified in {varlist}.{p_end}
{synopt :{opt lew:eight(#)}}indicates the {it:lamda} value to be used to calculate weights for all observations according to the exponentially 
weighted moving average (EWMA) method. The values for lamda must be greater than 0 and less than 1. (1-lamda) will be the initial weight for the 
more recent observation, while the lamda value will be exponentially assigned to all other observations. The weights will decay 
exponentially for old observations, so the most recent observations will have more weight for the calculation of the expected return. 
See Alexander(2008) for details of the EWMA method. If the options {it:weightvar(varname)} and {it:leweight(#)} are not used, then equal weights will be used for each observation.{p_end}
{synopt :{opt case:wise}}specifies casewise deletion of observations. The var-cov matrix is 
to be computed for the sample that is not missing for any of the variables in varlist.
If casewise is not specified, then all variances are computed independently, and the covariances are computed by pair of returns, so all possible return data is used.
If casewise is specified, then only observations with no missing values in all returns are be used to calculate the variance-covariance matrix.
The default is to use all the nonmissing values for each variable.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:varrets} calculates the expected variance-covariance matrix given a set of financial instrument or returns specified in 
{varlist}. The {varlist} must be a list of continuously compounded returns of financial instruments. 
Unlike the Stata {bf:correlate} command with the cov option, this command can calculate pairwise covariances when the casewise option is omitted. When the casewise option
is used, then this command calculates the same variance-covariance matrix than the Stata {bf:correlate} command with the cov option.
The expected variance-covariance matrix can be calculated assigning weights for each period/observation. With the {it:leweight(#)} option, 
weights for each period are generated according to the EWMA method, and these weights are used to calculate the expected variance-covariance matrix. 
If the {it:weightvar(varname)} is used, then the an existing variable is used to weight each period/observation and then estimate the
expected variance-covariance matrix.

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.
The return variables must be continuously compounded returns, not simple returns. 

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Calculates the expected variance-covariance matrix of 3 asset returns (continuously compounded): {p_end}
{phang}{cmd:. varrets r_AAPL r_MSFT r_GE}{p_end}

{pstd} Calculates the expected variance-covariance matrix of 3 asset returns assigning exponential weights for each observation according to the Exponential Weighted Moving Average method with a lamda=0.94: {p_end}
{phang}{cmd:. varrets r_AAPL r_MSFT r_GE}, leweight(0.94){p_end}
{pstd} The weights for each observation according to the EWMA method were stored in the r(W) matrix. The weights are adjusted so that the sum of all weights must be equal to one. {p_end}
{phang}{cmd:. matrix list r(W)}{p_end}

{pstd} Calculates the expected variance-covariance matrix of 3 asset returns using an existing variable to weight each observation: {p_end}
{phang}{cmd:. varrets r_AAPL r_MSFT r_GE}, weightvar(vol_AAPL){p_end}
     {hline}
	 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:varrets} saves results in {cmd:r()} in the following scalars, matrices/vectors:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N): }} number of observations used for computations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(cov): }} (n x n) matrix of expected variance-covariances of returns{p_end}
{synopt:{cmd:r(W): }} (n x 1) vector of weights assigned to each observation. These weights were used to compute the variance-covariance matrix{p_end}

{p2colreset}{...}

{title:References:}

Alexander, Carol (2008): Moving Average Models for Volatility and Correlation, and Covariance Matrices. Handbook of Finance. III:5:62.

{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
