{smcl}

{* *! version 1.1.1  21dec2016}{...}


{cmd:help mtebinary}
{hline}


{title:Title}

{p 4 8 2}
{cmd:mtebinary - }{bf:Marginal Treatment Effects (MTE) With a Binary Instrument}

{p} {it:Note}: {cmd:mtebinary} is the new version of the command {cmd:mtemore}. 
It generates results from Kowalski (May 2018).{p_end} 

{title:Syntax}

{p 4 4 2}
{cmdab:mtebinary} {it:outcome} {cmd:(}{it:endogvar} {cmd:=} {it:instrument}{cmd:)} [{it:covariates}] [{cmd:, }{it:options}]

{p 4 4 2}
{it:outcome} is the outcome variable; can be binary, discrete or continuous.

{p 4 4 2}
{it:endogvar} is the endogenous variable; must be binary.

{p 4 4 2}
{it:instrument} is the instrument; must be binary.

{p 4 4 2}
{it:covariates} is the list of covariates used for MTE estimation.

{synoptset 25 tabbed}{...}
{synopthdr :options}
{synoptline}

{syntab: Estimation}

{synopt: {opt poly(#)}}specify functional form of the MTE with covariates; {bf:default is poly(1)}. {p_end}
	
{synopt: {opt reps(#)}}specify number of bootstrap replications; {bf:default is reps(200)}.{p_end}

{synopt: {opt seed(#)}}specify random-number seed for bootstrapping; {bf: default is seed(6574358)}. {p_end}

{synopt: {opt boot:sample(opt)}}specify bootstrapping options; {it:opt} may be {bf:strata({it:varlist})}, 
{bf:cluster({it:varlist})}, or {bf:weight({it:varname})};{bf:default is nothing,} 
i.e., simple sampling with replacement. 

{synopt: {opt weightvar(varname)}}specify a (frequency or probability) weight variable {it:varname}; 
{bf:default is no weighting}.

{syntab:Post-Estimation}

{synopt: {opt sum:marize(varlist)}}specify variables for summary statistics computation.{p_end} 

{synopt:{opt graphsave(graphsave)}}specify the PDF file name for saving the graphed output, 
{bf:default is graphsave(mtegraph)}.{p_end} 

{title:Description}
{p 4 4 4}

{p}{cmd:mtebinary} estimates the marginal treatment effect (MTE) function using a binary instrument and
a binary endogenous variable. The MTE is defined as the difference between the potential treated outcome
and the potential untreated outcome for an individual for whom the net benefit of treatment equals the 
net cost of treatment, i.e., an individual marginal to selecting into treatment (see Kowalski (2016, 2018) for 
details). {p_end}

{p}{cmd:mtebinary} can implement MTE estimation with and without covariates. All statistical significance is assessed using bootstrapping. Observations with missing values for the outcome or
any specified covariates will be dropped prior to any estimation (including summary statistics).{p_end}

{p} Prior to MTE estimation, variables (e.g., covariates) for summary statistics may be specified using 
the {bf:summarize} option. Means and standard deviations are provided for the groups of always takers, 
compliers and never takers. Means and standard deviations of differences between always takers and 
compliers, and between compliers and never takers are also provided.{p_end}

{p} If no covariates are specified, {cmd:mtebinary} estimates and graphs the marginal treated outcome 
MTO(p), marginal untreated outcome MUO(p), and marginal treatment effect MTE(p) functions.
{cmd:mtebinary} estimates the treated outcomes, untreated outcomes, and treatment effects for the always 
takers, compliers and never takers groups. {cmd:mtebinary} also computes the differences in untreated
outcomes and treated outcomes for the treated outcome test and the untreated outcome test. {p_end}

{p}If covariates are specified, {cmd:mtebinary} can estimate a nonlinear polynomial MTE(X,p) function.
If no polynomial order is specified by the in the {bf:poly} option, {cmd:mtebinary} by default estimates
a linear MTE(X,p) function. {cmd:mtebinary} outputs the functional forms for the average marginal untreated 
outcome E[MUO(X,p)], the average marginal treated outcome E[MTO(X,p)], and the average marginal treatment
effect E[MTE(X,p)]. {cmd:mtebinary} also graphs the average marginal treatment effect E[MTE(X,p)], 
the minimum marginal treatment effect minMTE(X,p), and the maximum treatment effect maxMTE(X,p). {p_end}

{p}For details on terminology, methodology, and estimation, see Kowalski (May 2018), Kowalski (August 2016) 
and Kowalski (July 2018). 

{title:Options}

{dlgtab:Estimation}

{phang}{bf:poly(#)} specifies the functional form of the MTE with covariates. A non-linear polynomial, 
{bf:poly>1}, is only available if {it:covariates} is not empty (i.e., when estimating the MTE with covariates). 
The default, regardless of whether covariates are specified or not, is {bf:poly(1)} (a linear MTE).{p_end}

{phang}{bf:reps(#)} specifies the number of bootstrap replications. The default is {bf:reps(200)}. {p_end} 

{phang}{bf:seed(#)} specifies the random-number seed for bootstrapping. The number of bootstrap replications should
be 2 or higher. The default is {bf:seed(6574358)}. {p_end}

{phang}{bf:bootsample({it:opt})} specifies optional bootstrap sampling options. {it:opt} may be 
{bf:strata({it:varlist})}, {bf:cluster({it:varlist})}, or {bf:weight({it:varname})}. These options
are applied in the standard fashion as implemented by Stata. If no options are specified, the command uses
simple sampling with replacement. For more information on these options, please see the respective Stata help 
files.{p_end}

{phang}{bf:weightvar({it:varname})} specifies a frequency or probability weight {it:varname} for inclusion in the estimation
of average characteristics of the always takers, compliers and never takers (if the {bf:summarize()} option is specified). It is
also the weight used in the propensity score regression in the MTE estimation algorithm. The default is no weighting.{p_end}

{dlgtab:Post-Estimation}

{phang}{bf:summarize({it:varlist})} specifies additional variables for summary statistics computation. If no covariates are specified
the command will skip this funtionality. {p_end} 
	
{phang}{bf:graphsave({it:name})} specifies the PDF file name for saving the graphed output. The default is 
{bf:graphsave(mte_graph)}, saved in the working directory.{p_end} 

{title:Examples}

{phang} The example data provided with this command replicates the hypothetical examples from Kowalski(July 2018).
Example 1 replicates the results of the MTE without covariates reported in this paper. Examples 2 and 3 mimic 
the estimation of the MTE functions in Kowalski(July 2016, May 2018) but use a hypothetical data set and a simplified 
set of covariates.  Examples 1 and 2 set the number of bootstrap replications to 0 in order for the command 
to run quickly. Example 3, which sets the number of bootstrap replications to the default number, 200, will 
require some time. 

{phang} Install the mtebinary package. {p_end}
{phang}{cmd:. ssc install mtebinary}{p_end}

{phang} Download example data, which is placed in the user's current directory.{p_end}
{phang}{cmd:. net get mtebinary}{p_end}

{phang}Load the example data{p_end}
{phang}{cmd:. use mtebinary_data.dta}{p_end}

{phang}Example 1: Linear MTE without covariates and standard errors, summarize covariates.{p_end}
{phang}{cmd:. mtebinary Y2 (D = Z), reps(0) summarize(age female) graphsave(mte)}{p_end}

{phang}Example 2: Linear MTE with covariates and without standard errors.{p_end}
{phang}{cmd:. mtebinary Y2 (D = Z) age female, reps(0) graphsave(mte_cov)}{p_end}

{phang}Example 3: Quadratic MTE with covariates. Bootstrap for MTE with covariates will require some time. {p_end}
{phang}{cmd:. mtebinary Y2 (D = Z) age female, poly(2) graphsave(mte_cov_quad)}{p_end}

{title:Stored results}

{pstd}
{cmd:mtebinary} saves the following results in {cmd:e()}:

{synoptset 24 tabbed}{...}
{p2col 5 25 30 5: Scalars}{p_end}
{synopt: {cmd:e(N)}}Number of observations{p_end}
{synopt: {cmd:e(reps)}}Number of bootstrap replications{p_end}
{synopt: {cmd:e(poly)}}Polynomial degree of the MTE function{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 25 30 5: Matrices}{p_end}
{synopt: {cmd:e(averages)}}Summary statistics{p_end}

{phang}Without covariates{p_end}
{synopt: {cmd:e(MTE)}}Marginal treatment effect function MTE(p){p_end}
{synopt: {cmd:e(MTO)}}Marginal treated outcome function MTO(p) {p_end}
{synopt: {cmd:e(MUO)}}Marginal untreated outcome function MUO(p){p_end}
{synopt: {cmd:e(Treatment_Effect)}}Treatment effects{p_end}
{synopt: {cmd:e(Treated_Outcome)}}Treated outcomes{p_end}
{synopt: {cmd:e(Untreated_Outcome)}}Untreated outcomes{p_end} 

{phang}With covariates{p_end}
{synopt: {cmd:e(beta_to)}}Covariate coefficients from separate estimation among the treated{p_end}
{synopt: {cmd:e(beta_uo)}}Covariate coefficients from separate estimation among the untreated{p_end}
{synopt: {cmd:e(EMTE)}}Average Marginal Treatment Effect function E[MTE(X,p)]{p_end}
{synopt: {cmd:e(EMTO)}}Average Marginal Treated Outcome function E[MTO(X,p)]{p_end}
{synopt: {cmd:e(EMUO)])}}Average Marginal Untreated Outcome function E[MUO(X,p)]{p_end}
{synopt: {cmd:e(Treatment_Effect)}}Treatment effects{p_end}
{synopt: {cmd:e(Treated_Outcome)}}Treated outcomes{p_end}
{synopt: {cmd:e(Untreated_Outcome)}}Untreated outcomes{p_end}

{phang} All estimates in the matrices listed above are saved with their 95% confidence intervals. {p_end}

{title:References}

{phang} Amanda Kowalski, 2018 "Extrapolation using selection and moral hazard heterogeneity
from within the Oregon health insurance experiment", NBER Working Paper 24647, May 2018. {p_end}

{phang} Amanda Kowalski, 2016 "Doing More When You're Running LATE: Applying Marginal Treatment Effect Methods to 
Examine Treatment Effect Heterogeneity in Experiments", NBER Working Paper 22363, July 2016. {p_end}

{phang} Amanda Kowalski, 2018 "How to Examine External Validity Within an Experiment", NBER Working Paper 24834, July 2018.
{p_end}

{title:Disclaimer}
{phang} THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED. THE ENTIRE 
RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE YOU ASSUME 
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION. {p_end}

{phang} IN NO EVENT WILL THE COPYRIGHT HOLDERS OR THEIR EMPLOYERS, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR 
REDISTRIBUTE THIS SOFTWARE BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR 
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM. {p_end}

{title:Authors}

{p 4 6}Amanda Kowalski, Yen Tran, and Ljubica Ristovska{p_end}
{p 4 6}Yale University, Yale University, and NBER {p_end}
{p 4 6}kowalski@nber.org / yen.tran@yale.edu / lristovs@nber.org{p_end}
{p 4 6}Latest Version: June 2018 / First Version: December 2016{p_end}
