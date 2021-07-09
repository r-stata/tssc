{smcl}
{* *! version 1.0  2012-12-07}{...}
{cmd:help excelsave} (vs1.0: 2012-12-07)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:excelsave} {hline 2} Exporting Stata datasets to Excel with respect to matching criterion within selected 
folder (and also possibly within separately matched subfolders).
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt excelsave} [if] [in] [{cmd:,} {opt vars}({it:string}) {opt folder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt xls} {opt *}]
					


{title:Description}

{pstd}
{cmd:excelsave} 
is a program that helps to export (sets of) Stata datasets in a quite generally applicable fashion - 
through matched datasetnames from a stated in-directory - and also, if selected, from all separately matched subdirectories. 
If selected, only a selected list of variables will be exported and, similarly, specific if- and -in-conditions could also be used.
The simplest syntax is purely based on defaults. All options are optional. 

{pstd}
Note that this serves as a full wrapper for -export excel- and hence all options available with that command may also be used 
- and will then be passed on - here as well.


{title:Options}

{pstd}
{opt vars}({it:string}) List of variables to be exported from each file. The default set is all variables ('*').

{pstd}
{opt folder}({it:string}) Defines the directory from within where to look for files. 
The default directory is the current working directory (cwd; '.').

{pstd}
{opt match}({it:string}) Defines the matching criterion used in order to select files 
from the selected directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories. 
The default is all files in the directory/directories ('*').

{pstd}
{opt subs}({it:string}) Defines whether, or not, matched files (by {bf:match}) in corresponding 
separately matched subdirectories (recursively; based on here defined matching criterion) also should 
be affected. (Matching must be present at all levels.)

{pstd} 
{opt xls} Defines that the output Excel-format should be .xls; the default format is .xlsx

{pstd}
{opt *} List of all stated (valid) options to -export excel- that will be passed on to the (internal) call to that command.


{title:Examples}

    {hline}

{pstd} 1. Export all files in current working directory. {p_end}
{phang2}{cmd:. excelsave}{p_end}

    {hline}

{pstd} 2. Export all files with prefix {it:name} located in cwd-subdirectory {it:data}. {p_end}
{phang2}{cmd:. excelsave , folder(".\data") match("name*")}{p_end}

    {hline}

{pstd} 3. Export all files with prefix {it:name} located in cwd-subdirectory {it:data} - and also from
within any available subdirectories. {p_end}
{phang2}{cmd:. excelsave , folder(".\data") match("name*") subs("*")}{p_end}

    {hline}

{pstd} 4. Export all files located in cwd-subdirectory {it:data} - and also from any subdirectories with prefix {it:2011}.
Restrict the exporting to variables prefixed by {it:cid1*}. {p_end}
{phang2}{cmd:. excelsave , vars("cid1*") folder(".\data") match("*") subs("2011*")}{p_end}

    {hline}

{pstd} 5. Same as Example 4, but with matching based on prefix {it:name} and output format set to .xls. Moreover, the actual exporting
layout will also be affected by passed on -export excel- options {it:firstrow(var)} and {it:replace}. {p_end}
{phang2}{cmd:. excelsave , vars("cid1*") folder(".\data") match("name*") subs("2011*") xls firstrow(var) replace}{p_end}

    {hline}


{title:Requires}

{pstd} Stata 12.
Moreover, the command depends on the Stata 12 command {cmd: export excel}.


{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se


{title:Related commands (downloadable on SSC)}

{pstd} {help renfiles} - renaming set of matched files{break}
       {help rmfiles} - removing set of matched files{break}
       {help mvfiles} - moving set of matched files{break}
       {help use10save9} - save Stata 10/11 files as Stata 9 counterparts (also from within Stata 9)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help export excel}, {help extended_fcn}, {help dir}, {help copy}, {help erase}, {help mkdir}.
{p_end}
