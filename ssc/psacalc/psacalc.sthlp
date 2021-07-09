{smcl}
{* *! version 2.1  12May2017}{...}
{cmd:help psacalc}
{hline}

{title:Title}

{phang}
{bf:psacalc} {hline 2} Calculate treatment effects and relative degree of selection under proportional selection of observables and 
unobservables


{marker syntax}{...}
{title:Syntax}

{pstd}

{p 8 17 2}
{cmd:psacalc}
{it:estimate}
{varname}
[{cmd:,}{it:options}]

{synoptset 22}{...}
{synopthdr:estimate}
{synoptline}
{synopt:{opt beta}}Calculate treatment effect {p_end}
{synopt:{opt delta}}Calculate relative degree of selection{p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth mcontrols(varlist)}} unrelated controls to be included in all regressions{p_end}
{synopt:{opt rmax(#)}} maximum R-squared; default is rmax=1 {p_end}
{synopt :{opth model(command)}} command for model to be estimated when used as stand-alone command {p_end}

{syntab: Beta}
{synopt:{opt delta(#)}} value of delta if requesting calculation of treatment effect beta;
        default is delta=1 {p_end}
		
{syntab: Delta}
{synopt:{opt beta(#)}} value of beta if requesting a value of delta to match given beta; default is beta=0 {p_end}

{synoptline}
{p2colreset}{...}

{p 4 6 2}
{varname} may contain factor variables; see {help fvvarlist}.{p_end}
{marker command}{...}
{p 4 6 2}
{it:command} is any of the following commands: {helpb regress}, {helpb areg}, {helpb xtreg}.{p_end}
{p 4 6 2}
{ifin} qualifiers are allowed in {it:command}; see {help if} and {help in}.{p_end}
{p 4 6 2}
weights are allowed in {it:command}; see {help weight}.{p_end}
{p 4 6 2}
{opt absorb()} is required with {helpb areg}, see {manhelp absorb R}.{p_end}
{p 4 6 2}
Only {help xtreg##feoptions:fe} and {help xtreg##beoptions:be} allowed with {helpb xtreg}; see {manhelp xtreg R}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd: psacalc} calculates estimates of treatment effects and relative degree of selection in linear models as proposed in 
{browse "http://bit.ly/2gSJZch":Oster (2016)} for a independent variable {varname}. These estimators are consistent under the assumption of selection on the observed controls
being proportional to the selection on the unobserved controls. 

{pstd}
{cmd: psacalc beta} calculates estimates of the treatment effect of {varname}, beta, to match a proportional degree of selection delta. When there are 
multiple solutions, the default is to choose the solution that minimizes the squared difference to the estimated treatment effect in the controlled
regression and does not change the direction of the bias (See Assumption 3 in {browse "http://bit.ly/2gSJZch":Oster (2016)}).{p_end}

{pstd}
{cmd: psacalc delta} calculates an estimate of the proportional degree of selection, delta, to match a given treatment effect beta 
of {varname}.{p_end}

{pstd}
{cmd: psacalc} can be used after {helpb regress}, {helpb areg} and {helpb xtreg} or as a stand-alone command when estimating these linear
models. See {help psacalc2##models:Model} for details on the assumptions made for each type of model.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth mcontrols(varlist)} specifies a list of variables to include as controls in all regressions. These variables are assumed to be
unrelated to the set of proportionally related unobservables.

{phang}
{opt rmax(#)} specifies the maximum r-squared which would result if all unobservables were be included in the regression. Default is 1.0.

{dlgtab:Beta}

{phang}
{opt delta(#)} specifies a value for delta for which the requested treatment effect beta will be calculated.  An option 
of exactly 1.0 has the interpretation of equal selection. 

{dlgtab:Delta}

{phang}
{opt beta(#)} specifies a value of beta for which the requested proportional degree of selection beta will be calculated. Default is 0.

{dlgtab:Model}

{marker models}{...}
{phang}
{opt model} specifies a model to be estimated when the command is used as a stand-alone command instead of a post-estimation command.
This option is useful if using when obtaining bootstrap estimates of the standard errors of beta and delta. Three types of models are
supported.

{pmore} {helpb regress} for linear cross sectional models.

{pmore} {helpb xtreg}, with the {help xtreg##feoptions:fe} or {help xtreg##beoptions:be} for linear panel data models with fixed effects.
{cmd: psacalc} assumes individual effects are nuisance parameters and calculates estimates using R-squared values from the differenced estimation
equations. See {manhelp xtreg R} for details on the differenced equations.

{pmore} {helpb areg} for linear regression absorbing one categorical factor. {cmd: psacalc} assumes individual effects are control variables
and calculates estimates using R-squared values from the estimation including indicators for the categorical factor levels.
See {manhelp areg R} for details.

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto.dta, clear }{p_end}
{phang2}{cmd:. regress price foreign mpg weight headroom trunk }{p_end}

{pstd}Obtain value of treatment effect of weight, beta, assuming delta is equal to one, so selection in unobservables is equal to selection on
observables{p_end}
{phang2}{cmd:. psacalc beta weight}{p_end}

{pstd}Obtain value of treatment effect of weight, beta, assuming delta is equal to 0.5, so selection in unobservables is smaller than 
selection on observables{p_end}
{phang2}{cmd:. psacalc beta weight, delta(0.5)}{p_end}

{pstd}Obtain value of proportional selection, delta, such that the effect of weight is equal to zero{p_end}
{phang2}{cmd:. psacalc delta weight}{p_end}

{pstd}Obtain value of proportional selection, delta, such that the effect of weight is equal to 5{p_end}
{phang2}{cmd:. psacalc delta weight, beta(5)}{p_end}

{pstd}Obtain value of proportional selection, delta, such that the effect of weight is equal to 5, assuming foreign is fully observed, 
the selection on other controls is proportional to selection in unobservables, and a maximum R-squared of 0.7{p_end}
{phang2}{cmd:. psacalc delta weight, beta(5) rmax(0.7) mcontrol(foreign)}{p_end}

{pstd}Obtain bootstrap estimates of the standard error of delta with the model option{p_end}
{phang2}{cmd:. bs r(delta), rep(100): psacalc delta weight, model(regress price foreign mpg weight headroom trunk)}{p_end}

{pstd}Setup for panel data{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. xtset idcode}{p_end}

{pstd}Use after fixed effects model with individual effects taken as nuisance parameters{p_end}
{phang2}{cmd:. xtreg ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure 2.race not_smsa south, fe}{p_end}
{phang2}{cmd:. psacalc beta south}{p_end}

{pstd}Use with individual effects taken as controls{p_end}
{phang2}{cmd:. areg ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure 2.race not_smsa south, absorb(idcode)}{p_end}
{phang2}{cmd:. psacalc beta south}{p_end}


{marker saved}{...}
{title:Saved Results}

{pstd}
{cmd:psacalc} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(delta)}}proportional degree of selection{p_end}
{synopt:{cmd:r(beta)}}treatment effect{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}command used for estimation{p_end}
{synopt:{cmd:r(depvar)}}dependent variable{p_end}
{synopt:{cmd:r(indepvars)}}independent variables{p_end}
{synopt:{cmd:r(treatment)}}treatment variable{p_end}
{synopt:{cmd:r(mcontrol)}}unrelated controls{p_end}
{synopt:{cmd:r(type)}}type of calculation, {cmd:beta} or {cmd:delta}{p_end}
{p2colreset}{...}

{pstd}
{cmd:psacalc beta} saves the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(dist)}}squared difference from treatment effect to controlled beta, (beta-beta_tilde)^2{p_end}
{synopt:{cmd:r(root_count)}}number of solutions {p_end}
{synopt:{cmd:r(altsol1)}}alternative solution 1 {p_end}
{synopt:{cmd:r(altdist1)}}squared difference of alternative solution 1 to controlled beta {p_end}
{synopt:{cmd:r(altsol2)}}alternative solution 2 {p_end}
{synopt:{cmd:r(altdist2)}}squared difference of alternative solution 2 to controlled beta {p_end}

{title:Author}

{pstd}Emily Oster, Brown University{break} 
       emily_oster@brown.edu
	   
{title:Support}	   
	   
{pstd}For support and to report bugs please email Jorge Perez, Brown University{break} 
       jorge_perez@brown.edu	 
       
{title:References}

{pstd}Oster, Emily (2016). "Unobservable Selection and Coefficient Stability: Theory and Validation", {it: Journal of Business Economics and Statistics}, Forthcoming

{title:Aknowledgements}
{pstd}We are grateful to Danny Cohen-Zada for identifying bugs in a previous version of the command.

{title:Disclaimer}

{pstd} This program is provided without warranty of any kind. The author is not responsible for any cost derived by the usage
 of this program.

