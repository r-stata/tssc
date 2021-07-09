{smcl}
{* *! version 1.0.2  11feb2011}{...}
{* *! version 1.0.3  21jan2012}{...}
{* *! version 1.0.4  25jan2016}{...}
{* *! version 1.0.6  27jun2016}{...}

{cmd:help xsmle postestimation} {right:also see: {helpb xsmle}  }
{hline}

{title:Title}

{p 4 16 2}
{cmd:xsmle postestimation} {hline 2} Postestimation tools for xsmle{p_end}


{title:Description}

{pstd}
The following postestimation commands are available after {cmd:xsmle}:

{synoptset 13 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt:{bf:{help estat}}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_margins
INCLUDE help post_nlcom
{synopt :{helpb xsmle postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}

{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{synoptset 28 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt rf:orm}}reduced-form predicted values; the default{p_end}
{synopt :{opt fu:ll}}predictions based on a full information set{p_end}
{synopt :{opt li:mited}}predictions based on a limited information set{p_end}
{synopt :{opt na:ive}}predictions based on the observed values of {bf:y}{p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt a}}the fixed or random-effects{p_end}
{synopt :{opt noie}}exclude fixed or random-effects from the prediction{p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt rform} predicted values calculated from the reduced-form equation,
y_it= (I-{it:rho}*W)^(-1)*(x_it*beta + a_i).

{phang}
{opt full} predicted values based on the full information set.
This option is available only for a SAC model.

{phang}
{opt limited} predicted values based on the limited information set.
This option is available only for a SAC model.

{phang}
{opt naive} predicted values based on the observed values of y_it,
{it:rho}*W*y_it + x_it*beta + a_i.

{phang}
{opt xb} calculates the linear prediction x_it*beta + a_i.

{phang}
{opt a} estimates {it:a_i}'s, the fixed or random-effects. In the case of fixed-effects models, this statistic is allowed only when {opt type(ind)}.

{phang}
{opt noie} the estimated {it:a_i}'s are not included in the prediction.


{marker remarks}{...}
{title:Remarks}

{pstd}
The methods implemented in {cmd:predict} after {cmd:xsmle} are the panel data extensions
of those available in Drukker, Prucha, and Raciborski (2013) for the cross-sectional case.
See Kelejian and Prucha (2007) for more details.


{title:Examples}

{pstd}rform after SAR model with random-effects{p_end}
{pstd}SAR model{p_end}
{phang2}{cmd: use http://www.econometrics.it/stata/data/xsmle/product.dta, clear} {p_end}
{phang2}{cmd: spmat use usaww using http://www.econometrics.it/stata/data/xsmle/usaww.spmat} {p_end}
{phang2}{cmd: gen lngsp = log(gsp)} {p_end}
{phang2}{cmd: gen lnpcap = log(pcap)} {p_end}
{phang2}{cmd: gen lnpc = log(pc)} {p_end}
{phang2}{cmd: gen lnemp = log(emp)} {p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp unemp, wmat(usaww)} {p_end}
{phang2}{cmd: predict y_hat} {p_end}

{pstd}full information predictor after SAC model with fixed-effects {p_end}
{phang2}{cmd: xsmle lngsp lnpcap lnpc lnemp, fe model(sac) wmat(usaww) emat(usaww)}{p_end}
{phang2}{cmd: predict y_hat, full}{p_end}


{title:References}

{phang}
Drukker, D. M., I. R. Prucha, and R. Raciborski. 2013. 
Maximum likelihood and generalized spatial two-stage least-squares estimators 
for a spatial-autoregressive model with spatial-autoregressive disturbances. 
Stata Journal 13(2): 221–241.

{phang}
Kelejian, H. H., and I. R. Prucha. 2007. 
The relative efficiencies of various predictors in spatial econometric models 
containing spatial lags. Regional Science and Urban Economics 37(3): 363–374.


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Gordon Hughes{p_end}
{pstd}University of Edinburgh{p_end}
{pstd}Edinburgh, UK{p_end}
{pstd}g.a.hughes@ed.ac.uk{p_end}

{pstd}Andrea Piano Mortari{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}andrea.piano.mortari@uniroma2.it{p_end}


{title:Also see}

{psee}
Online:  {helpb xsmle}, {helpb spreg} (if installed), {helpb spivreg} (if installed){p_end}

