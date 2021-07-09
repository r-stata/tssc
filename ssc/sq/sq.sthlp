{smcl}
{* November 14, 2016 @ 13:23:58}{...}

{* link to other help files which could be of use}{...}
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


{cmd:help sq}{right:(SJ6-4: st0111)}
{hline}

{title:Title}

{phang}
{cmd:sq} {hline 2} Analysis of sequences
{p_end}


{title:Description}

{pstd} The term sq refers to sequence data and to the commands for
analyzing these data. Sequences are entities built by a limited number
of elements that are ordered in a specific way. A typical example is
human DNA, where the elements adenine, cytosine, guanine, and thymine
(the organic bases) are ordered into a sequence. Other sequences are
songs that are built by tones that appear in a specific order, or
careers of employers that are built by specific job positions and
ordered along time.

{pstd} Sequence data are data that contain one variable holding the
elements, one variable that contains the position of each element
within this sequence, and one variable that identifies the sequences
itself. Hence, sequence data require data that are set up in what
Stata usually calls the "long form" and which is explained in some
detail {help sq##1:below}.

{pstd} The SQ-Ados are a bundle of commands to describe, analyze, and
group the sequences of a sequence dataset. The following
sq commands are available:

{p2colset 9 27 29 2}{...}
{p2col : {it: Setting sequence data}}{p_end}
{p2col :{helpb sqset}}Declare data to be sequence data{p_end}

{p2col : {it: Description}}{p_end}
{p2col :{helpb sqdes}}Describe sequence concentration{p_end}
{p2col :{helpb sqtab}}Tabulate sequences{p_end}
{p2col :{helpb sqegen}}Generate variables reflecting entire
	sequences{p_end}
{p2col :{helpb sqstat}}Describe, summarize, and tabulate sq-egenerated
     variables' sequences{p_end}
{p2col :{helpb sqindexplot}}Graph sequences as sequence index plot{p_end}
{p2col :{helpb sqparcoord}}Graph sequences with parallel coordinates{p_end}
{p2col :{helpb sqmodalplot}}Index plot of modal categories{p_end}
{p2col :{helpb sqpercentageplot}}Range plot of percentage by order{p_end}

{p2col : {it: Similiarity measures}}{p_end}
{p2col :{helpb sqom}}Sequence similarity indices{p_end}
{p2col :{helpb sqstrlev}}Optimal matching for Strings{p_end}

{p2col : {it: Applications}}{p_end}
{p2col :{helpb sqstrmerge}}NN-Merge using optimal matching for strings{p_end}
{p2col :{helpb sqclusterdat}}Prepare a dataset to perform cluster analyses on the results of {helpb sqom}{p_end}
{p2col :{helpb sqmdsadd}}Adds the solution of an MDS on the results of {helpb sqom} to sequence data{p_end}
{p2col :{helpb sqclustermat}}Perform one cluster analysis on the results of {helpb sqom}{p_end}
{p2colreset}{...}

{pstd}
You begin an analysis by {cmd:sqset}ting your data, which tells Stata the key
sequence data variables; see {helpb sqset}.  Once you have {cmd:sqset} your
data, you can use the other sq commands.  If you {opt save} your data after
{cmd:sqset}ting it, you will not have to {cmd:sqset} it again in the future;
Stata will remember it.

{pstd} Please refer to {help sqdemo} for a quick demonstration of 
the sq commands.
{p_end}


{title:Remarks}

{pstd}
Remarks are presented under the following headings:

        {help sq##1:Sequences and how they are stored}
        {help sq##2:Typical research questions}
        {help sq##3:Gaps, missings, etc.}
        {help sq##4:Limitations}


{marker 1}{title:Sequences and how they are stored}

{pstd} An example for a sequence is the following chain of letters:

{center:A-G-C-T-T-T-T-G-C-A}

{pstd}
In this example, the letters might stand for
something else, such as the four organic bases adenine,
guanine, cytosine, and thymine of DNA. The chain of letters might,
however, also denote the tones of a song (using the letter "T" for a
break), the employment states in a job career, party preferences
during a lifetime, etc.

{pstd}In what follows, we will use the term "sequence" for the entire
chain, "element" for the states of the chain, and "position" for the
position on which a specific element is found. Hence, in the sequence
above, the element A is at positions 1 and 10, G is at position 2 and
8, etc.

{pstd}In Stata, sequences can be stored in two formats. The first
format is the wide form. Sequence data in wide form store
sequences underneath each other with one variable for each
position. Here is an example:

{center:         (wide form)           }

{center:{cmd:id  bas1   bas2   bas3   bas4}}
{center:{hline 31}}
{center:1      A      G     C     T  }
{center:2      G      C     T     A  }
{center:3      C      G     T     A  }


{pstd}The second format has one variable that indicates the sequence,
one variable that stores the position and another one that stores
the elements. This is called the long form. In long form, the above
example looks as follows:

{center:      (long form)      }

{center:{cmd:id   pos   bas  }}
{center:{hline 23}}
{center: 1     1    A }
{center: 1     2    G }
{center: 1     3    C }
{center: 1     4    T }
{center: 2     1    G }
{center: 2     2    C }
{center: 2     3    T }
{center: 2     4    A }
{center: 3     1    C }
{center: 3     2    T }
{center: 3     3    G }
{center: 3     4    A }

{pstd}The sq-commands expect sequence data in long form. Toggling
between wide and long form is easy with {helpb reshape}.


{marker 2}{title:Typical research questions}

{pstd} The first aim of sequence analysis is to describe the
sequences. With a few short sequences, it is easy to describe the
sequences by simply listing them, but in practice, there are usually
many sequences that tend to be rather long. It is therefore necessary
to have some specific tools that allow describing many long
sequences effectively. Among the sq-commands {helpb sqgen}, {helpb sqstat},
{helpb sqtab}, {helpb sqparcoord}, and {helpb sqindexplot} might be useful for
this task.

{pstd} The second aim of sequence analysis is to find certain
similarities of sequences. The similarity of sequences has to be
defined a little further, however. Look, for example, at the following
sequences, presented in wide form:

{center:{cmd:id  bas1   bas2   bas3   bas4}}
{center:{hline 31}}
{center:1      A      G     C     T  }
{center:2      G      C     T        }
{center:3      A      G              }

{pstd} First, the three sequences have different length. 
In terms of length, sequence 1 is more similar to sequence 2 than to sequence 3.
If one, however, compares the elements at each position, 
sequences 1 and 3 have the same elements at the first two positions, and
they differ only in that sequence 1 is longer than sequence 3. Sequence 2 has
different elements at each position from those of the two other sequences.
Hence, sequences 1 and 3 are more similar than 1 and 2 in this respect.
Finally, in a third respect, sequences 1 and 2 are quite similar.
They differ only in that sequence 1 starts with "A". If we delete the
first position from sequence 1, or insert "A" at the beginning of the second
sequence, both sequences would be identical. All tools to describe the
sequences can be also used to find similarities between the sequences in one
respect or another.  However, one of the sq-commands, {helpb sqom}, is
specially aimed to find similarities in the third respect. 

{pstd}Finally, if one has been able to depict certain typical
sequences, one might be interested in using sequence types as
independent variables in statistical models. Biostatisticians might be
interested in whether specific types of DNA sequences affect behavior or
appearance of species, and social scientists might be interested in
whether certain types of educational careers cause dangerous job
situations. The sq-commands therefore allow building variables for
grouping similar sequences together.


{marker 3}{title:Gaps, missings, etc.}

{pstd}If an element at a certain position is unknown, we call this a
gap. Gaps theortically can appear at the beginning, and/or in the
middle of a sequence, and we treat them differently.

{pstd}For sequence analysis, gaps create several problems -- not so
much in terms of technical problems but in terms of content. The way
one deals with gaps influences the substantial outcomes of sequence
analysis, and it depends on the research questions, which way of
dealing with gaps is the most appropriate. The SQ-Ados are generally
designed such that sequences that contain a gap in the middle are
not used in the analysis; however, they can be included in some of the
programs by using the option {cmd:gapinclude}.

{pstd}Unknown elements at the beginning or the end of a sequence are
generally not counted as a "gap". We do, however, recommend erasing
them with the options {cmd:ltrim}, {cmd:rtrim}, or {cmd:trim} of the
command {cmd:sqset}.

{pstd}Taking care of gaps is mainly up to the user.
To guide the user through his decisions, {helpb sqset} will control for
gaps and propose ways to deal with them.  In this section, we will explain
the various ways to deal with gaps in more detail.

{pstd}In sequence data, gaps can appear two ways. Presented in long
form, the first way is shown here:

{center:{cmd:id   pos   bas  }}
{center:{hline 23}}
{center: 1     1    A }
{center: 1     2      }
{center: 1     3    C }
{center: 1     4    T }

{pstd}There is no entry (or a missing), at position 2. In other
words, one does not know the element at position 2. The other way to
represent gaps is to erase an observation from the data:

{center:{cmd:id   pos   bas  }}
{center:{hline 23}}
{center: 1     1    A }
{center: 1     3    C }
{center: 1     4    T }

{pstd} Although both ways seem to represent the same
information, we let you {helpb sqset} the data only if gaps are
represented in the first way. With {helpb sqset}, an error message
will appear if gaps appear in the second form. To proceed, you need to
restructure your data such that gaps either appear the first way
or do not appear at all. Hence, you might go on with

{phang}{cmd:. fillin id pos}{p_end}

{pstd} which will bring you to the first way (as long as there is at
least one sequence without a gap at the second position), or you
restructure the variable holding the positions of the elements by
stating something like

{phang}{cmd:. bysort id: replace pos = _n}{p_end}

{pstd} After having decided how to deal with the "forbidden" gaps, one
can {helpb sqset} the data. However, if there are still gaps of the first
variety in the data, {helpb sqset} will display a note accordingly. You then
have several choices. The first choice always is to simply ignore the
note and to let the sq-commands deal with gaps however they like. The
second choice is to encode missings to a meaningful value. Hence, you
define the missing to be just another element:

{phang}{cmd:. replace base = "M" if base == "" }{p_end}

{pstd} The third choice is to keep only the longest available section
of each sequence that is not interrupted by gaps. This can be
achieved with the option {cmd:keeplongest} of {cmd:sqset}. 


{marker 4}{title:Limitations}

{pstd} For the SQ-Ados, sequence data are expected to be in long
format, which imposes no restrictions with respect to sequence
length. Much of the programming within the SQ-Ados is, however, done in
wide format, so that the maximum sequence length is somewhat less than the
number of variables allowed in the respective flavor of Stata (32,000
in Stata/SE and 2,047 in Intercooled Stata).

{pstd} The command {helpb sqom} with option {opt full} stores its results by
pushing a Mata matrix into a Stata matrix. The maximum dimension of
the Stata matrix is 11,000 x 11,000. The flavor of Stata and
the {help matsize} plays no role for this restriction.

{pstd} Given the limits and speed problems, optimal matching as it is
implemented in {helpb sqom} seems capable of working with a moderate
number of relatively short sequences. It has been tested for around 2,000
sequences of length up to 100 positions.


{title:Authors}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}
{pstd}Magdalena Luniak{p_end}
{pstd}Christian Brzinsky-Fay, WZB, brzinsky-fay@wzb.eu.de{p_end}

{pstd}Bug reports go to Ulrich Kohler. Questions on applications of
sequence analysis are handled by Christian Brzinsky-Fay.{p_end}


{title:Also see}

{psee}
Manual:  {bf:[D] reshape} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}
