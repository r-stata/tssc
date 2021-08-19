{smcl}
{* 11jan2021}{...}
{hi:help robmv}{...}
{right:{browse "http://github.com/benjann/robmv/"}}
{hline}

{title:Title}

{pstd}{hi:robmv} {hline 2} Robust multivariate estimation of location and covariance


{title:Syntax}

{pstd}Classical (non-robust) estimator

{p 8 15 2}
    {cmd:robmv} {opt cl:assic} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##cl_opt:{it:classic_options}} {help robmv##opt:{it:general_options}} ]

{pstd}M estimator

{p 8 15 2}
    {cmd:robmv} {opt m} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##m_opt:{it:m_options}} {help robmv##opt:{it:general_options}} ]

{pstd}S estimator

{p 8 15 2}
    {cmd:robmv} {opt s} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##s_opt:{it:s_options}} {help robmv##opt:{it:general_options}} ]

{pstd}MM estimator

{p 8 15 2}
    {cmd:robmv} {opt mm} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##mm_opt:{it:mm_options}} {help robmv##opt:{it:general_options}} ]

{pstd}Minimum Volume Ellipsoid (MVE) estimator

{p 8 15 2}
    {cmd:robmv} {opt mve} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##mve_opt:{it:mve_options}} {help robmv##opt:{it:general_options}} ]

{pstd}Minimum Covariance Determinant (MCD) estimator

{p 8 15 2}
    {cmd:robmv} {opt mcd} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##mcd_opt:{it:mcd_options}} {help robmv##opt:{it:general_options}} ]

{pstd}Stahel-Donoho estimator

