{smcl}
{* 12feb2008/27apr2016}{...}
{hi:help spineplot}{right: ({browse "http://www.stata-journal.com/article.html?article=gr0031_1":SJ16-2: gr0031_1})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:spineplot} {hline 2}}Spineplots for two-way categorical data{p_end} 


{title:Syntax}

{p 8 17 2} 
{cmd:spineplot} 
{it:yvar} {it:xvar} 
{ifin}
{weight}
[{cmd:,}
{cmd:bar1(}{it:twoway_bar_options}{cmd:)} ... 
{cmd:bar20(}{it:twoway_bar_options}{cmd:)} 
{cmd:barall(}{it:twoway_bar_options}{cmd:)}
{cmdab:miss:ing}
{cmdab:perc:ent}
{cmd:text(}{it:textvar} [{cmd:,} {it:marker_label_options}]{cmd:)} 
{it:twoway_options}]

{p 4 4 2}
{cmd:fweight}s and {cmd:aweight}s may be specified; see {help weight}. 


{title:Description}

{p 4 4 2}
{cmd:spineplot} produces a spineplot for two-way categorical data.  The
fractional breakdown of the categories of the first-named variable
{it:yvar} is shown for each category of the second-named variable
{it:xvar}. Stacked bars are drawn with vertical extent showing
fraction in each {it:yvar} category given each {it:xvar} category and
horizontal extent showing fraction in {it:xvar} category. Thus the areas of
tiles formed represent the frequencies, or more generally totals, for each
cross-combination of {it:yvar} and {it:xvar}. 


{title:Options} 

{p 4 8 2} 
{cmd:bar1(}{it:twoway_bar_options}{cmd:)} ...
{cmd:bar20(}{it:twoway_bar_options}{cmd:)} allow specification of the
appearance of the bars for each category of {it:yvar} using options of
{helpb twoway bar}. 

{p 4 8 2}
{cmd:barall(}{it:twoway_bar_options}{cmd:)} allows specification of the
appearance of the bars for all categories of {it:yvar} using options of
{helpb twoway bar}. 

{p 4 8 2}
{cmd:missing} specifies that any missing values of either of the
variables specified should also be included within their own categories.
The default is to omit them. 

{p 4 8 2}
{cmd:percent} specifies labeling as percentages. The default is labeling as
fractions. 

{p 4 8 2}
{cmd:text(}{it:textvar} [{cmd:,} {it:marker_label_options}]{cmd:)}
specifies a variable to be shown as text at the center of 
each tile. {it:textvar} may be a numeric or string variable. It should
contain identical values for all observations in each
cross-combination of {it:yvar} and {it:xvar}. A simple example is the 
frequency of each cross-combination. To show nothing in 
particular tiles, use a variable with missing values (either numeric 
missing or empty strings) for those tiles. 
A numeric variable with fractional part will typically look best converted 
to string as, for example, {cmd:string(}{it:residual}{cmd:, "%4.3f")}. 
The user is responsible for choice of tile colors so that text is readable.
{cmd:text()} may also include 
{it:{help marker_label_options}} for tuning the display. 

{p 4 8 2}
{it:twoway_options} refers to options of {helpb twoway}.  By
default there are two x axes, {cmd:axis(1)} on top and {cmd:axis(2)} on
bottom, and two y axes, {cmd:axis(1)} on right and {cmd:axis(2)} on left. 


{title:Remarks} 

{p 4 4 2}
The name "spineplot" is credited to Hummel (1996). The term is gaining in
popularity but already appears to be differently understood.  In the strictest
definition, spineplots are one-dimensional, horizontal stacked bar charts, but
many discussions and implementations allow vertical subdivision (e.g., by
highlighting) into two or possibly more categories.  Some literature treats
spineplots, as understood here, under the heading of mosaic plots, variously
with and without also using the term spineplot. This Stata implementation under
the name {cmd:spineplot} thus implies a broad interpretation of the term.
Conversely, the implementation here does not purport to be a general mosaic
plot program. 

{p 4 4 2}Textbooks and monographs with examples of spineplots and
related plots include 
Schmid (1954), 
Cole (1959), 
Edwards (1972, 1992), 
Ehrenberg (1975), 
Lockwood (1979), 
Schmid and Schmid (1979), 
Altman (1991), 
Friendly (2000), 
Venables and Ripley (2002),
Gotelli and Ellison (2004, 2013), 
Robbins (2005, 2013), 
Unwin, Theus, and Hofmann (2006),
Young, Valero-Mora, and Friendly (2006), 
Cook and Swayne (2007), 
Unwin (2015) and 
Friendly and Meyer (2016).  
Among several papers, Hofmann's
(2000) discussion is clear, concise, and well illustrated. 

