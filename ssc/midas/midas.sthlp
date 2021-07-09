 

{smcl}
{* *! version 2.00 21ddecember2008}{...}
{hline}
help for {hi:midas} {right: (Ben Adarkwa Dwamena)}

{hline}

{title:midas -- Meta-analytical Integration of Diagnostic Accuracy Studies}

{title:Syntax}

{p 8 18 2}
{opt midas}
{it:varlist} 
[{opt if} {it:exp}]
[{opt in} {it:range}]
[{opt ,} 
{options} *] 
 
{p 4 4 2}
{opt by}{it:...}{cmd ::} may be used with {help midas}; see help {help by}.


{title:Description}

{pmore}
{help midas} is a comprehensive program of statistical and graphical routines
for undertaking meta-analysis of diagnostic test performance in Stata. 

{pmore}
Primary data synthesis is performed within the bivariate mixed-efects binary
regression modeling framework. Model specification, estimation and prediction
are carried out with {help xtmelogit} in Stata release 10(Statacorp, 2007) 

{pmore}
Using the model estimated coefficients and variance-covariance matrices,
{help midas} calculates summary operating sensitivity and specificity 
(with confidence and prediction contours in SROC space), summary likelihood
and odds ratios. Global and relevant test performance metric-specific 
heterogeneity statistics are provided. 
{help midas} facilitates extensive statistical and graphical data 
synthesis and exploratory analyses of heterogeneity, covariate effects,
publication bias and influence. 

{pmore}
Bayes' nomograms and likelihood ratio matrices may be obtained and used to
guide clinical decision-making. 

{pmore}
The minimum required varlist is the data from contingency tables of test results. 
The user provides the data in a rectangular array containing variables for 
the 2x2 elements a, b, c, and d:
{p_end}

           2x2    +{hline 21}+
          table   |        Test         |
        +{hline 9}+{hline 10}+{hline 10}+    where:
        | Truth   | Positive | Negative |       a = true positives,
        +{hline 9}+{hline 10}+{hline 10}+       b = false positives,
        | Case    |    a     |    c     |       c = false negatives,
        +{hline 9}+{hline 10}+{hline 10}+       d = true negatives.
        | Noncase |    b     |    d     |
        +{hline 9}+{hline 10}+{hline 10}+


{pmore}
Each data file row contains the 2x2 data for one observation (i.e., study). 
{opt id(varname)} {opt year(varname)}, if provided , is concatenated to create
a study identification variable. Default uses observation number for id.

{pmore}
The varlist MUST contain variables for a, b, c, and d in that order.

{pmore}
Note: {help midas} requires release 10 to implement modeling with {help xtmelogit}



{pmore}
User should install (if not installed) {help metan} and {help mylabels}
for either estimator and also {help gllamm} if using release 9.

 

{dlgtab:Modeling}
 
{pmore}
{opt nip} specifies the number of integration points used for maximum likelihood
estimation based on adaptive gaussian quadrature.  Default is set at 1 for 
{opt midas} even though the default in {help xtmelogit} is 7. 
Higher values improve accuracy at the expense of execution times.
 
{pmore}
Using {help xtmelogit} with {opt nip(1)}, model will be estimated by
Laplacian approximation. This decreases substantially computational
time and yet provides reasonably valid fixed effects estimates. 
It may, however, produce biased estimates of the variance components.

{pmore}
{opt eb:pred(for|roc)} generates a forest plot or roc curve of empirical Bayes versus observed estimates of sensitivity and specificity.  

{pmore}

{opt modchk(gof|bvn|inf|out|all)} provides graphical model checking capabilities;
quantile plot of residual-based goodness-of fit; Chi-squared probability plot of 
squared Mahalanobis distances for assessment of the bivariate normality assumption; 
spikeplot for checking for particularly influential observations using Cook's distance;
scatterplot for checking for outliers using standardized predicted random effects (standardized level-2 residuals);
and a composite graphic of all four plots respectively.

{dlgtab:Quality_Assessment}

{pmore}
{opt qtab(varlist)} creates, using optional varlist of study quality items
(presence=1, other=0) a table showing frequency of methodologic quality items.  

