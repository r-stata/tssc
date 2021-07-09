{smcl}
{* Juni 5, 2013 @ 11:14:12}{...}
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


{cmd:help sqtab}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqtab} {hline 2} Tabulate sequences}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqtab}
[{varname}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20}{...}
{synopthdr}
{synoptline}
{synopt:{opth ranks(numlist)}}restrict tabulation on most frequent {it:numlist}{p_end}
{synopt:{opt se}}apply same-elements similarity{p_end}
{synopt:{opt so}}apply same-order similarity{p_end}
{synopt:{opt nosort}}do not sort according to frequency{p_end}
{synopt:{opt gapinclude}}include sequences with gaps in the tabulation{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synopt:{it:tabulate_options}}any options documented in {helpb tabulate}{p_end}
{synoptline}


{title:Description}

{pstd} {cmd:sqtab} displays frequency tables of all sequences in the
dataset. Sequences are described by using the following notation:
element[:repetitions] [element:repetitions]. {cmd:3:20 5 1:20 3:20}
describes a sequence that starts with element 3 over 20 positions, followed
by one position of elment 5, 20 positions of element 1 and finally
again 20 positions of element 3.  

{pstd}If the optional variable name is specified, a cross tabulation of
the sequences with the specified variable will be produced.


{title:Options}

{phang} {opt ranks(numlist)} is used to restrict the output to the
most frequent sequences. {it:{help numlist}} refers to the position of the
sequences in the sorted frequency table. Hence, {cmd:ranks(1)} refers to the
most frequent sequence only, whereas {cmd:ranks(1/10)} refers to the 10 most
frequent sequences. You can also specify {cmd:ranks(2(2)20)}.

{phang}{cmd:se} is used to request a frequency table, where similar
sequences have been grouped together beforehand. The concept for
similarity used with the option {opt so} is called same elements
similarity, because it treats sequences that consist of the same
elements as identical. Hence, with this option the sequence B-A-A-B
would be treated as identical to A-B-B-A, because both sequences
consist of the elements A and B.

{phang} {cmd:so} is used to request a frequency table, where similar
sequences have been grouped together beforehand. The concept for
similarity used with the option {opt so} is called same order
similarity, because it treats sequences where the elements appear in
the same order. The sequence A-B-B-A would be treated identical to
A-B-A-A, because the elements A and B appear in the same order in both
sequences (first A, then B, and then A again).

{phang} {cmd:nosort} changes the default of listing sequences in the
table according to their frequency. This change is reasonable, because
many sequences are probably unique. The option {opt nosort}
turns this default behavior off.

{phang}{cmd:gapinclude} is used to include sequences with gaps in the
tabulation. The default behavior is to drop sequences with gaps from
the tabulation, because they cannot be used in the program
{helpb sqom}.  The term gap refers only to missing values on the
element variable within a sequence. Sequences with missing values at
the beginning and at the end of a sequence are included in any
case. See {help sq##3:sq} for details.{p_end}

{phang}{cmd:subsequence(a,b)} is used to include only the part of
the sequence that is between position a and b, whereby a and b refer
to the position defined in the order variable. {p_end}

{phang}{it:tabulate_options} are any of the options documented
in {helpb tabulate oneway} or {helpb tabulate twoway}.


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Examples}

{phang}{cmd:. sqtab}

{phang}{cmd:. sqtab, so ranks(1/20)}

{phang}{cmd:. sqtab, se nosort}


{title:Also see}

{psee}
Manual:  {bf:[D] tabulate} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}
