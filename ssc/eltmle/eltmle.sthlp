{smcl}
{right: version 2.2.4  July 24th, 2019}
{...}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:eltmle}{hline 1}}Ensemble Learning Targeted Maximum Likelihood Estimation{p2colreset}{...}

{title:Syntax}

{p 4 4 2}
{cmd:eltmle} {hi: Y} {hi: X} {hi: Z} [{cmd:,} {it:tmle} {it:tmlebgam} {it:tmleglsrf}]

{p 4 4 2}
where:
{p_end}

{p 4 4 2}
{hi:Y}: Outcome: numeric binary or continuous variable
{p_end}
{p 4 4 2}
{hi:X}: Treatment or exposure: numeric binary variable
{p_end}
{p 4 4 2}
{hi:Z}: Covariates: vector of numeric and categorical variables
{p_end}

{title:Description}

{p 4 4 2 120}
{hi: Modern Epidemiology} has been able to identify significant limitations of classic epidemiological methods, like outcome regression analysis, when estimating causal quantities such as the average treatment effect (ATE) 
for observational data. For example, using classical regression models to estimate the ATE requires making the assumption that the effect measure is constant across levels of confounders included in the model,
 i.e. that there is no effect modification. Other methods do not require this assumption, including g-methods (e.g. the {hi:g-formula}) and targeted maximum likelihood estimation ({hi:TMLE}).
{p_end}

{p 4 4 2 120}
The average treatment effect ({hi:ATE}) or risk difference is the most commonly used causal parameter. Many estimators of the ATE but no all rely on parametric modeling assumptions. Therefore, the correct model specification is crucial 
to obtain unbiased estimates of the true ATE.
{p_end}

{p 4 4 2 120}
TMLE is a semiparametric, efficient substitution estimator allowing for data-adaptive estimation while obtaining valid statistical inference based on the targeted minimum loss-based estimation. TMLE has the advantage of 
being doubly robust. Moreover, TMLE allows inclusion of {hi:machine learning} algorithms to minimise the risk of model misspecification, a problem that persists for competing estimators. Evidence shows that TMLE typically 
provides the {hi: least unbiased} estimates of the ATE compared with other double robust estimators.
{p_end}

{p 4 4 2 120}
The following link provides access to a TMLE tutorial: {browse "http://migariane.github.io/TMLE.nb.html":TMLE_tutorial}.
{p_end}

{p 4 4 2 120}
{hi:eltmle} is a Stata program implementing the targeted maximum likelihood estimation for the ATE for a binary or continuous outcome and binary treatment. {hi:eltmle} includes the use of a super-learner called from the {hi:SuperLearner}
package v.2.0-21 (Polley E., et al. 2011). The Super-Learner uses V-fold cross-validation (10-fold by default) to assess the performance of prediction regarding the potential outcomes and the propensity score as weighted 
averages of a set of machine learning algorithms. We used the default SuperLearner algorithms implemented in the base installation of the {hi:tmle-R} package v.1.2.0-5 (Susan G. and Van der Laan M., 2017), 
which included the following: i) stepwise selection, ii) generalized linear modeling (GLM), iii) a GLM variant that includes second order polynomials and two-by-two interactions of the main terms
included in the model. Additionally, {hi:eltmle} users will have the option to include Bayes Generalized Linear Models and Generalized Additive Models as additional Super-Learner algorithms. Future implementations will offer 
more advanced machine learning algorithms. 
{p_end}

{title:Options}

{p 4 4 2 120}
{hi:tmle}: this is the default option. If no-option is specified eltmle by default implements the
TMLE algorithm plus the super-Learner ensemble learning for the main three machine learning algorithms described above.
{p_end}

{p 4 4 2 120}
{hi:tmlebgam}: this option may be specified or unspecified. When specified, it does include in addition to the above default
implementation, the Bayes Generalized Linear Models and Generalized Additive Models as Super-Learner algorithms for the tmle estimator.
This option might be suitable for non-linear treatment effects.
{p_end}

