{smcl}
{* *! version 1.0.02  5feb2015}{...}
{cmd:help ginireg}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: ginireg} {hline 2}}Progam to estimate Gini regression{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{phang}
Standard:

{p 8 14 2}
{cmd:ginireg}
{it:depvar} {it:regressors}
[{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,} {cmd:nogini(varlist)} }
{cmd:extended(varlist)} {cmd:nu(#)} {cmd:vce(jackknife)}
{bind:{cmdab:noc:onstant} ]}

{phang}
IV estimation:

{p 8 14 2}
{cmd:ginireg}
{it:depvar} [{it:exogenous regressors}] {it:(endogenous regressors = excluded instruments)}
[{it:weight}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]
{bind:[ {cmd:,} {cmd:nogini(varlist)} }
{cmd:extended(varlist)} {cmd:nu(#)} {cmd:vce(jackknife)}
{bind:{cmdab:noc:onstant} ]}

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:nogini(}{it:varlist}{cmd:)}}
do not apply Gini (rank) transformation to variables in {it:varlist}
{p_end}
{synopt:{cmd:extended(}{it:varlist}{cmd:)}}
regressors for extended Gini transformation{it:varlist}
{p_end}
{synopt:{cmd:nu(#)}}
extended Gini parameter (default=2)
{p_end}
{synopt:{cmd:vce(jackknife)}}
jackknife VCE
{p_end}
{synopt:{cmdab:noc:onstant}}
suppress constant from regression
{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:resid} {cmd:xb} ]

{p 8 14 2}
{cmd:estat} {it:graph_type}
{bind:[ {cmd:,} {cmd:nlma} }
{bind:{it:graph_options} ]}

{synoptset 20}{...}
{synopthdr:Postestimation options}
{synoptline}
{synopt:{it:graph_type}}
either {cmdab:lmar:esid} for LMA graph of residuals
or {cmdab:lmay:yhat} for LMA graph of dependent variable and fitted value,
in both cases vs. all independent variables.
{p_end}
{synopt:{cmd:nlma}}
report Normalized LMA graph instead of default LMA graph
{p_end}
{synopt:{it:graph_options}}
options to pass to underlying call to {cmd:graph combine}
{p_end}
{synoptline}
{p2colreset}{...}


{pstd}
{opt ginireg} may be used with time-series or panel data,
in which case the data must be tsset first; see help {helpb tsset}.

{pstd}
All varlists may contain time-series operators,
but factor variables are not currently supported; see help varlist.


{title:Contents}

{phang}{help ginireg##description:Description}{p_end}
{phang}{help ginireg##examples:Examples of usage}{p_end}
{phang}{help ginireg##saved_results:Saved results}{p_end}
{phang}{help ginireg##references:References}{p_end}
{phang}{help ginireg##acknowledgements:Acknowledgements}{p_end}
{phang}{help ginireg##citation:Citation of ginireg}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt ginireg} is a routine for estimating Gini regressions.
It can run standard Gini,
mixed OLS/Gini,
instrumental variables (IV) Gini
and extended Gini regressions.
The ability to mix regression methods enables finding
the implicit assumptions that affect the sign or magnitude of the estimates.

{pstd}
Gini regression can be interpreted in various ways.
The Gini regression has its origin in Corrado Gini's (1912) introduction
of the Gini Mean Difference (GMD) as an alternative to the variance.
The population GMD is defined as {bind:GMD = E{|X_i-X_j|}}, i.e.,
the expected absolute difference between two realizations
of an i.i.d. random variable.
It can be shown (see Yitzhak-Schechtman 2013, p. 18)
that the GMD can be equivalently defined as
{bind:GMD = 4*cov(X,F(X))}},
where F(X) is the population cumulative distribution function (CDF).
One intuition for the Gini regression is that
it replaces the standard notion of variance with the Gini notion of variance.

{pstd}
An alternative interpretation that also makes clear the methods of computation
is that the basic Gini regression of Y on a set of regressors X
is an IV regression with regressors X and instruments F(X),
where here F(X) represents the empirical CDF.
Mixed Gini regression is equivalent to partitioning the regressors X into two sets, X_1 and X2,
and estimating by IV treating X_1 as exogenous (OLS regressors)
and treating X_2 as endogenous with instruments F(X_2) (Gini regressors).
Pure Gini IV is IV with regressors X and instruments F(Z);
general Gini IV is IV with regressors partitioned into X_1, X_2
and a mix of instruments F(X_1) and F(Z).
{opt ginireg} can also estimate Extended Gini regressions.
For a full discussion of these estimators see Yitzhak-Schechtman (2013).

{pstd}
The default VCE is the classical VCE.
Jackknife SEs are available with the {opt vce(jackknife)} option.

{pstd}
The {opt nogini(varlist)} option may be used
to suppress the Gini transformation for the variables listed.
The untransformed variables may be either regressors or instruments
(in the case of IV estimation).
For example, {opt nogini(X_2)} will perform
the basic Mixed Gini estimation described above.
To peform Extended Gini regression,
the variables subject to the extended Gini tranform
{opt extended(varlist)} need to be specified
along with the Extended Gini parameter {opt nu(#)}.
Standard Gini regression is equivalent
to Extended Gini estimation with {opt nu}=2.

{pstd}
{opt ginireg} reports several goodness-of-fit measures
that parallel the standard OLS measure of R-squared.
Denote the predicted value of the dependent variable by Yhat.
Then

{p 8 12 2}GR = cov(Yhat,F(Yhat))/cov(Y,F(Y)){p_end}
{p 8 12 2}Gamma YYhat = cov(Y,F(Yhat))/cov(Y,F(Y)){p_end}
{p 8 12 2}Gamma YhatY = cov(Yhat,F(Y))/cov(Yhat,F(Yhat)){p_end}

{pstd}
For further discussion of these measures
see Yitzhaki-Schechtman (2013), pp. 18, 53, 159-60.

{pstd}
The LMA curve (Line of independence Minus the Absolute concentration)
and Normalized LMA (NLMA) can be obtained following {cmd:ginireg} estimation
using {cmd:estat}.
Either the regression residuals ({cmd:lmaresid})
or the dependent variable and fitted values ({cmd:lmayyhat})
can be requested.
Additional options for the underlying Stata graphics command
can also be added.
The {helpb ginilma} command must also be installed
for this option to be available.
See the online help for {helpb ginilma}
or Yitzkaki-Schechtman (2012)
for further discussion of the LMA and NLMA curves.


{marker examples}{...}
{title:Examples}

{pstd}Load Mroz cross-sectional dataset on female labor force participation{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta"}{p_end}

{pstd}Standard Gini estimation - labor force participation vs. age, education{p_end}

{phang2}. {stata "ginireg inlf age"}{p_end}

{phang2}. {stata "ginireg inlf age, vce(jackknife)"}{p_end}

{phang2}. {stata "ginireg inlf age educ"}{p_end}

{pstd}IV Gini estimation{p_end}

{phang2}. {stata "ginireg inlf age (educ = motheduc fatheduc huseduc)"}{p_end}

{pstd}Postestimation - LMA and NLMA for residuals or dependent variable/fitted values{p_end}

{pstd}Gini regression of labor force participation vs. age{p_end}

{phang2}. {stata "ginireg inlf age"}{p_end}
{phang2}. {stata "estat lmar"}{p_end}
{phang2}. {stata "estat lmay"}{p_end}

{pstd}Gini regression of labor force participation vs. age, education{p_end}

{phang2}. {stata "ginireg inlf age educ"}{p_end}
{phang2}. {stata "estat lmar"}{p_end}
{phang2}. {stata "estat lmay, nlma"}{p_end}

{pstd}Mixed Gini estimation{p_end}

{pstd}Gini estimation of a wage equation in levels{p_end}

{phang2}. {stata "ginireg wage age educ kidslt6 kidsge6"}{p_end}
{phang2}. {stata "estat lmay, nlma"}{p_end}

{pstd}Mixed Gini estimation of a wage equation with both Gini and OLS regressors{p_end}

{phang2}. {stata "ginireg wage age educ kidslt6 kidsge6 exper expersq, nogini(exper expersq)"}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:ginireg} saves the following in {cmd:e()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(nu)}}extended Gini parameter{p_end}
{synopt:{cmd:e(gr)}}Gini regression goodness-of-fit measure{p_end}
{synopt:{cmd:e(gyyh)}}cov(y,f(yhat))/cov(y,f(y)){p_end}
{synopt:{cmd:e(gyhyh)}}cov(yhat,f(yat))/cov(yhat,f(yhat)){p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: macros}{p_end}
{synopt:{cmd:e(cmd)}}ginireg{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(gini_inexog)}}Gini regressors{p_end}
{synopt:{cmd:e(nogini_inexog)}}standard (least squares) regressors{p_end}
{synopt:{cmd:e(endo)}}endogenous regressors{p_end}
{synopt:{cmd:e(gini_exexog)}}Gini instruments{p_end}
{synopt:{cmd:e(nogini_exexog)}}standard (least squares) instruments{p_end}
{synopt:{cmd:e(extended)}}extended Gini regressors{p_end}
{synopt:{cmd:e(predict)}}ginireg_p{p_end}
{synopt:{cmd:e(estat_cmd)}}ginireg_estat{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: functions}{p_end}
{synopt:{cmd:e(sample)}}{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{phang}
Yitzhaki, Shlomo and Schechtman, E. 2013.
The Gini Methodology: A Primer on a Statistical Methodology.
Springer.
{p_end}

{phang}
Yitzhaki, Shlomo and Schechtman, E. 2012.
Identifying monotonic and non-monotonic relationships.
{browse "http://dx.doi.org/10.1016/j.econlet.2011.12.123":Economics Letters 116 (2012) 23–25}.
{p_end}


{marker acknowledgements}{title:Acknowledgements}

{p}I am grateful to Shlomo Yitzhaki for guidance and many helpful discussions
about Gini regression and its implementation.


{marker citation}{...}
{title:Citation of ginireg}

{pstd}{opt ginireg} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Schaffer, M.E. 2015.
ginireg: Program to estimate Gini regression.
{browse "http://ideas.repec.org/c/boc/bocode/s457958.html":http://ideas.repec.org/c/boc/bocode/s457958.html}{p_end}


{title:Author}

	Mark E Schaffer, Heriot-Watt University, UK
	m.e.schaffer@hw.ac.uk


{title:Also see}

{p 7 14 2}
Help:  {helpb ginilma} (if installed){p_end}