{p 8 15 2}
    {cmd:robmv} {opt sd} {varlist} {ifin} {weight}
    [{cmd:,} {help robmv##sd_opt:{it:sd_options}} {help robmv##opt:{it:general_options}} ]

{pstd}Generate robust distances, outliers, etc., after estimation

{p 8 15 2}
    {cmd:predict} {dtype} {newvar} {ifin} [{cmd:,}
    {help robmv##predict_opt:{it:predict_options}} ]

{p 4 6 2}
{it:varlist} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{opt pweight}s, {opt aweight}s, {opt iweight}s, and {opt fweight}s are
allowed; see {help weight}{p_end}
{p 4 6 2}(exception: {cmd:robmv mcd} and {cmd:robmv mve} do
not allow {opt fweight}s)

{synoptset 21 tabbed}{...}
{marker opt}{col 5}{it:{help robmv##options:general_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt corr:elation}}report correlations instead of covariances
    {p_end}

{syntab :Standard errors/CIs}
{synopt :{cmd:vce(}{help robmv##vcetype:{it:vcetype}}{cmd:)}}{it:vcetype} may
    be {cmdab:a:nalytic} (the default), {cmdab:cl:uster} {it:clustvar},
    {cmdab:boot:strap} or {cmdab:jack:knife}
    {p_end}
{synopt :{cmd:svy}[{cmd:(}{help robstat##svy:{it:subpop}}{cmd:)}]}take account
    of survey design as set by {helpb svyset}, optionally restricting
    computations to {it:subpop}
    {p_end}
{synopt :{opt nose}}suppress computation of standard errors and confidence
    intervals
    {p_end}
{synopt :{cmdab:if:generate(}{help robmv##ifgen:{it:names}}{cmd:)}}stores the values of the
    influence functions
    {p_end}
{synopt :{opt r:eplace}}allows overwriting existing variables
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt nohe:ader}}suppress output header
    {p_end}
{synopt :{opt notab:le}}suppress output table
    {p_end}
{synopt :{help robmv##displayopts:{it:display_options}}}standard
    reporting options as described in
    {helpb estimation options:[R] estimation options}
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker cl_opt}{col 5}{it:{help robmv##cl_options:classic_options}}{col 28}Description
{synoptline}
{synopt :{opt normc:oll}}do not remove collinear variables
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker m_opt}{col 5}{it:{help robmv##m_options:m_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt k(#)}}set custom tuning constant
    {p_end}
{synopt :{opt ptrim(#)}}set winsorizing percentage
    {p_end}

{syntab :Consistency correction}
{synopt :{opt c(#)}}set custom consistency correction factor
    {p_end}
{synopt :{opt cemp}}use alternative approach to compute consistency correction factor
    {p_end}

{syntab :Algorithm}
{synopt :{opt tol:erance(#)}}tolerance for reweighting algorithm; default is
    {cmd:tolerance(1e-10)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations;
    default is as set by {helpb set maxiter}
    {p_end}
{synopt :{opt relax}}do not return error if convergence is not reached
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker s_opt}{col 5}{it:{help robmv##s_options:s_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt bp(#)}}breakdown point, in percent; default is {cmd:bp(50)}
    {p_end}
{synopt :{opt wh:ilferty}}obtain tuning constant using Wilson-Hilferty transformation
    {p_end}
{synopt :{opt k(#)}}custom tuning constant
    {p_end}

{syntab :Algorithm}
{synopt :{opt n:samp(#)}}number of trial candidates; default is {cmd:nsamp(20)}
    {p_end}
{synopt :{opt cstep:s(#)}}improvement steps applied to each trial
    candidate; default is {cmd:csteps(2)}
    {p_end}
{synopt :{opt nk:eep(#)}}number of candidates kept for final refinement;
    default is {cmd:nkeep(5)}
    {p_end}
{synopt :{opt tol:erance(#)}}tolerance for refinements; default is
    {cmd:tolerance(1e-10)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations; default is as set by {helpb set maxiter}
    {p_end}
{synopt :{opt relax}}do not return error if convergence is not reached
    {p_end}
{synopt :{opt noee}}do not use exact enumeration even if feasible
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker mm_opt}{col 5}{it:{help robmv##mm_options:mm_options}}{col 28}Description
{synoptline}
{synopt :{opt eff:iciency(#)}}desired efficiency, in percent; default is {cmd:efficiency(95)}
    {p_end}
{synopt :{opt loc:ation}}set location efficiency rather than shape efficiency
    {p_end}
{synopt : {help robmv##s_opt:{it:s_options}}}options as for {cmd:robreg s}
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker mve_opt}{col 5}{it:{help robmv##mve_options:mve_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt nore:weight}}report raw MVE estimate without reweighting step
    {p_end}
{synopt :{opt bp(#)}}breakdown point, in percent; default is {cmd:bp(50)}
    {p_end}
{synopt :{opt alpha(#)}}reweighting cutoff, in percent; default is {cmd:alpha(2.5)}
    {p_end}

{syntab :Consistency correction}
{synopt :{opt calpha(#)}}set custom consistency factor for raw MVE estimate
    {p_end}
{synopt :{opt cdelta(#)}}set custom consistency factor for reweighted estimate
    {p_end}

{syntab :Algorithm}
{synopt :{opt n:samp(#)}}number of trial candidates; default is {cmd:nsamp(500)}
    {p_end}
{synopt :{opt noee}}do not use exact enumeration even if feasible
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker mcd_opt}{col 5}{it:{help robmv##mcd_options:mcd_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt nore:weight}}report raw MCD estimate without reweighting step
    {p_end}
{synopt :{opt bp(#)}}breakdown point, in percent; default is {cmd:bp(50)}
    {p_end}
{synopt :{opt alpha(#)}}reweighting cutoff, in percent; default is {cmd:alpha(2.5)}
    {p_end}

{syntab :Consistency correction}
{synopt :{opt calpha(#)}}set custom consistency factor for raw MCD estimate
    {p_end}
{synopt :{opt cdelta(#)}}set custom consistency factor for reweighted estimate
    {p_end}
{synopt :{opt nosmall}}omit additional small sample correction
    {p_end}

{syntab :Algorithm}
{synopt :{opt n:samp(#)}}number of trial candidates; default is {cmd:nsamp(500)}
    {p_end}
{synopt :{opt cstep:s(#)}}concentration steps applied to each trial
    candidate; default is {cmd:csteps(2)}
    {p_end}
{synopt :{opt nk:eep(#)}}number of candidates kept for final refinement;
    default is {cmd:nkeep(10)}
    {p_end}
{synopt :{opt nsub(#)}}minimum subsample size; default is max(p*50, 300); type {cmd:nsub(.)} to omit subsampling
    {p_end}
{synopt :{opt ksub(#)}}maximum number of subsamples; default is {cmd:ksub(5)}
    {p_end}
{synopt :{opt tol:erance(#)}}tolerance for final refinement; default is
    {cmd:tolerance(1e-10)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations;
    default is as set by {helpb set maxiter}
    {p_end}
{synopt :{opt relax}}do not return error if convergence is not reached
    {p_end}
{synopt :{opt noee}}do not use exact enumeration even if feasible
    {p_end}
{synopt :{opt nouni:var}}use standard algorithm even if p=1
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker sd_opt}{col 5}{it:{help robmv##sd_options:sd_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt h:uber}}use a Huber-type rather than rectangular function
    to down-weight outliers
    {p_end}
{synopt :{opt alpha(#)}}outlier percentage under normality; default is {cmd:alpha(2.5)}
    {p_end}
{synopt :{opt asym:metric}[{cmd:(}{it:#}{cmd:)}]}compute generalized SD distances
    {p_end}
{synopt :{opt cut:off(#)}}set custom cutoff value for outlier identification
    {p_end}
{synopt :{opt nofit}}do not compute the location and covariance estimate
    {p_end}

{syntab :Generate}
{synopt :{cmdab:gen:erate(}{it:names}{cmd:)}}store SD distances, outlier
    indicator, and weights
    {p_end}
{synopt :{opt r:eplace}}allow overwriting existing variables
    {p_end}

{syntab :Algorithm}
{synopt :{opt n:samp(#)}}number of trial candidates; default is {cmd:nsamp(500)}
    {p_end}
{synopt :{opt nmax(#)}}maximum number of invalid candidates before aborting; default is max(1000,{cmd:nsamp()})
    {p_end}
{synopt :{opt expand}}expand invalid candidates by adding observations (not recommended)
    {p_end}
{synopt :{opt noee}}do not use exact enumeration even if feasible
    {p_end}
{synopt :{opt nostd}}omit standardization (not recommended)
    {p_end}
{synopt :{opt control:s(spec)}}partial out effects of covariates
    {p_end}
{synoptline}

{synoptset 21 tabbed}{...}
{marker predict_opt}{col 5}{it:{help robmv##predict_options:predict_options}}{col 28}Description
{synoptline}
{syntab :Main}
{synopt :{opt d:istance}}generate robust distances; the default
    {p_end}
{synopt :{opt r:d}}synonym for {cmd:distance}
    {p_end}
{synopt :{opt o:utlier}[{cmd:(}{it:#}{cmd:)}]}generate outlier indicator
    {p_end}
{synopt :{opt i:nlier}[{cmd:(}{it:#}{cmd:)}]}generate inlier indicator
    {p_end}

{syntab :Additional M options}
{synopt :{opt w:eights}}generate W1 weights
    {p_end}

{syntab :Additional MVE/MCD options}
{synopt :{opt s:ubset}}generate best H-subset indicator
    {p_end}
{synopt :{opt nore:weight}}use raw MVE/MCD estimate
    {p_end}
{synopt :{opt noscale}}use unscaled raw MVE/MCD estimate
    {p_end}
{synoptline}


{title:Description}

{pstd}
    {cmd:robmv} provides a number of robust multivariate estimators of location
    and covariance.

{pstd}
    {cmd:robmv classic} computes the classical (non-robust) estimate of
    location and covariance. Results are the same as computed by standard
    commands such as {helpb correlate}.

{pstd}
    {cmd:robmv m} computes an M estimate of location and covariance using a
    Huber weighting function as suggested by Lopuha{c a:} (1989). Singular
    solutions are handled as suggested by Maronna et al. (2006, p. 184-185).

{pstd}
    {cmd:robmv s} computes an S estimate of
    location and covariance (Lopuha{c a:} 1989) using the FastS algorithm
    as described in Hubert et al. (2013).

{pstd}
    {cmd:robmv mm} computes an MM estimate of location and covariance
    (Salibian-Barrera et al. 2006).

{pstd}
    {cmd:robmv mve} computes the Minimum Volume Ellipsoid (MVE) estimator
    of location and covariance. By default, the one-step reweighted estimate
    is reported instead of the raw MVE estimate. The estimation algorithm employs
    and improvement step as suggested by Maronna et al. (2006, p. 198). In case
    of an exact-fit situation (that is, when the variance matrix in the best
    H-subset is singular due to local collinearity among the variables) the
    means and covariances are based on all observations that lie on the
    hyperplane and the corresponding hyperplane equation is reported.

{pstd}
    {cmd:robmv mcd} computes the Minimum Covariance Determinant (MCD) estimator
    of location and covariance. By default, the one-step reweighted estimate
    is reported instead of the raw MCD estimate. A fast algorithm as suggested
    by Rousseeuw and Van Driessen (1999) is used for computation of the MCD
    estimate. Consistency correction as given in Croux and Haesbroeck (1999) is
    applied. Furthermore, by default, small sample bias is corrected as
    suggested by Pison et al. (2002). In case of an exact-fit situation
    (that is, when the variance matrix in the best H-subset is singular
    due to local collinearity among the variables) the means and covariances
    are based on all observations that lie on the hyperplane and
    the corresponding hyperplane equation is reported.

{pstd}
    {cmd:robmv sd} computes the Stahel-Donoho estimator of
    location and covariance as discussed, for example, by Maronna and
    Yohai (1995). It also supports the modified Stahel-Donoho estimator for
    skewed and/or heavy-tailed distributions suggested by Verardi and
    Vermandele (2016).

{pstd}
    {cmd:predict} can be used after {cmd:robmv} to generate variables
    identifying outliers, containing robust distances, etc.


{title:Dependencies}

{pstd}
    {cmd:robmv} requires {cmd:moremata}; see
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}.
    In addition, the {cmd:asymmetric} option of {cmd:robmv sd} requires {cmd:robbox}; see
    {net "describe robbox, from(http://fmwww.bc.edu/repec/bocode/r/)":ssc describe robbox}.


{marker options}{...}
{title:General options}

{dlgtab:Main}

{phang}
    {opt correlation} specifies that correlations be reported instead of
    variances and covariances.

{dlgtab:Standard errors/CIs}

{marker vcetype}{...}
{phang}
    {opth vce(vcetype)} determines how standard errors and confidence intervals
    are computed. {it:vcetype} may be

            {cmd:analytic}
            {cmd:cluster} {it:clustvar}
            {cmd:bootstrap} [{cmd:,} {help bootstrap:{it:bootstrap_options}}]
            {cmd:jackknife} [{cmd:,} {help jackknife:{it:jackknife_options}}]

{pmore}
    {cmd:vce(analytic)}, the default, computes standard errors based on influence
    functions. Likewise, {cmd:vce(cluster} {it:clustvar}{cmd:)} computes standard
    errors based on influence function allowing for intragroup correlation,
    where {it:clustvar} specifies to which group each observation belongs. For
    bootstrap and jackknife estimation, see help {it:{help vce_option}}.

{pmore}
    Currently, {cmd:vce(analytic)} and {cmd:vce(cluster)} are only supported by
    {cmd:robmv classic}. No standard errors will be estimated by the other
    subcommands.

{phang}
    {cmd:svy}[{cmd:(}{it:subpop}{cmd:)}] causes the survey design to be taken
    into account for variance estimation. The data need to be set up for survey
    estimation; see help {helpb svyset}. Only one of {cmd:svy()} and {cmd:vce()}
    is allowed. Specify {it:subpop} to restrict survey
    estimation to a subpopulation, where {it:subpop} is

            [{varname}] [{it:{help if}}]

{pmore}
    The subpopulation is defined by observations for which {it:varname}!=0 and
    for which the {cmd:if} condition is met. See help {helpb svy} and
    {manlink SVY subpopulation estimation} for more information on subpopulation
    estimation.

{pmore}
    The {cmd:svy} option of {cmd:robmv} only works if the variance
    estimation method is set to Taylor linearization by {helpb svyset} (the
    default). For other variance estimation methods you can use the usual {helpb svy}
    prefix command.

{pmore}
    Currently, {cmd:svy()} is only supported by
    {cmd:robmv classic}. No standard errors will be estimated by the other
    subcommands.

{phang}
    {opt nose} suppresses the computation of standard errors and confidence
    intervals.

{marker ifgen}{...}
{phang}
    {opt ifgenerate(names)} stores the influence functions that were used
    to compute the standard errors, where {it:names} is either a list of (new) variable names
    or {help newvarlist##stub*:{it:stub}}{cmd:*} to create names {it:stub}{cmd:1},
    {it:stub}{cmd:2}, etc. {cmd:ifgenerate()} has no effect if specified together
    with {cmd:nose}, {cmd:vce(bootstrap)}, or {cmd:vce(jackknife)}.

{phang}
    {opt replace} allows {cmd:ifgenerate()} to overwrite existing variables.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt noheader} suppresses the output header; only the coefficient table is
    displayed.

{phang}
    {opt notable} suppresses the coefficient table.

{marker displayopts}{...}
{phang}
    {it:display_options} are standard reporting options such as {cmd:cformat()},
    {cmd:pformat()}, {cmd:sformat()}, or {cmd:coeflegend}. See
    {helpb estimation options:[R] estimation options}.


{marker cl_options}{...}
{title:Additional options for robmv classic}

{phang}
    {opt normcoll} requests that collinear variables will be included in the
    estimation. The default is to remove collinear variables.


{marker m_options}{...}
{title:Additional options for robmv m}

{dlgtab:Main}

{phang}
    {opt k(#)} sets the tuning constant for the Huber objective function.
    Unless {cmd:ptrim()} is specified (see below), the default is to set the
    tuning constant to k = sqrt(p+1), where p is the number of variables, so
    that the maximum asymptotic breakdown point of bp = min(1/k^2, 1-p/k^2) is
    reached (see Lopuha{c a:} 1989). Note that {cmd:k()} must be larger than
    sqrt(p) for the M estimate to exist.

{phang}
    {opt ptrim(#)} sets the percentage of winsorizing. If {opt ptrim()} is
    specified, the tuning constant is set to k = sqrt(invchi2tail(p,
    ptrim/100)), where p is the number of variables. Setting {cmd:ptrim(0)}
    will return the classical location and covariance estimate (no
    winsorizing). Note that {cmd:ptrim()} must be smaller than
    chi2tail(p,p)*100, where p is the number of variables, for the M estimate
    to exist. Only one of {cmd:ptrim()} and {cmd:k()} is allowed.

{dlgtab:Consistency correction}

{phang}
    {opt c(#)} specifies a custom consistency correction factor by which
    the raw estimate be rescaled. The default is to rescale the
    estimate so that it provides a consistent estimate of the mean and
    covariance matrix for normally distributed data (see option {cmd:cemp}
    below).

{phang}
    {opt cemp} specifies that the normal consistency correction factor
    is estimated empirically (equation 6.22 in Maronna et al. 2006). The
    default is to derive the normal consistency correction factor
    numerically (equation 6.21 in Maronna et al. 2006). Use the {cmd:cemp}
    option should the default algorithm fail (unlikely to happen).

{dlgtab:Algorithm}

{phang}
    {opt tolerance(#)} sets the tolerance for the reweighting algorithm.
    When the maximum relative change in the location and covariance estimate
    is less than or equal to {cmd:tolerance()}, convergence is
    achieved. The default is {cmd:tolerance(1e-10)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the
    reweighting algorithm. If convergence is not reached within
    {cmd:iterate()} iterations, the algorithm stops and returns error. The
    default is as set by {helpb set maxiter}.

{phang}
    {opt relax} causes the algorithm to return the current results
    instead of returning error if convergence is not reached within
    {cmd:iterate()} iterations.


{marker s_options}{...}
{title:Additional options for robmv s}

{dlgtab:Main}

{phang}
    {opt bp(#)} sets the breakdown point (in percent) with # in [1,50]. The
    default is {cmd:bp(50)}.

{phang}{opt whilferty} obtains the tuning constant corresponding to the desired
    breakdown point by applying the Wilson-Hilferty transformation to the tuning
    constant of the univariate biweight function. The default is to obtain the
    tuning constant by finding value {it:k} that solves {it:bp} = {it:b} /
    ({it:k}^2/6), where {it:bp} is the desired breakdown point and {it:b} is
    the Gaussian consistency parameter of the scale optimization problem.

{phang}
    {opt k(#)} sets the tuning constant to a custom value. Only one of
    {cmd:k()} and {cmd:bp()} is allowed. The procedure used to compute the
    breakdown point corresponding to {cmd:k()} depends on whether {cmd:whilferty}
    is specified or not.

{dlgtab:Algorithm}

{phang}
    {opt nsamp(#)} specifies the number of trial candidates to be evaluated in the
    search algorithm. The default is {cmd:nsamp(20)}.

{phang}
    {opt csteps(#)} sets the number of improvement steps (C-steps) applied when
    evaluating the trial candidates. The default is {cmd:csteps(2)}.

{phang}
    {opt nkeep(#)} sets the number of best trial candidates kept for final
    refinement. The default is {cmd:nkeep(5)}.

{phang}
    {opt tolerance(#)} sets the tolerance for the candidate scale refinements
    and the final refinement of the best candidates. When the relative
    change in the scale from one iteration to the next is less than or equal
    to {cmd:tolerance()}, convergence is achieved. The default is {cmd:tolerance(1e-10)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the candidate scale refinements
    and the final refinement of the best candidates. If convergence is not reached within
    {cmd:iterate()} iterations, the algorithm stops and returns error. The
    default is as set by {helpb set maxiter}.

{phang}
    {opt relax} causes the algorithm to use the current results
    instead of returning error if convergence is not reached within
    {cmd:iterate()} iterations.

{phang}
    {opt noee} specifies that enumeration of random trials is used even if
    exact enumeration of all possible candidates would be feasible. The
    algorithms uses exact enumeration of all possible (p+1)-subsets if comb(N,
    p+1) <= {cmd:nsamp()}. Otherwise, {cmd:nsamp()} random (p+1)-subsets are
    enumerated. Given the low default value of {cmd:nsamp()}, exact enumeration
    will only be used in very small samples. Set {cmd:nsamp()} to comb(N, p+1),
    to enforce exact enumeration of (p+1)-subsets.


{marker mm_options}{...}
{title:Additional options for robmv mm}

{phang}
    {opt efficiency(#)} sets the desired gaussian efficiency (in percent) with #
    in [70,100). The default is {cmd:efficiency(95)}.

{phang}
    {opt location} requests that {cmd:efficiency()} sets the location
    efficiency. The default is to set the shape efficiency.

{phang}
    {help robmv##s_options:{it:s_options}} are additional options as for {cmd:robreg s}.


{marker mve_options}{...}
{title:Additional options for robmv mve}

{dlgtab:Main}

{phang}
    {opt noreweight} causes the raw MVE estimate to be reported instead of
    the one-step reweighted estimate. The one-step reweighted estimate
    is computed from the observations whose robust distances based on the
    raw MVE fit are smaller than invchi2(p, 0.975), where p is the number
    of variables. The one-step reweighted estimate has better efficiency
    properties than the raw MVE estimate.
    {p_end}

{phang}
    {opt bp(#)} sets the approximate breakdown point (in percent) with # being
    an integer number between 0 and 50. The default is {cmd:bp(50)}. The breakdown
    point determines the size of the H-subset, that is, the number of
    observations in the subset that identifies the MVE fit. The size of
    the H-subset is computed as

            h = floor((N - p - 1)*(1 - bp/100) + p + 1)

{pmore}
    where N is the sample size, p is the number of variable and bp is the
    specified breakdown point (in percent). In case of a breakdown point of 50%
    this simplifies to h = floor((N + p + 1)/2). Note that in case of
    weights, the H-subset will be constructed from the raw observations
    ignoring weights. That is, the breakdown point should be interpreted in
    terms of a percentage of the raw observations and not in terms of a
    percentage of the sum of weights.

{phang}
    {opt alpha(#)} sets the cutoff, in percent, used to determine the weights for the
    reweighted estimate. The weights are set to one for observations with squared
    distanced smaller than invchi2(p, 1-alpha/100) and zero else, where p is the
    number of variables. The default is {cmd:alpha(2.5)}.

{dlgtab:Consistency correction}

{phang}
    {opt calpha(#)} specifies a custom consistency factor by which the initial
    MVE estimate be rescaled. The default is to rescale the estimate so that it
    provides a consistent estimate of the mean and covariance matrix for
    normally distributed data. The default consistency factor is computed as
    median(d2)/invchi2(p, 0.5), where d2 are the squared robust distances based
    on the initial MVE fit an p is the number of variables.

{phang}
    {opt cdelta(#)} specifies a custom consistency factor by which
    the one-step reweighted estimate be rescaled. The default is to rescale the
    estimate so that it provides a consistent estimate of the mean and
    covariance matrix for normally distributed data. The default consistency
    factor is computed as (W/N)/chi2(p+2, invchi2(p, W/N)), where p
    is the number of variables, N is the sample size, and W is the number of
    observations on which the reweighted estimate is based
    (see option {cmd:noreweight} above).

{dlgtab:Algorithm}

{phang}
    {opt nsamp(#)} specifies the number of trial candidates to be evaluated in the
    search algorithm. The default is {cmd:nsamp(500)}.

{phang}
    {opt noee} specifies that enumeration of random trials is used even if
    exact enumeration of all possible candidates would be feasible. The
    algorithms uses exact enumeration of all possible (p+1)-subsets if comb(N,
    p+1) <= {cmd:nsamp()}. Otherwise, {cmd:nsamp()} random (p+1)-subsets are
    enumerated. Given the low default value of {cmd:nsamp()}, exact enumeration
    will only be used in very small samples. Set {cmd:nsamp()} to comb(N, p+1),
    to enforce exact enumeration of (p+1)-subsets.


{marker mcd_options}{...}
{title:Additional options for robmv mcd}

{dlgtab:Main}

{phang}
    {opt noreweight} causes the raw MCD estimate to be reported instead of
    the one-step reweighted estimate. The one-step reweighted estimate
    is computed from the observations whose robust distances based on the
    raw MCD fit are smaller than invchi2(p, 0.975), where p is the number
    of variables. The one-step reweighted estimate has better efficiency
    properties than the raw MCD estimate.
    {p_end}

{phang}
    {opt bp(#)} sets the approximate breakdown point (in percent) with # being
    an integer number between 0 and 50. The default is {cmd:bp(50)}. The breakdown
    point determines the size of the H-subset, that is, the number of
    observations in the subset that identifies the MCD fit. The size of
    the H-subset is computed as

            h = floor((N - p - 1)*(1 - bp/100) + p + 1)

{pmore}
    where N is the sample size, p is the number of variable and bp is the
    specified breakdown point (in percent). In case of a breakdown point of 50%
    this simplifies to h = floor((N + p + 1)/2). The relationship between h and
    the desired breakdown point is only approximate, as the breakdown point of
    the MCD estimate is given as (N - h + 1)/N. The larger the sample size, the
    better h realizes the desired breakdown point. Note that in case of
    weights, the H-subset will be constructed from the raw observations
    ignoring weights. That is, the breakdown point should be interpreted in
    terms of a percentage of the raw observations and not in terms of a
    percentage of the sum of weights.

{phang}
    {opt alpha(#)} sets the cutoff, in percent, used to determine the weights for the
    reweighted estimate. The weights are set to one for observations with squared
    distanced smaller than invchi2(p, 1-alpha/100) and zero else, where p is the
    number of variables. The default is {cmd:alpha(2.5)}.

{dlgtab:Consistency correction}

{phang}
    {opt calpha(#)} specifies a custom consistency factor by which
    the initial MCD estimate be rescaled. The default is to rescale the
    estimate so that it provides a consistent estimate of the mean and
    covariance matrix for normally distributed data. The default consistency
    factor is computed as (h/N)/chi2(p+2, invchi2(p, h/N)), where p
    is the number of variables, N is the sample size, and h is the size of the
    H-subset (see option {cmd:bp()} above).

{phang}
    {opt cdelta(#)} specifies a custom consistency factor by which
    the one-step reweighted estimate be rescaled. The default is to rescale the
    estimate so that it provides a consistent estimate of the mean and
    covariance matrix for normally distributed data. The default consistency
    factor is computed as (W/N)/chi2(p+2, invchi2(p, W/N)), where p
    is the number of variables, N is the sample size, and W is the number of
    observations on which the reweighted estimate is based
    (see option {cmd:noreweight} above).

{phang}
    {opt nosmall} specifies that the additional small sample correction suggested
    by Pison et al. (2002) be omitted.
    {p_end}

{dlgtab:Algorithm}

{phang}
    {opt nsamp(#)} specifies the number of trial candidates to be evaluated in the
    search algorithm for the best H-subset. The default is {cmd:nsamp(500)}.

{phang}
    {opt csteps(#)} sets the number of concentration steps (C-steps) applied when
    evaluating the trial candidates. The default is {cmd:csteps(2)}.

{phang}
    {opt nkeep(#)} sets the number of best trial candidates kept for final
    refinement. The default is {cmd:nkeep(10)}.

{phang}
    {opt nsub(#)} specifies the subsample size used by the search algorithm in
    case of a large sample size N. The default is max(p*50, 300), where p is
    the number of variables. If N >= 2*{cmd:nsub()} the algorithm splits the
    sample into subsamples for the enumeration of the trial candidates. Up to
    {cmd:ksub()} subsamples are constructed (see below). For example, if
    {cmd:nsub()} is set to 300, {cmd:ksub()} is set to 5, and N = 10000, then 5
    subsamples of size 300 are drawn (without replacement) from the 10000
    observations and in each of these subsample {cmd:nsamp()}/5 trial
    candidates are enumerated. From each subsample the {cmd:nkeep()} best
    candidates are kept for further evaluation. The 5 subsamples are then
    merged together to a subsample of size 5*300 = 1500 observations and the
    5*{cmd:nkeep()} candidates are evaluated. The {cmd:nkeep()} best candidates
    from the merged sample are then refined util convergence in the full sample
    to identify the best solution. If N < 2*{cmd:nsub()}, no subsampling is
    applied, that is, all {cmd:nsamp()} candidates are enumerated in the full
    sample. If 2*{cmd:nsub()} <= N <= {cmd:ksub()}*{cmd:nsub()}, the data is
    split into as many subsamples as possible using a minimum subsample size of
    {cmd:nsub()} observations. For example, if N = 800 and {cmd:nsub()} is set
    to 300, then the data is split into two subsamples with 400 observations
    and in each of the subsample {cmd:nsamp()}/2 trial candidates are
    enumerated. See Rousseeuw and Van Driessen (1999) for a more detailed
    description of the algorithm.

{pmore}
    Specify {cmd:nsub(.)} to omit subsampling and evaluate all {cmd:nsamp()}
    trial candidates in the full sample irrespective of the sample size.

{phang}
    {opt ksub(#)} sets the maximum number of subsamples used by the
    large-N algorithm; see the {cmd:nsub()} option above. The default is
    {cmd:ksub(5)}. {cmd:ksub()} must be equal to 2 or larger.

{phang}
    {opt tolerance(#)} sets the tolerance for the final refinement of the best
    candidates. When the relative change in the determinant from one iteration
    to the next is less than or equal to {cmd:tolerance()}, convergence is
    achieved. The default is {cmd:tolerance(1e-10)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the final
    refinement of the best candidates. If convergence is not reached within
    {cmd:iterate()} iterations, the algorithm stops and returns error. The
    default is as set by {helpb set maxiter}.

{phang}
    {opt relax} causes the algorithm to return the current results
    instead of returning error if convergence is not reached within
    {cmd:iterate()} iterations. Use this option together with
    {cmd:iterate()} if you want to restrict the number of C-steps in the
    final refinement.

{phang}
    {opt noee} specifies that enumeration of random trials is used even if
    exact enumeration of all possible candidates would be feasible. The
    algorithms uses exact enumeration of all possible H-subsets if comb(N, h)
    <= {cmd:nsamp()} and uses exact enumeration of all possible (p+1)-subsets
    if comb(N, p+1) <= {cmd:nsamp()}. Otherwise, {cmd:nsamp()} random
    (p+1)-subsets are enumerated (while expanding singular subsets until
    nonsingular or until reaching size h). Given the low default value of
    {cmd:nsamp()}, exact enumeration will only be used in very small samples.
    Set {cmd:nsamp()} to comb(N, h) or comb(N, p+1), to enforce exact
    enumeration of H-subsets or (p+1)-subsets, respectively.

{phang}
    {opt nounivar} specifies that the standard search algorithm is used even if
    only one variable is analyzed. The default is to use an exact enumeration
    algorithm for univariate data in this case.


{marker sd_options}{...}
{title:Additional options for robmv sd}

{dlgtab:Main}

{phang}
    {opt huber} requests that a Huber-type function is used to down-weight
    the outliers when computing the location and covariance estimate. By default,
    a rectangular function is used, which is equivalent to excluding the outliers.

{phang}
    {opt alpha(#)} sets the expected percentage of observations that will be classified
    as outliers under normal conditions. The default is {cmd:alpha(2.5)}. {cmd:alpha()}
    has no effect if {cmd:cutoff()} is specified.

{phang}
    {opt asymmetric}[{cmd:(}{it:#}{cmd:)}] computes generalized SD distances
    and determines the cutoff point for outlier identification based on
    Tukey's g-and-h distribution (employing command {helpb robbox}) as suggested by
    Verardi and Vermandele (2016). {it:#}
    sets the breakdown point, in percent, that is used when fitting the
    g-and-h distribution; the default is {cmd:10}. {it:#} has no effect if
    {cmd:cutoff()} is specified.

{phang}
    {opt cutoff(#)} specifies a custom cutoff value for outlier
    identification. By default, if {cmd:asymmetric} is omitted, the cutoff value
    is set to sqrt(invchi2({it:p}, 1 - {cmd:alpha()}/100)), where {it:p} is the
    number of variables. If {cmd:asymmetric} is specified, the default is to
    determine the cutoff value corresponding to {cmd:alpha()} based on
    Tukey's g-and-h distribution.

{phang}
    {opt nofit} omits the computation of the location and covariance estimate. Use
    this option if you are only interested in the Stahel-Donoho distances, but not
    in the location and covariance estimate. The Stahel-Donoho distances can be
    stored by the {cmd:generate()} option.

{dlgtab:Generate}

{phang}
    {cmd:generate(}{it:names}{cmd:)} store a variable containing the
    SD distances, an outlier indicator, and a variable containing the weights
    used to compute the location and covariance estimate. {it:names} may contain
    one to three names, depending on whether you only want to store the distances,
    the distances and the outlier indicators, or the distances, outlier indicator,
    and weights.

{phang}
    {opt replace} allows {cmd:generate()} to overwrite existing variables.

{dlgtab:Algorithm}

{phang}
    {opt nsamp(#)} specifies the number of candidates (p-subsets) to be evaluated in the
    search algorithm. The default is {cmd:nsamp(500)}.

{phang}
    {opt nsmax(#)} specifies the maximum number of candidates that are allowed to
    be infeasible (within each single search for a trial candidate) before aborting
    with error. The default is max(1000,{cmd:nsamp()}).

{phang}
    {opt expand} expands infeasible candidates by adding observations to the subset
    until the candidate becomes feasible. Specifying {cmd:expand} is not recommended.

{phang}
    {opt noee} specifies that enumeration of random subsets is used even if
    exact enumeration of all possible subsets would be feasible. The
    algorithms uses exact enumeration of all possible subsets if comb(N,
    p) <= {cmd:nsamp()}. Otherwise, {cmd:nsamp()} random subsets are
    enumerated.

{phang}
    {opt nostd} omits standardization of the data for the enumeration
    algorithm. Specifying {cmd:nostd} is not recommended.

{phang}
    {cmd:controls(}{it:varlist}[{cmd:,} {it:options}]{cmd:)} partials out the
    effects of {it:varlist} from the SD distances within each projection;
    {it:varlist} may contain factor variables; see {help fvvarlist}.
    {it:options} determine whether to include the controls in the final
    location and covariance estimate and set the details of the Huber M
    estimator used to partial out the effects of the controls; the options are
    as follows:

{phang2}
    {cmd:include} includes the variables specified in {cmd:controls()} in the
    final location and covariance estimate. The default is to include
    only the main variables.

{phang2}
    {opt eff:iciency(#)} sets the gaussian efficiency of the M estimator, in percent. {it:#}
    must be within [63.7,99.9]. The default is 100 - {cmd:alpha()}.

{phang2}
    {opt k(#)} sets the tuning constant of the M estimator. Only one of
    {opt efficiency()} and {cmd:k()} is allowed.

{phang2}
    {opt tol:erance(#)} set the tolerance of the M estimator. The default is
    {cmd:tolerance(1e-10)}.

{phang2}
    {opt iter:ate(#)} set the maximum number of iterations of the M
    estimator. The default is as set by {helpb set maxiter}


{marker predict_options}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}
    {opt distance} generates a variable containing robust distances. This is
    the default.

{phang}
    {opt rd} is a synonym for {cmd:distance}.

{phang}
    {opt outlier}[{cmd:(}{it:#}{cmd:)}] generates a 0/1 variable identifying
    outliers (1 = outlier, 0 = inlier). Optional argument {it:#} specifies the
    percentage of observations classified as outliers in normal data. That is,
    observations with squared distances greater than or equal to
    invchi2(p, 1-{it:#}/100), were p is the number of variables, are classified
    as outliers. Argument {it:#} must be in [0,50]; the default is 2.5.

{phang}
    {opt inlier}[{cmd:(}{it:#}{cmd:)}] generates a 0/1 variable identifying
    inliers (1 = inlier, 0 = outlier). Optional argument {it:#} specifies the
    percentage of observations classified as inliers in normal data. That is,
    observations with squared distances smaller than invchi2(p, {it:#}/100),
    were p is the number of variables, are classified as inliers; all other
    observations are classified as outliers. Argument {it:#} must be in
    [50,100]; default is 97.5.

{dlgtab:Additional M options}

{phang}
    {opt weights} generates a variable containing the W1 weights of the
    M fit.

{dlgtab:Additional MVE/MCD options}

{phang}
    {opt subset} generates a 0/1 variable identifying the best H-subset in the
    estimation sample. Observations outside {cmd:e(sample)}
    will be set to missing.

{phang}
    {opt noreweight} specifies that the raw MVE/MCD estimate be used for
    determining robust distances, ouliers, and inliers. If available (that is,
    unless option {cmd:noreweight} was specified during estimation), the
    default is to base computations on the one-step reweighted estimate.

{phang}
    {opt noscale} specifies that the unscaled raw MVE/MCD estimate be used for
    determining robust distances, ouliers, and inliers. The unscaled
    raw MVE/MCD estimate is equal to the raw MVE/MCD estimate before applying
    consistency or small-sample correction factors.


{title:Examples}

        . {stata sysuse auto}
        . {stata robmv classic price mpg weight length}
        . {stata robmv m price mpg weight length}
        . {stata robmv s price mpg weight length}
        . {stata robmv mm price mpg weight length}
        . {stata robmv mve price mpg weight length}
        . {stata robmv mcd price mpg weight length}
        . {stata robmv sd price mpg weight length}


{title:Saved results}

{pstd}
{cmd:robmv} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(nvars)}}number of variables included in the location and covariance estimate{p_end}
{synopt:{cmd:e(rnk)}}rank of covariance matrix{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (only if {cmd:vce(cluster)} is specified){p_end}
{synopt:{cmd:e(df_r)}}sample degrees of freedom (only if {cmd:e(V)} is stored){p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:robmv}{p_end}
{synopt:{cmd:e(subcmd)}}name of subcommand{p_end}
{synopt:{cmd:e(predict)}}{cmd:robmv_p}{p_end}
{synopt:{cmd:e(depvar)}}{cmd:Cov} or {cmd:Corr}{p_end}
{synopt:{cmd:e(valist)}}names of variables included in the location and covariance estimate{p_end}
{synopt:{cmd:e(valist0)}}names of variables including base levels and omitted terms{p_end}
{synopt:{cmd:e(correlation)}}{cmd:correlation} or empty{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V} or {cmd:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}sampling variance of estimates (only if supported){p_end}
{synopt:{cmd:e(mu)}}location estimates{p_end}
{synopt:{cmd:e(Cov)}}covariance estimates{p_end}
{synopt:{cmd:e(Corr)}}correlation estimates{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
{cmd:robmv m} additionally stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(bp)}}limiting value of breakdown point{p_end}
{synopt:{cmd:e(ptrim)}}winsorizing percentage{p_end}
{synopt:{cmd:e(k)}}tuning constant of the Huber objective function{p_end}
{synopt:{cmd:e(c)}}consistency correction factor{p_end}
{synopt:{cmd:e(tolerance)}}tolerance for reweighting algorithm{p_end}
{synopt:{cmd:e(iterate)}}maximum number of iterations for reweighting algorithm{p_end}
{synopt:{cmd:e(niter)}}executed number of iterations{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(relax)}}{cmd:relax} or empty{p_end}

{pstd}
{cmd:robmv s} and {cmd:robmv mm} additionally store the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(bp)}}breakdown point{p_end}
{synopt:{cmd:e(k)}}tuning constant{p_end}
{synopt:{cmd:e(delta)}}normal consistency parameter{p_end}
{synopt:{cmd:e(nsamp)}}number of trial candidates{p_end}
{synopt:{cmd:e(csteps)}}number of C-steps for trial candidates{p_end}
{synopt:{cmd:e(nkeep)}}number of best candidates for final refinement{p_end}
{synopt:{cmd:e(tolerance)}}tolerance for refinements{p_end}
{synopt:{cmd:e(iterate)}}maximum number of iterations for refinements{p_end}
{synopt:{cmd:e(scale)}}scale estimate{p_end}
{synopt:{cmd:e(efficiency)}}efficiency, in percent ({cmd:robreg mm} only){p_end}
{synopt:{cmd:e(k_m)}}tuning constant of M step ({cmd:robreg mm} only){p_end}
{synopt:{cmd:e(niter)}}executed number of M step iterations ({cmd:robreg mm} only){p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(whilferty)}}{cmd:whilferty} or empty{p_end}
{synopt:{cmd:e(noee)}}{cmd:noee} or empty{p_end}
{synopt:{cmd:e(method)}}{cmd:random} or {cmd:exact}{p_end}
{synopt:{cmd:e(relax)}}{cmd:relax} or empty{p_end}
{synopt:{cmd:e(efftype)}}{cmd:shape} or {cmd:location} ({cmd:robreg mm} only){p_end}

{pstd}
{cmd:robmv mve} additionally stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(h)}}size of H-subset{p_end}
{synopt:{cmd:e(bp)}}requested breakdown point{p_end}
{synopt:{cmd:e(calpha)}}consistency factor for raw MVE estimate{p_end}
{synopt:{cmd:e(cdelta)}}consistency factor for reweighted estimate (unless {cmd:noreweight} was specified){p_end}
{synopt:{cmd:e(nsamp)}}number of trial candidates{p_end}
{synopt:{cmd:e(nhyper)}}number of observations on hyperplane if H-subset is collinear; {cmd:0} else {p_end}
{synopt:{cmd:e(MVE)}}(normalized) scale of initial MVE estimate{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(noreweight)}}{cmd:noreweight} or empty{p_end}
{synopt:{cmd:e(noee)}}{cmd:noee} or empty{p_end}
{synopt:{cmd:e(method)}}{cmd:classical}, {cmd:random}, or {cmd:exact}{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(mu0)}}unscaled raw MVE location estimate{p_end}
{synopt:{cmd:e(Cov0)}}unscaled raw MVE covariance estimate{p_end}
{synopt:{cmd:e(Corr0)}}unscaled raw MVE correlation estimate{p_end}
{synopt:{cmd:e(gamma)}}coefficients of hyperplane equation (if H-subset is collinear){p_end}

{pstd}
{cmd:robmv mcd} additionally stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(h)}}size of H-subset{p_end}
{synopt:{cmd:e(bp)}}requested breakdown point{p_end}
{synopt:{cmd:e(calpha)}}consistency factor for raw MCD estimate{p_end}
{synopt:{cmd:e(salpha)}}small sample correction factor for raw MCD estimate {p_end}
{synopt:{cmd:e(cdelta)}}consistency factor for reweighted estimate (unless {cmd:noreweight} was specified){p_end}
{synopt:{cmd:e(sdelta)}}small sample correction factor for reweighted estimate (unless {cmd:noreweight} was specified){p_end}
{synopt:{cmd:e(nsamp)}}number of trial candidates{p_end}
{synopt:{cmd:e(nsub)}}(minimum) size of subsamples for large-N algorithm{p_end}
{synopt:{cmd:e(ksub)}}number of subsamples uses by large-N algorithm; {cmd:0} else{p_end}
{synopt:{cmd:e(nmerged)}}size of merged subsamples{p_end}
{synopt:{cmd:e(csteps)}}(maximum) number of C-steps for trial candidates{p_end}
{synopt:{cmd:e(nkeep)}}number of best candidates for final refinement{p_end}
{synopt:{cmd:e(tolerance)}}tolerance for final refinement{p_end}
{synopt:{cmd:e(iterate)}}maximum number of iterations for final refinement{p_end}
{synopt:{cmd:e(nhyper)}}number of observations on hyperplane if H-subset is collinear; {cmd:0} else {p_end}
{synopt:{cmd:e(MCD)}}determinant of unscaled raw MCD estimate{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(noreweight)}}{cmd:noreweight} or empty{p_end}
{synopt:{cmd:e(nosmall)}}{cmd:nosmall} or empty{p_end}
{synopt:{cmd:e(noee)}}{cmd:noee} or empty{p_end}
{synopt:{cmd:e(method)}}{cmd:classical}, {cmd:univar}, {cmd:random}, {cmd:exact-h}, or {cmd:exact-p}{p_end}
{synopt:{cmd:e(nounivar)}}{cmd:nounivar} or empty{p_end}
{synopt:{cmd:e(relax)}}{cmd:relax} or empty{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(mu0)}}unscaled raw MCD location estimate{p_end}
{synopt:{cmd:e(Cov0)}}unscaled raw MCD covariance estimate{p_end}
{synopt:{cmd:e(Corr0)}}unscaled raw MCD correlation estimate{p_end}
{synopt:{cmd:e(gamma)}}coefficients of hyperplane equation (if H-subset is collinear){p_end}

{pstd}
{cmd:robmv sd} additionally stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(nsamp)}}number of trial candidates{p_end}
{synopt:{cmd:e(nmax)}}setting of {cmd:nmax()}{p_end}
{synopt:{cmd:e(nskip)}}number of discarded candidates{p_end}
{synopt:{cmd:e(alpha)}}outlier percentage under normality{p_end}
{synopt:{cmd:e(cutoff)}}cutoff value for outlier identification{p_end}
{synopt:{cmd:e(Nout)}}number of observations classified as outliers{p_end}

{synoptset 20 tabbed}{...}
{p2col 7 20 24 2: Macros}{p_end}
{synopt:{cmd:e(method)}}{cmd:uniform}, {cmd:random} or {cmd:exact}{p_end}
{synopt:{cmd:e(asymmetric)}}{cmd:asymmetric} or empty{p_end}
{synopt:{cmd:e(xvars)}}names of main variables{p_end}
{synopt:{cmd:e(controls)}}names of control variables{p_end}
{synopt:{cmd:e(include)}}{cmd:include} or empty{p_end}
{synopt:{cmd:e(noee)}}{cmd:noee} or empty{p_end}
{synopt:{cmd:e(expand)}}{cmd:expand} or empty{p_end}
{synopt:{cmd:e(nostd)}}{cmd:nostd} or empty{p_end}
{synopt:{cmd:e(wftype)}}{cmd:huber} or {cmd:rectangle}{p_end}
{synopt:{cmd:e(nofit)}}{cmd:nofit} or empty{p_end}
{synopt:{cmd:e(generate)}}names of generated variables{p_end}

{pstd}
    If {cmd:robmv sd} is specified with option {cmd:nofit}, only a reduced set
    of results is stored.

{pstd}
    If the {cmd:svy} option is specified, various additional results as described in
    help {helpb svy} are stored.


{title:References}

{phang}
    Croux, C., G. Haesbroeck (1999). Influence Function
    and Efficiency of the Minimum Covariance Determinant Scatter Matrix
    Estimator. Journal of Multivariate Analysis 71: 161 190.

{phang}
    Hubert, M., P.J. Rousseeuw, D. Vanpaemel, T. Verdonck (2013). A deterministic algorithm
    for S-estimators and MM-estimators of multivariate location and scatter. KU Leuven. Available
    from {browse "http://wis.kuleuven.be/stat/robust/papers/2013/dets-technicalreport.pdf"}.

{phang}
    Lopuha{c a:}, H. P. (1989). On the Relation Between S-Estimators and
    M-Estimators of Multivariate Location and Covariance. The Annals of
    Statistics 17: 1662-1683.

{phang}
    Maronna, R.A., D.R. Martin, V.J. Yohai (2006). Robust Statistics.
    Theory and Methods. Chichester: John Wiley & Sons.

{phang}
    Maronna, R.A., V.J. Yohai (1995). The Behavior of the Stahel-Donoho Robust
    Multivariate Estimator. Journal of the American Statistical Association 90(429): 330-341.

{phang}
    Pison, G., S. Van Aelst, G. Willems (2002). Small sample corrections for
    LTS and MCD. Metrika 55: 111-123.

{phang}
    Rousseeuw, P.J., K. Van Driessen (1999). A Fast Algorithm for the
    Minimum Covariance Determinant Estimator. Technometrics 41(3): 212-223.

{phang}
    Salibian-Barrera, M., S. Van Aelst, G. Willems (2006). Principal Components Analysis
    Based on Multivariate MM Estimators With Fast and Robust Bootstrap. Journal of
    the American Statistical Association 101(475):1198-1211.

{phang}
    Verardi, V., C. Vermandele (2016). Outlier identification
    for skewed and/or heavy-tailed unimodal multivariate distributions. Journal de
    la Société Française de Statistique 157(2): 90-114.


{title:Author}

{pstd}
    Ben Jann (University of Bern),
    Vincenzo Verardi (University of Namur and Universite libre de Bruxelles),
    Catherine Vermandele (Universite libre de Bruxelles)

{pstd}
    Support: ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., V. Verardi, C. Vermandele  (2020). robmv: Stata module for robust
    multivariate estimation of location and covariance. Available from
    {browse "http://github.com/benjann/robmv/"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb correlate},
    {helpb robreg},
    {helpb robstat},
    {helpb robbox}

