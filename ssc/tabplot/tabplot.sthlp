{smcl}
{* 27oct2004/26sep2005/22jan2007/7jul2009/24jul2009/25nov2009/30nov2009/10dec2009/14jun2010/14dec2010/1mar2011/11oct2011/16nov2011/9may2012/6jun2012/14aug2012/19oct2012}{...}
{* 21feb2013/16jul2013/28aug2013/30dec2013/2may2015/25may2015/9jul2015/26aug2015/29sep2015/15oct2015/18dec2015/27apr2016/26aug2016/14sep2016/17oct2016/21dec2016}{...}
{* 9jan2017/5feb2017/12feb2017/28mar2017/13apr2017/24may2017/9jun2017/30jun2017/12jul2017/28sep2017/16oct2017/20nov2017/4dec2017/18dec2017/12feb2018/12may2018/4jun2018/30jan2019/22feb2019/23apr2019/19may2019}{...}
{* 3jul2019/12jul2019}{...}
{hi:help tabplot}{right: ({browse "http://www.stata-journal.com/article.html?article=up0056":SJ17-3:gr0066_1})}
{hline}

{title:Title}

{phang}{hi:tabplot} {hline 2} One-, two-, and three-way bar charts for tables


{title:Syntax}

{p 4 8 2} 
{cmd:tabplot}
{it:{help varname}}
{ifin}
[{it:weight}]
[{cmd:,} {it:options}] 

{p 4 8 2} 
{cmd:tabplot}
{it:rowvar}
{it:colvar}
{ifin}
[{it:weight}]
[{cmd:,} {it:options}] 

