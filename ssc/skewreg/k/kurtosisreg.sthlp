{smcl}
{* *! version 1.0.0  21july2020}{...}
{cmd: help kurtosisreg}
{hline}

{title:Title}

{phang}
{bf: kurtosisreg {hline 2} Kurtosis Regression}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt kurtosisreg} {depvar} [{indepvars}] {ifin} 
   [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt r:eps(#)}}specify number of bootstrap replications; default is {cmd:reps(50)} {p_end}
{synopt :{opt s:eed(#)}}set random seed; default is {cmd:seed(1)} {p_end}

{syntab:Reporting}
{synopt :{opt d:etail}}show detailed results{p_end}
{synopt :{opt g:raph}}graph coefficients and confidence intervals{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt p:redict(string)}}predict conditional kurtosis{p_end}

{synoptline}
INCLUDE help fvvarlist
{p 4 6 2}
{cmd:by} and {cmd: bysort} are allowed; see {help prefix}.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:kurtosisreg} performs kurtosis regression for cross-sectional or time-series data as defined in Chen and Xiao (2020), which quantifies the effects of covariates on quantile-based measure of kurtosis of the conditional distribution.  
{cmd:kurtosisreg} calls {help sqreg} for simultaneous quantile regression, which reports bootstrap standard errors. 
{cmd:kurtosisreg} then use {help margins} to computes average marginal effects (AME), which are parameters of interest. 
For a continuous variable {cmd:x}, AME is defined as marginal effects ({cmd:dy/dx}) averaged over all observations. For discrete variables, marginal effects are defined as discrete changes from the base level. 
For example, for a dummy variable {cmd:x}, AME is defined as {cmd:(y|x=1)-(y|x=0)}, averaged over all observations. Standard errors for AMEs are obtained by the delta method from bootstrap standard errors. 

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt reps} specify the number of bootstrap replications used for obtaining bootstrap standard errors. The default is {cmd:reps(50)} for fast computation, but {cmd:reps(500)} is recommended for accurate results. 

{phang}
{opt seed} set random seed for reproducible results. The default is {cmd:seed(1)}. 

{dlgtab:Reporting}

{phang}
{opt detail} show detailed results, including simultaneous quantile regression, the numerator and denominator parts of kurtosis regression.

{phang}
{opt graph} graph coefficients of kurtosis regression to visualize average marginal effects and their confidence intervals.

{phang}
{opt level(#)} set confidence level for confidence intervals in both regression results and graph. The default is {cmd:level(95)} for the 95% confidence level. 

{phang}
{opt predict(string)} predict conditional kurtosis for possible later usage.

{marker examples}{...}
{title:Examples: fast but trivial}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto,clear}{p_end}

{pstd}Fit a default kurtosis regression (for correct computation of AME, use "i.foreign" even though "foreign" is a dummy variable){p_end}
{phang2}{cmd:. kurtosisreg price mpg weight i.foreign}{p_end}

{pstd}Fit a kurtosis regression with detailed output, 90% confidience intervals, coefficient graph, and record predicted conditional kurtosis as a new variable {cmd:kurtosis} {p_end}
{phang2}{cmd:. kurtosisreg price mpg weight i.foreign, detail level(90) graph predict(kurtosis)}{p_end}

{pstd}Fit a kurtosis regression with random seed 123 and 500 bootstrap replications{p_end}
{phang2}{cmd:. kurtosisreg price mpg weight i.foreign, seed(123) reps(500)}{p_end}

{pstd}Fit a kurtosis regression in a subsample{p_end}
{phang2}{cmd:. kurtosisreg price mpg weight i.foreign if rep78==3}{p_end}

{marker examples}{...}
{title:Examples: slow but interesting}

{pstd}Setup (1% US census data in 1980 obtained from Angrist et al.(2006). After loading data, use command {help notes} for a detailed description){p_end}
{phang2}{cmd:. use census80.dta, clear}{p_end}

{pstd}Fit a default kurtosis regression (for correct computation of AME, use factor variable (see {help fvvarlist}) {cmd:c.exper#c.exper} so that Stata recognizes it as the square of {cmd:exper}){p_end}
{phang2}{cmd:. kurtosisreg logwk educ i.black exper c.exper#c.exper}{p_end}

{pstd}Test joint significance of coefficients following the above kurtosis regression{p_end}
{phang2}{cmd:. test educ 1.black exper}{p_end}

{pstd}Fit a kurtosis regression with detailed output, 90% confidience intervals, coefficient graph, and record predicted conditional kurtosis as a new variable {cmd:kurtosis} {p_end}
{phang2}{cmd:. kurtosisreg logwk educ i.black exper c.exper#c.exper, detail level(90) graph predict(kurtosis)}{p_end}

{pstd}Fit a kurtosis regression with random seed 123 and 500 bootstrap replications (very slow){p_end}
{phang2}{cmd:. kurtosisreg logwk educ i.black exper c.exper#c.exper, seed(123) reps(500)}{p_end}

{pstd}Fit a default kurtosis regression for the black and non-black subsamples respectively via {help bysort}{p_end}
{phang2}{cmd:. bysort black: kurtosisreg logwk educ exper c.exper#c.exper}{p_end}

{marker examples}{...}
{title:Examples: time series}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse sp500.dta, clear}{p_end}

{pstd}Since {help sqreg} doesn't accept time-series operators (see {help tsvarlist}), {cmd:kurtosisreg} doesn't either. So define one-period lagged variable manually{p_end}
{phang2}{cmd:. tsset date}{p_end}
{phang2}{cmd:. gen l1_close = l.close}{p_end}

{pstd}Fit a default kurtosis regression{p_end}
{phang2}{cmd:. kurtosisreg close l1_close}{p_end}

{pstd}Fit a kurtosis regression with detailed output, 90% confidience intervals, coefficient graph, and record predicted conditional kurtosis as a new variable {cmd:kurtosis} {p_end}
{phang2}{cmd:. kurtosisreg close l1_close, detail level(90) graph predict(kurtosis)}{p_end}

{pstd}Fit a kurtosis regression with random seed 123 and 500 bootstrap replications{p_end}
{phang2}{cmd:. kurtosisreg close l1_close, seed(123) reps(500)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:kurtosisreg} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(reps)}}number of bootstrap replications{p_end}
{synopt:{cmd:e(seed)}}random seed number{p_end}
{synopt:{cmd:e(q1)}}quantile of first simultaneous quantile regression{p_end}
{synopt:{cmd:e(q2)}}quantile of second simultaneous quantile regression{p_end}
{synopt:{cmd:e(q3)}}quantile of third simultaneous quantile regression{p_end}
{synopt:{cmd:e(q4)}}quantile of fourth simultaneous quantile regression{p_end}
{synopt:{cmd:e(q5)}}quantile of fifth simultaneous quantile regression{p_end}
{synopt:{cmd:e(q6)}}quantile of sixth simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q1)}}pseudo R2 of first simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q2)}}pseudo R2 of second simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q3)}}pseudo R2 of third simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q4)}}pseudo R2 of fourth simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q5)}}pseudo R2 of fifth simultaneous quantile regression{p_end}
{synopt:{cmd:e(pr_q6)}}pseudo R2 of sixth simultaneous quantile regression{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(vcetype)}}Delta-method{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:kurtosisreg}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}Kurtosis{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector, i.e. average marginal effects{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{marker author}{...}
{title:Author}

{phang}
Qiang Chen, School of Economics, Shandong University, P. R. China{p_end}
    qiang2chen2@126.com
    {browse "www.econometrics-stata.com"}       

{marker references}{...}
{title:References}

{marker ACF2006}{...}
{pstd}
Angrist, Joshua, Victor Chernozhukov and Iván Fernández-Val, 2006.{browse "https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-0262.2006.00671.x": Quantile Regression under Misspecification, with an Application to the U.S. Wage Structure}. 
{it:Econometrica}, 74(2), 539-563. 

{marker CX2020}{...}
{phang}
Chen, Qiang, and Zhijie Xiao, 2020, "Spread Regression, Skewness Regression and Kurtosis Regression with an Application to the U.S. Wage Structure," Shandong University working paper.

