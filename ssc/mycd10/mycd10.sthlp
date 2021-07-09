{smcl}
{* *! version 1.1  13jan2015}{...}
{title:Title}

{pstd}{cmd: mycd10} {hline 2}  ICD-10 diagnostic and procedure codes{p_end}



{marker syntax}{...}
{title:Syntax}

{phang}
Prepare WHO ICD-10 diagnosis code data for use with {opt mycd10}

{p 8 16 2}
{cmd:mycd10} {opt p:repare} using {it:WHOfile}

{p 8 16 2}
{cmd:mycd10} {opt p:repare} {opt co:des} using {it:WHOfile}

{p 8 16 2}
{cmd:mycd10} {opt p:repare} {opt ch:apters} using {it:WHOfile}

{p 8 16 2}
{cmd:mycd10} {opt p:repare} {opt b:locks} using {it:WHOfile}


{phang}
Verify that variable contains defined codes

{p 8 16 2}
{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}
{cmd:check} {varname}
[{cmd:,}
{opt any}
{opt l:ist}
{opth g:enerate(newvar)}]


{phang}
Verify and clean variable

{p 8 16 2}
{cmd:mycd10}
{opt clean} {varname}
[{cmd:,}
{opt d:ots}
{opt p:ad}]

{p 8 16 2}
{cmd:mycd10p}
{opt clean} {varname}
[{cmd:,}
{opt p:ad}]


{phang}
Generate new variable from existing variable

{p2colset 8 26 28 2}{...}
{p2col :{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}}{opt gen:erate} {newvar} {cmd:=} {varname}{cmd:, }{opt m:ain}{p_end}

{p2col :{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}}{opt gen:erate} {newvar} {cmd:=} {varname}{cmd:, }{opt d:escription}[{opt l:ong} {opt e:nd}]{p_end}

{p2col :{cmd:mycd10}}{opt gen:erate} {newvar} {cmd:=} {varname}{cmd:, }{opt c:hapter}[{opt l:ong} {opt e:nd}]{p_end}

{p2col :{cmd:mycd10}}{opt         gen:erate} {newvar} {cmd:=} {varname}{cmd:, }{opt b:lock}[{opt l:ong} {opt e:nd}]{p_end}

{p2col :{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}}{opt gen:erate} {newvar} {cmd:=} {varname}{cmd:, }{opt r:ange(icd10rangelist)}{p_end}
{p2colreset}{...}


{phang}
Display code descriptions

{p2colset 8 26 28 2}{...}
{p2col :{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}}{opt l:ookup} {it:icd10rangelist}{p_end}

{p2col :{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}}{opt l:ookup} {opt co:des} {it:icd10rangelist}{p_end}

{p2col :{cmd:mycd10}}{opt l:ookup} {opt ch:apters} {it:icd10chapterlist}{p_end}

{p2col :{cmd:mycd10}}{opt l:ookup} {opt b:locks} {it:icd10blockrangelist}{p_end}
{p2colreset}{...}


{phang}
Search for codes from descriptions

{p 8 16 2}
{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}
{opt sea:rch}
[{cmd:"}]{it:text}[{cmd:"}]
[[{cmd:"}]{it:text}[{cmd:"}] {it:...}]
[{cmd:,}
{opt or}]


{phang}
Display ICD-10 code source

{p 8 16 2}
{c -(}{cmd:mycd10}|{cmd:mycd10p}{c )-}
{opt q:uery}


{pstd}
where {it:icd10rangelist} is

{p2colset 9 30 32 2}{...}
{p2col :{it:icd10code}}(the particular code){p_end}
{p2col :{it:icd10code}{cmd:*}}(all codes starting with {it:icd10code}){p_end}
{p2col :{it:icd10code}{cmd:/}{it:icd10code}}(the code range){p_end}
{p2colreset}{...}

{pstd}
or any combination of the above, such as {cmd: A01* C18/C19 Q* N28.9}.

{pstd}
where {it:icd10chapterlist} is any valid Stata {help numlist}

{pstd}
where {it:icd10blockrangelist} is

{p2colset 9 32 34 2}{...}
{p2col :{it:icd10block}}(the particular block){p_end}
{p2col :{it:icd10block}{cmd:*}}(all blocks starting with {it:icd10block}){p_end}
{p2col :{it:icd10block}{cmd:/}{it:icd10block}}(the block range){p_end}
{p2colreset}{...}

{pstd}
or any combination of the above, such as {cmd: A* B60/B99 C02}.


