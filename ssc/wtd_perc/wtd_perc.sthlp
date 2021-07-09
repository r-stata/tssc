{smcl}
{* *! version 1.0  January 9, 2018 @ 09:46:35}{...}
{vieweralsosee "[R] ml" "help ml"}{...}
{viewerjumpto "Syntax" "wtd_perc##syntax"}{...}
{viewerjumpto "Description" "wtd_perc##description"}{...}
{viewerjumpto "Options" "wtd_perc##options"}{...}
{viewerjumpto "Remarks - Methods and Formulas" "wtd_perc##remarks"}{...}
{viewerjumpto "Examples" "wtd_perc##examples"}{...}
{viewerjumpto "Results" "wtd_perc##results"}{...}
{viewerjumpto "References" "wtd_perc##references"}{...}
{title:Title}

{phang}
{bf:wtd_perc} {hline 2} Calculate percentile of inter-arrival density
based on the parametric Waiting Time Distribution (WTD).


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:wtd_perc}
{varname}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt dist:typel(string)}}Parametric distribution for Forward
Recurrence Density (FRD){p_end}
{synopt:{opt iadp:ercentile(#)}}Percentile to estimate in the
Inter-Arrival Distribution (IAD) (between 0 and 1)
{p_end}

{syntab:Options}
{synopt:{opt prevf:ormat(string)}}Format for displaying proportion of
prevalent users{p_end}
{synopt:{opt perc:format(string)}}Format for displaying percentile of
IAD{p_end}
{synopt:{opt start(date)}}Date where time window starts{p_end}
{synopt:{opt end(date)}}Date where time window ends{p_end}
{synopt:{opt delta(#)}}Length of time window{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:wtd_perc} estimates a parametric Waiting Time Distribution (WTD)
to {varname} and then computes an estimate of the specified percentile
together with an estimate of the proportion of prevalent users in the
sample.

{pstd}
{bf: Note:} To use this command you first need to create a dataset
with the times of only the first prescription redemption of each
individual within an observation window. You can typically achieve
this with something like the following two lines of code:

{phang2}{cmd: . keep if rxdate >= startdate & rxdate <= enddate}

{phang2}{cmd: . bysort pid (rxdate): keep if _n == 1}

{pstd} where {cmd: pid} is a variable containing a person identifier and
{cmd: rxdate} is a variable containing times (typically dates) of
observed prescription redemptions. 



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt disttype} specifies the forward recurrence density to use. They
are named after their corresponding interarrival density and there are
three different choices implemented: {cmd:exp} means Exponential,
{cmd:lnorm} means Log-Normal, and {cmd:wei} means Weibull. See Remarks
below for a description of these and their parametrization. 


{phang}
{opt iadpercentile} The percentile of the IAD, which is to be
estimated - it should be specified as a fraction between 0 and 1. It
must be specified.

{phang}
{opt prevformat} Numerical format to be used for displaying the
estimated proportion of prevalent users in the sample. Defaults to
%4.3f, see help {help format}.

{phang}
{opt percformat} Numerical format to be used for displaying the
estimated percentile of the IAD. Defaults to
%4.3f, see help {help format}.

{phang}
{opt start} is a string such as "1Jan2014" which gives the start date
of the observation window. Strings must conform to requirements for
the date function {help td}(). When specified, an end date must also be
given. Default time for start of time window is 0. When specified, an
end date must also be given. 

{phang}
{opt end} is a string such as "31dec2014" which gives the end date
of the observation window. Strings must conform to requirements for
the date function {help td}(). When specified, a start date must also be
given.

{phang} {opt delta} specifies the length of the observation window. If
specified, no start and end date can be stated. Default value is 1.

{marker remarks}{...}
{title:Remarks - Methods and Formulas}

{pstd}
The WTD is parametrized as a two-component mixture distribution with
one density component for prevalent users, {it:g(t)}, and a uniform
distribution over the observation window for incident users, i.e. the
likelihood contribution for one patient is:

{p 24 24 2}
{it:l(t) = p * g(t) + (1 - p) / delta

{pstd} where {it: p} is the proportion of prevalent users in the
sample, and {it: delta} is the width of the observation window. Only
patients with at least one prescription redemption in the observation
window are considered.

{pstd}
The density {it:g(t)} is known as the forward recurrence density
corresponding to the interarrival density, {it:f(t)}, which governs
the distribution of time from one prescription redemption of a patient
to the subsequent one. {it: g(t)} is given by


{p 24 24 2}
{it:g(t)} = {it:(1 - F(t)) / M}

{pstd} where {it:F(t)} is the cumulative distribution function for
{it:f(t)} and {it:M} is the mean for {it:f(t)}. 
{* Parametrizations!!!}

{pstd}
The actual parametrizations used are:

{pstd} {bf:Exponenential}:

{p 16 24 2} {it:f(t) = exp(-(beta * t))}

{p 8 12 2} where {it:lnbeta = ln(beta)}.

{pstd} {bf:Weibull}:

{p 16 24 2} {it:f(t) = exp(-(beta * t) ^alpha)}

{p 8 12 2} where {it:lnalpha = ln(alpha)} and {it:lnbeta = ln(beta)}.

{pstd} {bf:Log-Normal}:

{p 16 24 2} {it:f(t) = normprob(-(ln(x) - mu)/exp(lnsigma)) }

{p 8 12 2} where {it:lnsigma = ln(sigma)}.

{pstd} The ML procedure reports estimates of {it:lnbeta}
(Exponential), {it:(lnalpha, lnbeta)} (Weibull) or {it:(mu, lnsigma)}
(Log-Normal) together with an estimate of the log-odds of prevalent
users {it:logitp}. The latter is reported as the estimated proportion
of prevalent users in the sample after an
inverse-logit-transformation, i.e. {it: exp(logitp)/(1 + exp(logitp))}
accompanied by a 95% confidence interval.


{marker examples}{...}
{title:Examples}

{phang}
{cmd:. wtd_perc rx1time, disttype(lnorm) iadpercentile(0.8)}{p_end}

{pstd}
To get bootstrap confidence intervals we can do the following - notice
the use of {cmd:eform} in the second statement to obtain the
percentile itself and not its logarithm:

{phang}{cmd:. bootstrap logtimeperc = r(logtimeperc), reps(50): ///}{p_end}
{phang2}{cmd:wtd_perc rx1time, disttype(lnorm) iadpercentile(0.8)}{p_end}

{phang}{cmd:. bootstrap, eform}

{pstd}
Further examples are provided in the example do-file
{it:wtd_perc_ex.do}, which contains analyses based on the datafile
{it:wtddat.dta} - a simulated dataset, which is also enclosed.



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:wtd_perc} stores the following scalars in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synoptline}
{synopt:{cmd:r(logtimeperc)}}Logarithm of estimated percentile{p_end}
{synopt:{cmd:r(timepercentile)}}Estimated percentile{p_end}
{synopt:{cmd:r(prevproc)}}Estimated proportion of prevalent users{p_end}
{synopt:{cmd:r(selogitprev)}}Standard error of estimated log-odds of
prevalent users{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
Apart from the above, all results obtained by the maximum likelihood
estimation are stored by {cmd:ml} in the usual {cmd:e()} macros, see
help {help ml}.

{marker references}{...}
{title:References}

{p 4 8 2} Støvring H, Pottegård A, Hallas J. Determining prescription
durations based on the parametric waiting time distribution.
2016 {it:Submitted}.{p_end}

{p 4 8 2} Hallas J, Gaist D, Bjerrum L. The Waiting Time Distribution
as a Graphical Approach to Epidemiologic Measures of Drug Utilization.
Epidemiology. 1997;8:666-670.{p_end}

{p 4 8 2} Stovring H, Vach W. Estimation of prevalence and incidence
based on occurrence of health-related events. Stat Med.
2005;24(20):3139-3154. {p_end}

{title:Author}

{pstd}
Henrik Støvring, Aarhus University, stovring@ph.au.dk
