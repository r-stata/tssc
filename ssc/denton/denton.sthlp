{smcl}
{* *! version 2.0.0 08aug2011}{...}
{hline}
help for {hi:denton}
{hline}

{title:Interpolate a time-series from low-frequency totals via proportional Denton method}

{p 8 14}{cmd:denton}{it: varlist} {cmd:using}({it:string}) [{cmd:if} {it:exp}] [{cmd:in} {it:range}], 
{cmdab:int:erp}({it:string}) 
{cmd: from}({it:string}) 
{cmdab:gen:erate}({it:string}) 
[{cmd:stock old}]


{p} {cmd:denton} is for use with time-series data.  You must {cmd:tsset} your data before using {cmd:denton}; see {help tsset}. {cmd:denton} may be used on a single time series of a panel which has been {cmd:tsset} or {cmd:xtset}.


{title:Description}

{p}{cmd:denton} computes the proportional Denton method of interpolation of a low-frequency time series by use of an associated higher-frequency indicator series, 
imposing the constraints that the interpolated series obeys the original low-frequency series 
totals. The method is described in IMF Chapter 6, Benchmarking (2001) as 
"relatively simple, robust, and well-suited for large-scale applications."

{p}{cmd:denton} requires that the low-frequency variable be an annual or quarterly time series, while the indicator variable may be of quarterly or monthly frequency. Although the procedure is usually applied to flow series (such as GDP), 
it may be applied to stock series applying the {cmd:stock} option, where both the low-frequency and indicator variables are stock series. 
The method may be particularly useful in cases where, due to sizable statistical discrepancy, quarterly series do not integrate to annual totals. The
indicator series only contribute their pattern to the interpolation;  thus it is quite feasible to use both quarterly and annual flow series expressed at an annual rate. In this instance the interpolated series will be at a  quarterly rate. 

{p}{cmd:denton} is a least squares approach, in which the high-frequency estimates to be derived are the parameters, and the sum of squares involved are  the first differences of the X/I ratio: 
the ratio of the interpolated series (X) to the indicator series (I). The problem is a constrained  least squares problem which may be written as a Lagrangian expression in the minimand and the constraints, one of which is 
defined for each low-frequncy observation.

{p}The low-frequency variable to be interpolated is specified as {cmd:varname}. The {cmd:using} clause specifies 
the filename of the Stata data (.dta) file to be created, containing the new series. This must be a new file.


{title:Options}

{p 0 4}{cmdab:int:erp()}, a required option, specifies the name of the high-frequency indicator variable. As the proportional Denton method requires that the indicator variable is strictly positive, the indicator variable is adjusted prior to use if it contains nonpositive values.

{p 0 4}{cmd:from()}, a required option, specifies the name of the Stata dataset containing the indicator variable. This dataset must be {cmd:tsset} as a single time-series.

{p 0 4}{cmdab:gen:erate()}, a required option, specifies the name of the new variable which will contain the interpolated series within the defined sample. 
The file created (as specified in {cmd:from()}) will store the interpolated series along with the X (low-frequency) series and the new time variable. 
The new variable's observations over each calendar year will sum to the low-frequency total given in the X series.
That may be verified, as the routine indicates, by making use of {cmd:tscollap}.

{p 0 4}{cmd:stock} may be used to specify that both of the time-series to be used are stock series. 
In that case both the low-frequency and indicator series are differenced, the interpolated variable is created, and then integrated via {cmd:sum()}, after adding the initial value. 
Because of differencing, the new variable is not interpolated for the first low-frequency period.

{p 0 4}{cmd:old} may be used to specify that the new file is saved in Stata 11 format if {cmd:denton} is run under Stata 12+. 


{title: Example}

{phang}{cmd:. denton aflow using ydta.dta, interp(qflow) from(qdta.dta) generate(qinterp)}{p_end}
{phang}{cmd:. denton aflow using ydta.dta if tin(1970, 1980), interp(qflow) from(qdta.dta) generate(qinterp)}{p_end}
{phang}{cmd:. denton aflow using ydta.dta, interp(qflow) from(qdta.dta) generate(qinterp) stock old}{p_end}

{title: References}

{p 0 4}Bloem, A., Dippelsman, R., and Maehle, N., {it:Quarterly National Accounts Manual: Concepts, Data Sources, and Compilation.}
 International Monetary Fund, 2001. http://www.imf.org/external/pubs/ft/qna/2000/Textbook/index.htm

{title: Authors}

{p 8 12}Christopher F Baum, Boston College, USA{p_end}
{p 8 12}baum@bc.edu{p_end}
{p 8 12}Sylvia Hristakeva, Boston College, USA{p_end}
{p 8 12}hristakeva@gmail.com{p_end}


{title: Also see}

{p 8 12} On-line:  {help tsset}, {help tscollap} (if installed)
