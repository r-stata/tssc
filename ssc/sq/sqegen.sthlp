{smcl}
{* November 14, 2016 @ 18:06:16}{...}
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


{hline}
help for {cmd:sqegen}{right:(SJ6-4: st0111)}
{hline}

{title:Extensions to generate (for sequence data)}

{p 8 17 2}{cmd:egen}
[{it:type}]
{it:newvar}
{cmd:=}
{it:sqfcn}{cmd:()}
{ifin}
[{cmd:,} {it:options}]

{phang}{cmd:Note:} All functions described here allow the option
{cmd:subsequence(a,b)}. It is used to include only the part of the
sequence that is between position a and b, whereby a and b refer to
the position defined in the order variable. {p_end}

{title:Description}

{pstd} {helpb egen} creates {it:newvar} of the optionally specified storage
type equal to {it:sqfcn}{cmd:()}. Unlike standard {cmd:egen} syntax, argument
of {it:sqfcn}{cmd:()} is generally left empty.


{title:Functions}


{phang} {cmd:sqallpos()} {cmd:,} {opt pat:tern(string)} [ gapinclude
   {opt subseq:uence(range)} {opt so}] generates a variable holding the number
   of occurences in the sequence of the given pattern. To specify the
   pattern use element[:repetitions] [element:repetitions].  For
   example, with {cmd: pattern(3:20 5 1:20 3:20)} you specifiy a
   pattern of length 61, starting with element 3 over 20 positions,
   followed by one position of elment 5, 20 positions of element 1 and
   finally again 20 positions of element 3.

   {p 8 8 0} When specifiying option {cmd:so} the specified pattern is
   interpreted in the sense of "same order", i.e. "A B B A" and "A B
   A" are both found if you search for for pattern "A B A". See
   {help sqtab} for further details on the "same order" specification.

   {p 8 8 0} Note: The program only considers independent occurences
   of pattern, i.e. if a pattern starts at a position within an
   already counted pattern it will be skiped. For example, consider
   the sequence "A A A B A A", in which you want to count the number
   of occurences of the pattern "A A". The program will count the
   pattern "A A" starting at positions 1 and 5. It will skip "A A"
   starting at postion 2 because its first element is part of the
   first instance. {p_end} {p 8 8 0} Also see below the egen-function
   {cmd:sqfirstpos()} for the position of the first occurence of a
   pattern.{p_end}


