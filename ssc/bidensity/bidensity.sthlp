{smcl}
{* 17dec2012}{...}
{hline}
help for {hi:bidensity}
{hline}

{title:Bivariate kernel density estimation}

{p 8 17}{cmd:bidensity}
{it:varnameY}
{it:varnameX}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
[{cmd:,} {cmdab:n(}{it:#}{cmd:)}
{cmdab:k:ernel(}{it:kernelname}{cmd:)}
{cmdab:xw:idth(}{it:#}{cmd:)}
{cmdab:yw:idth(}{it:#}{cmd:)}
{cmd:saving(}{it:name}{cmd:)}
{cmd:replace} 
{cmdab:nogr:aph} {cmdab:sc:atter}[{cmd:(}{it:scatter_options}{cmd:)}{cmd:]}
{it:contourline_options}
{cmdab:mn:ame(}{it:name}{cmd:)}

{title:Description}

{p 4 4}{cmd:bidensity} produces bivariate kernel density estimates and graphs the result using a {help twoway contourline:contourline} plot.  
The default kernel is an Epanechnikov.


{title:Options}

{p 4 8}{cmd:n(}{it:#}{cmd:)} specifies the number of points on the Y- and X-axes at which the density estimate is to be evaluated.  The default is min(_N,50).
 
{p 4 8}{cmdab:k:ernel(}{it:kernelname}{cmd:)} specifies which kernel should be used.  The default is {cmd:epanechnikov}.  
Other options are {cmd:gaussian}, {cmd:rectangle},  {cmd:triangle}, and {cmd:epan2}.  
These kernels are bivariate products of the univariate kernels described in {help kdensity}.  

{p 4 8}{cmdab:xw:idth(}{it:#}{cmd:)} specifies the halfwidth of the kernel, the width of the density window around each point of {it:varnameX}.  
If {cmd:xwidth()} is not specified, then the "optimal" width is used; see {cmd:kdensity}. 
    
{p 4 8}{cmdab:yw:idth(}{it:#}{cmd:)} specifies the halfwidth of the kernel, the width of the density window around each point of {it:varnameY}.  
If {cmd:ywidth()} is not specified, then the "optimal" width is used; see {cmd:kdensity}.     

{p 4 8}{cmd:saving(}{it:name}{cmd:)} saves the density estimates to {it:name}.dta, along with the x and y point values at which the density is estimated. 
If the file already exists, the {cmd:replace} option must be used to overwrite the previous data. The density estimates are saved in the variable "_d". 

{p 4 8}{cmdab:sc:atter}[{cmd:(}{it:scatter_options}{cmd:)}{cmd:]} superimposes a {cmd:twoway scatter} graph of {it:varnameY} and {it:varnameX} on the {cmd:contourline} graph of the density estimates.

{p 4 8}{it:contourline_options} are options to modify the {cmd:contourline} graph.

{p 4 8}{cmdab:nogr:aph} specifies that the contourline graph should not be drawn.

{p 4 8}{cmdab:mn:ame(}{it:name}{cmd:)} is a stub name for retaining the Mata matrices containing the density estimates ("{it:name}_d"), the X axis grid values ("{it:name}_x"), and the Y axis grid values ("{it:name}_y").
If {cmd:mname} is specified, these matrices can be seen after the {cmd:bidensity} with the command {cmd:mata: mata describe}.

{title:Examples}

{p 4 8}{stata "webuse grunfeld, clear" :. webuse grunfeld, clear}{p_end}

{p 4 8}{stata gen linv = log(invest) :. gen linv = log(invest)}{p_end}

{p 4 8}{stata label var linv "Log[Investment]:. label var linv "Log[Investment]"}{p_end}

{p 4 8}{stata "gen lmkt = log(mvalue)" :. gen lmkt = log(mvalue)}{p_end}

{p 4 8}{stata label var lmkt "Log[Mkt value]":. label var lmkt "Log[Mkt value]"}{p_end}
 
{p 4 8}{stata "bidensity linv lmkt" :. bidensity linv lmkt}{p_end}

{p 4 8}{stata "bidensity linv lmkt, n(100)" :. bidensity linv lmkt, n(100)}{p_end}

{p 4 8}{stata "bidensity linv lmkt, xw(.5) yw(.5)" :. bidensity linv lmkt, xw(.5) yw(.5)}{p_end}

{p 4 8}{stata "bidensity linv lmkt, scatter levels(10)" :. bidensity linv lmkt, scatter levels(10)}{p_end}

{p 4 8}{stata "bidensity linv lmkt, saving(biden) replace" :. bidensity linv lmkt, saving(biden) replace}{p_end}

{p 4 8}{stata "bidensity linv lmkt, mname(bid)" :. bidensity linv lmkt, mname(bid)}{p_end}
{p 4 8}{stata "mata: mata describe" :. mata: mata describe}{p_end}

{title:Authors}

{p 4 4}John Luke Gallup, Portland State University, USA{break} 
       jlgallup@pdx.edu
{p 4 4}Christopher F. Baum, Boston College, USA{break} 
       baum@bc.edu


{title:Also see}

{p 4 13}On-line: {help kdensity} 


