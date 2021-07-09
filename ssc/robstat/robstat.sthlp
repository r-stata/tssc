{smcl}
{* 21feb2019}{...}
{hi:help robstat}
{hline}

{title:Title}

{pstd}{hi:robstat} {hline 2} Robust univariate statistics


{title:Syntax}

{p 8 15 2}
    {cmd:robstat} {varlist} {ifin} {weight}
    [{cmd:,}
    {help robstat##opts:{it:options}}
    ]


{synoptset 22 tabbed}{...}
{marker opts}{col 5}{help robstat##options:{it:options}}{col 29}Description
{synoptline}
{syntab :Main}
{synopt :{cmdab:s:tatistics(}{help robstat##stats:{it:stats}}{cmd:)}}statistics
    to be computed; default is {cmd:statistics(mean)}
    {p_end}
{synopt :{opth over(varname)}}compute results for subpopulations defined by
    the values of {it:varname}
    {p_end}
{synopt :{opt t:otal}}include overall results across all subpopulations; only
    allowed with {cmd:over()}
    {p_end}
{synopt :{opt swap}}swap coefficients and equations
    {p_end}

{syntab :SE/SVY}
{synopt :{cmd:vce(}{help robstat##vcetype:{it:vcetype}}{cmd:)}}{it:vcetype} may
    be {cmd:analytic} (the default), {cmdab:cl:uster} {it:clustvar},
    {cmdab:boot:strap} or {cmdab:jack:knife}
    {p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for
    {cmd:vce(cluster} {it:clustvar}{cmd:)}
    {p_end}
{synopt :{cmd:svy}[{cmd:(}{help robstat##svy:{it:subpop}}{cmd:)}]}take account
    of survey design as set by {helpb svyset}, optionally restricting
    computations to {it:subpop}
    {p_end}
{synopt :{opt nose}}supress computation of standard errors and confidence
    intervals
    {p_end}
{synopt :{opt gen:erate}[{cmd:(}{it:prefix}{cmd:)}]}stores the values of the
    influence functions
    {p_end}
{synopt :{opt replace}}allows overwriting existing variables
    {p_end}

{syntab :Normality tests}
{synopt :{cmdab:jb:test}[{cmd:(}{help robstat##tests:{it:tests}}{cmd:)}]}compute
    generalized Jarque-Bera tests for normality
    {p_end}
{synopt :{opt wald}}employ Wald tests based on the estimated variance-covariance
    matrix
    {p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt cil:og}}use log-transformed confidence intervals for scale statistics
    {p_end}
{synopt :{opt nohe:ader}}suppress output header
    {p_end}
{synopt :{opt notab:le}}suppress output table
    {p_end}
{synopt :{help robstat##displayopts:{it:display_options}}}standard
    reporting options as described in
    {helpb estimation options:[R] estimation options}
    {p_end}

{syntab :Technical options}
{synopt :{opt tol:erance(#)}}tolerance for the M estimates; default is
    {cmd:tolerance(1e-10)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations for the M estimates; default
    is {cmd:iterate(16000)} or as set by {helpb set maxiter}
    {p_end}
{synopt :{opt k:ernel(kernel)}}type of kernel function for density estimation;
    default is {cmd:kernel(epan2)}
    {p_end}
{synopt :{opt bw(type)}}type of bandwidth selector for density estimation; default
    is {cmd:bw(dpi)}
    {p_end}
{synopt :{opt a:daptive(#)}}number of repetitions for adaptive density
    estimation; default is {cmd:adaptive(2)}
   {p_end}
{synopt :{opt n(#)}}number of evaluation points for density estimation; default
    is {cmd:n(512)}
    {p_end}
{synoptline}
{p 4 6 2}
{opt pweight}s, {opt iweight}s, and {opt fweight}s are allowed; see {help weight}.


{title:Description}

{pstd}
    {cmd:robstat} estimates various classic and robust measures of location, scale,
    skewness, and kurtosis, and, optionally, performs robust tests for normality. For
    methodological details see Jann, Verardi and Vermandele (forthcoming).

{pstd}
    {cmd:robstat} without {it:varlist} replays the previous results. Reporting
    options may be applied.

{pstd}
    {cmd:robstat} requires {cmd:moremata} and {cmd:kdens}. See
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}
    and
    {net "describe kdens, from(http://fmwww.bc.edu/repec/bocode/k/)":ssc describe kdens}.

{marker options}{...}
{title:Options}

{dlgtab:Main}

{marker stats}{...}
{phang}
    {opt statistics(stats)} specifies the statistics to be computed. {cmd:statistics()}
    is not allowed if the {cmd:jbtest} option is specified (see below). {it:stats}
    is a space-separated list of the following statistics (we use upper case
    letters in some of the statistics for purpose of clarity, but note that
    {it:stats} is not case sensitive). Default is {cmd:statistics(mean)}.

{p2colset 13 25 27 2}{...}
{p2col 11 25 27 2:Location}{p_end}
{p2col :{opt m:ean}}arithmetic mean
    {p_end}
{p2col :{cmdab:a:lpha}[{it:#}]}alpha-trimmed mean, where {it:#} specifies the
    trimming percentage; default is {cmd:alpha5}
    {p_end}
{p2col :{opt med:ian}}median
    {p_end}
{p2col :{opt HL}}Hodges-Lehmann estimator (Hodges and Lehmann 1963)
    {p_end}
{p2col :{cmdab:H:uber}[{it:#}]}Huber M estimate of location, where {it:#}
    specifies the desired gaussian efficiency; default is {cmd:Huber95}
    {p_end}
{p2col :{cmdab:bi:weight}[{it:#}]}biweight M estimate of location, where {it:#}
    specifies the desired gaussian efficiency; default is {cmd:biweight95}
    {p_end}

{p2col 11 25 27 2:Scale}{p_end}
{p2col :{opt sd}}standard deviation
    {p_end}
{p2col :{opt IQR}}interquartile range
    {p_end}
{p2col :{opt IQRc}}rescaled interquartile range
    {p_end}
{p2col :{opt MAD}}median absolute deviation
    {p_end}
{p2col :{opt MADN}}rescaled median absolute deviation
    {p_end}
{p2col :{opt Q:n}}Qn coefficient (Rousseeuw and Croux 1993)
    {p_end}
{p2col :{cmd:S}[{it:#}]}M estimate of scale, where {it:#}
    specifies the desired breakdown point; default is {cmd:S50}
    {p_end}

{p2col 11 25 27 2:Skewness}{p_end}
{p2col :{opt ske:wness}}classic skewness measure (Fisher coefficient)
    {p_end}
{p2col :{cmd:SK}[{it:#}]}Hinkley (1975) skewness measure, where {it:#}
    specifies the desired percentage; default is {cmd:SK25}, which is
    equal to the Yule and Kendall (1968) skewness measure
    {p_end}
{p2col :{opt MC}}medcouple (Brys et al. 2004)
    {p_end}

{p2col 11 25 27 2:Kurtosis}{p_end}
{p2col :{opt k:urtosis}}classic kurtosis measure
    {p_end}
{p2col :{cmd:QW}[{it:#}]}quantile tail weight measure, where {it:#}
    specifies the desired percentage; default is {cmd:QW25}
    {p_end}
{p2col :{cmd:LQW}[{it:#}]}left quantile tail weight measure, where {it:#}
    specifies the desired percentage; default is {cmd:LQW25}
    {p_end}
{p2col :{cmd:RQW}[{it:#}]}right quantile tail weight measure, where {it:#}
    specifies the desired percentage; default is {cmd:RQW25}
    {p_end}
{p2col :{opt LMC}}left medcouple tail weight measure (Brys et al. 2006)
    {p_end}
{p2col :{opt RMC}}right medcouple tail weight measure (Brys et al. 2006)
    {p_end}

{phang}
    {opth over(varname)} reports results for each subpopulation defined by the
    values of {it:varname}.

{phang}
    {opt total} causes additional overall results across all subpopulations to
    be reported. {cmd:total} is only allowed if {cmd:over()} is specified.

{phang}
    {opt swap} affects the layout of the results. Depending on
    specified options, {cmd:robstat} groups results into several
    "equations". Specify {cmd:swap} in such a case
    if you want to flip equations and coefficients.

{dlgtab:SE/SVY}

{marker vcetype}{...}
{phang}
    {opth vce(vcetype)} determines how standard errors and confidence intervals
    are computed. {it:vcetype} may be:

            {cmd:analytic}
            {cmd:cluster} {it:clustvar}
            {cmd:bootstrap} [{cmd:,} {help bootstrap:{it:bootstrap_options}}]
            {cmd:jackknife} [{cmd:,} {help jackknife:{it:jackknife_options}}]

{pmore}
    The default is {cmd:vce(analytic)}, using approximate formulas for variance
    estimation (based on influence functions) assuming independent data. For
    clustered data, specify {cmd:vce(cluster} {it:clustvar}{cmd:)}, where
    {it:clustvar} is the variable identifying the clusters. For bootstrap and
    jackknife estimation, see help {it:{help vce_option}}. Variance estimation
    is not supported if {cmd:iweights} or {cmd:fweights} are specified.

{phang}
    {opt cluster(clustvar)} is a synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}.

{marker svy}{...}
{phang}
    {cmd:svy}[{cmd:(}{it:subpop}{cmd:)}] causes the survey design to be taken
    into account for variance estimation. The data need to be set up for survey
    estimation; see help {helpb svyset}. Specify {it:subpop} to restrict survey
    estimation to a subpopulation, where {it:subpop} is

            [{varname}] [{it:{help if}}]

{pmore}
    The subpopulation is defined by observations for which {it:varname}!=0 and
    for which the {cmd:if} condition is met. See help {helpb svy} and
    {manlink SVY subpopulation estimation} for more information on subpopulation
    estimation.

{pmore}
    The {cmd:svy} option of {cmd:robstat} only works if the variance
    estimation method is set to Taylor linearization by {helpb svyset} (the
    default). For other variance estimation methods you can use the usual {helpb svy}
    prefix command. For example, you could type {cmd:svy brr: robstat ...} to
    use BRR variance estimation. {cmd:robstat} does not allow the {helpb svy}
    prefix for Taylor linearization due to technical reasons. This is why the
    {cmd:svy} option is provided.

{phang}
    {opt nose} suppresses the computation of standard errors and confidence
    intervals. The {cmd:nose} option may be useful to speed-up computations with
    prefix commands that use replication techniques for variance estimation,
    such as, e.g., {helpb svy jackknife}. Options {cmd:vce(bootstrap)} and
    {cmd:vce(jackknife)} imply {cmd:nose}.

{phang}
    {opt generate}[{cmd:(}{it:prefix}{cmd:)}] stores the values of the
    influence functions used for the computation of standard errors and
    confidence intervals. One influence function variable is stored for each
    statistic per outcome variable in each over-group. The variable names
    are prefixed by {it:prefix}, where the default prefix is "{cmd:_IF_}".
    {cmd:generate()} has no effect if {cmd:nose}, {cmd:vce(bootstrap)},
    or {cmd:vce(jackknife)} is specified.

{phang}
    {opt replace} allows overwriting existing variables. This is only relevant
    if {cmd:generate()} has been specified.

{dlgtab:Normality tests}

{marker tests}{...}
{phang}
    {cmd:jbtest}[{cmd:(}{it:tests}{cmd:)}] computes generalized Jarque-Bera tests
    for normality as suggested by Brys et al. (2008). The {cmd:statistics()}
    option (see above) is not allowed if {cmd:jbtest} is specified. {it:tests}
    is a space-separated list of the following tests.

{p2colset 13 32 34 2}{...}
{p2col 11 25 27 2:Test{space 6}Synonym}{p_end}
{p2col :{opt JB}{space 8}{opt jb:era}}classic Jarque-Bera skewness and kurtosis test
    {p_end}
{p2col :{opt MOORS}{space 5}{opt moors}}robust skewness and tail-weight test based on {cmd:SK25} and {cmd:QW25}
    {p_end}
{p2col :{opt MC-LR}{space 5}{opt mclr}}robust skewness and tail-weight test based on {cmd:MC}, {cmd:LMC} and {cmd:RMC}
    {p_end}
{p2col :{opt MC-L}{space 6}{opt mcl}}robust skewness and left tail-weight test based on {cmd:MC} and {cmd:LMC}
    {p_end}
{p2col :{opt MC-R}{space 6}{opt mcr}}robust skewness and right tail-weight kurtosis test based on {cmd:MC} and {cmd:RMC}
    {p_end}
{p2col :{opt MC}{space 8}{opt mc}}robust skewness test based on {cmd:MC}
    {p_end}
{p2col :{opt LR}{space 8}{opt lr}}robust tail-weight test based on {cmd:LMC} and {cmd:RMC}
    {p_end}
{p2col :{opt L:MC}{space 7}{opt l:mc}}robust left tail-weight test based on {cmd:LMC}
    {p_end}
{p2col :{opt R:MC}{space 7}{opt r:mc}}robust right tail-weight test based on {cmd:RMC}
    {p_end}

{pmore}
    Specifying option {cmd:jbtest} without argument is equivalent to
    {cmd:jbtest(jbera moors mclr)}. Furthermore, {cmd:jbtest(all)} reports all
    available tests.

{phang}
    {opt wald} specifies that the normality tests are to be based on the
    estimated variance-covariance matrix of the involved skewness and kurtosis
    or tail-weight parameters. The default is to base the tests on the
    theoretical variance for normally distributed data. Specifying the
    {cmd:svy} option, a {it:vcetype} other than {cmd:analytic}, or weights
    other than {cmd:fweight}s implies {cmd:wald}. {cmd:wald} is not allowed
    with {cmd:fweight}s.

{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt cilog} causes log-transformed confidence intervals to be used for scale
    statistics. This ensures that the confidence intervals do not include
    zero. Log-transformed confidence intervals are computed as

            exp(ln({it:S}) +/- z * SE/{it:S})

{pmore}
    where {it:S} is estimated the scale statistic, z is the critical value for the given
    confidence level, and SE is the standard error of {it:S}.

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

{dlgtab:Technical options}

{phang}
    {opt tolerance(#)} specifies the tolerance for the M estimates. The default
    is {cmd:tolerance(1e-10)}.

{phang}
    {opt iterate(#)} specifies the maximum number of iterations for the M
    estimates. If convergence is not reached within {cmd:iterate()} iterations,
    the algorithm stops and returns error. The default is {cmd:iterate(16000)}
    or as set by {helpb set maxiter}.

{phang}
    {opt kernel(kernel)} specifies the kernel function for density estimation
    (computation of standard errors involves density estimation for some of
    the statistics). The default is {cmd:kernel(epan2)}. See help {helpb kdens}
    for available kernels.

{phang}
    {opt bw(type)} specified the type of automatic bandwidth selector for
    density estimation. The default is {cmd:bw(dpi)}. See help {helpb kdens}
    for available bandwidth selectors.

{phang}
    {opt adaptive(#)} specifies the number of repetitions for adaptive
    kernel density estimation. The default is {cmd:adaptive(2)}. See help
    {helpb kdens}.

{phang}
    {opt n(#)} specifies the size of the evaluation grid for density
    estimation. The default is {cmd:n(512)}. See help {helpb kdens}.


{title:Examples}

        . {stata sysuse auto}
        . {stata robstat price, statistics(mean median alpha5 alpha25 HL Huber)}
        . {stata robstat price, jbtest}


{title:Stored results}

{pstd}
{cmd:robstat} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_over)}}number of subpopulations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(N_stats)}}number of statistics{p_end}
{synopt:{cmd:e(N_vars)}}number of variables{p_end}
{synopt:{cmd:e(df_r)}}sample degrees of freedom{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(level)}}confidence level for CIs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:robstat}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(depvar)}}variable names{p_end}
{synopt:{cmd:e(statistics)}}requested statistics{p_end}
{synopt:{cmd:e(over)}}name of {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_namelist)}}values from {cmd:over()} variable{p_end}
{synopt:{cmd:e(over_labels)}}labels from {cmd:over()} variable{p_end}
{synopt:{cmd:e(total)}}{cmd:total} or empty{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(jbtitle)}}title in normality test output{p_end}
{synopt:{cmd:e(jbtype)}}{cmd:chi2} or {cmd:F} or empty{p_end}
{synopt:{cmd:e(jbwald)}}{cmd:wald} or empty{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V} or {cmd:b}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimates{p_end}
{synopt:{cmd:e(aux)}}tuning constants of M estimators{p_end}
{synopt:{cmd:e(class)}}class of statistic (1 location, 2 scale, 3 skewness, 4 kurtosis){p_end}
{synopt:{cmd:e(_N)}}numbers of observations in subpopulations{p_end}
{synopt:{cmd:e(jbtest)}}normality test results (if requested){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
    If the {cmd:svy} option is specified, various additional results as described
    in help {helpb svy} are stored in {cmd:e()}.


{title:Methods and Formulas}

{pstd}
    Point estimates for {cmd:mean}, {cmd:alpha}, {cmd:median}, {cmd:sd}, {cmd:IQR},
    {cmd:MAD}, {cmd:skewness}, {cmd:SK}, {cmd:kurtosis}, {cmd:QW}, {cmd:LQW},
    and {cmd:RQW} are computed using {helpb summarize} and
    {helpb _pctile}.

{pstd}
    Point estimates for {cmd:Huber}, {cmd:biweight}, and {cmd:S} are computed by
    the iterative re-weighted least square procedure (IRWLS).

{pstd}
    Point estimates for {cmd:HL}, {cmd:Qn}, {cmd:MC}, {cmd:LMC}, and {cmd:RMC}
    are computed using variants of the fast algorithm proposed by
    Johnson and Mizoguchi (1978) (also see Croux and Rousseeuw 1992,
    Brys et al. 2004).

{pstd}
    The normality tests requested by the {cmd:jbtest} option are defined and
    computed as suggested by Brys et al. (2008). In case of nonstandard VCE or
    if the {cmd:wald} option is specify, Wald tests based on the
    estimated variance-covariance matrix are performed using the {helpb test}
    command.

{pstd}
    Approximate standard errors and confidence intervals are computed using an
    influence-function approach. For each statistic a variable
    containing the values of the influence function evaluated at the values of
    the outcome variable is computed, while imputing the unknown quantities of the influence
    function by their empirical counterparts. For some of the influence
    functions density estimation is required, which is performed using the
    binned approximation estimator implemented in {helpb kdens}. The sampling
    variance of the statistics is then estimated applying the {helpb mean} command
    to the variables containing the influence-function values.

{pstd}
    For more information on methods and formulas see Jann, Verardi and
    Vermandele (forthcoming).


{title:References}

{phang}
    Brys, G., M. Hubert, A. Struyf (2004). A Robust Measure of Skewness.
    Journal of Computational and Graphical Statistics 13(4): 996-1017.
    {p_end}
{phang}
    Brys, G., M. Hubert, A. Struyf (2006). Robust measures of tail weight.
    Computational Statistics & Data Analysis 50: 733-759.
    {p_end}
{phang}
    Brys, G., M. Hubert, A. Struyf (2008). Goodness-of-fit tests based on a
    robust measure of skewness. Computational Statistics 23: 429-442.
    {p_end}
{phang}
    Croux, C., P. J. Rousseeuw (1992). Time-efficient algorithms
    for two highly robust estimators of scale. P. 411-428 in: Y. Dodge and J.
    Whittaker (eds.). Computational Statistics. Heidelberg: Physica-Verlag.
    {p_end}
{phang}
    Jann, B., V. Verardi, C. Vermandele (forthcoming). Applied Robust Regression
    in Stata. College Station, Texas: The Stata Press.
    {p_end}
{phang}
    Johnson, D. B., T. Mizoguchi (1978). Selecting the {it:K}th element
    in {it:X} + {it:Y} and {it:X}_1 + {it:X}_2 + ... + {it:X}_{it:m}. SIAM
    Journal on Scientific Computing 7(2): 147–153.
    {p_end}
{phang}
    Hinkley, D. V. (1975). On power transformations to symmetry. Biometrika
    62(1): 101-111.
    {p_end}
{phang}
    Hodges, Jr., J. L., E. L. Lehmann (1963). Estimates of location based on
    rank tests. Annals of Mathematical Statistics 34(2): 598-611.
    {p_end}
{phang}
    Rousseeuw, P. J., C. Croux (1993). Alternatives to the Median
    Absolute Deviation. Journal of the American Statistical Association
    88(424): 1273-1283.
    {p_end}
{phang}
    Yule, G. U., M. G. Kendall (1968). An Introduction to the Theory of Statistics.
    14th ed. London: Griffin.
    {p_end}


{title:Authors}

{pstd}
    Ben Jann (University of Bern),
    Vincenzo Verardi (University of Namur and Universite libre de Bruxelles),
    Catherine Vermandele (Universite libre de Bruxelles)

{pstd}
    Support: ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., V. Verardi, C. Vermandele (2018). robstat: Stata module to estimate
    robust univariate statistics. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458524.html"}.


{title:Also see}

{psee}
    Online:  help for
    {helpb summarize},
    {helpb mean},
    {helpb tabstat},
    {helpb centile},
    {helpb ci},
    {helpb pctile}

{psee}
    From the SSC Archive:
    {stata ssc describe robreg:{bf:robreg}}
