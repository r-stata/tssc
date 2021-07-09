{smcl}
{* *! 02Feb2013}{...}
{cmd:help mrprobit}
{hline}

{title:Title}


{title:Probit Estimators with Misclassification of the Dependent Variable}


{title:Syntax}

{p 8 17 2}
{cmdab:mrprobit}
{depvar}
[{indepvars}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt:{opt alpha0(string)}}Can be used to specify model for the probability of false positives{p_end}
{synopt:{opt alpha1(string)}}Can be used to specify model for the probability of false negatives{p_end}
{synopt:{opt c0}}Forces {cmd:mrprobit} to interpret variable in {opt alpha0()} as defining cells if {opt alpha0()} contains one variable.{p_end}
{synopt:{opt c1}}Forces {cmd:mrprobit} to interpret variable in {opt alpha1()} as defining cells if {opt alpha1()} contains one variable.{p_end}
{synopt:{opt p:redict}}Returns results in e() such that some of the Probit postestimation programs work.{p_end}
{syntab:Maximization}
{synopt:{opt modelo:pts(string)}}options passed to {cmd: ml model}{p_end}
{synopt:{opt max:opts(string)}}options passed to {cmd: ml maximize}{p_end}
{synopt:{opt i:nit(string)}}starting values passed to {cmd: ml init}{p_end}

{synoptline}
{p2colreset}{...}
{pstd}
{hi:pweight}s, {hi:fweight}s, {hi:aweight}s and {hi:iweight}s are allowed; see {help weight}.{p_end}

{title:Description}

{pstd}
{cmd:mrprobit} estimates the probit model proposed in Hausman et al (1998) that is consistent in the presence of misreporting of the dependent variable as well as some extensions. The probability of 
misreporting can be allowed to differ by cells defined by observables, be a known constant or an estimate for each observation can be provided.{p_end}

{title:Options}

{dlgtab:Model}

{phang}
{opt alpha0(string)} can be used to specify the model for the probability of false positives. If it is not specified, {cmd:mrprobit} estimates the probit model proposed in Hausman et al (1998), which assumes
that the probability of false positives (Pr(y=1|y*=0)) is a constant and estimates it from the data. If {opt alpha0(string)} contains a real number, it constrains the probability to this number (for technical
reasons, {cmd:mrprobit} will constrain the probability to a value arbitrarily close to 0 if 0 is specified). {opt alpha0(string)} can also contain a (list of) categorical variables, inducing {cmd:mrprobit} to 
estimate separate probabilities of false positives for each cell defined by unique combinations of the {it:varlist}. The table of results lists the unique combinations of the lables (as created by egen group with
the option lable) of the variables in {opt alpha0()} to identify the cells. 
Finally, it can contain a variable that gives (estimated) probabilities of false positives for every observation, allowing the probability of false positves to depend on {indepvars} in arbitrary ways. The standard
errors assume that the probabilities are known, i.e. they do not take the uncertainty that arises from estimating these probabilities into account. If only one variable is specified, {cmd:mrprobit} tries to 
determine automatically whether it defines cells or contains a probability. See {opt c0} on how to override this.

{phang}
{opt alpha1(string)} can be used to specify the model for the probability of false negatives. Works exactly the same way as {opt alpha0(string)}, i.e. it can contain a number, a varlist specifying groups by which 
the probability of false negatives is allowed to differ or a probability of false negative for each observation.

{phang}
{opt c0} forces {cmd:mrprobit} to interpret the variable specified in {opt alpha0(string)} as defining groups of observations rather than probabilities. Can be used in case the program fails to figure that out
by itself.

{phang}
{opt c1} forces {cmd:mrprobit} to interpret the variable specified in {opt alpha1(string)} as defining groups of observations rather than probabilities. Can be used in case the program fails to figure that out
by itself.

{phang}
{opt p:redict} The regular {cmd:probit} postestimation commands (such as {cmd:predict} or {cmd:margins}) do not work unless some results are returned in e(). {opt p:redict} forces the program to return 
{hi:e(}predict{hi:)} and {hi:e(}rules{hi:)} such that some of these postestimation commands work. Use at your own risk, it just makes the commands work, they may not work correctly and do not work under all 
circumstances.

{dlgtab:Maximization}

{phang}
{opt modelo:pts(string)} can be used to pass any other options to {cmd: ml model}. Options should be entered just as they would be entered after the comma in the {cmd: ml model} statement.

{phang}
{opt max:opts(string)} can be used to pass any other options to {cmd: ml maximize}. Options should be entered just as they would be entered after the comma in the {cmd: ml maximize} statement.

