{smcl}
{* 03aug2018}{...}
{cmd: help scheme scientific}{right:(Ariel Linden)}
{hline}

{title:Title}

{p2colset 5 26 29 1}{...}
{p2col:{hi:scheme scientific} {hline 2}}Scheme description: scientific{p_end}
{p2colreset}{...}

{* index schemes}{...}
{title:Syntax}

{p 4 4 2}

	{it:schemename}{col 22}Foreground{col 34}Background{col 46}Description
	{hline 70}
{col 9}{cmd:scientific}{...}
{col 22}monochrome{...}
{col 36}white{...}
{col 46}black on white
	{hline 70}

{p 4 4 2}
For instance, you might type

{p 8 16 2}
{cmd:. graph}
...{cmd:,}
...
{cmd:scheme(scientific)}

{p 8 16 2}
{cmd:. set}
{cmd:scheme}
{cmd:scientific}
[{cmd:,}
{cmdab:perm:anently}
]

{p 4 4 2}
See help {help scheme_option} and help {help set_scheme}.


{title:Description}

{p 4 4 2}
Schemes determine the overall look of a graph; see help for {help schemes}.

{p 4 4 2}
Scheme {cmd:scientific} specifies a graph with certain attributes favored by some scientific journals. That is:

{p 4 4 2}
(1) black-and-white

{p 4 4 2}
(2) no gridlines

{p 4 4 2}
(3) X and Y axes that do not join

{p 4 4 2}
(4) Y axis labels that are horizontal

{p 4 4 2}
(5) the legend is in the lower right-hand corner outside of the plot area

{p 4 4 2}
(6) markers are paired, with the first one solid and the second one hollow


{title:Examples}

{pstd}
Load data

{phang2}{stata "sysuse auto, clear":. sysuse auto, clear}{p_end}

{pstd}
Simple scatter

{phang2}{stata "scatter price mpg, sort ylabel(0(5000)20000) xlabel(0(10)50) scheme(scientific)":. scatter price mpg, sort ylabel(0(5000)20000) xlabel(0(10)50) scheme(scientific)}{p_end}

{pstd}
With {cmd:by}

{phang2}{stata "scatter price mpg, sort ylabel(0(5000)20000) xlabel(0(10)50) by(foreign) scheme(scientific)":. scatter price mpg, sort ylabel(0(5000)20000) xlabel(0(10)50) by(foreign) scheme(scientific)}{p_end}

{pstd}
A {cmd:twoway line} graph with a comparison group

{phang2}{cmd:. twoway (line mpg weight if foreign, sort)(line mpg weight if !foreign, sort), ylabel(0(10)50) xlabel(1000(1000)5000) legend(label(1 "Foreign") label(2 "Domestic")) scheme(scientific)}{p_end}
{phang2}({stata "scheme_scientific_ex 1":click to run}){p_end}

{pstd}
A {cmd:twoway connected} graph with multiple comparison groups

{p 8 17 2}{cmd:. twoway (connected mpg weight if rep78==2,sort)(connected mpg weight if rep78==3,sort)}{break}
				{cmd:(connected mpg weight if rep78==4,sort)(connected mpg weight if rep78==5,sort),}{break}
				{cmd:ylabel(10(10)50) xlabel(1500(1000)5500) legend(label(1 "rep78=2") label(2 "rep78=3")}{break}
				{cmd:label(3 "rep78=4") label(4 "rep78=5")) scheme(scientific)}{p_end}
{phang2}({stata "scheme_scientific_ex 2":click to run}){p_end}

{pstd}
A {cmd:bar} graph

{phang2}{stata "graph bar price weight length , over(foreign) scheme(scientific)":. graph bar price weight length , over(foreign) scheme(scientific)}{p_end}

{pstd}
A {cmd:box} plot

{phang2}{stata "graph box mpg, by(for) scheme(scientific)":. graph box mpg, by(for) scheme(scientific)}{p_end}
				
{pstd}
A stacked multiple comparison-group graph using {cmd: graph combined}	

{p 8 17 2}{cmd:. twoway (connected mpg weight if rep78==2,sort)( connected mpg weight if rep78==3,sort),}{break}
				{cmd:ylabel(10(10)50) legend(label(1 "rep78=2") label(2 "rep78=3"))}{break}
				{cmd:scheme(scientific) xscale(off) name(rep23, replace)}

{p 8 17 2}{cmd:. twoway (connected mpg weight if rep78==4,sort)( connected mpg weight if rep78==5,sort),}{break}
				{cmd:ylabel(10(10)50) xlabel(1500(1000)5500) legend(label(1 "rep78=4") label(2 "rep78=5"))}{break}
				{cmd:scheme(scientific) name(rep45,replace)}

{phang2}{cmd:. graph combine rep23 rep45,cols(1) imargin(b=1 t=1) scheme(scientific)}{p_end}
{phang2}({stata "scheme_scientific_ex 3":click to run}){p_end}

{pstd}
A survival plot

{phang2}{cmd:. webuse drugtr, clear}{p_end}
{phang2}{cmd:. stcox age drug}{p_end}
{phang2}{cmd:. stcurve, survival at1(drug=1) at2(drug=0) scheme(scientific)}{p_end}
{phang2}({stata "scheme_scientific_ex 4":click to run}){p_end}

{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{break}
{browse "http://www.lindenconsulting.org"}{p_end}



{title:Also see}
 
{p 4 13 2}
{bind:}Manual:  {hi:[G] schemes}, {hi:[G] {it:scheme_option}}, {hi:[G] set scheme}

{p 4 13 2}
Online:  help for {help schemes}, {it:{help scheme_option}}, {help set_scheme}, {help scheme_s2mono}
{p_end}
