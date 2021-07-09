
{smcl}
{* Help for -powersimplot- version 1.0.0 2July2013, Joerg Luedicke}{...}
{hline}
help {hi:powersimplot}
{hline}

{title:Plot power curves after {cmd:powersim}}


{title:Syntax}

{p 8 17 2}
{cmd:powersimplot} 
[
{cmd:,}  
{opt e:size}
{opt no:grid}
{it:{help twoway_options}}
]


{title:Description}

{p 4 4 2}
{cmd:powersimplot} plots statistical power as a function of sample size
by effect sizes (the default) or as a function of effect size by sample
sizes, using simulation results obtained with {help powersim}.


{title:Options} 

{p 4 8 2}{opt e:size} Plot power as a function of effect size (by sample sizes).

{p 4 8 2}{opt no:grid} Suppress grid lines.

{p 4 8 2}{it:{help twoway_options}} Any options other than {opt by()} 
documented in {bind:{bf:[G] {it:twoway_options}}}.


{title:Examples}

{hline}

{pstd}Power (of testing a certain interaction effect in a linear regression model) 
as a function of sample size, by effect sizes:{p_end}

{phang2}{cmd: powersim , ///} {p_end}
{phang2}{cmd: b(0.2(0.2)0.8) ///} {p_end}
{phang2}{cmd: alpha(0.05) ///} {p_end}
{phang2}{cmd: pos(8) ///} {p_end}
{phang2}{cmd: sample(10 50(50)600) ///} {p_end}
{phang2}{cmd: nreps(500) ///} {p_end}
{phang2}{cmd: family(gaussian .92) ///} {p_end}
{phang2}{cmd: link(identity) ///} {p_end}
{phang2}{cmd: block22(0.5 x1 0.2 x2 _bp) ///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace): reg y i.x1##i.x2} {p_end}

{phang2}{cmd: powersimplot} {p_end}

{hline}

{pstd}Power (of testing a certain interaction effect in a linear regression model) 
as a function of effect size, by sample sizes:{p_end}

{phang2}{cmd: powersim , ///} {p_end}
{phang2}{cmd: b(0(0.1)1) ///} {p_end}
{phang2}{cmd: alpha(0.05) ///} {p_end}
{phang2}{cmd: pos(8) ///} {p_end}
{phang2}{cmd: sample(200(200)800) ///} {p_end}
{phang2}{cmd: nreps(500) ///} {p_end}
{phang2}{cmd: family(gaussian .92) ///} {p_end}
{phang2}{cmd: link(identity) ///} {p_end}
{phang2}{cmd: block22(0.5 x1 0.2 x2 _bp) ///} {p_end}
{phang2}{cmd: dofile(psim_dofile, replace): reg y i.x1##i.x2} {p_end}

{phang2}{cmd: powersimplot, e} {p_end}

{hline}


{title:Author}

{p 4 4 2}Joerg Luedicke{break}
Yale University and University of Florida{break}
United States{break} 
email: joerg.luedicke@ufl.edu


{title:Also see}

{psee}
{space 2}Help:  {help powersim}
{p_end}

