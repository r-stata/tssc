{smcl}
{* März 17, 2016 @ 17:09:17}{...}

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

{cmd:help sqom}{right:SJ6-4: st0111)}
{hline}

{title:Title}

{p2colset 5 11 13 2}{...}
{p2col :{hi:sqom} {hline 2} Optimal matching of sequences}{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmdab:sqom}
{ifin}
[{cmd:,} {it:options}]

{p 8 17 2}
{cmdab:sqom save} {it: filename} [{cmd:, replace}] 

{p 8 17 2}
{cmdab:sqom use} {it: filename} [{cmd:, clear}] 

{synoptset 40}{...}
{synopthdr}
{synoptline}
{synopt:{opt full}}calculate full dissimilarity matrix between sequences{p_end}
{synopt:{opt indel:cost(#)}}set indel costs to {it:#}{p_end}
{synopt:{opt ideal:type(spec)}}compare with a specified ideal typical sequence{p_end}
{synopt:{opt k(#)}}restrict indels (to save calculation time){p_end}
{synopt:{opt name(varname)}}specify name for distance variable{p_end}
{synopt:{opt ref:seqid(spec)}}select reference sequence{p_end}
{synopt:{opt sadi(name)}}call SADI-plugin (if installed){p_end}
{synopt:{cmdab:st:andard(}{it:#}|{cmd:cut}|{cmd:longer}|{cmd:longest}|{cmd:none)}}standardization of sequences of different length{p_end}
{synopt:{cmdab:sub:cost(}{it:#}|{it:implied formula}|{it:matexp}|{it:matname}{cmd:)}}specify substitution costs{p_end}
{synopt:{opt subseq:uence(a,b)}}use only subsequence between positions a and b{p_end}
{synoptline}
{synopt:{opt clear}}overwrites matrix SQdist with matrix on disk{p_end}
{synopt:{opt replace}}overwrites file on disk{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd} {cmd:sqom} performs optimal matching of sequences. The command
uses the Needleman-Wunsch algorithm to find the alignment between two
sequences that have the lowest Levenshtein distance. The Levenshtein
distances are then stored for further use.

{pstd} {cmd:sqom} also provides an interface to the distance measures
of Brandan Halpins SADI programms, such as the "Hamming distance", 
"Halpins Duration-Adjusted OM", the "Hollister's Localised OM",
"Lesnard's Dynamic Hamming measure", "Time-Warp Edit Distance", and
"Elzinga's number of common subsequences measure". Distances are stored
for further use.

{pstd}By default, all sequences are compared to the most frequent
sequence and the resulting distances are stored in a variable. It is,
however, possible to compare all sequences with a preselected
reference distance or to compare all sequences with every other
sequence. In the latter case, the resulting distances are stored in a
Stata matrix. 

{pstd}Comparing all sequences with any other sequence is
computationally intensive. We recommend the option {cmd:sadi()} for
working with large datasets.

{pstd} {cmd:sqom save} saves the distance matrix obtained by
{cmd:sqom, full} under the given filename on disk. If filename is
given without extension, .mmat is used.

{pstd} {cmd:sqom use} retrieves a distance matrix stored as a file on
disk for subsequent use by other sequence analysis commands. If
filename is given without extension .mmat is assumed.

{title:Options}

{phang} {opt indelcost(#)} specifies the cost attached to an
insertion or deletion of an alignment. The default is {cmd:indelcost(1)}.

{phang} {cmdab:sub:cost(}#|{it:implied
formula}|{it:matexp}|{it:matname}} specifies the cost attached to a
substitution in an alignment. Substitution costs may be specified as
real number, as implied formula, or as full matrix.  Specifying
substitution cost as, for example, {cmd:subcost(3)} will attach the
cost of 3 to any substitution necessary in an alignment, regardless of
how similar the substituted values may be. The default is two times
the value specified as indel cost.  A full substitution cost matrix
can be specified either by specifying the name of a matrix containing
the substitution cost or by typing valid matrix syntax into the option
itself.  The matrix has to be a symmetric n*n matrix, where n is the
number of different elements in all sequences.

{p 8 8 2}{it:implied formula} generates substitution costs based on the data. The implied formula is specified with a keyword. The following keywords are allowed

{p2colset 8 30 30 0} 
{p2line}
{p2col:{opt rawdistance}}use the
absolute value of the difference between the numeric values representing the respective elements{p_end}
{p2col:{opt meanprobdistance}}calculates symmetric substitiution cost matrix based on the mean of the transitions' probabilities {it:(p)} in the data 
between every two neighboring elements in the sequences. The substitution costs between elements x and y are defined by: SC(x,y) = SC(y,x) = 2-p(x,y)-p(y,x) if x is not equal to y, otherwise 0.{p_end}
{p2col:{opt minprobdistance}}calculates symmetric substitiution cost matrix based on the transitions' probabilities {it:(p)} in the data 
between every two neighboring elements in sequences. The substitution cost matrix contains the minimal substitution costs for 
each pair of symmetric transitions: SC(x,y) = SC(y,x) = min(1-p(x,y),1-p(y,x))*2 if x is not equal to y, otherwise 0.{p_end}
{p2col:{opt maxprobdistance}}calculates symmetric substitiution cost matrix based on the transitions' probabilities {it:(p)} in the data 
between every two neighboring elements in sequences. The substitution cost matrix contains the maximal substitution costs for 
each pair of symmetric transitions: SC(x,y) = SC(y,x) = max(1-p(x,y),1-p(y,x))*2 if x is not equal to y, otherwise 0.{p_end}
{p2line}
{p2colreset}{...}
{p 8 8 2}The substitution costs in last three cases have values between 0 and 2

{p 8 8 2}Specifying a full substitution cost matrix or generating a data based substitution
cost matrix can increase the running time of the program considerably.
Options {cmd:k()}, or {cmd:sadi()} might be considered for {cmd:sqom} with full
substitution cost matrix. 

 {phang} {opt name(varname)} is used to specify the name of the
variable in which the distances are stored. If not specified,
{cmd:_SQdist} is used. The automatically generated distance
variable will get overwritten without warning whenever a {cmd:sqom}
command without {cmd:name()} is invoked.

{phang} {opt refseqid(spec)} is used to select the
reference sequence against which all sequences in the dataset are
being tested. Within the parentheses, an existing value of the sequence
identifier has to be stated.

{phang} {cmd:full} is used to perform optimal matching for all
sequences in the dataset against any other. The results of these
comparisons are stored in the distance matrix "SQdist". Specifying
the option {cmd:full} will increase the running time of the program
considerably. Options {cmd:k()}, or {cmd:sadi()} might be considered for {cmd:sqom} 
{cmd:full}.

{pmore}Two companion programs, {help sqclusterdat} and {help sqclustermat},
help to further analyze the distance matrix produced with {cmd: sqom, full}. 

{phang}{opt k(#)} is used to speed up the calculation of the
optimal matching algorithm. Within the parentheses, an integer
positive number between 1  and the number of positions of the longest
sequence can be given. The speed up will be higher with small numbers.
Very small numbers can have the effect that the algorithm doesn't find
the best alignment between some sequences, and this problem tends to
increase if substitution costs are high relative to indel
costs. The option is ignored when option {cmd:sadi()} is specified.

{p 8 8 2}Note: The implementation of the {cmd:k()} is based partly on the
source code of TDA, written by Goetz Rohwer and Ulrich Poetter. TDA is
a very powerful program for transitory data analysis. It is programmed
in C and distributed as freeware under the terms of the General
Public License. It is downloadable from
{browse "http://www.stat.ruhr-uni-bochum.de/tda.html"}.

{phang} {cmd:sadi(}{it:name}{cmd:)} calls Brandan Halpins SADI
programs for calculating the full distance matrix. These programs are
developed independenly from the SQ-Ados as plugins written in the
command language C and therefore run much faster than the Mata
implmentation used for standard {cmd:sqom}. Options of {cmd:sqom} are
automatically translated to SADI, and all further functionality of the
SQ-Ados remain unchanged. {cmd:sqom} also automatically handles all
required options of SADI and allow the specification of the additional
SADI options (see help {help sadi}).

{p 8 8 2}{cmd:sadi()} allows to specify one of the following distance
measures. Note that Elzinga's number of common subsequences measure,
which is implemented in SADI is not yet supported by {cmd:sqom, sadi()}


{p2colset 8 20 22 0} 
{p2col:{opt name}}Distance measure{p_end}
{p2line}
{p2col:{opt hamming}}Hamming distance{p_end}
{p2col:{opt oma}}Levenshtein (same as standard {cmd:sqom}){p_end}
{p2col:{opt omav}}Halpin's duration-adjusted OM{p_end}
{p2col:{opt hollister}}Hollister's "Localised OM"{p_end}
{p2col:{opt dynhamming}}Lesnard's Dynamic Hamming measure{p_end}
{p2col:{opt twed}}Time warp edit distance{p_end}
{p2line}
{p2colreset}{...}

{pmore}Two companion program, {help sqclusterdat} and {help sqmdsadd}
help to further analyze the distance matrix produced with {cmd: sqom, sadi()}. 

{phang}
{cmdab:st:andard(}#|{cmd:cut}|{cmd:longer}|{cmd:longest}|{cmd:none)}
is used to define the standardization of the resulting distances. With
{cmd:standard(#)} all sequences are cut to the length {it:#}.  The keyword
{cmd:cut} automatically cuts all sequences to the length of the
shortest sequence in the dataset. {cmd:standard(longer)} divides all
distances by the length of the longer sequence of the respective
alignment. {cmd:standard(longest)} divides all distances by the length
of the longest sequence in the dataset; this is the
default. {cmd:none} is specified if no standardization is needed.

{phang}{cmd:subsequence(a,b)} is used to include only the part of
the sequence that is between position a and b, whereby a and b refer
to the position defined in the order variable. {p_end}

{phang}{cmd:idealtype(spec)} allows to specify an ideal typical
sequence against which all sequences are compared. To specify the
sequence use element[:repetitions] [element:repetitions]. For example,
with {cmd: idealtype(3:20 5 1:20 3:20)} you specifiy an ideal typical
sequence of length 61. The ideal typical sequence starts with element
3 over 20 positions, followed by one position of elment 5, 20 positions
of element 1 and finally again 20 positions of element 3.  {p_end}


{title:Authors}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}
{pstd}Magdalena Luniak{p_end}


{title:Examples}

{phang}{cmd:. sqom, name(mydist)}{p_end}
{phang}{cmd:. sqindexplot, order(mydist)}{p_end}

{phang}{cmd:. sqom, full k(2)}{p_end}
{phang}{cmd:. sqclustermat ward, name(mydist2)}{p_end}
{phang}{cmd:. sqindexplot, order(mydist2)}{p_end}


{title:Also see}

{psee} Online: {helpb sq},
{helpb sqdemo}, {helpb sqset}, {helpb sqdes}, {helpb sqegen}, {helpb sqstat},
{helpb sqindexplot}, {helpb sqparcoord}, {helpb sqom},
{helpb sqclusterdat}, {helpb sqclustermat} {p_end}
