{smcl}
{* 10april2006}{...}
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

{cmd:help sqset}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi: sqset} {hline 2}}Declare a dataset to be sequence data{p_end}
{p2colreset}{...}


{title:Syntax}

{pstd}Declare data to be sequence data and specify element variable,
the sequence identifier and sequence order (positions)

{p 8 15 2}
{cmd:sqset} {it:elementvar idvar ordervar}
                [{cmd:, trim rtrim ltrim keeplongest} ]

{pstd} where {it:elementvar} is the variable that contains the
    elements of sequences, {it:idvar} is a variable that
    identifies the sequences, and {it:ordervar} is a variable that
    defines the order of the sequences.

{pstd}Display how dataset is currently sqset

{p 8 15 2}
{cmd:sqset}

{pstd}Clear sequence data settings

{p 8 15 2}
{cmd:sqset, clear}


{title:Description}

{pstd}
{cmd:sqset} declares the data to be sequence data and designates that
{it:elementvar} represents the variable that represents the elements
of the sequences, {it:idvar} should be an identifier of the
sequences, and {it:ordervar} should be a variable that defines the
order of each sequence.

{pstd} When using {cmd:sqset} various checks on the data are
performed, and reported back to the user.

{pstd} {cmd:sqset} without arguments displays whether and how the
 dataset is currently set.

{pstd} {cmd:sqset, clear} is a rarely used to erase the settings from the data. 

{pstd} To use {cmd:sqset}, sequence data has to be in long format. Use
{helpb reshape} to change sequence data in wide format to sequence data
in long format.


{title:Options}

{phang} {cmd:trim} means both, {cmd:ltrim} and {cmd:rtrim}. Generally,
we recommend using this option.

{phang} {cmd:rtrim} erases empty elements at the end of the
sequences. Sequence data that stem from data in wide format often
contain missing values at the end of sequences. Generally, there is no
need for these observations, so that they can simply be erased without
loss of information. 

{phang} {cmd:ltrim} strips all empty elements at the beginning of the
sequences. Generally, all sequences should start with the element at
the first position. In practice, sequence data sometimes have one or
more empty elements at the beginning, which we call "gaps at the
beginning". Gaps at the beginning are very common for sequence data
that has its origins in unbalanced cross-sectional time-series data
(see {help xt}). The SQ-Ados slightly differ in how they deal
with gaps at the beginning. Gaps at the beginning are, however,
somewhat ill-treated, as this means that a sequence does not start at
the first position. {cmd:ltrim} changes the sequence data in such a
way that all sequences starts at position one. The dataset is changed
by the option {cmd:ltrim}.

{phang} {cmd:keeplongest} keeps only the longest section of a sequence
with unknown elements at specific positions. Generally, a missing
value at a certain position in a sequence is just another element, so
there is no specific technical problem. For some commands
(i.e., {helpb sqom}), it is however necessary to consider how similar the
missing value is with each of the other elements of a sequence. The
answer to this cannot be given by the SQ-Ados themselves. In order to
point the user to such problems, {cmd:sqset} checks for missing
elements and provides a note. The note points the user to the option
{cmd:keeplongest}. {cmd:sqset} with {cmd:keeplongest} will force Stata
to keep only the longest available section of a sequence that contains
missings. If several sections of a sequence have the same, Stata will
randomly select one of them. The dataset is changed by the option
{cmd:keeplongest}, and that {cmd:keeplongest} is only one of several
ways to deal with missing elements in a sequence
(see {help sq##3:sq}). 


{title:Examples}

{phang}{cmd:. use http://www.wz-berlin.de/~kohler/ado/youthemp, clear}{p_end}
{phang}{cmd:. reshape long st, i(id) j(order)}{p_end}
{phang}{cmd:. sqset st id order}


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Also see}

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
                {helpb sqdes}, {helpb sqegen}, {helpb sqstat},
		{helpb sqindexplot}, {helpb sqparcoord}, {helpb sqom},
		{helpb sqclusterdat}, {helpb sqclustermat}
{p_end}
