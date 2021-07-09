{smcl}
{* *! version 1.0.0  03may2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}


{viewerjumpto "Syntax" "simport##syntax"}{...}
{viewerjumpto "Description" "simport##description"}{...}
{viewerjumpto "Options" "simport##options"}{...}
{viewerjumpto "Remarks" "simport##remarks"}{...}
{viewerjumpto "Examples" "simport##examples"}{...}
{title:Title}

{phang}
{bf:simport} {hline 2} Simulates and makes a graph of random portfolios with non-negative weights given a set of stock returns.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt simport} {varlist} {ifin} 
{cmd:,} {it:nport(#)} [CASEwise] 


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt nport(#)}}number of portfolios inside the efficient frontier to be computed{p_end}
{synopt :{opt case:wise}}specifies casewise deletion of observations.  Expected returns and var-cov matrix are to be computed for the sample that is not missing for any of the variables in varlist.  
The default is to use all the nonmissing values for each variable. {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:simport} generates and graph random portfolios formed with the stock/bond returns specified in the   
{varlist}. The {varlist} must be a list of continuously compounded returns of financial instruments to be considered for the portfolio. 
It is recommended to use this command with no more than 8 stock returns and no more than 6,000 portfolios. If more returns or portoflios are specified, 
the command will take considerable time to generate all portfolios. 
The option nport specifies the the number of different portfolios to be generated inside the efficient frontier. The option nport must be specified.

{marker remarks}{...}
{title:Remarks}

{pstd}
This command needs the installation of the following commands: meanrets and varrets. Check the "Also See" Menu.
The return variables must be continuously compounded returns, not simple returns. 

{marker examples}{...}
{title:Examples}

    {hline}
	
	{pstd} Collects online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE GM WMT, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Generates 6,000 random portfolios inside the efficient frontier using 4 continuously compounded returns: {p_end}
{phang}{cmd:. simport r_AAPL r_MSFT r_GE r_GM, nport(6000)}{p_end}

{pstd} Generates 4,000 random portfolios inside the efficient frontier using the 5 continuously componded returns of the dataset, and excluding observations if a missing value is found: {p_end}
{phang}{cmd:. simport r_*, nport(4000) casewise}{p_end}

     {hline}
	 
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:simport} dos not store results in {cmd:r()} 


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
