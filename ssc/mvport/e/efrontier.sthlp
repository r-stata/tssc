{smcl}
{* *! version 1.0.0  03may2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "gmvport" "help gmvportwo2"}{...}
{vieweralsosee "mvport" "help mvportwo2"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "simport" "help simport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "efrontier##syntax"}{...}
{viewerjumpto "Description" "efrontier##description"}{...}
{viewerjumpto "Options" "efrontier##options"}{...}
{viewerjumpto "Remarks" "efrontier##remarks"}{...}
{viewerjumpto "Examples" "efrontier##examples"}{...}
{viewerjumpto "Results" "efrontier##results"}{...}
{title:Title}

{phang}
{bf:efrontier} {hline 2} Calculates and makes a graph of efficient frontier financial portfolios given a set of stock returns.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt cmline} {varlist} {ifin} 
{cmd:} {it: [,options]} 

{synoptset 25 tabbed}{...}

{synopthdr}
{synoptline}
{synopt :{opt nport(#)}}number of portfolios along the efficient frontier to be computed. The default is 100.{p_end}
{synopt :{opt case:wise}}Specifies casewise deletion of observations. If casewise is specified, then expected returns and variance-covariance matrix are 
computed using only the observations that have nonmissing values for all variables in varlist. If casewise is not specified, 
then all possible data of the sample for all variables will be used to compute the expected returns and variance-covariance matrix.
The default is to use all the nonmissing values for each variable.{p_end}
{synopt :{opt min:weight(#)}}Specifies the minimum weight to be allowed for all instruments. {p_end}
{synopt :{opt rmin:weights}}In case of specific restrictions of minimum weights for each instrument or return, a list of minimum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, zero is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt max:weight}}Specifies the maximum weight to be allowed for all instruments.{p_end}
{synopt :{opt rmax:weights}}In case of specific restrictions of maximum weights for each instrument or return, a list of maximum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, 1 is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt covm:atrix(cov_matrix)}}If cov_matrix exists and has the right dimension according to the number of variables, instead of calculating the variance-covariance
matrix, then the cov_matrix will be used as the variance-covariance matrix to estimate the efficient frontier.{p_end}
{synopt :{opt mr:ets(ret_matrix)}}If ret_matrix exists and has the right dimension according to the number of variables, instead of calculating the expected returns of the
assets, then the ret_matrix will be used as the vector of expected returns to estimate the efficient frontier.{p_end}
{synopt :{opt nog:raph}}If nograph is specified, then the Capital Market Line will not be graphed. {p_end}
{synopt :{opt allf:ront}}If allfront is specified, then all the frontier will be calculated (efficient and not efficient frontier will be calculated). {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:efrontier} calculates and graph the efficient frontier of different financial portfolio configurations formed with the stock/bond returns specified in the   
{varlist}. The {varlist} must be a list of continuously compounded returns of financial instruments to be considered for the portfolio. 
The efficient frontier starts with the global minimum variance portfolio and continues with all portfolio combinations that minimize portfolio variance 
given specific incremental values of expected portfolio return.
The option nport specifies the the number of different portfolios to be calculated along the efficient frontier. 


{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.
The return variables must be continuously compounded returns, not simple returns. 

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Calculates the efficient frontier with the continuously compounded returns, and creates 100 portfolios along the efficient frontier: {p_end}
{phang}{cmd:. efrontier r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM}, nport(100){p_end}

     {hline}
	 
{pstd} Calculates the efficient frontier restricting periods starting from Jan 2013. The default value for the number of portfolios (100) will be used:{p_end}
{phang}{cmd:. efrontier r_* if period>=tm(2013m1)} {p_end}

{pstd} Calculates the efficient frontier restricting the weights to be at least 10% for all instruments:{p_end}
{phang}{cmd:. efrontier r_* , minweight(0.10)}{p_end}

{pstd} Calculates the efficient frontier restricting the weights to be less or equal to 30% :{p_end}
{phang}{cmd:. efrontier r_* , maxweight(0.30)}{p_end}

{pstd} Calculates the efficient frontier restricting the weights to be less or equal to 30% and greater or equal to 10%:{p_end}
{phang}{cmd:. efrontier r_* , maxw(0.35) minw(0.05)}{p_end}

{pstd} Calculates the efficient frontier with different minimum weights for each instrument:{p_end}
{phang}{cmd:. efrontier r_* , rminweights(0 0.1 0.1 0 0.16 0)}{p_end}
{pstd} Negative minimum weights for each instrument can also be specified.{p_end}

{pstd} Calculates the efficient frontier with different maximum weights for each instrument:{p_end}
{phang}{cmd:. efrontier r_* , rmaxweights(0.5 0.5 0.4 0.4 0.25 0.15)}{p_end}

     {hline}

{pstd} Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:{p_end}
{phang}{cmd:. meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)}{p_end}
{pstd} Saving the matrix of expected returns in a vector:{p_end}
{phang}{cmd:. matrix mrets=r(meanrets)}{p_end}

{pstd} Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:{p_end}
{phang}{cmd:. varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)}{p_end}
{pstd} Saving the variance-covariance matrix in a local matrix:{p_end}
{phang}{cmd:. matrix cov=r(cov)}{p_end}

{pstd} Calculates the efficient frontier using the calculated expected returns and variance-covariance matrix using the EWMA method:{p_end}
{phang}{cmd:. efrontier r_AAPL r_MSFT r_GE r_GM, covm(cov) mrets(mrets)}{p_end}
{pstd} Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.{p_end}

{pstd} Store stock weights, standard deviation and expected return of the 50 portfolios that lie on the efficient frontier (using Stata matrices): {p_end}
{phang}{cmd:. matrix port_weighs_no_shorting=r(wefwos)}{p_end}
{phang}{cmd:. matrix port_weighs_shorting=r(wefws)}{p_end}
{phang}{cmd:. matrix port_std_dev_no_shorting=r(sdefwos)} {p_end}
{phang}{cmd:. matrix port_std_dev_shorting=r(sdefws)} {p_end}
{phang}{cmd:. matrix port_expected_ret_no_shorting=r(refwos)}{p_end}
{phang}{cmd:. matrix port_expected_ret_shorting=r(refws)}{p_end}

{pstd} For both cases, with and without short sales, store weights, standard deviation and expected returns of portfolios in a matrix: {p_end}
{phang}{cmd:. matrix port_no_shorting = port_weighs_no_shorting, port_std_dev_no_shorting, port_expected_ret_no_shorting} {p_end}
{phang}{cmd:. matrix port_shorting = port_weighs_shorting, port_std_dev_shorting, port_expected_ret_shorting} {p_end}

{pstd} Write both matrices to an Excel Workbook (efrontier.xls) in 2 sheets using the user command xml_tab (you must have the xml_tab command installed): {p_end}
{phang}{cmd:. xml_tab port_no_shorting using "efrontier.xls", replace sheet("Port-NO short sells") format ((S3120) (N1118)) title(Efficient Frontier Portfolios without allowing for short sales)}{p_end}
{phang}{cmd:. xml_tab port_shorting using "efrontier.xls", append sheet("Port-short sells") format ((S3120) (N1118)) title(Efficient Frontier Portfolios allowing for short sales)}{p_end}

     {hline}
	 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:efrontier} stores results in {cmd:r()} in the following matrices/vectors:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N):}}Observations used for the computations {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(exprets): }} (n x 1) expected returns of each return serie or variable (n variables) {p_end}
{synopt:{cmd:r(cov): }} (n x n) variance-covariance matrix of returns {p_end}
{synopt:{cmd:r(sdefws): }} (nport x 1) vector of expected standard deviation of each portfolio in the frontier constructed when allowing short sells {p_end}
{synopt:{cmd:r(sdefwos): }} (nport x 1) vector of expected standard deviation of each portfolio in the frontier constructed without allowing short sells or when specifying specific minimum weights for the instruments{p_end}
{synopt:{cmd:r(refws): }} (nport x 1) vector of expected return of each portfolio in the frontier constructed when allowing short sells {p_end}
{synopt:{cmd:r(refwos):}} (nport x 1) vector of expected return of each portfolio in the frontier constructed without allowing short sells or when specifying specific minimum weights for the instruments{p_end}
{synopt:{cmd:r(wefws): }} (nport x n) matrix (or set of nport horizontal vectors) of portfolio weights for each of the nport portfolios in the frontier when allowing short sells {p_end}
{synopt:{cmd:r(wefwos): }} (nport x n) matrix (or set of nport horizontal vectors) of portfolio weights for each of the nport portfolios in the frontier without allowing short sales or when specifying specific minimum weights for the instruments{p_end}

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
