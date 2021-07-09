{smcl}
{* *! version 1.1.0  30may2015}{...}
{cmd:help tsegen}
{hline}

{title:Title}

{phang}
{cmd:tsegen} {hline 2} Invoke an {cmd:egen} function using a {help tsvarlist:{it:tsvarlist}} as argument


{title:Syntax}

{p 8 14 2}
{cmd:tsegen} {dtype} {newvar} {cmd:=} {it:fcn}({help tsvarlist:{it:tsvarlist}}[, {it:min_obs}]) {ifin} 
[{cmd:,} {it:options}]

{pstd}
where {it:fcn} is an {help egen:{bf:egen}} function that expects a
{help varlist:{it:varlist}}. 
Optionally, results based on fewer than {it:min_obs}
non-missing observations are replaced with missing values.
{it:options} are {it:fcn} dependent.
{cmd:by} is not allowed.


{title:Description}

{pstd}
A number of {cmd:egen} functions 
(both built-in and user-written, e.g. {stata "ssc desc egenmore":egenmore})
expect a {help varlist:{it:varlist}}
and perform observation-level calculations based on
the variables provided as argument.
With {cmd:tsegen}, you can invoke any of these {bf:egen} functions
using a time-series varlist ({help tsvarlist:{it:tsvarlist}})
instead.
{cmd:tsegen} converts the {help tsvarlist:{it:tsvarlist}} 
to a {help varlist:{it:varlist}} 
by substituting equivalent temporary variables as necessary
and then invokes the specified {help egen:{bf:egen}} function.

{pstd}
To use time-series operators, 
the data must be declared to be a time series (with or without a panel
variable) using either {help tsset} or {help xtset}.

{pstd}
If the {help egen} function ignores missing values, 
you can specify that the results
be based on a minimum of non-missing values using the {it:min_obs} option. 

    
{title:Descriptive statistics over a rolling window examples}

{pstd}
Calculate the mean of the variable {hi:invest} over a 5-year 
rolling window that includes the current observation

        {cmd:.} {stata webuse grunfeld, clear}
        {cmd:.} {stata tsegen inv_m5 = rowmean(invest L(1/4).invest)}
        
{pstd}
Note that the above can also be written as

        {cmd:.} {stata tsegen inv_m5b = rowmean(L(0/4).invest)}

{pstd}
Since missing values are ignored, a non-missing mean may be based on a single
observation. To require a 3 year minimum

        {cmd:.} {stata tsegen inv_m5m3 = rowmean(L(0/4).invest, 3)}
        
{pstd}
To find the minimum and maximum investment within the 5-year window, again
ignoring windows with fewer than 3 observations

        {cmd:.} {stata tsegen inv_min5m3 = rowmin(L(0/4).invest, 3)}
        {cmd:.} {stata tsegen inv_max5m3 = rowmax(L(0/4).invest, 3)}
        
{pstd}
Calculate the standard deviation over a rolling 3-year window. The
first example includes the value of the current observation in the
rolling window. The second example calculates the standard deviation
for the current observation based on lagged values for the 3 preceding
periods. 

        {cmd:.} {stata tsegen inv_sd3 = rowsd(L(0/2).invest)}
        {cmd:.} {stata tsegen inv_sd3L = rowsd(L(1/3).invest)}


{title:Coefficient of variation example}

{pstd}
Calculate the coefficient of variation in market value over a
rolling window of 5 years (for representation as percent, 
multiply further by 100) 

        {cmd:.} {stata webuse grunfeld, clear}
        {cmd:.} {stata tsegen mysd = rowsd(L(0/4).mvalue,5)}
        {cmd:.} {stata tsegen mymean = rowmean(L(0/4).mvalue,5)}
        {cmd:.} {stata gen mycv = mysd / mymean}


{title:Data smoothing example}

{pstd}
Smooth data using a uniformly weighted moving average

        {cmd:.} {stata webuse sales1, clear}
        {cmd:.} {stata tsegen sm = rowmean(L(0/2).sales F(1/3).sales)}
        
{pstd}
which is the equivalent of

        {cmd:.} {stata tssmooth ma sm1=sales, window(2 1 3)}


{title:Geometric mean example}

{pstd}
Compare market value over a 3 year window using
arithmetic and geometric means.

        {cmd:.} {stata webuse grunfeld, clear}
        
{pstd}
Calculate the arithmetic mean

        {cmd:.} {stata tsegen amean = rowmean(L(0/2).mvalue,3)}
              
{pstd}
Calculate the geometric mean
        
        {cmd:.} {stata gen double log_mvalue = log(mvalue)}
        {cmd:.} {stata tsegen double gmean = rowmean(L(0/2).log_mvalue,3)}
        {cmd:.} {stata replace gmean = exp(gmean)}
              

{title:Other examples}

{pstd}
Identify observations that reflect 3 consecutive years of positive growth in
market value. This requires the {cmd: rall} function
from {stata "ssc desc egenmore":egenmore}

        {cmd:.} {stata webuse grunfeld, clear}
        {cmd:.} {stata gen double diff = D.mvalue}
        {cmd:.} {stata tsegen pg = rall(L(0/2).diff,3) , c(@ > 0)}

{pstd}
Note that the above example can be shortened to

        {cmd:.} {stata webuse grunfeld, clear}
        {cmd:.} {stata tsegen pg2 = rall(L(0/2)D.mvalue,3) , c(@ > 0)}

{pstd}
Thanks to Sebastian Kripfganz for pointing this out on
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1292241-new-on-ssc-tsegen-for-computations-over-a-rolling-window-using-time-series-operators-with-egen-functions?p=1292371#post1292371":Statalist}.


{title:Limitations}

{pstd}
All flavors of Stata impose a limit of 100 unique time-series operators 
per command (see {stata help limits}). 
This version of {cmd:tsegen} overcomes this limit. For example,
a rolling window of 200 periods can be specified using {cmd:L(1/200).return}.
See {stata help limits} for the maximum number of variables allowed with
your version of Stata.


{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}

{pstd}Nicholas J. Cox, Durham University{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{marker also}{...}
{title:Also see}

{psee}
Stata:  {help egen}, {help rolling}, {help tssmooth}, {help tsvarlist}, {help tsrevar}
{p_end}

{psee}
Article: Cox, Nicholas J. 2009. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0046":Speaking Stata: Rowwise}, {it:Stata Journal} 9: 137{c -}157. 
{p_end}

{psee}
SSC:  {stata "ssc desc mvsumm":mvsumm}, {stata "ssc desc rollstat":rollstat}, {stata "ssc desc egenmore":egenmore}
{p_end}

{psee}
Others:  {stata `"net from "https://sites.google.com/site/imspeshawar" "':asrol}
{p_end}
