{smcl}
{* *! version 1.2.10  15may2007}{...}
{cmd:help confa} {right: ({browse "http://www.stata-journal.com/article.html?article=st001":SJ9-3: st001})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:confa} {hline 2}}Confirmatory factor analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:confa}
{it:factorspec} [{it:factorspec ...}]
{ifin}
[{it:weight}]
[{cmd:,} {it:options}]

{pstd}
{it:factorspec} is{p_end}
{p 8 27}
{cmd:(}{it:factorname}{cmd::} {it:varlist}{cmd:)}{p_end}

{synoptset 43 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{cmdab:corr:elated(}{it:corrspec} [{it:corrspec} ...]{cmd:)}}correlated measurement errors; see {help confa##corr:below}{p_end}
{synopt :{cmd:unitvar(}{it:factorlist}|{cmd:_all}{cmd:)}}set variance of the factor(s) to 1{p_end}
{synopt :{opt free}}do not impose any constraints by default; seldom used{p_end}
{synopt :{opt constr:aint(numlist)}}user-supplied constraints;
        must be used with {cmd:free}{p_end}
{synopt: {cmdab:miss:ing}}full-information maximum-likelihood
    estimation with missing data{p_end}
{synopt: {cmdab:usen:ames}}alternative coefficient labeling{p_end}
{syntab:Variance estimation}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be
  {opt r:obust}, {opt cl:uster} {it:clustvar}, {cmd:oim}, {cmd:opg}, or
  {opt sb:entler}{p_end}
{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{syntab:Other}
{synopt :{opt svy}}respect survey settings{p_end}
{synopt :{cmd:from(ones}|{cmd:2sls}|{cmd:ivreg}|{cmd:smart}|{it:ml_init_args}{cmd:)}}control the starting values{p_end}
{synopt :{opt loglevel(#)}}specify the details of output; programmers only{p_end}
{synopt :{it:ml_options}}maximization options{p_end}


{title:Description}

{pstd}{cmd:confa} estimates single-level confirmatory factor analysis (CFA) models.
In a CFA model, each of the variables is assumed to
be an indicator of underlying unobserved factor(s) with a linear dependence
between the factors and observed variables:

{center:{it:y_i} = {it:m_i} + {it:l_i1 f_1} + ... + {it:l_iK f_K} + {it:e_i}}

{pstd}where {it:y_i} is the {it:i}th variable
in the {it:varlist}, {it:m_i} is its mean,
{it:l_ik} are the latent variable loading(s),
{it:f_k} are the {it:k}th latent factor(s)
({it:k} = 1,...,{it:K}),
and {it:e_i} is the measurement error.
Thus the specification
{cmd:(}{it:factorname}{cmd::} {it:varlist}{cmd:)}
is interpreted as follows: the latent factor
{it:f_k} is given {it:factorname}
(for display purposes only);
the variables specified in
the {it:varlist} have their loadings, {it:l_ik}, estimated;
and all other observed variables in the model
have fixed loadings, {it:l_ik} = 0.

{pstd}The model is estimated by the maximum likelihood
procedure; see {helpb ml}.

{pstd}As with all latent variable models, a number
of identifying assumptions need to be made about
the latent variables {it:f_k}. They are assumed
to have mean zero, and their scales are determined
by the first variable in the {it:varlist}
(i.e., {it:l_1k} is set to equal 1 for all {it:k}).
Alternatively, identification can be achieved by setting the
variance of the latent variable to 1 (with option
{cmd:unitvar()}). More sophisticated identification
conditions can be achieved by specifying the
{cmd:free} option and then providing the necessary
constraints in the {cmd:constraint()} option.

{pstd}
Please cite this package as Kolenikov (2009). See
full bibliographic details in References below.


{title:Options}

{dlgtab:Model}

{phang}{cmd:correlated(}{it:corrspec} [{it:corrspec} ...]{cmd:)}
      specifies the correlated measurement errors {it:e_i} and {it:e_j}.
      Here {it:corrspec} is of the form{p_end}
      {pmore} [{cmd:(}]{it:varname_k}{cmd::}{it:varname_j}[{cmd:)}]{p_end}
      {pmore}where {it:varname_k} and {it:varname_j} are some of
      the observed variables in the model; that is, they must appear in at
      least one
      {it:factorspec} statement. If there
      is only one correlation specified, the optional parentheses
      shown above may be omitted. There should be no space between the colon and
      {it:varname_j}.

{phang}{cmd:unitvar(}{it:factorlist}|{cmd:_all)} specifies the factors
(from those named in {it:factorspec}) that will be identified by setting
their variances to 1. The keyword {cmd:_all} can be used to specify that all
the factors have their variances set to 1 (and hence the matrix Phi can be
interpreted as a correlation matrix).

{phang}{cmd:free} frees up all the parameters in the model (making it
underidentified).  It is then the user's responsibility to provide
identification constraints and adjust the degrees of freedom of the tests.
This option is seldom used.

{phang}{cmd:constraint(}{it:numlist}{cmd:)} can be used to supply additional
constraints. There are no checks implemented for
redundant or conflicting constraints, so in some rare cases, the degrees of
freedom may be incorrect. It might be wise to run the model with the
{cmd:free} and {cmd:iterate(0)} options and then look at the names in the output of
{cmd:matrix list e(b)} to find out the specific names of the parameters.

{phang}{cmd:missing} requests full-information maximum-likelihood estimation
with missing data.  By default, estimation proceeds by listwise deletion.

{phang}{cmd:usenames} requests that the parameters be labeled with the names
of the variables and factors rather than with numeric values (indices of the
corresponding matrices).  It is a technical detail that does not affect the
estimation procedure in any way, but it is helpful when working with several
models simultaneously, tabulating the estimation results, and transferring the
starting values between models.

{dlgtab:Variance estimation}

{phang}{cmd:vce(}{it:vcetype}{cmd:)} specifies different estimators of the
variance-covariance matrix. Common estimators ({cmd:vce(oim)},
observed information matrix, the default; {cmd:vce(robust)}, sandwich
information matrix; {cmd:vce(cluster }{it:clustvar}{cmd:)}, clustered
sandwich estimator with clustering on {it:clustvar}) are supported, along with
their aliases (the {cmd:robust} and {cmd:cluster(}{it:clustvar}{cmd:)}
options).  See {help vce_option}.

{pmore}An additional estimator specific to structural equation modeling is the Satorra-Bentler
estimator (Satorra and Bentler 1994). It is requested by
{cmd:vce(}{cmdab:sben:tler}{cmd:)} or {cmd:vce(}{cmdab:sat:orrabentler}{cmd:)}.  When
this option is specified, additional Satorra-Bentler scaled and adjusted
goodness-of-fit statistics are computed and presented in the output.

{dlgtab:Reporting}

{phang}{cmd:level(}{it:#}{cmd:)} changes the confidence level for
confindence-interval reporting. See
{helpb estimation_options##level():estimation options}.

{dlgtab:Other}

{phang}{cmd:svy} instructs {cmd:confa} to respect the complex
      survey design, if one is specified. See {helpb svyset}.

{phang}{cmd:from(}{cmd:ones}|{cmd:2sls}|{cmd:ivreg}|{cmd:smart}|{it:ml_init_args}{cmd:)} provides the choice of starting values for the maximization
procedure.  The {cmd:ml} command's internal default is to set all parameters to zero,
which leads to a noninvertible matrix, Sigma, and {cmd:ml} has to make many changes to those initial values to find anything feasible. Moreover, this
initial search procedure sometimes leads to a domain where the likelihood is
nonconcave, and optimization might fail there.

{pmore}{cmd:ones} sets all the parameters to values of one except
for covariance parameters (off-diagonal values of the Phi and Theta matrices),
which are set to 0.5.  This might be a reasonable choice for data with
variances of observed variables close to 1 and positive covariances (no
inverted scales).

{pmore} {cmd:2sls} or {cmd:ivreg} requests that the initial parameters for the
freely estimated loadings be set to the two-stage least-squares
instrumental-variable estimates of Bollen (1996). This requires the model to
be identified by scaling indicators (i.e., setting one of the loadings to 1)
and to have at least three indicators for each latent variable.  The instruments
used are all other indicators of the same factor. No checks for their validity
or search for other instruments is performed.

{pmore} {cmd:smart} provides an alternative set of starting values that
is often reasonable (e.g., assuming that the reliability of observed
variables is 0.5).

{pmore}Other specification of starting values, {it:ml_init_args}, should follow the format of
{cmd:ml init}. Those typically include the list of starting values of the form
{cmd:from(}{it:# #} ... {it:#}{cmd:, copy)} or a matrix of starting values
{cmd:from(}{it:matname}{cmd:,} [{cmd:copy}|{cmd:skip}]{cmd:)}.  See {manhelp ml R}.

{phang}{cmd:loglevel(}{it:#}{cmd:)} specifies the details of output about
      different stages of model setup and estimation,
      and is likely of interest only to programmers. Higher numbers
      imply more output.

{phang}For other options, see {helpb maximize}.


{title:Saved results}

{pstd}Aside from the standard {helpb estcom:estimation results}, {cmd:confa}
also performs the overall goodness-of-fit test with results
saved in {cmd:e(lr_u)}, {cmd:e(df_u)}, and {cmd:e(p_u)}
for the test statistic, its goodness of fit, and the resulting
p-value. A test versus the model with the independent data
is provided with the {helpb ereturn} results with the {cmd:indep}
suffix. Here, under the null hypothesis,
the covariance matrix is assumed diagonal.

{pstd}When {cmd:sbentler} is specified, Satorra-Bentler
standard errors are computed and posted as {cmd:e(V)},
with intermediate matrices saved in {cmd:e(SBU)},
{cmd:e(SBV)}, {cmd:e(SBGamma)}, and {cmd:e(SBDelta)}.
Also, a number of corrected overall fit test statistics
is reported and saved: T scaled ({cmd:ereturn} results
with the {cmd:Tsc} suffix) and T adjusted
({cmd:ereturn} results with the {cmd:Tadj} suffix).
Scalars {cmd:e(SBc)} and {cmd:e(SBd)} are the
scaling constants, with the latter also
being the approximate degrees of freedom
of the chi-squared test
from Satorra and Bentler (1994), and T double
bar from Yuan and Bentler (1997)
(with the {cmd:T2} suffix).


{title:Remarks}

{p}{cmd:confa} relies on {help listutil} for
some parsing tasks. If it is not installed with your Stata,
{cmd:confa} will try to install it from {SSC:ssc install listutil}. If installation
is unsuccessful, {cmd:confa} will issue an error message and stop.

{p}In large models, {cmd:confa} may be restricted by Stata
{help limits} of 244 characters in the string expression.
The user might want to {help rename} their variables and give
them shorter names.


{title:Examples}

{pstd}Holzinger-Swineford data{p_end}
{phang2}{cmd:. use http://web.missouri.edu/~kolenikovs/stata/hs-cfa.dta}

{pstd}Basic model with different starting values{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(ones)}{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv)}{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(smart)}

{pstd}Robust and Satorra-Bentler standard errors{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) vce(sbentler)}{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) robust}

{pstd}Correlated measurement errors{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) corr( x7:x8 )}

{pstd}An alternative identification{p_end}
{phang2}{cmd:. confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(ones) unitvar(_all) corr(x7:x8)}

{pstd}Missing data{p_end}
{phang2}{cmd:. forvalues k=1/9 {c -(}}{p_end}
{phang2}{cmd:.       gen y`k' = cond( uniform()<0.0`k', ., x`k')}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. confa (vis: y1 y2 y3) (text: y4 y5 y6) (math: y7 y8 y9), from(iv)}{p_end}
{phang2}{cmd:. confa (vis: y1 y2 y3) (text: y4 y5 y6) (math: y7 y8 y9), from(iv) missing difficult}{p_end}


{title:References}

{phang}Bollen, K. A. 1996. {browse "http://www.springerlink.com/content/2v1837041117kh66/":An alternative two stage least squares (2SLS) estimator for latent variable equations}. {it:Psychometrika} 61: 109-121.

{phang}Kolenikov, S. 2009. {browse "http://www.stata-journal.com/article.html?article=st0169":Confirmatory factor analysis using {cmd:confa}}. {it:Stata Journal}, 9(3): 329--373.

{phang}Satorra, A., and P. M. Bentler. 1994. Corrections to test statistics and standard errors in covariance structure analysis. In {it:Latent Variables Analysis}, ed. A. von Eye and C. C. Clogg, 399-419. Thousand Oaks, CA: Sage.

{phang} Yuan, K.-H., and P. M. Bentler. 1997. {browse "http://www.jstor.org/stable/2965725":Mean and covariance structure analysis: Theoretical and practical improvements.}
   {it:Journal of the American Statistical Association} 92: 767-774.


{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Department of Statistics{p_end}
{pstd}University of Missouri{p_end}
{pstd}Columbia, MO{p_end}
{pstd}kolenikovs@missouri.edu{p_end}


{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 9, number 3: {browse "http://www.stata-journal.com/article.html?article=st0001":st0001}

{psee}Online:  {helpb factor}, {helpb bollenstine}, {helpb confa_estat:confa postestimation} (if installed),
{helpb gllamm} (if installed).
{p_end}
