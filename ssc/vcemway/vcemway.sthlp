{smcl}
{* 16August2019/}{...}
{cmd:help vcemway}{right: ({browse "https://doi.org/10.1177/1536867X19893637":SJ19-4: st0582})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{cmd:vcemway} {hline 2}}A one-stop solution for robust inference with
multiway clustering{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:vcemway}
{it:cmdline_main}{cmd:,}
{opth cl:uster(varlist)}
[{opt vmcfactor(type)}
{opt vmdrf(#)}
{it:cmdline_options}]

{pstd}
{it:cmdline_main} refers to the main component of an estimation command line,
such as {cmd:xtreg y X Z}.


{title:Description}

{pstd}
{cmd:vcemway} adjusts a Stata estimation command's standard errors and
covariance matrix for multiway clustering in {it:varlist}.  The command works
with any Stata command that allows one-way clustering via the built-in option
{cmd:cluster(}{it:varname}{cmd:)}.  When {cmd:vcemway} results are active, any
call to postestimation commands that use {cmd:e(V)} (for example, 
{helpb test}, {helpb nlcom}, and {helpb margins}) will also produce results
that are robust to multiway clustering.
 
{pstd}
The required option {cmd:cluster(}{it:varlist}{cmd:)} accepts {it:varlist}
that lists two or more variables identifying the clustering dimensions of
interest.  The optional options {cmd:vmcfactor(}{it:type}{cmd:)} and
{cmd:vmdfr(}{it:#}{cmd:)} allow the researcher to supply his or her preferred
small-sample correction factor and residual degrees of freedom: see below.


{title:Options}

{phang}
{opt cluster(varlist)} accepts {it:varlist} that lists the names of m >= 2
variables that identify the clustering dimensions of interest.  As we will
explain shortly, the optional options {cmd:vmcfactor()} and {cmd:vmdfr()} allow
the researcher to supply his or her preferred small-sample correction factor
and residual degrees of freedom.  In the remaining syntax diagram,
{it:cmdline_main} refers to the main component of an estimation command line
that the researcher would like to execute, such as {cmd:xtreg y X Z}; and
{it:cmdline_options} refers to required and optional options in that command
line, such as {cmd:re} and {cmd:nonest}.  To complete this example, we see
that executing {cmd:vcemway xtreg y X Z, cluster(id1 id2 id3) re nonest} will
report a linear random-effects regression with standard errors that have been
adjusted for clustering in the three variables and computed using the default
settings (see below) for options {cmd:vmcfactor()} and {cmd:vmdfr()}.
{cmd:cluster()} is required.

{phang}
{opt vmcfactor(type)} specifies the type of small-cluster correction factor.
{it:type} may be {cmd:default}, {cmd:minimum}, or {cmd:none}.

{p 8 8 2}
As Cameron, Gelbach, and Miller (2011) show, a covariance matrix robust to
multiway clustering can be written as a linear combination of several
covariance matrices that are robust to one-way clustering in different
dimensions.  With one-way clustering, Stata applies a small-sample correction
factor of {n_g/(n_g - 1)} * {(N - 1)/(N - {it:#})}, where n_g is the number of
groups in a particular one-way clustering dimension, N is the number of
observations in the estimation sample, and {it:#} is the number of estimated
coefficients for some commands (for example, {cmd:regress}) and 1 for others
(for example, {cmd:ml, maximize}).  The small-cluster correction factor
henceforth refers to the first term in the product, n_g/(n_g - 1).

{p 8 8 2}
Unless specified otherwise, {cmd:vcemway} assumes the {cmd:default} type that
uses Stata's one-way clustered covariance matrices without further
modification. That is, each V_g incorporates its own small-cluster correction
factor of n_g/(n_g - 1).

{p 8 8 2}
The {cmd:minimum} type requests the use of a conservative correction factor
that is identical across all component matrices.  Specifically, every V_g is
recalculated by replacing n_g/(n_g - 1) with G/(G - 1), where G is the size of
the smallest clustering dimension.  For instance, suppose that
{cmd:cluster(id1 id2 id3)} has been specified, and there are 180, 30, and 78
clusters in {cmd:id1}, {cmd:id2}, and {cmd:id3}, respectively.  G will be 30
in this case.

{p 8 8 2}
Finally, the {cmd:none} type requests the use of no small-cluster correction.
In this case, every V_g is recalculated by replacing n_g/(n_g - 1) with 1.

{phang}
{opt vmdfr(#)} specifies the residual degrees of freedom for t and F tests.
The default setting varies from command to command.  In case the estimation
command in question reports large-sample test statistics (for example,
{cmd:ivregress} and {cmd:ml, maximize}), {it:#} is set to missing so that the
researcher can carry out large-sample tests instead of t and F tests.  In case
the estimation command reports small-sample statistics (for example,
{cmd:regress}), {it:#} is set to (G - 1), where G is the size of the smallest
clustering dimension.

{phang}
{it:cmdline_options} specifies required and optional options in that command
line, such as {cmd:re} or {cmd:fe}.  To complete this example, we see that
executing {cmd:vcemway xtreg y X Z, cluster(id1 id2 id3) re nonest} will
report a linear random-effects regression, with standard errors adjusted for
three-way clustering.


{title:Examples}

{pstd}
Ordinary least-squares regression with two-way clustering:{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. vcemway regress ln_wage grade ttl_exp c.ttl_exp#c.ttl_exp, cluster(idcode year)}{p_end}

{pstd}
Random-effects generalized least-squares regression with two-way
clustering:{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. vcemway xtreg ln_wage grade ttl_exp c.ttl_exp#c.ttl_exp, cluster(idcode year) re nonest}{p_end}

{pstd}
Random-effects generalized least-squares regression with two-way clustering,
using a more conservative small-cluster correction factor:{p_end}
{phang2}{cmd:. webuse nlswork}{p_end}
{phang2}{cmd:. vcemway xtreg ln_wage grade ttl_exp c.ttl_exp#c.ttl_exp, cluster(idcode year) re nonest vmcfactor(minimum)}{p_end}


{title:Stored results}

{pstd}
{cmd:vcemway} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N_clust}{it:k}{cmd:)}}number of clusters in the kth variable in {it:varlist}{p_end}
{synopt:{cmd:e(rank)}}rank of multiway clustered covariance matrix{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom for t and F tests{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(vcemway)}}{cmd:yes}{p_end}
{synopt:{cmd:e(clustvar}{it:k}{cmd:)}}name of the kth variable in {it:varlist}{p_end}
{synopt:{cmd:e(clustvar)}}names of all variables in {it:varlist}{p_end}
{synopt:{cmd:e(vmcfactor)}}type of small-cluster correction factor
({cmd:default}, {cmd:minimum}, or {cmd:none}){p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(V)}}multiway clustered covariance matrix{p_end}
{synopt:{cmd:e(V_raw)}}original version of {cmd:e(V)}, in case it has been
reconstructed by replacing negative eigenvalues with zeros to achieve
positive semidefiniteness{p_end}
{p2colreset}{...}


{title:Caveats}

{pstd}
As with one-way clustering, an adjustment for multiway clustering should be
applied with careful attention to the model of interest.  For nonlinear models
such as {helpb probit}, the presence of cluster-specific random effects is a
form of model misspecification that can render parametric estimators
inconsistent.  It may be inappropriate to consider the probit model with
multiway clustered standard errors as a substitute for a modeling solution
such as the crossed random-effects probit model that {helpb meprobit}
supports.  See Cameron and Miller (2015, sec. VII.C) and references therein
for further information on multiway clustering with nonlinear models.

{pstd}
In some cases, multiway clustering may not produce suitably robust test
statistics for linear models either.  For example, consider paired or "dyadic"
data, where each observation is on a distinct country pair, {A, B}.  While
two-way clustering on variables identifying A and B adjusts for error
correlation in {Australia, Canada} and {Australia, USA} and in {USA, UK} and
{Canada, UK}, it fails to account for correlation in {Australia, USA} and
{USA, UK}.  The last two country pairs share neither A nor B because USA
appears in alternate positions.  {cmd:vcemway} does not support more general
clustering methods for dyadic data (Aronow, Samii, and Assenova 2015; Cameron
and Miller 2014).

{pstd}
Correia (2015) advises that when fitting linear models with multiway fixed
effects, the researcher should drop singleton groups in each dimension of
fixed effects iteratively until no singleton group remains before clustering
standard errors in those dimensions.  Including singleton groups that comprise
one observation may have undue effects on statistical inferences by making
small-sample correction factors smaller than otherwise.  His
community-contributed command
{net "describe reghdfe, from(http://fmwww.bc.edu/RePEc/bocode/r)":{bf:reghdfe}}
(Correia 2014) allows for multiway clustering for linear models with multiway
fixed effects and automates this advice.


{title:References}

{phang}
Aronow, P. M., C. Samii, and V. A. Assenova. 2015. Cluster-robust variance
estimation for dyadic data. {it:Political Analysis} 23: 564-577.

{phang}
Cameron, A. C., J. B. Gelbach, and D. L. Miller. 2011. Robust inference with
multiway clustering. {it:Journal of Business & Economic Statistics} 29: 238-249.

{phang}
Cameron, A. C., and D. L. Miller. 2014. Robust inference for dyadic data.
{browse "http://faculty.econ.ucdavis.edu/faculty/cameron/research/dyadic_cameron_miller_december2014_with_tables.pdf"}.

{phang}
------. 2015. A practitioner's guide to cluster-robust inference.
{it:Journal of Human Resources} 50: 317-372.

{phang}
Correia, S. 2014. reghdfe: Stata module to perform linear or
instrumental-variable regression absorbing any number of high-dimensional
fixed effects. Statistical Software Components S457874, Department of
Economics, Boston College. {browse "https://ideas.repec.org/c/boc/bocode/s457874.html"}.

{phang}
------. 2015. Singletons, cluster-robust standard errors and fixed
effects: A bad mix. {browse "http://scorreia.com/research/singletons.pdf"}.


{title:Authors}

{pstd}Ariel Gu{p_end}
{pstd}Newcastle Business School{p_end}
{pstd}Northumbria University{p_end}
{pstd}Newcastle, UK{p_end}
{pstd}ariel.gu@northumbria.ac.uk{p_end}

{pstd}Hong Il Yoo{p_end}
{pstd}Durham University Business School{p_end}
{pstd}Durham University{p_end}
{pstd}Durham, UK{p_end}
{pstd}h.i.yoo@durham.ac.uk{p_end}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 19, number 4: {browse "https://doi.org/10.1177/1536867X19893637":st0582}{p_end}

{p 7 14 2}
Help:  {helpb ivreg2}, {helpb reghdfe}, {helpb boottest} (if installed),
{manhelpi vce_option R}, {manhelp _robust R}{p_end}
