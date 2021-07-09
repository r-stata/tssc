{smcl}
{hline}
help for {hi:lastupto}{right:(Roger Newson)}
{hline}

{title:Condense a dataset to have 1 observation for each of a list of {it:X}-values.}

{p 8 17 2}{cmd:lastupto} {it:xvarname} [{cmd:if} {it:exp}]
        [{cmd:in} {it:range}] [{cmd:,}
         {break}
         {cmdab:xv:alues}{cmd:(}{it:numlist}{cmd:} {cmd:by(}{varlist}{cmd:)}
         {break}
         {cmdab:li:st}{cmd:(} [{varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ , [{it:list_options}] ] {cmd:)}
         {break}
         {cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}
         {break}
         {cmdab::no}{cmdab:re:store} {cmd:fast}
	 {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
         {break}
         {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:nidn:um}{cmd:(}{it:newvarname}{cmd:)}
         {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)} {cmdab:nids:tr}{cmd:(}{it:newvarname}{cmd:)}
         {break}
         {cmdab:fo:rmat}{cmd:(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
         {break}
         {cmdab::no}{cmdab:o:rder} {cmdab:ke:ep}{cmd:(}{varlist}{cmd:)}
        ]


{title:Description}

{pstd}
{cmd:lastupto} inputs a dataset in memory with an {it:X}-variable, a list of {it:X}-values,
and (optionally) a list of by-variables.
It creates an output dataset (or resultsset},
with 1 observation per provided {it:X}-value in the list
(or per {it:X}-value per by-group),
and data on the variable values in the last observation in the dataset (or by-group)
with an {it:X}-value up to and including the provided {it:X}-value,
when the observations have been sorted by by-group, then by their {it:X}-values,
and then by their pre-existing order.
{cmd:lastupto} is very useful for condensing Kaplan-Meier curves in big datasets.
{cmd:lastupto} uses the {help ssc:SSC} package {helpb expgen},
which must be installed if {cmd:lastupto} is to work.


{title:Options for use with {cmd:lastupto}}

{p 4 4 2}
The options are listed in the following 3 groups:

{p 4 6 2}{bf:1.} Basic options.
(These specify the {it:X}-values and by-groups.)

{p 4 6 2}{bf:2.} Output-destination options.
(These specify where the output dataset will be written.){p_end}

{p 4 6 2}{bf:3.} Output-modifying options.
(These specify additional variables for the output dataset,
or modifications to variables.)


{title:Basic options}

{p 4 8 2}{cmd:xvalues(}{it:numlist}{cmd:)} specifies a list of numeric input {it:X}-values.
The output dataset will have 1 observation per input {it:X}-value
(or per {it:X}-value per by-group if a {cmd:by()} option is specified),
and data on the values of non-{it:X}-variables variables in the last observation in the input dataset
with an {it:X}-value up to or including the input {it:X}-value.

{p 4 8 2}{cmd:by(}{it:varlist}{cmd:)} specifies the by-groups present in the input dataset.
If a {cmd:by()} option is absent, then the output dataset will have 1 observation per input {it:X}-value.
If a {cmd:by()} option is present,
then the output dataset will have 1 observation per input {it:X}-value per by-group.


{title:Output-destination options}

{p 4 8 2}{cmd:list(}{it:varlist} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [, {it:list_options} ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log by {cmd:lastupto}.
The {cmd:list()} option can be used with the {cmd:format()} option (see below)
to produce a list of summary statistics
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {helpb if} or {helpb in} qualifiers to list subsets of combinations
of variable values,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.

{p 4 8 2}{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{p 4 8 2}{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset. This option is automatically set if {cmd:fast} is
specified. Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {cmd:lastupto}.

{p 4 8 2}{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {helpb break:Break} during the execution of {cmd:lastupto}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {cmd:lastupto} will go to extra work so that
it can restore the original data if the user presses {helpb break:Break}.

{p 4 8 2}Note that the user must specify at least one of the four options {cmd:list()}, {cmd:saving()},
{cmd:norestore} and {cmd:fast}. These four options specify whether the output dataset
is listed to the Stata log, saved to a disk file, or written to the memory
(overwriting any pre-existing dataset). More than one of these options can be specified.

{p 4 8 2}{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a global macro, containing
a filename list (possibly empty). If {cmd:saving()} is also specified, then
{cmd:lastupto} will append the name of the dataset specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}. This
enables the user to build a list of filenames in a global macro, containing the
output of a sequence of output datasets.
These files may later be concatenated using {helpb append}.


{title:Output-modifying options}

{p 4 8 2}{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable, with default name {hi:idnum}, in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:lastupto} output datasets
using {helpb append}, or using {helpb dsconcat} if installed.

{p 4 8 2}{cmd:nidnum(}{it:newvarname}{cmd:)} specifies a name for the numeric ID variable
evaluated by {cmd:idnum()}. If {cmd:idnum()} is present and {cmd:nidnum()} is absent,
then the name of the numeric ID variable is set to {hi:idnum}.

{p 4 8 2}{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable, with default name {hi:idstr} in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:lastupto} output datasets
using {helpb append}, or using {helpb dsconcat} if installed.

{p 4 8 2}{cmd:nidstr(}{it:newvarname}{cmd:)} specifies a name for the string ID variable
evaluated by {cmd:idstr()}. If {cmd:idstr()} is present and {cmd:nidstr()} is absent,
then the name of the string ID variable is set to {hi:idstr}.

{p 4 8 2}{cmd:format(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {it:varlist_i}
lists.

{p 4 8 2}
{cmd:noorder} specifies that the {cmd:by()} variables and the {it:X}-variable
are not reordered to the beginning of the variable order of the output dataset.
If {cmd:noorder} is not specified,
then the {cmd:by()} variables and the {it:X}-variable
are reordered to the beginning of the variable order (see {helpb order}).

{p 4 8 2}
{cmd:keep(}{it:varlist}{cmd:)} specifies a list of variables to be kept in the output dataset.


{title:Remarks}

{pstd}
{cmd:lastupto} is designed to condense a large dataset
to a dataset small enough to be plotted and/or tabulated.
It is designed for use when a large dataset contains one or more variables
that are defined as a right-continuous function of the {it:X}-variable.
This will be the case if the {it:X}-variable is a survival time
and other variables include a Kaplan-Meier survival probability,
or if the {it:X}-variable is a test score
and the other variables include a sensitivity and/or a specificity.
In these cases, the user might want a dataset with 1 observation for each of a list of {it:X}-values,
or with 1 observation per listed {it:X}-value per by-group,
and data on sensitivities and/or specificities and/or survival probabilities
and/or their confidence limits.
Such a condensed dataset might be used to produce files contining plots and/or tables
of a manageable size.

{pstd}
{cmd:lastupto} can be very useful for condensing Kaplan-Meier curves in big datasets,
which may have millions of observations,
each with its survival probability and confidence limits,
and therefore the potential to generate gigabyte-sized graphics files
if the dataset is not first condensed to a smaller size with a smaller list of {it:X}-values.

{pstd}
To find out more about output-destination and output-modifying options
for resultsset-generating programs,
see the online help for other resultsset-generating packages,
such as the {help ssc:SSC} packages
{helpb xcollapse}, {helpb xcontract}, {helpb descsave} and {helpb parmest}.


{title:Examples}

{pstd}
Set-up:

{p 4 8 2}{cmd:. webuse stan3, clear}{p_end}
{p 4 8 2}{cmd:. describe, full}{p_end}
{p 4 8 2}{cmd:. st}{p_end}
{p 4 8 2}{cmd:. tab posttran, miss}{p_end}

{pstd}
Generate and list survival curves with confidence limits for whole dataset:

{p 4 8 2}{cmd:. sts gene surv=s lbsurv=lb(s) ubsurv=ub(s)}{p_end}
{p 4 8 2}{cmd:. describe *surv, full}{p_end}
{p 4 8 2}{cmd:. lastupto _t, xval(0(50)1000) list(, abbr(32))}{p_end}
{p 4 8 2}{cmd:. lastupto _t, xval(0(100)1000) keep(_t surv lbsurv ubsurv) list(, abbr(32))}{p_end}

{pstd}
Generate and plot survival curves for by-groups
(using the {help ssc:SSC} command {helpb eclplot} to create confidence-interval plots):

{p 4 8 2}{cmd:. sts gene surv2=s lbsurv2=lb(s) ubsurv2=ub(s)}{p_end}
{p 4 8 2}{cmd:. describe *surv2, full}{p_end}
{p 4 8 2}{cmd:. preserve}{p_end}
{p 4 8 2}{cmd:. lastupto _t, xval(0(50)1000) by(posttran) keep(posttran _t surv2 lbsurv2 ubsurv2) norestore}{p_end}
{p 4 8 2}{cmd:. foreach Y of var surv2 ubsurv2 lbsurv2 {c -(}}{p_end}
{p 4 8 2}{cmd:. replace `Y'=1 if _t==0}{p_end}
{p 4 8 2}{cmd:. {c )-}}{p_end}
{p 4 8 2}{cmd:. list, abbr(32) sepby(posttran)}{p_end}
{p 4 8 2}{cmd:. eclplot surv2 lbsurv2 ubsurv2 _t, eplot(connected) rplot(rspike) estopts(connect(stairstep)) by(posttran)}{p_end}
{p 4 8 2}{cmd:. restore}{p_end}

{pstd}
Note that we reassign the missing survival probability,
and its missing confidence limits, at {cmd:_t==0}
to a sensible value of 1 for plotting purposes.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual:  {hi:[ST] sts generate}
{p_end}

{p 4 13 2}
Online:  help for {helpb sts generate}
{break} help for {helpb expgen}, {helpb eclplot},
{helpb xcollapse}, {helpb xcontract}, {helpb descsave}, {helpb parmest}  if installed
{p_end}
