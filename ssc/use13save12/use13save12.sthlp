{smcl}
{* *! version 1.0  2013-09-25}{...}
{cmd:help use13save12} (vs1.0: 2013-09-25)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:use13save2} {hline 2} Loading sets of matched Stata 13-files into Stata 10-12 and saving them in older formats readable for the Stata 10-12 user. 
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt use13save12} [{cmd:,} {opt folder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt prefix}({it:string}) {opt suffix}({it:string})   {opt movenew}({it:string}) {opt moveold}({it:string}) saveold]



{title:Description}

{pstd}
{cmd:use13save12} 
is a program that helps out with opening Stata 13 files from within Stata 10-12 and then saving them in Stata 8-12 format 
- using {cmd: use13} (Radyakin, 2013), {cmd: save} and {cmd: saveold} - depending on the version run and the options used. 
The command may be applied to a quite generally defined set of Stata datasets within a defined folder and, if selected, 
also with respect to all matched corresponding subfolders of that main top-level folder. Original and/or new datasets may 
be put into specified - that will be created if neeeded, i.e. if they do not already exist - subfolders. 
All options are optional (but not all at the same time, see section {it: What option-combinations will not work?} below). 

{pstd}
An alternative, secondary, usage might be to use the function from within Stata 13 - even though the original files then 
are perfectly readable (hence {bf:use} are used for loading these cases)- in order to save (sets of) matched 
files in an older format readable by other users - as co-workers - that still run Stata 11-12. 


{title:Options}

{pstd}
{opt folder}({it:string}) Defines the main directory from within where to look (or start looking if {bf:subs} is not left 
empty) for files. The default directory is the current working directory (cwd; '.').

{pstd}
{opt match}({it:string}) Defines the matching criterion used in order to select files 
from the selected directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories. 
The default is all files in the directory/directories ('*').

{pstd}
{opt subs}({it:string}) Defines whether, or not, matched files (by {bf:match}) in corresponding matched 
subdirectories (recursively; based on the here defined matching {it:string} criterion) also should be affected. 
(Matching must be present at all directory-levels.)

{pstd}
{opt prefix}({it:string}) Defines a prefix string to put in front of all new files corresponding
to matched cases.

{pstd}
{opt suffix}({it:string}) Defines a suffix string to put at the end of all new files corresponding
to matched cases.
 
{pstd}
{opt movenew}({it:string}) States the subdirectory - compared to the location of the original (Stata 13) file, i.e. for files matched in a
first-level subdirectory this folder would be a subsubdirectory - 
where all new files (in older formats) should be put into. If left empty, the new files are saved into the original directory of the corresponding matched file
(and hence {bf: prefix} and/or {bf:suffix} must be stated if {bf:moveold} also is left unassigned, see below under 
{it:What option-combinations will not work?}). If stating {it:vs} then files will be put into subdirectory {it:stata11-12} (if using Stata 13 or as a 
default if using Stata 12), {it:stata10-11} (as a default if using Stata 11), {it:stata10} (as a default when running Stata 10), 
{it:stata8-10} (if {bf:saveold} is selected when running Stata 12), or {it:stata8-9} (if {bf:saveold} is selected when running Stata 10-11). 

{pstd}
{opt moveold}({it:string}) States the subdirectory - compared to the location of the original (Stata 13) file, i.e. for files matched in a
first-level subdirectory this folder would be a subsubdirectory - 
where matched original files (in Stata 13 format) should be moved into. If left empty, the old files are left where they were 
(and hence {bf: prefix} and/or {bf:suffix} must be stated if {bf:movenew} also is left unassigned, see below under 
{it:What option-combinations will not work?}). If stating {it:vs} then files will be put into subdirectory {it:stata13}.

{pstd}
{opt saveold} An indicator for whether, or not, the matched files should be saved in an older format using {cmd: saveold} instead of 
by using {cmd: save}. For information on which actually implied output dataset-versions this would imply, see the related information under {bf:movenew}.


{title: What option-combinations will not work?}

{pstd} (i) When using the command from within Stata 13, the option {bf:saveold} must be stated.{p_end}
{pstd} (ii) If saving, or moving, old and corresponding new files into the same directory
(either if {bf:moveold}={bf:movenew}!="vs" or when both are unassigned), prefixes and/or suffixes must be used. Related to this, it is not possible to replace original files with new ones
(i.e. to delete the original files). Originally, this was planned to be possible by using an option {bf:replace}, but then some obscure error of (temporary)
read only-permissions preventing saving of new files and hence leading to syntax errors was experienced/run into. On second thought, this might in fact also be an unwanted possibility, since it might 
perhaps be seen as good practise not to allow for deleting 'raw' files.{p_end}


