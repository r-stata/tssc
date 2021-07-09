{smcl}
{* version 1.2.8 01oct2018}{hline}
help for {hi:metamiss2} command
{hline}

{title:Title}

{p 4 4 2}
Accounting for missing outcome data in meta-analysis


{title:Description}

{p 4 4 1}
Missing outcome data are common in randomized controlled trials. 
If they are ignored then the estimated treatment effects might be biased.
Meta-analysts usually assume that the missing data problem has been solved at the trial level and proceed to an available case analysis.
This is equivalent to a missing at random assumption (MAR). 
However, if reasons for missingness are related to the actual outcome of the trials,
then data are missing not at random (MNAR) and ignoring missing data may lead to a biased summary estimate.   

{p 4 4 1}
Models that quantify the degree of departure from the MAR assumption are available for both binary and continuous outcome data. 
These models relate the mean outcome in the missing data to the mean of the observed data for each group through informative missingness parameters (IMPs). 
Either the IMPs are informed by expert opinion, or a sensitivity analysis is conducted to evaluate how sensitive results are to different values of the IMPs. 
Different assumptions for the missing pattern are possible by defining 
the mean and the variance of the IMP for each study group, and their covariance across study groups. 

{p 4 4 1}
For continuous data, the {cmd:metamiss2} command allows two 
definitions of the IMP: the informative missingness difference of means (IMDOM) 
or the informative missingness ratio of means (IMROM) 
{help metamiss2##Mavridis2015:(Mavridis et al, 2015)}. 
For binary data, the IMP is the informative missingness odds ratio 
{help metamiss2##White2008a:(White et al, 2008a)}.

{p 4 4 1}
The models are fitted using a two-step estimation procedure {help metamiss2##Chaimani2018:(Chaimani et al, 2018)}. 
At the first step the command estimates the study-specific relative effects using both the observed and missing participants.
At the second step it calls {helpb metan} (for standard 
pairwise meta-analysis) or {helpb network meta} (for network meta-analysis) 
to obtain the summary effects from the 'adjusted' study-specific relative effects. 

{p 4 4 1}
Using {cmd:metamiss2} typically has two impacts. 
Firstly, the point estimates are changed; this primarily reflects non-zero means of the IMPs.
Secondly, the variances are increased, so that less relative weight is assigned to trials with high or unbalanced missing rates: this primarily reflects non-zero standard deviations of the IMPs.


{title:Syntax}

{p 8 17 2}
{cmd:metamiss2} 
[{it:varlist}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,} 
{cmdab:impt:ype(}{it:imdom|logimrom}{cmd:)}
{cmdab:impm:ean(}{it:exp exp...exp}{cmd:)}
{cmd:impsd(}{it:exp exp...exp}{cmd:)}
{cmdab:impc:orrelation(}{it:real|matrix}{cmd:)}
{cmd:fixed}
{cmd:tau2(}{it:string}{cmd:)}
{cmdab:inc:onsistency}
{cmd:md}
{cmd:smd}
{cmd:rom}
{cmd:or}
{cmd:rr}
{cmd:rd}
{cmdab:sdp:ool(}{it:on|off}{cmd:)}
{cmdab:t:aylor}
{cmdab:b:ootstrap}
{cmd:reps(}{it:integer}{cmd:)}
{cmd:seed(}{it:integer}{cmd:)}
{cmdab:comp:are(}{it:string}{cmd:)}
{cmdab:sens:itivity}
{cmd:nokeep}
{cmd:nometa}
{cmdab:varch:ange}
{cmd:netplot}
{cmdab:trtlab:els(}{it:string}{cmd:)}
{cmdab:netplotref:erence(}{it:string}{cmd:)}
{cmdab:netplotopt:ions(}{it:intervalplot_options}{cmd:)}
{cmdab:metanopt:ions(}{it:meta_options}{cmd:)}
{cmdab:networkopt:ions(}{it:network_meta_options}{cmd:)}]

{p 4 4 2}
where {it:varlist} is:

{p 6 8 2}- for pairwise meta-analysis with continuous outcome data: {it:nE} {it:mE} {it:yE} {it:sdE} {it:nC} {it:mC} {it:yC} {it:sdC} - 
variables containing the numbers of observed and missing participants, 
the mean and standard deviation of the observed data in experimental and control group respectively. 

{p 6 8 2}- for pairwise meta-analysis with binary outcome data: 
{it:rE} {it:fE} {it:mE} {it:rC} {it:fC} {it:mC} - variables containing the numbers of successes and failures in the observed data and the number 
of missing participants in experimental and control group respectively. 

{p 6 8 2}- for network meta-analysis:
{it:varlist} is not used but the data must have been prepared using the {helpb network setup} command in the {bf:augmented} format (see the exmple).


{title:Options for specifying the IMPs}

{phang}
{cmdab:impt:ype(}{it:imdom|logimrom}{cmd:)} specifies the type of IMP for continuous outcome data. The default is {it:imdom}. This option is not needed for 
binary outcome data since the only available IMP is {it:logimor}. For details on the definition of IMDOM, logIMROM and logIMOR see the {bf:Description}
above, {help metamiss2##Mavridis2015:(Mavridis et al, 2015)} and {help metamiss2##White2008a:(White et al, 2008a)}.

{phang}
{cmdab:impm:ean(}{it:exp exp...exp}{cmd:)} specifies the mean of the assumed (normal) distribution for IMP. The default value is {it:0} in all groups.
If one value is given, it is the mean for all groups. For pairwise meta-analysis, if two values are given, they are the means for the experimental and control group.  
For network meta-analysis, if {it:T} values are given (with {it:T} the total number of treatments), they are the means for the reference treatment and the non-reference 
treatments in the order shown in {helpb network setup}. Each {it:exp} may be a single value corresponding to all studies or a variable containing study-specific values. 

{phang}
{cmd:impsd(}{it:exp exp...exp}{cmd:)} specifies the correlation of the IMP between the different groups. The default value is 0.  
A common correlation value for all pairs of treatments or the full {it:TxT} correlation matrix (only for network meta-analysis) can be specified.

{phang}
{cmdab:impc:orrelation(}{it:real|matrix}{cmd:)} specifies the correlation of the IMP between the different groups. The default value is {it:0}.
A common correlation value for all pairs of treatments or the full correlation matrix (only for network meta-analysis) can be specified.

{phang}
{cmdab:comp:are(}{it:string}{cmd:)} specifies a second assumption for IMP to be compared to the primary analysis. String may include {it:impmean()}, {it:impsd()}
and {it:impcorrelation()}.

{phang}
{cmdab:sens:itivity} specifies a sensitivity analysis for the IMP assuming a range of different standard deviations for its distribution with {it:impmean(0)}
or a different specified {it:impmean()}.


{title:Options for continuous data}

{phang}
{cmd:smd} specifies standardized mean difference as the measure of interest ({bf:the default} for continuous data).

{phang}
{cmd:md} specifies mean difference as the measure of interest.

{phang}
{cmd:rom} specifies ratio of means as the measure of interest. 

{phang}
{cmdab:sdp:ool(}{it:on|off}{cmd:)} specifies whether the standard deviation is pooled across groups in computing variances.
Following {helpb metan}, the default option for mean difference and ratio of means is {it:sdpool(off)} and for standardize mean difference is {it:sdpool(on)}.


{title:Options for binary data}

{phang}
{cmd:rr} specifies risk ratio as the measure of interest ({bf:the default} for binary data). 
Note that in this case the IMP is the logIMOR.

{phang}
{cmd:or} specifies odds ratio as the measure of interest. 
Note that in this case the IMP is the logIMOR.

{phang}
{cmd:rd} specifies risk difference as the measure of interest. 
Note that in this case the IMP is the logIMOR.


{title:Estimation options}

{phang}
{cmdab:t:aylor} specifies that Taylor-series approximation is used to integrate over the distribution of IMP ({bf:the default}).

{phang}
{cmdab:b:ootstrap} specifies that Monte Carlo (bootstrap) is used to integrate over the distribution of IMP.

{phang}
{cmd:reps(}{it:integer}{cmd:)} specifies the number of simulations under the {it:bootstrap} method. The default is {it:10000}

{phang}
{cmd:seed(}{it:integer}{cmd:)} specifies the initial value of the random-number seed for {it:bootstrap} method. The default is {it:0}.
See {helpb set seed} for more details.


{title:Meta-analysis options}

{phang}
{cmd:fixed} specifies the use of the fixed-effect model instead of the default random-effects model.

{phang}
{cmd:tau2(}{it:string}{cmd:)} specifies the use of an estimator other than the DerSimonial-Laird estimator for heterogeneity. 
This option is available only for pairwise meta-analysis and valid estimators are the available estimators in {helpb metaan}.

{phang}
{cmdab:inc:onsistency} specifies the use of an inconsistency model for the case of network meta-analysis instead of the consistency model which is the default.

{phang}
{cmd:nometa} skips the conduct of standard pairwise or network meta-analysis after estimating the 'adjusted' study-specific effect sizes and variances.

{phang}
{cmdab:metanopt:ions(}{it:meta_options}{cmd:)} are any valid options for {helpb metan}.

{phang}
{cmdab:networkopt:ions(}{it:network_meta_options}{cmd:)} are any valid options for {helpb network meta}.


{title:Output options}

{phang}
{cmd:nokeep} specifies that study-specific 'adjusted' effect sizes and standard errors/variances will be dropped from the dataset. 
By default, these estimates are stored as extra variables; for pairwise meta-analysis with names {it:_ES}, {it:_seES} (as in {it:metan}) and in network meta-analysis with prefix {it:_imp_}.

{phang}
{cmdab:varch:ange} specifies that the 'adjusted' study-specific relative effects and variances are stored in the dataset replacing the respective values obtained
from the {helpb network setup} command. This means that the current assumptions about the missing data will also apply to future analyses of the data.

{phang}
{cmd:netplot} specifies that a forest plot with the relative effects from network meta-analysis will be drawn. The same forest plot can be produced by running the {helpb intervalplot} 
command after {cmd:metamiss2} for a network meta-analysis. Note that for the case of standard pairwise meta-analysis a forest plot is produced by default. 

{phang}
{cmdab:trtlab:els(}{it:string}{cmd:)} specifies the labels of the treatments for the case of network meta-analysis separated with spaces. These labels will be used in {it:netplot}.
The first label should correspond to the reference treatment and the other treatment should be given in the numerical/alphabetical order of their codes in the data.
See also {helpb intervalplot}.  

{phang}
{cmdab:netplotref:erence(}{it:string}{cmd:)} specifies a reference treatment to be used as reference in {it:netplot} so as only a subset of the relative effects from the network 
meta-analysis (i.e. every treatment vs. that reference) will be given in the forest plot. The treatment specified here can be different from the reference treatment of the analysis.
See also {helpb intervalplot}. 

{phang}
{cmdab:netplotopt:ions(}{it:intervalplot_options}{cmd:)} specifies any additional valid option allowed in {helpb intervalplot}.


{title:Examples}

{pstd}{bf:1. Pairwise meta-analysis, binary data}{p_end}

{pstd}- Load the data comparing the effectiveness of haloperidol against placebo for the treatment of schizophrenia {help metamiss2##Loy2006:(Joy, 2006)}:{p_end}

{phang}{cmd:. use "http://clinicalepidemio.fr/Stata/haloperidol.dta", clear}{p_end}
{phang}  {stata "use http://clinicalepidemio.fr/Stata/haloperidol.dta, clear":(click to run)}{p_end}

{pstd}- Assume that the {it:logIMOR} in the haloperidol group has mean 0 and SD 1, while the logIMOR in the placebo group has mean -1 and SD 1. 
This expresses the belief that for placebo the response in missing participants is probably worse than in observed participants:{p_end}

{phang}{cmd:. metamiss2 rh fh mh rp fp mp, impmean(0 -1) impsd(1) metanopt(lcols(author))}{p_end}
{phang}  {stata "metamiss2 rh fh mh rp fp mp, impmean(0 -1) impsd(1) metanopt(lcols(author))":(click to run)}{p_end}

{pstd}- Next assume that the {it:logIMORs} are positively correlated between the two intervention groups, with correlation {it:rho=0.5}:{p_end} 
{phang}{cmd:. metamiss2 rh fh mh rp fp mp, impmean(0 -1) impsd(1) impc(0.5) b metanopt(lcols(author))}{p_end}
{phang}  {stata "metamiss2 rh fh mh rp fp mp, impmean(0 -1) impsd(1) impc(0.5) b metanopt(lcols(author))":(click to run)}{p_end}

{pstd}{bf:2. Pairwise meta-analysis, continuous data}{p_end}

{pstd}- Load the data comparing the effectiveness of mirtazapine versus placebo for major depression {help metamiss2##Cipriani2009:(Cipriani, 2009)}:{p_end}

{phang}{cmd:. use "http://clinicalepidemio.fr/Stata/mirtazapine.dta", clear}{p_end}
{phang}  {stata "use http://clinicalepidemio.fr/Stata/mirtazapine.dta, clear":(click to run)}{p_end}

{pstd}- Assume a systematic departure from the MAR assumption where for the mirtazapine group {it:IMDOM=-0.5} with {it:sd(IMDOM)=1} and for placebo 
{it:IMDOM=1} with {it:sd(IMDOM)=1.5}. This means that probably placebo performed worse in the missing participants than in the observed, 
whereas mirtazapine performed worse in the observed participants. Assume also that {it:IMDOMs} are correlated between the two groups with {it:rho=0.5} and compare the results with ACA:{p_end}

{phang}{cmd:. metamiss2 nm mm ym sdm np mp yp sdp, impmean(-0.5 1) impsd(1 1.5) impcorr(0.5) compare(impmean(0) impsd(0)) md metanopt(lcols(study))}{p_end}
{phang}  {stata "metamiss2 nm mm ym sdm np mp yp sdp, impmean(-0.5 1) impsd(1 1.5) impcorr(0.5) compare(impmean(0) impsd(0)) md metanopt(lcols(study))":(click to run)}{p_end}

{pstd}- Change the IMP parameter and run a sensitivity analysis with {it:IMROM=1} on a range of different values for {it:sd(logIMROM)}:{p_end}

{phang}{cmd:. metamiss2 nm mm ym sdm np mp yp sdp, md sensitivity b imptype(logimrom)}{p_end}
{phang}  {stata "metamiss2 nm mm ym sdm np mp yp sdp, md sensitivity b imptype(logimrom)":(click to run)}{p_end}

{pstd}{bf:3. Network meta-analysis}{p_end}

{pstd}- Load the data that comprise a network of trials comparing the effectiveness of 9 antidepressants {help metamiss2##Cipriani2009:(Cipriani, 2009)}:{p_end}

{phang}{cmd:. use "http://clinicalepidemio.fr/Stata/antidepressants.dta", clear}{p_end}
{phang}  {stata "use http://clinicalepidemio.fr/Stata/antidepressants.dta, clear":(click to run)}{p_end}

{pstd}- Prepare the data in the "augmented" format:{p_end}

{phang}{cmd:. network setup y sd n, trt(t) stud(id) nmiss(m)}{p_end}
{phang}  {stata "network setup y sd n, trt(t) stud(id) nmiss(m)":(click to run)}{p_end}

{pstd}- Run the ACA:{p_end}

{phang}{cmd:. metamiss2}{p_end}
{phang}  {stata "metamiss2":(click to run)}{p_end}

{pstd}- Explore the impact of alternative assumptions by incorporating IMPs in the analysis. Consider three groups of treatments with {it:IMDOM=1,-1 or 0} but {it:sd(IMDOM)=1}
for all treatments in the network. Also, allow the correlation of IMPs to differ across studies by specifying the full 9x9 correlation matrix:{p_end} 
{phang}{cmd:mat C=J(9,9,0.5)+0.5*I(9)}{p_end}
{phang}{cmd:forvalues i=4/8}{{p_end}
{p 8 8 8}{cmd:mat C[`i',`=`i'+1']=0.2}{p_end}
{p 8 8 8}{cmd:mat C[`=`i'+1',`i']=0.2}{p_end}
{phang}{cmd:}}{p_end}
{phang}{cmd:mat li C}{p_end}
{phang}  {stata "metamiss2_corr_example":(click to run)}{p_end}

{phang}{cmd:. metamiss2, impmean(1 1 -1 -1 0 1 0 1 -1) impsd(1) impcorr(C) b}{p_end}
{phang}  {stata "metamiss2, impmean(1 1 -1 -1 0 1 0 1 -1) impsd(1) impcorr(C) b":(click to run)}{p_end}

{title:Authors}

{p 4 4 2}
Anna Chaimani, Paris Descartes University, Paris, France{break}
{browse "mailto:anna.chaimani@parisdescartes.fr":anna.chaimani@parisdescartes.fr}

{p 4 4 2}
Ian R. White, MRC Clinical Trials Unit at UCL, London, UK{break}
{browse "mailto:ian.white@ucl.ac.uk":ian.white@ucl.ac.uk}


{title:Acknowledgements}

{p 4 4 2}
Drs Dimitris Mavridis and Georgia Salanti provided very helpful comments on earlier versions of the command.


{title:References}

{phang}{marker Chaimani2018}Chaimani A, Mavridis D, Higgins JPT, Salanti G, White IR. Allowing for informative missingness in
aggregate data meta-analysis with continuous or binary outcomes: Extensions to metamiss. The Stata Journal 2018; 18(3):716-740.
({browse "https://www.stata-journal.com/article.html?article=st0540":link to paper})

{phang}{marker Cipriani2009}Cipriani A, Furukawa TA, Salanti G, Geddes JR, Higgins J, Churchill R et al. Comparative efficacy and acceptability of
12 new-generation antidepressants : a multiple-treatments meta-analysis. Lancet 2009; 373:746-758.
({browse "http://www.ncbi.nlm.nih.gov/pubmed/19185342/":link to paper})

{phang}{marker Higgins2008}Higgins JPT, White IR, Wood AM. 
Imputation methods for missing outcome data in meta-analysis of clinical trials. 
Clin Trials 2008, 5: 225-239.
({browse "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2602608/":link to paper})

{phang}{marker Joy2006}Joy CB, Adams CE, Lawrie SM. Haloperidol  versus placebo  for  schizophrenia.
Cochrane Database Syst Rev 2006; 4: CD003082.
({browse "http://www.ncbi.nlm.nih.gov/pubmed/17054159/":link to paper})

{phang}{marker Mavridis2015}Mavridis D, White IR, Higgins JPT, Cipriani A, Salanti G. 
Allowing for uncertainty due to missing continuous outcome data in pairwise and network meta-analysis.
Stat Med 2015, 34: 721-741. 
({browse "http://onlinelibrary.wiley.com/doi/10.1002/sim.6365/abstract":link to paper})

{phang}{marker White2008a}White IR, Higgins JPT, Wood AM. Allowing for uncertainty due to missing data in meta-analysis-Part 1: two-stage methods. Stat Med 2008, 27: 711-727.
({browse "http://www.ncbi.nlm.nih.gov/pubmed/17703496":link to paper})

{phang}{marker White2008b}White IR, Welton NJ, Wood AM, Ades AE, Higgins JPT. Allowing for uncertainty due to missing data in meta-analysis-Part 2: hierarchical models. Stat Med 2008, 27: 728-745.
({browse "http://www.ncbi.nlm.nih.gov/pubmed/17703502":link to paper})


{title:See also}

{helpb metan}, {helpb metamiss}, {helpb network}, {helpb network graphs}.

{phang} 