{p 4 4 2}
Mosaic plots have been reinvented several times under different names.
Hartigan and Kleiner (1981, 1984) introduced, or reintroduced, them into
mainstream statistics. Friendly (2002) cites earlier examples, including the
work of Georg von Mayr (1877), Karl G. Karsten (1923), Erwin J. Raisz
(1934) and Thomas W. Birch (1949).  
Hofmann (2007) discusses a mosaic by Francis A.  Walker (1874).  Other
early examples are those of Willard C. Brinton (1914, quoting earlier work; 1939),
Berend G. Escher (1924) and Hans Zeisel (1947, 1985). 

{p 4 4 2}
Most implementations of mosaic plots in other software omit axes and numerical
scales and convey a recursive subdivision according to what may be several
categorical variables by a hierarchy of gaps of various sizes. As the graphs
produced by {cmd:spineplot} are restricted to two variables, this Stata
implementation keeps axes and numerical scales as defaults.  The distinction
between categories is conveyed by bar boundaries rather than explicit gaps. 

{p 4 4 2}
A key principle behind any kind of mosaic plot is that a categorical
classification of independent variables would yield tiles that align
consistently. Thus departures from independence, or relationships between
variables, will be shown by failure of alignment. 

{p 4 4 2}
The restriction to two variables is more apparent than real.  Composite
variables may be created by cross-combination of two or more categorical
variables. The {helpb egen} functions {cmd:group()} and {cmd:axis()} may
be useful for this purpose. {cmd:axis()} is in the {cmd:egenmore}
package from the Statistical Software Components archive and must have been
installed previously. Compare also what Hofmann (2001) calls 
"double-decker plots" 
(for binary responses) and what Wilkinson (2005) calls 
"region trees". 

{p 4 4 2}
The program works by calculating cumulative frequencies. The plot is then
produced by overlaying distinct graphs, each being a call to 
{cmd:twoway bar, bartype(spanning)} for one category of {it:yvar}. By
default, each bar is shown with {cmd:blcolor(bg) blw(medium)}, which
should be sufficient to outline each bar distinctly but delicately.  By
default also, the categories of {it:yvar} will be distinguished
according to the graph scheme you are using.  With the default
{cmd:s2color} scheme, the effect is reminiscent of canned fruit salad
(which may be fine for exploratory work).  For a publishable graph, you
might want to use something more subdued, such as various gray
scales or different intensities. 

{p 4 4 2} 
Options {cmd:bar1()} to {cmd:bar20()} are provided to allow overriding
the defaults on up to 20 categories, the first, second, etc., shown.
The limit of 20 is plucked out of the air as more than any user should
really want. The option {cmd:barall()} is available to override the
defaults for all bars. Any {cmd:bar}{it:#}{cmd:()} option always overrides
{cmd:barall()}. Thus, if you wanted thicker {cmd:blwidth()} on all bars,
you could specify {cmd:barall(blwidth(thick))}. If you wanted to
highlight the first category only, you could specify
{cmd:bar1(blwidth(thick))} or a particular color. 

{p 4 4 2} 
Other defaults include {cmd:legend(col(1) pos(3))}.  At least with
{cmd:s2color}, a legend on the right implies an approximately square plot
region, which can look quite good. A legend is supplied partly because 
there is no guarantee that all {it:yvar} categories will be represented
for extreme categories of {it:xvar}. However, it will often be possible 
and tasteful to omit the legend and show categories as axis label text. 
An example is given below. 

{p 4 4 2}
Note the possibility of using {cmd:plotregion(margin(zero))} to 
place axes alongside the plot region. 

{p 4 4 2}
As with scatterplots, a response variable is usually better shown on
the {it:y} axis.  If one variable is binary, it is often better to plot that
on the {it:y} axis. Naturally, there can be some tension between these 
suggestions. 
For example, in the auto data, {cmd:foreign} is arguably a predictor 
of {cmd:rep78} rather than vice versa, but I suggest that 
{cmd:spineplot foreign rep78} is more congenial than 
{cmd:spineplot rep78 foreign}. 

{p 4 4 2}
You may need to experiment with different sort orders 
for the categorical variables. {cmd:egen, axis()} may 
be useful here. 

{p 4 4 2}
The {it:x} axis labels on the bottom axis ({cmd:axis(2)}) are placed
below the middle of each column. As a convenience to users wishing to 
override the defaults, the specification is saved as {cmd:r(catlabels)},
so that the command may be repeated with revised positions and/or text. 
Type {cmd:return list} to see the specification. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto}{p_end}
{p 4 8 2}{cmd:. spineplot foreign rep78}{p_end}
{p 4 8 2}{cmd:. spineplot foreign rep78, xti(frequency, axis(1)) xla(0(10)60, axis(1)) xmti(1/69, axis(1))}{p_end}
{p 4 8 2}{cmd:. spineplot rep78 foreign}

