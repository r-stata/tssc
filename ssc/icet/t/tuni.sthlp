{smcl}
{* *! version 1.1  28may2015}{...}
{vieweralsosee "[MI] mi impute" "help mi_impute"}{...}
{vieweralsosee "[MI] mi impute pmm" "help mi_impute_pmm"}{...}
{vieweralsosee "[MI] mi impute truncreg" "help mi_impute_truncreg"}{...}
{vieweralsosee "[MI] mi estimate" "help mi_estimate"}{...}
{viewerjumpto "Options" "tuni##options"}{...}
{viewerjumpto "Remarks" "tuni##remarks"}{...}
{viewerjumpto "Examples" "tuni##examples"}{...}
{title:Title}

{phang}
{bf:tuni} {hline 2} Univariate imputation of one-dimensional fractional polynomial (FP1) functions


{title:Syntax}

{p 8 15 2} {cmd:tuni} {help varname:incomplete_var} [{help varlist:complete_vars}] [{help weight: weight}] [{cmd:,} {it:options}]

{synoptset 24 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt :{opt method(pmm/truncreg)}}Specifies the method by which x^p* will be imputed. Only {opt pmm} and {opt truncreg} are valid; {opt method()} is a required option{p_end}
{synopt :{opt knn(#)}}Specifies the number of donors to be used by {opt pmm}. {opt knn} can only be used with {opt method(pmm)}. Default is 10{p_end}
{synopt :{opt trunc:val(#)}}Specifies the lower limit value at which imputed values of {help varname:incomplete_var} are to be truncated. {opt truncval} can only be used with {opt method(truncreg)}. Default is 0.1{p_end}
{synopt :{opt powers(#(#)#)}}Candidate powers of {help varname:incomplete_var} to be considered; must be specified using the #(#)# syntax; default is -2(0.2)3 {p_end}
{synopt :{opt boot:strap(#)}}Uses the bootstrap option of {help mi_impute_chained:mi impute chained} to draw parameters; this may cause problems when used with {opt method(truncreg)} {p_end}
{synopt :{opt noi:sily}}Displays the draw of p* for each imputation{p_end}
{p2coldent :* {opt add(#)}}Specify number of imputations to add; required with 
no imputations{p_end}
{p2coldent:* {opt replace}}Replace imputed values in existing 
imputations{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt add(#)} is required when no imputations exist; 
{opt add(#)} or {cmd:replace} is required if imputations exist.{p_end}
{p 4 6 2}
Data must be {cmd:mi set} before using {cmd:tuni};
see {manhelp mi_set MI:mi set}. Note that {help varname:incomplete_var} must be registered as passive. {p_end}


{title:Description}

{pstd}
{cmd:tuni} multiply imputes missing values of {help varname:incomplete_var} allowing for an analysis model that
includes first-dimension fractional polynomial functions of {help varname:incomplete_var}. Denote
{help varname:incomplete_var} x. The analysis model will consider various power transformations x^p, usually
p = -2, -1, -.5, log(x), .5, 1, 2 or 3. The value of p is an unknown parameter and therefore the imputation
model allows for this uncertainty via the approximate Bayesian bootstrap when imputing x.

{pstd}
Technically, the imputation process involves drawing a bootstrap sample of the data before fitting models
for a series of Box-Tidwell power transformations of x, x^p, for p = -2(.2)3. The value of p, denoted p*,
which provides the best fit in the boostrap sample is used for imputation, and x (or rather x^1) is
passively imputed from x^p*.


{marker options}{...}
{title:Options}

{phang}
{opt method(pmm/truncreg)} defines the {it:{help mi_impute##methods:method}} for imputing x^p* before passively imputing x*.

{phang}
{opt add(#)} specifies the number of imputations to add to {cmd:mi} data.
This option is required if there are no imputations in the data. If
imputations exist, then {cmd:add()} is optional. The total number of
imputations must not exceed 1,000.

{phang}
{opt replace} specifies to replace existing imputed values with new ones. One
of {cmd:replace} or {cmd:add()} must be specified when {cmd:mi} data already
have imputations.

{phang}
{cmd:truncval} specifies the lower limit for left truncation. Fractional polynomial functions can only be calculated from
positive values, it is therefore important that negative values are not imputed. The value specified is transformed to the
scale of x^p before {help mi_impute_truncreg:mi impute truncreg} is invoked.

{phang}
{cmd:noisily} specifies that draws of p* be displayed for each imputation. 

{phang}
{cmd:bootstrap} specifies that posterior estimates of model parameters in {help mi_impute_truncreg:mi impute truncreg}
be obtained using sampling with replacement; that is, posterior estimates are estimated from a bootstrap sample. The
default is to sample the estimates from the posterior distribution of model parameters or from the large-sample normal
approximation of the posterior distribution. This option is useful when asymptotic normality of parameter estimates is
suspect. CAUTION: the option is currently problematic; inspect imputed values carefully after using it.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:tuni} multiply imputes missing values of an incomplete variable which is to be included in the analysis
as a one-dimensional fractional polynomial function.

{pstd}
This is achieved by using the approximate Bayesian bootstrap to draw a value of p, denoted p* before
imputing x^p* and passively imputing x^1.

{pstd}
{cmd:tuni} works with Stata's {help mi:mi} formats; data must be {help mi_set:mi set} before using {cmd:tuni}.
In particular, {help varname:incomplete_var} must be registered as passive. It is good practice to register
{help varlist:complete_vars} as regular.


{title:References}

{pstd}
Morris TP, White IR, Carpenter JR, Stanworth SJ, Royston P.
Combining fractional polynomial model building with multiple imputation.
Statistics in Medicine, 2015.


{title:Author}

{pstd}
Tim Morris, MRC Clinical Trials Unit at UCL, London UK{break}
tim.morris@ucl.ac.uk


{title:Acknowledgement}

{pstd}
I am grateful to Ian White. This idea was his as well as mine.


{title:Also see}

    {helpb mi impute}
    {helpb mi impute pmm}
    {helpb mi impute truncreg}
    {helpb mi estimate}
