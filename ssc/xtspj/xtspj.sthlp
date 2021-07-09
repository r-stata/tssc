{smcl}

{title:Title}

{p}
xtspj: Split-panel jackknife estimation for fixed-effect panel data models
{p_end}	

{title:Description}

{p}
{cmd:xtspj} implements the first-order split-panel jackknife (also termed the half-panel jackknife) of Dhaene and Jochmans (2015)
for possibly nonlinear panel data models with fixed effects. These models produce a potentially inconsistent maximum likelihood (ML)
estimate of the common parameters {it: theta} (the parameters common to all cross-sectional units and time periods).
The data, {it:(Y_it,X_it)}, are indexed with {it:i} referring to the cross-sectional unit (or individual) and {it:t} to the time period. 
For each individual there is an individual-specific but time-invariant parameter {it:a_i}.
{p_end}

{p}
{cmd:xtspj} accepts both balanced and unbalanced data sets, but there must be no gaps in the time series. Missing data are excluded
automatically. The  data must be {help xtset:xtset} with both {it:panelvar} and {it:timevar}. If the regressand is a lagged
variable, it has to be generated manually prior to estimation. When the regressors contain lagged values of the regressand
up to p lags, the model becomes autoregressive of order p and is estimated conditional on the first p observations.
The maximizaton of the likelihood function is carried out by the Newton-Raphson algorithm.
{p_end}

{p}
{cmd:xtspj} may also be used as a fast (but less flexible) alternative to {help ml:ml} for maximum likelihood
estimation of panel data models with fixed effects.
{p_end}

{title:Syntax}

{phang}
Split-panel jackknife estimation of probit, logit, linear, negative binomial, Poisson, exponential, gamma,
and Weibull regression models with fixed effects:
{p_end}

{p 8 16 2}
	{opt xtspj} {depvar} [{indepvars}] {ifin} {cmd:,} {it:required_options}
	[{it:other_options}]
{p_end}

{phang}
Split-panel jackknife estimation of linear models (using closed-form expressions):
{p_end}

{p 8 16 2}
	{opt xtspj} {depvar} [{indepvars}] {ifin} {cmd:,} {opt mo:del(regress)} {it:required_options}
	[{it:other_options}] [{help regress:{it:regress_options}}]
{p_end}

{phang}
Split-panel jackknife estimation of user-written fixed-effect models:
{p_end}

{p 8 16 2}
	{opt xtspj} {it:eq} [{it:eq} ...] {ifin} {cmd:,} {it:required_options}
	[{it:other_options}]
{p_end}

