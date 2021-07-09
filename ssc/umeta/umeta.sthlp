{smcl}
{* November 24, 2011}{...}
{hline}
{cmd:help for umeta and umeta_postestimation}
{hline}

{title:Title}

{p 4 4 2}
{bf:umeta} {hline 1} U-statistics-based random-effects meta-analyses



{title:Description}

{pstd}
The {cmd:umeta} command performs U-statistics-based random-effects meta-analysis on a
dataset of univariate, bivariate or trivariate point estimates, sampling variances, and for bivariate or trivariate data, within-study correlations or covariances. 
The methodology is described in {help umeta#MM2011:Ma and Mazumdar (2011)}. 

{pstd}
For each outcome, {cmd:umeta} calculates the overall effect and a confidence interval for
the effect. The command also displays the between-study variance 
(or alternatively between-study standard deviation), between-study correlation(s) 
for bivariate or trivariate data and inconsistency (I-squared) statistics. 


{title:{help umeta} Syntax}

{p 4 4 2}
{cmd:umeta} {it:yvar*} {it:svar*} [{it:wsvar*}]
{ifin}
[{cmd:,} 
{* MODEL OPTIONS}
{* ESTIMATION OPTIONS}
{cmdab:cov:var(string)}
{* OUTPUT OPTIONS}
{cmd:level(#)}
{cmdab:pred:int}
{cmdab:ts:cale(logit|log|asin)}
{cmdab:noest:imates}
{cmdab:bs:sd} 
{cmdab:z:ci}
{cmd:i2}]

{p 4 4 2}
where the data are arranged with one line per study: the point estimates are held in variables {it:yvar*}{cmd:}, the sampling variances are held in 
{it:svar*}, and within-study correlations (or covariances) for 2 or 3 outcomes are held in variable {it:wsvar*}.  

{p 4 4 2}
For univariate data, {cmd:yvar*} is {cmd:yvar} and {cmd:svar*} is {cmd:svar}

{p 4 4 2}
For bivariate data, {cmd:yvar*} is {cmd:yvar1 yvar2},  {cmd:svar*} is {cmd:svar1 svar2}  and {cmd:wsvar*} is {cmd:wsvar12}

{p 4 4 2}
For trivariate data,  {cmd:yvar*} represents {cmd:yvar1 yvar2 yvar3}, {cmd:svar*} is {cmd:svar1 svar2 svar3} and {cmd:wsvar*} is {cmd:wsvar12, wsvar13 wsvar23}

{p 4 4 2}
{hi:For any unreported outcomes, umeta sets the outcome and its variance at 0 and 1E12, respectively}.

{title:Options for {help umeta}}

{phang}
{cmdab:cov:var}({it:string})  For bivariate or trivariate data analysis, you {hi:must} specify {cmdab:cov:var}({it:rho}) or {cmdab:cov:var}({it:cov})
depending on whether you are using within-study correlation(s) or covariance(s).

{phang}
{cmd:level(#)} specifies the significance level for probability intervals.

{phang}
{cmdab:pred:int} displays outcome-specific mean estimates with the probability interval of the approximate predictive
 distribution of a future trial, based on the extent of heterogeneity. No method has been developed as yet for multivariate predictive distribution.


{phang}
{cmdab:ts:cale(logit|log|asin)} transformation of estimates to original scale, if data was transformed prior to analysis. 


{phang}
{cmdab: bs:sd} reports the between-study standard deviations with confidence intervals (calculated as a function of  inconsistency statistic and typical within-study variance  as by {help umeta#W2009:White(2009)}) instead of the default 
between-study variances. 

{phang}
{cmdab:noest:imates} prevents display of mean estimates, between-study variances (or standard deviations) and correlation(s)

{phang}
{cmdab:z:ci} uses z-statistics instead of default t-statistics for confidence interval calculation. This is overriden if option {cmdab:pred:int} specified.

{phang}
{cmd:i2} reports I-squared statistic for each outcome, together with confidence intervals  as is described in {help umeta#W2009:White(2009)}.  

{pstd}
{cmd:umeta}, typed without specifying varlist, redisplays the
latest estimation results.  All the output options listed above may be used


{pstd}
{opt by}{it:...}{cmd ::} or {opt statsby}{it:...}{cmd ::} may be used with {cmd:umeta} to perform subgroup analyses; see help {help by} or {help statsby}.


{title:Remarks}

{p 4 4 2}
Multivariate meta-analysis is used to synthesize multiple outcomes simultaneously
taking into account the correlation between the outcomes ({help umeta#R2009:Riley(2009)}). Likelihood based approaches, in particular, Restricted Maximum Likelihood (REML) method is
commonly utilized in this context. REML assumes a multivariate normal
distribution for the random-effects model. This assumption is
difficult to verify, especially for meta-analysis with small number of
component studies. Use of REML also requires iterative estimation between
parameters, needing moderately high computation time, especially when the
dimension of outcomes is large ({help umeta#W2009:White(2009)}). {help umeta#WT2010: Jackson, White and Thompson(2010)} have developed a multivariate method of moments (MMM) 
which has been shown to perform equally well to REML. 

{p 4 4 2}
Ma and Mazumdar recently proposed a new method 
for multivariate meta-analysis based on the theory of U-statistic. 
The motivation for using U-statistic stems from the fact that
it provides a a robust, nonparametric and noniterative approach. 
Additionally, the asymptotic behavior of the related statistics and their estimates 
are easy to derive being based on theorems already available for U-statistics. 

{p 4 4 2}
Since the between-study variance matrix for the random-effects  meta-analysis model 
involves second order moments, U-statistic formulation
is especially beneficial. It is easily applied to estimate the
variance matrix components and to develop their joint asymptotic
distribution for related inference. Because the U-statistic-based method does not depend on 
parametric distributional assumptions for both random effects and sampling errors, 
it provides robust inference irrespective of the data distribution

{p 4 4 2}
For a detailed description of the u-statistic methodology, 
see {help umeta#MM2011:Ma and Mazumdar (2011)}.

{p 4 4 2}
By convention, the within-study variances are assumed
known and replaced by their sample estimates. Thus imprecision in
within-study variance estimates may affect the estimation of pooled effect
size especially when the size of within-study variation is relatively large.

{p 4 4 2}
This program does not assume that variables need log, logit or arcsin or other transformation(s).
However, if study-level outcome data are available as odds ratios, risk ratios or proportions, the user may choose to
log-, logit-or arcsin-transform them first. Then {cmdab:ts:cale} option may be used to change
back to the original scale for reporting if so desired.

{p 4 4 2}
The probability interval of the approximate predictive distribution of a future trial, is 
based on the extent of heterogeneity. This incorporates uncertainty in the location 
and spread of the random effects distribution using the formula {cmd: t(df) x sqrt(se2 + tau2)} 
where t is the t-distribution with n-2 degrees of freedom, se2 is the squared standard error and 
tau2 the heterogeneity statistic and n is the number of observations(studies). This is applied to each outcome separately.
For further information see {help umeta#HTS2009:Higgins, Thompson and Spiegelhalter(2009)}


{p 4 4 2}
I-squared formulated by {help umeta#HT2002:Higgins and Thompson (2002)}, describes the percentage of total variation across studies that is attributable to heterogeneity rather than chance and measures impact of heterogeneity. 
. Negative values of I-squared are made equal to 0 so that I-squared lies between 0% and 100%. 
A value of 0% indicates no observed heterogeneity, and values greater than 50% may be considered substantial heterogeneity. 
The main advantage of I-squared is that it does not inherently depend on the number of the studies in the meta-analysis



{title:Examples}

{pstd}

Example 1: Univariate Data

{phang2}{cmd:. use umeta_example1, clear}{p_end}

{phang2}{cmd:. list yvar svar, clean noobs}{p_end}
{phang2}{cmd:. umeta yvar svar}{p_end}

Example 2: Bivariate logit-transformed Data, No within-study correlation

{phang2}{cmd:. use umeta_example2, clear}{p_end}

{phang2}{cmd:. list  yvar* svar*  rho*, clean noobs}{p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*, p} {p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*, z bssd p tscale(logit) }{p_end}


Example 3: Bivariate Outcomes with missing Data

{phang2}{cmd:. use umeta_example3, clear}{p_end}

{phang2}{cmd:. list  yvar* svar*  rho*, clean noobs}{p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*}{p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*, pred}{p_end}

{phang2}{cmd:. umeta, noest i2 z q}{p_end}

Example 4: Trivariate Outcomes with Zero within-study covariance matrix

{phang2}{cmd:. use umeta_example4, clear}{p_end}

{phang2}{cmd:. list  yvar* svar*  rho*, clean noobs}{p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*}{p_end}

{phang2}{cmd:. umeta, noest i2 z q}{p_end}


Example 5: Trivariate Outcomes with within-study correlations

{phang2}{cmd:. use umeta_example5, clear}{p_end}

{phang2}{cmd:. list  yvar* svar*  rho*, clean noobs}{p_end}

{phang2}{cmd:. umeta yvar* svar*  rho*, pred}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:umeta} saves the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(dims)}}number of outcomes for meta-analysis{p_end}
{synopt:{cmd:e(df_r)}}degrees of freedom for meta-analysis estimation{p_end}
{synopt:{cmd:e(Qdf)}}degrees of freedom for homogeneity testing {p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:umeta}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(yvars)}}names of study-specific outcome variables (point estimates){p_end}
{synopt:{cmd:e(svars)}}names of study-specific sampling variances{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(Isqmat)}}matrix of outcome-specific I^2 values{p_end}
{synopt:{cmd:e(Qmat)}}matrix of outcome-specific heterogeneity statistic{p_end}
{synopt:{cmd:e(Vtyp)}}typical within-study variance{p_end}
{synopt:{cmd:e(Sigma)}}between-study variance-covariance matrix {p_end}
{synopt:{cmd:e(svars)}}matrix of study-specific sampling variances{p_end}
{synopt:{cmd:e(rho)}}matrix of between-study correlation{p_end}
{synopt:{cmd:e(yvars)}}matrix of study-specific point estimates{p_end}

{synoptset 24 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}



{title:Authors}
{p 4 4 2}
Ben A. Dwamena, Department of Radiology, Division of Nuclear Medicine, University of Michigan Medical School, Ann Arbor, Michigan

{p 4 4 2}
Yan Ma, Hospital for Special Surgery, Weill Medical College of Cornell University, New York, New York

{title:programming problems:}
{p 4 4 2}
{browse "mailto:bdwamena@umich.edu":bdwamena@umich.edu}.

{title:u-statistic-based questions:}
{p 4 4 2}
{browse "mailto:yam2007@med.cornell.edu":yam2007@med.cornell.edu}.



{hline}

{title:Title}

{p2colset 5 31 33 2}{...}
{p2col :{hi:umeta postestimation} {hline 2}}Postestimation tools for umeta{p_end}
{p2colreset}{...}


{title:Description}

{p 4 4} 
{help umeta} is programmed as an Stata estimation command and so supports many of the commands listed under help
{help estcom} and {help postest}.  The following standard postestimation commands may be particularly useful:

{synoptset 14}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb umeta postestimation##estat:estat}}VCE and estimation sample summary. See help {help estat}{p_end}
{synopt :{helpb umeta postestimation##estimates:estimates}}Cataloging estimation results. See help {help estimates}{p_end}
{synopt :{helpb umeta postestimation##lincom:lincom}}Point estimates, standard errors, testing, and inference for linear combinations of coefficients. See {help lincom}{p_end}
{synopt :{helpb umeta postestimation##nlcom:nlcom}}Point estimates, standard errors, testing, and inference for nonlinear combinations of coefficients. See {help nlcom}{p_end}
{synopt :{helpb umeta postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
{synopt :{helpb umeta postestimation##test:test}}Wald tests of linear hypotheses. See help {help test}{p_end}
{synopt :{helpb umeta postestimation##testnl:testnl}}Wald tests of non-linear hypotheses. See help {help testnl}{p_end}
{synoptline}
{p2colreset}{...}


{title:{help predict} Syntax}

{p 4 4}
The syntax of {help predict} following {cmd:umeta} is

{p 4 4}{hi:syntax 1:}

{p 8 16}{cmd:predict} [{it:type}] {it:newvarname} [{cmd:if} {it:exp}]
[{cmd:in} {it:range}] [{cmd:,} {it:statistic} ]

{p 4 4}{hi:syntax 2:}

{p 8 16}{cmd:predict} {it:newvarname} [{cmd:if} {it:exp}]
[{cmd:in} {it:range}] [{cmd:,} {it:statistic} {it:show(string)}]

{synoptset 13 tabbed}{...}
{synoptline}
{synopthdr :statistic}
{synoptline}
{synopt :{cmdab:fix:ed}}prediction of fixed-effects; the default{p_end}
{synopt :{cmdab:stf:ixed}}standard error of the fixed-effects prediction{p_end}
{synopt :{cmdab:fit:ted}}prediction including random effects{p_end}
{synopt :{cmd:stfit}}standard error of {cmdab:fit:ted}{p_end}
{synopt :{cmd:stdf}}standard error of the forecast{p_end}
{synopt :{cmdab:reff:ects}}predicted random effects{p_end}
{synopt :{cmdab:res:es}}standard error of predicted random effects{p_end}
{synopt :{cmdab:rst:andard}}standardized predicted random effects{p_end}
{synopt :{cmd:lev}}leverage (diagonal elements of projection matrix){p_end}
{synopt :{cmdab:cooksd}}Cook's influence measure{p_end}
{synoptline}

{p 4 4} 
These statistics are available both in and out of sample;
type "predict ... if e(sample) ..." if wanted only for the estimation sample.

{synoptline}
{synopthdr :show}
{synoptline}
{synopt :{opt clean}}force table format with no divider or separator
lines{p_end}
{synopt :{opt t:able}}force table format{p_end}
{synopt :{opt ab:breviate(#)}}abbreviate variable names to {it:#} characters;
default is {cmd:ab(8)}{p_end}
{synopt :{opt noo:bs}}do not list observation numbers{p_end}
{synopt :{opt div:ider}}draw divider lines between columns{p_end}
{synopt :{opt sep:arator(#)}}draw a separator line every {it:#} lines; default is 
{cmd:separator(5)}{p_end}
{synoptline}
{p2colreset}{...}




{title:Options for {help predict}}

{p 4 8}{cmd:fixed} calculates the linear prediction for the fixed portion of the
model.

{p 4 8}{cmd:stfixed} calculates the outcome-specific standard error of the fixed-portion linear prediction

{p 4 8}{cmd:stfitted} calculates the outcome-specific standard error
of the prediction including random effects.

{p 4 8}{cmd:fitted} calculates the outcome-specific prediction including random effects,
{break}Xb[i] + u[i], also known as the empirical Bayes estimates of the effects in each study.

{p 4 8}{cmd:stdf} calculates the outcome-specific standard error of the forecast.
This gives the standard deviation of the predicted distribution
of the {hi:true} value of {it:depvar} in a future study
{break}stdf^2 = stdp^2 + tau2.

{p 4 8}{cmd:reffects} calculates the outcome-specific best linear unbiased predictions (BLUPs) of the 
random effects, also known as the posterior mean or empirical Bayes estimates of the random effects,
or as shrunken residuals.

{p 4 8}{cmd:reses} calculates the outcome-specific standard error of predicted random effects.

{p 4 8}{cmd:rstandard} calculates the outcome-specific standardized predicted random effects,
i.e. the predicted random effects u[i] divided by their (unconditional) standard errors.
These may be useful for diagnostics and model checking.

{p 4 8}{cmd:lev} calculates the study-specific leverages


{p 4 8}{cmd:cooksd} calculates the study-specific Cook's influence statistic.

{title:Remarks}

{p 4 4 2}
Similar to other types of data, it is not uncommon to observe extreme effect size values when conducting a meta-analysis. 
As the main objective of a meta-analysis is to provide a reasonable summary of the effect sizes of a body of empirical studies, the presence of such outliers may distort the conclusions of a meta-analysis. 
Moreover, if the conclusions of a meta-analysis hinge on the data of only one or two influential studies, then the robustness of the conclusions are called into question.
Researchers, therefore, generally agree that the effect sizes should be examined for potential outliers and influential cases when conducting a meta-analysis. 

{p 4 4 2}
The most thorough treatment of outlier diagnostics in the context of meta-analysis to date can be found in the classic book by Hedges and Olkin, 
who devoted a whole chapter to diagnostic procedures for effect size data. 
However, the methods developed by  {help umeta#H)1985:Hedges and Olkin(1985)}  are only applicable to fixed-effects models. 
Given that random- and mixed-effects models are gaining popularity in the meta-analytic context, 
corresponding methods for outlier and influential case diagnostics need to be developed.

{p 4 4 2}
 {help umeta#VC2010:Viechtbauer and Cheung(2010)} have introduced several outlier and influence diagnostic procedures for the random- and mixed-effects model in meta-analysis. 
 These procedures are logical extensions of the standard outlier and case-deletion influence diagnostics 
 for regular regression models as in {help umeta#DS2005:Demidenko and Stukel(2005)} and take both sampling variability 
 and between-study heterogeneity into account. The proposed measures provide a simple framework for evaluating the potential impact of outliers or influential cases in meta-analysis.

{title:Examples}

{pstd}

{phang2}{cmd:. use umeta_example5, clear}{p_end}

{phang2}{cmd:. umeta yvar* svar* rho*}{p_end}

{phang2}{cmd:. predict lev, lev show(clean)}{p_end}

{phang2}{cmd:. predict cook, cooksd show(clean)}{p_end}

{phang2}{cmd:. predict  fit, fit}{p_end}

{phang2}{cmd:. predict  fix}{p_end}

{phang2}{cmd:. predict  reff, reff show(clean noobs)}{p_end}

{phang2}{cmd:. predict  res, res}{p_end}

{phang2}{cmd:. predict  rst, rst}{p_end}

{phang2}{cmd:. predict  stpred, stfit}{p_end}



{phang2}{cmd:. predict double stdf, stdf}{p_end}





{title:Author}
{p 4 4 2}
Ben A. Dwamena, Department of Radiology, Division of Nuclear Medicine, University of Michigan Medical School, Ann Arbor, Michigan.
{browse "mailto:bdwamena@umich.edu":bdwamena@umich.edu}.



{title:References}

{marker DS2005}{...}
{phang}
Demidenko, E., T. A. Stukel. 2005
Influence analysis for linear mixed-effects models
{it:Statistics in Medicine} 24: 893–909

{marker DL1986}{...}
{phang}DerSimonian, R., and N. Laird.  1986.  Meta-analysis in clinical trials.
{it:Controlled Clinical Trials} 7: 177-188.

{marker HO1985}{...}
{phang}
Hedges LV, I. Olkin. 1985.
{it:Statistical Methods for Meta-Analysis} Academic Press: New York.

{marker HT2002}{...}
{phang}Higgins, J. P. T., and S. G. Thompson.  2002.  Quantifying heterogeneity
in a meta-analysis. 
{it:Statistics in Medicine} 21: 1539-1558.

{marker HTS2009}{...}
{phang}Higgins, J. P. T., S. G. Thompson, and D. J. Spiegelhalter.  2009.
A re-evaluation of random-effects meta-analysis.
{it:Journal of the Royal Statistical Society, Series A} 172: 137-159.

{marker JWT2010}{...}
{phang}Jackson, D., I. R. White, and S. G. Thompson. 2010.  Extending
DerSimonian and Laird's methodology to perform multivariate random effects
meta-analyses.  
{it:Statistics in Medicine} 29: 1282-1297.

{marker MM2011}{...}
{phang}Ma, Y., and M. Mazumdar. 2011. Multivariate meta-analysis: 
a robust approach based on the theory of U-Statistic.
{it:Statistics in Medicine} 30: 2911-2929.

{marker R2009}{...}
{phang}
Riley, R. D.  2009.  Multivariate meta-analysis: The effect of ignoring
within-study correlation.
{it:Journal of the Royal Statistical Society, Series A} 172: 789-811.


{marker VC2010}{...}
{phang}
Viechtbauer,  W., M. W.-L. Cheung. 2010.
Outlier and influence diagnostics for meta-analysis.
{it:Research Synthesis Methods} 1: 112-125.

{marker W2009}{...}
{phang}
White, I. R.  2009.
Multivariate random-effects meta-analysis.
{it:Stata Journal} 9: 40-56.

{title:Also see}

{p 4 14 2}

{p 7 14 2}Help: {helpb mvmeta} (if installed)
{p_end}




