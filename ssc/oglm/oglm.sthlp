{smcl}
{* Last revised Aug 30, 2016}{...}
{hline}
help for {hi:oglm} version 2.30 released August 30, 2016
{hline}

{title:Ordinal Generalized Linear Models}

{p 8 15 2}
	{cmdab:oglm} {it:depvar} [{it:indepvars}]
	[{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
	[{cmd:,} 
	{cmd:link(}{it:logit/probit/cloglog/loglog/cauchit/log}{cmd:)}
	{cmd:force}
	{cmdab:lrf:orce} 
	{cmdab:sto:re(}{it:name}{cmd:)} 
	{cmdab:c:onstraints:(}{it:clist}{cmd:)} {cmdab:r:obust}
	{cmdab:cl:uster:(}{it:varname}{cmd:)}
	{cmdab:l:evel:(}{it:#}{cmd:)} 
	{opt or} {opt irr} {opt rrr} {opt eform} {opt hr}
	{cmdab:log}
	{cmdab:het:ero(}{it:varlist}{cmd:)} {opt scale(varlist)} {opt eq2(varlist)}
	{opt hc} {opt ls} {opt flip}
	{it:display_options} {it:maximize_options} ]

{p 4 4 2}
{cmd:oglm} supports factor variables and the {cmd:margins} command and requires Stata 
version 11.2 or later. Those with Stata 9 or 10 should use {cmd:oglm9} instead.

{p 4 4 2}
{cmd:oglm} shares the features of all estimation commands; see help
{help est}.    
{cmd:oglm} typed without arguments redisplays previous results.  
The following options may be given when redisplaying results:

{p 8 8 2}
	{cmdab:sto:re}
	{cmd:or} {opt irr} {opt rrr} {opt hr} {opt eform} 
	{cmdab:l:evel:(}{it:#}{cmd:)}

{p 4 4 2}
{opt by}, {opt svy}, {opt nestreg}, {opt stepwise}, {opt xi} and possibly
other prefix commands are allowed; see help {help prefix}. 

{p 4 4 2} {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are
allowed; see help {help weights}.

{title:Syntax for predict}

{p 8 16 2}
{cmd:predict}
{dtype}
{it:{help newvar:newvars}}
{ifin}
[{cmd:,} {it:statistic}
{opt o:utcome(outcome)} ]

{p 8 16 2}
{cmd:predict}
{dtype}
{c -(}{it:stub*}{c |}{it:newvar_reg}
{it:newvar_k1}
... {it:newvar_kk-1}{c )-}
{ifin}
{cmd:,}
{opt sc:ores}

{pstd}
where k is the number of outcomes in the model.

{synoptset 11 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt p:r}}predicted probabilities; the default{p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt s:igma}}the standard deviation{p_end}
{synopt :{opt stdp}}standard error of the linear prediction{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Note that with the {opt pr} option, you specify  one or k new variables
depending on whether the {opt outcome()} option is also specified (where
k is the number of categories of {depvar}).  With {opt xb} and {opt stdp},
one new variable is specified.{p_end}

{p 4 4 2}
These statistics are available both in and out of sample; type
"{cmd:predict} {it:...} {cmd:if e(sample)} {it:...}" if wanted only for the
estimation sample.


{title:Description}

{p 4 4 2}{cmd:oglm} estimates Ordinal Generalized Linear Models. When
these models include equations for heteroskedasticity they are also
known as heterogeneous choice/ location-scale / heteroskedastic
ordinal regression models.  {cmd:oglm} supports multiple link functions,
including logit (the default), probit, complementary log-log, log-log
and cauchit.

{p 4 4 2}When an ordinal regression model incorrectly assumes that error
variances are the same for all cases, the standard errors are wrong
and (unlike OLS regression) the parameter estimates are biased.
Heterogeneous choice/ location-scale models explicitly specify the
determinants of heteroskedasticity in an attempt to correct for it.
Further, these models can be used when the variance/variability of
underlying attitudes is itself of substantive interest.  Alvarez and
Brehm (1995), for example, argued that individuals whose core values
are in conflict will have a harder time making a decision about
abortion and will hence have greater variability/error variances in
their responses.

{p 4 4 2}Several special cases of ordinal generalized linear models can also be
estimated by {cmd:oglm}, including the parallel lines models of
{cmd:ologit} and {cmd:oprobit} (where error variances are assumed to
be homoskedastic), the heteroskedastic probit model of {cmd:hetprob}
(where the dependent variable must be a dichotomy and the only link
allowed is probit), the binomial generalized linear models of
{cmd:logit}, {cmd:probit} and {cmd:cloglog} (which also assume
homoskedasticity), as well as similar models that are not otherwise
estimated by Stata.  This makes {cmd:oglm} particularly useful for
testing whether constraints on a model (e.g. homoskedastic errors) are
justified, or for determining whether one link function is more
appropriate for the data than are others.

{p 4 4 2}Other features of {cmd:oglm} include support for linear constraints, making
it possible, for example, to impose and test the constraint that the
effects of x1 and x2 are equal.  {cmd:oglm} works with several prefix
commands, including {cmd:by}, {cmd:nestreg}, {cmd:xi}, {cmd:svy} and {cmd:sw}.  
Its {cmd:predict} command includes the ability to compute estimated
probabilities.  The actual values taken on by the dependent variable
are irrelevant except that larger values are assumed to correspond to
"higher" outcomes. Up to 20 outcomes are allowed. {cmd:oglm} was
inspired by the SPSS PLUM routine but differs somewhat in its
terminology, labeling of links, and the variables that are allowed
when modeling heteroskedasticity.


{title:Options}

{p 4 8 2} {opt link(logit/probit/cloglog/loglog/cauchit/log)} specifies
the link function to be used.  The legal values are {opt link(logit)},
{opt link(probit)}, {opt link(cloglog)}, {opt link(loglog)} and {opt link(cauchit)} which
can be abbreviated as {opt link(l)}, {opt link(p)}, {opt link(c)}, {opt link(ll)}  and
{opt link(ca)}. {opt link(logit)} is the default if the option is
omitted.

{p 8 8 2} NOTE: {opt link(log)} is also available but is considered
experimental (and possibly wrong) at this point. Stata’s {cmd:glm}
program successfully uses the log link with dichotomous dependent
variables but it is not clear how and how well it generalizes to the
ordinal case.

{p 8 8 2} The following advice is adapted from Norusis (2005, p. 84):
Probit and logit models are reasonable choices when the changes in the
cumulative probabilities are gradual. If there are abrupt changes,
other link functions should be used. The log-log link may be a good
model when the cumulative probabilities increase from 0 fairly slowly
and then rapidly approach 1. If the opposite is true, namely that the
cumulative probability for lower scores is high and the approach to 1
is slow, the complementary log-log link may describe the data.

{p 8 8 2} WARNING: Programs differ in the names used for some
links.  Stata's loglog link corresponds to SPSS PLUM's cloglog link;
and Stata's cloglog link is called nloglog in SPSS.

{p 4 8 2} {opt hetero(varlist)}, {opt scale(varlist)} and {opt eq2(varlist)}
are synonyms (use only one of them) and can be used to specify the
variables believed to affect heteroskedasticity in heterogeneous
choice/ location-scale models.  In such models the model chi-square
statistic is a test of whether the choice/location parameters and the
heteroskedasticity/scale parameters differ from zero; this differs
from {cmd:hetprob}, where the model chi-square only tests the
choice/location parameters. The more neutral-sounding {opt eq2(varlist)}
alternative is provided because it may be less confusing when using
the {opt flip} option.

{p 8 8 2} WARNING: The default Wald tests conducted by the {opt nestreg}
and {opt sw} prefix commands can give incorrect results when the
same variable appears in both the location and scale equations.  In
such cases it is recommended that you use {opt nestreg}'s and {opt sw}'s
likelihood ratio test options.  

{p 4 8 2} {opt flip} causes the command-line placement of the location
and scale variables to be reversed, i.e. what would normally be the
location variables will instead be the scale variables, and vice-
versa.  This is primarily useful if you want to use the {opt sw} or
{opt nestreg} prefix commands to do stepwise selection or hierarchical
entry of the heteroskedasticity/scale variables. (Just be sure to keep
straight which set of variables is which!) Again, if you do this,
remember to use the likelihood ratio test options of {opt nestreg} or
{opt sw}, because the default Wald tests may be wrong otherwise.

{p 4 8 2} {opt hc} and {opt ls} affect how the equations are labeled.
If {opt hc} is used, then, consistent with the literature on
heterogeneous choice, the equations are labeled "choice" and
"variance". If {opt ls} is used, the equations are labeled "location"
and "scale", which is consistent with SPSS PLUM and other published
literature.  If neither option is specified, then the
scale/heteroskedasticity equation is labeled "lnsigma", which is
consistent with other Stata programs such as {cmd:hetprob}.

{p 4 8 2} {opt force} can be used to force {cmd:oglm} to issue
only warning messages in some situations when it would normally give a
fatal error.  By default, the dependent variable can have a maximum of
20 categories.  A variable with more categories than that is probably
a mistaken entry by the user, e.g. a continuous variable has been
specified rather than an ordinal one.  But, if your dependent variable
really is ordinal with more than 20 categories, {opt force} will let
{cmd:oglm} analyze it (although other practical limitations, such as
small sample sizes within categories, may keep it from coming up with
a final solution.) Obviously, you should only use {opt force} when
you are confident that you are not making a mistake. {opt trustme}
can be used as a synonym for {opt force}.

{p 4 8 2} {cmd:lrforce} forces Stata to report a Likelihood Ratio
Statistic under certain conditions when it ordinarily would not.  Some
types of constraints can make a Likelihood Ratio chi-square test
invalid. Hence, to be safe, Stata reports a Wald statistic whenever
constraints are used. But, for many common sorts of constraints
(e.g. constraining the effects of two variables to be equal) an LR chi-
square statistic is probably appropriate. Note that the {cmd:lrforce} option
will be ignored when robust standard errors are specified either
directly or indirectly, e.g. via use of the {cmd:robust} or {cmd:svy}
options. Use this option with caution.

{p 4 8 2} {cmd:store(}{it:name}{cmd:)} causes the command
{cmd:estimates store {it:name}} to be executed when {cmd:oglm}
finishes.  This is useful for when you wish to estimate a series of
models and want to save the results. 

{p 8 8 2} WARNING: The {opt store} option may not work correctly when
the {opt svy} prefix is used.

{p 4 8 2} {cmd:log} displays the iteration log. By default it is
suppressed.

{p 4 8 2} {cmd:coeflegend} specifies that the legend of the coefficients
and how to specify them in an expression be displayed rather than
displaying the statistics for the coefficients.

{p 4 8 2} {it:display_options} control how results are displayed. These
are generic options in Stata and not all have been tested with oglm.
In some cases the option may already be specified and cannot be
overridden. See {help estimation options##display_options}. A few other
options, along with abbreviations for commands, are listed at 
{help _get_diopts}.

{p 4 8 2} {opt or} reports the estimated coefficients transformed to
odds ratios, that is, exp(b) rather than b.  Standard errors and
confidence intervals are similarly transformed.  This option affects how
results are displayed, not how they are estimated.  {opt or} may be
specified at estimation or when replaying previously estimated results.
Options {cmd:rrr}, {cmd:eform}, {cmd:irr} and {cmd:hr} produce identical
results (labeled differently) and can also be used. It is up to the user
to decide whether the exp(b) transformation makes sense given the link
function used, e.g. it probably doesn't make sense when using the probit
link.

{p 4 8 2} {cmd:constraints(}{it:clist}{cmd:)} specifies the linear
constraints to be applied during estimation.  The default is to
perform unconstrained estimation.  Constraints are defined with the 
{help constraint} command. {cmd:constraints(1)} specifies that the
model is to be constrained according to constraint 1;
{cmd:constraints(1-4)} specifies constraints 1 through 4;
{cmd:constraints(1-4,8)} specifies 1 through 4 and 8.  

{p 4 8 2} {cmd:robust} specifies that the Huber/White/sandwich
estimator of variance is to be used in place of the traditional
calculation.  {cmd:robust} combined with {cmd:cluster()} allows
observations which are not independent within cluster (although they
must be independent between clusters).  If you specify {cmd:pweight}s,
{cmd:robust} is implied.

{p 4 8 2} {cmd:cluster(}{it:varname}{cmd:)} specifies that the
observations are independent across groups (clusters) but not
necessarily within groups. {it:varname} specifies to which group each
observation belongs; e.g., {cmd:cluster(personid)} in data with repeated
observations on individuals. {cmd:cluster()} affects the estimated
standard errors and variance-covariance matrix of the estimators (VCE),
but not the estimated coefficients. {cmd:cluster()} can be used with
{cmd:pweight}s to produce estimates for unstratified cluster-sampled
data.

{p 4 8 2} {cmd:level(}{it:#}{cmd:)} specifies the confidence level in
percent for the confidence intervals of the coefficients; see help 
{help level}.

{p 4 8 2} {cmd:startvals(}{it:matname}{cmd:)} specifies that the matrix
{it:matname} (a row vector) contains starting values. Column names
must correspond to parameters estimated in the model. Named parameters
will be assigned the corresponding starting value. Any parameters in
the model not included in the matrix {it: matname} will have default
starting values of 0. Extra paramaters named in the matrix
{it:matname} but not included in the model will be ignored. This is
equivalent to passing a matrix to {help ml init} with the {opt skip}
option but not the {opt copy} option specified. If {opt startvals()}
is not supplied, {cmd:oglm} uses the estimated thresholds from a
constant-only model as starting values for the thresholds, with 0s for
all other parameters.

{p 8 8 2} WARNING: The {opt startvals()} option should only be used if
you are confident you do not want to use the default starting values.
Specifying some starting values without including starting values for
the thresholds will probably result in worse performance than
specifying no starting values at all.

{p 4 8 2} {it:maximize_options} control the maximization process; see
help {help maximize}.  You should never have to specify most of these.
However, the {opt difficult} option can sometimes be useful with models
that are running very slowly or not converging at all.


{title:Options for predict}

{phang}
{opt pr}, the default, calculates the predicted probabilities.
If you do not also specify the {opt outcome()} option, you must specify
either one or else k new variables, where k is the number of categories of the
dependent variable.  Say that you fitted a model by typing
{cmd:oglm result x1 x2}, and {opt result} takes on three values.
Then you could type {cmd:predict p1 p2 p3} to obtain all three predicted
probabilities.  If you specify the {opt outcome()} option, you must specify
one new variable.  Say that {opt result} takes on the values 1, 2, and 3.
Typing {cmd:predict p1, outcome(1)} would produce the same {opt p1}
If you do not specify outcome(), pr (with one new variable specified) 
assumes outcome(#1).

{phang}
{opt xb} calculates the linear prediction.  You specify one new
variable, for example, {cmd:predict linear, xb}.  The linear prediction is
defined, ignoring the contribution of the estimated cutpoints.

{phang}
{opt sigma} calculates the standard deviation, also known as the
scale.  You specify one new variable, for example, {cmd:predict sigma, s}. 
If the model does not include an equation for heteroskedasticity
then the predicted sigma value is missing for all cases.

{phang}
{opt stdp} calculates the standard error of the linear prediction.  You
specify one new variable, for example, {cmd:predict se, stdp}.

{phang}
{opt outcome(outcome)} specifies for which outcome the predicted probabilities
are to be calculated.  {opt outcome()} should contain either a single value of
the dependent variable or one of {opt #1}, {opt #2}, {it:...}, with {opt #1}
meaning the first category of the dependent variable, {opt #2} the second
category, etc.

{phang}
{opt scores} calculates equation-level score variables.  

{title:Examples}

{p 4 4 2} {it}Example 1. Basic models. {sf} By default, {cmd:oglm} will estimate the same
models as {cmd:ologit}.  The {opt store} option is convenient for saving results if you
want to contrast different models.

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. oglm  warm i.yr89 i.male i.white age ed prst}{p_end}
{p 8 12 2}{cmd:. oglm  warm i.yr89 i.male i.white age ed prst, store(m1)}{p_end}
{p 8 12 2}{cmd:. oglm  warm i.yr89 i.male i.white age ed prst, robust}{p_end}

{p 4 4 2} {it}Example 2. Survey data estimation.{sf}  

{p 8 12 2}{cmd:. webuse nhanes2f, clear}{p_end}
{p 8 12 2}{cmd:. svy: oglm health i.female i.black age c.age#c.age}{p_end}
{p 8 12 2}{cmd:. svy, subpop(female): oglm health i.black age c.age#c.age}{p_end}

{p 4 4 2} {it}Example 3.  The {cmd:predict} command. {sf} 

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. quietly oglm  warm i.yr89 i.male i.white age ed prst}{p_end}
{p 8 12 2}{cmd:. predict p1 p2 p3 p4}{p_end}

{p 4 4 2} {it}Example 4.  Constrained logistic regression. {sf}
{cmd:logit}, {cmd:ologit}, {cmd:probit} and {cmd:oprobit} provide
other and generally faster means for estimating non-heteroskedastic
models with logit and probit links; but none of these commands
currently supports the use of linear constraints, such as two
variables having equal effects.  {cmd:oglm} can be used for this
purpose.  For example,

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. recode warm (1 2  = 0)(3 4 = 1), gen(agree)}{p_end}
{p 8 12 2}{cmd:. * Constrain the effects of male and white to be equal}{p_end}
{p 8 12 2}{cmd:. constraint 1 1.male = 1.white}{p_end}
{p 8 12 2}{cmd:. oglm agree i.yr89 i.male i.white age ed prst, lrf store(constrained) c(1)}{p_end}
{p 8 12 2}{cmd:. oglm agree i.yr89 i.male i.white age ed prst, store(unconstrained) }{p_end}
{p 8 12 2}{cmd:. lrtest constrained unconstrained}{p_end}


{p 4 4 2} {it}Example 5.  Other link functions. {sf} By default,
{cmd:oglm} uses the logit link. If you prefer, however, you can
specify probit, complementary log log, log log or log links.  In the following example, the
same model is estimated using each of the links supported by oglm (note that {opt link(log)}
is considered experimental and possibly wrong.}

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, link(l)}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, link(p)}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, link(c)}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, link(ll)}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, link(ca)}{p_end}


{p 4 4 2} {it}Example 6.  Prefix commands. {sf} {cmd:oglm} supports many of
Stata's prefix commands. But remember that many prefix commands do not support
factor variables. For example,

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. sw, pe(.05): oglm warm yr89 male}{p_end}
{p 8 12 2}{cmd:. nestreg: oglm warm (yr89 male  white age) (ed prst)}{p_end}

{p 4 4 2} {it}Example 7.  heteroskedasticity/scale/eq2 option. {sf}
The {opt het}, {opt scale} and {opt eq2} options are synonyms, use
whichever one you prefer.  {opt ls} and {opt hc} are optional and
affect whether the equations are labeled consistently with the
heterogeneous choice or location-scale literature. If also using the
{opt sw} or {opt nestreg} prefix commands, you should use their
likelihood ratio test options since the default Wald tests can be
wrong when the same variable appears in both the location and scale
equations. Note that it is possible to estimate a heteroskedasticity-only
model, and that the variables in the two equations do not need to
be the same.

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male i.white age ed prst, het(i.yr89) hc}{p_end}
{p 8 12 2}{cmd:. oglm warm i.yr89 i.male white age ed prst, scale(i.male i.white) ls link(p)}{p_end}
{p 8 12 2}{cmd:. oglm warm, eq2(i.male)}{p_end}
{p 8 12 2}{cmd:. sw, pe(.05) lr: oglm warm yr89 male white age ed prst, het(yr89 male white) }{p_end}
{p 8 12 2}{cmd:. nestreg, lr: oglm warm yr89 male white age ed prst, het(yr89 male white)}{p_end}


{p 4 4 2} {it}Example 8.  The flip option. {sf} In the last two
examples, we did stepwise selection and hierarchical entry of the
choice/location variables.  Suppose we wanted to do stepwise selection or
hierarchical entry of the heteroskedasticity/scale variables instead?
We can use the {opt flip} option, which causes the command-line
placement of the location and scale variables to be reversed.  Just make
sure you specify each variable list correctly - while the {opt hetero}, 
{opt scale} and {opt eq2} options are all synonyms, you may find it
less confusing if you use {opt eq2} with {opt flip}.  Also remember to use
the likelihood ratio test options with {opt nestreg} or {opt sw}. In
the following examples, because of the {opt flip} option, the choice
variables are yr89, male, white, age, ed, and prst, while the hetero variables
are yr89, male, and white.

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. sw, pe(.05) lr: oglm warm yr89 male white, eq2(yr89 male white age ed prst) flip}{p_end}
{p 8 12 2}{cmd:. nestreg, lr: oglm warm yr89 male white, eq2(yr89 male white age ed prst) flip}{p_end}

{p 4 4 2} {it}Example 9.  Factor variables and the margins command. {sf} {cmd:oglm} works with
factor variables and the {cmd:margins} command. Like {cmd:ologit}, {cmd:oglm} is a multiple 
outcome command, so you have to tell {cmd:margins} which outcome you want the predictive margins
or marginal effects for. Also, keep in mind that not all prefix commands work when factor
variables are used.

{p 8 12 2}{cmd:. use http://www.indiana.edu/~jslsoc/stata/spex_data/ordwarm2.dta, clear}{p_end}
{p 8 12 2}{cmd:. recode warm (1 2  = 0)(3 4 = 1), gen(agree)}{p_end}
{p 8 12 2}{cmd:. oglm agree i.yr89 i.male i.white age ed prst}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(1))}{p_end}
{p 8 12 2}{cmd:. margins, dydx(*) predict(outcome(1))}{p_end}
{p 8 12 2}{cmd:. oglm  warm i.yr89 i.male i.white age ed prst}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(1))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(2))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(3))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(4))}{p_end}
{p 8 12 2}{cmd:. margins, dydx(*) predict(outcome(1))}{p_end}
{p 8 12 2}{cmd:. margins, dydx(*) predict(outcome(2))}{p_end}
{p 8 12 2}{cmd:. margins, dydx(*) predict(outcome(3))}{p_end}
{p 8 12 2}{cmd:. margins, dydx(*) predict(outcome(4))}{p_end}

