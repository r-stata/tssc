{smcl}
{* *! version 0.1.0 13jul2012}{...}
{hline}
{cmd:help metapowplot} {right:also see: {helpb metasim}, {helpb metapow}}
{hline}

{title:Title}

{p2colset 5 20 21 2}{...}
{p2col :{cmd:metapowplot} {hline 2}}Produces power plots based on meta-analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: metapowplot} {it:varlist} {cmd:,} {opt start:(#)} {opt stop:(#)} {opt step:(#)} {opt nit:(#)} {opt type:(string)} {opt pow:(numlist)} [{it:options}]


{synoptset 18 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt:{opt start(#)}} minimum number of subjects in group 1 (see below) {p_end}
{synopt:{opt stop(#)}} maximum number of subjects in group 1 (see below) {p_end}
{synopt:{opt step(#)}} step size between start and stop sample sizes {p_end}
{synopt:{opt ty:pe(string)}} type of study being simulated {p_end}
{synopt:{opt nit(#)}} number of simulations the power calculation is based on {p_end}
{synopt:{opt pow(numlist)}} cut-off value for determining power {p_end}

{syntab :Optional}
{synopt:{opt meas:ure(string)}} outcome measure used in meta-analysis {p_end}
{synopt:{opt inf:erence(string)}} inference statistic on which power is based {p_end}
{synopt:{opt p(#)}} event rate or probability of being diseased dependent on ({it:type}) {p_end}
{synopt:{opt r(#)}} ratio of patients in two groups; treatment and control or diseased and healthy {p_end}
{synopt:{opt st:udies(#)}} number of new studies to be simulated {p_end}
{synopt:{opt mod:el(string)}} meta-analysis model used on pre-existing data {p_end}
{synopt:{opt npow(numlist)}} additional inference statistic on which power is based {p_end}
{synopt:{opt ci(#)}} width of confidence interval for power estimate (default=95%) {p_end}
{synopt:{opt dist(string)}} distribution of effect sizes used to simulate the new study from {p_end}
{synopt:{opt ind}} calculates power for new study on its own {p_end}
{synopt:{opt nip(#)}} number of integration points used for quadrature in bivariate model {p_end}
{synopt:{opt sos(string)}} inference option for sensitivity and specificity to be used with {it:ciwidth} or {it:lci} {p_end}
{synopt:{opt gr:aph(string)}} type of graph to be plotted {p_end}
{synopt:{opt noci}} prevents confidence intervals from being displayed on the graph {p_end}
{synopt:{opt regraph}} allows the user to re-graph the power curve using alternative graph options {p_end}
{synopt:{opt level(cilevel)}} specifies the confidence level for the study confidence intervals {p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:metapowplot} estimates the power of an updated meta-analysis including a new study and plots each value against 
a range of sample sizes. The program calls on the program {helpb metapow} to generate the power 
estimates. The user needs to input a minimum and a maximum sample size for which they want to calculate a power estimate. The 
power estimates are stored with their confidence intervals in a file called temppow3 within the working directory. 


{title:Options}

{dlgtab:Main}

{phang}
{opt start(integer)} is the smallest total sample size for a new study that the user wishes to calculate a power value for. {p_end}

{phang}
{opt stop(integer)} is the largest total sample size for a new study that the user wishes to calculate the power value for. {p_end}

{phang}
{opt step(integer)} is the step size to be used within the range of total sample sizes specified by {opt start} and {opt stop}.
 A step size of 10 between the range of 10 to 30 would mean that the power would be estimated for sample sizes of 10, 20 and 30. {p_end}

{phang}
{opt type(clinical/diagnostic)} specifies the type of new study that the user would like to simulate; either a 2-arm clinical trial or a diagnostic test accuracy study. {p_end}

{phang}
{opt nit(integer)} is the number of simulations that are run on which the estimated poweris based. The larger the number specified the more accurate
the estimate will be, but the longer the analysis will take. {p_end}

{phang}
{opt pow(numlist)} specifies the value used as a cut-off in determining the power. One or two values can be inputted. 
The value/s represents different things depending on the option chosen for {it:inference}. {p_end}

{dlgtab:Optional}

{phang}
{opt measure(or/rr/rd/nostandard/dor/ss)} specifies the outcome measure used in the meta-analysis to pool the results. The odds ratio ({it:or}), relative risk ({it:rr}), 
risk difference ({it:rd}) and unstandardised mean difference ({it:nostandard}) can only be used when simulating a new clinical study. The diagnostic odds ratio ({it:dor}) 
and sensitivity and specificity ({it:ss}) can only be used when simulating a new diagnostic accuracy study. The default for a clinical {opt type} study with 4 variables entered 
into the {it: varlist} is relative risk ({it:rr}, the default for a clinical {opt type} study with 6 variables entered 
into the {it: varlist} is unstandardised mean difference ({it:nostandard} and the default for a diagnostic {opt type} study is sensitivity and specificity ({it:ss}). {p_end}

{phang}
{opt inference(ciwidth/pvalue/lci/uci)} defines the approach to inference used to calculate power. The default is the confidence 
interval width ({it:ciwidth}). This counts the number of times that the confidence interval width of the estimate/s from the updated meta-analysis 
(i.e. with the simulated study(ies) included)
is less than the specified value/s. This option can be used regardless of the measure of accuracy. Two other approaches to inference available are 
{it:lci} and {it:uci}. These will count the number of times that the lower or upper confidence interval is higher or lower than a given value respectively. The {it:lci} 
option can be used regardless of the measure of accuracy. However, the {it:uci} option is currently only available when working with clinical trial data 
and not diagnostic data. A final option only available when using clinical trial data is the {it:pvalue}. This counts the number of times that a p-value 
is significant to a specified level. When using sensitivity and specificity two values may be inputted into {it:pow} for {it:ciwidth} and {it:lci}.
This will instruct the program to count the number of times that the confidence interval widths for both sensitivity and specificity are less than
their respective specified values. These must be given in the order sensitivity and specificity to be calculated correctly. In order to use the 
{it:ciwidth} or {it:lci} options for just sensitivity or just specificity the {it:sos} option should be used in addition to this option. {p_end}

{phang}
{opt p(real)} if simulating a new clinical study then this is the estimated event rate in the control group in the new study. When simulating a new diagnostic study 
this is the estimated probability of being diseased given a positive result in the new study. When this option is not specified by the user, the program will 
calculate this value by averaging the probabilities across the studies included in the dataset memory. Note that {opt p} is only relevant in the diagnostic framework
when using the diagnostic odds ratio ({it: dor}) as the option in {opt measure}.  {p_end}

{phang}
{opt r(real)} is the ratio of patients in the control group to the treatment group when simulating a new clinical study. When simulating a new diagnostic accuracy 
study this is the ratio of diseased to healthy people if using sensitivity and specificity and the ratio of positive to negative results if using the DOR 
(default 1). {p_end}

{phang}
{opt studies(integer)} specifies the number of new studies to be simulated (default 1). 
When more than one are specified they are all assumed to have the same sample size. {p_end}

{phang}
{opt model(fixed/fixedi/random/randomi/bivariate)} defines the type of model used to meta-analyse the pre-existing data. The default is the fixed effect
 Mantel-Haenszel method ({it:fixed}) unless the outcome measure is the nonstandardised mean difference in which case the default is the inverse variance method ({it:fixedi}).
 The ({it:fixedi}) option specifies a fixed effect model using the inverse variance method.  The ({it:random}) 
 option uses the random effect DerSimonian & Laird method, taking the estimate for heterogeneity from the Mantel-Haenszel method. The ({it:randomi}) option
 specifies a random effects model using the method of DerSimonian and Laird, with the estimate of heterogeneity being taken from the inverse-variance 
 fixed-effect model. All of the above options call on the {helpb metan} command within the program. The final option is the bivariate random effects 
 model ({it:bivariate}). This method calls on a combination of the {helpb metandi} and {helpb midas} commands. It may only be specified 
 when simulating a new diagnostic accuracy study. {p_end}

{phang}
{opt npow(numlist)} recalculates the power using a newly specified value for the same {it:inference} without having to re-run the whole program. Instead, it 
uses the data that is stored in temppow2 and allows alternative approaches to inference to be explored. This is particularly valuable when the required simulation time is lengthy. {p_end}

{phang}
{opt ci(real)} specifies the width of the confidence interval for the corresponding power estimate (default 95%). {p_end}

{phang}
{opt dist(normal/t)} specifies the distribution of effect sizes used to sample a value from in order to simulate a new study(ies). 
The default for the ({it:random}) and ({it:randomi}) is a predictive distribution based on the t-distribution ({it:t}) allowing 
for heterogeneity between studies (and the uncertainty in the heterogeneity). 
The default for all other models is the ({it:normal}) distribution based on the mean and variance entered in {opt es} and {opt var}. {p_end}

{phang}
{opt ind} instructs the program to calculate the power for the newly simulated study on its own in addition to the newly updated meta-analysis. {p_end}

{phang}
{opt nip(integer)} specifies the number of integration points used for quadrature when the bivariate model is selected. Higher values should result in greater accuracy but typically at 
the expense of longer execution times (see {help metandi##rhsp:Rabe-Hesketh, Skrondal, and Pickles 2005}, app. B). {p_end}

{phang}
{opt sos(sens/spec)} used in addition to the {it:inference} option this specifies whether inferences are focused on sensitivity or specificity when using {it:ciwidth} 
or {it:lci} as inference options. The default option is to use sensitivity. If {opt sos} is not specified then the inferences are based on both the sensitivity and specificity and two values should be entered for {opt pow}. {p_end}

{phang}
{opt graph(lowess/connected/overlay)} allows the user to choose the type of line used to connect the specific estimates of power at the specified sample sizes. 
The default option is a {it:connected} graph which plots each point and connects them with a line. The other options are a {it:lowess} plot, which plots a smoothed 
line to the specific points, and an {it:overlay} plot, which plots both the points and the lowess curve. Since power is estimated through simulation, there is sampling 
error in each estimate which will decrease with the number of simulations specified (but also increase evaluation time). Thus smoothing may be desirable if several different 
but inaccurate estimates are considered. The lowess line should be similar to the connected option for larger simulations. {p_end}

{phang}
{opt noci} prevents the program from plotting confidence intervals (indicating the sampling error in the estimation of power at specified sample sizes) on the graph. {p_end}

{phang}
{opt regraph} allows the user to re-graph the power curves with alternative graph options without having to run the simulations for the specified range of sample sizes again. {p_end}

{phang}
{opt level} specifies the confidence level, as a percentage, for the individual study and pooled confidence intervals. This is the level that is given in the
{helpb metan}, {helpb metandi} and {helpb midas} commands when called on to meta-analyses the current data set. The default is level(95). {p_end}


{title:Examples}

{pstd} Fixed effect Mantel-Haenszel method meta-analysis of clinical trial data using the odds ratio outcome for sample sizes ranging from 10 to 1010 in both the control group and the
treatment group of the new study (in increments of 100) and using a p-value of 0.05 for the hypothesis test that the pooled treatment effect is different from 0
 to calculate power through 100 iterations for each sample size (i.e. power is based on the proportion os the simulations in which the p-value for the treatment effect
 being different from 0 is less than 0.05). Note that the program will plot the power curve against the total sample size for the treatment and control groups combined. {p_end}

{phang}{cmd:. metapowplot e_trt ne_trt e_ctrl ne_ctrl, nit(100) start(10) step(100) stop(1010) measure(or) model(fixed) type(clinical) pow(0.05) inference(pvalue)}{p_end}


{pstd} Bivariate random effects model for combining diagnostic test accuracy data is used. Both sensitivity and specificity are considered for inferences purposes
for sample sizes ranging from 100 to 5000 (in steps of 100) in both the diseased group and the healthy group of the new study and using confidence interval 
widths of 0.2 and 0.1 for sensitivity and specificity respectively to calculate power through 1000 iterations (i.e. the width of each confidence interval 
has to be less than these values for the meta-analysis to be considered "significant"). {p_end}

{phang}{cmd:. metapowplot TP FP FN TN, nit(1000) start(100) step(100) stop(5000) measure(ss) model(bivariate) type(diagnostic) pow(0.2 0.1) inference(ciwidth)}{p_end}


{pstd}Unstandardised mean difference comparing exercise to no treatment in patients with chronic back pain (Ferreira et al. 2012). We investigate the power of the updated meta-analysis when comparing the lower 
confidence interval to a reduction in pain of 20 points. We vary the sample size of each arm of the new study from 50 to 550 patients in steps of 100.{p_end}

{phang}{cmd:. use http://fmwww.bc.edu/repec/bocode/m/metapow_eg1}{p_end}
{phang}{cmd:. metapowplot nrxpain rxmeanpain rxsdpain ncomppain compmeanpain compsdpain, nit(100) type(clinical) measure(nostandard) model(random) pow(-20) inference(lci) start(50) stop(550) step(100) graph(lowess)}{p_end}
{phang}{it:({stata "metapow_ploteg1":click to run})}{p_end}


{title:Authors}

{pstd}Michael J. Crowther, University of Leicester, United Kingdom. Email: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}.{p_end}

{pstd}Sally R. Hinchliffe, University of Leicester, United Kingdom. Email: {browse "mailto:srh20@le.ac.uk":srh20@le.ac.uk}.{p_end}

{pstd}Alison Donald, University of Leicester, United Kingdom.

{pstd}Alex J. Sutton, University of Leicester, United Kingdom. Email: {browse "mailto:ajs22@le.ac.uk":ajs22@le.ac.uk}.{p_end}


{title:References}

{phang}Hinchliffe S, Crowther MJ, Phillips RS, Sutton AJ. Using meta-analysis to inform the design of subsequent studies of diagnostic test accuracy (Submitted) {p_end}

{phang}Ferreira ML, Herbert RD, Crowther MJ, Verhagen A, Sutton AJ. When is another clinical trial justified? (Submitted){p_end}

{phang}Sutton AJ, Cooper NJ, Jones DR, Lambert PC, Thompson JR, Abrams KR. Evidence-based sample size calculations based upon meta-analysis. {it:Statistics in Medicine} 2007; 26:2479-2500.{p_end}


{title:Also see}

{psee}
Online:  {helpb metasim}, {helpb metapow}
{p_end}

