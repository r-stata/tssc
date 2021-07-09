{smcl}
{right:version:  3.4}
{cmd:help asreg} {right:June 15, 2019}
{hline}
{viewerjumpto "Options" "asreg##options"}{...}
{viewerjumpto "fmb" "asreg##fmb"}{...}
{viewerjumpto "newey" "asreg##newey"}{...}
{viewerjumpto "first" "asreg##first"}{...}
{viewerjumpto "save" "asreg##save"}{...}
{viewerjumpto "examples" "asreg##examples"}{...}

{title:Title}

{p 4 8}{cmd:asreg}  -  Rolling window regressions and by(group) regressions {p_end}


{title:Syntax}

{p 8 15 2}
[bysort varlist:] {cmd:asreg}
{depvar} {indepvars} {ifin} 
[, {cmdab:w:indow(}{it:rangevar # }{cmd:)}
{cmdab:noc:onstant:}{cmd:}
{cmdab:rec:ursive:}{cmd:}
{cmdab:min:imum:(}{it:#}{cmd:)}
{cmdab:by:(}{it:varlist}{cmd:)}
{help asreg##Options:{statistics_options} }
{help asreg##newey:newey(#)}
{help asreg##fmb:fmb}
{help asreg##save:save(file name)}
{help asreg##first:first}]

{title:Description}

{p 4 4 2} {cmd: asreg} fits a model of depvar on indepvars using linear regression in a user's defined rolling window 
or by a grouping variable. asreg is order of magnitude faster than estimating rolling window regressions through conventional
methods such as Stata loops or using the Stata's official {help rolling} command. {help asreg} has the same speed efficiency as
{help asrol}. All the rolling window calculations, estimation of regression parameters, and writing the results to Stata variables
are done in the Mata language.


{title:Web Page}

{p 4 4 2} There is a dedicated {browse "https://fintechprofessor.com/stata-programs/asreg-a-powerful-package-for-regressions-in-stata/":web page}
of asreg on my website {browse "https://fintechprofessor.com/": www.FinTechProfessor.com}. The webpage lists different helping
material related to asreg. These materials include YouTube videos, blog posts on different situations where asreg
can be used, and some questions and answers.{p_end} 
 

{title:Speed Optimization}
 {p 4 4 2} Rolling window calculations require lots of looping over observations. The problem is compounded by different data structures such as unbalanced panel data,
 data with many duplicates, and data with many missing values. Yet, there might be data sets that have both time series gaps as well as many duplicate observations
 across groups. {help asreg} does not use a static code for all types of data structures. Instead, {help asreg} intelligently identifies data structures and matches
one of its rolling window routines with the data characteristics. Therefore, the rolling window regressions are fast even in larger data sets. {p_end} 

 
{p 4 4 2} {cmd: asreg} writes all regression outputs to the data in memory as separate variables. This eliminates the need for
writing the results to a separate file, and then merging them back to the data for any further calculations. New variables
from the regression results follow the following naming conventions: {p_end}


{dlgtab:Regression statistics and their names}
 {p 4 4 2}
 
 {p2colset 8 29 29 2}{...}
{p2col :{opt observations}}variable containing number of observation is named as {cmd:obs_N}{p_end}
{p2col :{opt regression slopes}}a prefix of {cmd: _b_} is added to the name of each independent variables{p_end}
{p2col :{opt constant}}variable containing constant of the regression is names as {cmd: _b_cons}{p_end}
{p2col :{opt r-squared}}r-squared and adj. r-squared are named as {cmd:R2} and {cmd:AdjR2} , respectively{p_end}
{p2col :{opt RMSE}}root-mean-square error. This variable is named as {cmd:_rmse}.{p_end}
{p2col :{opt standard errors}}a prefix of {cmd: _se_} is added to the name of each independent variables. asreg can estimate three types of coefficient errors: See {help asreg##errors:Section 5 below} {p_end}
{p2col :{opt residuals}}variable containing residuals is named as {cmd:_residuals} {p_end}
{p2col :{opt fitted}}variable containing fitted values is named as {cmd:_fitted}.{p_end}

{marker asreg_options}{...}
{dlgtab:Options}

{p 4 4 2} 
{cmd:asreg} has the following options. {p_end}

{p 4 4 2} 1. {opt w:indow}: specifies length of the rolling window.  The {opt w:indow} option needs two arguments.
 The first argument must be a name of a numeric variable that will be used as a range variable (rangevar). Such a variable is usually
 a time-based variable such as years, months, days etc. The second arguments should be an integer that will specify the length of the rolling window. 
For example, if our time variable is year and we want a rolling window of 24,
 then option {opt w:indow} will look like: {p_end}
 
{p 8 8 2} {opt w:indow( year 24)} {p_end}

{p 4 4 2} NOTE: Option window is an optional option, and hence it can be dropped altogether. This is useful when we are interested in by-group regressions without using
rolling window. For example, if we have a large cross-section of industries or firms and we wish to estimate a separate regressions for each cross-section, we shall
drop option window. See Example 6 below. {p_end}

{p 4 4 2} 2. {opt rec:ursive}: The option recursive specifies that a recursive window be used. In time series analysis, a recursive window refers to 
a window where the starting period is held fixed, the ending period advances, and the window size grows (see for example, {help rolling}). {help asreg}
allows a recursive window either by invoking the option {opt rec:ursive} or setting the length of the window greater than or equal to the sample size per group. 
For example, if sample size of our data set is 1000 observation per group, we can use a {opt rec:ursive} analysis by setting the window length equal to 1000 or greater than 1000 {p_end}
		
{p 4 4 2} 3. {opt by}: {cmd: asreg} is {help byable}. Hence, it can be run on groups as specified by option {help by}({it:varlist}) or the {help bysort} {it: varlist}: prefix.
An example of such regression might be {browse "https://en.wikipedia.org/wiki/Fama%E2%80%93MacBeth_regression": Fama and MacBeth (1973)} first stage regression, which is estimated 
cross-sectionally in each time period. Therefore, the grouping {help variable} in this case would be 
the time variable. Assume that we have our dependent variable named as{it: stock_returns}, independent variable as  {it: stock_betas}, and time variable as 
{it:month_id}, then to estimate the cross-sectional
regression for each month, {help asreg} command will look like:

 {p 4 4 2}{stata "bys month_id: asreg stock_returns  stock_betas" :. bys month_id: asreg stock_return  stock_betas} {p_end}
 
 {p 4 4 2} 4. {opt  min:imum}: {help asreg} estimates regressions where number of observations are greater than number of regressors.
 However, there is a way to limit the regression estimates to a desired number of observations. The option {opt min:imum}
 can be used for this purpose. If option {opt min} is used, {help asreg} then finds the required number of observation for the regression estimated such that : {p_end}
 {p 4 8 2} obs = max(number of regressors (including the intercept), minimum observation as specified by the option {opt min}). {p_end}
 {p 4 4 2} For example, if we have 4 explanatory variables, then the number of regressors will be equal to 4 plus 1 i.e. 5. 
 Therefore, if {help asreg} receives the value of 8 from the option {opt min}, the required number of observations will be : max(5,8) = 8. If a specific
 rolling window does not have that many observations, values of the new variable will be replaced with missing values. {p_end}
{marker Options}
 {dlgtab:Statistics_Options}

{p2colset 8 21 21 2}{...}
{p2col :{opt fit:ted}}reports {stata help regress postestimation##predict:residuals} and fitted values for the last observation in the rolling window. 
If option window is not specified, then the residuals are calculated within each group as specified by the option {help by}({it:varlist}) or the {help bysort} {it: varlist}: {p_end}
{p2col :{opt se:rror}}reports standard errors for each explanatory variable{p_end}
{p2col :{opt rmse}}reports root-mean-squared error of OLS regression{p_end}
{p2col :{opt noc:onstant}}suppresses the constant term (intercept) in the model (this option is not available in the Fama-MacBeth regression i.e., when using option {opt fmb}{p_end}
{p2col :{opt other}}Most commonly used regression statistics such as number of observations, slope coefficients, r-squared, and adjusted r-squared are
written to new variables by default. Therefore, if these statistics are not needed, they can be dropped once asreg is estimated.{p_end}

{marker errors}
 {p 4 4 2} 5. {opt  Coefficient errors}: {help asreg} can estimate three types of coefficient errors. The first type is the standard errors. Standard errors are
 the default option in asreg. They are reported only when option {opt se} is used. The second type is the {browse "https://www.stata.com/support/faqs/statistics/robust-standard-errors/": robust standard errors}
 which are reported when option {opt r:obust} is used (this option is not available in the Fama-MacBeth regression i.e., when using option {opt fmb}. The third type is the {help newey:Newey-West} standard errors which are reported when option {opt newey(#)} is used, see
 further details {help asreg##newey:here}.
 
 

{marker fmb}
{title:FMB: Fama and McBeth(1973) regression}

{p 4 4 2} Option {cmd: fmb} applies a two-step Fama-McBeth procedure. The first step involves estimation of N cross-sectional regressions and the second steps involves T time-series
averages of the coefficients of the N-cross-sectional regressions. The standard errors are adjusted for cross-sectional dependence. This is generally an acceptable solution when
there is a large number of cross-sectional units and a relatively small time series for each cross-sectional unit. However, if both cross-sectional and time-series dependence are
suspected in the data set, then Newey-West consistent standard errors can be used. {cmd:asreg} uses the first method as a default. {p_end}

{p 4 4 2} {cmd:asreg} with optoin {cmd: fmb} is very similar to {stata "ssc des xtfmb" : xtfmb} program that was written by Daniel Hoechle, with the
following three major differences: (i) {cmd:fmb} estimates the cross-sectional regressions using Mata language, while {cmd:xtfmb} does that using the {help statsby} command. In case the data
set is very large, this makes a huge difference in the run-time of the two programs. (ii) {cmd: fmb} allows estimation of Newey-West standard errors even if the data set has time-series gaps while 
{cmd:xtfmb} exits with an error message if the data has time-series gaps. (iii) {cmd: fmb} allows to save coefficients of the first stage regression with the option
{opt save(filename)} to the current folder.

{marker save}
{p 4 4 2} {opt  6. save(filename)}: Option {opt save} is used only when option {opt fmb} is used. Option {opt save} saves the first stage regression coefficients of the Fama-McBeth 
regression to a file. 

{marker newey}
{p 4 4 2} {opt  7. newey(integer)}: {opt newey} specifies the number of lags for estimation of Newey-West consistent standard errors. {cmd: asreg} allows option {opt newey} to be used in both the rolling
regressions and Fama-McBeth regressions. In the rolling regressions, {opt newey} will work only when option {opt se} is used. Also, please note that without using option {opt newey},
 option {opt se} estimates normal standard errors of OLS. This option accepts only integers, for example {opt newey(1)} or {opt newey(4)} are acceptable, but {opt newey(1.5)} 
 or {opt newey(2.3)} are not.

 {marker first}
{p 4 4 2} {opt  8. first}: This option will work only when option {opt fmb} is invoked. Option {opt first} displays on screen the first-stage regression coefficients of the Fama-McBeth regressions.

{marker examples}
 {dlgtab:Examples}

 
 {title:Example 1: Regression for each company in a rolling window of 10 years}
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10)" :. bys company: asreg invest mvalue kstock, wind(year 10)} {p_end}

 {title:Example 2: Regression for each company in a recursive window}
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) rec" :. bys company: asreg invest mvalue kstock, wind(year 10) rec} {p_end}
 {p 4 8 2} OR {p_end}

  {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 1000)" :. bys company: asreg invest mvalue kstock, wind(year 1000)} {p_end}

 
 {title:Example 3: Using option minimum}
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) min(5)" :. bys company: asreg invest mvalue kstock, wind(year 10) min(5)} {p_end}

 
 
 {title:Example 4: Reporting standard errors} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) se" :. bys company: asreg invest mvalue kstock, wind(year 10) se} {p_end}
 
 
 {title:Example 5: Newey-West standard errors, lag(1)} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) se newey(1)" :. bys company: asreg invest mvalue kstock, wind(year 10) se newey(1)} {p_end}

 
 {title:Example 6: Robust standard errors} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) robust" :. bys company: asreg invest mvalue kstock, wind(year 10) robust} {p_end}

 
 
 {title:Example 7: Reporting standard errors, fitted values and residuals} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) se fit" :. bys company: asreg invest mvalue kstock, wind(year 10) se fit} {p_end}

 
  {title:Example 8: Regressions without constant} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, wind(year 10) noc" :. bys company: asreg invest mvalue kstock, wind(year 10) noc} {p_end}


 
 {title:Example 9: No window - by groups regressions} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock" :. bys company: asreg invest mvalue kstock} {p_end}

 
 
 {title:Example 10: Yearly cross-sectional regressions} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys year: asreg invest mvalue kstock" :. bys year: asreg invest mvalue kstock} {p_end}
 

 {title:Example 11: Rolling regression - reporting RMSE} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "bys company: asreg invest mvalue kstock, w(year 10) rmse" :. bys company: asreg invest mvalue kstock, w(year 10) rmse} {p_end}
 
 
 {title:Example 12: Fama and McBeth Regression} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "asreg invest mvalue kstock, fmb" :. asreg invest mvalue kstock, fmb} {p_end}
 
 
 {title:Example 13: Fama and McBeth Regression - using Newey-West errors} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "asreg invest mvalue kstock, fmb newey(1)" :. asreg invest mvalue kstock, fmb newey(1)} {p_end}


 {title:Example 14: Fama and McBeth Regression - report first stage regression} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "asreg invest mvalue kstock, fmb first" :. asreg invest mvalue kstock, fmb first} {p_end}
 
 
 {title:Example 15: Fama and McBeth Regression - save first stage results} 
 {p 4 8 2}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}
 {p 4 8 2}{stata "asreg invest mvalue kstock, fmb save(FirstStage)" :. asreg invest mvalue kstock, fmb save(FirstStage)} {p_end}

 
 {title:Stored Results from option FMB}
  {p 4 8 2} {cmd: asreg} returns the following scalars, macros and matrices in eclass for Fama-McBeth regressions.
  
  
 scalars:
                  e(N) =  number of observation
                e(N_g) =  number of groups
               e(df_r) =  degrees of freedom
                  e(F) =  F-test value
                e(r2)  =  average r-squared
			 e(adjr2)  = average Adjusted r-squared

macros:
                  e(2) : "average r-squared"
               e(cof1) : "coefficient of the first independent variable"
                e(cmd) : "command name"
             e(method) : "Fama-MacBeth Two-Step procedure"
             e(depvar) : "invest"
            e(vcetype) : "Fama-MacBeth"
         e(properties) : "b V"

matrices:
                  e(b) :  vector of slopes
                  e(V) :  variance-covariance matrix


{title:WANNA SAY THANKS? }
				  

{p 4 4 2} It is almost now two years to code, improve, and upate asreg. Specfically, I have taken much of the time
to increase the calculation efficiency of asreg. As you would experience, asreg is extremely efficient in rolling window
regression, cross-sectional regressions and Fama and MacBeth (1973) regressions. If you like it and find it useful,
please do cite it in your research work [{help asreg##cite:See how to cite it}] and send your thanks and 
comments to attaullah.shah@imsciences.edu.pk. If you think that you can thank me
otherwise, then my {bf:Paypal} account address is {bf:attaullah.shah@imsciences.edu.pk} 
A small token of thanks will suffice.  

{marker cite}
{title:HOW TO CITE }

{p 4 4 2} {bf: In-text citation style} : You can mention the following:

{p 4 4 2} {bf: Regressions were estimated using asreg program, written by Shah (2017).}

{p 4 4 2} {bf: Bibliography citation style} :

{p 4 4 2} Attaullah Shah, (2017). "ASREG: Stata module to estimate rolling window regressions, Fama-MacBeth and by(group) regressions,"
{it:Statistical Software Components S458339, Boston College Department of Economics}, revised 16 Nov 2018"


{title:AUTHOR}

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*           {browse "www.FinTechProfessor.com": www.FinTechProfessor.com}                                 *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{browse "http://www.opendoors.pk/home/paid-help-in-empirical-finance/stata-program-to-construct-j-k-overlappy-momentum-portfolios-strategy": asm    : for momentum portfolios}   {p_end}
{psee}{stata "ssc desc asdoc":asdoc : Creates high-quality tables in MS Word from Stata output} {p_end}
{psee}{stata "ssc desc astile":astile : for creating quantile groups} {p_end}
{psee}{stata "ssc desc asreg":asgen : for weighted average mean} {p_end}
{psee}{stata "ssc desc asrol":asrol : for rolling window statistics} {p_end}
{psee}{stata "ssc desc ascol":ascol : for coverting share prices and returns from daily to weekly or monthly frequency} {p_end}
{psee}{stata "ssc desc searchfor":searchfor : for searching text in data sets} {p_end}




