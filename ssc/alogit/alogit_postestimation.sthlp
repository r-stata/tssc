{smcl}
{* *! version 1.1.0 31May2017}{...}
{viewerdialog predict "dialog alogit_p"}{...}
{vieweralsosee "[R] alogit postestimation" "mansection R alogitpostestimation"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] alogit" "help alogit"}{...}
{viewerjumpto "Description" "alogit postestimation##description"}{...}
{viewerjumpto "Syntax for predict" "alogit postestimation##syntax_predict"}{...}
{viewerjumpto "Menu for predict" "alogit postestimation##menu_predict"}{...}
{viewerjumpto "Options for predict" "alogit postestimation##options_predict"}{...}
{viewerjumpto "Examples" "alogit postestimation##examples"}{...}
{viewerjumpto "Warning" "alogit postestimation##warning"}{...}
{title:Title}

{p2colset 5 34 36 2}{...}
{p2col :{manlink R alogit postestimation} {hline 2}}Postestimation tools for
alogit{p_end}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
The following standard postestimation commands are available after {cmd:alogit}:

{synoptset 17 notes}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
INCLUDE help post_contrast
INCLUDE help post_estatic
INCLUDE help post_estatsum
INCLUDE help post_estatvce
INCLUDE help post_svy_estat
INCLUDE help post_estimates
INCLUDE help post_hausman
INCLUDE help post_lincom
INCLUDE help post_linktest
INCLUDE help post_lrtest_star
INCLUDE help post_margins2
INCLUDE help post_marginsplot
INCLUDE help post_nlcom
{synopt :{helpb alogit postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
INCLUDE help post_pwcompare
INCLUDE help post_suest
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}
INCLUDE help post_lrtest_star_msg
{phang}(2) The prediction statistics {cmd:py pyc pa a u} cannot be correctly
handled by {cmd:margins}; however, {cmd:margins} can be used after {cmd:alogit}
with {cmd:predict(xb)}.

{marker syntax_predict}{...}
{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict}
{dtype}
{newvar}
{ifin}
[{cmd:,} {it:statistic} {opt nooff:set}]

{synoptset 17 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{syntab :Main}
{synopt :{opt py}}unconditional probability of choosing each option{p_end}
{synopt :{opt pyc}}probability of choosing each option given all are considered{p_end}
{synopt :{opt pa}}probability of paying attention to each good{p_end}
{synopt :{opt a}}fitted latent attention variable{p_end}
{synopt :{opt u}}fitted utility level{p_end}
{synopt :{opt p0}}P(empty choice set) for each individual{p_end}
{synopt :{opt mp0}}Average P(empty choice set) (for DSC, average P(inattention)){p_end}
{synopt :{opt mp1}}Average P(Attention) (DSC only){p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt stdp}}standard error of the linear prediction{p_end}
{synopt :{opt dydx(varname, [elasticity])}} dP(Y) / dx or d log(P(Y)) / d log x {p_end}
{synopt :{opt fit([b0(numlist) g0(numlist) last])}}fit at custom parameter set {p_end}
{synopt :{opt counterfactual([counterfactual_options])}} counterfactual P(Y); see {it:{help alogit_postestimation##counterfactual_options:counterfactual_options}}{p_end}
{synopt :{opt sorted}} notes the data is already sorted and no sorting is done.{p_end}

{synoptline}
{p2colreset}{...}

INCLUDE help menu_predict

{marker options_predict}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}
{opt py} unconditional probability of choosing each option

{phang}
{opt pyc} probability of choosing each option given all are considered;
that is, P(Y | c) where c is a J-dimensional vector of 1s.

{phang}
{opt pa} probability of paying attention to each good; that is, P(A | x, z)

{phang}
{opt u} fitted utility level (also {opt xb} using {opt eqation(#1)})

{phang}
{opt a} fitted latent attention variable (also {opt xb} using {opt eqation(#2)})

{phang}
{opt p0} fitted probability of paying attention to none of the goods

{phang}
{opt mp0} average probability of an empty set (for DSC, average probability of inattention) stored in scalar {it:newvar}

{phang}
{opt mp1} DSC only, average probability of attention stored in scalar {it:newvar}

{phang}
{opt xb} calculates the linear prediction.

{phang}
{opt stdp} calculates the standard error of the linear prediction.

{phang}
{opt dydx(varname, [elasticity])} {it:dP(Y) / dx} at x_ij, where
x is {it:varname}; if {it:elasticity} is specified then the
function outputs {it:d log(P(Y)) / d log(x)}. Note that if
{it:y = f(x)} then {it:log(y) = log(f(exp(log(x))))} so that the
elasticity is just {it:d log(y) / d log(x) = (dy / dx) (x / f(x))}

{phang}
{opt fit([b0(numlist) g0(numlist) last])} fit at custom parameter set. The
option tolerates fewer parameters than there are variables, and will
simply pad {opt b0} and {opt g0} with the fitted parameters until the we
have the correct number. The model will not accept more parameters than
variables, however. If {opt last} is specified, then the last parameters
are replaced as opposed to the first (i.e. pass -1 2- to vector -5 6 7-
with {opt last} gives -5 1 2- instead of -1 2 7-)

{marker counterfactual_options}{...}
{phang}
{opt counterfactual([u_ij(varname) phi_ij(varname) GRoup(varname) DEFault(varname) CONSider(varname) checksetup])}
fit P(Y) while specifying utility {it:u_ij} and attention probabilites
{it:phi_ij}. If {opt group(varname)} and one of {opt default(varname)} or {opt consider(varname)}
are not specified, {opt e(group)}, {opt e(default)}, or {opt e(consider)} are used.

{phang}
{opt sorted} Because the underlying computations are done in Mata
or C, the data must be sorted. Observations to be used (in case an
if-condition is passed) must appear first, and then be sorted by group.
(e.g. Suppose a variable {it:touse} contains 0, 1 indicators, then the
sorting must be {it:gsort -touse e(group)}; if {opt consider(varname)} is
passed instead of {opt default(varname)}, sorting must be {it:gsort -touse e(group) e(consider)}).
Sorting is expensive, and for large data even checking whether the data
is sorted can take a long time. Hence the user can pre-sort the data and
then pass this option for {opt predict} to skip sorting the data. It is
specially useful if several {opt predict} statements need to be used in
succession. However, if the data is not properly sorted then there will
be errors in the computation.

{synoptline}
{p2colreset}{...}

{marker warning}{...}
{title:Warning}

{pstd}
Though out-of-sample predictions are possible with {opt method(exact)},
{opt alogit} may yield off results if the chosen good, default good, or
considered good(s) are excluded.

{pstd}
Out of sample predictions are not possible with {opt method(importance)}.
This happens because {opt method(importance)} draws {opt reps} choice
sets for each group are simulated once at the starting parameters and
the same choice sets are used throughout the optimization; all the
output generated by {opt predict} uses the same choice sets.

{pstd}
Neither are a problem if {opt predict} uses the sample used by
{opt alogit} or a sub-sample thereof. However, if predict uses a
different subset or different data then the results will be incorrect.
Furthermore, it is not possible to make predictions for supersets of the
sample used by {opt alogit} (or larger samples) as it would require more
choice sets than were simulated.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. set seed 42}{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2)}{p_end}

{pstd}Fit (in)attentive logit regression{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) def(defgood) noc}{p_end}

{pstd}Basic post-estimation fits{p_end}
{phang2}{cmd:. predict py_exact,            py }{p_end}
{phang2}{cmd:. predict py_givenc_exact,     pyc}{p_end}
{phang2}{cmd:. predict pa_exact,            pa }{p_end}
{phang2}{cmd:. predict attn_latent_exact,   a  }{p_end}
{phang2}{cmd:. predict utility_exact,       u  }{p_end}
{phang2}{cmd:. predict pempty_exact,        p0 }{p_end}

{pstd}Derivatives and elasticities with respect to a variable{p_end}
{phang2}{cmd:. predict dydx1_exact,  dydx(x1)}{p_end}
{phang2}{cmd:. predict dydx2_exact,  dydx(x2)}{p_end}
{phang2}{cmd:. predict dydz1_exact,  dydx(z1)}{p_end}
{phang2}{cmd:. predict dydz2_exact,  dydx(z2)}{p_end}

{phang2}{cmd:. predict dlogy_dlogx1_exact,  dydx(x1, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogx2_exact,  dydx(x2, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogz1_exact,  dydx(z1, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogz2_exact,  dydx(z2, elasticity)}{p_end}

{pstd}Predict at arbitrary coefficient values{p_end}
{phang2}{cmd:. predict f_py_exact,          py  fit(b0(12 -2) g0(-3 4) d0(3 -4))                  }{p_end}
{phang2}{cmd:. predict f_py_givenc_exact,   pyc fit(b0(12 -2) g0(-3 4) d0(3 -4))                  }{p_end}
{phang2}{cmd:. predict f_pa_exact,          pa  fit(b0(12 -2) g0(-3 4) d0(3 -4))                  }{p_end}
{phang2}{cmd:. predict f_attn_latent_exact, a   fit(b0(-2) g0(-3) d0(-4))                         }{p_end}
{phang2}{cmd:. predict f_utility_exact,     u   fit(b0(-2) g0(-3) d0(-4))                         }{p_end}
{phang2}{cmd:. predict f_pempty_exact,      p0  fit(b0(-2) g0(-3) d0(-4))                         }{p_end}

{phang2}{cmd:. predict f_dydx1_exact,  dydx(x1) fit(b0(12 -2) g0(-3 4))                           }{p_end}
{phang2}{cmd:. predict f_dydx2_exact,  dydx(x2) fit(b0(12 -2) g0(-3 4))                           }{p_end}
{phang2}{cmd:. predict f_dydz1_exact,  dydx(z1) fit(b0(12 -2) g0(-3 4) d0(3 -4))                  }{p_end}
{phang2}{cmd:. predict f_dydz2_exact,  dydx(z2) fit(b0(12 -2) g0(-3 4) d0(3 -4))                  }{p_end}

{phang2}{cmd:. predict f_dlogy_dlogx1_exact, dydx(x1, elasticity) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dlogy_dlogx2_exact, dydx(x2, elasticity) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dlogy_dlogz1_exact, dydx(z1, elasticity) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_dlogy_dlogz2_exact, dydx(z2, elasticity) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}

{pstd}Counterfactuals (alternative utility, probability of attention){p_end}
{phang2}{cmd:. gen alt_u = runiform()}{p_end}
{phang2}{cmd:. gen alt_p = runiform()}{p_end}

{phang2}{cmd:. predict fit_u,  u }{p_end}
{phang2}{cmd:. predict fit_p,  pa}{p_end}
{phang2}{cmd:. predict fit_py, py}{p_end}

{phang2}{cmd:. predict counter_py_u, counterfactual(u_ij(alt_u) phi_ij(alt_p))}{p_end}
{phang2}{cmd:. predict counter_py_f, counterfactual(u_ij(fit_u) phi_ij(fit_p))}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. set seed 42}{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2) dsc}{p_end}

{pstd}Fit (in)attentive logit regression, DSC version{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) def(defgood) noc model(dsc)}{p_end}

{pstd}Basic post-estimation fits{p_end}
{phang2}{cmd:. predict py_exact,            py }{p_end}
{phang2}{cmd:. predict py_given_attention,  pyc}{p_end}
{phang2}{cmd:. predict pa_default,          pa }{p_end}
{phang2}{cmd:. predict attn_latent_default, a  }{p_end}
{phang2}{cmd:. predict utility_exact,       u  }{p_end}
{phang2}{cmd:. predict inattention_default, p0 }{p_end}

{pstd}Derivatives and elasticities with respect to a variable{p_end}
{phang2}{cmd:. predict dydx1_exact,  dydx(x1)}{p_end}
{phang2}{cmd:. predict dydx2_exact,  dydx(x2)}{p_end}
{phang2}{cmd:. predict dydz1_exact,  dydx(z1)}{p_end}
{phang2}{cmd:. predict dydz2_exact,  dydx(z2)}{p_end}

{phang2}{cmd:. predict dlogy_dlogx1_exact,  dydx(x1, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogx2_exact,  dydx(x2, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogz1_exact,  dydx(z1, elasticity)}{p_end}
{phang2}{cmd:. predict dlogy_dlogz2_exact,  dydx(z2, elasticity)}{p_end}

{pstd}Predict at arbitrary coefficient values{p_end}
{phang2}{cmd:. predict f_py_exact,            py  fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_py_given_attention,  pyc fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_pa_default,          pa  fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_attn_latent_default, a   fit(b0(-2) g0(-3) d0(-4))       }{p_end}
{phang2}{cmd:. predict f_utility_exact,       u   fit(b0(-2) g0(-3) d0(-4))       }{p_end}
{phang2}{cmd:. predict f_inattention_default, p0  fit(b0(-2) g0(-3) d0(-4))       }{p_end}

{phang2}{cmd:. predict f_dydx1_exact,  dydx(x1) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dydx2_exact,  dydx(x2) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dydz1_exact,  dydx(z1) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_dydz2_exact,  dydx(z2) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}

{phang2}{cmd:. predict f_dlogy_dlogx1_exact, dydx(x1, elasticity) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dlogy_dlogx2_exact, dydx(x2, elasticity) fit(b0(12 -2) g0(-3 4))         }{p_end}
{phang2}{cmd:. predict f_dlogy_dlogz1_exact, dydx(z1, elasticity) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}
{phang2}{cmd:. predict f_dlogy_dlogz2_exact, dydx(z2, elasticity) fit(b0(12 -2) g0(-3 4) d0(3 -4))}{p_end}

{pstd}Counterfactuals (alternative utility, probability of attention){p_end}
{phang2}{cmd:. gen alt_u = runiform()}{p_end}
{phang2}{cmd:. gen alt_p = runiform()}{p_end}

{phang2}{cmd:. predict fit_u,  u }{p_end}
{phang2}{cmd:. predict fit_p,  pa}{p_end}
{phang2}{cmd:. predict fit_py, py}{p_end}

{phang2}{cmd:. predict counter_py_u, counterfactual(u_ij(alt_u) phi_ij(alt_p))}{p_end}
{phang2}{cmd:. predict counter_py_f, counterfactual(u_ij(fit_u) phi_ij(fit_p))}{p_end}
