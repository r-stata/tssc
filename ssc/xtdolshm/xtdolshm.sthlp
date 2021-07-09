{smcl}
{* *! version 2.0  // A METTRE}{...}
{cmd:help xtdolshm}
{hline}

{title:Title}

{pstd}
    {hi: Performs Dynamic Ordinary Least Squares for Cointegrated Panel Data with homogeneous covariance structure}



{title:Syntax}

{p 8 17 2}
{cmd:xtdolshm}
{depvar}
{indepvars}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt L:evel}}set confidence level; default is {hi:level(95)} {p_end}
{synopt:{opt nla:gs}}specify the number of lags {p_end}
{synopt:{opt nle:ads}}specify the number of leads {p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:xtdolshm}; see {helpb tsset}.{p_end}
{p 4 6 2}
{indepvars} may contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is allowed with {hi:xtdolshm} if no time-series operators are used in the command line;
see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:xtdolshm} fits a model of {hi:depvar} on {hi:indepvars} using Kao and Chiang (2000) Dynamic 
Ordinary Least Squares (DOLS) for Cointegrated Panel Data with homogeneous long-run covariance 
structure across cross-sectional units. When your variables are non-stationary ({hi:I(1)}) and 
are cointegrated, this command allows you to obtain a cointegration regression between your 
dependent variable and your regressors.




{title:Options}

{dlgtab:Main}

