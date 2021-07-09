{smcl}
{* *! version 3.0.0  19apr2012}{...}
{cmd:help mfpi}, {cmd:help mfpi_plot}
{hline}


{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{hi:mfpi} {hline 2}}Modelling interactions between categorical and continuous/categorical covariates{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:mfpi} [, {it:mfpi_options}]
{cmd::} 
{it:{help mfp##syntax:regression_cmd}}
[{it:{help mfp##syntax:yvar1}} [{it:{help mfp##syntax:yvar2}}]]
{it:{help mfp##syntax:xvarlist}}
{ifin}
{weight}
[{cmd:,} {it:regression_cmd_options}]


{phang2}
{cmd:mfpi_plot}
{it:varname}
{ifin}
[
{cmd:,}
{it:mfpi_plot_options}
]



{synoptset 24}{...}
{marker mfpi_options}{...}
{synopthdr :mfpi_options}
{synoptline}
{synopt :{opt adju:st(xvarlist2)}}adjust linearly for {it:xvarlist2}{p_end}
{synopt :{opt all}}include out-of-sample observations in generated variables{p_end}
{synopt :{opt ce:nter(center_list)}}determine centering for FP-transformed variables{p_end}
{synopt :{opt det:ail}}give additional details of fitted models{p_end}
{synopt :{opt df(df_list)}}set up degrees of freedom for each predictor in {it:xvarlist}{p_end}
{synopt :{opt fl:ex(#)}}define flexibility of main-effects and interaction models{p_end}
{synopt :{opt fp1(fp1_zvarlist)}}use fractional polynomials (FPs) of degree 1 for main effects and interactions with {it:fp1_zvarlist}{p_end}
{synopt :{opt fp2(fp2_zvarlist)}}use FPs of degree 2 for main effects and interactions with {it:fp2_zvarlist}{p_end}
{synopt :{opt gend:iff(stubname)}}generate new variable(s) that contains the difference between the estimated functions{p_end}
{synopt :{opt genf(string)}}generate new variables that contain fitted functions{p_end}
{synopt :{opt lin:ear(linear_zvarlist)}}define list of variables whose linear interaction with {it:trt_var} is to be investigated{p_end}
{synopt :{opt mfp:opts(mfp_options)}}additional options for {helpb mfp}{p_end}
{synopt :{opt nosca:ling}}suppress scaling of continuous variables in FP transformations{p_end}
{synopt :{opt noci}}suppress standard errors and confidence intervals for {opt gendiff()} and {opt genf()} options{p_end}
{synopt :{opt sel:ect(select_list)}}set significance levels for variable selection in {it:xvarlist}{p_end}
{synopt :{opt show:model}}show variables and FP transformations selected from {it:xvarlist} by {helpb mfp}{p_end}
{synopt :{opt tr:eatment(trt_var)}}required - defines the categorical 'treatment' variable{p_end}
{synopt :{it:regression_cmd_options}}options for {it:regression_cmd}{p_end}
{synoptline}

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
{helpb stcrreg},
{helpb stpm2} (if installed),
{helpb streg},
{helpb xtgee}

{pstd}and

{phang}{it:varname} for {cmd:mfpi_plot} must be an existing variable.
Typically, {it:varname} is a member of
{it:linear_zvarlist}, {it:fp1_zvarlist} or {it:fp2_zvarlist}. See also the
remark on {bf:Working with composite variables} for details of plotting
with composite predictors, such as spline basis functions or fractional
polynomials, which can be done using a special feature of
{it:linear_zvarlist}s.


{marker mfpi_plot_options}{...}
{synopthdr :mfpi_plot_options}
{synoptline}
{synopt :{opt stub:name(stubname)}}required if the {opt gendiff()} option of
{cmd:mfpi} was not specified{p_end}
{synopt :{opt vn(#)}}variable number in {opt linear()}, {opt fp1()}, and {opt fp2()}{p_end}
{synopt :{opt level(#)}}select level of {it:trt_var} to compare with base level{p_end}
{synopt :{opt plot(plot)}}add other plots to generated graph{p_end}
{synopt :{it:graph_options}}options for {cmd:graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{phang}
All weight types supported by {it:regression_cmd} are allowed; see
{help weight}.{p_end}

{phang}
{it:yvar} is not allowed for {opt streg}, {opt stcox} and {opt stpm2}; for these
commands, you must first {helpb stset} your data.


{title:Description}

{pstd}
{cmd:mfpi} is designed to investigate the interaction of a categorical
covariate ({it:trt_var}) with covariate(s) specified by any combination of the
{cmd:fp1()}, {cmd:fp2()} and {cmd:linear()} options. Whether or not
{it:trt_var} is specified as a factor variable, it is handled as one. Typically,
{it:trt_var} is the treatment indicator variable in a randomized controlled
trial of one or more treatments against a control arm, with the lowest value
signifying the control arm.

{pstd}
{cmd:mfpi} adjusts interactions with {it:trt_var} for variables in
{it:xvarlist} (which may be subjected to FP transformation selected
by {cmd:mfp}) and/or linearly for variables in {it:xvarlist2}.

{pstd}
{cmd:mfpi_plot} produces a treatment-effect plot derived from variables
saved with the {opt gendiff()} option of {cmd:mfpi}. A treatment-effect
plot shows how the estimated treatment effect varies with a continuous
covariate when an interaction between the two has been modelled.


{title:Options for {cmd:mfpi}}

{phang}
{cmd:adjust(}{it:xvarlist2}{cmd:)} includes {it:xvarlist2} as
covariates with a linear functional form in all the fitted models.

{phang}
{cmd:all} allows prediction (see the {cmd:gendiff()} and {cmd:genf()}
options) for all available cases, irrespective of exclusion by {cmd:if},
{cmd:in}, or weights.

{phang}
{opt center(center_list)} determines the centering of FP-transformed variables.
The most likely requirement is to suppress centering for all such
variables, which is done with {cmd:center(no)}. The default behavior is
centering on the mean of each continuous predictor. For further details,
see the description of the {cmd:center()} option of {helpb fracpoly}.

{phang}
{cmd:detail} gives additional details of the fitted models.

{phang}
{cmd:df(}{it:df_list}{cmd:)} sets up the degrees of freedom (df) for
each predictor in {it:xvarlist}. The df (not counting the regression
constant, {cmd:_cons}) are twice the degree of the FP, so, for example, a
member of {it:xvarlist} fitted as a second-degree FP (FP2) has 4 df. The
first item in {it:df_list} can be either {it:#} or {it:varlist}{cmd::}{it:#}.
Subsequent items must be {it:varlist}{cmd::}{it:#}. Items are separated by
commas, and {it:varlist} is specified in the usual way for variables. With the
first type of item, the df for all predictors are taken to be {it:#}. With
the second type of item, all members of {it:varlist} (which must be a subset
of {it:xvarlist}) have {it:#} df.

{pin}
    The default df for a predictor of type {it:varlist} specified in
    {it:xvarlist} but not in {it:df_list} are assigned according to the
     number of distinct (unique) values of the predictor, as follows:

        {hline 63}
        No. of distinct values  Default df
        {hline 63}
                  1             (invalid -- covariate has variance 0)
                 2-3            1
                 4-5            min(2, {cmd:dfdefault(}{it:#}{cmd:)})
                 >=6            {cmd:dfdefault(}{it:#}{cmd:)}
        {hline 63}
{pin}
{cmd:dfdefault(}{it:#}{cmd:)} is an option of {cmd:mfp} (see the 
{opt mfpopts()} option and {helpb mfp}); its default {it:#} is 4,
meaning an FP2 function.

{pin}
    Example:  {cmd:df(4)}{break}
    All variables have 4 df.

{pin}
    Example:  {cmd:df(2, weight displ:4)}{break}
    {cmd:weight} and {cmd:displ} have 4 df, and all other variables have 2 df.

{pin}
    Example:  {cmd:df(weight displ:4, mpg:2)}{break}
    {cmd:weight} and {cmd:displ} have 4 df, {cmd:mpg} has 2 df, and all other
    variables have the default of 1 df.

{pin}
    Example:  {cmd:df(weight displ:4, 2)}{break}
    All variables have 2 df because the final 2 overrides the earlier 4.

{phang}
{opt flex(#)} defines the flexibility of the main-effects and
interaction models; {it:#} = 1 is the least flexible and {it:#} = 4 is the
most flexible. The default is {cmd:flex(1)}. See {cmd:Remarks} for
further details.

{phang}
{cmd:fp1(}{it:fp1_zvarlist}{cmd:)} defines a list of continuous
variables whose interactions with {it:trt_var} are to be investigated by
fitting FP functions of degree 1 (i.e., FP1 functions) to
each member of {it:fp1_zvarlist} in turn, at each level of {it:trt_var}. Also
see {cmd:flex()}.

{phang}
{cmd:fp2(}{it:fp2_zvarlist}{cmd:)} defines a list of continuous
variables whose interactions with {it:trt_var} are to be investigated by
fitting FP functions of degree 2 (i.e., FP2 functions) to
each member of {it:fp2_zvarlist} in turn, at each level of {it:trt_var}. Also
see {cmd:flex()}.

{phang}
{cmd:gendiff(}{it:stubname}{cmd:)} generates a new variable(s) called
{it:stubname}{it:#}{cmd:_}{it:j} that contains fj-f0, the difference between
the estimated functions (at level j minus level 0 of {it:trt_var}), for the
{it:#}th member of the list composed of {it:linear_zvarlist}, {it:fp1_zvarlist},
and {it:fp2_zvarlist}, in that order. The difference fj-f0 is an estimate of the
covariate-specific effect of level j compared with level 0 (e.g., the
covariate-specific treatment effect). {opt gendiff()} also creates new
variables called {it:stubname}{it:#}{cmd:s_}{it:j}, which contains the
standard error of fj-f0, and {it:stubname}{it:#}{cmd:lb_}{it:j} and
{it:stubname}{it:#}{cmd:ub_}{it:j}, the lower and upper 95% confidence limits,
thus providing all the quantities necessary for a treatment-effect plot.

{phang}
{cmd:genf(}{it:stubname}{cmd:)} generates new variables called
{it:stubname}{it:#}{cmd:_0}, {it:stubname}{it:#}{cmd:_1}, etc., that contain the
fitted functions at levels 0, 1, etc., of {it:trt_var}, respectively, for the
{it:#}th member of the list composed of {it:linear_zvarlist},
{it:fp1_zvarlist}, and {it:fp2_zvarlist}, in that order. For variables in
{it:fp1_zvarlist} and {it:fp2_zvarlist}, the same FP transformation is used at
each level of {it:trt_var}.  The estimated function at level 0 of {it:trt_var}
is adjusted to have mean 0.

{phang}
{cmd:linear(}{it:linear_zvarlist}{cmd:)} defines a list of variables
whose linear interactions with {it:trt_var} are to be investigated. If a
categorical variable in {it:linear_zvarlist} has more than 2 levels, the
necessary dummy variables must be created and placed between parentheses to
indicate that they should be tested together. More properly,
{it:linear_zvarlist} is a list of variables of which some may be dummies for
categorical variables.

{pin}
    For example, {cmd:linear((who2 who3))} would bind {cmd:who2} and {cmd:who3}
    together to create a predictor with 2 df for its main
    effect.

{pin}
For further information, see the remarks in {it:Working with composite variables}.


{phang} {cmd:mfpopts(}{it:mfp_options}{cmd:)} supplies {cmd:mfp} options to
{cmd:mfpi} for the creation of the adjustment model from {it:xvarlist}.

{phang}
{opt noscaling} suppresses scaling of all the continuous variables that
are subject to FP transformation. The default is automatic application
of scale factors; the behavior can be turned off for all such variables by
using {opt noscaling}. For further details, see the description of the same
option in {helpb fracpoly} and {helpb fracgen}.

{phang}
{opt select(select_list)} sets the nominal
P-values (significance levels) for variable selection among {it:xvarlist}
by backward elimination. See the {cmd:select()} option of {cmd:mfp} for
further details. A typical usage is {cmd:select(0.05)}, which selects all
variables in {it:xvarlist} that are significant at the 5% level according
to a backward stepwise algorithm.

{pin}
    Example:  {cmd:select(0.05)}{break}
    All variables have nominal p-value 5 percent.

{pin}
    Example:  {cmd:select(0.05, weight:1)}{break}
    All variables except {cmd:weight} have nominal p-value 5 percent;
    {cmd:weight} is forced into the model.

{pin}
    Example:  {cmd:select(a (b c):0.05)}{break}
    All variables except {cmd:a}, {cmd:b}, and {cmd:c} are forced into the
    model.  {cmd:b} and {cmd:c} are tested jointly with 2 df at the 5 percent
    level, and {cmd:a} is tested singly at the 5 percent level.

{phang}
{opt showmodel} shows the variables selected from {it:xvarlist} by
{helpb mfp}, together with their FP powers, where relevant. It also shows
the interaction model fitted last. {cmd:showmodel} is
a concise alternative to {cmd:detail}.

{phang}
{opt treatment(trt_var)} is required and defines the factor or categorical
variable whose interactions with variables specified in {cmd:linear()},
{cmd:fp1()}, or {cmd:fp2()} are of interest. {it:trt_var} must have at least
two distinct, nonmissing values, but the codes are arbitrary because they are
mapped to 0, 1, 2, etc.,  internally. The category corresponding to the lowest
value is taken as the reference category (level 0).

{phang}
{it:regression_cmd_options} are any options for {it:regression_cmd}.


{title:Options for {cmd:mfpi_plot}}

{phang}
{opt stubname(stubname)} is required if the {opt gendiff()} option
of {cmd:mfpi} was not specified. If the {opt gendiff()} option
was specified, then {it:stubname} is identified automatically. The
{opt stubname()} option allows you to produce a treatment-effect
plot for a variable whose {it:stubname} was used in an earlier run
of {cmd:mfpi}.

{phang}
{opt vn(#)} identifies the variable in {opt linear()}, {opt fp1()},
and {opt fp2()}, in that order, whose associated treatment effect is to be
plotted. Only one variable can be plotted in a given call to {cmd:mfpi_plot}.
For example, if {cmd:linear(x1 x2)} {cmd:fp1(x1 x3)} {cmd:fp2(x3)} was
specified, the list of variables is {cmd:x1 x2 x1 x3 x3}, and the total number
of variables is 5 (not 3). Thus {it:#} would be an integer between 1 and 5.
The default is {cmd:vn(1)}.

{phang}
{opt level(#)} defines the level of {it:trt_var} you wish to compare with
the base level. Levels of {it:trt_var} are coded 0, 1, 2, etc., with the
base (reference) level being 0. These coded levels may or may
not coincide with the actual values of {it:trt_var} in the data. For
example, {cmd:level(1)} denotes the second lowest value of {it:trt_var},
which could be any positive integer (not necessarily 1). The
default {it:#} is 1, meaning compare the second level of {it:trt_var}
with the first level. Specifying a non-existent level raises a
"variable ... not found" type of error message.

{phang}
{opt plot(plot)} provides a way to add other plots to the generated
graph; see {help addplot_option: [G] {it:addplot option}}.

{phang}
{it:graph_options} are any options of {cmd:graph twoway}, such as
{cmd:xtitle()} and {cmd:ytitle()}.


{title:Remarks}

    {ul:Methodology}

{pstd}
The algorithm used in {cmd:mfpi} can be summarized as follows. To fix ideas,
it is assumed that {it:trt_var} is a binary treatment indicator variable in a
randomized controlled clinical trial with two parallel groups. {it:trt_var}
therefore has two levels, arbitrarily labeled 0 and 1.

{pstd}
We first describe the mfpi algorithm for the default flexibility setting,
{cmd:flex(1)}, i.e., the least flexible case.

{pstd}
Let Z be the continuous or binary covariate of immediate interest, and let T be
the binary treatment variable with values of 0 and 1. Let X be a vector of
potentially prognostic factors. In {cmd:mfpi}, Z is a member of
{it:linear_zvarlist}, {it:fp1_zvarlist}, or {it:fp2_zvarlist}; T is {it:trt_var};
and X is {it:xvarlist}.  The basic idea is to model the relationship between
the outcome and Z at each level of T, adjusting for selected members of X, the
latter variables transformed by FP if appropriate.  A test for interaction is
performed on regression coefficients at the final step. The procedure for a Z
in {it:fp2_zvarlist} (see the {opt fp2()} option) is as follows:

{p 8 12 2}
1.  Apply the MFP algorithm to X with a p-value threshold of a* for selecting
variables and FP transformations. Let X* be the resulting covariate vector,
which we will call the adjustment model. X* can include (transformed) variables
in X selected by the MFP algorithm. If all variables in X are uninfluential, X*
may even be null. No covariate adjustment is then performed.
In some cases, X* can be formulated from subject-matter
knowledge, avoiding data-driven searching.

{p 8 12 2}
2.  Find by maximum likelihood the best-fitting FP2 powers (p1,p2) for Z,
adjusting for X*.

{p 8 12 2}
3.  For groups j = 0, 1 and powers p_i (i = 1, 2), define new predictors
Z_ji = Z^p_i if T = j, Z_ji = 0 otherwise.

{p 8 12 2}
4.  The test of T x Z interaction is a likelihood-ratio test between the nested
models T, Z_01, Z_02, Z_11, Z_12, X* and T, Z^p_1, Z^p_2, X*. The difference
in deviance is compared with chi-squared on 2 df.

{p 8 12 2}
5.  If an interaction is not found, Z is regarded as a potential prognostic
factor only. To investigate if an FP2 function is still needed for Z,
the final model is chosen by repeating step 1 but including Z as a
potential prognostic factor.

{pstd}
The procedure for a Z in {it:fp1_zvarlist}, i.e.,
using FP1 rather than FP2 functions of Z, is in principle identical.
The interaction is tested on 1 df.

{pstd}
If Z is binary or is modeled as linear (i.e., is a member of {it:linear_zvarlist}),
the approach reduces to the usual procedure to estimate and to
test for an interaction adjusted for covariates X*.

{pstd}
Extension to cases where T has more than 2 levels follows immediately.

{pstd}
For further details of the MFP algorithm used to construct X*, see Royston and
Ambler (1999), Sauerbrei and Royston (1999), and {helpb mfp}.
Further information on the method and applications is given by
Royston and Sauerbrei (2004).


    {ul:Other flexibility values}

{pstd}
The covariates X are treated in the same way for all values of {opt flex()}.
Only the main effect of Z and its interaction with T are dealt
with differently, as follows.

{pstd}
With {cmd:flex(2)}, the best-fitting FP powers for Z are found within
the context of interaction models. The powers are constrained to be
the same for all levels of T. The FP powers for the main effect of Z are
taken to be the same as for the Z x T interaction.

{pstd}
{cmd:flex(3)} is the same as {cmd:flex(2)}, except that the FP powers
for the main effect of Z are determined independently of the interaction,
exactly as for {cmd:flex(1)}.

{pstd}
{cmd:flex(4)}, the most flexible option, calls for FP powers to be 
estimated for the main effect of Z and also for all levels of T
in the interaction context.


    {ul:Hypothesis testing}

{pstd}
The main-effects and interaction models for {cmd:flex(1)} are nested,
so standard hypothesis testing may be used. Simulation studies (as
yet unpublished) have confirmed that the significance level of
{cmd:flex(1)} is close to its nominal value.

{pstd}
{cmd:flex(2)} uses the same FP function for the interaction as for the main
effect. At first glance, a standard hypothesis test appears appropriate.
However, no allowance has been made for degrees of freedom used to estimate FP
powers across the levels of the categorical variable in the interaction model,
so the p-values from interaction tests should be regarded as indicative, not
definitive.

{pstd}
Similar comments apply to {cmd:flex(3)}, except that here the main-effects and
interaction models are non-nested (because different FP models may be used for
the main effects and interaction). P-values should again be taken as indicative
rather than definitive.

{pstd}
The extra flexibility provided by {cmd:flex(4)} is reflected in its additional
degrees of freedom. Its significance level is currently under investigation
in simulation studies.


    {ul:Working with composite variables}

{pstd}
A useful feature of {cmd:mfpi} is the ability to model, and if
appropriate plot, functions of predictors represented by one or more
individual but linked variables. For example, a restricted cubic regression
spline with 4 knots, 2 interior and 2 boundary, is represented by 3 basis
functions. Regression is performed with these basis functions as predictors.
Such a set of predictors 'belongs' to just one original continuous predictor
and must be handled appropriately. This is done by surrounding in parentheses
({cmd:()}) the linked variables in the {opt linear()} option.

{pstd}
For example, suppose that {cmd:age_1 age_2 age_3} were restricted cubic
spline basis variables derived from a predictor called {cmd:age}, e.g. using
the Stata command {cmd:mkspline}. Analysis of
interaction between treatment and the spline function for {cmd:age} is
specified by the option {cmd:linear((age_ age_2 age_3))}:

{phang}
{cmd:. mkspline age_ = age, cubic nknots(4)}

{phang}
{cmd:. mfpi, select(0.05) treatment(treat) linear((age_1 age_2 age_3)): stcox z1 z2 z3}

{pstd}
When {cmd:treat} is binary, the interaction in the above example has 3 d.f.

{pstd}
A nice feature of this approach is that the treatment-effect plot created
by {cmd:mfpi_plot} works happily with the original variable. Continuing the
{cmd:age} example above, we specify the {opt gendiff()} option of {cmd:mfpi}
to create the variables necessary for the treatment-effect plot and then tell
{cmd:mfi_plot} to plot the age-related treatment difference and its 95%
pointwise confidence interval against {cmd:age} as follows:

{phang}
{cmd:. mfpi, select(0.05) treatment(treat) linear((age_1 age_2 age_3)) gendiff(d): stcox z1 z2 z3}

{phang}
{cmd:. mfpi_plot age}

{pstd}
The same approach works with categorical covariates with several levels, represented
by dummy variables. Alternatively, such covariates can be defined
as factor variables, for example, {cmd:linear(i.group)}. This avoids the need
to create dummy variables. Factor variables are not allowed to be combined
into groups using parentheses.


    {ul:Note on the base level}

{pstd}
{cmd:mfpi} assumes that the lowest value of {it:trt_var} represents the base
level (reference value). If you want a different value to be the base level,
you have to recode {it:trt_var} before running {cmd:mfpi}. For example

{phang}
{cmd:. recode trt (1=3) (3=1)}

{pstd}
would reverse the ordering of the levels 1, 2, 3 of the variable {cmd:trt}.
See {helpb recode} for details.


    {ul:Warning}

{pstd}
Excitement engendered by the discovery of interactions should be tempered by
proper caution. There is a significant problem of multiplicity and of
potential instability of the FP functions found. See Royston and Sauerbrei
(2004) for a more detailed discussion of this issue. It is prudent to check
whether the functions in each treatment group suggest a cutpoint(s) that can
reproduce a difference in response; whether the interaction is present in
univariate as well as multivariable models; and whether it is robust to
the choice of adjustment model.


{title:Examples}

{phang}
{cmd:. mfpi, select(0.05) showmodel treatment(i.treat) linear(c1 (c2 c3)) fp2(x1 x2): stcox x1 x2 c1 c2 c3}

{phang}
{cmd:. mfpi, select(1) degree(1) dfdefault(2) treatment(i.treat) linear(c1 (c2 c3)) fp1(x1 x2) fp2(x1 x2) genf(f) gendiff(d): logit y x1 x2 c1 c2 c3}

{phang}
{cmd:. mfpi, treatment(i.treat) linear(i.group x): regress y}

{phang}
{cmd:. mkspline age_ = age, cubic nknots(4)}

{phang}
{cmd:. mfpi, select(0.05) treatment(i.treat) linear((age_1 age_2 age_3)) gendiff(d): stcox z1 z2 z3}

{phang}
{cmd:. mfpi_plot age}


{title:Saved results}

{pstd}
In addition to what {it:regression_cmd} saves in {cmd:e()}, {cmd:mfpi} saves the
some or all of the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(nxvar)}}number of predictors in {it:xvarlist}{p_end}
{synopt:{cmd:r(nxf)}}number of predictors in {it:xvarlist} selected by {cmd:mfp}{p_end}
{synopt:{cmd:r(totdflin)}}total degrees of freedom for linear interaction model{p_end}
{synopt:{cmd:r(totdffp1)}}total degrees of freedom for FP1 interaction model{p_end}
{synopt:{cmd:r(totdffp2)}}total degrees of freedom for FP2 interaction model{p_end}
{synopt:{cmd:r(devlin)}}deviance for linear interaction model{p_end}
{synopt:{cmd:r(devfp1)}}deviance for FP1 interaction model{p_end}
{synopt:{cmd:r(devfp2)}}deviance for FP2 interaction model{p_end}
{synopt:{cmd:r(aiclin)}}AIC for linear interaction model{p_end}
{synopt:{cmd:r(aicfp1)}}AIC for FP1 interaction model{p_end}
{synopt:{cmd:r(aicfp2)}}AIC for FP2 interaction model{p_end}
{synopt:{cmd:r(chi2lin)}}chi-squared value for testing linear interaction model{p_end}
{synopt:{cmd:r(chi2fp1)}}chi-squared value for testing FP1 interaction model{p_end}
{synopt:{cmd:r(chi2fp2)}}chi-squared value for testing FP2 interaction model{p_end}
{synopt:{cmd:r(Plin)}}p-value for testing linear interaction model{p_end}
{synopt:{cmd:r(Pfp1)}}p-value for testing FP1 interaction model{p_end}
{synopt:{cmd:r(Pfp2)}}p-value for testing FP2 interaction model{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}{it:xvarlist}{p_end}
{synopt:{cmd:r(adjust)}}{it:xvarlist2}{p_end}
{synopt:{cmd:r(treatment)}}{it:trt_var}{p_end}
{synopt:{cmd:r(Linear)}}list of variables in {cmd:linear()}{p_end}
{synopt:{cmd:r(Fp1)}}list of variables in {cmd:fp1()}{p_end}
{synopt:{cmd:r(Fp2)}}list of variables in {cmd:fp2()}{p_end}
{synopt:{cmd:r(z)}}z, the final continuous variable processed{p_end}
{synopt:{cmd:r(powmain)}}FP powers for z, main effect{p_end}
{synopt:{cmd:r(powint0)}}FP powers for z at level 0 of {it:trt_var}{p_end}
{synopt:{cmd:r(powint`j')}}FP powers for z at level `j' of {it:trt_var} (`j' > 0){p_end}
{p2colreset}{...}


{title:Author}

{phang}Patrick Royston{p_end}
{phang}MRC Clinical Trials Unit{p_end}
{phang}London, UK{p_end}
{phang}pr@ctu.mrc.ac.uk{p_end}


{title:References}

{phang}Royston, P., and G. Ambler. 1999. sg112.1: Nonlinear regression
models involving power or exponential functions of covariates: Update.
{browse "http://www.stata.com/products/stb/journals/stb50.pdf":{it:Stata Technical Bulletin}} 50: 26. Reprinted in 
{browse "http://www.stata.com/products/stb/stbvols.html#9":{it:Stata Technical Bulletin Reprints}}, vol. 9, p. 180. College Station, TX:
Stata Press.

{phang}Royston, P., and W. Sauerbrei. 2004. A new approach to modelling
interactions between treatment and continuous covariates in clinical trials by
using fractional polynomials. {it:Statistics in Medicine} 23: 2509-2525.

{phang}Royston, P., and W. Sauerbrei. 2009. Two techniques for investigating
interactions between treatment and continuous covariates in clinical trials.
{it:Stata Journal} 9 (2): 230-251.

{phang}Sauerbrei, W., and P. Royston. 1999. Building multivariable prognostic
and diagnostic models: Transformation of the predictors by using fractional
polynomials. {it:Journal of the Royal Statistical Society, Series A} 162:
71-94.


{title:Also see}

{psee}Article: {it:Stata Journal}, volume 9, number 2: {browse "http://www.stata-journal.com/article.html?article=st0164":st0164}

{psee}
Manual:  {hi:[R] fracpoly}, {hi:[R] mfp}{p_end}

{psee}
Online:  {helpb mfp}{p_end}
