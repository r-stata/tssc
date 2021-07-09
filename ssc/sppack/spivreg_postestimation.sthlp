{smcl}
{* *! version 1.0.4  09jun2015}{...}
{cmd:help spivreg postestimation} {right:also see:  {helpb spivreg}  }
{hline}


{title:Title}

{p 4 16 2}
{cmd:spivreg postestimation} {hline 2} Postestimation tools for spivreg{p_end}


{title:Description}

{pstd}
The following postestimation commands are available after {cmd:spivreg}:

{synoptset 17 notes}{...}
{p2coldent :command}description{p_end}
{synoptline}
INCLUDE help post_estatic
INCLUDE help post_estatsum
INCLUDE help post_estatvce
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb spivreg postestimation##predict:predict}}predicted values{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{synoptset 15 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab :Main}
{synopt :{opt na:ive}}predictions based on the observed values of {bf:y};
the default{p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synoptline}
{p2colreset}{...}


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt naive} predicted values based on the observed values of {bf:y},
{bf:Y}*{bf:g} + {it:lambda}*{bf:W}*{bf:y} + {bf:X}*{bf:b}.

{phang}
{opt xb} calculates the linear prediction {bf:X}*{bf:b}.


{marker remarks}{...}
{title:Remarks}

{pstd}
The methods implemented in {cmd:predict} after {cmd:spivreg} are 
documented in Drukker, Prucha, and Raciborski (2011) which can be 
downloaded from 
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spivreg_2011.pdf"}.

{pstd}
The predictor computed by the option {bf:naive} will generally be biased;
see Kelejian and Prucha (2007) for an explanation.

{pstd}
See {help spreg postestimation##remarks:Remarks} in {cmd:spreg postestimation}
for a more detailed discussion of biased and unbiased spatial predictors.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use pollute}{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}
{phang2}{cmd:. spivreg pollution area (factories = penalties), id(id) dlmat(cobj) elmat(cobj)}{p_end}

{pstd}Obtain predicted values based on the observed values of {bf:y}{p_end}
{phang2}{cmd:. predict yhat}{p_end}


{title:References}

{phang}
Drukker, D. M., I. R. Prucha, and R. Raciborski. 2011.
A command for estimating spatial-autoregressive models with spatial
autoregressive disturbances and additional endogenous variables.
Working paper, The University of Maryland, Department of Economics,
{browse "http://econweb.umd.edu/~prucha/Papers/WP_spivreg_2011.pdf"}.

{phang}
Kelejian H. H., and I. R. Prucha. 2007. The relative efficiencies of various 
predictors in spatial econometric models containing spatial lags.
{it:Regional Science and Urban Economics} 37, 363-374.


{title:Also see}

{psee}
Online:  {helpb spivreg}, {helpb spreg} (if installed){p_end}

