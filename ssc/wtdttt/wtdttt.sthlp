{smcl}
{* *! version 1.0  January 15, 2020 @ 13:36:49}{...}
{* *! version 1.1  September 9, 2018 @ 18:13:10}{...}
{vieweralsosee "[R] ml" "help ml"}{...}
{vieweralsosee "ranwtdttt" "help ranwtdttt"}{...}
{vieweralsosee "wtdtttdiag" "help wtdtttdiag"}{...}
{vieweralsosee "wtdtttpredprob" "help wtdtttpredprob"}{...}
{vieweralsosee "wtdtttpreddur" "help wtdtttpreddur"}{...}
{viewerjumpto "Syntax" "wtdttt##syntax"}{...}
{viewerjumpto "Description" "wtdttt##description"}{...}
{viewerjumpto "Options" "wtdttt##options"}{...}
{viewerjumpto "Remarks - Methods and Formulas" "wtdttt##remarks"}{...}
{viewerjumpto "Examples" "wtdttt##examples"}{...}
{viewerjumpto "Results" "wtdttt##results"}{...}
{viewerjumpto "References" "wtdttt##references"}{...}
{title:Title}

{phang} {bf:wtdttt} {hline 2} Estimate maximum likelihood estimate for
parametric Waiting Time Distribution (WTD) based on observed
prescription redemptions with adjustment for covariates. Reports
estimates of prevalence fraction and specified percentile of
inter-arrival density together with regression coefficients.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:wtdttt}
{varname}
{cmd:,} {bf:disttype(}{it:recurrence_dens}{bf:)} {bf:start(}{it:time}{bf:)} {bf:end(}{it:time}{bf:)} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Recurrence distribution}
{synopt:{opt dist:type(string)}}Parametric distribution for Forward or
Backward Recurrence Density (FRD/BRD){p_end}

{syntab:Time window}
{synopt:{opt reverse}}Estimate reverse WTD{p_end}
{synopt:{opt start(string)}}Start of observation window{p_end}
{synopt:{opt end(string)}}End of observation window{p_end}
{synopt:{opt conttime}}Estimate durations for continuous data{p_end}

{syntab:Covariates}
{synopt:{opt logitp:covar}({help fvvarlist})}Covariates for logit({it:p}){p_end}
{synopt:{opt mu:covar}({help fvvarlist})}Covariates for {it:mu} (lnorm){p_end}
{synopt:{opt lnsigma:covar}({help fvvarlist})}Covariates for
log({it:sigma}) (lnorm){p_end}
{synopt:{opt lnbeta:covar}({help fvvarlist})}Covariates for
log({it:beta}) (exp | wei){p_end}
{synopt:{opt lnalpha:covar}({help fvvarlist})}Covariates for
log({it:alpha}) (exp | wei){p_end}
{synopt:{opt all:covar}({help fvvarlist})}Covariates for all parameters{p_end}

