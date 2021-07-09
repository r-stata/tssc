{smcl}
{* *! version 3.1  13jul2015}{...}
{vieweralsosee "mvmeta" "mvmeta"}{...}
{vieweralsosee "Getting the data in" "mvmetademo_setup"}{...}
{viewerjumpto "Berkey data" "mvmetademo_run##Berkey"}{...}
{viewerjumpto "p53 data" "mvmetademo_run##p53"}{...}
{viewerjumpto "FSC data 1" "mvmetademo_run##FSCfpama"}{...}
{viewerjumpto "FSC data 2" "mvmetademo_run##FSCshape"}{...}
{viewerjumpto "References" "mvmetademo_run##refs"}{...}
{hline}
{cmd:Demonstration for the mvmeta package in Stata: running mvmeta}
{cmd:Ian White}
{hline}

{title:Installing mvmeta}

{pstd}{stata "net from http://www.homepages.ucl.ac.uk/~rmjwiww/stata/"}

{p}then click on meta then {cmd:mvmeta}. Also install {cmd:bubble}.


{title:Getting the data in}{marker data}

{p 4 4 2}A separate {help mvmetademo_setup:demonstration} is available.


{title:Berkey data}{marker Berkey}

{p}Data from Berkey et al (1998): treatment effects on 
two outcomes (probing depth, y1; attachment level, y2)
in periodontal disease. 
The within-trial variances and covariances were reported by the authors.

{pstd}{stata use berkey, clear}

{pstd}{stata l, noo sep(0)}

{p}Now we'll {ul:draw a bubble plot of the data}. 
This requires converting the variances to standard errors 
and computing the correlation:

{pstd}{stata gen s1=sqrt(V11)}

{pstd}{stata gen s2=sqrt(V22)}

{pstd}{stata gen r12=V12/sqrt(V11*V22)}

{pstd}{stata bubble y1 y2 s1 s2 r12, colourby}

{p}We {ul:fit a bivariate meta-analysis}:

{pstd}{stata mvmeta y V}

{p}The y1 results are very similar to those from univariate meta-analysis:

{pstd}{stata mvmeta y V, var(y1)}

{p}We {ul:compare the univariate {cmd:mvmeta} results with those from {cmd:metan}}.

{pstd}{stata metan y1 s1}

{p}These differ because by default (1) {cmd:mvmeta} fits the random-effects model,
whereas {cmd:metan} fits the fixed-effect model;
(2) {cmd:mvmeta} uses REML, 
whereas {cmd:metan} uses the method of moments;
(3) {cmd:mvmeta}'s standard error allows for uncertainty in estimating tau.
To get exact agreement:

{pstd}{stata metan y1 s1, random}

{pstd}{stata mvmeta y V, var(y1) mm nouncertainv print(bscov)}

{p}Let's return to the bivariate setting and 
explore a {ul:meta-regression} on year of publication.

{pstd}{stata mvmeta y V pubyear}

{p}There's no evidence that either outcome is associated with year of publication.



{title:p53 data}{marker p53}

{p}These data come from 6 observational studies in patients with squamous cell carcinoma of the oropharynx.
The presence of mutant p53 tumor suppressor gene is considered as a possible prognostic factor (Jackson et al, 2011).

{p}
The data are the estimated log hazard ratios (lnHR) 
for mutant vs. normal p53 gene for two outcomes,
overall survival (OS) and disease-free survival (DFS), 
together with their variances.

{pstd}{stata use p53, clear}

{pstd}{stata l, noo sep(0) abb(12)}

{p}Now we'll draw a bubble plot of the data. 

{pstd}{stata gen selnHRdfs = sqrt(VlnHRdfsdfs)}

{pstd}{stata gen selnHRos = sqrt(VlnHRosos)}

{pstd}{stata bubble lnHRdfs lnHRos selnHRdfs selnHRos, colourby stagger(.02)}

{p}Note that the OS results in studies without
DFS results are much larger than those in studies with DFS results. 
This suggests that the multivariate result for DFS may be substantially larger
than the univariate result - but also that we should be cautious of both results.

{p}Let's {ul:fit the univariate meta-analysis for DFS}:

{pstd}{stata mvmeta lnHR VlnHR, var(lnHRdfs)}

{p}Let's {ul:compare with the multivariate meta-analysis}. 
The data don't include the within-study correlations: 
we assume they are all 0.7.

{pstd}{stata mvmeta lnHR VlnHR, wscorr(0.7)}

{p}Yes, the multivariate result for DFS is larger (lnHRdfs is less negative)
than the univariate result. It also has a larger between-studies variance,
and hence a larger standard error.

{p}Various {ul:post-estimation options} can be called after a {cmd:mvmeta}
fit without re-fitting the model.
The {cmd:i2} option estimates a multivariate I-squared,
together with its confidence interval. 
It also gives a confidence interval for the between-studies correlation:

{pstd}{stata mvmeta, i2}

{p}The {cmd:eform} option shows the exponentiated coefficients - here hazard ratios:

{pstd}{stata mvmeta, eform}

{p}We can also see the full parameterisation of the model,
including the Cholesky decomposition of the variance terms 
which are usually hidden:

{pstd}{stata mvmeta, showall}

