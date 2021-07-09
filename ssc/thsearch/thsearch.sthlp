{smcl}
{* *! version 1.0.8 22Mar2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "thsearch##syntax"}{...}
{viewerjumpto "Description" "thsearch##description"}{...}
{viewerjumpto "Required Settings" "thsearch##required_settings"}{...}
{viewerjumpto "Options" "thsearch##options"}{...}
{viewerjumpto "Remarks" "thsearch##remarks"}{...}
{viewerjumpto "Saved Results" "thsearch##saved_results"}{...}
{viewerjumpto "Examples" "thsearch##examples"}{...}
{viewerjumpto "References" "thsearch##references"}{...}
{viewerjumpto "Authors" "thsearch##authors"}{...}
{title:Title}

{phang}
{bf:thsearch} {hline 2} Threshold search model for non-linear models based on information criterion


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:ths:earch}
{help thsearch##depvar:{it:depvar}}
[{help thsearch##indepvars:{it:indepvars}}]
{ifin}
{cmd:,} {opt thvar}({it:{help varname:varname}}) [{opt intvar}({it:{help varname:varname}})] 
{opt thnum}({it:{help numlist:numlist}}) {opt emodel}({it:{help string:string}}) 
[{it:other_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt s:tep}({it:#})}specify the size/interval of the threshold, default is {cmd:1}{p_end}
{synopt:{opt cri:teria}({it:{help string:string}})}choose information criteria for model selection, default is {cmd:BIC} (Schwarz, 1978){p_end}
{synopt:{opt save:file}({it:filename})}save a dataset with the results from all the iterations in the file {it:filename}{cmd:.dta}{p_end}
{synopt:{opt replace}}replace the dataset specified in {cmd:savefile}({it:filename}) if it already exists{p_end}
{synopt:{opt min:th}({it:#})}specify the value for the first threshold{p_end}
{synopt:{opt max:th}({it:#})}specify the value for the last threshold{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:thsearch} implements the threshold search model based on information criterion for optimal threshold model selection. See Gannon, Harris and Harris (2014) for details.

{marker required_settings}{...}
{title:Required Settings}

{phang}
{marker depvar}
{cmd: depvar} the outcome variable.

{phang}
{cmd: thvar} the explanatory variable where thresholds are to be defined. 

{phang}
{cmd: thnum(#)} the number of threshold to be determined, e.g.{cmd: thnum(2)} estimates the threshold models with 3 subpopulations. 

{phang}
{cmd: emodel} the estimation model. Currently supports {helpb regress}, {helpb xtreg, fe} {helpb probit}, {helpb oprobit}. To specifiy options for regression models, type the regression options followed by comma, e.g. {cmd:emodel(oprobit, vce(robust))}. For {helpb xtreg, fe}, dataset must be declared as panel dataset.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{marker indepvars}
{cmd: indepvars} the list of explanatory variables. 

{phang}
{opt intvar} constructs interaction terms between {opt intvar} and the dummy variables defined by the thresholds. 

{phang}
{opt stepsize(#)} the increment of threshold value in each iteration. Positive real number.

{phang}
{opt criteria(string)} AIC, BIC, CAIC, HQIC. Default is {cmd:BIC} (Schwarz, 1978).

{phang}
{opt savefile(filename)} saves a dataset with the information criterion values of each iterations. If {opt savefile(filename)} is specified, {it:filename}.dta will contain the following variables: 

{p 8 17 15}
{opt emodel}: regression model specified in {cmd: emodel}.

{p 8 17 15}
{opt bic}: Bayesian information criterion or Schwarz criterion (BIC).

{p 8 17 15}
{opt aic}: Akaike information criterion (AIC).

{p 8 17 15}
{opt aicc}: AIC with a correction for finite sample sizes.

{p 8 17 15}
{opt hqic}: Hannan–Quinn information criterion (HQIC).

{p 8 17 15}
{opt num_threshold}: number of thresholds specified in {cmd: thnum(#)}.

{p 8 17 15}
{opt tau_#}: value of threshold #. 

{phang}
{opt replace} replaces the dataset specified in savefile({it:filename}) if it already exists.

{phang}
{opt minth(#)} Default is the minimum value of {cmd:thvar}.

{phang}
{opt maxth(#)} Default is the maximum value of {cmd:thvar}.

{marker remarks}{...}
{title:Remarks}

{phang}{cmd: thsearch} supports at most 6 thresholds. Depending on the uses, we generally do not recommend users to specify more than 4 thresholds as the estimation process quickly becomes computationally prohibitive. 

{pstd}

{marker saved_results}{...}
{title:Saved Results}

{phang}
{cmd: thsearch} stores the ereturn of the optimal threshold model. In addition, {cmd: thsearch} also stores the following in r():

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(tau_#)}}value of threshold # {p_end}
{synopt:{cmd:r(mincri)}}value of the minimum information criterion{p_end}
{synopt:{cmd:r(cri)}}information criterion specified{p_end}
{synopt:{cmd:r(emodel)}}regression model specified{p_end}
{p2colreset}{...}
{pstd}


{marker references}{...}
{title:Reference(s)}

{phang}Gannon B., Harris D., and Harris M. (2014), Threshold effects in nonlinear models with an application to the social capital-retirement-health relationship, Health Econ., 23, pp. 1072-1083.{p_end}

{marker authors}{...}
{title:Author(s)}

{phang}Ho Fai Chan{p_end}
{phang}Queensland University of Technology{p_end}
{phang}Brisbane, Queensland, Australia{p_end}
{phang}hofai.chan@qut.edu.au{p_end}

{phang}Brenda Gannon{p_end}
{phang}Centre for the Business and Economics of Health{p_end}
{phang}University of Queensland{p_end}
{phang}Brisbane, Australia{p_end}
{phang}brenda.gannon@uq.edu.au{p_end}

{phang}David Harris{p_end}
{phang}Department of Economics{p_end}
{phang}University of Melbourne{p_end}
{phang}Melbourne, Australia{p_end}
{phang}harrisd@unimelb.edu.au{p_end}

{phang}Mark Harris{p_end}
{phang}School of Economics and Finance{p_end}
{phang}Curtin Business School{p_end}
{phang}Curtin University of Technology{p_end}
{phang}Perth, Australia{p_end}
{phang}mark.harris@curtin.edu.au{p_end}
