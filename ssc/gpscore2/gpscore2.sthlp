{smcl}
{* 27march2013}{...}
{cmd:help gpscore2}{right: ({browse "http://mpra.ub.uni-muenchen.de/45013/"})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:gpscore2} {hline 2}}Estimation of the generalized propensity score through GLM{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:gpscore2}
{it: varlist} 
{ifin}
{weight}{cmd:,}
{cmd:t}{cmd:(}{it:varname}{cmd:)}
{cmd:gpscore}{cmd:(}{it:newvar}{cmd:)}
{cmd:predict}{cmd:(}{it:newvar}{cmd:)}
{cmd:sigma}{cmd:(}{it:newvar}{cmd:)}
{cmd:cutpoints}{cmd:(}{it:varname}{cmd:)}
{cmd:index}{cmd:(}{it:string}{cmd:)}
{cmd:nq_gps}{cmd:(}{it:#}{cmd:)}
{cmd:family}{cmd:(}{it:string}{cmd:)}
{cmd:link}{cmd:(}{it:string}{cmd:)}
[{cmd:t_transf}{cmd:(}{it:transformation}{cmd:)}
{cmd:normal_test}{cmd:(}{it:test}{cmd:)}
{cmd:norm_level}{cmd:(}{it:#}{cmd:)}
{cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)}
{cmd:test}{cmd:(}{it:type}{cmd:)}
{cmd:flag_b}{cmd:(}{it:#}{cmd:)}
{cmd:opt_nb}{cmd:(}{it:string}{cmd:)}
{cmd:opt_b}{cmd:(}{it:varname}{cmd:)}
{cmdab:det:ail}]

{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.


{title:Description}

{pstd} {cmd:gpscore2} estimates the parameters of the conditional distribution
of the treatment given the control variables in {it:varlist} by GLM, allowing 
six different distribution functions: binomial, gamma, inverse gaussian, 
negative binomial, normal, poisson coupled with admissible links; for the normal case 
assesses the validity of the assumed normal distribution model by a user-specified 
goodness-of-fit test; and estimates the generalized propensity score (GPS).
The estimated GPS is defined as {it: R=r(T,X)}, where {it:r(.,.)} is the conditional 
density of the treatment given the covariates, {it:T} is the observed treatment, and
{it:X} is the vector of the observed covariates. Then {cmd:gpscore} tests the
balancing property by using the algorithm suggested by Hirano and Imbens (2004),
and informs the user whether and at what extent the balancing property is
supported by the data.


{title:Options}

    {title:Required}

{phang} {cmd:t}{cmd:(}{it:varname}{cmd:)} specifies that {it:varname} is the
treatment variable.

{phang} {cmd:gpscore}{cmd:(}{it:newvar}{cmd:)} specifies the variable name for
the estimated GPS, which is added to the dataset.

{phang} {cmd:predict}{cmd:(}{it:newvar}{cmd:)} creates a new variable to hold
the fitted values of the treatment variable.

{phang} {cmd:sigma}{cmd:(}{it:newvar}{cmd:)} creates a new variable to hold
the GLM estimate of the conditional standard error of the
treatment given the covariates, obtained from Pearson residuals.

{phang} {cmd:cutpoints}{cmd:(}{it:varname}{cmd:)} divides the set of potential
treatment values into intervals according to the sample distribution of the
treatment variable, cutting at {it:varname} quantiles.

{phang} {cmd:index}{cmd:(}{it:string}{cmd:)} specifies the representative
point of the treatment variable at which the GPS has to be evaluated within
each treatment interval. {it:string} identifies either the mean ({it:string} =
{cmd:mean}) or a percentile ({it:string} = {cmd:p1}, ..., {cmd:p100}) of the
treatment.

{phang} {cmd:nq_gps}{cmd:(}{it:#}{cmd:)} specifies that the values of the GPS
evaluated at the representative point {cmd:index}{cmd:(}{it:string}{cmd:)} of
each treatment interval have to be divided into {it:#} (1 <= {it:#} <= 100)
intervals, defined by the quantiles of the GPS evaluated at the representative
point {cmd:index}{cmd:(}{it:string}{cmd:)}.

{phang} {cmd:family}{cmd:(}{it:string}{cmd:)} specifies the distribution family
name of the treated variable. {it:string} identifies the distribution family name.

{phang} {cmd:link}{cmd:(}{it:string}{cmd:)} specifies the link function for the treated
variable. The default is the canonical link for the family specified.

see {help glm}

    {title:Optional}

{phang} {cmd:t_transf}{cmd:(}{it:transformation}{cmd:)} specifies the
transformation of the treatment variable used in estimating the GPS. The
default {it:transformation} is the identity function.  The supported
transformations are the logarithmic transformation, {cmd:t_transf(ln)}; the
zero-skewness log transformation, {cmd:t_transf(lnskew0)}; the zero-skewness
Box-Cox transformation, {cmd:t_transf(bcskew0)}; and the Box-Cox
transformation, {cmd:t_transf(boxcox)}.

{phang} {cmd:normal_test}{cmd:(}{it:test}{cmd:)} specifies the goodness-of-fit
test that {cmd:gpscore} will perform to assess the validity of the assumed
normal distribution model for the treatment conditional on the covariates. By
default, {cmd:gpscore} performs the Kolmogorov-Smirnov test
({cmd:normal_test(ksmirnov)}). Possible alternatives are the Shapiro-Francia
test, {cmd:normal_test(sfrancia)}; the Shapiro-Wilk test,
{cmd:normal_test(swilk)}; and the Stata skewness and kurtosis
test for normality, {cmd:normal_test(sktest)}.

{phang} {cmd:norm_level}{cmd:(}{it:#}{cmd:)} sets the significance level of
the goodness-of-fit test for normality. The default is {cmd:norm_level(0.05)}.

{phang} {cmd:test_varlist}{cmd:(}{it:varlist}{cmd:)} specifies that the extent
of covariate balancing has to be inspected for each variable of {it:varlist}.
The default {it:varlist} consists of the variables used to estimate the GPS.
This option is useful when there are categorical variables among the
covariates to test the balancing property for the omitted group.

{phang} {cmd:test}{cmd:(}{it:type}{cmd:)} specifies whether the balancing
property has to be tested using a standard two-sided t test (the default) or a
Bayes-factor-based method.

{phang} {cmd:flag_b}{cmd:(}{it:#}{cmd:)} skips either the balancing or the 
normal test or both, takes as argument 0; 1; 2. If not specified in the commands 
the program estimates the {cmd:gpscore} performing both the balancing and 
the normal test. {cmd:flag_b(0)} skips both the balancing and the
normal test; {cmd:flag_b(1)} skips only the balancing test; {cmd:flag_b(2)}
skips only the normal test. 

{phang} {cmd:opt_nb}{cmd:(}{it:string}{cmd:)} negative binomial dispersion
parameter. In the GLM approach you specify {cmd:fam(nb #k)} where {it:#k}
is specified through the option {cmd:opt_nb}. The GLM then searches for 
{it:#k} that results in the deviance-based dispersion being 1. Instead, 
{cmd:nbreg} finds the ML estimate of {it:#k}.

{phang} {cmd:opt_b}{cmd:(}{it:varname}{cmd:)} name of the variable which contains the
number of binomial trials.

{phang} {cmd:detail} displays more detailed output showing the results of the
goodness-of-fit test for normality, some summary statistics of the
distribution of the GPS evaluated at the representative point of each
treatment interval, and the results of the balancing test within each
treatment interval.


{title:Remarks} 

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.
Otherwise, this program may not run properly.

{pstd} Pay attention to the family-link combination, not all the combinations
are feasible.

{pstd} Make sure that the variables in {it:varlist} do not contain missing
values.


{title:Examples}
   

   {inp:. egen max_p=max(prize) }
   {inp:. gen fraction= prize/max_p }

   {inp:. qui gen     cut1 = 23/max_p  if fraction<=23/max_p }
   {inp:. qui replace cut1 = 80/max_p  if fraction>23/max_p & fraction<=80/max_p }
   {inp:. qui replace cut1 = 485/max_p if fraction >80/max_p } 
   
   {inp:. #delimit ;}
   {inp:. gpscore2 male ownhs owncoll tixbot workthen yearw yearm1 yearm2, }
   {inp:. t(fraction) gpscore(gpscore) }
   {inp:. predict(y_hat_ns) sigma(sd_ns) cutpoints(cut1) index(mean) }
   {inp:. nq_gps(5) family(binomial) link(logit) det }
   {inp:. ;}



   {inp:. gen edu=owncoll+ownhs }

   {inp:. qui gen     cut3 = 3  if edu<=3 }
   {inp:. qui replace cut3 = 6  if edu>3 & edu<=6 }
   {inp:. qui replace cut3 = 9 if edu >6 }

   {inp:. #delimit ;}
   {inp:. gpscore2 male workthen yearw yearm1 yearm2, }
   {inp:. t(edu) gpscore(nostro) }
   {inp:. predict(y_hat_ns) sigma(sd_ns) cutpoints(cut3) index(p50) }
   {inp:. nq_gps(5) family(nb) link(log) }
   {inp:. ;}


{title:Reference}

{phang}
Hirano, K., and G. W. Imbens. 2004. The propensity score with continuous
treatments. In
{it:Applied Bayesian Modeling and Causal Inference from Incomplete-Data}
{it:Perspectives}, ed. A. Gelman and X.-L. Meng, 73-84. West Sussex, England:
Wiley InterScience. {p_end}

{phang}
Papke L.E. and J.M. Wooldridge. 1996. 
{it:Econometric Methods for fractional response variables with an application to 401(K) plan Partecipation rates.} 
Journal of Applied Econometrics, 11(6): 619-632. {p_end}

{phang}
Rabe-Hesketh S. and B. Everitt. 2000. 
{it:A Handbook of Statistical Analyses using Stata.} 
Second eds, Chapman & Hall/Crc. Boca Raton London New York Washington
D.C.. {p_end}


{title:Acknowledgment}

{pstd} We thank Professor H. Hirano, A. Mattei and J. Wooldridge for their 
useful comments and suggestions in an early stage of the work.
{p_end}


{title:Authors}

{phang}Barbara Guardabascio{p_end}
{phang}ISTAT, Italian National Institute of Statistics{p_end}
{phang}National Accounts and Economic Statistics Department{p_end}
{phang}{browse "mailto:guardabascio@istat.it":guardabascio@istat.it}{p_end}

{phang}Marco Ventura{p_end}
{phang}ISTAT, Italian National Institute of Statistics{p_end}
{phang}Econometric Studies and Economic Forecasting Division{p_end}
{phang}{browse "mailto:mventura@istat.it":mventura@istat.it}{p_end}


{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 9, number 4: {browse "http://www.stata-journal.com/article.html?article=up0026":st0150_2},{break}
         {it:Stata Journal}, volume 8, number 4: {browse "http://www.stata-journal.com/article.html?article=up0023":st0150_1},{break}
         {it:Stata Journal}, volume 8, number 3: {browse "http://www.stata-journal.com/article.html?article=st0150":st0150}

{psee}
Online:  {helpb gpscore}, {helpb doseresponse}, {helpb doseresponse2}, {helpb doseresponse_model}
{p_end}