{pmore}
{opt qbar(varlist)} creates, combined with optional varlist of study 
quality items (presence=1, other=0) calculates study-specific quality scores
and plots a bargraph of methodologic quality.

{pmore}
{opt qlab} may be combined with {opt qtab} or {opt qbar} to use
variable labels for table and bargraph of methodologic items.  

{dlgtab:Reporting}

{pmore}
{opt res:ults(all)} provides summary statistics for all performance
indices, group-specific between-study variances, likelihood rato
test statistics and other global homogeneity tests.

{pmore}
{opt res:ults(het)} provides group-specific between-study variances,
likelihood rato test statistics and other global homogeneity tests.

{pmore}
{opt res:ults(sum)} provides summary statistics for all performance indices

{pmore}
{opt tab:le(dss|dlr|dlor)} will create a table of study specific
performance estimates with measure-specific summary estimates and results
of homogeneity (chi_squared) and inconsistency(I_squared) tests. 
{opt dss}, {opt dlr} or {opt dlor} represent the paired performance
measures sensitivity/specificity, positive/negative likelihood ratios
and diagnostic score/odds ratios.

{dlgtab:Exploratory Graphics}

{pmore}
{opt bivbox} implements a two-dimensional analogue of the boxplot for
univariate data similar to the bivariate boxplot
(Goldberg and Iglewicz,1992). It is used to assess distributional
properties of sensitivity versus specificity and for indentifying
possible outliers. 

{pmore}
{opt chi:plot} creates a chiplot (Fisher & Switzer, 1985, 2001) for
judging whether or nor the paired performance indices are independent
by augmenting the scatterplot with an auxiliary display. In the case
of independence, the points will be concentrated in the central region,
in the horizontal band indicated on the plot. 
 
{dlgtab:Publication Bias}

{pmore}
{opt pubb:ias} When this option is invoked, midas performs linear regression
of log odds ratios on inverse root of effective sample sizes as a test 
for funnel plot asymmetry in diagnostic metanalyses. A non-zero slope coefficient
is suggestive of significant small study bias(pvalue < 0.10). In a meta-analysis, the funnel plot can be used to investigate whether all
studies come from a single population and to search for publication bias. 


{dlgtab:Forest Plots}

{pmore}
{opt id(varlist)}  provides a label for studies allowing for up to four variables.

{pmore}
{opt bfor:est(dss|dlr|dlor)} creates paired summary graphs with study-specific(box) and
overall(diamond) point estimates and confidence intervals for each performance
index pair using graph combine. Confidence intervals lines are allowed to extend
between 0 and 1000 beyond which they are truncated and marked by a leading arrow.

{pmore}
{opt ufor:est(dss|dlr|dlor)} creates univariate summary graphs with study-specific(box) and
overall(diamond) point estimates and confidence intervals for each performance
index pair using graph combine. Confidence intervals lines are allowed to extend
between 0 and 1000 beyond which they are truncated and marked by a leading arrow.

{pmore}
{opt ford:ata}  adds study-specific performance estimates and 95% CIs to right y-axis.

{pmore}
{opt fors:tats}  adds heterogeneity statistics below summary point estimate.


{dlgtab:Heterogeneity}

{pmore}
{opt galb(dss|dlr|dlor)}  The standardized effect measure (e.g. for lnDOR, lnDOR/precision) is plotted (y-axis) against
the inverse of the precision(x-axis). A regression line that goes through the
origin is calculated, together with 95% boundaries (starting at +2 and -2 on the y-axis). 
Studies outside these 95% boundaries may be considered as outliers.

