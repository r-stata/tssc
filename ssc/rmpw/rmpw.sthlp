{smcl}
{* *! 1.0.0 JDeutsch/MJacobus/AVigil 06feb2017}{...}
{viewerjumpto "Syntax" "rmpw##syntax"}{...}
{viewerjumpto "Description" "rmpw##description"}{...}
{viewerjumpto "Options" "rmpw##options"}{...}
{viewerjumpto "Remarks" "rmpw##remarks"}{...}
{viewerjumpto "Examples" "rmpw##examples"}{...}
{viewerjumpto "Stored Results" "rmpw##results"}{...}
{viewerjumpto "Citation" "rmpw##citing"}{...}
{viewerjumpto "Acknowledgements" "rmpw##acknowledge"}{...}
{viewerjumpto "Disclaimer" "rmpw##disclaimer"}{...}
{viewerjumpto "Background Reading" "rmpw##background"}{...}
{viewerjumpto "Author" "rmpw##author"}{...}
{title:Title}

{phang}
{bf:rmpw} {hline 2} Implement the RMPW method of causal mediation analysis to decompose treatment effects into "direct" and "indirect" effects.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:rmpw}
{cmd:(}{it:{help varname:ovar}}
{cmd:[}{it:{help varname:covarsout}}{cmd:])}
{cmd:(}{it:{help varname:tvar}}{cmd:)}
{cmd:(}{it:{help varname:mvar}}
{it:{help varname:covarsprop}}{cmd:)}
{ifin}
[{it:{help rmpw##weight:weight}}]
[, {it: options}]

{phang}
{it:ovar} is the outcome variable of interest.

{phang}
{it:covarsout} is the ({it:optional}) covariate list for the outcome model.

{phang}
{it:tvar} is a binary variable (only 0, 1, or missing) that represents the treatment (1) and control (0) groups.

{phang}
{it:mvar} is a binary variable representing the mediator.

{phang}
{it:covarsprop} is the covariate list for the propensity score model. Users are required to specify at least one (numeric) variable.

{synoptset 34 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth ps:model(strings:string)}}Type of estimation for propensity score model (logit or probit; logit is default){p_end}
{synopt :{opt winit:ial}{cmd:(}{it:iwtype}[{cmd:, }{opt indep:endent}]{cmd:)}}Specify initial weight matrix ({cmd:winitial(unadjusted, independent)} is default){p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt quickd:erivatives}}Use alternative method of computing numerical derivatives for VCE{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:covarsout} and {it:covarsprop} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{cmd:aweight}s and {cmd:pweight}s are allowed; see {help weight}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
This module implements the ratio-of-mediator-probability weighting (RMPW) method for causal mediation analysis to decompose
the treatment effect into "direct" and "indirect" effects. The indirect effect operates through a "mediator," which is a variable
that is affected by the treatment and in turn also has an effect on the outcome. The direct effect operates directly from the
treatment to the outcome, or operates through other unmeasured mediators.{p_end}

{pstd}
RMPW is an approach for mediation analysis introduced by Hong (2010) and further developed by Hong and Nomi (2012) Tchetgen Tchetgen
and Shipster (2012), Hong (2015) Hong, Deutsch, and Hill (2015), and Bein et al. (2016). Huber (2014) and
Tchetgen Tchetgen (2013) proposed related strategies employing weights that are mathematically equivalent to RMPW. RMPW departs from
the SEM approach of mediation analysis of Baron and Kenny (1986) in that it does not involve modeling the outcome as a function
of the treatment and mediator, and thus avoids the assumptions necessary for identification of such models. It also allows for
treatment-by-mediator interaction effects.{p_end}

{pstd}
The RMPW methodology is constructed for cases where {bf:treatment is randomized}.
In its current incarnation, it is also designed for scenarios where {bf:treatment is binary AND the mediator is binary}. Finally, causal
mediation analysis presumes that the treatment has an effect on the mediator; this module conducts a basic test of whether this condition
is met and issues a warning if it is not. However, it may be appropriate for the user to implement their own test of this conditon.{p_end}

{pstd}
{bf:Direct and indirect effects from a potential outcomes framework}.
Rather than the familiar formulation of potential outcomes that depend on (binary) treatment, Y(1) and Y(0), we can instead denote the potential
outcomes as a function of both the treatment and the mediator, which is in turn a function of the treatment:{p_end}

{pmore2}Y(1,M(1)) and Y(0,M(0)){p_end}

{pmore}
Note that these are the same two familiar potential outcomes, but written using different notation that will become useful.
Y(1,M(1)) is no different from the usual Y(1): the outcome if assigned to treatment. Likewise, Y(0,M(0)) is the same as Y(0).{p_end}

{pstd}
We can imagine a third potential outcome: the outcome if assigned to the treatment group but counterfactually possessing the mediator
value that one would have under the control condition:{p_end}

{pmore2}Y(1,M(0)){p_end}

{pstd}
The {bf:direct effect} is the effect of changing the treatment but leaving the mediator the same as what it would have been under the control condition:{p_end}

{pmore2}Y(1,M(0))-Y(0,M(0)){p_end}

{pstd}
Whereas the {bf:indirect effect} operates only through the treatment-induced change in the mediator:{p_end}

{pmore2}Y(1,M(1))-Y(1,M(0)){p_end}

{pstd}
The {bf:total effect} can be decomposed as the sum of the direct and indirect effects:{p_end}

{pmore2}Y(1,M(1))-Y(0,M(0))=[Y(1,M(1))-Y(1,M(0))]+[Y(1,M(0))-Y(0,M(0))]{p_end}

{pstd}
With random assignment of treatment, it is trivial to identify E[Y(1,M(1))] and E[Y(0,M(0))]. These are simply the treatment and control group means.
Additional assumptions and analytical methods are required to identify and estimate E[Y(1,M(0))].{p_end}

{pstd}
The entire methodological challenge reduces to estimating E[Y(1,M(0))]. With the sequential ignorability assumption along with assumptions
that are trivially satisfied so long as treatment is randomized, we can show that:{p_end}

{pmore2}E[WY|T=1] is an unbiased estimate of E[Y(1,M(0))] where:{p_end}
{pmore3}W=pr(M=1|T=0,X)/pr(M=1|T=1,X)  if T=1 and M=1;{p_end}
{pmore3}W=pr(M=0|T=0,X)/pr(M=0|T=1,X)  if T=1 and M=0{p_end}

{pstd}
Note that pr(M=m|T=t,X) is a propensity score (or 1 minus a propensity score, in the case of pr(M=0|T=t,X)).
For example, the numerator of the first equation is the predicted probability from a propensity score model
where the outcome is the mediator (M), and predictors are covariates (X), and the model is fit using only the treatment group.{p_end}

{pstd}
As an extension, the pure indirect effect can also be decomposed into the {bf:"pure" indirect effect}:{p_end}

{pmore2}Y(0,M(1))-Y(0,M(0)){p_end}

{pstd}
And the {bf:treatment-by-mediator interaction effect}:{p_end}

{pmore2}[Y(1,M(1))-Y(1,M(0))] - [Y(0,M(1))-Y(0,M(0))]={p_end}
{pmore2}{space 1}Y(1,M(1))+Y(0,M(0))-Y(1,M(0))-Y(0,M(1)){p_end}

{pstd}
Notice that the sum of the {bf:"pure" indirect effect} and the {bf:treatment-by-mediator interaction effect} is equal to the {bf:indirect effect}.{p_end}

{pstd}
Since the direct and indirect effects are functions of weights which are themselves functions of estimated propensity scores, standard error
estimation requires accounting for the uncertainty in the estimation of the coefficients from the propensity score models. RMPW accomplishes
this by using generalized method of moments (Hansen, 1982), via the {help gmm} command. In this way it is analogous to the {help teffects ipw} command.

{pstd}
The outcome variable may be continuous or binary. If no independent variables are specified for the outcome model, the method resolves to estimating weighted
means and differences between those means. If independent variables are specified for the outcome model, they are assumed to be linearly related to the outcome.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt ps:model(string)} sets the type of estimation for the propensity score model. Users can choose either {cmd:logit} or {cmd:probit}. The default is {cmd:logit} if
this option is not specified.

