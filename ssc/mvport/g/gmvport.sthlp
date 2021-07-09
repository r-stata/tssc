{smcl}
{* *! version 1.0.0  03may2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "gmvport##syntax"}{...}
{viewerjumpto "Description" "gmvport##description"}{...}
{viewerjumpto "Options" "gmvport##options"}{...}
{viewerjumpto "Remarks" "gmvport##remarks"}{...}
{viewerjumpto "Examples" "gmvport##examples"}{...}
{viewerjumpto "Results" "gmvport##results"}{...}
{title:Title}

{phang}
{bf:gmvport} {hline 2} Calculates the Global Minimum Variance financial portfolio given a set of financial returns (instruments). It also performs the risk decomposition of the portfolio according to its assets.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt gmvport} {varlist} {ifin} 
{cmd:} {it:[,options]} 

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt nos:hort}}Indicates that no short sales are allowed (no negative weights for the instruments). The default is to allow for short sales.{p_end}
{synopt :{opt case:wise}}Specifies casewise deletion of observations. Expected returns and var-cov matrix are 
to be computed for the sample that is not missing for any of the variables in varlist.
The default is to use all the nonmissing values for each variable.{p_end}
{synopt :{opt min:weight(#)}}Specifies the minimum weight to be allowed for all instruments. In case of specifying the noshort option, the default value for minweight is zero. {p_end}
{synopt :{opt rmin:weights}}In case of specific restrictions of minimum weights for each instrument or return, a list of minimum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, zero is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt max:weight}}Specifies the maximum weight to be allowed for all instruments.{p_end}
{synopt :{opt rmax:weights}}In case of specific restrictions of maximum weights for each instrument or return, a list of maximum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, 1 is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt covm:atrix(cov_matrix)}}If cov_matrix exists and has the right dimension according to the number of variables, instead of calculating the variance-covariance
matrix, then the cov_matrix will be used as the variance-covariance matrix to estimate the global minimum variance portfolio.{p_end}
{synopt :{opt mr:ets(ret_matrix)}}If ret_matrix exists and has the right dimension according to the number of variables, instead of calculating the expected returns of the
assets, then the ret_matrix will be used as the vector of expected returns to estimate the global minimum variance portfolio.{p_end}



{marker description}{...}
{title:Description}

{pstd}
{cmd:gmvport} calculates the global variance minimum financial portfolio given specific financial instrument returns specified in 
{varlist}. The {varlist} must be a list of continuously compounded returns of financial assets to be considered for the portfolio. This commands 
allows for different restrictions in terms of minimum and/or maximum values of asset weights. {it:gmvport} also performs the risk decomposition of the portfolio. 
It estimates the contribution to portfolio risk of each asset (see Stored results). 

{marker remarks}{...}
{title:Remarks}

{pstd}
This command needs the installation of the meanrets command. Check the "Also See" Menu for related commands.
The return variables must be continuously compounded returns, not simple returns. 
If a specific list of minimum weights for each financial return or instrument is specified, then the option minweight will not be used for computing the global minimum variance portfolio.
If a specific list of maximum weights for each financial return or instrument is specified, then the option maxweight will not be used for computing the global minimum variance portfolio.

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Calculates the global variance minimum portfolio using 6 continuously compounded returns, and allowing for short sales : {p_end}
{phang}{cmd:. gmvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM}{p_end}

{pstd} Calculates the global variance minimum portfolio using 6 continuously compounded returns, without allowing for short sales : {p_end}
{phang}{cmd:. gmvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, noshort}{p_end}

     {hline}

{pstd} Calculates the global variance minimum portfolio without allowing for short sales, restricting periods starting from Jan 2013:{p_end}
{phang}{cmd:. gmvport r_* if period>=tm(2013m1), noshort}{p_end}

{pstd} Calculates the global variance minimum portfolio restricting the weights to be at least 10% for all instruments:{p_end}
{phang}{cmd:. gmvport r_* , noshort minweight(0.10)}{p_end}

{pstd} Calculates the global variance minimum portfolio restricting the weights to be less or equal to 30% :{p_end}
{phang}{cmd:. gmvport r_* , noshort maxweight(0.30)}{p_end}

{pstd} Calculates the global variance minimum portfolio restricting the weights to be less or equal to 30% and greater or equal to 10%:{p_end}
{phang}{cmd:. gmvport r_* , noshort maxw(0.30) minw(0.10)}{p_end}

{pstd} Calculates the global variance minimum portfolio with different minimum weights for each instrument:{p_end}
{phang}{cmd:. gmvport r_* , rminweights(0 0.1 0.1 0 0.15 0)}{p_end}
{pstd} Negative minimum weights for each instrument can also be specified.{p_end}

{pstd} Calculates the global variance minimum portfolio with different maximum weights for each instrument:{p_end}
{phang}{cmd:. gmvport r_* , rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)}{p_end}

     {hline}

{pstd} Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:{p_end}
{phang}{cmd:. meanrets r_* , lew(0.94)}{p_end}
{pstd} Saving the matrix of expected returns in a vector:{p_end}
{phang}{cmd:. matrix mrets=r(meanrets)}{p_end}

{pstd} Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:{p_end}
{phang}{cmd:. varrets r_* , lew(0.94)}{p_end}
{pstd} Saving the variance-covariance matrix in a local matrix:{p_end}
{phang}{cmd:. matrix cov=r(cov)}{p_end}

{pstd} Calculates the global variance minimum portfolio using the calculated expected returns and variance-covariance matrix using the EWMA method:{p_end}
{phang}{cmd:. gmvport r_* , covm(cov) mrets(mrets)}{p_end}
{pstd} Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.{p_end}
	 
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:gmvport} saves results in {cmd:r()} in the following scalars, matrices/vectors:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N): }} number of observations used for computations{p_end}
{synopt:{cmd:r(varport): }} global minimum variance of the portfolio {p_end}
{synopt:{cmd:r(sdport): }} standard deviation of the global minimum variance portfolio {p_end}
{synopt:{cmd:r(retport): }} return of the global minimum variance portfolio {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(exprets): }} (n x 1) vector of expected simple returns for each return series {p_end}
{synopt:{cmd:r(cov): }} (n x n) variance-covariance matrix used for the optimization {p_end}
{synopt:{cmd:r(weights):}} (n x 1) weight vector of the global minimum variance portfolio{p_end}
{synopt:{cmd:r(mcr):}} (n x 1) Decomposition of risk: vector of asset marginal contributions to portfolio risk. 
   Risk decomposition is performed using the Euler's theorem, so the marginal contributions to risk is a set of partial derivatives of portfolio risk with respect to each asset weight.{p_end}
{synopt:{cmd:r(cr):}} (n x 1) Decomposition of risk: vector of asset contributions to portfolio risk. This is equal to the marginal contributions multiplied by its respective weights.
   The sum of the elements of this vector is equal to the portfolio risk (portfolio standard deviation). {p_end}
{synopt:{cmd:r(pcr):}} (n x 1) Decomposition of risk: vector of asset percent contributions to portfolio risk. This is equal to the contributions divided by portfolio risk.
   The sum of the elements of this vector is equal to one. {p_end}  
{synopt:{cmd:r(betas):}} (n x 1) vector of asset betas with respect to the portfolio. An asset beta is defined as the covariance between the asset returns and the portfolio returns divided by the portfolio variance. {p_end} 

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