{p 4 6 2}
{opt mycd10} is for use with ICD-10 diagnostic codes, and {opt mycd10p} for use with
procedure codes.  The two commands' syntaxes parallel each other. {opt myicd10} and 
{opt myicd10p} are acceptable synonyms for {opt mycd10} and {opt mycd10p}, respectively.

{marker description}{...}
{title:Description}

{pstd}
{opt mycd10} and {opt mycd10p} help when working with ICD-10 codes.

{pstd}
ICD-10 diagnostic codes are maintained by the World Health Organization. The system 
was developed in 1990 and released in 1994.  It has been in use in several countries since
the late 1990s.  Because of licensing restrictions the ICD-10 lookup data set cannot 
be included with {opt mycd10}.  See the discussion of {cmd: mycd10 prepare} below for more details.

{pstd}
The ICD-10 Procedure Coding System (ICD-10-PCS) was developed by the Centers for
Medicare and Medicaid Services (CMS) and 3M Health Information Systems in 1993.
It was released in 1998 as an eventual replacement for the ICD-9-CM procedure code system and
it is updated annually.  

{pstd}
ICD-10 codes come in two forms:  diagnostic codes and procedure codes.  In this
system, A00 (cholera) and S01.2 (Open wound of nose) are examples of
diagnostic codes, although some people write (and datasets record) S012
rather than S01.2.  Also, 005 (Central Nervous System, Destruction) and 00500ZZ 
(Destruction of Brain, Open Approach) are are examples of procedure codes.  
{opt mycd10} understand both ways of recording codes.  Periods are not allowed
in ICD-10 procedure codes.  {opt mycd10} does not (yet) support optional code qualifiers.

{pstd}
{* this note really is important, because it needs to be seen by skimmers.}
Important note: What constitutes a valid ICD-10 code changes over time.
For the rest of this help file, a {it:defined code} is any code
that is either currently valid, was valid at some point since the 2008 version, 
or has meaning as a grouping of codes.  For example, the diagnosis code A00, though not valid on its
own, is useful because it denotes cholera.  It is kept as a defined code
whose description ends with an asterisk (*).  Unlike Stata's {opt icd9}[{opt p}] 
command, there is no capability (yet) in {opt mycd10}[{opt p}] to determine whether
 and when certain codes have been added, changed, or removed.

{pstd}
{opt mycd10} and {opt mycd10p} parallel each other; {opt mycd10} is
for use with diagnostic codes, and {opt mycd10p} for use with procedure codes.

{pstd}
{opt mycd10}
{opt prepare}
reads an ICD-10 lookup dataset downloaded from WHO and creates a Stata version called
mycd10_cod.dta which contains the variables required for use with mycd10.  
Go to {browse "http://www.who.int/about/licensing/classifications/en/"},
click on "Register for non-commercial use" at the bottom of the page, and
follow the instructions.  You will have to create a user account, complete
a form regarding how you will use the ICD-10 data, and agree to the non-commercial
research license.  Once that process is complete, download the ICD-10 2nd Edition in
plain text tabular form, then run {opt mycd10 prepare}, providing the file name of the
downloaded file (probably codes.txt).  This command also creates a data set called mycd10_raw.dta, which contains 
all of the variables contained in the file from WHO.  Both data sets are stored
in the same directory as the mycd10 program.

{pstd}
{opt mycd10}
{opt prepare codes}
is the same as 
{opt mycd10}
{opt prepare}

{pstd}
{opt mycd10}
{opt prepare chapters}
reads the ICD-10 lookup dataset that contains the list of chapters and chapter descriptions.  This file is normally included in the 
download from WHO and will probably be named chapters.txt.  This command must be run before using {opt mycd10 generate, chapter} or
{opt mycd10 lookup chapter}. Note that chapters and chapter descriptions are only relevant for ICD-10 diagnosis codes, not
ICD-10 procedure codes.

{pstd}
{opt mycd10}
{opt prepare blocks}
reads the ICD-10 lookup dataset that contains the list of block groups and block group descriptions.  This file is normally included in the 
download from WHO and will probably be named blocks.txt.  This command must be run before using {opt mycd10 generate, block} or
{opt mycd10 lookup block}. Note that blocks and block group descriptions are only relevant for ICD-10 diagnosis codes, not
ICD-10 procedure codes.