{p 4 4 2 120}
{hi:tmleglsrf}: this option may be specified or unspecified. When specified, it does include in addition to the three main learning algorithms 
described above, the Lasso (glmnet R package), Random Forest (randomForest R package) and the Generalized Additive Models as Super-Learner algorithms for the tmle estimator.
This option might be suitable for heterogeneous treatment effects.
{p_end}


{title:Resutls}

In addtion to the ATE, the ATE's standard error and p-value, the marginal odds ratio (MOR), and the causal risk ratio (CRR), 
including their respective type Wald 95%CIs, {hi:eltmle} output provides a descriptive summary for the potential outcomes (POM) and the propensity score (ps):
{hi: POM1}: Potential outcome among the treated
{hi: POM0}: Potential outcome among the non-treated
{hi: ps}: Propensity score 


{title:Example}

**********************************************
* eltmle Y X Z [if] [,tmle tmlebgam tmleglsrf] 
**********************************************

.clear
.use http://www.stata-press.com/data/r14/cattaneo2.dta
.describe
.gen lbw = cond(bweight<2500,1,0.)
.lab var lbw "Low birthweight, <2500 g"
.save "your path/cattaneo2.dta", replace
.cd "your path"

******************
// Binary outcome 
******************

******************************************************
.preserve
.eltmle lbw mbsmoke mage medu prenatal mmarried, tmle
.restore
******************************************************

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        POM1 |      4,642    .1022792    .0401342   .0201151   .3747893
        POM0 |      4,642     .051596    .0252501   .0209907   .1735959
          ps |      4,642    .1861267     .110755   .0372202   .8494988
--------------------------------
TMLE: Average Treatment Effect
--------------------------------
ATE:      | 0.0507
SE:       | 0.0122
P-value:  | 0.0001
95%CI:    | 0.0268, 0.0745
--------------------------------
-----------------------------
TMLE: Causal Risk Ratio (CRR)
-----------------------------
CRR: 1.99; 95%CI:(1.53, 2.60)
-----------------------------
-------------------------------
TMLE: Marginal Odds Ratio (MOR)
-------------------------------
MOR: 2.11; 95%CI:(1.50, 2.72)
-------------------------------

**********************
// Continuous outcome 
**********************

***********************************************************
.preserve 
.eltmle bweight mbsmoke mage medu prenatal mmarried, tmle
.restore
***********************************************************

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        POM1 |      4,642    2833.081    74.84581   2580.186   2958.981
        POM0 |      4,642    3062.785    89.55875   2867.102   3166.985
          ps |      4,642    .1861267     .110755   .0372202   .8494988
--------------------------------
TMLE: Average Treatment Effect
--------------------------------
ATE:      | -229.7
SE:       |   24.5
P-value:  | 0.0000
95%CI:    | -277.8, -181.7
--------------------------------
-----------------------------
TMLE: Causal Risk Ratio (CRR)
-----------------------------
CRR: 0.93; 95%CI:(0.91, 0.94)
-----------------------------
-------------------------------
TMLE: Marginal Odds Ratio (MOR)
-------------------------------
MOR: 0.83; 95%CI:(0.80, 0.87)
-------------------------------

***************************************************************
// Continuous outcome and 
// more advance machine learning techniques
***************************************************************

***************************************************************
.preserve
.eltmle bweight mbsmoke mage medu prenatal mmarried, tmleglsrf
.restore
***************************************************************

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        POM1 |      4,642    2834.267    74.94767   2582.177   2964.985
        POM0 |      4,642    3063.768    89.56743   2867.587   3168.283
          ps |      4,642     .154641    .1111959       .025   .6236143
--------------------------------
TMLE: Average Treatment Effect
--------------------------------
ATE:      | -229.5
SE:       |   30.1
P-value:  | 0.0000
95%CI:    | -288.5, -170.5
--------------------------------
-----------------------------
TMLE: Causal Risk Ratio (CRR)
-----------------------------
CRR: 0.93; 95%CI:(0.91, 0.94)
-----------------------------
-------------------------------
TMLE: Marginal Odds Ratio (MOR)
-------------------------------
MOR: 0.83; 95%CI:(0.80, 0.87)
-------------------------------

**********************************************************************************************

{title:Remarks} 

