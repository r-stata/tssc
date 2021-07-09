{smcl}
{* November 14, 2016 @ 13:29:14}{...}
{vieweralsosee "sqclusterdat" "help sqclusterdat "}{...}
{vieweralsosee "sqdes" "help sqdes "}{...}
{vieweralsosee "sqegen" "help sqegen "}{...}
{vieweralsosee "sqindexplot" "help sqindexplot "}{...}
{vieweralsosee "sqmdsadd" "help sqmdsadd "}{...}
{vieweralsosee "sqmodalplot" "help sqmodalplot "}{...}
{vieweralsosee "sqom" "help sqom "}{...}
{vieweralsosee "sqpercentageplot" "help sqpercentageplot "}{...}
{vieweralsosee "sqset" "help sqset "}{...}
{vieweralsosee "sqstat" "help sqstat "}{...}
{vieweralsosee "sqstrlev" "help sqstrlev "}{...}
{vieweralsosee "sqstrmerge" "help sqstrmerge "}{...}
{vieweralsosee "sqtab" "help sqtab "}{...}


{cmd:help sqmodalplot}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqmodalplot} {hline 2} Sequence index plots of modal sequences}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqmodalplot}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opt so}}apply same order similarity{p_end}
{synopt:{opth over(varname)}}show plots for categories of {it:varname}{p_end}
{synopt:{opth by(varname)}}plot groups of sequences based on {it:varname}{p_end}
{synopt:{opth color(colorstyle)}}apply colors to the elements{p_end}
{synopt:{opt gapinclude}}include sequences with gaps in the tabulation{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synopt:{opt tie(keyword)}}how to resolve ties, if any{p_end}
{synopt:{it:twoway_options}}options allowed with {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:sqmodalplot} draws sequence index plots of modal
sequences. A modal sequence is an artificial sequence composed by the
most frequent element for each position. Think of the modal sequence
as some form of an ideal-typical sequence. Note that the notion of
"ideal"-type implies that the modal sequence do not necessarily exist
as a whole in the data set.{p_end}

{pstd} The plot is usefull to show the results of a cluster analysis
on the distance matrix created by {cmd: sqom, full}. Another use is to
inform the user about possible settings for the option {cmd: idealtype()} of
{help sqom}.{p_end}

{title:Options}

{phang}{cmd:over(}{it:varname}{cmd:)} is used to show one line for
each category of the over-variable. A typical use of over is, to show
the modal sequence for each cluster found in a preceding cluster
analysis.{p_end}

{phang}{cmd:tie(}{it:keyword}{cmd:)} deals with cases, in which more
than one element is the most frequent element at a certain
position. The default behavior is to plot the element that is the most
frequent accross all positions (for an category of
over). Alternatively it is possible to plot a gap, the previous, or
the following element of the modal sequence at that positon. The
alternative behaviour are controlled using one of the following
keywords:{p_end}

{p2colset 9 18 18 18}
{p2col:keyword}Explanation{p_end}
{p2line}
{p2col:{cmd:gap}}plot nothing; the default{p_end}
{p2col:{cmd:mode}}most frequent element accross all positions{p_end}
{p2col:{cmd:lag}}the next element of the modal sequence{p_end}
{p2col:{cmd:lead}}the previous element of the modal sequence{p_end}
{p2col:{cmd:highest}}the element with the highest level{p_end}
{p2col:{cmd:lowest}}the element with the lowest level{p_end}
{p2line}

{phang} {cmd:so} is used to request a plot where only the order of
elements is shown (same-order similarity). With this option the
sequences A-B-B-A and A-B-A-A would both be drawn as if they were
A-B-A.

{phang}{opt by(varname)} specifies to plot groups of sequences
separately based on {it:varname}.

{phang}{cmd:color(}{it:colorstyle}{cmd:)} specifies the colors for the
elements.  You can specify one color for each element, whereby the
first color refers to the element with the lowest level. See
{it:{help colorstyle}} for a list of color choices.{p_end}

{phang}{cmd:gapinclude} is used to include sequences with gaps. The
default behavior is to drop sequences with gaps from the graph. 
The term gap refers only to missing values on the element
variable within a sequence. Sequences with missing values at the
begining and at the end of a sequence are included in any case. You
might consider using {cmd:sqset} with option {cmd:trim} to get rid of
superfluous missings (see {help sq##3:sq} for details.){p_end}

{phang}{cmd:subsequence(a,b)} is used to include only the part of
the sequence that is between position a and b, whereby a and b refer
to the position defined in order variable. {p_end}

{phang}
{it:twoway_options} are a set of common options supported by all
{cmd:twoway} commands; see {it:{help twoway_options}}.

{title:Examples}

{phang}{cmd:. sqmodalplot}{p_end}
{phang}{cmd:. sqmodalplot, over(sex) color(black red yellow)}{p_end}
{phang}{cmd:. sqmodalplot, over(sex) tie(gap) so }{p_end}

{phang}{cmd:. sqom, full k(2)}{p_end}
{phang}{cmd:. sqclusterdat}{p_end}
{phang}{cmd:. clustermat wardslinkage SQdist, name(myname) add}{p_end}
{phang}{cmd:. cluster generate cluster = groups(5)}{p_end}
{phang}{cmd:. sqclusterdat, return keep(cluster)}{p_end}
{phang}{cmd:. sqmodalplot, over(cluster) color(black red yellow green cranberry)} by(sex){p_end}

{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}

{title:Also see}

{psee}
Manual:  {bf:[G] graph}, {bf:[G] graph twoway rbar}, {bf:[G] barlook options} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}, {helpb sqmdsadd}{p_end}

