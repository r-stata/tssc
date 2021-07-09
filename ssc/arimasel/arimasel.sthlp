{smcl}
{* *! version 1 12sep2020}{...}
{cmd:help arimasel}

{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:arimasel}}   Selection criteria for ARMA(p,q) models{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:arimasel} {varname} {ifin} [{cmd:,} 
{cmdab:AR(}{it:integer}{cmd:)}
{cmdab:MA(}{it:integer}{cmd:)}
{cmdab:ITER(}{it:integer}{cmd:)}
{cmdab:MATrix()}{it:string}{cmd:)}
{cmdab:GRAPH}]


{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:ersur}; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varname} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
Sample may not contain gaps.{p_end}


{title:Description}

{pstd}
{cmd:arimasel} computes selection criteria for ARMA(p,q) models using arima(p,0,q)
for p and q up to specified limits. To fit a model such as arima(p,1,q), specify D.varname.
{p_end}

{pstd}
For each model, the program displays the values of p, q, the log-likelihood, the AIC
and the SIC criteria for model selection, using the arimafit package from SSC.
If a model does not converge in the specified number of iterations, the results table
displays missing values for the criteria.
{p_end}

{title:Options}

{phang}
{opt ar(integer)} sets the maximum AR order of the ARMA models to be fit. If not specified,
a default of 3 is used. 

{phang}
{opt ma(integer)} sets the maximum MA order of the ARMA models to be fit. If not specified,
a default of 3 is used. 

{phang}
{opt iter(integer)} sets the maximum number of iterations to be used. If not specified,
a default of 100 is used. 

{phang}
{opt matrix(string)} specifies the name of a matrix into which the displayed results
are stored in the return list.

{phang}
{opt graph} specifies that the LLF, AIC and SIC values should be graphed, and their extreme
value identified. 

{title:Stored results}

{pstd}
{cmd:arimasel} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}total number of observations available{p_end}
{synopt:{cmd:r(maxllf)}}model number of maximum log-likelihood{p_end}
{synopt:{cmd:r(minaic)}}model number of minimum AIC {p_end}
{synopt:{cmd:r(minsic)}}model number of minimum SIC {p_end}


{title:Examples}


{phang2}{bf:. {stata "webuse wpi1":webuse wpi1}}{p_end}

{phang2}{bf:. {stata "arimasel D.wpi":arimasel D.wpi}}{p_end}

{phang2}{bf:. {stata "arimasel D.wpi, ar(4) matrix(arma_results)":arimasel D.wpi, ar(4) matrix(arma_results)}}{p_end}

{phang2}{bf:. {stata "arimasel D.wpi, ar(4) graph":arimasel D.wpi, ar(4) graph}}{p_end}


{title:Author}


{pstd}
Christopher F. Baum{break}
Boston College{break}
Chestnut Hill, MA USA{break}
baum@bc.edu{p_end}
