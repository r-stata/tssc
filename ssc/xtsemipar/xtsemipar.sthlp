{smcl}
{* *! version 1.2 23April2014}{...}
{cmd:help xtsemipar} {right: ({browse "http://www.stata-journal.com/article.html?article=st0296":SJ13-2: st0296})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi:xtsemipar} {hline 2}}Semiparametric estimator in panel data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:xtsemipar} {varlist} {ifin} {weight}{cmd:, nonpar(}{varname}{cmd:)}
[{it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {cmd:nonpar(}{it:{help varname:varname}}{cmd:)}}specify the variable that enters the model nonlinearly{p_end}
{synopt :{cmdab:gen:erate(}[{it:string1}] {it:string2}{cmd:)}}store fitted values in {it:string1} and residuals of the parametric estimation in {it:string2}{p_end}
{synopt :{opt deg:ree(#)}}specify the degree of the local weighted polynomial
fit used in the Epanechnikov kernel if {cmd:spline} is not specified (see
{helpb lpoly}); if {cmd:spline} is specified, {cmd:degree()} specifies the power (or degree) of
the splines; default is {cmd:degree(4)} (see {helpb bspline}){p_end}
{synopt:{cmd:knots1(}{it:{help numlist:numlist}}{cmd:)}}specify a list of at least two ascending knots used for the spline interpolation that allows removal of fixed effects{p_end}
{synopt :{opt nog:raph}}suppress graph{p_end}
{synopt:{opt spline}}use B-splines to perform the nonparametric fit instead of kernel-weighted local polynomial smoothing, the default (see {helpb lpoly}){p_end}
{synopt:{cmd:knots2(}{it:{help numlist:numlist}}{cmd:)}}specify a list of at least two ascending knots used for the last-step spline interpolation, which yields the graph{p_end}
{synopt:{cmdab:bw:idth(}{it:#}{cmd:)}}specify kernel bandwidth{p_end}
{synopt :{opt robust}}specify that the type of standard error reported is corrected using the Huber/White/sandwich estimator{p_end}
{synopt :{cmd:cluster(}{help varname:{it:varname}}{cmd:)}}specify that the type of standard error reported is corrected using the clustered sandwich estimator{p_end}
{synopt :{opt ci}}plot confidence bands{p_end}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {cmd:nonpar()} is required.{p_end}
{p 4 6 2}{cmd:aweight}s and {cmd:fweight}s are allowed; see {help weight}.


{title:Description}

{pstd}{opt xtsemipar} estimates Baltagi and Li's (2002) series
semiparametric fixed-effects regression estimator.  The main options
allow the use of a classical nonparametric estimator based on an
Epanechnikov-kernel-weighted local polynomial fit or a spline
interpolation.  This last technique yields similar results to the
polynomial interpolation but better approximates complex shapes and does
not suffer from Runge's phenomenon.


{title:Options}

{phang}{cmd:nonpar(}{it:{help varname:varname}}{cmd:)} specifies a
(continuous) variable that nonlinearly enters the model.  {cmd:nonpar()}
is required.

{phang}{cmd:generate(}[{it:string1}] {it:string2}{cmd:)} stores the
(centered) nonparametric fit evaluated at the values of the
{cmd:nonpar()} variable.  {it:string1} stores the (centered)
partialled-out residuals, that is, the part of the dependent variable
that is not explained by the parametric part of the estimation.  These
residuals are used to estimate the local polynomial smooth or the
splines.  This option is particularly handy if additional tests or
estimations have to be done on the residuals of the semiparametric fit.

{phang}{opt degree(#)} (a nonnegative integer) specifies the degree of
the polynomial to be used in the polynomial smoothing or the power of
the series estimator in the spline smoothing.  The default is
{cmd:degree(4)}.

{phang}{cmd:knots1(}{it:{help numlist:numlist}}{cmd:)} specifies a list
of at least two ascending knots on which the splines estimated to remove
fixed effects is based.  This option is seldom used.  If {cmd:knots1()}
is not specified, {cmd:bspline} will set the list to the minimum, the maximum 
and each decile of {opt nonpar()} and allow extending the list of knots outside 
of the completeness range (see Newson (2012) for more details).  

{phang}{cmd:nograph} suppresses drawing the graph of the estimated
smooth.

{phang}{cmd:spline} specifies that the nonparametric fit be done by
using B-splines (see Newson [2000]).  The default option is a
kernel-weighted local polynomial fit based on an Epanechnikov kernel.
Spline interpolation yields similar results to polynomial fit but is
more flexible and does not suffer from some weaknesses that affect
polynomial fit, such as Runge's phenomenon.

{phang}{cmd:knots2(}{it:{help numlist:numlist}}{cmd:)} specifies a list of at
least two ascending knots on which the spline interpolation appearing in
the graph is based.  This option is seldom used.  If {cmd:knots2()} is
not specified, {cmd:bspline} will set the list to the minimum, the
maximum and each decile of {opt nonpar()} and allow extending the list of knots 
outside of the completeness range (see Newson (2012) for more details). 
If {cmd:knots2()} is not specified while {cmd:knots1()} is, then {cmd:knots2()}
 is set equal to {cmd:knots1()} by default.

{phang}{opt bwidth(#)} specifies the half-width of the kernel, the width
of the smoothing window around each point.  If {opt bwidth()} is not
specified, a rule-of-thumb bandwidth estimator is calculated and used.

{phang}{opt robust} uses the Huber/White/sandwich variance estimator to
compute standard errors of the estimated parameters.  All the inference
and confidence intervals will be corrected.

{phang}{cmd:cluster(}{it:{help varname:varname}}{cmd:)} computes
cluster-corrected standard errors of the estimated parameters and
adjusts the inference as well as confidence intervals.

{phang}{opt ci} plots confidence intervals around the polynomial
smoothing or the spline.  The confidence level used is the one specified
in {opt level()}.

{phang}{opt level(#)} specifies the confidence level, as a percentage,
for confidence intervals.  The default is {cmd:level(95)} or as set by
{helpb set level}.


{title:Requirement}

{pstd}{opt xtsemipar} can only be used if data are declared to be panel
data through the {helpb xtset} or {helpb tsset} command.  Before using 
{opt xtsemipar}, you must install Newson's (2000) {opt bspline} program.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:.} {bf:{stata "webuse invest2"}}{p_end}
{phang2}{cmd:.} {bf:{stata "generate logi=log(invest)"}}{p_end}
{phang2}{cmd:.} {bf:{stata "generate logm=log(market)"}}{p_end}
{phang2}{cmd:.} {bf:{stata "generate logs=log(stock)"}}{p_end}
{phang2}{cmd:.} {bf:{stata "xtset company time"}}{p_end}

{pstd}Fixed-effects semiparametric regression with default quartic local polynomial smooth for the nonparametric part{p_end}
{phang2}{cmd:.} {bf:{stata "xi: xtsemipar logi logm i.time, nonpar(logs)"}}{p_end}

{pstd}Same as above but with quartic spline smoothing, confidence intervals, and standard errors clustered at company level{p_end}
{phang2}{cmd:.} {bf:{stata "xi: xtsemipar logi logm i.time, nonpar(logs) spline knots1(0(2)8) ci cluster(company)"}}{p_end}

{pstd}Same as above but with smoothed values (a) and partialled-out residuals (b) as variables instead of graphing{p_end}
{phang2}{cmd:.} {bf:{stata "xi: xtsemipar logi logm i.time, nonpar(logs) generate(a b) nograph"}}{p_end}


{title:Saved results}

{pstd}
{cmd:xtsemipar} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(F)}}F statistic{p_end}
{synopt:{cmd:e(r2)}}within R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtsemipar}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(model)}}{cmd:"Baltagi Fixed-effect Series Semiparametric Estimation"}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}Baltagi, B. H., and D. Li.  2002.  Series estimation of partially
linear panel data models with fixed effects. 
{it:Annals of Economics and Finance} 3: 103-116.

{phang}Newson, R.  2000.  B-splines and splines parameterized by their
values at reference points on the x-axis. 
{browse "http://www.stata.com/products/stb/journals/stb57.pdf":{it:Stata Technical Bulletin} 57}: 20-27.  Reprinted in 
{it:Stata Technical Bulletin Reprints}, vol. 10, pp. 221-230.  College Station, TX: Stata Press.

{phang}Newson, R.  2012.  Sensible parameters for univariate and multivariate splines.
{browse "http://www.stata-journal.com/article.html?article=sg151_2":{it:Stata Journal} 12-3}: 479-504.  College Station, TX: Stata Press.

{title:Authors}

{pstd}Fran{c c,}ois Libois{p_end}
{pstd}University of Namur{p_end}
{pstd}Centre for Research in the Economics of Development (CRED){p_end}
{pstd}Namur, Belgium{p_end}
{pstd}francois.libois@unamur.be{p_end}

{pstd}Vincenzo Verardi{p_end}
{pstd}University of Namur{p_end}
{pstd}Centre for Research in the Economics of Development (CRED){p_end}
{pstd}Namur, Belgium{p_end}
{pstd}and {p_end}
{pstd}Universit{c e'} Libre de Bruxelles{p_end}
{pstd}European Center for Advanced Research in Economics and Statistics
(ECARES) and
Center for Knowledge Economics (CKE){p_end}
{pstd}Brussels, Belgium{p_end}
{pstd}vincenzo.verardi@unamur.be{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 13, number 2: {browse "http://www.stata-journal.com/article.html?article=st0296":st0296}

{p 7 14 2}Help:  {manhelp lpoly R}, {helpb bspline} (if installed){p_end}
