{smcl}
{hline}
help for {cmd:osgen} {right:(Roger Newson)}
{hline}


{title:Add {helpb python:Python os_stat()} file attributes to a {helpb xdir} resultsset}

{p 8 15}{cmd:osgen} {ifin} [ {cmd:,}
 {cmdab:fi:lename}{cmd:(}{varname}{cmd:)} {cmdab:di:rname}{cmd:(}{varname}{cmd:)} {cmdab::no}{cmdab:dn:}
 {break}
 {opth st_mode(newvarname)} {opth st_ino(newvarname)} {opth st_dev(newvarname)} {opth st_nlink(newvarname)} {opth st_uid(newvarname)}
 {break}
 {opth st_gid(newvarname)} {opth st_size(newvarname)} {opth st_atime(newvarname)} {opth st_mtime(newvarname)} {opth st_ctime(newvarname)}
 {break}
 {cmd:replace} {cmdab::no}{cmdab:dest:ring}
 ]


{title:Description}

{pstd}
{cmd:osgen} is intended for use in output datasets (or resultssets)
produced by the {helpb xdir} module of the {helpb xdir} package,
which have one observation for each of a list of files,
and data on directory names and file names.
It inputs the file name variable and (optionally) the directory name variable,
and generates a list of new variables,
containing, in each observation, {help python:Python} {cmd:os_stat()} attributes
of the corresponding file,
as recognised by the current operating system (OS).
These attributes include file sizes and creation, modification and access times.
The storage conventions for these OS statistics for files
may vary between operating environments,
but it might still be useful to be able to sort the extended {helpb xdir} resultsset
by these attributes.
This package uses the {help python:Stata Python interface},
and requires the presence, in the user's operating environment,
of a version of {help python:Python} compatible with the user's version of Stata.


{title:Options}

{p 4 8 2}
{opth filename(varname)} specifies an existing string variable,
containing the file names.
If absent, then it is set to {cmd:filename}.

{p 4 8 2}
{opth dirname(varname)} specifies an existing string variable,
containing the directory names.
If absent, then it is set to {cmd:dirname}.

{p 4 8 2}
{cmd:nodn} specifies that the directory name variable specified by {cmd:dirname()} will not be used.
This option can be useful,
if the file name variable specified by {cmd:filename()} contains the full file path for each file,
including the directory name.

{p 4 8 2}
{opth st_mode(newvarname)}, {opth st_ino(newvarname)}, {opth st_dev(newvarname)}, {opth st_nlink(newvarname)}, {opth st_uid(newvarname)},
{opth st_gid(newvarname)}, {opth st_size(newvarname)}, {opth st_atime(newvarname)}, {opth st_mtime(newvarname)}, and {opth st_ctime(newvarname)}
specify the names for the output variables to be created.
Each of these options specifies the name of a created variable containing the {cmd:os_stat_result} attribute of the same name
returned by the {cmd:os_stat()} command of the {cmd:os} module of {help python:Python}.
In default, if one of these options is not specified,
then the new variable has the same name as the option.
These variables contain OS statistics for the corresponding files.

{p 4 8 2}
{cmd:replace} specifies that any existing variables with the same names as the generated output variables will be replaced.

{p 4 8 2}
{cmd:nodestring} specifies that the output variables will be created as string variables.
If {cmd:nodestring} is not specified, then the output variables will be converted to numeric,
preferably with the lowest {help datatype:storage type} capable of storing the information.
The {cmd:nodestring} option may be useful,
if some of these numbers are extremely large and cannot be stored as numbers to exact precision,
as might happen if the numbers are numbers of bytes in multi-gigabyte files,
or times in nanoseconds since 1960.


{title:Output variables created by {cmd:osgen}}

{pstd}
The {cmd: osgen} package creates the following list of variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{cmd:st_mode}}File mode (types and permissions){p_end}
{p2col:{cmd:st_ino}}File identification number (within device){p_end}
{p2col:{cmd:st_dev}}Device identifier{p_end}
{p2col:{cmd:st_nlink}}Number of hard links{p_end}
{p2col:{cmd:st_uid}}User ID of file owner{p_end}
{p2col:{cmd:st_gid}}Group ID of file owner{p_end}
{p2col:{cmd:st_size}}Size of file (bytes){p_end}
{p2col:{cmd:st_atime}}Last access time of file (seconds){p_end}
{p2col:{cmd:st_mtime}}Last modification time of file (seconds){p_end}
{p2col:{cmd:st_ctime}}Creation time of file (seconds){p_end}
{p2line}
{p2colreset}

{pstd}
The interpretation of these numbers may vary between operating environments,
which may have different conventions about precision and/or starting date-times.
However, it may be reasonable to assume that the sort order of file access, modification or creation dates
will be consistent between operating environments.
This should enable the user to create a sequence of output files under one operating environment
(such as a large data server using Linux),
and to sort them in the order in which these files were last modified under that environment,
and to send a list of these files, in creation order,
to another operating environment
(such as a user's own Windows machine).


{title:Remarks}

{pstd}
{cmd:descgen} is designed for use in output datasets (or resultssets),
with one observation for each of a list of files,
created using the {helpb xdir} package,
which can be downloaded from {help ssc:SSC}.
It inputs the variables whose default names are {cmd: filename},
and (optionally) {cmd:dirname},
containing the file names and directory names, respectively.
It outputs, in each observation,
the file attributes that may be output
by the {help python:Python} command {cmd:os_stat()} of the {cmd:os} module.


{title:Examples}

{pstd}
Create {helpb xdir} resultsset in current data frame:

{p 16 20}{cmd:. xdir, dir(.) pattern(*.*) fast}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list, abbr(32)}{p_end}

{pstd}
Generate new variables containing OS attributes using {cmd:osgen}:

{p 16 20}{cmd:. osgen, replace}{p_end}
{p 16 20}{cmd:. describe, full}{p_end}
{p 16 20}{cmd:. list, abbr(32)}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Acknowledgements}

{pstd}
I would like to thank Rafal Raciborski of StataCorp for suggesting the use of the {cmd:os} module of {help python:Python}
for accessing OS statistics about file sizes and modification dates in a way portable between operating environments,
and Zhao Xu of StataCorp for advising me on how to install a version of {help python:Python}
compatible with my version of Stata.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[P] python}, {hi:[D] dir}
{p_end}
{p 4 13 2}
On-line: help for {helpb python}, {helpb dir}
 {break} help for {helpb xdir} if installed
{p_end}