{pstd}
{opt mycd10}[{opt p}]
{opt check} verifies that existing variable {varname} contains defined
ICD-10 codes.  If not, {opt mycd10}[{opt p}] {opt check} provides a full
report on the problems.
{opt mycd10}[{opt p}] {opt check} is useful for tracking down problems when any
of the other {opt mycd10}[{opt p}] commands tell you that the 
"variable does not contain
ICD-10 codes".  {opt mycd10}[{opt p}] {opt check} 
verifies that each recorded code actually exists in the defined
code list.

{pstd}
{opt mycd10}[{opt p}]
{opt clean} also verifies that existing variable {it:varname} contains
defined ICD-10 codes and, if it does, {opt mycd10}[{opt p}] {opt clean} modifies
the variable to contain the codes in either of two standard formats.
All {opt mycd10}[{opt p}] commands
work equally well with cleaned or uncleaned codes.  There are several ways of
writing the same ICD-10 code, and {opt mycd10}[{opt p}] {opt clean} is designed
to ensure consistency and to make subsequent output look better.

{pstd}
{opt mycd10}[{opt p}]
{opt generate}
produces new variables based on existing variables containing
(cleaned or uncleaned) ICD-10 codes.
{opt mycd10}[{opt p}] {opt generate,} {opt main}
produces {newvar} containing the main code (the first three characters, also known as the block).
{opt mycd10}[{opt p}] {opt generate,} {opt description}
produces {it:newvar} containing a textual description of the ICD-10 code, {opt mycd10} {opt generate,} {opt chapter}
produces {it:newvar} containing a textual description of the the chapter corresponding
to the ICD-10 diagnosis code, and {opt mycd10} {opt generate,} {opt block}
produces {it:newvar} containing a textual description of the the block group corresponding to the ICD-10 diagnosis code.
{opt mycd10}[{opt p}] {opt generate,} {opt range()}
produces numeric {it:newvar} containing 1 if {it:varname} records an ICD-10
code in the range listed and 0 otherwise.

{pstd}
{opt mycd10}[{opt p}]
{opt lookup}
and {opt mycd10}[{opt p}] {opt search}
are utility routines that are useful interactively.
{opt mycd10}[{opt p}] {opt lookup} simply displays descriptions of the codes
specified on the command line, so to find out what
diagnosis code Q30.1 means, you can type {cmd:mycd10 lookup q30.1}.  The
data that you have in memory are irrelevant -- and remain
unchanged -- when you use
{opt mycd10}[{opt p}] {opt lookup}.

{pstd}
{opt mycd10}[{opt p}] {opt lookup codes} is the same as 
{opt mycd10}[{opt p}] {opt lookup}.

{pstd}
{opt mycd10} {opt lookup chapters} displays descriptions of the chapters
specified on the command line. Since chapters are integers, any valid Stata {help numlist}
can be specified.  For example, to find out what chapters 19 and 20 are, type {cmd:mycd10 lookup chapters 19/20}.

{pstd}
{opt mycd10} {opt lookup blocks} displays descriptions of the blocks
specified on the command line.  For example, to find out what block group block Q30 is in, type {cmd:mycd10 lookup block Q30}.
Note that since block groups are themselves ranges of blocks, if you specify a range of blocks to look up,
all block groups that overlap the specified range will be returned. For example, {cmd:mycd10 lookup blocks B60/B70}
will return the descriptions for block groups B50-B64 and B65-B83.

{pstd}
{opt mycd10}[{opt p}] {opt search} is similar to
{opt mycd10}[{opt p}] {opt lookup} (and {opt lookup codes}), except that it turns the problem around;
{opt mycd10}[{opt p}] {opt search} looks for relevant ICD-10 codes from the
description given on the command line.  For instance, you could type
{cmd:mycd10 search liver} or {cmd:mycd10p search liver} to obtain a list of
codes containing the word "liver".

{pstd}
{opt mycd10}[{opt p}]
{opt query}
displays the identity of the source from which the ICD-10 codes
were obtained and the textual description that {opt mycd10}[{opt p}] uses.

{pstd}
ICD-10 diagnosis codes are commonly written two ways: with and without periods.
For instance, you can write A00 and J348, or you can write A00. and J34.8.  
With procedure codes, however, you can write 005 and 00500ZZ, but you cannot use periods.  
The {opt mycd10} command does not care which syntax you use or even whether
you are consistent. {opt mycd10p} does not allow the use of periods.
Case is irrelevant in {opt mycd10}[{opt p}]:  q309, q30.9, Q309, and Q30.9
are all equivalent in {opt mycd10} and 00500zz and 00500ZZ are equivalent in 
{opt mycd10p}.  Codes may be recorded with or without leading and
trailing blanks.

