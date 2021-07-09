{smcl}
{* 15mar2009}{...}
{cmd:help for stsurvimpute}{right:Patrick Royston}
{hline}


{title:Impute censored survival times}
 

{title:Syntax}

{phang2}
{cmd:stsurvimpute}
[{it:varlist}]
{ifin}
[{cmd:,} {it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt df(#)}}baseline degrees of freedom for {help stpm2} (Royston-Parmar models){p_end}
{synopt :{cmdab:gen:erate(}{it:newvar} [{opt ,replace}]{cmd:)}}creates new variable containing observed and imputed survival times{p_end}
{synopt :{opt ll:ogistic}}imputes using log-logistic distribution{p_end}
{synopt :{opt ln:ormal}}imputes using lognormal distribution{p_end}
{synopt :{opt sc:ale(scalename)}}specifies the scale on which the Royston-Parmar model is
 to be fitted{p_end}
{synopt :{opt see:d(#)}}sets random number seed{p_end}
{synopt :{opt tru:ncate(#)}}truncate survival distribution at {it:#}{p_end}
{synopt :{opt uni:form(varname)}}uses {it:varname} to supply uniformly distributed random numbers{p_end}
{synopt :{opt wei:bull}}imputes using Weibull distribution{p_end}
{synopt :{it:stpm2_options}}additional options for {help stpm2}{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
Weights are not allowed. Note that {cmd:stsurvimpute} requires {cmd:stpm2}
to be installed - it can be downloaded from the SSC archive (see help on {help ssc}).


{title:Description}

{pstd}
{cmd:stsurvimpute} singly imputes censored observation-times using a parametric
survival model. Available basic parametric models are Weibull, log-logistic
and lognormal; also supported are Royston-Parmar flexible
parametric models, implemented by {help stpm2}. Variables in 
{it:varlist} constitute a prognostic model that is used for predicting
individual imputed survival times. Such a model should make
the imputations more accurate than using only the overall distribution.


{title:Options}

{phang}
{opt df(#)} specifies the degrees of freedom for Royston-Parmar models.
When {it:#} > 1 Royston-Parmar models are used to impute censored
survival times, and the baseline distribution function is approximated
by a restricted cubic spline with {it:#} degrees of freedom.
If {it:#} = 1 then a Weibull, log-logistic or lognormal distribution
is assumed. Further options controlling Royston-Parmar
models are available (see {help stpm2}). 

{phang}
{cmd:generate(}{it:newvar} [{cmd:, replace}]{cmd:)} creates a new variable
{it:newvar} containing observed
and imputed survival times. {opt replace} allows {it:newvar} to be replaced
with new data. {cmd:replace} may not be abbreviated.

{phang}
{opt llogistic} imputes assuming a log-logistic distribution.
{opt llogistic} is equivalent to {cmd:df(1) scale(odds)}.

{phang}
{opt lnormal} imputes assuming a lognormal distribution. {opt lnormal}
is equivalent to {cmd:df(1) scale(normal)}.

{phang}
{opt scale(scalename)} specifies on which scale the survival model is to be
fitted. {it:scalename} can be {opt hazard}, {opt odds} or {opt normal}.

{phang}
{opt seed(#)} sets the random number seed before random uniform values
are generated.

{phang}
{opt truncate(#)} truncates the survival distribution at {it:#}. The default
{it:#} is 1, meaning that the entire survival distribution is used for imputation.
With, for example, {cmd:truncate(0.8)} the longest (but less probable)
survival times, for which the survival probability is in the range 0.2 to 0.0,
are not imputed. Only the range 0.2 to 1 of the survival distribution is
used for imputation. The result is shorter and perhaps more realistic extreme
imputed survival times.

{phang}
{opt uniform(varname)} uses {it:varname} to supply
uniformly distributed random numbers. By default
the numbers are created internally. If the {opt unif()} option is used, the
{opt seed()} option is ignored.

{phang}
{opt weibull} imputes assuming a Weibull distribution. 
{opt weibull} is equivalent to {cmd:df(1) scale(hazard)}.

{phang}
{it:stpm2_options} are options for {help stpm2}.


{title:Remarks}

{pstd}
Royston, Parmar & Altman (2008) present an example of imputing right-censored
survival times in kidney cancer. The aim is to be able to use familiar and
informative graphs such as scatter plots and dotplots to illustrate the 
relationship between the outcome and treatments, covariates, prognostic
scores etc in an informative manner. Note that because the imputation
of censored observations is heavily model-dependent, one cannot validly do 
linear regression or the like of the complete and  imputed times on
covariates.

{pstd}
Royston et al (2008) use the lognormal distribution in their analysis,
and that is the default provided by {cmd:stsurvimpute}. However,
{cmd:stsurvimpute} provides many other distributional models which
may fit the data better than the lognormal, and so give more
appropriate imputations. Choosing between the various models
can be done using the Akaike Information Criterion, as discussed
by Royston & Parmar (2002) - see also Royston (2001) and
help on {help stpm2}.

{pstd}
An important point to remember when inspecting imputed survival
times is that their distribution is based on {hi:extrapolation}
of the modelled survival distribution into the future, on the
assumption that all individuals will eventually experience the
event of interest. In many cases the assumption is false - there
is a 'cured fraction' who will never experience the event.
The consequence is that in many instances unrealistic survival
times will be imputed, particularly when a large proportion of
the times are censored. The higher the censoring proportion, the
less information is present on the right-hand tail of the survival
distribution and the more 'wild' the imputed times are likely
to be.


{title:Examples}

{phang}
{cmd:. stsurvimpute x1 x2 x3, gen(t_imputed) weibull}

{phang}
{cmd:. stsurvimpute age sex stage, gen(t_imputed) llogistic}

{phang}
{cmd:. stsurvimpute, scale(normal) df(3) gen(t_imputed) truncate(0.8) seed(101)}


{title:Author}

{pstd}
Patrick Royston, MRC Clinical Trials Unit, London.{break}
pr@ctu.mrc.ac.uk


{title:References}

{phang}
P. C. Lambert and P. Royston. 2009. Further development of flexible parametric
models for survival analysis. Stata Journal, in press.

{phang}
P. Royston. 2001. Flexible alternatives to the Cox model, and more.
{it:Stata Journal} {hi:1}: 1-28.

{phang}
P. Royston and M. K. B. Parmar. 2002. Flexible proportional-hazards and
proportional-odds models for censored survival data, with application
to prognostic modelling and estimation of treatment effects.
{it:Statistics in Medicine} {hi:21}: 2175-2197.

{phang}
P. Royston, M. K. B. Parmar and D. G. Altman. 2008.
Visualizing length of survival in time-to-event studies: 
a complement to Kaplan–Meier plots.
{it:Journal of the National Cancer Institute} {hi:100}: 1-6.


{title:Also see}

{psee}
On-line:  help for {help stpm2}.