{phang}
{opt level(#)} sets confidence level; default is {hi:level(95)}.

{phang}
{opt nlags(integer)} indicates the number of lags, default is {hi:2}.

{phang}
{opt nleads(integer)} indicates the number of leads, default is {hi:1}.



{title:Options for {help predict}}

{p 4 8 2}{cmd:xb}, the default, calculates the linear prediction from the long-run coefficients. {p_end}

{p 4 8 2}{cmdab:dolsr:es} calculates the dols residuals. {p_end}



{title:Citation}

{pstd}
{hi:xtdolshm} is not an official Stata command. The main program of this command is an adaptation
of Kao and Chiang (2002) Gauss corresponding original procedure. It is entirely written in the new
powerful and wonderful Stata Matrix Programming Language {bf:{help Mata}}. The usual disclaimers
apply: all errors and imperfections in this package are mine and all comments are very welcome.



{title:Remarks}

{pstd}
The package {hi:xtdolshm} rely on the package {bf:{help ltimbimata}}. Hence you must install
{bf:{help ltimbimata}} to make {hi:xtdolshm} work. To install the package {bf:{help ltimbimata}}
from within {hi:Stata}, please click on: {stata "ssc install ltimbimata, replace"}. Note that
you must be connected to Internet for this action to work. The command {hi:xtdolshm}  now works
with {bf:{help test}}, {bf:{help predict}}, {bf:{help outreg}} (if installed), {bf:{help outreg2}}
(if installed) and all {hi:Stata} commands that allow tabulating estimations results. Also note 
that fixed effects are internally handled in the command but they are not displayed.



{title:Return values}

{col 4}Scalars
{col 8}{cmd:e(N)}{col 27}Number of observations used
{col 8}{cmd:e(k1)}{col 27}Number of variables used
{col 8}{cmd:e(T)}{col 27}Time used
{col 8}{cmd:e(N_g)}{col 27}Number of included individuals
{col 8}{cmd:e(r2)}{col 27}R-squared
{col 8}{cmd:e(r2_a)}{col 27}Adj R-squared
{col 8}{cmd:e(g_avg)}{col 27}Average number of observations per included individual
{col 8}{cmd:e(g_min)}{col 27}Lowest number of observations in an included individual
{col 8}{cmd:e(g_max)}{col 27}Highest number of observations in an included indiv.
{col 8}{cmd:e(nlags)}{col 27}Number of lags
{col 8}{cmd:e(nleads)}{col 27}Number of leads
{col 8}{cmd:e(chi2)}{col 27}Wald chi-squared statistic
{col 8}{cmd:e(chi2_p)}{col 27}p value of Wald statistic

{col 4}Macros
{col 8}{cmd:e(cmdline)}{col 27}Command as typed by the user
{col 8}{cmd:e(cmd)}{col 27}"xtdolshm", command name
{col 8}{cmd:e(predict)}{col 27}Program used to implement predict
{col 8}{cmd:e(ivar)}{col 27}Individual (panel) variable
{col 8}{cmd:e(depvar)}{col 27}Dependent variable
{col 8}{cmd:e(properties)}{col 27}sets the e(properties) macro

{col 4}Matrices
{col 8}{cmd:e(b)}{col 27}Coefficient vector
{col 8}{cmd:e(V)}{col 27}Variance-covariance matrix
{col 8}{cmd:e(omega_1_2)}{col 27}The estimated long-run conditional variance

{col 4}Functions
{col 8}{cmd:e(sample)}{col 27}Marks estimation sample



{marker remarks1}{...}
{title:Examples}

{p 4 8 2} Before beginning the estimations, we use the {hi:set more off} instruction to tell
{hi:Stata} not to pause when displaying the output. {p_end}

{p 4 8 2}{stata "set more off"}{p_end}

{p 4 8 2} We illustrate the use of the command {hi: xtdolshm} with the dataset {hi: xtdolshmdata.dta}.
This dataset contains panel data of 51 countries from 1975 to 2004. {p_end}

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/x/xtdolshmdata.dta, clear"}{p_end}

{p 4 8 2} Next we describe the dataset to see the definition of each variable. {p_end}

{p 4 8 2}{stata "describe"}{p_end}

{p 4 8 2} We regress iskr (dependent variable) on the regressors (gdskr irxmap1 defigd2 ltinflcd
opins2 totwdct ltdgdpd). It appears from this estimation that real effective exchange rate (REER) volatility
has significant negative effect on investment. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct ltdgdpd"}{p_end}

{p 4 8 2} We show how to use the options {opt nlags()} and {opt nleads()}. We increase the number
of lags to 3 and the number of leads to 4. The regression indicates that REER Volatility is still
negatively linked with investment. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct, nla(3) nle(4)"}{p_end}

{p 4 8 2} We estimate the previous equation with a 90% confidence interval. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct, nla(3) nle(4) level(90)"}{p_end}

{p 4 8 2} We illustrate the use of a time series operator by lagging inflation by one period. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 l.ltinflcd opins2 totwdct"}{p_end}

{p 4 8 2} Now we show how to use the package {hi:xtdolshm} with the command {manhelp by D}. First we
tabulate the variable income levels. {p_end}

{p 4 8 2}{stata "tab inclevel"}{p_end}

{p 4 8 2} Then we sort the dataset by income levels. {p_end}

{p 4 8 2}{stata "sort inclevel"}{p_end}

{p 4 8 2} Finally we use the command {hi:xtdolshm} with {manhelp by D}. We observe that REER volatility
continues to be negative and significant in both income categories.  {p_end}

{p 4 8 2}{stata "by inclevel: xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct ltdgdpd"}{p_end}

{p 4 8 2} Let us illustrate how the command {hi:xtdolshm} works with {bf:{help test}}. First, we restore the
original ordering of the dataset. {p_end}

{p 4 8 2}{stata "tsset"}{p_end}

{p 4 8 2} Second, we perform the following regression. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct"}{p_end}

{p 4 8 2} Third, we test that the coefficients on irxmap1 and opins2 are jointly equal to 0. {p_end}

{p 4 8 2}{stata "test (irxmap1=0) (opins2=0)"}{p_end}

{p 4 8 2} The result suggests that the coefficients of the two variables are jointly different to 0. {p_end}

{p 4 8 2} We can also run the regressions on subsamples. Here we estimate a model for the years before 1990. {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct ltdgdpd if year < 1990"}{p_end}

{p 4 8 2} We notice that real effective exchange rate volatility still negatively influences investment. {p_end}

{p 4 8 2} To finish this example section, we now illustrate how to use the command {hi:xtdolshm} with
{bf:{help predict}}. We start by running the following regression.  {p_end}

{p 4 8 2}{stata "xtdolshm iskr gdskr irxmap1 defigd2 ltinflcd opins2 totwdct ltdgdpd"}{p_end}

{p 4 8 2} We calculate the linear prediction from the long-run coefficients. {p_end}

{p 4 8 2}{stata "predict linpred, xb"}{p_end}

{p 4 8 2} We calculate the dols residuals. {p_end}

{p 4 8 2}{stata "predict dolsresiduals, dolsres"}{p_end}



{title:References}

{pstd}
Kao, C. and Chiang, M. H.: 2002, "Nonstationary Panel Time Series Using NPT 1.3 - A User Guide," Center for Policy Research, Syracuse University.
Downloadable at: {browse "http://faculty.maxwell.syr.edu/cdkao/working/npt.html"}.
{p_end}

{pstd}
Kao, C. and Chiang, M. H.: 2000, "On the estimation and inference of a cointegrated regression in panel data", Advances in Econometrics 15, 179-222.
{p_end}



{title:Author}

{p 4}Diallo Ibrahima Amadou {p_end}
{p 4}CERDI, University of Auvergne {p_end}
{p 4}65 bd Francois Mitterrand  {p_end}
{p 4}63000 Clermont-Ferrand   {p_end}
{p 4}France {p_end}
{p 4}{hi:E-Mail}: {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for {bf:{help xtpmg}} (if installed), {bf:{help xtwest}} (if installed), {bf:{help xtmg}} (if installed), {bf:{help mata}}, {bf:{help ltimbimata}}
{p_end}

