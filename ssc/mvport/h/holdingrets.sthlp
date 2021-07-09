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
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "holdingrets##syntax"}{...}
{viewerjumpto "Description" "holdingrets##description"}{...}
{viewerjumpto "Remarks" "holdingrets##remarks"}{...}
{viewerjumpto "Examples" "holdingrets##examples"}{...}

{title:Title}

{phang}
{bf:holdingrets} {hline 2} calculates the holding period return of one or more price variables.  

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt holdingrets} {varlist} {ifin} 

{marker description}{...}
{title:Description}

{pstd}
{cmd:holdingrets} calculates the holding period return of one or more price variables specified in the {varlist}. It is assumed that the dataset is sorted chronologically. 
The way the holding return is calculated for each variable is as follows. For each variable, the holding period return is calculated as the percentage change
between the last non-missing value and the first non-missing value. This command performs a casewise deletion (it drops observations with at least one missing 
value for any of the variables). 

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collects online daily stock data from Yahoo Finance for 2014 and 2015. {p_end}
{phang}{cmd:. returnsyh AAPL MSFT, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)}{p_end}

     {hline}

{pstd} Calculates the holding return of both stocks for the whole period. {p_end}
{phang}{cmd:. holdingrets p_adjclose_AAPL p_adjclose_MSFT} {p_end}

     {hline}

{pstd} Calculates the holding return of both stocks from the first day of Jan 2015 to Dec 31, 2015. {p_end}
{phang}{cmd:. holdingrets p_adjclose_AAPL p_adjclose_MSFT} if period>=td(01jan2015) & period<=td(31dec2015) {p_end}

     {hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:holdingrets} stores results in {cmd:r()} in the following scalar and matrix (vertical vector):

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N): }}Number of observations used for the calculations {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:r(holdingrets): }}(n x 1) holding period returns of each price variable (n variables) {p_end}

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
