{smcl}
{* *! version 1.2  2011-12-22}{...}
{cmd:help use10save9} (vs1.1: 2011-10-25) (vs1.2: 2011-12-22)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:use10save9} {hline 2} Saving matched files in Stata 9 format - either as new files in automatically 
created directory or through replacing previous Stata 10/11 files. 
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt use10save9} [{cmd:,} {opt folder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt prefix}({it:string}) {opt suffix}({it:string}) {opt replace} {opt newstx}]



{title:Description}

{pstd}
{cmd:use10save9} 
is a program that helps out with opening Stata 10/11 files from within Stata 9 and then saving them in Stata 9 format 
(using {cmd: use10} and {cmd: save9}). May be applied to a quite generally defined set of Stata datasets within a 
defined folder and, if selected, also with respect to all matched corresponding subfolders. 
The simplest syntax is purely based on defaults. All options are optional. 

{pstd}
An alternative, secondary, usage might be to simply use the function as an extension to {cmd: save9} (Ercolani, 2011) 
in order to save matched sets of datasets in Stata 9 format while being in Stata 10/11/12. 


{title:Options}

{pstd}
{opt folder}({it:string}) Defines the directory from within where to look for files. 
The default directory is the current working directory (cwd; '.').

{pstd}
{opt match}({it:string}) Defines the matching criterion used in order to select files 
from the selected directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories. 
The default is all files in the directory/directories ('*').

{pstd}
{opt subs}({it:string}) Defines whether, or not, matched files (by {bf:match}) in corresponding matched 
subdirectories (recursively; based on here defined matching criterion) also should be affected. 
(Matching must be present at all levels.)

{pstd}
{opt prefix}({it:string}) Defines a prefix string to put in front of all new files corresponding
to matched cases.

{pstd}
{opt suffix}({it:string}) Defines a suffix string to put at the end of all new files corresponding
to matched cases.
 
{pstd}
{opt replace} An indicator for whether, or not, the matched files should be saved as new files in subdirectory 
'stata9'(which is then - if not existing - automatically created) or rather simply be saved (with 'replace') in
{bf:folder} or relevant subdirectory (potentially overwriting, if no prefix/suffix assigned, the old versions). 

{pstd}
{opt newstx} An indicator for whether, or not, Stata 11 syntax (as compared to Stata 9 syntax) should be assumed
with respect to extended macro functions. If not stated, matching will not be case-sensitive and hence all matching 
strings {it:string} (with respect to {bf:match} and {bf:subs}) should be entered in lower case.


{title:Examples}

    {hline}

{pstd} 1. Save all (Stata dataset) files in current working directory in Stata 9 format in subdirectory 'stata9'. {p_end}
{phang2}{cmd:. use10save9}{p_end}

    {hline}

{pstd} 2. Save all files with prefix {it:name} located in cwd-subdirectory {it:data} in Stata 9 format in subdirectory 'stata9'. {p_end}
{phang2}{cmd:. use10save9 , folder(".\data") match("name*")} {p_end}

    {hline}

{pstd} 3. Same as Example 2, but in this case all matched files in all subdirectories to folder {it:data} are also to be affected. {p_end}
{phang2}{cmd:. use10save9 , folder(".\data") match("name*") subs("*")}{p_end}

    {hline}

{pstd} 4. Same as Example 3, but in this case all matched files in folder {it:data} should simply be saved replacing (overwriting) the original ones. {p_end}
{phang2}{cmd:. use10save9 , folder(".\data") match("name*") subs("*") replace}{p_end}

    {hline}

{pstd} 5. Same as Example 4, but in this case all new files will have prefix 's9_' added to filenames (for instance, to avoid overwriting). {p_end}
{phang2}{cmd:. use10save9 , folder(".\data") match("name*") subs("*") prefix("s9_") replace}{p_end}

    {hline}

{pstd} 6. Similar to Example 5, but in this case using the new syntax, leading to case-sensitive matching. Hence, here one may use upper case matching-notation 
and only files and directories exactly with prefixes {it:Name} and {it:Subdir} will be matched respectively.{p_end}
{phang2}{cmd:. use10save9 , folder(".\data") match("Name*") subs("Subdir*") prefix("s9_") replace newstx}{p_end}

    {hline}


{title:Requires}

{pstd} Stata 9; newer versions needed when option {bf: newstx} is used. 
Moreover, the command depends on the user written functions {cmd: use10} (Radyakin, 2008) & {cmd: save9} (Ercolani, 2011).


{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se


{title:Acknowledgements}

{pstd} Testing assistance by Birgit Marie Nielsen (Thanks Birgit! /  LÄ)


{title:Related commands (downloadable on SSC)}

{pstd} {help mvfiles} - moving set of matched files{break}
       {help renfiles} - renaming set of matched files{break}
       {help rmfiles} - removing set of matched files{break}
       {help excelsave} - exporting set of matched files to Excel (.xls or .xlsx)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help use10} (user-written; SSC), {help save9} (user-written; SSC), 
{p_end}
{psee}
{space 24}                       {help save}, {help mkdir}, {help varlist}, {help extended_fcn}, {help string functions}.
{p_end}
