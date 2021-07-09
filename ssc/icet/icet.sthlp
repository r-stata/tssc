{smcl}
{* *! version 1.1  28May2015}{...}
{vieweralsosee "tuni" "help uni"}{...}
{vieweralsosee "[MI] mi impute" "help mi_impute"}{...}
{vieweralsosee "[MI] mi impute chained" "help mi_impute_chained"}{...}
{vieweralsosee "[MI] mi impute pmm" "help mi_impute_pmm"}{...}
{vieweralsosee "[MI] mi impute truncreg" "help mi_impute_truncreg"}{...}
{vieweralsosee "[MI] mi estimate" "help mi_estimate"}{...}
{viewerjumpto "Options" "icet##options"}{...}
{viewerjumpto "Remarks" "icet##remarks"}{...}
{viewerjumpto "Examples" "icet##examples"}{...}
{title:Title}

{phang}
{bf:icet} {hline 2} Imputation for degree-one fractional polynomial (FP1) functions


{title:Syntax}

{p 8 15 2} {cmd:icet} {help varname:incomplete_vars} [{help weight: weight}] [{cmd:,} {it:options}]

{synoptset 24 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{synopt :{opt add(#)}}Specifies number of imputations. Default is 5.{p_end}
{synopt :{opt boot:strap(#)}}Uses the bootstrap to draw parameters.{p_end}
{synopt :{opt comp(complete_vars)}}Specifies fully observed variables to be included as covariates in the imputation models.{p_end}
{synopt :{opt cycles(#)}}Specifies number of cycles of chained equations before imputations are stored. Default is 10.{p_end}
{synopt :{opt eqd:isplay}}Displays the equations used for the univariate imputation models.{p_end}
{synopt :{opt knn(#)}}Specifies the number of donors to be used by {opt pmm}. Default is 10.{p_end}
{synopt :{opt method(pmm/truncreg)}}Specifies the method by which x^p* will be imputed. Only {opt pmm} and {opt truncreg} are valid.{p_end}
{synopt :{opt noi:sily}}Displays the draw of p* for each imputation.{p_end}
{synopt :{opt p:owers(#(#)#)}}Candidate powers of {help varname:incomplete_vars} to be considered; must be specified using the range (#(#)#) syntax; default is -2(0.2)3.{p_end}
{synopt :{opt trunc:val(#)}}Specifies the lower limit value at which imputed values of {help varname:incomplete_var} are to be truncated. Default is 0.1.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Data should be {cmd:mi set} before using {cmd:icet}; see {manhelp mi_set MI:mi set}. However, variables
do not need to be {cmd:mi registered}; see {manhelp mi_set MI:mi register}.

{p 4 6 2}
{opt incomplete_vars} must take strictly positive values. If there are negative or zero values, {cmd:icet}
will return an error and requst that you choose a preliminary transformation (e.g. add a constant to all values).


{title:Description}

{pstd}
{cmd:icet} multiply imputes missing values of {help varname:incomplete_vars} using chained equations,
allowing for an analysis model that includes first-dimension fractional polynomial functions of
{help varname:incomplete_var}. Denote {help varname:incomplete_var} x. The analysis model will consider
various power transformations x^p, usually p = -2, -1, -.5, log(x), .5, 1, 2 or 3. The value of p is an
unknown parameter; the imputation model allows for this uncertainty via the approximate Bayesian bootstrap.

{pstd}
{cmd:icet} works by repeatedly calling the {cmd:tuni} command. Technically, the imputation process used by
{cmd:tuni} involves drawing a bootstrap sample of the data before fitting models for a series of Box-Tidwell
power transformations of x, denoted x^p, for p = -2(.2)3. The value of p, denoted p*, which provides the best
fit in the boostrap sample is used for imputation, and x (or rather x^1) is passively imputed from x^p* in preparation for analysis.


{marker options}{...}
{title:Options}

{phang}
{opt comp(complete_varlist)} gives the names of fully observed variables to be included as covariates in the 

{phang}
{opt method(pmm/truncreg)} defines the method for imputing x^p* before passively imputing x*.

{phang}
{opt knn(#)} specifies the number of donors if the pmm method is used, as described in
{help mi_impute_pmm:mi impute pmm}. Do not use knn(1); this caution is not specific to
use with {cmd:icet}.

{phang}
{opt add(#)} specifies the number of imputations to create. Any existing imputations are replaced. The
total number of imputations must not exceed 1,000.

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
suspect. Caution: the option can be problematic when used in conjunction with method(truncreg); take care to inspect
imputed values properly after using it.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:icet} multiply imputes missing values of an incomplete variable which is to be included in the analysis
as a one-dimensional fractional polynomial function. For two or more dimensions, there will be a degree of bias
induced by PMM, though of the current methods PMM is less biased than any other.

{pstd}
This is achieved by using the approximate Bayesian bootstrap to draw a value of p, denoted p* before
imputing x^p* and passively imputing x^1.

{pstd}
{cmd:icet} works with Stata's {help mi_set:mi formats}; data must be {help mi_set:mi set} before using {cmd:icet}.


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
