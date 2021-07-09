{smcl}
{* *! version 1.5.0, 24 April 2013}{...}
{cmd:help for paramed}{right:Hanhua Liu and Richard Emsley}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:paramed} {hline 2}}causal mediation analysis using parametric regression models{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:paramed} {varname}{cmd:,} avar({varname}) mvar({varname}) a0({it:real}) a1({it:real}) m({it:real}) 
yreg({it:string}) mreg({it:string}) [cvars({varlist}) {opt nointer:action} {opt case:control}
{opt full:output} c({it:numlist}) {opt boot:strap} reps({it:integer 1000}) level(cilevel) seed({it:passthru})]

{phang}{opt varname} - this specifies the outcome variable.

{phang}{opt avar(varname)} - this specifies the treatment (exposure) variable.

{phang}{opt mvar(varname)} - this specifies the mediator variable.

{phang}{opt a0(real)} - this specifies the natural level of the treatment (exposure).

{phang}{opt a1(real)} - this specifies the alternative treatment (exposure) level.

{phang}{opt m(real)} - this specifies the level of mediator at which the controlled direct effect 
is to be estimated.  If there is no treatment (exposure)-mediator interaction the controlled direct effect
is the same at all levels of the mediator and so an arbitary value can be chosen.

{phang}{opt yreg(string)} - this specifies the form of regression model to be fitted for the outcome 
variable. This can be either {it:linear}, {it:logistic}, {it:loglinear}, {it:Poisson} or {it:Negative binomial}.

{phang}{opt mreg(string)} - this specifies the form of regression model to be fitted for the mediator variable. 
This can be either {it:linear} or {it:logistic}.


{title:Description}

{pstd}{cmd:paramed} performs causal mediation analysis using parametric regression models.  Two models 
are estimated: a model for the mediator conditional on treatment (exposure) and covariates (if specified), and a model for the 
outcome conditional on treatment (exposure), the mediator and covariates (if specified).  It extends statistical 
mediation analysis (widely known as Baron and Kenny procedure) to 
allow for the presence of treatment (exposure)-mediator interactions in the outcome regression 
model using counterfactual definitions of direct and indirect effects.  

{pstd}{cmd:paramed} allows continuous, binary or count outcomes, and continuous or binary mediators, and requires the user
to specify an appropriate form for the regression models.

{pstd}{cmd:paramed} provides estimates of the controlled direct effect, the natural direct effect, 
the natural indirect effect and the total effect with standard errors and confidence intervals derived 
using the delta method by default, with a bootstrap option also available. See references for precise definitions of these effects. 


{title:Options}

{phang}{opt cvars(varlist)} - this option specifies the list of covariates to be included in the analysis. 
Categorical variables need to be coded as a series of dummy variables before being entered as covariates.

{phang}{opt nointer:action} - this option specifies whether a treatment (exposure)-mediator interaction is not to be
included in the models (the default assumes an interaction is present).

{phang}{opt full:output} - this option specifies the output mode, which can be either {it:reduced} 
or {it:full}. The reduced output is the default option (if this option is omitted). The results matrix 
contains the controlled direct effect, natural direct effect, natural indirect effect and total effect. 
When the {it:full} option is specified, both conditional effects and effects evaluated at the mean 
covariate levels are shown.

{phang}{opt c(numlist)} - this option is used when the output option is {it:full}. 
When the output mode is {it:full}, fixed values must be provided for the covariates at which conditional 
effects are computed (the number of values must correspond to the number of covariates).

{phang}{opt case:control} - this option is used for implementing mediation analysis when data arise from a 
case-control design, provided the outcome in the population is rare. If this option is omitted, the data 
will not be treated as from a case-control design.

{phang}{opt boot:strap} - this specifies whether a bootstrap procedure should be performed to compute bias-corrected 
bootstrap confidence intervals. The bootstrap procedure will not be performed if this option is omitted.

{phang}{opt reps(integer 1000)} - this specifies the number of replications for bootstrap. The default is 1000.

{phang}{opt level(cilevel)} - this specifies the confidence level for bootstrap. If this option is omitted, 
the current default level of 95% will be used.

{phang}{opt seed(passthru)} - this specifies the seed for bootstrap. If this option is omitted, a random 
seed will be used and the results cannot be replicated. {p_end}

