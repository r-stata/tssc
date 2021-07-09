{smcl}
{* 26apr2017}{...}
{cmd:help for xtmixediou}{right:Rachael Hughes}
{hline}

{title:Title}

{p2colset 5 19 16 2}{...}
{p2col :{hi:xtmixediou} {hline 2}}Linear mixed effects Integrated Ornstein-Uhlenbeck model{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:xtmixediou} {depvar} [{indepvars}] {ifin} {cmd:,}
{cmd:id(}{it:{help varname:levelvar}}{cmd:)}
{cmd:time(}{it:{help varname:timevar}}{cmd:)}
[ {it:other_options} ] 
 
{p 8} 
where {it:levelvar} is a variable identifying the group structure for the random effects and {it:timevar} is a variable identifying the observation timepoints of {it:depvar}.


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt *id(levelvar)}}defines the group structure variable for the random effects{p_end}
{synopt :{opt *time(timevar)}}variable for the measurement times of {it:depvar}{p_end}
{synopt :{opt nofec:onstant}}suppresses the constant term for the fixed portion of the model{p_end}
{synopt :{opt re:ffects(varlist)}}defines the random effects of the model{p_end}
{synopt :{opt norec:onstant}}suppresses the constant term for the random portion of the model{p_end}
{synopt :{cmd:iou(}{help xtmixediou##ioutype:ioutype}{cmd:)}}specifies the parameterization of the IOU process used in estimation{p_end}
{synopt :{opt brown:ian}}specifies a scaled Brownian Motion process, which is a special case of the IOU process{p_end}
{synopt :{opt svdata:derived}}starting values derived from the data{p_end}
{synopt :{opt alg:orithm(algorithm_spec)}}maximization algorithm{p_end}
{synopt :{opt iter:ate(#)}}performs maximum of # iterations; default is iterate(16000){p_end}
{synopt :{opt dif:ficult}}uses a different stepping algorithm in nonconcave regions{p_end}
{synopt :{opt nolo:g}}suppresses the display of the iteration log{p_end}
{synopt :{opt tr:ace}}displays the current parameter vector in iteration log{p_end}
{synopt :{opt grad:ient}}displays the current gradient in iteration log{p_end}
{synopt :{opt showstep}}reports steps within an iteration log{p_end}
{synopt :{opt hess:ian}}displays the current Hessian matrix in iteration log{p_end}
{synoptline}
{p 4 6 2}{cmd:*id(}{it:levelvar}{cmd:)} and {cmd:*time({it:timelvar})} are required options.

{marker algorithm_spec}{...}
{p 4 6 2}
where {it:algorithm_spec} is

{p 8 8 2}
{it:algorithm} [ {it:#} [ {it:algorithm} [{it:#}] ] ... ]

{p 4 6 2}
and {it:algorithm} is {c -(}{opt nr} {c |} {opt fs} {c |} {opt ai}{c )-}.{p_end}

{marker ioutype}{...}
{synopthdr :ioutype}
{synoptline}
{synopt :{opt at}}IOU parameterization is {alpha} and tau, the default{p_end}
{synopt :{opt ao}}IOU parameterization is alpha and omega = (tau{c 178}/alpha{c 178}){p_end}
{synopt :{opt lnat}}IOU parameterization is ln(alpha) and tau{p_end}
{synopt :{opt lnao}}IOU parameterization is ln(alpha) and omega = (tau{c 178}/alpha{c 178}){p_end}
{synopt :{opt isat}}IOU parameterization is 1/(alpha{c 178}) and tau{p_end}
{synopt :{opt isao}}IOU parameterization is 1/(alpha{c 178}) and omega = (tau{c 178}/alpha{c 178}){p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:xtmixediou} fits a two-level linear mixed effects model with an added Integrated Ornstein-Uhlenbeck (IOU) nonstationary stochastic process, which can be applied to balanced and unbalanced longitudinal continuous data. 
The model allows for different levels of derivative tracking; that is, the degree to which a 
subject's longitudinal measurements maintain the same trajectory over long periods of time. 
Note that, a linear mixed effects model without an IOU process assumes strong derivative tracking (i.e., a subject's measurements follows
the same trajectory over long periods). The IOU process also allows the variance of the within-subject errors to change over time and for serial correlation, 
where the correlation between two measurements (within a subject) decreases with increasing time difference.

{pstd}
The IOU process is parameterized by two parameters alpha and tau (or functions of alpha and tau).
Parameter alpha is a measure of the degree of derivative tracking, where a small value indicates strong derivative tracking. Parameter tau serves as a scaling parameter. 
As alpha tends to infinity and the ratio tau{c 178}/alpha{c 178}
is held constant the IOU process becomes the scaled Brownian Motion (BM) process, which is parameterized by a single parameter phi. 

{pstd}
The overall error distribution of the linear mixed effects model is assumed to be Gaussian. The model is fitted using restricted maximum likelihood (REML) estimation.
 
{title:Options}

{dlgtab:model}

{phang}
{opt id(levelvar)} defines the variable for identifying subjects (level-2 units). {it:levelvar} can be a numeric variable or a string variable. This is a required option.

{phang}
{opt time(timevar)} defines the numeric variable for the observation timepoints of {it:depvar}. This is a required option.

{phang}
{opt nofeconstant} suppresses the constant term for the fixed portion of the model. By default a constant term is included in the fixed portion of the model.

{phang}
{opt reffects(varlist)} defines the random effects of the model. xtmixediou automatically includes a constant term in the random effects. For two or more random effects
an unstructured covariance matrix is assumed (i.e., all variances and covariances are distinctly estimated). Factor variables are not allowed. The default (when
reffects(varlist) is not specified) is a random intercept.

{phang}
{opt noreconstant} suppresses the constant term for the random effects of the model. By default a constant term is included in the random portion of the model.

{phang}
{opt iou(ioutype)} specifies the parameterization of the IOU process used during REML estimation. 
Six different parameterizations of the IOU process are allowed (see {help xtmixediou##ioutype:ioutype}). 
The default parameterization is alpha and tau ({it:ioutype=at}). Changing the IOU parameterization may improve convergence. 
For example, parameterizations ln(alpha) or 1/(alpha{c 178}) may be useful if alpha is suspected to be large.
There is no guarantee that any of the other parameterizations work better than the default; sometimes it is better and sometimes it is worse.

{phang}
{opt brownian} specifies a scaled Brownian Motion (BM) process, a special case of the IOU process, which is parameterized by a single parameter phi. The BM process represents no
derivative tracking and the fitted model then becomes the linear mixed effects Brownian Motion model.

{phang}
{opt svdataderived} specifies that the starting values of all of the model's variance parameters (i.e., random effects variances and
covariances, IOU or BM parameters and measurement error variance) are derived from the data. svdataderived assumes the user has specified 
(using options reffects() and/or noreconstant) that the random effects only include a random intercept and/or a random linear slope. 
When svdataderived is not specified (i.e., the default) then a linear mixed effects model without an added IOU or BM process is 
fitted (using Stata’s command mixed) and the resulting expectation maximization estimates are used as the starting values for the random effects variances 
and covariances, and the measurement error variance; whilst the starting values for the IOU or BM parameters are set to small positive values 
(i.e., representing strong derivative tracking). {cmd:xtmixediou} saves the starting values to matrix {cmd:e(sv)}.

{phang}
{opt algorithm(algorithm_spec)} specifies the optimization algorithm used to perform REML estimation. 
 The following algorithms are allowed:
 
{pmore}
        {cmd:algorithm(nr)} specifies the Newton-Raphson (NR) algorithm.

{pmore}
        {cmd:algorithm(fs)} specifies the Fisher Scoring (FS) algorithm. 

{pmore}
		{cmd:algorithm(ai)} specifies the Average Information (AI) algorithm.

{pmore}
		The default is {cmd:algorithm(nr)}.
       
{pmore}
	   You can switch between algorithms by specifying more than one in the {cmd:algorithm()} option.  By default, an algorithm is used for
       five iterations before switching to the next algorithm. To specify a different number of iterations, include the number after the algorithm in
       the option.  For example, specifying {cmd:algorithm(fs 10 nr 1000)} requests using 10 iterations with the FS algorithm
       followed by 1000 iterations with the NR algorithm, and then switch back to FS for 10 iterations, and so on.  The process continues until
       convergence or until the maximum number of iterations is reached.

{pmore}  
	   Convergence of the NR algorithm may be improved by starting with a few, say 3, iterations of the FS or AI algorithm, especially when the starting values 
	   of the parameters are suspected to be far from the REML estimates.
		
{phang}
{opt iterate(#)} specifies the maximum number of iterations.
When the number of iterations equals {cmd:iterate()}, the optimizer stops and
presents the current results.  If convergence is declared before this
threshold is reached, it will stop when convergence is declared. The default value is {cmd:iterate(16000)}. 

{phang}
{opt difficult} specifies that the likelihood function is likely to be
difficult to maximize because of  nonconcave regions.  When the message "not
concave" appears repeatedly, {opt ml}'s standard stepping algorithm may not be
working well.  {opt difficult} specifies that a different stepping algorithm be
used in nonconcave regions.  There is no guarantee that {opt difficult} will
work better than the default; sometimes it is better and sometimes it is
worse.  You should use the {opt difficult} option only when the default stepper
declares convergence and the last iteration is "not concave" or when the
default stepper is repeatedly issuing "not concave" messages and producing only
tiny improvements in the log likelihood.

{phang}
{opt nolog} suppresses the display of the iteration log showing the progress of the log likelihood. The log is displayed by default.

{phang}
{opt trace} adds to the iteration log a display of the current parameter vector. 

{phang}
{opt gradient} adds to the iteration log a display of the current gradient vector.

{phang}
{opt showstep} adds to the iteration log a report on the steps within an iteration. 

{phang}
{opt hessian} adds to the iteration log a display of the current negative Hessian matrix.

{title:Examples}

{synoptline}

{phang}
Random intercept IOU model{p_end}
{space 10}{cmd:. xtmixediou ln_cd4 measurement age sex, id(patient_id) time(measurement)}

{phang}
Random intercept and random slope IOU model, with the IOU process parameterized as eta = ln(alpha) and tau{p_end}
{space 10}{cmd:. xtmixediou ln_cd4 measurement age sex, id(patient_id) time(measurement) re(measurement) iou(et)}

{phang}
Random intercept and random slope IOU model, with all starting values derived from the data{p_end}
{space 10}{cmd:. xtmixediou ln_cd4 measurement age sex, id(patient_id) time(measurement) re(measurement) svdata}

{phang}
Random intercept and random slope IOU model, with estimation performed using 10 FS iterations followed by 100 NR iterations{p_end}
{space 10}{cmd:. xtmixediou ln_cd4 measurement age sex, id(patient_id) time(measurement) re(measurement) algorithm(fs 10 nr 100)}

{synoptline}

{title:Stored results}

{phang}
{cmd:xtmixediou} stores the following in {cmd:e():}

{synoptset 20 tabbed}{...}
    Scalars 
{synopt :{cmd:e(N)}}number of observations{p_end}
{synopt :{cmd:e(k)}}number of parameters{p_end}
{synopt :{cmd:e(k_f)}}number of fixed effects parameters{p_end}
{synopt :{cmd:e(k_r)}}number of random effects parameters{p_end}
{synopt :{cmd:e(k_res)}}number of residual-error parameters{p_end}
{synopt :{cmd:e(ll_reml)}} restricted log-likelihood{p_end}
{synopt :{cmd:e(converged)}}1 if converged, 0 otherwise{p_end}

    Macros   
{synopt :{cmd:e(cmd)}}xtmixediou{p_end}
{synopt :{cmd:e(cmdline)}}command as typed{p_end}
{synopt :{cmd:e(title)}}title in estimation output{p_end}
{synopt :{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt :{cmd:e(id)}}name of variable identifying level-2 units{p_end}
{synopt :{cmd:e(time)}}name of timepoint variable for {it:depvar}, i.e. {it:timevar}{p_end}
{synopt :{cmd:e(revars)}}names of random effects variables{p_end}
{synopt :{cmd:e(redim)}}random effects dimension{p_end}
{synopt :{cmd:e(iou)}}iou() specification{p_end}
{synopt :{cmd:e(method)}}REML{p_end}
{synopt :{cmd:e(ml_method)}}type of ml method{p_end}
{synopt :{cmd:e(opt)}}type of optimization{p_end}
{synopt :{cmd:e(predict)}}command used to implement predict{p_end}
{synopt :{cmd:e(properties)}}b V{p_end}

    Matrices 
{synopt :{cmd:e(b)}}coefficient vector{p_end}
{synopt :{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt :{cmd:e(sv)}}starting values of the variance parameters{p_end}
{synopt :{cmd:e(N_g)}}group counts{p_end}
{synopt :{cmd:e(g_min)}}group-size minimum{p_end}
{synopt :{cmd:e(g_avg)}}group-size average{p_end}
{synopt :{cmd:e(g_max)}}group-size maximum{p_end}

   Functions 
{synopt :{cmd:e(sample)}}marks estimation sample{p_end}

{title:References}

    Taylor, J. M. G., Cumberland, W. G and Sy, J. P. 1994.  A Stochastic Model for Analysis of Longitudinal AIDS Data.  Journal of the American Statistical Association 89: 727-736.

    Taylor, J. M. G. and Law, N. 1998.  Does the covariance structure matter in longitudinal modelling for the prediction of future CD4 counts? Statistics in Medicine 17: 2381-2394.
	
