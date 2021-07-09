{smcl}
{* April 4th 2019}{...}
{viewerdialog xtoos_bin_t "dialog xtoos_bin_t"}{...}
{vieweralsosee "[XT] xtoos_bin_i" "help xtoos_bin_i"}{...}
{vieweralsosee "[XT] xtoos_t" "help xtoos_t"}{...}
{vieweralsosee "[XT] xtoos_i" "help xtoos_i"}{...}

{hline}
Help for {hi:xtoos_bin_t}
{hline}

{title:Description}

{p}{cmd:xtoos_bin_t} evaluates the out-of-sample prediction performance of a specified panel-data model with a binary dependent variable in a time-series dimension.{p_end}

{p}The procedure excludes a number of time periods defined by the user from the estimation sample for each individual in the panel.
Then for the remaining subsample it fits the specified model and uses the resulting parameters to forecast the probability of ocurrence of the dependent variable in the unused periods (out-of-sample).{p_end} 

{p}The unused time-period set is then recursively reduced by one period in every subsequent step and the estimation and forecasting procedures are repeated, 
until there are no more periods ahead that could be evaluated.{p_end}

{p}The procedure evaluates the prediction performance based on the area under the receiver operator characteristic (ROC) statistic evaluated in both the training sample and the out-of-sample.{p_end}

{p}{cmd:xtoos_bin_t} allows to choose different estimation methods different estimation methods (e.g. logit, probit, xtprobit) and could also be used in a time-series dataset only.{p_end}
{p}{cmd:xtoos_bin_t} allows to evaluate the model's forecasting performance for one particular individual or for a defined group of individuals instead of the whole panel.{p_end}

{p}The performance results are broken down and reported in two different ways:{p_end}
{p}1) According to the last period included in the estimation sample.{p_end}
{p}2) According to the length of the forecasting horizon.{p_end}


{title:Syntax}

{cmd:xtoos_bin_t} {depvar} [{indepvars}] [{it:if}], 
	[{opt ind:ate(string)}] [{opt cd:ate(string)}] [{opt mpr:ob(string)}] [{opt ev:alopt(varname)}] 
	[{opt m:et(string)}] [{opt fe}] [{opt dum}] 
	[{it:model_options}]


{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt ind:ate()}}Specifies the last date (time-period) included in the estimation sample in the first step of the recursive procedure, 
i.e. it defines the date at which the performace evaluation starts. It allows Yearly, Quarterly and Monthly dates, or integer numbers, only. Quarterly and Monthly dates should be written as 1990q1 or 1990m1.{p_end}

{synopt:{opt cd:ate()}}Specifies the date at which the evaluation performance ends, i.e. the current date or the date at which the sample ends.  
It allows Yearly, Quarterly and Monthly dates, or integer numbers, only. Quarterly and Monthly dates should be written as 1990q1 or 1990m1.{p_end}

{synopt:{opt mpr:ob()}}Specifies the method of estimating the probability of a positive outcome that depends on the estimation method used (e.g. prob, pu0, pc1).{p_end}

{synopt:{opt ev:alopt()}}Specifies a particular individual or group of individuals for which the prediction performance is evaluated. 
The particular individual or group must be defined by a dummy variable equal to one for those individuals.{p_end}

{synopt:{opt m:et()}}Specifies the estimation method. The default is {cmd:xtlogit}.{p_end}

{synopt:{opt fe}}Estimates using Fixed-Effects (within) estimator.{p_end}

{synopt:{opt dum}}Estimates including one dummy variable per individual in the specification and in the prediction.{p_end}

{synopt:{it:model_options}}Specifies any other estimation options specific to the method used and not defined elsewhere.{p_end}
{synoptline}

{marker Examples}{...}
{title:Examples}

Use of {cmd:xtoos_bin_t} to evaluate the prediction perfomance based on ROC between the first quarter of year 2010 and the fourht quarter of year 2018

{p 4 8 2}{cmd:. xtoos_bin_t y x1 x2, indate(2010q1) cdate(2018q4) mprob(pr)}{p_end}

Use of {cmd:xtoos_bin_t} using Fixed-Effects (within) estimator and the estimation option pc1 for the predicted probability

{p 4 8 2}{cmd:. xtoos_bin_t y x1 x2, indate(2010q1) cdate(2018q4) mprob(pc1) fe}{p_end}

Use of {cmd:xtoos_bin_t} using as estimation method the command {cmd:xtprobit}

{p 4 8 2}{cmd:. xtoos_bin_t y x1 x2, indate(2010q1) cdate(2018q4) mprob(pr) met(xtprobit)}{p_end}

Use of {cmd:xtoos_bin_t} to evaluate the prediction perfomance based on ROC, but restricting the evaluation only to individual # 1 

{p 4 8 2}{cmd:. gen ind1=individual==1}{p_end}
{p 4 8 2}{cmd:. xtoos_bin_t y x1 x2, indate(2010q1) cdate(2018q4) mprob(pr) evalopt(ind1)}{p_end}

Use of {cmd:xtoos_bin_t} using dummy variables per individual 

{p 4 8 2}{cmd:. xtoos_bin_t y x1 x2, indate(2010q1) cdate(2018q4) mprob(pr) dum}{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtoos_bin_t} stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2: Matrices}{p_end}
{synopt:{cmd:r(ev_last)}}evaluation according to the last in-sample period{p_end}
{synopt:{cmd:r(ev_hor)}}evaluation according to the forecasting horizon{p_end}


{title:Author}

Alfonso Ugarte-Ruiz
alfonso.ugarte@bbva.com