{pmore}
{opt reg:ars(varlist} combined with an optional varlist permits univariable metaregression
analysis of one or multiple dichotomous or continuous covariables. 

{dlgtab:ROC Curves}

{pmore}
{opt sroc(none|pred|conf|both)}  plots observed datapoints, summary operating sensitivity and
specificity in SROC space without or with either or both of confidence and prediction 
contours at default or specified confidence level.

{pmore}
{opt sroc(nnoc|pnoc|cnoc|bnoc)}  plots observed datapoints, summary operating sensitivity and
specificity without or with either or both of confidence and prediction 
contours at default or specified confidence level.No summary ROC curve is plotted.


{pmore}
{opt roc:plane} plots observed data in receiver operating characteristic
space (ROC Plane) for visual assessment of threshold effect. 

{dlgtab: Probability Revision Options}

{pmore}
{opt fagan(#)} creates a plot showing the relationship between the prior probability specified by user over the range 0-1,
the likelihood ratio(combination of sensitivity and specificity), and posterior
test probability.

{pmore}
{opt pddam(0 1)} produces a line graph of post-test probalities versus
prior probabilities between 0 and 1 using summary likelihood ratios 

{pmore}
{opt lrm:atrix} creates a scatter plot of positive and negative likelihood
ratios with combined summary point. Plot is divided into quadrants based on
strength-of-evidence thresholds to determine informativeness of measured test.


{dlgtab:Miscellaneous Options}


{pmore}
{opt level()} specifies the significance level for statistical tests, confidence
contours, prediction contours and confidnce intervals.

{pmore}
{opt mscale()} affects size of markers for point estimates on forest plots.

{pmore}
{opt scheme(string)} permits choice of scheme for graphs. The default is s2color.

{pmore}
{opt texts:cale()} allows choice of text size for graphs especially regarding
labels for forest plots.

{pmore}
{opt zcf()} defines a fixed continuity correction to add in the case where a
study contains a zero cell. By default, {help midas} adds 0.5 to each cell of
a study where a zero is encountered for logit and log transformations, only to
calculate study-specific likelihood ratios and odds ratios. However, the 
{opt zcf()} option allows the use of other constants between 0 and 1.


{title: Remarks on test performance metrics:}

{pmore}
Sensitivity and specificity , diagnostic odds ratio and likelihood ratios with
 95% confidence intervals, are recalculated for each primary study from 
the contingency tables of true-positive [a], false-positive [b], false-negative
results [c], and true-negative [d]. 
 
{pmore}
A four-fold (two by two contingency) table comparing test results for a 
diagnostic/screening test is identical to a four-fold table comparing 
outcomes of an experimental application of an intervention
(Skupski, Rosenberg and Eglinton, 2002). 

{pmore}
For an interventional trial, the true positives are the experimental 
group with the monitored outcome present [a].The false positives are the control
group with the outcome present [b]. The false negatives are the experimental group
 with the outcome absent [c]. The true negatives are the control 
group with the outcome absent [d]. The expression for the relative risk 
in the experimental group {[a/ (a + c)]/ [b/ (b + d)]} is identical to 
the expression for the likelihood ratio for a positive test in an evaluation
 of a diagnostic or a screening methodology.
Similarly, the expression for the relative risk in the control group in an 
interventional trial is identical to the expression for the likelihood ratio
 for a negative test(Skupski, Rosenberg and Eglinton, 2002). 
The LRs indicate by how much a given test would raise or lower the 
probability of having disease. In order for diagnostic informativeness to be high,
 an LR of > 10 or < 0.1 would be required for a positive and negative test result,
 respectively. Moderate informational value can be achieved with LR values 
of 5-10 and 0.1-0.2; LRs of 2-5 and 0.2-0.5 have very small informational value. 

{pmore}
The diagnostic odds ratio of a test is the ratio of the odds of positivity 
in disease relative to the odds of positivity in the nondiseased 
(Glas, Lijmer, Prins, Bonsel and Bossuyt, 2003). The expression for the 
odds ratio (DOR) is (a × d)/(b × c). The value of a DOR ranges from 0 to infinity,
 with higher values indicating better discriminatory test performance. 
A value of 1 means that a test does not discriminate between patients 
with the disorder and those without it. Values lower than 1 point to improper 
test interpretation (more negative tests among the diseased).
 The diagnostic odds ratio (DOR) may be used as a single summary measure
 with the caveat that the same odds ratio may be obtained with different 
combinations of sensitivity and specificity (Glas, Lijmer, Prins, Bonsel and Bossuyt, 2003) 

{pmore}
The area under the curve (AUROC), obtained by trapezoidal integration, serves as a global measure of test performance. 
The AUROC is the average TPR over the entire range of FPR values. 
The following guidelines have been suggested for interpretation of intermediate AUROC values: 
low (0.5>= AUC <= 0.7), moderate (0.7 >= AUC <= 0.9), or high (0.9 >= AUC <= 1) accuracy (Swets, 1988). 



{title:Remarks on Meta-analytic Model:} 

{pmore}
Primarily, {help midas} uses an exact binomial rendition (Chu & Cole, 2006) of the bivariate mixed-effects regression model
developed by von Houwelingen(von Houwelingen, 1993, 2001) for treatment trial meta-analysis and modified for synthesis of 
diagnostic test data (Reitsma, 2005; Riley, 2006).

{pmore}
It fits a two-level model, with independent binomial distributions for the true positives and true negatives
conditional on the sensitivity and specificity in each study and a bivariate normal model for the {help f_logit:logit} 
transforms of sensitivity and specificity between studies.

{pmore}
The standard output of the bivariate model includes: mean logit sensitivity and specificity with their standard errors 
and 95% confidence intervals; and estimates of the between-study variability in logit sensitivity and specificity and 
the covariance between them. 

{pmore}
Based on these parameters, we can calculate other measures of interest such as the likelihood ratio for positive and 
negative test results, the diagnostic odds ratio, the correlation between logit sensitivity and specificity, 
several summary ROC linear regression lines based on either the regression of logit sensitivity on specificity,  
the regression of logit specificity on sensitivity, or an orthogonal regression line by minimizing the perpendicular distances. 
These lines can be transformed back to the originalROC scale to obtain a summary ROC curve. Summary sensitivity, specificity,
and the corresponding positive likelihood, negative likelihood and diagnostic odds ratios are drived as 
functions of the estimated model parameters; The derived logit estimates of sensitivity,  specificity and respective variances
are used to construct a hierarchical summary ROC curve.


{title:Remarks on assessment and exploration of heterogeneity:} 

{pmore}
Heterogeneity means that there is between study variation. Galbraith(radial) plot is used to visually identify outliers. 
To construct this plot, the standardized lnDOR = lnDOR/se is plotted (y-axis) against the inverse of the se (1/se) (x-axis). 
A regression line that goes through the origin is calculated, together with 95% boundaries (starting at +2 and -2 on the y-axis). 
Studies outside these 95% boundaries may be considered as outliers. 

{pmore}
Many sources of heterogeneity can occur: characteristics of the study population, variations in the study design 
(type of design, selection prodedures, sources of information, how the information is collected), different statistical methods, 
and different covariates adjusted for (if relevant) (Dinnes, 2005). Heterogeneity (or absence of homogeneity) of the results 
between the studies is assessed graphically by forest plots and statistically using the quantity I2 that describes the 
percentage of total variation across studies that is attributable to heterogeneity rather than chance (Higgins, 2003). 

{pmore}
I2 can be calculated from basic results as I2 = 100% x (Q - df)/Q, where Q is Cochran's heterogeneity statistic and 
df the degrees of freedom. (Higgins, 2003). Negative values of I2 are made equal to 0 so that I2 lies between 0% and 100%. 
A value of 0% indicates no observed heterogeneity, and values greater than 50% may be considered substantial heterogeneity. 
The main advantage of I2 is that it does not inherently depend on the number of the studies in the meta-analysis. 

{pmore}
Formal investigation of heterogeneity is performed by multiple univariable bivariate meta-regression models. 
Covariates are manipulated as  mean-centered continuous or as dichotomous (yes=1, no= 0) fixed effects. 
The effect of each covariate on sensitivity is estimated separately from that on specificity.
Metaregression is a collection of statistical procedures (weighted/unweighted linear, logistic regression) 
to assess heterogeneity, in which the effect size of study is regressed on one or several covariates, with a 
value defined for each study.


{title:Remarks on Publication bias:}

{pmore} 
Publication bias is produced when the published studies do not represent adequately all the studies carried out on a 
specific topic (Begg and Berlin). This bias may be caused by factors such as the trend to publish 
statistically significant (p < 0.05) or clinically relevant (high magnitude albeit non-significant) results. 
Other variables influencing publication bias (Song, 2002) are sample size (more in small studies), 
type of design, funding, conflict of interest, prejudice against an observed association, sponsorship. 

{pmore}
Publication bias is assessed visually by using a scatter plot (Light and Pillemer, 1984) of the inverse of the square root of the 
effective sample size (1/ESS1/2) versus the diagnostic log odds ratio(lnDOR) which should have a symmetrical funnel 
shape when publication bias is absent (Deeks, 2005). 

{pmore}
Separate funnel plots for sensitivity and specificity 
(after logit transformation) are unlikely to be helpful for detecting sample size effects, because 
sensitivities and specificities will vary due to both variability of threshold between the studies and 
random variability. Simultaneous interpretation of two related funnel plots and two tests for funnel plot 
asymmetry also presents challenges. Formal testing for publication bias may be conducted by a regression of 
lnDOR against 1/ESS1/2, weighting by ESS (Deeks, 2005), with P < .05 for the slope coefficient indicating significant asymmetry.


{title: Remarks on Clinical Application:}

{pmore}
The clinical or patient-relevant utility of diagnostic test is evaluated using the likelihood ratios to calculate
post-test probability based on  Bayes' theorem as follows (Jaeschke, 1994): 
Pretest Probability=Prevalence of target condition
 
{pmore}
Post-test probability= likelihood ratio x pretest probability/[(1-pretest probability) x (1-likelihood ratio)]

{pmore}
Assuming that the study samples are representative of the entire population, an estimate of the pretest 
probability of target condition is calculated from the global prevalence of this disorder across the studies. 

{pmore}
In this way, likelihood ratios are more clinically meaningful than sensitivities or specificities. 
This approach would be useful for the clinicians who might use the likelihood ratios generated from here to 
calculate the post-test probabilities of nodal disease based on the prevalence rates of their own practice population.  

{pmore}
Thus, this approach permits individualization of diagnostic evidence. 
This concept is depicted visually with Fagan's nomograms. When Bayes theorem is expressed in terms of log-odds, 
the posterior log-odds are linear functions of the prior log-odds and the log likelihood ratios. 
{opt fagan} plots an axis on the left with the prior log-odds, an axis in the middle representing the log likelihood ratio
and an axis on the right representing the posterior log-odds. Lines are then drawn 
from the prior probability on the left through the likelihood ratios in the center 
and extended to the posterior probabilities on the right.

{pmore}
The likelihood ratio matrix defines quadrants of informativeness based on established evidence-based thresholds:

{pmore}
{hi:Left Upper Quadrant}, Likelihood Ratio Positive > 10, Likelihood Ratio Negative <0.1: 
{hi:Exclusion & Confirmation}

{pmore}
{hi:Right Upper Quadrant}, Likelihood Ratio Positive >10, Likelihood Ratio Negative >0.1:
 {hi:Confirmation Only}

{pmore}
{hi:Left Lower Quadrant}, Likelihood Ratio Positive <10, Likelihood Ratio Negative <0.1:
{hi:Exclusion Only}

{pmore}
{hi:Right Lower Quadrant}, Likelihood Ratio Positive <10, Likelihood Ratio Negative >0.1:
{hi:No Exclusion or Confirmation}

	
{title:Examples}

{p 8 12 2}
{stata "use http://fmwww.bc.edu/repec/bocode/m/midas_example_data.dta":. use http://fmwww.bc.edu/repec/bocode/m/midas_example.dta}


{phang}
Summary Statistics

{p 8 12 2}{stata "midas tp fp fn tn, res(all)":midas tp fp fn tn, res(all)}{p_end}

{phang}
Table of index-specific results

{p 8 12 2}{stata "midas tp fp fn tn, table(dlr)":midas tp fp fn tn, table(dlr)}{p_end}


{phang}
Summary ROC Curve with prediction and confidence Contours

{p 8 12 2}{stata "midas tp fp fn tn, plot sroc(both)": midas tp fp fn tn, plot sroc(both)}{p_end}


{phang}
Linear regression test of funnel plot asymmetry

{p 8 12 2}{stata "midas tp fp fn tn, pubbias":midas tp fp fn tn, pubbias}{p_end}

{phang}
Forest plot to demonstrate variability

{p 8 12 2}
{stata "midas tp fp fn tn, id(author year) ms(0.75) bfor(dss)":midas tp fp fn tn, id(author year) ms(0.75) bfor(dss)} 
{p_end}

{phang}
Forest plot to demonstrate study-specific on right y-axis

{phang2}
{stata "midas tp fp fn tn, id(author year) ms(0.75) ford fors bfor(dss)":midas tp fp fn tn, id(author year) ms(0.75) ford fors bfor(dss)}{p_end}

{phang}
Fagan's plot

{phang2}
{stata "midas tp fp fn tn, fagan(0.20)":midas tp fp fn tn, fagan(0.20)}{p_end}


{phang}
Likelihood Matrix

{phang2}
{stata "midas tp fp fn tn, lrmat":midas tp fp fn tn, lrmat}{p_end}

{phang}
Bivariate Boxplot

{phang2}
{stata "midas tp fp fn tn, bivbox scheme(s2color)":midas tp fp fn tn, bivbox scheme(s2color)}
{p_end}


{phang}
Quality Assessment

{phang2}
{stata "midas tp fp fn tn, qbar(prodesign ssize30 fulverif testdescr refdescr subjdescr report brdspect blinded) qlab": midas tp fp fn tn, qbar(prodesign ssize30 fulverif testdescr refdescr subjdescr report brdspect blinded) qlab}
{p_end}

{phang}
Meta-regression

{phang2}
{stata "midas tp fp fn tn, reg(prodesign ssize30 fulverif testdescr refdescr subjdescr report brdspect blinded)": midas tp fp fn tn, reg(prodesign ssize30 fulverif testdescr refdescr subjdescr report brdspect blinded}
{p_end}


{title:Saved results}

{pstd}
{cmd:midas} saves the following in {cmd:r()}:


{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}

{synopt:{cmd:r(fsens)}}fixed effects estimate of summary sensitivity {p_end}
{synopt:{cmd:r(fspec)}}fixed effects estimate of summary specificity {p_end}
{synopt:{cmd:r(flrn)}}fixed effects estimate of summary likelihood ratio of a negative test {p_end}
{synopt:{cmd:r(flrp)}}fixed effects estimate of summary likelihood ratio of a positive test {p_end}
{synopt:{cmd:r(fdor)}}fixed effects estimate of summary diagnostic odds ratio {p_end}
{synopt:{cmd:r(fldor)}}fixed effects estimate of summary diagnostic score {p_end}


{synopt:{cmd:r(mtpr)}}mixed effects estimate of summary sensitivity {p_end}
{synopt:{cmd:r(mtprse)}}standard error of mixed effects estimate of summary sensitivity {p_end}
{synopt:{cmd:r(mtprlo)}}lower bound of mixed effects estimate of summary sensitivity {p_end}
{synopt:{cmd:r(mtprhi)}}upper bound of mixed effects estimate of summary sensitivity {p_end}


{synopt:{cmd:r(mtnr)}}mixed effects estimate of summary specificity {p_end}
{synopt:{cmd:r(mtnrse)}}standard error of mixed effects estimate of summary specificity {p_end}
{synopt:{cmd:r(mtnrlo)}}lower bound of mixed effects estimate of summary specificity {p_end}
{synopt:{cmd:r(mtnrhi)}}upper bound of mixed effects estimate of summary specificity {p_end}



{synopt:{cmd:r(mlrp) }}mixed effects estimate of summary likelihood ratio of a positive test result {p_end}
{synopt:{cmd:r(mlrpse)}}standard error of mixed effects estimate of summary likelihood ratio of a positive test result {p_end}
{synopt:{cmd:r(mlrplo)}}lower bound of mixed effects estimate of summary likelihood ratio of a positive test result {p_end}
{synopt:{cmd:r(mlrphi)}}upper bound of mixed effects estimate of summary likelihood ratio of a positive test result {p_end}


{synopt:{cmd:r(mlrn)}}mixed effects estimate of summary likelihood ratio of a negative test result {p_end}
{synopt:{cmd:r(mlrnse)}}standard error of summary likelihood ratio of a negative test result {p_end}
{synopt:{cmd:r(mlrnlo)}}lower bound of summary likelihood ratio of a negative test result {p_end}
{synopt:{cmd:r(mlrnhi)}}mixed effects estimate of summary likelihood ratio of a negative test result {p_end}


{synopt:{cmd:r(mdor)}}mixed effects estimate of summary diagnostic odds ratio {p_end}
{synopt:{cmd:r(mdorse)}}standard error of summary diagnostic odds ratio {p_end}
{synopt:{cmd:r(mdorlo)}}lower bound of summary diagnostic odds ratio {p_end}
{synopt:{cmd:r(mdorhi)}}upper bound of summary diagnostic odds ratio {p_end}



{synopt:{cmd:r(mldor)}}mixed effects estimate of summary diagnostic score {p_end}
{synopt:{cmd:r(mldorse)}}standard error of summary diagnostic score {p_end}
{synopt:{cmd:r(mldorlo)}}lower bound of summary diagnostic score {p_end}
{synopt:{cmd:r(mldorhi)}}upper bound of summary diagnostic score



{synopt:{cmd:r(AUC)}}Area under summary ROC curve {p_end}
{synopt:{cmd:r(AUClo)}}lower bound of area under summary ROC curve {p_end}
{synopt:{cmd:r(AUChi)}}upper bound of area under summary ROC curve {p_end}


{synopt:{cmd:r(covar)}}covariance of logits of sensitivity and specificity {p_end}


{synopt:{cmd:r(rho)}}correlation between logits of sensitivity and specificity {p_end}
{synopt:{cmd:r(rholo)}}lower bound of correlation {p_end}
{synopt:{cmd:r(rhohi)}}upper bound of correlation {p_end}
{synopt:{cmd:r(reffs1) }}variance of logit of sensitivity {p_end}
{synopt:{cmd:r(reffs1se)}}standard error of variance of logit of sensitivity {p_end}
{synopt:{cmd:r(reffs1lo)}}lower bound variance of logit of sensitivity {p_end}
{synopt:{cmd:r(reffs1hi)}}upper bound variance of logit of sensitivity {p_end}
{synopt:{cmd:r(reffs2) }}variance of logit of specificity {p_end}
{synopt:{cmd:r(reffs2se)}}standard error of variance of logit of specificity {p_end}
{synopt:{cmd:r(reffs2lo)}}lower bound variance of logit of specificity {p_end}
{synopt:{cmd:r(reffs2hi)}}upper bound variance of logit of specificity {p_end}



{synopt:{cmd:r(Islrt)}}global inconsistency index from likelihood ratio rest {p_end}
{synopt:{cmd:r(Islrtlo)}}lower bound global inconsistency index {p_end}
{synopt:{cmd:r(Islrthi)}}upper bound global inconsistency index {p_end}




{title:References}

{pmore}
Begg C.B. and Berlin J.A.
Publication bias: a problem in interpreting medical data. 
J R Stat Soc A 151 (1988), pp. 419-463.  

{pmore}
Chu H, Cole SR (2006).
Bivariate meta-analysis of sensitivity and specificity with sparse data:
a generalized linear mixed model approach.
Journal of Clinical Epidemiology 59:1331-1332.

{pmore}
Copas J, Jackson D.(2004) 
A bound for publication bias based on the fraction of unpublished studies.
Biometrics 60:146-153

{pmore}
Deeks JJ. Macaskill P and  Irwig Les.
The performance of tests of publication bias and other sample size effects in systematic 
reviews of diagnostic test accuracy was assessed. 
Journal of Clinical Epidemiology, Volume 58, Issue 9, September 2005, Pages 882-893.  

{pmore}
Dinnes J, Deeks J, Kirby J, Roderick P. 
A methodological review of how heterogeneity has been examined in systematic reviews of 
diagnostic test accuracy. 
Health Technol Assess 2005;9(12) 

{pmore}
Fisher NI, Switzer P (1985)
Chi-plots for assessing dependence. 
Biometrika 72, 253-265.

{pmore}
Fisher NI, Switzer P (2001)
Graphical assessment of dependence: Is a picture worth 100 tests?
American Statistician 55, 233-239.

{pmore}
Glas AS, Lijmer JG, Prins MH, Bonsel GJ, Bossuyt PMM (2003)
The diagnostic odds ratio: a single indicator of test performance. 
Journal of Clinical Epidemiology, Volume 56, Issue 11, November, Pages 1129-1135. 

{pmore}
Harbord RM, Deeks JJ, Egger M, Whiting P, Sterne JA (2006).
A unification of models for meta-analysis of diagnostic accuracy studies.
{it:Biostatistics} (online advance access).

{pmore}
Higgins JP, Thompson SG, Deeks JJ, Altman DG. 
Measuring inconsistency in meta-analyses [review].
BMJ 2003;327:557-60).

{pmore}
Jaeschke R, Guyatt GH, Sackett DL.
Users' guides to the medical literature. 
III. How to use an article about a diagnostic test. 
B. What are the results and will they help me in caring for my patients? 
The Evidence-Based Medicine Working Group. 
JAMA 1994;271:703-7.

{pmore}
Lau J, Schmid CH and  Chalmers TC. 
Cumulative meta-analysis of clinical trials builds evidence for exemplary medical care. 
Journal of Clinical Epidemiology, Volume 48, Issue 1, January 1995, Pages 45-57 )

{pmore}
Light R.J.and Pillemer D.B.. 
Summing up: the science of reviewing research.
Harvard University Press, Cambridge, MA (1984) 


{pmore}
Reitsma JB, Glas AS, Rutjes AWS, Scholten RJPM, Bossuyt PM, Zwinderman AH .
Bivariate analysis of sensitivity and specificity
produces informative summary measures in diagnostic reviews.
{it:Journal of Clinical Epidemiology} (2005) 58:982-990.

{pmore}
Riley RD, Abrams KR, Sutton AJ, Lambert P, Thompson JR (2005).
The benefits and limitations of multivariate meta-analysis, with application to 
diagnostic and prognostic studies.
University of Leicester Medical Statistics Group Technical Report Series.
Technical Report 05-04.

{pmore}
Rutter CM, Gatsonis CA (2001).
A hierarchical regression approach to meta-analysis of diagnostic test accuracy evaluations.
{it:Statistics in Medicine} 20:2865-2884.

{pmore}
Skupski DW, Rosenberg CR, Eglinton GS (2002) 
Intrapartum Fetal Stimulation Tests: A Meta-Analysis. 
Obstet. Gynecol. 99: 129 - 134.

{pmore}
Song F,  Khan K, Dinnes J. and Sutton A.J.
Asymmetric funnel plots and publication bias in meta-analyses of diagnostic accuracy. 
Int J Epidemiol 31 (2002), pp. 88-95


{pmore}
StataCorp. 2007.
Stata Statistical Software: Release 10
College station, TX:
StataCorp LP.


{pmore}
Swets JA. 
Measuring the accuracy of diagnostic systems. 
Science. 1988;240:1285-1293.

{pmore}
van Houwelingen H.C. , Arends  L.R. and  Stijnen T. 
Advanced methods in meta-analysis: multivariate approach and meta-regression,
Stat Med 21 (2002) (4), pp. 589-624. 
 
{pmore}
van Houwelingen H.C., Zwinderman K.H. and Stijnen T. 
A bivariate approach to meta-analysis, 
Stat Med 12 (1993) (24), pp. 2273-2284 


{title:Author}

{pmore}
{browse "http://www.sitemaker.umich.edu/metadiagnosis":Ben A. Dwamena}, Division of Nuclear Medicine, 
Department of Radiology, University of Michigan, USA
Email {browse "mailto:bdwamena@umich.edu":bdwamena@umich.edu} for problems, comments and suggestions

{title:Citation}

{pmore}
Users should please reference program in any published work as: 
{title:Dwamena, Ben A.(2007)}
{hi: midas: A program for Meta-analytical Integration of Diagnostic Accuracy Studies in Stata.}
Division of Nuclear Medicine, Department of Radiology, University of Michigan Medical School, Ann Arbor, Michigan.


{title:Also see}

{pmore}
On-line: help for {help metan} (if installed),
 {help gllamm} (if installed), 
{help mylabels} (if installed)
	
	
