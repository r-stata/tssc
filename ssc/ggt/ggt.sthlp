{smcl}
{* *! version 1.0  18oct2019}{...}

{cmd: help ggt}
{hline}

{title:Title}

{p2colset 5 12 12 2}{...}
{p2col :{hi:ggt} {hline 2}}Geweke, Gowrisankaran, and Town Model Quality Estimator{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 18 2}
{cmdab:GGT,} 
outcomevar({it:varname})
orgchar({it:varname})
indID({it:varname})
orgID({it:varname})
choicechar({it:varlist})
[
{it:options}]


{title:Description}

{pstd}
This program estimates the parameters of the Geweke, Gowrisankaran, and Town (2003), "GGT," model.
The GGT model estimates the posterior distribution of organizational performance where there are 
many organizations from which individuals can choose to receive services. In this framework, individuals 
may select organizations based, in part, on information that is unobserved to the researcher and is 
correlated with the binary outcome. If this is the case, then standard approaches to inferring 
organization performance will yield biased estimates. The GGT model corrects for this unobserved selection 
allowing for flexible correlation in the error structure across the organizational choice and outcome equations. 
The estimation approach is Bayesian. In sum, the model combines an organization choice multinomial probit model 
with an individual outcome binary probit model, allowing for correlation across equations for each individual. As noted in GGT,
some possible applications for this model include: hospital quality based on mortality, school performance based on graduation 
rates, prison rehabilitation programs based on recidivism rates, and job training programs based on incidence of harassment complaints. 

{pstd}
The parameters are estimated using Bayesian inference through Markov chain Monte Carlo techniques to simulate 
parameters and latent variables conditional on data to determine the posterior distribution of parameters. 
While we present the basics of the model in the associated auxiliary file "{bf:GGT_methods.pdf}," (accessed via the command: {cmd: ssc desc GGT}), 
we encourage all users of this Stata function to read the GGT 
paper to fully understand the model, assumptions underneath the model, and parameters used in the estimation. 

{pstd}
To speed up the computation process, the program code calls an included C plugin file which estimates the 
parameters via MCMC Gibbs Sampling. 



{title:Methods and Equations}

{pstd}
We include a brief, yet important, explanation of the appropriate GGT model in the auxiliary file "{bf:GGT_methods.pdf,}" which can be obtained
via command {cmd: ssc desc GGT}. This file shows which variables and parameters are references in the calling for the GGT Stata function. 

{pstd} 
{bf:Technical Note:} Users may notice some slight differences in the model description of prior 
distributions from that in GGT Section 2.2. These do not change the model but do make the Stata 
code more tractable. We also describe these changes in the {bf:"GGT_methods.pdf"} file. 


{title:Options}

{dlgtab:Required Model Variables}

{phang}
{opt outcomevar(varname)} is required. It is the name of the variable that indicates the individual outcomes
in the binary probit model. This variable needs to be 0 or 1 for each individual. 

{phang}
{opt orgchoice(varname)} is required. It is the name of the variable that indicates the organization 
that each individual selects/chooses. This variable should be 0,1 and should sum to 1 for each 
individual.
 
{phang}
{opt indID(varname)} is required. It provides a unique identifier for each individual.
 
{phang}
{opt orgID(varname)} is required. It provides a unique identifier for each organization.

{phang}
{opt choicechar(varlist)} is required. It specifies the name of the variables that should be 
included in the choice equation. These are the Z variables referenced in {bf:"GGT_methods.pdf"} auxiliary file. 


{dlgtab:Optional Model Variables}

{phang}
{opt orgchar(varlist)} specifies the name of the variables that hold the different organization 
characteristics. These are the k and l variables referenced in {bf:"GGT_methods.pdf"} auxiliary file.
The maximum number of variables in this varlist is 10. The variables must be categorical in nature 
and can either be of Stata type string or factor. 
	
{phang}
{opt indchar(varlist)} specifies the name of the variables that should be included in the individual 
outcome probit equation. These are the X variables referenced in {bf:"GGT_methods.pdf"} auxiliary file.
The maximum number of variables in this varlist is 20. 
 
{dlgtab:Optional Model Parameters}

{phang}
{opt niter(integer)} is the number of iterations for Gibbs sampling. The default is 100000. 

{phang} 
{opt alphapriorvar(real)} is the diagonal elements of the alpha prior variance-covariance matrix. 
The default is 1. 

{phang}
{opt gammapriorvar(real)} is the diagonal elements of the gamma prior variance-covariance matrix. 
The default is 1.		

{phang}
{opt deltapriorvar(real)} is the sigma_gamma^2 term in the prior distribution of delta. See footnote 17 in GGT for information 
on choosing this value. The default is 0.038416.

