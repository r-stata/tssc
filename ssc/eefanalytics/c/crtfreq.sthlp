{smcl}
{* January 15th 2021}{...}
{hline}
 {cmd:crtfreq} {hline 2} Effect Size calculation for Cluster Randomised Trials
{hline}

{marker syntax}{...}
{title:Syntax}

	{cmd:crtfreq} {varlist} {ifin}{cmd:,} {opt int:ervention(interv_var)} {opt ran:dom(clust_var)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr: main}
{synoptline}
{synopt :{opt int:ervention()}}requires a factor variable identifying the intervention (arms) of the trial.{p_end}
{synopt :{opt ran:dom()}}requires a factor variable identifying the clusters (Schools) of the trial.{p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt ml}}fits model via maximum likelihood. Default is RMLE.{p_end}
{synopt :{opt seed(#)}}seed number; default is 1020252.{p_end}
{synopt :{opt np:erm(#)}}number of permutations; default is NULL. {p_end}
{synopt :{opt nb:oot(#)}}number of bootstraps; default is NULL. {p_end}
{synopt :{opt *}}maximization options such as {cmd:technique()}, {cmd:difficult}, {cmd:iterate()}. {p_end}

{syntab:Reporting}
{synopt :{opt noi:sily}}displays the calculation of conditional models.{p_end}
{synopt :{opt show:progress}}displays progress of permutations/bootstraps.{p_end}
{synoptline}
{phang}
{it:varlist} and {cmd:intervention()} may contain factor-variable operators; see {help fvvarlist}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:crtfreq} Performs analysis of cluster randomised trials using a multilevel model under a frequentist setting.
This analysis produces {cmd:Effect Size} (ES) estimates for both conditional and unconditional model specifications. It also allows for sensitivity analysis options such as permutations
and bootstraps.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt ml} Calculates model using maximum likelihood estimation; default is Restricted Maximum Likelihood.

{phang}
{opt seed(#)} Sets seed number for permutations/bootstraps.

{phang}
{opt nperm(#)} Specifies number of permutations required to generate a permutated p-value. 
When specified, a list of generated variables ({cmd:PermC_I#_W}, {cmd:PermC_I#_T}, {cmd:PermUnc_I#_W}, {cmd:PermUnc_I#_T}) attaches to the user's dataset, containing the permutated effect sizes. 
I# denotes number of arms of the {it:interv_var} and C/Unc denotes Conditional and Unconditional estimates using residual variance (Within) indicated by suffix “_W” and total variance (Total) indicated by suffix “_T”. 

{phang}
{opt nboot(#)} Specifies number of bootstraps required to generate the bootstrap confidence intervals. 
When specified, a list of generated variables ({cmd:BootC_I#_W}, {cmd:BootC_I#_T}, {cmd:BootUnc_I#_W}, {cmd:BootUnc_I#_T}) attaches to the user's dataset, containing the permutated effect sizes. 
I# denotes number of arms of the {it:interv_var} and C/Unc denotes Conditional and Unconditional estimates using residual variance (Within) indicated by suffix “_W” and total variance (Total) indicated by suffix “_T”.

{phang2}
Any attached variables from previous use of {cmd:crtfreq} will be replaced.

{phang}
{cmd:*} Additional maximization options are allowed including {cmd:technique()}, {cmd:difficult}, {cmd:iterate()} see {helpb maximize:[R] Maximize}. {p_end}

{dlgtab:Reporting}

{phang}
{opt noisily} Displays the permutated/bootstrapped conditional models' regression results as they occur.
 
{phang}
{opt showprogress} Displays progress of permutations/bootstraps using dots, counting them by blocks of 10.



{marker Examples}{...}
{title:Examples}

 {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use crtData.dta}{p_end}

{pstd}Simple model{p_end}
{phang2}{cmd:. crtfreq Posttest Prettest, int(Intervention) ran(School)}{p_end}

{pstd}Model using permutations including if condition, additional maximization options and base level change{p_end}
{phang2}{cmd:. crtfreq Posttest Prettest if School!= 22, int(ib1.Intervention) ran(School) nboot(3000) technique(dfp) difficult}{p_end}

{pstd}Model using permutations and bootstraps with three-arm intervention variable and maximum likelihood estimation{p_end}
{phang2}{cmd:. crtfreq Posttest Prettest, int(Intervention2) ran(School) nperm(3000) nboot(2000) ml show}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:crtfreq} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(CondES#)}}conditional Hedges’ g effect size and its 95% confidence intervals for # number of arms in {it:interv_var}. If nboot is specified, CIs are replaced with bootstrapped CIs.{p_end}
{synopt:{cmd:r(UncondES#)}}unconditional effect size for # number of arms in {it:interv_var}, obtained based on variances from the unconditional model (model with only the intercept as a fixed effect).{p_end}
{synopt:{cmd:r(Beta)}}estimates and confidence intervals for variables specified in the model.{p_end}
{synopt:{cmd:r(Cov)}}variance decomposition into between cluster variance (Schools), within cluster variance (Pupils) and Total variance. It also contains intra-cluster correlation (ICC).{p_end}
{synopt:{cmd:r(SchEffects)}}estimated deviation of each school from the intercept and intervention slope.{p_end}