{title:Author}

{p 5 5}
Richard Williams{break}
Notre Dame Department of Sociology{break}
Richard.A.Williams.5@ND.Edu{break}
{browse "http://www.nd.edu/~rwilliam/oglm/"}{p_end}


{title:Acknowledgements}

{p 5 5}The documentation and source code for several Stata commands
(e.g. {opt ologit_p}) were major aids in developing the {cmd:oglm}
documentation and in adding support for the {cmd:predict} command.
Much of the code is adapted from {it}Maximum Likelihood Estimation
with Stata, Third Edition{sf}, by William Gould, Jeffrey Pitblado and
William Sribney.  SPSS's PLUM routine helped to inspire {opt oglm} and
provided a means for double-checking the accuracy of the program.

{p 5 5} Joseph Hilbe, Mike Lacy, Rory Wolfe, and Sean Reardon provided
stimulating and helpful comments. Jeff Pitblado helped me with several
programming issues. Kerry Kammire played a major role in updating oglm
to work with factor variables and the margins command. Ben Shear from
Stanford provided the code and help file documentation for the
{it:startvals} option.

{title:References}

{p 5 5}Alvarez, R. Michael and John Brehm. 1995.  "American
Ambivalence towards Abortion Policy: Development of a Heteroskedastic
Probit Model of Competing Values." American Journal of Political
Science 39(4):1055-82.

