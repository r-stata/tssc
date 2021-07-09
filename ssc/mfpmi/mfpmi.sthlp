{smcl}
{* *! version 1.1.0  10apr2015}{...}
{vieweralsosee "[MI] mim" "help mim"}{...}
{vieweralsosee "[MI] mi estimate" "help mi_estimate"}{...}
{vieweralsosee "[MI] mi impute" "help mi_impute"}{...}
{viewerjumpto "Options" "mfpmi##options"}{...}
{viewerjumpto "Remarks" "mfpmi##remarks"}{...}
{viewerjumpto "Examples" "mfpmi##examples"}{...}
{cmd:help for mfpmi, mfpmi_wald}{right:Patrick Royston}
{hline}


{title:Title}

{phang}
{cmd:mfpmi} {hline 2} Multivariable fractional polynomial models for multiply imputed data based on likelihood-ratio type tests

{phang}
{cmd:mfpmi_wald} {hline 2} Multivariable fractional polynomial models for multiply imputed data based on Wald type tests


{title:Syntax}

{phang2}
{cmd:mfpmi} [, {it:options}]
{cmd::} 
{it:{help mfpmi##syntax:regression_cmd}}
[{it:{help mfpmi##syntax:yvar1}} [{it:{help mfpmi##syntax:yvar2}}]]
{it:{help mfpmi##syntax:xvarlist}}
{ifin}
{weight}
[{cmd:,} {it:regression_cmd_options}]

{phang2}
{cmd:mfpmi_wald} [, {it:options}]
{cmd::} 
{it:{help mfpmi##syntax:regression_cmd}}
[{it:{help mfpmi##syntax:yvar1}} [{it:{help mfpmi##syntax:yvar2}}]]
{it:{help mfpmi##syntax:xvarlist}}
{ifin}
{weight}
[{cmd:,} {it:regression_cmd_options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model 2}
{synopt :{opt seq:uential}}use the Royston and Altman model-selection algorithm;
default uses closed-test algorithm{p_end}
{synopt :{opt cyc:les(#)}}maximum number of iteration cycles; default is
{cmd:cycles(5)}{p_end}
{synopt :{opt dfd:efault(#)}}default maximum degrees of freedom; default is
{cmd:dfdefault(4)}{p_end}
{synopt :{opt cent:er(cent_list)}}specification of centering for the indepdent variables{p_end}
{synopt :{opt df(df_list)}}degrees of freedom for each predictor{p_end}
{synopt :{opt po:wers(numlist)}}list of fractional polynomial powers to use;
default is {bind:{cmd:powers(-2 -1(.5)1 2 3)}}{p_end}

{syntab :Adv. model}
{synopt :{cmdab:xo:rder(+}|{cmd:-}|{cmd:n)}}order of entry into model-selection
algorithm; default is {cmd:xorder(+)}{p_end}
{synopt :{opt sel:ect(select_list)}}nominal p-values for selection on each
predictor{p_end}
{synopt :{opt xp:owers(xp_list)}}fractional polynomial powers for each
predictor{p_end}
{synopt :{opth zer:o(varlist)}}treat nonpositive values of specified predictors
as zero when FP is transformed{p_end}
{synopt :{opth cat:zero(varlist)}}add indicator variable for specified
predictors{p_end}
{synopt :{it:regression_cmd_options}}other options accepted by chosen
regression commands{p_end}

{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt all}}include
	out-of-sample observations in generated variables{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
All weight types supported by {it:regression_cmd} are allowed; see {help weight}.{p_end}
{p 4 6 2}
{opt fracgen} may be used to create new variables containing fractional
polynomial powers.  See {helpb fracpoly:[R] fracpoly}.{p_end}

{pstd}
{marker syntax}where

{pin}
{it:regression_cmd} may be
{helpb clogit},
{helpb cnreg},
{helpb glm},
{helpb intreg}, 
{helpb logistic},
{helpb logit},
{helpb mlogit},
{helpb nbreg},
{helpb ologit},
{helpb oprobit},
{helpb poisson},
{helpb probit},
{helpb qreg},
{helpb regress},
{helpb stcox},
{helpb stcrreg},
{helpb streg},
or
{helpb xtgee}.

{pin}
{it:yvar1} is not allowed for {opt streg} and {opt stcox}.  For these commands,
you must first {helpb stset} your data.

{pin}
{it:yvar1} and {it:yvar2} must both be specified when {it:regression_cmd} is
{opt intreg}.

{pin}
{it:xvarlist} has elements of type {varlist} and/or {opt (varlist)};
e.g.,

{pin2}
{cmd:x1 x2 (x3 x4 x5)}

{pin}
Elements enclosed in parentheses are tested jointly for inclusion in the
model and are not eligible for fractional polynomial transformation.


{title:Description}

{pstd}
{cmd:mfpmi} and {cmd:mfpmi_wald} select fractional polynomial (FP) models that best
predicts the outcome variable from the right-hand-side variables in {it:xvarlist}.
The data are assumed to be multiply imputed and stored in a format compatible with 
{help ice} and {help mim}. Also supported are Stata {help mi_set:mi styles}.

{pstd}
The two commands differ in the testing procedure used. {cmd:mfpmi} selects an FP model
based on a version of likelihood-ratio tests modified for multiply imputed data (see
Wood, White and Royston, 2008). {cmd:mfpmi_wald} selects an FP model based on Wald
statistics and, for non-nested hypotheses, the difference in Wald statistics (see
Morris et al. 2015).


{marker options}{...}
{title:Options}
{dlgtab:Model 2}

{phang}
{opt sequential} chooses the sequential FP selection algorithm.

{phang}
{opt cycles(#)} sets the maximum number of iteration cycles
    permitted.  {cmd:cycles(5)} is the default.

{phang}
{opt dfdefault(#)} determines the default maximum degrees of
    freedom (df) for a predictor. The default is {cmd:dfdefault(4)}
    (second-degree FP).

{phang}
{opt center(cent_list)}
defines the centering of the covariates {it:xvar1}, {it:xvar2}, ... of
    {it:xvarlist}.  The default is {cmd:center(mean)}, except for binary
    covariates, where it is {opt center(#)}, with {it:#} being the lower
    of the two distinct values of the covariate.
    A typical item in {it:cent_list} is
    {it:varlist}{cmd::}{c -(}{opt mean}|{it:#}|{opt no}{c )-}.
    Items are separated by commas.  The first item is special in that
    {it:varlist} is optional, and if it is omitted, the default is reset to
    the specified value ({opt mean}, {it:#}, or {opt no}).  For example,
    {cmd:center(no, age:mean)} sets the default to {opt no} (i.e., no
    centering) and the centering for {opt age} to {opt mean}.

{phang}{marker df}
{opt df(df_list)}
    sets the degrees of freedom (df) for each predictor. The df (not
    counting the regression constant, {cmd:_cons}) are twice the degree of the
    FP, so, for example, an {it:xvar} fitted as a second-degree FP (FP2) has 4
    df.  The first item in {it:df_list} may be either {it:#} or
    {varlist}{cmd::}{it:#}.  Subsequent items must be
    {it:varlist}{cmd::}{it:#}.  Items are separated by commas, and
    {it:varlist} is specified in the usual way for variables.  With the first
    type of item, the df for all predictors are taken to be {it:#}.  With the
    second type of item, all members of {it:varlist} (which must be a subset
    of {it:xvarlist}) have {it:#} df.

{pmore}
    The default number of degrees of freedom for a predictor of type
    {it:varlist} specified in {it:xvarlist} but not in {it:df_list} is
    assigned according to the number of distinct (unique) values of the
    predictor, as follows:

            {hline 43}
            # of distinct values    default df
            {hline 43}
                      1             (invalid predictor)
                     2-3            1
                     4-5            min(2, {opt dfdefault()})
                     {ul:>}6             {opt dfdefault()}
            {hline 43}

{pmore}
    Example:  {cmd:df(4)}{break}
    All variables have 4 df.

{pmore}
    Example:  {cmd:df(2, weight displ:4)}{break}
    {opt weight} and {opt displ} have 4 df; all other variables have 2 df.

{pmore}
    Example:  {cmd:df(weight displ:4, mpg:2)}{break}
    {opt weight} and {opt displ} have 4 df, {opt mpg} has 2 df, all other
    variables have default df.

{phang}{marker powers}
{opth powers(numlist)} is the set of fractional polynomial powers to
    be used. The default set is -2, -1, -0.5, 0, 0.5, 1, 2, 3 (0 means log).

{dlgtab:Adv. model}

{phang}
{cmd:xorder(+}|{cmd:-}|{cmd:n)}
    determines the order of entry of the covariates into the model-selection
    algorithm. The default is {cmd:xorder(+)}, which enters them in decreasing
    order of significance in a multiple linear regression (most significant
    first). {cmd:xorder(-)} places them in reverse significance order, whereas
    {cmd:xorder(n)} respects the original order in {it:xvarlist}.

{phang}
{opt select(select_list)}
    sets the nominal p-values (significance levels) for variable selection by
    backward elimination.  A variable is dropped if its removal causes a
    nonsignificant increase in deviance.  The rules for {it:select_list} are
    the same as those for {it:df_list} in the {helpb mfpmi##df:df()} option.
    Using the default selection level of 1 for all variables forces them all
    into the model.  Setting the nominal p-value to be 1 for a given variable
    forces it into the model, leaving others to be selected or not. The
    nominal p-value for elements of {it:xvarlist} bound by parentheses is
    specified by including {opt (varlist)} in {it:select_list}.

{pmore}
    Example:  {cmd:select(0.05)}{break}
    All variables have a nominal p-value of 5%.

{pmore}
    Example:  {cmd:select(0.05, weight:1)}{break}
    All variables except {opt weight} have a nominal p-value of 5%;
    {opt weight} is forced into the model.

{pmore}
    Example:  {cmd:select(a (b c):0.05)}{break}
    All variables except {opt a}, {opt b}, and {opt c} are forced into the
    model.  {opt b} and {opt c} are tested jointly with 2 df at the 5%
    level, and {opt a} is tested singly at the 5% level.

{phang}
{opt xpowers(xp_list)}
    sets the permitted fractional polynomial powers for covariates
    individually.  The rules for {it:xp_list} are the same as for {it:df_list}
    in the {helpb mfpmi##df:df()} option. The default selection is the same as
    those for the {helpb mfpmi##powers:powers()} option.

{pmore}
    Example:  {cmd:xpowers(-1 0 1)}{break}
    All variables have powers -1, 0, 1.

{pmore}
    Example:  {cmd:xpowers(x5:-1 0 1)}{break}
    All variables except {cmd:x5} have default powers; {cmd:x5} has powers
    -1, 0, 1.

{phang}
{opth zero(varlist)}
    treats negative and zero values of members of {it:varlist} as zero
    when FP transformations are applied.  By default, such variables are
    subjected to a preliminary linear transformation to avoid negative and zero
    values (see {manhelp fracpoly R}).  {it:varlist} must be part of
    {it:xvarlist}.

{phang}
{opth catzero(varlist)}
    is a variation on {opt zero()}.  {it:varlist} must be part of
    {it:xvarlist}.

{phang}
{it:regression_cmd_options} may be any of the options appropriate to
    {it:{help mfpmi##syntax:regression_cmd}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}
specifies the confidence level, as a percentage, for confidence intervals.
The default is {cmd:level(95)} or as set by {helpb set level}.

{phang}
{cmd:all} includes out-of-sample observations when generating the 
FP variables.
By default, the generated FP variables contain missing values outside
the estimation sample.


{marker remarks}{...}
{title:Remarks}

{pstd}
For elements in {it:xvarlist} not enclosed in parentheses, {cmd:mfpmi} leaves
variables in the data named {cmd:I}{it:xvar}{cmd:__1},
{cmd:I}{it:xvar}{cmd:__2}, ...,  where {it:xvar} represents the first four
letters of the name of {it:xvar1}, and so on for {it:xvar2}, {it:xvar3}, etc.
The new variables contain the best-fitting fractional polynomial powers of
{it:xvar1}, {it:xvar2}, ....


{marker examples}{...}
{title:Examples}

{pstd}
The below example illustrates the use of the {cmd:mfpmi} and {cmd:mfpmi_wald} commands
for the {help mi##example:simple example} given in the help for 
{help mi:mi}. The imputation is inappropriate for fractional polynomials.

{hline}
{pstd}
{...}
{...}
{...}
{...}
{txt}Use Fictional heart attack data (bmi and age are incomplete). Impute data using a
naive imputation model and add{break}
{com}. webuse mheart5{break}
{com}. mi set mlong{break}
{com}. mi register imputed age bmi{break}
{com}. mi impute chained (pmm, knn(10)) age bmi = attack smokes hsgrad female, add(10) rseed(29390)'{break}
{txt}Select an MFP model in MI data using Wald and difference-in-Wald tests; all options default.{break}
{com}. mfpmi_wald: logistic attack smokes age bmi hsgrad female{break}
{txt}Select an MFP model in MI data using weighted likelihood-ratio tests.{break}
{com}. mfpmi: logistic attack smokes age bmi hsgrad female {txt}

{hline}


{title:Saved results}

{pstd}
In addition to what {it:regression_cmd} saves, {cmd:mfpmi} saves the following
in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(fp_nx)}}number of predictors in {it:xvarlist}{p_end}
{synopt:{cmd:e(fp_dev)}}deviance of final model fitted{p_end}
{synopt:{cmd:e(Fp_id}{it:#}{cmd:)}}initial degrees of freedom for the {it:#}th element of
{it:xvarlist}{p_end}
{synopt:{cmd:e(Fp_fd}{it:#}{cmd:)}}final degrees of freedom for the {it:#}th element of
{it:xvarlist}{p_end}
{synopt:{cmd:e(Fp_al}{it:#}{cmd:)}}FP selection level for the {it:#}th element of
{it:xvarlist}{p_end}
{synopt:{cmd:e(Fp_se}{it:#}{cmd:)}}backward elimination selection level for the {it:#}th
element of {it:xvarlist}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(fp_cmd)}}{cmd:fracpoly}{p_end}
{synopt:{cmd:e(fp_cmd2)}}{cmd:mfpmi}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(fp_fvl)}}variables in final model{p_end}
{synopt:{cmd:e(fp_depv)}}{it:yvar1} ({it:yvar2}){p_end}
{synopt:{cmd:e(fp_opts)}}estimation command options{p_end}
{synopt:{cmd:e(fp_x1)}}first variable in {it:xvarlist}{p_end}
{synopt:{cmd:e(fp_x2)}}second variable in {it:xvarlist}{p_end}
{synopt:...}{p_end}
{synopt:{cmd:e(fp_x{it:N})}}last variable in {it:xvarlist}, N={cmd:e(fp_nx)}
{p_end}
{synopt:{cmd:e(fp_k1)}}power for first variable in {it:xvarlist} (*){p_end}
{synopt:{cmd:e(fp_k2)}}power for second variable in {it:xvarlist} (*){p_end}
{synopt:...}{p_end}
{synopt:{cmd:e(fp_k{it:N})}}power for last var. in {it:xvarlist} (*),
               N={cmd:e(fp_nx)}{p_end}

{pstd}
Note: (*) contains `.' if variable is not selected in final model.
{p2colreset}{...}


{title:Authors}

{pstd}Patrick Royston, MRC Clinical Trials Unit at UCL, London UK{break}
j.royston@ucl.ac.uk

{pstd}Tim Morris, MRC Clinical Trials Unit at UCL, London UK{break}
tim.morris@ucl.ac.uk


{title:References}

{phang}
Wood AM, White IR, Royston P. How should variable selection be performed with
multiply imputed data? {it:Statistics in Medicine} 2008; 27:3227-3246

{phang}
Morris TP, White IR, Carpenter JR, Stanworth SJ, Royston P. Combining fractional
polynomial model building with multiple imputation. {it:Statistics in Medicine} 2015


{title:Also see}

{psee}
Manual: {manlink R mfp}

{psee}
Online: {manhelp mfp R}; {manhelp fracpoly R}; {helpb ice}; {helpb mim}; {helpb mi_estimate:mi estimate}
{p_end}
 