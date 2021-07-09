{smcl}
{* *! version 1.0 20 Jan 2020}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "eventdd##syntax"}{...}
{viewerjumpto "Description" "eventdd##description"}{...}
{viewerjumpto "Options" "eventdd##options"}{...}
{viewerjumpto "Remarks" "eventdd##remarks"}{...}
{viewerjumpto "Examples" "eventdd##examples"}{...}
{title:Title}
{phang}
{bf:eventdd} {hline 2} Estimate panel event study models and generate event study plots

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:eventdd}
varlist(min=2
fv
ts
numeric)
[{help if}]
[{help in}]
[{help weight}]{cmd:,}
{it:timevar(varname)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt timevar(varname)}}  Specifies the standardized time variable relative to the event of interest. This is required.
{p_end}
{synopt:{opt baseline(#)}}  Specifies the baseline period relative to the moment of the event of interest; the default is -1.
{p_end}
{synopt:{opt level(#)}} Set confidence {help level}; default is level(95).
{p_end}
{synopt:{opt accum}}  Accumulates periods beyond indicated lags and leads into a final coefficient/confidence interval.
{p_end}
{synopt:{opt lags(#)}}  Specifies the number of lags which should be included. This is only required when specifying the {cmd:accum} or {cmd:keepbal} options, otherwise all possible lags will be plotted.
{p_end}
{synopt:{opt leads(#)}}  Specifies the number of leads which should be included. This is only required when specifying the {cmd:accum} or {cmd:keepbal} options, otherwise all possible lags will be plotted.
{p_end}
{synopt:{opt noend}}  Requests that end points are suppressed from graphs. This is only available if specifying the {cmd:accum} option.
{p_end}
{synopt:{opt keepbal(varname)}}  Indicates that only units which are balanced in the panel should be kept, where {it:varname} indicates the panel variable (eg state).
{p_end}
{synopt:{opt ols}}  Requests that the event study model should be estimated with Stata's {help regress} command.  This is the default.
{p_end}
{synopt:{opt fe}}  Requests that the event study model should be estimated with Stata's {help xtreg}, fe command.  The data must be {help xtset} if this option is used.
{p_end}
{synopt:{opt hdfe}}  Requests that the event study model should be estimated with the user-written {help reghdfe} command. 
{p_end}
{synopt:{opt absorb(varname)}}  Categorical variables that identify the fixed effects to be absorbed. Only required when specifying the {cmd:hdfe} option.
{p_end}
{synopt:{opt wboot}} Requests that standard errors be estimated by wild bootstrap. This requires the user-written {help boottest} command.  May not be combined with the {cmd:hdfe} option.
{p_end}
{synopt:{opt seed(#)}} Set random-number seed to #.
{p_end}
{synopt:{opt balanced}}  Requests that only balanced periods in which all units have data be shown in the plot.
{p_end}
{synopt:{opt graph_op(string)}}  specifies any options in {help twoway_options} which should be passed to the resulting event study graph, (eg title, axis, labels).
{p_end}
{synopt:{opt *}}  specifies any additional {help estimation options} and {help vce_option} which should be passed to the event study model, (eg robust or clustered sandwich estimator of variance).

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:eventdd} estimates a panel event study corresponding to a difference-in-difference style model
 where a series of lag and lead coefficients and confidence intervals are estimated and plotted.
 These lag and lead coefficients are all relative to the passage of an event of interest, which can
 occur at different moments in different units of the panel.  The estimated model is of the general
 form:

{p 8 12 2}y_st = Alpha + {bind:Lag^K_st * BetaK} + ... + {bind:Lag^2_st * Beta2} + {bind:Lead^0_st * gamma0} + ... {bind:Lead^L_st * gammaL} + mu_s + lambda_t + u_st      (1)

{pstd}
 where {it: y_st} is an outcome of interest for state {it: s} and time {it: t}, and a series of K
 Leads and L Lags are considered relative to the event of interest.  Fixed effects for state and
 time are included as {mu_s} and {lambda_t} respectively. 
 
{pstd}
 The command requires that the basic model be specified without lags and leads, and a variable
 should be indicated in {cmd: timevar()} which defines the standardized version of the time until
 the event, with missing values for units in which the event never occurs (pure control units).
 The command generates the estimation results and a graph documenting the coefficients and confidence
 intervals on all indicated lags and leads.  By default, the command uses as a baseline time period
 -1 (one year prior to the event of interest) and estimates event study models using Stata's
 {help regress} command.  However the command also allows estimation to be undertaken
 using {help xtreg} or {help reghdfe} (if installed).  Similarly, if specified, inference in
 eventdd can be based on wild bootstrapped standard errors using the {help boottest} command
 (if installed).  When displaying estimation results in a tabular format, lags and leads are
 named lag2, lag3, ... and lead0, lead1, ... respectively.  These variables are generated by the
 program internally, so any variables already named in this way in the dataset should be renamed
 prior to using the eventdd command.

{pstd}
 {cmd:eventdd} provides a useful check of parallel {it: pre}-trends in the context of a
 difference-in-differences (DD) estimator.  Broader discussion of these models are provided in
 Angrist and Pischke (2009, section 5.2), Freyaldenhoven et al,. (2019), and Goodman-Bacon
 (2018) (among many other references).  Examples of use are given in the "Examples"
 section below.

{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt timevar(varname)} is a required option. The time variable specified should contain a standardized
 value 0 corresponds to the time period in which the event of interest occurs for a given unit,
 -1 refers to one year prior to the event, 1 refers to one year following the event, and so forth.
 For any units in which the event does not occur (pure controls), this variable should contain missing
 values. 

{pstd}
{p_end}
{phang}
{opt baseline(#)}  Specifies the reference period for the event study, which is a baseline omitted category to which all other periods should be compared on the event study output.  By default this value is set at -1.

{pstd}
{p_end}
{phang}
{opt level(#)}  Specifies the confidence level, as a percentage, for confidence intervals.  The default is level(95) or as set by set level.  This sets the levels for confidence intervals in regression output, as well as the event study plot and returned matrices.

{pstd}
{p_end}
{phang}
{opt accum} Specifies that all periods beyond some specified values should be accumulated into final points.  For
example if {opt accum} is specified and {opt lags(#)} and {opt leads(#)} are both set equal to 10, a single coefficient
will be displayed in regressions and graphical output capturing 10 or more periods prior/post reform.  If {opt accum}
is not specified, all possible lags and leads will be included in models and graphical output.

{pstd}
{p_end}
{phang}
{opt lags(#)}  Indicates the maximum amount of pre-event periods to consider in the event study.  This can only be specified if either {cmd:accum} or {cmd:keepbal} are also specified.  Only integer values are permitted.

{pstd}
{p_end}
{phang}
{opt leads(#)}  Indicates the maximum amount of post-event periods to consider in the event study.  This can only be specified if either {cmd:accum} or {cmd:keepbal} are also specified.  Only integer values are permitted. 

{pstd}
{p_end}
{phang}
{opt noend}  Requests that accumulative end points are not shown on graphical output when the {opt accum} option is specified.

{pstd}
{p_end}
{phang}
{opt keepbal(varname)}  Specifies that only units which are balanced in the panel should be kept for estimation.  Here {it:varname} indicates the panel variable (eg state) which indicates units.
In this case "balance" refers to balance over calendar time.   An alternative option ({opt balanced}),
discussed below, allows for only balanced lags and leads {it:relative} to treatment to be considered in graphical output.

{pstd}
{p_end}
{phang}
{opt ols}  Requests that the event study model underlying graphical output should be estimated by OLS using Stata's {help regress} command.
In this case, unit-specific fixed effects and time-specific fixed effects must be included in the {help varlist} indicated in the command syntax.
This is the default estimation method.

{pstd}
{p_end}
{phang}
{opt fe}  Requests that the event study model underlying graphical output should be estimated by
fixed-effects (within) estimation, using Stata's {help xtreg}, fe command.  In this case the data
must be {help xtset} prior to use, and unit-specific fixed effects {it: should not} be included in
the {help varlist} indicated in the command syntax.  Time-specific fixed effects still need to be
included in the {help varlist} indicated in the command syntax.

{pstd}
{p_end}
{phang}
{opt hdfe} Requests that the event study model underlying graphical output should be estimated
using the user-written {help reghdfe} command (if installed).  If this option is specified,
the {opt absorb(varname)} option should also be specified to indicate which fixed effects
should be controlled in the regression.  Any fixed effects indicated in {opt absorb(varname)}
should not be included in the {help varlist} indicated in the command syntax.  This option
cannot be used in combination with the {opt wboot} option.

{pstd}
{p_end}
{phang}
{opt absorb(varlist)}  This option is only required when specifying the {cmd:hdfe} estimation option.
The {help varlist} identifies fixed effects to be absorbed (such as unit fixed effects).  Refer to
{help reghdfe} (if installed) for additional details.

{pstd}
{p_end}
{phang}
{opt wboot}  Indicates that inference in the event study plot produced by the command should be
based on wild cluster bootstrapped standard errors.  This requires the user-written {help boottest}
command (if installed).  This option may not be combined with the {cmd:hdfe} estimation option.

{pstd}
{p_end}
{phang}
{opt seed(#)}  Sets the {help seed} for simulation based calculations when using the {cmd:wboot} option. Setting the seed allows for confidence intervals to be replicated in repeated calls to {cmd:eventdd}.

{pstd}
{p_end}
{phang}
{opt *} Any other {help estimation options} permitted by {cmd:regress}, {cmd:xtreg}, or {cmd:reghdfe} can be included, and will be passed to the specified estimation command.
This allows for the inclusion of clustered standard errors or other variance estimators (see {help vce_option}).

{pstd}
{p_end}
{phang}
{opt balanced} Requests that only "balanced" lags and leads are plotted.  This will produce a
graph only showing lags and leads for which each treated unit has data, and as such, all
coefficients plotted will be based on all units in the data.  While only balanced lags and leads
will be plotted, all units and time periods will be included in the estimation of the event study.

{pstd}
{p_end}
{phang}
{opt graph_op(string)}  allows for the inclusion of any other graphing option permitted in
{help twoway_options}, including {help title_options}, {help added_lines_options}, {help axis_label_options}, among others.  This also allows for the use of alternative labels for graph axes.
If not specified, a standard graphical output will be provided.

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
Load data that replicates Stevenson and Wolfers' (2006) analysis of no-fault divorce reforms and female suicide, circulated with the {help bacondecomp} command.

{pstd}
 . {stata webuse set www.damianclarke.net/stata/}

{pstd}
 . {stata webuse bacon_example.dta}

{pstd}
Estimate a baseline two-way fixed effect DD model of female suicide on no-fault divorce reforms.

{pstd}
 . {stata xtreg asmrs post pcinc asmrh cases i.year, fe cluster(stfips)}

{pstd}
Generate standarized event-time variable giving time until passage of event for each state

{pstd}
 . {stata gen timeToTreat = year - _nfd}

{pstd}
Generate the event study plot associated to DD model of female suicide on no-fault divorce reforms with all periods.

{pstd}
 . {stata eventdd asmrs i.year, fe timevar(timeToTreat) cluster(stfips) graph_op(ytitle("Suicides per 1m Women") xlabel(-20(5)25) xtitle("Time"))}

{pstd}
Generate the event study plot associated to DD model of female suicide on no-fault divorce reforms with all periods but only showing balanced periods in plot.

{pstd}
 . {stata eventdd asmrs pcinc asmrh cases i.year i.stfips, fe timevar(timeToTreat) cluster(stfips) balanced graph_op(ytitle("Suicides per 1m Women"))}

{pstd}
Generate the event study plot associated to DD model of female suicide on no-fault divorce reforms only using balanced observations in the specified period.

{pstd}
 . {stata eventdd asmrs i.year, fe timevar(timeToTreat) cluster(stfips) lags(6) leads(15) keepbal(stfips) graph_op(ytitle("Suicides per 1m Women"))}

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}

{cmd:eventdd} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:eventdd}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(leads)}}all event leads, their lower bound, the point estimate, and their upper bound{p_end}
{synopt:{cmd:e(lags)}}all event lags, their lower bound, the point estimate, and their upper bound{p_end}


{title:References}
{pstd}

{pstd}
Angrist, Joshua and Jörn-Steffen Pischke. 2009. "Mostly Harmless Econometrics: An Empiricist's Companion".
Princeton University Press.

{pstd}
Freyaldenhoven, Simon, Christian Hansen, and Jesse M. Shapiro. 2019. "Pre-event Trends in 
the Panel Event-Study Design". American Economic Review 109(9):3307-38.

{pstd}
Goodman-Bacon, Andrew. 2018. "Difference-in-Differences with Variation in Treatment Timing".
National Bureau of Economic Research Working Paper 25018.

{pstd}
Stevenson, Betsey and Justin Wolfers. 2006. "Bargaining in the Shadow of
the Law: Divorce Laws and Family Distress". The Quarterly Journal of
Economics 121(1):267-288.


{title:Author}
{p}

Damian Clarke, Universidad de Santiago de Chile.
Email {browse "mailto:damian.clarke@protonmail.com":damian.clarke@protonmail.com}

Kathya Tapia, Universidad de Santiago de Chile.
Email {browse "mailto:kathya.tapia@usach.cl":kathya.tapia@usach.cl}



{title:See Also}
Related commands:

{help regress} 
{help xtset}
{help xtreg} 
{help reghdfe} (if installed)   {stata ssc install reghdfe} (to install this command)
{help bottest} (if installed)   {stata ssc install bottest} (to install this command)
{help twoway_options}
