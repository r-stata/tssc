{smcl}
{* *! version 5.0.3 27Dec2019}{...}
{cmd:help diff} 
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: diff} {hline 2}}Difference in differences estimation{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:diff}
{it:outcome_var}
{ifin}
{weight}
{cmd:,}[ {it:options}]


{title:Description}

{pstd}
{opt diff} runs several difference in differences (diff-in-diff) treatment effect estimations of 
a given outcome variable from a pooled baseline and follow up dataset: Single Diff-in-Diff, Diff-in-Diff
 accounting for covariates, Kernel Propensity Score Matching diff-in-diff, and the Quantile Diff-in-Diff.
{opt diff} is also suitable for estimating repeated cross sections diff-in-diff (including the {opt k:ernel} option)
 and the triple difference-in-differences analysis.


{title:Options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model - Required}
{synopt :{opt p:eriod(varname)}}Indicates the binary period variable (0: before; 1: after). Note: if your data contains a periodical 
frequency (monthly, quarterly, yearly, etc.), it is suggested to specify option {opt p:eriod(varname)} and include a binary variable
for each frequency in option {opt c:ov(varlist)}.{p_end}
{synopt :{opt t:reated(varname)}}Indicates the binary treatment variable (0: controls; 1:treated).{p_end}

{syntab: Optional}
{synopt :{opt c:ov(varlist)}}Specifies the pre-treatment covariates of the model. Also use this option to specify time fixed-effects
in the case of multiple time-frequency data (e.g. monthly, yearly, quarterly, etc.). When
option {opt k:ernel} is selected these variables are used to estimate the propensity score.{p_end}
{synopt :{opt k:ernel}}Performs the Kernel-based Propensity Score Matching diff-in-diff. This option
generates  the variable _weights containing the weights derived from the Kernel Propensity Score Matching,
and _ps when the Propensity Score is not supplied in {opt ps:core(varname)}, following {stata "ssc des psmatch2" :Leuven and Sianesi (2014)}.  
This option requires the {it: id(varname)} of each unit or individual except under the repeated cross section 
{opt rcs}) setting.{p_end}
{synopt :{opt id(varname)}}Option {it: kernel} requires the supply of the identification variable.{p_end}
{synopt :{opt bw(#)}}Supplied bandwidth of the Kernel function. The default bandwidth is 0.06.{p_end}
{synopt :{opt kt:ype(kernel)}}Specifies the type of the Kernel function. The types are {it:epanechnikov} (the default),
{it:gaussian}, {it:biweight}, {it:uniform} and {it:tricube}.{p_end}
{synopt :{opt rcs}}Indicates that the {opt k:ernel} is set for repeated cross section. This option
does not require option {opt id(varname)}. Option {opt rcs} strongly assumes that covariates in {opt c:ov(varlist)}
do not vary over time.{p_end}
{synopt :{opt qd:id(quantile)}}Performs the Quantile Difference in Differences estimation at the specified
 quantile from 0.1 to 0.9 (quantile 0.5 performs the QDID at the medeian). You may combine this option with
 {opt k:ernel} and {opt c:ov}. {opt qd:id} does not support weights nor robust standard errors.
 This option uses {manhelp qreg R} and {manhelp bsqreg R} for bootstrapped standard errors{p_end}
{synopt :{opt ps:core(varname)}}Supplied Propensity Score.{p_end}
{synopt :{opt lo:git}}Specifies logit estimation of the Propensity Score. The default is Probit.{p_end}
{synopt :{opt sup:port}}Performs {opt diff} on the common support of the propensity score given the option {opt k:ernel}.{p_end}
{synopt :{opt add:cov(varlist)}}Indicates additional covariates in addition to those specified
in the estimation of the propensity score. Also use this option to specify time fixed-effects
in the case of multiple time-frequency data (e.g. monthly, yearly, quarterly, etc.).{p_end}
{synopt :{opt ddd(varname)}}Additional category for triple difference estimation. {opt t:reated(varname)} is deemed as the
first category and {opt ddd(varname)} the second category. This option is not compatible with options {opt k:ernel}, {opt test}
or {opt qd:id(quantile)}.{p_end}

{syntab:SE/Robust}
{synopt :{opt cl:uster(varname)}}Calculates clustered Std. Errors by {it: varname}.{p_end}
{synopt :{opt robust}}Calculates robust Std. Errors.{p_end}
{synopt :{opt bs}}performs a Bootstrap estimation of coefficients and standard errors.{p_end}
{synopt :{opt r:eps(int)}}Specifies the number of repetitions when the {opt bs} is
selected. The default are 50 repetitions.{p_end}

{syntab:Balancing test}
{synopt :{opt test}}Performs a balancing t-test of the difference in the means of the  
covariates between the control and treated groups in period == 0. The option {it: test} 
combined with {it: kernel} performs the balancing t-test with the weighted covariates.
See {manhelp ttest R}{p_end}

{syntab:Reporting}
{synopt :{opt rep:ort}}Displays the inference of the included covariates or the
estimation of the Propensity Score when option {opt kernel} is specified.{p_end}
{synopt :{opt nos:tar}}Removes the inference stars from the p-values.{p_end}

{synoptline}
{p 4 6 2}

{title:Exporting results}

{phang}    You can export your results with {stata "ssc des outreg2" :outreg2}. Run the following command after {cmd: diff}
with double difference:{p_end}
{col 9}{phang}{txt}outreg2 using table_diff, ctitle(`r(depvar)') addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label  adec(3) excel  keep(_diff) nocons{p_end}

{phang}    Run the following command after {cmd: diff} with triple difference:{p_end}
{col 9}{phang}{txt}outreg2 using output, ctitle(`r(depvar)') addstat(Mean control - A t(0), r(mean_c0a), Mean control - B t(0), r(mean_c0b), Mean treated A - t(0),	r(mean_t0a), Mean treated B - t(0),	r(mean_t0b), Diff t(0), r(diff0), Mean control - A t(1), r(mean_c1a), Mean control - B t(1), r(mean_c1b), Mean treated - A t(1), r(mean_t1a), Mean treated - B t(1), r(mean_t1b), Diff t(1), r(diff1)) label excel keep(_diff) nocons dec(4) {p_end}

{phang}    Results will be stored in the working directory (also see {cmd: help outreg2} for further options).{p_end}

{synoptline}
{p 4 6 2}


{title:Example}

{phang} 1. Diff-in-Diff with no covariates.{p_end}
{phang} We use the dataset form Card & Krueger (1994)*.{p_end}

{col 9}{stata "use http://fmwww.bc.edu/repec/bocode/c/CardKrueger1994.dta" : use "http://fmwww.bc.edu/repec/bocode/c/CardKrueger1994.dta"}

{col 9}{stata "diff fte, t(treated) p(t)" : diff fte, t(treated) p(t)}

{phang} For bootstrapped std. err.:{p_end}

{col 9}{stata "diff fte, t(treated) p(t) bs rep(50)" : diff fte, t(treated) p(t) bs rep(50)}

{phang} 2. Diff-in-Diff with covariates.{p_end}

{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys)" : diff fte, t(treated) p(t) cov(bk kfc roys)}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) report" : diff fte, t(treated) p(t) cov(bk kfc roys) report}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) report bs" : diff fte, t(treated) p(t) cov(bk kfc roys) report bs}

{phang} 3. Kernel Propensity Score Diff-in-Diff.{p_end}

{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id)" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id)}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id) support" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id) support}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id) support addcov(wendys)" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel id(id) support addcov(wendys)}
{col 9}{stata "diff fte, t(treated) p(t) kernel id(id) ktype(gaussian) pscore(_ps)" : diff fte, t(treated) p(t) kernel id(id) ktype(gaussian) pscore(_ps)}
{col 9}{stata "diff fte, t(treated) p(t) kernel id(id) ktype(gaussian) pscore(_ps) bs reps(50)" : diff fte, t(treated) p(t) kernel id(id) ktype(gaussian) pscore(_ps) bs reps(50)}

