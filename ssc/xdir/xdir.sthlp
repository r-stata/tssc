{smcl}
{hline}
help for {cmd:xdir} and {cmd:xframedir} {right:(Roger Newson)}
{hline}


{title:Create a resultsset with 1 observation per file or per frame}

{p 8 15}{cmd:xdir} [ {cmd:,}
 {cmdab:dir:name}{cmd:(}{it:directory_name}{cmd:)} {cmdab:pa:ttern}{cmd:(}{it:file_pattern}{cmd:)} {cmdab:ft:ype}{cmd:(}{it:file_type}{cmd:)}
 {break}
 {cmdab::no}{cmdab:fa:il} {cmdab:res:pectcase}
 {break}
 {opt lo:cal(local_macro_name)} {opt plo:cal(local_macro_name)}
 {break}
 {cmdab:li:st}{cmd:(} [{varlist}] {ifin} [ , [{it:{help list:list_options}}] ] {cmd:)}
 {break}
 {cmdab:fr:ame}{cmd:(} {it:framename} [ , replace {cmdab:ch:ange} ] {cmd:)}
 {break}
 {cmdab:sa:ving}{cmd:(}{it:datafilename} [{cmd:, replace} ]{cmd:)}
 {break}
 {cmdab::no}{cmdab:re:store} {cmd:fast} {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
 {break}
 {cmdab:path:}
 {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)}
 {cmdab:ren:ame}{cmd:(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)}
 {cmdab:gs:ort}{cmd:(}{it:gsort_list}{cmd:)} {cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}
 {break}
 ]

{p 8 15}{cmd:xframedir} [ {cmd:,}
 {opt lo:cal(local_macro_name)}
 {break}
 {cmdab:li:st}{cmd:(} [{varlist}] {ifin} [ , [{it:{help list:list_options}}] ] {cmd:)}
 {break}
 {cmdab:fr:ame}{cmd:(} {it:framename} [ , replace {cmdab:ch:ange} ] {cmd:)}
 {break}
 {cmdab:sa:ving}{cmd:(}{it:datafilename} [{cmd:, replace} ]{cmd:)}
 {break}
 {cmdab::no}{cmdab:re:store} {cmd:fast} {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
 {break}
 {cmdab:path:}
 {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)}
 {cmdab:ren:ame}{cmd:(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)}
 {cmdab:gs:ort}{cmd:(}{it:gsort_list}{cmd:)} {cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}
 {break}
 ]

{pstd}
where {it:directory_name} is a directory name recognized by the operating environment currently being used,
{it:file_pattern} is a matching pattern recognized  by the {helpb f_strmatch:strmatch({it:s1},{it:s2})} function,
{it:file_type} is an item from the list

{p 8 18}
{cmdab:file:s} {cmdab:dir:s} {cmd:other}

{pstd}
and {it:{help list:list_options}} is a list of options accepted by the {helpb list} command.


{title:Description}

{pstd}
{cmd:xdir} is an extended version of {helpb dir}, or of the {help extended_fcn:extended macro function} {cmd:dir}.
It creates an output dataset (or resultsset),
with 1 observation for each file in a user-specified directory conforming to a user-specified pattern, and belonging to a user-specified file type,
and data on the file name and the directory name.
{cmd:xframedir} is an extended version of {helpb frames dir}.
It creates a resultsset with 1 observation per frame in the memory.
The resultsset from {cmd:xdir} or {cmd:xframedir} may be listed using the {cmd:list()} option
and/or saved to a {help frame:data frame} using the {cmd:frame()} option
and/or saved to a file using the {cmd:saving()} option
and/or written to the memory using the {cmd:norestore} or {cmd:fast} option,
overwriting any existing dataset.
Alternatively (or additionally), a list of the file or frame names
may be saved in a {help macro:local macro},
using the {cmd:local()} option, or the {cmd:plocal()} option for {cmd:xdir}.


{title:Options}

{pstd}
These options fall into the following 3 groups:

