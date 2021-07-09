{smcl}
{* 3 July 2017/17 July 2017/6 April 2020}{...}
{hline}
help for {hi:multiline}
{hline}

{title:Multiple panel line plots}

{p 8 17 2}
{cmd:multiline} 
{it:yvars} 
{it:xvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[
{cmd:,}
{cmd:by(}{it:by_options}{cmd:)}
{cmd:mylabels(}{it:labelspec}{cmd:)} 
{cmdab:miss:ing} 
{cmdab:sep:arate}
{it:line_options} 
]  


{title:Description}

{p 4 4 2}
{cmd:multiline} by default plots {it:yvars} against {it:xvar} as a
series of line plots in separate panels. A common application is to
multiple time series, especially those measured in different units
and/or on very different scales. 

{p 4 4 2}
{cmd:multiline} works with a temporarily restructured dataset in which
different {it:yvars} are {help stack}ed into one. The graph then is
based on use of {cmd:twoway line, by()}. The original variable labels
(or, if labels are not defined, variable names) become the value labels 
of the stacking variable. 

{p 4 4 2} 
It is not assumed that the data have been {help tsset} or {help xtset}.
However, if a panel variable has been declared, an attempt is made to
avoid spurious connections across panels. 

{p 4 4 2} 
The {cmd:recast()} option opens the door to using the same design for
other kinds of plots, such as scatter or connected plots. Note that 
as {cmd:connect(L)} is the default it must be switched off explicitly 
if you do not wish to connect data points. 


{title:Options}

{p 4 8 2}
{cmd:by()} specifies options of the {help by_option:by()} option.  The
defaults are {cmd:cols(1) yrescale note("")}. Note that {cmd:_stack}
produced temporarily by the program is already wired in as {it:varlist}
for this option. 

{p 4 8 2}
{cmd:mylabels} allows control of labels used to describe each panel. 
Most commonly, this option is used to modify original variable labels 
and/or to stack them vertically into shorter segments. New labels should
be bound in double quotes if they contain spaces and in compound double
quotes if they are to extend over multiple lines. Such labels have 
no lasting effect on the dataset used. 

{p 4 8 2}
{cmd:missing} specifies that observations with some missing values on 
{it:yvars} should be included in the sample. The default is to ignore 
observations with any missing values. 

{p 4 8 2}
{cmd:separate} specifies that the {it:yvars} be plotted differently. 
The default is to use the same style for all. With {cmd:separate} a legend will 
spring into being, which you should usually suppress. 
The line and marker defaults for your scheme might not be to your liking, 
so you can change those as usual.

{p 4 8 2}{it:line_options} are options of {help line}. 
Note that the defaults are 
{cmd:ytitle("") yla(, ang(h)) c(L) subtitle(, pos(9) bcolor(none) nobexpand place(e))}.  


{title:Examples}

{p 4 8 2}{cmd:. webuse grunfeld, clear}{p_end}
{p 4 8 2}{cmd:. multiline invest mvalue kstock year}{p_end}
{p 4 8 2}{cmd:. multiline invest mvalue kstock year if company == 1}{p_end}
{p 4 8 2}{cmd:. multiline invest mvalue kstock year if company == 1, recast(connected)}{p_end}
{p 4 8 2}{cmd:. multiline invest mvalue kstock year if company == 1, recast(connected) mylabels(`" `" "Gross" "investment" "' `" "Market" "value" "' `" "Plant and" "equipment value" "' "')}{p_end}

{p 4 8 2}{cmd:. multiline invest mvalue kstock year if company == 1 , xtitle("") recast(connected) separate}{p_end}
{p 4 8 2}{cmd:. multiline invest mvalue kstock year if company == 1 , xtitle("") recast(connected) separate by(legend(off)) ms(O D T) lc(black orange blue) mc(black orange blue)}{p_end}


{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. multiline mpg weight length displacement price, recast(scatter) c(none) by(col(2)) ms(Oh) subtitle(, orient(vertical))}{p_end}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, University of Durham, U.K.{break} 
        n.j.cox@durham.ac.uk
		

{title:Acknowledgments}

{p 4 4 2}Questions on Statalist led to improvements. The {cmd:separate} option arises from a question by Zeeshan Fareed. A bug fix was triggered by a problem reported by Shem Shen. 


{title:Also see}

{p 4 13 2}On-line:  help for {help line}, {help tsline}, {help xtline}, {help sparkline} (if installed)  