{p 4 4 2 120}
Remember 1: Y must be a binary or continuous variable; X must be numeric binary
variable coded (0, 1) and, Z a vector of numeric covariates. 
{p_end}

{p 4 4 2 120}
Remember 2: You must change your working directory to the location of the Stata.dta file.
{p_end}

{p 4 4 2 120}
Remember 3: Mac users must have installed R software on their personal computer as
eltmle calls R to implement the Super Learner. The R executable file must be located at 
the following path: {hi:"/usr/local/bin/r"}.
{p_end}

{p 4 4 2 120}
Remember 4: Windows users must have installed R software on their personal computer
as eltmle calls R to implement the Super Learner. The R executable file must be located 
at the following path: {hi:"C:\Program Files\R\R-X.X.X\bin\x64\R.exe"} (where X stands for the number of the version).
{p_end}

{p 4 4 2 120}
Remember 5: Windows users must have only one version of R software installed on their personal computer
at the following path: {hi:"C:\Program Files\R\R-X.X.X\bin\x64\R.exe"}. In case more than one different version 
is located in the above highlighted path users would like to keep the latest.
{p_end}

{p 4 4 2 120}
Remember 6: In case you want to preserve the original dataset you can use the 
preserve restore Stata functionality in combination to the Stata {hi: eltmle} command as shown in the previous example.
{p_end}

{title:Stored results}

eltmle stores the following in {hi: r()}:

Scalars

	{hi: r(SE_log_MOR)}          Standard error marginal odds ratio
               {hi: r(MOR)} 		Marginal odds ratio
        {hi: r(SE_log_CRR)} 		Standard error causal risk ratio
        {hi:        r(CRR)} 		Causal risk ratio
        {hi:   r(ATE_UCIa)} 		Risk difference upper 95%CI 
        {hi:   r(ATE_LCIa)} 		Risk difference lower 95%CI
        {hi: r(ATE_pvalue)} 		Risk difference pvalue
        {hi: (ATE_SE_tmle)} 		Standard error Risk difference
        {hi:    r(ATEtmle)} 		Risk difference
		
{title:Version in development: updates}		

{browse "https://github.com/migariane/eltmle/tree/master": https://github.com/migariane/eltmle/tree/master}

{title:References}
	
{p 4 4 2 120}
Miguel Angel Luque‐Fernandez, M Schomaker, B Rachet, M Schnitzer (2018). Targeted maximum likelihood estimation for a binary treatment: A tutorial.
Statistics in medicine. {browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.7628":Download here}.
{p_end}

{p 4 4 2 120}
Miguel Angel Luque-Fernandez (2017). Targeted Maximum Likelihood Estimation for a
Binary Outcome: Tutorial and Guided Implementation {browse "http://migariane.github.io/TMLE.nb.html":Download here}.
{p_end}

{p 4 4 2 120}
StataCorp. 2015. Stata Statistical Software: Release 14. College Station, TX: StataCorp LP.
{p_end}

{p 4 4 2 120}
Gruber S, Laan M van der. (2011). Tmle: An R package for targeted maximum likelihood
estimation. UC Berkeley Division of Biostatistics Working Paper Series.
{p_end}

{p 4 4 2 120}
Laan M van der, Rose S. (2011). Targeted learning: Causal inference for observational
and experimental data. Springer Series in Statistics.626p.
{p_end}

{p 4 4 2 120}
Van der Laan MJ, Polley EC, Hubbard AE. (2007). Super learner. Statistical applications
in genetics and molecular biology 6.
{p_end}

{title:Author and developer}

{phang}Miguel Angel Luque-Fernandez{p_end}
{phang}Biomedical Research Institute of Granada, Noncommunicable Disease and Cancer Epidemiolgy Group. University of Granada,
Granada, Spain.{p_end}
{phang}Department of Epidemiology and Population Health, London School of Hygiene and Tropical Medicine. 
London, UK.{p_end}
{phang}E-mail: {browse "mailto:miguel-angel.luque@lshtm.ac.uk":miguel-angel.luque@lshtm.ac.uk}{p_end}  

{title:Also see}

{psee}
Online:  {helpb teffects}
{p_end}