{p 4 4 2}{cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s may be specified;
see {help weight}.

{p 4 8 2}{it:options} specify 

{p 4 8 2}- whether bars show fractions, percents, or missing categories 

{p 8 8 2}
[ {cmdab:fr:action} {c |} {cmdab:fr:action(}{it:varlist}{cmd:)} {c |} {cmdab:perc:ent} {c |} {cmdab:perc:ent(}{it:varlist}{cmd:)} 
] 
{p_end} 
{p 8 8 2}{cmdab:miss:ing}

{p 4 8 2}- whether y and x values are literal (default: map to integers 1 up)

{p 8 8 2}{cmd:yasis xasis}

{p 4 8 2}- whether y and x values are reversed (default: not) 

{p 8 8 2}{cmdab:yrev:erse} {cmdab:xrev:erse}

{p 4 8 2}- horizontal bars (default vertical) 

{p 8 8 2}{cmdab:hor:izontal} 

{p 4 8 2}- maximum bar height (lengths if horizontal) (default 0.8) 

{p 8 8 2}{cmdab:h:eight(}{it:#}{cmd:)} 

{p 4 8 2}- showing numeric values below or beside bars 

{p 8 8 2}{cmdab:show:val}[{cmd:(}{it:specification}{cmd:)}] 

{p 4 8 2}- that bars are to be framed 

{p 8 8 2}{cmd:frame(}{it:#}{cmd:)} {cmd:frameopts(}{it:frame_options}{cmd:)} 

{p 4 8 2}- more specialized variants 

{p 8 8 2}
{cmdab:min:imum(}{it:#}{cmd:)} 
{cmdab:max:imum(}{it:#}{cmd:)} 
{cmdab:sep:arate(}{it:sepspec}{cmd:)} 

{p 4 8 2}- different displays for individual bars 

{p 8 8 2}{cmd:bar1(}{it:rbar_options}{cmd:)} 
...
{cmd:bar20(}{it:rbar_options}{cmd:)} 
{cmd:barall(}{it:rbar_options}{cmd:)} 

{p 4 8 2}- other graph details 

{p 8 8 2} 
{it:graph_options}
[ {cmd:plot(}{it:plot}{cmd:)} {c |}
{cmd:addplot(}{it:plot}{cmd:)} ]


{title:Description} 

{p 4 4 2}{cmd:tabplot} plots a table of numerical values 
(for example, frequencies, fractions, or percents) in graphical form as a bar
chart.  It is mainly intended for representing contingency tables for one,
two, or three categorical variables.  It also has uses for producing multiple
histograms and graphs for general one-, two-, or three-way tables.

{p 4 4 2}{cmd:tabplot} {it:varname} creates a bar chart that by default
displays one set of vertical bars; with the {cmd:horizontal} option, it
displays one set of horizontal bars.  The categories of {it:varname} thus
define either columns from left (low values) to right (high values) or rows
from top (low values) to bottom (high values).  The value (for example,
frequency, fraction, or percent) for each column or row is shown as a bar.

{p 4 4 2}{cmd:tabplot} {it:rowvar} {it:colvar} follows standard
tabular alignment: the categories of {it:rowvar} define rows from top
(low values) to bottom (high values), and the categories of {it:colvar}
define columns from left (low values) to right (high values).  The value 
(for example, frequency, fraction, or percent) for each combination of row and
column is shown as a bar, with default alignment vertical.

{p 4 4 2}The default bar width is 0.5.  Use the {cmd:barwidth()} option
to vary width, but note that all bars will have the same width.

{p 4 4 2}By default, both variables are mapped on the fly in sort order
to successive integers from 1 and up, but original values or value labels
are used as value labels: this may be varied by use of the {cmd:yasis},
{cmd:xasis}, {cmd:yreverse}, and {cmd:xreverse} options.
The maximum bar height is by default 0.8.
Use the {cmd:height()} option to vary this.

{p 4 4 2}See {it:Remarks} and {it:Examples} for advice on plotting two or more
variables on the rows or the columns of such a plot.


{title:Options} 

{p 4 8 2}{cmd:fraction} indicates that all frequencies should be shown
as fractions (with sum 1) of the total frequency of all values being
represented in the graph.

{p 4 8 2}{cmd:fraction(}{it:varlist}{cmd:)} indicates that all
frequencies should be shown as fractions (with sum 1) of the total
frequency for each distinct category defined by the combinations of
{it:varlist}.  Usually, {it:varlist} will be one or more of the variables
specified.

{p 4 8 2}{cmd:percent} indicates that all frequencies should be shown as
percents (with sum 100) of the total frequency of all values being
represented in the graph.

{p 4 8 2}{cmd:percent(}{it:varlist}{cmd:)} indicates that all
frequencies should be shown as percents (with sum 100) of the total
frequency for each distinct category defined by the combinations of
{it:varlist}.  Usually, {it:varlist} will be one or more of the variables
specified.

{p 4 8 2}Only one of the {cmd:fraction}[{cmd:()}] and
{cmd:percent}[{cmd:()}] options may be specified.

{p 4 8 2}{cmd:missing} specifies that any missing values of any of the
variables specified should also be included within their own categories.

{p 4 8 2}{cmd:yasis} and {cmd:xasis} specify, respectively, that the
y (row) variable and the x (column) variable are to be treated
literally (that is, numerically).  Most commonly, each option will be
specified if the variable in question is a measured scale or a graded
variable with gaps.  If values 1 to 5 are labeled A to E, but no value
of 4 (D) is present in the data, {cmd:yasis} or {cmd:xasis} prevents a
mapping to 1 (A) ... 4 (E).

{p 4 8 2}{cmd:yreverse} and {cmd:xreverse} specify, respectively, that
the y (row) variable and the x (column) variable are to be reversed from
the version presented.  For example, if a variable to be plotted takes
values 1 to 5, then reversing the scale will flip so 5 will be plotted
where 1 was and vice versa. 

{p 4 8 2}{cmd:xasis} may not be specified with {cmd:xreverse}. 

{p 4 8 2}{cmd:yasis} may not be specified with {cmd:yreverse}. 

{p 4 8 2}{cmd:horizontal} specifies horizontal bars.  The default is 
vertical bars.

{p 4 8 2}{cmd:height(}{it:#}{cmd:)} controls the amount of graph space
taken up by bars.  The default is 0.8.  Note that the height may need to
be much smaller or much larger with {cmd:yasis} or {cmd:xasis}, given
that the latter take values literally.

{p 4 8 2}{cmd:showval} specifies that numeric values be shown
beneath (or if {cmd:horizontal} is specified, to the left of) bars.

{p 8 8 2} {cmd:showval} may also be specified with a variable name
and options.  If options alone are specified, no comma is necessary.  In
particular, 

{phang2}{cmd:showval(}{it:varname}{cmd:)} specifies that the values
to be shown are those of {it:varname}.  For example, the values of some
kind of residuals might be shown alongside frequency bars.

{phang2}{cmd:showval(offset(}{it:#}{cmd:))} specifies an offset between
the base (or left-hand edge) of the bar and the position of the numeric
value.  Default is 0.1 with two variables or 0.02 with one variable.
Tweak this if the spacing is too large or too small.

{phang2}{cmd:showval(format(}{it:format}{cmd:))} specifies a format
with which to show values.  Specifying a format will often be advisable
with nonintegers; for example, {cmd:showval(format(%2.1f))} specifies
rounding to 1 decimal place.  Note that with a specified variable, the
format defaults to the format of that variable; with percent options, the
format defaults to %2.1f (1 decimal place); with fraction options, the
format defaults to %4.3f (3 decimal places).

{p 8 8 2}{cmd:showval(}{it:varname}{cmd:, format(%2.1f))} is an example
of {it:varname} specified with options.  As usual, a comma is needed 
in such cases.

{p 8 8 2}Otherwise, the options of {cmd:showval()} can be options of
{helpb scatter}, most usually {help marker label options}.

{p 4 8 2}{opt frame(#)} specifies that all bars should be framed with bars showing 
constant value {it:#}. Most commonly, {it:#} is the maximum possible value (say 
fraction 1 or percent 100) or some other reference value. By default, framing bars have 
no colour. See (e.g.) Cleveland and McGill (1984) or Cleveland (1985) 
for the idea of framed rectangles and Keen (2010, 2018) for so-called 
thermometer charts. 

{p 8 8 2}{opt frameopts(frame_options)} specifies options of {help twoway rbar} 
to tune representation of the framing bars. 

{p 4 8 2}{opt minimum(#)} suppresses plotting of bars with values less
than the minimum specified, in effect setting them to zero.

{p 4 8 2}{opt maximum(#)} truncates bars with values more than the
maximum specified to show that maximum.

{p 4 8 2}{opt separate(sepspec)} specifies that bars associated with different
{it:sepspec} will be shown differently, most obviously using different
colors.  {it:sepspec} is passed as an argument to the {cmd:by()} option
of {helpb separate}, except that references to {cmd:@} are first
translated to be references to the quantity being plotted.

{p 8 8 2}A call to {cmd:separate()} may be supplemented with calls to
options {cmd:bar1()} ... {cmd:bar20()} or to {cmd:barall()}.  The
arguments should be options of {helpb twoway rbar}.

{p 8 8 2}Options {cmd:bar1()} to {cmd:bar20()} are provided to allow
overriding the defaults on up to 20 categories, the first, second, etc.,
shown.  The limit of 20 is arbitrary and more than any user
should really want.  Option {cmd:barall()} is available to override
the defaults for all bars.  Any {cmd:bar}{it:#}{cmd:()} option always
overrides {cmd:barall()}. Thus if you wanted thicker {cmd:blwidth()} on all
bars, you could specify {cmd:barall(blwidth(thick))}.  If you wanted to
highlight the first category only, you could specify
{cmd:bar1(blwidth(thick))}.

{p 4 8 2}{it:graph_options} refers to options of 
{helpb twoway rbar}.  Among others: 

{phang2}{opt barwidth(#)} specifies the widths of the bars.  The default
is {cmd:barwidth(0.5)}.  This may need changing, especially with the 
{cmd:xasis} or {cmd:yasis} option or if you wish bars to touch, exactly or
nearly.

{phang2}{opt bfcolor(colorstyle)} adjusts the bar fill color.  In particular,
Stata's defaults often imply that bars are filled with strong colors, but
unfilled bars created by using {cmd:bfcolor(none)} may be more subtle and just
as clear.

{phang2}{opt by(varlist)} specifies another variable used to subdivide the
display into panels.

{phang2}{opt recast(newplottype)} recasts the graph as another twoway
plottype.  In practice, {cmd:recast(rspike)} is the main alternative.

{phang2}{opt subtitle(tinfo)}, shown by default outside the graph and at top
left, specifies what kind of quantity is being shown: {cmd:"frequency"},
{cmd: "percent"}, and so forth.  The {it:Examples} section below includes
examples in which it is changed, which may mean being blanked out.

{phang2}{cmd:plot(}{help plot_option:plots}{cmd:)} provides a way to add
other plots to the generated graph.  Allowed in Stata 8.

{phang2}{cmd:addplot(}{help addplot option:plots}{cmd:)} provides a
way to add other plots to the generated graph.  Allowed in Stata 9 and later.

{p 8 8 2}With large datasets especially, one should ensure that
the plot or the extra plots do not contain information repeated for every
observation within each combination of {it:rowvar} and {it:colvar}.  The
examples show one technique for avoiding this.


{title:Remarks} 

{p 4 4 2}The display is deliberately minimal.  No numeric scales are
shown for reading off numeric values, although optionally numeric values
may be shown below or beside bars using the {cmd:showval} option.
Above all, there is no facility for any kind of three-dimensional
display or effect.  The maximum value (or more generally, value furthest 
from zero) shown is indicated with {cmd:note()}, unless {cmd:showval} or
{cmd:showval()} is specified.

{p 4 4 2}In contrast to a table, in which it is easier to compare values
down columns, it is usually easier to compare values across rows
whenever bars are vertical.  A simple alternative is to use the
{cmd:horizontal} option, in which case it is usually easier to compare
down columns.  Some experimentation with both forms and with
{cmd:percent(}{it:rowvar}{cmd:)} or {cmd:percent(}{it:colvar}{cmd:)}
will often be helpful.

{p 4 4 2}{cmd:tabplot} {it:rowvar colvar}{cmd:, by()} is the way to plot
three-way tables.  The variable specified in {cmd:by()} is used to
produce a set of graphs in several panels.  Similarly, {cmd:tabplot}
{it:varname}{cmd:, by()} is another way to plot two-way tables.

{p 4 4 2}Four-way or higher charts would often not be readable or
interpretable, but there are three evident ways to attempt them.  First,
try to {helpb reshape} or otherwise restructure the data
concerned to fewer variables.  Second, combine
variables, usually predictor variables, into a composite variable to be
shown on one axis.  See Cox (2007) for discussion of how to do that.
Third, use {cmd:tabplot} repeatedly and then use {helpb graph combine}.

{p 4 4 2}{cmd:tabplot} with the {cmd:xasis} option may be useful for
stacking histograms vertically.  Less commonly, with the {cmd:yasis} and
{cmd:horizontal} options, it may be useful for stacking them
horizontally.  A typical protocol would be, for {cmd:mpg} shown in bins
of width 2.5 mpg, 

{p 8 8 2}
{cmd:. sysuse auto, clear}{break} 
{cmd:. gen midpoint = round(mpg, 2.5)}{break} 
{cmd:. _crcslbl midpoint mpg}{break} 
{cmd:. tabplot foreign midpoint, xasis barw(2.5) bstyle(histogram) percent(foreign)}

{p 4 4 2}In general, specify a variable containing equally spaced
midpoints, and assign to it an appropriate variable label.  {cmd:tabplot}
will do the rest.  Omit the {cmd:percent()} option for display of
frequencies.

{p 4 4 2}A recipe for subverting {cmd:tabplot} to plot any variable that
takes on a single value for each cross-combination of categories is
illustrated in the examples below.  The key is to select precisely one
observation for each cross-combination and to specify that variable as
(most generally) an {cmd:iweight}.

{p 4 4 2}Furthermore, using an {cmd:iweight} is the only possible method
whenever a variable has at least some negative values.  In that case, 
you might do the following:

{p 8 8 2}1. Consider changing the maximum height through {cmd:height()}
to avoid overlap of bars variously representing positive and negative
values.  By default, {cmd:tabplot} chooses the scale to accommodate the
longest bar to be shown, but it contains no special intelligence
otherwise to avoid overlap of bars in the same column or row.

{p 8 8 2}2. If also using {cmd:showval} or {cmd:showval()}, consider
changing {cmd:offset()} and using a transparent {cmd:bfcolor()}.

{p 4 4 2}
Bar charts presented as one row or one column of bars go back at least
as far as Playfair (1786).  See, for example, Playfair (2005, 25) or Wainer
(2005, 45; 2009, 174).

{p 4 4 2} 
Bar charts presented in table form with two or more rows and two or more
columns are less common. Evans {it:et al.} (1933) discussed various geological
applications. Emeny (1934) used them in a well-illustrated monograph on raw
materials. Sears (1933, 1935) gave examples in pollen diagrams (for which line
or area plots are more common).  Brinton (1914, 66) showed a hybrid (in more
recent terms) of a bumps chart and a two-way bar chart. 

{p 4 4 2} 
A variety of examples can be found in
Brinton (1939), 
Neurath (1939), 
Kinsey et al. (1948, 1953), 
Olds (1949),
Stouffer et al. (1949a, 1949b), 
Rogers (1961), 
Ager (1963), 
Lockwood (1969), 
Koch and Link (1970), 
Colinvaux (1973, 1986, 1993), 
Doran and Hodson (1975), 
Bertin (1981, 1983), 
Lebart, Morineau, and Warwick (1984), 
Morrison (1985), 
Cliff and Haggett (1988),
Anderson and May (1991), 
Gleick (1993),
Carr (1994),
Hobbie et al. (1995),
Chapman and Wykes (1996), 
de Falguerolles, Friedrich, and Sawitzki (1997),
Chauchat and Risson (1998), 
Valiela (2001), 
Mihalisin (2002), 
MacKay (2003, 2009),  
Wilkinson (2005), 
Unwin, Theus, and Hofmann (2006), 
Hahsler, Hornik, and Buchta (2008), 
Hofmann (2008),
Sarkar (2008),  
Theus and Urbanek (2009),  
Few (2009, 2012, 2015), 
Atkins (2010), 
Carr and Pickle (2010, 85),
McDaniel and McDaniel (2012a, 2012b),  
Merz (2012),
Robbins (2013, 124),
Heiberger and Holland (2015, 34), 
Unwin (2015), 
Rodriguez and Kaczmarek (2016), 
Schwabish (2017, 91),
Evergreen (2017, 111), 
Wexler {it:et al.} (2017), 
Albert (2018),    
Kriebel and Murray (2018)
and Healy (2019, 102). 

{p 4 4 2}
As the example of pollen diagrams shows, the same form of graph can be
used for showing on any one axis either the categories of what is
regarded as one variable or two or more variables considered similar or
comparable.  Such bar charts, or similar displays, are also known as 

{p 8 8 2}aligned bar charts and multipane bar charts (see Mackinlay [1986] 
and McDaniel and McDaniel [2012a; 2012b]);

{p 8 8 2}column graph matrices (see Harris [1999]); 

{p 8 8 2}survey plots (see Lohninger [1994; 1996], Hoffman and Grinstein
[2002], Grinstein et al. [2002], and Ward, Grinstein, and Keim [2010]);

{p 8 8 2}table lens or table plots (see
Rao and Card [1994],
Pirolli and Rao [1996],
Spence [2001, 2007, 2014],
Ward, Grinstein, and Keim [2010],
Few [2012],
and
Cook, Lee, and Majumder [2016]);

{p 8 8 2}reorderable matrices (e.g. 
Siirtola and M{c a:}kinen 2005; M{c a:}kinen and Siirtola 2005);

{p 8 8 2}Bertin plots (e.g. Carlson 2017); 

{p 8 8 2}multiple bar charts and fluctuation diagrams 
(see Becker, Chambers, and Wilks [1988], Unwin, Theus, and Hosmann [2006],
Hofmann [2008], Theus and Urbanek [2009], and Unwin [2015]);

{p 8 8 2}layered bar charts (see Streit and Gehlenborg [2014]); 

{p 8 8 2}panel bar charts (see Peltier [2013a, 2013b] and 
Rahlf [2017, 110, 214]);  

{p 8 8 2}matrix charts (see Kirk [2016]); and

{p 8 8 2}thermometer charts (see Keen [2010, 2018]).  

{p 4 4 2}Such bar charts may require no more than a {helpb reshape}.  The
Examples include one with archaeological data for different levels at a site.

{p 4 4 2}Displays such as bar and pie charts with added numeric labels
have been called "grables" (Hink, Wogalter, and Eustace 1996; Hink, Eustace,
and Wogalter 1998; Bradstreet 2012). 

{p 4 4 2}We note also what are often called Hinton diagrams or Hinton 
plots in machine learning.  Rumelhart et al. (1986) is a token reference.
Examples occur in mainstream machine learning texts such as MacKay (2003), 
Bishop (2006), Barber (2012), and Murphy (2012).

{p 4 4 2}See also the general discussion of product plots (Wickham and 
Hofmann 2011) centring on the use of area to represents counts, proportions
and probabilities. 

{p 4 4 2}Brinton (1939, 142, 505) uses the term "two-way bar chart" for 
back-to-back or bilateral bar charts, a use different from that here.

{p 4 4 2}Similar references would be much appreciated by the author.

{p 4 4 2}For applications of {cmd:tabplot}, see also Cox (2004, 2008, 2012) 
or Roberts {it:et al.} (2013) or search Statalist.


{title:Examples}

{p 4 8 2}Stata's automobile data: 

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. tabplot rep78}{p_end}
{p 4 8 2}{cmd:. tabplot rep78, showval}{p_end}
{p 4 8 2}{cmd:. tabplot rep78, showval horizontal}

{p 4 8 2}{cmd:. tabplot for rep78}{p_end}
{p 4 8 2}{cmd:. tabplot for rep78, showval}{p_end}
{p 4 8 2}{cmd:. tabplot for rep78, percent(foreign) showval(offset(0.05) format(%2.1f))}{p_end}
{p 4 8 2}{cmd:. tabplot for rep78, percent(foreign) sep(foreign) bar1(bcolor(red*0.5)) bar2(bcolor(blue*0.5)) showval(offset(0.05) format(%2.1f)) subtitle(% by origin)}

{p 4 8 2}{cmd:. tabplot rep78 mpg, xasis barw(1) bstyle(histogram)}

{p 4 8 2}{cmd:. egen mean = mean(mpg), by(rep78)}{p_end}
{p 4 8 2}{cmd:. gen rep78_2 = 6 - rep78 - 0.05}{p_end}
{p 4 8 2}{cmd:. bysort rep78 : gen byte tag = _n == 1}{p_end}
{p 4 8 2}{cmd:. tabplot rep78 mpg, xasis barw(1) bstyle(histogram) addplot(scatter rep78_2 mean if tag)}

{p 4 8 2}{cmd:. drop tag}{p_end}
{p 4 8 2}{cmd:. egen mean2 = mean(mpg), by(foreign rep78)}{p_end}
{p 4 8 2}{cmd:. egen tag = tag(foreign rep78)}{p_end}
{p 4 8 2}{cmd:. tabplot foreign rep78 if tag [iw=mean2], showval(format(%2.1f)) subtitle(mean miles per gallon)}{p_end}

{p 4 8 2}Stata's radiologist assessment data: 

{p 4 8 2}{cmd:. webuse rate2, clear}{p_end}
{p 4 8 2}{cmd:. tabplot rad?, percent showval}{p_end}
{p 4 8 2}{cmd:. count}{p_end}
{p 4 8 2}{cmd:. bysort rada radb : gen show = string(_N) + "  " + string(_N * 100/85, "%2.1f") + "%"}{p_end}
{p 4 8 2}{cmd:. tabplot rad?, showval(show) subtitle("frequency and %")}{p_end}
{p 4 8 2}{cmd:. tabplot rad?, showval(show) xsc(alt) subtitle("frequency and %", pos(7))}

{p 4 8 2}Doran and Hodson (1975, 259) gave these archaeological data:

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
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. reshape long freq, i(levels) j(type) string}{p_end}
{p 4 8 2}{cmd:. tabplot levels type [w=freq], bfcolor(none) horizontal barw(1) percent(levels) subtitle(% at each level) showval(offset(0.45)) xsc(r(0.8 .)) yasis}

{p 4 8 2}Greenacre (2007, 42; 2017, 42) gave these data from the 1997 
Encuesta Nacional de la Salud (Spanish National Health Survey):

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input byte(agegroup health) long freq}{p_end}
{p 4 8 2}{cmd:. 1 1 243}{p_end}
{p 4 8 2}{cmd:. 1 2 789}{p_end}
{p 4 8 2}{cmd:. 1 3 167}{p_end}
{p 4 8 2}{cmd:. 1 4  18}{p_end}
{p 4 8 2}{cmd:. 1 5   6}{p_end}
{p 4 8 2}{cmd:. 2 1 220}{p_end}
{p 4 8 2}{cmd:. 2 2 809}{p_end}
{p 4 8 2}{cmd:. 2 3 164}{p_end}
{p 4 8 2}{cmd:. 2 4  35}{p_end}
{p 4 8 2}{cmd:. 2 5   6}{p_end}
{p 4 8 2}{cmd:. 3 1 147}{p_end}
{p 4 8 2}{cmd:. 3 2 658}{p_end}
{p 4 8 2}{cmd:. 3 3 181}{p_end}
{p 4 8 2}{cmd:. 3 4  41}{p_end}
{p 4 8 2}{cmd:. 3 5   8}{p_end}
{p 4 8 2}{cmd:. 4 1  90}{p_end}
{p 4 8 2}{cmd:. 4 2 469}{p_end}
{p 4 8 2}{cmd:. 4 3 236}{p_end}
{p 4 8 2}{cmd:. 4 4  50}{p_end}
{p 4 8 2}{cmd:. 4 5  16}{p_end}
{p 4 8 2}{cmd:. 5 1  53}{p_end}
{p 4 8 2}{cmd:. 5 2 414}{p_end}
{p 4 8 2}{cmd:. 5 3 306}{p_end}
{p 4 8 2}{cmd:. 5 4 106}{p_end}
{p 4 8 2}{cmd:. 5 5  30}{p_end}
{p 4 8 2}{cmd:. 6 1  44}{p_end}
{p 4 8 2}{cmd:. 6 2 267}{p_end}
{p 4 8 2}{cmd:. 6 3 284}{p_end}
{p 4 8 2}{cmd:. 6 4  98}{p_end}
{p 4 8 2}{cmd:. 6 5  20}{p_end}
{p 4 8 2}{cmd:. 7 1  20}{p_end}
{p 4 8 2}{cmd:. 7 2 136}{p_end}
{p 4 8 2}{cmd:. 7 3 157}{p_end}
{p 4 8 2}{cmd:. 7 4  66}{p_end}
{p 4 8 2}{cmd:. 7 5  17}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values agegroup agegroup}{p_end}
{p 4 8 2}{cmd:. label def agegroup 1 "16-24", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 2 "25-34", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 3 "35-44", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 4 "45-54", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 5 "55-64", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 6 "65-74", modify}{p_end}
{p 4 8 2}{cmd:. label def agegroup 7 "75+", modify}{p_end}
{p 4 8 2}{cmd:. label values health health}{p_end}
{p 4 8 2}{cmd:. label def health 1 "very good", modify}{p_end}
{p 4 8 2}{cmd:. label def health 2 "good", modify}{p_end}
{p 4 8 2}{cmd:. label def health 3 "regular", modify}{p_end}
{p 4 8 2}{cmd:. label def health 4 "bad", modify}{p_end}
{p 4 8 2}{cmd:. label def health 5 "very bad", modify}{p_end}
{p 4 8 2}{cmd:. tabplot health agegroup [w=freq] ,  percent(agegroup) showval subtitle(% of age group) xtitle("") bfcolor(none)}{p_end}

{p 4 4 2}Aitkin et al. (1989, 242) reported
data from a survey of student opinion on the Vietnam War taken at the
University of North Carolina at Chapel Hill in May 1967.  Students were
classified by sex, year of study, and the policy they supported, given
the following choices:

{p 8 11 2} 
A. The United States should defeat the power of North Vietnam by widespread
bombing of its industries, ports, and harbors and by land invasion.

{p 8 11 2} 
B. The United States should follow the present policy in Vietnam.

{p 8 11 2} 
C. The United States should de-escalate its military activity, stop bombing
North Vietnam, and intensify its efforts to begin negotiation.

{p 8 11 2} 
D. The United States should withdraw its military forces from Vietnam
immediately.

{p 4 4 2} 
(They also report response rates [page 243], which average 26% for males and
17% for females.) 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input str6 sex str8 year str1 policy int freq}{p_end}
{p 4 8 2}{cmd:. "male"   "1"        "A" 175}{p_end}
{p 4 8 2}{cmd:. "male"   "1"        "B" 116}{p_end}
{p 4 8 2}{cmd:. "male"   "1"        "C" 131}{p_end}
{p 4 8 2}{cmd:. "male"   "1"        "D"  17}{p_end}
{p 4 8 2}{cmd:. "male"   "2"        "A" 160}{p_end}
{p 4 8 2}{cmd:. "male"   "2"        "B" 126}{p_end}
{p 4 8 2}{cmd:. "male"   "2"        "C" 135}{p_end}
{p 4 8 2}{cmd:. "male"   "2"        "D"  21}{p_end}
{p 4 8 2}{cmd:. "male"   "3"        "A" 132}{p_end}
{p 4 8 2}{cmd:. "male"   "3"        "B" 120}{p_end}
{p 4 8 2}{cmd:. "male"   "3"        "C" 154}{p_end}
{p 4 8 2}{cmd:. "male"   "3"        "D"  29}{p_end}
{p 4 8 2}{cmd:. "male"   "4"        "A" 145}{p_end}
{p 4 8 2}{cmd:. "male"   "4"        "B"  95}{p_end}
{p 4 8 2}{cmd:. "male"   "4"        "C" 185}{p_end}
{p 4 8 2}{cmd:. "male"   "4"        "D"  44}{p_end}
{p 4 8 2}{cmd:. "male"   "Graduate" "A" 118}{p_end}
{p 4 8 2}{cmd:. "male"   "Graduate" "B" 176}{p_end}
{p 4 8 2}{cmd:. "male"   "Graduate" "C" 345}{p_end}
{p 4 8 2}{cmd:. "male"   "Graduate" "D" 141}{p_end}
{p 4 8 2}{cmd:. "female" "1"        "A"  13}{p_end}
{p 4 8 2}{cmd:. "female" "1"        "B"  19}{p_end}
{p 4 8 2}{cmd:. "female" "1"        "C"  40}{p_end}
{p 4 8 2}{cmd:. "female" "1"        "D"   5}{p_end}
{p 4 8 2}{cmd:. "female" "2"        "A"   5}{p_end}
{p 4 8 2}{cmd:. "female" "2"        "B"   9}{p_end}
{p 4 8 2}{cmd:. "female" "2"        "C"  33}{p_end}
{p 4 8 2}{cmd:. "female" "2"        "D"   3}{p_end}
{p 4 8 2}{cmd:. "female" "3"        "A"  22}{p_end}
{p 4 8 2}{cmd:. "female" "3"        "B"  29}{p_end}
{p 4 8 2}{cmd:. "female" "3"        "C" 110}{p_end}
{p 4 8 2}{cmd:. "female" "3"        "D"   6}{p_end}
{p 4 8 2}{cmd:. "female" "4"        "A"  12}{p_end}
{p 4 8 2}{cmd:. "female" "4"        "B"  21}{p_end}
{p 4 8 2}{cmd:. "female" "4"        "C"  58}{p_end}
{p 4 8 2}{cmd:. "female" "4"        "D"  10}{p_end}
{p 4 8 2}{cmd:. "female" "Graduate" "A"  19}{p_end}
{p 4 8 2}{cmd:. "female" "Graduate" "B"  27}{p_end}
{p 4 8 2}{cmd:. "female" "Graduate" "C" 128}{p_end}
{p 4 8 2}{cmd:. "female" "Graduate" "D"  13}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. tabplot policy year [w=freq], by(sex, subtitle(% by sex and year, place(w)) note("")) percent(sex year) showval}{p_end}
{p 4 8 2}{cmd:. tabplot policy year [w=freq], by(sex, subtitle(% by sex and year, place(w)) note("")) percent(sex year) showval frame(100)} 


{title:Acknowledgments} 

{p 4 4 2}Bob Fitzgerald, Friedrich Huebler, and Martyn Sherriff found typos in
earlier versions of this help file.  Friedrich also pointed to various
efficiency issues.  Marcello Pagano provided encouragement and found a bug.
Vince Wiggins suggested how best to align x-axis labels when bars are
horizontal.  Jay Goodliffe suggested flagging use of the {cmd:subtitle()}
option in this help.  Maarten Buis pointed out that compound double quotes
may be needed to handle value labels. William Huber and Jeff Laux indirectly 
encouraged addition of the {cmd:frame()} option. 
 

{title:References} 

{p 4 8 2}Ager, D. V. 1963.
{it:Principles of Paleoecology: An Introduction to the Study of How and Where Animals and Plants Lived in the Past}.
New York: McGraw-Hill.

{p 4 8 2}Aitkin, M., D. Anderson, B. Francis, and J. Hinde. 1989.
{it:Statistical Modelling in GLIM}. Oxford: Oxford University Press.

{p 4 8 2}Albert, J. 2018. 
{it:Visualizing Baseball.} 
Boca Raton, FL: CRC Press.  

{p 4 8 2}Anderson, R. M., and R. M. May. 1991.
{it:Infectious Diseases of Humans: Dynamics and Control}.
Oxford: Oxford University Press.

{p 4 8 2}Atkins, P. 2010.
{it:Liquid Materialities: A History of Milk, Science and the Law}.
Farnham, UK: Ashgate.

{p 4 8 2}Barber, D. 2012.
{it:Bayesian Reasoning and Machine Learning}.
Cambridge: Cambridge University Press. 

{p 4 8 2}Becker, R. A., J. M. Chambers, and A. R. Wilks. 1988.
{it:The New S Language: A Programming Environment for Data Analysis and Graphics}.
Pacific Grove, CA: Wadsworth and Brooks/Cole.

{p 4 8 2}Bertin, J. 1981.
{it:Graphics and Graphic Information Processing}.
Berlin: De Gruyter.

{p 4 8 2}Bertin, J. 1983.
{it:Semiology of Graphics: Diagrams, Networks, Maps}.
Madison: University of Wisconsin Press.

{p 4 8 2}Bishop, C. M. 2006.
{it:Pattern Recognition and Machine Learning}.
New York: Springer.

{p 4 8 2}Bradstreet, T. E. 2012.
Grables: Visual displays that combine the best attributes of graphs 
and tables.
In 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences},
ed. A. Krause and M. O'Connell, 41{c -}69. New York: Springer.

{p 4 8 2}Brinton, W. C. 1914. 
{it:Graphic Methods for Presenting Facts}.
New York: Engineering Magazine Company. 

{p 4 8 2}Brinton, W. C. 1939.
{it:Graphic Presentation}.
New York: Brinton Associates.

{p 4 8 2}Carlson, D. L. 2017. 
{it:Quantitative Methods in Archaeology Using R.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Carr, D. B. 1994. 
Using gray in plots. 
{it:Statistical Computing and Statistical Graphics Newsletter} 5(1): 11{c -}14.

{p 4 8 2}
Carr, D. B., and L. W. Pickle. 2010. 
{it:Visualizing Data Patterns with Micromaps}.
Boca Raton, FL: Chapman & Hall/CRC.

{p 4 8 2}Chapman, M. and C. Wykes. 1996.
{it:Plain Figures}. 2nd ed.
London: The Stationary Office.

{p 4 8 2}Chauchat, J.-H., and A. Risson. 1998.
Bertin's graphics and multidimensional data analysis.
In {it:Visualization of Categorical Data},
ed. J. Blasius and M. Greenacre, 37{c -}45.
San Diego, CA: Academic Press.

{p 4 8 2}Cleveland, W.S. 1985. 
{it:The Elements of Graphing Data.} 
Monterey, CA: Wadsworth. 

{p 4 8 2}Cleveland, W.S. and R. McGill. 1984. 
Graphical perception: theory, experimentation, and application to the 
development of graphical methods. 
{it:Journal of the American Statistical Association} 
79: 531{c -}554, 

{p 4 8 2}Cliff, A. D., and P. Haggett. 1988. 
{it:Atlas of Disease Distributions: Analytic Approaches to Epidemiological Data}.
Oxford: Blackwell. 

{p 4 8 2}Colinvaux, P. A. 1973. 
{it:Introduction to Ecology.} 
New York: John Wiley. 

{p 4 8 2}Colinvaux, P. A. 1986. 
{it:Ecology.} 
New York: John Wiley. 

{p 4 8 2}Colinvaux, P. A. 1993. 
{it:Ecology 2.} 
New York: John Wiley. 

{p 4 8 2}Cook, D., E.{c -}K. Lee, and M. Majumder. 2016. 
Data visualization and statistical graphics in big data analysis. 
{it:Annual Review of Statistics and its Applications} 3: 133{c -}159. 

{p 4 8 2}Cox, N. J. 2004.
{browse "http://www.stata-journal.com/article.html?article=gr0004":Speaking Stata: Graphing categorical and compositional data}.
{it:Stata Journal} 4: 190{c -}215.

{p 4 8 2}Cox, N. J. 2007.
{browse "http://www.stata-journal.com/article.html?article=dm0034":Stata tip 52: Generating composite categorical variables}.
{it:Stata Journal} 7: 582{c -}583.

{p 4 8 2}Cox, N. J. 2008.
{browse "http://www.stata-journal.com/article.html?article=gr0031":Speaking Stata: Spineplots and their kin}.
{it:Stata Journal} 8: 105{c -}121.

{p 4 8 2}Cox, N. J. 2012.
{browse "http://www.stata-journal.com/article.html?article=gr0053":Speaking Stata: Axis practice, or what goes where on a graph}.
{it:Stata Journal} 12: 549{c -}561.

{p 4 8 2}de Falguerolles, A., F. Friedrich, and G. Sawitzki. 1997.
A tribute to J. Bertin's graphical data analysis.
In {it:Softstat '97: Advances in Statistical Software 6: The 9th Conference on the Scientific Use of Statistical Software, March 3{c -}6, 1997},
ed. W. Bandilla and F. Faulbaum, 11{c -}20.
Stuttgart: Lucius & Lucius.

{p 4 8 2}Doran, J. E., and F. R. Hodson. 1975.
{it:Mathematics and Computers in Archaeology}.
Edinburgh: Edinburgh University Press.

{p 4 8 2}Emeny, B. 1934.
{it:The Strategy of Raw Materials: A Study of America in Peace and War}.
New York: Macmillan.

{p 4 8 2}
Evans, P., R. J. Hayman and M. A. Majeed. 1933. 
The graphical representation of heavy mineral analyses.  
London: 1st World Petroleum Congress 1: 251{c -}256. WPC-1060. 
{browse "https://www.onepetro.org/download/conference-paper/WPC-1060?id=conference-paper%2FWPC-1060":https://www.onepetro.org/download/conference-paper/WPC-1060?id=conference-paper%2FWPC-1060}

{p 4 8 2}Evergreen, S. D. H. 2017. 
{it:Effective Data Visualization: The Right Chart for the Right Data}.
Thousand Oaks, CA: Sage.

{p 4 8 2}Few, S. 2009.
{it:Now You See It: Simple Visualization Techniques for Quantitative Analysis}.
Oakland, CA: Analytics Press.

{p 4 8 2}Few, S. 2012.
{it:Show Me the Numbers: Designing Tables and Graphs to Enlighten}. 2nd ed.
Burlingame, CA: Analytics Press.

{p 4 8 2}Few, S. 2015.
{it:Signal: Understanding What Matters in a World of Noise}.
Burlingame, CA: Analytics Press.

{p 4 8 2}Gleick, P. H., ed. 1993.
{it:Water in Crisis: A Guide to the World's Fresh Water Resources}.
New York: Oxford University Press.

{p 4 8 2}Greenacre, M. 2007. {it:Correspondence Analysis in Practice}.
2nd ed. Boca Raton, FL: Chapman & Hall/CRC.

{p 4 8 2}Greenacre, M. 2017. {it:Correspondence Analysis in Practice}.
3rd ed. Boca Raton, FL: CRC Press. 

{p 4 8 2}
Grinstein, G. G., P. E. Hoffman, R. M. Pickett, and S. J. Laskowski. 2002.
Benchmark development for the evaluation of visualization for data mining.
In
{it:Information Visualization in Data Mining and Knowledge Discovery},
ed. U. Fayyad, G. G. Grinstein, and A. Wierse, 129{c -}176.
San Diego, CA: Academic Press.

{p 4 8 2}Hahsler, M., K. Hornik, and C. Buchta. 2008.
Getting things in order: An introduction to the R package seriation.
{it:Journal of Statistical Software} 25(3): 1{c -}34.
{browse "http://www.jstatsoft.org/v25/i03":http://www.jstatsoft.org/v25/i03}.

{p 4 8 2}Harris, R. L. 1999. 
{it:Information Graphics: A Comprehensive Illustrated Reference}.
New York: Oxford University Press. 

{p 4 8 2}Healy, K. 2019. 
{it:Data Visualization: A Practical Introduction.} 
Princeton, NJ: Princeton University Press. 

{p 4 8 2}Heiberger, R.M. and B. Holland. 2015. 
{it:Statistical Analysis and Data Display: An Intermediate Course with Examples in R.}
New York: Springer. 

{p 4 8 2}
Hink, J. K., J. K. Eustace, and M. S. Wogalter. 1998.
Do grables enable the extraction of quantitative information
better than pure graphs or tables?
{it:International Journal of Industrial Ergonomics} 22: 439{c -}447.

{p 4 8 2}
Hink, J. K., M. S. Wogalter, and J. K. Eustace. 1996.
Display of quantitative information: 
Are grables better than plain graphs or tables? 
{it:Proceedings of the Human Factors and Ergonomics Society Annual Meeting}
40: 1155{c -}1159.

{p 4 8 2}
Hobbie, J. E., L. A. Deegan, B. J. Peterson, E. B. Rastetter, 
G. R. Shaver, G. W. Kling, W. J. O'Brien, F. S. T. Chapin, M. C. Miller, 
G. W. Kipphut, W. B. Bowden, A. E. Hershey, and M. E. McDonald.  
1995. Long-term measurements at the Arctic LTER site. 
In {it:Ecological Time Series},
ed. T. M. Powell and J. H. Steele, 391{c -}409. 
New York: Chapman and Hall. 

{p 4 8 2}Hoffman, P. E., and G. G. Grinstein. 2002.
A survey of visualizations for high-dimensional data mining.
In {it:Information Visualization in Data Mining and Knowledge Discovery},
ed. U. Fayyad, G. G. Grinstein, and A. Wierse, 47{c -}82.
San Diego, CA: Academic Press.

{p 4 8 2}Hofmann, H. 2008.
Mosaic plots and their variants.
In {it:Handbook of Data Visualization},
ed. C. Chen, W. H{c a:}rdle, and A. Unwin, 617{c -}642.
Berlin: Springer.

{p 4 8 2}Keen, K. J. 2010 (second edition 2018). 
{it:Graphics for Statistics and Data Analysis with  R.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}
Kinsey, A. C., W. B. Pomeroy and C. E. Martin. 1948. 
{it:Sexual Behavior in the Human Male.} 
Philadelphia: W.B. Saunders. 

{p 4 8 2}
Kinsey, A. C., W. B. Pomeroy,  C. E. Martin and P. H. Gebhard. 1953. 
{it:Sexual Behavior in the Human Female.} 
Philadelphia: W.B. Saunders. 

{p 4 8 2}Kirk, A. 2016. 
{it:Data Visualization: A Handbook for Data Driven Design}.
London: Sage. 

{p 4 8 2}Koch, G. S., Jr., and R. F. Link. 1970.
{it:Statistical Analysis of Geological Data: Volume I}.
New York: Wiley.

{p 4 8 2}Kriebel, A. and E. Murray. 2018. 
{it:#MakeoverMonday: Improving How We Visualize and Analyze Data, One Chart at a Time.}
Hoboken, NJ: John Wiley.

{p 4 8 2}Lebart, L., A. Morineau, and K. M. Warwick. 1984.
{it:Multivariate Descriptive Statistical Analysis: Correspondence Analysis and Related Techniques for Large Matrices}.
New York: Wiley.

{p 4 8 2}Lockwood, A. 1969.
{it:Diagrams: A Visual Survey of Graphs, Maps, Charts and Diagrams for the Graphic Designer}.
London: Studio Vista.

{p 4 8 2}Lohninger, H. 1994.
INSPECT: A program system to visualize and interpret chemical data.
{it:Chemometrics and Intelligent Laboratory Systems} 22: 147{c -}153.

{p 4 8 2}Lohninger, H. 1996.
{it:INSPECT: A Program System for Scientific and Engineering Data}.
Berlin: Springer.

{p 4 8 2}MacKay, D. J. C. 2003.
{it:Information Theory, Inference, and Learning Algorithms}.
Cambridge: Cambridge University Press.

{p 4 8 2}MacKay, D. J. C. 2009.
{it:Sustainable Energy {c -} Without the Hot Air}.
Cambridge: UIT Cambridge.

{p 4 8 2}Mackinlay, J. D. 1986.
Automating the design of graphical presentations of relational information.
{it:ACM Transactions on Graphics} 5: 110{c -}141.

{p 4 8 2}M{c a:}kinen,  E. and H. Siirtola. 2005.
The barycenter heuristic and the reorderable matrix.
{it:Informatica (Slovenia)} 29: 357{c -}364

{p 4 8 2}McDaniel, E., and S. McDaniel. 2012a.
{it:The Accidental Analyst: Show Your Data Who's Boss}.
Seattle, WA: Freakalytics.

{p 4 8 2}McDaniel, S., and E. McDaniel. 2012b.
{it:Rapid Graphs with Tableau Software 7: Create Intuitive, Actionable Insights in Just 15 Days.}
Seattle, WA: Freakalytics.

{p 4 8 2}Merz, M. 2012.
(Interactive) Graphics for biomarker assessment.
In 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences},
ed. A. Krause and M. O'Connell, 117{c -}138. New York: Springer.

{p 4 8 2}Mihalisin, T. W. 2002.
Data warfare and multidimensional education.
In
{it:Information Visualization in Data Mining and Knowledge Discovery},
ed. U. Fayyad, G. G. Grinstein, and A. Wierse, 315{c -}344.
San Diego, CA: Academic Press.

{p 4 8 2}Morrison, P. S. 1985.
Symbolic representation of tabular data.
{it:New Zealand Journal of Geography} 79: 11{c -}18.

{p 4 8 2}Murphy, K. P. 2012.
{it:Machine Learning: A Probabilistic Perspective}.
Cambridge, MA: MIT Press.

{p 4 8 2}Neurath, O. 1939.
{it:Modern Man in the Making}.
London: Secker and Warburg.

{p 4 8 2}Olds, E. B. 1949. 
The city block as a unit for recording and analyzing urban data. 
{it:Journal of the American Statistical Association} 44: 485{c -}500.

{p 4 8 2}Peltier, J. 2013a. 
Alternatives to a 3D Bar Chart. 
{browse "https://peltiertech.com/3d-bar-chart-alternatives/":https://peltiertech.com/3d-bar-chart-alternatives/}  
[September 12] 

{p 4 8 2}Peltier, J. 2013b. 
Column Chart with Primary and Secondary Axes
{browse "https://peltiertech.com/excel-column-chart-primary-secondary-axes/":https://peltiertech.com/excel-column-chart-primary-secondary-axes/}
[October 28]. 

{p 4 8 2}Peltier, J. Note many similar posts on the author's site. 

{p 4 8 2}
Pirolli, P., and R. Rao. 1996.
Table lens as a tool for making sense of data.
In {it:AVI '96: Proceedings of the Workshop on Advanced Visual Interfaces},
ed. T. Catarci, M. F. Costabile, S. Levialdi, and G. Santucci, 67{c -}80.
New York: Association for Computing Machinery.

{p 4 8 2}Playfair, W. H. 1786.
{it:The Commercial and Political Atlas}.
London: Robinson, Sewell, and Debrett.

{p 4 8 2}Playfair, W. H. 2005.
{it:The Commercial and Political Atlas and Statistical Breviary}.
Cambridge: Cambridge University Press.
Edited by H. Wainer and I. Spence.

{p 4 8 2}Rahlf, T. 2017. 
{it:Data Visualisation with R: 100 Examples}.
Cham, Switzerland: Springer.

{p 4 8 2}
Rao, R., and S. K. Card. 1994.
The table lens: Merging graphical and symbolic representations in an
interactive focus + context visualization for tabular information.
In
{it:CHI '94: Proceedings of the SIGCHI Conference on Human Factors in Computing Systems},
ed. B. Adelson, S. Dumais, and J. S. Olson, 318{c -}322.
New York: Association for Computing Machinery.

{p 4 8 2}
Roberts, D. H., D. J. A. Evans, J. Lodwick and N. J. Cox. 
2013. 
The subglacial and ice-marginal signature of the North Sea Lobe of the 
British-Irish Ice Sheet during the Last Glacial Maximum at Upgang, North 
Yorkshire, UK. 
{it:Proceedings of the Geologists' Association} 
124: 503{c -}519 
{browse "http://dx.doi.org/10.1016/j.pgeola.2012.08.009":http://dx.doi.org/10.1016/j.pgeola.2012.08.009} 

{p 4 8 2}
Robbins, N. B. 2013. 
{it:Creating More Effective Graphs}.
Wayne, NJ: Chart House.

{p 4 8 2}
Rodriguez, J. and P. Kaczmarek. 2016. 
{it:Visualizing Financial Data.} 
Indianapolis, IN: Wiley. 

{p 4 8 2}Rogers, A. C. 1961.
{it:Graphic Charts Handbook}.
Washington, DC: Public Affairs Press.

{p 4 8 2}
Rumelhart, D. E., G. E. Hinton, and R. J. Williams. 1986.
Learning representations by back-propagating errors.
{it:Nature} 323: 533{c -}536.

{p 4 8 2}
Sarkar, D. 2008.
{it:Lattice: Multivariate Data Visualization with R}.
New York: Springer.

{p 4 8 2}
Schwabish, J. 2017. 
{it:Better Presentations: A Guide for Scholars, Researchers, and Wonks}.
New York: Columbia University Press.

{p 4 8 2}Sears, P. B. 1933.
Climatic change as a factor in forest succession.
{it:Journal of Forestry} 31: 934{c -}942.

{p 4 8 2}Sears, P. B. 1935.
Types of North American pollen profiles.
{it:Ecology} 16: 488{c -}499.

{p 4 8 2}Siirtola, H. and E. M{c a:}kinen. 2005.  
Constructing and reconstructing the reorderable matrix. 
{it:Information Visualization} 4: 32{c -}48. 

{p 4 8 2}Snyder, T. 2012.
Data visualization for clinical trials data management and operations. 
In 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences},
ed. A. Krause and M. O'Connell, 359{c -}372. New York: Springer.

{p 4 8 2}
Spence, R. 2001.
{it:Information Visualization.} 
Harlow, UK: Pearson.

{p 4 8 2}
Spence, R. 2007.
{it:Information Visualization: Design for Interaction.} 2nd ed.
Harlow, UK: Pearson.

{p 4 8 2}
Spence, R. 2014. 
{it:Information Visualization: An introduction.} 3rd ed. 
Cham: Springer. 

{p 4 8 2}
Stouffer, S. A., E. A. Suchman, L. C. DeVinney, S. A. Star, and R. M.
Williams, Jr. 1949a.
{it:The American Soldier: Adjustment During Army Life}.
Princeton, NJ: Princeton University Press.

{p 4 8 2}
Stouffer, S. A., A. A. Lumsdaine, M. H. Lumsdaine, R. M. Williams, Jr.,
M. B. Smith, I. L. Janis, S. A. Star, and L. S. Cottrell. 1949b.
{it:The American Soldier: Combat and its Aftermath}.
Princeton, NJ: Princeton University Press.

{p 4 8 2} 
Streit, M., and N. Gehlenborg. 2014. Bar charts and box plots. 
{it:Nature Methods} 11: 117. 
{browse "http://dx.doi.org/10.1038/nmeth.2807":http://dx.doi.org/10.1038/nmeth.2807} 

{p 4 8 2}
Theus, M., and S. Urbanek. 2009.
{it:Interactive Graphics for Data Analysis: Principles and Examples}.
Boca Raton, FL: Chapman & Hall/CRC.

{p 4 8 2}
Unwin, A. 2015.
{it:Graphical Data Analysis with R}.
Boca Raton, FL: Taylor & Francis.

{p 4 8 2}
Unwin, A., M. Theus, and H. Hofmann. 2006.
{it:Graphics of Large Datasets: Visualizing a Million}.
New York: Springer.

{p 4 8 2}
Valiela, I. 2001.
{it:Doing Science: Design, Analysis, and Communication of Scientific Research}.
New York: Oxford University Press.

{p 4 8 2}Wainer, H. 2005.
{it:Graphic Discovery: A Trout in the Milk and Other Visual Adventures}.
Princeton, NJ: Princeton University Press.

{p 4 8 2}Wainer, H. 2009.
{it:Picturing the Uncertain World: How to Understand, Communicate, and Control Uncertainty through Graphical Display}.
Princeton, NJ: Princeton University Press.

{p 4 8 2}Ward, M., G. Grinstein, and D. Keim. 2010.
{it:Interactive Data Visualization: Foundations, Techniques, and Applications}.
Natick, MA: A K Peters.

{p 4 8 2}Wexler, S., J. Shaffer and A. Cotgreave. 2017. 
{it:The Big Book of Dashboards: Visualizing Your Data Using Real-World Business Scenarios.} 
Hoboken, NJ: John Wiley. 
See pp.63, 65, 66, 225, 228, 247, 249{c -}252, 257, 283, 288{c -}290. 

{p 4 8 2}Wickham, H. and H. Hofmann. 2011. Product plots. 
{it:IEEE Transactions on Visualization and Computer Graphics} 17: 
2223{c -}2230. 

{p 4 8 2}
Wilkinson, L. 2005.
{it:The Grammar of Graphics}. 2nd ed.
New York: Springer.


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:Also see} 

{p 4 14 2}
Article:  {it:Stata Journal}, volume 17, number 3: {browse "http://www.stata-journal.com/article.html?article=up0056":gr0066_1},{break}
          {it:Stata Journal}, volume 16, number 2: {browse "http://www.stata-journal.com/article.html?article=gr0066":gr0066}

{p 7 13 2}
Help:  {helpb twoway rbar}, {helpb histogram},
{helpb catplot} (if installed), {helpb spineplot} (if installed)  
{p_end}

{* Brooks Emeny 1901-1980 political scientist, latterly President Foreign Policy Association}{...}
{* Percy Evans 1892-1974 worked for Burmah Oil Company}{...}
{* Paul Bigelow Sears 1891-1990 ecologist, latterly at Yale)}{...}