{phang} 3. Kernel Propensity Score Diff-in-Diff (Repeated Cross Section - rcs).{p_end}

{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support addcov(wendys)" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support addcov(wendys)}
{col 9}{stata "diff fte, t(treated) p(t) kernel rcs ktype(gaussian) pscore(_ps)" : diff fte, t(treated) p(t) kernel rcs ktype(gaussian) pscore(_ps)}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support addcov(wendys) bs reps(50)" : diff fte, t(treated) p(t) cov(bk kfc roys) kernel rcs support addcov(wendys) bs reps(50)}

{phang} 4. Quantile Diff-in-Diff.{p_end}

{col 9}{stata "diff fte, t(treated) p(t) qdid(0.25)" : diff fte, t(treated) p(t) qdid(0.25)}
{col 9}{stata "diff fte, t(treated) p(t) qdid(0.50)" : diff fte, t(treated) p(t) qdid(0.50)}
{col 9}{stata "diff fte, t(treated) p(t) qdid(0.75)" : diff fte, t(treated) p(t) qdid(0.75)}
{col 9}{stata "diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys)" : diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys)}
{col 9}{stata "diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys) kernel id(id)" : diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys) kernel id(id)}
{col 9}{stata "diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys) kernel id(id)" : diff fte, t(treated) p(t) qdid(0.50) cov(bk kfc roys) kernel rcs}

