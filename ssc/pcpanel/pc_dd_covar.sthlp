{smcl}
{* *! version 3.0 14apr2020}{...}
{vieweralsosee "[R] power" "help power"}{...}
{vieweralsosee "[R] pc_simulate" "help pc_simulate"}{...}
{vieweralsosee "[R] pc_dd_analytic" "help pc_dd_analytic"}{...}
{viewerjumpto "Syntax" "pc_dd_covar##syntax"}{...}
{viewerjumpto "Description" "pc_dd_covar##description"}{...}
{viewerjumpto "Stored results" "pc_dd_covar##results"}{...}
{viewerjumpto "Details" "pc_dd_covar##details"}{...}
{viewerjumpto "Examples" "pc_dd_covar##examples"}{...}
{viewerjumpto "Contact" "pc_dd_covar##contact"}{...}
{title:Title}

{p2colset 5 21 21 2}{...}
{p2col :{cmd:pc_dd_covar} {hline 2}}Estimates variance and average covariances of idiosyncratic residuals for a difference-in-differences model{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 20 2} {cmd:pc_dd_covar} {depvar} {ifin} {cmd:,}  {opt pre(#)} {opt post(#)} [{opt i(panelvar)} {opt t(timevar)} {opt di:splay}] {p_end}


{marker opt_summary}{...}
{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt pre(#)}}number of pre-treatment periods; must be positive integer.{p_end}
{synopt :{opt post(#)}}number of post-treatment periods; must be positive integer.{p_end}

{syntab:Optional}
{p2coldent:* {opt i(panelvar)}}cross-sectional unit of randomization; must be numeric; will default to stored r({it:panelvar}) if not specified.{p_end}
{p2coldent:* {opt t(timevar)}}time period variable; must be numeric; will default to stored r({it:timevar}) if not specified.{p_end}
{synopt :{ifin}}option to restrict observations over which program estimates idiosyncratic residual variance and covariances of {it:depvar}.{p_end}
{synopt :{opt di:splay}}display estimated variance and average covariances in Stata console.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* Required if r({it:panelvar}) and r({it:timevar}) are not stored in memory.{p_end}

{break}
{marker description}{...}
{title:Description}

{pstd}
This program estimates the average residual variance and the average within-unit
residual covariances for a difference-in-differences model with {it:panelvar} and {it:timevar} fixed effects:{p_end}

{p2col 8 12 12 2: -}{it:Y_it = b*D_it + fe_i + fe_t + e_it} {p_end}

{pstd}
It is designed to be called as a subprogram within {help pc_dd_analytic}. 

{pstd}
{help pc_dd_covar} returns the following 4 estimates, averaged across all possible experiments with {it:pre} pre-treatment periods and {it:post} post-treatment periods:{p_end}
{break}
{p2col 8 12 12 2: -}residual variance: 
{bf:var(e_it)}{p_end}
{p2col 8 12 12 2: -}average pre-treatment residual covariance: 
{bf:mean(cov(e_it,e_is))}, for all pre-treatment periods {bf:t!=s} {p_end}
{p2col 8 12 12 2: -}average post-treatment residual covariance:
{bf:mean(cov(e_it,e_is))}, for all post-treatment periods {bf:t!=s} {p_end}
{p2col 8 12 12 2: -}average pre/post-treatment residual covariance: 
{bf:mean(cov(e_it,e_is))}, for all pre-treatment periods {bf:t} and post-treatment periods {bf:s} {p_end}

{pstd}
Importantly, these estimates depend on the number of pre-treatment and post-treatment observations included in the
regression specification, for two reasons. 

{pstd}
First, residuals from time periods farther apart are likely to be less correlated, 
thereby reducing the {it:average} across all off-diagonal covariances. For example,
a model with {it:pre}=3 will likely have a higher average covariance between pre-treatment 
residuals than a model with {it:pre}=30 that uses the exact same 
dataset. This is because the former is averaging the covariances of residuals separated by at most 2 periods, whereas the latter
averages covariances separated by up to 29 periods.

{pstd}
Second, residuals are only {it:estimates} of the error terms of the underlying data-generating 
process. As panel length increases, residuals will more closely approximate the true
error terms (because the number of panel observations increases faster than the 
degrees of freedom, allowing more precise estimation of fixed effects). For
example, 
suppose a data-generating process includes an idiosyncratic error term with a variance of 10. The residuals from an estimated two-period panel fixed model will have
a variance of much less than 10, and for greater numbers of time periods this residual variance will increase approaching 10. (Residual covariances behave analogously.) 

{pstd}
As a result, directly plugging in these estimates into
an analytic power calculation formula will produce an inaccurate minimum detectable effect. {help pc_dd_analytic} 
corrects for this estimation error in expectation using the result derived in Appendix E of: 

{phang2}
{browse "https://ei.haas.berkeley.edu/research/papers/WP277.pdf":Burlig, Fiona, Louis Preonas, and Matt Woerman (2017). "Panel Data and Experimental Design." Energy Institute at Haas Working Paper #277. University of California Berkeley.}
{p_end}

{pstd}
{browse "https://ei.haas.berkeley.edu/research/papers/WP277Appendix.pdf":Appendix D.1} of this paper
outlines the full variance-covariance estimation procedure implemented by {cmd:pc_dd_covar}.

{hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:pc_dd_covar} stores the following scalars in {cmd:r()}:
{break}

{p2col 8 12 12 2: -}{cmd:r(variance)}{p_end}
{p2col 8 12 12 2: -}{cmd:r(cov_pre)}{p_end}
{p2col 8 12 12 2: -}{cmd:r(cov_post)}{p_end}
{p2col 8 12 12 2: -}{cmd:r(cov_cross)}{p_end}
{p2col 8 12 12 2: -}{cmd:r(n_units)}{p_end}

{pstd}
The first 4 terms correspond to estimates of {it:sigma^2_[omega^hat]}, {it:psi^B_[omega^hat]}, {it:psi^A_[omega^hat]}, and {it:psi^X_[omega^hat]} using the
notation of 
{browse "https://ei.haas.berkeley.edu/research/papers/WP277.pdf":Burlig, Preonas, and Woerman (2017)}.{p_end}

{pstd}
{cmd:r(n_units)} reports the average number of cross-sectional
units used to estimate each of the above 4 terms. This value is used by
{help pc_dd_analytic} 
as a correction factor to estimate analytical power calculations.{p_end}

{pstd}
If {it:pre}=1 ({it:post}=1) then the average residual covariance between pre-treatment (post-treatment) periods is undefined, and
the stored value will be missing.

{hline}

{marker details}{...}
{title:Details}

{pstd}
This program uses the following algorithm to estimate the average residual variance and average residual covariance terms:

{p2col 8 12 12 2: 1.}Determine the range of feasible experiments, given the panel length ({it:pre+post}) and the number of time periods present 
in the dataset. For example, if {it:timevar = {1,2,...,100}}, {it:pre=5} and {it:post=6}, then there are 90 feasible ranges for an 11-period experiment (i.e., beginning
in periods 1 thru 90). If the dataset contains over 5000 feasible ranges,
the program will sample 5000 ranges without replacement.
{p_end}
{break}
{p2col 8 12 12 2: 2.}For each feasible range:
{p_end}
{break}
{p2col 12 16 16 2: (a)}Regress {it:depvar} on {it:panelvar} and {it:timevar}, storing the (idiosyncratic) residuals. (This regression includes 
all cross-sectional units with non-missing data, but only time periods 
within the specific {it:pre+post} range.)
{p_end} 
{p2col 12 16 16 2: (b)}Calculate the variance of the stored residuals. 
{p_end} 
{p2col 12 16 16 2: (c)}For each pair of pre-treatment periods (i.e., the 
first {it:pre} time periods in the specific {it:pre+post} range), calculate the covariance between these periods' residuals. Sum 
these estimated pre-treatment covariances and divide by the total number of pre-treatment pairs, to estimate the {it:average} pre-treatment covariance.
{p_end}

{p2col 12 16 16 2: }For example, if {it:pre=4}, this step will sum 
{{it:cov(e_i1,e_i2)}, {it:cov(e_i1,e_i3)}, {it:cov(e_i1,e_i4)}, {it:cov(e_i2,e_i3)}
{it:cov(e_i2,e_i4)}, {it:cov(e_i13,e_i4)}}, and divide by {it:pre*(pre-1)/2 = 6}.
{p_end} 
{p2col 12 16 16 2: (d)}For each pair of post-treatment periods (i.e., the 
last {it:post} time periods in the specific {it:pre+post} range), calculate the average covariance by the same method.
{p_end} 
{p2col 12 16 16 2: (e)}For each pair of pre- and post-treatment periods (i.e., the 
first {it:pre} and the last {it:post} time periods in the specific {it:pre+post} range), calculate the average covariance by the same method.
{p_end} 
{p2col 12 16 16 2: }For example, if {it:pre=4} and {it:post=2}, this step will sum 
{{it:cov(e_i1,e_i5)}, {it:cov(e_i1,e_i6)}, {it:cov(e_i2,e_i5)}, {it:cov(e_i2,e_i6)}
{it:cov(e_i3,e_i5)}, {it:cov(e_i3,e_i6)}, {it:cov(e_i4,e_i5)}, {it:cov(e_i4,e_i6)}}, and divide by {it:pre*post = 8}.
{p_end} 
{p2col 8 12 12 2: 3.}Average the results of steps (b)-(e) across all feasible ranges.{p_end}

{pstd}
One note of caution: using this algorithm to estimate variance and covariance 
parameters from regression residuals will {cmd:not} recover the {it:population parameters} governing the data-generating process of the error term. 
To take one simple example, suppose an AR(1) error structure
{it:e_it = 0.8*e_i{t-1} + v_it}, where {it:var(v_it)=3.6}, implying that {it:var(e_it)=10}. In a model with {it:pre=1} and {it:post=1}, the average
covariance across pre- and post-treatment periods is simply the AR(1) correlation scaled by the variance of {it:e_it}, or {it:cov(e_ipre,e_ipost)=8}. However, 
partialing out fixed effects from the outcome variable recovers {it:residuals} that are not equal to {it:e_it}, due to estimation error. The {it:residual} 
variance will be less than 10, and the average cross-period {it:residual} covariance will be negative. 

{pstd}
Importantly,
{help pc_dd_analytic} requires that the variance and covariance parameters be internally consistent {hline 2} {it:either} all must be population parameters (as with the {cmd:pc_dd_analytic}
options {opt var:iance} and {opt ar1}), {it:or} all must be 
estimated from the same vector of regression residuals (via this algorithm). An
example of internally {it:inconsistent} variance and covariance parameters would 
be variance estimated from a long time series of residuals and covariances estimated using residuals from a shorter ({it:pre+post})-length panel.

{pstd}
The underlying analytic formula used in {cmd:pc_dd_analytic} will depend on whether users input population parameters or estimates 
of population parameters. For population parameters specified using options {opt var:iance}, {opt ar1}, or {opt trueparam:eters}, {cmd:pc_dd_analytic} will 
apply the serial-correlation-robust power calculation formula from Burlig, Preonas, and Woerman (2017). Otherwise,
{cmd:pc_dd_analytic} will automatically apply the 
correction factors for estimated parameter values, as derived in 
{browse "https://ei.haas.berkeley.edu/research/papers/WP277Appendix.pdf":Appendix E}
of Burlig, Preonas, and Woerman (2017).

{hline}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. pc_dd_covar y, i(person_id) t(t) pre(2) post(8) disp}{p_end}

{phang}{cmd:. pc_dd_covar income, i(household_id) t(year) pre(1) post(2)} {p_end}

{phang}{cmd:. pc_dd_covar price if year>2002, i(firm_id) t(month) pre(5) post(3)} {p_end}

{hline}

{marker contact}{...}
{title:Contact}

{pstd}Louis Preonas{break}
Department of Agricultural and Resource Economics{break}
University of Maryland{break}
Email: {browse "mailto:lpreonas@umd.edu":lpreonas@umd.edu}
{p_end}

{pstd}This program is part of the {help ssc} package {cmd:pcpanel}.{p_end}


