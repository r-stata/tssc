{smcl}
{* *! version 1.7 16may2018}{...}
{vieweralsosee "[MI] mi impute" "help mi_impute"}{...}
{vieweralsosee "[MI] mi impute chained" "help mi_impute_chained"}{...}
{vieweralsosee "[MI] mi estimate" "help mi_estimate"}{...}
{viewerjumpto "Options" "smcfcs##options"}{...}
{viewerjumpto "Remarks" "smcfcs##remarks"}{...}
{viewerjumpto "Examples" "smcfcs##examples"}{...}

{title:Title}

{phang}
{bf:smcfcs} Multiple imputation of partially observed covariates and outcomes by substantive model compatible fully conditional specification (smcfcs)

{title:Syntax}

{p 8 15 2} {cmd:smcfcs} {it:smcmd} {it:smdepvar} {it:smindepvars}, [ {opt reg:ress}({help varlist:varlist})
{opt logi:t}({help varlist:varlist}) {opt poisson}({help varlist:varlist}) {opt nbreg}({help varlist:varlist}) {opt mlogit}({help varlist:varlist})
{opt ologit}({help varlist:varlist}) {opt time}({help varname:varname}) {opt enter}({help varname:varname}) {opt failure}({help varname:varname})
{opt iter:ations(#)} {opt m(#)} {opt rjlimit(#)} {opt passive(string)}
{opt eq(string)} {opt rseed(string)} {opt chainonly} {opt savetrace(filename)} {opt noisily} {opt by}({help varlist:varlist}) ]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt reg:ress}({help varlist:varlist})}partially observed continuous variables to be imputed{p_end}
{synopt :{opt logi:t}({help varlist:varlist})}partially observed binary variables to be imputed{p_end}
{synopt :{opt poisson}({help varlist:varlist})}partially observed Poisson variables to be imputed{p_end}
{synopt :{opt nbreg}({help varlist:varlist})}partially observed negative binomial variables to be imputed{p_end}
{synopt :{opt mlogit}({help varlist:varlist})}partially observed unordered categorical variables to be imputed{p_end}
{synopt :{opt ologit}({help varlist:varlist})}partially observed ordered categorical variables to be imputed{p_end}
{synopt :{opt time}({help varname:varname})}for competing risks outcomes, the name of the variable indicating failure time{p_end}
{synopt :{opt enter}({help varname:varname})}for competing risks outcomes, an optional variable indicating the time of delayed entry{p_end}
{synopt :{opt failure}({help varname:varname})}for competing risks outcomes, the name of the variable indicating failure type{p_end}
{synopt :{opt iter:ations(#)}}specify number of iterations to perform for each imputation; default is 10{p_end}
{synopt :{opt m(#)}}specify number of imputations to generate; default is 5{p_end}
{synopt :{opt rjlimit(#)}}specify limit for rejection sampler; default is 1000{p_end}
{synopt :{opt passive(string)}}{it:string} expressions for evaluating derived covariates in the substantive model{p_end}
{synopt :{opt eq(string)}}{it:string} expressions for custom prediction equations{p_end}
{synopt :{opt rseed(string)}}set Stata's random seed{p_end}
{synopt :{opt chainonly}}perform iterations of SMC-FCS (as specified by iteration option) without creating imputations{p_end}
{synopt :{opt savetrace(filename)}}save estimates of substantive model parameters from each iteration in {it:filename}.dta{p_end}
{synopt :{opt noisily}}runs {cmd:smcfcs} noisily{p_end}
{synopt :{opt by}({help varlist:varlist})}specifies that imputation be performed separately by groups defined by {help varlist:varlist}{p_end}
{synopt :{opt clear}}specifies that any multiply imputed data in memory be cleared. {p_end}
{synopt :{opt exposure}({help varname:varname})}for Poisson substantive models, an optional variable indicating exposure time {p_end}
{synoptline}

{pstd}
{it:smcmd} {help smdepvar:{it:smdepvar}} {help smindepvars:{it:smindepvars}} specifies the substantive model 
with which covariates are to be imputed compatibly with. Currently {it:smcmd} can be {help regress:regress}, {help logit:logit},
{help stcox:stcox}, compet, or {help poisson:poisson}. In the case of {help stcox:stcox}, the dataset should be {help stset:stset} 
prior to running smcfcs, and no {help smdepvar:{it:smdepvar}} should be specified. In the case of compet,
the data should not be {help stset:stset}, but instead the time and failure indicator variables should passed
using the time and failure options.


{title:Description}

{pstd}
{cmd:smcfcs} multiply imputes missing values of covariates using a modified version of the fully conditional specification (chained equations) 
algorithm. Each partially observed covariate is imputed from an imputation model which is compatible with the specified substantive model.


{marker options}{...}
{title:Options}

{phang}
{opt reg:ress}({varlist}) specifies the names of the partially observed continuous variables (if any), which are to be imputed.

{phang}
{opt logi:t}({varlist}) specifies the names of the partially observed binary variables (if any), which are to be imputed.

{phang}
{opt poisson}({varlist}) specifies the names of the partially observed Poisson variables (if any), which are to be imputed.

{phang}
{opt nbreg}({varlist}) specifies the names of the partially observed negative binomial variables (if any), which are to be imputed.

{phang}
{opt mlogit}({varlist}) specifies the names of the partially observed unordered categorical variables (if any), which are to be imputed.

{phang}
{opt ologit}({varlist}) specifies the names of the partially observed ordered categorical variables (if any), which are to be imputed.

{phang}
{opt time}({help varname:varname})} for competing risks outcomes, the name of the variable indicating failure time.

{phang}
{opt enter}({help varname:varname}) for competing risks outcomes, an optional variable indicating the time of delayed entry.

{phang}
{opt failure}({help varname:varname}) for competing risks outcomes, the name of the variable indicating failure type.

{phang}
{opt iterations(#)} specifies the number of iterations to perform for each imputation; default is 10.

{phang}
{opt m(#)} specifies number of imputations to generate; default is 5.

{phang}
{opt rjlimit(#)} {cmd:smcfcs} uses rejection sampling to impute missing covariate values for variables which do not have a finite sample space. Rejection sampling involves repeatedly drawing from a distribution until a valid imputation is found. This option
specifies the maximum number of attempts that {cmd:smcfcs} will make to find a valid draw for imputed values. If valid values have not been found for one or more subjects by the limit the command continues,
using the last proposed draw for such subjects. The default limit is 1000.

{phang}
{opt passive(string)} specifies a string of equations to update derived covariates (if any). Each expression within the string must be separated by a |. Derived covariates may appear either in the
substantive model, in covariate models, or both.

{phang}
{opt eq(string)} specifies a string of linear predictor sets for partially observed variables. Each expression within the string must be separated by a |. Each expression should be of the form varname: varlist,
which specifies that the linear predictor of the covariate model for varname is given by varlist. If an expression is not specified for a given partially observed variable, the default is to impute using
a covariate model which includes any fully observed variables in the substantive model and all partially observed variables except the one being imputed.

{phang}
{opt rseed(string)} sets Stata's random number seed to the given value.

{phang}
{opt chainonly} perform iterations of SMC-FCS (as specified by iteration option) without creating imputations. Useful in conjunction with {opt savetrace} to assess convergence.

{phang}
{opt savetrace(filename)} save estimates of substantive model parameters from each iteration in {it:filename}.dta. Useful for checking convergence of SMC-FCS.

{phang}
{opt noisily} runs SMC-FCS noisily. Useful for diagnosing errors.

{phang}
{opt by}({help varlist:varlist}) imputes separately within groups defined by {help varlist:varlist}.

{phang}
{opt clear} specifies that any previous imputations in the data be cleared. If imputations already exist, {cmd:smcfcs} will exit with an error unless the {opt clear} option is specified.

{phang}
{opt exposure}({help varname:varname}) for Poisson substantive models, the exposure time variable.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:smcfcs} multiply imputes missing values in covariates based on the fully conditional specification (or chained equations) approach. The 
user must specify a substantive model for how the outcome depends on the covariates. At present, linear ({help regress:regress}), logistic ({help logistic:logistic}),
Cox proportional hazards ({help stcox:stcox}) for time to event data, and competing risks substantive models are supported. For Cox models for single
time to event data, the data should be {help stset:stset} prior to running {cmd:smcfcs}. Right censoring and delayed entry (left truncation) are supported.

{pstd}
Each partially observed variable is then imputed from an imputation model 
which is compatible with the specified substantive model. For continuous and binary outcomes, {cmd:smcfcs} will additionally impute any missing values
in the outcome, using the specified substantive model as the imputation model.

{pstd}
The substantive model can include independent variables whose values are (user defined) functions of the partially observed variables.
For example, the substantive model can contain non-linear terms, such as x^2 as independent variables, or
ratios (e.g. BMI = weight / height^2). In this case the {opt passive} option is used to specify how these derived
covariates are calculated, with equations separated by | symbols (see {help smcfcs##examples:examples}).

{pstd}
Currently {cmd:smcfcs} supports the imputation of continuous (linear regression), binary (logistic), count (Poisson or negative binomial regression),
unordered categorical (multinomial logistic regression) and ordered categorical (ordered logistic regression) variables. By default, partially
observed variables are imputed from a model which conditions on all of the other fully and partially observed variables. If
desired, this behaviour can be altered through use of the {opt eq} option. By default partially observed categorical variables are included
as factor variables when they serve as predictors in the imputation models of other variables. Main effects of variables can be included in
the substantive model using Stata's i. factor notation if desired. Interactions must however be included by first generating an interaction variable,
including this in the substantive model, and by passing the corresponding argument to the passive option to enable the interaction variable to be
updated by the program (see the example).

{pstd}
For competing risks outcomes, {cmd:smcfcs} assumes a Cox proportional hazards model for each cause of failure. For competing risks
outcomes you must pass variables to the time and failure options to indicate the corresponding variables. The failure variable should be
an integer valued variable, with 0 indicating censoring and 1,2,3 etc indicating failures due to each of the competing causes. In the case
of competing risks outcomes, {cmd:smcfcs} (at present) uses a common set of covariates in each Cox model.

{pstd}
Once the desired number of imputations have been generated, {cmd:smcfcs} imports the imputations to a Stata {help mi:mi} format ({help mi_styles:flong}), and then fits the substantive model to
the imputations using Stata's {help mi estimate:mi estimate} command. The {help mi estimate:mi estimate} command can then be used to fit alternative models for the outcome, although
care should be taken to ensure that these are nested within the substantive model specified to generate the imputations.

{pstd}
The command will give a warning if valid draws are not obtained for one or more observations within the limit specified by the {opt rjlimit(#)} option. If you receive
this warning you should probably increase the limit until the warning no longer appears, although in (limited) simulations we have obtained good results even when
the warning has appeared for a small proportion of subjects.

{pstd}
The default number of iterations of 10 may not be sufficient for SMC-FCS to converge in a given setting. Users should check convergence of the algorithm by using
the {opt chainonly} and {opt savetrace} options, using a large number of iterations.

{pstd}
If the {opt by} option is specified, {cmd:smcfcs} imputes separately in groups defined by the corresponding {help varlist:varlist}, and then combines these to
form a single set of imputations for the whole dataset. Ordinarily after generating the imputed datasets {cmd:smcfcs} fits the specified substantive model
to the imputed datasets. However, if imputation has been performed separately by groups, {cmd:smcfcs} does not do this - in this situation the user must 
fit an appropriate model in the combined dataset. Note that if a variable is specified in {opt by}, it must not be included as a covariate in the substantive model
specified when calling {cmd: smcfcs}. In this case however one can still fit a substantive model to the imputed datasets which does include the variable.

{pstd}
Further details regarding the algorithm used by {cmd:smcfcs} can be found in the article referenced below.


{marker examples}{...}
{title:Examples}

{pstd}Create multiple imputations of continuous x1 and x2, assuming y follows a linear regression with x1, x1^2, x2 and x2^2 as covariates{p_end}
{phang2}{cmd:smcfcs reg y x1 x1sq x2 x2sq, reg(x1 x2) passive(x1sq = x1^2 | x2sq = x2^2)}{p_end}

{pstd}Create multiple imputations of continuous x1 and x2, assuming y follows a linear regression with x1, x2 and x1*x2 as covariates{p_end}
{phang2}{cmd:gen x1x2=x1*x2}{p_end}
{phang2}{cmd:smcfcs reg y x1 x2 x1x2, reg(x1 x2) passive(x1x2=x1*x2)}{p_end}

{pstd}Create multiple imputations of wgt and ht, assuming the outcome y follows a logistic model with bmi (wt / ht^2) as covariate{p_end}
{phang2}{cmd:smcfcs logistic y bmi, reg(wgt ht) passive(bmi = wt / ht^2)}{p_end}

{pstd}Create multiple imputations of x1 (binary) and x2 (continuous), assuming a Cox model with x1 and x2 as linear terms{p_end}
{phang2}{cmd:smcfcs stcox x1 x2, reg(x2) logit(x1)}{p_end}

{pstd}Competing risks outcomes. Create multiple imputations of x1 (binary) and x2 (continuous), assuming a Cox model for each competing risk 
with x1 and x2 as linear terms in both{p_end}
{phang2}{cmd:smcfcs compet x1 x2, reg(x2) logit(x1) time(t) failure(d)}{p_end}


{title:References}

{phang}Jonathan W. Bartlett, Shaun R. Seaman, Ian R. White, James R. Carpenter. Multiple imputation of covariates by fully conditional specification: accommodating the substantive model.
{browse "http://doi.org/10.1177/0962280214521348":Statistical Methods in Medical Research, 24:462-487, 2015}

{phang}Jonathan W. Bartlett, Tim P. Morris. Multiple imputation of covariates by substantive model compatible fully conditional specification.
{browse "http://www.stata-journal.com/article.html?article=st0387": The Stata Journal, 15:437-456, 2015}
	

{title:Authors}

{pstd}Jonathan Bartlett, AstraZeneca, UK{break}
jwb133@googlemail.com{break}
{browse "www.thestatsgeek.com"}
{browse "www.missingdata.org.uk"}
	
{pstd}Tim Morris, MRC Clinical Trials Unit at UCL, UK{break}
tim.morris@ucl.ac.uk


{title:Also see}

    {helpb mi impute}
    {helpb mi impute chained}
    {helpb mi estimate}
