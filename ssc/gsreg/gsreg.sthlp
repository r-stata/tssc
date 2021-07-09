{smcl}
{* *! version 1.0  19nov2013}{...}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:gsreg} {hline 2}}Global Search Regression {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:gsreg} {depvar} {varlist:_ocand} {ifin} {weight} 
[{cmd:, } 
{opt nc:omb(#1,#2)}
{opt same:sample}
{opt vs:elect}
{opt dl:ags(numlist)}
{opt il:ags(numlist)}
{opt l:ags(numlist)}
{opt f:ixvar(varlist_fix)}
{opt sc:hange(varname_sc)}
{opt int:eractions}
{opt sq:uares}
{opt cub:ic}
{opt fixint:eractions}
{opt o:utsample(#)}
{opt cmde:st(commandname)}
{opt cmdo:ptions(commandoptions)}
{opt cmds:tat(commandstats)}
{opt cmdi:veq(varlist_end = varlist_inst)}
{opt aic:bic}
{opt het:test}
{opt hettest_o(hettestmoptions)}
{opt arc:hlm}
{opt archlm_o(archlmoptions)}
{opt bgod:frey}
{opt bgodfrey_o(bgodfreyoptions)}
{opt dur:binalt}
{opt durbinalt_o(durbinaltoptions)}
{opt dw:atson}
{opt sk:test}
{opt sktest_o(sktestoptions)}
{opt sw:ilk}
{opt swilk_o(swilkoptions)}
{opt sf:rancia}
{opt test:pass(#)}
{opt res:ultsdta(newbasename)}
{opt rep:lace}
{opt do:uble}
{opt noco:unt}
{opt com:pact}
{opt ni:ndex(lcimplist)}
{opt mi:ndex(lcimplist)}
{opt best(#)}
{opt back:up(#)}
{opt p:art(#1,#2)}]

{phang2}{cmd:fweight}s, {cmd:aweight}s, and {cmd:pweight}s are allowed depending on the estimation command specified in {opt cmdest(commandname)}; see
{help weight}. {p_end}

{*:*****************************************************************************************}
{title:Sections}
{*:*****************************************************************************************}
{pstd} 
Main sections are presented under the following headings:
{p_end}

{phang2} {it:{help gsreg##Description:Description}} {p_end}
{phang2} {it:{help gsreg##Options:Options}} {p_end}
{phang2} {it:{help gsreg##Examples:Examples}} {p_end}
{phang2} {it:{help gsreg##Saved_results:Saved results}} {p_end}

{*:*****************************************************************************************}
{marker Description}{...}
{title:Description}
{*:*****************************************************************************************}
{pstd} 
{cmd:gsreg} is an automatic model selection command for time series,
cross-section and panel data regressions. By default (otherwise, users 
have many options to modify this simplest specification), gsreg performs 
alternative OLS regressions looking for the best {depvar} Data Generating 
Process, iterating over all possible combinations among explanatory variables 
specified in {varlist:_ocand}. Regression results are stored in a .dta file 
named as {it:gsreg.dta}, and saved in the working directory. This database 
assigns one row for each regression and includes the following columns: 
{p_end}

{marker list1}{...}
{phang} 1) regression id (variable {it:order}){p_end}
{phang} 2) covariate regression coefficients (named {it:v_1_b, v_2_b… , etc.}, 
and labeled with the full covariate name plus the word “coeff.”) {p_end}
{phang} 3) coefficient t-statistics (named {it:v_1_t, v_2_t…, etc.}, and labeled
with the full covariate name plus the word “tstat.”) {p_end}
{phang} 4) number of observations (variable {it:obs}) {p_end}
{phang} 5) number of covariates -including the intercept- (variable {it:nvar}) {p_end}
{phang} 6) adjusted R2 (variable {it:r_sqr_a}) {p_end}
{phang} 7) in-sample root mean square error (variable {it:rmse_in}) {p_end}
{phang} 8) normalized linear combination of user selected (and weighted) model 
selection criteria (as nindex or mindex if this option is specified). 
By default nindex is the normalized adjusted R2. {p_end}

{phang}{cmd:.gsreg depvar ocand1 ocand2}{p_end}

{pstd} runs the 3 following regressions {p_end}
{pstd} {it: regress depvar ocand1} {p_end}
{pstd} {it: regress depvar ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2} {p_end}
{pstd} and generates a {it:gsreg.dta } database like: {p_end}

order	v_1_b	v_1_t	v_2_b	v_2_t	v_3_b	v_3_t	obs	nvar	r_sqr_a	rmse_in	nindex
1	#	#			#	#	#	2	#	#	#
2			#	#	#	#	#	2	#	#	#
3	#	#	#	#	#	#	#	3	#	#	#

{pstd} Below is a description of each variable of the dataset:{p_end}

{phang} {cmd:.use gsreg.dta} {p_end}
{phang} {cmd:.describe} {p_end}
		
variable	variable label
---------	--------------					
order		order number of estimation
v_1_b		ocand1 coeff.
v_1_t		ocand1 tstat.
v_2_b		ocand2 coeff.
v_2_t		ocand2 tstat.
v_3_b		intercept coeff.
v_3_t		intercept tstat.
obs		number of observations
nvar		number of covariates
r_sqr_a		adjusted R-squared
rmse_in		in-sample RMSE
nindex		normalized linear combination of model selection criteria

{pstd} Back to {it:{help gsreg:Top}} {p_end}

{*:*****************************************************************************************}
{marker Options}{...}
{title:Options}
{*:*****************************************************************************************}
{marker genoption}{...}
{syntab:{it:General options}}
{phang} 
{opt nc:omb(#1,#2)} specifies the minimum and maximum number of variable
(instead of user-specified fixed) covariates to be included in the procedure. {cmd:gsreg} 
will perform all possible combinations (regressions) between candidate variables taken 
from {it:#1} to {it:#2}. {it:#1} must be less or equal to {it:#2} and, additionally, 
the number of candidates must be greater or equal to {it:#2}. If this option is not 
specified, {cmd:gsreg} will run all possible combinations without repetition of size 
1 to n (the total number of candidates). See {it:{help gsreg##egncomb:Examples of using ncomb}} 
{p_end}

{phang} 
{opt same:sample} makes all regressions to be performed over the same
sample of observations, defined as the largest common sample. By default, {cmd:gsreg} 
performs each regression with the maximum number of common observations available 
for the covariate subset used in each particular case. 
See {it:{help gsreg##egsamesample:Examples of using samesample}} 
{p_end}

{phang} 
{opt noco:unt} hides from the screen the number of regression which is being
estimated. If this option is not specified, {cmd:gsreg} will show for each 
alternative model, the regression number (used for identification purposes) and 
the total number of regressions to be estimated.  
{p_end}

{phang} 
{opt back:up(#)} creates {it:#} backup files during the execution of {cmd:gsreg}. Each backup
will contain approximately {it:1/#} regressions. Each file will be saved in the ongoing working 
directory and will be named with the name of the result database ({it:gsreg} by default), 
plus the number of partition and the total number of backups specified in {it:#} 
(eg. {it:gsreg_ part_1_of_#.dta}). All partitions will be deleted at the end of the execution 
of {cmd:gsreg} and result database with all results will be saved. If number of regressions 
is lower than {it:#}, the number of partitions will be reset to the number of regressions.   
See {it:{help gsreg##egbackpart:Examples of using backup and part}} 
{p_end}

{phang} 
{opt p:art(#1,#2)} runs a specific partition of all regressions. The partition will contain
approximately {it:1/#2} regressions. {cmd:gsreg} will save the partition (instead of the result
database) in the ongoing working directory. If total number of regressions is lower than {it:#2}, the 
number of partitions ({it:#2}) will be reset to the number of regressions.   
See {it:{help gsreg##egbackpart:Examples of using backup and part}} 
{p_end}

{phang} 
{opt vs:elect} runs the command {search vselect:vselect} (using the vselect “best” 
option) developed by Charles Lindsey and Simon Sheather (2010), which has to
be previously installed) to obtain the best n regressions (one for each maximum 
number of covariates included in regressions: e.g. the best one covariate model, 
the best two-covariates model, and so on) in terms of in-sample RMSE. Using vselect, 
the only additional gsreg option that can be specified is the fixvar option. 
See {it:{help gsreg##egvselect:Examples of using vselect}} 
{p_end}

{*:*****************************************************************************************}
{marker lag}{...}
{syntab:{it:Lag structure options}}

{phang} 
{opt dl:ags(numlist)} allows to include dependent variable lags ({depvar}) among 
candidate covariates. tsset must be specified when using this option. 
See {it:{help gsreg##eglag:Examples of using dlag, ilags or lags}} 
{p_end}

{phang} 
dlags({it:#}) adds among candidates the {it:#} dependent variable lag. 
{p_end}

{phang} 
dlags({it:#1/#2}) adds among candidates all dependent variable lags from {it:#1} to
{it:#2} considering one-unit intervals. 
{p_end}

{phang} 
dlags({it:#1 #2 #3}) adds among candidates the {it:#1}, the {it:#2}, and the {it:#3} 
dependent variable lags. 
{p_end}

{phang} 
dlags({it:#1 (#d) #2}) adds among candidates all dependent variable lags from {it:#1} 
to {it:#2} considering {it:#d} unit intervals. 
{p_end}

{phang} 
dlags({it:#1 #2 #3 … #4 (#d) #5}) adds among candidates dependent variable lags {it:#1}
, {it:#2}, and {it:#3}, and additionally all dependent variable lags from {it:#4} to
{it:#5} considering {it:#d} unit intervals.
{p_end}

{phang} 
{opt il:ags(numlist)} allows including independent variable lags among original candidates.
The syntax is flexible and identical to that used in {opt dlags}. 
See {it:{help gsreg##eglag:Examples of using dlag, ilags or lags}} 
{p_end}

{phang} 
{opt l:ags(numlist)} allows to jointly include dependent and independent variable lags 
among original candidates. It replaces {opt dlags} and {opt ilags} when the argument is 
identical. tsset must be specified when using this option. {opt lags} must not be specified 
together with {opt dlags} or {opt ilags}. 
See {it:{help gsreg##eglag:Examples of using dlag, ilags or lags}} 
{p_end}

{*:*****************************************************************************************}
{marker fixvar}{...}
{syntab:{it:Fixed variable options}}

{phang} 
{opt f:ixvar(varlist_fix)} allows users to specify a subset of covariates which must be 
included in all regressions. Variables defined in {varlist:_fix} must not be included 
among the standard candidates ({it:{help gsreg:varlist_ocand}}). 
See {it:{help gsreg##egfixvar:Examples of using fixvar}} 
{p_end}

{*:*****************************************************************************************}
{marker interactions}{...}
{syntab:{it:Options for transformations and interactions}}

{phang} 
{opt sc:hange(varname_sc)} tests structural change of slops (using dummy {varname:_sc} as 
interaction with all candidates) or dependent variable levels (alternatively allowing 
{varname:_sc} to interact with the intercept). Interactions of {varname:_sc} with any candidate 
will only be included if this candidate is in the equation. {varname:_sc} must not be included 
among original candidates ({it:{help gsreg:varlist_ocand}}) because it will only be used for 
structural change. 
See {it:{help gsreg##eginteractions:Examples of using transformations and interactions}} 
{p_end}

{phang} 
{opt int:eractions} includes additional covariate candidates to evaluate all possible 
interactions without repetition among original candidates ({it:{help gsreg:varlist_ocand}}) 
and lags, if specified in {it:{help gsreg##lag:dlags}}, {it:{help gsreg##lag:ilags}} or 
{it:{help gsreg##lag:lags}}. Interactions between any two candidates will only be allowed 
if both of them are in the equation. When used together with {opt schange}, the structural 
change of interactions will only be used if these interactions are included in the estimated 
specification. 
See {it:{help gsreg##eginteractions:Examples of using transformations and interactions}} 
{p_end}

{phang} 
{opt sq:uares} adds the squares of each variable in {it:{help gsreg:varlist_ocand}} 
(and lags, if specified in {it:{help gsreg##lag:dlags}}, {it:{help gsreg##lag:ilags}} 
or {it:{help gsreg##lag:lags}}) as new candidates. Each square will only be accepted as 
a regression covariate if its level (original variable) is present in the equation. 
Similarly, when used together with {opt schange}, the structural change of the squares 
will only be allowed if these squares are in the equation. 
See {it:{help gsreg##eginteractions:Examples of using transformations and interactions}} 
{p_end}

{phang} 
{opt cub:ic} is similar to {opt squares}. It includes cubes of each variable in
{it:{help gsreg:varlist_ocand}} (and lags, if specified in {it:{help gsreg##lag:dlags}},
{it:{help gsreg##lag:ilags}} or {it:{help gsreg##lag:lags}}) as new candidates. 
These cubes will only be accepted as covariates if level and squares of the same 
variable are also included in the equation. As for {opt squares}, when used together
with {opt schange}, the structural change of the cubes will only be allowed if these 
cubes are also in the equation. 
See {it:{help gsreg##eginteractions:Examples of using transformations and interactions}} 
{p_end}

{phang} 
{opt fixint:eractions} is similar to {opt interactions}, but it includes as additional
candidates all possible interactions without repetition among {it:{help gsreg:varlist_ocand}}
(and lags, if specified in {it:{help gsreg##lag:dlags}}, {it:{help gsreg##lag:ilags}} or 
{it:{help gsreg##lag:lags}}) and each fixed variable in {it:{help gsreg##fixvar:varlist_fix}}. 
See {it:{help gsreg##eginteractions:Examples of using transformations and interactions}} 
{p_end}

{*:*****************************************************************************************}
{marker outsample}{...}
{syntab:{it:Options for time series and panel data forecasts}}

{phang} 
{opt o:utsample(#)} is used in time series and panels models. It splits the sample into two. 
The first sub-sample is used for regression purposes and the second one is applied to evaluate
forecast accuracy. {opt outsample(#)} leaves the last {it:#} periods to make forecasts (so that
regressions are performed over the first {it:T-#} periods – where {it:T} is the total number of
available time series observations). When this option is specified, {cmd:gsreg} calculates and
store the rmse_in (in sample root mean square error) between period {it:1} and {it:N-#}, and 
rmse_out (out sample root mean square error) between period {it:N-#} and {it:N}. tsset must be
specified when using this option.
See {it:{help gsreg##egoutsample:Examples of using outsample}} 
{p_end}

{*:*****************************************************************************************}
{marker commandopt}{...}
{syntab:{it:Regression command options}}

{phang} 
{opt cmde:st(commandname)} allows choosing the regression command to be used. If the option is 
not specified, {it:commandname} default is {it:{help regress:regress}}. This option allows using
{it:{help regress:regress}}, {it:{help xtreg:xtreg}}, {it:{help probit:probit}}, 
{it:{help logit:logit}}, {it:{help areg:areg}}, {it:{help qreg:qreg}} and {it:{help plreg:plreg}},
but it additionally accept any regression command that respects the syntax of 
{it:{help regress:regress}} 
and saves results ({it:matrices e(b) and e(V)}) in the same way. {it:{help ivregress:ivregress}}
is also acepted using option {opt cmdiveq(varlist_end = varlist_inst)}.
See {it:{help gsreg##egcommand:Examples of using cmdest, cmdoptions, cmdstat and cmdiveq}} 
{p_end}

{phang} 
{opt cmdo:ptions(commandoptions)} allows adding supported (by {it:commandname}) additional 
options for each regression. 
See {it:{help gsreg##egcommand:Examples of using cmdest, cmdoptions, cmdstat and cmdiveq}} 
{p_end}

{phang} 
{opt cmds:tat(commandstats)} enables {cmd:gsreg} (which automatically saves the number of
observations -{it:{help gsreg##list1:obs}}–, the number of covariates -{it:{help gsreg##list1:nvar}}–,
the adjusted R2 -{it:{help gsreg##list1:r_sqr_a}}– and the root mean square error -{it:{help gsreg##list1:rmse_in}}–) 
to save additional regression statistics saved as scalars {it:{help e():e()}} by the regression 
command ({it:commandname}).
See {it:{help gsreg##egcommand:Examples of using cmdest, cmdoptions, cmdstat and cmdiveq}} 
{p_end}

{phang} 
{opt cmdi:veq(varlist_end = varlist_inst)} is a special option to include a varlist 
of endogenous variables ({it:varlist_end}) and of instruments ({it:varlist_inst}) when
the estimator command is {it:{help ivregress:ivregress}}. When using this option, 
{opt cmdest(ivregress 2sls)}, {opt cmdest(ivregress liml)} or {opt cmdest(ivregress gmm)}
must be specified. The endogenous variables must be included in {it:varlist_fix}
(see option {it:{help gsreg##fixvar:fixvar}}) or in {it:{help gsreg:varlist_ocand}}). 
See {it:{help gsreg##egcommand:Examples of using cmdest, cmdoptions, cmdstat and cmdiveq}} 
{p_end}

{*:*****************************************************************************************}
{marker posestim}{...}
{syntab:{it:Post-estimation options}}

{phang}	Information criteria {p_end}

{phang} {opt aic:bic} calculates {it:{help estat ic:estat ic}} after each regression to 
obtain Akaike ({it:aic}) and Bayesian information criteria ({it:bic}).
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang}	Heteroscedasticity tests{p_end}

{phang} {opt het:test} calculates default {it:{help regress postestimation##estathett:estat hettest}}
after each regression and saves p-values.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt hettest_o(hettestmoptions)} allows adding options to {opt hettest}.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt arc:hlm} runs default {it:{help regress postestimationts##archlm:estat archlm}} 
after each regression and saves p-values. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt archlm_o(archlmoptions)} allows adding options to {opt archlm}.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang}	Serial autocorrelation tests{p_end}

{phang} {opt bgod:frey} computes default {it:{help regress postestimationts##bgodfrey:estat bgodfrey}}
after each regression and saves p-values. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt bgodfrey_o(bgodfreyoptions)} allows adding options to {opt bgodfrey}.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt dur:binalt} calculates {it:{help regress postestimationts##durbinalt:estat durbinalt}} 
after each regression and saves the p-values. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt durbinalt_o(durbinaltoptions)} allows adding options to {opt durbinalt}.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt dw:atson} runs {it:{help regress postestimationts##dwatson:estat dwatson}} after each
regression and saves the Durbin-Watson statistic. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} Normality tests of residuals{p_end}

{phang} {opt sk:test} computes {it:{help sktest:sktest}} after each regression and saves the p-value 
of the joint probability of skewness and kurtosis for normality. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt sktest_o(sktestoptions)} allows adding options to {opt sktest}.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt sw:ilk} calculates {it:{help swilk:swilk}} after each regression and saves the p-value 
of the Shapiro-Wilk normality test. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt swilk_o(swilkoptions)} allows adding options to {opt swilk}. 
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{phang} {opt sf:rancia} runs {it:{help sfrancia:sfrancia}} after each regression and saves the p-value 
of the Shapiro-Francia normality test. tsset must be specified when using this option.
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}


{phang} {opt test:pass(#)} allows a reduction of the outcome database size by saving only those 
regression results that fulfilled all user-specified residual tests (at a {it:#} significance level).
See {it:{help gsreg##egposestim:Examples of using Post-estimation options}} 
{p_end}

{*:*****************************************************************************************}
{marker outputopt}{...}
{syntab:{it:Output options}}

{phang} 
{opt res:ultsdta(newbasename)} allows results database name to be user defined 
in {it:{help filename:newbasename}}. By default, the name will be {it:gsreg.dta}.  {p_end}

{phang} {opt rep:lace} replaces the results database if it is already created (with 
the same name) in the ongoing working directory.  {p_end}

{phang} {opt do:uble} forces results to be created and saved in {it:{help data_types:double}}
format, that is, with double precision. {p_end}

{phang} {opt com:pact} reduces the results database size by deleting all coefficients 
and t-statistics. In their place, {cmd:gsreg} creates a {it:{help data_types:string}} 
variable called {it:regressors} that describes which candidate variables are included 
in each regression. This variable takes value “1” in position {it:#} if the candidate 
variable with position {it:#} is included in the equation, and it takes value “.” if 
it is not. Variable positions are kept in a small database called {it:newbasename_labels.dta} 
(where {it:newbasename} is the results database user defined name). 
See {it:{help gsreg##egoutputopt:Examples of using output options}} 
{p_end}

{phang} 
{opt ni:ndex(lcimplist)} allows specifying an index of normalized accuracy 
–{it:nindex}-. Regressions will be ordered from highest to lowest in the results 
database, the best regression according to {it:nindex} will be shown on screen and {it:e()} 
results of this regression will be saved in memory at the end of the {cmd:gsreg} execution. 
If not specified, nindex will be based on the adjusted R-squared ({it:r_sqr_a}). User choices 
about goodness-of-fit or forecast accuracy criteria on nindex can flexibly be specified in 
{it:lcimplist}. By means of user-selected weights and ranking variables, {it:lcimplist} allows 
complex arguments to create multinomial ordering criteria. Any results-database variable can 
be used in the {it:lcimplist} argument as a ranking variable (e.g. {it:r_sqr_a}, {it:rmse_in}, 
{it:rmse_out}, {it:aic}, {it:bic}, etc.), but it must be preceded by a user-defined real number
weight as in the following example: nindex({it:0.3 r_sqr_a -0.3 aic -0.4 bic}). It should be 
noticed that each variable included in {it:lcimplist} is normalized using the whole sample 
average (across of all regressions) of the same variable. 
See {it:{help gsreg##egoutputopt:Examples of using output options}} 
{p_end}

{phang} 
{opt mi:ndex(lcimplist)} and {opt best(#)} options must be specified 
together. {opt mindex} generates a normalized ranking index like {opt nindex} –{it:mindex}-,
and has the same syntax as {opt nindex}, but the normalization of its arguments is developed
using averages obtained from the best {it:#+1} regressions. Therefore, mindex is updated with
each additional regression and only the best (in terms of {it:lcimplist}) {it:#} regressions 
results are saved. The joint use of {opt mindex} and {opt best} options can strongly reduce 
database size (and RAM requirements) making feasible larger model selection problems. 
However, as {opt mindex} must be re-calculated with every regression, {cmd:gsreg} could 
run slower than using nindex (particularly for small model selection problems). 
See {it:{help gsreg##egoutputopt:Examples of using output options}} 
{p_end}

{pstd} Back to {it:{help gsreg:Top}} {p_end}

{*:*****************************************************************************************}
{marker Examples}{...}
{title:Examples}
{*:*****************************************************************************************}
{phang2}{cmd:. sysuse auto} {p_end}
{phang2}{cmd:. gsreg mpg weight foreign} {p_end}
{pstd} In this case there are 2 candidate covariates (weight and foreign), {cmd:gsreg} will 
perform all possible combinations (regressions) without repetition taken from 2:{p_end}
{pstd} {it: regress mpg weight} {p_end}
{pstd} {it: regress mpg foreign} {p_end}
{pstd} {it: regress mpg weight foreign} {p_end}

{marker egncomb}{...}
{dlgtab: Examples of using ncomb}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1,1)} {p_end}
{pstd} or equivalently {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1)} {p_end}
{pstd} In this case there are 3 candidate covariates, {cmd:gsreg} will perform all
possible combinations (regressions) without repetition of size 1 taken from 3:{p_end}
{pstd} {it: regress depvar ocand1} {p_end}
{pstd} {it: regress depvar ocand2} {p_end}
{pstd} {it: regress depvar ocand3} {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1,2)} {p_end}
{pstd} will perform all possible combinations (regressions) without repetition
of size 1 and 2, taken from 3, that is, it will perform the following 6 regressions:{p_end}
{pstd} {it: regress depvar ocand1} {p_end}
{pstd} {it: regress depvar ocand2} {p_end}
{pstd} {it: regress depvar ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand3} {p_end}
{pstd} {it: regress depvar ocand2 ocand3} {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1,3)} {p_end}
{pstd} or equivalently {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3} {p_end}
{pstd} {cmd:gsreg} will perform all possible combinations (regressions) without repetition
of size 1 to 3, taken from 3:{p_end}
{pstd} {it: regress depvar ocand1} {p_end}
{pstd} {it: regress depvar ocand2} {p_end}
{pstd} {it: regress depvar ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand3} {p_end}
{pstd} {it: regress depvar ocand2 ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3} {p_end}

{pstd} Back to {it:{help gsreg##genoption:General options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egsamesample}{...}
{dlgtab: Examples of using samesample}

{pstd} suppose {it:depvar}, {it:ocand1} and {it:ocand2} have 50 nonmissing 
observations but {it:ocand3} has only 48, then {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1)} {p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: regress depvar ocand1}, with 50 observations {p_end}
{pstd} {it: regress depvar ocand2}, with 50 observations {p_end}
{pstd} {it: regress depvar ocand3}, with 48 observations {p_end}

{pstd} while: {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(1) samesample} {p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: regress depvar ocand1}, with 48 observations {p_end}
{pstd} {it: regress depvar ocand2}, with 48 observations {p_end}
{pstd} {it: regress depvar ocand3}, with 48 observations {p_end}

{pstd} Back to {it:{help gsreg##genoption:General options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egbackpart}{...}
{dlgtab: Examples of using backup and part}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, backup(3)} {p_end}
{pstd} will perform the same 7 regressions that: {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3} {p_end}
{pstd} But during the execution will save 3 temporary files
in the ongoing working directory: {p_end}
{pstd} {it: gsreg_part_1_of_3.dta}, containing the outputs of regressions 1 and 2 {p_end}
{pstd} {it: gsreg_part_2_of_3.dta}, containing the outputs of regressions 3 to 5 {p_end}
{pstd} {it: gsreg_part_3_of_3.dta}, containing the outputs of regressions 6 and 7 {p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2 ocand3 ocand4 ocand5 ocand6 ocand7 ocand8 ocand9, backup(3)} 
{p_end}
{pstd} will perform the same 511 regressions that {p_end}
{phang2}
{cmd:. gsreg depvar ocand1 ocand2 ocand3 ocand4 ocand5 ocand6 ocand7 ocand8 ocand9} 
{p_end}
{pstd} But during the execution will save 3 temporary files
in the ongoing working directory: {p_end}
{pstd} {it: gsreg_part_1_of_3.dta}, containing the outputs of regressions 1 and 170 {p_end}
{pstd} {it: gsreg_part_2_of_3.dta}, containing the outputs of regressions 171 to 341 {p_end}
{pstd} {it: gsreg_part_3_of_3.dta}, containing the outputs of regressions 342 and 511 {p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2 ocand3 ocand4 ocand5 ocand6 ocand7 ocand8 ocand9, part(1,3)} 
{p_end}
{pstd} will perform only 170 of the 511 regressions and will save 
{it:gsreg_part_1_of_3.dta} containing the outputs of regressions 1 to 170 
{p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2 ocand3 ocand4 ocand5 ocand6 ocand7 ocand8 ocand9, part(2,3)} 
{p_end}
{pstd} will perform only 171 of the 511 regressions and will save 
{it:gsreg_part_2_of_3.dta} containing the outputs of regressions 171 to 341
{p_end}

{pstd} Back to {it:{help gsreg##genoption:General options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egvselect}{...}
{dlgtab: Examples of using vselect}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, vselect} {p_end}
{pstd} will execute {p_end}
{phang2}{cmd:. vselect depvar ocand1 ocand2 ocand3, best} {p_end}
{pstd} 
and will only run the minimum number of regressions necessary to obtain 
the best models of 1, 2 and 3 covariates (plus the intercept) in terms of 
in-sample RMSE, AIC and BIC.{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, vselect fix(indepvar1)} {p_end}
{pstd} will execute {p_end}
{phang2}{cmd:. vselect depvar ocand1 ocand2 ocand3, best fixvar(indepvar1)} {p_end}
{pstd} 
and will only run the minimum number of regressions necessary to obtain the best 
models of 2, 3 and 4 covariates (plus the intercept) in terms of in-sample RMSE, AIC and BIC. 
{it:indepvar1} will be included in all regressions. 
{p_end}

{pstd} Back to {it:{help gsreg##genoption:General options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker eglag}{...}
{dlgtab: Examples of using dlags, ilags and lags}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(3) dlags(1/4)} {p_end}
{pstd} 
In this example there are two original candidate covariates (ocand1 and ocand2). 
Dependent variable lags 1 to 4 will be added to the original candidates. 
Therefore there will be 6 final candidates: 
{p_end}
{pstd} 
{it:ocand1 ocand2 L2.depvar L1.depvar L3. depvar L4.depvar.}
{p_end}
{pstd} 
and 20 regressions must be estimated (combinations of size 3 taken from 6)
{p_end}
{pstd} 
The same problem structure can be obtained by generating all lags before
executing gsreg and including them as original candidates:
{p_end}
{phang2}{cmd:. gen aux1= L1.depvar} {p_end}
{phang2}{cmd:. gen aux2= L2.depvar} {p_end}
{phang2}{cmd:. gen aux3= L3.depvar} {p_end}
{phang2}{cmd:. gen aux4= L4.depvar} {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 aux1 aux2 aux3 aux4, ncomb(3) } {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(3) dlags(1 2 4(4)12)} {p_end}
{pstd} 
In this example dependent variable lags 1,2,4,8 and 12 are included among 
candidate covariates, increasing to 7 the final number of potential candidates: 
{p_end}
{pstd} 
{it:ocand1 ocand2 L1.depvar L2.depvar L4.depvar L8.depvar L12.depvar}
{p_end}
{pstd} 
35 regressions will be estimated (combinations of size 3 taken from 7)
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(3) ilags(1/4)} {p_end}
{pstd} 
In this case, independent (explanatory) variable lags 1 to 4 will be added to the 
original candidate covariates, obtaining the following final candidate list: 
{p_end}
{pstd} 
{it:ocand1 ocand2 L1.ocand1 L2.ocand1 L3.ocand1 L4.ocand1 L1.ocand2 L2.ocand2 L3. ocand2 L4.ocand2}
{p_end}
{pstd} 
120 regressions must be estimated (combinations of size 3 taken from 10)
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(3) lags(1 3))} {p_end}
{pstd} 
In our final lag-structure example, lags 1 and 3 of dependent and explanatory variables 
are included among candidates (now 8 candidates): 
{p_end}
{pstd} 
{it:ocand1 ocand2 L1.depvar L3.depvar L1.ocand1 L3.ocand1 L1.ocand2 L3.ocand2}
{p_end}
{pstd} 
56 regressions will be estimated (combinations 3 taken from 8)
{p_end}

{pstd} Back to {it:{help gsreg##lag:Lag structure options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egfixvar}{...}
{dlgtab: Examples of using fixvar}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1) fixvar(fixvar1 fixvar2)} {p_end}
{pstd} will perform the following 2 regressions: {p_end}
{pstd} {it: regress depvar ocand1 fixvar1 fixvar2} {p_end}
{pstd} {it: regress depvar ocand2 fixvar1 fixvar2} {p_end}

{pstd} 
when using fixvar without the {opt ncomb} option, {cmd:gsreg} will also evaluate regressions 
without any variable candidate covariate:
{p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2, fixvar(fixvar1 fixvar2)} {p_end}
{pstd} will perform the following 4 regressions: {p_end}
{pstd} {it: regress depvar fixvar1 fixvar2} {p_end}
{pstd} {it: regress depvar ocand1 fixvar1 fixvar2} {p_end}
{pstd} {it: regress depvar ocand2 fixvar1 fixvar2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 fixvar1 fixvar2} {p_end}

{pstd} Back to {it:{help gsreg##fixvar:Fixed variable options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker eginteractions}{...}
{dlgtab: Examples of using schange, interactions, squares, cubic and fixinteractions}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1) schange(varschange)} {p_end}
{pstd} will perform the following 6 regressions: {p_end}
{pstd} {it: regress depvar ocand1}  {p_end}
{pstd} {it: regress depvar ocand1 c.ocand1#varschange} {p_end}
{pstd} {it: regress depvar ocand1 c.ocand1#varschange varschange} {p_end}
{pstd} {it: regress depvar ocand2} {p_end}
{pstd} {it: regress depvar ocand2 c.ocand2#varschange} {p_end}
{pstd} {it: regress depvar ocand2 c.ocand2#varschange varschange} {p_end}

{pstd} Note that it is also possible to test structural change by: {p_end}
{phang2}{cmd:. gen aux1= c.ocand1#varschange} {p_end}
{phang2}{cmd:. gen aux2= c.ocand2#varschange} {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2 aux1 aux2 varschange, ncomb(1,3) } {p_end}
{pstd} 
But this procedure will run 25 regressions (including the 6 of the first procedure).
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3, ncomb(2,3) interactions} {p_end}
{pstd} will perform the following 14 regressions: {p_end}
{pstd} {it: regress depvar ocand1 ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand3}  {p_end}
{pstd} {it: regress depvar ocand1 ocand3 c.ocand1#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand2 ocand3} {p_end}
{pstd} {it: regress depvar ocand2 ocand3 c.ocand2#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand2#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand2 c.ocand1#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand2 c.ocand2#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand3 c.ocand1#c.ocand3} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 ocand3 c.ocand1#c.ocand2 c.ocand1#c.ocand3}
{it: c.ocand2#c.ocand3} 
{p_end}

{pstd} Note that it is also possible to evaluate this problem by generating 
interactions before {cmd:gsreg}, including them as original {cmd:gsreg} candidates 
and using the ncomb(2,6) option. 
{p_end}
{pstd} 
However, with this procedure {cmd:gsreg} will run 57 regressions 
(including the 14 models of the first procedure).
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1,2) squares} {p_end}
{pstd} will perform the following 8 regressions: {p_end}
{pstd} {it: regress depvar ocand1 } {p_end}
{pstd} {it: regress depvar ocand1 c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand2 } {p_end}
{pstd} {it: regress depvar ocand2 c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 } {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand2#c.ocand2} {p_end}
{pstd} Note that it is also possible to examine the same problem by generating squares
before using {cmd:gsreg}, including them as original {cmd:gsreg} candidates and 
using the option ncomb(1,4) 
{p_end}
{pstd} 
Notwithstanding, this procedure will run 15 regressions (including the 8 of the first procedure).
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1,2) squares cubic} {p_end}
{pstd} will perform the following 15 regressions: {p_end}
{pstd} {it: regress depvar ocand1 } {p_end}
{pstd} {it: regress depvar ocand1 c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand1 c.ocand1#c.ocand1 c.ocand1#c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand2 } {p_end}
{pstd} {it: regress depvar ocand2 c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand2 c.ocand2#c.ocand2 c.ocand2#c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 } {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 } {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand1#c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand2#c.ocand2 c.ocand2#c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand2#c.ocand2} 
{it: c.ocand1#c.ocand1#c.ocand1} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand2#c.ocand2}
{it: c.ocand2#c.ocand2#c.ocand2} {p_end}
{pstd} {it: regress depvar ocand1 ocand2 c.ocand1#c.ocand1 c.ocand2#c.ocand2}
{it: c.ocand1#c.ocand1#c.ocand1 c.ocand2#c.ocand2#c.ocand2} {p_end}
{pstd} Note that it is also possible to obtain these 15 regressions by generating squares 
and cubes before {cmd:gsreg}, including them as original {cmd:gsreg} candidates and 
using the option ncomb(1,6) 
{p_end}
{pstd} 
But this procedure will run 63 regressions (including the 15 of the first procedure).
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1,2) fixvar(fixvar1) fixinteractions} {p_end}
{pstd} will perform the following 8 regressions: {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 } {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 c.ocand1#c.fixvar1} {p_end}
{pstd} {it: regress depvar fixvar1 ocand2 } {p_end}
{pstd} {it: regress depvar fixvar1 ocand2 c.ocand2#c.fixvar1} {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 ocand2 } {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 ocand2 c.ocand1#c.fixvar1} {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 ocand2 c.ocand2#c.fixvar1} {p_end}
{pstd} {it: regress depvar fixvar1 ocand1 ocand2 c.ocand1#c.fixvar1 c.ocand2#c.fixvar1} {p_end}
{pstd} Note that it is also possible to evaluate the same model selection problem by generating 
interactions with fixvar before using {cmd:gsreg}, including them as original {cmd:gsreg} candidates
and using the option ncomb(1,4) 
{p_end}
{pstd} 
However, this procedure will run 15 regressions (including the 8 of the first procedure).
{p_end}

{pstd} Back to {it:{help gsreg##interactions:Options for transformations and interactions}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egoutsample}{...}
{dlgtab: Examples of using outsample}

{pstd} Assume that we have 40 nonmissing observations {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2, outsample(6)} {p_end}
{pstd} Will perform all regressions using the first 34 observations. Post-estimation commands will 
compute the rmse_out (out-of-sample root mean square error) for each regression using the last 6 
observartions, storing them in the results database. 
{p_end}

{pstd} Back to {it:{help gsreg##outsample:Options for time series and panel data forecasts}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egcommand}{...}
{dlgtab: Examples of using cmdest, cmdoptions, cmdstat and cmdiveq}

{phang2}{cmd:. gsreg depvar ocand1 ocand2,  cmdest(probit) cmdstat(r2_p)} {p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: probit depvar ocand1} {p_end}
{pstd} {it: probit depvar ocand2} {p_end}
{pstd} {it: probit depvar ocand1 ocand2} {p_end}
{pstd} and the Pseudo R2 of each estimation (e(r2_p)) will be saved in {it:gsreg.dta}
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2,  cmdoptions(robust) } {p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: regress depvar ocand1, robust} {p_end}
{pstd} {it: regress depvar ocand2, robust} {p_end}
{pstd} {it: regress depvar ocand1 ocand2, robust} {p_end}


{phang2}{cmd:. gsreg depvar ocand1 ocand2, ncomb(1,2) cmdest(xtreg) cmdoptions(fe vce(robust)) 
cmdstat(sigma_u sigma_e rho r2_w r2_b r2_o) } {p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: xtreg depvar ocand1, fe vce(robust)} {p_end}
{pstd} {it: xtreg depvar ocand2, fe vce(robust)} {p_end}
{pstd} {it: xtreg depvar ocand1 ocand2, fe vce(robust)} {p_end}
{pstd} and the scalars stored in e(sigma_u), e(sigma_e), e(r2_p), e(rho), e(r2_w), e(r2_b) and e(r2_o) 
will be saved in {it:gsreg.dta} {it:{help xtreg:xtreg}}
{p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2, cmdest(ivregress liml) cmdiveq(ocand2= ivar1 ivar2)} 
{p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: ivregress liml depvar ocand1} {p_end}
{pstd} {it: ivregress liml depvar ocand2 (ocand2= ivar1 ivar2)} {p_end}
{pstd} {it: ivregress liml depvar ocand1 ocand2 (ocand2= ivar1 ivar2)} {p_end}
{pstd} (the first regression is equivalent to {it:regress depvar ocand1}) {p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2, cmdest(ivregress gmm) cmdiveq(ocand2= ivar1 ivar2)} 
{p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: ivregress gmm depvar ocand1 (=ivar1 ivar2)} {p_end}
{pstd} {it: ivregress gmm depvar ocand2 (ocand2= ivar1 ivar2)} {p_end}
{pstd} {it: ivregress gmm depvar ocand1 ocand2 (ocand2= ivar1 ivar2)} {p_end}

{phang2}
{cmd:. gsreg depvar ocand1 ocand2, cmdest(ivregress 2sls) cmdiveq(fixvar1 fixvar2= ivar1 ivar2) fixvar(fixvar1 fixvar2)} 
{p_end}
{pstd} will perform the following 3 regressions: {p_end}
{pstd} {it: ivregress 2sls depvar ocand1 (fixvar1 fixvar2= ivar1 ivar2)} {p_end}
{pstd} {it: ivregress 2sls depvar ocand2 (fixvar1 fixvar2= ivar1 ivar2)} {p_end}
{pstd} {it: ivregress 2sls depvar ocand1 ocand2 (fixvar1 fixvar2= ivar1 ivar2)} {p_end}

{pstd} Back to {it:{help gsreg##commandopt:Regressions command options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egposestim}{...}
{dlgtab: Examples of using aicbic, hettest, archlm, bgodfrey, durbinalt, dwatson, sktest, swilk, sfrancia and testpass}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, aicbic} {p_end}
{pstd} will execute {it:{help estat ic:estat ic}} after each regression, saving values of the 
Akaike and the Bayesian information criteria in {it:gsreg.dta}. 
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, hettest} {p_end}
{pstd} 
will execute {it:{help regress postestimation##estathett:estat hettest}} after each regression, 
saving Breusch-Pagan / Cook-Weisberg (heteroscedasticity test) p-values in {it:gsreg.dta}.
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2,  hettest hettest_o(iid)} {p_end}
{pstd} adds the option {it:iid} to {it:{help regress postestimation##estathett:estat hettest}} 
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2,  aicbic archlm archlm_o(1 2 4)} {p_end}
{pstd} adds the option {it:lags(1 2 4)} to {it:{help regress postestimation##estathett:estat archlm}}.
{cmd:gsreg} will save {cmd:archlm} test p-values for lags 1, 2 and 4 with varnames archlm1 archlm2 and archlm4
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, hettest archlm bgodfrey durbinalt sktest swilk sfrancia} {p_end}
{pstd} after each regression, {cmd:gsreg} will execute:{p_end}
{pstd} {it: estat hettest} {p_end}
{pstd} {it: estat archlm} {p_end}
{pstd} {it: estat bgodfrey} {p_end}
{pstd} {it: estat durbinalt} {p_end}
{pstd} {it: estat dwatson} {p_end}
{pstd} {it: estat sktest} {p_end}
{pstd} {it: estat swilk} {p_end}
{pstd} {it: estat sfrancia} {p_end}
{pstd} saving each test p-values in {it:gsreg.dta}.   {p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2, archlm archlm_o(lags(1 3)) durbinalt durbinalt_o(lags(1/4)) 
swilk swilk_o(noties) testpass(0.05)} {p_end}
{pstd} after each regression, {cmd:gsreg} will execute:{p_end}
{pstd} {it: estat archlm, lags(1 3)} {p_end}
{pstd} {it: estat durbinalt,lags(1/4)} {p_end}
{pstd} {it: estat dwatson} {p_end}
{pstd} {it: estat swilk, noties} {p_end}
{pstd} each test p-value will be saved in {it:gsreg.dta}. Because of option {it:testpass(0.05)}, 
only regressions where all p-values are higher than 0.05 will be saved. {p end}

{pstd} Back to {it:{help gsreg##posestim:Post-estimation options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}
{*:*****************************************************************************************}
{marker egoutputopt}{...}
{dlgtab: Examples of using resultsdta, replace, double, compact, nindex and mindex}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 , resultsdta(myresults) } {p_end}
{pstd} generates a results database named {it:myresults.dta} instead of {it:gsreg.dta}
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 , resultsdta(myresults) replace } {p_end}
{pstd} will replaced {it:myresults.dta} if it has already been created in the ongoing working 
directory. All results of {it:myresults.dta} will be stored with double precision
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ,  compact resultsdta(myresults) } {p_end}
{pstd} generates two results databases. {it:myresults.dta} without coefficients nor t-statistics, 
and {it:myresults_labels.dta} with the name and position of each covariate.
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ,  nindex(r_sqr_a) } {p_end}
{pstd} is equivalent to {p_end}
{phang2}{cmd:. gsreg depvar ocand1 ocand2  } {p_end}
{pstd} {it: nindex=(r_sqr_a-mean(r_sqr_a))/sd(r_sqr_a)} will be created and stored in {it:gsreg.dta}.
{it: nindex} will be used to sort models from highest to lowest values.
{p_end}
 

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ,  nindex(1 r_sqr_a -.3 aic -.5 bic -1 rmse_out) aicbic 
outsample(6) } {p_end}
{pstd} will create {it:nindex} as a normalized polynomial function of {it:r_sqr_a}, {it:aic}, {it:bic}, 
and {it:rmse_out} with weights 1, -0.3, -0.5 and -1, respectively.
{p_end}

{phang2}{cmd:. gsreg depvar ocand1 ocand2 ocand3,  mindex(r_sqr_a) best(3)} {p_end}
{phang2} will compute {it: mindex=(r_sqr_a-mean(r_sqr_a))/sd(r_sqr_a)} using the first 4
regression, deleting the worse (in terms of {it: mindex}). After that, {it: mindex} will be computed
again including the fifth regression and the best step one 3 regressions. The worse model among these new
4 regressions will be deleted. {cmd:gsreg} will repeat this procedure for all possible regressions, and 
only the best 3 model results will be saved in {it:gsreg.dta}.
{p_end}

{pstd} Back to {it:{help gsreg##outputopt:Output options}} {p_end}
{pstd} Back to {it:{help gsreg:Top}} {p_end}

{*:*****************************************************************************************}
{marker Saved_results}{...}
{title:Saved results}
{*:*****************************************************************************************}
{pstd} 
{cmd:gsreg} creates a .dta file with outcome information for all estimated 
alternatives. By default it includes the following columns for each regression: 
{p_end}

{phang} 1) regression id (variable {it:order}) {p_end}
{phang} 2) covariate regression coefficients (named {it:v_1_b, v_2_b… , etc.}, 
and labeled with the full covariate name plus the word “coeff.”)
{p_end}
{phang} 3) coefficient t-statistics (named {it:v_1_t, v_2_t…, etc.}, and labeled
with the full covariate name plus the word “tstat.”) 
{p_end}
{phang} 4) number of observations (variable {it:obs}) {p_end}
{phang} 5) number of covariates (variable {it:nvar}) {p_end}
{phang} 6) adjusted R2 (variable {it:r_sqr_a}) {p_end}
{phang} 7) in-sample root mean square error (variable {it:rmse_in}) {p_end}
{phang} 8) normalized linear combination of user selected (and weighted) 
model selection criteria {it: nindex} (or {it:mindex} if this option is specified)
{p_end}
{phang}
9) additional user specified statistics (if the {opt cmdstat} option is specified)
{p_end}
{phang}
10) out-of-sample root mean square error (if {opt outsample} option is specified) and
{p_end}
{phang}
11) residual test statistics (if specified).
{p_end}

{phang}
When {opt compact} option is specified, regression coefficients and t-statistics 
are omitted and replaced by a unique summary string variable as described in {it:{help gsreg##outputopt:compact}}
{p_end}

{pstd} 
In addition, {cmd:gsreg} shows on screen the best regression in terms of the user specified 
{it:mindex} or {it:mindex} (or the adjusted R2 if these options are not specified). 
Therefore, all this “best model” results (as scalars, macros, matrices and functions)
are also saved in {bf: e()}. 
{p_end}

{pstd} Back to {it:{help gsreg:Top}} {p_end}

{*:*****************************************************************************************}
{marker Authors}{...}
{title:Authors}

{pstd}Pablo Gluzmann{p_end}
{pstd}CEDLAS-UNLP and CONICET{p_end}
{pstd}La Plata, Argentina{p_end}
{pstd}gluzmann@yahoo.com{p_end}

{pstd}Demian Panigo{p_end}
{pstd}CEIL-CONICET, UNM and UNLP{p_end}
{pstd}La Plata, Argentina{p_end}
{pstd}dpanigo@ceil-conicet.gov.ar{p_end}

{pstd}Back to {it:{help gsreg:Top}} {p_end}

{*:*****************************************************************************************}
{title:Also see}

{p 4 14 2}Article: Global Search Regression (GSREG): A new automatic model selection technique for cross-section, time series and panel data regressions, CEIL, Argentina
{p 7 14 2}Help: {it:{help estcom:estcom}}, {it:{help regress:regress}}, {it:{search vselect:vselect}}

