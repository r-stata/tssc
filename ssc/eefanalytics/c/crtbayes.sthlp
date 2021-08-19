{smcl}
{* January 15th 2021}{...}
{hline}
 {cmd:crtbayes} {hline 2} Bayesian Effect Size calculation for Cluster Randomised Trials
{hline}

{marker syntax}{...}
{title:Syntax}

	{cmd:crtbayes} {varlist} {ifin}{cmd:,} {opt int:ervention(interv_var)} {opt ran:dom(clust_var)} [{it:options}]

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
{synopt :{opt *}}additional Bayesian arguments to be passed to the command. Stata defaults apply.{p_end}
{syntab:Reporting}
{synopt :{opt thr:eshold(#)}}a real scalar or vector of threshold(s) for estimating Bayesian posterior probability.{p_end}
{synopt :{opt sepch:ains}}stores summary statistics for each chain.{p_end}
{synopt :{opt diag:nostics}}generates convergence diagnostic graphs.{p_end}
{synopt :{opt noi:sily}}displays regression output.{p_end}
{synopt :{opt save}}saves the simulation output.{p_end}
{synoptline}
{phang}
{it:varlist} and {cmd:intervention()} may contain factor-variable operators; see {help fvvarlist}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:crtbayes} performs {cmd:Effect Size} (ES) calculation of cluster randomised education trials using a multilevel model under a Bayesian setting. This analysis produces ES estimates for both conditional and unconditional model specifications. 



{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt *} Additional Bayesian arguments to be passed to the command such as {cmd:mcmcsize(#) burnin(#) rseed(#) nchains(#)} and custom priors. Stata defaults of Bayesian mixed models apply; see {opt bayes} prefix ({manhelp bayes BAYES}).


{dlgtab:Reporting}

{phang}
{opt threshold(#)} A real scalar or vector for estimating Bayesian posterior probability such that the observed effect size is greater than or equal to the threshold(s).{p_end}

{phang}
{opt sepchains} Stores summary statistics for each number of chains specified in {cmd:nchains(#)}.

{phang}
{opt diagnostics} Generates convergence diagnostic graphs for each number of chains specified in {cmd:nchains(#)}.

{phang}
{opt noisily} Displays regression output for both conditional and unconditional models.{p_end}

{phang}
{opt save} Saves simulation output in two datasets {cmd:(mcmcUncCRT.dta, mcmcCondCRT.dta)} containing the simulation output for the conditional and unconditional models.



{marker Examples}{...}
{title:Examples}

 {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. use crtData.dta}{p_end}

{pstd}Simple model{p_end}
{phang2}{cmd:. crtbayes Posttest Prettest, int(Intervention) ran(School)}{p_end}

{pstd}Model using custom simulation options and all diagnostic options with base level change{p_end}
{phang2}{cmd:. crtbayes Posttest Prettest, int(ib1.Intervention) ran(School) thr(0.1) mcmcsize(50000) burnin(50000) rseed(1234) nchains(4) sepch diag save}{p_end}

{pstd}Model using custom simulation options with three-arm intervention variable and custom priors{p_end}
{phang2}{cmd:. crtbayes Posttest Prettest, int(Intervention2) ran(School) mcmcsize(50000) burnin(50000) rseed(1234) nchains(4) prior({Posttest:_cons}, uniform(-50,50))}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:crtbayes} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(CondES#)}}conditional Hedges’ g effect size and its 95% credible intervals for # number of arms in {it:interv_var}.{p_end}
{synopt:{cmd:r(UncondES#)}}unconditional effect size for # number of arms in {it:interv_var}, obtained based on within and total variance from the unconditional model.{p_end}
{synopt:{cmd:r(Beta)}}estimates and credible intervals for variables specified in the model.{p_end}
{synopt:{cmd:r(Cond_ProbES#)}}a matrix of Bayesian Posterior Probabilities for the conditional model, such that the observed effect size is greater than or equal to a pre-specified threshold(s) for arm #.{p_end}
{synopt:{cmd:r(Uncond_ProbES#)}}a matrix of Bayesian Posterior Probabilities for the unconditional model, such that the observed effect size is greater than or equal to a pre-specified threshold(s) for arm #.{p_end}
{synopt:{cmd:r(Cov)}}a matrix of variance decomposition into between cluster variance (Schools), within cluster variance (Pupils) and Total variance. It also contains intra-cluster correlation (ICC).{p_end}
{synopt:{cmd:r(SchEffects)}}a vector of the estimated deviation of each school from the intercept.{p_end}
{synopt:{cmd:r(sepchains_#)}}stores summary statistics for # number of chains separately.{p_end}

{p_end}