{phang} 5. Balancing test of covariates.{p_end}

{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys wendys) test" : diff fte, t(treated) p(t) cov(bk kfc roys wendys) test}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys wendys) test id(id) kernel" : diff fte, t(treated) p(t) cov(bk kfc roys wendys) test id(id) kernel}
{col 9}{stata "diff fte, t(treated) p(t) cov(bk kfc roys wendys) test rcs kernel" : diff fte, t(treated) p(t) cov(bk kfc roys wendys) test kernel rcs}

{phang} 6. Triple differences (consider bk is a second treatment category).{p_end}

{col 9}{stata "diff fte, t(treated) p(t) ddd(bk)" : diff fte, t(treated) p(t) ddd(bk)}


{title:Saved results}

{phang} {cmd: diff} saves the following list of scalars in {cmd: r()}:{p_end}

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}			total number of observations.{p_end}
{synopt:{cmd:r(N_t0)}}			number of observations in period == 0.{p_end}
{synopt:{cmd:r(N_t1)}}			number of observations in period == 1.{p_end}
{synopt:{cmd:r(R2)}}			R-square{p_end}
{synopt:{cmd:r(mean_c0)}}		mean of {it:output_var} of the control group in period == 0{p_end}
{synopt:{cmd:r(mean_c0a)}}		mean of {it:output_var} of the control group A in period == 0{p_end}
{synopt:{cmd:r(mean_c0b)}}		mean of {it:output_var} of the control group B in period == 0{p_end}
{synopt:{cmd:r(mean_t0)}}		mean of {it:output_var} of the treated group in period == 0{p_end}
{synopt:{cmd:r(mean_t0a)}}		mean of {it:output_var} of the treated group A in period == 0{p_end}
{synopt:{cmd:r(mean_t0b)}}		mean of {it:output_var} of the treated group B in period == 0{p_end}
{synopt:{cmd:r(diff0)}}			difference of the mean of {it:output_var} between treated and 
control groups in period == 0{p_end}
{synopt:{cmd:r(mean_c1)}}		mean of {it:output_var} of the control group in period == 1{p_end}
{synopt:{cmd:r(mean_c1a)}}		mean of {it:output_var} of the control group A in period == 1{p_end}
{synopt:{cmd:r(mean_c1b)}}		mean of {it:output_var} of the control group B in period == 1{p_end}
{synopt:{cmd:r(mean_t1)}}		mean of {it:output_var} of the treated group in period == 1{p_end}
{synopt:{cmd:r(mean_t1a)}}		mean of {it:output_var} of the treated group A in period == 1{p_end}
{synopt:{cmd:r(mean_t1b)}}		mean of {it:output_var} of the treated group B in period == 1{p_end}
{synopt:{cmd:r(diff1)}}			difference of the mean of {it:output_var} between treated and 
control groups in period == 1{p_end}
{synopt:{cmd:r(did)}}			differences in differences - Treatment Effect {p_end}
{synopt:{cmd:r(se_c0)}}			Standard error of the mean of {it:output_var} of the control group 
in period == 0{p_end}
{synopt:{cmd:r(se_c0a)}}		Standard error of the mean of {it:output_var} of the control group A 
in period == 0{p_end}
{synopt:{cmd:r(se_c0b)}}		Standard error of the mean of {it:output_var} of the control group B 
in period == 0{p_end}
{synopt:{cmd:r(se_t0)}}			standard errors of the mean of {it:output_var} of the treated group 
in period == 0{p_end}
{synopt:{cmd:r(se_t0a)}}		standard errors of the mean of {it:output_var} of the treated group A 
in period == 0{p_end}
{synopt:{cmd:r(se_t0b)}}		standard errors of the mean of {it:output_var} of the treated group B 
in period == 0{p_end}
{synopt:{cmd:r(se_d0)}}			standard Errors of the difference of {it:output_var} between the 
treated and control groups in period == 0 {p_end}
{synopt:{cmd:r(se_c1)}}			standard errors of the mean of {it:output_var} of the control group 
in period == 1{p_end}
{synopt:{cmd:r(se_c1a)}}		standard errors of the mean of {it:output_var} of the control group A 
in period == 1{p_end}
{synopt:{cmd:r(se_c1b)}}		standard errors of the mean of {it:output_var} of the control group B 
in period == 1{p_end}
{synopt:{cmd:r(se_t1)}}			standard errors of the mean of {it:output_var} of the treated group 
in period == 1{p_end}
{synopt:{cmd:r(se_t1a)}}		standard errors of the mean of {it:output_var} of the treated group A 
in period == 1{p_end}
{synopt:{cmd:r(se_t1b)}}		standard errors of the mean of {it:output_var} of the treated group B 
in period == 1{p_end}
{synopt:{cmd:r(se_d1)}}			standard errors of the difference of {it:output_var} between the 
treated and control groups in == 0 {p_end}
{synopt:{cmd:r(se_dd)}}			standard errors of the difference in difference{p_end}
{synopt:{cmd:r(se_dd)}}			standard errors of the difference in difference{p_end}
{p2colreset}{...}

