{smcl}
{cmd:help ztnbp}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:ztnbp} {hline 2} Zero-truncated NegBin-P regression}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 19 2}{cmd:ztnbp}
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
{synopt :{opt nocon:stant}}suppress constant term{p_end}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust}, {opt cl:uster} {it:clustvar}, or {opt opg}{p_end}
{synopt :{it:maximize_options}}control the maximization process; see {manhelp maximize R} {p_end}
{synoptline}
{p 4 6 2} {cmd:bootstrap} and {cmd:jackknife} are allowed; see {help prefix}.{p_end}


{title:Description}

{pstd} {cmd:ztnbp} fits a zero-truncated Negbin-P model. Setting P=1 or P=2 gives the ztnb-1 (dispersion(constant)) or ztnb-2 (dispersion(mean)) model (see {helpb tnbreg}). Otherwise 
{cmd:ztnbp} generalizes these models in the sense that you get an estimate for P.

{pstd}
This program uses {cmd:ml lf} method.


{title:Options}

{phang}
{opt noconstant} suppresses the constant term (intercept) in the model.

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which
includes types that are derived from asymptotic theory, that are robust to
some kinds of misspecification, and that allow for intragroup correlation; see
{manhelpi vce_option R}.

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


{title:Author}

{pstd}Helmut Farbmacher{p_end}
{pstd}Munich Center for the Economics of Aging (MEA){p_end}
{pstd}Max Planck Society, Germany{p_end}
{pstd}farbmacher@mea.mpisoc.mpg.de{p_end}

{title:Reference}

{psee}Farbmacher, H. 2012: {it:Extensions of hurdle models for overdispersed count data}, Health Economics, forthcoming.

{p 4 14 2}
{space 3}Help:  {manhelp tnbreg R}, {manhelp ztpnm R}, {manhelp ztpflex R} {p_end}
