{smcl}
{hline}
{cmd:help parmest_outdest_opts}{right:(Roger Newson)}
{hline}


{title:Output-destination options for {helpb parmest} and {helpb parmby}}


{title:Syntax}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt li:st(list_spec)}}List output dataset to Stata log and/or Results window{p_end}
{synopt:{cmdab:fra:me}{cmd:(}{it:framename}[,replace {cmdab:cha:nge}]{cmd:)}}Save output dataset to a data frame{p_end}
{synopt:{cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}}Save output dataset to a disk file{p_end}
{synopt:{cmdab::no}{cmdab:re:store}}Write output dataset to memory{p_end}
{synopt:{opt fast}}Write output dataset to memory without precautions{p_end}
{synopt:{opt fl:ist(global_macro_name)}}Append output filename to a global macro{p_end}
{synoptline}

{pstd}
where {it:list_spec} is a specification of the form

{pstd}
[{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ]

{pstd}
and {help list:{it:list_options}} is a list of options used by the {helpb list} command.


{title:Description}

{pstd}
These options control the destination of the output dataset (or resultsset) created by {helpb parmest} or {helpb parmby},
which may be listed and/or saved to disk and/or written to the memory.


{title:Options}

{p 4 8 2}
{cmd:list(} [{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log by {helpb parmby} or {helpb parmest}.
The {cmd:list()} option can be used with the {cmd:format()} option (see {help parmest_varmod_opts:{it:parmest_varmod_opts}})
to produce a list of parameter names, estimates, confidence limits,
{it:P}-values and other parameter attributes,
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {help if} or {help in} clauses to list subsets of parameters,
or change the display style using a list of {help list:{it:list_options}}
allowed as options by the {helpb list} command.
If the {cmd:rename()} option is specified (see {help parmest_varmod_opts:{it:parmest_varmod_opts}}),
then any variable names specified by the {cmd:list()} option must be the new names.
If the {cmd:by()} option is specified with {helpb parmby} (see {help parmby_only_opts:{it:parmby_only_opts}}),
then the variables specified by the {cmd:list()} option are listed by the by-variables,
as when {helpb by:by ... :} is used with the {helpb list} command.

{p 4 8 2}
{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
to be generated to contain the output data set.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame
after the execution of {cmd:parmest} or {cmd:parmby}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{p 4 8 2}
{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{p 4 8 2}
{cmd:norestore} specifies that the output dataset will be written to the current data frame,
overwriting any pre-existing dataset.
This option is automatically set if {cmd:fast} is specified.
Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {helpb parmby} or {helpb parmest}.

{p 4 8 2}
{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {help break:Break} during the execution of {helpb parmby} or {helpb parmest}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {helpb parmest} or {helpb parmby} will go to extra work so that
it can restore the original data if the user presses {help break:Break}.

{p 4 8 2}
{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a {help macro:global macro},
containing a filename list (possibly empty).
If {cmd:saving()} is also specified, then
{helpb parmest} or {helpb parmby} will append the {it:filename} specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}.
This enables the user to build a list of filenames in a global macro, containing the
output of a sequence of estimation result sets saved by {helpb parmest} or {helpb parmby}.
These files may later be concatenated using {helpb append}.


{title:Notes}

{pstd}
Note that the user must specify at least one of the five options
{cmd:list()}, {cmd:frame()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.
These four options specify whether the output dataset is listed to the Stata log,
saved to a new data frame,
saved to a disk file, or written to the current data frame (overwriting any pre-existing dataset).
More than one of these options can be specified.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {manlink D list}, {manlink D save}, {manlink D append}, {manlink P macro}
{p_end}

{psee}
{space 2}Help:  {manhelp list D}, {manhelp save D}, {manhelp append D}, {manhelp macro P}{break}
{helpb parmest}, {helpb parmby},
{help parmest_ci_opts:{it:parmest_ci_opts}}, {help parmest_varadd_opts:{it:parmest_varadd_opts}},
{help parmest_varmod_opts:{it:parmest_varmod_opts}}, {help parmby_only_opts:{it:parmby_only_opts}},
{help parmest_resultssets:{it:parmest_resultssets}}
{p_end}
