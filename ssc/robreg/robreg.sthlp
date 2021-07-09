{smcl}
{* 26jan2010}{...}
{hi:help robreg}
{hline}

{title:Title}

{pstd}{hi:robreg} {hline 2} Robust regression


{title:Syntax}

{pstd}
MM-estimator

{p 8 15 2}
    {cmd:robreg mm} {depvar} {varlist} {ifin}
    [{cmd:,} {help robreg##mm_opt:{it:mm_options}} ]

{pstd}
M-estimator

{p 8 15 2}
    {cmd:robreg m} {depvar} [{varlist}] {ifin}
    [{cmd:,} {help robreg##m_opt:{it:m_options}} ]

{pstd}
S-estimator

{p 8 15 2}
    {cmd:robreg s} {depvar} {varlist} {ifin}
    [{cmd:,} {help robreg##s_opt:{it:s_options}} ]

{pstd}
LMS/LQS/LTS-estimator

{p 8 15 2}
    {cmd:robreg lms} {depvar} {varlist} {ifin}
    [{cmd:,} {help robreg##lqs_opt:{it:lqs_options}} ]
    {p_end}
{p 8 15 2}
    {cmd:robreg lqs} {depvar} {varlist} {ifin}
    [{cmd:,} {help robreg##lqs_opt:{it:lqs_options}} ]
    {p_end}
{p 8 15 2}
    {cmd:robreg lts} {depvar} {varlist} {ifin}
    [{cmd:,} {help robreg##lqs_opt:{it:lqs_options}} ]

{pstd}
Replay syntax

{p 8 15 2}
    {cmd:robreg} [{cmd:,} {opt l:evel(#)}
    ]


{synoptset 20 tabbed}{...}
{marker mm_opt}{col 5}{it:{help robreg##mm_options:mm_options}}{col 27}description
{synoptline}
{syntab :Main}
{synopt :{opt eff:iciency(#)}}gaussian efficiency;
    # in 70(5)95; default is {cmd:efficiency(85)}
    {p_end}
{synopt :{opt bp(#)}}breakdown point; {it:#} in .10(.05).50;
    default is {cmd:bp(0.5)}
    {p_end}

{syntab :Biweight M-estimate}
{synopt :{opt k(#)}}tuning constant; not allowed
    with {cmd:efficiency()}
    {p_end}
{synopt :{opt tol:erance(#)}}tolerance for IRWLS weights; default is
    {cmd:tolerance(1e-6)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations; default
    is {cmd:iterate(16000)}
    {p_end}
{synopt :{opt relax}}continue even if convergence not reached
    {p_end}
{synopt :{opth g:enerate(newvar)}}store IRWLS weights
    {p_end}
{synopt :{opt re:place}}overwrite existing variable
    {p_end}

{syntab :Initial S-estimate}
{synopt :{opt n:samp(#)}}number of trial samples
    {p_end}
{synopt :{cmdab:s:opts(}{help robreg##s_opt:{it:s_options}}{cmd:)}}additional
    options passed through to S-algorithm
    {p_end}
{synopt :{opt save(name)}}save S-estimate
    {p_end}

{syntab :Standard errors}
{synopt :{cmd:vce(}{cmdab:nor:obust}{cmd:)}}traditional standard errors
    {p_end}
{synopt :{opt nor:obust}}synonym for {cmd:vce(norobust)}
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt first}}display initial S-estimate
    {p_end}
{synopt :{opt nodot:s}}suppress progress dots of S-estimate
    {p_end}
{synopt :{opt lo:g}}display RWLS iteration log
    {p_end}
{synoptline}


{synoptset 20 tabbed}{...}
{marker m_opt}{col 5}{it:{help robreg##m_options:m_options}}{col 27}description
{synoptline}
{syntab :Main}
{synopt :{opt h:uber}}use Huber objective function; the default
    {p_end}
{synopt :{opt bi:weight}}use biweight objective function; {opt bis:quare}
    is a synonym
    {p_end}
{synopt :{opt eff:iciency(#)}}gaussian efficiency;
    # in 70(5)95; default is {cmd:efficiency(95)}
    {p_end}
{synopt :{opt k(#)}}tuning constant; not allowed
    with {cmd:efficiency()}
    {p_end}

{syntab :IRWLS algorithm}
{synopt :{opt tol:erance(#)}}tolerance for IRWLS weights; default is
    {cmd:tolerance(1e-6)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations; default
    is {cmd:iterate(16000)}
    {p_end}
{synopt :{opt relax}}continue even if convergence not reached
    {p_end}
{synopt :{opth g:enerate(newvar)}}store IRWLS weights
    {p_end}
{synopt :{opt re:place}}overwrite existing variable
    {p_end}

{syntab :Initial estimate}
{synopt :{opt init(arg)}}initial estimate; {it:arg} may be {cmd:lav},
    {cmd:ols}, {it:name}, or {cmd:.}; default is {cmd:init(lav)}
    {p_end}
{synopt :{opt save(name)}}save initial estimate
    {p_end}

{syntab :Scale estimate}
{synopt :{opt s:cale(#)}}provide preliminary scale estimate
    {p_end}
{synopt :{opt update:scale}}update scale estimate in each iteration
    {p_end}
{synopt :{opt cen:ter}}center residuals when computing scale
    {p_end}

{syntab :Standard errors}
{synopt :{cmd:vce(}{cmdab:nor:obust}{cmd:)}}traditional standard errors
    {p_end}
{synopt :{cmd:vce(}{cmd:pv}{cmd:)}}traditional standard errors using
    pseudo-values approach
    {p_end}
{synopt :{opt nor:obust}}synonym for {cmd:vce(norobust)}
    {p_end}
{synopt :{opt nose}}skip computation of standard errors
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt first}}display initial estimate
    {p_end}
{synopt :{opt lo:g}}display RWLS iteration log
    {p_end}
{synoptline}


{synoptset 20 tabbed}{...}
{marker s_opt}{col 5}{it:{help robreg##s_options:s_options}}{col 27}description
{synoptline}
{syntab :Main}
{synopt :{opt bp(#)}}breakdown point; {it:#} in .10(.05).50;
    default is {cmd:bp(0.5)}
    {p_end}
{synopt :{opt k(#)}}tuning constant; not allowed
    with {cmd:bp()}
    {p_end}

{syntab :Resampling algorithm}
{synopt :{opt n:samp(#)}}number of trial samples
    {p_end}
{synopt :{opt alpha(#)}}maximum risk of bad solution; default is
    {cmd:alpha(0.01)}
    {p_end}
{synopt :{opt eps:ilon(#)}}maximum contamination fraction; default
    is {cmd:epsilon(0.2)}
    {p_end}
{synopt :{opt nk:eep(#)}}number of candidates to keep; default
    is {cmd:nkeep(2)}
    {p_end}
{synopt :{opt rstep:s(#)}}number of local improvement steps; default
    is {cmd:rsteps(1)}
    {p_end}
{synopt :{opt stol:erance(#)}}tolerance for scale estimate; default is
    {cmd:stolerance(1e-6)}
    {p_end}
{synopt :{opt siter:ate(#)}}maximum number of iterations for scale
    estimate; default is {cmd:siterate(16000)}
    {p_end}
{synopt :{opt tol:erance(#)}}tolerance for coefficient vector; default is
    {cmd:tolerance(1e-6)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of RWLS iterations; default
    is {cmd:iterate(16000)}
    {p_end}
{synopt :{opt sstep:s(#)}}number of scale approximation steps; default
    is {cmd:ssteps(1)}
    {p_end}
{synopt :{opth g:enerate(newvar)}}store IRWLS weights
    {p_end}
{synopt :{opt re:place}}overwrite existing variable
    {p_end}

{syntab :Standard errors}
{synopt :{cmd:vce(}{cmdab:nor:obust}{cmd:)}}traditional standard errors
    {p_end}
{synopt :{opt nor:obust}}synonym for {cmd:vce(norobust)}
    {p_end}
{synopt :{opt nose}}skip computation of standard errors
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt nodot:s}}suppress progress dots
    {p_end}
{synoptline}


{synoptset 20 tabbed}{...}
{marker lqs_opt}{col 5}{it:{help robreg##lqs_options:lqs_options}}{col 27}description
{synoptline}
{syntab :Main}
{p2coldent :* {opt bp(#)}}breakdown point; {it:#} in (0,0.5]; default is {cmd:bp(0.5)}
    {p_end}

{syntab :Resampling algorithm}
{synopt :{opt n:samp(#)}}number of trial samples
    {p_end}
{synopt :{opt alpha(#)}}maximum risk of bad solution; default is
    {cmd:alpha(0.01)}
    {p_end}
{synopt :{opt eps:ilon(#)}}maximum contamination fraction; default
    is {cmd:epsilon(0.2)}.
    {p_end}
{synopt :{opth g:enerate(newvar)}}store minimizing sample
    {p_end}
{synopt :{opt re:place}}overwrite existing variable
    {p_end}

{syntab :Reporting}
{synopt :{opt nodot:s}}suppress progress dots
    {p_end}
{synoptline}
{p 4 6 2}* {opt bp()} is not allowed with {cmd:robreg lms}{p_end}


{title:Description}

{pstd}
    {cmd:robreg} provides a number of robust estimators for linear
    regression models. The command accompanies Jann (2010), a survey paper
    on robust regression in a German handbook on social science data
    analysis.

{pstd}
    {cmd:robreg mm} fits the efficient high breakdown MM-estimator proposed
    by Yohai (1987). On the first stage, a high breakdown S-estimator is
    applied to estimate the residual scale and derive starting values for
    the coefficients vector. On the second stage, an efficient bisquare
    M-estimator is applied to obtain the final coefficient estimates.

{pstd}
    {cmd:robreg m} fits regression M-estimators (Huber 1973) using
    iteratively reweighted least squares (IRWLS).

{pstd}
    {cmd:robreg s} fits the high breakdown S-estimator introduced by Rousseeuw and Yohai
    (1984) using the fast algorithm proposed by Salibian-Barrera and Yohai
    (2006).

{pstd}
    {cmd:robreg lms}, {cmd:robreg lqs}, and {cmd:robreg lts} fit the least
    median of squares (LMS), least quantile of squares (LQS; a
    generalization of LMS), and the least trimmed squares (LTS) estimators
    (Rousseeuw and Leroy 1987). Estimation is carried out using simple
    resampling without local improvement (e.g. Rousseeuw and Leroy
    1987:197). Computation of standard errors is not supported for LMS,
    LQS, and LTS.

{pstd}
    For a recent contribution of similar estimators in Stata also see
    Verardi and Croux (2009).


{title:Dependencies}

{pstd}
    {cmd:robreg} requires {cmd:moremata}. See
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}.

{marker mm_options}
{title:Options for robreg mm}

{dlgtab:Main}

{phang}
    {opt efficiency(#)} sets the gaussian efficiency of the MM-estimator
    (i.e. the asymptotic relative efficiency compared to the OLS or ML
    estimator in case of i.i.d. normal errors). The efficiency is
    determined by appropriate choice of the tuning constant for the
    bisquare M-estimator in the second stage of the MM-algorithm. {it:#}
    may be a number between 70 and 95 in steps of 5. The default for the
    MM-estimator is {cmd:efficiency(85)}, as suggested by Maronna et al.
    (2006: 144).

{phang}
    {opt bp(#)} sets the breakdown point of the MM-Estimator. The breakdown
    point is determined by appropriate choice of the tuning constant for
    the S-estimator in the first stage of the MM-algorithm. {it:#} may be a
    number between 0.1 and 0.5 in steps of 0.05. The default is
    {cmd:bp(0.5)}.

{dlgtab:Biweight M-estimate}

{phang}
    {opt k(#)} specifies the tuning constant for the bisquare M-estimator
    in the second stage of the MM-algorithm. {cmd:k()} not allowed if
    {cmd:efficiency()} is specified.

{phang}
    {opt tolerance(#)} specifies the tolerance for the weights of the IRWLS
    algorithm used to fit the bisquare M-estimator. When the maximum
    absolute change in the weights from one iteration to the next is less
    than or equal to {cmd:tolerance()}, the convergence criterion is
    satisfied. The default is {cmd:tolerance(1e-6)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the
    IRWLS algorithm used to fit the bisquare M-estimator. If convergence is
    not reached within {cmd:iterate()} iterations, the algorithm stops and
    returns error. The default is {cmd:iterate(16000)} or as set by
    {helpb set maxiter}.

{phang}
    {opt relax} causes the IRWLS algorithm to return the current results
    instead of returning error if convergence is not reached.

{phang}
    {opth generate(newvar)} stores the final weights of the IRWLS algorithm
    in variable {it:newvar}.

{phang}
    {opt replace} permits {cmd:robreg} to overwrite existing variables.

{dlgtab:Initial S-estimate}

{phang}
    {opt nsamp(#)} specifies the number of trial samples for the search
    algorithm of the S-estimator in the first stage of the MM-algorithm. The
    default value is determined according to formula

            ceil(ln(alpha) / ln(1 - (1 - epsilon)^p))

{pmore}
    within a range of 50 to 10000, where p is the number of coefficients in
    the model and alpha = 0.01 and epsilon = 0.2 (see Salibian-Barrera and
    Yohai 2006 for a justification of the formula). The default values for
    alpha and epsilon can be changed via {cmd:sopts()} (see below).

{phang}
    {cmd:sopts(}{help robreg##s_opt:{it:s_options}}{cmd:)} specified
    additional options to be passed through to the S-estimator. See the
    section on {help robreg##s_options:options for {bf:robreg s}}.

{phang}
    {opt save(name)} saves the results of the S-estimator under {it:name}
    using {helpb estimates store}.

{dlgtab:Standard errors}

{phang}
    {cmd:vce(norobust)} causes standard errors to be computed
    using traditional formulas assuming constant error variance. The default
    is to compute robust standard errors as suggested by Croux et al
    (2003; using formula Avar_1; the traditional formula is equivalent to
    Avar_2s).

{phang}
    {opt norobust} is a synonym for {cmd:vce(norobust)}


{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the level for confidence intervals. The
    default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
    {opt first} causes the first stage S-estimate to be displayed.

{phang}
    {opt nodots} suppresses the progress dots of the S-estimator
    search algorithm.

{phang}{opt log} displays the iteration log of the second stage IRWLS
    algorithm.

{marker m_options}
{title:Options for robreg m}

{dlgtab:Main}

{phang}
    {opt huber} causes the Huber objective function to be used
    (monotone M-estimator). This is the default.

{phang}
    {opt biweight} causes the biweight or bisquare objective function to be
    used (redescending M-estimator). {cmd:bisquare} is a synonym for
    {cmd:biweight}. The solution of a redescending M-estimator may depend on
    the starting values.

{phang}
    {opt efficiency(#)} sets the gaussian efficiency (i.e. the asymptotic
    relative efficiency compared to the OLS or ML estimator in case of
    i.i.d. normal errors) by appropriate choice of the tuning constant.
    {it:#} may be a number between 70 and 95 in steps of 5. The default is
    {cmd:efficiency(95)}.

{phang}
    {opt k(#)} specifies the tuning constant. {cmd:k()} not allowed if
    {cmd:efficiency()} is specified.

{dlgtab:IRWLS algorithm}

{phang}
    {opt tolerance(#)} specifies the tolerance for the weights of the IRWLS
    algorithm. When the maximum absolute change in the weights from one
    iteration to the next is less than or equal to {cmd:tolerance()}, the
    convergence criterion is satisfied. The default is
    {cmd:tolerance(1e-6)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the
    IRWLS algorithm. If convergence is not reached within {cmd:iterate()}
    iterations, the algorithm stops and returns error. The default is
    {cmd:iterate(16000)} or as set by {helpb set maxiter}.

{phang}
    {opt relax} causes the IRWLS algorithm to return the current results
    instead of returning error if convergence is not reached. For example,
    to fit a one-step M-estimate specify {cmd:relax} together with
    {cmd:iterate(1)}.

{phang}
    {opth generate(newvar)} stores the final weights of the IRWLS algorithm
    in variable {it:newvar}.

{phang}
    {opt replace} permits {cmd:robreg} to overwrite existing variables.

{dlgtab:Initial estimate}

{phang}
    {opt init(arg)} determines the choice of the initial estimate that
    provides the starting values for the IRWLS algorithm. {it:arg} may be
    {cmd:lav} for the LAV-estimator (a.k.a. median regression; fitted
    using {helpb qreg}), {cmd:ols} for the least squares estimator (fitted
    using {helpb regress}), {it:name} for an estimation set stored under
    {it:name}, or {cmd:.} for the currently active estimation results. The
    default is {cmd:init(lav)}.

{phang}
    {opt save(name)} saves initial {cmd:lav} or {cmd:ols} estimate under
    {it:name} using {helpb estimates store}.

{dlgtab:Scale estimate}

{phang}
    {opt scale(#)} provides a preliminary value for the residual scale that
    will be held constant. The default is to use the normalized median of
    the (N - number of coefficients) largest absolute residuals from the
    initial fit as an estimate of the residual scale (MADN).

{phang}
    {opt updatescale} causes the MADN scale estimate to be updated in each
    iteration of the IRWLS algorithm. {cmd:updatescale} has no effect if
    {cmd:scale()} is specified.

{phang}
    {opt center} causes the MADN scale estimate to be computed based on
    median centered residuals. {cmd:center} has no effect if
    {cmd:scale()} is specified.

{dlgtab:Standard errors}

{phang}
    {cmd:vce(norobust)} causes standard errors to be computed
    using traditional formulas assuming constant error variance. The
    default is to compute robust standard errors as suggested by Croux et
    al (2003; using formula Avar_1s; the traditional formula is equivalent
    to Avar_2s).

{phang}
    {cmd:vce(pv)} causes traditional standard errors to be computed
    using the pseudo-values approach (Street et al. 1988). {cmd:vce(pv)} is
    equivalent to {cmd:vce(norobust)} but includes some small sample
    correction.

{phang}
    {opt norobust} is a synonym for {cmd:vce(norobust)}

{phang}
    {opt nose} skips the computation of standard errors.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the level for confidence intervals. The
    default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
    {opt first} causes the initial estimate to be displayed.

{phang}{opt log} displays the iteration log of the second stage IRWLS
    algorithm.

{marker s_options}
{title:Options for robreg s}

{dlgtab:Main}

{phang}
    {opt bp(#)} sets the breakdown point by appropriate choice of the
    tuning constant (this also determines the gaussian efficiency). {it:#}
    may be a number between 0.1 and 0.5 in steps of 0.05. The default is
    {cmd:bp(0.5)}.

{phang}
    {opt k(#)} specifies the tuning constant. {cmd:k()} not allowed if
    {cmd:bp()} is specified.

{dlgtab:Resampling algorithm}

{phang}
    {opt nsamp(#)} specifies the number of trial samples for the search
    algorithm. The default value is determined according to formula

            ceil(ln(alpha) / ln(1 - (1 - epsilon)^p))

{pmore}
    within a range of 50 to 10000, where p is the number of coefficients in
    the model and alpha and epsilon are set by {cmd:alpha()} and
    {cmd:epsilon()} (see Salibian-Barrera and Yohai 2006 for a
    justification of the formula).

{phang}
    {opt alpha(#)} specifies the maximum admissible risk of drawing a set
    of samples of which none is free of outliers. This is a parameter in
    the formula for the computation of the required number samples (see
    above). The default is {cmd:alpha(0.01)} (i.e. 1 percent).
    {cmd:alpha()} has no effect if {cmd:nsamp()} is specified.

{phang}
    {opt epsilon(#)} specifies the assumed maximum fraction of contaminated
    data.  This is a parameter in the formula for the computation of the
    required number samples (see above). The default is {cmd:epsilon(0.2)}
    (i.e. 20 percent). {cmd:epsilon()} has no effect if {cmd:nsamp()} is
    specified.

{phang}
    {opt nkeep(#)} specifies the number of best candidates to be
    kept for final refinement. The default is {cmd:nkeep(2)}.

{phang}
    {opt rsteps(#)} specifies the number of local improvement steps
    applied to the candidates. The default is {cmd:rsteps(1)}.

{phang}
    {opt stolerance(#)} specifies the tolerance for the scale estimate of
    the candidates. When the absolute relative change in the scale from one
    iteration to the next is less than or equal to {cmd:stolerance()}, the
    convergence criterion is satisfied. The default is
    {cmd:stolerance(1e-6)}.

{phang}
    {opt siterate(#)} specifies the maximum number of iterations for the
    scale estimate of the candidates. If convergence is not reached within
    {cmd:siterate()} iterations, the algorithm stops and returns error.
    The default is {cmd:siterate(16000)} or as set by {helpb set maxiter}.

{phang}
    {opt tolerance(#)} specifies the tolerance for the coefficients in the
    refinement IRWLS algorithm. When the maximum relative change in the
    coefficient vector from one iteration to the next is less than or equal
    to {cmd:tolerance()}, the convergence criterion is satisfied. The
    default is {cmd:tolerance(1e-6)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the
    refinement IRWLS algorithm. If convergence is not reached within
    {cmd:iterate()} iterations, the algorithm stops and returns error. The
    default is {cmd:iterate(16000)} or as set by {helpb set maxiter}.

{phang}
    {opt ssteps(#)} specifies the number of approximation steps for the
    scale estimate within each RWLS iteration. The default is
    {cmd:ssteps(1)}.

{phang}
    {opth generate(newvar)} stores the final IRWLS weights from the best
    solution in variable {it:newvar}.

{phang}
    {opt replace} permits {cmd:robreg} to overwrite existing variables.

{dlgtab:Standard errors}

{phang}
    {cmd:vce(norobust)} causes standard errors to be computed using
    traditional formulas assuming constant error variance. The default is
    to compute robust standard errors as suggested by Croux et al (2003;
    using formula Avar_1; the traditional formula is equivalent to Avar_2s).

{phang}
    {opt norobust} is a synonym for {cmd:vce(norobust)}

{phang}
    {opt nose} skips the computation of standard errors.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the level for confidence intervals. The
    default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
    {opt nodots} suppresses the progress dots of the search algorithm.


{marker lqs_options}
{title:Options for robreg lms/lqs/lts}

{dlgtab:Main}

{phang}
    {opt bp(#)} sets the breakdown point, where # may be in (0,0.5]. {cmd:bp()}
    determines the h parameter for the LQS and LTS estimators as follows:

            h = floor((1-{cmd:bp()})*N) + floor({cmd:bp()}*(p + 1))

{pmore}
    where N is the sample size and p is the number of coefficients. The
    default is {cmd:bp(0.5)}. {cmd:bp()} is not allowed with
    {cmd:robreg lms}.

{dlgtab:Resampling algorithm}

{phang}
    {opt nsamp(#)} specifies the number of trial samples for the search
    algorithm. The default value is determined according to formula

            ceil(ln(alpha) / ln(1 - (1 - epsilon)^p))

{pmore}
    within a range of 500 to 10000, where p is the number of coefficients
    in the model and alpha and epsilon are set by {cmd:alpha()} and
    {cmd:epsilon()}.

{phang}
    {opt alpha(#)} specifies the maximum admissible risk of drawing a set
    of samples of which none is free of outliers. This is a parameter in
    the formula for the computation of the required number samples (see
    above). The default is {cmd:alpha(0.01)} (i.e. 1 percent).
    {cmd:alpha()} has no effect if {cmd:nsamp()} is specified.

{phang}
    {opt epsilon(#)} specifies the assumed maximum fraction of contaminated
    data.  This is a parameter in the formula for the computation of the
    required number samples (see above). The default is {cmd:epsilon(0.2)}
    (i.e. 20 percent). {cmd:epsilon()} has no effect if {cmd:nsamp()} is
    specified.

{phang}
    {opth generate(newvar)} stores a variable {it:newvar} that marks the
    minimizing trial sample.

{phang}
    {opt replace} permits {cmd:robreg} to overwrite existing variables.

{dlgtab:Reporting}

{phang}
    {opt nodots} suppresses the progress dots of the search algorithm.


{title:Examples}

        {com}. sysuse auto

        . robreg mm price mpg weight headroom foreign

        . robreg m price mpg weight headroom foreign

        . robreg m price mpg weight headroom foreign, biweight

        . robreg s price mpg weight headroom foreign

        . robreg lqs price mpg weight headroom foreign

        . robreg lts price mpg weight headroom foreign
        {txt}

{title:Saved results}

{pstd}
    {cmd:robreg} saves its results in {cmd:e()}. Type
    {helpb ereturn list} to list the results after estimation.


{title:References}

{phang}
    Croux, C., G. Dhaene, D. Hoorelbeke (2003). Robust Standard Errors for
    Robust Estimators. Discussions Paper Series (DPS) 03.16. Center for
    Economic Studies.

{phang}
    Huber, P. J. (1973). Robust Regression: Asymptotics, Conjectures and
    Monte Carlo. The Annals of Statistics 1: 799-821.

{phang}
    Jann, B. (2010). Robuste Regression. In: Henning Best, Christof Wolf
    (eds.). Handbuch der sozialwissenschaftlichen
    Datenanalyse. Wiesbaden: VS-Verlag.

{phang}
    Salibian-Barrera, M., V. J. Yohai (2006). A Fast Algorithm for
    S-Regression Estimates. Journal of Computational and Graphical
    Statistics 15: 414-427.

{phang}
    Street, J. O., R. J. Carroll, D. Ruppert (1988). A Note on Computing
    Robust Regression Estimates Via Iteratively Reweighted Least
    Squares. The American Statistician 42: 152-154.

{phang}
    Rousseeuw, P., V. Yohai (1984). Robust Regression by Means of
    S-Estimators. Pp. 256-272 in: Jürgen Franke, Wolfgang Hardle, and
    Douglas Martin (eds.). Robust and Nonlinear Time Series Analysis.
    Lecture Notes in Statistics Vol. 26. Berlin: Springer.

{phang}
    Yohai, V. J. (1987). High Breakdown-Point and High Efficiency Robust
    Estimates for Regression. The Annals of Statistics 15: 642-656.

{phang}
    Verardi, V., C. Croux (2009). Robust regression in Stata. The Stata
    Journal 9: 439-453.


{title:Author}

{pstd}
    Ben Jann, ETH Zurich, jannb@ethz.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2010). robreg: Stata module providing robust regression 
    estimators. Available from http://ideas.repec.org/c/boc/bocode/s457114.html.


{title:Also see}

{psee}
    Online:  help for
    {helpb regress},
    {helpb rreg},
    {helpb qreg}
