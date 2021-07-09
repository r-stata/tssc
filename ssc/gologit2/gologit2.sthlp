{smcl}
{* Last revised May 17, 2019}{...}
{hline}
help for {hi:gologit2} version 3.2.5
{hline}

{title:Generalized Ordered Logit Models for Ordinal Dependent Variables}

{p 4 8 2}
	{cmdab:gologit2} {it:depvar} [{it:indepvars}]
	[{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
	[{cmd:,} 
	{cmdab:p:l} 
	{cmdab:p:l(}{it:varlist}{cmd:)} 
	{cmdab:np:l}
	{cmdab:np:l(}{it:varlist}{cmd:)}
	{cmdab:auto:fit}
	{cmdab:auto:fit(}{it:alpha}{cmd:)}
	{cmd:link(}{it:logit/probit/cloglog/loglog/cauchit}{cmd:)}
	{cmdab:force}
	{cmdab:lrf:orce} {cmdab:waldf:orce}
	{cmdab:g:amma}
	{cmdab:g:amma(}{it:name}{cmd:)}
	{cmdab:nol:abel}
	{cmdab:mls:tart}
	{cmdab:sto:re(}{it:name}{cmd:)} 
	{cmdab:c:onstraints:(}{it:clist}{cmd:)} 
	{cmdab:vce}{it:(vcetype)}
	{cmdab:r:obust}
	{cmdab:cl:uster:(}{it:varname}{cmd:)}
	{cmdab:l:evel:(}{it:#}{cmd:)} 
	{cmdab:coefl:egend}
	{cmdab:nocnsr:eport}
	{cmdab:or} {cmdab:log}
	{it:display_options}
	{it:maximize_options} ]

{p 4 4 2} NOTE!!! {cmd:gologit2} now supports factor variables as well as the 
{opt svy}: and user-written {opt gsvy}: prefixes.

{p 4 4 2}
{cmd:gologit2} shares the features of all estimation commands; see help
{help est}.    
{cmd:gologit2} typed without arguments redisplays previous results.  
The following options may be given when redisplaying results:

{p 8 8 2}
	{cmdab:g:amma}
	{cmdab:g:amma(}{it:name}{cmd:)}
	{cmdab:sto:re(}{it:name}{cmd:)} 
	{cmd:or}
	{cmdab:l:evel:(}{it:#}{cmd:)}
	{cmdab:coefl:egend}

{p 4 4 2} {cmd:gologit2} works under Stata 11.2 or higher.  Download and
install {cmd:gologit29} if you have an older version of Stata. 

{p 4 4 2} {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are
allowed; see help {help weights}.

{p 4 4 2}
The syntax of {help predict} following {cmd:gologit2} is

{p 8 16 2}{cmd:predict} [{it:type}] {it:newvarname}({it:s})
        [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
	[{cmd:,} {it:statistic} {cmdab:o:utcome:(}{it:outcome}{cmd:)} ]

{p 4 4 2}
where {it:statistic} is

{p 8 21 2}{cmd:p}{space 8}probability (specify one new variable and
		{cmd:outcome()} option, or specify k new variables, k = # of
		outcomes); the default{p_end}
{p 8 21 2}{cmd:xb}{space 7}linear prediction ({cmd:outcome()} option
		required){p_end}
{p 8 21 2}{cmd:stdp}{space 5}S.E. of linear prediction ({cmd:outcome()} option
		required){p_end}
{p 8 21 2}{cmd:stddp}{space 4}S.E. of difference in linear predictions
		({cmd:outcome()} option is
		{cmd:outcome(}{it:outcome1}{cmd:,}{it:outcome2}{cmd:)}){p_end}

{p 4 4 2}
Note that you specify one new variable with {cmd:xb}, {cmd:stdp}, and
{cmd:stddp} and specify either one or k new variables with {cmd:p}.

{p 4 4 2}
These statistics are available both in and out of sample; type
"{cmd:predict} {it:...} {cmd:if e(sample)} {it:...}" if wanted only for the
estimation sample.


{title:Description}

{p 4 4 2} {cmd:gologit2} is a user-written program that estimates
generalized ordered logit models for ordinal dependent variables. The
actual values taken on by the dependent variable are irrelevant except
that larger values are assumed to correspond to "higher" outcomes. Up to
20 outcomes are allowed. {cmd:gologit2} is inspired by Vincent Fu's
{cmd:gologit} program and is backward compatible with it (and with
gologit29) but offers several additional powerful options, including
support for factor variables and complex survey data estimation.

{p 4 4 2} A major strength of {cmd:gologit2} is that it can also
estimate three special cases of the generalized model: the {it}
proportional odds/parallel lines model{sf}, the {it}partial proportional
odds model{sf}, and the {it}logistic regression model{sf}. Hence,
{cmd:gologit2} can estimate models that are less restrictive than the
proportional odds /parallel lines models estimated by {cmd:ologit}
(whose assumptions are often violated) but more parsimonious and
interpretable than those estimated by a non-ordinal method, such as
multinomial logistic regression (i.e. {cmd:mlogit}). The {cmd:autofit}
option greatly simplifies the process of identifying partial
proportional odds models that fit the data.

{p 4 4 2}  An alternative but equivalent parameterization of the model
that has appeared in the literature is reported when the {cmd:gamma}
option is selected.  Other key advantages of {cmd:gologit2} include
support for linear constraints (making it possible to use
{cmd:gologit2} for constrained logistic regression), survey data
estimation, and the computation of estimated probabilities via the
{cmd:predict} command.

{p 4 4 2} Despite the program's name, probit, complementary log-log,
log-log and cauchit links can be used instead of logit by specifying the
{cmd:link} option, e.g. {opt link(l)} for logit (the default), 
{opt link(p)} for probit, {opt link(c)} for complementary log-log, 
{opt link(ll)} for log-log, and {opt link(ca)} for  cauchit.

{p 4 4 2} {cmd:gologit2} works under Stata 11.2 and higher. Users of
older versions of Stata should download and install {cmd:gologit29}. 

{p 4 4 2} {cmd:gologit2} now has two major enhancements over earlier
versions of the program: support for factor variables, and support for
the {opt svy} prefix. This also means that {cmd:margins} and related
commands should work correctly with {cmd:gologit2}. HOWEVER, when
working with svyset data and the {opt autofit} option, it is required
that you use the {opt gsvy} prefix rather than the {opt svy} prefix.
{opt gsvy} has the same syntax as {help svy} but provides customized
support for {cmd:gologit2}'s unique options.  See the section below
about other cautions when using Stata prefix commands.{p_end}

{p 4 4 2} More information on the statistical theory behind
{cmd:gologit2} as well as several worked examples and a troubleshooting
FAQ can be found at {browse "https://www3.nd.edu/~rwilliam/gologit2/"}.

{title:Options}

{p 4 8 2} {cmd:pl}, {cmd:npl}, {cmd:npl()}, {cmd:pl()}, {cmd:autofit}
and {cmd:autofit()} provide alternative means for imposing or relaxing
the proportional odds/ parallel lines assumption. Only one may be
specified at a time.

{p 8 12 2} {cmd:autofit(}{it:alpha}{cmd:)} uses an iterative process to
identify the partial proportional odds model that best fits the data.
{it:alpha} is the desired significance level for the tests; {it:alpha}
must be greater than 0 and less than 1.  If {cmd:autofit} is specified
without parameters, the default alpha-value is .05. Note that, the
higher {it:alpha} is (e.g., .10), the easier it is to reject the
parallel lines assumption, and the less parsimonious the model will tend
to be. Especially when several variables are being tested or the sample
is large, a more stringent alpha-value (e.g. .01) may be called for.
This option can take a while because several models may need to
be estimated. The use of {cmd:autofit} is recommended but the other
options provide more control over the final model. Be careful of using
autofit with prefix commands that can change the sample being estimated
(e.g. {cmd:bootstrap}, {cmd:mi estimate}) as they may result in
different autofitted models for different sample selections.

{p 8 12 2} {cmd:pl} specified without parameters constrains all
independent variables to meet the proportional odds/ parallel lines
assumption.  It will produce results that are equivalent to
{cmd:ologit}.

{p 8 12 2} {cmd:npl} specified without parameters relaxes the
proportional odds/ parallel lines assumption for all explanatory
variables.  This is the default option and presents results equivalent
to the original {cmd:gologit.}

{p 8 12 2} {cmd:pl(}{it:varlist}{cmd:)} constrains the specified
explanatory variables to meet the proportional odds/ parallel lines
assumption. All other variable effects do not need to meet the
assumption.  The variables specified must be a subset of the explanatory
variables.

{p 8 12 2} {cmd:npl(}{it:varlist}{cmd:)} frees the specified explanatory
variables from meeting the proportional odds/ parallel lines assumption.
All other explanatory variables are constrained to meet the assumption.
The variables specified must be a subset of the explanatory variables.

{p 4 8 2} {cmd:link(}{it:logit/probit/cloglog/loglog/cauchit}{cmd:)}
specifies the link function to be used.  The legal values are 
{opt link(logit)}, {opt link(probit)}, {opt link(cloglog)}, 
{opt link(loglog)}, and {opt link(cauchit)}, which can be abbreviated as 
{opt link(l)}, {opt link(p)}, {opt link(c)}, {opt link(ll)} and 
{opt link(ca)}. {opt link(logit)} is the default if the option is omitted.

{p 8 8 2} The following advice is adapted from Norusis (2005, p. 84):
Probit and logit models are reasonable choices when the changes in the
cumulative probabilities are gradual. If there are abrupt changes, other
link functions should be used. The log-log link may be a good model when
the cumulative probabilities increase from 0 fairly slowly and then
rapidly approach 1. If the opposite is true, namely that the cumulative
probability for lower scores is high and the approach to 1 is slow, the
complementary log-log link may describe the data. The cauchit
distribution has tails that are bigger than the normal distribution’s,
hence the cauchit link may be useful when you have more extreme values
in either direction.

{p 8 8 2} NOTE: Programs differ in the names used for these latter two
links.  Stata's loglog link corresponds to SPSS PLUM's cloglog link; and
Stata's cloglog link is called nloglog in SPSS.

{p 4 8 2} {opt force} can be used to force {cmd:gologit2} to issue only
warning messages in some situations when it would normally give a fatal
error:

{p 8 8 2} By default, the dependent variable can have a maximum of 20
categories.  A variable with more categories than that is probably a
mistaken entry by the user, e.g. a continuous variable has been
specified rather than an ordinal one.  But, if your dependent variable
really is ordinal with more than 20 categories, {opt force} will let
{cmd:gologit2} analyze it (although other practical limitations, such
as small sample sizes within categories, may keep it from coming up with
a final solution.)

{p 8 8 2} Also, variables specified in {opt npl(varlist)} and 
{opt pl(varlist)} are required to be a subset of the explanatory variables.
However, prefix commands like {opt sw} and {opt nestreg} estimate models
that may use only a subset of the X variables, and those subsets may not
include all the variable specified in the npl/pl varlists.  Using 
{opt force} will allow model estimation to continue in those cases.

{p 8 8 2} Obviously, you should only use {opt force} when you are
confident that you are not making a mistake.

{p 4 8 2} {cmd:lrforce} forces Stata to report a Likelihood Ratio
Statistic under certain conditions when it ordinarily would not. Note
that the {cmd:lrforce} option will be ignored when robust standard
errors are specified either directly or indirectly, e.g. via use of the
{cmd:robust} or {cmd:svy}: options. THIS OPTION IS NOW THE DEFAULT. and
is included for compatibility with earlier versions of gologit2. Use
{cmd:waldforce} to override.

{p 4 8 2} {cmd:waldforce} forces Stata to report a Wald Statistic even
when a Likelihood Ratio statistic is possible. Some types of constraints
can make a Likelihood Ratio chi-square test invalid. But, Likelihood
Ratio statistics should be correct for the types of constraints imposed
by the {cmd:pl} and {cmd:npl} commands.  Use {cmd:waldforce} if you are
imposing additional constraints of your own and are not sure a
Likelihood Ratio test is appropriate.

{p 4 8 2} {cmd:store(}{it:name}{cmd:)} causes the command 
{cmd:estimates store {it:name}} to be executed when {cmd:gologit2} finishes.  
This is useful for when you wish to estimate a series of models and want to save
the results. This option can also be specified when replaying the results.

{p 4 8 2} {cmd:gamma} displays an alternative but equivalent
parameterization of the partial proportional odds model used by Peterson
and Harrell (1990) and Lall et al (2002). Under this parameterization,
there is one Beta coefficient and M-2 Gamma coefficients for each
explanatory variable, where M = the number of categories for Y. The
gammas indicate the extent to which the proportional odds assumption is
violated by the variable, i.e. when the gammas do not significantly
differ from 0 the proportional odds assumption is met. Advantages of
this parameterization include the fact that it is more parsimonious than
the default layout.  In addition, by examining the test statistics for
the Gammas, you can get a feel for which variables meet the
proportionality assumption and which do not.

{p 4 8 2} {opt gamma(name)} causes the gamma estimates to be stored as
{it:name}, e.g. {opt g(gamma1)} would store the gamma estimates under
the name {it:gamma1}.  This makes the gamma results easily usable with
post- estimation table formatting commands like {cmd:outreg2} and
{cmd:estout}.  Do NOT try to make the gamma results active and then use
other post-estimation commands, e.g. {cmd:predict} or {cmd:test}. Such
commands either will not work or, if they do work, may give incorrect
results.  Note that only the variances and standard errors of the gamma
estimates are correct; all the covariances of the estimates are set
equal to zero.

{p 4 8 2} {cmd:nolabel} causes the equations to be named eq1, eq2, etc.
The default is to use the first 32 characters of the value labels and/or
the values of Y as the equation labels.  Note that some characters
cannot be used in equation names, e.g. the space ( ), the period (.),
the dollar sign ($), and the colon(:), and will be replaced with the
underscore (_) character.  Square brackets ([]) and parentheses will be
replaced with curly brackets ({}). The default behavior works well when
the value labels are short and descriptive.  It may not work well when
value labels are very long and/or include characters that have to be
changed. If the printout looks unattractive and/or you are getting
strange errors, try changing the value labels of Y or else use the
{cmd:nolabel} option.

{p 4 8 2} {cmd:mlstart} uses an alternative method for computing start
values. This method is slower but sometimes surer. This option shouldn't
be necessary but it can be used if the program is having trouble for
unclear reasons or if you want to confirm that the program is working
correctly.

{p 4 8 2} {cmd:log} displays the iteration log. By default it is
suppressed.

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
constraints to be applied during estimation.  The default is to perform
unconstrained estimation.  Constraints are defined with the 
{help constraint} command. {cmd:constraints(1)} specifies that the model is to
be constrained according to constraint 1; {cmd:constraints(1-4)}
specifies constraints 1 through 4; {cmd:constraints(1-4,8)} specifies 1
through 4 and 8.  Keep in mind that the {cmd:pl}, {cmd:npl}, and
{cmd:autofit} options work by generating across-equation constraints,
which may affect how any additional constraints should be specified.

{p 4 8 2} {cmd:vce(}{it:vcetype}{cmd:)} specifies the type of standard
error reported, which includes types that are derived from asymptotic
theory (oim), that are robust to some kinds of misspecification
(robust), that allow for intragroup correlation (cluster clustvar).
vce(bootstrap) and vce(jackknife) are not supported but you can use the
prefix commands for them. The older options {cmd:robust} and
{cmd:cluster(}{it:varname}{cmd:)} are also supported.

{p 4 8 2} {cmd:robust} specifies that the Huber/White/sandwich estimator
of variance is to be used in place of the traditional calculation.
{cmd:robust} combined with {cmd:cluster()} allows observations which are
not independent within cluster (although they must be independent
between clusters).  If you specify {cmd:pweight}s, {cmd:robust} is
implied.

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
percent for the confidence intervals of the coefficients; 
see help {help level}.

{p 4 8 2} {cmd:coeflegend} specifies that the legend of the coefficients
and how to specify them in an expression be displayed rather than
displaying the statistics for the coefficients.

{p 4 8 2} {opt nocnsreport} causes constraints not to be displayed.

{p 4 8 2} {it:display_options} control how results are displayed. These
are generic options in Stata and not all have been tested with gologit2.
In some cases the option may already be specified and cannot be
overridden. See {help estimation options##display_options}. A few other
options, along with abbreviations for commands, are listed at 
{help _get_diopts}.

{p 4 8 2} {it:maximize_options} control the maximization process; see
help {help maximize}.  You should never have to specify most of these.
However, the {opt difficult} option can sometimes be useful with models
that are running very slowly or not converging at all.

{title:Options for Survey Data Estimation}

{p 4 8 2} Stata's {cmd:svy} prefix command is now supported. See help
{help svy}. The old {cmd:svy} option is no longer allowed. However,
rather than use the {opt svy}: prefix, it is recommended that you use
the {opt gsvy}: prefix, and you are required to do so when
using {opt autofit}.  The {opt gsvy} prefix has the same syntax as
{help svy} but provides customized support for some of the non-standard
features of gologit2, such as the {cmd:autofit} and {cmd:gamma} options.
{opt gsvy} and {opt gologit2_svy} are synonyms for each other and
either can be used.

{p 4 8 2} NOTE: If you want to use the {cmd:svy} subpop option, 
if you don't already have one it is best to compute
a 0/1 selection variable beforehand (e.g. mysample) and 
then say something like
{cmd:gsvy, subpop(mysample)}. More complicated subpop 
statements can sometimes cause
errors with gologit2.

{title:Options for predict}

{p 4 8 2} {cmd:p}, the default, calculates predicted probabilities.

{p 8 8 2} If you do not also specify the {cmd:outcome()} option, you
must specify k new variables.  For instance, say you fitted your model
by typing "{cmd:gologit2 insure age male}" and that {cmd:insure} takes
on three values.  Then you could type "{cmd:predict p1 p2 p3, p}" to
obtain all three predicted probabilities.

{p 8 8 2} If you also specify the {cmd:outcome()} option, then you
specify one new variable.  Say that {hi:insure} took on values 1, 2, and
3.  Then typing "{cmd:predict p1, p outcome(1)}" would produce the same
{hi:p1} as above, "{cmd:predict p2, p outcome(2)}" the same {hi:p2} as
above, etc. If {hi:insure} took on values 7, 22, and 93, you would
specify {cmd:outcome(7)}, {cmd:outcome(22)}, and {cmd:outcome(93)}.
Alternatively, you could specify the outcomes by referring to the
equation number ({cmd:outcome(#1)}, {cmd:outcome(#2)}, and
{cmd:outcome(#3)}, or, if the variable values are labeled, you can do
something like {cmd:outcome(low)}, {cmd:outcome(medium)}, and
{cmd:outcome(high)}.

{p 4 8 2} If you do not specify {cmd:outcome()}, {cmd:p} (with one new
variable specified), {cmd:xb}, and {cmd:stdp} assume {cmd:outcome(#1)}.
You must specify {cmd:outcome()} with the {cmd:stddp} option.
For {cmd:p}, {cmd:xb}, and {cmd:stdp} you can compute predictions for 
each of the M outcomes of Y.

{p 4 8 2} {cmd:xb} calculates the linear prediction.  You should also
specify the {cmd:outcome()} option. Default is {cmd:outcome(#1)}.

{p 4 8 2} {cmd:outcome()} specifies for which outcome the statistic is
to be calculated.  {cmd:equation()} is a synonym for {cmd:outcome()}: it
does not matter which you use.  {cmd:outcome()} and {cmd:equation()} can
be specified using (1) {cmd:#1}, {cmd:#2}, ..., with {cmd:#1} meaning
the first category of the dependent variable, {cmd:#2} the second
category, etc.; (2) values of the dependent variable; or (3) the value
labels (if any) of the dependent variable.

{p 4 8 2} {cmd:stdp} calculates the standard error of the linear
prediction. You should also specify the {cmd:outcome()} option. Default
is {cmd:outcome(#1)}.

{p 4 8 2} {cmd:stddp} calculates the standard error of the difference in
two linear predictions.  You must specify option {cmd:outcome()} and in
this case you specify the two particular outcomes of interest inside the
parentheses; for example, "{cmd:predict sed, stddp outcome(1,3)}".

{title:Some cautions about using {opt gologit2} (especially {opt autofit}) with Stata prefix commands}

{p 4 4 2} Be careful when using prefix commands with the {opt autofit} option. 
These commands often change the sample that is being used which could result
in differing models after {opt autofit}. If you have this mad desire to
use bootstrapping or jackknifing or multiple imputation, it may
be safer to specify the model without using {opt autofit}. The output from
{opt autofit} will contain information on alternative ways to specify the model
by using the {opt pl} option.

{p 4 4 2} Keep in mind that many prefix commands do not work when factor
variables are used. Also there are many possible esoteric combinations of
prefix commands and {opt gologit2} options and {opt gologit2} is not
guaranteed to be problem-free with all of them.


{title:Examples}

{p 4 4 2} {it}Example 1. Proportional Odds/ Parallel Lines Assumption
Violated.{sf} Long and Freese (2003) present data from the 1977/ 1989
General Social Survey.  Respondents are asked to evaluate the
following statement: "A working mother can establish just as warm and
secure a relationship with her child as a mother who does not work."
Responses were coded as 1 = Strongly Disagree (1SD), 2 = Disagree
(2D), 3 = Agree (3A), and 4 = Strongly Agree (4SA).  We can do a
global test of the proportional odds assumption by estimating a model
in which no variables are constrained to meet the assumption and
contrasting it with a model in which all are so constrained (the
latter is equivalent to the {cmd:ologit} model).

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/ordwarm2, clear}{p_end}
{p 8 12 2}{cmd:. gologit2 warm i.yr89 i.male i.white age ed prst, store(unconstrained)}{p_end}
{p 8 12 2}{cmd:. gologit2 warm i.yr89 i.male i.white age ed prst, pl store(constrained)}
{p_end}
{p 8 12 2}{cmd:. lrtest constrained unconstrained}{p_end}

{p 4 4 2}The LR chi-square from the above is 49.20.  These data fail the global test.

{p 4 4 2} However, we can now use the {cmd:autofit} option to see whether a
partial proportional odds model can fit the data.  In a partial proportional odds model,
some variables meet the proportional odds assumption while others do not.

{p 8 12 2}{cmd:. gologit2 warm i.yr89 i.male i.white age ed prst, autofit}{p_end}

{p 4 4 2} The results show that 4 of the 6 variables (white, age, ed,
prst) meet the parallel lines assumption.  Only yr89 and male do not.
This model is less restrictive than a model estimated by {cmd:ologit}
would be (whose assumptions are violated in this case) but much more
parsimonious than a non-ordinal alternative such as {cmd:mlogit}.

{p 4 4 2} {it}Example 2: Alternative parameterization using the {cmd:gamma}
option.{sf} Peterson & Harrell (1990) and Lall et al (2002) present an
alternative parameterization of the partial proportional odds model.  In
this parameterization, gamma coefficients represent deviations from
proportionality.  When the gammas of an explanatory variable do not
significantly differ from 0, the parallel lines assumption for that
variable is met. Using the {cmd:autofit} and {cmd:gamma} options, we can (a)
confirm that Lall came up with the correct partial proportional odds
model, and (b) replicate the results from his Table 5.

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/lall.dta, clear}{p_end}
{p 8 12 2}{cmd:. gologit2 hstatus i.heart  i.smoke, gamma autofit}{p_end}

{p 4 4 2} {it}Example 3: Complex survey data estimation.{sf} By using the
{cmd:svy} or {cmd:gsvy} prefixes, we can estimate models with complex
survey data that have been svyset. {cmd: gsvy} is required if 
{opt autofit} is used.

{p 8 12 2}{cmd:. webuse nhanes2f, clear}{p_end}
{p 8 12 2}{cmd:. gsvy: gologit2 health i.female i.black age c.age#c.age, autofit}{p_end}
{p 8 12 2}{cmd:. gsvy, subpop(female): gologit2 health i.black age c.age#c.age, autofit}{p_end}
{p 8 12 2}{cmd:. svy: gologit2 health i.female i.black age c.age#c.age, pl}{p_end}
{p 8 12 2}{cmd:. svy, subpop(female): gologit2 health i.black age c.age#c.age, pl}{p_end}


{p 4 4 2} {it}Example 4.  The {cmd:predict} command. {sf} 
In addition to the standard options ({cmd:xb, stdp, stddp}) the {cmd:predict}
command supports the {cmd:pr} option (abbreviated {cmd:p}) for predicted
probabilities; {cmd:pr} is the default option if nothing else is specified.
For example,

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/ordwarm2, clear}{p_end}
{p 8 12 2}{cmd:. quietly gologit2  warm i.yr89 i.male i.white age ed prst, pl(i.yr89 i.male)}{p_end}
{p 8 12 2}{cmd:. predict p1 p2 p3 p4}{p_end}
{p 8 12 2}{cmd:. list p1 p2 p3 p4 in 1/10}{p_end}

{p 4 4 2} {it}Example 5.  Constrained logistic regression. {sf} 
Here is an example of how you can impose your own linear constraints on variables.

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/ordwarm2, clear}{p_end}
{p 8 12 2}{cmd:. recode warm (1 2  = 0)(3 4 = 1), gen(agree)}{p_end}
{p 8 12 2}{cmd:. * Constrain the effects of male and white to be equal}{p_end}
{p 8 12 2}{cmd:. constraint 1 1.male = 1.white}{p_end}
{p 8 12 2}{cmd:. gologit2 agree yr89 i.male i.white age ed prst, store(constrained) c(1)}{p_end}

{p 4 4 2} {it}Example 6.  Other link functions. {sf} By default, and
as its name implies. {cmd:gologit2} uses the logit link. If you
prefer, however, you can specify probit, complementary log log, 
log log, or cauchit links.  For example, to estimate a goprobit model,

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/ordwarm2, clear}{p_end}
{p 8 12 2}{cmd:. gologit2 warm i.yr89 i.male i.white age ed prst, link(p)}{p_end}

{p 4 4 2} {it}Example 7.  The margins command. {sf}

{p 8 12 2}{cmd:. use https://www3.nd.edu/~rwilliam/statafiles/ordwarm2, clear}{p_end}
{p 8 12 2}{cmd:. gologit2 warm i.yr89 i.male i.white age ed prst, pl}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(1))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(2))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(3))}{p_end}
{p 8 12 2}{cmd:. margins yr89 male white, predict(outcome(4))}{p_end}

{p 4 4 2} {it}Example 8.  The spost13 commands. {sf} Long & Freese's spost13 commands
(download and install spost13_ado) make it much easier to work with ordinal
and multinomial models. Here is one simple example.

{p 8 12 2}{cmd:. webuse nhanes2f, clear}{p_end}
{p 8 12 2}{cmd:. gologit2 health i.female i.black c.age, auto(.01)}{p_end}
{p 8 12 2}{cmd:. quietly mtable, at (black = 0 age = 20 ) rown(20 year old white) dec(4)}{p_end}
{p 8 12 2}{cmd:. quietly mtable, at (black = 1 age = 20 ) rown(20 year old black) dec(4) below} {p_end}
{p 8 12 2}{cmd:. quietly mtable, at (black = 0 age = 47 ) rown(47 year old white) dec(4) below} {p_end}
{p 8 12 2}{cmd:. quietly mtable, at (black = 1 age = 47 ) rown(47 year old black) dec(4) below} {p_end}
{p 8 12 2}{cmd:. quietly mtable, at (black = 0 age = 74 ) rown(74 year old white) dec(4) below} {p_end}
{p 8 12 2}{cmd:. mtable, at (black = 1 age = 74 ) rown(74 year old black) dec(4) below} {p_end}

{title:Author}

{p 5 5}
Richard Williams{break}
Notre Dame Department of Sociology{break}
rwilliam@ND.Edu{break}
{browse "https://www3.nd.edu/~rwilliam/gologit2/"}{p_end}


{title:Acknowledgements}

{p 5 5} Vincent Kang Fu of the Utah Department of Sociology wrote
{cmd:gologit 1.0} and graciously allowed Richard Williams to incorporate
parts of its source code and documentation in {cmd:gologit2}.

{p 5 5}The documentation for Stata 8.2's {cmd:mlogit} command and the
program {cmd:mlogit_p} were major aids in developing the {cmd:gologit2}
documentation and in adding support for the {cmd:predict} command.  Much
of the code is adapted from {it}Maximum Likelihood Estimation with
Stata, Second Edition{sf}, by William Gould, Jeffrey Pitblado and
William Sribney.

{p 5 5} Sarah Mustillo, Dan Powers, J. Scott Long, Nick Cox, Kit Baum
and Joseph Hilbe provided stimulating and helpful comments. Kerry
Kammire helped with updating the program to work with factor variables
and the margins command. Jeff Pitblado played a critical role in
updating the program to use numerous Stata features, including the
gsvy: prefix.

{title:References}

{p 5 5}Fu, Vincent. 1998. "Estimating Generalized Ordered Logit
Models." Stata Technical Bulletin 8:160-164.

{p 5 5}Lall, R., S.J. Walters, K. Morgan, and MRC CFAS Co-operative
Institute of Public Health.  2002. "A Review of Ordinal Regression
Models Applied on Health-Related Quality of Life Assessments."
Statistical Methods in Medical Research 11:49-67.

{p 5 5}Long, J. Scott and Jeremy Freese.  2014.  "Regression Models
for Categorical Dependent Variables Using Stata, 3rd Edition." College
Station, Texas: Stata Press.

{p 5 5}Norusis, Marija.  2005.  "SPSS 13.0 Advanced Statistical
Procedures Companion."  Upper Saddle River, New Jersey: Prentice Hall.

{p 5 5}Peterson, Bercedis and Frank E. Harrell Jr.  1990.  "Partial
Proportional Odds Models for Ordinal Response Variables." Applied
Statistics 39(2):205-217.

{title:Suggested citations if using {cmd:gologit2} in published work }

{p 5 5}{cmd:gologit2} is not an official Stata command. It is a free
contribution to the research community, like a paper. Please cite it
as such. You can email Richard Williams if you do not otherwise have
access to these articles.

{p 5 5}Williams, Richard.  2006.  "Generalized Ordered Logit/ Partial
Proportional Odds Models for Ordinal Dependent Variables." The Stata 
Journal 6(1):58-82. The published article is available for free at 
{browse "http://www.stata-journal.com/article.html?article=st0097"}.

{p 5 5}Williams, Richard. 2016. 2016. "Understanding and interpreting
generalized ordered logit models." The Journal of Mathematical
Sociology, 40:1, 7-20, 
{browse "http://www.tandfonline.com/doi/full/10.1080/0022250X.2015.1112384"}.

{p 5 5}Updates to the program that have been made since the 2006 Stata
Journal article are summarized at
{browse "https://www3.nd.edu/~rwilliam/gologit2/gologit2.pdf"}. 



