{smcl}
{* 12apr2015}{...}
{cmd:help localp} 
{hline}

{title:Kernel-weighted local polynomial smoothing (customised version)}


{title:Syntax}

{p 8 18 2}
{cmd:localp} {it:yvar xvar} 
{ifin} 
[{it:weight}] 
[{cmd:,}
{it:options} 
]


{title:Description}

{pstd}
{cmd:localp} is a customised version of {help lpoly}, smoothing
{it:yvar} as a function of {it:xvar}.  

{pstd}
Defaults include 
{cmd:kernel(biweight)}, 
{cmd:degree(1)}, 
{cmd:bwidth()} given by rounding 0.2 of the range of {it:xvar} down to 
a nice number, 
{cmd:at(}{it:xvar}{cmd:)}, 
{cmd:ms(Oh)} and 
{cmd:title(, size(medium) place(w))} with text such as "local linear 
smooth". 

{pstd}
R-square and RMSE statistics of the smoother are shown based on
regression of smoothed on original values of {it:yvar} for the values of
{it:xvar}. 

{pstd}
{cmd:fweights} and {cmd:aweights} are allowed. See {help weights}. 


{title:Remarks}

{pstd}
{cmd:localp} is indicative, not definitive. It was written primarily for
teaching. 

{pstd}
The default bandwidth is just an arbitrary choice and emphatically not
the result of any kind of optimisation. {cmd:localp} offers both
opportunity and obligation to change bandwidth to identify instructive
and useful smooths.

{pstd}
The display of R-square and RMSE is essentially for guidance and for
comparison with results for other methods. It should be emphasised that
the goal of local polynomial regression is in no sense to maximise that
R-square or to minimise that RMSE. Indeed, high R-square and low RMSE
may often be achieveable by minimal smoothing, but not helpfully. 


{title:Options}

{phang}
See {help lpoly}. 


{title:Examples} 

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. localp dispacement weight}{p_end}
{phang}{cmd:. localp dispacement weight, bw(300)}{p_end}

{phang}(means by category with sufficiently small bandwidth){p_end}
{phang}{cmd:. localp mpg rep78, lineopts(recast(connect) ms(Th) msize(*2))}

{phang}{cmd:. webuse motorcycle}{p_end}
{phang}{cmd:. localp accel time}{p_end}
{phang}{cmd:. localp accel time, bw(3)}{p_end}


{title:Author} 

{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 


{title:Acknowledgments} 

{pstd}Ariel Linden suggested use of the motorcycle data as an example. 


{title:Also see}

{psee}
Manual:  {bf:[R] lpoly}, {bf:[G] graph twoway}

