{smcl}
{cmd:help ztpflex}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:ztpflex} {hline 2} Zero-truncated Poisson mixture regression}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 19 2}{cmd:ztpflex}
{depvar}
[{indepvars}]
{ifin} 
[{cmd:,} 
{it:options}]

{pstd}
where {it:depvar} has to be a strictly postive outcome.

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt :{opt ir:r}}report incidence-rate ratios{p_end}
{synopt :{opt non:adaptive}}use standard Gauss-Hermite quadrature; default is adaptive quadrature{p_end}
{synopt :{opt intp:oints(#)}}choose the number of quadrature points used for the approximation; default is {cmd:intpoints(30)}{p_end}
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust}, {opt cl:uster} {it:clustvar}, or {opt opg}{p_end}
{synopt :{opt vuong}}perform Vuong test of {cmd:ztpflex} versus {helpb ztnbp}{p_end}
{synopt :{it:maximize_options}}control the maximization process; see {manhelp maximize R} {p_end}
{synoptline}
{p 4 6 2} {cmd:bootstrap} and {cmd:jackknife} are allowed; see {help prefix}.{p_end}


{title:Description}

{pstd} {cmd:ztpflex} fits a zero-truncated Poisson model with a more flexible mixing distribution 
than {helpb ztpnm}. The integral is approximated using adaptive Gauss-Hermite quadrature. 
Generally, a higher number of quadrature points leads to a more accurate approximation, 
but it takes longer to converge. It is highly recommended to check the sensitivity of the results; see
{manhelp quadchk XT}.

{pstd} {cmd:ztpflex, nonadaptive} uses standard Gauss-Hermite quadrature.
Generally, this method is less accurate even if the number of quadrature
points is high.

{pstd}
This program uses {cmd:ml lf} method.


{title:Options}

{phang} {opt irr} reports incidence-rate ratios.

{phang} {opt nonadaptive} uses standard Gauss-Hermite quadrature; the default is
adaptive quadrature.

{phang}
{opt intpoints(#)} chooses the number of points used for the approximation.
The default is {cmd:intpoints(30)}. The maximum is 195. Generally, a higher number of
points leads to a more accurate approximation, but it takes longer to
converge.  It is highly recommended to check the sensitivity of the results.

{phang}
{opt noconstant} suppresses the constant term (intercept) in the model.

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which
includes types that are derived from asymptotic theory, that are robust to
some kinds of misspecification, and that allow for intragroup correlation; see
{manhelpi vce_option R}.

{phang}
{opt vuong} performs a Vuong test of {cmd:ztpflex} versus {helpb ztnbp}.

{phang}{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{cmd:{ul:lo}}{cmd:g}, {opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)}, {opt nrtol:erance(#)},
{opt nonrtol:erance}, and {opt from(init_specs)}; see {manhelp maximize R}.
These options are seldom used.

{phang2}{cmd:difficult} is the default.

{title:Remarks for quadcheck}

{pstd}
See {it:{mansection XT quadchkRemarks:Remarks}} in {bf:[XT] quadchk}.

{title:Author}

{pstd}Helmut Farbmacher{p_end}
{pstd}Munich Center for the Economics of Aging (MEA){p_end}
{pstd}Max Planck Society, Germany{p_end}
{pstd}farbmacher@mea.mpisoc.mpg.de{p_end}

{title:Reference}

{psee}Farbmacher, H. 2012: {it:Extensions of hurdle models for overdispersed count data}, Health Economics, forthcoming.

{p 4 14 2}
{space 3}Help:  {manhelp ztp R}, {manhelp ztpnm R}, {manhelp ztnbp R}{p_end}