{p 4 8 2}{cmd:. set scheme s1color}{p_end}
{p 4 8 2}{cmd:. bysort foreign rep78: gen freq = _N}{p_end}
{p 4 8 2}{cmd:. spineplot foreign rep78, text(freq, mlabsize(*1.4)) bar1(color(gs14)) bar2(color(gs10))}{p_end}
{p 4 8 2}{cmd:. spineplot foreign rep78, text(freq, mlabsize(*1.4)) bar1(color(gs14)) bar2(color(gs10)) legend(off) yla(0.1 "Domestic" 0.9 "Foreign", noticks axis(1))}{p_end}


{title:References}

{p 4 8 2}
Altman, D. G. 1991. 
{it:Practical Statistics for Medical Research.} 
London: Chapman & Hall. 

{p 4 8 2}
Anderson, M. J. 2001. 
Francis Amasa Walker. 
In {it:Statisticians of the Centuries}, ed. C. C. Heyde and E. Seneta,
216-218. New York: Springer.

{p 4 8 2}
Anonymous. 1967. 
In memoriam: Prof. Dr. B. G. Escher. 
{it:Geologie en Mijnbouw} 46: 417-422.

{p 4 8 2}
Birch, T. W. 1949. 
{it:Maps: Topographical and Statistical.} 
London: Oxford University Press. 
 
{p 4 8 2}
Brinton, W. C. 1914. 
{it:Graphic Methods for Presenting Facts}.
New York: Engineering Magazine Company. 