{syntab:Reporting}
{synopt:{opt iadp:ercentile(#)}}Percentile to estimate in the
Inter-Arrival Distribution (IAD); default is 0.8 (80th percentile){p_end}
{synopt:{opt eform(string)}}Report exponentiated regression coefficients{p_end}

{syntab:Maximum likelihood options (all options available with {help ml})}
{synopt:{opt niter(#)}}perform maximum of # iterations; default is niter(50){p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:wtdttt} estimates a parametric Waiting Time Distribution (WTD)
to {varname} and then computes an estimate of the specified percentile
together with an estimate of the proportion of prevalent users in the
sample. Parameters may depend on covariates when estimating a reverse
WTD.

{pstd}
{bf: Note:} To use this command you first need to create a dataset
which contains only the first prescription redemption of each
individual within an observation window (ordinary WTD), or the last
(reverse WTD), respectively. You can typically achieve
this with something like the following two lines of code:

{phang2}{cmd: . keep if rxdate >= startdate & rxdate <= enddate}

{phang2}{cmd: . bysort pid (rxdate): keep if _n == 1}

{pstd} or for the reverse WTD replace the last line with

{phang2}{cmd: . bysort pid (rxdate): keep if _n == _N}

{pstd} Here {cmd: pid} is a variable containing a person identifier
and {cmd: rxdate} is a variable containing the time of observed
prescription redemptions, typically dates. Before estimation it is
advisable to make a histogram of the variable {cmd:rxdate} to ensure
that its distribution has the shape of a WTD, ordinary or reverse.

{pstd} To assess the fit, the command {help wtdtttdiag} can be used to
obtain diagnostic plots.

{pstd} After estimation, the command {help wtdtttpredprob} allows
prediction of treatment probabilities on times of interest based on
observed prescription redemptions. Similarly the command
{help wtdtttpreddur} allows prediction of prescription durations
based on a specified percentile of the inter-arrival distribution.

{pstd} A key requirement for the WTD is that the index date is chosen independently of the individual redemption processes. Instead of using a fixed index date for the WTD and identical observation windows for each individual, it is possible to randomly sample index dates. The is implemented with the command {help ranwtdttt} which takes an entire dataset of prescription redemption dates as input. It then uniformly samples unique index dates for each individual, such that only the first prescription subsequent to (ordinary WTD) or the last prescription prior to (reverse WTD) the random index date for each individual are considered in the WTD estimation.

{marker options}{...}
{title:Options}

{dlgtab:Recurrence distribution}

{phang} 
{opt disttype} specifies the forward recurrence density to use.
Possible choices are named after their corresponding interarrival
density and there are three different choices implemented: {cmd:exp}
means Exponential, {cmd:lnorm} means Log-Normal, and {cmd:wei} means
Weibull. See Remarks below for a description of these and their
parametrization.

{dlgtab:Time window}
{phang}
{opt reverse} indicates that observations represent the last
prescription redemption observed in the interval for each patient and
a reverse WTD is estimated. If not specified (default), observations
are assumed to be first prescription redemptions and the ordinary WTD
is estimated.

{phang}
{opt start} is either a string such as "1Jan2014" (a date for discrete data) 
or "0" (a number for continuous data) which gives the start of the observation 
window. In the discrete case (default) the string must conform to requirements 
for the date function {help td}(). 

{phang}
{opt end} is either a string such as "31Dec2014" (a date for discrete data) 
or "1" (a number for continuous data) which gives the end of the observation 
window. In the discrete case (default) the string must conform to requirements
for the date function {help td}().

{phang} {opt conttime} indicates that the data is continuous. If not 
specified (default), observations are assumed to be discrete.

{dlgtab:Covariates}
{phang}
{opt logitp:covar}({help fvvarlist}) specifies covariates included in
the regression equation for the parameter logit({it:p}) (log-odds of
prevalence).

{phang}
{opt mu:covar}({help fvvarlist}) specifies covariates included in the
regression equation for {it:mu}, when using a Log-Normal recurrence
distribution (lnorm).

{phang}
{opt lnsigma:covar}({help fvvarlist}) Covariates for log({it:sigma}) (lnorm)

{phang}
{opt lnbeta:covar}({help fvvarlist}) Covariates for log({it:beta}) (exp | wei)

{phang}
{opt lnalpha:covar}({help fvvarlist}) Covariates for log({it:alpha}) (exp | wei)

{phang}
{opt all:covar}({help fvvarlist}) Covariates included in all regression
equations for the parameters.



{phang}
{opt iadpercentile} The percentile of the IAD, which is to be
estimated specified as a fraction between 0 and 1 (default is 0.8).


{marker remarks}{...}
{title:Remarks - Methods and Formulas}

{pstd}
The WTD is parametrized as a two-component mixture distribution with
one density component for prevalent users, {it:g(t)}, and a uniform
distribution over the observation window for incident users, i.e. the
likelihood contribution for one patient is:

{p 24 24 2}
{it:l(t) = p * g(t) + (1 - p) / delta}

{pstd} where {it: p} is the proportion of prevalent users in the
sample, and {it: delta} is the width of the observation window. Only
patients with at least one prescription redemption in the observation
window are considered. When a reverse WTD is estimated, {it:t} is time
from last prescription in the time window to its end.

{pstd} The density {it:g(t)} is known as the forward (ordinary WTD) or
backward (reverse WTD) recurrence density corresponding to the
interarrival density, {it:f(t)}, which governs the distribution of
time from one prescription redemption of a patient to the subsequent
one. {it: g(t)} is given by


{p 24 24 2}
{it:g(t)} = {it:(1 - F(t)) / M}

{pstd} where {it:F(t)} is the cumulative distribution function for
{it:f(t)} and {it:M} is the mean for {it:f(t)}. 


{pstd}
The actual parametrizations used are:

{pstd} {bf:Exponenential}:

{p 16 24 2} {it:f(t) = exp(-(exp(lnbeta) * t))}

{p 8 12 2} where {it:lnbeta = ln(beta)}.

{pstd} {bf:Weibull}:

{p 16 24 2} {it:f(t) = exp(-(exp(lnbeta) * t)^exp(lnalpha))}

{p 8 12 2} where {it:lnalpha = ln(alpha)} and {it:lnbeta = ln(beta)}.

{pstd} {bf:Log-Normal}:

{p 16 24 2} {it:f(t) = normprob(-(ln(x) - mu) / exp(lnsigma)) }

{p 8 12 2} where {it:lnsigma = ln(sigma)}.

{pstd} The ML procedure reports estimates of {it:lnbeta}
(Exponential), {it:(lnalpha, lnbeta)} (Weibull) or {it:(mu, lnsigma)}
(Log-Normal) together with an estimate of the log-odds of prevalent
users, {it:logitp}. The latter is also reported as the estimated proportion
of prevalent users in the sample after an
inverse-logit-transformation, i.e. {it: exp(logitp)/(1 + exp(logitp))}
accompanied by a 95% confidence interval.


{marker examples}{...}
{title:Examples}

{phang}
{cmd:. wtdttt rx1time, disttype(lnorm) start(1jan2014) end(31dec2014)}{p_end}

{phang}{cmd: . wtdttt last_rxtime, disttype(lnorm) start(0) end(1) conttime reverse mucovar(i.packsize) logitpcovar(i.packsize)}{p_end}

{pstd}
To get bootstrap confidence intervals we can do the following - notice
the use of {cmd:eform} in the second statement to obtain the
percentile itself and not its logarithm:

{phang}{cmd:. bootstrap logtimeperc = r(logtimeperc), reps(50): ///}{p_end}
{phang2}{cmd:wtdttt rx1time, disttype(lnorm) start(1jan2014) end(31dec2014)}{p_end}

{phang}{cmd:. bootstrap, eform}

{pstd} Further examples are provided in the example do-file
{it:wtdttt_ex.do}, which contains analyses based on the datafile
{it:wtddat.dta} - a simulated dataset, which is also enclosed. Be sure
to read comments in the do-file for further explanations.



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:wtdttt} stores the following scalars in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synoptline}
{synopt:{cmd:r(logtimeperc)}} Logarithm of estimated IAD percentile{p_end}
{synopt:{cmd:r(timepercentile)}} Estimated IAD percentile{p_end}
{synopt:{cmd:r(setimepercentile)}} Standard error of estimated IAD percentile{p_end}
{synopt:{cmd:r(prevprop)}} Estimated proportion of prevalent users{p_end}
{synopt:{cmd:r(seprev)}} Standard error of estimated proportion of
prevalent users{p_end}
{synopt:{cmd:r(disttype)}} Model type (backward or forward recurrence distribution){p_end}
{synopt:{cmd:r(reverse)}} If undefined: Ordinary WTD. If defined and
equal to "reverse": Reverse WTD.{p_end}
{synopt:{cmd:r(delta)}} Length of observation window{p_end}
{synopt:{cmd:r(start)}} Time value at start of time window{p_end}
{synopt:{cmd:r(end)}} Time value at end of time window{p_end}

{synoptline}
{p2colreset}{...}

{pstd}
Apart from the above, all results obtained by the maximum likelihood
estimation are stored by {cmd:ml} in the usual {cmd:e()} macros, see
help {help ml}.

{marker references}{...}
{title:References}

{p 4 8 2} Støvring H, Pottegård A, Hallas J. Refining estimates of
prescription durations by using observed covariates in
pharmacoepidemiological databases: an application of the reverse
waiting time distribution. Pharmacoepidemiol Drug Saf. 2017.
doi:10.1002/pds.4216. {browse "http://dx.doi.org/10.1002/pds.4216":http://dx.doi.org/10.1002/pds.4216}
{p_end}

{p 4 8 2} Støvring H, Pottegård A, Hallas J. Estimating medication
stopping fraction and real-time prevalence of drug use in
pharmaco-epidemiologic databases. An application of the reverse
waiting time distribution. Pharmacoepidemiol Drug Saf. 2017.
doi:10.1002/pds.4217. {browse "http://dx.doi.org/10.1002/pds.4217":http://dx.doi.org/10.1002/pds.4217}
{p_end}

{p 4 8 2} Støvring H, Pottegård A, Hallas J. Determining prescription
durations based on the parametric waiting time distribution.
Pharmacoepidemiol Drug Saf. 2016. doi:10.1002/pds.4114. {browse "http://dx.doi.org/10.1002/pds.4114":http://dx.doi.org/10.1002/pds.4114}
{p_end}

{p 4 8 2} Hallas J, Gaist D, Bjerrum L. The Waiting Time Distribution
as a Graphical Approach to Epidemiologic Measures of Drug Utilization.
Epidemiology. 1997;8:666-670. {browse "http://insights.ovid.com/pubmed?pmid=9345667":http://insights.ovid.com/pubmed?pmid=9345667}
{p_end}

{p 4 8 2} Stovring H, Vach W. Estimation of prevalence and incidence
based on occurrence of health-related events. Stat Med.
2005;24(20):3139-3154. {browse "https://doi.org/10.1002/sim.2142":https://doi.org/10.1002/sim.2142}
{p_end}

{title:Author}

{pstd}Katrine Bødkergaard Nielsen, Aarhus University, kani@ph.au.dk.

{pstd}Henrik Støvring, Aarhus University, stovring@ph.au.dk.

