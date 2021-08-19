{smcl}
{* January 15th 2021}{...}
{hline}
 {cmd:srtfreq} {hline 2} Effect Size calculation for Simple Randomised Trials
{hline}

{marker syntax}{...}
{title:Syntax}

	{cmd:srtfreq} {varlist} {ifin}{cmd:,} {opt int:ervention(interv_var)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr: main}
{synoptline}
{synopt :{opt int:ervention()}}requires a factor variable identifying the intervention (arms) of the trial.{p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt seed(#)}}seed number; default is 1020252.{p_end}
{synopt :{opt np:erm(#)}}number of permutations; default is NULL. {p_end}
{synopt :{opt nb:oot(#)}}number of bootstraps; default is NULL. {p_end}

{syntab:Reporting}
{synopt :{opt noi:sily}}displays the calculation of conditional models.{p_end}
{synopt :{opt show:progress}}displays progress of permutations/bootstraps.{p_end}
{synoptline}
{phang}
{it:varlist} and {cmd:intervention()} may contain factor-variable operators; see {help fvvarlist}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:srtfreq} Performs analysis of educational trials under the assumption of independent errors among pupils; this can also be used with schools as fixed effects.
The analysis produces {cmd:Effect Size} (ES) estimates for both conditional and unconditional model specifications in Simple Randomised Trials. It also allows for sensitivity analysis options such as permutations
and bootstraps.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt seed(#)} Sets seed number for permutations/bootstraps.

{phang}
{opt nperm(#)} Specifies number of permutations required to generate a permutated p-value. 
When specified, a list of generated variables ({cmd:PermC_I#}, {cmd:PermUnc_I#}) attaches to the user's dataset containing the permutated estimates. 
I# denotes number of arms of the {it:interv_var} and C/Unc denotes Conditional and Unconditional estimates. 

{phang}
{opt nboot(#)} Specifies number of bootstraps required to generate bootstrap confidence intervals. 
When specified, a list of generated variables ({cmd:BootC_I#}, {cmd:BootUnc_I#}) attaches to the user's dataset containing the bootstrap estimates. 
I# denotes number of arms of the {it:interv_var} and C/Unc denotes Conditional and Unconditional estimates. 

{phang}
Any attached variables from previous use of {cmd:srtfreq} will be replaced.


{dlgtab:Reporting}

{phang}
{opt noisily} Displays the permutated/bootstrapped conditional models' regression results as they occur.
 
{phang}
{opt showprogress} Displays progress of permutations/bootstraps using dots, counting them by blocks of 10.



{marker Examples}{...}
{title:Examples}

 {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use mstData.dta}{p_end}

{pstd}Simple model{p_end}
{phang2}{cmd:. srtfreq Posttest Prettest, int(Intervention)}{p_end}

{pstd}Model using permutations including Schools as fixed effects with base level change{p_end}
{phang2}{cmd:. srtfreq Posttest Prettest i.School, int(ib(#2).Intervention) nperm(3000)}{p_end}

{pstd}Model using permutations and bootstraps with three-arm intervention variable{p_end}
{phang2}{cmd:. srtfreq Posttest Prettest, int(Intervention2) nperm(3000) nboot(2000) noisily}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:srtfreq} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(CondES)}}conditional Hedges’ g effect size and its 95% confidence intervals for the trial arm(s) in {it:interv_var}. If nboot is specified, CIs are replaced with bootstrapped CIs.{p_end}
{synopt:{cmd:r(UncondES)}}unconditional effect size for the trial arm(s) in {it:interv_var}, obtained based on variance from the unconditional model (model with only the intercept as a fixed effect).{p_end}
{synopt:{cmd:r(Beta)}}estimates and confidence intervals for variables specified in the model.{p_end}
{synopt:{cmd:r(Sigma2)}}residual variance for conditional and unconditional models.{p_end}



{p_end}