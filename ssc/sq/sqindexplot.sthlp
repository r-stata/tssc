{smcl}
{* März 12, 2012 @ 14:02:53 UK}{...}
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

{cmd:help sqindexplot}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqindexplot} {hline 2} Sequence index plots}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqindexplot}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opth ranks(numlist)}}restrict tabulation on most frequent
{it:numlist}{p_end}
{synopt:{opt se}}apply same elements similarity{p_end}
{synopt:{opt so}}apply same order similarity{p_end}
{synopt:{opth order(varlist)}}specify order of vertical axis{p_end}
{synopt:{opth by(varname)}}plot groups of sequences based on {it:varname}{p_end}
{synopt:{opth color(colorstyle)}}apply colors to the elements{p_end}
{synopt:{opt overplot(#)}}fine tune bar-width{p_end}
{synopt:{opt rbar}}bars intead of spikes{p_end}
{synopt:{opt gapinclude}}include sequences with gaps in the tabulation{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synopt:{it:twoway_options}}options allowed with {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}{cmd:sqindexplot} draws sequence index plots. These plots draw a
horizontal line for each sequence, which changes its colors according
to the elements.

{pstd} Out of the box, sequence index plots have several shortcomings, which
should be dealt with when fine-tuning the graph:

{phang}o In general, colored versions of sequence index plots are
  more sensible than black-and-white versions. The {cmd:color()} opton allows
  fine-tuning of the colors used for the elements.

{phang}o Depending on variables such as the resulution of the screen,
the viewer used to show the figure, the resolution of the printer, or
the graph size, there can be a tendency to either overplot the lines,
which overrepresents elements with higher category values (levels) or
to have white stripes between the lines. The effect can be moderated
by tuning the option {cmd:overplot()} and/or the
{help aspectratio}. It might also be sensible to restrict the graph to the
most frequent sequences by using the {cmd:ranks()} option.

{phang}o Sequence index plots depend heavily on the order of
the sequences along the vertical axis. Without further options, a naive
algorithm is used to order the sequences; however, the {cmd:order()} option 
sorts the sequences according to a user-defined variable list. It is
sensible to use the results of {helpb sqom} to order the sequences in a
sequence index plot.


{title:Options}

{phang} {opt ranks(numlist)} is used to restrict the output to the
most frequent sequences. {it:{help numlist}} refers to the position of the
sequences in the sorted frequency table. Hence, {cmd:ranks(1)} refers to the
most frequent sequence, whereas {cmd:ranks(1/10)} refers to the 10 most frequent
sequences. You can also specify {cmd:ranks(2(2)20)}.

{phang}{cmd:se} is used to request that a plot showing only the elements of
sequences are used (same elements similarity). Hence, with this
option sequences like A-B-A-B, B-A-A-B, and A-B-B-A would be 
drawn as A-B.

{phang} {cmd:so} is used to request a plot where only the order of
elements is shown (same-order similarity). With this option the
sequences A-B-B-A and A-B-A-A would both be drawn as if they were
A-B-A.

{phang}{cmd:order(}{it:varlist}{cmd:)} is used to control the order of
the sequences along the vertical axis. Without this option, a simple
algorithm for the order is used. However, an order derived from an
application of {help sqom} is preferable. Note that within sequences
with the same pattern on the order variables the default algorithm is
applied.

{phang}{opt by(varname)} specifies to plot groups of sequences separately
based on {it:varname}.

{phang}{cmd:color(}{it:colorstyle}{cmd:)} specifies the colors for the
elements.  You can specify one color for each element, whereby the
first color refers to the element with the lowest level. See
{it:{help colorstyle}} for a list of color choices.{p_end}

{phang}{cmd:overplot(}{it:#}{cmd:)} lets you fine-tune the amount of
overplotting. The command tries to be smart about this setting, but
the solutions are not always satisfying, especially with either rather
small or rather large numbers of sequences. The default setting is
{cmd:overplot(60)}. Choose a smaller number if the lines for higher
levels appear to thicker than lines for lower levels. Choose a larger
number if there are white stripes between the lines. If you have only
few observations and/or draw sequence index plots with option by(),
you may want to use option {cmd:rbar}.{p_end}

{phang}{cmd:rbar} uses bars instead of spike to draw the
sequences. This option leads to serious overplotting even for moderate
number of observations but can be advantageous for small sample sizes
of when plots are drawn with option by(). {cmd:rbar}.{p_end}

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

{phang}{cmd:. sqindexplot}

{phang}{cmd:. sqindexplot, color(black red yellow)}

{phang}{cmd:. sqindexplot, so}

{phang}{cmd:. sqindexplot, se}


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}

{title:Also see}

{psee}
Manual:  {bf:[G] graph}, {bf:[G] graph twoway rbar}, {bf:[G] barlook options} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot}, {helpb sqmodalplot}
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}