{phang}
{opt winit:ial}{cmd:(}{it:iwtype}[{cmd:, }{opt indep:endent}]{cmd:)} specifies an initial weight matrix; {it:iwtype} may be {opt un:adjusted}, {opt i:dentity},
{cmd:xt} {help gmm##xtspec:{it:xtspec}}, or the name of a Stata matrix. If users do not specify this option, the default is {cmd:winitial(unadjusted, independent)}.
See {help gmm} for more information on this option.

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which
includes types that are robust to some kinds of misspecification ({cmd:robust}; the default), that allow
for intragroup correlation ({cmd:cluster} {it:clustvar}), and that use
bootstrap or jackknife methods ({cmd:bootstrap}, {cmd:jackknife}); see
{helpb vce_option:[R] {it:vce_option}}.

{phang}
{opt quickd:erivatives} requests that an alternative method be used to compute
the numerical derivatives for the VCE. See {help gmm} for more information on this option.


{marker remarks}{...}
{title:Remarks}

{pstd}
Note that this command uses generalized method of moments estimation via the {cmd:gmm} command to estimate the standard error of the direct/indirect effects.
See {help gmm} for more information on this type of estimation in Stata.{p_end}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. rmpw (y) (treat) (med x1-x3)}{p_end}
{phang}{cmd:. rmpw (y x1-x3) (treat) (med x1-x3)}{p_end}
{phang}{cmd:. rmpw (y x1-x3) (treat) (med x1-x3), psmodel(probit)}{p_end}
{phang}{cmd:. rmpw (y) (treat) (med x*), vce(cluster cid)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:rmpw} retains all {cmd:gmm} stored results and adds the following results to {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(itt_b)}}Intent-to-treat (ITT) effect, estimate{p_end}
{synopt:{cmd:e(itt_se)}}Intent-to-treat (ITT) effect, standard error{p_end}
{synopt:{cmd:e(de_b)}}Direct effect, estimate{p_end}
{synopt:{cmd:e(de_se)}}Direct effect, standard error{p_end}
{synopt:{cmd:e(ie_b)}}Indirect effect, estimate{p_end}
{synopt:{cmd:e(ie_se)}}Indirect effect, standard error{p_end}
{synopt:{cmd:e(pie_b)}}Pure indirect effect, estimate{p_end}
{synopt:{cmd:e(pie_se)}}Pure indirect effect, standard error{p_end}
{synopt:{cmd:e(txm_b)}}Treatment-by-mediator interaction effect, estimate{p_end}
{synopt:{cmd:e(txm_se)}}Treatment-by-mediator interaction effect, standard error{p_end}


