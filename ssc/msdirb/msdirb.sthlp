{smcl}
{hline}
help for {cmd:msdirb}{right:(Roger Newson)}
{hline}

{title:Create a dataset of file names from the output of a MS-DOS {cmd:dir/b} command}

{p 8 21 2}
{cmd:msdirb} [ , {cmdab:di:rspec}{cmd:(}{it:dir_spec}{cmd:)} {cmdab:fi:lespec}{cmd:(}{it:file_spec){cmd:}}
{opth dn:ame(newvarname)} {opth fn:ame(newvarname)} {opth dfn:ame(newvarname)}
{opt clear} {opt lo:wercase} 
{cmdab:a:ttribute}{cmd:(}{it:attribute_specs}{cmd:)} {cmdab:s:ortorder}{cmd:(}{it:sort_order_specs}{cmd:)}
]

{p 8 21 2}
{cmd:lmsdirb} [ , {cmdab:di:rspec}{cmd:(}{it:dir_spec}{cmd:)} {cmdab:fi:lespec}{cmd:(}{it:file_spec){cmd:}}
{opth dn:ame(name)} {opth fn:ame(name)} {opth dfn:ame(name)}
{opt lo:wercase} 
{cmdab:a:ttribute}{cmd:(}{it:attribute_specs}{cmd:)} {cmdab:s:ortorder}{cmd:(}{it:sort_order_specs}{cmd:)}
]

