{smcl}
{* *! version 1.05  3 Aug 2015}{...}
{viewerjumpto "Syntax" "crm##syntax"}{...}
{viewerjumpto "Description" "crm##description"}{...}
{viewerjumpto "Options" "crm##options"}{...}
{viewerjumpto "Examples" "crm##examples"}{...}
{title:Title}

{phang}
{bf:crm} {hline 2} An implementation of the continual reassessment model

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:crm}
[{varlist}]
{if}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth s:keleton(numlist)}}specifies the prior probabilities of a DLT for each dose.{p_end}
{synopt:{opt m:odel(string)}}specifies the toxicity model in terms of dose.{p_end}
{synopt:{opt t:arget(#)}}specifies the target toxicity level; the default is 0.2.{p_end}
{synopt:{opt d:elta(string)}}specifies the distance measure for selecting the next dose.{p_end}
{synopt:{opt q:uadpts(#)}}specifies the number of quadrature points to use in the numerical integration; the default is 80.{p_end}
{synopt:{opt inv:model(string)}}specifies the inverse function of the model option.{p_end}
{synopt:{opt prior(string)}}specifies the prior distribution.{p_end}
{synopt:{opt p:mean(#)}}specifies the mean of the prior distribution.{p_end}
{synopt:{opt p:sd(#)}}specifies the standard deviation of the prior distribution.{p_end}
{synopt:{opt sd:osemedian(#)}}specifies that the median of the prior is used in calculating the standardised doses.{p_end}
{synopt:{opt ignorebinary:}}specifies that estimation should continue even though the outcome variable does not vary.{p_end}
{synopt:{opth dose(numlist)}}specifies the doses.{p_end}
{synopt:{opt g:raph}}specifies that a graph drawn of the data and posterior toxicity probabilities.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:crm} is an implementation of a single parameter continual reassessment method (O'Quigley et al. 1990). The implementation
uses the exact method i.e. integrals are evaluated at every dose level rather than using a plug-in mean. Additionally 
the quantiles of the posterior distributions are calculated by using optimization and numerical integration which can be slow.

{pstd}
A model is specified that links dose and the probability of a dose limiting toxicity (DLT) using
a single parameter {bf:a}. A prior distribution is required for {bf:a}. The
default mean of the prior is 1, but the mean and standard deviation can be user specified. 
A prior probability of DLT for every dose level needs to be specified beforehand, this is the "skeleton".
 These probabilities must be monotonically increasing, if any of these values are the same then this would 
mean that two doses will always give the same chance of a DLT and so the posterior probability of toxicity for two doses would be the same
and hence the lower dose is redundant. In order for these prior
probabilities to be consistent with the prior distribution of {bf:a}, the doses are rescaled at the 
start of the study; this ensures an exact fit of the model to the priors.

{pstd}
The dataset should consist of two columns the dose given to each patient and whether that patient experienced a DLT (1) or not (0).
The doses should be nominal values starting at 1 for the lowest dose, 2 for the next lowest, 3 for the next and so on. The
number of doses available is determined by the number of levels in the {it:skeleton()} option.

{pstd}
Note that this algorithm has been cross-checked with the R code bcrm.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth s:keleton(numlist)} specifies the prior probabilities of a DLT for each dose. All the probabilities need
to be between 0 and 1 and specified in ascending order as there is an assumption that the probilitiy of a DLT
increases monotonically with dose.

{phang}
{opt m:odel(string)} specifies the toxicity model in terms of dose and a single parameter a. There are two
built-in models (hyperbolic tangent and power) that have been implemented, but this option is very flexible and can use any single line function noting that
the parameter {bf:a} can be a vector so elementwise operators are needed.
The default model is the hyperbolic tangent model --- ((tanh(dose):+1):/2):^a . 

{phang}
{opt t:arget(#)} specifies the target toxicity level; the default is 0.2. In recommending a dose to a new patient the
dose chosen is closest to the target toxiciy level. Distance between the probability of toxicity and the target level is 
determined by the delta() option and the default is Euclidean distance.

{phang}
{opt d:elta(string)} specifies the distance measure for selecting the next dose. The default measure is Euclidean distance.

{phang}
{opt q:uadpts(#)} specifies the number of quadrature points to use in the numerical integration; the default is 80. The numerical
integration function can allow many quadrature points but if too many are specified then the program will become slow. 

{phang}
{opt inv:model(string)} specifies the inverse function of the model option. This option is important if the user specifies
a novel model function and the inverse function is required to calculate the standardised doses. The function should take two
arguments, the first is {bf:p} the probability of a toxicity and the second is {bf:a} the unknown parameter.

{phang}
{opt prior(string)} specifies the prior distribution, the default is the Exponential distribution. Additionally the log-normal
distribution can be used or any distribution can be specified in terms of the vector {bf:a}, here this vector is just the values of the 
distribution and not related to the unknown parameter.

{phang}
{opt p:mean(#)} specifies the mean of the prior distribution; the default is 1.

{phang}
{opt p:sd(#)} specifies the standard deviation of the prior distribution.

{phang}
{opt sd:osemedian(#)} specifies that the median of the prior is used in calculating the standardised doses.

{phang}
{opt ignorebinary:} specifies that estimation should continue even though the outcome variable does not vary.

{phang}
{opt dose(numlist)} specifies the doses.

{phang}
{opt g:raph} specifies that a graph drawn of the data and posterior toxicity probabilities.

{marker examples}{...}
{title:Examples}

{pstd}
The following dataset is taken from Neuenschwander et al. (2008)

. list

     +----------+
     | y   dose |
     |----------|
  1. | 0      1 |
  2. | 0      1 |
  3. | 0      1 |
  4. | 0      2 |
  5. | 0      2 |
  6. | 0      2 |
  7. | 0      2 |
  8. | 0      3 |
  9. | 0      3 |
 10. | 0      3 |
 11. | 0      3 |
 12. | 0      3 |
 13. | 0      4 |
 14. | 0      4 |
 15. | 0      4 |
 16. | 0      4 |
 17. | 1      7 |
 18. | 1      7 |
     +----------+

{pstd}
The doses are in the dataset as nominal doses and y is whether a patient experienced a dose limiting toxicity (DLT).
In the paper there were actually 15 possible doses and the prior skeleton was specified for all 15 doses.
The target toxicity level (TTL) was 30%. The command below fits the power model of risk i.e.  standardised_dose^a, where
{bf:a} has an exponential prior distribution with a mean of 1. The option quad(90) gives high precision on the numerical integration
and the option g produces a nice graphic to describe the recommended dose and the risk of DLT at each dose.

{phang}
{cmd: crm y dose, s(0.01 0.015 0.02 0.025 0.03 0.04 0.05 0.1 0.17 0.3 0.4 0.5 0.65 0.8 0.9) dose(1 2.5 5 10 15 20 25 30 40 50 75 100 150 200 250) target(0.3) model(power) inv(power) prior(exponential) pmean(1) quad(90) g }

{pstd}
Taking the same data but removing the highest 6 doses and now using the hyperbolic tangent model with a log-normal prior the command becomes

{phang}
{cmd: crm y dose, s(0.01 0.015 0.02 0.025 0.03 0.04 0.05 0.1 0.17) dose(1 2.5 5 10 15 20 25 30 40) target(0.3) prior(lognormal) psd(1.4) pmean(0) g }

{pstd}
The command can allow {bf:ANY} prior and risk model. The following example uses an exponential prior distribution with the hyperbolic tangent risk
model (and the inverse model needs to be specified in this case to get the standardised doses)

{phang}
{cmd: crm y dose, s(0.01 0.015 0.02 0.025 0.03 0.04 0.05 0.1 0.17) dose(1 2.5 5 10 15 20 25 30 40) target(0.3) prior( exp(-1:*a) ) model( ((tanh(dose):+1):/2):^a ) invmodel( atanh(2*p^(1/a)-1) ) quad(30) pmean(1) g }

{pstd}
Note that this example was chosen as it suggests to escalate doses even when observing 2 DLTs from 2 patients at dose 7

{title:References}

{pstd}
Sweeting M., Mander A. and Sabin A. (2013) bcrm: Bayesian contrinula reassessment method designs for phase I dose-finding trials. 
{it: Journal of Statistical Software}, {bf 54}:13.

{pstd}
O'Quigley J., Pepe M. and Fisher L. (1990) Continual reassessment method: A practical design for phase I clinical trials in cancer. {it:Biometrics},
{bf:46}: 33-48.

{pstd}
Neuenschwander B., Branson M. and Gsponer T. (2008) Critical aspects of the Bayesian approach to phase I cancer trials. {it:Statistics in Medicine},
{bf:27}: 2420-2439.

{title:Author}
{p}
Adrian Mander, MRC Biostatistics Unit, Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

