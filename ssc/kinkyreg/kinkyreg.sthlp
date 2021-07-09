{smcl}
{* *! version 1.0.1  12sep2020}{...}
{* *! Sebastian Kripfganz, www.kripfganz.de}{...}
{* *! Jan F. Kiviet, sites.google.com/site/homepagejfk/}{...}
{vieweralsosee "kinkyreg postestimation" "help kinkyreg_postestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "[R] ivregress" "help ivregress"}{...}
{vieweralsosee "[G-2] graph twoway" "help graph_twoway"}{...}
{viewerjumpto "Syntax" "kinkyreg##syntax"}{...}
{viewerjumpto "Description" "kinkyreg##description"}{...}
{viewerjumpto "Options" "kinkyreg##options"}{...}
{viewerjumpto "Example" "kinkyreg##example"}{...}
{viewerjumpto "Saved results" "kinkyreg##results"}{...}
{viewerjumpto "Version history and updates" "kinkyreg##update"}{...}
{viewerjumpto "Authors" "kinkyreg##authors"}{...}
{viewerjumpto "References" "kinkyreg##references"}{...}
{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{bf:kinkyreg} {hline 2}}Kinky least squares estimation and inference{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}{cmd:kinkyreg} {depvar} [{it:{help varlist:varlist1}}] {cmd:(}{it:{help varlist:varlist2}} [{cmd:=} {it:{help varlist:varlist_iv}}]{cmd:)} {ifin} [{cmd:,} {it:options}]


{synoptset 24 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Model}
{p2coldent :* {opth endo:geneity(numlist)}}specify values for the endogeneity correlations{p_end}
{synopt:{opt ek:urtosis(#)}}specify kurtosis of error term{p_end}
{synopt:{opt xk:urtosis(#)}}specify kurtosis of right-hand side variables{p_end}
{synopt:{opt r:ange(#_1 #_2)}}admissible range for endogeneity{p_end}
{synopt:{opt step:size(#)}}step size for considered endogeneities{p_end}
{synopt:{opt nocons:tant}}suppress constant term{p_end}

{syntab:Reporting}
{synopt:{opt corr:elation(#)}}postulated endogeneity for regression output{p_end}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt sm:all}}make degrees-of-freedom adjustment and report small-sample statistics{p_end}
{synopt:{opth in:ference(varlist)}}specify variables for KLS inference{p_end}
{synopt:{opt lincom}{cmd:(}{it:#}{cmd::} {it:exp}{cmd:)}}specify linear combinations for KLS inference; can be specified more than once{p_end}
{synopt:{opt tw:oway}{cmd:(}{it:{help kinkyreg##options_spec:twoway_spec}}{cmd:)}}specify options for twoway graphs; can be specified more than once{p_end}
{synopt:{opt coefp:lot}{cmd:(}{it:{help kinkyreg##options_spec:coefplot_spec}}{cmd:)}}specify options for coefficient plots; can be specified more than once{p_end}
{synopt:{opt cip:lot}{cmd:(}{it:{help kinkyreg##options_spec:ciplot_spec}}{cmd:)}}specify options for confidence interval plots; can be specified more than once{p_end}
{synopt:{opt name:stub(namestub)}}set prefix for twoway graph names{p_end}
INCLUDE help shortdes-coeflegend
{synopt:{opt nogr:aph}}suppress creation of graphs; seldom used{p_end}
{synopt:{opt nohe:ader}}suppress output header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{opt novstore}}do not store variance-covariance matrices for each grid point; seldom used{p_end}
{synopt:{it:{help kinkyreg##display_options:display_options}}}control
INCLUDE help shortdes-displayoptall
{synoptline}
{p2colreset}{...}
{p 4 6 2}* This option is required if {it:varlist2} contains multiple endogenous variables.{p_end}

{marker options_spec}{...}
{p 4 6 2}
{it:twoway_spec} is

{p 8 12 2}
[{varname}|{it:#}] [{cmd:,} {it:{help twoway_options}} {opt order(orderinfo)} {opt yrange(#_1 #_2)} {opt addplot(plotinfo)}]

{p 4 6 2}
{it:coefplot_spec} is

{p 8 12 2}
{cmd:kls}|{cmd:iv} [{varname}|{it:#}] [{cmd:,} {it:{help line_options}} {cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)}]

{p 4 6 2}
{it:ciplot_spec} is

{p 8 12 2}
{cmd:kls}|{cmd:iv} [{varname}|{it:#}] [{cmd:,} {it:{help fitarea_options}} {cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)}]

{p 4 6 2}
See {helpb kinkyreg postestimation} for features available after estimation.{p_end}
{p 4 6 2}
{cmd:kinkyreg} is a community-contributed program. The current version requires Stata version 13 or higher; see {help kinkyreg##update:version history and updates}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:kinkyreg} implements the kinky least squares (KLS) estimator proposed by Kiviet (2020).
The estimates are graphically compared to the instrumental variables (IV) / two-stage least squares (2SLS) estimator; see {helpb ivregress:[R] ivregress}.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opth endogeneity(numlist)} specifies values for the correlations of the endogenous variables with the error term. The order of the values corresponds to the order of the variables in {it:varlist2}.
A missing value ({cmd:.}) must be specified for the variable for which the endogeneity correlation should be varied over the range specified with option {cmd:range()}. All other endogeneity correlations are held fixed.
This option is required if {it:varlist2} contains multiple variables, and it is redundant otherwise.

{phang}
{opt ekurtosis(#)} specifies a value for the kurtosis of the error term to be used in the variance calculation. By default, the kurtosis is estimated based on the KLS estimates.

{phang}
{opt xkurtosis(#)} specifies a value for the kurtosis of the right-hand side variables to be used in the variance calculation. By default, the maximum of the estimated kurtosis for all variables in {it:varlist1} and {it:varlist2} is used.

{phang}
{opt range(#_1 #_2)} requests to compute the KLS estimator for all feasible endogeneity correlations in the interval [{it:#_1}, {it:#_2}]. The default is {cmd:range(-1 1)}.

{phang}
{opt stepsize(#)} sets the step size for the interval over which the KLS estimator is computed. The default is {cmd:stepsize(0.01)}.

{phang}
{opt noconstant}; see {helpb estimation options##noconstant:[R] estimation options}.

{dlgtab:Reporting}

{phang}
{opt correlation(#)} requests to display estimation results for the specified endogeneity correlation and to return the results in {cmd:e(b)} and {cmd:e(V)}.
If {it:#} does not match a value on the grid specified with options {cmd:range()} and {cmd:stepsize}, the estimation results for the closest grid point to {it:#} are displayed.
By default, a regression table is not displayed and estimation results are not returned in {cmd:e(b)} and {cmd:e(V)}.

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt small} requests that a degrees-of-freedom adjustment be made to the variance-covariance matrix and that small-sample t and F statistics be reported.
The adjustment factor is N/(N-K), where N is the number of observations and K the number of coefficients. By default, no degrees-of-freedom adjustment is made and z and Wald statistics are reported.

{phang}
{opth inference(varlist)} specifies variables for which KLS inference graphs are generated. By default, KLS inference is only carried out for the endogenous regressors, {opt inference(varlist2)}, unless option {cmd:lincom()} is specified.
In the latter case, the default is to produce KLS inference only for the specified linear combinations.

{phang}
{cmd:lincom(}{it:#}{cmd::} {it:exp}{cmd:)} specifies linear combinations {it:exp} of the regression coefficients for which KLS inference graphs are generated; see {helpb lincom:[R] lincom}.
You may specify as many sets of linear combinations, with different reference number {it:#} (an integer number between 1 and 1,999), as you need.

{phang}
{cmd:twoway(}[{varname}|{it:#}] [{cmd:,} {it:{help twoway_options}} {opt order(orderinfo)} {opt yrange(#_1 #_2)} {opt addplot(plotinfo)}} specifies options for twoway graphs; see {helpb graph_twoway:[G-2] graph twoway}.
{it:varname} must be a variable name in {it:varlist1} or {it:varlist2}. {it:#} must be the reference number for a linear combination specified with option {cmd:lincom()}.
If neither {it:varname} nor {it:#} are specified, then all twoway graphs are addressed.

{pmore}
The twoway options {cmd:name(}{it:{help name_option:name}}{cmd:)} and {cmd:saving(}{it:{help saving_option:filename}}{cmd:)} require {it:varname} or {it:#} to be specified.
If {cmd:name()} is not specified, {cmd:name(}{it:namestub}{cmd:_}{it:varname}|{it:#}{cmd:, replace)} is assumed. The prefix is set with option {opt namestub(namestub)}.
If {it:varname} is specified and the addressed variable contains factor variable or time series operators, the symbols "." and "#" are replaced by "_".

{pmore}
{opt order(orderinfo)} allows to change the order in which the plots are drawn. {it:orderinfo} is a list containing one or more of the following graph elements in the order in which they shall be drawn:
{cmd:kls} for the KLS coefficient estimate, {cmd:kls_ci} for the KLS confidence interval, {cmd:iv} for the IV coefficient estimate, and {cmd:iv_ci} for the IV confidence interval. The default is {cmd:order(iv_ci iv kls_ci kls)}.
This option also affects the order of the graph elements in the graph legend; see {it:{help legend_options}}.

{pmore}
{opt yrange(#_1 #_2)} specifies that the coefficient and confidence interval plots be restricted to the interval [{it:#_1}, {it:#_2}] on the {it:y} axis.
A missing value for {it:#_1} or {it:#_2} refers to minus or plus infinity, respectively.

{pmore}
{cmd:addplot(}{it:{help addplot_option:plot}} [{cmd:,} {opt before(orderinfo)}]{cmd:)} allows to overlay the twoway graphs with additional plots; see {it:{help addplot_option}}.
{opt before(orderinfo)} allows to change the order of the graph elements by drawing the additional plots immediately before the specified element.
{it:orderinfo} is one of the graph elements {cmd:kls}, {cmd:kls_ci}, {cmd:iv}, {cmd:iv_ci} as specified with suboption {cmd:order()}. By default, the additional plots are ordered last.

{phang}
{cmd:coefplot(}{cmd:kls}|{cmd:iv} [{varname}|{it:#}] [{cmd:,} {it:{help line_options}} {cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)}]{cmd:)} determines the look of the KLS and IV coefficient plots.
By default, these are options for twoway line plots; see {helpb line:[G-2] graph twoway line}. {it:varname} must be a variable name in {it:varlist1} or {it:varlist2}.
{it:#} must be the reference number for a linear combination specified with option {cmd:lincom()}. If neither {it:varname} nor {it:#} are specified, then all coefficient plots are addressed.

{pmore}
{cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)} allows to treat the plot as {it:newplottype} instead of a line plot; see {it:{help advanced_options}}.

{phang}
{cmd:ciplot(}{cmd:kls}|{cmd:iv} [{varname}|{it:#}] [{cmd:,} {it:{help fitarea_options}} {cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)}]{cmd:)} determines the look of the KLS and IV confidence interval plots.
By default, these are options for twoway range plots with area shading; see {helpb twoway_rarea:[G-2] graph twoway rarea}. {it:varname} must be a variable name in {it:varlist1} or {it:varlist2}.
{it:#} must be the reference number for a linear combination specified with option {cmd:lincom()}. If neither {it:varname} nor {it:#} are specified, then all confidence interval plots are addressed.

{pmore}
{cmd:recast(}{it:{help advanced_options:newplottype}}{cmd:)} allows to treat the plot as {it:newplottype} instead of a range plot with area shading; see {it:{help advanced_options}}.

{phang}
{opt namestub(namestub)} sets the prefix for the names of all graphs being created unless a name is explicitly specified with option {cmd:twoway(}{it:varname}|{it:#}{cmd:, }{opt name(name)}{cmd:)}.
The default is {cmd:namestub(kinkyreg)}. This option also affects the graphs created by the postestimation commands.

{phang}
{opt coeflegend}; see {helpb estimation options##coeflegend:[R] estimation options}.

{phang}
{opt nograph} suppresses the creation of graphs for KLS inference. This option is seldom used.

{phang}
{opt noheader} suppresses display of the header above the coefficient table that displays the number of observations.

{phang}
{opt notable} suppresses display of the coefficient table.

{phang}
{opt novstore} requests not to store the variance-covariance matrices for each grid point in order to consume less memory. By default, these matrices are stored as hidden estimation results.
They are required by some postestimation commands. This option is seldom used.

{marker display_options}{...}
{phang}
{it:display_options}: {opt noci}, {opt nopv:alues}, {opt noomit:ted}, {opt vsquish}, {opt noempty:cells}, {opt base:levels}, {opt allbase:levels}, {opt nofvlab:el}, {opt fvwrap(#)}, {opt fvwrapon(style)}, {opth cformat(%fmt)},
{opt pformat(%fmt)}, {opt sformat(%fmt)}, and {opt nolstretch}; see {helpb estimation options##display_options:[R] estimation options}.


{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}. {stata "use http://www.stata-press.com/data/imeus/griliches"}{p_end}

{pstd}Graphical inference for KLS estimation with 2SLS comparison{p_end}
{phang2}. {stata kinkyreg lw s expr tenure rns smsa _I* (iq = age mrt), range(-0.7 0.7) inference(iq s)}{p_end}

{pstd}Regression output for selected endogeneity correlation{p_end}
{phang2}. {stata kinkyreg, correlation(-0.4)}

{pstd}Graphical inference for KLS estimation with two endogenous variables and fixed endogeneity correlation for the second endogenous variable{p_end}
{phang2}. {stata kinkyreg lw s expr tenure rns smsa _I* (iq kww), endogeneity(. -0.2) range(-0.7 0.7) inference(iq s)}{p_end}


{marker results}{...}
{title:Saved results}

{pstd}
{cmd:kinkyreg} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom; not always saved{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(xkurtosis)}}maximum kurtosis of right-hand side variables{p_end}
{synopt:{cmd:e(grid_min)}}lower bound for admissible endogeneity{p_end}
{synopt:{cmd:e(grid_max)}}upper bound for admissible endogeneity{p_end}
{synopt:{cmd:e(grid_step)}}step size for considered endogeneities{p_end}
{synopt:{cmd:e(corr)}}postulated endogeneity for {cmd:e(b)}; not always saved{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:kinkyreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(estat_cmd)}}{cmd:kinkyreg_estat}{p_end}
{synopt:{cmd:e(predict)}}{cmd:kinkyreg_p}{p_end}
{synopt:{cmd:e(klsvar)}}endogenous variable with varied endogeneity{p_end}
{synopt:{cmd:e(endovars)}}endogenous variables{p_end}
{synopt:{cmd:e(exovars)}}exogenous variables{p_end}
{synopt:{cmd:e(ivvars)}}instrumental variables{p_end}
{synopt:{cmd:e(namestub)}}prefix for graph names{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}; not always saved{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector; not always saved{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators; not always saved{p_end}
{synopt:{cmd:e(b_kls)}}KLS coefficient vectors{p_end}
{synopt:{cmd:e(se_kls)}}KLS standard errors{p_end}
{synopt:{cmd:e(endogeneity)}}fixed endogeneity correlations; not always saved{p_end}
{synopt:{cmd:e(sigma2e)}}KLS estimates of sigma_e^2{p_end}
{synopt:{cmd:e(ekurtosis)}}kurtosis of KLS residuals{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker update}{...}
{title:Version history and updates}

{pstd}{cmd:kinkyreg} is a community-contributed program. To determine the currently installed version, type{p_end}
{phang2}. {stata which kinkyreg, all}{p_end}

{pstd}To update the {cmd:kinkyreg} package to the latest version, type{p_end}
{phang2}. {stata `"net install kinkyreg, from("http://www.kripfganz.de/stata/") replace"'}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}
Sebastian Kripfganz, University of Exeter, {browse "http://www.kripfganz.de"}

{pstd}
Jan F. Kiviet, University of Amsterdam, {browse "https://sites.google.com/site/homepagejfk/"}


{marker references}{...}
{title:References}

{phang}
Kiviet, J. F. 2020.
Testing the impossible: identifying exclusion restrictions.
{it:Journal of Econometrics} 218: 294-316.

{phang}
Kiviet, J. F. 2020.
Instrument-free inference under confined regressor endogeneity; derivations and applications.
{it:Stellenbosch Economic Working Papers}: WP09/2020.
