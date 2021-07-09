{smcl}
{* *! version 3.0 14apr2020}{...}
{vieweralsosee "[R] power" "help power"}{...}
{vieweralsosee "[R] pc_simulate" "help pc_simulate"}{...}
{vieweralsosee "[R] pc_dd_covar" "help pc_dd_covar"}{...}
{viewerjumpto "Syntax" "pc_dd_analytic##syntax"}{...}
{viewerjumpto "Description" "pc_dd_analytic##description"}{...}
{viewerjumpto "Design parameters" "pc_dd_analytic##opt_params"}{...}
{viewerjumpto "Assumed vcov options" "pc_dd_analytic##opt_resid_assumed"}{...}
{viewerjumpto "Estimated vcov options" "pc_dd_analytic##opt_resid_estimated"}{...}
{viewerjumpto "Manually input covariances" "pc_dd_analytic##opt_avgcov"}{...}
{viewerjumpto "Output options" "pc_dd_analytic##opt_output"}{...}
{viewerjumpto "Examples" "pc_dd_analytic##examples"}{...}
{viewerjumpto "Contact" "pc_dd_analytic##contact"}{...}
{viewerjumpto "References" "pc_dd_analytic##references"}{...}
{title:Title}

{p2colset 5 24 24 2}{...}
{p2col :{cmd:pc_dd_analytic} {hline 2}}Analytic power calculations for difference-in-differences model with serial correlation{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 25 2} {cmd:pc_dd_analytic} {cmd:,} [{opth n(numlist)} {opth mde(numlist)} {opth pow:er(numlist)} {help pc_dd_analytic##options:options}] {p_end}


{marker opt_summary}{...}
{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required (exactly 2 of 3) {help pc_dd_analytic##description:[+]}}
{p2coldent:* {opth n(numlist)}}list of sample sizes for experiment 
(the number of cross-sectional units included in the randomization); must be positive integers; 
e.g. {cmd:n(}50(10)150{cmd:)}.{p_end}
{p2coldent:* {opth mde(numlist)}}list of minimum detectable effect sizes, in levels ({it:not} in percents); 
e.g. {cmd:mde(}10 20 30{cmd:)}.{p_end}
{synopt :{opth pow:er(numlist)}}list of desired statistical power of experiment; must be between 0 and 1; 
default is {opt pow:er}{cmd:(0.80)}.{p_end}

{syntab:Experimental design parameters {help pc_dd_analytic##opt_params:[+]}}
{synopt :{opth p(numlist)}}list of treatment ratios (the proportion of cross-sectional units to receive treatment); 
must be between 0 and 1, e.g. {cmd:p(}0.5 0.75{cmd:)}; default is {cmd:p(0.5)}.{p_end}
{synopt :{opth pre(numlist)}}list of number of pre-treatment periods; must be positive integer(s), 
e.g. {cmd:pre(}2(2)10{cmd:)}; default is {cmd:pre(1)}.{p_end}
{synopt :{opth post(numlist)}}list of number of post-treatment periods; must be positive integer(s), e.g. {cmd:post(}1 2 3{cmd:)}; 
default is {cmd:post(1)}.{p_end}
{synopt :{opt alp:ha(#)}}desired Type-I error rate (or false discovery rate); must be between 0 and 1; default is {cmd:alpha(0.05)}.{p_end}
{synopt :{opt onesid:ed}}assumes one-sided hypothesis test; 
if not specified, default is a two-sided hypothesis test.{p_end}

{syntab:Residual variance-covariance (estimated) {help pc_dd_analytic##opt_resid_estimated:[+]}}
{p2coldent:+ {opth dep:var(depvar)}}dependent variable of experiment, for estimating idiosyncratic 
residual variance and covariances; must be numeric.{p_end}
{synopt :{opt i(panelvar)}}cross-sectional unit of randomization; must be numeric; will default to 
stored r({it:panelvar}) if not specified.{p_end}
{synopt :{opt t(timevar)}}time period variable; must be numeric; will default to stored r({it:timevar}) if not specified.{p_end}
{synopt :{opth if(if)}}option to restrict observations over which program estimates idiosyncratic 
esidual variance and covariances of {it:depvar}; e.g. {cmd:if(}{it:year>2000}{cmd:)}.{p_end}
{synopt :{opth in(in)}}option to restrict observations over which program estimates idiosyncratic 
residual variance and covariances of {it:depvar}; e.g. {cmd:in(}{it:1/1000}{cmd:)}.{p_end}

{syntab:Residual variance-covariance (assumed) {help pc_dd_analytic##opt_resid_assumed:[+]}}
{p2coldent:+ {opth var:iance(numlist)}}list of {it:idiosyncratic} residual variances; must be positive, 
e.g. {opt var:iance}{cmd:(}5(1)10{cmd:)}.{p_end}
{p2coldent:+ {opth sd(numlist)}}list of {it:idiosyncratic} residual standard deviations; must be positive, 
e.g. {opt sd}{cmd:(}1 2 3{cmd:)}; a substitute for {opth var:iance(numlist)}.{p_end}
{synopt :{opth ar1(numlist)}}list of AR(1) coefficients, to model within-unit serial correlation of {it:idiosyncratic} residuals; 
must be between -1 and 1, e.g. {cmd:ar1(}0.1(0.1)0.9{cmd:)}.{p_end}

{syntab:Average covariances (manually input) {help pc_dd_analytic##opt_avgcov:[+]}}
{synopt :{opt avgcov(pre post cross)}}average within-unit covariances of idiosyncratic residuals, 
between pre-treatment periods, between post-treatment periods, and across pre/post-treatment periods, respectively; 
equivalent to stored results from {help pc_dd_covar}: {cmd:avgcov(}{it:r(cov_pre) r(cov_post) r(cov_cross)}{cmd:)}; 
use with caution, see details {help pc_dd_analytic##opt_avgcov:below}.{p_end}
{synopt :{opt avgcor(pre post cross)}}average within-unit correlations of idiosyncratic residuals, 
between pre-treatment periods, between post-treatment periods, and across pre/post-treatment periods, respectively; 
equivalent to {cmd:avgcov(}{it:r(cov_pre) r(cov_post) r(cov_cross)}{cmd:)} divided by {opth var:iance(numlist)}; 
use with caution, see details {help pc_dd_analytic##opt_avgcov:below}.{p_end}
{synopt :{opt ncovest(#)}}number of units used to estimate {opt avgcov(pre post cross)}; 
equivalent to stored result {it:r(n_units)} from {help pc_dd_covar}; 
treats manually input variance (sd) and covariances (correlations) as estiamted parameters.{p_end}
{synopt :{opt trueparam:eters}}treats manually input variance (sd) and covariances (correlations) as true parameters of the DGP.{p_end}

{syntab:Output options {help pc_dd_analytic##opt_output:[+]}}
{synopt :{opth out:file(filename)}}.txt file that stores results in current directory; 
if not specified, output will not be stored but will display in console.{p_end}
{synopt: [{cmd:append}|{cmd:replace}]}{cmd:append} adds results to an existing .txt file; {cmd:replace} is 
required to overwrite existing .txt file (if {cmd:append} is 
not specified).{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* At least 1 of {opth n(numlist)} and {opth mde(numlist)} is required. If only 1 is specified, 
{opth pow:er(numlist)} will default to {it:power=}0.8 if missing.{p_end}
{p 4 6 2}+ Exactly 1 of the following options is required: {opth dep:var(depvar)}, {opth var:iance(numlist)}, or {opth sd(numlist)}.
Options {opth ar1(numlist)}, {opt avgcov(pre post cross)}, and {opt avgcor(pre post cross)} may not be combined with
{opth dep:var(depvar)}, or with each other. {p_end}

{break}
{marker description}{...}
{title:Description}

{pstd}
This program performs analytic power calculations for randomized experiments with difference-in-differences designs. It 
accommodates arbitrary serial correlation in the outcome variable, and will also directly estimate the correlation structure
of an existing dataset.{p_end}
 
{pstd}
{help pc_dd_analytic} operationalizes the serial-correlation-robust (SCR) DD power calculation formula developed in

{phang2}
{browse "https://ei.haas.berkeley.edu/research/papers/WP277.pdf":Burlig, Fiona, Louis Preonas, and Matt Woerman (2017). "Panel Data and Experimental Design." Energy Institute at Haas Working Paper #277. University of California Berkeley.}
{p_end}

{pstd}
This paper demonstrates that standard power calculation tools ignore non-constant serial correlation present in panel data, 
which can lead to dramatically incorrect power calculations. While 
{help pc_simulate:power calculations by simulation} are recommended, this program is appropriate in cases where 
pre-existing data do not exist, or are not reliable. This
program can also help to narrow the range of potential parameters values analytically, before undergoing 
more time-consuming simulations.
{p_end}

{pstd}
Users must provide exactly 2 of the following 3 parameters, allowing {help pc_dd_analytic} to solve for the third:{p_end}
{break}
{p2col 8 12 12 2: -}{opth n(numlist)}  sample size (number of cross-sectional units in the experiment){p_end}
{p2col 8 12 12 2: -}{opth mde(numlist)} minimum detectable effect (in units of the outcome variable, {it:not} in percents) {p_end}
{p2col 8 12 12 2: -}{opth pow:er(numlist)} statistical power (probability of correctly rejecting a false null 
given the true effect size {it:mde}) {p_end}

{pstd}
(If {it:power} is not specified and one of {it:n} or {it:mde} is missing, the program will assume the default 
{it:power}=0.80 and solve of the missing parameter.){p_end}

{pstd}
Power calculations assume a standard panel fixed effects/difference-in-differences model, with a treatment 
indicator {it:D_it}, unit fixed effects {it:fe_i}, time period fixed effects {it:fe_t}, and serially correlated errors {it:e_it}:{p_end}
{break}
{p2col 8 12 12 2: -}{it:Y_it = b*D_it + fe_i + fe_t + e_it} {p_end}

{pstd} 
The simulation-based program {help pc_simulate} accommodates more flexible regression specifications.


{marker options}{...}
{title:Options}
{marker opt_params}{...}
{dlgtab:Experimental design parameters}

{phang}
{opth p(numlist)} denotes the proportion of units in the experiment that are randomized into treatment.

{phang}
{opth pre(numlist)} governs the number of pre-treatment periods in the experiment. Will default to {it:pre}=1 if not specified.  

{phang}
{opth post(numlist)} governs the number of post-treatment periods in the experiment. Will default to {it:post}=1 if not specified.  

{phang}
{opt alp:ha(#)} assigns a Type-I error rate (or false discovery rate). The conventional significance level 
is {it:alpha=}0.05, which is also the default value.

{phang}
{opt onesid:ed} toggles a one-sided hypothesis test, instead of the default two-sided test. (For analytic power 
calculations, the direction of the one-sided test does not matter.) 


{marker opt_resid_estimated}{...}
{dlgtab:Estimated vcov options}

{pstd}
The strength of {help pc_dd_analytic} is that it parametrizes analytical DD power calculations by 
directly estimating the correlation structure of an existing dataset. "Under the hood" of {help pc_dd_analytic}, 
the subprogram {help pc_dd_covar} estimates the idiosyncratic residual variance and 
covariances of the desired outcome variable ({it:depvar}). The resulting power calculations are able to 
capture the complex dependencies inherent to real data.

{phang}
{opth dep:var(depvar)} denotes the dependent variable of choice, from the dataset in memory.

{phang}
{opt i(panelvar)} and {opt t(timevar)} denote the cross-sectional unit of randomization and time period variables, respectively. They 
will each be partialed out of {it:depvar} as fixed effects. 
Both options must be specified together with {opth dep:var(depvar)}, unless {it:r(panelvar)} and {it:r(timevar)} are already stored in memory.

{phang}
{opth if(if)} and {opth in(in)} allow users to specify a subset of {it:depvar} observations over 
which to estimate residual variance and covariances, if desired.

{pstd}
Please see the  {help pc_dd_covar:pc_dd_covar help documentation} for details on how this program estimates 
variance and covariance parameters to be fed into the analytical power calculation formula.


{marker opt_resid_assumed}{...}
{dlgtab:Assumed vcov options}

{pstd}
In the absence of representative pre-existing data, users can manually input assumed variance and covariance parameters.

{phang}
{opth var:iance(numlist)} allows users to provide a list of residual variances. Note
that these are {cmd:not} variances of the composite error term, but rather of the {cmd:idiosyncratic} error term, 
after partialing out unit and time period fixed effects (i.e., {it:e_it} in the equation above).
For users accustomed to the notation of McKenzie (2012) (or {help sampsi}), this variance ({it:var_e}) combines the composite variance 
({it:var_Y}) and the intracluster correlation ({it:rho}): {it: var_e = var_Y * (1-rho)}.

{pmore}
This option cannot be combined with {opth dep:var(depvar)} or {opth sd(numlist)}.


{phang}
{opth sd(numlist)} allows users to provide a list of residual standard deviations, i.e. the square roots of {opth var:iance(numlist)}.

{pmore}
This option cannot be combined with {opth dep:var(depvar)} or {opth var:iance(numlist)}.


{phang}
{opth ar1(numlist)} allows users to model serially correlated (idiosyncratic) errors using a simple AR(1) process. This 
assumes that each cross-sectional unit's error terms evolve by the process:{p_end}

{phang3}
{it:e_it = ar1*e_i(t-1) + v_it},  where {it:v_it} is an i.i.d. white noise term.
{p_end}

{pmore}
While AR(1) represents an imperfect approximation of the complex covariance structures found in real-world panel data, 
it is unrealistic to assume i.i.d. error terms in a panel data setting (even in a randomized experiment). In 
the absence of a pre-existing dataset, users can enter a range of AR(1) coefficients to test how 
weaker/stronger serial correlation changes the relationship between sample size, minimum detectable effect, and statistical power.

{pmore}
{opth ar1(numlist)} can only be used in combination with {opth var:iance(numlist)} or {opth sd(numlist)}. However, 
{opth var:iance(numlist)} may also be combined with option {opt avgcov(pre post cross)} or {opt avgcor(pre post cross)}. 
See discussion {help pc_dd_analytic##opt_avgcov:below}. 

{pmore}
If {opth var:iance(numlist)} or {opth sd(numlist)} alone is specified, then the resulting power calculations will assume i.i.d. idiosyncratic errors with no serial correlation.


{marker opt_avgcov}{...}
{dlgtab:Average covariances (manually input)}

{phang}
{opt avgcov(pre post cross)} allows users to manually input average within-unit covariances of the idiosyncratic errors. These terms are, in order: the 
average covariance between pre-treatment periods; 
the average covariance between post-treatment periods;
and the average covariance across pre-treatment and post-treatment periods.

{pmore}
These three terms are equivalent to those estimated by {help pc_dd_covar} and stored as {cmd:avgcov(}{it:r(cov_pre) r(cov_post) r(cov_cross)}{cmd:)}, respectively.

{pmore}
These average covariances depend on the number of pre- and post-treatment periods,
because residuals from time periods farther apart are likely to be less correlated, 
thereby reducing the {it:average} across all off-diagonal covariances. Hence, if 
{opt avgcov} is specified, options {opt pre(#)} and {opt post(#)} can only accommodate one value each. Similarly, 
because residual covariances scale with the residual variance, option {opt var:iance(#)} (or {opt sd(#)})
can only accommodate one value when combined with {opt avgcov}. (Option 
{opth dep:var(depvar)} performs the same operation under the hood, by using  {help pc_dd_covar} 
to calculate new covariances for each combination of parameters.)

{pmore}
If {it:pre}=1 ({it:post}=1) then the average residual covariance between pre-treatment 
(post-treatment) periods is vacuously defined. However, {opt avgcov(pre post cross)} still 
requires three inputs, and the program simply ignores any vacuously defined values.

{pmore}
These three terms correspond to {it:psi^B_[omega^hat]}, {it:psi^A_[omega^hat]}, and {it:psi^X_[omega^hat]} in the
notation of Burlig, Preonas, and Woerman (2017). Please refer to 
{browse "https://ei.haas.berkeley.edu/research/papers/WP277Appendix.pdf":Appendix D.1} 
of this paper, and to the  {help pc_dd_covar:{it:pc_dd_covar} help documentation} for further detail. 


{phang}
{opt avgcor(pre post cross)} allows users to manually input three average within-unit {it:correlation} terms, rather than {it:covariance} terms. 
This option is equivalent to {opt avgcov(pre post cross)} divided by the idiosyncratic residual variance {opth var:iance(numlist)} (or {opth sd(numlist)}^2).
It performs identically to {opt avgcov(pre post cross)}, with one exception: whereas {opt avgcov(pre post cross)} can only accommodate a single
variance (or sd), {opt avgcor(pre post cross)} can accommodate multiple inputs for {opth var:iance(numlist)} (or {opth sd(numlist)}).

{pmore}
Importantly, {opt avgcor(pre post cross)} is {cmd:not} equivalent to the options {cmd: r0()}, {cmd:r1()}, and {cmd:r01()} from the depreciated function {help sampsi}.
Whereas the latter characterized correlations in the {cmd:composite} error term, {opt avgcor(pre post cross)} characterizes correlations in the {cmd:idiosyncratic} error
term, after partialing out unit and time fixed effects. Whereas {it: r0=r1=r01} implied {cmd:constant} serial correlation in the outcome variable, 
{opt avgcor(pre post cross)} with {it:pre=post=cross} implies {cmd:non-constant} serial correlation in the outcome variable.


{phang}
When specifying either {opt avgcor(pre post cross)} or {opt avgcor(pre post cross)} (which cannot be combined), users must also specify either 
{opt ncovest(#)} or {opt trueparam:eters}.


{phang}
{opt ncovest(#)} specifies the number of cross-sectional units
used to estimate the four values {opt var:iance(#)} (or {opt sd(#)}) and {opt avgcov(pre post cross)} (or {opt avgcor(pre post cross)}). This 
is used in the correction factors that allow {cmd:pc_dd_analytic} to estimate unbiased
power calculations using (biased) estimates of these variance-covariance parameters. (See Appendix
E from Burlig, Preonas, and Woerman (2017) for more detail.)

{pmore}
This option tells {help pc_dd_analytic} to treat {opt var:iance()} (or {opt sd()}) and {opt avgcov()} (or {opt avgcor()}) as {cmd:estimated parameters}.
In other words, the program will apply estimation correction factors to the variance/covariance terms in the analytic power calculation formula.
This will yield inaccurate power calculations in cases where users estimate the variance from residuals, but do not also estimate covariances
from the same residuals. 

{pmore}
Estimating variance and covariance parameters from regression 
residuals will {cmd:not} replicate the {it:true parameters} governing the DGP of the error term. 
To take one simple example, 
suppose {it:e_it = 0.8*e_i{t-1} + v_it}, where {it:var(v_it)=3.6}, implying that {it:var(e_it)=10}. 
In a model with {it:pre=1} and {it:post=1}, the average
covariance across pre- and post-treatment periods is simply the AR(1) correlation scaled by the variance 
of {it:e_it}, or {it:cov(e_ipre,e_ipost)=8}. However, 
partialing out fixed effects from the outcome variable recovers {it:residuals} that are not equal to {it:e_it}, 
due to estimation error. The {it:residual} 
variance will be less than 10, and the average cross-period {it:residual} covariance will be negative. 


{phang}
{opt trueparam:eters} tells {help pc_dd_analytic} to treat {opt var:iance()} (or {opt sd()}) and {opt avgcov()} (or {opt avgcor()}) as {cmd:true parameters}.
In other words, the program will assume the variance/covariance terms in the analytic power calculation formula characterize the true DGP of data.
This will yield inaccurate power calculations in cases where users have estimated either the variance or covariance terms from residuals, 
because of the estimation error inherent in doing so.

{pmore}
Toggling this option only makes sense in cases where users are "guessing" the variance/covariance structure. Because {opt avgcov(pre post cross)}
and {opt avgcor(pre post cross)} are functions of {it:both} the data structure and the panel length, we recommend that users "guess" 
either using option {opth ar1(numlist)} or using option {opth dep:var(depvar)} on simulated data.


{marker opt_output}{...}
{dlgtab:Output options}

{phang}
{opth out:file(filename)} specifies the name of the .txt output file that stores {cmd:pc_dd_analytic} results in the current directory. 
If not specified, the program will not store its results, but they will still display in the Stata console.

{pmore} Option {cmd:append} will append {cmd:pc_dd_analytic} results below previous results in an existing {it:filename}. 
Option {cmd:replace} will overwrite an existing {it:filename}.
If {it:filename} exists, then either {cmd:append} or {cmd:replace} is required.


{hline}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. pc_dd_analytic, n(80(5)160) pre(3) post(3) var(1) ar1(0.9) }{p_end}

{phang}{cmd:. pc_dd_analytic, n(100 200 300) power(0.90) pre(5) post(20) var(63.2) ar1(0.1(0.1)0.9) alpha(0.01) onesided} {p_end}

{phang}{cmd:. pc_dd_analytic, mde(20) power(0.8) pre(1(1)10) post(1(1)10) p(0.5) depv(y) i(person_id) t(month) out(power_calcs.txt) replace}{p_end}

{phang}{cmd:. pc_dd_analytic, n(50 60 70) mde(20 15 10) depv(income) i(village_id) t(year) if(village_id!=999) out(pc_test.txt) append}{p_end}

{hline}

{marker contact}{...}
{title:Contact}

{pstd}Louis Preonas{break}
Department of Agricultural and Resource Economics{break}
University of Maryland{break}
Email: {browse "mailto:lpreonas@umd.edu":lpreonas@umd.edu}
{p_end}

{pstd}This program is part of the {help ssc} package {cmd:pcpanel}.{p_end}

{hline}

{marker references}{...}
{title:References}

{p 0 0 0}
This program implements the analytic power calculation formula derived in:

{phang2}
{browse "https://doi.org/10.1016/j.jdeveco.2020.102458":Burlig, Fiona, Louis Preonas, and Matt Woerman (2020). "Panel Data and Experimental Design." {it:Journal of Development Economics} 144: 102548.}
{p_end}

{p 0 0 0}
Additional references include:

{phang}
Athey, Susan, and Guido W. Imbens (2016). "The Econometrics of Randomized Experiments." Working Paper.
{p_end}

{phang}
Bertrand, Marianne, Esther Duflo, and Sendhil Mullainathan (2004). "How Much Should We Trust Differences-in-Differences Estimates?" {it:The Quarterly Journal of Economics} 119(1): 249-275.
{p_end}

{phang}
Bloom, Howard S. (1995). "Minimum Detectable Effects: A Simple Way to Report the Statistical Power of Experimental Designs." {it:Evaluation Review} 19(5): 547-556.
{p_end}

{phang}
Cameron, A. Colin, and Douglas L. Miller (2015). "A Practitioner's Guide to Cluster-Robust Inference." {it:Journal of Human Resources} 50(2): 317-372.
{p_end}

{phang}
Campbell, Cathy (1977). "Properties of Ordinary and Weighted Least Square Estimators of Regression Coefficients for Two-Stage Samples." 
{it:Proceedings of the Social Statistics Section, American Statistical Association}: 800-805.
{p_end}

{phang}
Duflo, Esther, Rachel Glennerster, and Michael Kremer (2007). "Using Randomization in Development Economics Research: A Toolkit."  
Chap. 61 in {it:Handbook of Development Economics}, 
edited by Paul T. Schultz and John A. Strauss, 3895-3962. Volume 4. Oxford, UK: Elsevier.
{p_end}

{phang}
Frison, L., and S. J. Pocock (1992). "Repeated Measures in Clinical Trials: Analysis Using Mean Summary Statistics and its Implications for Design." {it:Statistics in Medicine} 11(13): 1685-1704.
{p_end}

{phang}
McKenzie, David (2012). "Beyond Baseline and Follow-up: The Case for More T in Experiments." {it:Journal of Development Economics} 99(2): 210-221.
{p_end}

{phang}
Moulton, Brent (1986). "Random Group Effects and the Precision of Regression Estimates." {it:Journal of Econometrics} 32(3): 385-397.
{p_end}

{phang}
Rubin, Donald B. (1974). "Estimating Causal Effects of Treatments in Randomized and Nonrandomized Studies." {it:Journal of Educational Psychology} 66(5): 688-701.
{p_end}



