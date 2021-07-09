{smcl}
{* 04 Aug 2006}{...}
{hline}
help for {hi:lomackinlay}
{hline}

{title:Perform Lo-MacKinlay variance ratio test}

{p 8 17 2}
{cmd:lomackinlay} 
{it:varname} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{cmd:,}
{cmdab:q:(}{it:numlist}{cmd:)} 
{cmd:gaps} 
{cmd:robust} 
]  

{p 4 4 2}
{cmd:lomackinlay} is for use on time series data, which must be {help tsset}.  It
may be applied to a single panel of a panel ({it:xt}) data set using an {cmd:if} qualifier.
{cmd:lomackinlay} also supports the {cmd:by:} prefix.

{title:Description}

{p 4 4 2}
{cmd:lomackinlay} computes a overlapping variance-ratio test on a timeseries. The
timeseries should be in level form; e.g., to test that stock returns vary randomly 
around a constant mean, you consider the null hypothesis that the log price series
is a random walk with drift. The log price series would then be given in the 
{it:varlist}. If the assumption of homoskedastic errors in the process generating
the differenced series is not reasonable, the {it:robust} option may be used to
calculate a variance ratio test statistic robust to arbitrary heteroskedasticity. The
standarized variance ratio, labeled R_s, is distributed as Normal under the null
hypothesis of a random walk.


{title:Options} 

{p 4 8 2}{cmd:q(numlist)} optionally specifies a {it:numlist} of values for
the span of differencing. If not provided, the {it:numlist} of 2 4 8 16 is applied.

{p 4 8 2}
{cmd:gaps} is used to indicate that gaps in the timeseries are allowed.

{p 4 8 2}
{cmd:robust} specifies that a heteroskedasticity-robust test statistic should
be computed.


{title:Examples}

{p 4 8 2}{stata "webuse wpi1" :. webuse wpi1}{p_end}
{p 4 8 2}{stata "lomackinlay ln_wpi" :. lomackinlay ln_wpi}{p_end}
{p 4 8 2}{stata "lomackinlay ln_wpi, robust" :. lomackinlay ln_wpi, robust}{p_end}
{p 4 8 2}{stata "lomackinlay ln_wpi, q(2 3 5 7 9)" :. lomackinlay ln_wpi, q(2 3 5 7 9)}{p_end}


{title:References}


Campbell, J. Y., Lo, A. W. and A. C. MacKinlay, The Econometrics of Financial Markets. 
Princeton: Princeton University Press, 1997.

Lo, A. and MacKinlay, A. C., "Stock market prices do not follow random walks: evidence
 from a simple specification test", Review of Financial Studies 1:1, 1988. 
 
Lo, A. W. and A. C. MacKinlay, A Non-Random Walk Down Wall Street. 
Princeton: Princeton University Press, 1999. https://www.jstor.org/stable/j.ctt7tccx.9

Tse, Ng and Zhang, "A small-sample overlapping variance-ratio test",
 available from www.mysmu.edu/faculty/yktse/JTSA_R.pdf 
 
 

{title:Author} 

{p 4 4 2}Christopher F Baum, Boston College{break} 
         baum@bc.edu


{title:Acknowledgements} 

{p 4 4 2}Tomasz Stepniak's query to Statalist suggested this problem. I am very
grateful to Allin Cottrell for pointing out several corrections required in the
code and providing corrected code. Brian Fryd also pointed out an error in the
routine and provided a fix, for which I thank him.


{title:Also see}

{p 4 13 2}On-line: help for {help lomodrs} (if installed)  