{p2colset 4 26 28 2}{...}
{p2col:Option group}Description{p_end}
{p2line}
{p2col:{it:{help xdir##filespec_opts:filespec_opts}}}File-specifying options for {cmd:xdir} only{p_end}
{p2col:{it:{help xdir##outdest_opts:outdest_opts}}}Output-destination options for the resultsset{p_end}
{p2col:{it:{help xdir#conspec_opts:conspec_opts}}}Content-specifying options for the resultsset{p_end}
{p2line}
{p2colreset}


{marker filespec_opts}{...}
{title:File-specifying options for {cmd:xdir} only}

{p 4 8 2}
{cmd:dirname(}{it:directory_name}{cmd:)} specifies a {help dir:directory name} under the current operating environment.
This directory name may be an absolute location (expressed as a full directory path)
or a relative location (expressed as a relative directory path).
If not specified, then the {cmd:dirname()} option defaults to the current directory location,
stored in the {helpb creturn} result {cmd:c(pwd)} and output by the Stata {helpb pwd} command.

{p 4 8 2}
{cmd:pattern(}{it:file_pattern}{cmd:)} specifies a file pattern, as recognized by the {helpb f_strmatch:strmatch({it:s1},{it:s2})} function in Stata.
This file pattern is used to specify a list of names of files found in the directory
specified by the {cmd:dirname()} option.
If unspecified, then the {cmd:pattern()} option is set to {cmd:pattern(*)},
specifying all files, directories or other entries in the directory specified by {cmd:dirname()}.

{p 4 8 2}
{cmd:ftype(}{it:file_type}{cmd:)} specifies a file type recognized by the {help extended_fcn:extended macro function} {cmd:dir}.
This file type may be {cmd:files}, {cmd:dirs}, or {cmd:other},
specifying, respectively, files, directories, or entries that are neither files nor directories,
in the directory specified by the {cmd:dirname()} option.

{p 4 8 2}
{cmd:nofail} specifies that, if the directory contains too many filenames to fit into a macro,
then, instead of issuing an error, the filenames that fit into the macro should be returned.
{cmd:nofail} should rarely, if ever, be specified.

{p 4 8 2}
{cmd:respectcase} specifies that, under Microsoft Windows, {cmd:xdir} will respect the case of filenames when performing matches.
Unlike other operating systems, Microsoft Windows has, by default, case-insensitive filenames.
{cmd:respectcase} is ignored in operating systems other than Windows.


{marker outdest_opts}{...}
{title:Output-destination options}

{p 4 8 2}
{cmd:local(}{it:local_macro_name}{cmd:)} specifies the name of a {help macro:local macro},
containing a list of the names of all the files (or other directory entries) for {cmd:xdir},
or a list of all the frame names in the memory for {cmd:xframedir})
The list will be in alphabetical (ascending ASCII or code-point) order.

{p 4 8 2}
{cmd:plocal(}{it:local_macro_name}{cmd:)} ({cmd:xdir} only)
specifies the name of a {help macro:local macro},
in which a list of the complete path names (complete with the directory name)
of all the files (or other directory entries) will be stored.
The list will be in alphabetical (ascending ASCII or code-point) order.
The complete path name for a file is defined
as the directory name plus the directory separator plus the file name.
For instance, the file {cmd:myfile.txt} in the directory {cmd:root}
will have the complete pathname {cmd:root/myfile.txt},
if the directory separator is {cmd:/}, as it is under Linux.
The {cmd:plocal()} macro is very useful for input to {helpb append}
to concatenate multiple dataset files from a directory into the memory.

{p 4 8 2}
{cmd:list(}{it:varlist} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [, {it:list_options} ] {cmd:)}
specifies a list of variables in the output dataset,
which will be listed to the Stata log by {cmd:xdir}.
The user may optionally also specify {helpb if} or {helpb in} clauses to list subsets of observations
(corresponding to subsets of directory entries),
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.
If the {cmd:rename()} option is specified (see below),
then any variable names specified by the {cmd:list()} option must be the new names.
If the {cmd:list()} option is absent, then nothing is listed.

{p 4 8 2}
{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
with one observation per directory entry,
and data on the attributes of the directory entry.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame after the execution of {cmd:xdir}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{p 4 8 2}
{cmd:saving(}{it:datafilename} [{cmd:, replace}]{cmd:)} specifies an output file containing a Stata dataset,
with one observation per directory entry,
and data on the attributes of the directory entry.
If {cmd:replace} is specified, then any existing file of the same name is overwritten. 

{p 4 8 2}
{cmd:norestore} and {cmd:fast} are two names for the same option.
They specify that the output dataset will be written to the current {help frame:data frame} in memory,
overwriting any pre-existing dataset.

{p 4 8 2}
Note that the user must specify at least one of the options {cmd:local()}, {cmd:plocal()}, {cmd:list()},
{cmd:frame()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.

{p 4 8 2}
{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a {help macro:global macro},
containing a filename list (possibly empty).
If {cmd:saving()} is also specified,
then {cmd:xdir} will append the {it:filename} specified in the {cmd:saving()} option
to the value of the global macro specified in {cmd:flist()}.
This enables the user to build a list of filenames in a global macro, containing the
output of a sequence of resultssets saved by {cmd:xdir}.
These files may later be concatenated using {helpb append}.


{marker conspec_opts}{...}
{title:Content-specifying options}

{p 4 8 2}
{cmd:path} ({cmd:xdir} only) specifies that a new string variable {cmd:path} will be generated,
containing the complete path names for the files.
The complete path name for a file is defined
as the directory name plus the directory separator plus the file name.

{p 4 8 2}
{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable {hi:idnum} in the output dataset, with that value for all
observations.
This is useful if the output dataset is concatenated with other {cmd:xdir} or {cmd:xframedir} output datasets
using {helpb append}.

{p 4 8 2}
{cmd:idstr(}{it:#}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable {hi:idstr} in the output dataset, with that value for all
observations. (An output dataset may have {hi:idnum}, {hi:idstr}, both or neither.)

{p 4 8 2}
{cmd:rename(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)} specifies a list
of pairs of variable names. The first variable name of each pair specifies a variable in the output dataset,
which is renamed to the second variable name of the pair.
(See {hi:Output dataset created by {cmd:xdir} and {cmd:xframedir}} below for details on output variables.)

{p 4 8 2}
{cmd:gsort(}{it:gsort_list}{cmd:)} specifies a generalized sorting order (as recognised by {helpb gsort})
for the observations in the output dataset.
If {cmd:gsort()} is not specified,
then the output dataset will be sorted by the {help varlist:variable list} {cmd:dirname filename}.
If {cmd:rename()} is specified, then {cmd:gsort()} must use the new names.

{p 4 8 2}
{cmd:keep(}{it:varlist}{cmd:)} specifies a list of variables to be kept in the output dataset.
If {cmd:keep()} is not specified, then the output dataset contains all the variables listed in the next section.
If {cmd:rename()} is specified, then {cmd:keep()} must use the new names.


{title:Output datasets created by {cmd:xdir}} and {cmd:xframedir}}

{pstd}
The output dataset (or resultsset) created by {cmd:xdir}
has one observation per entry, in the directory specified by the {cmd:dirname()} option,
of the type specified by the {cmd:ftype()} option,
and conforming to the file pattern specified by the {cmd:pattern()} option.
If the {cmd:rename()} option
is not specified, then it contains the following variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{cmd:idnum}}Numeric dataset ID{p_end}
{p2col:{cmd:idstr}}String dataset ID{p_end}
{p2col:{cmd:dirname}}Directory name{p_end}
{p2col:{cmd:filename}}File name{p_end}
{p2col:{cmd:path}}File path{p_end}
{p2line}
{p2colreset}

{pstd}
The otput dataset (or resultsset) created by {cmd:xframedir}
has one observation per data frame in the memory.
If the {cmd:rename()} option
is not specified, then it contains the following variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{cmd:idnum}}Numeric dataset ID{p_end}
{p2col:{cmd:idstr}}String dataset ID{p_end}
{p2col:{cmd:framename}}Frame name{p_end}
{p2line}
{p2colreset}

{pstd}
The variables {hi:idnum}, {hi:idstr} and {cmd:path} are only present if requested in the options of the same names.
The dataset is sorted by the variables {cmd:dirname} and {cmd:filename} (for {cmd:xdir}),
or by the variabl {cmd:framename} (for {cmd:xframedir}),
unless the {cmd:gsort()} option is specified..
All of these variables can be renamed using the {cmd:rename()} option,
or used by the {cmd:gsort()} option to specify the sorting order.
If the {cmd:keep()} option is used, then the output dataset will contain only the specified subset of these variables.


{title:Remarks}

{pstd}
{cmd:xdir} is an extended version of the {helpb dir} command,
and uses the {help extended_fcn:extended macro function} {cmd:dir}
to produce a comparable list of directory entries under different operating environments.
Under specific operating environments, the user can use alternative packages for producing directory listings,
such as {helpb linuxlsd1} under Linux or Mac OS X,
or {helpb msdirb} under Microsoft Windows.
These packages have syntax and output optimized for their specific operating environments.
The packages {helpb linuxlsd1} and {helpb msdirb} can be downloaded from {help ssc:SSC}.


{title:Examples}

{p 16 20}{cmd:. xdir, list(,)}{p_end}

{p 16 20}{cmd:. xdir, dir(.) list(,)}{p_end}

{p 16 20}{cmd:. xdir, dir(..) ftype(dir) list(,)}{p_end}

{p 16 20}{cmd:. xdir, saving(myxdir.dta, replace)}{p_end}

{p 16 20}{cmd:. xdir, norestore}{p_end}
{p 16 20}{cmd:. describe}{p_end}
{p 16 20}{cmd:. list}{p_end}

{p 16 20}{cmd:. xdir, norestore idstr("My directory listing")}{p_end}
{p 16 20}{cmd:. describe}{p_end}
{p 16 20}{cmd:. list}{p_end}

{p 16 20}{cmd:. xdir, fast}{p_end}
{p 16 20}{cmd:. describe}{p_end}
{p 16 20}{cmd:. list}{p_end}

{p 16 20}{cmd:. xdir, list(,) local(lalla)}{p_end}
{p 16 20}{cmd:. disp `"`lalla'"'}{p_end}

{p 16 20}{cmd:. xdir, path frame(mycontents, replace change)}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list, abbr(32)}{p_end}
{p 16 20}{cmd:. frame change default}{p_end}

{p 16 20}{cmd:. xframedir, list(, abbr(32))}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] dir}, {hi:[P] Extended macro functions}
{p_end}
{p 4 13 2}
On-line: help for {helpb dir}, {helpb frames dir}, {help extended_fcn:Extended macro functions}
 {break} help for {helpb linuxlsd1}, {helpb msdirb} if installed
{p_end}
