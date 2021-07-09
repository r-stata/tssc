{smcl}
{* April 4th 2019}{...}
{viewerdialog xtoos_bin_i "dialog xtoos_bin_i"}{...}
{vieweralsosee "[XT] xtoos_bin_t" "help xtoos_bin_t"}{...}
{vieweralsosee "[XT] xtoos_t" "help xtoos_t"}{...}
{vieweralsosee "[XT] xtoos_i" "help xtoos_i"}{...}

{hline}
Help for {hi:xtoos_bin_i}
{hline}

{title:Description}

{p}{cmd:xtoos_bin_i} evaluates the out-of-sample prediction performance of a specified panel data model with a binary dependent variable in a cross-individual dimension.{p_end}

{p}The procedure excludes a group of individuals (e.g.countries) defined by the user from the estimation sample (including all their observations throughout time).
Then for each remaining subsample it fits the specified model and uses the resulting parameters to predict the probability of ocurrence of the dependent variable in the unused individuals (out-of-sample).{p_end}
{p}The procedure evaluates the prediction performance based on the area under the receiver operator characteristic (ROC) statistic evaluated in both the training sample and the out-of-sample.{p_end}

{p}{cmd:xtoos_bin_i} allows to choose different estimation methods (e.g.logit, probit, xtprobit) and could also be used in a cross-section dataset only.{p_end}

{p}The individuals excluded (learning sample) could be:{p_end}
{p}i) Random subsamples of size {it:n}; if the whole sample contains {it:N} individuals, then {it:N/n} subsamples without repeated individuals are extracted and evaluated. Moreover, the sampling process could be repeated {it:r} times.{p_end}
{p}ii) an ordered partition of the sample in subsamples of size {it:k}; if the whole sample contains {it:N} individuals, then {it:N/k} ordered subsamples are formed and evaluated.{p_end}
{p}iii) a particular individual or a particular group (e.g.a country or a region).{p_end}

{title:Syntax}

{cmd:xtoos_bin_i} {depvar} [{indepvars}] [{it:if}], 
	[{opt o:us(integer)}] [{opt r:smpl(integer)}] [{opt k:smpl(integer)}] [{opt mpr:ob(string)}]  
	[{opt ev:alopt(varname)}] [{opt m:et}] [{opt fe}]  
	[{it:model_options}]

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt o:us()}}Specifies the size {it:n} of each random subsample (i.e. the number of individuals) that is excluded from each (in)sample estimation, and for which the prediction performance is evaluated.{p_end}

{synopt:{opt r:smpl()}}Specifies the number {it:r} of times the random sampling process is repeated. The default is (1). If this parameter is defined as zero, the procedure will not perform any random sampling.{p_end}

{synopt:{opt k:smpl()}}Specifies the size {it:k} of each partition or (non-random) subsample, i.e. the number of individuals in each partition, and for which the prediction performance is evaluated. The size {it:k} automatically determines the number of subsamples. If this parameter is defined as zero, the procedure will not perform any partition.{p_end}

{synopt:{opt mpr:ob()}}Specifies the method of estimating the probability of a positive outcome that depends on the estimation method used (e.g. prob, pu0, pc1).{p_end}

{synopt:{opt ev:alopt()}}Specifies a particular individual or group of individuals to be excluded from the estimation (in)sample and for which the prediction performance is evaluated. The particular individual or group must be defined by a dummy variable equal to one for those individuals.{p_end}

{synopt:{opt m:et()}}Specifies the estimation method. The default is {cmd:xtlogit}.{p_end}

{synopt:{opt fe}}Estimates using Fixed-Effects (within) estimator.{p_end}

{synopt:{it:model_options}}Specifies any other estimation options specific to the method used and not defined elsewhere.{p_end}
{synoptline}

{marker Examples}{...}
{title:Examples}

Use of {cmd:xtoos_bin_i} to evaluate the prediction perfomance based on ROC for 3 random subsamples of 1500 individuals ({opt r:smpl()} and {opt o:us()}) 
and ordered subsamples of also 1500 individuals ({opt k:smpl()})

{p 4 8 2}{cmd:. webuse union, clear}{p_end}
{p 4 8 2}{cmd:. xtoos_bin_i union age grade i.not_smsa south##c.year, k(1500) o(1500) r(3) mprob(pr)}{p_end}

Use of {cmd:xtoos_bin_i} using Fixed-Effects (within) estimator and the estimation option pc1 for the predicted probability

{p 4 8 2}{cmd:. xtoos_bin_i union age grade i.not_smsa south##c.year, k(1500) o(1500) r(3) mprob(pc1) fe}{p_end}

Use of {cmd:xtoos_bin_i} using as estimation method the command {cmd:xtprobit}

{p 4 8 2}{cmd:. xtoos_bin_i union age grade i.not_smsa south##c.year, k(1500) o(1500) r(3) mprob(pr) met(xtprobit)}{p_end}

Use of {cmd:xtoos_bin_i} to evaluate the prediction perfomance based on ROC, but restricting the evaluation only to individual # 1  

{p 4 8 2}{cmd:. gen id1to50=idcode<=50}{p_end}
{p 4 8 2}{cmd:. xtoos_bin_i union age grade i.not_smsa south##c.year, k(1500) o(1500) r(3) mprob(pr) evalopt(id1to50)}{p_end}


{marker results}{...}
{title:Stored results}

{p}{cmd:xtoos_bin_i} displays one table for each possible way of generating an learning sample and of evaluating the model's out-of-sample performance, i.e. either random-sampling, ordered partition or particular individuals.{p_end}

{pstd}
{cmd:xtoos_bin_i} stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2: Matrices}{p_end}
{synopt:{cmd:r(random)}}evaluation results after random-sampling{p_end}
{synopt:{cmd:r(ordered)}}evaluation results for ordered partition{p_end}
{synopt:{cmd:r(specific)}}evaluation results for particular individuals{p_end}


{title:Author}

Alfonso Ugarte-Ruiz
alfonso.ugarte@bbva.com

