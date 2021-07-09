{smcl}
{* *! version 2  09May2018}{...}
{vieweralsosee "[XT] xtreg" "help xtreg"}{...}
{vieweralsosee "[ME] mixed" "help mixed"}{...}
{vieweralsosee "runmlwin" "help runmlwin"}{...}
{vieweralsosee "gllamm" "help gllamm"}{...}
{viewerjumpto "Syntax" "runmixregls##syntax"}{...}
{viewerjumpto "Description" "runmixregls##description"}{...}
{viewerjumpto "Options" "runmixregls##options"}{...}
{viewerjumpto "Remarks" "runmixregls##remarks"}{...}
{viewerjumpto "Examples" "runmixregls##examples"}{...}
{viewerjumpto "Saved results" "runmixregls##saved_results"}{...}
{viewerjumpto "References" "runmixregls##references"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{cmd:runmixregls} {hline 2}}Run the MIXREGLS mixed-effects location scale software from within Stata{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:runmixregls} {depvar} [{varlist}] {ifin} [{cmd:,} {it:options}]

{p 4 4 2}
where {varlist} specifies variables in the mean function.

{synoptset 33 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt nocons:tant}}suppress constant term in the mean function{p_end}
{synopt:{opt b:etween}{cmd:(}{varlist}[{cmd:,} {cmdab:nocons:tant}]{cmd:)}}specify variables in between-group variance function{p_end}
{synopt:{opt w:ithin}{cmd:(}{varlist}[{cmd:,} {cmdab:nocons:tant}]{cmd:)}}specify variables in within-group variance function{p_end}
{synopt:{cmdab: a:ssociation(}{it:{help runmixregls##atype:atype}}{cmd:)}}specify the group-level association between the (log of the) within-group variance and the random-location effects;
default is {cmd:association(linear)}{p_end}

{syntab:Random effects/Residuals}
{synopt:{opt reffects}{cmd:(}{newvar:1}{cmd: }{newvar:2}{cmd:)}}retrieve standardized random-location and random-scale effects{p_end}
{synopt:{opth residuals(newvar)}}retrieve standardized residual errors{p_end}

{syntab:Integration}
{synopt:{opt noadapt}}do not perform adaptive Gaussian quadrature {p_end}
{synopt:{opt intp:oints(#)}}set the number of integration (quadrature) points; default is {cmd:intpoints(11)}{p_end}

{syntab:Maximization}
{synopt:{opt iterate(#)}}maximum number of iterations; default is {cmd:iterate(200)}{p_end}
{synopt:{opt tol:erance(#)}}tolerance; default is {cmd:tolerance(0.0005)}{p_end}
{synopt:{opt stand:ardize}}standardize all covariates{p_end}
{synopt:{opt ridge:in(#)}}initial value for ridge; default is {cmd:ridgein(0)}{p_end}


{syntab:Reporting}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{it:{help runmixregls##display_options:display_options}}}control column formats, row spacing, line width,
and display of omitted variables and base and empty cells{p_end}
{synopt:{opt nohe:ader}}suppress table header{p_end}
{synopt:{opt notab:le}}suppress coefficient table{p_end}
{synopt:{opt coefl:egend}}display legend instead of statistics{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 33}{...}
{marker atype}{...}
{synopthdr :atype}
{synoptline}
{synopt :{opt n:one}}none{p_end}
{synopt :{opt l:inear}}linear; the default{p_end}
{synopt :{opt q:uadratic}}quadratic{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
A panel variable must be specified. Use {helpb xtset}. {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:runmixregls} runs the
{browse "http://publichealth.uic.edu/epidemiology-and-biostatistics/projects":MIXREGLS}
mixed-effects location scale software
({help runmixregls##HN2013:Hedeker and Nordgren 2013}) from within Stata.

{pstd}
The mixed-effects location scale model extends the standard two-level
random-intercept mixed-effects model for continuous responses ({cmd:xtreg, mle}) in three ways.

{p 8 12 2}
(1) The (log of the) within- and between-group variances are further modeled as functions of the covariates.

{p 8 12 2}
(2) A new random effect, referred to as the random-scale effect, 
is then entered into the within-group variance function to account for any unexplained group differences in the residual variance.
The existing random-intercept effect is now referred to as the random-location effect. 

{p 8 12 2}
(3) A group-level association between the location and the scale may be allowed for by entering the 
random-location effect into the within-group variance function using either a linear or quadratic functional form.
The regression coefficients of these linear and quadratic terms are then estimated.

{pstd}
The distributions of the random-location and random-scale effects are assumed to be Gaussian.  


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}. 

{phang}
{opt between}{cmd:(}{varlist}[{cmd:,} {cmdab:nocons:tant}]{cmd:)} 
specifies the variables in the between-group variance function.

{phang}
{opt within}{cmd:(}{varlist}[{cmd:,} {cmdab:nocons:tant}]{cmd:)}
specifies the variables in the within-group variance function.

{phang}
{opt association(atype)}, where {it:atype} is

{phang3}
{cmd:none}{c |}{cmd:linear}{c |}{cmd:quadratic}

{pmore}
specifies the group-level association between the (log of the) within-group variance and the random-location effects.
The default is {cmd:association(linear)}.


{dlgtab:Random effects/Residuals}

{phang}
{opt reffects}{cmd:(}{newvar:1}{cmd: }{newvar:2}{cmd:)}
retrieves the best linear unbiased predictions (BLUPs) of the standardized random effects from MIXREGLS.
BLUPs are also known as empirical Bayes estimates.
The standardized random-location effects are placed in {newvar:1}
while the standardized random-scale effects are placed in {newvar:2}
The associated standard errors are placed in {newvar:1}_se and {newvar:2}_se.

{phang}
{opth residuals(newvar)} retrieves the standardized residual errors from MIXREGLS.


{dlgtab:Integration}

{phang}
{opt noadapt} prevents MIXREGLS from using adaptive Gaussian quadrature.
MIXREGLS will use ordinary Gaussian quadrature instead.

{phang}
{opt intpoints(#)} sets the number of integration points for (adaptive) Gaussian quadrature.
The default is {cmd:intpoints(11)}.
The more points, the more accurate the approximation to the log likelihood.
However, computation time increases with the number of quadrature points.
When models do not converge properly, increasing the number of quadrature points can sometimes lead to convergence.

{dlgtab:Maximization}

{phang}
{opt iterate(#)} specifies the maximum number of iterations.  
The default is {cmd:iterate(200)}.
You should seldom have to use this option.

{phang}
{opt tolerance(#)} specifies the convergence tolerance.
The default is {cmd:tolerance(0.0005)}.
You should seldom have to use this option.

{phang}
{opt standardize} standardizes all covariates in all functions during optimization.
This ensures all covariates are on the same numerical scale with mean 0 and variance 1.
This can be helpful if the model "blows up" or does not converge to the solution.

{phang}
{opt ridgein(#)} specifies the initial value for the ridge parameter.
The default is {cmd:ridgein(200)}.
This is a numeric value that adds to the diagonal of the second derivative matrix, which can aid in convergence of the solution; usually set to 0 or some small fractional value.


{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels},
{opth cformat(%fmt)},
{opt pformat(%fmt)},
{opt sformat(%fmt)}, and
{opt nolstretch};
    see {helpb estimation options##display_options:[R] estimation options}.

{phang}
{opt noheader} suppresses the display of the summary statistics at the top of 
the output; only the coefficient table is displayed.

{phang}
{opt notable} suppresses display of the coefficient table.

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.


{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

            {help runmixregls##remarks_model:Remarks on the mixed-effects location scale model}
            {help runmixregls##remarks_first_time:Remarks on getting runmixregls working for the first time}
            {help runmixregls##remarks_mixregls_estimation:Remarks on MIXREGLS estimation}
            {help runmixregls##remarks_runmixregls_output:Remarks on runmixregls output}


{marker remarks_model}{...}
{title:Remarks on the mixed-effects location scale model}

{pstd}
The mixed-effects location scale model fitted by MIXREGLS consists of three functions

{p 8 12 2}
(1) the mean function,

{p 8 12 2}
(2) the between-group variance function,

{p 8 12 2}
(3) the within-group variance function.

{pstd}
These three functions can be written as

{pmore}
y_ij = b_1*x1_ij + sigma_u_ij*theta1_j + e_ij,{space 3}i=1,...,n_j;{space 3}j=1,...,J,

{pmore}
log(sigma2_u_ij) = b_2*x2_ij,

{pmore}
log(sigma2_e_ij) = b_3*x3_ij + a_l*theta1_j + a_q*theta1_j^2 + sigma_v*theta2_j,

{pstd}
where

{pmore}
theta1_j ~ N(0,1),

{pmore}
theta2_j ~ N(0,1),

{pmore}
e_ij ~ N(0,sigma2_e_ij),

{pstd}
and

{pmore}
y_ij is the continuous response variable,

{pmore}
x1_ij, x2_ij and x3_ij are vectors of observation- and group-level covariates,

{pmore}
b_1, b_2 and b_3 are vectors of parameters to be estimated,

{pmore}
theta1_j are the unobserved standardized random-location effects,

{pmore}
theta2_j are the unobserved standardized random-scale effects,

{pmore}
a_l and a_q are scalar parameters to be estimated,

{pmore}
e_ij are the observation-specific errors.

{pstd}
See {help runmixregls##HN2013:Hedeker and Nordgren 2013} for further details on the mixed-effects location scale model.


{marker remarks_first_time}{...}
{title:Remarks on getting runmixregls working for the first time}

{pstd}
{cmd:runmixregls} can be installed from the Statistical Software Components (SSC) archive by typing the following
from a net-aware version of Stata

{p 8 12 2}
{cmd:. ssc install runmixregls}

{pstd}
If you have already installed {cmd:runmixregls} from the SSC, you can check that you are using the latest version
by typing the following command:

{phang2}{stata "adoupdate runmixregls":. adoupdate runmixregls}{p_end}


{marker remarks_mixregls_estimation}{...}
{title:Remarks on MIXREGLS estimation}

{pstd}
MIXREGLS uses maximum likelihood estimation, utilizing both the EM algorithm and a Newton-Raphson solution.
Because the log likelihood for this model has no closed form, it is approximated by adaptive Gaussian quadrature.
Estimation of the random effects is accomplished using empirical Bayes methods.
The full model is estimated in three sequential stages:

{p 8 18 2}
(1) Standard random-intercept model + between-group variance function regression coefficients

{p 8 18 2}
(2) Stage 1 model + within-group variance function regression coefficients

{p 8 18 2}
(3) Stage 2 model + group-level association between the (log of the) within-group variance
and the random-location effects + random-scale effects

{pstd}
Prior to Stage 1, 20 iterations are performed of the EM algorithm 
to estimate the parameters of a standard random-intercept model 
(regression coefficients, between-group variance, within-group variance, and random-location effects).
These estimates are then used as starting values for Stage 1
Estimates at each stage are used as starting values for the next stage, 
which improves the convergence of the final model.
This also provides a way of assessing the statistical significance of the additional parameters in each stage via likelihood-ratio tests.
The results of each stage as well as these likelihood-ratio tests are provided in the {help runmixregls##saved_results:saved results}.

{pstd}
See {help runmixregls##HN2013:Hedeker and Nordgren 2013} for further details on the MIXREGLS estimation.


{marker remarks_runmixregls_output}{...}
{title:Remarks on runmixregls output}

{pstd}
The {cmd:runmixregls} output displays five different sets of parameters

{p 8 12 2}
Mean:{space 8}
Mean function regression coefficients

{p 8 12 2}
Between:{space 5}
Between-group variance function regression coefficients (log scale)

{p 8 12 2}
Within:{space 6}
Within-group variance function regression coefficients (log scale)

{p 8 12 2}
Association:{space 1}
Group-level association parameters between the (log of the) within-group function and the random-location effects

{p 8 12 2}
Scale:{space 7}
Random-scale standard deviation


{marker examples}{...}
{title:Example: Replicate Hedeker and Nordgren 2013 (pages 10-18)}

{pstd}Load the data{p_end}
{phang2}{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmixregls/reisby, clear":. use http://www.bristol.ac.uk/cmm/media/runmixregls/reisby, clear}}

{pstd}Recode missing values in hamdep from -9 to Stata system missing{p_end}
{phang2}{bf:{stata "recode hamdep (-9 = .)":. recode hamdep (-9 = .)}}

{pstd}Declare panel variable to be id{p_end}
{phang2}{bf:{stata "xtset id":. xtset id}}

{pstd}Fit the mixed-effects location scale model{p_end}
{phang2}{bf:{stata "runmixregls hamdep week endog endweek, between(endog) within(week endog)":. runmixregls hamdep week endog endweek, between(endog) within(week endog)}}

{pstd}Refit the model, this time retrieving the BLUPs of the standardized random-location and random-scale effects, and their associated standard errors{p_end}
{phang2}{bf:{stata "runmixregls hamdep week endog endweek, between(endog) within(week endog) reffects(theta1 theta2)":. runmixregls hamdep week endog endweek, between(endog) within(week endog) reffects(theta1 theta2)}}

{pstd}Examine a scatter plot of the BLUPs of the standardized random-scale effects against
the standardized random-location effects{p_end}
{phang2}{bf:{stata "scatter theta2 theta1":. scatter theta2 theta1}}

{pstd}Refit the model removing the group-level linear association between the (log of the) within-group variance and the intercept{p_end}
{phang2}{bf:{stata "runmixregls hamdep week endog endweek, between(endog) within(week endog) association(none)":. runmixregls hamdep week endog endweek, between(endog) within(week endog) association(none)}}
 
{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:runmixregls} saves the following in e():

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Scalars}{p_end}

{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(g_min)}}smallest group size{p_end}
{synopt:{cmd:e(g_avg)}}average group size{p_end}
{synopt:{cmd:e(g_max)}}largest group size{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_1)}}number of parameters, stage 1 model{p_end}
{synopt:{cmd:e(k_2)}}number of parameters, stage 2 model{p_end}
{synopt:{cmd:e(k_3)}}number of parameters, stage 3 model{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(ll_1)}}log likelihood, stage 1 model{p_end}
{synopt:{cmd:e(ll_2)}}log likelihood, stage 2 model{p_end}
{synopt:{cmd:e(ll_3)}}log likelihood, stage 3 model{p_end}
{synopt:{cmd:e(deviance_1)}}deviance, stage 1 model{p_end}
{synopt:{cmd:e(deviance_2)}}deviance, stage 2 model{p_end}
{synopt:{cmd:e(deviance_3)}}deviance, stage 3 model{p_end}
{synopt:{cmd:e(iterations)}}number of iterations{p_end}
{synopt:{cmd:e(iterations_1)}}number of iterations, stage 1 model{p_end}
{synopt:{cmd:e(iterations_2)}}number of iterations, stage 2 model{p_end}
{synopt:{cmd:e(iterations_3)}}number of iterations, stage 3 model{p_end}
{synopt:{cmd:e(time)}}estimation time (seconds){p_end}
{synopt:{cmd:e(chi2_1vs2)}}chi-squared, stage 1 model vs. stage 2 model{p_end}
{synopt:{cmd:e(chi2_1vs3)}}chi-squared, stage 1 model vs. stage 3 model{p_end}
{synopt:{cmd:e(chi2_2vs3)}}chi-squared, stage 2 model vs. stage 3 model{p_end}
{synopt:{cmd:e(p_1vs2)}}p-value, stage 1 model vs. stage 2 model{p_end}
{synopt:{cmd:e(p_1vs3)}}p-value, stage 1 model vs. stage 3 model{p_end}
{synopt:{cmd:e(p_2vs3)}}p-value, stage 2 model vs. stage 3 model{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}runmixregls{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(adapt)}}adaptive Gaussian quadrature {p_end}
{synopt:{cmd:e(n_quad)}}number of integration points{p_end}
{synopt:{cmd:e(iterate)}}maximum number of iterations{p_end}
{synopt:{cmd:e(tolerance)}}tolerance{p_end}
{synopt:{cmd:e(ridgein)}}initial ridge{p_end}
{synopt:{cmd:e(standardize)}}standardized variables{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(b_1)}}coefficient vector, stage 1 model{p_end}
{synopt:{cmd:e(b_2)}}coefficient vector, stage 2 model{p_end}
{synopt:{cmd:e(b_3)}}coefficient vector, stage 3 model{p_end}
{synopt:{cmd:e(V_1)}}variance-covariance matrix of the estimators, stage 1 model{p_end}
{synopt:{cmd:e(V_2)}}variance-covariance matrix of the estimators, stage 2 model{p_end}
{synopt:{cmd:e(V_3)}}variance-covariance matrix of the estimators, stage 3 model{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{marker citation}{...}
{title:Citation of {cmd:runmixregls} and MIXREGLS}

{pstd}{cmd:runmixregls} is not an official Stata command.
It is a free contribution to the research community, like a paper.
Please cite it as such:

{p 8 12 2}
Leckie, G. 2014. 
{cmd:runmixregls} - A Program to Run the MIXREGLS Mixed-effects Location Scale Software from within Stata.
{it:Journal of Statistical Software}, 59 (Code Snippet 2), 1-41.
URL: {browse "http://www.jstatsoft.org/v59/c02":http://www.jstatsoft.org/v59/c02}.

{pstd}Similarly, please also cite the MIXREGLS software:

{p 8 12 2}
Hedeker, D. R. and Nordgren. 2013. 
MIXREGLS: A Program for Mixed-effects Location Scale Analysis.
{it:Journal of Statistical Software}, 52, 12, 1-38.
URL: {browse "http://www.jstatsoft.org/v52/i12":http://www.jstatsoft.org/v52/i12}.

{marker authors}{...}
{title:Authors}

{p 4}George Leckie{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}
{p 4}{browse "mailto:g.leckie@bristol.ac.uk":g.leckie@bristol.ac.uk}{p_end}
{p 4}{browse "http://www.bristol.ac.uk/cmm/team/leckie.html":http://www.bristol.ac.uk/cmm/team/leckie.html}{p_end}

{p 4}Chris Charlton{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}The development of this command was funded under the LEMMA3 project, a node of the
UK Economic and Social Research Council's National Centre for Research Methods (grant number RES-576-25-0035).


{marker disclaimer}{...}
{title:Disclaimer}

{pstd}{cmd:runmixregls} comes with no warranty.


{marker references}{...}
{title:References}

{marker HN2013}{...}
{phang}
Hedeker, D. R. and Nordgren. 2013. 
MIXREGLS: A Program for Mixed-effects Location Scale Analysis.
{it:Journal of Statistical Software}, 52, 12, 1-38.
URL: {browse "http://www.jstatsoft.org/v52/i12":http://www.jstatsoft.org/v52/i12}.

{title:Also see}

{psee}
Manual:  {bf:[XT] xtreg} {bf:[ME] mixed} 

{psee}
Online:  {manhelp xtreg XT}, {manhelp mixed ME}, {bf:{help runmlwin}}, {bf:{help gllamm}}
{p_end}
