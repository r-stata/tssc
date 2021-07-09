{smcl}
{* *! version 1.4 09oct2018}{...}
{cmd:help stcrmix}
{hline}

{title:Title}

{phang}
{bf:stcrmix} {hline 2} Estimation of Mixtures of Generalized Gamma Models for Competing Risks


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:stcrmix} [{varlist}] {ifin}{cmd:,}
[{it:options}] 

{p 4 4 2}
    where {it:varlist} includes covariates to be used in the estimation of the proportion of subjects that achieve each competing event. 	
	This regression is carried out in the logit scale (i.e., log of the odds of event being the type one event).{p_end}

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Event types}
{synopt :{cmd:*cr1(}{it:{help numlist}}{cmd:)}}specifies the list of events that correspond to competing risk 1.{p_end}
{synopt :{cmd:*cr2(}{it:{help numlist}}{cmd:)}}specifies the list of events that correspond to competing risk 2.{p_end}
{synopt :{cmd:*cru(}{it:{help numlist}}{cmd:)}}specifies the list of codes identifying individuals for whom the event type was unobserved 
(either event-free or event observed but the type is unkown).{p_end}

{syntab:Distributions}
{synopt :{cmd:distribution(}{cmd:exponential)}}exponential distribution{p_end}
{synopt :{cmd:distribution(}{cmd:weibull)}}Weibull distribution{p_end}
{synopt :{cmd:distribution(}{cmd:lognormal)}}lognormal distribution{p_end}
{synopt :{cmd:distribution(}{cmd:ggamma)}}generalized gamma distribution{p_end}

{syntab:Outcome variables}
{synopt :{cmd:*failure(}{it:{help varname}}{cmd:)}}specifies the variable containing the events.{p_end}
{synopt :{cmd:*enter(}{it:{help varname}}{cmd:)}}specifies the variable containing entry times which is zero for individuals observed from origin.{p_end}
{synopt :{cmd:*time(}{it:{help varname}}{cmd:)}}specifies the variable containing times at the end of follow up.{p_end}
{synopt :{cmd:*uppertime(}{it:{help varname}}{cmd:)}}specifies the variable containing the maximum possible time by when all are expected to develop one event or the other (e.g., 100 years if age is the time scale).{p_end}

{syntab:Predictors/Exposures}
{synopt :{cmd:cr1loc(}{it:{help varlist}}{cmd:)}}variables in location component of the distribution of times to competing risk 1.{p_end}
{synopt :{cmd:cr1anc1(}{it:{help varlist}}{cmd:)}}variables in scale component of the distribution of times to competing risk 1.{p_end}
{synopt :{cmd:cr1anc2(}{it:{help varlist}}{cmd:)}}variables in shape component of the distribution of times to competing risk 1.{p_end}
{synopt :{cmd:cr2loc(}{it:{help varlist}}{cmd:)}}variables in location component of the distribution of times to competing risk 2.{p_end}
{synopt :{cmd:cr2anc1(}{it:{help varlist}}{cmd:)}}variables in scale component of the distribution of times to competing risk 2.{p_end}
{synopt :{cmd:cr2anc2(}{it:{help varlist}}{cmd:)}}variables in shape component of the distribution of times to competing risk 2.{p_end}

