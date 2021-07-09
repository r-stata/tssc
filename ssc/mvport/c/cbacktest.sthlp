{smcl}
{* *! version 1.0.0  23jun2016}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "simport" "help simport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}

{viewerjumpto "Syntax" "cbacktest##syntax"}{...}
{viewerjumpto "Description" "cbacktest##description"}{...}
{viewerjumpto "Options" "cbacktest##options"}{...}
{viewerjumpto "Remarks" "cbacktest##remarks"}{...}
{viewerjumpto "Examples" "cbacktest##examples"}{...}

{title:Title}

{phang}
{bf:backtest} {hline 2} performs and graphs a cumulative backtest of a financial portfolio period by period.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt cbacktest} {varlist} {ifin} 
{cmd:,} {it:weights(matrix_name) generate(newvarname) timevar(varname)} [nograph]



{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt w:eights(matrix_name)}}{it:matrix_name} is the name of a Stata matrix (Nx1) where the weights of the portfolio are stored. 
 This is a vertical matrix with dimensions (N x 1), where N= number of price variables.{p_end}
{synopt :{opt g:enerate(newvarname)}}{it:newvarname} is the name of a new variable where the cumulative holding return will be stored. If the variable exists, the variable is replaced with the calculated values.{p_end}
{synopt :{opt t:imevar(varname)}}{it:varname} is the name of the time-series variable.{p_end}
{synopt :{opt nog:raph}}if {it:nograph} is specified, the graph will not be shown. The default is to show the graph of cumulative holding return of the portfolio{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:cbacktest} calculates the cumulative holding period return of a financial portfolio for each observation/period. The {varlist} must be price variables, one for each asset of the portfolio. 
The portfolio weights must be located in a (Nx1) Stata matrix, which must be specified in the weights option. 
The time series variable is usually the period variable. The dataset is sorted according to this variable. 
The cumulative holding return of the portfolio will be stored in the new variable specified in the generate option. If this variable exists, then
it will be replaced. {p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collects online daily stock data from Yahoo Finance for 2014 and 2015. {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)}{p_end}

     {hline}

{pstd} Defines two weight matrices for two portfolios: {p_end}
{pstd} Portfolio 1: 30% for Apple, Inc, 20% for Microsoft Corp, and 50% for General Electric, Co.: {p_end}
{pstd} Portfolio 2: 50% for Apple, Inc, 25% for Microsoft Corp, and 25% for General Electric, Co.: {p_end}
{phang}{cmd:. matrix WPORT1=(0.3\0.2\0.5)}{p_end}
{phang}{cmd:. matrix WPORT2=(0.5\0.25\0.25)}{p_end}

     {hline}

{pstd} Generates the cumulative holding returns of the portfolios for the whole period. For each period, the holding period return of the portfolio is calculated: {p_end}
{phang}{cmd:. cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, gen(portret1) timevar(period) weights(WPORT1) nograph} {p_end}
{phang}{cmd:. cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, gen(portret2) timevar(period) weights(WPORT2) nograph} {p_end}

     {hline}

{pstd} Makes a graph to compare the performance of both portfolios over time: {p_end}
{phang}{cmd:. tsline portret1 portret2} {p_end}

     {hline}

{pstd} Generates and graphs the cumulative holding return of the portfolio 1 for a specified period. The holding period return of the portfolio for all days in 2015 (starting from Jan 01 2015) is calculated: {p_end}
{phang}{cmd:. cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE if period>=td(01jan2015) & period<=td(31dec2015), gen(portret1_1) timevar(period) weights(WPORT1)} {p_end}

     {hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cbacktest} does not save results in {cmd:r()} 

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
