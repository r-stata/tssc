{smcl}
{* *! version 1.0  January 15, 2020 @ 13:31:10}{...}
{* *! version 1.1  September 9, 2018 @ 18:13:10}{...}
{vieweralsosee "[R] ml" "help ml"}{...}
{vieweralsosee "wtdtttdiag" "help wtdtttdiag"}{...}
{vieweralsosee "wtdttt" "help wtdttt"}{...}
{vieweralsosee "wtdtttpredprob" "help wtdtttpredprob"}{...}
{vieweralsosee "wtdtttpreddur" "help wtdtttpreddur"}{...}
{viewerjumpto "Syntax" "wtdttt##syntax"}{...}
{viewerjumpto "Description" "wtdttt##description"}{...}
{viewerjumpto "Options" "wtdttt##options"}{...}
{viewerjumpto "Examples" "wtdttt##examples"}{...}
{viewerjumpto "Results" "wtdttt##results"}{...}
{title:Title}

{phang} {bf:ranwtdttt} {hline 2} Estimate maximum likelihood estimate for
parametric Waiting Time Distribution (WTD) with random index times based on observed
prescription redemptions with adjustment for covariates. Reports
estimates of prevalence fraction and specified percentile of
inter-arrival density together with regression coefficients.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ranwtdttt}
{varname}
{cmd:,} {opth id:(varname:idvar)} {bf:disttype(}{it:recurrence_dens}{bf:)} {bf:samplestart(}{it:time}{bf:)} {bf:sampleend(}{it:time}{bf:)} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opth "id(varname:idvar)"}}ID variable{p_end}

{syntab:Recurrence distribution}
{synopt:{opt dist:type(string)}}Parametric distribution for Forward or
Backward Recurrence Density (FRD/BRD){p_end}

{syntab:Time window}
{synopt:{opt reverse}}Estimate reverse WTD{p_end}
{synopt:{opt samplestart(string)}}Start of sampling window{p_end}
{synopt:{opt sampleend(string)}}End of sampling window{p_end}
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
{cmd:ranwtdttt} estimates a parametric Waiting Time Distribution (WTD) with random index times
to {varname} ({it:rxtime}) and then computes an estimate of the specified percentile
together with an estimate of the proportion of prevalent users in the
sample. Parameters may depend on covariates when estimating a reverse
WTD with random index times.

{pstd} Here {it:rxtime} is a variable containing the time of observed
prescription redemptions, typically dates (discrete case). 

{pstd}
{cmd:ranwtdttt} estimation is based on the {help wtdttt}, but in contrast to wtdttt it uses all prescription redemption times of patients within a time window as input. Random index times for each individual is then uniformly sampled, within the sampling window of length delta, and the first prescription subsequent to (ordinary WTD) or the last prescription prior to (reverse WTD) the random index time for each individual are considered in the WTD estimation. Consequently the full data window must be sufficiently wide to contain all individual observation windows, i.e. it must be of length 2*delta. 

{pstd}
{cmd:ranwtdttt} alters the original dataset as it only keeps either the first prescription subsequent to (ordinary WTD) or the last prescription prior to (reverse WTD) the random
index time for each individual. Furthermore the new dataset contains the variable {it:_rxshift} which is the shifted prescription redemption time after all individuals have had their index times aligned to the same time. 

{pstd} To assess the fit, the command {help wtdtttdiag} can be used to
obtain diagnostic plots, cf. example below.

{pstd} The post-estimation command {help wtdtttpredprob} allows
prediction of treatment probabilities on times of interest based on
observed prescription redemptions. Similarly the post-estimation command
{help wtdtttpreddur} allows prediction of prescription durations
based on a specified percentile of the inter-arrival distribution.

{pstd} For references and a general introduction to the analytic approach of the WTD, see the documentation for {help wtdttt}. 

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
{opt samplestart} is either a string such as "1Jan2014" (a date for discrete data) 
or "1" (a number for continuous data) which gives the start of the sampling 
window within which we sample random index times. In the discrete case (default) the string must conform to requirements 
for the date function {help td}(). 

{phang}
{opt sampleend} is either a string such as "31Dec2014" (a date for discrete data) 
or "2" (a number for continuous data) which gives the end of the sampling 
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



{marker examples}{...}
{title:Examples}

{phang}
{cmd:. ranwtdttt rxdate, id(pid) disttype(lnorm) samplestart(1jan2014) sampleend(31dec2014)}{p_end}
{phang}
{cmd:. wtdtttdiag _rxshift}{p_end}

{phang}{cmd: . ranwtdttt rxtime, id(pid) disttype(lnorm) samplestart(1) sampleend(2) conttime reverse mucovar(i.packsize)}{p_end}

{pstd} Further examples are provided in the example do-file
{it:ranwtdttt_ex.do}, which contains analyses based on the datafiles
{it:ranwtddat_discdates.dta} and {it:ranwtddat_conttime.dta} - simulated datasets, which are also enclosed. Be sure
to read comments in the do-file for further explanations.



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ranwtdttt} stores the following scalars in {cmd:r()}:

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
{synopt:{cmd:r(samplestart)}} Time value at start of sampling window - corresponding to the start of the observation window for the shifted rx{p_end}
{synopt:{cmd:r(sampleend)}} Time value at end of sampling window - corresponding to the end of the observation window for the shifted rx{p_end}

{synoptline}
{p2colreset}{...}

{pstd}
Apart from the above, all results obtained by the maximum likelihood
estimation are stored by {cmd:ml} in the usual {cmd:e()} macros, see
help {help ml}.

{title:Author}

{pstd}Katrine Bødkergaard Nielsen, Aarhus University, kani@ph.au.dk.

{pstd}Henrik Støvring, Aarhus University, stovring@ph.au.dk.

