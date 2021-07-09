{smcl}
{cmd:help stockquote}
{hline}

{title:Title}

    {hi: Get Time Series Stock Quotes from the net}

{title:Syntax}

{p 8 17 2}
{cmd:stockquote}
<ticker symbol>, start_date(first day) end_date(last day) 

{title:Description}
{pstd}

{cmd:stockquote} exploits the Python integration which, Stata introduced starting with version 16
({cmd:man python}) and wraps itself around the Python module {browse "https://pypi.org/project/yfinance/":"yfinance"} to query Yahoo's 
Finance API for ticker symbol historical values. The "yfinance" module can do much more of course
and stockquote translates only part of its functionality for Stata speakers.

You need Python 3.7 (go with Anaconda) and, besides Stata 16 or more, you need to 
have configured your Stata to use the right Python on your system. To install 
"yfinance" run the command {cmd:pip install yfinance} at the command line. 



{title:Examples}
The command below
{phang}
{cmd:. stockquote ^GDAXI, start_date(2010-01-01) end_date(2010-01-30)}{p_end}
will "use" the daily historical values of the DAX index from January 1 2010 to January 30 2010, whereas
{phang}
{cmd:. stockquote AAPL, start_date(2010-01-01) end_date(2010-01-30)}{p_end}
will do the same for the Apple stock.

{title: Author}
Nikos Askitas, IZA - Institute of Labor Economics, Bonn, Germany.
Email: nikos@iza.org, Twitter: {browse "https://twitter.com/askitas":@askitas} 
Web: {browse "https://askitas.com":askitas.com}
