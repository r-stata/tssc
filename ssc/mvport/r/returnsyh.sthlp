{smcl}
{* *! version 2.0.0  23jun2016}{...}

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
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "returnsyh##syntax"}{...}
{viewerjumpto "Description" "returnsyh##description"}{...}
{viewerjumpto "Options" "returnsyh##options"}{...}
{viewerjumpto "Remarks" "returnsyh##remarks"}{...}
{viewerjumpto "Examples" "returnsyh##examples"}{...}
{title:Title}

{phang}
{bf:returnsyh} {hline 2} collects a set of online stock series from Yahoo Finance, integrate the series and calculates simple and continously compounded returns.  

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt returnsyh} {cmd:} {it:ticker_list}, fm(#) fd(#) fy(#) lm(#) ld(#) ly(#) frequency(d|w|m) price(open|close|high|low|adjclose) [CASEwise]

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt fm(#)}}first month (from 1 to 12){p_end}
{synopt :{opt fd(#)}}first day (from 1 to 31){p_end}
{synopt :{opt fy(#)}}first year {p_end}
{synopt :{opt lm(#)}}last month (from 1 to 12){p_end}
{synopt :{opt ld(#)}}last day (from 1 to 31){p_end}
{synopt :{opt ly(#)}}last year{p_end}
{synopt :{opt frequency(d|w|m)}}frequency of the data: d for daily; w for weekly; m for monthly{p_end}
{synopt :{opt price(open|close|adjclose|high|low)}}Type of price: open, close, high, low, and adjclose (adjclose means adjusted for dividends and stock split){p_end}
{synopt :{opt case:wise}}specifies casewise deletion of observations in case there is no match of periods. 
The default is to use all the observations for each variable.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:returnsyh} collects and integrates stock prices from Yahoo Finance, and also calculates simple and continously compounded returns for each ticker. The stock symbols or tickers must be
equal to those used in Yahoo Finance (finance.yahoo.com)   

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.

{marker examples}{...}
{title:Examples}

    {hline}

{pstd} Collects online monthly stock data (adjusted prices) from Yahoo Finance from Jan 2012 to Dec 2015. Returns are calculated automatically and the return variables will start with r_* {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}


     {hline}	 
	 

{marker results}{...}
{title:Stored results}

{pstd}

{cmd:returnsyh} stores results in {cmd:r()} in the following scalar and macro:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(numtickers): }}Number of tickers with online data that could be brought from Yahoo Finance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(tickerlist): }}Contains a list of the tickers brought from Yahoo Finance {p_end}

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