{marker citing}{...}
{title:Citation}

{pstd}
Please cite this module as follows:{p_end}

{pmore}
Mathematica Policy Research, Inc. under subcontract to MDRC and project sponsored by Grant #201500035 from the Spencer Foundation,
"RMPW: Stata module for causal mediation analysis using ratio-of-mediator-probability weights."
This version INSERT_VERSION_HERE.{p_end}

{pstd}
Note that you can check your version using {cmd:which}:{p_end}

{pmore}
{inp: . which rmpw}{p_end}


{marker acknowledge}{...}
{title:Acknowledgements}

{pstd}
This program was supported by a subcontract to MDRC under Grant #201500035 from the Spencer Foundation entitled
"Using emerging methods with existing data from multi-site trials to learn about and from variation in education program effects."{p_end}


{marker disclaimer}{...}
{title:Disclaimer}

{pstd}
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE
OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

{pstd}
IN NO EVENT WILL THE COPYRIGHT HOLDERS, THEIR AGENTS, SUBCONTRACTORS OR EMPLOYEES, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE
THIS SOFTWARE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE
OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU
OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF
THE POSSIBILITY OF SUCH DAMAGES.


{marker background}{...}
{title:Background Reading}

{pstd}
Baron, R. M., & Kenny, D. A. (1986). "The moderator-mediator variable distinction in social psychological research: Conceptual, strategic, and statistical
considerations." {it:Journal of Personality and Social Psychology}, 51, 1173-1182.

{pstd}
Bein, E., Deutsch, J., Hong, G., Porter, K., Qin, X., and Yang, C. (2016). "Technical report on two-step estimation in RMPW analysis." Oakland, CA: MDRC.

{pstd}
Hansen, L. P. (1982). "Large sample properties of generalized method of moments estimators." {it:Econometrica}, 1029-1054.

{pstd}
Hong, G. (2010). "Ratio of mediator probability weighting for estimating natural direct and indirect effects." {it:JSM Proceedings}, Biometrics Section.
Alexandria, VA: American Statistical Association, pp. 2401-2415.

{pstd}
Hong, G., Deutsch, J., and Hill, H. D. (2015). "Ratio-of-mediator-probability weighting for causal mediation analysis in the presence of treatment-by-mediator
interaction." {it:Journal of Educational and Behavioral Statistics}, 40(3), 307-340.

{pstd}
Hong, G., and Nomi, T. (2012). "Weighting methods for assessing policy effects mediated by peer change." {it:Journal of Research on Educational Effectiveness},
5(3), 261-289.

{pstd}
Hong, G. (2015). {it:Causality in a social world: Moderation, mediation and spill-over.} West Sussex, UK: John Wiley & Sons, Ltd.

{pstd}
Huber, M. (2014). "Identifying causal mechanisms (primarily) based on inverse probability weighting." {it:Journal of Applied Econometrics}, 29(6), 920-943.

{pstd}
Tchetgen Tchetgen, E. J. (2013). "Inverse odds ratio weighted estimation for causal mediation analysis." {it:Statistics in Medicine}, 32, 4567-4580.

{pstd}
Tchetgen Tchetgen, E. J., & Shpitser, I. (2012). "Semiparametric theory for causal mediation analysis: Efficiency bounds, multiple robustness and
sensitivity analysis." {it:The Annals of Statistics}, 40, 1816-1845.


{marker author}{...}
{title:Author}

{pstd}Jonah Deutsch{p_end}
{pstd}Mathematica Policy Research, Inc.{p_end}
{pstd}JDeutsch@mathematica-mpr.com{p_end}

{pstd}Matthew Jacobus (corresponding author){p_end}
{pstd}Mathematica Policy Research, Inc.{p_end}
{pstd}MJacobus@mathematica-mpr.com{p_end}

{pstd}Alma Vigil{p_end}
{pstd}Mathematica Policy Research, Inc.{p_end}
{pstd}AVigil@mathematica-mpr.com{p_end}