{syntab:Weighting}
{synopt :{cmd:wt(}{it:{help varlist}}{cmd:)}}variable containing inverse probability weights.{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt cr1 cr2 cru failure enter time uppertime} are required.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stcrmix} fits competing risk models through mixtures of generalized gamma distributions, 
using maximum likelihood, according to methods in {help stcrmix##CBM2010:Checkley, Brower and Munoz (2010)}. 
This command allows for the specification of two competing risk events, along with a category for individuals 
for whom the event type was unobserved. Moreover, an upper censoring time should be specified. 
This is assumed to be the latest potential time at which an individual would be expected to develop one event or the other 
which is content dependent but if unknown, user can select the times corresponding to when individuals will reach 125 years of age. 
In terms of parameters, this model allows for seven components of parameters to be estimated, 
including one for the proportion of subjects that achieve each competing risk, 
and then three parameters for the distribution of times to each competing risk (location, scale and shape).


{pstd}

{marker options}{...}
{title:Options}

{dlgtab:Event types}

{phang}
{cmd:cr1(}{it:{help numlist}}{cmd:)} is required and specifies the events that are associated with events due to the competing risk 1.

{phang}
{cmd:cr2(}{it:{help numlist}}{cmd:)} is required and specifies the events that are associated with events due to the competing risk 2.

{phang}
{cmd:cru(}{it:{help numlist}}{cmd:)} is required and specifies the codes identifying individuals for whom the event type was unobserved.


{dlgtab: Distributions}

{phang}
This command allows for the specification of the type of distribution
that will be used in the mixtures.

{phang}
{opt ggamma} is the most flexible distribution, where a location, scale,
and shape parameter will be estimated

{phang}
{opt weibull} fixes the shape parameter to be 1, and estimates a location and
a scale parameter.

{phang}
{opt lognormal} fixes the shape parameter to be 0, and estimates a location and
a scale parameter.

{phang}
{opt exponential} fixes the shape and scale parameter to be equal to 1 and
estimates a location parameter.


{dlgtab:Outcome variables}

{phang}
{cmd:failure({help varname:{it:varname}})} is required and specifies the variable that contains the events.

{phang}
{cmd:enter({help varname:{it:varname}})} is required and specifies the variable that contains the entry time for each observation which will take the value zero for individuals observed from origin.

{phang}
{cmd:time({help varname:{it:varname}})} is required and specifies the variable that contains times at the end of follow-up.

{phang}
{cmd:uppertime({help varname:{it:varname}})} is required and specifies the variable that contains the maximum possible time when all are expected to develop one event or the other.

{pmore}
        For a model estimation in which the maximum possible time is unknown, 
		you can set the {it:varname} for the {opt uppertime} 
		to when individuals will reach 125 years of age. 



{dlgtab:Predictors/Exposures}

{phang}
{cmd:cr1loc({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the location component for competing risk 1. 

{phang}
{cmd:cr1anc1({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the (log) scale component for competing risk 1.

{phang}
{cmd:cr1anc2({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the shape component for competing risk 1.


{phang}
{cmd:cr2loc({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the location component for competing risk 2. 

{phang}
{cmd:cr2anc1({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the (log) scale component for competing risk 2.

{phang}
{cmd:cr2anc2({help varlist:{it:varlist}})} specifies the covariates listed in {it:varlist} whose 
linear combination stipulates the regression for the shape component for competing risk 2.

{dlgtab:Weighting}

{phang}
{cmd:wt({help varlist:{it:varlist}})} indicates the variable to be used for inverse probability weighting. 

 
{marker examples}{...}
{title:Examples}

{pstd}Note: this example comes from the paper by
{help stcrmix##NG2017:Ng et al. (2017)}{p_end}

{pstd}Setup{p_end}
{pstd}Data set from the CKID study contain the ready for use variables entry for enter, exit for time and event for failure{p_end}
{phang2}{cmd:. use "https://statepi.jhsph.edu/ckid/racial_differences_dialysis_transplant_ckid.dta", clear}{p_end}

{pstd}Generate an indicator variable for CKD onset after birth{p_end}
{phang2}{cmd:. gen ageatCKDgt0= (ageatCKDonset >0)}{p_end}

{pstd}Setup an upper bound: by 40 years after diagnosis of non-glomerular chronic kidney disease, 
everyone will need either a dialysis or a kidney transplant{p_end}
{phang2}{cmd:. gen upperexit=40}{p_end}

{pstd}Anchor entry time at 2 years from onset and modify exit time appropriately{p_end}   
{phang2}{cmd:. drop if exit <= 2 /*exclude those whose exit is less than 2 years*/}{p_end}
{phang2}{cmd:. replace entry= entry - 2 /* moves the origin to 2 years */}{p_end}
{phang2}{cmd:. replace entry=0 if entry < 0 /* those entering the study before 2 years duration are seen from the new origin at 2 */}{p_end}
{phang2}{cmd:. replace exit= exit - 2 }{p_end}
{phang2}{cmd:. replace upperexit= upperexit - 2 /*to anchor upperexit at 2 also */}{p_end}

{pstd}Replace the upper censoring time by the actual time of event if the subject had an event{p_end}
{phang2}{cmd:. replace upperexit= exit if event==1 | event==2 }{p_end}

{pstd}Set data as survival (not required for stcrmix) to explore time by when mostly all will have one event or the other{p_end}
{phang2}{cmd:. stset exit, enter(entry) failure(event=1,2)}{p_end}
{phang2}{cmd:. streg , d(ggamma)}{p_end}

{pstd}To obtain the 99.5th percentile from the fitted generalized gamma distribution{p_end}
{phang2}{cmd:. gen Quantile99p5= exp([_t]_cons)*((e(kappa)^2)*invgammap(e(kappa)^(-2), (e(kappa)>0)*0.995+(e(kappa)<=0)*0.005))^(e(sigma)/e(kappa))}{p_end}
{phang2}{cmd:. display Quantile99p5 /*this justifies the use of 40  for uppertime */}{p_end}

{pstd}Fit competing-risks model with a mixture of generalized gamma distributions. In this model, we allow the proportion 
of events to vary by race and by whether CKD onset occured after birth, allow race to modify all location, scale and shape parameters, 
and allow whether CKD onset occured after birth to modify the location of event 2.{p_end}
{phang2}{cmd:. stcrmix b1nb0 ageatCKDgt0 , cr1(1) cr2(2) cru(0) distribution(ggamma) failure(event) enter(entry) time(exit) uppertime(upperexit) cr1loc(b1nb0)  cr1anc1(b1nb0) cr1anc2(b1nb0) cr2loc(b1nb0 ageatCKDgt0) cr2anc1(b1nb0) cr2anc2(b1nb0)}{p_end}

{pstd}Check a more parsimonious model, where we use an Weibull distribution allowing the two covariates to have similar effects.{p_end}
{phang2}{cmd:. stcrmix b1nb0 ageatCKDgt0, cr1(1) cr2(2) cru(0) distribution(weibull) failure(event) enter(entry) time(exit) uppertime(upperexit) cr1loc(b1nb0)  cr1anc1(b1nb0) cr2loc(b1nb0 ageatCKDgt0) cr2anc1(b1nb0)}{p_end}

{pstd}Inverse probability weighting is one potential way to adjust for confounding or selection bias. This command allows for the inclusion of a variable with inverse probability weights. Here is an exmaple fitting competing-risks model with a mixture of generalized gamma distributions with stabilized inverse probability weighting.{p_end}
{phang2}{cmd:. stcrmix b1nb0 , cr1(1) cr2(2) cru(0) distribution(ggamma) failure(event) enter(entry) time(exit) uppertime(upperexit) cr1loc(b1nb0) cr1anc1(b1nb0) cr1anc2(b1nb0) cr2loc(b1nb0) cr2anc1(b1nb0) cr2anc2(b1nb0)	wt(sipw)}{p_end}

		
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:stcrmix} stores the following in {cmd:e()}: 

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:stcrmix}{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald}; type of model chi-squared test{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(ilog)}}iteration log{p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{marker references}{...}
{title:Reference}

{marker CBM2010}{...}
{phang}
Checkley W, Brower RG, Munoz A. Inference for mutually exclusive competing 
events through a mixture of generalized gamma distributions. 
Epidemiology. 2010 Jul; 21(4): 557-565.
Available at:  {browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3227544/"}
{p_end}
{marker NG2017}{...}
{phang}
Ng DK, Moxey-Mims M, Warady BA, Furth SL, Munoz A. Racial differences in renal 
replacement therapy initiation among children with a non-glomerular cause of 
chronic kidney disease. 
Annals of Epidemiology. 2016 Nov; 26(11): 780-787.
Available at:  {browse "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5110248/"}
{p_end}


{title:Authors}

{phang}Perry Kuo{p_end}
{phang}MD, MPH{p_end}
{phang}Johns Hopkins Bloomberg School of Public Health{p_end}
{phang}perrykuo@jhu.edu{p_end}

{phang}Usama Bilal{p_end}
{phang}MD, MPH, PhD{p_end}
{phang}Drexel Dornsife School of Public Health{p_end}
{phang}ubilal@drexel.edu{p_end}

{phang}Alvaro Munoz{p_end}
{phang}PhD{p_end}
{phang}Johns Hopkins Bloomberg School of Public Health{p_end}
{phang}amunoz@jhu.edu{p_end}

