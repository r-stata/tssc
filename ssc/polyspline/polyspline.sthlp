{smcl}
{hline}
help for {cmd:polyspline}{right:(Roger Newson)}
{hline}


{title:Generate sensible bases for polynomials and other splines}

{p 8 21 2}
{cmd:polyspline} {varname} {ifin} , {opt g:enerate(prefix)}
  [ {cmdab:r:efpts}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {opt p:ower(#)}
    {opt om:it(#)} {opt ba:se(#)}
    {cmdab:inc:lude}{cmd:(}{help numlist:{it:numlist}}{cmd:)}
    {cmdab:t:ype}{cmd:(}{help datatype:{it:type}}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{help format:{it:format}}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}
  ]


{title:Description}

{pstd}
The {cmd:polyspline} package inputs an {it:X}-variable
and a list of reference points on the {it:X}-axis,
and generates a basis of reference splines (one per reference point)
for a polynomial or other unrestricted spline.
This basis can be included in the list of covariates of a regression model.
The estimated parameters will then be values of the spline at the reference points,
or differences between values of the spline at the reference points
and the value of the spline at a base reference point.
{cmd:polyspline} is an easy-to-use front end for the {help ssc:SSC} package {helpb bspline},
which must be installed for {cmd:polyspline} to work.


{title:Options for {cmd:polyspline}}

{p 4 8 2}
{opt generate(prefix)} must be specified.
It specifies a prefix for the names of the generated splines,
which will be named as {it:prefix}{cmd:1}...{it:prefix}{cmd:N},
where {cmd:N} is the number of reference points.

{p 4 8 2}
{cmd:refpts(}{help numlist:{it:numlist}}{cmd:)} specifies a list of at least 2 reference points.
If the generated splines are used in a regression model,
then the fitted parameters will be values of the spline at those points,
or differences between those values and the value of the spline at a base reference point
specified by the {cmd:base()} option or the {cmd:omit()} option.
If {cmd:refpts()} is absent, then the list is initialized to a list of two points,
equal to the minimum and maximum of the completeness range,
which is the range of {it:X}-values
for which the spline basis is valid.

{p 4 8 2}
{opt power(#)} (a positive integer)
specifies the power (or degree) preferred for the generated splines.
Examples are 1 for linear, 2 for quadratic, 3 for cubic, 4 for quartic or 5 for quintic.
If absent, {cmd:power()} is set to {cmd:q-1}, where {cmd:q} is the number of reference points,
implying that the spline in the regression model will simply be a polynomial.
If {cmd:power()} is specified as being equal to, or greater than,
the number of reference points,
then it is revised downwards to be one less than the number of reference points,
because the number of reference points is then too small to define a polyomial
of the power originally requested.

{p 4 8 2}
{cmd:base(#)} is used in {help version:Stata Versions 11 or higher}.
It specifies a reference point,
which must be present in the {cmd:refpts()} list,
and whose corresponding reference spline will be set to zero.
If the user specifies {cmd:base()},
then the set of generated splines will not be a complete basis,
but can be completed by the addition of a constant variable,
equal to 1 in all observations.
The generated splines can then be used in the list of covariates for an estimation command
in {help version:Stata Version 11 or higher},
without the {cmd:nocoonst} option.
The correspondiing parameters will then be differences
between the values of the spline at the reference points
and the value of the spline at the {cmd:base()} reference point.
If the user does not specify a {cmd:base()} or {cmd:omit()} option,
then the regression command should usually have a {cmd:noconst} option.
The corresponding parameters will then simply be values
of the spline at the reference points.

{p 4 8 2}
{cmd:omit(#)} is an alternative to the {cmd:base()} option,
for use in {help version:Stata Version 10}.
It specifies a reference point,
which must be present in the {cmd:refpts()} list,
and whose corresponding reference spline will be omitted from the set of generated splines.
If the user specifies {cmd:omit()},
then the set of generated splines will not be a complete basis,
but can be completed by the addition of a constant variable,
equal to 1 in all observations.
The generated splines can then be used in the list of covariates for an estimation command
in {help version:Stata Version 10},
without the {cmd:nocoonst} option.
The correspondiing parameters will then be differences
between the values of the spline at the reference points
and the value of the spline at the {cmd:omit()} reference point.
If the user does not specify a {cmd:base()} or {cmd:omit()} option,
then the regression command should usually have a {cmd:noconst} option.
The corresponding parameters will then simply be values
of the spline at the reference points.

{p 4 8 2}
{cmd:include(}{help numlist:{it:numlist}}{cmd:)} specifies a list of additional numbers
to be included within the boundaries of the completeness region of the spline basis,
which is the interval on the {it:X}-axis in which the generated splines are valid.
This completeness region will always include the available values of the input {it:X}-variable,
and also the {cmd:refpts()} values.
The {cmd:include()} option allows the user to specify a non-default minimum and/or maximum
for the completeness region.

{p 4 8 2}
{cmd:type(}{help datatype:{it:type}}{cmd:)} specifies the storage type of the generated splines
({cmd:float} or {cmd:double}).
If {cmd:type()} is given as anything else (or not given), then it is set to {cmd:float}.

{p 4 8 2}
{cmd:labfmt(}{help format:{it:format}}{cmd:)} specifies the format to be used
in the variable labels for the generated reference splines.
If absent, then it is set to the format of the input {it:X}-variable.

{p 4 8 2}
{cmd:labprefix(}{it:string}{cmd:)} specifies the prefix to be used
in the variable labels for the generated reference splines.
If absent, then it is set to {cmd:"Spline at "}.


{title:Remarks}

{pstd}
{cmd:polyspline} is described in {help polyspline##polyspline_references:Newson (2014)}.
The splines generated are intended for use in the {varlist} of an estimation
command (eg {helpb regress} or {helpb glm}).
The model whose parameters are estimated
will then be a polynomial
(if the {cmd:power()} option is unspecified or equal to the number of reference points minus one),
or an unrestricted spline of degree specified by the {cmd:power()} option,
with knots interpolated between the reference points
(if the {cmd:power()} option is less than the number of reference points minus one).

{pstd}
If {cmd:polyspline} has no {cmd:base()} or {cmd:omit()} option
and the estimation command has a {cmd:noconst} option,
then the estimated model parameters corresponding to the generated splines
will be values of the polynomial or spline at the reference points.
If {cmd:polyspline} has a {cmd:base()} or {cmd:omit()} option
and the estimation command has no {cmd:noconst} option,
then the estimated parameters corresponding to the generated splines
will be differences between the values of the spline at the reference points
and the value of the spline at the base reference point.
These parameters will be easier to understand
than the usual parameters for a polynomial
(expressed in {it:Y}-axis units per power-raised {it:X}-axis unit),
and will be much easier to understand
than the usual parameters for other unrestricted splines
(usually expressed in even more alien units).

{pstd}
{cmd:polyspline} works by calling the {helpb flexcurv} module of the {helpb bspline} package,
which can be downloaded from {help ssc:SSC}.
The principles and definitions of reference splines, and of the {helpb bspline} package,
are given in detail in {help polyspline##polyspline_references:Newson (2012)} and {help polyspline##polyspline_references:Newson (2011)}.


{title:Technical note}

{pstd}
{cmd:polyspline} works by calling {helpb flexcurv}, using a command of form

{p 8 21 2}
{cmd:flexcurv} {ifin} , {opt xvar(varname)} {opt refpts(refpts)} {opt power(power)}
  {cmd:krule(interpolate)}
  {opt include(include)} {opt omit(omit)} {opt base(base)}
  {opt generate(generate)} {opt type(type)} {opt labfmt(labfmt)} {opt labprefix(labprefix)}

{pstd}
where {it:varname} is the input {it:X}-variable name,
the option value {it:refpts} is the value of the {cmd:refpts()} option of {cmd:polyspline},
the option value {it:power} is the value of the {cmd:power()} option of {cmd:polyspline} if supplied
and the number of reference points minus one otherwise,
and the option values {it:include}, {it:omit}, {it:base},
{it:generate}, {it:type}, {it:labfmt} and {it:labprefix}
are the option values passed to the {cmd:polyspline} options of the same names.


{title:Examples}

{pstd}
These examples demonstrate the fitting of polynomial and other spline models
of {cmd:mpg} with respect to {cmd:weight}
in the {helpb datasets:auto} dataset supplied with official Stata.

{pstd}
Set-up:

{phang2}{inp:. sysuse auto, clear}{p_end}
{phang2}{inp:. describe}{p_end}

{pstd}
The following example generates a bass for a quadratic model,
with parameters equal to the values of the quadratic
at weights of 1500, 3000 and 5000 US pounds.
We then fit the model,
using {helpb regress} with the {cmd:noconst} option.

{phang2}{inp:. polyspline weight, gene(qs_) refpts(1500 3000 5000)}{p_end}
{phang2}{inp:. describe qs_*}{p_end}
{phang2}{inp:. regress mpg qs_*, noconst}{p_end}

{pstd}
The following example generates an alternative incomplete basis for the same quadratic model,
using the {cmd:base()} option to specify a base reference weight of 1500 US pounds.
This time, we fit the model using {helpb regress} without the {cmd:noconst} option.
The parameter for the reference spline at 1500 US pounds is omitted,
because that reference spline is zero in all observations.
The parameter {cmd:_cons} is now the bseline value of {cmd:mpg},
predicted for cars with a weight of 1500 US pounds.
The parameters for the other reference splines are differences between predicted values of {cmd:mpg}
for cars with the corresponding reference weight
and the predicted value of {cmd:mpg}
for cars with the base reference weight.

{phang2}{inp:. polyspline weight, gene(bqs_) refpts(1500 3000 5000) base(1500)}{p_end}
{phang2}{inp:. describe bqs_*}{p_end}
{phang2}{inp:. regress mpg bqs_*}{p_end}

{pstd}
The following example generates another alternative incomplete basis for the same quadratic model,
using the {cmd:omit()} option to specify a base reference weight of 1500 US pounds.
This time, we fit the model using {helpb regress}, again without the {cmd:noconst} option.
However, this time, there is no spline for the omitted base reference weight.
The parameter {cmd:_cons}, and the parameters for the other reference splines,
are interpreted as in the previous example.

{phang2}{inp:. polyspline weight, gene(oqs_) refpts(1500 3000 5000) omit(1500)}{p_end}
{phang2}{inp:. describe oqs_*}{p_end}
{phang2}{inp:. regress mpg oqs_*}{p_end}

{pstd}
The following example generates a basis for a quartic model (degree 4),
with reference points at 1000, 2000, 3000, 4000 and 5000 US pounds,
and a base reference weight of 1000 US pounds.
This time, the parameter {cmd:_cons} is a base value of {cmd:mpg}
for cars weighing 1000 US pounds,
and the parameters for the reference splines are differences in {cmd:mpg}
between cars with the other reference weights
and cars with the base reference weight.

{phang2}{inp:. polyspline weight, gene(o4s_) refpts(1000(1000)5000) base(1000)}{p_end}
{phang2}{inp:. describe o4s_*}{p_end}
{phang2}{inp:. regress mpg o4s_*}{p_end}

{pstd}
The following example uses the same 5 reference weights,
and uses the {cmd:power()} option
to specify a linear spline (degree 1),
instead of a quartic spline (degree 4).
The parameters estimated by {helpb regress}
are interpreted as in the previous example.
However, predicted values are interpolated linearly,
instead of being interpolated quartically.

{phang2}{inp:. polyspline weight, gene(ols_) refpts(1000(1000)5000) base(1000) power(1)}{p_end}
{phang2}{inp:. describe ols_*}{p_end}
{phang2}{inp:. regress mpg ols_*}{p_end}


{title:Saved results}

{pstd}
{cmd:polyspline} saves the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(xsup)}}upper bound of completeness region{p_end}
{synopt:{cmd:r(xinf)}}lower bound of completeness region{p_end}
{synopt:{cmd:r(nincomp)}}number of {it:X}-values out of completeness region{p_end}
{synopt:{cmd:r(nknot)}}number of knots{p_end}
{synopt:{cmd:r(nspline)}}number of splines{p_end}
{synopt:{cmd:r(power)}}power (or degree) of splines{p_end}
{synopt:{cmd:r(omit)}}omitted reference point specified by {cmd:omit()}{p_end}
{synopt:{cmd:r(base)}}base reference point specified by {cmd:base()}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(knots)}}final list of knots{p_end}
{synopt:{cmd:r(refpts)}}final list of reference points{p_end}
{synopt:{cmd:r(splist)}}{it:varlist} of generated splines{p_end}
{synopt:{cmd:r(labfmt)}}format used in spline variable labels{p_end}
{synopt:{cmd:r(labprefix)}}prefix used in spline variable labels{p_end}
{synopt:{cmd:r(type)}}storage type of splines ({cmd:float} or {cmd:double}){p_end}
{synopt:{cmd:r(xvar)}}input {it:X}-variable{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(knotv)}}row vector of knots{p_end}
{synopt:{cmd:r(refv)}}row vector of reference points{p_end}
{p2colreset}{...}

{pstd}
The result {cmd:r(nincomp)} is the number of values of the {cmd:xvar()} variable
outside the completeness region,
and should always be zero.
The number lists {cmd:r(knots)} and {cmd:r(refpts)} are the lists of knots and reference points.
The vectors {cmd:r(knotv)} and {cmd:r(refv)} contain the same values in double precision
(mainly for programmers).
The scalars {cmd:r(xinf)} and {cmd:r(xsup)} are knots,
such that the completeness region is {cmd:r(xinf)} {it:<= x <=} {cmd:r(xsup)}.

{pstd}
In addition, {cmd:polyspline} saves {help char:variable characteristics}
for the output spline basis variables.
The characteristic {it:varname}{cmd:[xvar]} is set
to be equal to the input {it:X}-variable name.
The characteristics {it:varname}{cmd:[xinf]} and {it:varname}{cmd:[xsup]}
are set to be equal to the infimum and supremum, respectively,
of the completeness region.
The characteristic {it:varname}{cmd:[xvalue]} is set
to be equal to the reference point on the {it:X}-axis corresponding to the reference spline.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker polyspline_references}{...}
{title:References}

{phang}
Newson, R. B.  2014.
Easy-to-use packages for estimating rank and spline parameters.
Presented at the {browse "http://ideas.repec.org/p/boc/usug14/01.html":20th UK Stata User Meeting, 11–12 September, 2014}.

{phang}
Newson R. B.  2012.
Sensible parameters for univariate and multivariate splines.
{it:The Stata Journal} 12(3): 479-504.
Download from
{browse "http://www.stata-journal.com/article.html?article=sg151_2"}.

{phang}
Newson R. B.  2011.
Sensible parameters for polynomials and other splines.
Presented at the {browse "http://ideas.repec.org/p/boc/usug11/01.html":17th UK Stata User Meeting, 15-16 September, 2011}.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] mkspline}
{p_end}
{p 4 13 2}
On-line: help for {helpb mkspline}
{break} help for {helpb bspline}, {helpb frencurv}, {helpb flexcurv} if installed
{p_end}
