{smcl}
{* 5jul2004/28nov2005/24jun2007/26jul2007/26aug2007/8nov2007/30nov2007/27feb2008/7nov2008/22apr2009/2may2009/15may2009/30nov2009/8dec2009/4feb2010/19feb2010/15mar2010/26apr2010/21may2010/2dec2010}{...}
{* 23mar2011/6apr2011/30aug2011/20jul2012/20feb2013/16apr2013/2sept2013/10nov2013/17nov2013/18dec2013/29jan2014/27mar2014/7apr2014/24apr2014/2may2014/14may2014/21may2014/13jun2014/14aug2014/4sep2014/23sep2014/6oct2014/21oct2014/9dec2014}{...}
{* 2jan2015/30mar2015/4may2015/25may2015/9jul2015/4sep2015/15oct2015/14dec2015/26jan2016/22mar2016/9may2016/9aug2016/18aug2016/31oct2016/20dec2016/22feb2017/24feb2017/2mar2017}{...}
{hline}
help for {hi:stripplot}
{hline}

{title:Strip plots: oneway dot plots}

{p 8 17 2}
{cmd:stripplot}
{it:varlist} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 

{p 12 17 2} 
[ 
{cmd:,}
{cmdab:vert:ical} 
{c -(}
{cmdab:st:ack}
{c |}
{cmdab:cumul:ate} 
{cmdab:cumpr:ob} 
{c )-}
{cmdab:h:eight(}{it:#}{cmd:)}
{c -(} 
{cmdab:ce:ntre}
{c |} 
{cmdab:ce:nter}
{c )-} 

{p 12 17 2} 
{cmdab:w:idth(}{it:#}{cmd:)}
{c -(}
{cmd:floor}
{c |}
{cmdab:ceil:ing} 
{c )-}

{p 12 17 2} 
{cmdab:sep:arate(}{it:varname}{cmd:)} 

{p 12 17 2} 
{c -(} 
{cmd:bar}[{cmd:(}{it:bar_options}{cmd:)}] 
{c |} 
{cmd:box}[{cmd:(}{it:box_options}{cmd:)}] 
{c )-} 
{c -(} 
{cmd:iqr}[{cmd:(}{it:#}{cmd:)}] 
{c |} 
{cmdab:pct:ile(}{it:#}{cmd:)} 
{c )-} 
{cmdab:wh:iskers(}{it:rspike_options}{cmd:)} 
{cmdab:out:side}[{cmd:(}{it:scatter_options}{cmd:)}]
{cmd:boffset(}{it:#}{cmd:)}

{p 12 17 2} 
{cmdab:ref:line}
{cmdab:ref:line(}{it:linespec_options}{cmd:)} 
{cmd:reflevel(}{it:egen_function}{cmd:)} 

{p 12 17 2} 
{cmd:variablelabels} 
{cmd:plot(}{it:plot}{cmd:)}
{cmd:addplot(}{it:plot}{cmd:)}
{it:graph_options} ]


{p 8 17 2}
{cmd:stripplot}
{it:varname} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 

{p 12 17 2} 
[ 
{cmd:,}
{cmdab:vert:ical} 
{c -(}
{cmdab:st:ack}
{c |}
{cmdab:cumul:ate} 
{cmdab:cumpr:ob} 
{c )-}
{cmdab:h:eight(}{it:#}{cmd:)}
{c -(} 
{cmdab:ce:ntre}
{c |} 
{cmdab:ce:nter}
{c )-}

{p 12 17 2} 
{cmdab:w:idth(}{it:#}{cmd:)} 
{c -(}
{cmd:floor}
{c |}
{cmdab:ceil:ing} 
{c )-}

{p 12 17 2} 
{cmdab:o:ver(}{it:groupvar}{cmd:)}
{cmdab:sep:arate(}{it:varname}{cmd:)} 

{p 12 17 2} 
{c -(} 
{cmd:bar}[{cmd:(}{it:bar_options}{cmd:)}] 
{c |} 
{cmd:box}[{cmd:(}{it:box_options}{cmd:)}] 
{c )-} 
{c -(} 
{cmd:iqr}[{cmd:(}{it:#}{cmd:)}] 
{c |} 
{cmdab:pct:ile(}{it:#}{cmd:)} 
{c )-} 
{cmdab:wh:iskers(}{it:rspike_options}{cmd:)} 
{cmdab:out:side}[{cmd:(}{it:scatter_options}{cmd:)}]
{cmd:boffset(}{it:#}{cmd:)}

{p 12 17 2} 
{cmdab:ref:line}
{cmdab:ref:line(}{it:linespec_options}{cmd:)} 
{cmd:reflevel(}{it:egen_function}{cmd:)} 

{p 12 17 2} 
{cmd:plot(}{it:plot}{cmd:)} 
{cmd:addplot(}{it:plot}{cmd:)} 
{it:graph_options} 
]


{title:Description}

{p 4 4 2}{cmd:stripplot} plots data as a series of marks against a
single magnitude axis. By default this axis is horizontal. With the
option {cmd:vertical} it is vertical.  Optionally, data points may be
jittered or stacked or cumulated into histogram- or {cmd:dotplot}-like
or distribution or quantile function displays.     Bars showing means
and confidence intervals or boxes showing medians and quartiles may be
added. Reference lines showing means or other summaries of level may
also be added. 


{title:Options}

{it:General appearance}

{p 4 8 2}{cmd:vertical} specifies that the magnitude axis should be
vertical. 

{p 4 8 2}{cmd:stack} specifies that data points with identical values are to
be stacked, as in {cmd:dotplot}, except that by default there is no binning of
data.

{p 4 8 2}{cmd:cumulate} specifies that data points are to be plotted with 
respect to an implicit cumulative frequency scale. 
By default displays resemble cumulative frequency plots; otherwise with 
{cmd:vertical} displays resemble quantile plots. Note that with
{cmd:cumulate} specifying {cmd:connect(L)} [sic] to join points within groups
may be helpful. 

{p 4 8 2}Given {cmd:cumulate} the further option {cmd:cumprob} specifies
use of an implicit cumulative probability scale rather than cumulative
frequency. The precise definition is to plot using (rank - 0.5) /
#values. Plotting each set of values within the same vertical or
horizontal extent permits easy superimposition over box plots. 

{p 4 8 2}{cmd:stack} and {cmd:cumulate} may not be combined. 

{p 4 8 2}{cmd:height(}{it:#}{cmd:)} controls the amount of graph space
taken up by stacked data points under the {cmd:stack} or {cmd:cumulate}
options above. The default is 0.8.  This option will not by itself
change the appearance of a plot for a single variable. Note that the
height may need to be much smaller or much larger than 1 with
{cmd:over()}, given that the latter takes values literally. For example,
if your classes are 0(45)360, 36 might be a suitable height. 

{p 8 8 2}{cmd:centre} or {cmd:center} centres or centers markers for
each variable or group on a hidden line.

{it:Binning} 

{p 4 8 2}{cmd:width(}{it:#}{cmd:)} specifies that values are to be rounded in
classes of specified width. Classes are defined by default by 
{cmd:round(}{it:varname}{cmd:,}{it:width}{cmd:)}. See also the 
{cmd:floor} and {cmd:ceiling} options just below. 

{p 8 8 2}{cmd:floor} or {cmd:ceiling} in conjunction with {cmd:width()} 
specifies rounding by {it:width} {cmd:* floor(}{it:varname/width}{cmd:)}
or {it:width} {cmd:* ceil(}{it:varname/width}{cmd:)} respectively. Only 
one may be specified. (These options are included to give some users the 
minute control they may desire, but if either option produces a marked
difference in your plot, you may be rounding too much.)  

{it:Grouping} 

{p 4 8 2}{cmd:over(}{it:groupvar}{cmd:)} specifies that values of
{it:varname} are to be shown separately by groups defined by
{it:groupvar}. This option may only be specified with a single variable.
If {cmd:stack} is also specified, then note that distinct values of any
numeric {it:groupvar} are assumed to differ by at least 1. Tuning
{cmd:height()} or the prior use of {cmd:egen, group() label} will fix
any problems. See help on {help egen} if desired. 

{p 8 8 2}Note that {cmd:by()} is also available as an alternative or
complement to {cmd:over()}. See the examples for detail on how
{cmd:over()} and {cmd:by()} could be used to show data subdivided by a
cross-combination of categories. 

{p 4 8 2}{cmd:separate()} specifies that data points be shown separately
according to the distinct classes of the variable specified. Commonly,
but not necessarily, this option will be specified together with
{cmd:stack} or {cmd:cumulate}.  Note that this option has no effect on
any error bar or box plot or reference line calculations. 

{it:Added confidence bars or quartile boxes}  

{p 4 8 2}{cmd:bar} specifies that bars be added showing means and
confidence intervals. Bar information is calculated using {cmd:ci}.
{cmd:bar(}{it:bar_options}{cmd:)} may be used to specify details of the
means and confidence intervals. {it:bar_options} are 

{p 8 8 2}Various options of {help ci}: 
{cmdab:l:evel()}, 
{cmdab:p:oisson}, 
{cmdab:b:inomial},   
{cmdab:exa:ct}, 
{cmdab:wa:ld}, 
{cmdab:a:gresti}, 
{cmdab:w:ilson}, 
{cmdab:j:effreys} and 
{cmdab:e:xposure()}. For example, {cmd:bar(binomial jeffreys)} specifies
those options of {cmd:ci}. 

{p 8 8 2}{cmd:mean(}{it:scatter_options}{cmd:)} may be used to control
the rendering of the symbol for the mean. 
For example, {cmd:bar(mean(mcolor(red) ms(sh)))} specifies the use
of red small hollow squares. 

{p 8 8 2}Options of {help twoway rcap} may be used to control the 
appearance of the bar. For example, {cmd:bar(lcolor(red))} specifies
red as the bar colour. 

{p 8 8 2}These kinds of options may be combined. 

{p 4 8 2}{cmd:box} specifies that boxes be added showing medians and
quartiles.  Box information is calculated using {cmd:egen, median()} and
{cmd:egen, pctile()}.  {cmd:box(}{it:box_options}{cmd:)} may be used to
specify options of {help twoway rbar} to control the appearance of the
box. For example, {cmd:box(bfcolor(eltgreen))} specifies {cmd:eltgreen}
as the box fill colour.  The defaults are 
{cmd:bfcolor(none) barwidth(0.4) blwidth(medthin)}. 
Note that the length of each box is the interquartile range or IQR. 

{p 8 8 2}{cmd:iqr}[{cmd:(}{it:#}{cmd:)}] specifies that spikes are to be
added to boxes that extend as far as the largest or smallest value
within {it:#} IQR of the upper or lower quartile. Plain {cmd:iqr}
without argument yields a default of 1.5 for {it:#}. 

{p 8 8 2}{cmd:pctile(}{it:#}{cmd:)} specifies that spikes are to be
added to boxes that extend as far as the {it:#} and 100 - {it:#}
percentiles. 0 and 100 are allowed for {it:#} and are interpreted 
as the minimum and maximum values. 

{p 8 8 2}{cmd:whiskers()} specifies options of {help twoway rspike} that
may be used to modify the appearance of spikes added to boxes. 

{p 8 8 2}{cmd:iqr}, {cmd:iqr()}, {cmd:pctile()} and {cmd:whiskers()}
have no effect without {cmd:box} or {cmd:box()}. {cmd:iqr} or
{cmd:iqr()} may not be combined with {cmd:pctile()}. 

{p 8 8 2}Given an {cmd:iqr} or {cmd:iqr()} or {cmd:pctile()} option, the
extra option {cmd:outside} specifies that values beyond the ends of the
whiskers be shown with the box plots. {cmd:outside()} may also be
specified with options of {help scatter} tuning the display of markers. 
This option is especially useful if strip or dot plots are to be
suppressed in favour of multiple box plots. 

{p 4 8 2}{cmd:bar}[{cmd:()}] and {cmd:box}[{cmd:()}] may not be
combined. 

{p 4 8 2}{cmd:boffset()} may be used to control the position of bars or
boxes.  By default, bars are positioned 0.2 unit to the left of (or
below) the base line for strips, and boxes are positioned under the 
base line for strips.  Negative arguments specify positions to the left
or below of the base line and positive arguments specify positions to
the right or above. 

{it:Added reference lines} 

{p 4 8 2}{cmd:refline} specifies that reference lines are to be shown 
for each group of values (each variable, subdivided by the distinct
values of any variable specified by {cmd:over()}). {cmd:refline} 
may be specified with options that tune the line width, colour,
pattern and style: see (e.g.) help for {help line options}.  
By default reference lines show means, but the option {cmd:reflevel()}
may be used to specify other summaries, so long as the name used
is that of a suitable {help egen} function. {cmd:median} is the most
obvious alternative. 

{it:Other details} 

{p 4 8 2}{cmd:variablelabels} specifies that multiple variables be
labelled by their variable labels. The default is to use variable names. 

{p 4 8 2}{cmd:plot(}{it:plot}{cmd:)} provides a way to add other plots
to the generated graph; see help {help plot_option} (Stata 8 only). 

{p 4 8 2}{cmd:addplot(}{it:plot}{cmd:)} provides a way to add other
plots to the generated graph; see help {help addplot_option} (Stata 9
up). 

{p 4 8 2}{it:graph_options} are options of {help scatter}, including
{cmd:by()}, on which see {help by_option}. Note that {cmd:by(, total)}
is not supported with bars or boxes, nor {cmd:by()} with reference lines. 
{cmd:jitter()} is often helpful. 


{title:Remarks}

{it:General and bibliographic remarks}

{p 4 4 2}There is not a sharp distinction in the literature or in
software implementations between {it:dot plots} and {it:strip plots}.
Commonly, but with many exceptions, a dot plot is drawn as a pointillist
analogue of a histogram. Sometimes, dot plot is used as the name when
data points are plotted in a line, or at most a narrow strip, against a
magnitude axis. Strip plot implementations, as here, usually allow
stacking options, so that dot plots may be drawn as one choice. 

{p 4 4 2}Such plots under these and yet other names go back at least as
far as Langren (1644): see Tufte (1997, p.15) and in much more detail
Friendly {it:et al.} (2010).  Galton (1869, pp.27{c -}28; 1892, 
pp.27{c -}28) gave a schematic dot diagram showing how the heights of a
million men might be plotted.  Jevons (1884), Bateson and Brindley (1892), 
Bateson (1894), Brunt (1917), Shewhart
(1931, 1939), Pearson (1931, 1938), Pearson and Chandra Sekhar (1936),
Shaw (1936), Brinton (1939), Tippett (1943) and Zipf (1949) are other
early sources.  Sasieni and Royston (1996) and Wilkinson (1999) give
general discussions: see Sasieni and Royston (1994) for the first
Stata implementation. 

{p 4 4 2}
Hald (1952) and Box {it:et al.} (1978) used the term {it:dot diagrams}, 
as did Rowntree (1981) and Bl{c ae}sild and Granfeldt (2003). 
Monkhouse and Wilkinson (1952) used the term {it:dispersion diagrams}, 
a term also used for box plot-like displays (e.g. Hogg 1948; Ottaway 1973). 
Miller (1953, 1964) used the terms {it:dispersion graphs} and 
{it:dispersion diagrams}. 
Pearson (1956) gives several examples.  
Dickinson (1963) used the term {it:dispersal graphs}. 
Tukey (1974) used the term {it:dot patterns}. 
Tukey (1977, p.50) showed a dot plot for an example in which a boxplot works poorly. See also Mosteller and Tukey (1977, p.456). 
Chambers {it:et al.} (1983), Becker {it: et al.} (1988), Fox (1990), 
Cleveland (1994), Lee and Tu (1997) and Reimann {it:et al.} (2008) 
used the term {it:one-dimensional scatter plots}. 
H{c a:}rdle (1991) used the term {it:needle plots}. 
Jacoby (1997) used the term {it:univariate scatter plots}, as did 
Edwards (2000), Weissgerber et al. (2015) and Kirk (2016). 
Jacoby also used the term {it:unidimensional scatter plots}. 
Ryan {it:et al.} (1985) discuss their Minitab implementation as {it:dotplots}. 
Krieg {it:et al.} (1988), Velleman (1989), and Hoaglin {it:et al.} (1991) 
are among many others also using the term {it: dot plot} or {it:dotplot}. 
Cumming (2012) used {it:dotplot} for unstacked and {it:dot histogram} 
for stacked plots.
Bradstreet (2012) and Rice and Lumley (2016) used {it:dot chart}.  
Cleveland (1985) used the term {it:point graphs}. 
Computing Resource Center (1985) used the term {it:oneway plots}. 
Feinstein (2002, p.67) used the term {it:one-way graphs}.  
The term {it:line plots} appears in Hill and Dixon (1982), 
Cooper and Weekes (1983), Klemel{c a:} (2009) and Schenemeyer and Drew (2011), 
that of {it:line charts} appears in Robertson (1988), 
and that of {it:linear plots} appears in Hay (1996). 
The term {it:strip plots} (or {it:strip charts}) (e.g. Dalgaard 2002; 
Venables and Ripley 2002; Robbins 2005; Faraway 2005; 
Maindonald and Braun 2003; Few 2012, 2015; Cairo 2016; Cam{c o~}es 2016; 
Hilfiger 2016) appears traceable to work by J.W. and P.A. Tukey (1990).  
The term {it:dit plots} appears in Ellison (1993, 2001). 
The term {it:number lines} or {it:number-line plots} appears in 
Helsel and Hirsch (1992) and Monmonier (1993). See also Monmonier (1996). 
People in neuroscience often plot event times for multiple trials as 
{it:raster plots}: Brillinger and Villa (1997) is a token reference 
from the statistical literature. See Kass {it:et al.} (2014) for more. 
Doane and Tracy (2000) combined dotplots, a beam to indicate data range
and a fulcrum to indicate mean as centre of gravity, as one kind of 
{it:beam and fulcrum display}. 
The term {it:data distribution graph} appears in Robbins (2005). 
The term {it:column scatter plot} for vertical strip plots appears in 
Motulsky (2014) and in Girgis and Mohanty (2012). 
The term {it:stripes plot} appears in Leisch (2010). 
The term {it:barcode plot} or {it:barcode chart} appears in Keen (2010) and Kirk (2012). 
The term {it:circle plots} appears in McDaniel and McDaniel (2012a, 2012b). 
The term {it:Wilkinson dot plots} appears in Chang (2013). 
The term {it:beeswarm plots} appears in Eklund (2013). 
The term {it:instance chart} appears in Kirk (2016). 

{p 4 4 2}
Moroney (1956), 
Wallis and Roberts (1956, p.178), 
Clement and Robertson (1961), 
Williams (1964, 1970), 
Haggett (1965, 1972), 
Draper and Smith (1966), 
Cormack (1971), 
Agterberg (1974), Tufte (1974), 
Wright (1977), 
Smith (1979), 
Green (1981), 
Wetherill (1981, 1982), 
Dobson (1983 and later), 
Light and Pillemer (1984), 
Bentley (1985, 1988), 
Ibrekk and Morgan (1987), 
Chatfield (1988), Siegel (1988), 
Morgan and Henrion (1990), 
Henry (1995), Jongman {it:et al.} (1995), 
Berry (1996), McNeil (1996), Siegel and Morgan (1996), 
Cobb (1998), Griffiths {it:et al.} (1998), 
Bland (2000), Nolan and Speed (2000), Wild and Seber (2000), 
Davis (2002), Dupont (2002), 
Field (2003, 2010, 2016), 
van Belle {it:et al.} (2004), 
Robbins (2005), 
Young {it:et al.} (2006), 
Agresti and Franklin (2007), Morgenthaler (2007),
Sarkar (2008), Warton (2008), 
Theus and Urbanek (2009), 
Whitlock and Schluter (2009, 2015), 
Keen (2010), 
Sokal and Rohlf (2012), 
Ramsey and Schafer (2013),  
Berinato (2016; who also uses the term in another sense: p.30) 
and Wainer (2016) 
are some other references with examples of strip plots. 

{p 4 4 2} 
Siegel (1988) gives an especially lucid discussion of stem-and-leaf
plots presented to maximise their resemblance to both histograms and
strip plots (in the present sense).  His first edition is preferable on
this point to the second edition, Siegel and Morgan (1996).  

{p 4 4 2}
The Federal Reserve publishes predictions of interest rates using dot plots. 
See for illustration and discussion (e.g.) the Economist (2015). 

{p 4 4 2}
Strip plot-like displays on the margins of other graphs (e.g. histograms, 
density plots, scatter plots} are now often known as {it:rugs} 
or {it:rug plots}, 
although their use predates this term. See (e.g.)
Wallis and Roberts (1956, p.178),  
Boneva {it:et al.} (1971), Binford (1972), Daniel (1976),  
Brier and Fienberg (1980), Tukey and Tukey (1981), 
Tufte (1983), Fox (1990),  
Hastie and Tibshirani (1990) (who do use the term),
H{c a:}rdle (1990, 1991), Hastie (1992) and Clark and Pregibon (1992). 
Tufte (1983, p.135) uses the term differently, for a series of plots linked 
together using their marginal distributions.

{p 4 4 2}Hybrid dot-box plots were used by Crowe (1933, 1936), 
Matthews (1936), Hogg (1948),
Monkhouse and Wilkinson (1952), Farmer (1956), Gregory (1963), Lewis
(1975), Matthews (1981), Wilkinson (1992, 2005),  
Ellison (1993, 2001), Wild and Seber (2000),
Quinn and Keough (2002), Young {it:et al.} (2006)
and Hendry and Nielsen (2007). See also Miller (1953, 1964). 

{p 4 4 2}Box plots in widely current forms are best known through the
work of Tukey (1970, 1972, 1977).  Drawing whiskers to particular percentiles,
rather than to data points within so many IQR of the quartiles, was
emphasised by Cleveland (1985), but anticipated by Matthews (1936) 
and Grove (1956) who plotted the interoctile range, meaning between the first
and seventh octiles, as well as the range and interquartile range. 
Dury (1963), Johnson (1975), Myatt (2007) and Myatt and Johnson (2009, 2011) 
showed means as well as minimum, quartiles, median and maximum. 
Bentley (1985, 1988) plotted whiskers to 5 and 95% points. 
Morgan and Henrion (1990, pp.221, 241) and Gotelli and Ellison (2004,
2013, pp.72, 110, 213, 416) plotted whiskers to 10% and 90% points. 
Altman (1991, pp.34, 63) plotted whiskers to 2.5% and 97.5% points. 
Reimann et al. (2008, pp.46{c -}47) plotted whiskers to 5% and 95% and 
2% and 98% points.

{p 4 4 2}Parzen (1979a, 1979b, 1982) hybridised box and quantile plots as 
quantile-box plots. See also (e.g.) Shera (1991), 
Militk{c y'} and Meloun (1993), Meloun and Militk{c y'} (1994). 
Note, however, that the quantile box plot of Keen (2010)
is just a box plot with whiskers extending to the extremes. 
In contrast, the quantile box plots of JMP are evidently box plots with 
marks at 0.5%, 2.5%, 10%, 90%, 97.5%, 99.5%: 
see Sall {it:et al.} (2014, pp.143{c -}4).  

{p 4 4 2}Similar ideas go back much further.  Cox (2009) gives various
references. Bibby (1986, pp.56, 59) gave even earlier references to
their use by A.L. Bowley in his lectures about 1897 and to his
recommendation (Bowley, 1910, p.62; 1952, p.73) to use minimum and
maximum and 10, 25, 50, 75 and 90% points as a basis for graphical
summary. Keen (2010) and Martinez {it:et al.} (2011) also discuss 
several variants of box plots. 

{p 4 4 2}Plots showing values as deviations from means were given by
Shewhart (1931), Pearson (1956),  Davis (2002, p.81), 
Grafen and Hails (2002, pp.4{c -}7),
and Whitlock and Schluter (2009, pp.396, 519; 2015, p.464 and cf.p.609).  
A related plot, which
seems especially popular in clinical oncology, is the waterfall plot (or
waterfall chart). Common examples show variations in change in tumour
dimensions during clinical trials.  See (e.g.) Gilder (2012). Note,
however, that waterfall plots or charts also refer to at least two quite
different plots in business and in the analysis of spectra. 

{p 4 4 2}Quantile plots were discussed by Cox (1999, 2005), including 
historical comments. Further examples long in use for environmental applications
are hypsometric curves (Clarke 1966) and flow duration curves (Searcy 1959).  

{p 4 4 2}Dot charts (also sometimes called dot plots) in the sense of
Cleveland (1984, 1994), as implemented in {help graph dot}, are quite
distinct. Various authors (e.g. Lang and Secic 2006, Zuur {it:et al.} 2007, 
Sarkar 2008, Mitchell 2010, Chang 2013, Kirk 2016) call these Cleveland dot charts or dot plots. 
See also (e.g.) Becker {it:et al.} (1988), Helsel and Hirsch (1992), 
Henry (1995), Jacoby (1997, 2006), Sinacore (1997), Harrell (2001, 2015), 
Cox (2008), Myatt and Johnson (2009), Martinez {it:et al.} (2011), 
Wainer (2014, 2016), Few (2015) and Hilfiger (2016). 

{p 4 4 2}See also Cox (2004) for a general discussion of graphing
distributions in Stata; Cox (2007) for an implementation of
stem-and-leaf plots that bears some resemblance to what is possible with
{cmd:stripplot}; and Cox (2009, 2013) on how to draw box plots using
{help twoway}. 

{it:A note for experimental design people} 

{p 4 4 2}There is no connection between {cmd:stripplot} and the strip
plots discussed in design of experiments. 

{it:A comparison between} {cmd:stripplot}{it:,} {cmd:gr7, oneway} {it:and} {cmd:dotplot}

{p 4 8 2}{cmd:stripplot} may have either horizontal or vertical
magnitude axis.  With {cmd:gr7, oneway} the magnitude axis is always
horizontal.  With {cmd:dotplot} the magnitude axis is always vertical. 

{p 4 8 2}{cmd:stripplot} and {cmd:dotplot} put descriptive text on the
axes.  {cmd:gr7, oneway} puts descriptive text under each line of marks.

{p 4 8 2}{cmd:stripplot} and {cmd:dotplot} allow any marker symbol to be
used for the data marks.  {cmd:gr7, oneway} always shows data marks as
short vertical bars, unless {cmd:jitter()} is specified. 

{p 4 8 2}{cmd:stripplot} and {cmd:dotplot} interpret {cmd:jitter()} in
the same way as does {cmd:scatter}.  {cmd:gr7, oneway} interprets
{cmd:jitter()} as replacing short vertical bars by sets of dots.

{p 4 8 2}{cmd:stripplot} and {cmd:dotplot} allow tuning of
{cmd:xlabel()}.  {cmd:gr7, oneway} does not allow such tuning: the
minimum and maximum are always shown.  Similarly, {cmd:stripplot} and
{cmd:dotplot} allow the use of {cmd:xline()} and {cmd:yline()}. 

{p 4 8 2}{cmd:dotplot} uses only one colour in the body of the graph.
{cmd:stripplot} allows several colours in the body of the graph with its
{cmd:separate()} option.  {cmd:gr7, oneway} uses several colours with
several variables. 

{p 4 8 2}There is no equivalent with {cmd:stripplot} or {cmd:dotplot} to
{cmd:gr7, oneway rescale}, which  stretches each set of data marks to
extend over the whole horizontal range of the graph.  Naturally, users
could standardise a bunch of variables in some way before calling
{cmd:stripplot} or {cmd:dotplot}. 

{p 4 8 2}{cmd:stripplot} and {cmd:dotplot} with option
{cmd:over(}{it:groupvar}{cmd:)} do not require data to be sorted by
{it:groupvar}. The equivalent {cmd:gr7, oneway by(}{it:groupvar}{cmd:)}
does require this. 

{p 4 8 2}{cmd:stripplot} allows the option {cmd:by(}{it:byvar}{cmd:)},
producing separate graph panels according to the groups of {it:byvar}.
{cmd:dotplot} does not allow the option {cmd:by()}.  {cmd:gr7, oneway}
allows the option {cmd:by(}{it:byvar}{cmd:)}, producing separate
displays within a single panel. It does not take the values of
{it:byvar} literally: displays for values 1, 2 and 4 will appear equally
spaced. 

{p 4 8 2}{cmd:stripplot} with the {cmd:stack} option produces a variant
on {cmd:dotplot}. There is by default no binning of data: compare
{cmd:dotplot, nogroup}. Binning may be accomplished with the
{cmd:width()} option so that classes are defined by
{cmd:round(}{it:varname}{cmd:/}{it:width}) or optionally by {it:width}
{cmd:* floor(}{it:varname/width}{cmd:)} or {it:width} 
{cmd:* ceil(}{it:varname/width}{cmd:)}: contrast {cmd:dotplot, ny()}.
Conversely, stacking may in effect be suppressed in {cmd:dotplot} by
setting {cmd:nx()} sufficiently large. 

{p 4 8 2}{cmd:stripplot} has options for showing bars as confidence intervals 
or boxes showing medians and quartiles; and for showing means, medians,
etc. by horizontal or vertical reference lines. 
{cmd:gr7, oneway box} shows Tukey-style box plots.
{cmd:dotplot} allows the showing of mean +/- SD or median and quartiles by
horizontal lines. 


{title:Examples} 

{p 4 8 2}(Stata's auto data){p_end}
{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. stripplot mpg}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, aspect(0.05)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) by(foreign)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) vertical}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) vertical stack}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) vertical stack h(0.4)}

{p 4 8 2}{cmd:. gen pipe = "|"}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, ms(none) mlabpos(0) mlabel(pipe) mlabsize(*2) stack}{p_end}
{p 4 8 2}{cmd:. stripplot price, over(rep78) ms(none) mla(pipe) mlabpos(0)}{p_end}
{p 4 8 2}{cmd:. stripplot price, over(rep78) w(200) stack h(0.4)}

{p 4 8 2}(5 here is empirical: adjust for your variable){p_end}
{p 4 8 2}{cmd:. gen price1 = price - 5}{p_end}
{p 4 8 2}{cmd:. gen price2 = price + 5}{p_end}
{p 4 8 2}{cmd:. stripplot price, over(rep78) box ms(none) addplot(rbar price1 price2 rep78, horizontal barw(0.2) bcolor(gs6))}

{p 4 8 2}{cmd:. stripplot mpg, over(rep78) stack h(0.5) bar(lcolor(red))}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box boffset(-0.3)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box(bfcolor(eltgreen)) boffset(-0.3)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box(bfcolor(eltgreen) barw(0.2)) boffset(-0.2) stack h(0.5)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box(bfcolor(black) blcolor(white) barw(0.2)) boffset(-0.2) stack h(0.5)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box(bfcolor(black) blcolor(white) barw(0.2)) iqr boffset(-0.2) stack h(0.5)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) box(bfcolor(black) blcolor(white) barw(0.2)) pctile(10) whiskers(recast(rbar) bcolor(black) barw(0.02)) boffset(-0.2) stack h(0.5)}

{p 4 8 2}{cmd:. gen digit = mod(mpg, 10)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, stack vertical mla(digit) mlabpos(0) ms(i) over(foreign) height(0.2) yla(, ang(h)) xla(, noticks)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, stack vertical mla(digit) mlabpos(0) ms(i) by(foreign) yla(, ang(h))}

{p 4 8 2}{cmd:. stripplot mpg, over(rep78) separate(foreign) stack}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, by(rep78) separate(foreign) stack}

{p 4 8 2}(fulcrums to mark means as centres of gravity){p_end}
{p 4 8 2}{cmd:. gen rep78_1 = rep78 - 0.1}{p_end}
{p 4 8 2}{cmd:. egen mean = mean(mpg), by(foreign rep78)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) by(foreign, compact) addplot(scatter rep78_1 mean, ms(T)) stack}

{p 4 8 2}{cmd:. egen mean_2 = mean(mpg), by(rep78)}{p_end}
{p 4 8 2}{cmd:. gen rep78_L = rep78 - 0.1}{p_end}
{p 4 8 2}{cmd:. gen rep78_U = rep78 - 0.02}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78) stack addplot(pcarrow rep78_L mean_2 rep78_U mean_2, msize(medlarge) barbsize(medlarge)) yla(, grid)}

{p 4 8 2}{cmd:. clonevar rep78_2 = rep78}{p_end}
{p 4 8 2}{cmd:. replace rep78_2 = cond(foreign, rep78 + 0.15, rep78 - 0.15)}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(rep78_2) separate(foreign) yla(1/5) jitter(1 1)}

{p 4 8 2}{cmd:. logit foreign mpg}{p_end}
{p 4 8 2}{cmd:. predict pre}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(foreign) stack ms(sh) height(0.15) addplot(mspline pre mpg, bands(20))}

{p 4 8 2}(reference lines where {cmd:by()} would seem natural){p_end}
{p 4 8 2}({cmd:labmask} (Cox 2008) would be another solution for label fix){p_end}
{p 4 8 2}{cmd:. egen group = group(foreign rep78)}{p_end}
{p 4 8 2}{cmd:. replace group = cond(group <= 5, group, group + 1)}{p_end}
{p 4 8 2}{cmd:. label def group 7 "3" 8 "4" 9 "5", modify}{p_end}
{p 4 8 2}{cmd:. lab val group group}{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(group) vertical cumul cumprob refline box centre  mcolor(blue) xmla(3 "Domestic" 8 "Foreign", tlength(*7) tlc(none) labsize(medium)) xtitle("") xli(6, lc(gs12) lw(vthin))}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. egen median = median(mpg), by(foreign)}{p_end}
{p 4 8 2}{cmd:. egen loq = pctile(mpg), by(foreign) p(25)}{p_end}
{p 4 8 2}{cmd:. egen upq = pctile(mpg) , by(foreign) p(75)}{p_end}
{p 4 8 2}{cmd:. egen mean = mean(mpg), by(foreign) }{p_end}
{p 4 8 2}{cmd:. egen min = min(mpg)}{p_end}
{p 4 8 2}{cmd:. egen n = count(mpg), by(foreign) }{p_end}
{p 4 8 2}{cmd:. gen shown = "{it:n} = " + string(n) }{p_end}
{p 4 8 2}{cmd:. gen foreign2 = foreign + 0.15}{p_end}
{p 4 8 2}{cmd:. gen foreign3 = foreign - 0.15 }{p_end}
{p 4 8 2}{cmd:. gen showmean = string(mean, "%2.1f") }{p_end}
{p 4 8 2}{cmd:. stripplot mpg, over(foreign) box(barw(0.2)) centre cumul}{p_end}
{p 8 8 2}{cmd:cumprob vertical height(0.4)}{p_end}
{p 8 8 2}{cmd:addplot(scatter median loq upq foreign2, ms(none ..)}{p_end}
{p 8 8 2}{cmd:mla(median loq upq) mlabc(blue ..) mlabsize(*1.2 ..) ||}{p_end}
{p 8 8 2}{cmd:scatter mean foreign3, ms(none) mla(showmean) mlabc(orange) mlabsize(*1.2) mlabpos(9) ||}{p_end}
{p 8 8 2}{cmd:scatter min foreign, ms(none) mla(shown) mlabc(black) mlabsize(*1.2) mlabpos(6))}{p_end}
{p 8 8 2}{cmd:xsc(r(. 1.2)) xla(, noticks)}{p_end}

{p 4 8 2}(Stata's blood pressure data){p_end}
{p 4 8 2}{cmd:. sysuse bplong, clear}{p_end}
{p 4 8 2}{cmd:. egen group = group(age sex), label}{p_end}
{p 4 8 2}{cmd:. stripplot bp*, bar over(when) by(group, compact col(1) note("")) ysc(reverse) subtitle(, pos(9) ring(1) nobexpand bcolor(none) placement(e)) ytitle("") xtitle(Blood pressure (mm Hg))}

{p 4 8 2}(Stata's US city temperature data){p_end}
{p 4 8 2}{cmd:. sysuse citytemp, clear}{p_end}
{p 4 8 2}{cmd:. label var tempjan "Mean January temperature ({&degree}F)"}{p_end}
{p 4 8 2}{cmd:. stripplot tempjan, over(region) cumul vertical yla(14 32 50 68 86, ang(h)) refline centre}{p_end}
{p 4 8 2}{cmd:. stripplot tempjan, over(region) cumul vertical yla(14 32 50 68 86, ang(h) grid) refline(lc(red) lw(medium)) centre}

{p 4 8 2}{cmd:. gen id = _n}{p_end}
{p 4 8 2}{cmd:. reshape long temp, i(id) j(month) string}{p_end}
{p 4 8 2}{cmd:. replace month = cond(month == "jan", "January", "July")}{p_end}
{p 4 8 2}{cmd:. label var temp "Mean temperature ({&degree}F)"}{p_end}
{p 4 8 2}{cmd:. stripplot temp, over(region) by(month) cumul vertical yla(14 32 50 68 86, ang(h)) bar centre}{p_end}
{p 4 8 2}{cmd:. stripplot temp, over(region) by(month) cumul cumpr vertical yla(14 32 50 68 86, ang(h)) box(barw(0.5) blcolor(gs12)) height(0.4) centre}

{p 4 8 2}{cmd:. gen tempC = (5/9) * temp - 32}{p_end}
{p 4 8 2}{cmd:. label var tempC "Mean temperature ({&degree}C)"}{p_end}
{p 4 8 2}{cmd:. stripplot tempC, over(division) by(month, xrescale note("whiskers to 5 and 95% points")) xla(, ang(h)) box pctile(5) outside(ms(oh) mcolor(red)) ms(none)}
 

{title:Acknowledgments}

{p 4 4 2}
Philip Ender helpfully identified a bug. 
William Dupont offered encouragement. 
Kit Baum nudged me into implementing {cmd:separate()}. 
Maarten Buis made a useful suggestion about this help. 
Ron{c a'}n Conroy suggested adding whiskers. He also found two bugs. 
Marc Kaulisch asked a question which led to more emphasis on the use of {cmd:by()} and the blood pressure example.
David Airey found another bug. 
Oliver Jones asked a question which led to an example of the use of {cmd:twoway rbar} to mimic pipe or barcode symbols. 
Fredrik Norstr{c o:}m found yet another bug. 
Marcello Pagano verified the 1966 Draper and Smith reference. 
Dionyssios Mintzopoulos and Judith Abrams underlined the value of reference lines like those in {cmd:dotplot}, but drawn as such. 
Vince Wiggins and David Airey gave helpful and encouraging 
suggestions on a related program. 
Frank Harrell also made encouraging remarks. 
Alona Armstrong provided the 2015 Weissgerber {it:et al.} reference.  
James Sanders, William Lisowski, Eric Booth and Chinh Nguyen helped to  
identify and solve a problem with box line widths that were 
sometimes much too small to be visible. 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:References} 

{p 4 8 2}Agresti, A. and C. Franklin. 2007. 
{it:Statistics: The Art and Science of Learning from Data.} 
Upper Saddle River, NJ: Pearson Prentice Hall. (later editions 2009, 2013)  

{p 4 8 2}Agterberg, F.P. 1974. 
{it:Geomathematics: Mathematical Background and Geo-Science Applications.} 
Amsterdam: Elsevier. See p.178. 

{p 4 8 2}Altman, D.G. 1991. 
{it:Practical Statistics in Medical Research.} 
London: Chapman and Hall. 

{p 4 8 2}Bateson, W. 1894. 
{it:Materials for the Study of Variation Treated with Especial Regard to Discontinuity in the Origin of Species.} 
London: Macmillan (Reprint 1992. Baltimore: Johns Hopkins University Press) 
(see p.39, repeating one graph from Bateson and Brindley).  

{p 4 8 2}Bateson, W. and H.H. Brindley. 1892. On some cases of 
variation in secondary sexual characters, statistically examined. 
{it:Proceedings of the Zoological Society of London} 
60: 585{c -}594  (see pp.591{c -}593). 

{p 4 8 2}Becker, R.A., J.M. Chambers, and A.R. Wilks. 1988. 
{it:The New S language: A Programming Environment for Data Analysis and Graphics.} 
Pacific Grove, CA: Wadsworth and Brooks/Cole. 

{p 4 8 2}Bentley, J.L. 1985. 
Programming pearls: selection. 
{it:Communications of the ACM} 28: 1121{c -}1127.  

{p 4 8 2}Bentley, J.L. 1988. 
{it:More Programming Pearls: Confessions of a Coder.} 
Reading, MA: Addison-Wesley.  

{p 4 8 2}Berinato, S. 2016. 
{it:Good Charts: The HBR Guide to Making Smarter, More Persuasive Data Visualizations.} 
Boston, MA: Harvard Business Review Press. 

{p 4 8 2}Berry, D.A. 1996. {it:Statistics: A Bayesian Perspective.} 
Belmont, CA: Duxbury. 

{p 4 8 2}Bibby, J. 1986. 
{it:Notes Towards a History of Teaching Statistics.} 
Edinburgh: John Bibby (Books). 

{p 4 8 2}Binford, L.R. 1972. 
Contemporary model building: paradigms and the current state of 
Palaeolithic research. In Clarke, D.L. (ed) 
{it:Models in Archaeology.} 
London: Methuen, 109{c -}166. 

{p 4 8 2}
Bl{c ae}sild, P. and J. Granfeldt. 2003. 
{it:Statistics with Applications in Biology and Geology.} 
Boca Raton, FL: Chapman and Hall/CRC. 

{p 4 8 2}Bland, M. 2000. 
{it:An Introduction to Medical Statistics.}
Oxford: Oxford University Press. (fourth edition 2015)  

{p 4 8 2}Boneva, L.I., D.G. Kendall and I. Stefanov. 1971. 
Spline transformations: three new diagnostic aids for the statistical 
data-analyst. 
{it:Journal of the Royal Statistical Society Series B} 
33: 1{c -}71. (See p.35.)                               

{p 4 8 2}Bowley, A.L. 1910. 
{it:An Elementary Manual of Statistics.} 
London: Macdonald and Evans. (seventh edition 1952) 

{p 4 8 2}Box, G.E.P., W.G. Hunter and J.S. Hunter. 1978. 
{it: Statistics for Experimenters: An Introduction to Design, Data Analysis, and Model Building.}
New York: John Wiley. (second edition 2005)

{p 4 8 2}Bradstreet, T.E. 2012.
Grables: Visual displays that combine the best attributes of graphs 
and tables. 
In Krause, A. and O'Connell, M. (eds) 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences.} 
New York: Springer, 41{c -}69.  

{p 4 8 2}Brier, S.S. and S.E. Fienberg. 1980.  
Recent econometric modelling of crime and punishment: 
support for the deterrence hypothesis? 
In Fienberg, S.E. and A.J. Reiss Jr (eds)
{it:Indicators of Crime and Criminal Justice: Quantitative Studies.} 
Washington, DC: US Department of Justice Bureau of Justice Statistics, 
82{c -}97.  

{p 4 8 2}Brillinger, D.R. and A.E.P. Villa. 1997. 
Assessing connections in networks of biological neurons. 
In Brillinger, D.R., L.T. Fernholz and S. Morgenthaler (eds) 
{it:The Practice of Data Analysis: Essays in Honor of John W. Tukey.}
Princeton, NJ: Princeton University Press, 77{c -}92. 

{p 4 8 2}Brinton, W.C. 1939. 
{it:Graphic Presentation.} 
New York: Brinton Associates. 

{p 4 8 2}Brunt, D. 1917. 
{it:The Combination of Observations.} 
London: Cambridge University Press. 

{p 4 8 2}Cairo, A. 2016. 
{it:The Truthful Art: Data, Charts, and Maps for Communication.} 
San Francisco, CA: New Riders. 

{p 4 8 2}Cam{c o~}es, J. 2016. 
{it:Data at Work: Best Practices for Creating Effective Charts and Information Graphics in Microsoft Excel.} San Francisco, CA: New Riders. 

{p 4 8 2}Chambers, J.M., W.S. Cleveland, B. Kleiner and P.A. Tukey. 1983. 
{it:Graphical Methods for Data Analysis.} Belmont, CA: Wadsworth. 

{p 4 8 2}Chang, W. 2013. 
{it:R Graphics Cookbook.} Sebastopol, CA: O'Reilly. 

{p 4 8 2}Chatfield, C. 1988. 
{it:Problem Solving: A Statistician's Guide.} London: Chapman & Hall.
(second edition 1995) 

{p 4 8 2}Clark, L.A. and D. Pregibon. 1992. Tree-based models. 
In Chambers, J.M. and T. Hastie (eds) 
{it:Statistical Models in S.} 
Pacific Grove, CA: Wadsworth and Brooks/Cole, 377{c -}419. 

{p 4 8 2}Clarke, J.I. 1966. 
Morphometry from maps. 
In Dury, G.H. (ed.) {it:Essays in Geomorphology.}
London: Heinemann, 235{c -}274. 

{p 4 8 2}Clement, A.G. and R.H.S. Robertson. 1961. 
{it:Scotland's Scientific Heritage.} Edinburgh: Oliver and Boyd. 

{p 4 8 2}Cleveland, W.S. 1984. Graphical methods for data presentation: full
scale breaks, dot charts, and multibased logging. 
{it:American Statistician} 38: 270{c -}80.

{p 4 8 2}Cleveland, W.S. 1985. {it:Elements of Graphing Data.} 
Monterey, CA: Wadsworth. 

{p 4 8 2}Cleveland, W.S. 1994. {it:Elements of Graphing Data.} 
Summit, NJ: Hobart Press. 

{p 4 8 2}Cobb, G.W. 1998. 
{it:Introduction to Design and Analysis of Experiments.} 
New York: Springer. 

{p 4 8 2}Computing Resource Center. 1985. {it:STATA/Graphics User's Guide.} 
Los Angeles, CA: Computing Resource Center. 

{p 4 8 2}Cooper, R.A. and A.J. Weekes. 1983. 
{it:Data, Models and Statistical Analysis.} 
Deddington, Oxford: Philip Allan. 

{p 4 8 2}Cormack, R.M. 1971. 
{it:The Statistical Argument.} 
Edinburgh: Oliver and Boyd. 

{p 4 8 2}Cox, N.J. 1999. 
Quantile plots, generalized. 
{it:Stata Technical Bulletin} 51: 16{c -}18. 

{p 4 8 2}Cox, N.J. 2004. 
Speaking Stata: Graphing distributions. 
{it:Stata Journal} 4(1): 66{c -}88. 

{p 4 8 2}Cox, N.J. 2005. 
Speaking Stata: The protean quantile plot. 
{it:Stata Journal} 5(3): 442{c -}460. 
 
{p 4 8 2}Cox, N.J. 2007. 
Speaking Stata: Turning over a new leaf. 
{it:Stata Journal} 7(3): 413{c -}433. 

{p 4 8 2}Cox, N.J. 2008. 
Speaking Stata: Between tables and graphs
{it:Stata Journal} 8(2): 269{c -}289. 

{p 4 8 2}Cox, N.J. 2009. 
Speaking Stata: Creating and varying box plots. 
{it:Stata Journal} 9(3): 478{c -}496. 

{p 4 8 2}Cox, N.J. 2013. 
Speaking Stata: Creating and varying box plots: correction. 
{it:Stata Journal} 13(2): 398{c -}400. 

{p 4 8 2}Crowe, P.R. 1933. 
The analysis of rainfall probability: A graphical method and its application to European data. 
{it:Scottish Geographical Magazine} 49: 73{c -}91.

{p 4 8 2}Crowe, P.R. 1936. 
The rainfall regime of the Western Plains. 
{it:Geographical Review} 26: 463{c -}484.  

{p 4 8 2}Cumming, G. 2012. 
{it:Understanding the New Statistics: Effect Sizes, Confidence Intervals, and Meta-analysis.} 
New York: Routledge. 

{p 4 8 2}Dalgaard, P. 2002. {it:Introductory Statistics with R.} 
New York: Springer. 

{p 4 8 2}Daniel, C. 1976. 
{it:Applications of Statistics to Industrial Experimentation.} 
New York: John Wiley. 

{p 4 8 2}Davis, J.C. 2002. 
{it:Statistics and Data Analysis in Geology.} 
New York: John Wiley.

{p 4 8 2}Dickinson, G.C. 1963. 
{it:Statistical Mapping and the Presentation of Statistics.} 
London: Edward Arnold. (second edition 1973) 

{p 4 8 2}Doane, D.P. and R.L. Tracy. 2000. 
Using beam and fulcrum displays to explore data. 
{it:American Statistician} 54: 289{c -}290.

{p 4 8 2}Dobson, A.J. 1983. 
{it:An Introduction to Statistical Modelling.} 
London: Chapman and Hall. 

{p 4 8 2}Dobson, A.J. 1990. 
{it:An Introduction to Generalized Linear Models.} 
London: Chapman and Hall. 

{p 4 8 2}Dobson, A.J. 2002. 
{it:An Introduction to Generalized Linear Models.}
Boca Raton, FL: Chapman and Hall/CRC Press. 

{p 4 8 2}Dobson, A.J. and Barnett, A.G. 2008. 
{it:An Introduction to Generalized Linear Models.}
Boca Raton, FL: CRC Press. 

{p 4 8 2}Draper, N.R. and H. Smith. 1966. 
{it:Applied Regression Analysis.} 
New York: John Wiley. (later editions 1981, 1998) 

{p 4 8 2}Dupont, W.D. 2002. 
{it:Statistical Modelling for Biomedical Researchers.} 
Cambridge: Cambridge University Press (second edition 2009) 

{p 4 8 2}Dury, G.H. 1963. 
{it:The East Midlands and the Peak.} 
London: Thomas Nelson. 

{p 4 8 2}The Economist. 2015. 
The Fed's interest-rate projections: Dotty. June 13, p.74 UK edition. 
{browse "http://www.economist.com/news/finance-and-economics/21654095-chart-intended-provide-insight-actually-sows-confusion-dotty":online}

{p 4 8 2}Edwards, D. 2000. 
{it:Introduction to Graphical Modelling.} 
New York: Springer. 

{p 4 8 2}Eklund, A. 2013. 
Package beeswarm. 
{browse "http://cran.r-project.org/web/packages/beeswarm/beeswarm.pdf":http://cran.r-project.org/web/packages/beeswarm/beeswarm.pdf}
[accessed 16 April 2013] 

{p 4 8 2}Ellison, A.M. 1993. 
Exploratory data analysis and graphic display. 
In Scheiner, S.M. and J. Gurevitch (eds) 
{it:Design and Analysis of Ecological Experiments.} 
New York: Chapman & Hall, 14{c -}45. 

{p 4 8 2}Ellison, A.M. 2001. 
Exploratory data analysis and graphic display. 
In Scheiner, S.M. and J. Gurevitch (eds) 
{it:Design and Analysis of Ecological Experiments.} 
New York: Oxford University Press, 37{c -}62. 

{p 4 8 2}Faraway, J.J. 2005. {it:Linear Models with R.} 
Boca Raton, FL: Chapman and Hall/CRC. 

{p 4 8 2}Farmer, B.H. 1956. 
Rainfall and water-supply in the Dry Zone of Ceylon. 
In Steel, R.W. and C.A. Fisher (eds) 
{it:Geographical Essays on British Tropical Lands.}
London: George Philip, 227{c -}268. 

{p 4 8 2}Feinstein, A.R. 2002. {it:Principles of Medical Statistics.} 
Boca Raton, FL: Chapman and Hall/CRC. 

{p 4 8 2}Few, S. 2012. 
{it:Show Me the Numbers: Designing Tables and Graphs to Enlighten.} 
Burlingame, CA: Analytics Press. 

{p 4 8 2}Few, S. 2015. 
{it:Signal: Understanding What Matters in a World of Noise.} 
Burlingame, CA: Analytics Press. 

{p 4 8 2}Field, R. 2003. The handling and presentation of geographical 
data. In Clifford, N. and G. Valentine (eds) 
{it:Key Methods in Geography}. 
London: SAGE, 309{c -}341. 

{p 4 8 2}Field, R. 2010. Data handling and representation. 
In Clifford, N., S. French and G. Valentine (eds) 
{it:Key Methods in Geography}. 
London: SAGE, 317{c -}349. 

{p 4 8 2}Field, R. 2016. Exploring and presenting geographical data. 
In Clifford, N., M. Cope, T. Gillespie and S. French (eds) 
{it:Key Methods in Geography}. 
London: SAGE, 550{c -}580. 

{p 4 8 2}
Fox, J. 1990. Describing univariate distributions. 
In Fox, J. and J. S. Long (eds) 
{it:Modern Methods of Data Analysis.} 
Newbury Park, CA: SAGE, 58{c -}125. 

{p 4 8 2}Friendly, M., P. Valero-Mora and J.I. Ulargui. 2010.
The first (known) statistical graph: Michael Florent van Langren and the "secret" of longitude.
{it:American Statistician} 64: 174{c -}184. (supplementary materials online) 

{p 4 8 2}Galton, F. 1869. 
{it:Hereditary Genius: An Inquiry into its Laws and Consequences.}
London: Macmillan. (second edition 1892) 

{p 4 8 2}Gilder, K. 2012.
Statistical graphics in clinical oncology.                        
In Krause, A. and O'Connell, M. (eds) 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences.} 
New York: Springer, 173{c -}198.  

{p 4 8 2}Girgis, I.G. and S. Mohanty. 2012.
Graphical data exploration in QT model building and cardiovascular drug safety. 
In Krause, A. and O'Connell, M. (eds) 
{it:A Picture is Worth a Thousand Tables: Graphics in Life Sciences.} 
New York: Springer, 255{c -}271.  

{p 4 8 2}Gotelli, N.J. and A.M. Ellison. 2004 (second edition 2013). 
{it:A Primer of Ecological Statistics.} Sunderland, MA: Sinauer. 

{p 4 8 2}
Grafen, A. and R. Hails. 2002. 
{it:Modern Statistics for the Life Sciences.} 
Oxford: Oxford University Press. 

{p 4 8 2}
Green, P.J. 1981. 
Peeling bivariate data. 
In Barnett, V. (ed.) {it:Interpreting Multivariate Data.} 
Chichester: John Wiley, 3{c -}19. 

{p 4 8 2}Gregory, S. 1963. {it:Statistical Methods and the Geographer.} 
London: Longmans. (later editions 1968, 1973, 1978; publisher later Longman)

{p 4 8 2}Griffiths, D., W.D. Stirling and K.L. Weldon. 1998. 
{it:Understanding Data: Principles and Practice of Statistics.} 
Brisbane: John Wiley. 

{p 4 8 2}
Grove, A.T. 1956. Soil erosion in Nigeria. In Steel, R.W. and C.A. Fisher (eds)
{it:Geographical Essays on British Tropical Lands.}
London: George Philip, 79{c -}111.

{p 4 8 2}
Haggett, P. 1965. 
{it:Locational Analysis in Human Geography.} 
London: Edward Arnold. 

{p 4 8 2}
Haggett, P. 1972. 
{it:Geography: A Modern Synthesis.} 
New York: Harper and Row. 

{p 4 8 2}Hald, A. 1952. 
{it:Statistical Theory with Engineering Applications.} 
New York: John Wiley.

{p 4 8 2}H{c a:}rdle, W. 1990. 
{it:Applied Nonparametric Regression.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}H{c a:}rdle, W. 1991. 
{it:Smoothing Techniques with Implementation in S.}
New York: Springer. 

{p 4 8 2}Harrell, F.E. 2001. 
{it:Regression Modeling Strategies: With Applications to Linear Models, Logistic Regression, and Survival Analysis}.
New York: Springer. 
    
{p 4 8 2}Harrell, F.E. 2015. 
{it:Regression Modeling Strategies: With Applications to Linear Models, Logistic and Ordinal Regression, and Survival Analysis}.
Cham: Springer. 

{p 4 8 2}Hastie, T. 1992. Generalized additive models. 
In Chambers, J.M. and T. Hastie (eds) 
{it:Statistical Models in S.} 
Pacific Grove, CA: Wadsworth and Brooks/Cole, 249{c -}307. 

{p 4 8 2}Hastie, T.J. and R.J. Tibshirani. 1990. 
{it:Generalized Additive Models.} 
London: Chapman and Hall. 

{p 4 8 2}Hay, I. 1996. 
{it:Communicating in Geography and the Environmental Sciences.}
Melbourne: Oxford University Press. (later editions 2002, 2006, 2012) 

{p 4 8 2}Helsel, D.R. and R.M. Hirsch. 1992. 
{it:Statistical Methods in Water Resources.} 
Amsterdam: Elsevier. 

{p 4 8 2}Hendry, D.F. and B. Nielsen. 2007. 
{it:Econometric Modeling: A Likelihood Approach.} 
Princeton, NJ: Princeton University Press. 

{p 4 8 2}Henry, G.T. 1995. 
{it:Graphing Data: Techniques for Display and Analysis.}
Thousand Oaks, CA: SAGE. 
See pp.5, 133, 137, 139, 141 (strip plots); 42, 68 (Cleveland dot charts). 

{p 4 8 2}Hilfiger, J.J. 2016.
{it:Graphing Data with R.} 
Sebastopol, CA: O'Reilly. 

{p 4 8 2}Hill, M. and W.J. Dixon. 1982. 
Robustness in real life: a study of clinical laboratory data.
{it:Biometrics} 38: 377{c -}396.

{p 4 8 2}Hoaglin, D.C., F. Mosteller and J.W. Tukey (eds). 2001. 
{it:Fundamentals of Exploratory Analysis of Variance.} 
New York: John Wiley. 

{p 4 8 2}Hogg, W.H. 1948. 
Rainfall dispersion diagrams: a discussion of their advantages and
disadvantages. 
{it:Geography} 33: 31{c -}37. 

{p 4 8 2}Ibrekk, H. and M.G. Morgan. 1987. 
Graphical communication of uncertain quantities to nontechnical people. 
{it:Risk Analysis} 7: 519{c -}529. 

{p 4 8 2}
Jacoby, W.G. 1997. 
{it:Statistical Graphics for Univariate and Bivariate Data.} 
Thousand Oaks, CA: SAGE. 

{p 4 8 2}
Jacoby, W.G. 2006. 
The dot plot: a graphical display for labeled quantitative values.
{it:The Political Methodologist} 14(1): 6{c -}14.

{p 4 8 2}
Jevons, W.S. 1884. 
{it:Investigations in Currency and Finance.} 
London: Macmillan. 

{p 4 8 2}
Johnson, B.L.C. 1975. 
{it:Bangladesh.} London: Heinemann Educational. 

{p 4 8 2}
Jongman, R.H.G., C.J.F. ter Braak and O.F.R. van Tongeren (eds) 1995. 
{it:Data Analysis in Community and Landscape Ecology.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}
Kass, R.E., U.T. Eden and E.N. Brown. 2014. 
{it:Analysis of Neural Data.} 
New York: Springer. 

{p 4 8 2}Keen, K.J. 2010. 
{it:Graphics for Statistics and Data Analysis with R.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}Kirk, A. 2012. 
{it:Data Visualization: A Successful Design Process.} 
Birmingham: Packt. 

{p 4 8 2}Kirk, A. 2016. 
{it:Data Visualization: A Handbook for Data Driven Design.} 
London: SAGE. 

{p 4 8 2}Klemel{c a:}, J. 2009. 
{it:Smoothing of Multivariate Data: Density Estimation and Visualization.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Krieg, A.F., J.R. Beck and M.B. Bongiovanni. 1988. 
The dot plot: a starting point for evaluating test performance. 
{it:Journal, American Medical Association} 260: 3309{c -}3312. 

{p 4 8 2}Lang, T.A. and M. Secic. 2006. 
{it:How to Report Statistics in Medicine: Annotated Guidelines for Authors, Editors, and Reviewers.} 
Philadelphia: American College of Physicians. 

{p 4 8 2}Langren, Michael Florent van. 1644. 
{it:La Verdadera Longitud por Mar y Tierra.} Antwerp. 

{p 4 8 2}Lee, J.J. and Z.N. Tu. 1997. 
A versatile one-dimensional distribution plot: the BLiP plot. 
{it:American Statistician}
51: 353{c -}358. 

{p 4 8 2}Leisch, F. 2010.  
Neighborhood graphs, stripes and shadow plots for cluster visualization. 
{it:Statistics and Computing} 20: 457{c -}469. 

{p 4 8 2}Lewis, C.R. 1975. 
The analysis of changes in urban status: a case study in Mid-Wales and the 
middle Welsh borderland. 
{it:Transactions of the Institute of British Geographers}
64: 49{c -}65. 

{p 4 8 2}Light, R.J. and D.B. Pillemer. 1984. 
{it:Summing Up: The Science of Reviewing Research.}
Cambridge, MA: Harvard University Press. 

{p 4 8 2}Maindonald, J.H. and W.J. Braun. 2003. 
{it:Data Analysis and Graphics Using R {c -} An Example-based Approach.} 
Cambridge: Cambridge University Press. (later editions 2007, 2010) 

{p 4 8 2}Martinez, W.L., A.R. Martinez and J.L. Solka. 2011. 
{it:Exploratory Data Analysis with MATLAB.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}Matthews, H.A. 1936.
A new view of some familiar Indian rainfalls.
{it:Scottish Geographical Magazine} 52: 84{c -}97. 

{p 4 8 2}Matthews, J.A. 1981. 
{it:Quantitative and Statistical Approaches to Geography: A Practical Manual.} 
Oxford: Pergamon. 

{p 4 8 2}McDaniel, E. and S. McDaniel. 2012a. 
{it:The Accidental Analyst: Show Your Data Who's Boss.}
Seattle, WA: Freakalytics.

{p 4 8 2}McDaniel, S. and E. McDaniel. 2012b. 
{it:Rapid Graphs with Tableau 7: Create Intuitive, Actionable Insights in Just 15 Days.}
Seattle, WA: Freakalytics.

{p 4 8 2}McNeil, D. 1996. 
{it:Epidemiological Research Methods.} 
Chichester: John Wiley. 

{p 4 8 2}Meloun, M. and J. Militk{c y'}. 1994. 
Computer-assisted data treatment in analytical chemometrics.
I. Exploratory analysis of univariate data. 
{it:Chemical Papers} 48: 151{c -}157. 

{p 4 8 2}Militk{c y'}, J. and M. Meloun. 1993. 
Some graphical aids for univariate exploratory data analysis. 
{it:Analytica Chimica Acta} 277: 215{c -}221. 

{p 4 8 2}Miller, A.A. 1953. 
{it:The Skin of the Earth.} 
London: Methuen. (2nd edition 1964) 

{p 4 8 2}Mitchell, P.L. 2010. 
Replacing the pie chart, and other graphical grouses. 
{it:Bulletin of the British Ecological Society} 41(1): 58{c -}60. 

{p 4 8 2}Monkhouse, F.J. and H.R. Wilkinson. 1952. 
{it:Maps and Diagrams: Their Compilation and Construction.} 
London: Methuen. (later editions 1963, 1971)

{p 4 8 2}Monmonier, M. 1993. 
{it:Mapping It Out: Expository Cartography for the Humanities and Social Sciences.} 
Chicago: University of Chicago Press. 

{p 4 8 2}Monmonier, M. 1996. 
{it:How to Lie with Maps.} 
Chicago: University of Chicago Press. (first published 1991)

{p 4 8 2}Moroney, M.J. 1956. 
{it:Facts from Figures.} 
Harmondsworth: Penguin. (previous editions 1951, 1953) 

{p 4 8 2}Morgan, M.G. and M. Henrion. 1990. 
{it:Uncertainty: A Guide to Dealing with Uncertainty in Quantitative Risk and Policy Analysis.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Mosteller, F. and J.W. Tukey. 1977. 
{it:Data Analysis and Regression: A Second Course in Statistics.} 
Reading, MA: Addison-Wesley. 

{p 4 8 2}Morgenthaler, S. 2007. 
{it:Introduction {c a'g} la Statistique}. 
Lausanne: Presses polytechniques et universitaires romandes. 

{p 4 8 2}Motulsky, H. 2014. 
{it:Intuitive Biostatistics: A Nonmathematical Guide to Statistical Thinking.} 
New York: Oxford University Press. (previous editions 1995, 2010) 

{p 4 8 2}Myatt, G.J. 2007. 
{it:Making Sense of Data: A Practical Guide to Exploratory Data Analysis and Data Mining.}
Hoboken, NJ: John Wiley. 

{p 4 8 2}Myatt, G.J. and Johnson, W.P. 2009. 
{it:Making Sense of Data II: A Practical Guide to Data Visualization, Advanced Data Mining Methods, and Applications.}
Hoboken, NJ: John Wiley. 

{p 4 8 2}Myatt, G.J. and Johnson, W.P. 2011. 
{it:Making Sense of Data III: A Practical Guide to Designing Interactive Data Visualizations.}
Hoboken, NJ: John Wiley. 

{p 4 8 2}Nolan, D. and Speed, T. 2000. 
{it:Stat Labs: Mathematical Statistics through Applications.} 
New York: Springer. 

{p 4 8 2}Ottaway, B. 1973. 
Dispersion diagrams: a new approach to the display of carbon-14 dates. 
{it:Archaeometry} 15: 5{c -}12. 

{p 4 8 2}Parzen, E. 1979a. 
Nonparametric statistical data modeling. 
{it:Journal, American Statistical Association}  
74: 105{c -}121. 

{p 4 8 2}Parzen, E. 1979b. 
A density-quantile function perspective on robust estimation. 
In Launer, R.L. and G.N. Wilkinson (eds) {it:Robustness in Statistics.} 
New York: Academic Press, 237{c -}258. 

{p 4 8 2}Parzen, E. 1982. 
Data modeling using quantile and density-quantile functions. 
In Tiago de Oliveira, J. and Epstein, B. (eds) 
{it:Some Recent Advances in Statistics.} London: Academic Press, 
23{c -}52.

{p 4 8 2}Pearson, E.S. 
1931. The analysis of variance in cases of non-normal variation. 
{it:Biometrika} 23: 114{c -}133. 

{p 4 8 2}Pearson, E.S. 
1938. The probability integral transformation for testing goodness of fit and combining independent tests of significance. 
{it:Biometrika} 30: 134{c -}148. 

{p 4 8 2}Pearson, E.S. 1956.
Some aspects of the geometry of statistics: the use of visual 
presentation in understanding the theory and application of mathematical 
statistics. 
{it:Journal of the Royal Statistical Society Series A} 
119: 125{c -}146.

{p 4 8 2}Pearson, E.S. and C. Chandra Sekhar. 
1936. The efficiency of statistical tools and a criterion for the rejection of outlying observations. 
{it:Biometrika} 28: 308{c -}320. 

{p 4 8 2}Quinn, G.P. and M.J. Keough. 2002. 
{it:Experimental Design and Data Analysis for Biologists.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Ramsey, F.L. and D.W. Schafer. 2013. 
{it:The Statistical Sleuth: A Course in Methods of Data Analysis.} 
Boston, MA: Brooks/Cole (previous editions 1996, 2002) 

{p 4 8 2}Reimann, C., P. Filzmoser, R.G. Garrett and R. Dutter. 2008. 
{it:Statistical Data Analysis Explained: Applied Environmental Statistics with R.}
Chichester: John Wiley. 

{p 4 8 2}Rice, K. and T. Lumley. 2016. 
Graphics and statistics for cardiology: comparing categorical and continuous
variables.  {it:Heart} 102: 349-355 doi:10.1136/heartjnl-2015-308104

{p 4 8 2}Robertson, B. 1988.
{it:Learn to Draw Charts and Diagrams Step-by-step.}
London: Macdonald Orbis. See pp.34-5.

{p 4 8 2}Robbins, N.B. 2005. 
{it:Creating More Effective Graphs.} 
Hoboken, NJ: John Wiley. (2013 edition: Wayne, NJ: Chart House) 

{p 4 8 2}Rowntree, D. 1981. 
{it:Statistics Without Tears: A Primer for Non-mathematicians. 
Harmondsworth: Penguin. 

{p 4 8 2}Ryan, B.F., B.L. Joiner and T.A. Ryan. 1985. 
{it:Minitab Handbook.} 
Boston, MA: Duxbury. 

{p 4 8 2}Sall, J., A. Lehman, M. Stephens and L. Creighton. 2014. 
{it:JMP Start Statistics: A Guide to Statistics and Data Analysis Using JMP.} 
Cary, NC: SAS Institute. 

{p 4 8 2}
Sarkar, D. 2008. 
{it:Lattice: Multivariate Data Visualization with R.}
New York: Springer.

{p 4 8 2}
Sasieni, P. and P. Royston. 1994. 
dotplot: Comparative scatterplots. 
{it:Stata Technical Bulletin} 19: 8{c -}10. 

{p 4 8 2}Sasieni, P.D. and P. Royston. 1996. 
Dotplots. 
{it:Applied Statistics} 45: 219{c -}234.

{p 4 8 2}Schenemeyer, J.H. and L.J. Drew. 2011. 
{it:Statistics for Earth and Environmental Scientists.}
Hoboken, NJ: John Wiley.

{p 4 8 2}Searcy, J.K. 1959. 
Flow-duration curves. 
{it:Geological Survey Water-Supply Paper} 1542-A. 
{browse "http://pubs.usgs.gov/wsp/1542a/report.pdf":http://pubs.usgs.gov/wsp/1542a/report.pdf} 

{p 4 8 2}Shaw, N. 1936. 
{it:Manual of Meteorology. Volume II: Comparative Meteorology.} 
Cambridge: Cambridge University Press. See pp.102{c -}105, 420. 

{p 4 8 2}Shera, D.M. 1991. 
Some uses of quantile plots to enhance data presentation. 
{it:Computing Science and Statistics} 23: 50{c -}53.

{p 4 8 2}Shewhart, W.A. 1931. 
{it:Economic Control of Quality of Manufactured Product.}
New York: Van Nostrand. 

{p 4 8 2}Shewhart, W.A. 1939. 
{it:Statistical Method from the Viewpoint of Quality Control.} 
Washington, DC: Graduate School of the Department of Agriculture. 

{p 4 8 2}Siegel, A.F. 1988.                        
{it:Statistics and Data Analysis: An Introduction.} 
New York: John Wiley. 

{p 4 8 2}Siegel, A.F. and C.J. Morgan. 1996.                        
{it:Statistics and Data Analysis: An Introduction.} 
New York: John Wiley. 

{p 4 8 2}Sinacore, J.M. 1997.
Beyond double bar charts: The value of dot charts with ordered category
clustering for reporting change in evaluation research. 
{it:New Directions for Evaluation} 73: 43{c -}49. 

{p 4 8 2}Smith, D.M. 1979. 
{it:Where the Grass is Greener: Living in an Unequal World.} 
Harmondsworth: Penguin. See p.270. 

{p 4 8 2}Sokal, R.R. and F.J. Rohlf. 2012. 
{it:Biometry: The Principles and Practice of Statistics in Biological Research.}
New York: W.H. Freeman (previous editions 1969, 1981, 1995) 

{p 4 8 2}Theus, M. and S. Urbanek. 2009. 
{it:Interactive Graphics for Data Analysis: Principles and Examples.}
Boca Raton, FL: CRC Press. 

{p 4 8 2}Tippett, L.H.C. 1943. 
{it:Statistics.} London: Oxford University Press. See p.97 in 1956 edition.
 
{p 4 8 2}Tufte, E.R. 1974. 
{it:Data Analysis for Politics and Policy.} 
Englewood Cliffs, NJ: Prentice-Hall. 

{p 4 8 2}Tufte, E.R. 1983. 
{it:The Visual Display of Quantitative Information.} 
Cheshire, CT: Graphics Press. 

{p 4 8 2}Tufte, E.R. 1997. 
{it:Visual Explanations: Images and Quantities, Evidence and Narrative.} 
Cheshire, CT: Graphics Press. 

{p 4 8 2}Tukey, J.W. 1970.  
{it:Exploratory data analysis. Limited Preliminary Edition. Volume I.}
Reading, MA: Addison-Wesley.

{p 4 8 2}Tukey, J.W. 1972.
Some graphic and semi-graphic displays.
In Bancroft, T.A. and Brown, S.A. (eds)
{it:Statistical Papers in Honor of George W. Snedecor.}
Ames, IA: Iowa State University Press, 293{c -}316.
(also accessible at {browse "http://www.edwardtufte.com/tufte/tukey":http://www.edwardtufte.com/tufte/tukey})

{p 4 8 2}
Tukey, J.W. 1974. 
Named and faceless values: an initial exploration in memory of Prasanta C. Mahalanobis. 
{it:Sankhya: The Indian Journal of Statistics} Series A 36: 125{c -}76. 
http://www.jstor.org/stable/25049924. NB: last character of journal title is a with macron, uchar(257) from Stata 14. 

{p 4 8 2}Tukey, J.W. 1977. 
{it:Exploratory Data Analysis.} 
Reading, MA: Addison-Wesley. 

{p 4 8 2}Tukey, J.W. and P.A. Tukey. 1990. Strips displaying 
empirical distributions: I. Textured dot strips. Bellcore Technical Memorandum. 

{p 4 8 2}Tukey, P.A. and Tukey, J.W. 1981. 
Data-driven view selection; Agglomeration and sharpening. 
In Barnett, V. (ed.) {it:Interpreting Multivariate Data.} 
Chichester: John Wiley, 215{c -}243. See p.235. 

{p 4 8 2}Uman, M.A. 1969. 
{it:Lightning.} 
New York: McGraw-Hill. See p.86. 

{p 4 8 2}van Belle, G., L.D. Fisher, P.J. Heagerty and T. Lumley. 2004. 
{it:Biostatistics: A Methodology for the Health Sciences.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Velleman, P.F. 1989. 
{it:Learning Data Analysis with Data Desk.} 
New York: W.H. Freeman. (later editions 1993, etc.) 

{p 4 8 2}Venables, W.N. and B.D. Ripley. 2002. 
{it:Modern Applied Statistics with S.} New York: Springer. 

{p 4 8 2}Wainer, H. 2014. 
{it:Medical Illuminations: Using Evidence, Visualization and Statistical Thinking to Improve Healthcare.} 
Oxford: Oxford University Press. 

{p 4 8 2}Wainer, H. 2016. 
{it:Truth or Truthiness: Distinguishing Fact from Fiction by Learning to Think Like a Data Scientist.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Wallis, W.A. and H.V. Roberts. 1956. 
{it:Statistics: A New Approach.} Glencoe, IL: Free Press. 

{p 4 8 2}Warton, D.I. 2008. 
Raw data graphing: an informative but under-utilized tool for the analysis of multivariate abundances.
{it:Austral Ecology} 33: 290{c -}300. 

{p 4 8 2}Weissgerber, T.L., N.M. Milic, S.J. Winham and V.D. Garovic. 2015. 
Beyond bar and line graphs: time for a new data presentation paradigm. 
{it:PLoS Biology} 13(4): e1002128. doi:10.1371/journal.pbio.1002128

{p 4 8 2}Wetherill, G.B. 1981. 
{it:Intermediate Statistical Methods.} 
London: Chapman and Hall. See p.2. 

{p 4 8 2}Wetherill, G.B. 1982. 
{it:Elementary Statistical Methods.} 
London: Chapman and Hall. See p.68. 

{p 4 8 2}
Whitlock, M.C. and D. Schluter. 2009. 
{it:The Analysis of Biological Data.} 
Greenwood Village, CO: Roberts and Company. (second edition 2015)

{p 4 8 2}Wild, C.J. and G.A.F. Seber. 2000. 
{it:Chance Encounters: A First Course in Data Analysis and Inference.} 
New York: John Wiley. 

{p 4 8 2}Wilkinson, L. 1992. Graphical displays. 
{it:Statistical Methods in Medical Research} 1: 3{c -}25. 

{p 4 8 2}Wilkinson, L. 1999. Dot plots. {it:American Statistician} 
53: 276{c -}281. 

{p 4 8 2}Wilkinson, L. 2005. {it:The Language of Graphics.} 
New York: Springer. 

{p 4 8 2}Williams, C.B. 1964. {it:Patterns in the Balance of Nature.} 
London: Academic Press. See pp.43, 51, 84, 155, 170, 208, 213, 286, 290. 

{p 4 8 2}Williams, C.B. 1970. {it:Style and Vocabulary.} 
London: Charles Griffin. See pp.57, 61, 77. 

{p 4 8 2}Wright, S. 1977. 
{it:Evolution and the Genetics of Populations. Volume 3:  Experimental Results and Evolutionary Deductions.}
Chicago: University of Chicago Press. p.64. 

{p 4 8 2}Young, F.W., P.M. Valero-Mora and M. Friendly. 2006. 
{it:Visual Statistics: Seeing Data with Interactive Graphics.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Zipf, G.K. 1949.
{it: Human Behavior and the Principle of Least Effort: An Introduction to Human Ecology.}
Cambridge, MA: Addison-Wesley. 

{p 4 8 2}Zuur, A.F., E.N. Ieno and G.M. Smith. 2007.
{it:Analysing Ecological Data.} 
New York: Springer.


{title:Also see}

{p 4 13 2} 
On-line: help for {help dotplot}, {help gr7oneway}, {help histogram}, 
{help distplot} (if installed), {help qplot} (if installed) 
 

