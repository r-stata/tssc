{smcl}
{* 13may2014}{...}
{hline}
help for {hi:designplot}
{hline}

{title:Design plot: graphical summary of response given one or more factors} 

{p 8 17 2} 
{cmd:designplot}
{it:yvar}
{it:xvarlist} 
[{it:weight}] 
[{help if}] 
[{help in}]
[
{cmd:,}
{cmdab:stat:istics(}{it:statistics}{cmd:)}
{cmd:prefix(}{it:prefix}{cmd:)}  
{cmd:saveresults(}{it:filename} [{cmd:,} {it:save_options}{cmd:)}  
{cmdab:max:way(}{it:#}{cmd:)}  
{cmdab:min:way(}{it:#}{cmd:)}  
{cmd:recast(}{c -(}{cmd:bar}{c |}{cmd:hbar}{c )-}{cmd:)} 
{c -(}
{cmd:variablelabels} 
{c |}
{cmd:variablenames} 
{c )-} 
{cmd:alllabel(}{it:text}{cmd:)}                 
{cmd:entryopts(}{it:over_subopts}{cmd:)}
{cmd:groupopts(}{it:over_subopts}{cmd:)} 
{it:graph_options}
]

{p 8 17 2}
aweights and fweights are supported. 


{title:Description} 

{p 4 4 2} 
{cmd:designplot} produces a graphical summary of a numeric response
variable {it:yvar} given one or more "factors" {it:xvarlist}. The term
"factor" in this context means that any (numeric or string) variable
concerned will be treated in terms of its distinct values or levels as
they occur in the data. Use of Stata's factor variable syntax is neither
explicit nor implicit. 

{p 4 4 2}
For concreteness, consider the example 

{p 8 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 8 2}{cmd:. designplot mpg foreign rep78} 

{p 4 4 2}
This produces a plot showing the mean of {cmd:mpg} for all observations;
for all the classes defined by the values of {cmd:foreign} and also
those of {cmd:rep78}; and for all the classes defined by the
cross-combinations of values of {cmd:foreign} and {cmd:rep78} occurring
in the data. 

{p 4 4 2}
Options give scope for showing other summary statistics as calculated by
{help summarize} and for restricting the results shown in the plot. 

{p 4 4 2}
By default the graph is produced by {help graph dot}. Optionally 
{help graph hbar} or {help graph bar} may be used instead. 

{p 4 4 2}
Design plots offer a diversity of uses, ranging from simple exploratory
overviews to multiscale breakdowns deserving and demanding detailed
scrutiny. 


{title:Remarks} 

{p 4 4 2} 
{cmd:designplot} is an eclectic combination of ideas. Readers are warmly
invited to inform the author of other similar or related work. 

{p 4 4 2}
1. The existing Stata command {help grmeanby} shows means (or optionally
medians) of  a response variable given one or more other variables. The
scope of {cmd:grmeanby} is identical to that of {cmd:designplot} insofar
as the other variables could be string variables as well as numeric
variables.  As recorded by Gould (1993) and in the manual entry,
{cmd:grmeanby} was inspired by examples in Chambers and Hastie (1992).
{cmd:grmeanby} is based on direct use of {cmd: summarize}. 

{p 4 4 2} 
2. Freeny and Landwehr (1992) gave the name "design plot" to plots
similar to those in Chambers and Hastie (1992) and that name is
associated with software implementations outside Stata, notably in S,
S-Plus and R. The name is also consistent with S syntax detailed at
Chambers and Hastie (1992, pp.546{c -}547). In these implementations
plots show results from fitting linear models, specifically analyses of
variance.  The name evokes the idea of an underlying experimental
design, but the command here clearly may be applied to any data,
including observational data in any sense of that term. The graph shown
by Zuur et al. (2007, p.37) is an example from the applied literature. 

{p 4 4 2}
3. Various plots given in Hoaglin, Mosteller, and Tukey (1991) show
displays "side-by-side" of main effects, interactions and residuals as
fitted in analysis of variance. Roberts (1993, p.310) cites an earlier
instance of the same idea in Tukey (1977, p.451).  Yandell (1997) calls
these "effect plots" or "effects plots". 

{p 4 4 2}
4. Broadly similar plots for "graphical ANOVA" appear in Box, Hunter and
Hunter (2005). See also the earlier work in Box (1993). van Belle
(2008, p.201) called them "BHH plots". 

{p 4 4 2}
Graphs of types 3 and 4 commonly show effects and residuals scaled to be
comparable in terms of variability. 

{p 4 4 2}
5. Graphically, these displays share a possible problem: points may need
to be plotted close to each other, creating difficulties especially if
any text labels occlude each other or need to be abbreviated. 3 out of 4
examples in Chambers and Hastie (1992) show this, as does the example in
[R] grmeanby.  Several examples in Hoaglin et al. (1991) avoid the
problem only by jittering points apart. Harrell (2001) used a different
display based on dot charts or dot plots (in the sense of Cleveland
1984, 1985, 1994) that avoids this problem.  Conversely, a dot chart 
representation will work well with say 10 entries, but not with 100 or
more. 

{p 4 4 2}
6. On a simpler level, tables or graphs reporting survey results often
show two or more separate breakdowns of some sample.  Examples are
shown by Tufte (1983/2001, p.179) and (more trivially) Cox (2008), among
many others. 

{p 4 4 2}
7. The {cmd:statsby} command with its {cmd:subsets} option provides an
easy framework for calculation and assembly of summary statistics for
zero-, one-, two-way and higher breakdowns of a dataset. Cox (2010)
provided an illustration of its exploitation for graphics. 

{p 4 4 2}
The name "design plot" is adopted here as a simple, memorable name and
given its earlier and widespread use to show similar information. These
are positive features. On the other hand, the connotation of experimental
design will often be inappropriate. The use of dot chart (or optionally
bar chart) form also distinguishes the results of this command from
others published as design plots. People who like the plots and dislike
the name are naturally free to use other terminology, or none at all.
Not every kind of graph needs a distinct name, but every graph program
does. 

{p 4 4 2}
Naturally, this lack of standardization is not new. "Most or all
features of statistical computation{c -}computer hardware, software
systems, coding, languages, symbols, terminology, procedures{c -}have
much to gain from elimination of pointless variations, redundancies and
confusion. Yet pointlessness is not always easy to judge. The only quite
satisfying rule of standardization is that you adopt my standards."
(Anscombe 1981, p.3) 

{p 4 4 2}
{cmd:designplot} creates a new dataset of {cmd:summarize} results with
default variable names {cmd:_stat1} and so forth for each statistic and
{cmd:_way}, {cmd:_group} and {cmd:_entry} describing the results. If the
number of observations is not one of the statistics requested, a
variable with default name {cmd:_nobs} is added any way, on the grounds
that it will often be interesting or useful.  The original dataset will
be restored after the graph is drawn, but the results set may be
{cmd:save}d for other use with the {cmd:saveresults()} option. 

{p 4 4 2} 
How therefore does {cmd:designplot} differ from what is readily
available through (e.g.) {cmd:graph dot}? There are two main
differences. First, {cmd:graph dot} and its siblings are more restricted
in offering only one-way or two-way or three-way breakdowns given,
respectively, one or two or three "factors" as arguments to {cmd:over()}
or {cmd:by()} options. Second, they do not give scope for saving results
for separate graphing or tabulation. 

{p 4 4 2}
For concreteness, consider again the example 

{p 8 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 8 2}{cmd:. designplot mpg foreign rep78} 

{p 4 4 2}
This produces a plot showing 

{p 8 8 2}
the mean of {cmd:mpg} for all observations, which may be called a
"zero-way" breakdown

{p 8 8 2}
the means for all the classes defined by the values of {cmd:foreign} and
also of {cmd:rep78}, which may be called "one-way" breakdowns, as often
done in statistical literature

{p 8 8 2} 
and the means for all the classes defined by the cross-combinations of
values of {cmd:foreign} and {cmd:rep78} occurring in the data, which
similarly may be called a "two-way" breakdown, again as often done. 

{p 4 4 2}
In general, specifying one or more factors gives scope for various
breakdowns, but the number of (cross-)combinations may grow rapidly, so
that the resulting graph might be too complicated to be readable or
useful. Thus {cmd:designplot} offers options to restrict the scope of
what is plotted. 


{title:Options}

{p 4 8 2}
{cmd:statistics(}{cmd:)} specifies statistics calculated by 
{help summarize} to be calculated. The default is the mean (only).  One
or more statistics may be specified. Note that no allowance is made in
graphics for different statistics being on quite different scales, so
that the user may need to exercise discretion over what is specified.
The names allowed include the names of the r-class results as visible
after {cmd:summarize, detail} or as documented in [R] summarize.  Thus
{cmd:p50} specifies the median available as {cmd:r(p50)}. 

{p 4 8 2}
Allowed synonyms also include the following. Any synonym specified will
be echoed literally to the {cmd:ytitle()}. 

{p 8 8 2} 
{cmd:n} or {cmd:count} or any abbreviation of {cmd:frequency} for
{cmd:N}. 

{p 8 8 2}
{cmd:minimum} for {cmd:min} and {cmd:maximum} for {cmd:max}. 

{p 8 8 2}
{cmd:total} for {cmd:sum}.

{p 8 8 2}
{cmd:median} for  {cmd:p50}. 

{p 8 8 2}
{cmd:SD} for {cmd:sd}. 

{p 8 8 2}
any abbreviation of {cmd:variance} or {cmd:Variance} for {cmd:Var}. 

{p 4 8 2}
{cmd:skew} for {cmd:skewness} and {cmd:kurt} for {cmd:kurtosis}. 

{p 8 8 2}Note that if just {cmd:statistics(N)} is specified, which {it:yvar} is 
specified is immaterial so long as it is non-missing 
whenever {it:xvarlist} are non-missing. 

{p 4 8 2} 
{cmd:prefix()} is an occasionally used option.  {cmd:designplot} creates
a dataset of results with variable names such as {cmd:_stat1} and so
forth. If these names clash with existing variable names, this option
may be used to add a prefix to all such names to remove the clash. 
 
{p 4 8 2}
{cmd:saveresults()} saves the results as a Stata dataset.  Options of
{help save} may be specified, most usefully {cmd:replace}. The dataset
will include {help notes} on the {cmd:designplot} command issued and 
(if defined) the filename and its date for the ({cmd:save}d) dataset. 

{p 4 8 2} 
{cmd:maxway()} specifies the maximum "way" to be plotted. See
explanation in Remarks on breakdowns that are called zero-way, one-way,
two-way and so forth.  Thus {cmd:maxway(1)} by itself specifies that
zero-way and one-way breakdowns only are to be shown. 

{p 4 8 2} 
{cmd:minway()} specifies the minimum "way" to be plotted. See
explanation in Remarks on breakdowns that are called zero-way, one-way,
two-way and so forth.  Thus {cmd:minway(1)} by itself specifies that the
zero-way breakdown should not be shown. 

{p 4 8 2} 
{cmd:recast(}{c -(}{cmd:hbar}{c |}{cmd:bar}{c )-}{cmd:)} specifies that
the graph should be drawn using {help graph hbar} or {help graph bar}.
The default is {help graph dot}. People fond of bar charts are advised
to try {cmd:graph hbar} for greater readability of axis information.  
Note for experienced users: although the option name is suggested by another 
{help advanced_options:recast()} option, this is not a back door to
recasting to a {cmd:twoway} plot. 

{p 4 8 2} 
{cmd:variablelabels} specifies that one-way breakdowns should be
labelled by the corresponding variable labels, or the corresponding
variable names if no variable label is defined. The default is, or
should be, an invisible label (precisely, an instance of
{cmd:char(160)}). 

{p 4 8 2} 
{cmd:variablenames} specifies that one-way breakdowns should be labelled
by the corresponding variable names. The default is, or should be, an
invisible label (precisely, an instance of {cmd:char(160)}). The reason
for using this option rather than {cmd:variablelabels} is likely to be
that variable labels would take up too much space. 

{p 8 8 2} 
Only one of {cmd:variablelabels} and {cmd:variablenames} may be
specified.  

{p 4 8 2} 
{cmd:alllabel(}{it:text}{cmd:)} specifies text to label results for all
observations used. The default is {cmd:(all)}. 

{p 4 8 2} 
{cmd:entryopts(}{it:over_subopts}{cmd:)} specifies {it:over_subopts} of
{cmd:graph dot}, {cmd:graph hbar} or {cmd:graph bar}, used to tune the
corresponding call to an {cmd:over()} option that affects the display of
individual entries in the graph.  Users unsure of what this means may
find inspection of the source code helpful or alternatively just modify
a graph by use of the Graph Editor. 

{p 4 8 2} 
{cmd:groupopts(}{it:over_subopts}{cmd:)} specifies {it:over_subopts} of
{cmd:graph dot}, {cmd:graph hbar} or {cmd:graph bar}, used to tune the
corresponding call to an {cmd:over()} option that affects the display of
groups of entries in the graph.  Users unsure of what this means may
find inspection of the source code helpful or alternatively just modify
a graph by use of the Graph Editor. 

{p 4 8 2}
{it:graph_options} are other options allowed with
{help graph dot},  
{help graph hbar} or 
{help graph bar} (whichever command is being used). 
Note that among other defaults {cmd:t1title()} is used to display 
information on {it:yvar}. 


{title:Examples} 

{p 4 8 2}{cmd:. set scheme s1color}{p_end}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}

{p 4 8 2}{cmd:. designplot mpg foreign rep78}{p_end}

{p 4 8 2}{cmd:. designplot mpg foreign rep78 if !missing(foreign,rep78), stat(count) recast(hbar) blabel(total) yla(none) t1title("frequencies") variablelabels ytitle("") ysc(r(0 72))}{p_end}

{p 4 8 2}{cmd:. designplot mpg foreign rep78, stat(min p25 median mean p75 max) maxway(1) legend(row(1))}{p_end}

{p 4 8 2}{cmd:. infix class 1-9 adult 10-18 male 19-27 survived 28-36 using http://www.amstat.org/publications/jse/datasets/titanic.dat.txt, clear }{p_end}
{p 4 8 2}{cmd:. label def class 0 crew 1 first 2 second 3 third}{p_end}
{p 4 8 2}{cmd:. label def adult 1 adult 0 child}{p_end}
{p 4 8 2}{cmd:. label def male 1 male 0 female}{p_end}
{p 4 8 2}{cmd:. label def survived 1 yes 2 no}{p_end}
{p 4 8 2}{cmd:. foreach v in class adult male survived {c -(}}{p_end}
{p 4 8 2}{cmd:. }{space 4}{cmd:label val `v' `v'}{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}

{p 4 8 2}{cmd:. designplot survived class adult male, max(2) ysize(7)}{p_end}


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:References} 

{p 4 8 2}
Anscombe, F.J. 1981. 
{it:Computing in Statistical Science through APL.}
New York: Springer. 

{p 4 8 2}
Box, G.E.P. 1993.
How to get lucky. 
{it:Quality Engineering} 5: 517{c -}524.

{p 4 8 2}
Box, G.E.P., Hunter, J.S. and Hunter, W.G. 2005. 
{it:Statistics for Experimenters: Design, Innovation, and Discovery.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}
Chambers, J.M. and Hastie, T.J. (Eds.) 1992. 
{it:Statistical Models in S.} 
Pacific Grove, CA: Wadsworth and Brooks/Cole. 
See pp.3, 9, 148, 164. 

{p 4 8 2}
Cleveland, W.S. 1984. Graphical methods for data presentation: full
scale breaks, dot charts, and multibased logging. 
{it:American Statistician} 38: 270{c -}80.

{p 4 8 2}
Cleveland, W.S. 1985. {it:Elements of graphing data.} 
Monterey, CA: Wadsworth. 

{p 4 8 2}
Cleveland, W.S. 1994. {it:Elements of graphing data.} 
Summit, NJ: Hobart Press. 

{p 4 8 2}
Cox, N.J. 2008. 
Between tables and graphs. 
{it:Stata Journal} 8: 269{c -}289.

{p 4 8 2}
Cox, N.J. 2010.
The statsby strategy. 
{it:Stata Journal} 10: 143{c -}151.

{p 4 8 2}
Dawson, R.J.M. 1995. 
The "unusual episode" data revisited. 
{it:Journal of Statistics Education} 3(3). 
{browse "http://www.amstat.org/publications/jse/v3n3/datasets.dawson.html":http://www.amstat.org/publications/jse/v3n3/datasets.dawson.html}

{p 4 8 2}
Freeny, A.E. and Landwehr, J.M. 1992. 
Displays for data from large designed experiments.
In Page, C. and LePage, R. (Eds) 
{it:Computer Science and Statistics: Proceedings of the 22nd Symposium on the Interface. Statistics of Many Parameters: Curves, Images, Spatial Models}.
New York: Springer, 117{c -}126.

{p 4 8 2}
Gould, W.W. 1993. 
gr12: Graphs of means and medians by categorical variables. 
{it:Stata Technical Bulletin} 12: 13.

{p 4 8 2}
Harrell, F.E. 2001.  
{it:Regression Modeling Strategies: With Applications to Linear Models, Logistic Regression, and Survival Analysis.}
New York: Springer. See pp.126, 303, 304, 314, 315, 336. 

{p 4 8 2}
Hoaglin, D.C., Mosteller, F. and Tukey, J.W. (Eds) 1991. 
{it:Fundamentals of Exploratory Analysis of Variance.}  
New York: John Wiley. See pp.84, 97, 103, 120, 125, 133, 140, 174, 181,
182, 382, 385. 

{p 4 8 2}
Roberts, S. 1993. 
Fundamentals of Exploratory Analysis of Variance. 
Edited by David C. Hoaglin, Frederick Mosteller, and John W. Tukey. 
{it:American Journal of Psychology} 
106: 308{c -}320.

{p 4 8 2}
Tufte, E.R. 1983/2001.   
{it:The Visual Display of Quantitative Information.}
Cheshire, CT: Graphics Press. 

{p 4 8 2}
Tukey, J.W. 1977. 
{it:Exploratory Data Analysis.} 
Reading, MA: Addison-Wesley. 

{p 4 8 2}
van Belle, G. 2008. 
{it:Statistical Rules of Thumb.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}
Yandell, B.S. 1997. 
{it:Practical Data Analysis for Designed Experiments.} 
London: Chapman & Hall. 
See pp.138, 173, 174, etc. for examples of effects plots. 

{p 4 8 2}
Zuur, A.F., Ieno, E.N. and Smith, G.M. 2007.
{it:Analysing ecological data.}
New York: Springer. 


{title:Also see}

{p 4 13 2}
On-line: help for {help graph dot}, help for {help graph hbar}, 
help for {help graph bar}; help for {help statsby}  


