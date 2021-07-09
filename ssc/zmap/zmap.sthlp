{smcl}
{* 11mar2010/3dec2012/10dec2012}{...}
{hline}
help for {hi:zmap}
{hline}

{title:Binned scatter map}

{p 8 17 2}
{cmd:zmap}
{it:zvar} 
{it:yvar} 
{it:xvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[
{cmd:,}  
{c -(} 
{cmdab:pct:iles(}{it:numlist}{cmd:)}
{c |} 
{cmdab:br:eaks(}{it:numlist}{cmd:)} 
{c )-} 
{cmdab:mult:iples} 
{it:graph_options}
]
   
   
{title:Description} 

{p 4 4 2} 
{cmd:zmap} graphs (or maps) binned values of a variable z with respect
to two variables x and y treated as Cartesian coordinates. In 
geographical or cartographical terms x defines distance east and y defines
distance north. The range of z is divided into two or more bins or classes
and points in each bin are shown distinctly. The resulting plot is
thus a composite scatter plot. 

{p 4 4 2} 
The main intended application is that z is a
spatial series measured at numerous points or for numerous small areas
with respect to planar coordinates x and y. However, 
nothing ties this command to spatial data. Users may wish to use the
command on other trivariate data. The marker symbols used may then be
better set to something larger than points. 

{p 4 4 2}
By default binning is into 8 classes with 7 breaks determined by the 5
10 25 50 75 90 95% points or percentiles of the distribution of z.
Alternatively, the user may specify other percentile breaks, or a set of
breaks on the scale of z. The number of classes in general is naturally 
one more than the number of breaks. 

{p 4 4 2}
By default with between 1 and 8 breaks, points falling into different
bins are shown with different gray scale colours, darker meaning higher
values. If more than 8 breaks are specified, default colours are just
those of the prevailing graph scheme. In either case users may specify
their own colour choices to override defaults. 

{p 4 4 2}
Lower limits are inclusive, so that each bin contains points >= its 
lower limit and < its upper limit. 


{title:Remarks} 

{p 4 4 2}
If the y variable follows a row or matrix or Southern latitude convention 
so that it increases downwards, then use the {cmd:ysc(reverse)} option. 

{p 4 4 2} 
The following limitations may be noted. 

{p 8 8 2}
1. {cmd:zmap} is not smart about tied values. Higher values of z for
the same x and y values will just overplot lower values. If this is
important, considering averaging z for each distinct combination of x
and y in some way. An example appears below. 

{p 8 8 2}
2. {cmd:zmap} does not apply any special intelligence to ensure
appropriate aspect ratios to maintain equal scales on both x and y axes.
The presumption is that most uses will be exploratory or that, if this is
important, {cmd:xsize()}, {cmd:ysize()} or {cmd:aspect()} options may be used
according to taste. 

{p 8 8 2}
3. {cmd:zmap} can do nothing about the limitations of your monitor, or
indeed any other monitor. 


{title:Options} 

{p 4 8 2} 
{cmd:pctiles(}{it:{help numlist}}{cmd:)} specifies that breaks between 
categories are defined by the percent points or percentiles indicated. 
For example, {cmd:pct(25 50 75)} specifies that the 25%, 50% and 75% 
points (lower quartile, median, upper quartile) be used as breaks, 
thus defining 4 classes. Percent points must be greater than 0 and 
less than 100. 

{p 4 8 2} 
{cmd:breaks(}{it:{help numlist}}{cmd:)} specifies that breaks between 
categories are defined by the values indicated. 
For example, {cmd:br(100 200 400)} specifies that values of 100, 200 
and 400 be used as breaks, thus defining 4 classes. 

{p 8 8 2}
Only one of {cmd:pctiles()} and {cmd:breaks()} may be specified. 
If neither is specified, the default is {cmd:pctiles(5 10 25 50 75 90 95)}. 
	
{p 4 8 2} 
{cmd:multiples} specifies that each bin or class be shown as a separate 
graph. Thus each plot is just a plot of the x and y values of points in that
bin of z. {cmd:multiples} is likely to be most useful with a small number 
of bins. 

{p 4 8 2} 
{it:graph_options} refers to any of the options of {help scatter}.
Defaults include, but are not limited to, 

{p 8 8 2}if {cmd:multiples} is not specified:  
{cmd:ysc(off) xsc(off) ms(p ..) legend(off)}  

{p 8 8 2}if {cmd:multiples} is specified:  
{cmd:by(, compact) yla(none) xla(none) ms(p) mcolor(gs4) legend(off)} 


{title:Examples} 

{p 4 4 2}(spatial data, all x, y pairs distinct){p_end}
{p 4 8 2}{cmd:. zmap B5 Y X, pct(25 50 75)}{p_end}
{p 4 8 2}{cmd:. zmap B5 Y X, pct(25 50 75) mcolor(blue blue*0.5 orange*0.5 orange)}{p_end}
{p 4 8 2}{cmd:. zmap B5 Y X, pct(25 50 75) multiples}{p_end}

{p 4 8 2}(non-spatial data, average z given x, y first){p_end}
{p 4 8 2}{cmd:. webuse nlswork}{p_end}
{p 4 8 2}{cmd:. egen mean = mean(ln_wage), by(age grade)}{p_end}
{p 4 8 2}{cmd:. egen tag = tag(age grade)}{p_end}
{p 4 8 2}{cmd:. label var mean "mean ln wage"}{p_end}
{p 4 8 2}{cmd:. su ln_wage if !missing(age, grade), detail}{p_end}
{p 4 8 2}{cmd:. zmap mean grade age if tag, breaks(.993 1.166 1.361 1.641 1.964 2.275 2.456) ms(S ..) ysc(on) xsc(on) legend(on pos(3) col(1)) yla(0/18, ang(h)) ytitle(`: var label grade') xla(15(5)45) note("")}{p_end} 


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Also see} 

{p 4 13 2}
On-line: help for  {help twoway contour} (Stata 12+), {help spmap} (if installed) 

