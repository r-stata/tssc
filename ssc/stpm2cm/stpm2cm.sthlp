{smcl}
{* *! version 1.0 30jun2011}{...}
{cmd:help stpm2cm} 
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:stpm2cm} {hline 1}}Postestimation command for {cmd:stpm2} models to estimate crude and net mortality after fitting a
relative survival model{p_end}
{p2colreset}{...}


{title:Syntax}


{p 8 16 2}{cmd:stpm2cm} using {filename}  [{cmd:,} {it:options}]


{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt at(varlist)}}specifies covariate pattern for prediction}{p_end}
{synopt :{opt mergeby(varlist)}}specifies the variables to merge with the population mortality file.{p_end}
{synopt :{opt diaga:ge(#)}}gives age at diagnosis{p_end}
{synopt :{opt diagy:ear(#)}}gives year at diagnosis{p_end}
{synopt :{opt sex(#)}}gives coding for sex required in population mortality file{p_end}
{synopt :{opt atta:ge(varname)}}specifies the variable containing attained age (i.e., age at the time of follow-up){p_end}
{synopt :{opt atty:ear(varname)}}specifies the variable containing attained year (i.e., year at the time of follow-up){p_end}
{synopt :{opt maxa:ge}}maxium age in popmort file{p_end}
{synopt :{opt n:obs}}specifies the number of observations (of time) to predict for (default 1000). Observations are evenly spread between the minimum and maximum value of follow-up time. {p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt maxt(#)}}the maximum value of follow up time{p_end}
{synopt :{opt stub(stub)}}the stub name for calculation of new variables{p_end}
{synopt :{opt tgen(newvarname)}}name of variable for generated follow-up time.{p_end}
{synopt :{opt mergegen(varname # ...)}}values of other merge variables required for the population mortality file{p_end}

{title:Description}

{pstd}
{cmd:stpm2cm} calculates crude and net mortality after fitting an {cmd:stpm2} model. It is a postestimation command and requires that an {cmd:stpm2} 
has been fitted. The expected survival/mortality is required for calculation of the crude probabilities of death due to other causes and the 
{cmd:strs} command is used for this. {cmd:strs} can be obtained from Paul Dickman's webpage (http://www.pauldickman.com/rsmodel/stata_colon/). 
Note that {cmd:stpm2cm} does a prediction for an individual with a particular covariate pattern (specified with the {cmd:at()} option). 
You must also specify the age, sex and calendar year the prediction is for in the population mortality file.

{title:Options}

{phang}
{opt at(varlist)} gives the covariates values for the prediction. All covariates in the model must be specified. For example {cmd: at(age 60 sex 1)}

{phang}
{opt mergby(varlist)} specifies the variables by which the file of general population survival probabilities is sorted. See {help strs}{p_end}

{phang}
{opt diaga:ge(#)} age of subject at diagnosis for prediction. Note that this must be specified even if age has been modelled as a categorical covariate.{p_end}

{phang}
{opt diagy:ear(#)} year of diagnosis of subject.{p_end}

{phang}
{opt sex(#)} coding for sex prediction is for. This needs to match that in the population mortality file.{p_end}

{phang}
{opt atta:ge(varname)} specifies the variable containing attained age (i.e., age at the time of follow-up). This needs to match the variable 
in the population mortality file{p_end}

{phang}
{opt atty:ear(varname)} specifies the variable containing attained calendar year. This needs to match the variable 
in the population mortality file{p_end}

{phang}
{opt maxa:ge} maxium age in population mortality file{p_end}

{phang}
{opt n:obs} specifies the number of observations (of time) to predict for (default 1000). Observations are evenly spread between the 
minimum and maximum value of follow-up time. {p_end}

{phang}
{opt ci} calculate confidence intervals{p_end}

{phang}
{opt maxt(#)} the maximum value of follow up time{p_end}

{phang}
{opt stub(stub)} the stub name for calculation of the new variables. The following variables are created: {cmd:{it:stub}_d} - crude 
probability of death due to disease, {cmd:{it:stub}_o} - crude probability of death due to other causes, {cmd:{it:stub}_all} - 
probability of death (all causes), {cmd:{it:stub}_lambda} - excess mortality rate, {cmd:{it:stub}_lambda} - expected mortality rate,
{cmd:{it:stub}_St_star} - Expected survival, {cmd:{it:stub}_s_all} - overall survival.{p_end}

{phang}
{opt tgen(newvarname)} name of variable for generated follow-up time.

{phang}
{opt mergegen(varname # ...)} values of other merge variables required for the population mortality file. This is used when there are
additional variables in the population mortality file. For example, region or socio-economic group.{p_end}


{hline}
{title:Example}


{pstd}{cmd: stpm2 agegrp2-agegrp4, scale(hazard) bhazard(rate) df(5) ///}{p_end}
{phang2}{cmd: tvc(agegrp2-agegrp4) dftvc(3)}{p_end}
{pstd}{cmd: stpm2cm using popmort, at(agegrp2 0 agegrp3 0 agegrp4 0) ///}{p_end}
{phang2}{cmd:	                       mergeby(_year sex _age) ///}{p_end}
{phang2}{cmd:					diagage(40) diagyear(1985) ///}{p_end}
{phang2}{cmd:					sex(1) stub(cm1) nobs(1000) ///}{p_end}
{phang2}{cmd:					tgen(cm1_t)}{p_end}


{title:Author}

{pstd}
Paul Lambert, University of Leicester, UK.
paul.lambert@leicester.ac.uk


{title:References}

Lambert PC, Dickman PW, Nelson CP, Royston P. Estimating the crude probability of
death due to cancer and other causes using relative survival models. {it:Statistics in Medicine}
2010;29:885-895.

{title:Also see}

{psee}
Online:  {manhelp stpm2_postestimation ST:stpm2 postestimation};
{manhelp stset ST},
{help stpm}
{p_end}
