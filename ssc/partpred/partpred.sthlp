{smcl}
{* 27apr2010}{...}
{cmd:help partpred}
{hline}

{title:Title}

{p2colset 5 21 23 2}{...}
{p2col :{hi: partpred} {hline 2}}partial predictions after fitting a model{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:partpred}
{newvar}
{ifin}
{cmd:, for({varlist})} [{it:{help partpred ##options:options}}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth for(varlist)}}variables included in partial prediction{p_end}
{synopt :{opt at(varname # ...)}}define certain covariates to take single values{p_end}
{synopt :{opt ref(varname # ...)}}define reference values for certain covariates{p_end}
{synopt :{opth ci(newvars)}}create {it:newvars} containing lower and upper confidence intervals{p_end}
{synopt :{opth se(newvar)}}create {it:newvar} containing standard error of predictions{p_end}
{synopt :{opt cons}}include constant in prediction{p_end}
{synopt :{opt eform}}exponentiate partial predictions{p_end}
{synopt :{opt eq(name)}}name of equation used for prediction; default is to use the first equation{p_end}
{synopt :{opt level(#)}}set confidence level; default is level(95){p_end}
{synoptline}
{p 4 4 4}

{title:Description}

{pstd}
{cmd:partpred} calculates partial predictions for regression equations. Multi-equation models are supported via the {cmd:eq()}
option.

{title:Options}

{phang}
{opth for(varlist)} defines which variables are to be included in the prediction. Factor variables are allowed.

{phang}
{opt at(varname # ...)} allows some covariates to take single values over the whole sample.

{phang}
{opt ref(varname # ...)} defines a reference value for continuous variables. For example if the coefficient of variable {it: x} is b then 
in the linear predictor it is included as b({it:x}-#).

{phang}
{opth ci(newvars)} requires the specification of two {it:newvars}, giving the variable names for the 
lower and upper confidence limits.  The level of the confidence intervals is determined by level(#).

{phang}
{opth se(newvar)} requires the specification of a {it:newvar}. The standard error of the partial prediction is generated.
Note that if the {cmd: eform} option is used the standard error is still reported on the original scale.

{phang}
{opt cons} forces the constant term in the partial prediction.

{phang}
{opt eform} Exponentiates the partial prediction (and confidence intervals if applicable).

{phang}
{opt eq(name)} Gives the equation name for multiple equations. The default is to use the first equation.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence intervals.  The default is
{cmd:level(95)} or as set by {help set level}.

{title:Example:}
{pstd} When using non-linear effects using polynomials, splines or similar, it can be useful to plot with a reference value. 
The following fits a non-linear effect of age using polynomials and then uses {cmd:partpred} to obtain
the hazard ratio for different ages with age 60 as the reference age.

{cmd:. webuse brcancer}
{cmd:. stset rectime, failure(censrec=1) scale(365.25)}
{cmd:. gen age = x1}
{cmd:. gen age2 = age^2}
{cmd:. stcox age age2 hormon}
{cmd:. partpred hr_age, for(age age2) ref(age 60 age2 3600) ci(hr_age_lci hr_age_uci) eform}
{cmd:. twoway	(rarea hr_age_lci hr_age_uci age, sort pstyle(ci)) ///}
{cmd:		(line hr_age age, sort) ///}
{cmd:		, legend(off) xtitle(age) ytitle(Hazard Ratio)}
		{it:({stata partpred_examples 1:click to run})}	

{pstd} Factor variables can be used. The following fits an interaction between hormon therapy and age and
then uses {cmd: partpred} to obtain an estimate of the hazard ratio for hormone therapy as a function of age.

{cmd:. webuse brcancer}
{cmd:. stset rectime, failure(censrec=1) scale(365.25)}
{cmd:. gen age = x1}
{cmd:. gen age2 = age^2}
{cmd:. stcox (c.age c.age2)##hormon}
{cmd:. partpred hr_hormon if hormon==1, for(1.hormon 1.hormon#c.age 1.hormon#c.age2) ///}
{cmd:		ci(hr_hormon_lci hr_hormon_uci) eform}
{cmd:. twoway	(rarea hr_hormon_lci hr_hormon_uci age, sort pstyle(ci)) ///}
{cmd:		(line hr_hormon age, sort) ///}
{cmd:		, legend(off) xtitle(age) ytitle(Hazard Ratio)}
		{it:({stata partpred_examples 2:click to run})}	

{title:Author}

{p 2 2 2}
Paul Lambert ({browse "mailto:paul.lambert@le.ac.uk":paul.lambert@le.ac.uk}).

{title:Also see}

{p 0 19}On-line:  help for {help xpredict}, {help predictnl}.
