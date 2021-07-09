{smcl}
{* *! version 1.0.0 18Jun2020}{...}

{title:Title}

{p2colset 5 15 16 2}{...}
{p2col:{hi:rwrmed} {hline 2}} Causal mediation analysis using regression-with-residuals  {p_end}
{p2colreset}{...}


{title:Syntax}


{p 8 14 2}
{cmd:rwrmed} 
{depvar}
[{help indepvars:lvars}]
{ifin} 
[{it:{help weight:pweight}}] 
{cmd:,}
{cmdab:avar(}{it:{help varname:varname}}{cmd:)}
{cmdab:mvar(}{it:{help varname:varname}}{cmd:)}
{opt a(#)}
{opt astar(#)}
{opt m(#)}
[ {opt mreg(string)} 
{cmdab:cvar(}{it:{help varlist:varlist}}{cmd:)}
{cmdab:cat(}{it:{help varlist:varlist}}{cmd:)}
{opt nointer:action}
{opt cxa}
{opt cxm}
{opt lxm}
{opt noi:sily}
{opt boot:strap}[{cmd:(}{it:{help bootstrap##options:bootstrap_options}}{cmd:)}]
{it:model_options}
]

{pstd}
{it:lvars} are post-treatment covariates



{synoptset 32 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opt avar}{cmd:(}{it:varname}{cmd:)}}specify the treatment (exposure) variable {p_end}
{p2coldent:* {opt mvar}{cmd:(}{it:varname}{cmd:)}}specify the mediator variable  {p_end}
{p2coldent:* {opt a}{cmd:(}{it:#}{cmd:)}}set the reference level of treatment  {p_end}
{p2coldent:* {opt astar}{cmd:(}{it:#}{cmd:)}}set the alternative level of treatment  {p_end}
{p2coldent:* {opt m}{cmd:(}{it:#}{cmd:)}}set the level of the mediator at which the controlled direct effect 
is evaluated. If there is no treatment-mediator interaction, then the controlled direct effect
is the same at all levels of the mediator and thus an arbitary value can be chosen {p_end}
{synopt:{opt mreg}{cmd:(}{it:string}{cmd:)}}specify the form of regression model to be estimated for the mediator variable. 
Options are {opt reg:ress}, {opt log:it}, or {opt poi:sson}; {cmd: default is {opt reg:ress}}  {p_end}
{synopt:{opt cvars}{cmd:(}{it:varlist}{cmd:)}}specify the pre-treatment covariates to be included in the analysis {p_end}
{synopt:{opt cat}{cmd:(}{it:varlist}{cmd:)}}specify which of the {cmd: cvars} and {cmd: lvars} should be handled as categorical variables  {p_end}
{synopt:{opt nointer:action}}specify that a treatment-mediator interaction should not be included in the outcome model  {p_end}
{synopt:{opt cxa}}specify that treatment-covariate interactions should be included in the mediator and outcome models  {p_end}
{synopt:{opt cxm}}specify that mediator-covariate interactions should be included in the outcome model  {p_end}
{synopt:{opt lxm}}specify that mediator-posttreatment interactions should be included in the outcome model  {p_end}
{synopt:{opt noi:sily}}display GSEM output tables; this option is not available with {cmd:bootstrap}  {p_end}
{synopt:{opt boot:strap}[{cmd:(}{it:bootstrap_options}{cmd:)]}}specify that bootstrap replications be used to estimate the variance-covariance matrix. 
All {helpb bootstrap} options are available {p_end}
{synopt:{it:model_options}}specify any option available for {helpb gsem} {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* required option.
{p_end}
{marker weight}{...}
{p 4 6 2}{opt pweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}{opt vce(robust)} and {cmd:vce(}{opt cl:uster} {it:clustvar}{cmd:)} are allowed.{p_end}
{p 4 6 2}


{title:Description}

{pstd}{cmd:rwrmed} performs causal mediation analysis using regression-with-residuals. Using {helpb gsem}, two models are estimated: a 
model for the mediator conditional on treatment and the pre-treatment covariates (if specified) after centering them 
around their sample means, and a model for the outcome conditional on treatment, the mediator, the pre-treatment covariates 
(if specified) after centering them around their sample means, and the post-treatment covariates (if specified) after 
centering them around their estimated conditional means given all prior variables. Thus {cmd:rwrmed} allows for the presence of treatment-induced confounders, 
which are post-treatment covariates that confound the mediator-outcome relationship.

{pstd}{cmd:rwrmed} uses {opt reg:ress} for the outcome, and requires the user to specify an appropriate form for the mediator model ({opt reg:ress}, {opt log:it}, or {opt poi:sson}). 
Post-treatment covariates are residualized with respect to treatment and the pre-treatment covariates.

{pstd}{cmd:rwrmed} provides estimates of the controlled direct effect and then the randomized intervention analogues to 
the natural direct effect, the natural indirect effect, and the total effect when a set of measured post-treatment covariates
are included in {opt lvars}. When post-treatment covariates are not included in {opt lvars}, the command instead 
provides estimates of the conventional natural direct and indirect effects and the conventional total effect. 

{pstd}By default, standard errors and confidence intervals for mediation effect estimates are derived by {helpb margins} with 
the {cmd:vce(unconditional)} option. However, bootstrapped standard errors are preferred when post-treatment covariates 
are included in the model (i.e. by specifying {cmd: lvars}) because the boostrap procedure properly accounts for the uncertainty 
that arises from estimating the models used to residualize the post-treatment covariates, whereas the analytic standard errors do not.  {p_end}


{title:Assumptions}

{pstd}Let C be the measured pre-treatment covariates included in {opt cvars(varlist)}, and let L be the measured post-treatment covariates
included in {opt lvars(varlist)}. Obtaining consistent estimates of the controlled direct effect requires two main assumptions: {p_end}

{phang2}(1) There are no unmeasured treatment-outcome confounders given C {p_end}
{phang2}(2) There are no unmeasured mediator-outcome confounders given C and L {p_end}

{pstd}Obtaining consistent estimates of the randomized intervention analogues to natural direct and indirect effects requires assumptions (1) 
and (2) and then an additional assumption: {p_end}

{phang2}(3) There are no unmeasured treatment-mediator confounders given C {p_end}

{pstd}Note that assumptions (1) and (3) are satisified by random assignment of the treatment variable. See references for further details. {p_end}


{title:Options}

{p 4 8 2}
{cmd:avar(}{it:varname}{cmd:)} specifies the treatment (exposure) variable; {cmd:avar() is required}. 

{p 4 8 2}
{cmd:mvar(}{it:varname}{cmd:)} specifies the mediator variable; {cmd:mvar() is required}.

{p 4 8 2}
{cmd:a(}{it:#}{cmd:)} sets the reference level of treatment; {cmd:a() is required}.

{p 4 8 2}
{cmd:astar(}{it:#}{cmd:)} sets the alternative level of treatment. Together, (astar - a) defines
the treatment contrast of interest; {cmd:astar() is required}.

{p 4 8 2}
{cmd:m(}{it:#}{cmd:)} sets the level of the mediator at which the controlled direct effect 
is evaluated. If there is no treatment-mediator interaction, then the controlled direct effect
is the same at all levels of the mediator and thus an arbitary value can be chosen; {cmd:m() is required}.

{p 4 8 2}
{opt mreg}{cmd:(}{it:string}{cmd:)} specifies the form of regression model to be estimated for the mediator variable. 
Options include {opt reg:ress}, {opt log:it}, and {opt poi:sson}; {cmd: default is {opt reg:ress}}. 

{p 4 8 2}
{opt cvars}{cmd:(}{it:varlist}{cmd:)} specifies the pre-treatment covariates to be included in the analysis. 

{p 4 8 2}
{opt cat}{cmd:(}{it:varlist}{cmd:)} specifies which of the {cmd: cvars} and {cmd: lvars} should be handled as categorical variables.
For multi-categorical variables, {cmd:rwrmed} generates dummy variables for each level and then residualizes them individually. A warning
message will be issued if the logit model produces perfect predictions, resulting in dropped observations. The program will terminate
if the logit model cannot converge. In both of these cases (dropped observations or model non-convergence), the user should consider either
collapsing the multi-categorical variable into fewer categories, or specify it as a continuous variable (by not adding it to {cmd:cat()}).

{p 4 8 2}
{opt nointeraction} specifies that a treatment-mediator interaction should not be included in the outcome model. When not specified, {cmd:rwrmed}
will generate a treatment-mediator interaction term.

{p 4 8 2}
{opt cxa} specifies that treatment-covariate interactions be included in the mediator and outcome models.

{p 4 8 2}
{opt cxm} specifies that mediator-covariate interactions be included in the outcome model.

{p 4 8 2}
{opt lxm} specifies that mediator-posttreatment interactions be included in the outcome model.

{p 4 8 2}
{opt noisily} displays the GSEM output tables; this option is not available with {cmd:bootstrap}.

{p 4 8 2}
{opt bootstrap}[{cmd:(}{it:bootstrap_options}{cmd:)]} specifies that bootstrap replications are to be used to estimate the variance-covariance matrix. 
All {helpb bootstrap} options are available. Specifying bootstrap without options uses the default bootstrap settings. {p_end}

{p 4 8 2}
{it:model_options} allows the user to specify any option available for {helpb gsem} {p_end}



{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use depression.dta} {p_end}

 
{pstd} A continuous outcome (cesd40), a continuous mediator (ses), a binary treatment (college), nine pre-treatment covariates (of which five are categorical), four post-treatment covariates, 
no interaction between treatment and mediator, and the default delta-method for estimation: {p_end}
 
	{cmd:. rwrmed cesd40 cesd92 prmarr98 transitions98, avar(college) mvar(ses) cvar(male black test_score educ_exp father hispanic urban educ_mom num_sibs) ///}
		{cmd:cat(male black father hispanic urban) a(0) astar(1) m(0) mreg(reg)  nointer}


{pstd}Same as above, but include all interactions and specify that 1000 bootstrap replications be used for estimation: {p_end}
 
	{cmd:. rwrmed cesd40 cesd92 prmarr98 transitions98, avar(college) mvar(ses) cvar(male black test_score educ_exp father hispanic urban educ_mom num_sibs) ///}
		{cmd:cat(male black father hispanic urban) a(0) astar(1) m(0) mreg(reg) cxa cxm lxm boot(reps(1000) seed(1234))}

{pstd}Display all available post-estimation bootstrap confidence intervals: {p_end}

	{cmd:. estat boot, all}
 
{pstd}Same as the first model, but now include the survey weights (note: bootstrap cannot be used in conjunction with weights): {p_end}
 
	{cmd:. rwrmed cesd40 cesd92 prmarr98 transitions98 [pw=weights], avar(college) mvar(ses) cvar(male black test_score educ_exp father hispanic urban educ_mom num_sibs) ///}
		{cmd:cat(male black father hispanic urban) a(0) astar(1) m(0) mreg(reg)  nointer}
 
{pstd}This model includes a binary mediator. All interactions are included and the bootstrap is specified: {p_end}
 
	{cmd:. rwrmed cesd40 cesd92 prmarr98 transitions98, avar(college) mvar(ses_bin) cvar(male black test_score educ_exp father hispanic urban educ_mom num_sibs) ///}
		{cmd:cat(male black father hispanic urban) a(0) astar(1) m(0) mreg(logit) cxa cxm lxm boot(reps(1000) seed(1234))}
		
{pstd}This model includes a mediator which is a count variable. All interactions are included and the bootstrap is specified: {p_end}	

	{cmd:. rwrmed cesd40 cesd92 prmarr98 transitions98, avar(college) mvar(ses_count) cvar(male black test_score educ_exp father hispanic urban educ_mom num_sibs) ///}
		{cmd:cat(male black father hispanic urban) a(0) astar(1) m(0) mreg(poisson) cxa cxm lxm boot(reps(1000) seed(1234))}


{title:Stored results}

{pstd}
When margins is used for estimating VCE, {cmd:rwrmed} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macros:}{p_end}
{synopt:{cmd:r(NDEtype)}}natural direct effect type {p_end}
{synopt:{cmd:r(NDEtext)}}natural direct effect description {p_end}
{synopt:{cmd:r(NIEtype)}}natural indirect effect type {p_end}
{synopt:{cmd:r(NIEtext)}}natural indirect effect description {p_end}
{synopt:{cmd:r(ATEtype)}}average total effect type {p_end}
{synopt:{cmd:r(ATEtext)}}average total effect description {p_end}


{pstd}
and also stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macros:}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: matrices:}{p_end}
{synopt:{cmd:e(b)}}vector of transformed coefficients{p_end}
{synopt:{cmd:e(V)}}estimated variance-covariance matrix of the transformed
coefficients{p_end}



{pstd}
When the bootstrap method is specified for estimating VCE, {cmd:rwrmed} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: macros:}{p_end}
{synopt:{cmd:r(NDEtype)}}natural direct effect type {p_end}
{synopt:{cmd:r(NDEtext)}}natural direct effect description {p_end}
{synopt:{cmd:r(NIEtype)}}natural indirect effect type {p_end}
{synopt:{cmd:r(NIEtext)}}natural indirect effect description {p_end}
{synopt:{cmd:r(ATEtype)}}average total effect type {p_end}
{synopt:{cmd:r(ATEtext)}}average total effect description {p_end}


{pstd}
and also stores the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: macros:}{p_end}
{synopt:{cmd:e(cmdname)}}command name from {it:command}{p_end}
{synopt:{cmd:e(cmd)}}same as {cmd:e(cmdname)} or {cmd:bootstrap}{p_end}
{synopt:{cmd:e(command)}}{it:command}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(prefix)}}{cmd:bootstrap}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(strata)}}strata variables{p_end}
{synopt:{cmd:e(cluster)}}cluster variables{p_end}
{synopt:{cmd:e(rngstate)}}random-number state used{p_end}
{synopt:{cmd:e(size)}}from the {cmd:size(}{it:#}{cmd:)} option{p_end}
{synopt:{cmd:e(exp}{it:#}{cmd:)}}expression for the {it:#}th statistic{p_end}
{synopt:{cmd:e(ties)}}{cmd:ties}, if specified{p_end}
{synopt:{cmd:e(mse)}}{cmd:mse}, if specified{p_end}
{synopt:{cmd:e(vce)}}{cmd:bootstrap}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: matrices:}{p_end}
{synopt:{cmd:e(b)}}observed statistics{p_end}
{synopt:{cmd:e(b_bs)}}bootstrap estimates{p_end}
{synopt:{cmd:e(reps)}}number of nonmissing results{p_end}
{synopt:{cmd:e(bias)}}estimated biases{p_end}
{synopt:{cmd:e(se)}}estimated standard errors{p_end}
{synopt:{cmd:e(z0)}}median biases{p_end}
{synopt:{cmd:e(accel)}}estimated accelerations{p_end}
{synopt:{cmd:e(ci_normal)}}normal-approximation CIs{p_end}
{synopt:{cmd:e(ci_percentile)}}percentile CIs{p_end}
{synopt:{cmd:e(ci_bc)}}bias-corrected CIs{p_end}
{synopt:{cmd:e(ci_bca)}}bias-corrected and accelerated CIs{p_end}
{synopt:{cmd:e(V)}}bootstrap variance-covariance matrix{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: functions:}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}  



{marker citation}{title:Citation of {cmd:rwrmed}}

{p 4 8 2}{cmd:rwrmed} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, A., C. Huber, G. T. Wodtke. 2020. RWRMED: Stata module for conducting causal mediation analysis using regression-with-residuals. {p_end}

	  
{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}

{p 4 4 2}
Chuck Huber{break}
Associate Director of Statistical Outreach, StataCorp, LLC{break}
chuber@stata.com{break}

{p 4 4 2}
Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{break}
wodtke@uchicago.edu{break}


{title:References}

{phang} Wodtke, G. T. and D. Almirall. 2017. Estimating Moderated Causal Effects with Time-varying Treatments and Time-varying Moderators: Structural Nested Mean Models and Regression-with-residuals. {it:Sociological Methodology} 47: 212-245.

{phang} Wodtke, G. T., and X. Zhou. 2020. Effect Decomposition in the Presence of Treatment-induced Confounding: A Regression-with-Residuals Approach. {it:Epidemiology} 31: 69-375.

{phang} Wodtke, G. T., Z. Alaca, and X. Zhou. 2020. Regression-with-residuals Estimation of Marginal Effects. {it:Journal of the Royal Statistical Society Series A} 183: 311-332.

{phang} Zhou, X., and Wodtke, G. T. 2019. A Regression-with-residuals Method for Estimating Controlled Direct Effects. {it:Political Analysis} 27: 360-369.



{title:Acknowledgments}

{pstd}We thank Enrique Pinzon of StataCorp for his helpful suggestion to use {cmd:margins} with the {it: vce(unconditional)} option for estimating analytic standard errors {p_end}


{title:Also see}

{p 4 8 2} Online: {helpb gsem}, {helpb margins}, {helpb bootstrap} (if installed) {p_end}