{title:Recommended references}

Single diff-in-diff:

{phang}Card, D., Krueger, A. "Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania".
 The American Economic Review, Vol. 84, No. 4 (Sep., 1994), pp. 772-793.{p_end}

Kernel diff-in-diff:

{phang}Heckman, J., Ichimura, H., Todd, P. "Matching As an Econometric Evaluation Estimator". The Review of Economic Studies, Vol. 65,
No. 2 (Apr., 1998), pp. 261-294.{p_end}

{phang}Leuven, E., Sianesi, B. 2014. "PSMATCH2: Stata module to perform full Mahalanobis and propensity score matching, 
common support graphing, and covariate imbalance testing, Statistical Software Components". Boston College Department of Economics.{p_end}

Kernel diff-in-diff (repeated cross section):

{phang}Blundell, R., Dias, M. "Alternative Approaches to Evaluation in Empirical Microeconomics". Journal of Human Resources, Vol. 44,
No. 3 (Jun., 2009), pp. 565-640.{p_end}

Quantile diff-in-diff:

{phang}Meyer, B., Viscusi, W. "Workers' Compensation and Injury Duration: Evidence from a Natural Experiment". The American 
Economic Review, Vol. 85, No.3 (Jun., 1995), pp. 322-340.{p_end}

Triple difference in differences:

{phang}Imbens, G., Wooldridge, J. "Difference-in-Differences Estimation. Lecture Notes 10, Summer '07". NBER (Jul., 2007), pp. 322-340.{p_end}

{title:Author}

{phang}Juan M. Villa{p_end}
{phang}Global Development Institute{p_end}
{phang}The University of Manchester{p_end}
{phang}juan.villa@manchester.ac.uk{p_end}

{phang}Colpensiones{p_end}
{phang}{p_end}

{phang}Please cite as: Villa, J.M., 2016. diff: Simplifying the estimation of 
difference-in-differences treatment effects. Stata Journal 16, pp. 52-71.{p_end}

{phang}This version: December - 2019.{stata "ssc install diff, replace" : Click here periodically} to get the lastest version.{p_end}
{phang}*Acknowledgements to Kit Baum for valuable comments. The Kernel matching is based on the command {stata "ssc des psmatch2":psmatch2} developved by Edwin 
Leuven and Barbara Sianesi.{p_end}

