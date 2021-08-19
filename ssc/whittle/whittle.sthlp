{smcl}
{* 09nov2019}{...}
{hline}
help for {hi:whittle}
{hline}


{title:Estimate long memory in a timeseries via Whittle's method}

{p 8 17}{cmd:whittle}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,} 
{cmdab:powers(}{it:numlist}{cmd:)}
{cmdab:detrend}
{cmdab:exact}
]

{p 4 4}{cmd:whittle} is for use with time-series data. 
You must {cmd:tsset} your data before using {cmd:whittle}; see help {cmd:tsset}. {it:varname}
may not contain gaps.  {it:varname} may contain time series operators.
{cmd:whittle} supports the {cmd:by} prefix, which may be used to operate on each 
time series in a panel. Alternatively, the {cmd:if} qualifier may be used to specify 
a single time series in a panel.

{title:Description}

{p 4 4}{cmd:whittle} 
computes two forms of the Whittle (1962) 
estimate of the long memory (fractional integration) parameter, {it:d}, of a 
timeseries.  If a series
exhibits long memory, it is neither stationary (I[0]) nor is it a unit 
root (I[1]) process; it is an I({it:d}) process, with {it:d} a real number. {p_end}

{p 4 4}
The local Whittle estimator applies a log-likelihood approach to compute an estimate of {it:d}.
Alternatively, an exact local Whittle estimator, derived by Shimotsu and Phillips (2005) can be computed.  
A linear trend can be extracted from the series.
{p_end}

{p 4 4}
A choice must be made of the number of harmonic ordinates to be included
in the estimator. The local Whittle estimate is an estimate of
the slope of the series' power spectrum in the vicinity of the zero 
frequency; if too few ordinates are included, the slope is calculated from
a small sample. If too many are included, medium and high-frequency components
of the spectrum will contaminate the estimate. 
{cmd:whittle} uses the default value of T^0.65 where T is the sample size. {p_end}

{p 4 4}
The command displays the d estimate, number of lags, conventional 
standard error, and asymptotic standard error.{p_end}

{title:Options}

{p 4 4}{cmdab:powers(}{it:numlist}) specifies a list of one or more fractional values for the power of sample size T to be
included in computing the local Whittle estimate. This overrides the default value of T^0.65, chosen from
sample size.

{p 4 4}{cmdab:trend} specifies that a linear trend should be removed from the series before
the local Whittle estimate is computed.

{p 4 4}{cmdab:exact} specifies that the exact local Whittle estimator should be computed.

{title:Examples}

{p 4 8}{stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/nile.dta, clear" :. use http://fmwww.bc.edu/ec-p/data/wooldridge/nile.dta, clear}{p_end}

{p 4 8}{stata "whittle nile" :. whittle nile}{p_end}

{p 4 8}{stata "whittle nile, detrend" :. whittle nile, detrend}{p_end}

{p 4 8}{stata "whittle nile, exact" :. whittle nile, exact}{p_end}

{p 4 8}{stata "whittle nile, powers(0.5 0.6 0.7)" :. whittle nile, powers(0.5 0.6 0.7)}{p_end}

{p 4 8}{stata "whittle nile, powers(0.5 0.6 0.7) exact" :. whittle nile, powers(0.5 0.6 0.7) exact}{p_end}

{p 4 8}{stata "webuse pennxrate,clear" :. webuse pennxrate,clear}{p_end}

{p 4 8}{stata "keep if id<10" :. keep if id<10}{p_end}

{p 4 8}{stata "by id: whittle realxrate,  exact" :. by id: whittle realxrate,  exact}{p_end}


{title:Authors}

{p 4 4}Christopher F. Baum, Boston College, USA{break} 
       baum@bc.edu
       
{p 4 4}Stan Hurn, Queensland University of Technology, Australia{break} 
	   s.hurn@qut.edu.au
    
{p 4 4}Kenneth Lindsay, Glasgow University, UK{break}
	kenneth.lindsay@glasgow.ac.uk
    

{title:References}
      
{p}Shimotsu, K., and P. Phillips. 2005. Exact local Whittle estimation of fractional 
integration. Annals of Statistics 33: 1890–1933.{p_end}

{p}Whittle, P. 1962. Gaussian estimation in stationary time series. 
Bulletin of the International Statistical Institute 39: 105–129.{p_end}


      
{title:Also see}

{p 4 13}On-line: {help tsset}, {help arfima}, 
 {help gphudak} (if installed), {help roblpr} (if installed), {help modlpr} (if installed)
        