{phang2}
where {it:eq} is similar to {help ml##eq:eq} of {help ml:ml}, i.e.,
{p_end}

{p 8 16 2}
( [{it:eqname:}] [{it:{help varlist:varlist_y}}] = [{indepvars}] [{it:, nocons}] )
{p_end}

{phang}
Note that "=" is required even if an equation has an empty right-hand side, i.e., if there is only a constant term.
In the first {it:eq}, which is always without constant term due to the presence of fixed effects, {opt nocons} is
implicitly assumed, without specifying it. When a factor variable appears as {indepvar} in more than one {eq},
it must appear with a different name in each {eq}. Hence one has to generate a duplicate of the underlying variable
for each additional {eq} where the factor variable appears.

{p_end}

{phang}
	{indepvars}, but not {depvar} or {it:{help varlist:varlist_y}}, may contain time-series operators and factor variables;
	see {help tsvarlist:tsvarlist} and {help fvvarlist:fvvarlist}.
{p_end}

{phang}
	{help regress:{it:regress_options}} are options of the {help regress:regress} command. They do not affect the estimation
	of the model parameters but do affect the estimated covariance matrix of the estimator. See	{help xtspj##Remarks:Remarks} below.
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr :required_options}
{synoptline}
	{synopt :{opt mo:del(string)}}
		specifies the type of regression model to be estimated: probit ({opt mo:del(probit)}), logit ({opt mo:del(logit)}), 
		linear ({opt mo:del(linear)}), negative binomial ({opt mo:del(negbin)}),
		Poisson ({opt mo:del(poisson)}), exponential ({opt mo:del(exponential)}),
		gamma ({opt mo:del(gamma)}), Weibull ({opt mo:del(weibull)}), 
		or some other, user-written model.
		For user-written models, see {help xtspj##UserWrittenModels:User Written Models}.
		The linear model can also be estimated by specifying {opt mo:del(regress)}; see {help xtspj##Remarks:Remarks} below.
	{p_end}
	{synopt :{opt me:thod(string)}}
		takes {cmd:none}, {cmd:like}, and {cmd:parm} for, respectively, no correction 
		(the usual ML estimate {it:theta_hat}), the split-panel jackknife estimate based on the jackknifed 
		log-likelihood ({it:theta_dot}), and the split-panel jackknife ML estimate ({it:theta_tilde}).
	{p_end}
{synoptline}

{synoptset 20 tabbed}{...}
{synopthdr :other_options}	
{synoptline}
{syntab:Estimation}
	{synopt: {opt l:evel(#)}}
		sets the confidence level. The default is {opt l:evel(95)}.
	{p_end}
	{synopt: {opt ltol(#)}}
		sets the tolerance level for changes in the objective function value. When the difference 
		between the objective function values of the current and the previous iteration, divided 
		by the absolute value of the current objective function value, is positive and smaller 
		than {opt l:evel(#)}, the algorithm stops and reports that convergence has been achieved.
		The default is {opt ltol(1e-4)}.
	{p_end}
	{synopt: {opt ptol(#)}}
		sets the tolerance level for changes in the parameter values. The algorithm stops and 
		reports convergence when the change in the parameter is smaller than {opt ptol(#)}.
		The change is computed as the absolute difference between the parameter values in the current and 
		the previous iteration. When the parameter is a vector, the maximum element of the vector 
		of absolute differences is taken. The default is {opt ptol(1e-4)}.
	{p_end}
	{synopt: {opt maxi:ter(#)}}
		sets the maximum number of iterations the algorithm is allowed to use. The default is {opt maxi:ter(100)}.
	{p_end}
	{synopt: {opt diag:nosis}}
		specifies that a simple diagnostic algorithm be invoked when the Newton-Raphson 
		algorithm gives an updated parameter vector that does not improve the objective function value
		(see {help xtspj##Remarks:Remarks} below). The diagnostic algorithm is slow and disabled by default.
	{p_end}
{syntab:Results}
	{synopt: {opt verb:ose}}
		specifies whether the iteration log of the maximization (i.e., the objective function values) 
		and extra notes (e.g., about omitted individuals) should be printed on the screen. The printed
		content can be lengthy. It is disabled by default.
	{p_end}
	{synopt: {opt a:lpha(newvarname)}}
		specifies the name of the variable to be created to store the estimates of the fixed effects 
		(the same value for all observations corresponding to {it:i}). When {opt me:thod(none)} is requested, 
		{it:newvarname} contains the ML estimate of the fixed effects. When {opt me:thod(like)} or 
		{opt me:thod(parm)} is requested, {it:newvarname} is the ML estimates of the fixed effects 
		with {it:theta} held fixed in the likelihood function at, respectively, 
		{it:theta_dot} and {it:theta_tilde}.
	{p_end}
{synoptline}

{title:Remarks}
{marker Remarks}{...}

{pstd}
Covariance matrix
{p_end}

{pin}
The covariance matrix of the estimated {it:theta} is computed as follows. When no correction 
is requested, the usual oim covariance matrix based on the Hessian of the concentrated 
log-likelihood is computed (see {help vce_option:vce_option}). When {opt me:thod(like)} or 
{opt me:thod(parm)} is requested, the covariance matrix is obtained from the same Hessian, 
but now evaluated at the corresponding estimate, {it:theta_dot} or {it:theta_tilde}. 
This requires maximizing the uncorrected log-likelihood with respect to the fixed-effect 
parameters while {it:theta} is kept fixed at {it:theta_dot} or {it:theta_tilde}. 
For this maximization, the options {opt ltol(#)}, {opt ptol(#)}, and {opt maxi:ter(#)} are 
also effective.
{p_end}

{pstd}
Option {opt diag:nosis}
{p_end}

{pin}
When {opt diag:nosis} is turned on, a diagnostic algorithm is invoked every time the current 
objective function value in the Newton-Raphson algorithm is smaller than that in the previous 
iteration. Given the gradient vector and Hessian matrix obtained from the previous iteration, 
the algorithm successively reduces the step size, used to update the parameter vector, from 1 
to 0.5, 0.5^2, ..., possibly down to a minimum value of 0.5^10. The objective function is 
evaluated at the parameter vector updated with the reduced step size. When the objective 
function value improves on that from the previous iteration, the diagnostic algorithm stops 
and maximization continues from the currently updated parameter vector. Otherwise it keeps
reducings the step size unless the minimum step size is already reached, in which case the 
diagnostic algorithm reports that no improvement could be achieved by reducing the step size, 
it stops, and maximization continues from the parameter vector obtained before the diagnostic 
algorithm was called.
{p_end}

{pstd}
Check of multicollinearity
{p_end}

{pin}
By default, the program runs a multicollinearity check {it:eq}-wise, for each half-panel; i.e., on the set of
regressors of each equation, with observations corresponding to each half-panel. The check is performed using the
command {help _rmcoll:_rmcoll}, and the coefficients of the omitted variables are kept in the regression,
but fixed at 0 and assigned a variance of 0. 
{p_end}

{pin}
When {help fvvarlist:fvvarlist} is present, the indicators corresponding to the base level
(marked with {cmd:b.}) and those marked with {cmd:o.} by {help fvexpand:fvexpand} are omitted from the estimation
in the same way as above.
{p_end}

{pstd}
Noninformative individuals
{p_end}

{pin}
For the probit and logit regression models, a check is performed for each individual {it:i} in each of 
the subpanels to ensure that the regressand varies across {it:t}. When the regressand do not vary across {it:t},
the individual is omitted from the estimation altogether, because it is not informative. A similar check is also
performed in, e.g., {help probit:probit}. Similarly, for the Poisson and negative binomial regression models,
individuals for which the regressand is zero for all {it:t} are uninformative and are therefore dropped. 
For the exponential, gamma, and Weibull regression models, individuals for which the regressand is nonpositive are dropped;
this is similar to {help streg:streg}.

{p_end}

{pstd}
{opt mo:del(linear)} vs. {opt mo:del(regress)}
{p_end}

{pin}
When ({opt mo:del(linear)}) is specified, the linear model estimates are computed by maximization of a Gaussian log-likelihood
using the Newton-Raphson algorithm. When ({opt mo:del(regress)}) is specified, the linear model estimates are computed
using least-squares-based closed-form expressions. Apart from small numerical differences, the two ways of
computing the estimates gives identical results.
{p_end}

{pin}
When {opt mo:del(regress)} is specified, no estimate of the error variance is reported, as is often the case for least-squares-based procedures.
When {opt mo:del(linear)} is specified, the estimated error variance is reported, as is standard for ML-based procedures.
For the implementation, {opt mo:del(regress)} computes within-group estimates. If {opt me:thod(none)} is specified,
the resulting coefficient estimates are identical to those obtained from {help xtreg:xtreg, fe}.
{p_end}

{pin}
Users are advised to use {opt mo:del(regress)} when the error variance is not of interest. Since {opt mo:del(regress)} uses
closed-form expressions to compute the estimates, it is faster and more accurate than {opt mo:del(linear)}.
{p_end}

{pin}
When {opt mo:del(regress)} is specified, the options {opt ltol(#)}, {opt ptol(#)}, {opt maxi:ter(#)}, {opt diag:onsis}, and {opt verb:ose}
are ineffective (i.e., they are ignored). The option {opt a:lpha(newvarname)} remains effective.
{p_end}

{pin}
When {opt mo:del(regress)} is specified, the estimated covariance matrix is obtained from the {help regress:regress} command by estimating the
model using the same dataset but after the within transformation. Here, when {help regress:regress} is called, the {opt nocons} option
is activated and cannot be overridden. However, other options for the {help regress:regress} command can be specified via
{help regress:{it:regress_options}} in order to control the estimation of the covariance matrix. In particular, {opt robust} can be specified
to obtain robust covariance matrix estimates.
{p_end}

{pstd}
Model parameterizations
{p_end}

{pin}
The parameterizations for the probit, logit, and Poisson regression models are standard. For the negative binomial model, the
parameterization is the same as for {help nbreg:nbreg}.
{p_end}

{pin}
For the gamma regression model the log-likelihood is specified as
{p_end}

{pin2}
{it:log[f(Y_it|X_it; theta, a_i, kappa)] = - log[gamma(kappa)] - kappa * log(u_it) - (kappa - 1) * log(Y_it) - Y_it / u_it }
{p_end}

{pin}
with
{p_end}

{pin2}
{it: u_it = exp(X'_it * theta + a_i)}
{p_end}

{pin}
where {it:a_i} is the {it:i}th fixed effect and {it:kappa} is a scalar shape
parameter. This parameterization is the same as for {help glm:glm, family(gamma) link(log)} for the
regression slope coefficients; we also report the shape parameter estimate.
{p_end}

{pin}
For the exponential regression model the log-likelihood is specified as
{p_end}

{pin2}
{it:log[f(Y_it|X_it; theta, a_i)] = log(1/u_it) - Y_it / u_it},
{p_end}

{pin}
which is the same as for {help glm:glm, family(gamma) link(log)}.
{p_end}

{pin}
For the Weibull regression model the log-likelihood is specified as
{p_end}

{pin2}
{it:log[f(Y_it|X_it; theta, a_i, k)] = log(kappa) + (kappa-1) * log(Y_it) + log(u_it) - u_it * Y_it ^ kappa}
{p_end}

{pin}
where {it:kappa=exp(k)}.
{p_end}

{title:Example}

{pstd}Data setup{p_end}
{phang2}{cmd:. webuse chicken, clear}{p_end}
{phang2}{cmd:. gen worker=.}{p_end}
{phang2}{cmd:. by restaurant: replace worker=_n}{p_end}
{phang2}{cmd:. xtset restaurant worker}{p_end}
{phang2}{cmd:. label define sex 0 "female" 1 "male"}{p_end}
{phang2}{cmd:. label values gender sex}{p_end}

{pstd}Uncorrected fixed-effect probit ML{p_end}
{phang2}{cmd:. xtspj complain age i.gender, model(probit) method(none)}{p_end}

{pstd}Jackknifed log-likelihood{p_end}
{phang2}{cmd:. xtspj complain age i.gender, model(probit) method(like)}{p_end}

{pstd}Jackknifed ML{p_end}
{phang2}{cmd:. xtspj complain age i.gender, model(probit) method(parm)}{p_end}

{title:Stored Results}

{p}
{cmd:xtspj} stores the following in {cmd:e()}:
{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(empty)}}contains 1 if there are no covariates in the model{p_end}
{synopt:{cmd:e(converged)}}contains 1 if the maximization converged{p_end}
{synopt:{cmd:e(ll)}} log-likelihood value (only for {opt me:thod(none)} or {opt me:thod(like)} when {opt mo:del(regress)} is not specified)
{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}covariance matrix{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(model)}}value of {opt mo:del(string)}{p_end}
{synopt:{cmd:e(method)}}value of {opt me:thod(string)}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtspj}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(vce)}}{cmd:oim} or vcetype specified in vce() (for {opt mo:del(regress)} only){p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err. (for {opt mo:del(regress)} only){p_end}
{synopt:{cmd:e(title)}}title of table of results{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(depvar)}}the regressands or the list of regressands (when user-written model with several {it:{help ml##eq:eq}} were specified)
{p_end}

{marker UserWrittenModels}{...}
{title:User-written Models}

{pstd}
Parameterization of the density
{p_end}

{pin}
To use {cmd:xtspj} with a user-written model, the density has to be of the form
{p_end}

{pin}
{it:f(Y_it|X_it; u_1_it, ..., u_M_it)}
{p_end}

{pin}
with
{p_end}

{pin}
{it:u_1_it = X'_1_it * theta_1 + a_i},
{p_end}
{pin}
{it:u_m_it = X'_m_it * theta_m}
{p_end}

{pin}
where {it:a_i} is the fixed effect of the {it:i}-th individual and m=2,...,M for an arbitrary 
number of {it:M>=1} equations depending on covariates {it:X_m_it}. The regressands {it:Y_it} can 
be a vector, at most of dimension {it:M}. The first equation, {it:u_1_it} contains an additive 
fixed effect. Nevertheless, this design is general in the sense that, when the fixed effects enter 
non-additively, one simply needs to keep the first equation free of covariates. It is also possible 
to set {it:X_m_it=1} for one or several {it: m>1}; then the corresponding {it:u_m_it=theta_m} are 
simply parameters entering the model.
{p_end}

{pstd}
User-written evaluator
{p_end}

{pin}
The likelihood function has to be specified as a {help mata:mata} {help m2_class:class} containing two 
member functions {cmd:::Evaluate()} and {cmd:::Check()}. The template for the class is
{p_end}
{marker ClassTemplate}{...}
{cmd:	1 | mata}
{cmd:	2 | class xtspj{it:YourModel} extends xtspjModel {c -(}}
{cmd:	3 | 	public:}
{cmd:	4 | 		void Evaluate(), Check()}
{cmd:	5 | {c )-}}
{cmd:	6 | void function xtspj{it:YourModel}::Evaluate(}
{cmd:	7 | 		real matrix Y,}
{cmd:	8 | 		real matrix XB,}
{cmd:	9 | 		real colvector LogLikelihood,}
{cmd:	10|  		real matrix Gradient,}
{cmd:	11|  		pointer(real colvector) matrix Hessian) {c -(}}
{cmd:	12|  			// compute the log-likelihood, gradient, and Hessian.}
{cmd:	13|  {c )-}}
{cmd:	14|  void function xtspj{it:YourModel}::Check(}
{cmd:	15|  		real matrix Data,}
{cmd:	16|  		real scalar Keep) {c -(}}
{cmd:	17| 			// check data.}
{cmd:	18| {c )-}}
{cmd:	19| end}	

{pin}
The user needs to supply the relevant mata code in the lines 12 and 17 as discussed below, and change 
{cmd:{it:YourModel}} (lines 2, 6, and 14) to a desired name, e.g., {cmd:MyModel}. When {cmd:xtspj} is executed, 
this name must be specified in the option {opt mo:del(string)}, e.g., {opt mo:del(MyModel)}, so that 
{cmd: xtspj} calls the user-written specification of the log-likelihood function.
{p_end}

{pin}
{ul on}{cmd:void function ::Evaluate()}{ul off}
{p_end}

{pin}
This function computes the log-likelihood, gradient, and Hessian for a given set of observations {it:(i,t)}. 
The function is called repeatedly and separately for each {it:i} and various sets {it:{t}}. The arguments 
of {cmd:::Evaluate()} are:
{p_end}

{phang2}
- {cmd:real matrix Y},
	the matrix of regressands. The {it:k}-th column of Y corresponds to the {it:k}-th regressand defined 
	by an {it:{help ml##eq:eq}}, and each row corresponds to an observation {it:(i,t)} with {it:t}
	belonging to a specific set {it:{t}}.
{p_end}

{phang2}
- {cmd:real matrix XB},
	the matrix of linear indices ({it:u_m_it} for {it:1<=m<=M}). The {it:m}-th column corresponds 
	to the {it:m}-th equation and each row corresponds to an observation {it:(i,t)}.
{p_end}

{phang2}
- {cmd:real colvector LogLikelihood},
	the column vector of log-likelihood values. Each row contains the log-likelihood value corresponding to 
	an observation {it:(i,t)} evaluated at the corresponding row of {cmd:XB} and {cmd:Y}; i.e.,
{p_end}

{it:			log[f(Y_it|X_it; u_1_it, ..., u_M_it)]}

{phang3}
where {it:t} belongs to a given {t}.
{p_end}

{phang2}
- {cmd:real matrix Gradient},
	the matrix of scores. The {it:m}-th column of {cmd:Gradient} corresponds to the log-likelihood 
	derivative with respect to the {it:m}-th equation, evaluated at {cmd:XB} and {cmd:Y}; i.e.,
{p_end}

{it:			d log[f(Y_it|X_it; u_1_it, ..., u_M_it)]}
{it:			----------------------------------------}
{it:			            d u_m_it               }

{phang3}
where {it:t} belongs to a given {t}.
{p_end}

{phang2}
- {cmd:pointer(real colvector) matrix Hessian},
	the {help m2_pointers:pointer} matrix pointing to the Hessian. The matrix must be 
	{help mf_makesymmetric:made symmetric}. The {it:(m,n)}-th element of Hessian is a pointer to the 
	column vector of second-order log-likelihood derivatives with respect to the {it:m}-th and {it:n}-th 
	equation, evaluated at {cmd:XB} and {cmd:Y}; i.e.,
{p_end}

{it:			d^2 log[f(Y_it|X_it; u_1_it, ..., u_M_it)]}
{it:			------------------------------------------}
{it:			          d u_m_it  d u_n_it         }

{phang3}
where {it:t} belongs to a given {t}.
{p_end}

{pin}
Here the arguments {cmd:real matrix gradient} and {cmd:pointer(real colvector) matrix Hessian} are optional.
If they are not changed inside {cmd:::Evaluate()}, {cmd:xtspj} uses a numerical differentiation algorithm 
to compute the derivatives.
{p_end}

{pin}
Below is an example of {cmd:::Evaluate()} for the probit model:
{p_end}

{cmd:	1 | void function xtspjprobit::Evaluate(}
{cmd:	2 | 		real matrix Y,}
{cmd:	3 | 		real matrix XB,}
{cmd:	4 | 		real colvector LogLikelihood,}
{cmd:	5 |  		real matrix Gradient,}
{cmd:	6 |  		pointer(real colvector) matrix Hessian) {c -(}}
{cmd:	7 |  			q=(Y:*2:-1)}
{cmd:	8 |  			LogLikelihood=lnnormal(q:*XB)}
{cmd:	9 |  			Gradient=q:*(normalden(q:*XB):/normal(q:*XB))}
{cmd:	10|  			Hessian=&(-Gradient:*(XB+Gradient))}
{cmd:	11|  {c )-}}

{pin}
Here the first point to be noted is that {it:YourModel} is replaced with {cmd:probit}. The {cmd:LogLikelihood}, 
{cmd:Gradient}, and {cmd:Hessian} are computed in lines 8 to 10. Lines 9 and 10 can be omitted for a numerical 
differentiation algorithm to take over.
{p_end}

{pin}
When a model contains more than one equation ({it:M>1}), the variable {cmd:Gradient} and {cmd:Hessian} may 
need to be preallocated to expedite the computation. To do so, simply insert
{p_end}

{cmd:	1 | Gradient=J(rows(Data),cols(Data),.)}
{cmd:	2 | Hessian=J(rows(Data),cols(Data),NULL)}

{pin}
between lines 6 and 7. In addition, one should avoid reusing variables in the calculation of the Hessian; 
i.e., code such as
{p_end}

{cmd:	1 | H=...}
{cmd:	2 | Hessian[1,1]=&H}
{cmd:	3 | H=...}
{cmd:	4 | Hessian[1,2]=&H}

{pin}
should be replaced by
{p_end}

{cmd:	1 | H11=...}
{cmd:	2 | Hessian[1,1]=&H11}
{cmd:	3 | H12=...}
{cmd:	4 | Hessian[1,2]=&H12}

{pin}
{ul on}{cmd:void function ::Check()}{ul off}
{p_end}

{pin}
If a check is not desired, one can simply replace line 17 in {help xtspj##ClassTemplate:this code} with 
{cmd: Keep=1}. To perform a model-specific check of the data, one has to supply suitable code to {cmd:::Check()}.
Similar to {cmd:::Evaluate()}, the function is called repeatedly and separately for each 
{it:i} and various sets {it:{t}}. The arguments are:
{p_end}

{phang2}
- {cmd:real matrix Data},
	the data to be checked. The columns of {cmd:Data} correspond to the regressands of the model, followed 
	by the regressors, in the same order as specified by the equations. The rows correspond to the 
	observations {it:(i,t)} with {it:t} belonging to a given set {it:{t}}.
{p_end}
{phang2}
- {cmd:real scalar Keep},
	the main output. {cmd:Keep} is set to {cmd:1} if {cmd:Data} passes the check, and to {cmd:0} otherwise.
{p_end}

{pin}
Below is an example of {cmd:::Check()} for the probit model:
{p_end}

{cmd:	1 |  void function xtspjprobit::Check(}
{cmd:	2 |  		real matrix Data,}
{cmd:	3 |  		real scalar Keep) {c -(}}
{cmd:	4 | 			if (sum(Data[.,1])==0 || sum(Data[.,1])==rows(Data)) {c -(}}
{cmd:	5 | 				Keep=0}
{cmd:	6 | 			{c )-} else {c -(}}
{cmd:	7 | 				Keep=1}
{cmd:	8 | 			{c )-}}
{cmd:	9 | {c )-}}

{title:References}

{phang}
	Dhaene, G., and K. Jochmans. 2015. Split-panel jackknife estimation of fixed-effect models. {it:The Review of Economic Studies}
	82(3): 991-1030.
{p_end}



