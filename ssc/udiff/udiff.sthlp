{smcl}
{* *! version 1.1.7  03apr2020 Ben Jann & Simon Seiler}{...}
{vieweralsosee "[R] mlogit" "help mlogit"}{...}
{viewerjumpto "Syntax" "udiff##syntax"}{...}
{viewerjumpto "Description" "udiff##description"}{...}
{viewerjumpto "Options" "udiff##options"}{...}
{viewerjumpto "Postestimation" "udiff##postest"}{...}
{viewerjumpto "Examples" "udiff##examples"}{...}
{viewerjumpto "Methods and formulas" "udiff##methods"}{...}
{viewerjumpto "Saved results" "udiff##saved_results"}{...}
{viewerjumpto "References" "udiff##references"}{...}
{viewerjumpto "Authors" "udiff##authors"}{...}
{hi:help udiff}
{hline}

{title:Title}

{pstd}{hi:udiff} {hline 2}  Generalized unidiff model for individual-level data


{marker syntax}{...}
{title:Syntax}

{pstd}
    Simple syntax:

{p 8 15 2}
    {cmd:udiff} {depvar} {help varlist:{it:xvars}} {help varname:{it:layervar}} {ifin} {weight} [{cmd:,}
    {help udiff##opts:{it:options}} ]

{pstd}
    Advanced syntax:

{p 8 15 2}
    {cmd:udiff} {depvar} {it:term} [{it:term} ...] [{help varlist:{it:controlvars}}] {ifin} {weight} [{cmd:,}
    {help udiff##opts:{it:options}} ]

{pmore}
    where {it:term} is a unidiff term specified as

            {cmd:(}{help varlist:{it:xvars}} {help varname:{it:layervar}}{cmd:)}
        or
            {cmd:(}{help varlist:{it:xvars}} {cmd:<-} {help varlist:{it:layervars}}{cmd:)}
        or
            {cmd:(}{help varlist:{it:layervars}} {cmd:->} {help varlist:{it:xvars}}{cmd:)}

{pmore}
    {it:xvars} must be unique across unidiff terms, {it:layervars} may be repeated; parentheses may be
    omitted if there are no control variables and if only one unidiff term is specified.


{synoptset 22 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt cf:only}}estimate constant-fluidity model instead of unidiff model{p_end}
{synopt :{opth constr:aints(numlist)}}apply specified linear constraints{p_end}
{synopt :{opt b:aseoutcome(#)}}value of {depvar} that will be the base outcome{p_end}
{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or
   {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}{p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt all:equations}}report results for all equations; by default only the unidiff parameters are displayed{p_end}
{synopt :{opt eform}}report coefficients in exponentiated form{p_end}
{synopt :{opt noh:eader}}suppress header display above coefficient table{p_end}
{synopt :{it:{help estimation_options##display_options:display_options}}}standard display options{p_end}
{synopt :{opt coefl:egend}}display legend instead of statistics{p_end}
{synopt :{opt noi:sily}}display output from initial constant-fluidity model{p_end}

{syntab :Maximization}
{synopt :{it:{help maximize:maximize_options}}}maximization options{p_end}
{synoptline}
{p 4 6 2}{it:xvars}, {it:layervars}, and {it:controlvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{helpb svy} and {helpb mi estimate} are supported; see {help prefix}.{p_end}
{p 4 6 2}{cmd:fweight}s, {cmd:aweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see help {help weight}.{p_end}
{p 4 6 2}{helpb udiff##postest:predict} and other postestimation commands are available after {cmd:udiff}; see {help udiff##postest:below}.{p_end}
{p 4 6 2}{helpb udiff##postest:estat rescale} computes rescaled unidiff parameters after {cmd:udiff}; see {help udiff##postest:below}.{p_end}
{p 4 6 2}{helpb udiff##postest:estat lambda} computes lambda coefficients after {cmd:udiff}; see {help udiff##postest:below}.{p_end}
{p 4 6 2}{helpb udiff##postest:estat kappa} computes kappa indices after {cmd:udiff}; see {help udiff##postest:below}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
    {cmd:udiff} estimates parameters of the so-called unidiff model (Erikson
    and Goldthorpe 1992), also known as the log-multiplicative layer effect
    model (Xie 1992), which is often used to study differences in
    intergenerational class mobility between birth cohorts or countries.

{pstd}
    The original unidiff model has been expressed as a log-linear model of cell
    frequencies in a three-way contingency table (origin by destination by
    cohort or country). The model, however, can also be expressed at the
    individual-level (similar to a multinomial logit model). {cmd:udiff} estimates such a
    re-expressed unidiff model for individual-level data. Furthermore, it generalized the
    model to allow for multiple layers and non-categorical predictors. For details see
    {help udiff##methods:Methods and Formulas} below. For an implementation
    of the classic log-linear unidiff model for aggregate data see Pisati (2000).

{pstd}
    {it:depvar} is the (categorical) destination variable (e.g. class of
    respondent).

{pstd}
    {it:xvars} specifies the origin variable(s) (e.g. class of
    respondent's parents). Typically, {it:xvars} is a single
    categorical variable specified as {cmd:i.}{it:varname}, although multiple
    variables as well as continuous variables are allowed.

{pstd}
    {it:layervars} specifies the layer variable(s) to be interacted with
    {it:xvars}. Typically, {it:layervars} is a single categorical variable
    specified as {cmd:i.}{it:varname} (e.g. countries or birth-cohort
    categories), although multiple variables as well as continuous variables
    are allowed. For example, specify {cmd:(}{it:xvars} {cmd:<-}
    {cmd:c.cohort##c.cohort}{cmd:)} to model the unidiff scaling factor
    as a quadratic function of variable {cmd:cohort}. Likewise, if your data
    contains information on countries and birth cohorts, you could type
    {cmd:(}{it:xvars} {cmd:<-} {cmd:i.country i.cohort}{cmd:)} to include
    separate unidiff parameters for both dimensions. Furthermore, you could
    type  {cmd:(}{it:xvars} {cmd:<-} {cmd:i.country##i.cohort}{cmd:)}
    to include unidiff parameters for all country-cohort combinations.

{pstd}
    {it:controllvars} are control variables whose effects are assumed to be
    constant across layers.


{marker options}{...}
{title:Options}

{phang}
    {opt cfonly} causes the constant-fluidity model to be reported instead
    of the unidiff model. Estimation of the unidiff model will be skipped.

{phang}
    {opth constraints(numlist)} applies linear constraints to
    the estimation. {it:numlist} specifies the constraints by number, after
    they have been defined using the {helpb constraint} command. An
    {help udiff##exconstr:example} is provided below.

{phang}
    {opt baseoutcome(#)} specifies the value of {depvar} to be treated as the base
    outcome. The default is to choose the most frequent outcome.

{phang}
    {opt noconstant} suppresses the constant (outcome-specific intercepts)
    in the model.

{phang}
    {opt vce(vcetype)} specifies the type of variance estimation to be used
    to determine the standard errors. {it:vcetype} may be {opt oim},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or
   {opt jack:knife}; see {help vce_option:[R] {it:vce_option}}.

{phang}
    {opt robust} is a synonym for {cmd:vce(robust)}.

{phang}
    {opt cluster(clustvar)} is a synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}.

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)}
    or as set by {helpb set level}.

{phang}
    {opt allequations} reports results for all equations of the model. By default,
    only the first equation containing the unidiff parameters is displayed.

{phang}
    {opt eform} displays the coefficients in exponentiated form. That is, for each coefficient,
    exp({it:b}) rather than {it:b} is displayed, and standard errors and
    confidence intervals are transformed accordingly.

{phang}
    {opt noheader} suppresses the header above the coefficient table
    that displays the final log-likelihood value, the number of observations,
    and the unidiff significance test.

{phang}
    {it:display_options} are standard display options; see
    {helpb estimation_options##display_options:[R] estimation options}.

{phang}
    {opt coeflegend} specifies that the legend of the coefficients and how
    to specify them in an expression be displayed rather than displaying the
    statistics for the coefficients.

{phang}
    {opt noisily} displays the {helpb mlogit} output of the initial
    constant-fluidity model. By default, the initial model is not displayed.

{phang}
    {it:maximize_options} are maximization options such as {cmd:iterate()} or
    {cmd:difficult}. See {helpb maximize:[R] maximize}. These options will only
    be applied to the unidiff model, but not to the initial constant-fluidity model.


{marker postest}{...}
{title:Postestimation commands}

{pstd}
    Usual postestimation commands such as {helpb predict}, {helpb test}, {helpb estat},
    {helpb lincom}, {helpb nlcom}, {helpb margins}, or {helpb suest} are available
    after {cmd:udiff}. Details on {cmd:estat} and {cmd:predict} are as follows.

{pstd}
    Note that, after a model that has been estimated using the {helpb svy}
    prefix, {cmd:estat rescale}, {cmd:estat lambda}, and {cmd:estat kappa} have to be specified as

        {cmd:. udiff_estat} {it:subcmd}

{pstd}
    where {it:subcmd} is {cmd:rescale}, {cmd:lambda}, or {cmd:kappa}.

{dlgtab:estat rescale}

{p 8 15 2}
    {cmd:estat} {cmdab:res:cale} [{it:{help numlist}}] [{cmd:,} {opt post} {opt l:evel(#)} {it:{help estimation_options##display_options:display_options}} ]

{pstd}
    Report rescaled unidiff parameters using the normalization suggested by
    Xie (1992). The normalization is only supported for unidiff terms that contain
    a single categorical layer variable specified as {cmd:i.}{it:varname}
    (factor variable). The normalization is such that the sum of the squared
    parameters equals 1 (within each unidiff term).

{phang}
    {it:numlist} specifies the unidiff terms to be included; this is only
    relevant if a model contains multiple unidiff terms. The default is to
    include all unidiff terms found in the model. To only include, say, the
    second unidiff term, type {cmd:estat rescale 2}.

{phang}
    {opt post} causes the rescaled results to be posted in {cmd:e(b)} and {cmd:e(V)}. This
    will clear out the previous estimation results. Without the {cmd:post} option, the results
    are stored in {cmd:r(b)} and {cmd:r(V)}; see {help udiff##saved_results:Saved results} below.

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)}
    or as set by {helpb set level}.

{phang}
    {it:display_options} are standard display options; see
    {helpb estimation_options##display_options:[R] estimation options}.

{dlgtab:estat lambda}

{p 8 15 2}
    {cmd:estat} {cmdab:lam:bda} [{it:#}] [{cmd:,} {opt std:ize} {opt eform} {opt comp:act} {opt post} {opt l:evel(#)} {it:{help estimation_options##display_options:display_options}} ]

{pstd}
    Report lambda coefficients for unidiff term {it:#} (if {it:#} is omitted,
    the first unidiff term is used). {cmd:estat lambda} only supports unidiff terms that contain
    a single categorical layer variable and a single categorical predictor, both specified
    as {cmd:i.}{it:varname} (factor variable). See Pisati (2000) for a definition
    of the lambda coefficients.

{phang}
    {opt stdize} requests standardized lambda coefficients. The default is to
    report raw lambda coefficients.

{phang}
    {opt eform} reports the results in exponentiated form.

{phang}
    {opt compact} requests that the lambda coefficients be displayed in a
    two-way table with one column per outcome level. Standard errors will not be displayed
    in this case. The default is to display the coefficients in a one-way
    table including standard errors and confidence intervals.

{phang}
    {opt post} causes the lambda coefficients to be posted in {cmd:e(b)} and {cmd:e(V)}. This
    will clear out the previous estimation results. Without the {cmd:post} option, the results
    are stored in {cmd:r(b)} and {cmd:r(V)}; see {help udiff##saved_results:Saved results} below.

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)}
    or as set by {helpb set level}.

{phang}
    {it:display_options} are standard display options; see
    {helpb estimation_options##display_options:[R] estimation options}.

{dlgtab:estat kappa}

{p 8 15 2}
    {cmd:estat} {cmdab:kap:pa} [{it:#}] [{cmd:,} {opt post} {opt l:evel(#)} {it:{help estimation_options##display_options:display_options}} ]

{pstd}
    Report kappa indices coefficients for unidiff term {it:#} (if {it:#} is omitted,
    the first unidiff term is used). {cmd:estat kappa} only supports unidiff terms that contain
    a single categorical layer variable and a single categorical predictor, both specified
    as {cmd:i.}{it:varname} (factor variable). See Pisati (2000) for a definition
    of the kappa indices.

{phang}
    {opt post} causes the kappa indices to be posted in {cmd:e(b)} and {cmd:e(V)}. This
    will clear out the previous estimation results. Without the {cmd:post} option, the results
    are stored in {cmd:r(b)} and {cmd:r(V)}; see {help udiff##saved_results:Saved results} below.

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)}
    or as set by {helpb set level}.

{phang}
    {it:display_options} are standard display options; see
    {helpb estimation_options##display_options:[R] estimation options}.

{dlgtab:predict}

{p 8 15 2}
    {cmd:predict} [{it:{help datatypes:type}}] {newvar} {ifin} [{cmd:,} {opt xb} {opt e:quation(equation)} ]

{p 8 15 2}
    {cmd:predict} [{it:{help datatypes:type}}] {newvar} {ifin}{cmd:,} {opt p:r} [ {opt o:utcome(outcome)} ]

{p 8 15 2}
    {cmd:predict} [{it:{help datatypes:type}}] {c -(}{it:stub}{cmd:*} | {help newvarlist:{it:newvarlist}}{c )-}  {ifin}{cmd:,}
    {opt sc:ores} [ {opt e:quation(equation)} ]

{phang}
    {opt xb} calculates linear predictions for the equation specified by
    {cmd:equation()}. {cmd:xb} is the default unless {cmd:pr} or {cmd:scores}
    is specified. If {opt equation()} is omitted, linear predictions are calculated
    for the first equation.

{phang}
    {opt equation(equation)} specifies the equation for which linear
    predictions are to be calculated. {it:equation} can be an equation name, or
    an equation index specified as {cmd:#1}, {cmd:#2}, etc. Option
    {opt equation()} is not allowed with {cmd:pr}.

{phang}
    {opt pr} calculates predicted probabilities for the outcome specified by
    {cmd:outcome()}. If {opt outcome()} is omitted, predicted probabilities are
    calculated for the first outcome.

{phang}
    {opt outcome(outcome)} specifies the outcome for which predicted
    probabilities are to be calculated. {it:outcome} can be an
    outcome value, or an outcome index specified as {cmd:#1}, {cmd:#2}, etc. Option
    {opt outcome()} is only allowed with {cmd:pr}.

{phang}
    {opt scores} calculates equation-level score variables (first derivative
    of the log likelihood). If {opt equation()} is omitted, score variables
    are generated for all equations (one variable per equation; if {it:k} is
    the number of outcomes, then the number of equations is equal to ({it:k}-1)*2+1).


{marker examples}{...}
{title:Examples}

    {help udiff##exbasic:Basic example}
    {help udiff##exrescale:Normalized unidiff parameters}
    {help udiff##exlambda:Lambda coefficients and kappa indices}
    {help udiff##exconstr:Specifying constraints}
    {help udiff##exfit:Testing model fit}
    {help udiff##excontinuous:Continuous origin variables}
    {help udiff##exmultiple:Multiple unidiff terms}
    {help udiff##excont:Continuous layer variables}
    {help udiff##excontrol:Control variables}

{marker exbasic}{...}
{dlgtab:Basic example}

{pstd}
    The unidiff model in Example 2 in Pisati (2000) can be reproduced as follows:

        . {stata "use http://www.stata.com/stb/stb55/sg142/example2.dta, clear"}
        . {stata udiff son i.father i.country [fweight=obs]}

{pstd}
    Using advanced syntax we could type

        . {stata udiff son (i.father <- i.country) [fweight=obs]}
    or
        . {stata udiff son (i.country -> i.father) [fweight=obs]}

{pstd}
    A likelihood-ratio test against the constant-fluidity model is included in the
    header of the output table. In the example, the test is highly significant and confirms that
    there are differences in the unidiff parameters between the countries.

{pstd}
    By default, {cmd:udiff} omits the base category from the output
    (Australia in this example) and displays the unidiff parameters in logarithmic form. To
    include the base category in the output, specify {cmd:baselevels}; to
    report unidiff parameters as multipliers, add the {cmd:eform} option:

        . {stata udiff, eform baselevels}

{pstd}
    Furthermore, by default only the unidiff scaling parameters are reported. To
    report all parameters of the model, specify option {cmd:all}:

        . {stata udiff, all}

{marker exrescale}{...}
{dlgtab:Normalized unidiff parameters}

{pstd}
    To obtain rescaled unidiff parameters using the normalization suggested
    by Xie (1992), you can apply command {helpb udiff##postest:estat rescale} after
    model estimation:

        . {stata "use http://www.stata.com/stb/stb55/sg142/example2.dta, clear"}
        . {stata udiff son i.father i.country [fweight=obs], eform base}
        . {stata estat rescale}

{pstd}
    Note that {helpb udiff##postest:estat rescale} is only supported for unidiff terms
    that contain a single categorical layer variable.

{marker exlambda}{...}
{dlgtab:Lambda coefficients and kappa indices}

{pstd}
    To obtain lambda coefficients (see Pisati 2000) you can apply command
    {helpb udiff##postest:estat lambda} after
    model estimation:

        . {stata "use http://www.stata.com/stb/stb55/sg142/example1.dta, clear"}
        . {stata udiff son i.father i.country [fweight=obs], eform base}
        . {stata estat lambda, stdize eform compact}

{pstd}
    The {cmd:compact} option has been specified to display the coefficients
    in a two-way table. This means that standard errors are not
    shown. Omit the {cmd:compact} option if you are interested in the standard
    errors or confidence intervals.

{pstd}
    The kappa indices, which are based on standardized lambda coefficients, can
    be obtained as follows:

        . {stata estat kappa}

{pstd}
    Note that {helpb udiff##postest:estat lambda} and {helpb udiff##postest:kappa} are
    only supported for unidiff terms
    that contain a single categorical layer variable and a single categorical
    predictor.

{marker exconstr}{...}
{dlgtab:Specifying constraints}

{pstd}
    In case of empty cells or similar problems, it may be necessary to specify
    constraints for the model to converge. Using the same data as above, assume
    that the combinations of father = "NonManual" and son = "Farm" is missing:

        . {stata "use http://www.stata.com/stb/stb55/sg142/example2.dta, clear"}
        . {stata replace obs = 0 if son==3 & father==1}

{pstd}
    To make {cmd:udiff} converge in this example, we can set the parameter
    for "NonManual" in the psi-equation for "Farm" to zero (while at the same time
    making sure that "NonManual" is not used as the base category). The following
    commands would do:

        . {stata "constraint 1 [Psi_3]: 1.father"}
        . {stata udiff son ib2.father i.country [fweight=obs], allequations constraints(1)}

{marker exfit}{...}
{dlgtab:Testing model fit}

{pstd}
    To test the fit of the unidiff model, a likelihood-ratio test against a
    saturated model can be performed, where the saturated model is a
    fully-interacted multinomial logit. A significant test statistic would
    indicate, that the saturated model fits the data significantly better than the
    unidiff model. An example is as follows:

        . {cmd:use http://www.stata.com/stb/stb55/sg142/example1.dta, clear}
        . {cmd:udiff son i.father i.country [fweight=obs]}
        . {cmd:estimates store udiff}
        . {cmd:mlogit son i.father##i.country [fweight=obs]}
        . {cmd:lrtest udiff ., force}

{pstd}
    Option {cmd:force} is needed because different estimation commands have been
    used to estimate the two models.

{pstd}
    Be aware that the likelihood-ratio test is only valid in case of simple
    random sampling. Do not use the test with complex samples, i.e., if
    sampling weights or the {cmd:svy} prefix have been specified.

{marker excontinuous}{...}
{dlgtab:Continuous origin variables}

{pstd}
    Assume that, apart from the categorical information on father's class,
    your data also contains a continuous origin variable such as father's ISEI score
    ({cmd:fisei}). Such information could easily be included in the model by adding the
    variable to the list of predictors in the unidiff term:

        . {cmd:udiff son (i.father fisei <- i.country)}

{marker exmultiple}{...}
{dlgtab:Multiple unidiff terms}

{pstd}
    Assume your data also contains information on mothers. You could include this
    information in the unidiff model, for example, as follows:

        . {cmd:udiff son (i.father i.mother <- i.country)}

{pstd}
    In this case, a single unidiff scaling factor would be used for both the effects of
    fathers and the effects of mothers. To use different unidiff factors and thus
    allow the effects of father and mothers to vary differently across countries, you
    could type:

        . {cmd:udiff son (i.father <- i.country) (i.mother <- i.country)}

{marker excont}{...}
{dlgtab:Continuous layer variables}

{pstd}
    The layer variable(s) do not need to be categorical. For example, if you have
    individual-level data containing information on the birth years
    of the respondents, you could model the layer effects
    as a parabolic function of the birth year to analyze how social mobility changes over
    time. To avoid convergence issues it is
    a good idea to center the birth years at a date that actually exists in the data. For
    example, define {cmd:cohort} = (birth year - 1980) and then type

        . {cmd:udiff son (i.father <- c.cohort##c.cohort)}

{pstd}
    Likewise, you could model the layer effects in terms of country characteristics:

        . {stata "use http://www.stata.com/stb/stb55/sg142/example2.dta, clear"}
        . {stata udiff son (i.father <- develop socdem i.east i.asia) [fweight=obs]}

{pstd}
    Statistical inference may not be credible in this example and we might want to
    cluster on countries:

        . {stata udiff son (i.father <- develop socdem i.east i.asia) [fweight=obs], cluster(country)}

{pstd}
    No value for the joint Wald test of the unidiff parameters (i.e. the
    test against the constant-fluidity model) is reported in this case due to the
    way how {helpb ml} (the underlying command used for model estimation) determines the
    degrees of freedom for the test. You can obtain the test using the
    {helpb test} command after model estimation:

        . {stata test [Phi]}

{pstd}
    However, note that the number of countries is small. Cluster-robust
    standard errors may be inconsistent in such a setting (a general recommendation
    is that the number of clusters should be at least 40 or 50).

{marker excontrol}{...}
{dlgtab:Control variables}

{pstd}
    Assume that the age structure (or distribution of birth years) is different
    across countries and you want to take account of that in your analysis. You could,
    for example, type

        . {cmd:udiff son (i.father <- i.country) age}

{pstd}
    In this way a an age effect that is common to all countries is included
    in the model. You could, of course, also use a more complex specification,
    such as, e.g.,

        . {cmd:udiff son (i.father <- i.country) c.age##c.age}


{marker methods}{...}
{title:Methods and formulas}

{dlgtab:The unidiff model}

{pstd}
    The unidiff model is typically used to study differences in
    intergenerational social mobility between birth cohorts or countries. Let
    {it:mu}(x,y,z) be the cell frequencies in a three-way table of X (origin
    class, e.g. class of parents) by Y (destination class, e.g. class of
    children) by Z (e.g. cohort). Lowercase x, y, and z denote the
    levels of X, Y, and Z. In a saturated log-linear model the cell
    frequencies are parametrized as

        ln {it:mu}(x,y,z) = {it:a} + {it:a}(x) + {it:a}(y) + {it:a}(z) + {it:a}(x,y) + {it:a}(x,z) + {it:a}(y,z) + {it:a}(x,y,z)

{pstd}
    where {it:a} is an overall intercept capturing the average cell frequency,
    {it:a}(x), {it:a}(y), and {it:a}(z) are factors capturing the marginal distributions
    of X, Y, and Z, {it:a}(x,y), {it:a}(x,z), and {it:a}(y,z)
    capture two-way associations, and {it:a}(x,y,z) captures the three-way
    association. For example, if X, Y, and Z are independent from each other,
    {it:a}(x,y), {it:a}(x,z), {it:a}(y,z), and {it:a}(x,y,z) will be zero for
    all x, y, and z. Likewise, if the association between X and Y is
    constant over cohorts, {it:a}(x,y,z) will be zero for all x, y, and z,
    such that

        ln {it:mu}(x,y,z) = {it:a} + {it:a}(x) + {it:a}(y) + {it:a}(z) + {it:a}(x,y) + {it:a}(x,z) + {it:a}(y,z)

{pstd}
    This is the so-called constant-fluidity model. The saturated
    model accurately describes the data, but has too many parameters
    to be informative; the constant-fluidity model is too
    simplistic because it assumes away any change in relative mobility. The unidiff
    model takes a middle ground in that it allows the association between X and Y
    to vary with Z, but places a specific restriction on the form of this
    variation. In particular, the unidiff model introduces a scaling factor
    {it:b}(z) such that

        ln {it:mu}(x,y,z) = {it:a} + {it:a}(x) + {it:a}(y) + {it:a}(z) + {it:a}(x,z) + {it:a}(y,z) + {it:a}(x,y) * {it:b}(z)

{pstd}
    That is, the unidiff model assumes that there is a common association pattern
    between X and Y, but the "strength" of the pattern can differ across
    cohorts.

{dlgtab:Re-expression at the individual level}

{pstd}
    Traditionally, the unidiff model has been estimated from tabular data.
    However, the model (or, at least, the interesting part of it) can also be
    expressed such that it takes the form of a regression model fitted to
    individual-level data. From a perspective with Y as the "dependent"
    variable, the saturated log-linear model is equivalent to a multinomial
    logit of Y on X, Z, and the interaction between X and Z, where X and Z are
    treated as factor variables. Likewise, the constant-fluidity model is a
    multinomial logit of Y on X and Z, without interaction between X and Z.
    Furthermore, the unidiff model is equivalent to a multinomial logit written
    as

        Pr(Y = y| X, Z) = exp(W'{it:theta}(y) + X'{it:psi}(y) * exp(Z'{it:phi})) / D

{pstd}
    where D is the sum of the expression in the numerator across all levels of
    Y, and W is equal to Z augmented by a constant, i.e. W = (1,Z')' (again, X
    and Z are treated as factor variables, i.e. think of X and Z as vectors
    of dummy variables). {it:theta}(y), {it:phi},
    and {it:psi}(y) are parameter vectors; {it:phi} is common to all levels of
    Y, {it:theta}(y) and {it:psi}(y) are level-specific. In this model,
    {it:theta}(y) represents {it:a}(y) and {it:a}(y,z) (the marginal
    distribution of Y as well as the main effects of Z, i.e. how the marginal
    distribution of Y depends on Z), exp({it:phi}) represents {it:b}(z) (the
    unidiff scaling factors), and {it:psi}(y) represents {it:a}(x,y) (the
    association between X and Y). Terms {it:a}(x) (marginal distribution of X),
    {it:a}(z) (marginal distribution of Z), {it:a}(x,z) (association between X
    and Z) are not represented in the model (i.e., the model only contains
    parameters that are related to Y).

{dlgtab:Generalization: multiple unidiff terms}

{pstd}
    Generally seen, the unidiff model is just a multinomial logit model
    that contains a special kind of interaction terms. The model may thus be
    useful also for research questions that have nothing to do with social
    mobility. Furthermore, the model can be generalized so that it contains
    multiple unidiff terms. Let X1 and X2 be two sets of independent
    variables, Z1 and Z2 two sets of layer variables, and C a set of
    control variables that are not interacted with Z1 or Z2. The model can then be
    written as:

{p 8 8 2}Pr(Y = y| X1, Z1, X2, Z2, C) ={p_end}
{p 12 12 2}exp(W'{it:theta}(y) + X1'{it:psi1}(y) * exp(Z1'{it:phi1}) + X2'{it:psi2}(y) * exp(Z2'{it:phi2})) / D{p_end}

{pstd}
    where W = (1, Z1', Z2', C')'. The model can be extended analogously
    to accommodate more than two unidiff terms.

{dlgtab:Estimation}

{pstd}
    {cmd:udiff} estimates the unidiff model using {helpb ml}. To obtain good
    starting values, {cmd:udiff} first fits a constant-fluidity model (which is
    equivalent to a standard {helpb mlogit} model ignoring the layer
    variables). A test of the unidiff model against the constant-fluidity model
    is included in the output (as an LR test or a Wald test, depending on
    context).

{pstd}
    As usual in a multinomial logit, the coefficients are set to zero for one
    of the levels of Y to identify the model. Furthermore, as is usual for factor variables,
    {it:phi} is set to zero for one of the levels of Z if Z is a categorical variable. exp({it:phi})
    then expresses the unidiff scaling factors with respect to this base category.

{pstd}
    Estimating the unidiff model from individual-level data is more demanding
    than fitting the model to a contingency table (although note that, for
    efficient computation, {cmd:fweight}s can be used on collapsed data),
    but it brings about enhanced flexibility. For example, it is easily
    possible to include continuous (rather than categorical) origin and layer
    variables, control variables whose effects as assumed constant over cohorts
    can be taken into account (by including them in W), and standard errors for
    the parameter estimates are readily available (including support for
    sampling weights or other characteristics of a complex survey design).


{marker saved_results}{...}
{title:Saved results}

{pstd}
    {cmd:udiff} stores results as described in {helpb ml##results:[R] ml},
    as well as the following elements:

{p2colset 7 22 26 2}{...}
{p2col 5 22 26 2: Scalars}{p_end}
{p2col : {cmd:e(k_out)}}number of outcomes
    {p_end}
{p2col : {cmd:e(ibaseout)}}index of the base outcome
    {p_end}
{p2col : {cmd:e(k_unidiff)}}number of unidiff terms
    {p_end}
{p2col : {cmd:e(k_eform)}}number of equations to be affected by the {cmd:eform} option
    {p_end}

{p2col 5 22 26 2: Macros}{p_end}
{p2col : {cmd:e(cmd)}}{cmd:udiff}
    {p_end}
{p2col : {cmd:e(predict)}}{cmd:udiff_p}
    {p_end}
{p2col : {cmd:e(estat_cmd)}}{cmd:udiff_estat}
    {p_end}
{p2col : {cmd:e(cfonly)}}{cmd:cfonly} or empty
    {p_end}
{p2col : {cmd:e(layervars)}}names of layer variables; if {cmd:e(k_unidiff)}=1
    {p_end}
{p2col : {cmd:e(layervars#)}}names of layer variables of #th unidiff term; if {cmd:e(k_unidiff)}>1
    {p_end}
{p2col : {cmd:e(xvars)}}names of independent variables; if {cmd:e(k_unidiff)}=1
    {p_end}
{p2col : {cmd:e(xvars#)}}names of independent variables of #th unidiff term; if {cmd:e(k_unidiff)}>1
    {p_end}
{p2col : {cmd:e(controlvars)}}names of control variables
    {p_end}
{p2col : {cmd:e(eqnames)}}names of equations
    {p_end}
{p2col : {cmd:e(out)}}values of {it:depvar}
    {p_end}
{p2col : {cmd:e(baseout)}}value of {it:depvar} treated as the base outcome
    {p_end}
{p2col : {cmd:e(out_labels)}}value labels of {it:depvar} (if available)
    {p_end}

{pstd}
    Without the {cmd:post} option, {cmd:estat rescale}, {cmd:estat lambda}, and {cmd:estat kappa} store the following
    results in {cmd:r()}:

{p2colset 7 22 26 2}{...}
{p2col 5 22 26 2: Scalars}{p_end}
{p2col : {cmd:r(N)}}number of observations
    {p_end}

{p2col 5 22 26 2: Matrices}{p_end}
{p2col : {cmd:r(b)}}coefficients
    {p_end}
{p2col : {cmd:r(V)}}variance matrix
    {p_end}
{p2col : {cmd:r(lambda)}}compact representation coefficients ({cmd:estat lambda} only)
    {p_end}

{pstd}
    Without the {cmd:post} option, {cmd:estat rescale},
    {cmd:estat lambda}, and
    {cmd:estat kappa}
    store the following results in {cmd:e()}:

{p2colset 7 22 26 2}{...}
{p2col 5 22 26 2: Scalars}{p_end}
{p2col : {cmd:r(N)}}number of observations
    {p_end}
{p2col : {cmd:r(N_clust)}}number of clusters (if {it:vcetype} is {cmd:cluster})
    {p_end}
{p2col : {cmd:r(k_eq)}}number of equations
    {p_end}
{p2col : {cmd:e(k_eform)}}number of equations to be affected by the {cmd:eform} option
    {p_end}

{p2col 5 22 26 2: Macros}{p_end}
{p2col : {cmd:e(cmd)}}{cmd:udiff_estat}
    {p_end}
{p2col : {cmd:e(subcmd)}}{cmd:rescale} or {cmd:lambda}
    {p_end}
{p2col : {cmd:e(estat_cmd)}}{cmd:udiff_estat}
    {p_end}
{p2col : {cmd:e(title)}}title used in output
    {p_end}
{p2col : {cmd:e(vce)}}{it:vcetype} as specified when calling {cmd:udiff}
    {p_end}
{p2col : {cmd:e(vcetype)}}title used to label Std. Err.
    {p_end}
{p2col : {cmd:e(clustvar)}}name of cluster variable
    {p_end}
{p2col : {cmd:e(properties)}}{cmd:b V}
    {p_end}

{p2col 5 22 26 2: Matrices}{p_end}
{p2col : {cmd:e(b)}}coefficients
    {p_end}
{p2col : {cmd:e(V)}}variance matrix
    {p_end}
{p2col : {cmd:r(lambda)}}compact representation coefficients ({cmd:estat lambda} only)
    {p_end}


{marker references}{...}
{title:References}

{phang}
    Erikson, R., J.H. Goldthorpe. 1992. The Constant Flux: A Study of Class
    Mobility in Industrial Societies. Oxford: Oxford University Press.
    {p_end}
{phang}
    Pisati, M. 2000. {stata "net describe sg142, from(http://www.stata.com/stb/stb55)":sg142}: Uniform
    layer effect models for the analysis of differences in two-way associations. Stata
    Technical Bulletin 55: 33-47.
    {p_end}
{phang}
    Xie, Y. 1992. The Log-Multiplicative Layer Effect Model for Comparing Mobility
    Tables. American Sociological Review 57(3): 380–395.
    {p_end}


{marker authors}{...}
{title:Authors}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch
    {p_end}
{pstd}
    Simon Seiler, University of Bern, simon.seiler@icer.unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B., S. Seiler. 2019. udiff: Stata module to estimate the generalized
    unidiff model for individual-level data. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458711.html"}.

