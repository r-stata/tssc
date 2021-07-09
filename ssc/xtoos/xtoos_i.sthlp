{smcl}
{* April 4th 2019}{...}
{viewerdialog xtoos_i "dialog xtoos_i"}{...}
{vieweralsosee "[XT] xtoos_t" "help xtoos_t"}{...}
{vieweralsosee "[XT] xtoos_bin_t" "help xtoos_bin_t"}{...}
{vieweralsosee "[XT] xtoos_bin_i" "help xtoos_bin_i"}{...}
{hline}
Help for {hi:xtoos_i}
{hline}

{title:Description}

{p}{cmd:xtoos_i} evaluates the out-of-sample prediction performance of a specified panel data model in a cross-individual dimension.{p_end}

{p}The procedure excludes a group of individuals (e.g.countries) defined by the user from the estimation sample (including all their observations throughout time).
Then for each remaining subsample it fits the specified model and uses the resulting parameters to predict the dependent variable in the unused individuals (out-of-sample).{p_end}

{p}{cmd:xtoos_i} Although the default estimation method is {cmd:xtreg}, the procedure allows to choose different estimation methods including some dynamic methodologies and could also be used in a cross-section dataset only.{p_end}

{p}{cmd:xtoos_i} reports the specified model's forecasting performance, both in absolute terms (RMSE) and also relative to an alternative model by means of an U-Theil ratio. 
By default, the alternative model is a "naive" prediction in which the mean of all in-sample individuals at every period is used as a prediction for the excluded ones.  
The procedure also allows to use an AR1 model as the alternative model for the comparison.{p_end}
{p}It also reports several in-sample and out-of-sample statistics of both the specified and the comparison models.{p_end}

{p}The individuals excluded (learning sample) could be:{p_end}
{p}i) Random subsamples of size {it:n}; if the whole sample contains {it:N} individuals, then {it:N/n} subsamples without repeated individuals are extracted and evaluated. Moreover, the sampling process could be repeated {it:r} times.{p_end}
{p}ii) an ordered partition of the sample in subsamples of size {it:k}; if the whole sample contains {it:N} individuals, then {it:N/k} ordered subsamples are formed and evaluated.{p_end}
{p}iii) a particular individual or a particular group (e.g.a country or a region).{p_end}

{p}Additionally, it allows to draw a graph with the model's prediction for a particular individual or a particular group, when those individuals are not included in the estimation sample. {p_end}

{title:Syntax}

{cmd:xtoos_i} {depvar} [{indepvars}] [{it:if}], {opt *o:us(integer)} {opt *k:smpl(integer)}
	[{opt r:smpl(integer)}]	[{opt ev:alopt(varname)}] [{opt m:et}] [{opt mc:omp(string)}] [{opt fe}] 
	[{opt dum}] [{opt lags(numlist)}] [{opt hgraph}] [{it:model_options}]

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt *o:us()}}Specifies the size {it:n} of each random subsample (i.e. the number of individuals) that is excluded from each (in)sample estimation, and for which the prediction performance is evaluated.{p_end}

{synopt:{opt r:smpl()}}Specifies the number {it:r} of times the random sampling process is repeated. The default is (1). If this parameter is defined as zero, the procedure will not perform any random sampling.{p_end}

{synopt:{opt *k:smpl()}}Specifies the size {it:k} of each partition or (non-random) subsample, i.e. the number of individuals in each partition, and for which the prediction performance is evaluated. 
The size {it:k} automatically determines the number of subsamples. If this parameter is defined as zero, the procedure will not perform any partition.{p_end}

{synopt:{opt ev:alopt()}}Specifies a particular individual or group of individuals to be excluded from the estimation (in)sample and for which the prediction performance is evaluated. The particular individual or group must be defined by a dummy variable equal to one for those individuals.{p_end}

{synopt:{opt cd:ate()}}Specifies the date at which the evaluation performance ends, i.e. the current date or the date at which the sample ends.  
It allows Yearly, Quarterly and Monthly dates, or integer numbers, only. Quarterly and Monthly dates should be written as 1990q1 or 1990m1.{p_end}

{synopt:{opt m:et()}}Specifies the estimation method. The default is {cmd:xtreg}.{p_end}

