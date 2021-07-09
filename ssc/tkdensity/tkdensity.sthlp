{smcl}
{* 9aug2012}{...}
{hline}
help for {hi:tkdensity}
{hline}

{title:Univariate kernel density estimation, calculation on transformed scale} 

{p 8 17 2} 
{cmd:tkdensity} 
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
{cmdab:g:enerate(}{help newvar:newvar_x} {help newvar:newvar_d}{cmd:)} 
{cmdab:t:rans(}{it:transformation}{cmd:)} 
{cmdab:graph:opts(}{it:line_opts}{cmd:)} 
{it:kdensity_options} 
] 


{title:Description}

{p 4 4 2}
{cmd:tkdensity} estimates and graphs kernel density estimates for the
density function of numeric variable {it:varname}, doing the
calculations on a specified transformed scale and back-transforming to
show density versus the original scale. It is a convenience wrapper for
{help kdensity}. 

{title:Remarks}

{p 4 4 2}
For a monotone transformation t(x) the principle is that for densities f 

{p 8 8 2} 
estimate of f{x} = estimate of f{t(x)} * |dt/dx|.  

{p 4 4 2}
For discussion and references, see Cox (2004, pp.76{c -}78). 

{p 4 4 2}
On cube roots, see also Cox (2011). 


{title:Options} 

{p 4 8 2}
{cmd:trans()} specifies the transformation to be used. Transformations
implemented are 

{p 8 8 2} 
natural logarithm, which may be specified by {cmd:ln} or
{cmdab:loga:rithm}, and which is the default; for this values must all be
strictly positive (>0); 

{p 8 8 2}
cube root, which may be specified by {cmdab:cube: root};
for this values may be negative, zero, or positive; 

{p 8 8 2} 
square root, which may be specified by {cmd:root} or {cmdab:square: root};
for this values must all be zero or positive; 

{p 8 8 2}
reciprocal, which may be specified by {cmdab:rec:iprocal};
for this values must all be strictly positive (>0);

{p 8 8 2}
logit, which may be specified by {cmd:logit}; for this values must all be
within (0,1) (and so not equal to 0 or 1). 

{p 8 8 2}See underlining above for permitted abbreviations of keywords. 

{p 4 8 2}
{cmd:generate()} stores the results of the 
estimation.  {it:newvar_x} will contain the points at which the density is
estimated.  {it:newvar_d} will contain the density estimate.

{p 4 8 2}
{cmd:graphopts(}{it:line_options}{cmd:)} specifies options of 
{help line} used to tune the graphical display of the density.

{p 4 8 2}
{it:kdensity_options} are options of {help kdensity}. Note that 
{cmd:kdensity} is called with option {cmd:nograph} and that in any case
the density estimates it would graph would be on the transformed scale,
so graphics options are excluded here. See also the option just above.
Note also that bandwidths are measured on the transformed scale. 


{title:Examples} 

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. tkdensity mpg, trans(ln) kernel(biweight) bw(0.25)}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break}
n.j.cox@durham.ac.uk


{title:References} 

{p 4 8 2}
Cox, N.J. 2004. 
Graphing distributions. 
{it:Stata Journal} 2: 66{c -}88. See esp. pp.76{c -}78. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0003":http://www.stata-journal.com/sjpdf.html?articlenum=gr0003}

{p 4 8 2}
Cox, N.J. 2011. 
Stata tip 96: Cube roots. 
{it:Stata Journal} 11: 149{c -}154. 


{title:Also see} 

{p 4 4 2}
{help kdensity} 

