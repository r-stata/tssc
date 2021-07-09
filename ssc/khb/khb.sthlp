{smcl}
{* September 7, 2015 @ 15:48:28}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "khbtab" "khbtab"}{...}

{title:Title}

{phang} {cmd:khb} Decomposition of effects in non-linear probabiltiy models using the KHB-method {p_end}

{title:Syntax}

{p 8 17 2}
   {cmd: khb}
   {it:model-type}
   {it:depvar} {it:key-vars} || {it:z-vars} 
   {ifin}
   {weight}
[ {cmd:, } {it: options} ]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt:{opt c:oncomitant(varlist)}}concomitants{p_end}
{synopt:{opt d:isentangle}}disentangle difference for each z-var{p_end}
{synopt:{opt s:ummary}}summary of decomposition{p_end}
{synopt:{opt or}}exponentiated coeficients{p_end}
{synopt:{opt vce(vcetype)}}vcetype may be {cmd:robust}, {cmd:cluster}
{it:clustvar}{p_end}
{synopt:{opt ape}}decomposition using average partial (marginal) effects{p_end}
{synopt:{opt continuous}}treat dummy variable as continuous when using ape-method{p_end}
{synopt:{opt not:able}}suppress coefficient table{p_end}
{synopt:{opt v:erbose}}show restricted and full model{p_end}
{synopt:{opt k:eep}}keep residuals of z-vars{p_end}
{synopt:{opt xs:tandard}}standardize {it:key-vars}{p_end}
{synopt:{opt zs:tandard}}standardize {it:z-vars}{p_end}
{syntab :Model-type specific}
{synopt:{opt out:come(outcome)}}outcome used for decomposition when {it: model-type} is {help mlogit}{p_end}
{synopt:{opt b:aseoutcome(#)}}value of depvar that will be the base outcome when {it:model-type} is {help mlogit}{p_end}
{synopt:{opt g:roup(varname)}}necessary options for {it:model-types} {help rologit} and {help clogit}; see help of these models.{p_end}
{synopt:{it:other}}all options allowed for the specified {it:model-type}{p_end}
{synoptline}
{p2colreset}{...}

{pstd} {it:model-type} can be any of {help regress}, {help logit},
{help ologit}, {help probit}, {help oprobit}, {help cloglog}, {help
slogit}, {help scobit}, {help rologit}, {help clogit}, {help xtlogit},
{help xtprobit} and {help mlogit}. Other models might also produce
output but for the time being this output is considered to be
"experimental".{p_end}

{pstd}{it:depvar} is the name of the dependent variable, {it:key-vars}
is a {help varlist} holding the name(s) of the variable(s) to be
decomposed, and {it:z-vars} is a varlist holding the name(s) of
control variables of interest.{p_end}

{pstd}{help fvvarlist:Factor variables} are allowed for {it:key-vars}.
Factor variables for {it:z-vars} are only allowed for Stata 12 or
higher. Factor variables for {it:key-vars} are not allowed, if option
-xstandard- is specified.{p_end}

{pstd}aweights, fweights, iweights, and pweights are allowed if they
    are allowed in the specified {it:model-type}; see {help weight}.  

{title:Description}

{pstd}{cmd:khb} applies the KHB method developed to compare the
estimated coefficients between two nested non-linear probability
models (Karlson/Holm/Breen 2011; Breen/Karlson/Holm 2010). An
important use of the technique is to decompose the total effect of a
variable into a {it:direct} and {it:indirect} of {it:spurious} part.
The method is developed for binary, logit and probit models, but this
command also includes other nonlinear probability models (ordered and
multinomial) and linear regression. Contrary to other decomposition
methods, the KHB-method gives unbiased decompositions, decomposes
effects of both discrete and continuous variables, and provides
analytically derived statistical tests for many models of the GLM
family.{p_end}

{pstd}In linear regression models, decomposing the total effect into
direct and indirect/spurious effects is straightforward. The
decomposition is done by comparing the estimated coefficient of a key
variable of interest ({it:key-var}) between a {it:reduced} model
without a control variable Z and a {it:full} model with one or more Z
variable added. The difference between the estimated coefficients of
the key-variable of interest in the two models expresses the amount by
which the effect of the key-variable is confounded by the
z-variable(s). If the control variable is hypothesized to be a
consequence of the key-variable, the difference will be commonly
termed as the "indirect effect"; if the control variable is the
hypothesized to be a cause of the key-variable, the difference is
termed the "spurious effect".

{pstd} The strategy described for linear models cannot be used in the
context of nonlinear probability models such as logit and probit,
because the estimated coefficients of these models are not comparable
between different models. The reason is a rescaling of the model
induced by a property of these models: the coefficients and the error
variance are not separately identified. The KHB-method solves this
problem. It allows the comparison of effects of nested models for many
models of the GLM framework, including logit, probit, ologit, oprobit,
and mlogit. The basic idea of the method is to compare the full model
with a reduced model that substitutes some Z-variables by the
residuals of the Z-variables from a regression of the Z-variables on
the {it:key-vars} (see Karlson/Holm/Breen 2011 for explanations and
details). The method consequently allows separation of the change in
the coefficient that is due to confounding and the change that is due
to rescaling.

{pstd}The KHB-method also allows the inclusion variables that control
for confounding influences on the decomposition. These variables are
named concomitants in Karlson/Holm (2011) and Breen/Karlson/Holm
(2010). These variables do not play the role of the Z-variables of the
y*-x-relationship, but rather as a set of variables that is included
to secure that both, the effects of the full model and the reduced
model are not confounded by these variables.

{pstd}The KHB-method is primarily intended to be used for various
variants of logit and probit models. However, it can be also used for
linear regression, in which case it returns the same results as the
standard technique. {cmd:khb} is then just a convenient way to do the
decomposition with one single command.

{pstd}Note that using {help regress} as {it:model-type} for binary
dependent variables boils down to using a linear probability model for
the decomposition. However, the interpretation of decompositions in
linear probability models is unknown, and may not reflect the parameters
of interest (in particular the indirect effect). Caution should
consequently be exercised, and the authors do not recommend using khb
for linear probability models until the properties of these models have
been explored formally.{p_end}

{pstd}A worked example using {cmd:khb} appears in Breen/Karlson/Holm
(2010).{p_end}

{title:Options}

{phang}{opt s:ummary} requests the provision of a decomposition
summary for all {it:key-vars}. By default, {cmd:khb} reports the
effects of all key variables along with standard errors in terms of
the estimated coefficients. With option summary, {cmd:khb} also
presents a table holding the "confounding ratios", the "percentage
reduction due to confounding" and the "rescale factor". The
confounding ratio measures the impact of confounding net of
rescaling. The percentage reduction measures the percentage change in
the coefficient of each {it:key-var} attributable to confounding net
of scaling. Finally, the rescale factor measures the impact of
rescaling, net of confounding.{p_end}

{phang}{opt d:isentangle} request a table that show how much of the
difference between the full and reduced model is contributed by each
of the single z-variables. {p_end}

{phang}{opt not:able} suppresses the display of the coefficient
table. This normally involves the options {opt summarize} and/or
{opt disentangle}{p_end}

{phang}{opt c:oncomitant(varlist)} is used to specify control
variables that are not z-variables. Factor variables are allowed.{p_end}

{phang}{opt vce(vcetype)} specifies the type of standard error
reported. It defaults to the Stata's defaults for the specified
model-type. Standard errors for indirect effects are estimated using a
method discussed by Sobel (1982). The option vce() set the standard
errors for total and direct effects and controls the type of standard
error that enter into Sobel's method. Types {cmd:robust},
{cmd:cluster}; see help {help vce_option}.{p_end}

{phang}{opt ape} is used to decompose the {it:key-vars} using average
   partial effects (average marginal effects). Uses {help margins} to
   compute average partial effects. For {it:model-types} {help ologit}
   and {help oprobit}, khb uses the average partial effect on the 
   probability for the first outcome unless {cmd:outcome()} is
   specified; see {help ologit_postestimation} for various ways to
   specify {cmd:outcome()}. Note that with APE the calculated
   indirect effect is not constant across outcomes. This is a
   well-known property of ordered choice models (see Greene/Henscher
   2010).{p_end}

{phang}{opt or} exponentiates the estimated coefficients, and hence
 shows odds-ratios for logit models. The coefficient for the reduced
 model is then the product of the full model with the estimated
 difference.  {p_end}

{phang}{opt v:erbose} is used to show the complete output of the full
   and restricted models that are used to estimate the
   decomposition. This is especially usefull to detect problems that
   occure in the intermediate steps of the estimation.{p_end}

{phang}{opt k:eep} is used to keep the residuals of the z-variables,
i.e. the z-variables net of confounding. These residuals are included as
independent variables in the reduced model. {p_end}

{phang}{opt continuous} Average partial effects are by default based
   on unit effects for dummy variables. Specifying continuous treats
   dummy variables equal to continuous variables. See {help margins}
   for details about this option{p_end}

{phang}{opt xs:tandard} is used to standardize the {it:key-vars}.{p_end}

{phang}{opt zs:tandard} is used to standardize the {it:z-vars}.{p_end}

{phang}{opt out:come(outcome)} specifies the outcome for which the
decompostion is to be calculated. This takes effect for models for
multinomial response (mlogit), and, if option {cmd:ape} is specified,
for ordered response models. {cmd:outcome()} can be specified using

{pin2}
{cmd:#1}, {cmd:#2}, ..., where {cmd:#1} means the first category of
the dependent variable, {cmd:#2} means the second category, etc.; 

{pin2}
the values of the dependent variable; or 

{pin2}
the value labels of the dependent variable if they exist.

{phang}{opt b:aseoutcome(#)} can be used for {it:model-type}
{cmd:mlogit}.  It specifies the value of depvar to be treated as the
base outcome. The default is to choose the most frequent outcome. The
option can be used together with {cmd:outcome()} to fully control the
contrast for which the decompositon is done.{p_end}


{title:Example(s)}

{pstd}{cmd: . use dlsy_khb.dta}{p_end}
{pstd}{cmd:. khb logit univ fses || abil }{p_end}
{pstd}{cmd:. khb probit univ fses || abil }{p_end}
{pstd}{cmd:. khb logit univ fses || abil, c(intact boy)} {p_end}
{pstd}{cmd:. khb logit univ fses || abil, summary}{p_end}

{title:References}

{pstd} Breen, R./Karlson, K.B./Holm, A. (Forthcoming).
Total, direct, and indirect effects in logit models.
Sociological Methods and Research, 42(2)164-191.
{p_end}

{pstd} Greene, W.H./Hensher, D.A. (2010): Modeling Ordered Choices: A
Primer. New York: Cambridge University Press.{p_end}

{pstd} Karlson, K.B./Holm, A./Breen, R. (2011): Comparing Regression
Coefficients Between Same-sample Nested Models using Logit and Probit. A New
Method. Sociological Methodology 42:286-313.{p_end}

{pstd} Karlson, K.B./Holm, A. (2011): Decomposing
primary and secondary effects: A new decomposition method. Research
in Stratification and Social Mobility 29:221-237.{p_end}

{pstd} Kohler, U./Karlson, K.B./Holm, A. (2011): Comparing
coefficients of nested nonlinear probability models. The Stata Journal
11:420-438.{p_end}


{title:Also see}

{psee}
Manual: {hi:[R] margins}
{p_end}

{psee}
Online: help for {help margins}, {help ldecomp} (if installed)
{p_end}

{psee}
Web:   {browse "http://stata.com":Stata's Home}
{p_end}

{title:Author}

{pstd}Ulrich Kohler (ukohler@uni-potsdam.de) and Kristian Karlson
(kbk@dpu.dk){p_end}

{pstd}Please send bug reports and questions regarding the program to
Ulrich Kohler. Questions regarding the KHB method itself are handled
by Kristian Karlson.{p_end}