{p}Other post-estimation options include {cmd:t(#)} to specify
a t-distribution for inference.

{p}Above we assumed the unknown within-study correlations were all 0.7.
We can avoid this assumption by using Riley's alternative model (Riley et al, 2008). 
Usually this converges quickly, 
but for these data this occasion it can need more than 2000 iterations:

{pstd}{stata mvmeta lnHR VlnHR, wscorr(riley)}

{p}Adding the {cmd:difficult} option leads to convergence in 14 iterations.


{title:Fibrinogen Studies Collaboration 1}{marker FSCfpama}
{title:Fully and partly adjusted associations}

{p}The original data are from 31 studies relating plasma levels of fibrinogen,
a blood clotting factor, to time to a coronary heart disease (CHD) event (Fibrinogen Studies Collaboration, 2005).
In this example, we assume a linear association between fibrinogen and CHD, 
and we wish to adjust for confounding. Some confounders are recorded in all studies, while 
others are recorded in only 14 studies.
We therefore estimate a partly adjusted coefficient (log hazard ratio) in all 31 studies, 
and a fully adjusted coefficient in the 14 studies.
We also estimate their (within-studies) correlation: in the paper we considered three methods,
but here we'll use the bootstrap method (Fibrinogen Studies Collaboration, 2009).

{pstd}{stata use FSCfpama, clear}

{pstd}{stata l, noo}

{p}In order to do {cmd:mvmeta} we need to {ul:construct the variance-covariance matrices}:

{pstd}{stata gen varfafa = sefa^2}

{pstd}{stata gen varpapa = sepa^2}

{pstd}{stata gen varfapa = corrb*sefa*sepa}

{p}The {ul:"standard" approach} would be to analyse only the fully adjusted estimates:

{pstd}{stata mvmeta beta var, var(betafa)}

{p}Our {ul:new approach} analyses the fully-adjusted estimates jointly with the partly-adjusted estimates
in order to gain precision:

{pstd}{stata mvmeta beta var}

{p}The standard error for betafa has decreased from 0.0389 to 0.0266 or 32%.
This represents a 53% decrease in variance.
Note the between-studies correlation is estimated as 1, so that the model is able to infer 
fully-adjusted estimates quite precisely from partly-adjusted estimates.

{p}The {cmd:bos} option estimates the borrowing of strength 
- the degree to which results for one outcome gain precision
by the inclusion of the other outcome(s) in the analysis.

{pstd}{stata mvmeta, bos}

{p}This also shows a 53% borrowing of strength. 
The results also show the relative contributions of the studies to the fully-adjusted result:
study 12 makes the largest contribution, 
but e.g. study 28 (only partly adjusted) contributes more than study 1 (fully adjusted).
This is because study 28 is much more precise:

{pstd}{stata l if inlist(cohort,1,14,28)}



{title:Fibrinogen Studies Collaboration 2}{marker FSCshape}
{title:Shape of exposure-outcome relationship}

{p}We now use the same original data to explore the shape of association
between fibrinogen and CHD, adjusting for complete confounders.
Each study has been analysed using a Cox model including fibrinogen
categorised into 5 groups and adjusting for confounders.
The "outcomes" of interest are therefore the 4 contrasts (log hazard ratios) of groups 
2-5 with group 1.
Some studies (e.g. study 15) 
have no participants or no events in group 1:
these have been handled by introducing ("augmenting") a very small amount of 
data in group 1.
{cmd:mvmeta_make} has been used to automate the augmentation, fitting of the Cox models 
and extraction of the point estimates, variances and covariances (White, 2009).

{pstd}{stata use FSCstage1, clear}

{pstd}{stata browse}

{pstd}{stata mvmeta b V}

{pstd}{stata estimates store FSC2full}

{p}That was a little slow. 
We'll demonstrate some faster alternatives.
First and probably best, the method of moments. The original version is by Jackson et al (2010):

{pstd}{stata mvmeta b V, mm}

{p}and a matrix-based method of moments is by Jackson et al (2013):

{pstd}{stata mvmeta b V, mm2}

{p}The fixed-effect method (not recommended, because it ignores heterogeneity):

{pstd}{stata mvmeta b V, fixed}

{p}We could also assume that the between-studies variation 
is captured by a random slope:

{pstd}{stata matrix B = (1,2,3,4)'*(1,2,3,4)}

{pstd}{stata mvmeta b V, bscov(prop B)}

{pstd}{stata lrtest FSC2full}

{p}Not significantly worse, 
but I'd prefer to use the full model:

{pstd}{stata estimates replay FSC2full}

{p}Finally, here's a graph I made earlier:

{pstd}{stata graph use FSC2cigraph}



{title:References}{marker refs}

{phang}Berkey CS, Hoaglin DC, Antczak-Bouckoms A, Mosteller F, Colditz GA (1998). 
Meta-analysis of multiple outcomes by regression with random effects. 
Statistics in Medicine 17: 2537-2550.

{phang}Jackson D, White IR, Thompson SG (2010). 
Extending DerSimonian and Laird's methodology to perform multivariate random effects meta-analyses. 
Statistics in Medicine 29: 1282-1297.

{phang}Jackson D, Riley R, White IR (2011). 
Multivariate meta-analysis: potential and promise. 
Statistics in Medicine 30: 2481-2498.

{phang}Jackson D, White IR, Riley R (2013). 
A matrix based method of moments for fitting the random effects model 
for meta-analysis and meta-regression. 
Biometrical Journal 55: 231-245.

{phang}Fibrinogen Studies Collaboration (2005). 
Plasma fibrinogen and the risk of major cardiovascular diseases and non-vascular mortality: meta-analysis of individual data for 154 211 adults in 31 prospective studies. 
Journal of the American Medical Association 294: 1799-1809.

{phang}Fibrinogen Studies Collaboration (2009). 
Systematically missing confounders in individual participant data meta-analysis of observational cohort studies. 
Statistics in Medicine 28: 1218-1237. 
Writing committee: Jackson D, White I.

{phang}White IR (2009). 
Multivariate random-effects meta-analysis. 
Stata Journal 9: 40-56.


