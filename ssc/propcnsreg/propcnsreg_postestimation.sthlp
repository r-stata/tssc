{smcl}
{* 07Feb2013}{...}
{* 14Sep2012}{...}
{hline}
help for {cmd:propcnsreg postestimation}
{hline}


{title:Description}

{p 4 4 2}This file documents postestimation tools for {help propcnsreg}. 

{p 4 4 2}{helpb propcnsreg_postestimation##propcnsasl:propcnsasl} computes a bootstrap test
of the proportionality constraint imposed by {cmd:propcnsreg}.

{p 4 4 2}The table below lists the standard postestimation commands that are also available.
Notice that {helpb margins} is not part of this list, because {cmd:propcnsreg} does not allow
the {help fvvarlist:factor variable notation}. The reason is that the purpose of {cmd:propcnsreg}
is to estimate a model with a special (constrained) type of interaction effect while part of the 
job of the factor variable notation is to keep track of interactions in your model, and the two 
bite.  

{synoptset 14 tabbed}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estat
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_mfx
INCLUDE help post_nlcom
{synopt :{helpb propcnsreg_postestimation##predict:predict}}predictions{p_end}
INCLUDE help post_predictnl
INCLUDE help post_suest
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker propcnsasl}{...}
Help for {cmd:propcnsasl}
{hline}

{title:Syntax}

{p 8 15 2}
{cmd:propcnsasl} 
[
{cmd:,} 
{opt reps(#)}
{opt nodots}
{opt mcci(#)} 
{opt sa:ving(filename [, replace double every(#)])}
]

{title:Description}

{pstd}
{cmd:propcnsasl} computes a bootstrap test ({help propcnsreg_postestimation##davison_hinkley:Davison and Hinkley 1997}, Chapter 4; 
{help propcnsreg_postestimation##efron_tibshirani:Efron and Tibshirani 1993}, chapter 16) of the proportionality constraint imposed 
by {cmd:propcnsreg}. It is similar to the tests reported {cmd:propcnsreg}, except that
it computes the p-values using the bootstrap. It is mainly useful when the 
{cmd:vce(bootstrap)} option was used for estimating the standard errors of the 
{cmd:propcnsreg} model. In that case no test of the proportionality constrained will 
be reported and the test returned by {cmd:propcnsasl} is the natural analogue of that 
test.

{pstd}
A {cmd:propcnsreg} model allows the effects of the variables in 
{cmd:constrained()} to change as the variables in {cmd:lambda()} change but imposes 
the constraint that the effects of all variables in {cmd:constrained()} change by the 
same proportion. So if we have the variables father's education and mother's education
in {cmd:constrained()} and birth-cohort in {cmd:lambda()}, than {cmd:propcnsreg} 
imposes the constraint that the effects of both parents' education change over time by 
the same proportion. In other words, the effect of parental eduction may have changed 
but the relative influence of the father compared to the mother has remained constant.

{pstd}
This bootstrap test takes the following steps:

{pmore}
1) It estimates an unconstrained model, that is, a model that includes all interactions
between the variables in {cmd:lambda()} and {cmd:constrained()}, and computes a 
non-linear Wald test of the proportionality constraint.

{pmore}
2) It creates a dataset such that the null hypothesis is true but is otherwise as
similar as possible to the observed data. It samples with replacement {cmd:reps} samples
from this dataset.

{p 12 12 2} If the {cmd:logit} option was not specified in the preceding {cmd:propcnsreg}
command, than this is done by first subtracting the predicted values of the unconstrained
model from the dependent variable and than adding the predicted values of the constrained
model. It than samples with replacement {cmd:reps} samples from this dataset.

{p 12 12 2} If the {cmd:logit} option was specified in the preceding {cmd:propcnsreg}
command, than this was done by first computing predicted probabilities under the 
constrained model, and than sample {cmd:reps} new dependent variables based on these
probabilities.

{pmore}
3) It than computes the Wald statistic in each of these samples. This gives an estimate of
 the sampling distribution of the test statistic if the null hypothesis is true.

{pmore}
4) The estimate of the Achieved Significance Level (ASL) or p-value is the number of 
replications in which the Wald statistic is larger than the observed value plus one
divided by the number of replications plus one.

{pstd}
A key aspect this test is that it is computed with aid of a Monte Carlo experiment and are thus
uncertain. If one were to call {cmd: propcnsasl} twice (and not set the {help set_seed:seed}), one 
will find slightly different ASLs. {cmd:propcnsasl} quantifies this uncertainty by displaying a 
Monte Carlo confidence interval for the ASL. If you were to call {cmd:propcnsasl} a 100 times you 
would in 95 of these calls expect to find an ASL within this interval. If you are unhappy with 
the width of this interval, than you can decrease it by specifying more replications in the 
{cmd:reps()}. Typically, I find 19,999 a number that works well for this type of procedure; if 
the "true" p-value is 0.05 than the ASL will on average be computed based on a 999 replications 
where the simulated statistic is larger than the observed statistic.


{title:An aside}

{pstd}
The estimate of the ASL used in this program is discussed in Chapter 4 of 
({help propcnsreg_postestimation##davison_hinkley:Davison and Hinkley 1997}) and deviates slightly from the estimate 
discussed in Chapter 16 of ({help propcnsreg_postestimation##efron_tibshirani:Efron and Tibshirani 1993}) in that the 
latter estimate the ASL using just the proportion of times that that test statistic is more extreme 
than the one found in the real data. With a large number of replications this difference is not going
to matter, but striclty speaking the former is slightly preferable. 

{pstd}
If we find an ASL of {it:a}, than the probability of drawing a dataset with an ASL less than or equal 
to {it:a} if the null hypothesis is true should itself be {it:a}, and this should be true for all 
possible values of {it:a}. So the sampling distribution of the ASL if the null hypothesis is true 
should be a standard uniform distribution. In other words, if the null hypothesis is true all possible 
values of {it:a} should be equally likely.

{pstd}
If we compute our ASL using B replications, than the number of possible values for {it:a} is limited 
to only B+1 values: a value based on 0, 1, 2, ..., or B replications with a test statistic as extreme 
or more than the one found in the real data. Based on the condition discussed above, each of these 
possible values should have a probability of 1/(B+1) if the null hypothesis is true. This means that 
if the null hypothesis is true, the probability of finding 0 replications with a test statistic as 
extreme or more as the one found in the real data is 1/(B+1). Similarly, the probability of finding 1 
or less replications with a test statistic at least as extreme as the one found in the real data is 
2/(B+1). Generally, the probability of finding k or less replications with a test statistic as 
extreme or more as the one found in the real data if the null hypothesis is true is (k+1)/(B+1).


{title:Options}

{phang}
{opt reps(#)} specifies the number of replications used to compute the ASL. The default is {cmd:reps(1000)}.

{phang}
{opt nodots} suppresses display of the replication dots.  By default, one dot character is displayed for
each successful replication.  A red "x" is displayed if there was an error while computing the test 
statistic or if it is missing.

{phang}
{opt mcci(#)} specifies the confidence level, as a percentage, for the Monte Carlo confidence interval.  The 
default is {cmd:mcci(95)} or as set by {helpb set level}.

{phang}
{opt saving(filename [, replace double every(#)])} creates a Stata data file containing for each replication
the Wald statistic and p-value. See: {help prefix_saving_option}.


{title:Example}

{cmd}{...}
    sysuse nlsw88, clear
    gen hs = grade == 12 if grade < .
    gen sc = grade > 12 & grade < 16 if grade < .
    gen c = grade >= 16 if grade < .
    gen tenure2 = tenure^2
    gen tenureXunion = tenure*union
    gen tenure2Xunion = tenure2*union
    gen hours2 = ( hours - 40 ) / 5
    gen white = race == 1 if race < .

    propcnsreg wage tenure* union white hours2 , ///
        lambda(tenure tenureXunion union)        ///
        constrained(hs sc c) unit(c)             ///
        poisson irr vce(bootstrap)
		
    propcnsasl
{txt}{...}
{p 4 4 2}({stata "propcnsreg_ex 3":click to run}){p_end}


{title:References}

{marker davison_hinkley}{...}
{phang}
A.C. Davison & D.V. Hinkley (1997) 
{it:Bootstrap Methods and their Application}. Cambridge: Cambridge University Press.

{marker efron_tibshirani}{...}
{phang}
B. Efron & R.J. Tibshirani (1993) 
{it:An Introduction to the Bootstrap}. Boca Raton: Chapman & Hall/CRC.


{marker predict}{...}
Help for {cmd:predict}
{hline}

{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} 
[{cmd:,} {it:statistic} 
{cmd:{ul:eq}uation(}{it:eqno}{cmd:[}{it:, eqno}{cmd:])}]

{synoptset 14 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{synopt :{opt mu}}expected value of y (the default){p_end}
{synopt :{opt lat:ent}}predicted value of the latent variable{p_end}
{synopt :{opt eff:ect}}predicted effect of the latent variable{p_end}
{synopt :{cmd:xb}}xb, linear prediction{p_end}
{synopt :{cmd:stdp}}standard error of the linear prediction{p_end}
{synopt :{opt sc:ore}}first derivative of the log likelihood with respect to the linear 
predictor. {p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{phang}
{opt mu} (the default) calculates the expected value of the dependent variable.

{phang}
{opt lat:ent} calculates the predicted value of the latent variable.

{phang}
{opt eff:ect} calculates the predicted effect of the latent variable.

{phang}
{opt xb} calculates the linear prediction.

{phang}
{opt stdp} calculates the standard error of the linear prediction.

{phang}
{opt score} calculates the first derivative of the log likelihood with respect
to the linear predictions.

{phang}
{opt eq:ation()} specifies which equation is used. The complete syntax is given in
{help predict}. For example {cmd:predict eff, xb equation(lambda)} is equivalent to
 {cmd:predict eff, effect}. An example of its use for predicting standard errors (and
 confidence intervals) is given {helpb propcnsreg##example:here}.

