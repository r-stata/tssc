{smcl}
{hline}
{cmd:help parmhet_resultsset_opts}{right:(Roger Newson)}
{hline}


{title:Resultsset options for {helpb parmhet}}

{synoptset 32}
{synopthdr}
{synoptline}
{synopt:{opt li:st(list_spec)}}List output dataset to Stata log and/or Results window{p_end}
{synopt:{cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}}Save output dataset to a disk file{p_end}
{synopt:{cmdab::no}{cmdab:re:store}}Write output dataset to memory{p_end}
{synopt:{opt fast}}Write output dataset to memory without precautions{p_end}
{synopt:{opt fl:ist(global_macro_name)}}Append output filename to a global macro{p_end}
{synopt:{opt idn:um(#)}}Value of numeric dataset ID variable{p_end}
{synopt:{cmdab:nidn:um}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of numeric dataset ID variable{p_end}
{synopt:{opt ids:tr(string)}}Value of string dataset ID variable{p_end}
{synopt:{cmdab:nids:tr}{cmd:(}{help newvar:{it:newvarname}}{cmd:)}}Name of string dataset ID variable{p_end}
{synopt:{cmdab:su:mvar}{cmd:(}{varlist}{cmd:)}}Variables to be summed in the output dataset{p_end}
{synopt:{opt fo:rmat(formatting_list)}}Display formats for variables in the output dataset{p_end}
{synopt:{cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}}Variables to be kept in the output dataset{p_end}
{synoptline}

{pstd}
where {it:formatting_list} is a list of form

{pstd}
{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}

{pstd}
and {it:list_spec} is a specification of the form

{pstd}
[{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ]

{pstd}
and {help list:{it:list_options}} is a list of options used by the {helpb list} command.


{title:Description}

{pstd}
These options are used by {helpb parmhet} to control the destination and content
of the output dataset (or resultsset) created.
This resultsset may be listed, saved to a file, or written to the memory,
replacing the existing input dataset.


{title:Options}

{p 4 8 2}
{cmd:list(} [{varlist}] {ifin} [ , [{help list:{it:list_options}} ] ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log and/or the Results window.
The {cmd:list()} option can be used with the {cmd:format()} option
to produce a list of heterogeneity-test statistics,
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {helpb if} or {helpb in} clauses to list subsets of parameters,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.

{p 4 8 2}
{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{p 4 8 2}
{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset. This option is automatically set if {cmd:fast} is
specified. Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {helpb parmhet}.

{p 4 8 2}
{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {help break:Break} during the execution of {helpb parmhet}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {helpb parmhet} will go to extra work so that
it can restore the original data if the user presses {help break:Break}.

{p 4 8 2}
{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a global macro, containing
a filename list (possibly empty).
If {cmd:saving()} is also specified,
then {helpb parmhet} will append the name of the dataset specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}.
This enables the user to build a list of filenames in a global macro,
containing the output of a sequence of datasets.
These files may later be concatenated using {helpb append}.

{p 4 8 2}
{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable, with default name {hi:idnum}, in the output dataset,
with that value for all observations.
This is useful if the output resultsset is concatenated with other resultssets
using {helpb append}.

{p 4 8 2}
{cmd:nidnum(}{help newvar:{it:newvarname}}{cmd:)} specifies a name for the numeric ID variable
evaluated by {cmd:idnum()}.
If {cmd:idnum()} is present and {cmd:nidnum()} is absent,
then the name of the numeric ID variable is set to {hi:idnum}.

{p 4 8 2}
{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable, with default name {hi:idstr}, in the output dataset,
with that value for all observations.
This is useful if the output resultsset is concatenated with other resultssets
using {helpb append}.

{p 4 8 2}
{cmd:nidstr(}{help newvar:{it:newvarname}}{cmd:)} specifies a name for the string ID variable
evaluated by {cmd:idstr()}.
If {cmd:idstr()} is present and {cmd:nidstr()} is absent,
then the name of the string ID variable is set to {hi:idstr}.

{p 4 8 2}
{cmd:sumvar(}{varlist}{cmd:)} specifies a list of variables in the input dataset
to be included in the output dataset, with values equal to their unweighted sums in the input dataset
(if {cmd:by()} is not specified) or to their unweighted sums within the by-group
(if {cmd:by()} is specified).
For instance, if the input dataset contains one observation
per study to be entered into a meta-analysis, and contains a variable {hi:N} specifying the number
of subjects in the study, then the user can specify {cmd:sumvar(N)}, and {hi:N} will be present
in the output dataset, where it will contain the total number of subjects in all the studies.

{p 4 8 2}
{cmd:format(}{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {help varlist:{it:varlist}s}.

{p 4 8 2}
{cmd:keep(}{it:varlist}{cmd:)} specifies a list of variables to be kept in the output dataset.
If {cmd:keep()} is not specified, then the output dataset contains all the variables
listed in the help for {help parmhet_resultsset:{it:parmhet_resultsset}}.
If the variables have been renamed
using the options described in {help parmhet_hettest_opts:{it:parmhet_hettest_opts}},
then the user must specify the new names in the {cmd:keep()} option.


{title:Notes}

{pstd}
Note that the user must specify at least one of the four options
{cmd:list()}, {cmd:saving()}, {cmd:norestore} and {cmd:fast}.
These four options specify whether the output dataset is listed to the Stata log,
saved to a disk file, or written to the memory (overwriting any pre-existing dataset).
More than one of these options can be specified.


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] meta}, {hi:[R] test}
{p_end}
{p 4 13 2}
On-line: help for {helpb parmhet}, {helpb parmiv},
{help parmhet_basic_opts:{it:parmhet_basic_opts}},
{help parmhet_hettest_opts:{it:parmhet_hettest_opts}},
{help parmhet_resultsset:{it:parmhet_resultsset}}
{break} help for {helpb test}
{break} help for {helpb parmest}, {helpb parmby}, {helpb parmcip}, {helpb metaparm}, {helpb metan} if installed
{p_end}
