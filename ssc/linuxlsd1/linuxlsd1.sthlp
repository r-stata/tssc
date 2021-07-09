{smcl}
{hline}
help for {cmd:linuxlsd1}{right:(Roger Newson)}
{hline}

{title:Create a dataset of file records from the output of a Linux {cmd:ls -d1} command}

{p 8 21 2}
{cmd:linuxlsd1} [ , {cmdab:fs:pec}{cmd:(}{it:file_spec}{cmd:)} {cmdab:lso:ptions}{cmd:(}{it:ls_options}{cmd:)}
{opth fi:nfo(newvarname)}
{opt clear} 
]

{p 8 21 2}
{cmd:llinuxlsd1} [ , {cmdab:fs:pec}{cmd:(}{it:file_spec}{cmd:)}{cmd:)} {cmdab:lso:ptions}{cmd:(}{it:ls_options}{cmd:)}
{opth fi:nfo(name)}
]

{pstd}
where {it:file_spec} is a Linux or Mac OS X file list specification
and {it:ls_options} is a list of extra options for the Linux {cmd:ls} command.
For more about these specifications and options, see the Linux online help under {cmd:ls --help}.


{title:Description}

{pstd}
{cmd:linuxlsd1} inputs a file list specification recognised by Linux, Unix or Mac OS X,
and generates in the memory a new Stata dataset, with 1 observation per file in the list,
and data on information about the file,
including the file name and possibly other file-specific information.
This new Stata dataset can then be used for mass-processing of the specified files.
{cmd:llinuxlsd1} inputs a file list specification recognised by Linux or Mac OS X,
and generates a {help macro:local macro} containing a list,
with 1 list item per file in the list,
containing information about the file, including the file name and possibly other items.
{cmd:linuxlsd1} and {cmd:llinuxlsd1} work by using the Linux {cmd:ls} command,
with the options {cmd:-d1} to specify that directories in the file list will be listed as files (and not expanded),
and that the output will contain 1 line per file.
They are designed to work only under a Linux, Unix or Mac OS X operating environment.


{title:Options for {cmd:linuxlsd1} and {cmd:llinuxlsd1}}

{phang}
{cmd:fspec(}{it:file_spec}{cmd:)} specifies a list of files,
in the language of Linux or Mac OS X.
If not specified, then it is set to {cmd:.},
specifying the local directory under Linux or Mac OS X.
These file specifications may contain wildcards such as {cmd:*}.
For instance, {cmd:filespec("*.txt")} specifies a list of all files in the current directory with the extension {cmd:.txt}.
It is usually a good idea to enclose the {cmd:fspec()} option in quotes,
because Linux file specifications often contain forward slashes ({cmd:/}),
which Stata uses for an escape character, at least in {help do:do-files}.

{phang}
{cmd:lsoptions(}{it:ls_options}{cmd:)} specifies a list of options acceptable to the {cmd:ls} command under Linux.
For instance, {cmd:lsoptions(-t)} specifies that the files will be sorted by the time when they were created,
and {cmd:lsoptions(l)} specifies that the output variable or macro will contain list items for each file,
instead of just the file name.

{title:Options for {cmd:linuxlsd1} only}

{phang}
{opth finfo(newvarname)} specifies the name for a variable to be generated in the output dataset,
containing the file information output by the Linux {cmd:ls -d1} command,
with the files specified by the {cmd:fspec()} option.
If {cmd:finfo()} is unset, then the variable will have the name {cmd:finfo}.

{phang}
{cmd:clear} specifies that the output dataset will overwrite any existing dataset that may be present in the memory.
If {cmd:clear} is not specified,
then {cmd:linuxlsd1} will refuse to create an output dataset if data are already in memory.
This convention protects the user from deleting important data.


{title:Options for {cmd:llinuxlsd1} only}

{phang}
{opth finfo(name)} specifies the name for a {help macro:local macro} to be generated,
containing the list of file information records output by the Linux {cmd:ls -d1} command
for the files specified by the {cmd:fspec()} option.
If {cmd:finfo()} is unset, then the macro will have the name {cmd:finfo}.


{title:Remarks}

{pstd}
The {cmd:linuxlsd1} package is the Linux, Unix or Mac OS X equivalent of the {helpb msdirb} package,
which creates a dataset in memory, or a local macro, containing a user-specified list of Microsoft Windows file names,
and which can be downloaded from {help ssc:SSC}.


{title:Examples}

{pstd}
The following example creates in memory a dataset of all filenames with the extension {cmd:.txt} in the directory {cmd:./mysub1},
with a single variable {cmd:finfo} containing the file name. Note that the file specification is enclosed in quotes:

{p 8 12 2}{cmd:. linuxlsd1, fspec("./mysub1/*.txt") clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example creates in memory a dataset of all filenames with the extension {cmd:.txt} in the directory {cmd:./mysub1},
but this time the a single variable containing the file name is named {cmd:filepath}:

{p 8 12 2}{cmd:. linuxlsd1, fspec("./mysub1/*.txt") finfo(filepath) clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example creates in memory a dataset with 1 observation per file with the extension {cmd:.txt} in the directory {cmd:./mysub1}.
However, this time the file-information variable is named {cmd:filedata},
and the {cmd:lsoptions} option ensures that it contains not only the filename but also a list of other information (specified by the {cmd {ls} option {cmd:-l}),
 and the observations are sorted in descending order of file size (specified by the {cmd:ls} option {cmd:-S}).

{p 8 12 2}{cmd:. linuxlsd1, fspec("./mysub1/*.txt") lsoptions(-lS) finfo(filedata) clear}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}

{pstd}
The following example uses the {cmd:llinuxlsd1} module to create a list of all filenames with the extension {cmd:.txt} in the directory {cmd:./mysub1},
storing their names in a {help local macro} named {cmd:foobar}.
It then uses the {helpb tfconcat} module of the {help ssc:SSC} package {helpb intext}
to concatenate all the files in the list into a dataset in memory,
with a string variable {cmd:line} containing the file line,
and a string variable {cmd:filename} containing the file from which the line came:

{p 8 12 2}{cmd:. llinuxlsd1, fspec("./mysub1/*.txt") finfo(foobar)}{p_end}
{p 8 12 2}{cmd:. macro list _foobar}{p_end}
{p 8 12 2}{cmd:. tfconcat `foobar', tfname(filename) gene(line)}{p_end}
{p 8 12 2}{cmd:. describe, full}{p_end}
{p 8 12 2}{cmd:. list}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] shell}, {hi:[D] insheet}, {hi:[D] cd}
{p_end}
{p 4 13 2}
On-line: help for {helpb shell}, {helpb insheet}, {helpb pwd}, {helpb cd}
{break}
help for {helpb msdirb}, {helpb intext}, {helpb tfconcat} if installed
{break}
Linux help for the {cmd:ls} command under {cmd:ls --help} in Linux
{p_end}
