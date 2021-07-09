{smcl}
{* *! version 1.0  2011-12-22}{...}
{cmd:help rmfiles} (vs1.0: 2011-12-22)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:rmfiles} {hline 2} Removing matched files and possibly, if applicable, corresponding empty directories.
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt rmfiles} [{cmd:,} {opt folder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt rmdirs} {opt oldstx}]



{title:Description}

{pstd}
{cmd:rmfiles} 
is a program that helps to remove files in a quite generally applicable fashion - 
through matched filenames in a stated directory, and also - if selected -
in all matched subdirectories.  If selected, and applicable, any empty matched 
directories will also be removed. The simplest syntax is purely based on defaults. 
All options are optional. 


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
{opt rmdirs} An indicator for whether, or not, any matched empty directories (i.e. {bf:folder} or corresponding subdirectories by {bf:match})
should be removed as well. 

{pstd}
{opt oldstx} An indicator for whether, or not, Stata 9 syntax (as compared to Stata 11 syntax) should be assumed
with respect to extended macro functions. If stated, matching will not be case-sensitive and hence all matching 
strings {it:string} should be entered in lower case.


{title:Examples}

    {hline}

{pstd} 1. Remove all files in current working directory. {p_end}
{phang2}{cmd:. rmfiles}{p_end}

    {hline}

{pstd} 2. Remove all files with prefix {it:name} located in cwd-subdirectory {it:data}. {p_end}
{phang2}{cmd:. rmfiles , folder(".\data") match("name*")}{p_end}

    {hline}

{pstd} 3. Same as Example 2, but in this case the corresponding folder - if empty - is also deleted  {p_end}
{phang2}{cmd:. rmfiles , folder(".\data") match("name*") rmdirs}{p_end}

    {hline}

{pstd} 4. Same as Example 3, but in this case actions are also performed with respect to all subfolders 
(recursively, see note above) starting with string {it:2011}.{p_end}
{phang2}{cmd:. rmfiles , folder(".\data") match("name*") subs("2011*") rmdirs}{p_end}

    {hline}

{pstd} 5. Same as Example 4, but in this case using the old syntax, leading to case-insensitive matching. 
For example, all files starting with strings {it: NAME} or {it: Name} will also be matched in this case. 
Use lower case, see note above.{p_end}
{phang2}{cmd:. rmfiles , folder(".\data") match("name*") subs("2011*") rmdirs oldstx}{p_end}

    {hline}


{title:Requires}

{pstd} Stata 9; newer versions needed when option {bf: oldstx} is not used.



{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se



{title:Acknowledgements}

{pstd} Testing assistance by Birgit Marie Nielsen (Thanks Birgit! /  LÄ)


{title:Related commands (downloadable on SSC)}

{pstd} {help mvfiles} - moving set of matched files{break}
       {help renfiles} - renaming set of matched files{break}
       {help use10save9} - save Stata 10/11 files as Stata 9 counterparts (also from within Stata 9){break}
       {help excelsave} - exporting set of matched files to Excel (.xls or .xlsx)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help extended_fcn}, {help dir}, {help erase}, {help rmdir}.
{p_end}
