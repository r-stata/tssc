{smcl}
{* 15jan2005}{...}
{hline}
help for {hi:kdens2}
{hline}

{title:Bivariate kernel density estimation}

{p 8 17}{cmd:kdens2}
{it:varnameY}
{it:varnameX}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,} {cmdab:n(}{it:#}{cmd:)}
{cmdab:xw:idth(}{it:#}{cmd:)}
{cmdab:yw:idth(}{it:#}{cmd:)}
{cmd:saving(}{it:name}{cmd:)}
{cmd:replace} {cmd:nodraw}  {cmd:color} {cmd:*)
]


{title:Description}

{p 4 4}{cmd:kdens2} produces bivariate kernel density estimates using a Gaussian kernel.
For version 12.1 of Stata, a graph is produced with {cmd:twoway contourline}, or optionally
{cmd:twoway contour}. For versions 10 and 11 of Stata, {kdens2} graphs the result using 
Adrian Mander's {cmd:surface} plot routine. If Y- and X-variable labels are available, 
they are used to label the graph.


{title:Options}

{p 4 8}{cmd:n(}{it:#}{cmd:)} specifies the number of points on the Y- and X-axes at which the density estimate is to be evaluated.  The default is min(_N,50).
 
{p 4 8}{cmd:xwidth(}{it:#}{cmd:)} specifies the halfwidth of the kernel, the width of the density window around each point of {it:varnameX}. 
 If {cmd:xwidth()} is not specified, then the "optimal" width is used; see {cmd:kdensity}. 
    
{p 4 8}{cmd:ywidth(}{it:#}{cmd:)} specifies the halfwidth of the kernel, the width of the density window around each point of {it:varnameY}. 
 If {cmd:ywidth()} is not specified, then the "optimal" width is used; see {cmd:kdensity}.     

{p 4 8}{cmd:saving(}{it:name}{cmd:)} causes the graph to be saved as {it:name}.gph. 
If this graph already exists, the {cmd:replace} option must be used. The option also causes the data underlying the 
graph to be written to {it:name}.dta. If this file already exists, 
the {cmd:replace} option must be used.

{p 4 8}{cmd:nodraw} specifies that the 3D graph should not be drawn. However, if the {cmd:saving} option is invoked,
the resulting data will be saved.

{p 4 8}{cmd:color} specifies, for Stata version 12.1, that {cmd:twoway contour} is to be used
rather than {cmd:twoway contourline}.

{p 4 8}{cmd:*} indicates that any options appropriate for {cmd:twoway contourline} or {cmd:twoway contour}
may be given.

{title:Examples}

{p 4 8}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}

{p 4 8}{stata gen linv = log(invest) :. gen linv = log(invest)}{p_end}

{p 4 8}{stata label var linv "Log[Investment]:. label var linv "Log[Investment]"}{p_end}

{p 4 8}{stata "gen lmkt = log(mvalue)" :. gen lmkt = log(mvalue)}{p_end}

{p 4 8}{stata label var lmkt "Log[Mkt value]":. label var lmkt "Log[Mkt value]"}{p_end}
 
{p 4 8}{stata "kdens2 linv lmkt" :. kdens2 linv lmkt}{p_end}

{p 4 8}{stata "kdens2 linv lmkt, levels(20)" :. kdens2 linv lmkt, levels(20)}{p_end}

{p 4 8}{stata "kdens2 linv lmkt, levels(20) color" :. kdens2 linv lmkt, levels(20) color}{p_end}

{p 4 8}{stata "kdens2 linv lmkt, saving(bivar) replace" :. kdens2 linv lmkt, saving(bivar) replace}{p_end}

{title:Author}

{p 4 4}Christopher F. Baum, Boston College, USA{break} 
       baum@bc.edu

{title:Acknowledgements}

{p 4 4} For Stata versions 10 and 11, the graphics produced by this routine are generated by Adrian Mander's 
     {cmd:surface} routine. Thanks to Friedrich Huebler and Maria Cecilia Calderon for 
     identifying bugs and Tom Steichen for constructive suggestions. 

{title:Also see}

{p 4 13}On-line: {help density} 


