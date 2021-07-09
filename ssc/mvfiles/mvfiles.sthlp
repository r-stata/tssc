{smcl}
{* *! version 1.0  2012-01-04}{...}
{cmd:help mvfiles} (vs1.0: 2012-01-04)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:mvfiles} {hline 2} Moving matched files into defined directory. 
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt mvfiles} [{cmd:,} {opt infolder}({it:string}) {opt outfolder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt makedirs} {opt erase} {opt oldstx}]



{title:Description}

{pstd}
{cmd:mvfiles} 
is a program that helps to move, or copy, (sets of) files in a quite generally applicable fashion - 
through matched filenames from a stated in-directory - and also, if selected, from all matched subdirectories -
into a defined out-directory. If selected, any non-existing out-directory will automatically be created before move. 
If selected, corresponding files will be removed from old location. The simplest syntax is purely based on defaults. 
All options are optional. 


{title:Options}

{pstd}
{opt infolder}({it:string}) Defines the directory from within where to look for files. 
The default directory is the current working directory (cwd; '.').

{pstd}
{opt outfolder}({it:string}) Defines the directory where to move matched files. 
The default directory is the current working directory (cwd; '.'), but if 
{bf:infolder}={bf:outfolder} then the files will be put into the common - created if needed -
subdirectiry {it:mvfiles}. If option {bf:makedirs} is selected, the outfolder-directory 
will generally be created if not already existing.

{pstd}
{opt match}({it:string}) Defines the matching criterion used in order to select files 
from the selected directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories. 
The default is all files in the directory/directories ('*').

{pstd}
{opt subs}({it:string}) Defines whether, or not, matched files (by {bf:match}) in corresponding matched 
subdirectories (recursively; based on here defined matching criterion) also should be affected. 
(Matching must be present at all levels.)

{pstd}
{opt makedirs} An indicator for whether, or not, {bf:outfolder} should be created if not already existing.

{pstd}
{opt erase} An indicator for whether, or not, any original matched files should be removed as well
(conditioned on successful move, i.e. that {bf:outfolder} existed or was created). 

{pstd}
{opt oldstx} An indicator for whether, or not, Stata 9 syntax (as compared to Stata 11 syntax) should be assumed
with respect to extended macro functions. If stated, matching will not be case-sensitive and hence all matching 
strings {it:string} should be entered in lower case.


{title:Examples}

    {hline}

{pstd} 1. Copy all files in current working directory to subdirectory {it:mvfiles} (which is created if nonexisting). {p_end}
{phang2}{cmd:. mvfiles}{p_end}

    {hline}

{pstd} 2. Move all files with prefix {it:name} located in cwd-subdirectory {it:data} to subdirectory {it:mvdirs} 
(which is created if nonexisting), original files are erased. {p_end}
{phang2}{cmd:. mvfiles , infolder(".\data") outfolder(".\data") match("name*") erase}{p_end}

    {hline}

{pstd} 3. Copy all files with prefix {it:name} located in cwd-subdirectory {it:data} to user-defined subdirectory 
{it:yes} (which is created if nonexisting).  {p_end}
{phang2}{cmd:. mvfiles , infolder(".\data") outfolder(".\data\yes") match("name*") makedirs}{p_end}

    {hline}

{pstd} 4. Move all files located in cwd-subdirectory {it:data} - and in subdirectories with prefix {it:2011} - to 
user-defined subdirectory {it:yes} (if existing).{p_end}
{phang2}{cmd:. mvfiles , infolder(".\data") outfolder(".\data\yes") match("*") subs("2011*") erase}{p_end}

    {hline}

{pstd} 5. Same as Example 4, but with matching based on prefix {it:name}, and in this case also using the old syntax, 
leading to case-insensitive matching. For example, all files starting with strings {it: NAME} or {it: Name} will also 
be matched in this case. Use lower case, see note above.{p_end}
{phang2}{cmd:. mvfiles , infolder(".\data") outfolder(".\data\yes") match("name*") subs("2011*") erase oldstx}{p_end}

    {hline}


{title:Requires}

{pstd} Stata 9; newer versions needed when option {bf: oldstx} is not used.



{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se


{title:Related commands (downloadable on SSC)}

{pstd} {help renfiles} - renaming set of matched files{break}
       {help rmfiles} - removing set of matched files{break}
       {help use10save9} - save Stata 10/11 files as Stata 9 counterparts (also from within Stata 9) {break}
       {help excelsave} - exporting set of matched files to Excel (.xls or .xlsx)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help extended_fcn}, {help dir}, {help copy}, {help erase}, {help mkdir}.
{p_end}
