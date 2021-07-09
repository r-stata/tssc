{smcl}
{* *! version 1.0  September 11, 2017 @ 08:34:54}{...}
{vieweralsosee "wtdttt" "help wtdttt"}{...}
{viewerjumpto "Syntax" "wtdtttpreddur##syntax"}{...}
{viewerjumpto "Description" "wtdtttpreddur##description"}{...}
{viewerjumpto "Options" "wtdtttpreddur##options"}{...}
{viewerjumpto "Examples" "wtdtttpreddur##examples"}{...}
{title:Title}

{phang} {bf:wtdtttpreddur} {hline 2} Predict duration of observed prescription
redemptions based on the estimated parametric Waiting Time Distribution
(WTD).

{marker syntax}{...}
{title:Syntax}

{p 8 40 2}
{cmd:wtdtttpreddur}
{help newvar} [{it:if}] [{it:in}] [{cmd:,} {opt iadp:ercentile(#)} {opt iadm:ean}]

{marker description}{...}
{title:Description}

{pstd} {cmd:wtdtttpreddur} uses the last fitted reverse Waiting Time
Distribution to predict the duration of a prescription redemption.
Any covariates used in the reverse WTD should also be present in the
dataset, where the prediction is to be calculated. Estimation of the
WTD will typically take place in one dataset before another dataset is
opened in which the prediction is then carried out.

{marker options}{...}
{title:Options}

{phang}
{opt iadp:ercentile(#)} Percentile to predict in the
Inter-Arrival Distribution (IAD); default is 0.8 (80th percentile).
This means that 80% of all users with similar covariate values are
predicted to have a new prescription redemption within the predicted
time value.{p_end}

{phang}
{opt iadm:ean} Predict the mean of the IAD instead of a percentile.{p_end}

{marker examples}{...} {title:Examples}

{pstd} In the following example we first fit a Log-Normal WTD model in
one dataset before predicting the duration (90th percentile) based 
on observed prescription redemptions found in another dataset and the
just obtained parameter values:

{phang}

{phang2}{cmd: . wtdttt last_rxtime, disttype(lnorm) reverse mucovar(i.packsize) logitpcovar(i.packsize)}

{phang2}{cmd: . use lastRx_index, clear}

{phang2}{cmd: . wtdtttpreddur probttt, iadpercentile(0.9)}{p_end}

{pstd}
To see this example in action run the example do-file
{it:wtdttt_ex.do}, which contains analyses based on the datafiles
{it:wtddat_covar.dta} and {it:lastRx_index} - both are simulated
datasets and both are enclosed.

{title:Author}

{pstd}Katrine Bødkergaard Nielsen, Aarhus University, kani@ph.au.dk.

{pstd}Henrik Støvring, Aarhus University, stovring@ph.au.dk.

