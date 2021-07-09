{smcl}
{* 17feb2017}{...}
{cmd:help locpoly3}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col:{cmd:locpoly3} {hline 2}}Kernel-weighted local polynomial
regression{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}{cmd:locpoly2} {it:yvar} {it:xvar} 
{ifin} {weight} [{cmd:,} 
{cmdab:d:egree:(}{it:#}{cmd:)} {cmdab:w:idth:(}{it:#}{cmd:)}
{opt n(#)} {opt at(atvar)}
{cmdab:gen:erate:(}[{it:newvarx}] {it:newvary} [{it:newvarsy}]{cmd:)}
[{cmdab:ep:anechnikov} | {cmdab:bi:weight} | {cmdab:cos:ine} |
{cmdab:gau:ssian} | {cmdab:par:zen} | {cmdab:rec:tangle} | {cmdab:tri:angle}]
{cmdab:nog:raph} {cmdab:nos:catter}
{cmd:plot(}{it:plot}{cmd:)} {it:line_options} {it:twoway_options} ]

{title:Description}

{pstd}
{cmd:locpoly3} is a slight variation on locpoly2 that produces kernel-weighted local polynomial smooths
and returns the derivates of the conditional mean estimate. locpoly3 accepts {cmd:fweight}s and {cmd:pweight}s.


{title:Options}

{phang}
{opt degree(#)} specifies the degree of the polynomial to be used in the
smoothing.  The default is {cmd:degree(0)}, meaning local mean
smoothing.

{phang}
{opt width(#)} specifies the half-width of the kernel, that is, the
width of the smoothing window around each point.  If {cmd:width()} is
not specified, the "default" width is used; see {helpb kdensity}.  This
default is inappropriate for local polynomial smoothing; roll your own.

{phang}
{opt n(#)} specifies the number of points at which the smooth is to be
evaluated.  The default is {cmd:min(_N,50)}.

{phang}
{opt at(atvar)} specifies a variable that contains the values at which
the smooth should be evaluated.  {cmd:at()} allows you to easily obtain
smooths for different variables or different subsamples of a variable
and then overlay the estimates for comparison.

{phang}
{cmd:generate(}[{it:newvarx}] {it:newvary} [{it:newvarsy}]{cmd:)}
stores the results of the estimation.  {it:newvary} will contain the
estimated smooth.  {it:newvarx} will contain the smoothing grid. If
{cmd:at()} is not specified, then both {it:newvarx} and {it:newvary}
must be specified.  Otherwise, only {it:newvary} is to be specified
along with optional {it:newvarsy}.  Any variables specified in addition
to {it:newvarx} and {it:newvary} contain the derivates of the
conditional mean function up to the degree specified in {cmd:degree()}.

{phang}
{cmd:epanechnikov}, {cmd:biweight}, {cmd:cosine}, {cmd:gaussian},
{cmd:parzen}, {cmd:rectangle}, and {cmd:triangle} specify the kernel.
({cmd:cosine} specifies the cosine trace; there is no such thing as a
cosine kernel.)  The default is {cmd:epanechnikov}, meaning the
Epanechnikov kernel is used.

{phang}
{cmd:nograph} suppresses drawing the graph.  This option is often used
in conjunction with {cmd:generate()}.

{phang}
{cmd:noscatter} suppresses superimposing a scatterplot of the observed
data over the smooth.  This option is useful when the number of
resulting points would be large enough to clutter the graph.

{p 4 8 2}
{cmd:plot(}{it:plot}{cmd:)} provides a way to add other plots to the generated
graph; see {manhelpi plot_option G-3}.

{p 4 8 2}
{it:line_options} affect the rendition of the plotted lines; see
{manhelpi line_options G-3}.

{p 4 8 2}
{it:twoway_options} are any of the options documented in 
{manhelpi twoway_options G-3} excluding {cmd:by()}.  These include options for titling
the graph (see {manhelpi title_options G-3}) and options for saving the graph to
disk (see {manhelpi saving_option G-3}).


{title:Examples}

{pstd}
Setup: Generate 5,000 observations from a parametric normal data-generating
process modeling the returns to college{p_end}
{phang2}{cmd:. margte_dgps}

{pstd}
A nonparametric regression that plots an estimate of the conditional mean
function over a scatterplot of the data{p_end}
{phang2}{cmd:. locpoly2 lwage momsEdu}

{pstd}
Save {cmd:xgrid}, {cmd:yhat}, and the first and second derivatives{p_end}
{phang2}{cmd:. locpoly2 lwage momsEdu, degree(2) generate(xgrid yhat dydx1 d2ydx12)}


{title:Authors}

{pstd}Original Authors:{p_end}

{pstd}Roberto G. Gutierrez{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}rgutierrez@stata.com{p_end}

{pstd}Jean Marie Linhart{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}

{pstd}Jeffrey S. Pitblado{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}

{pstd}Modifying Authors locpoly2:{p_end}

{pstd}Thomas Walstrum{p_end}
{pstd}University of Illinois at Chicago{p_end}
{pstd}Federal Reserve Bank of Chicago{p_end}
{pstd}Chicago, IL{p_end}
{pstd}twalstrum@frbchi.org{p_end}

{pstd}Scott Brave{p_end}
{pstd}Federal Reserve Bank of Chicago{p_end}
{pstd}Chicago, IL{p_end}
{pstd}sbrave@frbchi.org{p_end}

{pstd}Modifying Author locpoly3:{p_end}

{pstd}Martin Eckhoff Andresen{p_end}
{pstd}University of Oslo and Statistics Norway{p_end}
{pstd}Oslo, Norway{p_end}
{pstd}martin.eckhoff.andresen@gmail.com{p_end}

{title:Also see}

{p 5 14 2}Manual:  {manlink R kdensity}, {manlink R lowess}

{p 7 14 2}Help:  {manhelp graph G-2}{p_end}