{marker options_icd10_check}{...}
{title:Options for mycd10[p] check}

{phang}
{opt any} tells {opt mycd10}[{opt p}] {opt check} to verify that the codes
fit the format of ICD-10 codes but not to check whether the codes are
actually defined.  This makes {opt mycd10}[{opt p}] {opt check} run faster.  For
instance, diagnostic code D33.5 (or D335, if you prefer) looks valid,
but there is no such ICD-10 code.  Without the {opt any} option, D33.5
would be flagged as an error.  With {opt any}, D33.5
is not an error.

{phang}
{opt list} reports any invalid codes that were found in the data 
by {opt mycd10}[{opt p}] {opt check}.
For example, A1, A1.1.1, and perhaps D33.5, if {opt any} is not
specified, are to be individually listed.

{phang}
{opth generate(newvar)} specifies that {opt mycd10}[{opt p}]
{opt check} create new variable {it:newvar} containing, for each
observation, 0 if the code is defined and a number from 1 to 11 otherwise.  The
positive numbers indicate the kind of problem and correspond to the listing
produced by {opt mycd10}[{opt p}] {opt check}.  For instance, in {opt mycd10} 9 means that the
code could be valid, but it turns out not to be on the list of defined codes.


{marker options_icd10_clean}{...}
{title:Options for mycd10[p] clean}

{phang}
{opt dots} specifies whether periods are to be included in the final format.
Do you want the diagnostic codes recorded, for instance, as G958 or G95.8?
Without the {cmd:dots} option, the G958 format would be used.
With the {opt dots} option, the G95.8 format would be used.  This option is not valid
in {opt mycd10p}

{phang}
{opt pad} specifies that the codes are to be padded with spaces, front
and back, to make the codes line up vertically in listings.  Specifying
{opt pad} makes the resulting codes look better when used with most other
Stata commands.


{marker options_icd10_gen}{...}
{title:Options for mycd10[p] generate}

{phang}
{opt main}, {opt description}, {opt chapter}, {opt block}, and {opt range(icd10rangelist)}
specify what {opt mycd10}[{opt p}] {opt generate} is to calculate. {opt chapter} and {opt block}
are not valid with {opt mycd10p}. {varname} always specifies a variable containing ICD-10 codes.

{phang2}
{opt main} specifies that the main code be extracted from the
ICD-10 code.  For procedure codes, the main code is the first three characters (although
this is not an official designation in the ICD-10 procedure code system).
For diagnostic codes, the main code is usually the first three characters 
(the characters before the dot if the code has dots).  In any case,
{opt mycd10}[{opt p}] {opt generate} does not care whether the code is padded
with blanks in front or how strangely it might be written; {opt mycd10}[{opt p}]
{opt generate} will find the main code and extract it.  The resulting variable
is itself an ICD-10 code and may be used with the other {opt mycd10}[{opt p}]
subcommands.  This includes {opt mycd10}[{opt p}] {opt generate, main}.

{phang2}
{opt description} creates {newvar} containing descriptions of the
ICD-10 codes.

{phang2}
{opt chapter} creates {newvar} containing descriptions of the
chapters corresponding to each ICD-10 diagnosis code. (Requires Stata 10 or above)

{phang2}
{opt block} creates {newvar} containing descriptions of the
block groups corresponding to each ICD-10 diagnosis code. (Requires Stata 10 or above)

{phang2}
{opt long} is for use with {opt description}, {opt chapter}, and {opt block}.  It specifies that the new
variable, in addition to containing the text describing the code, chapter, or block,
also contain the code, chapter number, or block group, too.  Without {opt long}, {it:newvar} in an observation
might contain "Injury of bronchus", "Injury, poisoning and certain other consequences of external causes",
or "Injuries to the thorax".  With {opt long}, it would contain
"S27.4 Injury of bronchus", "19) Injury, poisoning and certain other consequences of external causes",
or "S20-S29) Injuries to the thorax".

{phang2}
{opt end} modifies {opt long} (specifying {opt end} implies {opt long})
and places the code at the end of the string:  "Injury of bronchus S27.4", or 
"Injury, poisoning and certain other consequences of external causes (19)", 
or "Injuries to the thorax (S20-S29)".

{phang2}
{opt range(icd10rangelist)} allows you to create indicator variables
equal to 1 when the ICD-10 code is in the inclusive range specified.


