{smcl}
{.-}
help for {cmd:intext} and {cmd:tfconcat} {right:(Roger Newson)}
{.-}


{title:Read text files into string variables in the memory (without losing blanks)}

{p 8 27}
{cmd:intext} {cmd:using} {it:filename} {cmd:,} {cmdab:g:enerate}{cmd:(}{it:prefix}{cmd:)}
[ {cmdab:le:ngth}{cmd:(}{it:#}{cmd:)} {cmdab:clear:} ]

{p 8 27}
{cmd:tfconcat}  {it:filename_list}  {cmd:,} {cmdab:g:enerate}{cmd:(}{it:prefix}{cmd:)}
[ {cmdab:le:ngth}{cmd:(}{it:#}{cmd:)}
{cmdab:tfi:d}{cmd:(}{it:{help newvarname}}{cmd:)} {cmdab:tfn:ame}{cmd:(}{it:{help newvarname}}{cmd:)}
{cmdab:obs:seq}{cmd:(}{it:{help newvarname}}{cmd:)}
]

{pstd}
where {it:filename_list} is a list of filenames separated by spaces.


{title:Description}

{pstd}
{cmd:intext} inputs a single text file into a set of generated string variables in
the memory, generating as many string variables as is necessary to store the longest
records in full, without trimmming leading and trailing blanks (as {helpb infix} does).
{cmd:tfconcat} takes, as input, a list of filenames, assumed to belong to text
files, and concatenates them (without losing blanks) to create a new data set in memory,
overwriting any pre-existing data. The new data set contains one observation for each
record in each text file, ordered primarily by source text file and secondarily by
order of record within source text file, and contains a set of generated string
variables containing the text, as created by {cmd:intext}.
Optionally, {cmd:tfconcat}
creates new variables, specifying, for each observation, the input text file of origin
and/or the sequential order of the observation in its input text file of origin.


{title:Options for {cmd:intext} and {cmd:tfconcat}}

{p 4 8 2}
{cmd:generate(}{it:prefix}{cmd:)} is not optional. It specifies a prefix for the names
of the new string variables generated, which will be named as {it:prefix1 ... , prefixn},
where {it:n} is the number of string variables required to contain the longest text record
in any input data set, with length as specified by the {cmd:length} option.

{p 4 8 2}
{cmd:length(}{it:#}{cmd:)} specifies the maximum length of the generated text variables. If absent,
it is set to 80.
The value of {cmd:length()} must be an integer between 1 and the maximum length of a {help datatypes:strL variable} on the version of Stata being used.
This value is stored in the {help creturn: c-class value} {cmd:c(maxstrlvarlen)}.
See also help for {help limits}.


{title:Options for {cmd:intext} only}

{p 4 8 2}
{cmd:clear} specifies that any existing data set in the memory is to be removed before the
generated text variables are created.
If {cmd:clear} is absent, then {cmd:intext} attempts to
add the generated variables to the existing data set, failing if there is an existing variable
with the same name as one of the generated variables.
({cmd:tfconcat} always removes any
existing data set before generating new variables.)


{title:Options for {cmd:tfconcat} only}

{p 4 8 2}
{cmd:tfid(}{it:{help newvarname}}{cmd:)} specifies a new integer variable to be created,
containing, for each observation in the new data set, the sequential order, in the
{it:filename_list}, of the input text file of origin of the observation.
If possible,
{cmd:tfconcat} creates a {help label:value label} for the {it:{help newvarname}} with the same name,
assigning, to each positive integer {hi:i} from 1 to the number of input file names
in the list, a {help label} equal to the filename of the {hi:i}th input text file,
truncated if necessary to the maximum length of a {help label} in the version of Stata being used,
which is 80 characters in Stata Version 9..
If a {help label:value label} of that name already exists in one of the input data sets, and
{cmd:nolabel} is not specified, then {cmd:tfconcat} adds new labels,
but does not replace existing labels.

{p 4 8 2}
{cmd:tfname(}{it:{help newvarname}}{cmd:)} specifies a new string variable containing,
for each observation in the new data set, the name of the input text file of origin
of that observation, 
ttruncated if necessary to the maximum length of a string variable in the version of Stata being used.
This  maximum value is stored in the {help creturn: c-class value} {cmd:c(maxstrvarlen)}.
(See also help for {help limits}.)

{p 4 8 2}
{cmd:obsseq(}{it:{help newvarname}}{cmd:)} specifies a new integer variable containing,
for each observation in the new data set, the sequential order of that observation
as a text record in its input text data set of origin.


{title:Remarks}

{pstd}
{cmd:intext} is an inverse of {helpb outfile} with the {cmd:runtogether} option.
That is to say, if the user inputs a text file into a list of generated string variables
using {cmd:intext} and then outputs them to a second text file using {helpb outfile}
with the {cmd:runtogether} option, then the second text file will be identical
to the first text file.
{cmd:tfconcat}
works by calling {cmd:intext} multiple times to create a data set for each text file,
and concatenating these data sets into the memory.
Both programs make it possible to use
Stata for text file processing, especially when the text files may be indented Stata programs.
This cannot be done properly using {helpb infix}, which uses fixed-field input, but trims leading and trailing blanks from strings.
Therefore, the {cmd:intext} package enables Stata programs to read Stata programs,
just as {helpb outfile} with the {cmd:runtogether} option enables Stata programs to write
Stata programs.


{title:Examples}

{p 8 16}{cmd:. intext using intext.ado, gene(sect) clear}{p_end}

{p 8 16}{cmd:. tfconcat auto1.txt auto2.txt auto3.txt auto4.txt, gene(piece) tfid(tfseq) obs(recnum)}{p_end}
{p 8 16}{cmd:. sort tfseq recnum}{p_end}

{pstd}
The following example is equivalent to {cmd:copy tfconcat.ado trash1.txt,text replace}

{p 8 16}{cmd:. intext using tfconcat.ado, gene(slice) clear}{p_end}
{p 8 16}{cmd:. outfile slice* using trash1.txt, runtogether replace}{p_end}

{pstd}
The following advanced example works under Windows, and might be used if the user has
a library of Stata ado-files in the current directory.
It inputs the ado-files into the memory
and lists the lines beginning with {hi:"*!"}, which are echoed by the {helpb which} command.

{p 8 16}{cmd:. tempfile dirf}{p_end}
{p 8 16}{cmd:. shell dir/b *.ado > `dirf'}{p_end}
{p 8 16}{cmd:. intext using `dirf', gene(fn) length(244) clear}{p_end}
{p 8 16}{cmd:. levelsof fn1}{p_end}
{p 8 16}{cmd:. tfconcat `r(levels)', gene(line) tfid(adofile) obs(lseq)}{p_end}
{p 8 16}{cmd:. list adofile line* if substr(line1,1,2)=="*!"}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 0 10}
{bind: }Manual:  {hi:[D] infix}, {hi:[D] append}, {hi:[D] outfile}, {hi:[P] file}
{p_end}
{p 0 10}
On-line:  help for {help infiling}, {helpb infix}, {helpb append}, {helpb outfile}, {helpb file}
{p_end}