{title:Examples}

    {hline}

{pstd} 1. Re-save all (Stata dataset) files in the current working directory in Stata 10-12 format (depending on used Stata version) and move original (Stata 13) files to (created if needed) 
subdirectory 'tmp'. {p_end}
{phang2}{cmd:. use13save12 , moveold("tmp")}{p_end}

    {hline}

{pstd} 2. Re-save all files located in the cwd-subdirectory {it:test2} in Stata 10-12 format (depending on used Stata version) in the very same directory, adding strings 'aa_'
as prefixes and '_bb' as suffixes.{p_end}
{phang2}{cmd:. use13save12 , folder("./test2") prefix("aa_") suffix("_bb")} {p_end}

    {hline}

{pstd} 3. Same as Example 1, but here the cwd-subdirectory {it:test3} is used and all subfolders are also searched through - in a hierarchical manner (recursive calls) - 
for matching files and - if needed - creation of 'tmp' directories as well.{p_end}
{phang2}{cmd:. use13save12 , folder("./test3") subs("*") moveold("tmp")}{p_end}

    {hline}

{pstd} 4. Combination of Examples 2-3, but applied to cwd-subdirectory {it:test4}. Moreover, here all original (Stata 13) files are moved to corresponding 
subdirectories {it:stata13} (through assigning 'vs' to {bf:moveold}).{p_end}
{phang2}{cmd:. use13save12 , folder("./test4") subs("*") prefix("aa_") suffix("_bb") moveold("vs")}{p_end}

    {hline}

{pstd} 5. Similar to Example 4, but here the main directory is the cwd-subdirectory {it:test5} and only files with original suffix {it:est} (goverened by option {bf:match("{it:est*}")}) 
are matched (and hence affected). Moreover, here the matched original files remain at their initial positions whereas the new files are put into corresponding 
subdirectories with name as described in connection with option {bf:movenew} above (through assigning 'vs' to {bf:movenew}).{p_end}
{phang2}{cmd:. use13save12 , folder("./test5") match("est*") subs("*") prefix("aa_") suffix("_bb") movenew("vs")}{p_end}

    {hline}

{pstd} 6. Similar to Example 5, but here the main directory is the cwd-subdirectory {it:test6} and all Stata files are matched while only subdirectories 
(and, as usual, subsubdirectories within subdirectories, etc.) having suffix {it:test} will be affected. Moreover, both original and new files will be put 
into corresponding subdirectories named according to the predefined naming structure (through assigning 'vs' to {bf:moveold} and {bf:movenew}, see above)
while the {bf:saveold} option defines both the output format and the {bf: movenew} subdirectory name (depending on used Stata version).{p_end}
{phang2}{cmd:. use13save12 , folder("./test6") subs("test*") prefix("aa_") suffix("_bb") moveold("vs") movenew("vs") saveold}{p_end}

    {hline}

{pstd} 7. Combination of Examples 5-6, but here the main directory is an absolute path {it:C:/dir1/dir2/dir3/test7}. Moreover, both new and old files are 
put/moved to the same corresponding subdirectories {it:tmp} (located with respect to the corresponding directory of the file at study).{p_end}
{phang2}{cmd:. use13save12 , folder("C:/dir1/dir2/dir3/test7") match("est*") subs("test*") prefix("aa_") suffix("_bb") moveold("tmp") movenew("tmp") saveold}{p_end}

    {hline}

{title:Requires}

{pstd} Stata 10. Moreover, the command depends on the user written function {cmd: use13} (Radyakin, 2013).


{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se

{title:Acknowledgements}

{pstd} Thanks to Matthew White for comments on the related command {bf:mvfiles} and whose suggestions have been implemented here. 


{title:Related commands (downloadable on SSC)}

{pstd} {help use10save9} - reading Stata 10/11 files and saving them in Stata 8/9 format.{break}
       {help mvfiles} - moving set of matched files{break}
       {help renfiles} - renaming set of matched files{break}
       {help rmfiles} - removing set of matched files{break}
       {help excelsave} - exporting set of matched files to Excel (.xls or .xlsx)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help use13} (user-written; SSC),  
{p_end}
{psee}
{space 24}                       {help use}, {help save}, {help saveold}, {help mkdir}, {help varlist}, {help extended_fcn}, {help string functions}, {help _caller()}.
{p_end}
