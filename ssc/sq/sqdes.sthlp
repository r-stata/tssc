{smcl}
{* 25march2006}{...}
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

{cmd:help sqdes}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqdes} {hline 2} Describe sequence concentration}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqdes}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opt so}}apply same-order similarity{p_end}
{synopt:{opt se}}apply same-elements similarity{p_end}
{synopt:{opt graph}}display results graphically{p_end}
{synopt:{opt gap:include}}include sequences with gaps in the tabulation{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synoptline}


{title:Description}

{pstd} {cmd:sqdes} is a way to describe the concentration of sequences
in the dataset.  Considering the limiting case when all respondents
share the same sequence, one would speak of a high concentration of
sequences, whereas one would speak of a low concentration if all
observed sequences were unique. Hence, the more only a few sequences are
shared by many respondents, the higher the concentration of sequences
is, whereas the more sequences that are unique, the lower the concentration.

{pstd}The command {cmd: sqdes} provides this and some further
information about the concentration or diversification of sequences.


{title:Options}

{phang} {cmd:so} is used to request a frequency table, where similar
sequences have been grouped together beforehand. The concept for
similarity used with the option {opt so} is called same-order
similarity, because it treats sequences where the elements appear in
the same order. The sequence A-B-B-A would be treated identical to
A-B-A-A, because the elements A and B appear in the same order in both
sequences (first A, then B, and then A again).

{phang}{cmd:se} is used to request a frequency table, where similar
sequences have been grouped together beforehand. The concept for
similarity used with the option {opt so} is called same-elements
similarity, because it treats sequences that consist of the same
elements as identical. Hence, with this option the sequence B-A-A-B
would be treated as identical to A-B-B-A, because both sequences
consist of the elements A and B.

{phang}{cmd:graph} provides a simple vertical bar chart of the table
presented with {cmd:sqdes}. Sequences are highly concentrated if many
and/or high bars are on the right of the graph, and fairly unique if
they are on the left. You can specify all options available for
{helpb graph twoway bar}  to further control the look of the
graph. {p_end}

{phang}{cmd:gapinclude} is used to include sequences with gaps in the
tabulation. The default behavior is to drop sequences with gaps from
the tabulation, because they cannot be used in the program {helpb sqom}.
The term "gap" refers only to missing values on the element variable within
a sequence. Sequences with missing values at the beginning and at the end of a
sequence are included in any case. See {help sq##3:sq} for details.{p_end}


{phang}{cmd:subsequence(a,b)} is used to include only the part of
the sequence that is between position a and b, whereby a and b refer
to the position defined in the order variable. {p_end}

{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Examples}

{phang}{cmd:. sqdes}

{phang}{cmd:. sqdes, so}

{phang}{cmd:. sqdes, so graph}


{title:Also see}

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}