{phang}
{opt priortau(real, integer)} is the hyper-parameters for the organization characteristic variance 
hierarchical prior distributions. GGT allows users to specify the s2 and v terms in the hierarchical prior, 		
s2 / tauo2 ~ chi2(v) for organization characteristic, o. These terms are all referenced in referenced in {bf:"GGT_methods.pdf}" auxiliary file. 
The first and second numbers in priortau() are s2 and v respectively. The default is priortau(1.25,5). Users must specify both elements 
if choosing to use this option. 

{phang}
{opt noselection} option should be specified if the user does not want to apply the selection 
correction. In this case, the program 	will simply estimate the parameters in GGT equation (1). Note: 
The code will also estimate alpha solely for the purpose of comparison. 

{phang}
{opt noconstant} option should be specified if the user does not want to include a constant in 
the outcome probit equation, i.e. gamma will not include a constant term. 

{dlgtab:Reporting}

{phang}
{opt savedraws} option will save a .csv file in the directory which holds every 100 draws of each parameter 
via the MCMC Gibbs Sampling routine. 



{title:Examples}

{pstd}
In this section, we present the data structure necessary to run {cmd:GGT} along with 
3 examples to demonstrate different calls to the program. Please see the auxiliary file {bf:"GGT_examples.pdf"} for more 
detailed explanation of the following data and examples. We provide the sample data, {bf:"GGT_test_data.dta"} 
as an additional auxiliary file as well. 

{bf:Data Structure}

{pstd}
Assume we are interested in hospital quality. The dataset {bf:"GGT_test_data.dta"} contains data on 
300 patients and 8 hospitals. The variables include the individual patient identifier, {it:indnumber}, and the hospital identifier,
{it:hospnum}. The patient specific variables are {it:mortality} and {it:severity}.
The individual choice variables are {it:dist} and {it:dist2} representing the distance from each patient to each 
hospital along with its square (normalized to have similar scales, necessary since the priors are the same).  We also have 
hospital characteristic variables, {it:hosp_size} and {it:hosp_ownership}.

{pstd}
In the Stata dataset, there should be an observation for each individual-hospital pair, even if the 
individual did not choose that hospital. For example, with 300 patients and 8 hospitals, we have 
300*8=2400 observations in the data. Please see the {bf:"GGT_test_data.dta"} auxiliary file to explore the appropriate dataset format. 

{pstd}{cmd:. use GGT_test_data.dta}{p_end}

{bf:Example 1}

{pstd}
Suppose we want to estimate the selection-correction hospital quality measures using all the default settings. 

{pstd}{cmd:. ggt, outcomevar(mortality) orgchoice(hosp_choice) indID(indnumber) orgID(hospnum) choicechar(dist dist2)}{p_end}

{pstd}complete

{pstd}
This will apply the selection model using {it:dist} and {it:dist2} as the choice characteristics. 
Since we did not specify the {opt indchar} option, the code will assume only a constant and the hospital choice 
for the individual probit model. Additionally, since we did not specify {opt orgchar}, the code will assume 
no correlation across hospitals via hospital size or ownership. The sampling algorithm will assume the 
default prior variance options and number of iterations.

{pstd}
The output on the screen will be the summary statistics for the estimated beta draws via the MCMC Gibbs 
sampler. The variable "q_n" respresents the quality for hospital ID, 'n'. The number of observations in 
this example is 900- this comes from the default 100000 iterations, saving only every 100th draw, and 
deleting the first 10000 draws as burn-in. 

{pstd}
{bf:Note:} The code may take several minutes to complete running due to its computational complexity. Once the 
code is complete, the word "complete" will display on the Stata screen. If after a couple minutes the code
does not complete or Stata simply quits, this is likely due to an error with the prior variance 
specifications which are not compatible with the data. We suggest re-loading Stata and trying to call the program again using 
different prior variance values. 

{bf:Example 2}

{pstd}
Now, suppose we want to include the severity measure in the mortality equation and we also want to allow hospital correlation based on size and ownership. 
Additionally, we want to rescale the prior variances based on the structure of the data. Specifically, we want the prior variance of alpha to be 5, 
the prior variance of gamma to be 3, selection term for delta to be 1, and the parameters for the hyperpriors to be 1 and 5.  Finally, we want to save 
the draws for each of the parameters in a csv file to the directory. 

{pstd}{cmd:. ggt, outcomevar(mortality) orgchoice(hosp_choice) indID(indnumber) orgID(hospnum) choicechar(dist dist2) indchar(severity) orgchar(hosp_size hosp_ownership) alphapriorvar(5) gammapriorvar(3) deltapriorvar(1) priortau(1,5) savedraws }{p_end}

{pstd}complete

{bf:Example 3}

{pstd}
Finally, suppose we wish to compare the results to the case where we do not apply the selection 
correction. In this case, the program simply estimates equation (1) in GGT. We can still specify all the 
options, but the code will only use those that are necessary. e.g., since the nonselection model assumes 
that delta=0, then specifying deltapriorvar is unnecessary. 

{pstd}
Note: Even though the equation we wish to estimate does not depend on patient-organization choice 
characteristics, the code will still require choice characteristics in its estimation of alpha. 

{pstd}{cmd:. ggt, outcomevar(mortality) orgchoice(hosp_choice) indID(indnumber) orgID(hospnum) choicechar(dist dist2) indchar(severity) orgchar(hosp_size hosp_ownership) alphapriorvar(5) gammapriorvar(3) priortau(1,5) noselection}{p_end}

{pstd}{txt}complete


{title:References}

Geweke, J., Gowrisankaran, G., & Town, R. J. (2003). Bayesian inference for hospital quality in a selection model. Econometrica, 71(4), 1215-1238.

{p2colreset}{...}
