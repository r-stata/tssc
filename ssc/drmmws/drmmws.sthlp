{smcl}
{* *! version 1.0.0 06Jan2017}{...}

{title:Title}

{p2colset 5 15 20 2}{...}
{p2col:{hi:drmmws} {hline 2}} Doubly-robust marginal mean weighting through stratification  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{p 8 12 2}
{cmd:drmmws}
{cmd:}{it:{help varname:outcome}} 
{cmd:}{it:{help varname:treatvar}}
{cmd:}[{it:{help varlist:indepvars}}] 
{ifin} 
[{cmd:,} {opt o:vars}({it:{help varlist:varlist}}) 
{opt p:vars}({it:{help varlist:varlist}}) 
{opt nstr:ata}({it:integer}) 
{opt f:amily}({it:{help glm##familyname:familyname}})
{opt l:ink}({it:{help glm##linkname:linkname}})
{opt att}
{opt med:ian}
{opt comm:on}
{opt seed}({it:integer})
{opt reps}({it:integer}) ]


{p 4 4 2}
{it:treatvar} must be binary and coded 0 for the control group and 1 for the treatment group.

{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt o:vars}{cmd:(}{it:{help varlist:varlist}}{cmd:)}} specifies the covariates in the outcome model {p_end}
{synopt:{opt p:vars}{cmd:(}{it:{help varlist:varlist}}{cmd:)}} specifies the covariates in the treatment assignment model (propensity score)  {p_end}
{synopt:{opt nstr:ata}{cmd:(}{it:integer}{cmd:)}} specifies the number of quantiles of the propensity score to generate; default is 5 {p_end}
{synopt :{opth f:amily(glm##familyname:familyname)}} distribution of the outcome variable; default is {cmd:family(gaussian)}{p_end}
{synopt :{opth l:ink(glm##linkname:linkname)}} link function; default is {cmd:link(identity)}{p_end}
{synopt:{opt att}} estimates average treatment effect on the treated; default is the average treatment effect in the population {p_end}
{synopt:{opt med:ian}} estimates median treatment effects. Can be combined with {cmd:att} to estimate the median treatment effect on the treated {p_end}
{synopt:{opt comm:on}} restricts the analysis to only those units within the region of common support {p_end}
{synopt:{opt seed}{cmd:(}{it:integer}{cmd:)}} sets the random-number seed for the bootstrap procedure {p_end}
{synopt:{opt reps}{cmd:(}{it:integer}{cmd:)}} specifies the number of replications to be performed in the bootstrap procedure; default is 200 {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it: ovars} and {it: pvars} may contain factor variables; see {help fvvarlists:fvvarlists}.{p_end}

{p 4 6 2}

{title:Description}

{pstd}
{opt drmmws} estimates doubly-robust effects of a binary treatment on an outcome, controlling for observed confounding variables (See Linden [2017a] for details of the method). 
{opt drmmws} use weighted regression coefficients to compute averages (or medians) of each treatment group's predicted outcome distribution, with weights computed for each observation 
based on their actual treatment assignment and stratum (See Hong [2010, 2012], and Linden [2014]). The contrast of these averages (or medians) estimates the treatment effects. 
{opt drmmws} estimates the potential-outcome means (or medians) for each treatment group, and the average (or median) treatment effect (ATE, MTE), or the average (or median) 
treatment effect on the treated (ATT, MTE). Standard errors, {it:p} values, and confidence intervals are computed using a bootstrap procedure which incorporates estimation of both 
the propensity score and outcome models.

{pstd}
{opt drmmws} requires the user-written program {help mmws} to be installed.


{title:Remarks}

{pstd}
 By default {opt drmmws} generates 5 quantiles of the propensity score (Rosenbaum & Rubin [1984] have shown that stratifying the propensity score into 5 quantiles 
can remove over 90% of the initial bias due to the covariates used to generate the propensity score). However, the user should consider identifying the optimal 
stratification solution for the specific data at hand. This can be accomplished by first running the user-written program {help pstrata} to determine how many quantiles
are necessary to achieve balance on the propensity score (Linden [2017b] found that {help pstrata} consistently achieved better covariate balance and reduced bias when compared
to 5 quantiles). Once the optimal number of quantiles has been determined, this value can be passed on to {opt drmmws} in the {opt nstrata()} option.



{title:Options}

{p 4 8 2}
{cmd:ovars(}{it:varlist}{cmd:)} specifies the covariates to be used in the outcome model. If no {it:ovars} are set, all the variables in {it:indepvars} are used. 

{p 4 8 2}
{cmd:pvars(}{it:varlist}{cmd:)} specifies the covariates to be used in the propensity score model. If no {it:pvars} are set, all the variables in {it:indepvars} are used. 

{p 4 8 2}
{cmd:nstrata(}{it:#}{cmd:)} specifies the number of quantiles of the propensity score to generate. The default is 5, however, the user should consider running {help pstrata} 
to determine the optimal number of quantiles for the given dataset.

{p 4 8 2}
{cmd:family(}{it:familyname}{cmd:)} uses the probability distribution of the generalized linear outcome model. See {help glm##familyname:familyname} for all available options.

{p 4 8 2}
{cmd:link(}{it:linkname}{cmd:)}is the link function of the generalized linear outcome model. See {help glm##linkname:linkname} for all available options.

{p 4 8 2}
{cmd:att} specifies that {opt drmmws} should estimate the average treatment effect on the treated (ATT). The default is to estimate the average treatment effect in the population (ATE).

{p 4 8 2}
{cmd:median} specifies that {opt drmmws} should estimate the median treatment effect (estimated using quantile regression). {opt median} can be combined with the {opt att} option to
estimate the median treatment effect on the treated (MTT).

{p 4 8 2}
{cmd:common} restricts the analysis to only those units within the region of common support. {opt drmmws} generates weights for those observations within the region of common 
	support, and gives a weight of zero to observations not on common support.  An indicator or dummy variable named _support is added to the dataset to identify the observations 
	on common support.

{p 4 8 2}
{cmd:seed(}{it:#}{cmd:)} sets the random-number seed for the bootstrap procedure.
	
{p 4 8 2}
{cmd:reps(}{it:#}{cmd:)} specifies the number of bootstrap replications to be performed.  The default is 200.  A total of 50-200 replications are generally adequate for estimates of standard error
        and thus are adequate for normal-approximation confidence intervals; see Mooney and Duval [1993, 11].  Estimates of confidence intervals using the percentile or bias-corrected
        methods typically require 1,000 or more replications.


    
{title:Variables added to the dataset}

{pstd} {cmd:drmmws} generates several variables for the convenience of the user. These variables will be replaced automatically after each run, so rename them if you'd like to retain them:{p_end}

{p 5 15 15}{opt _strata} will be the result of the chosen option in {opt nstrata()}{p_end}

{p 5 17 15}{opt _support} is an indicator or dummy variable indicating whether an observation is on common support{p_end}

{p 5 17 15}{cmd:_mmws} is the weight generated by {cmd:drmmws}. The variable label will provide a brief description{p_end}
		
        

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse cattaneo2, clear}

{pstd}Estimate the average treatment effect of smoking on birthweight, using 5 stata {p_end}
{phang2}{cmd: . drmmws bweight mbsmoke, ovars(prenatal1 mmarried mage fbaby) pvars(mmarried c.mage##c.mage fbaby medu) nstrata(5)}

{pstd}Assess the ATE as a percentage of the mean birthweight that would occur if no mothers smoke. {p_end}
{phang2}{cmd: . nlcom _b[teffect] / _b[poms0]}

{pstd}Estimate the median treatment effect of smoking on birthweight, using 5 stata {p_end}
{phang2}{cmd: . drmmws bweight mbsmoke, ovars(prenatal1 mmarried mage fbaby) pvars(mmarried c.mage##c.mage fbaby medu) nstrata(5) median}

{pstd}Refit the above model, but estimate median treatment effects on the treated {p_end}
{phang2}{cmd: . drmmws bweight mbsmoke, ovars(prenatal1 mmarried mage fbaby) pvars(mmarried c.mage##c.mage fbaby medu) nstrata(5) att median}

{pstd}Refit the above model, but limit the analysis to individuals on common support, and set the number of bootstrap reps to 1,000 {p_end}
{phang2}{cmd: . drmmws bweight mbsmoke, ovars(prenatal1 mmarried mage fbaby) pvars(mmarried c.mage##c.mage fbaby medu) nstrata(5) att median common reps(1000)}

{pstd}Get produce a table of additional boostrap confidence intervals{p_end}
{phang2}{cmd: . estat bootstrap, all}



{title:Saved results}

{p 4 8 2}
{cmd:drmmws} returns the following bootstrap results in {cmd: e()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}

{synopt:{cmd:e(level)}}confidence level for bootstrap CIs{p_end}
{synopt:{cmd:e(N_reps)}}number of complete replications{p_end}
{synopt:{cmd:e(N_misreps)}}number of incomplete replications{p_end}
{synopt:{cmd:e(bs_version)}}version for {cmd:bootstrap} results{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_exp)}}number of standard expressions{p_end}
{synopt:{cmd:e(k_eexp)}}number of extended expressions (i.e., {cmd:_b}){p_end}
{synopt:{cmd:e(k_extra)}}number of extra equations beyond the original ones from {cmd:e(b)}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}same as {cmd:e(cmdname)} or {cmd:bootstrap}{p_end}
{synopt:{cmd:e(cmdname)}}command name from {it:command}{p_end}
{synopt:{cmd:e(prefix)}}{cmd:bootstrap}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(rngstate)}}random-number state used{p_end}
{synopt:{cmd:e(exp}{it:#}{cmd:)}}expression for the {it:#}th statistic{p_end}
{synopt:{cmd:e(command)}}{it:command}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(vce)}}{cmd:bootstrap}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}observed statistics{p_end}
{synopt:{cmd:e(V)}}bootstrap variance-covariance matrix{p_end}
{synopt:{cmd:e(b_bs)}}bootstrap estimates{p_end}
{synopt:{cmd:e(reps)}}number of nonmissing results{p_end}
{synopt:{cmd:e(bias)}}estimated biases{p_end}
{synopt:{cmd:e(z0)}}median biases{p_end}
{synopt:{cmd:e(se)}}estimated standard errors{p_end}
{synopt:{cmd:e(ci_normal)}}normal-approximation CIs{p_end}
{synopt:{cmd:e(ci_percentile)}}percentile CIs{p_end}
{synopt:{cmd:e(ci_bc)}}bias-corrected CIs{p_end}


{title:References}

{p 4 8 2}
Hong, G. 2010. Marginal mean weighting through stratification: adjustment for selection bias in multilevel data. 
{it:Journal of Educational and Behavioral Statistics} 35: 499-531.

{p 4 8 2}
Hong, G. 2012. Marginal mean weighting through stratification: a generalized method for evaluating multi-valued 
and multiple treatments with non-experimental data. {it:Psychological Methods} 17: 44-60.

{p 4 8 2}
Linden, A. 2014. Combining propensity score-based stratification and weighting to improve 
causal inference in the evaluation of health care interventions. {it:Journal of Evaluation in Clinical Practice} 20: 1065-1071.

{p 4 8 2}
Linden, A. 2017a. Improving casual inference with a doubly robust estimator that combines propensity score stratification and weighting. 
{it:Journal of Evaluation in Clinical Practice} DOI:10.1111/jep.12714

{p 4 8 2}
Linden, A. 2017b. A comparison of approaches for stratifying on the propensity score to reduce bias. 
{it:Journal of Evaluation in Clinical Practice} DOI:10.1111/jep.12701

{p 4 8 2}
Mooney, C. Z., and R. D. Duval. 1993. {browse "http://www.stata.com/bookstore/banasi.html":{it:Bootstrapping: A Nonparametric Approach to Statistical Inference}.}
Newbury Park, CA: Sage.

{p 4 8 2}
Rosenbaum P.R, and D. B. Rubin. 1984. Reducing bias in observational studies using subclassification on the propensity score. 
{it:Journal of the American Statistical Association} 79: 516-524.


{marker citation}{title:Citation of {cmd:drmmws}}

{p 4 8 2}{cmd:drmmws} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel. 2017. 
drmmws: Stata module for implementing doubly-robust marginal mean weighting through stratification.{p_end}


{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}


{title:Acknowledgments} 

{p 4 4 2}
I wish to thank Chuck Huber for trouble-shooting an error in the bootstrap procedure, and to John Moran for beta-testing the program.{p_end}


{title:Also see}

{p 4 8 2}Online:  {helpb xtile}, {helpb glm}, {helpb teffects}, {helpb bootstrap}, {helpb mmws} (if installed), 
 {helpb pstrata} (if installed), {helpb covbal} (if installed) {p_end}



