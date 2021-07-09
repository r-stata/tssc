{smcl}
{cmd:help mtefe}{right: ({browse "http://www.stata-journal.com/article.html?article=st00!!":SJ18-1: st00!!})}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col:{cmd:mtefe} {hline 2}}Marginal treatment effects with factor variables
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:mtefe} {depvar} [{indepvars}]
{cmd:(}{depvar:_t} {cmd:=} {varlist:_iv}{cmd:)}
{ifin} {weight} [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt pol:ynomial(#)}}specify the degree of the polynomial for the polynomial models; default is the joint normal{p_end}
{synopt:{opt spl:ines(numlist)}}allow for splines at knots specified by {it:numlist} in parametric models{p_end}
{synopt:{opt semi:parametric}}specify the semiparametric model{p_end}
{synopt:{opt res:tricted(varlist)}}control variables restricted to be the same in treated and untreated state{p_end}
{synopt:{opt l:ink(string)}}link function can be {cmd:probit}, {cmd:logit}, or {cmd:lpm}; default is {cmd:link(probit)}{p_end}

{syntab:Estimation}
{synopt:{opt sep:arate}}fit the model using the separate approach rather than local instrumental variables (LIVs){p_end}
{synopt:{opt mlik:elihood}}fit the model using maximum likelihood rather than local IVs; only for joint normal model{p_end}
{synopt:{opt trim:support(#)}}trim off {it:#} share of the treated and untreated sample from the thinnest tails of support{p_end}
{synopt:{opt full:support}}estimate marginal treatment effect (MTE) over the full unit interval even when using semiparametric models{p_end}
{synopt:{opt prte(varname)}}estimate policy-relevant treatment effects based on the propensity scores in {it:varname}{p_end}

{syntab:Inference}
{synopt:{opt boot:reps(#)}}use bootstrap with {it:#} repetitions{p_end}
{synopt:{opt norepeat1}}do not reestimate the propensity scores, mean of X, and parameter weights for each replication{p_end}
{synopt:{opt vce(vcetype)}}standard error specification -- {cmd:robust} or {cmd:cluster} {it:clustvar}{p_end}
{synopt:{opt level(#)}}specify confidence level{p_end}

{syntab:Semiparametric}
{synopt:{opt deg:ree(#)}}specify degree of local polynomial smooth in semiparametric models{p_end}
{synopt:{opt ybw:idth(#)}}specify bandwidth of local polynomial smooth for the outcome in semiparametric models{p_end}
{synopt:{opt xbw:idth(#)}}specify bandwidth of local polynomial smooth for X variables in the semiparametric model{p_end}
{synopt:{opt grid:points(#)}}evaluate the local polynomial smooths of X on p at {it:#} points rather than precise propensity scores{p_end}
{synopt:{opt kernel:(string)}}kernel for use in the semiparametric models{p_end}

{syntab:Other}
{synopt:{opt f:irst}}report the first-step estimates{p_end}
{synopt:{opt s:econd}}report the underlying second-stage (rarely used){p_end}
{synopt:{opt nop:lot}}do not graph common support and MTE plots{p_end}
{synopt:{opt savef:irst(string)}}save the first-stage estimates to disk as {it:string}{cmd:.ster}{p_end}
{synopt:{opt savep:ropensity(newvar)}}save the estimated propensity scores in a new variable {it:newvar}{p_end}
{synopt:{opt savekp}}save the variables of the K(p) [and K0(p)] functions in the dataset for postestimation{p_end}
{synopt:{opt saveweights(string)}}save the weights for the mean of X in in the subpopulations for the treatment effect parameters in variables with prefix {it:string}{p_end}
{synopt:{opt norescale}}Does not rescale the weights of the treatment effect parameters to sum to 1 in cases with limited support.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:fweight}s and {cmd:pweight}s are allowed unless bootstrapping; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:mtefe} calculates MTEs derived using a variety of parametric and
semiparametric models and three estimation methods.


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opt polynomial(#)} specifies the k(p) or k_j(p) functions to be polynomials
of degree {it:#}. Required for the parametric and semiparametric polynomial
models.  Note that {cmd:mtefe} specifies the degree of the MTE directly,
rather than the degree of K(p) like {cmd:margte}, so a polynomial of L+1 in
{cmd:margte} will be equivalent to L in {cmd:mtefe}.

{phang}
{opt splines(numlist)} allows for splines with knots at k1, k2, ... kQ as
specified in {it:numlist}. Specifies splines for degree 2 and above in k(p) or k_j(p).
Required for models with splines. Degree of polynomial must be greater than 1.

{phang}
{cmd:semiparametric} specifies that the models be fit using semiparametric
methods -- semiparametric polynomial, semiparametric polynomial with splines,
or semiparametric using double residual regression.

{phang}
{opt restricted(varlist)} specifies control variables that are included in the
first stage and second stage, but these are restricted to have the same effect
in the treated and untreated state.

{phang}
{opt link(string)} specifies the first-stage model. {it:string} may be
{cmd:probit}, {cmd:logit}, or {cmd:lpm}.  The default is
{cmd:link(probit)}.

{dlgtab:Estimation}

{phang}
{cmd:separate} specifies that the model be fit using the separate approach or
principled stratification. Otherwise, estimation is done using local IVs unless 
{cmd_mlikelihood} is specified.

{phang}
{cmd:mlikelihood} specifies that the model be fit using maximum likelihood.
This is appropriate only for the standard normal model.  The evaluator is an
adapted version of the maximum likelihood evaluator from Lokshin and Sajaia
(2004), see {helpb movestay}.

{phang}
{opt trimsupport(#)} trims the sample after estimating the propensity scores
to deal with issues of common support. After estimating the propensity scores,
this option estimates the density of p separately in each sample. It then
removes individuals from the points of least support until a total share {it:#}
of each sample has been removed. Common support is calculated at the points of
the propensity score distribution where the two samples have overlapping
support, estimation proceeds excluding the individuals with estimated
scores outside the range of the relevant subsample and the first stage is re-estimated
on the trimmed sample. This procedure drops exactly {it:#} share of the total sample,
but the final estmation sample will include observations outside the common support in 
the fat tail of each subsample of treated and control.

{phang}
{cmd:fullsupport} specifies that the MTE is estimated over the full unit
interval even when using semiparametric models.  By default, the MTE will only
be estimated at points of overlapping support in the treated and untreated
samples. Therefore, using {cmd:fullsupport} relies on extrapolation in the
local linear regressions, and may be unstable.  This option has no effect 
when using parametric models. Use with caution.

{phang}
{opt prte(varname)} fits the specified MTE model and calculates the PRTE for a
hypothetical policy change that generated the propensity score distribution in
variable {it:varname}.

{dlgtab:Inference}

{phang}
{opt bootreps(#)} uses the bootstrap for inference, performing {it:#}
bootstrap replications. Otherwise, analytic standard errors are calculated,
ignoring the estimation error from the first stage. See the remark on standard
errors below.

{phang}
{cmd:norepeat1} specifies that the first stage, treatment effect parameter weights
and means of X are not reestimated for each bootstrap repetition, thus ignoring 
the estimation error from the first stage in the bootstrap. See the remark on 
standard errors below.

{phang}
{opt vce(vcetype)} specifies standard errors -- {cmd:robust} or {cmd:cluster}
{it:clustvar}. Works for both analytic standard errors and bootstrapped ones.

{phang}
{opt level(#)} uses a confidence level of {it:#}% for confidence intervals and
MTE plots. The default is {cmd:level(95)}.

{dlgtab:Semiparametric}

{phang}
{opt degree(#)} specifies the degree of the local polynomial regressions used
in the semiparametric models. When using the semiparametric polynomial model,
this option is overruled by the degree specified in the {cmd:polynomial()}
option plus one, so this option is relevant only for the semiparametric model.
The degree of polynomial smooth is always 1 for the local polynomial
regressions of the covariates on p, so this affects only the degree in the
local polynomial regression of Y on p. The default is {cmd:degree(2)}.

{phang}
{opt ybwidth(#)} specifies the bandwidth of the local polynomial smooth of Y
on p in semiparametric models. The default is {cmd:ybwidth(0.2)}.

{phang}
{opt xbwidth(#)} specifies the bandwidth of the local polynomial smooth of the
covariates on p in semiparametric models. The default is {helpb lpoly}'s
rule-of-thumb.

{phang}
{opt gridpoints(#)} is used with the fully semiparametric model only. Instead
of running the local polynomial regressions of covariates on p at each and
every estimated propensity score, this option allows for estimating it at
{it:#} separate points spread out between the minimum and maximum of the
propensity score distribution and then assigns every individual the predicted
value from the closest point in this set before calculating the residuals. In
large samples, this may provide large improvement in computation time.
Does not affect the local polynomial regressions of Y on p that are always
performed at the points of common support.

{phang}
{opt kernel(string)} uses {it:string} as the kernel in all local polynomial
regressions. {it:string} may be {cmd:epanechnikov}, {cmd:biweight},
{cmd:cosine}, {cmd:gaussian}, {cmd:parzen}, {cmd:rectangle}, or
{cmd:triangle}. The default is {cmd:kernel(epanechnikov)}.

{dlgtab:Other}

{phang}
{cmd:first} reports the first-stage estimates.

{phang}
{cmd:second} reports the output from the second-stage estimating equation,
which might not be particularly easy to read because of temporary variables.
Use primarily for investigating the log-likelihood iterations when using
maximum likelihood.

{phang}
{cmd:noplot} suppresses the drawing of common support and MTE plots.

{phang}
{cmd:norescale} specifies that the treatment effect parameter weights are not rescaled
to sum to 1 in cases with limited support. When support is limited, regular non-marginal
treatment effect parameters (ATE, ATT, ATUT, LATE and PRTE) cannot be estimated. 
Instead, mtefe by default rescales the weights to sum to 1 within the support, creating
a parameter that can be interpreted analogously to the original, but for people with unobserved
resistance within the support. If norescale is specified instead, the weights are not rescaled.

{phang}
{opt savefirst(string)} saves the first-stage estimates to disk using the
filename {it:string}{cmd:.ster}. If suboption {opt margins} is specified,
{cmd:mtefe} instead saves the marginal effects for all variables.

{phang}
{opt savepropensity(newvar)} saves the predicted propensity scores from the
first stage to a new variable called {it:newvar}.

{phang}
{cmd:savekp} saves the variables used in K(p) and, if {cmd:separate} or
{cmd:mlikelihood} is specified, K0(p) in the dataset for postestimation use. 
Relevant only for parametric models.

{phang}
{opt saveweights(string)} saves the estimated weights for mean of X in the relevant
subopulations for the treatment effect parameters in variables with the prefix 
{it:string}. Weights are calculated for the ATT, ATUT, LATE, MPRTE1 and, if 
specified in the option {cmd:prte()}, PRTE.

{marker remarks}{...}
{title:Remarks}

    {title:The model}

{pstd}
The MTEs are derived from the generalized Roy model{p_end}

{p 10} Y = (1 - D)Y_0 + DY_1{p_end}
{pin}Y_j = Xb_j + U_j     for j=0,1{p_end}
{p 10} D = 1(Zg>V)	for Z=X,Z_{p_end}

{pstd}
where Y_1 is the outcome in the treated state, Y_0 is the outcome in the
untreated state, D is a binary treatment indicator, and 1[A] is the indicator
function for event A. Zg is an index that can be interpreted as a latent
utility of treatment.

{pstd}
Transforming the treatment condition gives P(Z)>U_d, where P(Z) is the
propensity score, or the probability of treatment given Z, and U_d=F(V) is the
percentiles of V, the unobserved resistance to treatment.

{pstd}
Estimation of MTE requires the (standard) IV assumptions of conditional
independence of the errors (U_0,U_1,V) from Z_ conditional on X.  This allows us
to estimate the MTE within the support of P(Z) conditional on X. In practical 
applications, however, this support is often very limited, and most applied work
therefore require an additional separability assumption: E(U_j | X,V) =
E(U_j | V).  This last assumption implies that the level of MTE, but not the
slope, is a function of X and allows us to identify the MTE over the
unconditional support of P(Z). In many cases, even the unconditional support of
P(Z) can be limited, and the MTE can only be estimated for parts of the unit interval.
See the note on support below for how mtefe treats these cases.

{pstd}
The MTE measures the average treatment effect for people at a particular
margin of indifference, or with a particular resistance to treatment. It can
be expressed as{p_end}

{pin}MTE(x,u) = E(Y_1-Y_0|X=x,U_d=u) = X(b_1-b_0)+k(u){p_end}

{pstd}where{p_end}

{pin}k(u) = E(U_1-U_0|U_d=u)

{pstd}
We can trace out the distribution of the MTE over U_d, MTE(x,u), within the
support of p.


    {title:Estimation using local IV}

{pstd}
It can be shown that the derivative of the conditional expectation of Y with
respect to p identifies the MTE (Heckman and Vytlacil 2007a,b). Given the
separability assumption, we have

{pin}E{Y|X,P(Z)=p} = Xb_0 + X(b_1-b_0)p +K(p){p_end}

{pstd}where{p_end}

{pin}K(p) = pE(U_1 - U_0|U_d < p){p_end}

{pstd}
Thus, if we make assumptions on the K(p) function, we can estimate the
conditional expectation of Y and form its derivative to construct the MTE.


    {title:Estimation using the separate approach}

{pstd}
When using the separate approach, we estimate the conditional expectation
separately in the treated and untreated sample. We apply the appropriate
selection correction, depending on the model, to account for the endogenous
selection into treatment. Following the notation of Brinch, Mogstad, and
Wiswall (2017),{p_end}

{pin}E(Y_j|X,D=j,p) = Xb_j + K_j(p){p_end}

{pstd}where{p_end}

{pin}K_1(p) = E(U_1|U_d < p){p_end}
{pin}K_0(p) = E(U_0|U_d >= p){p_end}

{pstd}
Thus, if we make assumptions on the K_j(p) functions, we can estimate the
conditional expectation. Then, we form the MTE as{p_end}

{pin}MTE(x,u)=E(Y_1-Y_0|X = x, U_d = u)  = X(b_1-b_0)+k_1(p)-k_0(p){p_end}

{pstd}
where{p_end}

{pin}k_1(p) = K_1(p)+pK_1'(p){p_end}
{pin}k_0(p) = K_0(p)-(1-p)K_0'(p){p_end}

{pstd}
As with the local IV method, the exact specification of the K-functions
depends on the model.


    {title:Estimation using maximum likelihood}

{pstd}
Alternatively, the joint normal MTE model can be estimated using maximum
likelihood because we know the full distribution of the errors.  In that case,
the log-likelihood function can be expressed as

{pin}
l=D[ln{F(eta_1)}+ln((1/s1)f(U_1/s1))] +(1-D)[ln((1/s0)f(U_0/s0))+ln{F(-eta_0)}]

{pstd}
where f and F are standard normal density and cumulative density functions
and{p_end}

{pin}eta_j = {Zg+(Y_j-Xb_j)*rho_j/s_j}/sqrt(1-rho_j^2)

{pstd}
which can be maximized to find the parameters of the model. For details, see
the {helpb movestay} command, which inspired the log-likelihood estimation in
{cmd:mtefe}, and Lokshin and Sajaia (2004).


    {title:A note on standard errors}

{pstd}
Local IVs and the separate approach as implemented by {cmd:mtefe} are two-step
methods.  In the first step, the propensity scores are estimated and predicted
and the treatment-effect parameter weights are estimated based on these
estimates. In the subsequent step, the rest of the parameters of the model are
estimated, and lastly, the MTE estimates themselves are constructed from the
estimates of b_1-b_0 and k(p).

{pstd}
In this setting, analytic standard errors are inappropriate because they
ignore the uncertainty from three sources: a) the uncertainty from the
propensity score estimates by simply treating p as a variable, b) the
uncertainty from the estimation of the treatment-effect parameter weights, and
c) the uncertainty from the estimates of X, the set of values for which we
evaluate the MTE and the treatment effect parameters.

{pstd}
If we are interested in the MTE at the (unknown) mean of X in the population,
it is appropriate to include the uncertainty in the estimate of the mean of X
in the estimates of the MTEs.

{pstd}
For all these reasons, the most conservative way to estimate standard errors
of MTE models are through the bootstrap. The bootstrap in {cmd:mtefe} takes
all the above mentioned sources of uncertainty into account by reestimating
the first step for each bootstrap replication, unless the options
{cmd:norepeat1} is specified.

{pstd}
Nonetheless, the default standard errors reported by {cmd:mtefe} are
calculated analytically, ignoring these sources of uncertainty. Users are
warned about this after estimation unless bootstrap is applied with the
{cmd:bootreps()} option. When cluster bootstrapping the standard errors 
(using bootreps() and the vce(cluster clustvar) options together), users
should be wary of specifications that also include the cluster variable 
in one of the independent variable lists. mtefe handles the most common 
application of this, when the cluster variable is included as fixed effects
in one of the independent variable lists, but with other (arguable uncommon) 
specifications such as the cluster variable included as a continuous regressor
and a fixed effect, users should be careful.

{pstd}
When using maximum likelihood estimation of the joint normal model, all model
parameters are estimated in one step. This implies that the analytic standard
errors are more appropriate, because they now account for the uncertainty of
the first-step estimates, but they still do not account for the uncertainty in
the estimation of the mean or the estimates of the treatment-effect parameter
weights.


    {title:A note on the support of P(Z)}

{pstd}
Under the separability assumption, the MTE can be identified
semiparametrically over the support of P(Z).  If the support is limited,
identification outside the common support will necessarily rely on
extrapolation.  By default, {cmd:mtefe} estimates the MTE over the full unit
interval if a parametric model is specified.  If a semiparametric model is
specified, however, {cmd:mtefe} estimates the MTE only at points where there
are at least one treated and one untreated individual, unless the option
{cmd:fullsupport} is specified.  In addition, the option {cmd:trimsupport()}
allows the user to trim a fraction of {it:#} from the tails of each sample, in
practice strengthening the conditions for what constitutes support.
Individuals with propensity scores outside the support for the relevant sample 
are dropped, and the first stage is reestimated when {cmd:trimsupport()} is 
specified. This option trumps the {cmd:fullsupport} option.{p_end}

{pstd}
In cases where the MTE is not estimated over the full unit interval, conventional
non-marginal treatment effect parameters (ATE, ATT, ATUT, LATE and PRTE) cannot
be estimated, as they depend on the MTE over the full unit interval. In these cases, 
the user should be careful when interpreting the treatment effect estimates.
{cmd:mtefe} by default rescales the treatment effect parameter weights to sum to 1 within
the support, producing a parameter that can be interpreted analogously to the original but for
people with unobserved resistance within the support. These parameters are identical to the 
originals only if the weighted average over the MTE outside of the support is equal to the 
weighted average within the support. Alternatively, if norescale is specified, mtefe does 
not rescale the weights when producing the parameter estimates. This parameter is equal 
to the original only if the MTE is equal to 0 outside of the support.

{marker examples}{...}
{title:Examples}

{pstd}
To fix ideas, the {cmd:mtefe_gendata} program simulates data on log wages for
people with varying experience, living in different districts or labor
markets, and with and without college education. College education is
endogenous, so we need an instrument to identify causal effects.
Unfortunately, even the distance to college is not a valid instrument because
there is correlation across districts; rural labor markets with longer
distances to colleges are different than urban ones. Within districts,
however, the distance to college is unrelated to unobservables, so the
instrument is valid conditional on fixed effects.

{pstd}
Generate simulated data of 10,000 observations distributed in 10
districts{p_end}
{phang2}{cmd:. mtefe_gendata, obs(10000) districts(10)}{p_end}

{pstd}
The parametric normal model, fit using local IV{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol)}{p_end}

{pstd}
The parametric polynomial of degree 1, estimated using the separate
approach{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), separate pol(1)}{p_end}

{pstd}
The polynomial model of degree 2, using a linear probability model for the
propensity score{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), polynomial(2) link(lpm)}{p_end}

{pstd}
The parametric normal model, fit using maximum likelihood{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), mlikelihood}{p_end}

{pstd}
The semiparametric polynomial model with 50 bootstrap replications {p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), pol(1) bootreps(50)}{p_end}

{pstd}
The joint normal model where the fixed effects are restricted to be the same in
the treated and untreated state (note: violation of exclusion) {p_end}
{phang2}{cmd:. mtefe lwage exp exp2 (col=distCol), restricted(i.district)}{p_end}

{pstd}
The semiparametric model, using a smaller evaluation grid to save computational time{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), semiparametric gridpoints(100)}{p_end}

{pstd}
Calculating the PRTE for a policy that mandates a maximum distance to college
of 40 miles, normal model{p_end}
{phang2}{cmd:. probit col distCol exp exp2 i.district}{p_end}
{phang2}{cmd:. rename distCol tempdistcol}{p_end}
{phang2}{cmd:. gen distCol=min(40,tempdistcol)}{p_end}
{phang2}{cmd:. predict double p_prte}{p_end}
{phang2}{cmd:. drop distCol}{p_end}
{phang2}{cmd:. rename tempdistcol distCol}{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), prte(p_prte)}{p_end}
{phang2}{cmd:. mtefeplot, prte}{p_end}

{pstd}
The polynomial model of degree 2 with two splines at 0.25 and 0.75, fit using
the local IV{p_end}
{phang2}{cmd:. mtefe lwage exp exp2 i.district (col=distCol), polynomial(2) splines(0.25 0.75)}{p_end}


{marker saved_results}{...}
{title:Stored results}

{pstd}
{cmd:mtefe} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(IV)}}regular two-stage least-squares estimate{p_end}
{synopt:{cmd:e(polynomial)}}degree of polynomial in polynomial models{p_end}
{synopt:{cmd:e(p_U)}}p-value for a test of unobserved heterogeneity -- the coefficients on k(p){p_end}
{synopt:{cmd:e(p_X)}}p-value for a test of observed heterogeneity -- the b_1-b_0 coefficients{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mtefe}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(title2)}}secondary title in estimation output{p_end}
{synopt:{cmd:e(method)}}estimation method{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}; {cmd:V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector, including MTE and treatment parameters{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of {cmd:b}, empty if using semiparametric methods and no bootstrap{p_end}
{synopt:{cmd:e(trimminglimits)}}trimming limits if using the trimsupport() option. {p_end}
{synopt:{cmd:e(support)}}vector of common support over p{p_end}
{synopt:{cmd:e(mte)}}vector of MTE estimates{p_end}
{synopt:{cmd:e(mtexs_ate)}}vector of x values for which the main MTE and ATE
were calculated{p_end}
{synopt:{cmd:e(mteatt)}}MTE curve for the treated individuals{p_end}
{synopt:{cmd:e(weightsatt)}}estimated weights at each point of support for the ATT{p_end}
{synopt:{cmd:e(mtexs_att)}}vector of x values for which the ATT was calculated{p_end}
{synopt:{cmd:e(mteatut)}}MTE curve for the untreated individuals{p_end}
{synopt:{cmd:e(weightsatut)}}estimated weights at each point of support for the ATUT{p_end}
{synopt:{cmd:e(mtexs_atut)}}vector of x values for which the ATUT was calculated{p_end}
{synopt:{cmd:e(mtelate)}}MTE curve for the compliers{p_end}
{synopt:{cmd:e(weightslate)}}estimated weights at each point of support for the LATE{p_end}
{synopt:{cmd:e(mtexs_atut)}}vector of x values for which the LATE was calculated{p_end}
{synopt:{cmd:e(mteprte)}}MTE curve for the policy compliers if specified in {cmd:prte()}{p_end}
{synopt:{cmd:e(weightsprte)}}estimated weights at each point of support for the PRTE (if specified in {cmd:prte()}){p_end}
{synopt:{cmd:e(mtexs_atut)}}vector of x values for which the PRTE was calculated (if specified in {cmd:prte()}){p_end}
{synopt:{cmd:e(dkdp)}}estimates of k(u) at the points of support{p_end}
{synopt:{cmd:e(weightsmprte1)}}estimated weights at each point of support for the MPRTE1 parameter{p_end}
{synopt:{cmd:e(weightsmprte2)}}estimated weights at each point of support for the MPRTE2 parameter{p_end}
{synopt:{cmd:e(weightsmprte3)}}estimated weights at each point of support for the MPRTE3 parameter{p_end}
{synopt:{cmd:e(tescales)}}scales of the non-marginal treatment effect parameters in situations with limited support{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{pstd}
If {cmd:semiparametric} is specified, the following matrices are stored:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(bandwidth)}}bandwidths used in local polynomial smooths, alternatively as {cmd:e(bandwidth1)} and {cmd:e(bandwidth0)} if the separate approach is used{p_end}
{synopt:{cmd:e(degree)}}degree in local polynomial smooth{p_end}

{pstd}
If {cmd:separate} or {cmd:mlikelihood} is specified, the following matrices
are stored:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(Y1)}}average outcomes in the treated state{p_end}
{synopt:{cmd:e(Y0)}}average outcomes in the untreated state{p_end}

{pstd}
Note: {cmd:bootstrap} stores its own output in {cmd:e()} as well.  See
{helpb bootstrap##saved_results:bootstrap}.

{pstd}
Note: Various options store results as variables as well. These include
{cmd:saveweights()}, where the variable prefix is user specified;
{cmd:savepropensity}, where the new variable name is user specified; and
{cmd:savekp}, where the variable names are predetermined to work with
postestimation predictions.




{marker references}{...}
{title:References}

{phang}
Brave, S., and T. Walstrum. 2014. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=st0331":Estimating marginal treatment effects using parametric and semiparametric methods}. {it:Stata Journal} 14: 191-217.

{phang}
Brinch C., M. Mogstad, and M. Wiswall. 2017. Beyond LATE with a discrete instrument. {it:Journal of Political Economy} 125: 985-1039.

{phang}
Heckman, J. J., and E. J. Vytlacil. 2007a. Econometric evaluation of social
programs, part I: Causal models, structural models and econometric policy
evaluation. In {it:Handbook of Econometrics}, vol. 6B, ed. J. J. Heckman and E.
E. Leamer, 4779-4874. Amsterdam: Elsevier.

{phang}
------. 2007b. Econometric evaluation of social programs, part II: Using the
marginal treatment effect to organize alternative econometric estimators to
evaluate social programs, and to forecast their effects in new environments. In
{it:Handbook of Econometrics}, vol. 6B, ed. J. J. Heckman and E. E. Leamer,
4875-5143. Amsterdam: Elsevier.

{phang}
Lokshin, M. and Z. Sajaia. 2004.
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=st0071":Maximum likelihood estimation of endogenous switching regression models}.
{it:Stata Journal} 4: 282-289.


{title:Thanks for citing mtefe as follows}

{pstd}
Andresen, Martin E., (2018). "MTEFE: Stata module to estimate marginal treatment effects". This version VERSION_DATE.{p_end}

{pstd}
where you can check your version date as follows:{p_end}

{phang2}{cmd:. which mtefe}{p_end}

	 
{marker Author}{...}
{title:Author}

{pstd}Martin Eckhoff Andresen{p_end}
{pstd}Statistics Norway{p_end}
{pstd}Oslo, Norway{p_end}
{pstd}martin.eckhoff.andresen@gmail.com{p_end}

{pstd}
This program is inspired by {helpb margte} by Brave and Walstrum (2014), who
deserve a huge thanks.  The maximum likelihood evaluator is adapted from
the {helpb movestay} command by Lokshin and Sajaia. Edwin Leuven, Katrine Løken, 
Magne Mogstad also deserve thanks for various help and bug reports.


{marker also_see}{...}
{title:Also see}

{p 4 14 2}
Development version: net install mtefe, from("https://raw.githubusercontent.com/martin-andresen/mtefe/master"){p_end}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 1: {browse "http://www.stata-journal.com/article.html?article=st0516":st0516}{p_end}

{p 7 14 2}
Help:  {helpb mtefeplot}, {helpb locpoly3}, {helpb nearmrg} (required for {cmd:gridpoints()}), {helpb movestay}, {helpb margte} (if installed){p_end}
