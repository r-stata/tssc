{smcl}
{* *! version 1.1.2 25oct2017}{...}
{cmd:help npiv}{right: ({browse "http://www.stata-journal.com/article.html?article=st0547":SJ18-4: st0547})}
{hline}

{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{bf:npiv} {hline 2}}Nonparametric instrumental-variable regression of
a scalar outcome on a scalar endogenous regressor and a vector of exogenous 
covariates with an instrument{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}
Nonparametric instrumental-variable (NPIV) regression with a B-spline basis

{p 8 12 2}{cmd:npiv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {it:options}]


{phang}
NPIV regression with a power polynomial basis

{p 8 12 2}{cmd:npiv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {opt poly:nomial} {it:options}]


{phang}
NPIV regression with an increasing shape restriction

{p 8 12 2}{cmd:npiv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:, {opt inc:reasing}} {it:options}]


{phang}
NPIV regression with a decreasing shape restriction

{p 8 12 2}{cmd:npiv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {opt dec:reasing} {it:options}]


{marker ncoptions}{...}
{synoptset 20}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt power_exp(integer)}}degree of the power of the basis 
function for the endogenous regressor; default is {cmd:power_exp(2)}{p_end}
{synopt :{opt power_inst(integer)}}degree of the power of the basis 
function for the instrument; default is {cmd:power_inst(3)}{p_end}
{synopt :{opt num_exp(integer)}}number of knots for the basis of 
the endogenous regressor; default is {cmd:num_exp(2)}{p_end}
{synopt :{opt num_inst(integer)}}number of knots for the basis of 
the instrument; default is {cmd:num_inst(3)}{p_end}
{synopt :{opt pctile(integer)}}domain over which the nonparametric 
sieve estimator is evaluated; default is {cmd:pctile(5)}{p_end}
{synopt :{opt polynomial}}specify the type of both bases p(x) and q(w) to be power polynomials{p_end}
{synopt :{opt increasing}}impose that the NPIV estimator is an increasing function of the endogenous regressor{p_end}
{synopt :{opt decreasing}}impose that the NPIV estimator is a decreasing function of the endogenous regressor{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:expvar} is an endogenous regressor, {it:inst} an instrument, and {it:exovar} a list of exogenous covariates.{p_end}
{p 4 6 2}
{it:exovar} may contain factor variables; see {help fvvarlist}.{p_end}


{title:Description}

{pstd}
{cmd:npiv} provides NPIV models with or without imposing monotonicity
restrictions on the function of interest.  Suppose Y is an outcome, X an
endogenous regressor, Z a list of exogenous covariates, and W an instrument.
Given a model equation, Y = g(X) + Z'γ+ e, and the assumption, E(e | W, Z) =
0, {cmd:npiv} gives estimators for g(X) and γ.  Under the default setup,
{cmd:npiv} runs series instrumental-variable regression on a B-spline basis
with no shape restriction.

{pstd}
{cmd:npiv} requires that community-contributed commands {cmd:bspline} and
{cmd:polyspline} be installed from Statistical Software Components.

{pstd}
{cmd:npiv} with {cmd:polynomial} uses a power polynomial basis instead of a
B-spline basis.  Options {cmd:num_exp()} and {cmd:num_inst()} are unnecessary
and are ignored if they are specified by the user.

{pstd}
{cmd:npiv} with {cmd:increasing} (or {cmd:decreasing}) imposes an increasing
(or decreasing) shape restriction on the nonparametric function g(X).  A
monotone shape restriction may significantly improve the performance of the
NPIV estimator (Chetverikov and Wilhelm 2017).

{pstd}
{cmd:npiv} stores the fitted values of g(X) in the variable {cmd:npest}.  Other
results are stored in {cmd:e()}.


{title:Options}

{phang}
{opt power_exp(integer)} specifies a positive integer for the degree of the
spline basis for the endogenous regressor.  The default is {cmd:power_exp(2)}.

{phang}
{opt power_inst(integer)} specifies a positive integer for the degree of the
spline basis for the instrument.  {opt power_inst()} must be equal to or
larger than {opt power_exp()}.  The default is {cmd:power_inst(3)}.

{phang}
{opt num_exp(integer)} specifies a positive integer greater than 1 for the
number of knots of the spline basis for the endogenous regressor.
{cmd:num_exp()} must be no less than {opt power_exp()}.  The default is
{cmd:num_exp(2)}.  The user need not specify this option if {cmd:polynomial} is used.

{phang}
{opt num_inst(integer)} specifies a positive integer greater than 1 for the
number of knots of the spline basis for the instrument.  {opt num_inst()} must be no less than {opt num_exp()}.  The default is {cmd:num_inst(3)}.  The
user need not specify this option if {cmd:polynomial} is used.

{phang}
{opt pctile(integer)} specifies the domain of the endogenous regressor over
which the NPIV estimator of g is to be computed.  {opt pctile(integer)} must be a positive integer smaller than 50.  For a given value of k, the NPIV
estimator is computed at fine grid points within the kth and the (100-k)th
percentiles of the empirical distribution of X.  The default is
{cmd:pctile(5)}.

{phang}
{cmd:polynomial} specifies the type of both bases p(x) and q(w) to be power
polynomials.  Choices of numbers of knots are ignored under this option.
Shape restrictions cannot be imposed for this basis, and an error message is
generated if this option is used together with {cmd:decreasing} or
{cmd:increasing}.

