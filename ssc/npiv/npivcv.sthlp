{smcl}
{* *! version 1.1.2 25oct2017}{...}
{cmd:help npivcv}{right: ({browse "http://www.stata-journal.com/article.html?article=st0547":SJ18-4: st0547})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{bf:npivcv} {hline 2}}Nonparametric instrumental-variable regression with cross-validation{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}
Nonparametric instrumental-variable (NPIV) regression with a B-spline basis and cross-validated numbers of knots

{p 8 14 2}{cmd:npivcv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {it:options}]


{phang}
NPIV regression with a polynomial basis and cross-validated powers

{p 8 14 2}{cmd:npivcv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {opt poly:nomial} {it:options}]


{phang}
NPIV regression with an increasing shape restriction and cross-validated numbers of knots

{p 8 14 2}{cmd:npivcv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {opt inc:reasing} {it:options}]


{phang}
NPIV regression with a decreasing shape restriction and cross-validated numbers of knots

{p 8 14 2}{cmd:npivcv} {depvar} {it:expvar} {it:inst} [{it:exovar}] {ifin}
[{cmd:,} {opt dec:reasing} {it:options}]


{marker ncoptions}{...}
{synoptset 20}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt power_exp(integer)}}degree of the power of the basis 
function for the endogenous regressor; default is {cmd:power_exp(2)}{p_end}
{synopt :{opt power_inst(integer)}}degree of the power of the basis 
function for the instrument; default is {cmd:power_inst(3)}{p_end}
{synopt :{opt maxknot(integer)}}number of knots to be evaluated in
cross-validation; if {opt maxknot(k)} is typed and N is the sample size, the
cross-validation procedure evaluates the performance of
NPIV estimator with numbers of knots from 3 to max(N^(1/5), k) and executes NPIV regression 
with the optimal number of knots; if {opt polynomial} is used, then
{cmd:maxknot()} 
specifies maximum power to be evaluated; default is {cmd:maxknot(5)}{p_end}
{synopt :{opt pctile(integer)}}domain over which the nonparametric sieve estimator is evaluated; default is {cmd:pctile(5)}{p_end}
{synopt :{opt polynomial}}specify the type of both bases p(x) and q(w) to
be power polynomials{p_end}
{synopt :{opt increasing}}impose that the NPIV estimator is an
increasing
function of the endogenous regressor{p_end}
{synopt :{opt decreasing}}impose that the NPIV estimator is a
decreasing function of the endogenous regressor{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:expvar} is an endogenous regressor, {it:inst} an instrument, and {it:exovar} a list of exogenous covariates.{p_end}
{p 4 6 2}
{it:exovar} may contain factor variables; see {help fvvarlist}.{p_end}


{title:Description}

{pstd}
{cmd:npivcv} is built upon {cmd:npiv} and provides NPIV models with the
optimal numbers of knots.  {cmd:npivcv} constrains the two numbers of knots
for {it:expvar} and {it:inst} to be equal and then uses cross-validation to
choose them in a data-driven fashion.  Under the default setup, {cmd:npiv} runs
series instrumental-variable regression on a B-spline basis with no shape restriction.

{pstd}
{cmd:npivcv} requires community-contributed commands {cmd:bspline} and
{cmd:polyspline} to be installed from Statistical Software Components.

{pstd}
{cmd:npivcv} with {cmd:polynomial} uses a polynomial basis instead of a
B-spline basis.  Options {cmd:power_exp()} and {cmd:power_inst()} are unnecessary 
and are ignored if they are specified by the user because the
cross-validation procedure automatically chooses the optimal powers.

{pstd}
{cmd:npivcv} with {cmd:increasing} (or {cmd:decreasing}) imposes an increasing
(or decreasing) shape restriction on the nonparametric function g(X).  A
monotone shape restriction may significantly improve the performance of the
NPIV estimator (Chetverikov and Wihelm 2017).

{pstd}
{cmd:npivcv} stores the fitted values of g(X) in the Stata
variable {cmd:npest}.  Other results are stored in {cmd:e()}.


{title:Options}

{phang}
{opt power_exp(integer)} specifies a positive integer for the degree of the
spline basis for the endogenous regressor.  The default is {cmd:power_exp(2)}.
The user need not specify this option if {cmd:polynolmial} is used.

{phang}
{opt power_inst(integer)} specifies a positive integer for the degree of the
spline basis for the instrument.  {opt power_inst()} must be equal to or
larger than {opt power_exp()}.  The default is {cmd:power_inst(3)}.  The user
need not specify this option if {cmd:polynolmial} is used.

{phang}
{opt maxknot(integer)} is a positive integer for the maximum number of knots to be
considered in the cross-validation procedure.  With a sample size N and the
option {opt maxknot(k)}, the cross-validation procedure evaluates the
performance of the NPIV estimator with numbers of knots from 3 to max(N^{1/5},
k) and executes the NPIV regression with the optimal number of knots from that
range.  If the option {cmd:polynomial} is used, then {cmd:maxknot()} specifies
the maximum power of the polynomial to be considered.  The default is
{cmd:maxknot(5)}.

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
NPIV regression with cross-validation under a default setting{p_end}
{phang2}{cmd:. npivcv price mpg trunk}{p_end}

{pstd}
NPIV regression with a cubic B-spline for X, a quintic B-spline
for W, and cross-validated number of knots{p_end}
{phang2}{cmd:. npivcv price mpg trunk, power_exp(3) power_inst(5)}{p_end}

{pstd}
NPIV regression with a polynomial basis cross-validated power{p_end}
{phang2}{cmd:. npivcv price mpg trunk, polynomial}{p_end}

{pstd}
NPIV regression imposing increasing shape with a cubic B-spline
for X and a quintic B-spline for W and cross-validated number of knots{p_end}
{phang2}{cmd:. npivcv price mpg trunk, power_exp(3) power_inst(5) increasing}{p_end}

{pstd}
Default setup regression without Z and plot the fitted value with data{p_end}
{phang2}{cmd:. npivcv price mpg trunk}{p_end}
{phang2}{cmd:. scatter price mpg || line npest grid}{p_end}


{title:Stored results}

{pstd}
{cmd:npivcv} stores the following in {cmd:e()}:

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
{synopt:{cmd:e(optknot)}}optimal number of knots found by cross-validation{p_end}
{synopt:{cmd:e(maxknot)}}maximum number of knots (or power for polynomial) to be evaluated{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:npivcv}{p_end}
{synopt:{cmd:e(depvar)}}name of outcome{p_end}
{synopt:{cmd:e(expvar)}}name of endogenous regressor{p_end}
{synopt:{cmd:e(inst)}}name of instrument{p_end}
{synopt:{cmd:e(exovar)}}list of exogenous covariates{p_end}
{synopt:{cmd:e(basis)}}type of spline basis{p_end}
{synopt:{cmd:e(title)}}NPIV regression with cross-validation{p_end}
{synopt:{cmd:e(shape)}}type of imposed shape restriction{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}


{title:Remarks}

{pstd}
This is a first and preliminary version. Please feel free to share your
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
