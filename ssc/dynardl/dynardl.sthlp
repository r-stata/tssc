{smcl}
{* *! version 1.0.5  01may2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "dynardl##syntax"}{...}
{viewerjumpto "Description" "dynardl##description"}{...}
{viewerjumpto "Options" "dynardl##options"}{...}
{viewerjumpto "Authors" "dynardl##authors"}{...}
{viewerjumpto "References" "dynardl##references"}
{viewerjumpto "Citations" "dynardl##citations"}
{viewerjumpto "Examples" "dynardl##examples"}{...}
{viewerjumpto "Version" "dynardl##version"}{...}

{title:Title}

{phang}
{bf:dynardl} {hline 2} A program to dynamically simulate autoregressive distributed lag (ARDL) models.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:dynardl} 
{depvar}
{indepvars}{cmd:,} {cmdab:l:ags(numlist)} {cmdab:shockvar(varname)} {cmdab:shockval(#)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required options}

{synopt:{opth l:ags(numlist)}}numeric list of the number of lags to include for each variable{p_end}
{synopt:{opth shockvar(varname)}}a single independent variable from {indepvars} that is to be shocked {p_end}
{synopt:{opt shockval(#)}}amount to shock {cmd:shockvar({varname})} by{p_end}

{syntab:Additional options}

{synopt:{opth d:iffs(numlist)}}numeric list of the number of contemporaneous first differences to include for each variable{p_end}
{synopt:{opth lagd:iffs(numlist)}}numeric list of the number of lagged first differences to include for each variable{p_end}
{synopt:{opth levels(numlist)}}numeric list of variables to appear in levels{p_end}
{synopt:{opt ec}}if specified, {depvar} will be estimated in first differences{p_end}
{synopt:{opt trend}}add a deterministic linear trend{p_end}
{synopt:{opt nocon:stant}}suppress the constant{p_end}
{synopt:{opt range(#)}}length of scenario to simulate (default is 20){p_end}
{synopt:{opt sig(#)}}significance level for confidence intervals  (default is 95%){p_end}
{synopt:{opt t:ime(#)}}scenario time in which the shock occurs (default is 10){p_end}
{synopt:{opth saving(string)}}specifies the name of the output file (default is "dynardl_results.dta"){p_end}
{synopt:{opth forceset(numlist)}}forces the variables to be set to a user-specified value{p_end}
{synopt:{opth sims(numlist)}}number of simulations (default is 1000){p_end}
{synopt:{opt burnin(#)}}allows program to iterate for stable starting values (rarely used){p_end}
{synopt:{opt graph}}plot dynamic results using a spikeplot. Additional options are {opt rarea} for an area plot, or {opt change} to plot changes from sample mean{p_end}
{synopt:{opt expectedval}}calculate expected values instead of predicted values (the default){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:dynardl} is a program to produce dynamic simulations of autoregressive distributed lag (ARDL) models. See Philips (2018) for a discussion of this approach, especially in regards to the error-correction ARDL representation of Pesaran, Shin, and Smith (2001). See Jordan and Philips (Forthcoming) for an in-depth discussion of this program.

{pstd}
Users can find and download the most up-to-date version of {cmd:dynardl} at:
 http://andyphilips.github.io/dynamac/.

{pstd} 
{cmd:dynardl} is designed to dynamically simulate the effects of a counterfactual change in one weakly exogenous regressor at a point in time, using stochastic simulation techniques. Since the ARDL procedure can produce models that are complicated to interpret, {cmd:dynardl} is designed to ease the burden of substantive interpretations through the creation of predicted (or expected) values of the dependent variable (along with associated confidence intervals), which can be plotted to show how a change in one variable "flows" through the model over time. {cmd:dynardl} takes 1000 (or however many simulations a user desires) draws of the set of parameters from a multivariate normal distribution, using the estimated parameters and the variance-covariance matrix from the linear regression. All covariates are set to certain values (typically means), which are used to create predicted Y-hat values plus stochastic uncertainty. 
 
{marker options}{...}
{title:Options}

{dlgtab:Required Options}
 
{phang}
{opth lags(numlist)} is a numeric list of the number of lags to include for each variable, separated by a comma. The number of desired lags is listed in the order in which the variables depvar and indepvars appear. For instance, in a model with two weakly exogenous variables, we lag all variables by one period by specifying: {cmd:lags(1, 1, 1)}. Note that the lag on depvar (the first "1") must always be specified. To estimate a model without a lag for a particular variable, simply replace the number with a “.”; for instance, to remove the lag on the first regressor: {cmd:lags(1, ., 1)}. {cmd:dynardl} can handle consecutive and non-consecutive lags as well. For instance, {cmd:lags(1/3, ., .)} will introduce lags of y at t−1, t−2, and t−3 into the model, while {cmd:lags(1 3/4, ., .)} will add lags of y at t-1, t-3, and t-4.

{phang}
{opth shockvar(varname)}
is the independent variable in {indepvars} that is to experience a counterfactual shock of size {cmd:shockval(#)} at time {cmd:time(#)}.

{phang}
{opt shockval(#)}
is the amount to shock {cmd:shockvar(varname)} by. Most commonly, a +/- one standard deviation shock is specified.

{dlgtab:Additional Options}

{phang}
{opth diffs(numlist)} is a numeric list of the number of contemporaneous first differences (i.e., t − (t − 1)) to include for each variable, separated by a comma. Note that the first entry (the placeholder for the depvar) will always be empty (denoted by “.”), since the first difference of the dependent variable cannot appear on the right-hand side of the model.

{phang}
{opth lagdiffs(numlist)} is a numeric list of the number of lagged first differences to include for each variable, separated by a comma. The lag syntax is the same as for {cmd:lags( )}. For instance, to include a lagged first difference at t−2 for depvar, a lag at t−1 for the first weakly exogenous regressor, and none for the second, specify {cmd:lagdiff(2, 1, .)}. To include an additional lag for both the first and second lagged first differences of depvar, specify {cmd:lagdiff(1/2, 1, .)}.

{phang}
{opth levels(varlist)} is a numeric list of variables to appear in levels (i.e., not lagged or differenced but appearing contemporaneously at time t), separated by a comma. For instance, to include the first regressor contemporaneously in levels, specify {cmd:levels(., 1, .)}

{phang}
{opt ec} if specified, {depvar} will be estimated in first differences. If estimating an error correction model, users will need to use this option.

{phang}
{opt trend} if specified, the program will estimate the regression model with a deterministic linear trend.

{phang}
{opt noconstant} if specified, the constant will be suppressed.

{phang}
{opt range(#)} is the length of scenario to simulate. By default, this is t=20. {cmd:range( )} must always be larger than {cmd:time( )}.

{phang}
{opt sig(#)} specifies the significance level for the percentile confidence intervals. The default is for 95% confidence intervals.

{phang}
{opt t:ime(#)} is the scenario time in which the shock occurs to {cmd:shockvar( )}. The default time is t=10.

{phang}
{opth saving(string)} specifies the name of the output file. If no filename is specified, the program will save the results as "dynardl_results.dta".

{phang}
{opth forceset(numlist)} by default, {cmd:dynardl} estimates the ARDL model in equilibrium; all lagged variables and variables appearing in levels are set to their sample means, and all first-differences and any lagged first differences are set to zero. This option allows the user to change the setting of the lagged (or unlagged if using {cmd:levels( )}) levels of the variables. For instance, to set the value of the first regressor to 5, specify: {cmd:forceset(., 5, .)}

{phang}
{opt sims(#)} is the number of simulations (default is 1000). If confidence intervals are particularly noisy, it may help to increase this number. You may need to increase the {opth matsize} in Stata.

{phang}
{opt burnin(#)} allows {cmd:dynardl} to iterate out so starting values are stable. This option is rarely used. However, if using the option {cmd:forceset( )}, the predicted values will not be in equilibrium at the start of the simulation, and will take some time to converge on stable values. To get around this, one can use the burnin option to specify a number of starting simulations to drop. By default, this is 20. Burnins do not change the simulation range or time; to simulate a range of 25 with a shock time at 10 and a burnin of 30, specify: {cmd:burnin(30) range(25) time(10)}.

{phang}
{opt graph} although dynardl saves the means of the predicted values and user-specified confidence intervals in saving, users can use this option to automatically plot the dynamic results using a spikeplot. Two alternative plots are possible: 

{phang}
By adding the option {cmd:rarea}, the program will automatically create an area plot. Predicted means along with 75, 90, and 95 percent confidence intervals are shown using the area plot. 

{phang}
By adding the option {cmd:change}, predicted changes (from the sample mean) are shown across time (starting with the time at which the shock occurs), similar to an impulse response function.
	
{phang}
{opt expectedval} by default, {cmd:dynardl} will calculate predicted values of the dependent variable for a given number of simulations. For every simulation, the predicted value comes from a systematic component as well as a single draw from the stochastic component. With the expectedval option, the program instead calculates expected values of the dependent variable such that the average of 1000 stochastic draws now becomes the estimate of the stochastic component for each of the simulations. This effectively removes stochastic uncertainty. Predicted values are more conservative than expected values. Note that {cmd:dynardl} takes longer to run if calculating expected values.

{marker authors}{...}
{title:Authors}

{pstd}
Soren Jordan {break}
Department of Political Science {break}
Auburn University  {break}
sorenjordanpols@gmail.com {p_end}

{pstd}
Andrew Q. Philips {break}
Department of Political Science {break}
University of Colorado Boulder {break}
andrew.philips@colorado.edu {p_end}

{marker references}{...}
{title:References}

If you use {cmd:dynardl}, please cite:

{phang}Jordan, Soren and Andrew Q. Philips. Forthcoming. "Cointegration testing and dynamic simulations of autoregressive distributed lag models". Stata Journal.{p_end}

and:

{phang}Philips, Andrew Q. 2018. "Have your cake and eat it too? Cointegration and dynamic inference from autoregressive distributed lag models." American Journal of Political Science: 62(1): 230-244.{p_end}

{marker citations}{...}
{title:Citations}

{phang}Pesaran, M Hashem, Yongcheol Shin and Richard J Smith. 2001. "Bounds testing approaches to the analysis of level relationships." Journal of Applied Econometrics 16(3):289-326.{p_end}

{marker examples}{...}
{title:Examples}

{phang}Open up the Lutkepohl data:{p_end}
{phang}{cmd:set matsize 5000}{p_end}
{phang}{cmd:webuse lutkepohl2}{p_end}
{phang}{cmd:tsset}{p_end}

{phang}A −1 shock to ln_inc for the estimated equation: d.ln_inv = l.ln_inv + d.ln_inc + l.ln_inc + d.ln_consump + l.ln_consump{p_end}

{phang}{cmd:dynardl ln_inv ln_inc ln_consump, ///}{p_end}
{phang}{cmd:lags(1, 1, 1) diffs(., 1, 1) ///}{p_end}
{phang}{cmd:shockvar(ln_inc) shockval(-1)  ///}{p_end}
{phang}{cmd:time(10) range(30) graph ec}{p_end}

{phang}The same shock for the following equation, with an area plot: d.ln_inv = l.ln_inv + ld.ln_inv + l3d.ln_inv + l.ln_inc + l2.ln_inc + l3.ln_inc + d.ln_consump + l.ln_consump{p_end}

{phang}{cmd:dynardl ln_inv ln_inc ln_consump,  ///}{p_end}
{phang}{cmd:lags(1, 1/3, 1) diffs(., ., 1) lagdiffs(1 3, ., .)  ///}{p_end}
{phang}{cmd:shockvar(ln_inc) shockval(-1)  ///}{p_end}
{phang}{cmd:time(10) range(30) graph ec rarea sims(5000)}{p_end}

{phang}The same shock for the following equation, graphed as an impulse response function, with ln_inc and ln_consump set to 6 and 7, respectively: ln_inv = l.ln_inv + ln_inc + l.ln_inc + ln_consump + l.ln_consump{p_end}

{phang}{cmd:dynardl ln_inv ln_inc ln_consump,  ///}{p_end}
{phang}{cmd:lags(1, 1, 1) levels(., 1, 1) forceset(., 6, 7)  ///}{p_end}
{phang}{cmd:shockvar(ln_inc) shockval(-1)  ///}{p_end}
{phang}{cmd:time(10) range(30) graph change sims(5000)}{p_end}


{phang} See Jordan and Philips (Forthcoming) for more examples and an in-depth discussion.{p_end}

{marker version}{...}
{title:Version}

version 1.0.5, Apr 18, 2018.