{p 5 5}Hardin, James and Joseph Hilbe.  2001. "Generalized Linear
Models and Extensions." College Station, TX: Stata Press.

{p 5 5}Long, J. Scott and Jeremy Freese.  2014.  "Regression Models
for Categorical Dependent Variables Using Stata, 3rd Edition." College
Station, Texas: Stata Press.

{p 5 5}Norusis, Marija.  2005.  "SPSS 13.0 Advanced Statistical
Procedures Companion."  Upper Saddle River, New Jersey: Prentice Hall. See
especially the chapter on SPSS PLUM, available on the web at{break}
{browse "http://www.norusis.com/pdf/ASPC_v13.pdf"}{p_end}

{title:Suggested citations if using {cmd:oglm} in published work }

{p 5 5}{cmd:oglm} is not an official Stata command. It is a free
contribution to the research community, like a paper. Please cite it
as such.

{p 5 5}Williams, Richard.  2009. "Using Heterogeneous Choice Models To 
Compare Logit and Probit Coefficients Across Groups" 
Sociological Methods & Research 37(4): 531-559. A pre-publication version
is available at {break} 
{browse "http://www.nd.edu/~rwilliam/oglm/RW_Hetero_Choice.pdf"}.

{p 5 5}Williams, Richard.  2010. "Fitting Heterogeneous Choice 
Models with oglm."  The Stata Journal 10(4):540-567.  
The published article can be found at {break}
{browse "http://www.stata-journal.com/article.html?article=st0208"}

{p 5 5}Williams, Richard.  2006.  "Generalized Ordered Logit/ Partial
Proportional Odds Models for Ordinal Dependent Variables." The Stata 
Journal 6(1):58-82.  A pre-publication version that includes information on
updates to the program since the article was published is available at {break}
{browse "http://www.nd.edu/~rwilliam/gologit2/gologit2.pdf"}. 
{break}The published article can be found at {break}
{browse "http://www.stata-journal.com/article.html?article=st0097"}

{p 5 5} {cmd:gologit2} is a related program and may be more appropriate
than {cmd:oglm} for some purposes.  The two programs can also be used
together if you wish to contrast heterogeneous choice / location-scale models
with gologit models.

{p 5 5}I would appreciate an email notification if you use  oglm in published 
work, as well as a citation of one or more of the sources listed above.  Also 
feel free to email me if you have comments about the program or its documentation.


{title:Also see}

{p 4 13 2} Online: {help estcom}, {help postest}, 
{help constraint}, {help ologit}, {help oprobit}, {help hetprob},
{help svy}, {help margins}, {help fvvarlist}, {help prefix},
{help gologit2} (if installed).
