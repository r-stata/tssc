{smcl}
{* *! version 1.0.0 March 3, 2013 @ 14:32:43}{...}
{cmd:help genstest}{right: ({browse "http://www.stata-journal.com/article.html?article=st0320":SJ13-4: st0320})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{hi: genstest} {hline 2}}Perform generalized S tests for models in the
generalized method of moments framework{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:genstest} [{cmd:(}{it:residual}{cmd:)}] [{it:{help if}}] {weight}
[{cmd:,} {cmdab:inst:ruments(}{varlist} [{cmd:, noconstant}]{cmd:)}
{cmdab:deriv:ative(/}{it:name} {cmd:=} [{cmd:<}]{it:dexp}[{cmd:>}]{cmd:)}
{cmd:twostep}
{cmd:igmm}
{opth init(numlist)}
{cmd:null(}{it:{help numlist}}|{cmd:last)}
{opt test(namelist)}
{cmd:sb}
{cmd:stab}
{opt winitial(iwtype)}
{opt wmat:rix(wmtype)}
{cmd:center}
{cmd:small}
{opt trim(#)}
{cmd:nuisS}
{cmd:varS}
{cmd:ci(}{it:ci_options}{cmd:)}]


{title:Description}

{pstd}
{cmd:genstest} implements four types of generalized S tests: the average
(ave-) S test, the exponential (exp-) S test, the supremum (sup-) S test, and
the quasi local level (qLL-) S test.  The first three tests are here referred
to collectively as the "single-break" tests because each is derived under the
assumption that there is a single-break date in the data-generating process
for the endogenous variables.  The fourth test, the qLL-S test, is derived by
assuming that the instability of the moments is described as a difference
martingale sequence.

{pstd}
{cmd:genstest} may be invoked both as a stand-alone command or as
a postestimation command for {cmd:gmm}.  When used as a postestimation
command, it will use all the {cmd:gmm} options that {cmd:genstest}
supports.


{title:Options}

{dlgtab:Testing options}

{phang}
{cmd:instruments(}{varlist}[{cmd:, noconstant}]{cmd:)}
specifies the vector of instruments.  The optional {cmd:noconstant}
indicates removal of a constant from the matrix of instruments.

{phang}
{cmd:derivative(/}{it:name} {cmd:=} [{cmd:<}]{it:dexp}[{cmd:>}]{cmd:)}
specifies the derivative of a {it:residual} function with respect to the
parameter {it:name}.  The functionality of this option requires entering all
untested parameter derivatives; otherwise, derivatives in the optimization
algorithm will be computed numerically.  The use of this option is recommended
when estimating confidence intervals and sets because it improves the
performance of the optimization algorithm and the computational speed (see
{cmd:ci()} option).  This option is specified as in {cmd:gmm} with the
addition that the {cmd:<>}'s indicate the value of a parameter tested under
the null hypothesis.  If one is using {cmd:genstest} as a postestimation
command, the derivatives passed to {cmd:gmm} will be used by {cmd:genstest}.

{phang}
{opt twostep} requires the two-step general method of moments estimator be
used (this is the default).

{phang}
{opt igmm} requires the iterated general method of moments estimator be used.

{phang}
{opth init(numlist)} sets the initial values in the optimization routine for
estimating the nuisance parameters.  The default choice is a vector of zeros.
One should include this option if the algorithm for estimating untested
parameters does not converge, if it converges to a local minimum, or if the
residual expression is undefined at the zero vector.

{phang}
{cmd:null(}{it:{help numlist}}|{cmd:last)} specifies the null hypothesis
vector for tested parameters (a zero vector by default).  It must be specified
in the order the parameters appear in the {it:residual}.  The special value
{cmd:last} indicates using the parameter estimates from {cmd:gmm}.

{phang}
{opt test(namelist)} lists the names of the {cmd:gmm} parameters in the
{it:residual} expression to be tested.  This option is only applicable if
{cmd:genstest} is being used as a postestimation command.

{phang}
{opt sb} reports the ave-, exp-, and sup-S tests (the single-break
tests).  These are computationally more intensive than the qLL-S test and
therefore not computed by default.

{phang}{opt stab} reports the stability tests (the S-tilde tests).

{phang}{opt winitial(iwtype)} specifies the initial weighting matrix for
estimating the untested parameters.  There are two options for this
matrix: {cmd:identity}, which uses the identity matrix or (Z'Z), and
{cmd:unadjusted}, which sets (Z'Z) as the initial weight matrix.  The
default is {cmd:winitial(unadjusted)}.

{phang}
{opt wmatrix(wmtype)} allows the choice of the covariance matrix.  The choices
are the following:

{phang2}
{cmd:unadjusted} for the homoskedastic case.

{phang2}
{cmd:robust}, {cmd:hc1}, {cmd:hc2}, {cmd:hc3}, and {cmd:hc4}
specify a weight matrix robust to heteroskedasticity with four
possible adjustments.  The default is {cmd:wmatrix(hc1)}.

{phang2}
{cmd:cluster} {it:clustvar} for a cluster-robust covariance
matrix having the cluster variable defined in {it:clustvar}.

{phang2}
{cmd:hac} {it:kernel} [{it:lags}] specifies a weight matrix
robust to autocorrelation and heteroskedasticity.  The possible choices for
{it:kernel} are {cmd:bartlett}, {cmd:nwest}, {cmd:parzen}, {cmd:gallant},
{cmd:quadraticspectral}, or {cmd:andrews}.  {it:lags} may be {cmd:optimal} to
use the optimal lag selection algorithm of Newey and West (1994),
{cmd:automatic} to set the number of lags to the starting value of the optimal
lag selection algorithm, or {it:number}, which is any positive integer.

{phang}
{opt center} indicates recentering the moment function when
computing the heteroskedastic and autocorrelated estimate of the
variance.

{phang}
{cmd:small} indicates using a small-sample adjustment when
computing the heteroskedastic and autocorrelated weight matrix.

{dlgtab:Single-break options}

{phang}
{opt trim(#)} specifies the value of the trimming parameter, s.
The sample will be initially split at (sT), where T is the number of
observations.  The possible values are 0.05, 0.10, 0.15, and 0.20.  The
default is {cmd:trim(0.15)}.

{phang}
{opt nuisS} uses the full-sample estimate of the nuisance parameters for the
split-sample tests.

{phang}
{opt varS} uses the full-sample weight matrix when estimating the nuisance
parameters.

{dlgtab:Confidence interval}

{phang}
{opt ci(ci_options)} indicates that a confidence interval or set be estimated.

{pmore}
The following are {it:ci_options}:

{phang2}
{it:{help numlist}} specifies the range over which to test the parameters for
up to two tested parameters.

{phang2}
{opth points(numlist)} determines the number of equally spaced points for the
grid search.  The default is {cmd:points(20)} for confidence intervals and
{cmd:points(20 20)} for confidence sets.

{phang2}
{opt alpha(#)} determines the 1 - alpha coverage probability of the interval
or set.  The default is {cmd:alpha(0.05)}.

{phang2}
{cmd:allpv} tells {cmd:genstest} to return p-values for all points
tested in the selected range.  Therefore, if one wishes to examine the
confidence interval (set) for a different significance level, there is
no need to execute the command a second time.

{phang2}
{opt autograph} tells {cmd:genstest} to automatically graph the
confidence region if two parameters are being tested.  Whether or not
this option is specified, the points necessary to plot the confidence
region are stored in matrices.


{title:Example as a stand-alone command}

{pstd}Examine confidence set for {cmd:rho} and {cmd:theta}, the
price-indexation parameter and the price-stickiness parameter in the new
Keynesian Phillips curve{p_end}
{phang2}{cmd:.} {bf:{stata "use nkpc_gmm"}}{p_end}
{phang2}{cmd:.} {bf:{stata generate time = _n}}{p_end}
{phang2}{cmd:.} {bf:{stata tsset time}}{p_end}
{phang2}{cmd:.} {bf:{stata generate dinf = inf - L.inf}}{p_end}
{phang2}{cmd:.} {bf:{stata genstest (dinf - {c} - (1/(1 + {rho}))*(F.inf - L.inf) -(((1 - <th>)^2)/(<th> * (1 + {rho})))*ls) if time >= 50, inst(L.dinf L.ls L2.ls L3.ls L2.dinf) wmat(hac nwest optimal) center null(0.7) ci(0.3 1.0, points(20))}}

{title:Example as a postestimation command for gmm}

{pstd}Below is the same example using {cmd:genstest} as a postestimation
command{p_end}
{phang2}{cmd:.} {bf:{stata gmm (dinf - {c} - (1/(1 + {rho}))*(F.inf - L.inf) -(((1 - {th=1})^2)/({th} * (1 + {rho})))*ls) if time >= 50, inst(L.dinf L.ls L2.ls L3.ls L2.dinf) wmat(hac nwest optimal) center}}{p_end}
{phang2}{cmd:.} {bf:{stata genstest, null(last) test(th) ci(0.3 1.0, points(20))}}


{title:Stored results}

{cmd:genstest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(S)}}S statistic{p_end}
{synopt:{cmd:r(aveS)}}ave-S statistic{p_end}
{synopt:{cmd:r(expS)}}exp-S statistic{p_end}
{synopt:{cmd:r(supS)}}sup-S statistic{p_end}
{synopt:{cmd:r(qllS)}}qLL-S statistic{p_end}
{synopt:{cmd:r(avestabS)}}ave-stab-S statistic{p_end}
{synopt:{cmd:r(expstabS)}}exp-stab-S statistic{p_end}
{synopt:{cmd:r(supstabS)}}sup-stab-S statistic{p_end}
{synopt:{cmd:r(qllstabS)}}qLL-stab-S statistic{p_end}
{synopt:{cmd:r(pS)}}S statistic p-value{p_end}
{synopt:{cmd:r(paveS)}}ave-S p-value{p_end}
{synopt:{cmd:r(pexpS)}}exp-S p-value{p_end}
{synopt:{cmd:r(psupS)}}sup-S p-value{p_end}
{synopt:{cmd:r(pqllS)}}qLL-S p-value{p_end}
{synopt:{cmd:r(pavestabS)}}ave-stab-S p-value{p_end}
{synopt:{cmd:r(pexpstabS)}}exp-stab-S p-value{p_end}
{synopt:{cmd:r(psupstabS)}}sup-stab-S p-value{p_end}
{synopt:{cmd:r(pqllstabS)}}qLL-stab-S p-value{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(Sci)}}
grid search points not rejected by the S test or search points and their associated p-values (if {cmd:allpv} is specified){p_end}
{synopt:{cmd:r(aveSci)}}
grid search points not rejected by the ave-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(expSci)}}
grid search points not rejected by the exp-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(supSci)}}
grid search points not rejected by the sup-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(qllSci)}}
grid search points not rejected by the qLL-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(avestabSci)}}
grid search points not rejected by the ave-stab-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(expstabSci)}}
grid search points not rejected by the exp-stab-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(supstabSci)}}
grid search points not rejected by the sup-stab-S test or search points and their associated p-values{p_end}
{synopt:{cmd:r(qllstabSci)}}
grid search points not rejected by the qLL-stab-S test or search points and their associated p-values{p_end}
{p2colreset}{...}


{title:Reference}

{phang}Newey, W. K., and K. D. West.  1994.  Automatic lag selection in
covariance matrix estimation. {it:Review of Economic Studies} 61: 631-653.


{title:Authors}

{pstd}Zachary L. Flynn{p_end}
{pstd}University of Wisconsin-Madison{p_end}
{pstd}Madison, WI{p_end}
{pstd}zflynn@wisc.edu

{pstd}Leandro M. Magnusson{p_end}
{pstd}University of Western Australia{p_end}
{pstd}Crawley, Australia{p_end}
{pstd}leandro.magnusson@uwa.edu.au


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 13, number 4: {browse "http://www.stata-journal.com/article.html?article=st0320":st0320}{p_end}
