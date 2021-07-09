{smcl}
{* *! version 1.5.3  02jan2013}{...}
{cmd:help boxtid}{right: Patrick Royston}
{hline}


{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:boxtid} {hline 2}}Box-Tidwell and exponential regression models{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd:boxtid}
{it:regression_cmd}
{it:yvar} {it:xvarlist} [{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
[{cmd:,}
{cmdab:cen:ter:(}{it:cen_list}{cmd:)}
{cmd:df(}{it:df_list}{cmd:)}
{cmdab:dfd:efault(}{it:#}{cmd:)}
{cmdab:exp:on(}{it:varlist}{cmd:)}
{cmdab:in:it(}{it:init_list}{cmd:)}
{cmdab:it:er(}{it:#}{cmd:)}
{cmdab:ltol:erance(}{it:#}{cmd:)}
{cmdab:tr:ace}
{cmdab:zer:o(}{it:varlist}{cmd:)}
{it:regression_cmd_options}
]

{pstd}
where {it:regression_cmd} may be {help clogit}, {help glm},
{help logistic}, {help logit}, {help poisson}, {help probit},
{help regress}, {help stcox}, or {help streg}.

{pstd}
{cmd:boxtid} shares the features of all estimation commands; see help
{help estcom}.

{pstd}
All weight types supported by {it:regression_cmd} are allowed; see help
{help weights}. Also, factor variables are permitted in {it:xvarlist}.

{pstd}
Note that {cmd:xfracplot} and {cmd:xfracpred} may be used after
{cmd:boxtid} to plot and predict fitted values, respectively.
The syntax for {cmd:xfracplot} and {cmd:xfracpred} is the same as for
{cmd:fracplot} and {cmd:fracpred}; see help on {help fracpoly}.


{title:Description}

{pstd}
{cmd:boxtid} is a generalization of {help fracpoly} in which continuous rather than
fractional powers of the continuous covariates are estimated. {cmd:boxtid} fits
Box & Tidwell's (1962) power transformation model to {it:yvar} with predictors
in {it:xvarlist}. The model function for each {it:xvar} in {it:xvarlist} is

	b1 * xvar^p1 + b2 * xvar^p2 ...

{pstd}
{cmd:boxtid} also fits exponential models for predictors specified in {cmd:expon()}.
The model function for each such {it:xvar} in {it:xvarlist} is

	b1 * exp(p1 * xvar) + b2 * exp(p2 * xvar) ...

{pstd}
The quantities p1, p2, ... are real numbers. After execution, {cmd:boxtid}
leaves variables in the data named
{hi:I}{it:xv}{hi:__1}, {hi:I}{it:xv}{hi:__2}, ..., where {it:xv}
represents the first four letters of the name of {it:xvar}, the first
member of {it:xvarlist}. The new variables contain the best-fitting powers of
{it:xvar} (as centered and scaled by {cmd:boxtid}). Also left are variables
named {hi:I}{it:xv}{hi:_p1}, {hi:I}{it:xv}{hi:_p2}, ... which are auxiliary
variables (see Remarks). Subsequent members of {it:xvarlist}, if any, also
leave behind such variables.


{title:Options}

{phang}
{cmd:center}{cmd:(}{it:cen_list}{cmd:)} defines the centering for the
covariates {it:xvar1}, {it:xvar2}, ....  The default is
{cmd:center}{cmd:(mean)}, except for binary covariates where it is
{cmd:center(}{it:#}{cmd:)}, {it:#} being the lower of the two distinct values
of the covariate. {it:cen_list} is a comma-separated list with elements
{it:varlist}{cmd::}{c -(}{cmd:mean}|{it:#}|{cmd:no}{c )-}, except that the
first element may optionally be of the form
{c -(}{cmd:mean}|{it:#}|{cmd:no}{c )-} to specify the default 
for all variables. For example, {cmd:center(no, age:mean)} sets the default
centering to {cmd:no} and that for {hi:age} to {cmd:mean}.

{phang}
{cmd:df(}{it:df_list}{cmd:)}
sets up the degrees of freedom (df) for each predictor. The df (not
counting the regression constant, {cmd:_cons}) are twice the degree of the
Box-Tidwell function, defining a model with m terms to have degree m.
For example an {it:xvar} fitted as a second-degree Box-Tidwell function
has 4 df.  The first item in df_list may be either {it:#} or
{it:varlist}{cmd::}{it:#}.  Subsequent items must be
{it:varlist}{cmd::}{it:#}.  Items are separated by commas and {it:varlist}
is specified in the usual way for variables.  With the first type of item,
the df for all predictors are taken to be {it:#}.  With the second type of
item, all members of {it:varlist} (which must be a subset of
{it:xvarlist}) have {it:#} df.

{p 8 8 2}
    The default degrees of freedom for a predictor of type varlist specified in
    {it:xvarlist} but not in {it:df_list} are assigned according to the
     number of distinct (unique) values of the predictor, as follows:

        {hline 43}
        # of distinct values    default df
        {hline 43}
                  1             (invalid predictor)
                 2-3            1
                 4-5            min(2, {cmd:dfdefault()})
                 >=6            {cmd:dfdefault()}
        {hline 43}

{p 8 8 2}
    Example:  {cmd:df(4)}{break}
    All variables have 4 df.

{p 8 8 2}
    Example:  {cmd:df(2, weight displ:4)}{break}
    {cmd:weight} and {cmd:displ} have 4 df, all other variables have 2 df.

{p 8 8 2}
    Example:  {cmd:df(weight displ:4, mpg:2)}{break}
    {cmd:weight} and {cmd:displ} have 4 df, {cmd:mpg} has 2 df, all other
    variables have the default of 1 df.

{phang}
{cmd:dfdefault(}{it:#}{cmd:)} determines the default maximum degrees of
freedom (df) for a predictor. Default {it:#} is 2 (one power term, one beta).

{phang}
{cmd:iter(}{it:#}{cmd:)} sets {it:#} to be the maximum number of iterations
allowed for the fitting algorithm to converge. Default: 100.

{phang}
{cmd:expon(}{it:varlist}{cmd:)} specifies that all members of varlist are to be modelled
using an exponential function, the default being a power (Box-Tidwell)
model. For each {it:xvar} (a member of {it:varlist}), a multi-exponential model
is fitted, namely

	b1 * exp(p1 * xvar) + b2 * exp(p2 * xvar) +...

{phang}
{cmd:init(}{it:init_list}{cmd:)} sets initial values for the parameters
p1, p2, ... of the model. By default these are calculated automatically.
The first item in {it:init_list} may be either {it:#} [{it:#} ...] or
{it:varlist}{cmd::}{it:#} [{it:#} ...]. Subsequent items must be
{it:varlist}{cmd::}{it:#} [{it:#} ...]. Items are separated by commas
and {it:varlist} is specified in the usual way for variables. If the
first item is {it:#}[{it:#} ...], this becomes the default initial value
for all variables, but subsequent items (re)set the initial value for
variables in subsequent {it:varlist}s. If the df for a variable in the
model is d (greater than 1) then {it:# #} ... consists of d/2 items.
Typically d = 2 so that there is just one initial value, {it:#}.

{phang}
{cmd:ltolerance(}{it:#}{cmd:)} is the maximum difference in deviance
between iterations required for convergence of the fitting algorithm.
Default {it:#}: 0.001.

{phang}
{cmd:powers(}{it:powerlist}{cmd:)} defines the powers to be used with
fractional polynomial initialization for {it:xvarlist} (see Remarks).

{phang}
{cmd:trace} reports the progress of the fitting procedure towards convergence.

{phang}
{cmd:zero(}{it:varlist}{cmd:)} indicates transformation of negative and zero
values of all members of {it:varlist} to zero before fitting the model
(see Remarks).
 
{phang}
{it:regression_cmd_options} are any of the options available with
{it:regression_cmd}.


{title:Remarks}

{pstd}
{cmd:boxtid} finds and reports a multiple regression model comprising the maximum
likelihood estimate of p1, p2, ... for each member of {it:xvarlist}. The model that
is fit depends on the type of {it:regression_cmd} that is used.

{pstd}
The fitting procedure is iterative and requires accurate starting values for
the powers p1, p2, ... {cmd:boxtid} finds initial values for the p's by
fitting a fractional polynomial of the appropriate degree for each xvar
in turn, with the remaining xvars treated as linear. This procedure
greatly reduces the amount
of iteration needed subsequently to obtain maximum likelihood estimates
of the p's.

{pstd}
The table of output includes for each member of {it:xvarlist} a test of whether
the relation is linear. That is, it reports a quantity called
{cmd:Nonlin. dev.}, the difference in deviance between
the continuous-power model for an xvar and a model linear in xvar,
adjusting for other variables in the model. A P-value from a chi-square
or F test of the hypothesis of linearity, and the estimated linear coefficient
for the xvar, are given.

{pstd}
Appropriate estimates of the standard errors of p1, p2, ... are provided in the
table of output, and the standard errors of the corresponding regression
coefficients are correctly estimated. This requires the auxiliary variables
ln(xvar) * xvar^p1, ln(xvar) * xvar^p2, ... to be included in the model.
The estimated t- or z-values for the coefficients of these terms should be
zero to at least 3 decimal places. If they are not zero, then the estimation
procedure probably has not converged properly; the value of {it:#} in
{cmd:ltolerance()} should be reduced below its default value of 0.001,
and the model re-fitted.

{pstd}
If an xvar has any negative or zero values and neither the {cmd:expon()}
nor the {cmd:zero()} option is used, {cmd:boxtid} behaves exactly like
{help fracpoly} in that it subtracts the minimum of xvar from xvar and
adds the rounding (or counting) interval. The interval is defined
as the smallest positive difference between the ordered values of xvar. After
this change of origin, the minimum value of xvar is guaranteed positive.

{pstd}
An example of the {cmd:zero()} option is in the assessment of the effect of cigarette
smoking on the risk of a disease in an epidemiological study. Since non-smokers
may be qualitatively different from smokers, the effect of quantity smoked,
regarded as a continuous risk factor, may be discontinuous at zero. The risk
may be modelled as a constant for the non-smokers and a Box-Tidwell function of
the amount smoked for the smokers by including the {cmd:zero()} option
and a dummy variable for non-smokers, for example

        {cmd:. gen byte nonsmoker = (num_cigs==0) if ~missing(num_cigs)}
        {cmd:. boxtid logit death num_cigs nonsmoker, zero(num_cigs)}

{pstd}
Omission of {cmd:zero(num_cigs)} would cause {cmd:num_cigs} to be transformed
before analysis by the addition of a suitable constant, probably 1.

{pstd}
Convergence of the algorithm is not guaranteed and may be hard to achieve for
models with xvars with 4 or more degrees of freedom. Sometimes a large
negative or positive power estimate with an enormous standard error is
obtained, a sign that the model may be overparametrized. It is worth trying
a lower degree model and noting whether the deviance is significantly reduced
(chi-square or F test on 2 df).


{title:Examples}

{phang}{cmd:. sysuse auto.dta}{p_end}
{phang}{cmd:. boxtid regress mpg weight}{p_end}
{phang}{cmd:. boxtid regress mpg weight displ foreign}{p_end}
{phang}{cmd:. boxtid regress mpg weight displ foreign, df(weight displ:2, foreign:1)}{p_end}
{phang}{cmd:. boxtid regress mpg displ weight, expon(weight)}{p_end}
{phang}{cmd:. boxtid logit foreign mpg, center(no)}{p_end}
{phang}{cmd:. boxtid glm foreign mpg, family(bin)}{p_end}
{phang}{cmd:. xfracplot mpg}{p_end}


{title:Reference}

{phang}Box GEP, Tidwell PW. 1962. Transformation of the independent variables.
Technometrics 4:531-550.


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London.
patrick.royston@ctu.mrc.ac.uk


{title:Also see}

{p 4 13 2}
Online:  help for {help fracpoly}, {help mfp}.
