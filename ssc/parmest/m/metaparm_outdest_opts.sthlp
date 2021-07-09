{smcl}
{hline}
{cmd:help metaparm_outdest_opts}{right:(Roger Newson)}
{hline}


{title:Output-destination options for {helpb metaparm}}


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
These options are available for {helpb metaparm}, but only {cmd:fast} is available for {helpb parmcip}.
They control the destination of the output dataset (or resultsset) created by {helpb metaparm},
which may be listed and/or saved to disk and/or written to the memory.


{title:Options}

{p 4 8 2}
{cmd:list(} [{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log and/or the Results window.
The {cmd:list()} option can be used with the {cmd:format()} option (see {it:{help metaparm_misc_opts}})
to produce a list of parameter names, estimates, confidence limits,
{it:P}-values and other parameter attributes,
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {help if} or {help in} clauses to list subsets of parameters,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.

{p 4 8 2}
{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
to be generated to contain the output data set.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame after the execution of {cmd:metaparm}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{p 4 8 2}
{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{p 4 8 2}
{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset. This option is automatically set if {cmd:fast} is
specified. Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {cmd:metaparm}.

{p 4 8 2}
{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {help break:Break} during the execution of {helpb metaparm}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {helpb metaparm} will go to extra work so that
it can restore the original data if the user presses {help break:Break}.

{p 4 8 2}
{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a global macro, containing
a filename list (possibly empty). If {cmd:saving()} is also specified, then
{cmd:metaparm} will append the name of the dataset specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}. This
enables the user to build a list of filenames in a global macro, containing the
output of a sequence of datasets.
These files may later be concatenated using {helpb append}.


{title:Notes}

{pstd}
Note that the user must specify at least one of the five options
{cmd:list()}, {cmd:frame()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.
These four options specify whether the output dataset is listed to the Stata log,
saved to a new data frame,
saved to a disk file, or written to the current data frame
(overwriting any pre-existing dataset).
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
{helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm},
{help metaparm_content_opts:{it:metaparm_content_opts}}, {help parmcip_opts:{it:parmcip_opts}},
{help metaparm_resultssets:{it:metaparm_resultssets}}
{p_end}
