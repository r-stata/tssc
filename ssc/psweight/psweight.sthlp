{smcl}
{* Copyright (C) Mathematica This code cannot be copied, distributed or used without the express written permission of Mathematica , Inc.}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[TE] teffects intro" "mansection TE teffectsintro"}{...}
{vieweralsosee "[TE] teffects ipw" "mansection TE teffectsipw"}{...}
{vieweralsosee "[R] logit" "mansection R logit"}{...}
{vieweralsosee "[M-2] class" "mansection M-2 class"}{...}
{viewerjumpto "Title" "psweight##title"}{...}
{viewerjumpto "Syntax" "psweight##syntax"}{...}
{viewerjumpto "Description" "psweight##description"}{...}
{viewerjumpto "Remarks" "psweight##remarks"}{...}
{viewerjumpto "Options" "psweight##options"}{...}
{viewerjumpto "Examples" "psweight##examples"}{...}
{viewerjumpto "Author" "psweight##author"}{...}
{viewerjumpto "Stored results" "psweight##results"}{...}
{viewerjumpto "References" "psweight##references"}{...}
{marker title}{...}
{title:Title}

{p2colset 2 14 16 2}{...}
{p2col:{bf:psweight} {hline 2}}IPW- and CBPS-type propensity score reweighting,
with various extensions{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{p 8 12 2}
. {cmd:psweight} {it:{help psweight##subcmd:subcmd}}
                      {it:{help varname:tvar}} {it:{help varlist:tmvarlist}}
                      {ifin}
                      [{it:{help psweight##weight:weight}}]
                      [{cmd:,}
                      {it:{help psweight##stat:stat}}
                      {it:{help psweight##penalty:penalty}}
                      {it:{help psweight##variance:variance}}
                      {it:{help psweight##options_table:options}}]

{p 8 12 2}
. {cmd:psweight} {opt balance:only}
                      {it:{help varname:tvar}} {it:{help varlist:tmvarlist}}
                      {ifin}
                      [{it:{help psweight##weight:weight}}]
                      [{cmd:,}
                      {opth mw:eight(varname)}
                      {it:{help psweight##variance:variance}}
                      {it:{help psweight##options_table:options}}]

{p 8 12 2}
. {cmd:psweight} {opt call} [v = ] [{it:classfunction()} | {it:classvariable}]

{phang2}
{it:tvar} must contain values 0 or 1, representing the treatment (1) and comparison (0) groups.

{phang2}
{it:tmvarlist} specifies the variables that predict treatment assignment in
the treatment model.

{phang2}
{it:classfunction()} is a function of the psweight Mata class
(the functions may take arguments),
{it:classvariable} is a member variable,
and {it:v} is a new Mata variable;
see details {help psweight##call:below}.


{marker subcmd}{...}
{synoptset 18}{...}
{synopthdr:subcmd}
{synoptline}
{synopt: {opt ipw}}logit regression{p_end}
{synopt: {opt cbps}}just-identified covariate-balancing propensity score{p_end}
{synopt: {opt cbpsoid}}over-identified covariate-balancing propensity score{p_end}
{synopt: {opt pcbps}}penalized covariate-balancing propensity score{p_end}
{synopt: {opt mean_sd_sq}}minimize mean(stddiff())^2{p_end}
{synopt: {opt sd_sq}}minimize sum(stddiff()^2){p_end}
{synopt: {opt stdprogdiff}}minimize sum(stdprogdiff()^2){p_end}
{synopt: {opt mean_sd}}synonym for {it:mean_sd_sq}{p_end}
{synopt: {opt sd}}synonym for {it:sd_sq}{p_end}
{synoptline}
{p 4 6 2}Only one {it:subcmd} may be specified.{p_end}


{marker stat}{...}
{synopthdr:stat}
{synoptline}
{synopt: {opt ate}}estimate average treatment effect in population; the default{p_end}
{synopt: {opt atet}}estimate average treatment effect on the treated{p_end}
{synopt: {opt ateu}}estimate average treatment effect on the untreated{p_end}
{synoptline}
{p 4 6 2}Only one {it:stat} may be specified.{p_end}


{marker penalty}{...}
{synopthdr:penalty}
{synoptline}
{synopt: {opt cvt:arget(# # #)}}applies penalty using the coefficient of variation of the weight distribution; default is no penalty: cvtarget(0 0 2){p_end}
{synopt: {opt skewt:arget(# # #)}}applies penalty using the skewness of the weight distribution; default no penalty: skewtarget (0 0 2){p_end}
{synopt: {opt kurtt:arget(# # #)}}applies penalty using the excess kurtosis of the weight distribution; default no penalty: kurttarget(0 0 2){p_end}
{synoptline}
{p 4 6 2}One or more penalty options may be specified.{p_end}


{marker variance}{...}
{synopthdr:variance}
{synoptline}
{synopt: {opt pool:edvariance}}uses the pooled (treatment plus control) sample's variances to calculate standardized differences; the default{p_end}
{synopt: {opt con:trolvariance}}uses the control group's variances to calculate standardized differences{p_end}
{synopt: {opt tre:atvariance}}uses the treatment group's variances to calculate standardized difference{p_end}
{synopt: {opt ave:ragevariance}}uses (the control group's variances + treatment group's variances)/2 to calculate standardized differences{p_end}
{synoptline}
{p 4 6 2}Only one {it:variance} may be specified.{p_end}


{marker options_table}{...}
{synopthdr}
{synoptline}
{synopt: {opth dep:varlist(varlist)}}outcome variables{p_end}
{synopt: {it:{help psweight##display_options:display_options}}}control
columns and column formats, row spacing, line width, display of omitted
variables and base and empty cells, and factor-variable labeling{p_end}
{synopt: {it:{help psweight##maximize_options:maximize_options}}}control
the maximization process; seldom used {* includes from()}{p_end}
{synopt: {opt ntab:le}}display a table with sample sizes{p_end}
{synopt: {opt coefl:egend}}display legend instead of statistics{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:tmvarlist} may contain factor variables; see {help fvvarlists}.{p_end}
{p 4 6 2}
{marker weight}{...}
Sample weights may be specified as {opt fweight}s or {opt iweight}s;
see {help weight}. {opt iweight}s are treated the same as {opt fweight}s.{p_end}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:psweight} is a Stata command that offers Stata users easy access
to the {helpb psweight class:psweight Mata class}.

{pstd}
{cmd:psweight} {it:subcmd} computes inverse-probability weighting (IPW) weights for average treatment effect,
average treatment effect on the treated, and average treatment effect on the untreated estimators for observational data.
IPW estimators use estimated probability weights to correct for the missing data on the potential outcomes.
Probabilities of treatment--propensity scores--are computed for each observation with one of a variety of methods, including
logistic regression (traditional IPW),
covariate-balancing propensity scores (CBPS),
penalized covariate-balancing propensity scores (PCBPS),
prognostic score-balancing propensity scores, and
other methods.

{pstd}
{cmd:psweight} {cmd:balance} constructs a balance table without computing IPW weights.
The most common use case is when you wish to construct a balance table for the unweighted sample.
However, you can also construct a balance table with
{help psweight##mweight_opt:user-supplied weights}.

{pstd}
After running {cmd:psweight} you can apply class functions
to your data or access results through {cmd:psweight call};
see details {help psweight##call:below}.


{title:Remarks}

{pstd}
{cmd:psweight} {it:subcmd} constructs several variables:
{it:_pscore}, {it:_treated}, {it:_weight_mtch}, and {it:_weight}.
If these variables exist before running {cmd:psweight}, they will be replaced.{p_end}

{pstd}
{cmd:psweight} {it:subcmd} solves for propensity score model coefficients, propensity scores,
and IPW weights as follows:

{pmore}
The first step involves computing coefficients for the propensity score model, {it:b}.
The propensity score model takes the form of a logit regression model.
Specifically, the propensity score for each row in the data is defined as {p_end}

{center:p = {help mf_logit:invlogit}({it:X} {help [M-2] op_arith:*} {it:b}')}

{pmore} where {it:X} is the vector of matching variables ({it:tmvarlist}) for the respective row.

{pmore}
You specify a {it:{help psweight##subcmd:subcmd}} to control how the vector {it:b} is computed
in the internal numerical optimization problem.
As discussed in Kranker, Blue, and Vollmer Forrow (2019), we can set up optimization problems to solve for
the {it:b} that produces the best fit in the propensity score model,
the {it:b} that produces the best balance on matching variables,
the {it:b} that produces the best balance on prognostic scores, or something else.
The {it:subcmd} also determines how the term "best balance" is defined in the previous sentence.
That is, for a given {it:subcmd}, we can generically define {it:b} as the vector that solves the problem: {p_end}

{center:{it:b} = argmin {it:L(X,T,W)}}

{pmore} where {it:L(X,T,W)} is a "loss function" that corresponds to the specified {it:subcmd}
(e.g., logit regression or CBPS),
given the data ({it:X,T}) and a vector of weights {it:(W)}.
(The weights are computed using the propensity scores, as we describe below.
The propensity scores are calculated using {it:b}, the data, and the formula given above.)
The available {it:subcmd}s are listed below.

{pmore}
In Kranker, Blue, and Vollmer Forrow (2019), we proposed adding a "penalty" to the loss function
that lets you effectively prespecify the variance (or higher-order moments) of the IPW weight distribution.
By constraining the distribution of the weights, you can choose among alternative sets of matching weights,
some of which produce better balance and others of which yield higher statistical power.
The penalized method solves for {it:b} in:{p_end}

{center:{it:b} = argmin {it:L(X,T,W)} + {it:f(W)}}

{pmore}
where {it:f(W)} is a smooth, flexible function that increases as the vector of observation weights (W) becomes more variable.
The {it:{help psweight##penalty:penalty}} options control the functional form of {it:f(W)}; see details below.

{pmore}
Once the {it:b} is estimated, we can compute propensity scores ({it:p}) for each observation
with the formula given above and the observation's matching variables ({it:tmvarlist}).
The propensity scores are returned in a variable named {it:_pscore}.

{pmore}
Once propensity scores are computed for each observation, we can compute IPW "matching weights"
for each observation.
The formulas for the IPW weights depend on whether you request weights for estimating
the average treatment effect ({opt ate}),
the average treatment effect on the treated  ({opt atet}), or
the average treatment effect on the untreated  ({opt ateu}).
First we compute unnormalized weights as follows:

{phang3}
- The unnormalized {opt ate} weights are
1/{it:p} for treatment group observations and
1/(1-{it:p}) for control group observations.

{phang3}
- The unnormalized {opt atet} weights are
1 for treatment group observations and
{it:p}/(1-{it:p}) for control group observations.

{phang3}
- The unnormalized {opt ateu} weights are
(1-{it:p})/{it:p}  for treatment group observations and
1 for control group observations.

{pmore}
Next, the weights are normalized to have mean equal to 1 in each group,
and returned in the variable named {it:_weight_mtch}.

{pmore}
Finally, the final weights (a variable named {it:_weight}) are set equal to:{p_end}

{center:{it:_weight} = {it:W} {help [M-2] op_colon::*} {it:_weight_mtch}}

{pmore} where {it:W} are the {it:{help psweight##weight:sample weights}}.
(The variable {it:_weight} equals {it:_weight_mtch} if no sample weights are provided.
If sample weights are provided, the weights are normalized so the weighted mean equals 1 in each group.)
For convenience, (a copy of) the treatment group indicator variable is
returned in a variable named {it:_treated}.

{pstd}
After estimation, {cmd:psweight} {it:subcmd} will display the model coefficients {it:b}
and a summary of the newly constructed variables.


{marker call}
{pstd}
Postestimation commands: {cmd:psweight call}

{pmore}
The {cmd:psweight} {it:subcmd}
and {cmd:psweight} {cmd:balance} Stata commands are "wrappers" around the
{helpb psweight class:psweight Mata class}.
When either command is run, it constructs an instance of the class, and this instance
remains accessible to {cmd:psweight call} afterward.

{pmore}
Specifically, {cmd:psweight call} can be used to access the class functions or member variables.
A list of available functions ({it:classfunction()}) and member variables ({it:classvariable})
are available at: {helpb psweight class}

{pmore}
For example, the following code would calculate traditional IPW weights and then contruct
a balance table for the reweighted sample:{p_end}
{phang3}{cmd:. psweight ipw mbsmoke mmarried mage fbaby medu, treatvariance}{p_end}
{phang3}{cmd:. psweight call balanceresults()}{p_end}

{pmore}
You can also save the results of the function to a Mata variable, for exmaple:{p_end}
{phang3}{cmd:. psweight call mynewvar = stddiff()}{p_end}

{pmore}
Note that any default options that were overridden when {cmd:psweight} {it:subcmd} was called
will continue to be applied with {cmd:psweight call}.
In the example above, the balance table will use the treatment group's variance
to calculate standardized differences (rather than the default variance).
In general, I tried to use {help mf_st_view:views} rather than Mata variables to store data;
you could run into problems if you add, drop, or sort your data before using {cmd:psweight call}.

{pmore}
After you finish using the instance of the class, it can be deleted with:{p_end}
{phang3}{cmd:. mata: mata drop psweight_ado_most_recent}{p_end}


{marker options}{...}
{title:Options}

{dlgtab:subcmd}

{pstd}
The {it:subcmd} specifies which method is used to compute coefficients {it:b} for the
propensity score model. The seven available estimation methods are:

{pmore}
The {opt ipw} {it:subcmd} fits a {help logit:logit regression model} by maximum likelihood.

{pmore2}
The logit regression solves for {it:b} in the model:

{center:Prob({it:tvar} = 1 | {it:X}) = {help mf_logit:invlogit}({it:X} {help [M-2] op_arith:*} {it:b})}

{pmore}
The {opt cbps} {it:subcmd} computes just-identified covariate-balancing propensity scores
(Imai and Ratkovic 2014).

{pmore}
The {opt cbpsoid} {it:subcmd} computes over-identified covariate-balancing propensity scores.
(Imai and Ratkovic 2014).

{pmore}
The {opt pcbps} {it:subcmd} implements penalized covariate-balancing propensity scores (Kranker, Blue, and Vollmer Forrow 2019).
The {opt pcbps} {it:subcmd} requires that at least one
{it:{help psweight##penalty:penalty}} option be specified.
This is a synonym for the {it:cbps} {it:subcmd} when one or
more of the {it:{help psweight##penalty:penalty}} options is included.

{pmore}
The {opt mean_sd_sq} or {opt mean_sd} {it:subcmd}s find the model coefficients that minimize the quantity:
mean({help psweight class:stddiff()})^2.
That is, the weights minimize the mean standardized difference, squared.

{pmore}
The {opt sd_sq} or {opt sd} {it:subcmd}s find the model coefficients that minimize the quantity:
sum({help psweight class:stddiff()}:^2).
That is, the weights minimize the squared (standardized) differences
in means of {it:tmvarlist} between the treatment and control groups.
If you have more than one variable in {it:tmvarlist},
the squared (standardized) differences in prognostic scores are summed.

{pmore}
The {opt stdprogdiff} {it:subcmd} finds the model coefficients that minimize the quantity:
sum({help psweight class:stdprogdiff()}:^2).
That is, the weights minimize the squared (standardized) differences
in mean prognostic scores between the treatment and control groups.
If you have more than one outcome variable,
the squared (standardized) differences in prognostic scores are summed.

{pmore2}
The {it:stdprogdiff} {it:subcmd} requires that dependent
variables be specified (through the {opt depvarlist}() option).

{pmore2}
Prognostic scores are computed by fitting a linear regression model
of the {it:tmvarlist} on the dependent variable(s) by ordinary least squares using only
control group observations, and then computing predicted values (for the whole sample).
This method of computing prognostic scores follows Hansen (2008) and Stuart, Lee, and Leacy (2013).


{dlgtab:Stat}

{pstd}
{it:stat} is one of three statistics: {opt ate}, {opt atet}, or {opt ateu}.
{opt ate} is the default.
The {it:stat} dictates how the command uses propensity scores ({it:p}) to compute
IPW "matching weights" (the variable named {it:_weight_mtch}).

{pmore}
{opt ate} specifies that the average treatment effect be estimated.

{pmore}
{opt atet} specifies that the average treatment effect on the treated be estimated.

{pmore}
{opt ateu} specifies that the average treatment effect on the untreated be estimated.

{pstd}The formulas used for computing IPW weights for each of these three stats are described above.


{dlgtab:Penalty}

{pstd}
The {it:penalty} options determine the function, {it:f(W)},
that we use to modify the loss function ({it:L(X,T,W)}).
If none of these options are specified, {it:f(W)}=0.

{phang2}{opt cvtarget(# # #)} applies a penalty using the coefficient of variation of the weight distribution.
If {opt cvopt(a, b, c)} is specified, then the loss function is modified as:{p_end}
{center:{it:L'(X,T,W) = L(X,T,W) + a * abs(({help psweight class:wgt_cv()} - b)^c)}}
{phang3}The default is no penalty: cvtarget(0 . .).

{phang2}{opt skewtarget(# # #)} applies a penalty using the skewness of the weight distribution.
If {opt skewtarget(d, e, f)} is specified, then the loss function is modified as:{p_end}
{center:{it:L'(X,T,W) = L(X,T,W) + d * abs(({help psweight class:wgt_skewness()} - e)^f)}}
{phang3}The default is no penalty: skewtarget(0 . .).{p_end}

{phang2}{opt kurttarget(# # #)} applies a penalty using the excess kurtosis of the weight distribution.
If {opt kurttarget(g, h, i)} is specified, then the loss function is modified as:{p_end}
{center:{it:L'(X,T,W) = L(X,T,W) + g* abs(({help psweight class:wgt_kurtosis()} - h)^i)}}
{phang3}The default is no penalty: kurttarget(0 . .).{p_end}
{...}
{* maxtarget option is undocumented}{...}


{dlgtab:Variance}

{pstd}
{it:variance} is one of three statistics: {opt pooledvariance}, {opt controlvariance}, {opt treatvariance}, or {opt averagevariance}.
{opt pooledvariance} is the default.
The {it:variance} dictates how the command standardizes the difference in means between the treatment and control groups.
Standardized differences are used to compute the loss function for some {it:{help psweight##subcmd:subcmds}}
and for computing balance tables.

{phang2}
{opt pooledvariance} uses the pooled (treatment plus control) sample's variances to calculate standardized differences; the default

{phang2}
{opt controlvariance} uses the control group's variances to calculate standardized differences

{phang2}
{opt treatvariance} uses the treatment group's variances to calculate standardized difference

{phang2}
{opt averagevariance} uses (the control group's variances + treatment group's variances)/2 to calculate standardized differences (as in {help tebalance})


{dlgtab:Other options}

{phang}
{opth depvarlist(varlist)} specificies dependent variables (outcome variables).
The data for the treatment group observations are ignored, but the data for the
the control group are used to compute prognostic scores (see above).

{marker display_options}
{phang}
{it:display_options}:

{phang2}
The following options control the display of the coefficient tables:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:level}s,
{opt nofvlab:el},
{opt fvwrap(#)},
{opt fvwrapon(style)},
{opt cformat(%fmt)},
and
{opt nolstretch}
see {help estimation options##display_options:[R] estimation options}.{p_end}

{phang2}
The following options control the display of the balance tables:
{opt formats(%fmt)},
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels},
{opt nofvlab:el},
{opt fvwrap(#)},
{opt fvwrapon(style)}, and
{opt nolstretch};
see {help _matrix_table##display_options: _matrix_table}.

{marker maximize_options}{...}
{phang}
{it:maximize_options} control the maximization process:
{opt from(init_specs)},
{opt tr:ace},
{opt grad:ient},
{opt hess:ian},
{cmd:showstep},
{opt tech:nique(algorithm_specs)},
{opt iter:ate(#)},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt qtol:erance(#)},
{opt nonrtol:erance},
{opt showtol:erance}, and
{cmdab:dif:ficult}.
For a description of these options, see {manhelp maximize R} and
{help mf_moptimize_init_mlopts:moptimize_init_mlopts()}.

{phang}
{opt ntable} displays a table with sample sizes and the sum of the weights.

{phang}
{cmd:coeflegend};
{helpb estimation options##coeflegend:[R] estimation options}.

{* [opt noconstant]; see [helpb estimation options:[R] estimation options].}{...}

{dlgtab:psweight balance}

{marker mweight_opt}
{phang}
{opth mweight(varname)} is a variable containing user-specified "matching" weights.
This variable is the analogue to the _weight_mtch variable;
it should not be multiplied with the {it:{help psweight##weight:sample weights}}.

{phang2}
If {opth mweight(varname)} is not specified, the balance table is constructed with "unweighted" data.
(Only the {it:{help psweight##weight:sample weights}} are applied.)

{phang}
As explained in the {help psweight##syntax:syntax}, {cmd:psweight} {cmd:balance} also allows many of the options listed above.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse cattaneo2}{p_end}

{pstd}
Balance before reweighting{p_end}
{phang2}{cmd:. psweight balance mbsmoke mmarried mage fbaby medu}{p_end}

{pstd}
Estimate the average treatment effect of smoking on birthweight, using a
logit model to predict treatment status{p_end}
{phang2}{cmd:. psweight ipw mbsmoke mmarried mage fbaby medu}{p_end}
{phang2}{cmd:. psweight call balanceresults()}{p_end}

{pstd}Estimate the average treatment effect on the treated with CBPS{p_end}
{phang2}{cmd:. psweight cbps mbsmoke mmarried mage fbaby medu, atet}{p_end}
{phang2}{cmd:. psweight call balanceresults()}{p_end}

{pstd}Estimate the average treatment effect on the treated with Penalized CBPS{p_end}
{phang2}{cmd:. psweight pcbps mbsmoke mmarried mage fbaby medu, atet cvtarget(1 .5 6)}{p_end}
{phang2}{cmd:. psweight call balanceresults()}{p_end}

{phang}For more examples, see psweight_example.do{p_end}


{marker author}{...}
{title:Author}

{pstd}By Keith Kranker{break}
Mathematica{p_end}

{pstd}Suggested Citation:{p_end}
{phang2}Kranker, K. "psweight: IPW- and CBPS-type propensity score reweighting, with various extensions," Statistical Software Components S458657, Boston College Department of Economics, 2019. Available at https://ideas.repec.org/c/boc/bocode/s458657.html.{p_end}
{phang2}- or -{p_end}
{phang2}Kranker, K., L. Blue, and L. Vollmer Forrow.  "Improving Effect Estimates by Limiting the Variability in Inverse Propensity Score Weights." Manuscript under review, 2019.{p_end}


{title:Acknowledgements}

{pstd}
My coauthors, Laura Blue and Lauren Vollmer Forrow, were closely involved with the
developement of the Penalized CBPS methodology.
We received many helpful suggestions from our colleages at Mathematica,
especially those on the Comprehensive Primary Care Plus Evaluation team.
Of note, I thank Liz Potamites for testing early versions of the program and providing helpful feedback.{p_end}

{pstd}
The code for implementing the CBPS method is based on work by Fong et al. (2018), namely the CBPS package for R.
I also reviewed the Stata CBPS implementation by Filip Premik.

{pstd}Source code is available at {browse "https://github.com/kkranker/psweight"}.
Please report issues at {browse "https://github.com/kkranker/psweight/issues"}.{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:psweight} {it:subcmd} and {cmd:psweight} {cmd:balance}
store the following in {cmd:e()}:

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2:Scalars}{p_end}
{synopt: {cmd:e(N)}}number of observations{p_end}

{p2col 5 14 18 2:Macros}{p_end}
{synopt: {cmd:e(cmd)}}{cmd:psweight}{p_end}
{synopt: {cmd:e(cmdline)}}command as typed{p_end}
{synopt: {cmd:e(properties)}}{opt b}{p_end}
{synopt: {cmd:e(subcmd)}}specified {it:{help psweight##subcmd:subcmd}}{p_end}
{synopt: {cmd:e(tvar)}}name of the treatment indicator ({it:tvar}){p_end}
{synopt: {cmd:e(tmvarlist)}}names of the matching variables ({it:tmvarlist}){p_end}
{synopt: {cmd:e(depvarlist)}}names of dependent variables (if any){p_end}
{synopt: {cmd:e(variance)}}specified {it:{help psweight##variance:variance}}{p_end}
{synopt: {cmd:e(wtype)}}weight type (if any){p_end}
{synopt: {cmd:e(wexp)}}weight expression (if any){p_end}
{synopt: {cmd:e(cvopt)}}specified {it:penalty} (if any){p_end}

{pstd}
In addition, {cmd:psweight} {it:subcmd} stores the following in {cmd:e()}:

{p2col 5 14 18 2:Macros}{p_end}
{synopt: {cmd:e(stat)}}specified {it:{help psweight##stat:stat}}{p_end}

{p2col 5 14 18 2:Matrices}{p_end}
{synopt: {cmd:e(b)}}coefficient vector{p_end}

{p2col 5 14 18 2:Functions}{p_end}
{synopt: {cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
In addition, {cmd:psweight} {cmd:balance} stores a matrix named {cmd:r(bal)}
and other output in {cmd:r()};
see the documentation for the {help psweight class:balancetable()}.

{pstd}
The {opt ntable} option adds a matrix stores a matrix named {cmd:r(N_table)}
and other output in {cmd:r()};
see the documentation for the {help psweight class:get_N() command}.


{marker references}{...}
{title:References}

{psee}
Fong, C., M. Ratkovic, K. Imai, C. Hazlett, X. Yang, and S. Peng.
2018.
CBPS: Covariate Balancing Propensity Score,
Package for the R programming langauage,
{it:The Comprehensive R Archive Network}.
Available at: {browse "https://CRAN.R-project.org/package=CBPS"}

{psee}
Hansen, B. B.
2008.
"The Prognostic Analogue of the Propensity Score."
{it:Biometrika},
95(2): 481–488, doi:10.1093/biomet/asn004.

{psee}
Imai, K. and M. Ratkovic.
2014.
"Covariate Balancing Propensity Score."
{it:Journal of the Royal Statistical Society: Series B (Statistical Methodology)},
76(1): 243–263, doi:10.1111/rssb.12027.

{psee}
Kranker, K., L. Blue, and L. Vollmer Forrow.
2019.
"Improving Effect Estimates by Limiting the Variability in Inverse Propensity Score Weights."
Manuscript under review.

{psee}
Stuart, E. A., B. K. Lee, and F. P. Leacy.
2013.
"Prognostic Score–based Balance Measures Can Be a Useful Diagnostic for Propensity Score Methods in Comparative Effectiveness Research."
{it:Journal of Clinical Epidemiology},
66(8): S84–S90.e1, doi:10.1016/j.jclinepi.2013.01.013.