{marker options_icd10_search}{...}
{title:Option for mycd10[p] search}

{phang}
{opt or} specifies that ICD-10 codes be searched for entries
that contain any word specified after {opt mycd10}[{opt p}]
{opt search}.  The default is to list only entries that contain all the words
specified.


{marker examples}{...}
{title:Examples}

{pstd}Prepare data set for use with mycd10{p_end}
{phang2}{cmd:. mycd10 prepare using C:\Downloads\codes.txt}{p_end}

{pstd}Display a description of code C15.9{p_end}
{phang2}{cmd:. mycd10 lookup C15.9}{p_end}

{pstd}Look up a range of codes{p_end}
{phang2}{cmd:. mycd10 lookup C15/C16}{p_end}

{pstd}Display a description of chapter 19{p_end}
{phang2}{cmd:. mycd10 lookup chapter 19}{p_end}

{pstd}Look up a range of chapters{p_end}
{phang2}{cmd:. mycd10 lookup chapter 19/20}{p_end}

{pstd}Display a description of the block group containing C15{p_end}
{phang2}{cmd:. mycd10 lookup block C15}{p_end}

{pstd}Look up a range of blocks{p_end}
{phang2}{cmd:. mycd10 lookup block B50/B70}{p_end}

{pstd}Search for codes containing the words jaw and disease{p_end}
{phang2}{cmd:. mycd10 search jaw disease}{p_end}

{pstd}Attempt to clean {cmd:diag1} diagnostic code variable{p_end}
{phang2}{cmd:. mycd10 clean diag1}{p_end}

{pstd}Flag observations containing invalid codes{p_end}
{phang2}{cmd:. mycd10 check diag1, gen(prob)}{p_end}

{pstd}List flagged observations{p_end}
{phang2}{cmd:. list patid diag1 if prob}{p_end}

{pstd}Clean {cmd:diag2} diagnostic code variable{p_end}
{phang2}{cmd:. mycd10 clean diag2}{p_end}

{pstd}Add periods to {cmd:diag2} variable{p_end}
{phang2}{cmd:. mycd10 clean diag2, dots}{p_end}

{pstd}Clean {cmd:proc1} procedure code variable and add spaces for padding{p_end}
{phang2}{cmd:. mycd10p clean proc1, pad}{p_end}

{pstd}Check that {cmd:proc1} contains valid procedure codes{p_end}
{phang2}{cmd:. mycd10p check proc1}{p_end}

{pstd}Create variable {cmd:tp1} containing descriptions of codes in {cmd:proc1}
{p_end}
{phang2}{cmd:. mycd10p generate tp1 = proc1, description}{p_end}

{pstd}Create variable {cmd:chp1} containing descriptions of chapters corresponding to codes in {cmd:dx1}
{p_end}
{phang2}{cmd:. mycd10 generate chp1 = dx1, chapter}{p_end}

{pstd}Create variable {cmd:blk1} containing descriptions of block groups corresponding to codes in {cmd:dx1}
{p_end}
{phang2}{cmd:. mycd10 generate blk1 = dx1, block}{p_end}

{pstd}Create variable {cmd:main1} containing main codes{p_end}
{phang2}{cmd:. mycd10 generate main1 = diag2, main}{p_end}


{marker saved_results}{...}
{title:Saved results}

{pstd}
{cmd:mycd10} and {cmd:mycd10p} save the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(e}{it:#}{cmd:)}}number of errors of type {it:#}{p_end}
{synopt:{cmd:r(esum)}}total number of errors {p_end}
{p2colreset}{...}

{title:Acknowledgements}

The code and help for {cmd:mycd10} is borrowed almost entirely from the Stata {help icd9} 
command and it is expected that this program will be retired as soon as StataCorp
is able to produce their own version. Thanks also to Statalist members Sara Glick, 
Tom Weichle, and Matthew Barclay, who (unwittingly) encouraged this effort.  Thanks to
Joanna Davies who inspired the addition of the functionality for chapter and block 
group descriptions. Finally, thanks in advance to the Stata user community for 
providing feedback.  This program will no doubt benefit from extensive use with 
real-life data sets.

{title:Author}

{pstd}
Joseph Canner{break}
Johns Hopkins University School of Medicine{break}
Department of Surgery{break}
Center for Surgical Trials and Outcomes Research{break}

{pstd}
Email {browse mailto:jcanner1@jhmi.edu}