{synopt:{opt mc:omp()}}Specifies the estimation method for the AR1 model used as a comparison and for estimating the U-Theil, when an AR1 is preferred to a "naive" prediction. 
The AR1 could be estimated by dynamic panel methods such as {cmd:xtabond} or {cmd:xtdpdsys}, or simply by {cmd:xtreg} or {cmd:reg}.{p_end}

{synopt:{opt fe}}Estimates using Fixed-Effects (within) estimator.{p_end}

{synopt:{opt dum}}Estimates including one dummy variable per individual in the specification.{p_end}

{synopt:{opt lags()}}Specifies the number of lags of the dependent variable that must be included the specification, the default is zero lags.
This option should be used when using a dynamic panel methods such as {cmd:xtabond} or {cmd:xtdpdsys}.  If other estimation method is being used,
the command {cmd:xtoos_t} also allows to write down the desired lagged dependent variables terms simply as other explanatory variables. {p_end}

{synopt:{opt hgraph}}Generates a graph with the model's prediction for a particular individual or a particular group, when those individuals are not included in the estimation sample.
The graph displays the actual dependent variable together with the model's prediction for each individual and the alternative (comparison) prediction, which by default
corresponds to the in-sample mean at every period. This option must be run together with the option {opt ev:alopt()}.{p_end}

{synopt:{it:model_options}}Specifies any other estimation options specific to the method used and not defined elsewhere.{p_end}
{synoptline}

{marker Examples}{...}
{title:Examples}

Use of {cmd:xtoos_i} to evaluate the prediction performance for 20 random subsamples of 40 individuals ({opt r:smpl()} and {opt o:us()}) 
and ordered subsamples of also 40 individuals ({opt k:smpl()})

{p 4 8 2}{cmd:. webuse abdata, clear}{p_end}
{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40)}{p_end}

Use of {cmd:xtoos_i} including lags of the dependent variable in the specification.  The following three specifications are equivalent:

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) lags(3)}{p_end}
{p 4 8 2}{cmd:. xtoos_i l(0/3).n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) {p_end}
{p 4 8 2}{cmd:. xtoos_i n l.n l2.n l3.n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) lags(3)}{p_end}

Use of {cmd:xtoos_i} using a dynamic model method, either {cmd:xtabond} or {cmd:xtdpdsys}. 
In this case, the default specification includes one lag of the dependent variable

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) met(xtabond)}{p_end}
{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) met(xtdpdsys) lags(2)}{p_end}

Use of {cmd:xtoos_i} to evaluate the prediction performance between periods 15 and 20, but restricting the evaluation only to first 6 individuals

{p 4 8 2}{cmd:. gen id1to6=id<=6}{p_end}
{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) evalopt(id1to6)}{p_end}

Use of {cmd:xtoos_i} using as estimation method the command {cmd:xtregar}

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) met(xtregar)}{p_end}

Use of {cmd:xtoos_i} using OLS ({cmd:reg}) as the estimation method for the AR(1) comparison model 

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) mcomp(reg)}{p_end}

Use of {cmd:xtoos_i} using Fixed-Effects (within) estimator (the estimated individual components cannot be included in the prediction of the out-of-sample individuals)

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) fe}{p_end}

Use of {cmd:xtoos_i} using dummy variables per individual (the estimated dummy variable coefficients cannot be included in the prediction of the out-of-sample individuals)

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(20) ksmpl(40) dum}{p_end}

Use of {cmd:xtoos_i} to evaluate the prediction performance restricting the evaluation only to first 6 individuals, while drawing a graph with the prediction for each one of those 6 individuals

{p 4 8 2}{cmd:. xtoos_i n w l.w k l.k ys l.ys, ous(40) rsmpl(0) ksmpl(40) evalopt(id1to6) hgraph}{p_end}

{marker results}{...}
{title:Stored results}

{p}{cmd:xtoos_i} displays one table for each possible way of generating an learning sample and of evaluating the model's out-of-sample performance, i.e. either random-sampling, ordered partition or particular individuals.{p_end}

{pstd}
{cmd:xtoos_i} stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2: Matrices}{p_end}
{synopt:{cmd:r(random)}}evaluation results after random-sampling{p_end}
{synopt:{cmd:r(ordered)}}evaluation results for ordered partition{p_end}
{synopt:{cmd:r(specific)}}evaluation results for particular individuals{p_end}


{title:Author}

Alfonso Ugarte-Ruiz
alfonso.ugarte@bbva.com

