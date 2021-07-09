{smcl}
{* 28mar2008}{...}
{hline}
help for {hi:ivpois}
{hline}

{title:IV/GMM Poisson regression}

{title:Syntax}

{p 6 16 2}
{cmd:ivpois} [{vars}] {ifin} 
[{cmd:,} {cmd:exog(}{vars}{cmd:)} {cmd:endog(}{vars}{cmd:)} {it:{help ivpois##options:other options}}]

{marker contents}{dlgtab: Table of Contents}
{p 6 16 2}

{p 2}{help ivpois##description:General description of estimator}{p_end}
{p 2}{help ivpois##examples:Examples}{p_end}
{p 2}{help ivpois##options:Description of options}{p_end}
{p 2}{help ivpois##macros:Remarks and saved results}{p_end}
{p 2}{help ivpois##refs:References}{p_end}
{p 2}{help ivpois##acknow:Acknowledgements}{p_end}
{p 2}{help ivpois##citation:Citation of {cmd:ivpois}}{p_end}
{p 2}{help ivpois##citation:Author information}{p_end}

{marker description}{dlgtab:Description}

{p}Using the Mata function {help optimize} available in Stata 10, 
{cmd:ivpois} implements a Generalized Method of Moments
(GMM) estimator (due to Mullahy, 1997) of Poisson regression 
that allows additional exogenous variables that have no direct impact
on the dependent variable to be specified, and endogenous variables
to be instrumented by excluded instruments (see {help ivreg2} or {help rd} if installed, and references therein; 
{stata "ssc inst ivreg2":ssc install ivreg2} and {stata "ssc inst rd, replace":ssc install rd} to install),
hence the acronym for Instrumental Variables (IV) in its name (see Baum et al. 2007 or Nichols 2007 for more on IV). {p_end}

{p}Standard errors are estimated by the asymptotic approximation outlined by 
Hansen (1982), requiring "large" samples, though {help bootstrap}ped standard errors may outperform
these in many situations (the latter are obtained by prefixing the command with {help bootstrap}:).
If clustering of errors is suspected, the cluster option may be supplied to {help bootstrap}.{p_end}

{p}Variables specified in the {cmd:exog(}{vars}{cmd:)} option and not in the primary {vars}
are used as excluded instruments that are correlated with the endogenous variables in
{cmd:endog(}{vars}{cmd:)} and not the error term.{p_end}

{p}Note that Poisson regression assumes {bf:{bind:E[y|X]=exp(Xb)}} to get a consistent estimate of {bf:b},
so it is appropriate for 
a wide variety of models where the dependent variable is nonnegative (zero or positive),
not just where the dependent variable measures counts of events.
Wherever you might be inclined to take the logarithm of a nonnegative dependent variable {bf:y}
and use {help ivregress}, {cmd:ivpois} offers an alternative that includes in the
estimation observations where {bf:y} is zero.{p_end}

{p}Assuming {bf:{bind:E[y|X]=exp(Xb)}}, one can assume either 
an additive error or a multiplicative error, which produce different versions of the moment conditions.
The model used by {cmd:ivpois} assumes a multiplicative error.  
There is no explicit support for
panel models and cluster-robust SEs are supplied by {help bootstrap}, 
using the {cmdab:cl:uster(}{vars}{cmd:)} option.{p_end}

{p}On the moment conditions, the additive form for the error posits that {bf:{bind:y=exp(xb)+u}}
and gives moment conditions of the form {bf:{bind:Z'(y-exp(xb))=0}}, whereas the
multiplicative form posits {bf:{bind:y=exp(xb)u}} and gives moment conditions of
the form {bf:{bind:Z'(y-exp(Xb)/exp(Xb)))=Z'(y*exp(-Xb)-1))=0}} for 
instruments Z satisfying {bf:{bind:E(Z'u)=0}} (where Z includes all exogenous variables, both
included and excluded instruments).  Angrist (2001) shows that in a
model with endogenous binary treatment and a binary instrument, the
latter procedure (assuming a multiplicative error) estimates a
proportional local average treatment effect (LATE) parameter in models
with no covariates.  The latter is also more intuitively appealing and
congruent with {help poisson} and {help glm}, and the assumption can be
rewritten {bf:{bind:y=exp(xb)u=exp(xb)*exp(v)=exp(xb+v)}} 
so {bf:{bind:ln(y)=xb+v}} assuming {bf:{bind:y>0}} to
provide the natural link to OLS.
Windmeijer (2006) has a very useful discussion and further related models.{p_end}

{marker examples}{dlgtab:Examples}

{p}In each example, you can cut and paste the entire block of code to the Command window, or click on commands one by one to run.{p_end}

{hline}
{p}There is no theoretical model to support the next set of commands; they merely illustrate syntax.
You will need to {stata "ssc install estout":install estout} from SSC to run the {cmd:esttab} command.{p_end}
{hline}
{p 6 16 2}{stata "est clear": est clear }{p_end}
{p 6 16 2}{stata "sysuse auto, clear": sysuse auto, clear }{p_end}
{p 6 16 2}{stata "poisson mpg disp wei, r": poisson mpg disp wei, r }{p_end}
{p 6 16 2}{stata "est sto pois": est sto pois}{p_end}
{p 6 16 2}{stata "ivpois mpg wei, exog(turn) endog(disp)": ivpois mpg wei, exog(turn) endog(disp)}{p_end}
{p 6 16 2}{stata "est sto pois": est sto endog}{p_end}
{p 6 16 2}{stata "ivpois mpg disp wei, exog(turn) ": ivpois mpg disp wei, exog(turn)}{p_end}
{p 6 16 2}{stata "est sto excl": est sto excl}{p_end}
{p 6 16 2}{stata "ivpois mpg disp wei": ivpois mpg disp wei}{p_end}
{p 6 16 2}{stata "est sto noexcl": est sto noexcl}{p_end}
{p 6 16 2}{stata "g manuf=word(make,1)": g manuf=word(make,1)}{p_end}
{p 6 16 2}{stata "bs, cl(manuf): ivpois mpg wei, exog(turn) endog(disp)": bs, cl(manuf): ivpois mpg wei, exog(turn) endog(disp)}{p_end}
{p 6 16 2}{stata "est sto clustbs": est sto clustbs}{p_end}
{p 6 16 2}{stata "esttab *, nogaps se mti": esttab *, nogaps se mti}{p_end}

{hline}
{p}Comparison of {help poisson} to {cmd:ivpois} with an exposure variable and a small sample.{p_end}
{hline}
{p 6 16 2}{stata "est clear": est clear }{p_end}
{p 6 16 2}{stata "webuse dollhill3, clear ":webuse dollhill3, clear }{p_end}
{p 6 16 2}{stata "tab agecat, gen(a) ":tab agecat, gen(a) }{p_end}
{p 6 16 2}{stata "drop a4 a5 ":drop a4 a5 }{p_end}
{p 6 16 2}{stata "poisson deaths smokes a?, exposure(pyears) r ":poisson deaths smokes a?, exposure(pyears) r }{p_end}
{p 6 16 2}{stata "est sto p ":est sto p }{p_end}
{p 6 16 2}{stata "bs: poisson deaths smokes a?, exposure(pyears)":bs: poisson deaths smokes a?, exposure(pyears)}{p_end}
{p 6 16 2}{stata "est sto bsp ":est sto bsp }{p_end}
{p 6 16 2}{stata "ivpois deaths smokes a?, exposure(pyears) ":ivpois deaths smokes a?, exposure(pyears) }{p_end}
{p 6 16 2}{stata "est sto gmm ":est sto gmm }{p_end}
{p 6 16 2}{stata "bs: ivpois deaths smokes a?, exposure(pyears) ":bs: ivpois deaths smokes a?, exposure(pyears) }{p_end}
{p 6 16 2}{stata "est sto bsgmm ":est sto bsgmm }{p_end}
{p 6 16 2}{stata "esttab *, nogaps se mti": esttab *, nogaps se mti}{p_end}

{hline}
{p}The following three examples offer a comparison of linear regression of ln(y) on X to Poisson regression of y on X, and each model has 
some real economic content.
You will need to {stata "ssc install ivreg2":install ivreg2} from SSC to run the {cmd:ivreg2} command.{p_end}
{hline}
{phang}An example from Card (1995):{p_end}
{p 6 16 2}{stata "use http://fmwww.bc.edu/ec-p/data/wooldridge/card, clear" : use http://fmwww.bc.edu/ec-p/data/wooldridge/card, clear}{p_end}
{p 6 16 2}{stata `"loc x "exper* smsa* south mar black reg662-reg669" "': loc x "exper* smsa* south mar black reg662-reg669" }{p_end}
{p 6 16 2}{stata "ivreg2 lw `x' (educ=nearc4) " : ivreg2 lw `x' (educ=nearc4) }{p_end}
{p 6 16 2}{stata "ivpois wage `x', endog(educ) exog(nearc4) " : ivpois wage `x', endog(educ) exog(nearc4) }{p_end}

{phang}An example from Mullahy (1997) where {help ivreg2} reports no evidence of a weak instruments problem:{p_end}
{p 6 16 2}{stata "use http://fmwww.bc.edu/RePEc/bocode/i/ivp_bwt.dta, clear": use http://fmwww.bc.edu/RePEc/bocode/i/ivp_bwt.dta, clear}{p_end}
{p 6 16 2}{stata "g lnbw=ln(bw) ": g lnbw=ln(bw) }{p_end}
{p 6 16 2}{stata `"loc x "parity white male" "': loc x "parity white male" }{p_end}
{p 6 16 2}{stata `"loc z "edfwhite edmwhite incwhite cigtax88" "': loc z "edfwhite edmwhite incwhite cigtax88" }{p_end}
{p 6 16 2}{stata "ivreg2 lnbw `x' (cigspreg=`z') ": ivreg2 lnbw `x' (cigspreg=`z') }{p_end}
{p 6 16 2}{stata "ivpois bw `x', endog(cigspreg) exog(`z') ": ivpois bw `x', endog(cigspreg) exog(`z') }{p_end}

{phang}An example from Mullahy (1997) where {help ivreg2} reports evidence of a weak instruments problem:{p_end}
{p 6 16 2}{stata "use http://fmwww.bc.edu/RePEc/bocode/i/ivp_cig.dta, clear": use http://fmwww.bc.edu/RePEc/bocode/i/ivp_cig.dta, clear}{p_end}
{p 6 16 2}{stata "g lnc=ln(cigpacks) ": g lnc=ln(cigpacks) }{p_end}
{p 6 16 2}{stata `"loc x "pcigs79 rest79 income age qage educ qeduc famsize white""': loc x "pcigs79 rest79 income age qage educ qeduc famsize white"}{p_end}
{p 6 16 2}{stata `"loc z "ageeduc cage ceduc pcigs78 restock" "': loc z "ageeduc cage ceduc pcigs78 restock" }{p_end}
{p 6 16 2}{stata "ivreg2 lnc `x' (k210=`z') " : ivreg2 lnc `x' (k210=`z') }{p_end}
{p 6 16 2}{stata "ivpois cigpacks `x', endog(k210) exog(`z') " : ivpois cigpacks `x', endog(k210) exog(`z') }{p_end}

{hline}
{p}An alternative Generalized Linear Model ({help glm}) approach,
due to Hardin, Schmiediche, and Carroll (2003), is
designed to address endogeneity due to measurement error. Type
{stata "findit qvf":findit qvf} to install. The following
example, loosely based on the {help qvf} help file, favors the GMM approach:{p_end}
{hline}
{p 6 16 2}{stata "clear all": clear all}{p_end}
{p 6 16 2}{stata "set obs 1000 ": set obs 1000 }{p_end}
{p 6 16 2}{stata "gen x1 = uniform() ": gen x1 = uniform() }{p_end}
{p 6 16 2}{stata "gen x2 = uniform() ": gen x2 = uniform() }{p_end}
{p 6 16 2}{stata "gen x3 = uniform() ": gen x3 = uniform() }{p_end}
{p 6 16 2}{stata "gen err = invnorm(uniform()) ": gen err = invnorm(uniform()) }{p_end}
{p 6 16 2}{stata "gen y = exp(1+2*x1+3*x2+4*x3+err) ": gen y = exp(1+2*x1+3*x2+4*x3+err) }{p_end}
{p 6 16 2}{stata "gen t3 = .8*x3 + .6*invnorm(uniform()) ": gen t3 = .8*x3 + .6*invnorm(uniform()) }{p_end}
{p 6 16 2}{stata "qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)": qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)}{p_end}
{p 6 16 2}{stata "est sto qvf ":est sto qvf }{p_end}
{p 6 16 2}{stata "bs: qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)": bs: qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)}{p_end}
{p 6 16 2}{stata "est sto bsqvf ":est sto bsqvf }{p_end}
{p 6 16 2}{stata "ivpois y x1 x2, endog(x3) exog(t3) ": ivpois y x1 x2, endog(x3) exog(t3) }{p_end}
{p 6 16 2}{stata "est sto gmm ":est sto gmm }{p_end}
{p 6 16 2}{stata "bs: ivpois y x1 x2, endog(x3) exog(t3) ": bs: ivpois y x1 x2, endog(x3) exog(t3) }{p_end}
{p 6 16 2}{stata "est sto bsgmm ":est sto bsgmm }{p_end}
{p 6 16 2}{stata "cap ssc inst estout": cap ssc inst estout}{p_end}
{p 6 16 2}{stata "esttab *, nogaps se mti": esttab *, nogaps se mti}{p_end}

{marker options}{dlgtab:Options summary}

{phang}
{cmd:exog({vars})} specifies a list of exogenous variables, possibly included in the primary {vars}.
Exogenous variables not included in the primary {vars} are considered {bf: excluded instruments}.

{phang}
{cmd:endog({vars})} specifies a list of endogenous variables, possibly included in the primary {vars}.
Endogenous variables not included in the primary {vars} are added to that list.

{phang}
{opth "exposure(varname:varname_e)"},
{opt offset(varname_o)}, 
{opt constraints(constraints)}, {opt collinear}; see
{helpb estimation options:[R] estimation options}.

{phang}
{opt from(matrix)} specifies a row matrix of initial values for {help optimize} to use.

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{phang}
Other {cmd:options} can be supplied to a {help bootstrap} prefix, including {cmd:reps(n)} requesting
a number of repetitions other than the default of 50 and
the {cmdab:cl:uster(}{vars}{cmd:)} option. In practice, the number of
{help bootstrap} replications should probably be much larger than 50, and convergence should be examined,
though simulations show that for a correctly specified model, 50 are sufficient for good performance.

{marker macros}{dlgtab:Remarks and saved results}

{p}The command saves the following results in {cmd:e()}:

Scalars
{col 4}{cmd:e(N)}{col 18}Number of observations used in estimation

Macros
{col 4}{cmd:e(cmd)}{col 18}{cmd:ivpois}
{col 4}{cmd:e(version)}{col 18}Version number 
{col 4}{cmd:e(depvar)}{col 18}Name of dependent variable

Matrices
{p 3 18 2}{cmd:e(b)} {space 8} Coefficient vector{p_end}
{p 3 18 2}{cmd:e(V)} {space 8} VCE estimate{p_end}

Functions
{col 4}{cmd:e(sample)}{col 18}Marks estimation sample


{marker refs}{title:References}

{p}On the GMM approach, see:{p_end}

{phang}Angrist, Joshua D. 2001. "Estimation of limited dependent variable
models with dummy endogenous regressors: simple strategies for
empirical practice." {it:Journal of Business and Economic Statistics,} 19:2-16.{p_end}

{phang}Hansen, Lars P. 1982. "Large Sample Properties of Generalized Methods of Moments Estimators." {it:Econometrica,} 50:1029-1054.{p_end}

{phang}Mullahy, John. 1997. "Instrumental-Variable Estimation of Count Data
Models: Applications to Models of Cigarette Smoking Behavior." {it:The Review of Economics and Statistics,} 79(4):586-593.{p_end}

{phang}Windmeijer, Frank. 2006. "GMM for Panel Count Data Models." Discussion
Paper No. 06/591, Department of Economics, University of Bristol.{p_end}

{p}On IV methods, see:{p_end}

{phang}Baum, Christopher F., Mark E. Schaffer, and Steven Stillman. 2007. "Enhanced routines for instrumental variables/generalized method of moments estimation and testing."
{browse "http://www.stata-journal.com/article.html?article=st0030_3":Stata Journal 7(4):465-506}.{p_end}

{phang}Nichols, Austin. 2007. "Causal inference with observational data." {browse "http://www.stata-journal.com/article.html?article=st0136":Stata Journal 7(4):507-541}.{p_end}

{p}For the {help glm}-style approach, see:{p_end}

{phang}Hardin, James W., Henrik Schmiediche, and Raymond J. Carroll. 2003. 
"Instrumental variables, bootstrapping, and generalized linear models." {it:The Stata Journal} 3(4): 351-360. 
See also {browse "http://www.stata.com/merror/":http://www.stata.com/merror/}.{p_end}

{p}The example using earnings as the outcome:{p_end}

{phang}Card, David E. 1995. "Using Geographic Variation in College Proximity to Estimate the
Return to Schooling" in {it: Aspects of Labour Economics: Essays in Honour of John Vanderkamp,}
edited by Louis Christofides, E. Kenneth Grant and Robert Swindinsky.
University of Toronto Press. See also {browse "http://www.nber.org/papers/w4483":NBER WP 4483}.

{marker acknow}{title:Acknowledgements}

{p}The central code was promulgated by Bill Gould at a Seminar in DC on November 2, 2007.
That Mata code was written by David Drukker at an earlier date, and reads as follows:{p_end}

{phang}{cmd:  m=((1/rows(Z)):*Z'((y:*exp(-X*b') :- 1)))'}{p_end}
{phang}{cmd:  crit=(m*W*m')}{p_end}

{p}Type {stata "viewsource ivpois.ado":viewsource ivpois.ado} to see that code {it: in situ} (four lines into the section that begins {cmd:mata:},
where all the Mata code appears).{p_end}

{p}Thanks to John Mullahy for sharing the data used in Mullahy (1997), and for writing that paper. Thanks to Mark Schaffer for pointing
out that using the zero vector as an initial value can result in failure of {help optimize} in some cases, and suggesting
a return to using the estimated coefficients from {help poisson} as initial values.
Thanks to Henry Schneider for asking for an exposure option.  Thanks to John Zedlewski for asking for a speed improvment
using the d1 evaluatortype of {help optimize} and asymptotic standard errors.

{marker citation}{title:Citation of {cmd:ivpois}}

{p}{cmd:ivpois} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Nichols, Austin. 2007.
ivpois: Stata module for IV/GMM Poisson regression.
{browse "http://ideas.repec.org/c/boc/bocode/s456890.html":http://ideas.repec.org/c/boc/bocode/s456890.html}{p_end}

{title:Author}

    Austin Nichols
    Urban Institute
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual:  {hi:[U] 23 {help est: Estimation} and {help postest: post-estimation} commands}{p_end}
{p 10 14}{manhelp bootstrap R}{p_end}
{p 10 14}{manhelp poisson R}{p_end}
{p 10 14}{manhelp regress R}{p_end}
{p 10 14}{manhelp ivregress R}{p_end}

{p 1 10}On-line: help for (if installed) {help ivreg2},
{help overid}, {help ivendog}, {help ivhettest}, {help ivreset},
{help xtivreg2}, {help xtoverid}, {help ranktest},
{help condivreg}; {help qvf}.
{p_end}