{phang} {cmd:sqelemcount()} [{cmd:,} {opt e:lement(#)} {cmd:gapinclude}]
generates a variable holding the number of different elements in each
sequence. If {cmd:gapinclude} is specified, variables get defined even for
sequences containing gaps. Missing values are generally counted as an element
of their own. You might consider using {cmd:sqset} with option {cmd:trim} to
get rid of superfluous missings.

{phang} {cmd:sqepicount()} [{cmd:,} {opt e:lement(#)} {cmd:gapinclude}]
separates a sequence into sections of equal elements (called "episodes"), and
generates a variable holding the number of episodes for each sequence.
With option {cmd:element()} only the number of episodes of the specified
element is generated. If {cmd:gapinclude} is specified, variables get defined
even for sequences containing gaps. Episodes with missing values are
generally counted as an element of their own. You might consider using
{cmd:sqset} with option {cmd:trim} to get rid of superfluous missings.


{phang} {cmd:sqfirstpos()} {cmd:,}
   {opt pat:tern(string)} [ gapinclude {opt subseq:uence(range)} ]
generates a variable holding the position of the first occurence of the given
pattern. To specify the pattern use element[:repetitions] [element:repetitions].
For example, with {cmd: pattern(3:20 5 1:20 3:20)} you specifiy a pattern
of length 61, starting with element 3 over 20 positions, followed by one position
of elment 5, 20 positions of element 1 and finally again 20 positions of element 3.
{p_end}


{p 8 8 0} When specifiying option {cmd:so} the specified pattern is
 interpreted in the sense of "same order", i.e. "A B B A" and "A B
 A" are both found if you search for for pattern "A B A". See
 {help sqtab} for further details on the "same order" specification.

{p 8 8 0} Also see above the egen-function {cmd:sqallpos()} for
  the number of occurence of a pattern.{p_end}

{phang} {cmd:sqfreq()} [{cmd:,} {cmd:gapinclude so se}
{opt subseq:uence(range)} ] generates a variable holding the frequencies of
each sequence-type. These are the numbers given in the output of
{help sqtab} stored as a variable. The options {cmd: so} and {cmd: se}
are described in detail under {help sqtab}. If {cmd:gapinclude}
is specified, variables get defined even for sequences containing
gaps.  Missing values are used as yet another element. You might
consider using {cmd:sqset} with option {cmd:trim} to get rid of
superfluous missings.

{phang} {cmd:sqgapcount()} generates a variable holding the number of
gap episodes in each sequence. Only gaps within a sequence is counted
as gap (see {help sq##3:sq}). You might consider using {cmd:sqset} with option
{cmd:trim} to get rid of "gaps" at the beginning or the end of sequences.

{phang} {cmd:sqgaplength()} generates a variable holding the overall
length of gap episodes in each sequence. Only gaps within a sequence
is counted as gap (see {help sq##3:sq}). You might consider using {cmd:sqset}
with option {cmd:trim} to get rid of "gaps" at the beginning or the end of
sequences.

{phang} {cmd:sqlength()} [{cmd:,} {opt e:lement(#)} {cmd:gapinclude}]
generates a variable holding the length -- the number of positions -- of each
observed sequence.  With option {cmd:element()}, the length of all episodes of
the specified element is generated. If {cmd:gapinclude} is specified,
variables get defined even for sequences containing gaps. Episodes with
missing values adds to the length of the sequences. You might consider using
{cmd:sqset} with option {cmd:trim} to get rid of superfluous missings.

{phang} {cmd:sqranks()} [{cmd:,} {cmd:gapinclude so se}
{opt subseq:uence(range)} ] generates a variable holding rank of the
frequencies "league-table" of sequence-types. These are the numbers that define
the order of frequencies in the output of {help sqtab} stored as a variable.
The options {cmd: so} and {cmd: se} are described in detail under {help sqtab}.
If {cmd:gapinclude} is specified, variables get defined even for sequences containing
gaps.  Missing values are used as yet another element. You might
consider using {cmd:sqset} with option {cmd:trim} to get rid of
superfluous missings.

{phang} {cmd:sqstrnn(varname)} [{cmd:, max(#)} {cmd:sqstrlev-options}
] generates a new variable holding strings of varname that have a
Levenshtein distance below {cmd:max()}. For the calculation of the
Levenshtein distance all options allowed with {help sqstrelev} are
allowed.  The option max() defaults to max(1), meaning that the new
variable will hold all strings in varname which miss one letter of the
comparison string, or have one additional letter attached to the
comparison string.


{phang} {cmd:sqtostring()} [{cmd:,} {cmd:gapinclude so se} {opt subseq:uence(range)} ] generates a string representation of the
sequences. String representation follows the notation
element[:repetitions] [element:repetitions]. {cmd:3:20 5 1:20 3:20} is
a sequence that starts with element 3 over 20 positions, followed by
one position of elment 5, 20 positions of element 1 and finally again
20 positions of element 3. The options {cmd:so} and {cmd:se} are
described in detail under {help sqtab}.  If {cmd:gapinclude} is
specified, variables get defined even for sequences containing gaps.
Missing values are used as yet another element. You might consider
using {cmd:sqset} with option {cmd:trim} to get rid of superfluous
missings.

{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Examples}

{phang}{cmd:. egen length = sqlength()}

{phang}{cmd:. egen length1 = sqlength(), element(1) gapinclude}

{phang}{cmd:. egen elemnum = sqelemcount()}

{phang}{cmd:. egen epinum = sqepicount()}


{title:Also see}

{psee}Manual:  {bf:[D] egen} 

{psee}Online: {helpb egenmore} (if installed), {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}
