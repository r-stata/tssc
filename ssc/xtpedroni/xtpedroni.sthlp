{smcl}
{* version 1.0.0 11July2013}{...}
{cmd: help xtpedroni}{right: ...}
{hline}

{title:Title}

{phang}
{bf:xtpedroni} {hline 2} Pedroni's panel cointegration tests and Panel Dynamic OLS estimation.

{title:Syntax}

{p 8 17 2}
{cmd:xtpedroni} {depvar} [{indepvars}] {ifin} 
[{cmd:,} {it:options}]


{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtpedroni}; see {helpb xtset}.{p_end}
{p 4 6 2}
For correct estimation, ensure that any missing observations are at the start or end of the sample.{p_end}

{title:Description}

{pstd}
{cmd:xtpedroni} has two functions:{p_end}

{p 4 6 1}First, it allows Stata users to compute Pedroni's seven test statistics under a null of no cointegration in a heterogeneous panel (medium to large N, large T) with one or more nonstationary regressors. These test statistics are panel-v, panel-rho, group-rho, panel-t (non-parametric), group-t (non-parametric), panel-adf (parametric t), and group-adf (parametric t). 
All test statistics are normalised to be distributed under N(0,1). All of the statistics, save for panel-v, diverge to negative infinity as the p-value converges to 0.{p_end}

{p 4 6 1}Second, it computes Pedroni's group mean Panel Dynamic Ordinary Least Squares estimates. Very briefly, it extends the Dynamic OLS technique of estimating the cointegrating vector 
in a single equation to panel time series data (medium to large N, large T). Dynamic OLS involves adding lags and leads of the regressors to eliminate feedback effects and endogeneity. 
In Panel Dynamic OLS, a DOLS regression is conducted for each individual, and the results are combined for the entire panel following Pedroni's group mean approach.
Variables must exhibit cointegration to be used here.{p_end}

{p 4 6 1}For more information on both of these functions, please see:{p_end}
{p 4 6 1}Pedroni, Peter (1999) "Critical Values for Cointegration Tests in Heterogeneous Panels with Multiple Regressors," Oxford Bulletin of Economics and Statistics, 61, 653-70.{p_end}
{p 4 6 1}Pedroni, Peter (2001) "Purchasing Power Parity Tests in Cointegrated Panels," Review of Economics and Statistics, 83, 727-731{p_end}

{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main:}
{synopt:{opt notdum}}Suppresses time-demeaning of the variables (i.e. common time dummies). Time-demeaning is turned on by default. The use of this option may be appropriate in any
situations where there is reason to believe that averaging over the N dimension may
destroy the cointegrating relationship, or where there are comparability concerns
between panel units in the data.{p_end}
{synopt:{opt nopdols}}Suppresses PDOLS estimation (i.e. only reports the cointegration test).{p_end}
{synopt:{opt notest}}Suppresses cointegration tests (i.e. only reports PDOLS results).{p_end}
{synopt:{opt extraobs}}In the event of an unbalanced panel where observations are missing for some of the variables (at the start or end of the sample) for certain individuals, this option will allow the available observations in the missing years to be included in the time means used for time-demeaning. This was the behaviour of Pedroni's original PDOLS
program, but not the cointegration test program. It is off by default.{p_end}
{synopt:{opt b(#)}}Defines the null hypothesis beta as #. Defaults to 0.{p_end}
{synopt:{opt mlags(#)}}Forces the number of lags used in the Bartlett kernel for the Newey-West long run variance to be #. If not specified, it is automatically determined for each individual.{p_end}

{syntab:Coint Test Specific:}
{synopt:{opt trend}}Adds a linear time trend.{p_end}
{synopt:{opt lagselect(string)}}Specifies the criterion  usedto select lag length in the ADF regressions. Can be {it:AIC} (default), {it:BIC}, and {it:HQIC}.{p_end}
{synopt:{opt ADFlags(#)}}Specifies the maximum number of lags to be considered in the above lag selection process. If not specified, it is automatically determined.{p_end}


{syntab:PDOLS Specific:}
{synopt:{opt lags}}Specifies the number of lags and leads to be included in the DOLS regression. Defaults to 2 if not specified.{p_end}
{synopt:{opt full}}Reports the DOLS regression for each individual in the panel.{p_end}
{synopt:{opt average(string)}}Average can be {it:simple}, {it:sqrt}, and {it:precision}. Determines the methodology used to combine individual estimates into the panel estimate. {it:Simple} takes a simple average, and is the behaviour of Pedroni's original program (it is the default). {it:Sqrt} weighs each individual estimate according to the square root of the precision matrix, which is the same procedure used for averaging the t-statistics. {it:Precision} weighs each individual's estimates by their precision.{p_end}


{title:Examples}

{phang}{cmd:. xtpedroni y x1 x2, full notest}

{phang}{cmd:. xtpedroni y x1 x2 x3 x4, nopdols trend lagselect(hqic) adflags(8)}

{phang}{cmd:. xtpedroni y x1, notdum b(1) lags(4)}

{title:Also see}

{psee}
{space 2}Online:  {helpb xtdata}, {helpb xtunitroot}, {helpb xtset}, {helpb xtreg}, {helpb xtpmg}
{p_end}
