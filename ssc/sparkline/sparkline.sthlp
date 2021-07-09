{smcl}
{* 21jan2013/19feb2013/22mar2013/24mar2013}{...}
{hline}
help for {hi:sparkline}
{hline}

{title:Sparkline-type plots}

{p 8 12 2} 
{cmd:sparkline} 
{it:yvarlist xvar} 
{ifin}
[
{cmd:,}
{cmdab:vert:ical} 
{cmd:by(}{it:varname} [{cmd:,} {it:byopts}]{cmd:)} 
{cmdab:h:eight(}{it:#}{cmd:)} 
{cmdab:lim:its(}{it:min max}{cmd:)} 
{cmdab:f:ormat(}{it:fmt}{cmd:)}              
{cmdab:ext:remes}[{cmd:(}{it:scatter_options}{cmd:)}] 
{cmd:extremeslabel}[{cmd:(}{it:marker_label_options}{cmd:)}] 
{cmd:flipy}
{cmd:variablelabels}
{it:line_options}
] 


{p 8 12 2} 
{cmd:sparkline} 
{it:yvar xvar} 
{ifin}
[
{cmd:,}
{cmdab:vert:ical} 
{cmd:over(}{it:varname}{cmd:)}  
{cmd:by(}{it:varname} [{cmd:,} {it:byopts}]{cmd:)} 
{cmdab:h:eight(}{it:#}{cmd:)} 
{cmdab:lim:its(}{it:min max}{cmd:)} 
{cmdab:f:ormat(}{it:fmt}{cmd:)}              
{cmdab:ext:remes}[{cmd:(}{it:scatter_options}{cmd:)}] 
{cmd:extremeslabel}[{cmd:(}{it:marker_label_options}{cmd:)}] 
{cmd:flipy}
{cmd:variablelabels}
{it:line_options}
]


{title:Description}

{p 4 4 2}{cmd:sparkline} graphs sparkline-type plots for one or more y
variables against a single x variable. Typically, plots for different y
variables or for different subsets of one y variable are stacked
vertically into one image.  Commonly, but not necessarily, such plots
are multiple time series, so that the x variable is a time variable.


{title:Slogans}

{p 4 8 2}Graphics can be shrunk way down.
{break}{space 40}E.R. Tufte (1983/2001, p.169) 

{p 4 8 2}Wider-than-tall shapes usually make it easier for the eye to
follow from left to right.
{break}{space 40}J.W. Tukey (1977, p.129)


{title:Remarks}

{p 4 4 2}{cmd:sparkline} takes its name from the discussion in Tufte
(2006, pp.44{c -}63). Sparklines are typically simple in design, sparing
of space and rich in data, but they include several quite different
kinds of graph otherwise. The most common kind of example, however,
shows several wider-than-tall time series stacked vertically. By any
reasonably broad definition, sparklines have long been standard in
several fields, including climatology, ecology (e.g. pollen diagrams), 
archaeology, seismology, and physiology (notably encephalography and cardiography).
Tufte provided an memorable and evocative new name and an excellent
provocative discussion. 

{p 4 4 2}{cmd:sparkline} is intended to support certain line plots and
related graphs presented in a sparkline style.  The implementation is
indicative, not definitive. It is not the intention that {cmd:sparkline}
provides Stata support for every kind of graph discussed elsewhere under
this heading. Conversely, {cmd:sparkline} supports some kinds of graphs
that might not be considered sparklines in Tufte's sense. 

{p 4 4 2}There are two leading situations in which {cmd:sparkline} may
be useful. In both there is a single x variable. As mentioned, x is
commonly but not necessarily a time variable. 

{p 8 8 2}One y variable and a subdivision by a third variable into
subsets (e.g. panel data). The subdivision is usually indicated to
{cmd:sparkline} by the {cmd:over()} option. 
 
{p 8 8 2}Two or more y variables. 

{p 4 4 2}In both situations, {cmd:sparkline}'s default is that subsets 
or variables are plotted separately and stacked vertically.  
Values are scaled to (value - minimum) / (maximum - minimum) so that 
they lie in [0,1] and each subset or variable is assigned the same 
vertical space. Axis labelling is,
however, in terms of the observed or optionally specified minimum and maximum. 

{p 4 4 2}Know that {it:multiple} subsets or variables on the y axis are
plotted centred on y = 1, 2, 3, etc. Otherwise data are plotted as
supplied. 

{p 4 4 2}With the {cmd:vertical} option, the single x variable is plotted
vertically and the other subsets or variables are plotted separately and stacked
horizontally. This variant is motivated by many graphs in archaeology and the Earth and 
environmental sciences, in which depth below or height above a land or 
water surface is plotted on the vertical axis. If the x variable is a depth, 
{cmd:ysc(reverse)} will also be appropriate. For more comments on such graphs 
in Stata, see Cox and Barlow (2008). 
 
{p 4 4 2}Note that it is not an error to specify a single variable y
without the {cmd:over()} option. The plot so produced would have the
same style as other plots produced by {cmd:sparkline} but contain only a
single set of values. More usefully, subplots could be produced by also
using the {cmd:by()} option. Note that specifying {cmd:by()} does not
itself trigger scaling to [0,1]. 

{p 4 4 2}Some sparkline displays show elaborate mixes of text and
graphical displays and would require more complex Stata code or more
work integrating text and graphics than is supported here. The Examples
indicate that previously prepared value labels may be used to carry
further text. The same device could be used with variable labels. See
also Cox (2008, 2009). 

{p 4 4 2}For other broadly similar plots (see also Tufte's references
and the page cited below on his website) 

{p 8 8 2}various historical charts, surveyed by Rosenberg and Grafton (2010), 
including Joseph Priestley's chart from 1765 

{p 8 8 2}plots of lines and bands in a spectrum, a staple of 19th and 20th 
century spectroscopy (Hentschel 2002 gives a very detailed scholarly 
account) 

{p 8 8 2}Marey (1878, 1895) 

{p 8 8 2}Brinton (1914, pp.114, 122, 123, 145) and Karsten (1923, p.297) 

{p 8 8 2}climatology examples: Shaw (1926) (as curve-parallels), Shaw (1933) 
and Lamb (1972) 

{p 8 8 2}Bertin (1981, 1983)

{p 8 8 2}aligned bar charts, multi-pane bar and line charts: Mackinlay (1986), 
McDaniel and McDaniel (2012a, 2012b)  

{p 8 8 2}survey plots: Lohninger (1994, 1996), Hoffman and Grinstein (2002,
p.57) and Grinstein et al. (2002, pp.143, 152, 155, 158, 162, 163, 166)

{p 8 8 2}table lens: Rao and Card (1994), Pirolli and Rao (1996), Spence (2007), Few (2012)   

{p 8 8 2}multiline graphs: Hoffman and Grinstein (2002, p.52)

{p 8 8 2}Robbins (2005, pp.173, 186, 272) 


{title:Options} 

{p 4 8 2}{cmd:vertical} specifies that the x variable (the last-named) 
be plotted on the vertical axis, so that the other variables are plotted
on the horizontal axis. See Remarks above. 

{p 4 8 2}{cmd:over()} indicates a third variable (e.g. a panel
identifier) to subdivide data. This option may only be used when there
is a single y variable. 

{p 4 8 2}{cmd:by()} is the usual {help by_option} provided for
completeness. Typically it is less useful than the {cmd:over()} option
for producing sparklines, but it may be combined with two or more y
variables. See Remarks above and Examples below. 

{p 4 8 2}{cmd:height()} specifies the height of each vertical zone 
(or with {cmd:vertical} the width of each horizontal zone) 
within which each of the multiple variables or subsets is shown. The
default is 0.7, so that each series takes up 70% of the available space. 

{p 4 8 2}{cmd:limits()} specifies minimum and maximum to use in scaling
all subsets or variables. The default is to use the observed minimum and
maximum in each case. Typically this option is useful when values are
broadly similar in each case and it is desired to specify exactly
similar vertical scales or just to ensure that axis labels are simple.
Placement of labels can be based on knowing that series are centred at y
= 1, 2, 3, ... and that minimum and maximum are plotted at half the
height above and half the height below those levels. See also
{cmd:height()} option above. 

{p 8 8 2}Note that it is not possible to specify a different minimum and
minimum for  different subsets or variables. Note also that there is no
check on whether the specified minimum and maximum are exceeded by any
of the data. The latter imparts both some risk (of overlapping series)
and some flexibility. 

{p 4 8 2}{cmd:format()} specifies a numeric format controlling the
display of axis labels showing the maximum and minimum of each series.
The default is the display format of the first y variable specified. See
help for {help format}. 

{p 4 8 2}{cmd:extremes} specifies that the minimum and maximum of each
subset or variable be flagged by marker symbols. The default symbol is
O. {it:scatter_options} may be specified to tune the display. See help
for {help scatter}. 

{p 4 8 2}{cmd:extremeslabel} specifies that the minimum and maximum of
each subset or variable be shown as marker labels. By default minima are
shown at clock position 4 and maxima at clock position 10.
{it:marker_label_options} may be specified to tune the display. See help
for {help marker_label_options}. That said, fine tuning with the Graph
Editor may also be desired if this option is found useful. 

{p 4 8 2}{cmd:flipy} specifies that what is shown on the left-hand y
axis (axis 1) be shown on the right-hand axis (axis 2), and vice versa. 
With {cmd:vertical}, this option flips top and bottom x axes. 

{p 4 8 2}{cmd:variablelabels} specifies that variable labels be shown to
describe two or more y variables. The default is to use variable names. 

{p 4 8 2}{it:line_options} are options of {help line}. 


{title:Examples}

{p 4 8 2}{cmd:. set scheme s1color}

{p 4 8 2}{cmd:. webuse grunfeld, clear}{p_end}
{p 4 8 2}{cmd:. sparkline invest mvalue kstock year if company == 1}{p_end}
{p 4 8 2}{cmd:. sparkline invest year, over(company)}{p_end}
{p 4 8 2}{cmd:. sparkline invest year, over(company) extremes}

{p 4 8 2}{cmd:. sparkline invest year, by(company) extremes}{p_end}
{p 4 8 2}{cmd:. sparkline invest year, by(company, col(2) compact) subtitle(, pos(9) ring(1) nobexpand bcolor(none) placement(e)) extremes ysc(log)}{p_end}
{p 4 8 2}{cmd:. sparkline invest mvalue kstock year, by(company) xtitle("") extremes}{p_end}
{p 4 8 2}{cmd:. sparkline invest mvalue kstock year, by(company, note("")) xtitle("") extremes extremeslabel ysc(r(0.3 3.7))}

{p 4 8 2}{cmd:. bysort company (year) : gen clabel= string(invest[_N], "%9.0g") + "  " + string(company)}{p_end}
{p 4 8 2}{cmd:. * for labmask: net describe gr0034, from(http://www.stata-journal.com/software/sj8-2)}{p_end}
{p 4 8 2}{cmd:. labmask company, values(clabel)}{p_end}
{p 4 8 2}{cmd:. sparkline invest year, over(company) flipy xtick(1935/1954) xla(1935(5)1950 1954, tlength(*1.6)) extremes}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. gen gpm = 1/mpg}{p_end}
{p 4 8 2}{cmd:. sort rep78 gpm weight}{p_end}
{p 4 8 2}{cmd:. gen observation = _n}{p_end}
{p 4 8 2}{cmd:. sparkline rep78 gpm weight observation, recast(scatter) xla(1 10(10)70 74)}

{p 4 8 2}{cmd:. * iris data in Stata 11 up}{p_end}
{p 4 8 2}{cmd:. webuse iris, clear}{p_end}
{p 4 8 2}{cmd:. pca sep* pet*}{p_end}
{p 4 8 2}{cmd:. predict PC1}{p_end}
{p 4 8 2}{cmd:. sparkline sep* pet* PC1, recast(scatter) variablelabels format(%3.1f)}{p_end}
{p 4 8 2}{cmd:. sparkline sep* pet* PC1, recast(scatter)}
{cmd:yla(1 "sepal length" 2 "sepal width" 3 "petal length" 4 "petal width", axis(2)) subtitle(all measurements in cm, place(w) size(*0.8)) format(%3.1f) yli(1.5 2.5 3.5, lstyle(grid)) flipy}

{p 4 8 2}{cmd:. * stocks data in Stata 12 up}{p_end}
{p 4 8 2}{cmd:. webuse stocks, clear}{p_end}
{p 4 8 2}{cmd:. sparkline toyota nissan honda t}{p_end}
{p 4 8 2}{cmd:. sparkline toyota nissan honda t, limits(-0.2 0.2)}{p_end}
{p 4 8 2}{cmd:. sparkline toyota nissan honda t, limits(-0.2 0.2) height(0.8) yla(0.6 "-0.2" 1 "0" 1.4 "0.2" 1.6 "-0.2" 2 "0" 2.4 "0.2" 2.6 "-0.2" 3 "0" 3.4 "0.2", axis(2) labgap(*1) ticks) yli(1.5 2.5, lstyle(grid))}

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input levels freqcores freqblanks freqtools}{p_end}
{p 4 8 2}{cmd:.     25 21 32 70}{p_end}
{p 4 8 2}{cmd:.     24 36 52 115}{p_end}
{p 4 8 2}{cmd:.     23 126 650 549}{p_end}
{p 4 8 2}{cmd:.     22 159 2342 1633}{p_end}
{p 4 8 2}{cmd:.     21 75 487 511}{p_end}
{p 4 8 2}{cmd:.     20 176 1090 912}{p_end}
{p 4 8 2}{cmd:.     19 132 713 578}{p_end}
{p 4 8 2}{cmd:.     18 46 374 266}{p_end}
{p 4 8 2}{cmd:.     17 550 6182 1541}{p_end}
{p 4 8 2}{cmd:.     16 76 846 349}{p_end}
{p 4 8 2}{cmd:.     15 17 182 51}{p_end}
{p 4 8 2}{cmd:.     14 4 51 14}{p_end}
{p 4 8 2}{cmd:.     13 29 228 130}{p_end}
{p 4 8 2}{cmd:.     12 135 2227 729}{p_end}
{p 4 8 2}{cmd:. end}

{p 4 8 2}{cmd:. foreach k in cores blanks tools {c -(}}{p_end}
{p 4 8 2}{cmd:. {space 4}gen `k' = 100 * freq`k' / (freqcores + freqblanks + freqtools)}{p_end}
{p 4 8 2}{cmd:. {c )-}}

{p 4 8 2}{cmd:. sparkline cores blanks tools levels, yaxis(1 2) vertical ysc(reverse) yla(12/25, axis(1) nogrid) format(%2.1f)}
{cmd:recast(connected) ms(Oh Dh Th) plotregion(color(gs13)) xli(1.5 2.5, lw(*2)  lstyle(grid)) yla(12/25, nogrid ang(h) axis(2)) flipy}{p_end}


{title:Author} 

{p 4 4 2}Nicholas J. Cox{break} 
         Durham University{break} 
	 n.j.cox@durham.ac.uk 


{title:Acknowledgments} 

{p 4 4 2}
Ariel Linden and Vince Wiggins provided encouragement. 
Christopher Baum made helpful comments on the examples. 
Jeff Warburton encouraged implementation of the {cmd:vertical} option. 
Scott Merryman signalled problems with string variables in {cmd:over()}. 


{title:References} 

{p 4 8 2}Bertin, J. 1981. 
{it:Graphics and graphic information processing.} 
Berlin: Walter de Gruyter. 

{p 4 8 2}Bertin, J. 1983/2011. 
{it:Semiology of graphics.} 
Madison: University of Wisconsin Press; Redlands, CA: Esri Press. 

{p 4 8 2}Brinton, W.C. 1914. 
{it:Graphic methods for presenting facts.} 
New York: Engineering Magazine Company. 

{p 4 8 2}Cox, N.J. 2008. 
Speaking Stata: Between tables and graphs. 
{it:Stata Journal} 8: 269{c -}289. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0034":http://www.stata-journal.com/sjpdf.html?articlenum=gr0034}

{p 4 8 2}Cox, N.J. 2009.
Speaking Stata: Paired, parallel, or profile plots for changes,
correlations, and other comparisons. 
{it:Stata Journal} 9: 621{c -}639. 
{browse "http://www.stata-journal.com/article.html?article=gr0041":http://www.stata-journal.com/article.html?article=gr0041}

{p 4 8 2}
Cox, N.J. and Barlow, N.L.M. 2008. 
Stata tip 62: Plotting on reversed scales. 
{it:Stata Journal} 8: 295{c -}298. 
{browse "http://www.stata-journal.com/article.html?article=gr0035":http://www.stata-journal.com/article.html?article=gr0035}

{p 4 8 2}Few, S. 2012. 
{it:Show me the numbers: Designing tables and graphs to enlighten.} 
Burlingame, CA: Analytics Press. 

{p 4 8 2}
Grinstein, G.G., Hoffman, P.E., Pickett, R.M. and Laskowski, S.J. 
2002. 
Benchmark development for the evaluation of visualization for data mining. 
In Fayyad, U., Grinstein, G.G. and Wierse, A. (Eds). 
{it:Information visualization in data mining and knowledge discovery.} 
San Francisco: Morgan Kaufmann, 129{c -}176. 

{p 4 8 2}Hentschel, K. 2002. 
{it:Mapping the spectrum: Techniques of visual representation in research and teaching.} 
Oxford: Oxford University Press. 

{p 4 8 2}Hoffman, P.E. and Grinstein, G.G. 2002. 
A survey of visualizations for high-dimensional data mining. 
In Fayyad, U., Grinstein, G.G. and Wierse, A. (Eds). 
{it:Information visualization in data mining and knowledge discovery.} 
San Francisco: Morgan Kaufmann, 47{c -}82. 

{p 4 8 2}
Karsten, K.G. 1923. 
{it:Charts and graphs: An introduction to graphic methods in the control and analysis of statistics.} 
New York: Prentice-Hall. 

{p 4 8 2}Lamb, H.H. 1972. 
{it:Climate: present, past and future. Volume 1: Fundamentals and climate now.} 
London: Methuen. 

{p 4 8 2}Lohninger, H. 1994. 
INSPECT: A program system to visualize and interpret chemical data.
{it:Chemometrics and Intelligent Laboratory Systems}
22: 147{c -}153.

{p 4 8 2}
Lohninger, H. 1996. 
{it:INSPECT: A program system for scientific and engineering data analysis: HANDBOOK with 2 diskettes.}
Berlin: Springer.

{p 4 8 2}Mackinlay, J.D. 1986. 
Automating the design of graphical presentations of relational information. 
{it:ACM Transactions on Graphics} 
5: 111{c -}141. 

{p 4 8 2}Marey, E.J. 1878. 
{it:La m{c e'}thode graphique dans les sciences exp{c e'}rimentales et principalement en physiologie et en m{c e'}decine.} 
Paris: G. Masson.  

{p 4 8 2}Marey, E.J. 1895. 
{it:Movement.} 
London: William Heinemann. 

{p 4 8 2}McDaniel, E. and McDaniel, S. 2012a. 
{it:The accidental analyst: Show your data who's boss.}
Seattle, WA: Freakalytics.

{p 4 8 2}McDaniel, S. and McDaniel, E. 2012b. 
{it:Rapid graphs with Tableau 7: Create intuitive, actionable insights in just 15 days.}
Seattle, WA: Freakalytics.

{p 4 8 2}
Pirolli, P. and Rao, R. 1996. 
Table lens as a tool for making sense of data.
In Catarci, T., Costabilem, M.F., Levialdi, S. and Santucci, G. (Eds) 
{it:Workshop on Advanced Visual Interfaces: AVI-96.}
New York: Association for Computing Machinery, 67{c -}80.  

{p 4 8 2}
Rao, R. and Card, S.K. 1994.
The table lens: merging graphical and symbolic representations in an interactive focus+context visualization for tabular information. 
{it:Proceedings of CHI '94, ACM Conference on Human Factors in Computing Systems}
New York: Association for Computing Machinery, 318{c -}322 and 481{c -}482.  

{p 4 8 2}
Robbins, N.B. 2005.
{it:Creating more effective graphs.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}
Rosenberg, D. and Grafton, A. 2010.
{it:Cartographies of time.}
New York: Princeton Architectural Press. 

{p 4 8 2}
Shaw, N. 1926. 
{it:Manual of meteorology. Volume I: Meteorology in history.} 
London: Cambridge University Press. 

{p 4 8 2}
Shaw, N. 1933/1939. 
{it:The drama of weather.} 
London: Cambridge University Press. 

{p 4 8 2}
Spence, R. 2007. 
{it:Information visualization: Design for interaction.} 
Harlow, Essex: Pearson Education. 

{p 4 8 2}Tufte, E.R. 1983, 2nd edition 2001. 
{it:The visual display of quantitative information.} Cheshire, CT: 
Graphics Press. 

{p 4 8 2}Tufte, E.R. 2006. {it:Beautiful evidence.} Cheshire, CT:
Graphics Press. 

{p 4 8 2}Sparkline theory and practice. 
{browse "http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0001OR":http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0001OR}
(accessed 15 January 2013) 

{p 4 8 2}Tukey, J.W. 1977. 
{it:Exploratory data analysis.} Reading, MA: Addison-Wesley. 


{title:Also see}

{p 4 13 2}Online: 
{help line}, 
{help tsline}, 
{help xtline}, 
{help dotplot}, 
{help stripplot} (if installed), 
{help tabplot} (if installed) 