{title:Assumptions}

{pstd}Let C be the measured covariates included in {opt cvars(varlist)}. To obtain valid estimates of the controlled direct effects requires two assumptions:

{phang}(1) There are no unmeasured treatment (exposure)-outcome confounders given C {p_end}
{phang}(2) There are no unmeasured mediator-outcome confounders given C {p_end}

{phang}To estimate natural direct and indirect effects we need the assumptions (1) and (2) and require need two additional assumptions:

{phang}(3) There are no unmeasured treatment (exposure)-mediator confounders given C {p_end}
{phang}(4) There is no effect of treatment (exposure) that confounds the mediator-outcome relationship {p_end}

{phang}Note that assumptions (1) and (3) are satisified by random allocation of the treatment variable. See references for further details. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use paramed_example.dta} {p_end}

{pstd}Continuous outcome, continuous mediator, a binary treatment coded 0 and 1, two covariates, 
no interaction between treatment and mediator, delta method standard errors {p_end}
{phang2}{cmd:. paramed y_cont, avar(treat) mvar(m_cont) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(linear)} nointer {p_end}

{pstd}Continuous outcome, binary mediator, a binary treatment coded 0 and 1, two covariates, 
include an interaction between treatment and mediator, bootstrap standard errors with default bootstrap settings{p_end}
{phang2}{cmd:. paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot} {p_end}

{pstd}Binary outcome, binary mediator, a binary treatment coded 0 and 1, no covariates, no interaction between treatment and mediator, 
bootstrap standard errors with 500 replications and fixing the seed to 1234{p_end}
{phang2}{cmd:. paramed y_bin, avar(treat) mvar(m_bin) a0(0) a1(1) m(1) yreg(logistic) mreg(logistic) nointer boot reps(500) seed(1234)} {p_end}

{pstd}Count outcome with a Poisson model, binary mediator, a binary treatment coded 0 and 1, two covariates, 
no interaction between treatment and mediator, bootstrap standard errors with 1000 replications and fixing the seed to 1234{p_end}
{phang2}{cmd:. paramed y_poisson, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(poisson) mreg(logistic) nointer boot seed(1234)} {p_end}

{pstd}Continuous outcome, binary mediator, a binary treatment coded 0 and 1, two covariates, interaction between treatment and mediator, and request full output. {p_end}
{phang2}{cmd:. paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) c(10 6) full} {p_end}

{title:Saved results}

{pstd}{cmd:paramed} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing direct, indirect and total effect estimates{p_end}
{synopt:{cmd:e(V)}}matrix containing variance of the effect estimates{p_end}


{title:Authors}

{pstd}Hanhua Liu, Richard Emsley and Graham Dunn{break}
Centre for Biostatistics{break}
Institute of Population Health{break}
The University of Manchester{p_end}

{pstd}Tyler VanderWeele and Linda Valeri{break}
Harvard School of Public Health{break}
Harvard University{p_end}

{phang}Email: richard.emsley@manchester.ac.uk or hanhua.liu@manchester.ac.uk


{title:Further reading}

Emsley RA, Liu H, Dunn G, Valeri L, VanderWeele TJ. (2013). paramed: causal mediation analysis using parametric models. In preparation.

Valeri L, VanderWeele TJ. (2013). Mediation Analysis Allowing for Exposure–Mediator Interactions and Causal Interpretation: 
Theoretical Assumptions and Implementation With SAS and SPSS Macros. Psychological Methods. Advance online
publication. doi: 10.1037/a0031034

VanderWeele TJ and Vansteelandt S. (2009). Conceptual issues concerning mediation, interventions and 
composition. {it:Statistics and Its Interface - Special Issue on Mental Health and Social Behavioral Science, 2:457-468.}


{title:Acknowledgments}

This work was supported by the UK Medical Research Council Methodology Research Programme (Grant number: G0900678)
and a UK Medical Research Council Career Development Award in Biostatistics (Grant number: G0802418).

The command is based on the MEDIATION macros in SAS and SPSS by Linda Valeri and Tyler VanderWeele.

We are grateful to Tom Palmer and Ian White for the suggestions they have made to improve this command.


{title:Also see}

{psee}
Help: {manhelp regress R}, {manhelp logit R}, {manhelp glm R}
{p_end}
