{smcl}
{* 30jan2013/2feb2013/22feb2013/1may2013}{...}
{hline}
help for {hi:trimplot}
{hline}

{title:Plots of trimmed means} 

{p 8 17 2}
{cmd:trimplot} 
{it:varname}
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}]
[{cmd:,}
{c -(}
{cmd:over(}{it:overvar}{cmd:)} 
{c |}
{cmd:by(}{it:byvar} [{cmd:,} {it:by_subopts}]{cmd:)} 
{c )-} 
{cmd:percent} 
{cmd:metric} 
{cmd:mad} 
{it:scatter_options}]

{p 8 17 2}
{cmd:trimplot} 
{it:varlist}
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}]
[{cmd:,}
{cmd:percent} 
{cmd:metric} 
{cmd:mad} 
{it:scatter_options}]


{title:Description}

{p 4 4 2}
{cmd:trimplot} produces plots of trimmed means versus depth or percent
trimmed or deviation for one or more numeric variables. Such plots may
help specifically in choosing or assessing measures of level and
generally in assessing the symmetry or skewness of distributions. They
can be used to compare distributions or to assess whether
transformations are necessary or effective.

{p 4 4 2}
{cmd:trimplot} may be used to show trimmed means for one variable, in
which case different groups may be distinguished by the {cmd:over()} or
the {cmd:by()} option; or for several variables. 


{title:Remarks} 

{p 4 4 2}Order n data values for a variable y and label them such that
y(1) <= ... <= y(n). Following Tukey (1977), depth is defined as 1 for
y(1) and y(n), 2 for y(2) and y(n-1), and so forth: it is the smaller 
number reached by counting inwards from either extreme y(1) or y(n)
toward any specified value. So the depth of y(i) is the smaller of i and
n - i + 1. 

{p 4 4 2}Trimmed means as plotted by {cmd:trimplot} by default may be
related to depth as follows. A trimmed mean may be defined for any
particular depth as the mean of all values with that depth or greater.
Thus the trimmed mean for depth 1 is the mean of all values. The trimmed
mean for depth 2 is the mean of all values except those of depth 1, i.e.
all values except for the extremes. The trimmed mean for depth 3 is the
mean of all values except those of depth 1 and 2; and so forth. 

{p 4 4 2}The highest depth observed for a distribution occurs once if n
is odd and twice if n is even; either way it labels values whose mean is
the median. Thus trimmed means range from the mean to the median. 

{p 4 4 2}The idea of plotting trimmed mean as a family or function  
is simple. Examples can be found in Rosenberger and Gasko (1983,
p.315) and Davison and Hinkley (1997, p.122). Users knowing good and/or
early references are welcome to email me with details. 

{p 4 4 2}Alternatively, values can be ordered in terms of their absolute 
deviation from the median. The option {cmd:metric} is required for this. 
In this case trimmed means are defined as 
the means of values whose absolute deviation from the median is no greater 
than some specified amount. More formally, let med() indicate taking the 
median and ave() taking the average. Trimmed means for a variable y are then a 
family ave(y : |y - med(y)| <= d). As d becomes small, the trimmed mean 
tends to the median; as d becomes arbitrarily large, it becomes the 
unconditional mean. This sequence of trimmed means has the same endpoints
(the mean and median) as trimmed means defined using depth, but need
not coincide with the latter otherwise. 

{p 4 4 2}For more on trimmed means, see the help for {help trimmean}
(which must be installed first).  


{title:Options} 

{p 4 8 2}{cmd:over(}{it:overvar}{cmd:)} specifies that calculations are
to be carried out separately for each group defined by {it:overvar} but
plotted in the same panel.  {cmd:over()} is allowed only with a single
variable to be plotted. 

{p 4 8 2}{cmd:by(}{it:byvar} [{cmd:,} {it:by_subopts}] {cmd:)}
specifies that calculations are to be carried out separately for each
group defined by {it:byvar} and plotted in separate panels. Suboptions
may be specified to tune the graphical display: see help on the 
{help by_option:by option}.  {cmd:by()} is allowed only with a single
variable to be plotted. 

{p 8 8 2}{cmd:over()} and {cmd:by()} may not be combined. 

{p 4 8 2}{cmd:percent} specifies that depth is to be scaled and plotted
as percent trimmed, which will range from 0 to nearly 50 (a median cannot 
be based on no observed values, so 50 cannot be attained). 

{p 4 8 2}{cmd:metric} specifies that trimmed means be defined and plotted
in terms of allowed absolute deviation from the median. 

{p 4 8 2}{cmd:mad} specific metric trimming as above, but values will be 
plotted versus absolute deviation from the median / median absolute deviation 
from the median. The median (absolute) deviation (from the median) can be traced to Gauss (1816). 

{p 4 8 2}{it:scatter_options} are options of {help twoway scatter}. 


{title:Examples}

{p 4 8 2}{cmd:. webuse citytemp}{p_end}
{p 4 8 2}{cmd:. describe}{p_end}
{p 4 8 2}{cmd:. trimplot *dd}{p_end}
{p 4 8 2}{cmd:. trimplot temp*}{p_end}
{p 4 8 2}{cmd:. trimplot tempjan, over(region) percent}{p_end}
{p 4 8 2}{cmd:. gen code = word("E C S W", region)}{p_end}
{p 4 8 2}{cmd:. trimplot tempjan, over(region) metric mad legend(off) mla(code code code code) mlabpos(0 ..) ms(none ..)}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Ariel Linden found a typo in the help. 


{title:References}

{p 4 8 2}Davison, A.C. and Hinkley, D.V. 1997. 
{it:Bootstrap methods and their application.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Gauss, C.F. 1816. 
Bestimmung der Genauigkeit der Beobachtungen. 
{it:Zeitschrift f{c u:}r Astronomie und verwandte Wissenschaften}
1: 187{c -}197.

{p 4 8 2}Rosenberger, J.L. and Gasko, M. 1983. 
Comparing location estimators: trimmed means, medians, and trimean. 
In Hoaglin, D.C., Mosteller, F. and Tukey, J.W. (Eds)
{it:Understanding robust and exploratory data analysis.}
New York: John Wiley, 297{c -}338. 

{p 4 8 2}Tukey, J.W. 1977. 
{it:Exploratory data analysis.} 
Reading, MA: Addison-Wesley. 


{title:Also see} 

{p 4 13 2}  
{help summarize}, 
{help means}, 
{help trimmean} (if installed), 
{help hsmode} (if installed), 
{help shorth} (if installed)

