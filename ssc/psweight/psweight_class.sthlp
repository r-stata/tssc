{smcl}
{* Copyright (C) Mathematica This code cannot be copied, distributed or used without the express written permission of Mathematica , Inc.}{...}
{vieweralsosee "[M-2] class" "mansection M-2 class"}{...}
{viewerjumpto "Title" "psweight class##title"}{...}
{viewerjumpto "Syntax" "psweight class##syntax"}{...}
{viewerjumpto "Description" "psweight class##description"}{...}
{viewerjumpto "Details" "psweight class##details"}{...}
{viewerjumpto "Examples" "psweight class##examples"}{...}
{viewerjumpto "Author" "psweight class##author"}{...}
{viewerjumpto "Conformability" "psweight class##conformability"}{...}
{viewerjumpto "Source code" "psweight class##source"}{...}
{marker title}{...}
{title:Title}

psweight() {hline 2} A Mata class to implement IPW- and CBPS-type propensity
score reweighting, with various extensions (class definition)


{marker syntax}{...}
{title:Syntax}

{help psweight_class##funct1:Setup functions}:

                    P = psweight()
    void            P.st_set(tvar, tmvarlist, | tousevar, swvar)
    void            P.st_set_depvars(depvarlist, | tousevar)
    void            P.set(t, tm, | sw)
    void            P.set_depvars(y0)

{help psweight_class##funct2:Functions to estimate IPW weights}:

    real rowvector  P.solve(| stat, subcmd, denominator, cvopt)
    real rowvector  P.ipw(| stat)
    real rowvector  P.cbps(| stat, denominator)
    real rowvector  P.cbpsoid(| stat, denominator)

{help psweight_class##funct3:Post-estimation functions}:

    void            P.reweight(| w,  p)
    real colvector  P.get_pscore()
    real colvector  P.get_weight_mtch()
    real colvector  P.get_weight()
    void            P.fill_vars(varnames, | tousevar)
    real rowvector  P.pomean()

{help psweight_class##funct4:Functions to assess balance} (comparing the
treatment and control groups):

    real matrix     P.balancetable(| denominator)
    real rowvector  P.diff()
    real rowvector  P.stddiff(| denominator)
    real rowvector  P.varratio()
    real scalar     P.mean_sd(| denominator)
    real scalar     P.mean_asd(| denominator)
    real scalar     P.max_asd(| denominator)
    real rowvector  P.progdiff(| denominator)

{help psweight_class##funct5:Functions to summarize the distribution of the IPW weights}:

    real scalar     P.wgt_cv(stat)
    real scalar     P.wgt_sd(stat)
    real scalar     P.wgt_skewness(stat)
    real scalar     P.wgt_kurtosis(stat)
    real scalar     P.wgt_max(stat)

{help psweight_class##funct6:Miscellaneous functions}:

    void            P.balanceresults(| stat, denominator)
    void            P.clone(src)
    real matrix     P.get_N(| s)

where:

        tvar            : string scalar (must contain Stata {help varname})
        tmvarlist       : string scalar (must contain Stata {help varnames})
        tousevar        : string scalar (must contain Stata {help varname})
        swvar           : string scalar (must contain Stata {help varname})
        depvarlist      : string scalar (must contain Stata {help varnames})
        varnames        : string scalar (must contain Stata {help varnames})

        t               : real column vector
        x               : real matrix
        y0              : real matrix
        w               : real column vector
        p               : real column vector
        s               : real scalar

and where denominator, a real (integer) scalar optionally specified, determines
how standardized differences are calculated:

        denominator  variance used
        0            the control groups' variances
        1            the treatment groups' variances
        2            the pooled variances; the default
        3            (control variance + treatment variance)/2
                        (as in {help tbalance})

and where stat, a string scalar optionally specified determines whether the
estimand of interest for computing IPW weights:

        stat         computes weights for
        ate          the average treatment effect; the default
        atet         the average treatment effect on the treated
        ateu         the average treatment effect on the untreated

        When summarizing the distribution of weights (e.g., the wgt_cv()
        function), stat specifies whether to summarize weights for the whole
        sample (ate, the default), the control group (atet), or the treatment
        group (ateu).

and where subcmd, a string scalar optionally specified in P.solve( ), is
defined below.

and where cvopt, a real rowvector optionally specified in P.solve( ), is
defined below.

and where src is a (scalar) instance of the class psweight.


{marker description}{...}
{title:Description}

{cmd:psweight()} is a {help m-2 class:Mata class} that computes inverse-probability weighting (IPW)
weights for average treatment effect, average treatment effect on the treated,
and average treatment effect on the untreated estimators for observational
data. IPW estimators use estimated probability weights to correct for the
missing data on the potential outcomes. Probabilities of treatment--propensity
scores--are computed for each observation with one of a variety of methods,
including logistic regression (traditional IPW), covariate-balancing
propensity scores (CBPS), penalized covariate-balancing propensity scores
(PCBPS), prognostic score balancing propensity scores, and other methods.
It also constructs balance tables and assesses the distribution of the IPW
weights.

{helpb psweight} is a Stata command that offers Stata users easy access to
the class. However, the class offers more flexibility and can conduct some
analyses unavailable with the Stata command.


{marker details}{...}
{title:Details}

{marker funct1}{...}
{bf:Setup functions}:

void P.st_set(tvar, tmvarlist, | tousevar, swvar)

    Loads Stata data for the treatment model into the Mata class using views.

    tvar, tmvarlist, tousevar, and swvar contain the names of variables in
        the Stata data.

    tvar      is a variable that must contain values 0 or 1, representing the
                treatment (1) and comparison (0) group observations.
    tmvarlist specifies one or more variables that predict treatment
                assignment in the treatment model.
    tousevar  is a variable that must contain values 0 or 1, representing the
                rows to include (1) or exclude (0). (optional)
    swvar     is a variable that specifies sample weights (optional; sample is
                unweighted if swvar is not provided)

void P.set(t, x, | w)

    Loads Mata data into the Mata class.

    t must contain values 0 or 1, representing the treatment (1) and
        comparison (0) group observations.
    x specifies the data that predict treatment assignment in the treatment
        model.
    w specifies sample weights; these are treated as iweights (optional;
        sample is unweighted if w is not provided)

void P.st_set_depvars(depvarlist, | tousevar)

    Loads Stata data for the dependent variable (control group only) into the
    Mata class using views.

    depvarlist and tousevar contain the names of variables in the Stata data.

    depvarlist are the variable(s) containing the dependent variable(s).
    tousevar is a variable that must contain values 0 or 1, representing the
    rows to include (1) or exclude (0). (optional)

void P.set_depvars(y0)

    Loads Mata data for the dependent variable (control group only) into the
    Mata class.

    y0 specifies the dependent variable(s) data for the control group.


{marker funct2}{...}
{bf:Functions to estimate IPW weights}:

real rowvector P.solve(| stat, subcmd, denominator, cvopt)

    This is the psweight class's premier solver function. See the remarks in
    {help psweight##remarks:help psweight} for a description of the methods.

    The function returns the vector of coefficients for the propensity score
    model, {it:b}.

    In addition, the function updates (private) variables containing the
    propensity scores (predicted values) and IPW weights. The type of IPW
    weights is specified by {it:stat}, and could be weights for estimating
    average treatment effects {opt ate}, average treatment effects on the
    treated {opt atet}, or average treatment effects on the untreated {opt
    ateu}. The IPW weights are normalized to have mean equal to 1 in each
    group. (If sample weights are provided, the weights are normalized so
    the weighted mean equals 1 in each group.)

    subcmd, a string scalar, specifies which method is used to compute
    coefficients for the propensity score model ({it:b}).  In some cases, the
    method requires defining how standardized differences are calculated (
    {it:denominator}).

        subcmd       Method used to compute {it:b}
        ipw          logit regression; the default
        cbps         just-identified covariate-balancing propensity score
        cbpsoid      over-identified covariate-balancing propensity score
        mean_sd_sq   minimize mean(stddiff())^2
        sd_sq        minimize sum(stddiff()^2)
        stdprogdiff  minimize sum(stdprogdiff()^2)

    cvopt is analogue to the cvtarget(# # #), skewtarget(# # #), and
    kurttarget(# # #) options in {help psweight}.

        Let loss_0 be the objective function corresponding to the
        specified {it:subcmd}.

        Size of cvopt   Penalty
        1 x 3           If cvopt=(a, b, c), the loss function is modified to:
                            loss = loss_0 + a * abs((wgt_cv() - b)^c)
        1 x 6           If cvopt=(a, b, c, d, e, f), the loss function is
                        modified to:
                            loss = loss_0 + a * abs((wgt_cv() - b)^c)
                                          + d * abs((wgt_skewness() - e)^f)
        1 x 9           If cvopt=(a, b, c, d, e, f, g, h, i), the loss
                        function is modified to:
                            loss = loss_0 + a * abs((wgt_cv() - b)^c)
                                          + d * abs((wgt_skewness() - e)^f)
                                          + g * abs((wgt_kurtosis() - h)^i)
        1 x 12          If cvopt=(a, b, c, d, e, f, g, h, i, j, k, l),  the
                        loss function is modified to:
                            loss = loss_0 + a * abs((wgt_cv() - b)^c)
                                          + d * abs((wgt_skewness() - e)^f)
                                          + g * abs((wgt_kurtosis() - h)^i)
                                          + j * abs((wgt_max() - k)^l)

        The default is a zero-length matrix (cvopt=J(1, 0, .)),
        meaning that the loss function is unmodified.

real rowvector P.ipw(| stat)

    Fits a logit regression model and then computes predicted values
    (propensity scores). Propensity scores are then used to compute IPW
    weights, and the weights are applied to the class instance. stat is
    defined the same as in solve().

    This function is a synonym for
        : P.psweight(stat, "ipw")

real rowvector P.cbps(| stat, denominator)

    Computes just-identified covariate-balancing propensity scores (Imai and
    Ratkovic 2014). Propensity scores are then used to compute IPW weights,
    and the weights are applied to the class instance. stat and denominator
    are defined the same as in solve().

    This function is a synonym for
        : P.psweight(stat, "cbps", denominator)

real rowvector P.cbpsoid(| stat, denominator)

    Computes over-identified covariate-balancing propensity scores (Imai and
    Ratkovic 2014). Propensity scores are then used to compute IPW weights,
    and the weights are applied to the class instance. stat and denominator
    are defined the same as in solve().

    This function is a synonym for
        : P.psweight(stat, "cbpsoid", denominator)

P.solve(), P.ipw(), P.cbps(), and P.cbpsoid() will detect any maximization
options stored in the Stata local mlopts (if present); see {help mlopts}.


{marker funct3}{...}
{bf:Post-estimation functions}:

void P.reweight(| w,  p)

    Updates the class instance's (private) member variables with the supplied
    matching weights (w) and propensity scores (p).

    After reweight(), subsequent functions (e.g., to construct the balance
    table) will use the reweighted sample.

    w is treated as a set of matching weights; they will be multiplied by the
    sample weights (if sample weights exist).

    The function does not normalize the weights, w;
    weights should be normalized before calling reweight().

    If no arguments are provided, the matching weights are reset (that is, the
    matching weights are set to one, and the propensity scores are set to
    missing).

    There is no need to call reweight() when estimating IPW weights. Newly
    calculated IPW weights will automatically be applied to the class instance.

real colvector P.get_pscore()

    Returns the propensity scores (predicted values from the propensity score
    model).

real colvector P.get_weight_mtch()

    Returns the matching weights.

    When weights are constructed through solve(), ipw(), cbps(), or cbpsoid(),
    the matching weights are normalized to have mean equal to 1 in each group.
    (If sample weights are provided, the weights are normalized so the weighted
    mean equals 1 in each group.)

real colvector P.get_weight()

    Returns the final weights.

    The final weights are the matching weights times the sample weights (if
    any). The variable final weights equal the matching weights no sample
    weights are provided.

void P.fill_vars(varnames, | tousevar)

    Copies the class instance's IPW weights and propensity scores into Stata
    data.

    varnames contains the names of four new variables to be updated in the
    Stata data.
        The first variable will receive the final weight (typically _weight)
        The second variable will receive the matching weight
            (typically _weight_mtch)
        The third variable will receive the propensity scores
            (typically _pscore)
        The fourth variable will receive the treatment indicator
            (typically _treated)
    tousevar is a variable that must contain values 0 or 1, representing the
    rows to include (1) or exclude (0). (optional)

real rowvector P.pomean()

   Returns the (weighted) mean of the dependent variable(s) for the control
   group.

   This function requires that a dependent variable exist.

   This function is really only useful after computing ATET weights.


{marker funct4}{...}
{bf:Functions to assess balance (comparing the treatment and control groups)}:

real matrix P.balancetable(| denominator)

    Returns the balance table, a k x 6 matrix:
            first column:   mean for the treatment group
            second column:  mean for the control group
            third column:   difference in means (=diff())
            fourth column:  standardized differences (=stddiff(denominator))
            fifth column:   the standard deviation (denominator) used to
                              compute the standardized difference
                              (=stddiff(denominator):/diff())
            sixth column:   the ratio of variances (treatment variance:/control
                              variance), (=varratio(denominator))

    The table is also returned to Stata in r(bal).

real rowvector P.diff()

    Returns the difference in means between the treatment and control groups
    for each variable in tmvarlist.

    The vector is also returned to Stata in r(diff).

real rowvector P.stddiff(| denominator)

    Returns the standardized difference in means between the treatment and
    control groups for each variable in tmvarlist.

    The vector is also returned to Stata in r(stddiff).

real rowvector P.varratio()

    Returns the ratio of variances (treatment variance :/ control variance).

    The vector is also returned to Stata in r(varratio).

real scalar P.mean_sd(| denominator)

    Returns the average of the standardized differences,
      mean(stddiff(denominator)').

    The value is also returned to Stata in r(mean_sd).

    Sometimes you may see r(mean_sd_sq). That value is just r(mean_sd)^2.

real scalar P.mean_asd(| denominator)

    Returns the average of the absolute standardized differences,
      mean(abs(stddiff(denominator))').

    The value is also returned to Stata in r(mean_asd).

real scalar P.max_asd(| denominator)

    Returns the maximum absolute standardized difference,
      max(abs(stddiff(denominator))').

    The value is also returned to Stata in r(max_asd).

real rowvector P.progdiff(| denominator)

    Returns the prognostic score balance table, an L x 5 matrix:
            first column:   mean prognostic score for the treatment group
            second column:  mean prognostic score for the control group
            third column:   difference in mean prognostic scores
            fourth column:  standardized differences, stddiff(denominator)
            fifth column:   the actual mean of the dependent variables in the
                               control group

    Prognostic scores are generated by: regressing depvar on the tmvarlist
    using OLS and the control group's data, then computing predicted values
    (prognostic scores) for all observations.

    The table is also returned to Stata in r(progdiff).

    This function requires that a dependent variable exist.


{marker funct5}{...}
{bf:Functions to summarize the distribution of the IPW weights}:

real scalar P.wgt_cv(stat)

    Returns the coefficient of variation of the IPW weights.
    The coefficient of variation equals the standard deviation of the weights
    divided by their mean.

    The value is also returned in Stata in r(wgt_cv).

real scalar P.wgt_sd(stat)

    Returns the standard deviation of the IPW weights.

    The value is also returned in Stata in r(wgt_sd).

real scalar P.wgt_skewness(stat)

    Returns the skewness of the IPW weights.

    The value is also returned in Stata in r(wgt_skewness).

real scalar P.wgt_kurtosis(stat)

    Returns the excess kurtosis of the IPW weights.

    The value is also returned in Stata in r(wgt_kurtosis).

real scalar P.wgt_max(stat)

    Returns the maximum value of the IPW weights.

    The value is also returned in Stata in r(wgt_max).


{marker funct6}{...}
{bf:Miscellaneous functions}:

void P.balanceresults(| stat, denominator)

    This function is a one-stop shop to call a selection of the functions
    defined above. The balance table (balancetable()) is always computed. The
    weight distribution is summarized if any of the current IPW weights do not
    equal 1. The prognostic scores are compared (progdiff()) if a dependent
    variable exists.

    Depending on which functions were called, results will be returned to
    Stata in r().

void P.clone(src)

    Clones variables in src into the current instance of the class, but
    nothing related to weighting/analyses. (Matching weights are reset to 1
    and sample sizes are recalculated.) Any views will be turned into regular
    Mata variables.

    The last line of code in this example will produce an unweighted balance
    table:
        : P1 = P2 = psweight()
        : P1.st_set(...)
        : P1.cbps(...)
        : P1.balancetable()
        : P2.clone(P1)
        : P2.balancetable()

real matrix P.get_N(| s)

    Returns a 3x3 matrix with sample sizes and the sum of the weights (if any).

        The first  column refers to the treatment group
        The second column refers to the control group
        The third  column refers to the pooled sample

        The first  row contains the number of observations (rows) in the data
        The second row contains the sum of the sample weights.
        The third  row contains the sum of the final weights.
        (For unweighted data, the three rows will be identical.)

    The matrix is also returned in Stata in r(N_table).

    Further, the individual cells from the table are also returned in Stata
    in r():

        r(N1_raw)     number of observations (rows) for the treatment group
        r(N0_raw)     number of observations (rows) for the control group
        r(N_raw)      number of observations (rows) for the pooled sample

        r(sum_sw_1)   sum of the sample weights for the treatment group
        r(sum_sw_0)   sum of the sample weights for the control group
        r(sum_sw)     sum of the sample weights for the pooled sample

        r(sum_w_1)    sum of weights for the treatment group
        r(sum_w_0)    sum of weights for the control group
        r(sum_w)      sum of weights for the pooled sample

    The r(N_table) matrix is displayed if s is nonmissing and is nonzero.


{marker conformability}{...}
{title:Conformability}

    t                 : n x 1   real
    x                 : n x k   real
    w                 : n x 1   real
    y0                : n0 x l  real, where n0 is the number of rows with t==0
    newweight         : n x 1   real
    colvector         : n x 1   real

    denominator       : 1 x 1   real
    stat              : 1 x 1   string
    subcmd            : 1 x 1   string
    cvopt             : 1 x 3, 1 x 6, 1 x 9, or 1 x 12 real

    src               : scalar, instance of class psweight

    solve()           : 1 x k   real
    ipw()             : 1 x k   real
    cbps()            : 1 x k   real
    cbpsoid()         : 1 x k   real

    get_pscore()      : n x 1   real
    get_weight_mtch() : n x 1   real
    get_weight()      : n x 1   real
    get_N()           : 3 x 3   real

    balancetable()    : k x 6   real
    diff()            : 1 x k   real
    stddiff()         : 1 x k   real
    varratio()        : 1 x k   real

    progdiff()        : 1 x l   real
    stdprogdiff()     : 1 x l   real
    pomean()          : 1 x l   real

    mean_sd()         : 1 x 1   real
    mean_asd()        : 1 x 1   real
    max_asd()         : 1 x 1   real

    wgt_cv()          : 1 x 1   real
    wgt_sd()          : 1 x 1   real
    wgt_skewness()    : 1 x 1   real
    wgt_kurtosis()    : 1 x 1   real
    wgt_max()         : 1 x 1   real

{marker examples}{...}
{title:Examples}

  //  Setup
  . webuse cattaneo2, clear
  . gen byte touse=1

  mata:

    // Create an instance of the class, tell it where the data are
    P = psweight()
    P.st_set("mbsmoke", "mmarried mage fbaby medu", "touse")

    //  Balance before reweighting
    P.balancetable(2)

    // Estimate the ATE of smoking on birthweight,
    // using a logit model to predict treatment status
    P.ipw()
    P.balanceresults("ate", 1)

    //  Estimate the ATET with CBPS
    P.cbps("atet")
    P.balanceresults("atet", 1)

    //  Estimate the ATET with Penalized CBPS
    P.solve("atet", "cbps", 2, (1, .5, 6))
    P.balanceresults("atet", 1)

  end


{marker author}{...}
{title:Author}

By Keith Kranker,
Mathematica Policy Research

Please refer to the citations and ackowledgements in {helpb psweight}.

{marker source}{...}
{title:Source code}

{view psweight.mata}