{phang}
{cmd:increasing} imposes that the NPIV estimator is an increasing function of
the endogenous regressor.  If this option is specified, the basis p(x) is
forced to be quadratic B-spline, and the option {opt power_exp(integer)} is not
used.  An error occurs when this option is used together with one of the
options {cmd:decreasing} or {cmd:polynomial}.  The basis q(w) for the
instrument is also restricted to be a B-spline, but the power and number of
knots can be freely chosen through {opt power_inst(integer)} and
{cmd:num_inst(integer)}.

{phang}
{cmd:decreasing} imposes that the NPIV estimator is a decreasing function of
the endogenous regressor.  The same restrictions as for {cmd:increasing} apply
to this option.


{title:Examples}

{pstd}
Setup - Y = {cmd:price}, X = {cmd:mpg}, W = {cmd:trunk}, Z = {cmd:weight}{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
NPIV regression under a default setting{p_end}
{phang2}{cmd:. npiv price mpg trunk}{p_end}

{pstd}
NPIV regression with a cubic B-spline (four knots) for {cmd:mpg} and a quintic
B-spline (five knots) for {cmd:trunk}{p_end}
{phang2}{cmd:. npiv price mpg trunk, power_exp(3) power_inst(5) num_exp(4) num_inst(5)}{p_end}

{pstd}
NPIV regression with a polynomial basis{p_end}
{phang2}{cmd:. npiv price mpg trunk, polynomial}{p_end}

{pstd}
NPIV regression with a cubic polynomial for {cmd:mpg} and a quintic polynomial
for {cmd:trunk}{p_end}
{phang2}{cmd:. npiv price mpg trunk, power_exp(3) power_inst(5) polynomial}{p_end}

{pstd}
NPIV regression imposing increasing shape with a cubic B-spline (four knots)
for {cmd:mpg} and a quintic B-spline (five knots) for {cmd:trunk}{p_end}
{phang2}{cmd:. npiv price mpg trunk, power_exp(3) power_inst(5) num_exp(4) num_inst(5) increasing}{p_end}

{pstd}
Default setup regression without Z and plot the fitted value with data{p_end}
{phang2}{cmd:. npiv price mpg trunk}{p_end}
{phang2}{cmd:. scatter price mpg || line npest grid}{p_end}


{title:Stored results}

{pstd}
{cmd:npiv} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(powerexp)}}power of basis for endogenous regressor{p_end}
{synopt:{cmd:e(powerinst)}}power of basis for instrument{p_end}
{synopt:{cmd:e(numexp)}}number of knots of basis for endogenous regressor{p_end}
{synopt:{cmd:e(numinst)}}number of knots of basis for instrument{p_end}
{synopt:{cmd:e(pct)}}value specified by {cmd:pctile()} option{p_end}
{synopt:{cmd:e(xmin)}}minimum of endogenous regressor{p_end}
{synopt:{cmd:e(xmax)}}maximum of endogenous regressor{p_end}
{synopt:{cmd:e(wmin)}}minimum of instrument{p_end}
{synopt:{cmd:e(wmax)}}maximum of instrument{p_end}
{synopt:{cmd:e(gmin)}}minimum of grid on which g is evaluated{p_end}
{synopt:{cmd:e(gmax)}}maximum of grid on which g is evaluated{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:npiv}{p_end}
{synopt:{cmd:e(depvar)}}name of outcome{p_end}
{synopt:{cmd:e(expvar)}}name of endogenous regressor{p_end}
{synopt:{cmd:e(inst)}}name of instrument{p_end}
{synopt:{cmd:e(exovar)}}list of exogenous covariates{p_end}
{synopt:{cmd:e(basis)}}type of spline basis{p_end}
{synopt:{cmd:e(title)}}NPIV regression{p_end}
{synopt:{cmd:e(shape)}}type of imposed shape restriction{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}


{title:Remarks}

{pstd}
This is a first and preliminary version.  Please feel free to share your
comments, reports of bugs, and propositions for extensions.

{pstd}
If you use this command in your work, please cite Chetverikov and Wilhelm
(2017) and Chetverikov, Kim, and Wilhelm (2018).


{title:References}

{phang}
Chetverikov, D., D. Kim, and D. Wilhelm. 2018.
{browse "http://www.stata-journal.com/article.html?article=st0547":Nonparametric instrumental-variable estimation}.
{it:Stata Journal} 18: 937-950.

{phang}
Chetverikov, D., and D. Wilhelm. 2017. Nonparametric instrumental variable
estimation under monotonicity. {it:Econometrica} 85: 1303-1320.


{title:Authors}

{pstd}
Denis Chetverikov{break}
Department of Economics{break}
University of California, Los Angeles{break}
Los Angeles, CA{break}
chetverikov@econ.ucla.edu

{pstd}
Dongwoo Kim{break}
Department of Economics{break}
University College London{break}
London, UK{break}
dongwoo.kim.13@ucl.ac.uk

{pstd}
Daniel Wilhelm{break}
Department of Economics{break}
University College London{break}
London, UK{break}
d.wilhelm@ucl.ac.uk


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 4: {browse "http://www.stata-journal.com/article.html?article=st0547":st0547}{p_end}
