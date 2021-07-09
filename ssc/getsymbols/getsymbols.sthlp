{smcl}
{* *! version 2.0.0  23jun2016}{...}

{viewerjumpto "Syntax" "getsymbols##syntax"}{...}
{viewerjumpto "Description" "getsymbols##description"}{...}
{viewerjumpto "Options" "getsymbols##options"}{...}
{viewerjumpto "Examples" "getsymbols##examples"}{...}
{title:Title}

{phang}
{bf:getsymbols} {hline 2} collects and integrates one or more series from Quandl.com, Google Finance, Yahoo Finance, and Alpha Vantage.  

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt getsymbols} {cmd:} {it:ticker_list} [,options] 

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt go:ogle}}if google is specified, then the source will be Google Finance; the default source is Quandl.com. {p_end}
{synopt :{opt ya:hoo}}if yahoo is specified, then the source will be Yahoo Finance; the default source is Quandl.com.{p_end}
{synopt :{opt van:tage}}if vantage is specified, then the source will be Alpha Vantage. This option works for Stata 15. For Stata 13 and 14 it is necessary to do a Java configuration.
 Send an email to cdorante@itesm.mx to request instructions for this configuration. {p_end}
{synopt :{opt cur:rency(string)}}currency of the criptocurrency quotation in case of downloading a criptocurrency from Alpha Vantage. To see the list of cryptocurrencies check the Alpha Vantage site at https://www.alphavantage.co/ {p_end}
{synopt :{opt database(string)}}name of the Quandl database to be used. The default is the WIKI database, which contains US stock data. To see which databases can be used check the Quandl site at https:/www.quandl.com/search. This option only applies for the Quandl sourcey.  {p_end}
{synopt :{opt fm(#)}}first month (from 1 to 12). The default value is 1{p_end}
{synopt :{opt fd(#)}}first day (from 1 to 31). The default value is 1{p_end}
{synopt :{opt fy(#)}}first year. The default is 1990 {p_end}
{synopt :{opt lm(#)}}last month (from 1 to 12). The default value is 12{p_end}
{synopt :{opt ld(#)}}last day (from 1 to 31). The default value is 31{p_end}
{synopt :{opt ly(#)}}last year. The default is 2099, which will be the current year{p_end}
{synopt :{opt fr:equency(d|w|m|q|1min|5min|15min|30min)}}frequency of the data: d for daily (the default value); w for weekly; m for monthly. Only for vantage source has the frequencies 1min, 5min, 15min, 30min. 
 Google usually has only daily stock data. {p_end}
{synopt :{opt price(string)}}if price is specified, then this price variable will be used to calculate period simple and continuously compounded returns. Also, if price is specified only that price series will be downloaded even though the source might have other variables such as open, high, low, etc. {p_end}
{synopt :{opt keep:all}}if the price option is specified and the keepall option is specified, then besides calculating returns with the price variale, all variables of the series will be kept.
  If price option is specified and keepall is not specified, then only the price variable will be downloaded and corresponding returns will be calculated. {p_end}
{synopt :{opt clear}}indicates to clear the dataset before the command is executed.{p_end}  
{synopt :{opt case:wise}}specify casewise deletion of observations in case periods of different tickers do no match. The default is to use all the observations for each ticker/series.{p_end}
{synopt :{opt apikey(string)}}specify the apikey of the user in case the source requires it. For example, Quandl requires an apikey for the premium databases and for some free databases, and Alpha Vantage always requires an apikey.
  Any user can create a Quandl or an Alpha Vantage apikey from their sites. {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:getsymbols} collects and integrates time series of symbols (e.g. stock tickers, indexes, economic series) from any of the following sources: Quandl, Yahoo Finance, Google Finance and Alpha Vantage. The symbols must be
equal to those used in the corresponding source. 
Quandl is a repository of hundreds of free and premium databases, and each database usually has many series. Examples of FREE Quandl databases  
are: WIKI, Chicago Mercantile Exchange Futures, Chicago Board Options Exchange, Federal Reserve Economic Data, London Stock Exchange, Franfurt Stock Exchange, Tokyo Stock Exchange, National Stock Exchange of India, NASDAQ OMX Global Index Data, 
Yale Department of Economics, World Bank databases, etc. 
Google Finance has only stock daily data from several countries.
Yahoo Finance has stock quotes and market indexes, and ETF's from many countries.
Alpha Vantage has stock quotes, market indexes, and also cryptocurrency quotes.
 This command works with Stata 13 or above.


{marker examples}{...}
{title:Examples}

    {hline}

{pstd} Collects online monthly stock data (adjusted prices) (Apple, Microsoft, General Electric, General Motors, and Wal-Mart) from the WIKI Quandl database from Jan 2012 to May 2017. 
Returns are calculated automatically and return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols AAPL MSFT GE GM WMT, fm(1) fd(1) fy(2012) lm(5) ld(31) ly(2017) frequency(m) price(adjclose) clear} {p_end}

{pstd} Collects online daily stock data (adjusted prices) from the WIKI Quandl database. When frequency is not specified, daily data is assumed.  
When dates are not specified, the initial date will be up to Jan 1st 1990, and the last date will be the most current one.  {p_end}
{phang}{cmd:. getsymbols AAPL MSFT GE GM WMT, clear} {p_end}

{pstd} Collects online daily stock data (adjusted prices) from the Yahoo Finance!. When frequency is not specified, daily data is assumed.  
When dates are not specified, the initial date will be up to Jan 1st 1990, and the last date will be the most current one. Returns are calculated using adjclose and return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols AAPL MSFT GE GM WMT, fy(2010) price(adjclose) clear yahoo} {p_end}

{pstd} Collects online monthly ETF data from the Yahoo Finance!. 
Returns are calculated using adjclose and return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols VNQ SPY, fy(2015) freq(m) price(adjclose) clear yahoo} {p_end}

{pstd} Collects online monthly data for the S&P500 and the Mexican market index from the Yahoo Finance!. 
Returns are calculated using adjclose and return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols ^GSPC ^MXX , fy(2015) freq(m) price(adjclose) clear yahoo} {p_end}

{pstd} Collects online daily stock data (adjusted prices) from the Yahoo Finance!. 
When dates are not specified, the initial date will be up to Jan 1st 1990, and the last date will be the most current one. In this case, returns are calculated, and 
all price variables are kept (e.g. open, close, high, low, adjusted). {p_end}
{phang}{cmd:. getsymbols WMT MSFT AAPL, fy(2014) fm(3) fd(2) ly(2015) lm(6) ld(30) price(adjclose) keepall yahoo clear} {p_end}

{pstd} Collects online quarterly stock data from the WIKI Quandl database, indicating the user APIKEY, which is a string of characters.  {p_end}
{phang}{cmd:. getsymbols AAPL MSFT GE GM WMT, fy(2015) freq(q) database("WIKI") apikey(USERAPIKEY) clear} {p_end}

{pstd} Collects online daily stock data of 2 German stocks from 2005 to date (close prices) from the FSE Quandl database, which is the Frankfurt Stock Exchange. {p_end}
{phang}{cmd:. getsymbols MLP_X  SKB_X KGX_X, database("FSE") clear} {p_end}

{pstd} Collects online daily stock data of 2 German stocks from 2008 to date (close prices) from the FSE Quandl database, which is the Frankfurt Stock Exchange. With the option price and keepall returns will be
calculated using the price variable and all variables from the original dataset will be kept in the integrated dataset. {p_end}
{phang}{cmd:. getsymbols MLP_X  SKB_X KGX_X, database("FSE") fy(2008) price(close) keepall clear} {p_end}

{pstd} Collects online daily data of 2 indexes from NASDAQ-OMX Quandl database from 2008 to date. The price variable to be used to calculate returns is indexvalue. With the option keepall ALL variables from the original dataset will be kept in the integrated dataset.
If the option keepall is not indicated then only the price variable is kept from the original dataset.  
Returns are calculated automatically and the return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols VOLNDX COMP , database("NASDAQOMX") fy(2011) price(indexvalue)  keepall clear} {p_end}

{pstd} Collects online monthly data of 2 series from the FRED Quandl database from 1990 to date. The price variable to be used to calculate returns is value.  
In this case, returns are calculated using the value variable, which is already a return (annual). Then, in this case, the returns calculated are monthly percentage increases of annual rates. {p_end}
{phang}{cmd:. getsymbols INTGSTUSM193N INTGSTAUM193N, database("FRED")  frequency(m) price(value) clear} {p_end}

{pstd} Collects online daily stock data (Apple, Microsoft, General Electric, General Motors, and Wal-Mart) from Google Finance from Jan 3, 2012 to the most recent day. 
Returns are calculated automatically and the returns variables will start with r_* {p_end}
{phang}{cmd:. getsymbols AAPL MSFT GE GM WMT, google fm(3) fd(1) fy(2012) clear} {p_end}

{pstd} Collects online daily German stock data (Volkswagen, SAP, Siemens) from Google Finance from Jan 3, 2012 to the most recent day. 
Returns are calculated automatically and the returns variables will start with r_* {p_end}
{phang}{cmd:. getsymbols FRA:VOW FRA:SAP FRA:SIE, google fm(3) fd(1) fy(2012) clear} {p_end}

{pstd} Collects online daily Mexican stock data (América Móvil, Bimbo, CEMEX) from Google Finance from Jan 3, 2012 to the most recent day. Returns are calculated automatically and the return variables will start with r_* {p_end}
{phang}{cmd:. getsymbols BMV:AMXL BMV:BIMBOA BMV:CEMEXCPO, google fm(3) fd(1) fy(2012) clear} {p_end}

{pstd} Collects online daily quotations of the cryptocurrencies Bitcoin and Etherium from Alpha Vantage. {p_end}
{phang}{cmd:. getsymbols BTC ETH, vantage currency(MXN) apikey(USERAPIKEY)  clear } {p_end}

{pstd} Collects intraday quotations (5min) for Microsoft and GE from Alpha Vantage. {p_end}
{phang}{cmd:. getsymbols MSFT GE, freq(5min) vantage apikey(USERAPIKEY)  clear } {p_end}


{hline}	 
	 

{marker results}{...}
{title:Stored results}

{pstd}

{cmd:getsymbols} stores results in {cmd:r()} in the following scalar and macro:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(numtickers): }}Number of symbols with online data that could be collected {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(tickerlist): }}Contains a list of the symbols that could be collected. If a symbol specified does not exist in the source, this symbol will no be included in this list.  {p_end}

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
