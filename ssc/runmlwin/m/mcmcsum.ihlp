{smcl}
{* *! mcmcsum.sthlp, Chris Charlton and George Leckie}{...}
{cmd:help mcmcsum}
{hline}

{title:Title}

    {cmd:mcmcsum} - {cmd:runmlwin} postestimation - MCMC summary statistics and plots 
   

{marker syntax}{...}
{title:Syntax}

{pstd}
{cmd:mcmcsum} in parameter mode

{p 8 20 2}
{cmd:mcmcsum}
{it:parameter_list}
{ifin}
[{cmd:,}
{it:options} 
{opt get:chains}]

{pstd}
{cmd:mcmcsum} in variable mode

{p 8 20 2}
{cmd:mcmcsum}
{it:{help varlist}}
{ifin}
[{cmd:,}
{it:options}]
{opt var:iables}


{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Parameter mode only options}
{synopt:{opt get:chains}}save the MCMC parameter chains from the current {cmd:runmlwin} estimation results as variables in the current data set{p_end}

{syntab:Variable mode only options}
{synopt:{opt var:iables}}reads the data from the variables currently in memory instead of the current estimation results{p_end}

{syntab:Main}
{synopt:{opt sq:rt}}base MCMC summary statistics on square rooted MCMC chains{p_end}
{synopt:{opt e:form}}base MCMC summary statistics on exponentiated MCMC chains{p_end}
{synopt:{opt mo:de}}report MCMC chain modes rather than means{p_end}
{synopt:{opt me:dian}}report MCMC chain medians rather than means{p_end}
{synopt:{opt z:ratio}}report classical z-ratios and p-values{p_end}
{synopt:{opt l:evel(#)}}set credible level; default is level(95){p_end}
{synopt:{opt w:idth(#)}}parameter/variable width; default is {cmd:width(13)}{p_end}
{synopt:{opt d:etail}}display additional MCMC statistics{p_end}
{synopt:{help mcmcsum##display_options:display_options}}control column formats{p_end}

{syntab:Graphics}
{synopt:{opt traj:ectories}}trajectory plot for each MCMC chain{p_end}
{synopt:{opt dens:ities}}kernel density plot for each MCMC chain{p_end}
{synopt:{opt five:way}}trajectory, kernal density, ACF, PACF, and MCSE plots for a single chosen MCMC chain{p_end}

{syntab:Advanced options}
{synopt:{opt t:hinning(#)}}specifies that thinning every # iterations was used when storing the MCMC chains{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mcmcsum} is a postestimation command for {cmd:runmlwin}.
{cmd:mcmcsum} calculates and displays a variety of MCMC summary statistics and plots.
These statistics and plots can be based on either the current {cmd:runmlwin} estimation results or the variables currently in memory.


{marker options}{...}
{title:Options}

{dlgtab:Parameter mode only options}

{phang}
{opt getchains} save the MCMC parameter chains from the current {cmd:runmlwin} estimation results as variables in the current data set.
Note this will overwrite the current data set.


{dlgtab:Variable mode only options}

{phang}
{opt variables} reads the data from the variables currently in memory instead of the current estimation results.
The latter is useful if the MCMC chains have been saved to disk.


{dlgtab:Main}

{phang}
{opt sqrt} base MCMC summary statistics on square rooted MCMC chains.
This is useful for MCMC variance parameter chains.

{phang}
{opt eform} base MCMC summary statistics on exponentiated MCMC chains.
This is useful for parameters fitted on the log-odds and log scales (i.e. multilevel logit and poisson models).

{phang}
{opt mode} reports the modes of the MCMC chains rather than the means.

{phang}
{opt median} reports the medians of the MCMC chains rather than the means.

{phang}
{opt zratio} reports classical z-ratios and p-values (i.e. under the assumption that the chains are normally distributed)

{phang}
{opt level(#)} set credible level; default is {cmd:level(95)}.

{phang}
{opt width(#)} parameter/variable width; default is {cmd:width(12)}.

{phang}
{opt detail} display additional MCMC statistics including various percentiles, the Raftery Lewis statistics and the Brooks Draper statistic.

{marker display_options}{...}
{phang}{opt display_options}  cformat({help fmt:%fmt}), pformat({help fmt:%fmt}), sformat({help fmt:%fmt}); see {help estimation options##display_options:[R] estimation options.}

{dlgtab:Graphics}

{phang}
{opt trajectories} display a trajectory plot for each MCMC chain.

{phang}
{opt densities} displays a kernel density plot for each MCMC chain.

{phang}
{opt fiveway} displays a five-way plot containing the MCMC trajectory plot, kernel density plot, ACF plot, PACF plot, and MCSE plot for the chosen MCMC chain.
The trajectory and kernel density plots are as described above.
Note that only one MCMC chain can be specified when using this option. 


{dlgtab:Advanced options}

{phang}
{opt thinning(#)} specifies that thinning every # iterations was used when storing the MCMC chains.



{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

{pstd}
{help mcmcsum##Remarks_using_parameters_mode:Remarks on referencing specific parameters when using parameters mode}{break}
{help mcmcsum##Remarks_variables_mode:Remarks on referencing specific parameters when using variables mode}{break}
{help mcmcsum##remarks_on_mcmc_summary_statistics:Remarks on MCMC summary statistics}{break}
{help mcmcsum##remarks_on_MCMC_plots:Remarks on MCMC plots}{break}


{marker Remarks_using_parameters_mode}{...}
{title:Remarks on referencing specific parameters when using parameters mode}

{pstd}
You can find the names assigned to parameters by {cmd:runmlwin} using the {cmd:mat list e(b)} command.
For example, if your model contains the parameter FP1:cons, you would refer to this as [FP1]cons.
Similarly, the parameter RP2:var(cons) would be referred to as [RP2]var(cons).
See the {bf:Examples} section for an example.


{marker Remarks_variables_mode}{...}
{title:Remarks on referencing specific parameters when using variables mode}

{pstd}
An alternative to referencing the parameters in the current {cmd:runmlwin} estimation results is to
use the {opt getchains} option to save these parameter chains as variables in the current data set.
Note this will overwrite the current data set.
For example, if your model contains the parameter FP1:cons, this would be saved as the variable FP1_cons in your current data set.
Similarly, the parameter RP2:var(cons) would be saved as RP2_var_cons_.
See the {bf:Examples} section for an example.


{marker remarks_on_mcmc_summary_statistics}{...}
{title:Remarks on MCMC summary statistics}

{pstd}
{cmd:mcmcsum} calculates and displays a variety of MCMC summary statistics.

{p 8 12 2}
(1) The chain mean (posterior mean).
This gives the parameter point estimate.

{p 8 12 2}
(2) The MCSE of this mean.
The MCSE will decrease as the chain length is increased.

{p 8 12 2}
(3) The chain standard deviation.
This gives the parameter standard error.

{p 8 12 2}
(4) The chain mode.

{p 8 12 2}
(5) The proportion of chain values of the opposite sign to the chain mean.

{p 8 12 2}
(6) The proportion of chain values of the opposite sign to the chain mode.

{p 8 12 2}
(7) The proportion of chain values of the opposite sign to the chain median.

{p 8 12 2}
(8) The 0.5th, 2.5th, 5th, 25th, 50th, 75th, 95th, 97.5th, and 99.5th quantiles.
The 2.5th and 97.5th quantiles give the 95% Bayesian credible interval.
This is equivalent to a 95% confidence interval in maximum likelihood.
Unlike maximum likelihood, this is not based on a normal sampling distribution assumption.

{p 8 12 2}
(9) The thinned chain length.

{p 8 12 2}
(10) The Effective Sample Size (ESS) gives an estimate of the equivalent number of independent iterations that the chain represents.
The ESS will typically be less than the number of actual iterations because the chain is positively autocorrelated (it is a Markov chain).

{p 8 12 2}
(11) Brooks-Draper (mean):
This statistic is based on the mean of the distribution.
It is used to estimate the length of chain required to produce a mean estimate to 2 significant  figures with a given accuracy.

{p 8 12 2}
(12) Raftery-Lewis (quantile):
This statistic is based on the 2.5th and 97.5th quantiles of the posterior distribution (i.e. the 95% credible interval).
It is used to estimate the length of chain required to estimate the boundaries of the 95% credible interval to a given accuracy.

{pstd}
We recommend users seeking further information to consult the comprehensive MLwiN MCMC manual by
Browne (2012).


{marker remarks_on_MCMC_plots}{...}
{title:Remarks on MCMC plots}

{pstd}
{cmd:mcmcsum} calculates and displays a variety of MCMC plots.

{pstd}
Trajectory plots can be thought of as "time series" plots of each chain.
The chain values are plotted against the iteration number.
Healthy chains are those that resemble white noise.

{pstd}
Kernel density plots are smoothed histograms of the chains.
They plot the posterior distributions, the fundamental things of interest.
Note that posterior distributions for variance parameters will typically be right skewed.

{pstd}
The ACF plot shows the autocorrelation between iteration t and t - k.
A Markov chain should have a power relationship in the lags i.e. if ACF(1) = rho then ACF(2) = rho^2 etc.
This is known as an AR(1) process.
The less correlated the chain the better.

{pstd}
The PACF plot shows the autocorrelation between iteration t and t - k, having accounted for t - 1,...,t - (k - 1).
It is used to identify the extent to which the chain departs from an ACF(1).
That is, it is used to identify the extent of the lag in the chain.
Look for the point on the plot where the partial autocorrelations for all higher lags are essentially zero.

{pstd}
The MCSE is an indication of how much error is in the mean estimate due to the fact that MCMC is used.
As the number of iterations increases the MCSE tends to 0.
The MCSE is used to calculate how long to run the chain to achieve a mean estimate with a particular desired MCSE.

{pstd}
We recommend users seeking further information to consult the comprehensive MLwiN MCMC manual by
Browne (2012).



{marker examples}{...}
{title:Examples}

{pstd}The following examples will only work on your computer if you have installed {cmd:runmlwin}.

{pstd}Two-level random-intercept model, analogous to xtreg{p_end}
    {hline}
{pstd}Setup{p_end}
{phang2}{bf:{stata "use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear":. use http://www.bristol.ac.uk/cmm/media/runmlwin/tutorial, clear}}{p_end}

{pstd}Fit model using IGLS{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) nopause":. runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) nopause}}

{pstd}Fit model using MCMC{p_end}
{phang2}{bf:{stata "runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) mcmc(on) initsprevious nopause":. runmlwin normexam cons standlrt, level2(school: cons) level1(student: cons) mcmc(on) initsprevious nopause}}

{pstd}Calculate and display MCMC summary statistics for all model parameters{p_end}
{phang2}{bf:{stata "mcmcsum":. mcmcsum}}{p_end}

{pstd}Calculate and display additional MCMC summary statistics for all model parameters{p_end}
{phang2}{bf:{stata "mcmcsum, detail":. mcmcsum, detail}}{p_end}

{pstd}Trajectory plots for all model parameters{p_end}
{phang2}{bf:{stata "mcmcsum, trajectories":. mcmcsum, trajectories}}{p_end}

{pstd}Kernel density plots for all model parameters{p_end}
{phang2}{bf:{stata "mcmcsum, densities":. mcmcsum, densities}}{p_end}

{pstd}Fiveway plot for the level 2 variance parameter ([RP2]var(cons)){p_end}
{phang2}{bf:{stata "mcmcsum [RP2]var(cons), fiveway":. mcmcsum [RP2]var(cons), fiveway}}{p_end}

{pstd}Save the MCMC parameter chains from the current {cmd:runmlwin} model as variables in the current data set{p_end}
{phang2}{bf:{stata "mcmcsum, getchains":. mcmcsum, getchains}}{p_end}

{pstd}Compute the intraclass correlation (a non-linear combination of model parameters){p_end}
{phang2}{bf:{stata "gen icc = RP2_var_cons_/(RP2_var_cons_ +  RP1_var_cons_)":. gen icc = RP2_var_cons_/(RP2_var_cons_ +  RP1_var_cons_)}}{p_end}

{pstd}Calculate and display a variety of MCMC summary statistics for the derived ICC parameter{p_end}
{phang2}{bf:{stata "mcmcsum icc, variables":. mcmcsum icc, variables}}{p_end}

{pstd}Fiveway plot for the ICC parameter{p_end}
{phang2}{bf:{stata "mcmcsum icc, fiveway variables":. mcmcsum icc, fiveway variables}}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:mcmcsum} saves the following in {cmd:r()} when no {it:{help mcmcsum##plot:plot}} is specified:

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(thinnedchain)}}length of chain after thinning{p_end}
{synopt:{cmd:r(mean)}}mean of parameter chain{p_end}
{synopt:{cmd:r(mode)}}mode of parameter chain{p_end}
{synopt:{cmd:r(sd)}}standard deviation of parameter chain{p_end}
{synopt:{cmd:r(ess)}}effective sample size{p_end}
{synopt:{cmd:r(meanmcse)}}mean Monte-Carlo standard error{p_end}
{synopt:{cmd:r(bd)}}Brook-Draper diagnostic statistic{p_end}
{synopt:{cmd:r(rlub)}}Raftery-Lewis upper bound{p_end}
{synopt:{cmd:r(rllb)}}Raftery-Lewis lower bound{p_end}
{synopt:{cmd:r(p99_5)}}99.5% quantile of the chain{p_end}
{synopt:{cmd:r(p95)}}95% quantile of the chain{p_end}
{synopt:{cmd:r(p75)}}75% quantile of the chain{p_end}
{synopt:{cmd:r(p50)}}50% quantile (median) of the chain{p_end}
{synopt:{cmd:r(p25)}}25% quantile of the chain{p_end}
{synopt:{cmd:r(p5)}}5% quantile of the chain{p_end}
{synopt:{cmd:r(p2_5)}}2.5% quantile of the chain{p_end}
{synopt:{cmd:r(p0_5)}}0.5% quantile of the chain{p_end}
{p2colreset}{...}


{marker about_cmm}{...}
{title:About the Centre for Multilevel Modelling}

{pstd}
The MLwiN software is developed at the Centre for Multilevel Modelling.
The Centre was established in 1986, and has been supported largely by project grants from the UK Economic and Social Research Council.
The Centre has been based at the University of Bristol since 2005.

{pstd}
The Centre’s website:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm":http://www.bristol.ac.uk/cmm}

{pstd}
contains much of interest, including new developments, and details of courses and workshops.
This website also contains the latest information about the MLwiN software, including upgrade information,
maintenance downloads, and documentation.

{pstd}
The Centre also runs a free online multilevel modelling course:

{p 8 12 2}{browse "http://www.bristol.ac.uk/cmm/learning/course.html":http://www.bristol.ac.uk/cmm/learning/course.html}

{pstd}
which contains modules starting from an introduction to quantitative research progressing to multilevel modelling of 
continuous and categorical data.
Modules include a description of concepts and models and instructions of how to carry out analyses in MLwiN, Stata and R.
There is a also a user forum, videos and interactive quiz questions for learners’ self-assessment.


{marker citation}{...}
{title:How to cite {cmd:runmlwin} and MLwiN}

{pstd}{cmd:runmlwin} is not an official Stata command.
It is a free contribution to the research community, like a paper.
Please cite it as such:

{p 8 12 2}
Leckie, G. and Charlton, C. 2013. {cmd:runmlwin} - A Program to Run the MLwiN Multilevel Modelling Software from within Stata. Journal of Statistical Software, 52 (11),1-40.{break}
{browse "http://www.jstatsoft.org/v52/i11":http://www.jstatsoft.org/v52/i11}

{pstd}Similarly, please also cite the MLwiN software:

{p 8 12 2}
Rasbash, J., Charlton, C., Browne, W.J., Healy, M. and Cameron, B. 2009. MLwiN Version 2.1. Centre for Multilevel Modelling, 
University of Bristol.

{pstd}For models fitted using MCMC estimation, we ask that you additionally cite:

{p 8 12 2}
Browne, W.J. 2012. MCMC Estimation in MLwiN, v2.26. Centre for Multilevel Modelling, University of Bristol.


{marker user_forum}{...}
{title:The {cmd:runmlwin} user forum}

{pstd}Please use the {cmd:runmlwin} user forum to post any questions you have about {cmd:runmlwin}.
We will try to answer your questions as quickly as possible, but where you know the answer to another user's question please also reply to them!

{p 8 12 2}{browse "http://www.cmm.bristol.ac.uk/forum/viewforum.php?f=3":http://www.cmm.bristol.ac.uk/forum/}


{marker authors}{...}
{title:Authors}

{p 4}Chris Charlton{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}
{p 4}{browse "mailto:c.charlton@bristol.ac.uk":c.charlton@bristol.ac.uk}{p_end}

{p 4}George Leckie{p_end}
{p 4}Centre for Multilevel Modelling{p_end}
{p 4}University of Bristol{p_end}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd} The code to calculate the MCMC summary statistics was adapted from that written by Bill Browne for the MCMC engine in the MLwiN software (Browne, 2012).
We are very grateful to colleagues at the Centre for Multilevel Modelling and the University of Bristol for their useful comments.

{pstd}The development of this command was funded under the LEMMA project, a node of the
UK Economic and Social Research Council's National Centre for Research Methods (grant number RES-576-25-0003).


{marker disclaimer}{...}
{title:Disclaimer}

{pstd}{cmd:mcmcsum} comes with no warranty.
Where users are using {cmd:mcmcsum} after fitting a model by {cmd:runmlwin},
we recommend that users check their results with those obtained through operating MLwiN by its graphical user interface.


{marker references}{...}
{title:References}

{p 4 8 2}
Browne, W.J. 2009. MCMC Estimation in MLwiN, v2.13.  Centre for Multilevel Modelling, University of Bristol.{break}
{browse "http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html":http://www.bristol.ac.uk/cmm/software/mlwin/download/manuals.html}

{p 4 8 2}
Leckie, G. and Charlton, C. 2013. {cmd:runmlwin} - A Program to Run the MLwiN Multilevel Modelling Software from within Stata. Journal of Statistical Software, 52 (11),1-40.{break}
{browse "http://www.jstatsoft.org/v52/i11":http://www.jstatsoft.org/v52/i11}


{title:Also see}

{psee}
Online:  {bf:{help runmlwin}}, {bf:{help usewsz}}, {bf:{help savewsz}}, {bf:{help reffadjust}}, {bf:{help winbugs}}
{p_end}

