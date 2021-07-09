{smcl}
{* *! version 2.0.2  04jul2012}{...}
{cmd:help mfpigen}{right: Patrick Royston}
{hline}


{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:mfpigen} {hline 2}}Modelling interactions between pairs of covariates{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:mfpigen}
[, {it:options}]
{cmd::}
{it:regression_cmd}
[{it:yvar}]
{it:mainvarlist}
{ifin}
{weight}
[{cmd:,}
{it:regression_cmd_options}]


{pstd}
{marker syntax}where

{phang}
{it:regression_cmd} may be
{helpb clogit},
{helpb cnreg},
{helpb glm},
{helpb intreg}, 
{helpb logistic},
{helpb logit},
{helpb mlogit},
{helpb nbreg},
{helpb ologit},
{helpb oprobit},
{helpb poisson},
{helpb probit},
{helpb qreg},
{helpb regress},
{helpb rreg},
{helpb stcox},
{helpb stpm2} (if installed),
{helpb streg},
{helpb xtgee}.


{synoptset 24}{...}
{marker mfpigen_options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt ag:ainst(against_var)}}variable to plot interaction function against{p_end}
{synopt :{opt al:pha(alpha_list)}}significance level(s) for selecting FP functions of continuous predictors{p_end}
{synopt :{opt df(df_list)}}degrees of freedom for FP functions of continuous predictors{p_end}
{synopt :{opt for:ward(#)}}forward selection of interaction(s) (linear terms only){p_end}
{synopt :{opt fpl:ot([%]list)}}define plotting values for an interaction{p_end}
{synopt :{opt lin:adj(xvarlist_lin)}}adjust for linear effects of variables in {it:xvarlist_lin}{p_end}
{synopt :{opt int:eractions(intlist)}}adjust for predefined interactions{p_end}
{synopt :{opt mfpa:dj(xvarlist_mfp)}}adjust for effects of variables in {it:xvarlist_mfp}, as selected by {cmd:mfp}{p_end}
{synopt :{opt nomfp}}prevent MFP being applied to variables in {it:mainvarlist}{p_end}
{synopt :{opt nover:bose}}suppresses the display of interaction results{p_end}
{synopt :{opt out:come(outcome)}}outcome for prediction ({it:regression_cmd} = {cmd:mlogit} only){p_end}
{synopt :{opt plot:opts(plot_options)}}options for {cmd:graph twoway}{p_end}
{synopt :{opt pv:alue(#)}}P-value for screening interactions{p_end}
{synopt :{opt sel:ect(select_list)}}significance level for selecting variables{p_end}
{synopt :{opt se}}standard error of predicted functions (see {opt fplot()}){p_end}
{synopt :{it:mfp_options}}options for {cmd:mfp}, excluding {cmd:select()}, {cmd:alpha()}, {cmd:df()}
(which are described separately, see above){p_end}
{synopt :{it:regression_cmd_options}}options for {it:regression_cmd}{p_end}
{synoptline}
{p2colreset}{...}

{phang}
All weight types supported by {it:regression_cmd} are allowed; see
{help weight}.{p_end}

{phang}
{it:yvar} is not allowed for {opt streg}, {opt stcox} and {opt stpm2};
for these commands, you must first {helpb stset} your data.


{title:Description}

{pstd}
{cmd:mfpigen} is designed to investigate interactions between each
pair of covariates in {it:mainvarlist}. Typically these are continuous covariates,
but linear effects of binary or categorical covariates are allowed. Factor variables
are supported. Fractional polynomials are used to model the main
effects of continuous variables. The statistical significance of each
interaction between pairs of selected FP (or linear) functions is reported.

{pstd}
For each pair of variables in {it:mainvarlist}, {cmd:mfpigen} applies {help mfp}
to the remaining variables in {it:mainvarlist} and also to variables defined by 
{opt mfpadj(xvarlist_mfp)} to select a `confounder model' which is used to
adjust an interaction model for possible confounding by other covariates.
Variables defined by {opt linadj(xvarlist_lin)} are included as linear in
the confounder part of the model, and are included in every model.
Variables in {it:mainvarlist} and {it:xvarlist_mfp} are subject to FP transformation
if required, as determined by {cmd:mfp}, whereas those in {it:xvarlist_lin}
are modelled as linear. The best-fitting FP functions of each pair of variables
modelled with an interaction and of variables in the confounder model,
including the adjustment variables, are selected simultaneously
in single runs of {cmd:mfp}.


{title:Options}

{phang}
{opt against(against_var)} defines the variable against which interaction
function(s) are to be plotted. See {opt fplot()} for more details.

{phang}
{opt alpha(alpha_list)} sets the significance levels for testing between FP models
    of different degrees. The rules for {it:alpha_list} are the same as for
    {it:df_list} in the {opt df()} option.
    The default nominal p-value (significance level, selection level) is 0.05
    for all variables.

{phang}
{opt df(df_list)} sets the df for each predictor in {it:mainvarlist}
and (if the {opt mfpadj()} option is used) in {it:xvarlist_mfp}.
See {helpb mfp##df:df()} for further details. Models with all terms linear
are specified as {cmd:df(1)}.

{phang}
{opt forward(#)} performs forward selection of interaction(s) at significance
level {it:#}. This option applies only to models with all terms linear,
therefore use of the {opt forward()} option implies {cmd:df(1)}. The
procedure searches for the most significant interaction. If it is
is significant at the {it:#} level, the interaction is reported and the
procedure continues to search for anothher interaction. The process stops
when no further significant interactions are found.

{phang}
{opt fplot([%]list)} plots the interaction between the last pair of
items in {it:mainvarlist}, say, {it:item1} and {it:item2}.
Typically, both items are continuous variables. {it:list} is a
set of values of {it:item1}. The fitted function of {it:item2} is
evaluated at each value in {it:list} and plotted against {it:item2}.
The functions are adjusted for other variables in the selected model,
if any. Examples:

{phang2}{cmd:. mfpigen, fplot(30 40 50 60) : regress y age bmi}{p_end}
{phang2}{cmd:. mfpigen, select(0.05) fplot(30 40 50 60) : regress y sex chol age bmi}{p_end}

{pin}
If {it:list} is preceded by a percent sign ({bf:%}) then its values
are interpreted as centiles of the distribution of {it:item1}. If
{it:list} is only a percent sign, default centiles of 25, 50
and 75 are used. Examples:

{phang2}{cmd:. mfpigen, fplot(%10 50 90) : regress y age bmi}{p_end}
{phang2}{cmd:. mfpigen, select(0.05) fplot(%) : regress y sex chol age bmi}{p_end}

{pin}
A second possibility is for {it:item1} to be a factor variable. Then
{it:list} consists of factor levels of {it:item1}, and {cmd:fplot(%)}
means plot at all available levels. Example:

{phang2}{cmd:. mfpigen, fplot(1 2 3) : stcox i.grade age}{p_end}

{pin}
A third possibility is for {it:item1} to be of the form
{bf:(}{it:varlist}{bf:)}, i.e. a list of variables enclosed in parentheses.
{it:varlist} could comprise any combination of binary, categorical or
continuous variables. {it:list} defines values of each variable in
{it:varlist} at which the function of {it:item2} is to be plotted. For example,
{cmd: fplot(0 0 0 1 1 0 1 1)} might define the four possible combinations
of two binary variables, each of which takes the value 0 or 1. This
would plot four fitted curves against {it:item2}, one for each combination
of the two binary variables. Example:

{phang2}{cmd:. mfpigen, fplot(0 0 0 1 1 0 1 1): regress y (sex treat) age}{p_end}

{pin}
An abbreviated syntax is available. If the pairs of values in {it:list}
are enclosed within parentheses, all combinations of the values are 
generated. For example, {cmd: fplot(0 0 0 1 1 0 1 1)} could be abbreviated as
{cmd: fplot((0 1)(0 1))}. All combinations of three such binary variables could
be specified as {cmd: fplot((0 1)(0 1)(0 1))}, much easier than spelling out
the required 2 ^ 3 = 8 pairs = 16 values. Examples:

{phang2}{cmd:. mfpigen, fplot((0 1)(0 1)(0 1)): regress y (sex treat group) age}{p_end}
{phang2}{cmd:. mfpigen, fplot((25 50)(10 100)): regress y (age pgr) bmi}{p_end}

{pin}
Items within parentheses do not have to be 0 and 1; for example, they
could be values of a continuous variable. However, there must be exactly
two values within each pair of parentheses. More general combinations of
values should be spelled out explicitly using the standard syntax.

{pin}
{it:item2} could consist of a single variable, as already discussed, or take
the form {bf:(}{it:varlist}{bf:)}. {it:varlist} might be an FP transformation
created outside {cmd:mfpigen}. For example, to plot an interaction between
sex and an FP2 function of age with powers (-2, 2) centered on age 50,
we could code:

{phang2}{cmd:. fracgen age -2 2, center(50)}{p_end}
{phang2}{cmd:. mfpigen, fplot(0 1) adjust(no) against(age): regress y sex (age_1 age_2)}{p_end}

{pin}
{cmd:fracgen} creates FP-transformed variables called {cmd:age_1} and {cmd:age_2},
centered on age 50, that is, such that the mean of each of {cmd:age_1} and
{cmd:age_2} is zero. The {cmd:adjust(no)} option of {cmd:mfpigen} prevents
{cmd:mfp} from re-centering the already-centered variables {cmd:age_1} and
{cmd:age_2}. {cmd:mfpigen} computes the interaction between {cmd:sex}
and both of {cmd:age_1} and {cmd:age_2}. The example assumes that {cmd:sex}
is coded as 0 and 1, but this coding is not mandatory. Note the use of the
option {cmd:against(age)}. Without this option, the plots would be against
the first member of {it:varlist}, in this case, {cmd:age_1}. We would be
unlikely to want this.

{pin}
As well as being plotted, the fitted functions are saved under the names
{cmd:_fit1}, {cmd:_fit2}, ... .

{phang}
{opt interactions(intlist)} adjusts all investigated models for predefined
interactions specified by {it:intlist}. The syntax of {it:intlist} is
{it:var11} {it:var12} [{cmd:,} {it:var21} {it:var22} ...]. Each pair of
variables is translated to model terms of the form
{cmd:c.}{it:var11}{cmd:##}{cmd:c.}{it:var12} if {it:var11} and {it:var12}
are both continuous. If either of the variables is an FP transformation with more
than one term, the terms are included in parentheses, for example to include
an interaction between an FP2 function of age and binary sex, we would 
specify interactions((age_1 age_2) i.sex), where {cmd:age_1 age_2} are
the FP2 transformed terms for age. The interaction terms are included as
linear terms in all interaction models investigated.

{pmore}
Note that continuous variables should be entered as they are and
categorical predictors preceded by {cmd:i.}, for example,
{cmd:interactions((age_1 age_2) i.race)}.

{phang}
{cmd:linadj(}{it:xvarlist_lin}{cmd:)} includes {it:xvarlist_lin} as
confounder variables in all the fitted models. They are always modelled
as linear and are not subject to selection. {it:xvarlist_lin} may include
factor variables.

{phang}
{cmd:mfpadj(}{it:xvarlist_mfp}{cmd:)} includes {it:xvarlist_mfp} as
confounder variables in all the fitted models. Members of {it:xvarlist_mfp}
are subject to selection and to determination of FP functional
form by {cmd:mfp}, according to the options used for model selection (see
the {opt alpha()}, {opt df()} and {opt select()} options).
{it:xvarlist_mfp} may include factor variables.

{phang}
{opt nomfp} prevents MFP being applied to variables in {it:mainvarlist}, and
prevents them being candidates for an adjustment model. The default is to
select these variables using {cmd:mfp}, if necessary with FP transformation.

{phang}
{opt noverbose} suppresses the display of interaction results. This is useful
when you are building up a model including multiple interactions and you wish
to see which interaction has the lowest P-value.

{phang}
{opt outcome(outcome)} specifies the outcome in {cmd:mlogit} models
for which the linear predictor is to be calculated. For details of
the syntax, see the description of {opt outcome()}
in {helpb mlogit postestimation}.

{phang}
{opt plotopts(plot_options)} are options for the graph of fitted function
to be used by {cmd:graph twoway}.

{phang}
{opt pvalue(#)} defines the P-value to be used for screening interactions.
Interactions that are not significant at the {it:#} level are not
displayed, thus reducing clutter in the output. Default {it:#} is 1,
meaning results for all interactions are displayed. Note that the
{opt pvalue()} option has no effect on estimation, it is merely for
convenience when inspecting many interactions for "interesting" ones.

{phang}
{opt se} requests standard errors of the fitted functions provided by
the {opt fplot()} options. These are saved under the names {cmd:_sefit1},
{cmd:_sefit2}, ... .

{phang}
{opt select(select_list)}
    sets the nominal p-values (significance levels) for variable selection by
    backward elimination.  A variable is dropped if its removal causes a
    non-significant increase in deviance.  The rules for {it:select_list} are
    the same as those for {it:df_list} in the {opt df()} option.
    Using the default selection level of 1 for all variables forces them all
    into the model.  Setting the nominal p-value to be 1 for a given variable
    forces it into the model, leaving others to be selected or not. The
    nominal p-value for elements of {it:mainvarlist} or {it:xvarlist_mfp}
    bound by parentheses is specified by including {opt (xvarlist)}
    or {opt (xvarlist_mfp)} in {it:select_list}. Note that variables
    in {it:xvarlist_lin} may not be included in {it:select_list}.

{phang}
{opt showmfp} displays each {cmd:mfp} command that is run by {cmd:mfpigen},
and its results. This is to enable you to check that the commands are correct
and as expected.

{phang}
{it:regression_cmd_options} are any options for {it:regression_cmd}.

{phang}
{it:mfp_options} are any options for {cmd:mfp}, excluding {opt alpha()},
{opt df()} and {opt select()}.


{title:Methodology}

{pstd}
The algorithm provided in {cmd:mfpigen} can be summarized as follows.
Suppose we have continuous variables z1 and z2 and potential confounders x:

{phang}
1. Apply MFP to z1, z2 and x with significance level a* for selecting members of
x and FP functions of continuous variables. Force z1 and z2 into the model and
apply the FP function selection procedure to them. This step requires a single
run of MFP.

{phang}
2. Calculate multiplicative interaction terms between the FP transformations
selected for z1 and z2, or between untransformed z1 and z2 if no FP
transformation is needed. For example, if both variables need FP2
transformation, four interaction terms are created.

{phang}
3. Refit the model selected on x, z1, z2 with the interaction terms included.
Test the latter in the usual way using a likelihood ratio test. If k
interaction terms are added to the model, the interaction chisquare test has
k d.f. For example, if FP2 functions were selected for both z1 and z2 then
k = 2 × 2 = 4.

{phang}
4. Consider all pairs of predictors for possible interaction,
irrespective of the statistical significance of their main effects in the MFP
model. If z1 and/or z2 is binary or forced to be linear, the procedure
simplifies to the usual situation. If z1 and/or z2 are categorical, joint
tests on all dummy variables are performed. An option is to treat the dummy
variables as separate predictors.

{phang}
5. Check all interactions for artefacts and ignore any that fail the
check. See section 7.4.2 of Royston & Sauerbrei (2008) for further details.

{phang}
6. If more than one interaction is detected, apply a forward stepwise procedure
to extend the main-effects model.

{pstd}
There is one main difference between this algorithm, MFPIgen, and MFPI (Royston & 
Sauerbrei 2004, 2009). In MFPI, the confounder model x is selected independently of
z1 and z2, whereas in MFPIgen, a joint model is selected. The reason for the
difference is that MFPI is principally intended for use with data from a
randomized trial in which the effect of the treatment covariate z1 is by
design independent of other covariate effects. Therefore, adjustment by x
is less important. In observational studies, however, it may be necessary
fully to adjust the effects of z1 and z2 for confounders before investigating
their interaction.

{pstd}
Since MFPIgen addresses dozens of potential interactions, multiple testing is
an issue. Results must be checked in detail and interpreted cautiously
as hypothesis-generating only.


{title:Examples}

{phang}{cmd:. mfpigen, alpha(0.2): logit y x1 x2 x3 x4 x5}

{phang}{cmd:. mfpigen: stcox x1 x2 x3 x4 x5, stratify(group)}

{phang}{cmd:. mfpigen, select(0.05) dfdefault(2) linadj(x1 x4 x5) mfpadj(x6 x7) fplot(%33 67) se: logit y x2 x3}

{phang}{cmd:. mfpigen, select(0.05) fplot(0 1) dfdefault(2) alpha(1): regress mpg price headroom trunk weight length turn displacement foreign gear_ratio}


{title:Author}

{phang}Patrick Royston{p_end}
{phang}MRC Clinical Trials Unit{p_end}
{phang}London, UK{p_end}
{phang}pr@ctu.mrc.ac.uk{p_end}


{title:References}

{phang}Royston, P., and W. Sauerbrei. 2008. Multivariable model-building. A
pragmatic approach based on fractional polynomials for modelling continuous variables,
pp. 172-181. Chichester, John Wiley and Sons.


{title:Also see}
{* {psee}Article: {it:Stata Journal}, volume 9, number 1: {browse "http://www.stata-journal.com/article.html?article=st0146":st0001}}
{psee}
Manual:  {hi:[R] fracpoly}, {hi:[R] mfp}{p_end}

{psee}
Online:  {helpb mfp}, {helpb fracpoly}, {helpb mfpi} (if installed){p_end}
