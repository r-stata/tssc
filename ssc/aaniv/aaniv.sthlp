{smcl}
{* 3jul2019}{...}
{hline}
help for {hi:aaniv}
{hline}

{title:Unbiased IV regression}

{title:Syntax}

{p 6 16 2}
{cmd:aaniv} [{vars}] {ifin} 
[{cmd:,} {it:{help ivreg##options:other options}}]

{marker contents}{dlgtab: Table of Contents}
{p 6 16 2}

{p 2}{help aaniv##description:General description of estimator}{p_end}
{p 2}{help aaniv##examples:Examples}{p_end}
{p 2}{help aaniv##options:Description of options}{p_end}
{p 2}{help aaniv##macros:Remarks and saved results}{p_end}
{p 2}{help aaniv##refs:References}{p_end}
{p 2}{help aaniv##acknow:Acknowledgements}{p_end}
{p 2}{help aaniv##citation:Citation of {cmd:aaniv}}{p_end}
{p 2}{help aaniv##citation:Author information}{p_end}

{marker description}{dlgtab:Description}

{p}The conventional instrumental variable (IV) or two-stage least squares (2SLS) estimator may be
badly biased in overidentified models with weak instruments. While the 2SLS estimator performs better in the
exactly identified case, in the sense that its median rapidly approaches the true value as instruments become strong, it has
no first moment. That is, the estimator has no mean, and no finite higher moments, either. 
For papers on the finite-sample properties of IV estimators, see e.g. Phillips (1980), Phillips (1983), and Hillier (2006), and references therein.

{p}The estimator implemented in {bf:aaniv} is an unbiased IV estimator for a special case of an exactly identified model 
with one endogenous variable and one instrument, from Andrews and Armstrong (2017), which relies on a 
sign restriction in the first stage. That is, if we know the sign of the effect of of the instrument on the endogenous treatment variable, 
we can construct an unbiased estimate of the effect of treatment on the treated.
Per Andrews and Armstrong (2017), "the only other paper to treat finite-sample mean-unbiased estimation
in IV models is Hirano and Porter (2015), who find that unbiased estimators do
not exist when the parameter space is unrestricted." In that setting, "the sign restriction
on the first-stage coefficient leads to a parameter space that violates the assumptions of
Hirano and Porter (2015), so that the negative results in that paper do not apply. 
In particular, the sign restriction violates Assumption 2.4 of Hirano and Porter (2015), and so renders
the negative result in Theorem 2.5 of that paper inapplicable.
The
nonexistence of unbiased estimators has been noted in other nonstandard econometric
contexts by Hirano and Porter (2012)."

{p}The unbiased estimator in Andrews and Armstrong (2017), "differs from the conventional IV estimator only in that it replaces the plug-in
estimate [the reciprocal of the first stage coefficient] for 1/pi [the true value] by the unbiased estimate [tau-hat]." 
The unbiased estimator of the reciprocal of the first stage coefficient (tau-hat) is less than the reciprocal of the first stage coefficient 
when the first stage coefficient exceeds zero, so in this case,
the unbiased estimator shrinks the conventional IV estimator toward the covariance of the two errors scaled by the variance of the first-stage error.

{marker examples}{dlgtab:Examples}

{p}The following example offers a comparison of standard IV/2SLS (using {help ivreg2}) and the unbiased IV implemented in {help aaniv}.{p_end}

{phang}An example from Card (1995):{p_end}
{p 6 16 2}{stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/card, clear" : use http://fmwww.bc.edu/ec-p/data/wooldridge/card, clear}{p_end}
{p 6 16 2}{stata `"loc x "exper* smsa* south mar black reg662-reg669" "': loc x "exper* smsa* south mar black reg662-reg669" }{p_end}
{p 6 16 2}{stata "qui ivreg2 lw `x' (educ=nearc4), noid " : ivreg2 lw `x' (educ=nearc4), noid }{p_end}
{p 6 16 2}{stata "est sto iv2sls " : est sto iv2sls }{p_end}
{p 6 16 2}{stata "aaniv lwage `x' (educ=nearc4) " : aaniv lwage `x' (educ=nearc4) }{p_end}
{p 6 16 2}{stata "est sto aaniv " : est sto aaniv }{p_end}
{p 6 16 2}{stata "est tab iv2sls aaniv, t keep(educ)" : est tab iv2sls aaniv, t keep(educ)}{p_end}

{marker options}{dlgtab:Options summary}

{phang}
{bf:deltase}; by default, the standard IV/2SLS standard error is used as asymptotically correct but the option deltase requests a first-order delta-method approximation
to the Andrews & Armstrong (2017) estimator's (nonfinite) variance. Neither of these estimates of variance are correct, as the true variance is nonfinite, so approximations are
by necessity incorrect and dramatically understate the true variance. Nevertheless, simulations show that inference is quite good in practice, using either poor approximation.

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{marker macros}{dlgtab:Remarks and saved results}

{p}The command saves the following results in {cmd:e()}:

Scalars
{col 4}{cmd:e(N)}{col 18}Number of observations used in estimation

Macros
{col 4}{cmd:e(cmd)}{col 18}{cmd:aaniv}
{col 4}{cmd:e(version)}{col 18}Version number 
{col 4}{cmd:e(depvar)}{col 18}Name of dependent variable

Matrices
{p 3 18 2}{cmd:e(b)} {space 8} Coefficient vector{p_end}
{p 3 18 2}{cmd:e(V)} {space 8} VCE estimate{p_end}

Functions
{col 4}{cmd:e(sample)}{col 18}Marks estimation sample


{marker refs}{title:References}

{phang}Andrews, Isaiah, and Timothy B. Armstrong. 2017. "Unbiased instrumental variables estimation
under known first-stage sign." Quantitative Economics, 8(2): 479-503.{p_end}

{phang}Hillier, G. 2006. "Yet more on the exact properties of IV estimators." Econometric Theory,
22: 913-931.

{phang}Hirano, K. and J. R. Porter. 2012 "Impossibility results for nondifferentiable functionals."
Econometrica, 80(4): 1769-1790.{p_end}

{phang}Hirano, K. and J. Porter. 2015. "Location properties of point estimators in linear instrumental
variables and related models." Econometric Reviews, 34(6-10): 719-733.{p_end}

{phang}Phillips, Peter C. B. 1980. "The Exact Distribution of Instrumental Variable Estimators in an Equation Containing n+1 Endogenous Variables." Econometrica, 48: 861–878.

{phang}Phillips, Peter C. B. 1983. "Exact Small Sample Theory in the Simultaneous Equations Model." Chapter in Zvi Griliches and Michael D. Intriligator, ed.
{it:Handbook of Econometrics}, Volume 1, 449–516, North Holland, Amsterdam. 
See also {browse "http://cowles.yale.edu/sites/default/files/files/pub/d06/d0617.pdf": http://cowles.yale.edu/sites/default/files/files/pub/d06/d0617.pdf}
 
{p}The first example is based on:{p_end}

{phang}Card, David E. 1995. "Using Geographic Variation in College Proximity to Estimate the
Return to Schooling" in {it: Aspects of Labour Economics: Essays in Honour of John Vanderkamp,}
edited by Louis Christofides, E. Kenneth Grant and Robert Swindinsky.
University of Toronto Press. See also {browse "http://www.nber.org/papers/w4483":NBER WP 4483}.

{marker citation}{title:Citation of {cmd:aaniv}}

{p}{cmd:aaniv} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Andrews, Isaiah, Timothy B. Armstrong, and Austin Nichols. 2019. 
aaniv: Stata module for Unbiased IV Regression.
{browse "http://ideas.repec.org/c/boc/bocode/S458664.html":http://ideas.repec.org/c/boc/bocode/s456890.html}{p_end}

{title:Contact for support}

    Austin Nichols
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual:  {hi:[U] 23 {help est: Estimation} and {help postest: post-estimation} commands}{p_end}
{p 10 14}{manhelp bootstrap R}{p_end}
{p 10 14}{manhelp regress R}{p_end}
{p 10 14}{manhelp ivregress R}{p_end}

{p 1 10}On-line: help for (if installed) {help ivreg2},
{help overid}, {help ivendog}, {help ivhettest}, {help ivreset},
{help xtivreg2}, {help xtoverid}, {help ranktest}, {help weakivtest},
{help condivreg}.
{p_end}
