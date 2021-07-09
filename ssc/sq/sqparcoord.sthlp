{smcl}
{* September 5, 2013 @ 16:54:42}{...}
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

{cmd:help sqparcoord}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqparcoord} {hline 2} Parallel-coordinates plot for sequence data}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqparcoord}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opt ranks(numlist)}}restrict tabulation on most frequent
{it:numlist}{p_end}
{synopt:{opt so}}apply same order similarity{p_end}
{synopt:{opt offset(#)}}add random noise to vertical position of sequence lines{p_end}
{synopt:{opt wlines(#)}}highlight sequence lines according to frequency{p_end}
{synopt:{opt gapinclude}}include sequences with gaps in the tabulation{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synopt:{it:line_options}}most options described in {helpb line_options}{p_end}
{synopt:{it:twoway_options}}options allowed for {helpb graph twoway}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd} {cmd:sqparcoord} draws sequences as a parallel-coordinates plot,
with some trickery added.


{title:Options}

{phang}{opt ranks(numlist)} is used to restrict the output to the
most frequent sequences. {it:{help numlist}} refers to the position of the
sequences in the sorted frequency table. Hence, {cmd:ranks(1)} refers to the
most frequent sequence, whereas {cmd:ranks(1/10)} refers to the 10 most
frequent sequences. You can also specify {cmd:ranks(2(2)20)}.

{phang}{cmd:so} is used to request a plot where only the order of
elements is shown (same-order similarity). With this option the
sequences A-B-B-A and A-B-A-A would both be drawn as if they were
A-B-A. Option {cmd:se}, which is available for many other
SQ-Ados, is not applicable here.

{phang}{opt offset(#)} adds random noise to the vertical position of
sequence lines.

{phang}{cmd:wlines(#)} is used draw more frequent sequences thicker
than le,ss frequent ones. Within the parentheses a number is used to
specify the factor by which the thickness is increased. The number
given is multiplied with the relative frequency of the sequences and
passed as {it:{help relativesize}} to the option {cmd:lwidth()} of
{helpb graph twoway line} (also see {it:{help linewidthstyle}}).

{phang}{cmd:gapinclude} is used to include sequences with gaps. The
default behavior is to drop sequences with gaps from the graph. The
gaps will be not visible in the parallel-coordinates plot. 
The term gap refers only to missing values on the element variable
within a sequence. Sequences with missing values at the beginning and
at the end of a sequence are included in any case. You might consider
using {cmd:sqset} with option {cmd:trim} to get rid of superfluous
missings (see {help sq##3:sq} for details.){p_end}

{phang}{cmd:subsequence(a,b)} is used to include only the part of
the sequence that is between position a and b, whereby a and b refer
to the position defined in the order variable. {p_end}

{phang} {it:line_options} are most of the options described in
{it:{help line_options}}, nameley {cmd:lwidth()}, {cmd:lpattern()},
{cmd:lcolor()} and {cmd:lstyle()}. For the former three, several
arguments can be specified, whereby the first argument controls the
characteristic of the line for the most frequent sequence, the second
argument controls the characteristic for the second most frequent
sequence, and so on. If you whish to change widths, colors, and/or
line patterns of all lines in the graph, you can use Stata's normal
continuation syntax, for example {cmd:lcolor(red..)},
{cmd:lpattern(dash..)}, and/or {cmd:lwidth(*3..)}.

{phang}
{it:twoway_options} are a set of common options supported by all
{cmd:twoway} commands; see {it:{help twoway_options}}.


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ukohler@uni-potsdam.de{p_end}

{title:Examples}

{phang}{cmd:. sqparcoord, wline(3) lcolor(cyan magenta yellow black}

{phang}{cmd:. sqparcoord, ranks(1/10) offset(.2)}


{title:Also see}

{psee}
Manual:  {bf:[G] graph}, {bf:[G] graph twoway rbar}, {bf:[G] barlook options} 

{psee} Online: {helpb parcoord} (if installed), {helpb sq},
{helpb sqdemo}, {helpb sqset}, {helpb sqdes}, {helpb sqegen}, {helpb sqstat},
{helpb sqindexplot}, {helpb sqparcoord}, {helpb sqom},
{helpb sqclusterdat}, {helpb sqclustermat} {p_end}