{p 4 8 2}
Brinton, W. C. 1939. 
{it:Graphic Presentation.} 
New York: Brinton Associates. 
{browse "http://www.archive.org/stream/graphicpresentat00brinrich":http://www.archive.org/stream/graphicpresentat00brinrich} 

{p 4 8 2}
Cole, J. P. 1959. 
{it:Geography of World Affairs.} 
Harmondsworth: Penguin. 

{p 4 8 2}
Cook, D. and D. F. Swayne. 2007. 
{it:Interactive and Dynamic Graphics for Data Analysis: With R and GGobi}.
New York: Springer. 

{p 4 8 2}
Edwards, A. W. F. 1972, revised 1992. 
{it:Likelihood: An Account of the Statistical Concept of Likelihood and its Application to Statistical Inference.}
London: Cambridge University Press; Baltimore: Johns Hopkins University Press. 
{* NJC confirms London as place of first publication} 

{p 4 8 2} 
Ehrenberg, A. S. C. 1975. 
{it:Data Reduction: Analysing and Interpreting Statistical Data.}
London: John Wiley. 
{* NJC confirms London as place of first publication} 

{p 4 8 2}
Escher, B. G. 1924. 
{it:De Methodes der Grafische Voorstelling}.
Amsterdam: Wereldbibliotheek.

{p 4 8 2}
Escher, B. G. 1934. 
{it:De Methodes der Grafische Voorstelling}. 2nd ed.
Amsterdam: Wereldbibliotheek.

{p 4 8 2}
Friendly, M. 2000.  
{it:Visualizing Categorical Data}.
Cary, NC: SAS Institute. 

{p 4 8 2} 
Friendly, M. 2002. 
A brief history of the mosaic display.  
{it:Journal of Computational and Graphical Statistics} 
11: 89{c -}107. 

{p 4 8 2}
Friendly, M. and D. Meyer. 2016. 
{it:Discrete Data Analysis with R: Visualization and Modeling Techniques for Categorical and Count Data.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}
Gotelli, N. J. and A. M. Ellison. 2004 (2nd edition 2013). 
{it:A Primer of Ecological Statistics.} 
Sunderland, MA: Sinauer. 

{p 4 8 2}
Hartigan, J. A. and B. Kleiner. 1981. 
Mosaics for contingency tables. 
In {it:Computer Science and Statistics: Proceedings of the 13th Symposium}
{it:on the Interface}, ed. W. F. Eddy, 268-273.  New York: Springer.

{p 4 8 2}
Hartigan, J. A. and B. Kleiner. 1984. 
A mosaic of television ratings. 
{it:American Statistician} 38: 32-35. 

{p 4 8 2}
Hertz, S. 2001. 
Georg von Mayr.
In {it:Statisticians of the Centuries}, ed. C. C. Heyde and E. Seneta,
219-222. New York: Springer.

{p 4 8 2}
Hofmann, H. 2000. 
Exploring categorical data: Interactive mosaic plots. 
{it:Metrika} 51: 11-26. 

{p 4 8 2}
Hofmann, H. 2001. 
Generalized odds ratios for visual modeling. 
{it:Journal of Computational and Graphical Statistics} 10: 628-640. 

{p 4 8 2}
Hofmann, H. 2007. 
Interview with a centennial chart. 
{it:Chance} 20(2): 26-35. 

{p 4 8 2} 
Hummel, J. 1996.
Linked bar charts: Analyzing categorical data graphically.
{it:Computational Statistics} 11: 23-33.

{p 4 8 2}
Karsten, K. G. 1923. 
{it:Charts and Graphs: An Introduction to Graphic Methods in the Control and Analysis of Statistics.} 
New York: Prentice-Hall.

{p 4 8 2}
Lockwood, A. 1969. 
{it:Diagrams: A Visual Survey of Graphs, Maps, Charts and Diagrams for the Graphic Designer.}
London: Studio Vista.

{p 4 8 2}
Raisz, E. J. 1934. 
The rectangular statistical cartogram. 
{it:Geographical Review} 24: 292-296. 

{p 4 8 2}
Robbins, N. B. 2005 (reissued 2013). 
{it:Creating More Effective Graphs}.
Hoboken, NJ: Wiley; Wayne, NJ: Chart House. 

{p 4 8 2}
Robinson, A. H. 1970. 
Erwin Josephus Raisz, 1893-1968. 
{it:Annals of the Association of American Geographers} 60: 189-193. 

{p 4 8 2}
Schmid, C. F. 1954. 
{it:Handbook of Graphic Presentation.} 
New York: Ronald Press. 

{p 4 8 2}
Schmid, C. F. and Schmid, S. E. 1979. 
{it:Handbook of Graphic Presentation.}
New York: John Wiley.

{p 4 8 2}
Sills, D. L. 1992.  
In Memoriam: Hans Zeisel, 1905-1992.  
{it:Public Opinion Quarterly} 56: 536-537. 

{p 4 8 2}
Unwin, A. 2015. 
{it:Graphical Data Analysis with R.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}
Unwin, A., M. Theus, and H. Hofmann. 2006.  
{it:Graphics of Large Datasets: Visualizing a Million}.
New York: Springer. 

{p 4 8 2}
Venables, W. N. and B. D. Ripley. 2002. 
{it:Modern Applied Statistics with S}.
New York: Springer. 

{p 4 8 2}
von Mayr, G. 1877. 
{it:Die Gesetzm{c a:}ssigkeit im Gesellschaftsleben}.
M{c u:}nchen: Oldenbourg. 

{p 4 8 2}
Walker, F. A. 1874.
{it:Statistical Atlas of the United States Based on the Results of the Ninth Census 1870.}
New York: Census Office. 

{p 4 8 2}
Wilkinson, L. 2005. 
{it:The Grammar of Graphics.} 2nd ed.
New York: Springer. 

{p 4 8 2}
Young, F. W., P. M. Valero-Mora, and M. Friendly. 2006.
{it:Visual Statistics: Seeing Data with Dynamic Interactive Graphics}.
Hoboken, NJ: Wiley. 

{p 4 8 2} 
Zeisel, H. 1947. 
{it:Say It with Figures}.
New York: Harper.  

{p 4 8 2} 
Zeisel, H. 1985. 
{it:Say It with Figures}. 6th ed.
New York: Harper & Row.


{title:Stored results} 

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(catlabels)}}specification of x axis labels, axis 2{p_end}
{p2colreset}{...}


{title:Acknowledgments} 

{p 4 4 2}
Matthias Schonlau, Scott Merryman, and Maarten Buis provoked the writing of this
program through challenging Statalist postings, which reawakened a
long-standing thought that someone, perhaps me, should implement spineplots in
Stata. A suggestion from Peter Jepsen led to the {cmd:text()} option. Private
emails from Matthias Schonlau and Antony Unwin highlighted different senses of
spineplots and the importance of sort order. Antony suggested standardizing on
"spineplot" rather than "spine plot". Maarten verified for me that the
spineplot in my copy of Escher (1934) also appears in Escher (1924).  Vince
Wiggins originally told me about the undocumented {cmd:bartype(spanning)}
option. 

{p 4 4 2}
Dimitriy V. Masterov prompted revision in 2016 to improve handling of {it:x} axis labels. 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break} 
n.j.cox@durham.ac.uk

	 
{title:Also see}

{psee}
Article: {it:Stata Journal}, volume 8, number 1: {browse "http://www.stata-journal.com/article.html?article=gr0031":gr0031}{break}

{psee}
Online:  {manhelp histogram R}, 
{helpb catplot} (if installed), 
{helpb tabplot} (if installed), 
{helpb egenmore} (if installed), 
{helpb vreverse} (if installed) 
{p_end}