{phang}
{opt i:nit(string)} can be used to pass starting values to {cmd: ml} using {cmd: ml init}. Options should be entered as they would be entered after the comma in the {cmd: ml init} statement. Specifying starting 
values for {it:any} parameter switches off the default starting values for all other parameters as well. See {help mrprobit##start:Starting Values} for more details.


{title:Remarks}
{marker remarks}
{pstd}
{hi:Starting Values and Convergence}{break}
{marker start}
{cmd:mrprobit} choses starting values for the slope coefficients by running a standard probit and lets Stata choose starting values for the alphas. This tends to lead to quick and reliable convergence. However,
problems sometimes occured with probabilities of misreporting for different groups if the probability for one or more groups is 0, since this puts the maximum of the likelihood function on the boundary of the 
parameter space. Stata sometimes settles on a local minimum if alpha() contains the probabilities of misreporting, so it seems desirable to check the robustness of the maximum by specifying starting values 
manually using {opt i:nit()}. Note that if {opt i:nit()} is specified, {cmd:mrprobit} does not choose any starting values, but lets Stata choose starting values for any parameter without a starting value in 
{opt i:nit()}.
Finally, as Hausman et al (1998) show, the model is only identified if alpha0+alpha1<1, since the likelihood function has a symetric maximum at (1-alpha0,1-alpha1,-b). In rare cases, the maximization may end
up at this maximum, which can be avoided by choosing appropriate starting values.

{pstd}
{hi:svy, Standard Errors}{break}
{cmd:mrprobit} should work with the {hi:svy} prefix, but I haven't checked whether all details are correct. If you find any errors, please let me know. The standard errors for the alphas are linearized by the
delta method. Clustering and any other variance option Stata is capable of can be used by passing the option to ml using {opt modelo:pts()} and {opt max:opts()}.

{pstd}
{hi:Version 10 and omitted variables}{break}
The program runs under version 10, but may not transform the alphas back to [0,1] properly if Stata drops any variables from the model. I would like to thank Fola Malomo for pointing out this problem, which I have partially fixed in this version: It should only occur under version 10 with long (>244 characters) varlists of independent variables (in which case it should display a warning). If you want to be on the safe side, exclude any variables from your estimation command that Stata will exclude from e(b). 

{pstd}
{hi:Other}{break}
If you find any mistakes or have any suggestions for improvements, please send me an email to {browse "mailto:mittag@uchicago.edu":mittag@uchicago.edu}. Feel free to use, change or mutilate this program for private purpose, but please don't steal it, give due credit.

{title:Examples}

    {hline}
    Setup
{phang2}{cmd:. webuse lbw2}{p_end}

{pstd}Probit regression with union subject to misreporting, estimating probabilities of misreporting from the data as in Hausman et al (1998){p_end}
{phang2}{cmd:. mrprobit low age lwt race2 race3 smoke ptl ht ui}{p_end}

{pstd}Same regression, but not allowing for false positives{p_end}
{phang2}{cmd:. mrprobit low age lwt race2 race3 smoke ptl ht ui, alpha0(0)}
{p_end}

{pstd}Same regression, but using external information to fix probabilities of misreporting rather than estimating them{p_end}
{phang2}{cmd:. mrprobit low age lwt race2 race3 smoke ptl ht ui, alpha0(0.03) alpha1(0.1)}
{p_end}

{pstd}Same regression, allowing alpha0 and alpha1 to be different for each combination of race and smoke{p_end}
{phang2}{cmd:. mrprobit low age lwt race2 race3 smoke ptl ht ui, alpha0(race smoke) alpha1(race smoke)}
{p_end}

{pstd}Using estimated probabilities (stored in variables pr_fp and pr_fn) for each observation{p_end}
{phang2}{cmd:. mrprobit low age lwt race2 race3 smoke ptl ht ui, alpha0(pr_fp) alpha1(pr_fn)}
{p_end}

{title:Saved results}

{pstd}
{cmd:mrprobit} saves the following in {cmd:e()} (additional macros may be returned depending on the options passed to {cmd:ml}):

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in model Wald test{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mrprobit}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared test{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V svyb svyr svyj}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(b_o)}}original coefficient vector before parameter transformations{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_o)}}original variance-covariance matrix of the estimators before parameter transformations{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}Hausman, Jerry,  Jason Abrevaya and F. M. Scott-Morton. 1998. Misclassification of the Dependent Variable in a Discrete-Response Setting. {it:Journal of Econometrics}, 87 (2): 239-69.{p_end}
{phang}Meyer, Bruce and Nikolas Mittag. 2013. Misclassification in Binary Choice Models. Unpublished Manuscript.{p_end}