{pstd}
where {it:dir_spec} is a MS-DOS directory specification, {it:file_spec} is a MS-DOS file list specification,
{it:attribute_specs} is a MS-DOS attribute specification recognised by the MS-DOS {cmd:dir} command,
and {it:sort_order_specs} is a MS-DOS sort order specification recognised by the MS-DOS {cmd:dir} command.
For more about these specifications, see the MS-DOS online help under {cmd:help dir} in MS-DOS,
or refer to {help msdirb##jamsa_1993:Jamsa (1993)}.


{title:Description}

{pstd}
{cmd:msdirb} inputs a directory specification and a file list specification recognised by MS-DOS,
and generates in the memory a new Stata dataset, with 1 observation per file in the list,
and data on the directory and/or the name of the file.
This new Stata dataset can then be used for mass-processing of the specified files.
{cmd:lmsdirb} inputs a directory specification and a file list specification recognised by MS-DOS,
and generates local macros containing lists, with 1 list item per file in the list,
and data on the directory and/or the name of the file.
{cmd:msdirb} and {cmd:lmsdirb} work by using the MS-DOS {cmd:dir} command,
with the switch {cmd:/b} to specify display of filenames only.
They are designed to work only under a Microsoft Windows operating environment.


{title:Options for {cmd:msdirb} and {cmd:lmsdirb}}

{phang}
{cmd:dirspec(}{it:dir_spec}{cmd:)} specifies a directory in the language of MS-DOS.
This directory is where the specified files are located.
If not supplied, then it is set to {cmd:dirspec(.)},
specifying the current working directory,
which can be found by typing {helpb pwd} in Stata.
The specification may be an absolute directory location,
or a relative directory location specified from the current working directory.
For instance, {cmd:dirspec(..)} specifies the parent directory of the current directory,
and {cmd:dirspec(..\..\myfolder)} specifies a subdirectory {cmd:myfolder},
located in the grandparent directory of the current directory.
Note that {cmd:msdirb} replaces all forward slashes in the {cmd:dirspec()} option with backward slashes,
to harmonize with MS-DOS conventions.
For instance, {cmd:dirspec(../../myfolder)} is interpreted as {cmd:dirspec(..\..\myfolder)}.

{phang}
{cmd:filespec(}{it:file_spec}{cmd:)} specifies a list of files in the directory specified by the {cmd:dirspec()} option,
in the language of MS-DOS.
If not specified, then it is set to {cmd:filespec(*)},
specifying the set of all files in the directory specified by {cmd:dirspec()},
or possibly a variant of this set,
after modification by the {cmd:attribute()} option
(see below).
These file specifications may contain wildcards such as {cmd:*}.
For instance, {cmd:filespec(*.txt)} specifies a list of all files with the extension {cmd:.txt}.

{phang}
{cmd:lowercase} specifies that the directory and file specifications in the output dataset will contain only lower case letters.
If {cmd:lowercase} is absent,
then the directory and file specifications may contain upper case letters.

{phang}
{cmd:attribute(}{it:attribute_specs}{cmd:)} specifies a file attribute specification,
recognised as a suboption list for the {cmd:/a} switch of the MS-DOS {cmd:dir} command,
which specifies subsets of files.
For instance, {cmd:attribute(d)} specifies that only directories will be included.
The prefix {cmd:-} specifies exclusions.
For instance, {cmd:attribute(-d)} specifies that only non-directories will be included.

{phang}
{cmd:sortorder(}{it:sort_order_specs}{cmd:)} specifies th a sorting order specification,
recognised as a suboption list for the {cmd:/o} switch of the MS-DOS {cmd:dir} command.
For instance, {cmd:sortorder(n)} specifies sorting by ascending alphanumeric order of file name.
The prefix {cmd:-} is used to specify descending sorts.
For instance, {cmd:sortorder(-n)} specifies sorting by descending alphanumeric order of file name.


{title:Options for {cmd:msdirb} only}

{phang}
{cmd:dname(}{varname}{cmd:)} specifies the name for a variable in the output dataset,
containing the directory specification.
This variable will have the same value in all the observations of the output dataset.
If {cmd:dname()} is unset, then such a variable will not be present in the output dataset.

{phang}
{cmd:fname(}{varname}{cmd:)} specifies the name for a variable in the output dataset,
containing the filename without the directory specification.
If {cmd:fname()} is unset, then such a variable will not be present in the output dataset.

{phang}
{cmd:dfname(}{varname}{cmd:)} specifies the name for a variable in the output dataset,
containing the filename with the directory specification.
The directory specification will be separated from the filename by a backslash character ({cmd:"\"}).
If {cmd:dfname()} is unset, then such a variable will not be present in the output dataset.

{phang}
Note that the user must specify one of the 3 options {cmd:dname()}, {cmd:fname()},
and/or {cmd:dfname()}.

{phang}
{cmd:clear} specifies that the output dataset will overwrite any existing dataset that may be present in the memory.
If {cmd:clear} is not specified,
then {cmd:msdirb} will refuse to create an output dataset if data are already in memory.
This convention protects the user from deleting important data.


{title:Options for {cmd:lmsdirb} only}

{phang}
{opth dname(name)} specifies the name for a local macro,
containing the list of directory specifications.
This list will have the same value in all items.
If {cmd:dname()} is unset, then such a macro will not be created.

{phang}
{opth fname(name)} specifies the name for a local macro,
containing the list of filenames without the directory specifications.
If {cmd:fname()} is unset, then such a macro will not be created.

{phang}
{opth dfname(name)} specifies the name for a local macro,
containing the list of filenames with the directory specifications.
The directory specifications will be separated from the filenames by a backslash character ({cmd:"\"}).
If {cmd:dfname()} is unset, then such a macro will not be created.

{phang}
Note that the user must specify one of the 3 options {cmd:dname()}, {cmd:fname()},
and/or {cmd:dfname()}.


{title:Examples}

{pstd}
The following example creates a dataset of all filenames with the extension {cmd:.txt} in the current directory,
with a single variable containing the file name:

{p 8 12 2}{cmd:. msdirb, filespec(*.txt) fname(filename) clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example creates a dataset of all filenames with the extension {cmd:.txt} in the directory {cmd:.\mysub1},
with separate variables containing the directory specification, the short file name, and the full file name,
sorted in ascending name order:

{p 8 12 2}{cmd:. msdirb, dirspec(.\mysub1) filespec(*.txt) dname(folder) fname(shortname) dfname(fullname) sortorder(n) clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example creates a dataset of all directory names in the parental folder,
and a single variable containing the directory name as a file in the parental filder,
sorted in ascending name order:

{p 8 12 2}{cmd:. msdirb, dirspec(..) dfname(fulldir) sortorder(n) attribute(d) clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example uses {cmd:lmsdirb} to create a local macro {cmd:paths},
containing a list of all files with the extension {cmd:.txt}
in the directory {cmd:.\mysub1}.
It then uses the {helpb tfconcat} module of the {helpb intext} package
to concatenate these text files into a Stata dataset in memory,
with 1 string variable {cmd:line1},
containing the lines of all the concatenated {cmd:.txt} files.
The {helpb intext} package is downloadable from {help ssc:SSC}.

{p 8 12 2}{cmd:. lmsdirb, dirspec(.\mysub1) filespec(*.txt) dfname(paths)}{p_end}
{p 8 12 2}{cmd:. tfconcat `paths', gene(line)}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{marker jamsa_1993}{...}
{phang}
Jamsa, K.
1993.
{it:DOS: the Pocket Reference. Third Edition}.
Berkeley, CA: McGraw-Hill.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] shell}, {hi:[D] insheet}, {hi:[D] cd}
{p_end}
{p 4 13 2}
On-line: help for {helpb shell}, {helpb insheet}, {helpb pwd}, {helpb cd}
{break}
help for {helpb tfconcat}, {helpb intext} if installed
{break}
MS-DOS help for the {cmd:dir} command under {cmd:help dir} in MS-DOS
{p_end}
