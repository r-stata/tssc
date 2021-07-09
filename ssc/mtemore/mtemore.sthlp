{smcl}

{* *! version 1.1.1  21dec2016}{...}


{cmd:help mtemore}
{hline}


{title:Title}

{p 4 8 2}
{cmd:mtemore - }{bf:Marginal Treatment Effects (MTE) With a Binary Instrument}

{p} {it:Note}: {cmd:mtemore} is the old version of the command {cmd:mtebinary}. 
{cmd:mtemore} was designed to produce results from Kowalski (July 2016), and {cmd:mtebinary}
was designed to produce results from Kowalski (May 2018).{p_end} 


{title:Syntax}

{p 4 4 2}
{cmdab:mtemore} {it:outcome} {cmd:(}{it:endogvar} {cmd:=} {it:instrument}{cmd:)} [{it:covariates}] [{cmd:, }{it:options}]

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

{synopt: {opt seed(#)}}specify random-number seed for bootstrapping; {bf: default is seed(6574357)}. {p_end}

{synopt: {opt boot:sample(opt)}}specify bootstrapping options; {it:opt} may be {bf:strata({it:varlist})}, 
{bf:cluster({it:varlist})}, or {bf:weight({it:varname})};{bf:default is nothing,} 
i.e., simple sampling with replacement. 

{synopt: {opt weightvar(varname)}}specify a (frequency or probability) weight variable {it:varname}; 
{bf:default is no weighting}.

{synopt: {opt noint:eract}}estimate the MTE with covariates without interaction terms between {it:covariates} 
and {it:instrument}; {bf:default is to interact}. {p_end}

{syntab:Post-Estimation}

{synopt: {opt nodec:omp}}suppress output containing selection and treatment effect decomposition. {p_end}
 
{synopt: {opt sum:marize(varlist)}}specify additional variables for summary statistics computation; 
{bf:default is summarize(outcome [predicted_outcome])}. {p_end} 

{synopt: {opt did:test(varlist)}}specify additional dependent variables in the internal validity test and the 
difference-in-difference test; {bf:default is  didtest(outcome [predicted_outcome])}. {p_end}
	
{synopt:{opt graphsave(graphsave)}}specify the PDF file name for saving the graphed output, 
{bf:default is graphsave(mtegraph)}.{p_end} 

{title:Description}
{p 4 4 4}

{p}{cmd:mtemore} estimates the marginal treatment effect (MTE) function using a binary instrument and a binary 
endogenous variable. The MTE is defined as the difference between the potential treated outcome and the potential
untreated outcome for an individual for whom the net benefit of treatment equals the cost of treatment, i.e., an
individual marginal to selecting into treatment (see Kowalski (July 2016) and Kowalski (May 2018) for details). {p_end}

{p}{cmd:mtemore} can implement both MTE estimation with and without covariates.
All statistical significance is assessed using bootstrapping. Observations with missing values for the outcome or
any specified covariates will be dropped prior to any estimation (including summary statistics and tests for internal
and external validity).{p_end}

{p} {cmd:mtemore} outputs sample counts and summary statistics for the outcome prior to MTE estimation. The 
predicted outcome, estimated among lottery losers but predicted among the entire sample, is summarized 
if covariates are included. Additional variables (e.g., covariates) for summary statistics may be specified using 
the {bf:summarize} option. Means and sample counts are provided for the Randomized Intervention Sample (RIS, the 
full sample), Intervention (I, lotteried in), Baseline (B, lotteried out), Randomized Intervention Sample Treated 
(RIST, treated), Randomized Intervention Sample Untreated (RISU, untreated), Baseline Treated (BT, always takers),
Baseline Untreated (BU, never takers and control compliers), Intervention Treated (IT, always takers and treated
compliers), Intervention Untreated (IU, never takers), Local Average Treated (LAT, treated compliers), Local 
Average Untreated (LAU, untreated compliers), and the Local Average (LA, all compliers).{p_end}

{p} Prior to MTE estimation, {cmd:mtemore} outputs results from the internal validity and 
difference-in-difference tests introduced in Kowalski (July 2016), with the outcome as the dependent variable. If 
covariates are specified, {cmd:mtemore} also outputs the results for these tests with the predicted outcome as the
dependent variable. Additional variables (e.g., covariates) as dependent variables for these tests can be specified 
using the {bf:didtest} option. To avoid oversampling of missing values and ensure reproducibility of bootstrapped samples,
each variable specified for the internal validity and difference-in-difference test is bootstrapped separately.{p_end}

{p} If no covariates are specified, {cmd:mtemore} estimates and graphs the marginal treated outcome MTO(p), 
marginal untreated outcome MUO(p), and marginal treatment effect functions. {cmd:mtemore} estimates the treated outcomes, 
untreated outcomes, and treatment effects for the aforementioned BT, BU, IT, IU, RIST, RISU, LA, and average (A) groups. 
Unless {bf:nodecomp} is specified, {cmd:mtemore} will also output the decomposition of the treated outcome into selection
and treatment effect for each of the aforementioned groups of interest, the baseline OLS (BOLS), the intervention OLS (IOLS),
 and the randomized intervention sample OLS (RISOLS), and the decomposition of BOLS, IOLS, and RISOLS into selection and
 treatment effect.{p_end}

{p}If covariates are specified, {cmd:mtemore} can estimate a nonlinear polynomial MTE(x,p) function. If no 
polynomial order is specified by the in the {bf:poly} option, {cmd:mtemore} by default estimates a linear MTE(x,p) 
function. {cmd:mtemore} graphs the SMTE(p), minMTE(x,p), and maxMTE(x,p) and outputs the functional forms for SMTE(p),
SMTO(p), and SMUO(p). Additionally, {cmd:mtemore} estimates the treated outcomes, untreated outcomes, and treatment 
effects for the BT, BU, IT, IU, RIST, RISU, LA, and A groups using the MTE with covariates. Finally, {cmd:mtemore} 
outputs the RMSD of the MTE with covariates, as well as the fraction explained and unexplained heterogeneity from
the user-specified covariates.

{p} For details on terminology, methodology, and estimation, see Kowalski (July 2016),
Kowalski (May 2018) and Kowalski (July 2018). The command outputs a legend for the output at the end of each execution.{p_end}

{title:Options}

{dlgtab:Estimation}

{phang}{bf:poly(#)} specifies the functional form of the MTE with covariates. A non-linear polynomial, 
{bf:poly>1}, is only available if {it:covariates} is not empty (i.e., when estimating the MTE with covariates). 
The default, regardless of whether covariates are specified or not, is {bf:poly(1)} (a linear MTE).{p_end}

{phang}{bf:reps(#)} specifies the number of bootstrap replications. The default is {bf:reps(200)}. {p_end} 

{phang}{bf:seed(#)} specifies the random-number seed for bootstrapping. The number of bootstrap replications should
be 2 or higher. The default is {bf:seed(6574357)}. {p_end}

{phang}{bf:bootsample({it:opt})} specifies optional bootstrap sampling options. {it:opt} may be 
{bf:strata({it:varlist})}, {bf:cluster({it:varlist})}, or {bf:weight({it:varname})}. These options
are applied in the standard fashion as implemented by Stata. If no options are specified, the command uses
simple sampling with replacement. For more information on these options, please see the respective Stata help 
files.{p_end}

{phang}{bf:weightvar({it:varname})} specifies a frequency or probability weight {it:varname} for inclusion in the
MTE estimation. The default is no weighting.{p_end}

{phang}{bf:nointeract} suppresses the interaction terms between {it:covariates} and {it:instrument} when estimating the
MTE with covariates. Interaction terms between {it:covariates} and {it:instrument} are only included in the
propensity score estimation regression, as per Kowalski (July 2016). The default is to include the interaction terms.{p_end}


{dlgtab:Post-Estimation}

{phang}{bf:nodecomp} suppresses the output containing the selection and treatment effect decomposition. The output 
includes a decomposition of the treated outcome and OLS estimates into a selection and treatment effect. The output 
is only available for the MTE without covariates. {p_end}

{phang}{bf:summarize({it:varlist})} specifies additional variables for summary statistics computation. The default is
{bf:summarize(outcome [pred_outcome])}. The summary statistics for the predicted outcome are output if covariates 
are specified. {p_end} 
	
{phang}{bf:didtest({it:varlist})} specifies additional dependent variables in the internal validity test and the 
difference-in-difference test. The default is {bf:didtest(outcome [pred_outcome])}. Results from the tests with the
predicted outcome as the dependent variable are output if covariates are specified. {p_end} 

{phang}{bf:graphsave({it:name})} specifies the PDF file name for saving the graphed output. The default is 
{bf:graphsave(mte_graph)}, saved in the working directory.{p_end} 

{title:Examples}

{phang} Examples implement the {bf:mtemore} command using a hypothetical dataset 
to replicate the results in Kowalski (July 2018)'s paper. 

{phang} Download example data, which is placed in the user's current directory.{p_end}
{phang}{cmd: net get mtemore}{p_end}

{phang}Load the example data{p_end}
{phang}{cmd:. use mtemore_data.dta}{p_end}

{phang}Example 1: Linear MTE without covariates, summarize covariates. {p_end}
{phang}{cmd:. mtemore Y2 (D = Z), summarize(age female) graphsave(mtemore)}{p_end}

{phang}Example 2: Linear MTE with covariates. Bootstrap for MTE with covariates might require some time.{p_end}
{phang}{cmd:. mtemore Y2 (D = Z) age female, reps(50) graph(mte_cov)}{p_end}

{phang}Example 3: Linear MTE with covariates, no interaction terms{p_end}
{phang}{cmd:. mtemore Y2 (D = Z) age female, nointeract reps(50) graph(mte_cov_noint)}{p_end}

{phang}Example 4: Quadratic MTE with covariates{p_end}
{phang}{cmd:. mtemore Y2 (D = Z) age female, poly(2) graph(mte_cov_quad)}{p_end}

{title:Stored results}

{pstd}
{cmd:mtemore} saves the following results in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt: {cmd:e(N)}}Number of observations{p_end}
{synopt: {cmd:e(reps)}}Number of bootstrap replications{p_end}
{synopt: {cmd:e(poly)}}Polynomial degree of the MTE function{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt: {cmd:e(averages)}}Summary statistics{p_end}
{synopt: {cmd:e(internal_valid)}}Results from internal validity test{p_end}
{synopt: {cmd:e(did_reg)}}Results from difference-in-difference test{p_end}

{phang}Without covariates{p_end}
{synopt: {cmd:e(MTE)}}Marginal treatment effect function MTE(p){p_end}
{synopt: {cmd:e(MTO)}}Marginal treated outcome function MTO(p) {p_end}
{synopt: {cmd:e(MUO)}}Marginal untreated outcome function MUO(p){p_end}
{synopt: {cmd:e(TE)}}Treatment effects{p_end}
{synopt: {cmd:e(TO)}}Treated outcomes{p_end}
{synopt: {cmd:e(UO)}}Untreated outcomes{p_end} 
{synopt: {cmd:e(selection)}}Selection effect decomposition of treated outcomes{p_end}
{synopt: {cmd:e(treatment)}}Treatment effect decomposition of treated outcomes{p_end}
{synopt: {cmd:e(OLS_est)}}BOLS, IOLS, and RISOLS estimates {p_end}
{synopt: {cmd:e(OLS_selection)}}Selection effect decomposition of OLS estimates{p_end}
{synopt: {cmd:e(OLS_treatment)}}Treatment effect decomposition of OLS estimates{p_end}

{phang}With covariates{p_end}
{synopt: {cmd:e(beta_to)}}Covariate coefficients from separate estimation among the treated{p_end}
{synopt: {cmd:e(beta_uo)}}Covariate coefficients from separate estimation among the untreated{p_end}
{synopt: {cmd:e(SMTE)}}Sample Marginal Treatment Effect function SMTE(p){p_end}
{synopt: {cmd:e(SMTO)}}Sample Marginal Treated Outcome function SMTO(p){p_end}
{synopt: {cmd:e(SMUO)}}Sample Marginal Untreated Outcome function SMUO(p) {p_end}
{synopt: {cmd:e(minMTE)}}The minimum MTE(x,p){p_end}
{synopt: {cmd:e(maxMTE)}}The maximum MTE(x,p){p_end}
{synopt: {cmd:e(STE)}}Treatment effects{p_end}
{synopt: {cmd:e(STO)}}Treated outcomes{p_end}
{synopt: {cmd:e(SUO)}}Untreated outcomes{p_end}
{synopt: {cmd:e(RMSD)}}RMSD, fraction explained and unexplained heterogeneity{p_end}

{phang} All estimates in the matrices listed above are saved with their 95% confidence intervals. {p_end}

{title:References}

{phang} Amanda Kowalski, 2018 "Extrapolation using selection and moral hazard heterogeneity
from within the Oregon health insurance experiment", NBER Working Paper 24647, May 2018. {p_end}

{phang} Amanda Kowalski, 2016 "Doing More When You're Running LATE: Applying Marginal Treatment Effect Methods to 
Examine Treatment Effect Heterogeneity in Experiments", NBER Working Paper 22363, July 2016. {p_end}

{phang} Amanda Kowalski, 2016 "How to Examine External Validity Within an Experiment", NBER Working Paper 24834, July 2018.
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
{p 4 6}Latest Version: December 2016 / First Version: December 2016{p_end}
