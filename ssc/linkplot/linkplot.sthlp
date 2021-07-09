{smcl}
{* 30jan2004/12dec2007}{...}
{hline}
help for {hi:linkplot}
{hline}

{title:Linked scatter plots}

{p 8 17 2}
{cmd:linkplot}
{it:yvarlist} 
{it:xvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{it:weight}] 
{cmd:,}
{cmd:link(}{it:linkvar}{cmd:)} 
[ 
{cmdab:asy:vars} 
{cmdab:cmis:sing(}{c -(}{cmd:y}{c |}{cmd:n}{c )-}{cmd:)}
{cmd:sort(}{it:sort_varlist}{cmd:)} 
{cmd:plot(}{it:plot}{cmd:)} 
{cmd:addplot(}{it:plot}{cmd:)} 
{it:graph_options} 
]


{title:Description}

{p 4 4 2}{cmd:linkplot} plots {it:yvarlist} versus {it:xvar} such that data
points are linked (i.e. connected) within groups defined by distinct values of
{it:linkvar}. For example, with paired data it might be desired to link each
pair, or with panel data it might be desired to link observations within each
panel. 

{p 4 4 2}{cmd:aweight}s, {cmd:fweight}s and {cmd:pweight}s are allowed; 
see help {help weights}.


{title:Options}
 
{p 4 8 2}{cmd:link(}{it:linkvar}{cmd:)} specifies that values of each 
variable in {it:yvarlist} are to be linked if they have the same value 
of {it:linkvar}. This option is required. 

{p 4 8 2}{cmd:asyvars} specifies that the groups defined by {it:linkvar} 
should be plotted as if they were separate {it:y} variables.

{p 4 8 2}{cmd:cmissing(}{c -(}{cmd:y}{c |}{cmd:n}{c )-}{cmd:)} specifies
whether missing values are ignored.  The default is to ignore missing values.
Note that this is a slight variant on {cmd:cmissing()} as explained at help
{help connect_options}.  The only allowed arguments are {cmd:y}, to ignore, and
{cmd:n}, not to ignore.  These are automatically expanded to all variables
plotted. 
 
{p 4 8 2}{cmd:sort(}{it:sort_varlist}{cmd:)} specifies that values are to be 
linked in order of {it:sort_varlist}. By default values are linked in sort 
order of {it:xvar}, the last variable specified before the option comma. 
Do not specify {it:linkvar}, as this will automatically be used. 

{p 4 8 2}{cmd:plot(}{it:plot}{cmd:)} provides a way to add other plots to the 
generated graph; see help {help plot_option}. (Stata 8 only) 

{p 4 8 2}{cmd:addplot(}{it:plot}{cmd:)} provides a way to add other plots to the 
generated graph; see help {help addplot_option}. (Stata 9 up) 

{p 4 8 2}{it:graph_options} are options of 
{help twoway_connected:twoway connected}. 


{title:Examples} 

{p 4 4 2}Box, Hunter and Hunter (1978, p.100) gave data for 10 boys on the 
wear of shoes made using materials A and B. The data are also analysed by 
Wild and Seber (2000, p.446) and Davison (2003, pp.421-3). The units are not 
specified. Before exemplifying 
{cmd:linkplot} we make some general comments on graphing such paired data. 
One natural data structure would be something like this: 

         {cmd:A          B         id}
      13.2       14.0          1
       8.2        8.8          2
      10.9       11.2          3
      14.3       14.2          4
      10.7       11.8          5
       6.6        6.4          6
       9.5        9.8          7
      10.8       11.3          8
       8.8        9.3          9
      13.3       13.6         10

{p 4 4 2}This data structure permits some Stata graphs, but inhibits others. 
A scatter plot such as {cmd:scatter A B} may be useful, but does not allow easy 
decoding of the difference, say {cmd:A} - {cmd:B}, which is here of central 
interest. Similarly, it is difficult to read off ratios such as 
{cmd:A} / {cmd:B}. If {cmd:A} and {cmd:B} are plotted versus {cmd:id}, 
or {it:vice versa}, the resulting graphs suffer from the arbitrariness of 
{cmd:id}. See also the possibilities offered by {help pairplot}, which 
may be installed using {help ssc}. 

{p 4 4 2}Other possibilities are available after a {help reshape}: 

{p 4 8 2}{cmd:. rename A wearA}{p_end}
{p 4 8 2}{cmd:. rename B wearB}{p_end}
{p 4 8 2}{cmd:. reshape long wear, string i(id) j(j)}{p_end}
{p 4 8 2}{cmd:. encode j, gen(material)}

{p 4 4 2}Now we have a choice, including 

{p 4 8 2}{cmd:. linkplot material wear, link(id) yla(1 2, valuelabel) ysc(r(0.5 2.5)) yla(, ang(h))}{p_end}
{p 4 8 2}{cmd:. linkplot wear material, link(id) xla(1 2, valuelabel) xsc(r(0.5 2.5)) yla(, ang(h))}


{title:Acknowledgments}

{p 4 4 2}Vince Wiggins made encouraging noises.  


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:References} 

{p 4 8 2}Box, G.E.P., W.G. Hunter and J.S. Hunter. 1978. 
{it: Statistics for experimenters: an introduction to design, data analysis, and model building.}
New York: John Wiley. 

{p 4 8 2}Davison, A.C. 2003. {it: Statistical models.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Wild, C.J. and G.A.F. Seber. 2000. 
{it:Chance encounters: a first course in data analysis and inference.} 
New York: John Wiley. 


{title:Also see} 

{p 4 17 2}On-line: help for {help pairplot} (if installed) 

