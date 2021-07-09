{smcl}
{* *! version 1.0  September 11, 2017 @ 08:35:43}{...}
{vieweralsosee "wtdttt" "help wtdttt"}{...}
{viewerjumpto "Syntax" "wtdtttpredprob##syntax"}{...}
{viewerjumpto "Description" "wtdtttpredprob##description"}{...}
{viewerjumpto "Options" "wtdtttpredprob##options"}{...}
{viewerjumpto "Examples" "wtdtttpredprob##examples"}{...}
{title:Title}

{phang} {bf:wtdtttpredprob} {hline 2} Predict probability of a
patient still being in treatment after a prescription
redemption based on the estimated parametric Waiting Time 
Distribution (WTD).

{marker syntax}{...}
{title:Syntax}

{p 8 40 2}
{cmd:wtdtttpredprob}
{help newvar} [{it:if}] [{it:in}], {opt distrx}({help varname})

{marker description}{...}
{title:Description}

{pstd} {cmd:wtdtttpredprob} uses the last fitted reverse Waiting Time Distribution
to estimate the probability of a user still being treated at a time
{opt distrx} after a prescription redemption. Any covariates used in
the reverse WTD should also be present in the dataset, where the 
prediction is to be calculated. Estimation of the WTD will typically
take place in one dataset before another dataset is opened
in which the prediction is then carried out.

{marker options}{...}
{title:Options}

{phang} 
{opt distrx}({help varname}) The specified variable should contain
the time after a prescription redemption for which the prediction 
should be calculated. In some applications this will be the time 
from a prescription until a subsequent event.{p_end}

{marker examples}{...}
{title:Examples}

{pstd} In the following example we first fit a Log-Normal WTD model in
one dataset before predicting the probability of being treated based
on observed prescription redemptions found in another dataset and the
just obtained parameter values:

{phang}

{phang2}{cmd: . wtdttt last_rxtime, disttype(lnorm) reverse mucovar(i.packsize) logitpcovar(i.packsize)}

{phang2}{cmd: . use lastRx_index, clear}

{phang2}{cmd: . wtdtttpredprob probttt, distrx(distlast)}{p_end}

{pstd}
To see this example in action run the example do-file
{it:wtdttt_ex.do}, which contains analyses based on the datafiles
{it:wtddat_covar.dta} and {it:lastRx_index} - both are simulated
datasets and both are enclosed.

{title:Author}

{pstd}Katrine Bødkergaard Nielsen, Aarhus University, kani@ph.au.dk.

{pstd}Henrik Støvring, Aarhus University, stovring@ph.au.dk.

