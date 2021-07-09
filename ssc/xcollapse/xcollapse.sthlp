{smcl}
{hline}
help for {hi:xcollapse}{right:(Roger Newson)}
{hline}

{title:Make dataset of means, medians, and other summary statistics.}

{p 8 17 2}{cmd:xcollapse} {it:clist} [{it:weight}] [{cmd:if} {it:exp}]
        [{cmd:in} {it:range}] [{cmd:,}
         {break}
         {cmdab:li:st}{cmd:(} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ , [{it:list_options}] ] {cmd:)}
         {break}
         {cmdab:fra:me}{cmd:(} {it:framename} [ , replace {cmdab:ch:ange} ] {cmd:)}
         {break}
         {cmdab:sa:ving}{cmd:(}{it:filename}[{cmd:,replace}]{cmd:)}
         {break}
         {cmdab::no}{cmdab:re:store} {cmd:fast}
	 {cmdab:fl:ist}{cmd:(}{it:global_macro_name}{cmd:)}
         {break}
         {cmd:cw}
         {cmd:by(}{it:varlist}{cmd:)}
         {cmdab:idn:um}{cmd:(}{it:#}{cmd:)} {cmdab:nidn:um}{cmd:(}{it:newvarname}{cmd:)}
         {cmdab:ids:tr}{cmd:(}{it:string}{cmd:)} {cmdab:nids:tr}{cmd:(}{it:newvarname}{cmd:)}
         {break}
         {cmdab:fo:rmat}{cmd:(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
         {break}
         {cmd:float}
        ]


{p 4 4 2}where {it:clist} is a list of statistics and variables,
defined as in the online help for {helpb collapse}.

{p 4 4 2}
{cmd:aweight}s, {cmd:fweight}s, {cmd:pweight}s, and {cmd:iweight}s are allowed.
See help for {helpb collapse} for details of how these are handled.


{title:Description}

{p 4 4 2}
{cmd:xcollapse} is an extended version of {helpb collapse}.
It creates an output dataset of means, sums, medians, and other summary statistics.
This output dataset may be listed to the Stata log, or saved to a {help frame:data frame},
or saved to a disk file,
or written to the memory (overwriting any pre-existing dataset).


{title:Options for use with {cmd:xcollapse}}

{p 4 4 2}
The options are listed in the following 2 groups:

{p 4 6 2}{bf:1.} Output-destination options.
(These specify where the output dataset will be written.){p_end}

{p 4 6 2}
{bf:2.} Other options. (These specify what the output dataset will contain.)


{title:Output-destination options}

{p 4 8 2}{cmd:list(}{it:varlist} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [, {it:list_options} ] {cmd:)}
specifies a list of variables in the output
dataset, which will be listed to the Stata log by {cmd:xcollapse}.
The {cmd:list()} option can be used with the {cmd:format()} option (see below)
to produce a list of summary statistics
with user-specified numbers of decimal places or significant figures.
The user may optionally also specify {helpb if} or {helpb in} qualifiers to list subsets of combinations
of variable values,
or change the display style using a list of {it:list_options} allowed as options by the {helpb list} command.

{p 4 8 2}{cmd:frame(} {it:name}, [ {cmd:replace} {cmd:change} ] {cmd:)} specifies an output {help frame:data frame},
to be generated to contain the output data set.
If {cmd:replace} is specified, then any existing data frame of the same name is overwritten. 
If {cmd:change} is specified,
then the current data frame will be changed to the output data frame after the execution of {cmd:xcollapse}.
The {cmd:frame()} option may not specify the current data frame.
To do this, use one of the options {cmd:norestore} or {cmd:fast}.

{p 4 8 2}{cmd:saving(}{it:filename}[{cmd:,replace}]{cmd:)} saves the output dataset to a disk file.
If {cmd:replace} is specified, and a file of that name already exists,
then the old file is overwritten.

{p 4 8 2}{cmd:norestore} specifies that the output dataset will be written to the memory,
overwriting any pre-existing dataset. This option is automatically set if {cmd:fast} is
specified. Otherwise, if {cmd:norestore} is not specified, then the pre-existing dataset is restored
in the memory after the execution of {cmd:xcollapse}.

{p 4 8 2}{cmd:fast} is a stronger version of {cmd:norestore}, intended for use by programmers.
It specifies that the pre-existing dataset in the memory will not be restored,
even if the user presses {helpb break:Break} during the execution of {cmd:xcollapse}.
If {cmd:norestore} is specified and {cmd:fast} is absent,
then {cmd:xcollapse} will go to extra work so that
it can restore the original data if the user presses {helpb break:Break}.

{p 4 8 2}Note that the user must specify at least one of the five options {cmd:list()}, {cmd:frame()}, {cmd:saving()},
{cmd:norestore} and {cmd:fast}. These five options specify whether the output dataset
is listed to the Stata log, saved to a data frame, saved to a disk file, or written to the memory
(overwriting any pre-existing dataset). More than one of these options can be specified.

{p 4 8 2}{cmd:flist(}{it:global_macro_name}{cmd:)} specifies the name of a global macro, containing
a filename list (possibly empty). If {cmd:saving()} is also specified, then
{cmd:xcollapse} will append the name of the dataset specified in the
{cmd:saving()} option to the value of the global macro specified in {cmd:flist()}. This
enables the user to build a list of filenames in a global macro, containing the
output of a sequence of output datasets.
These files may later be concatenated using {helpb append}, or using {helpb dsconcat}
(downloadable from {help ssc:SSC}) if installed.


{title:Other options}

{p 4 8 2}{cmd:cw} specifies casewise deletion.  If not specified, all
observations possible are used for each calculated statistic.

{p 4 8 2}{cmd:by(}{it:varlist}{cmd:)} specifies the groups over which the summary statistics
are to be calculated.  If not specified, the resulting dataset will
contain one observation.  If specified, {it:varlist} may refer to either
string or numeric variables.
Note that, if the {helpb if} expression or the {help weight} expression contains the
reserved names {hi:_n} and {hi:_N}, then these will be interpreted as the observation sequence number
and the number of observations, respectively, within the whole dataset, not within the by-group.

{p 4 8 2}{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable, with default name {hi:idnum}, in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:xcollapse} output datasets
using {helpb append}, or using {helpb dsconcat} if installed.

{p 4 8 2}{cmd:nidnum(}{it:newvarname}{cmd:)} specifies a name for the numeric ID variable
evaluated by {cmd:idnum()}. If {cmd:idnum()} is present and {cmd:nidnum()} is absent,
then the name of the numeric ID variable is set to {hi:idnum}.

{p 4 8 2}{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable, with default name {hi:idstr} in the output dataset,
with that value for all observations.
This is useful if the output dataset is concatenated with other {cmd:xcollapse} output datasets
using {helpb append}, or using {helpb dsconcat} if installed.

{p 4 8 2}{cmd:nidstr(}{it:newvarname}{cmd:)} specifies a name for the string ID variable
evaluated by {cmd:idstr()}. If {cmd:idstr()} is present and {cmd:nidstr()} is absent,
then the name of the string ID variable is set to {hi:idstr}.

{p 4 8 2}{cmd:format(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {it:varlist_i}
lists.
If the {cmd:format()} option is absent, then the percent variables have the format {hi:%8.2f},
the frequency variables have the format {hi:%12.0g},
and the other variables have the same formats as the variables of the same names
in the input dataset.

{p 4 8 2}{cmd:float}
specifies that numeric output variables in the output dataset,
specified by the {it:clist},
will not have {help datatypes:storage type} {cmd:double},
but will be recast to {help datatypes:storage type} {cmd:float},
even if this causes loss of precision.
Whether or not {cmd:float} is specified,
numeric output variables in the output dataset,
specified by the {it:clist},
will be {help compress:compressed} to the lowest {help datatypes:storage type} possible
without loss of precision.


{title:Examples}

{p 4 4 2}
The following examples use the {cmd:list()} option to list the output dataset to the Stata log.
After these examples are executed, there is no new dataset either in the memory or on disk.

{p 4 8 2}{cmd:. xcollapse mpg weight price, list(,)}

{p 4 8 2}{cmd:. xcollapse (median) mpg weight price, list(,)}

{p 4 8 2}{cmd:. xcollapse mpg weight price, by(foreign rep78) list(,clean)}

{p 4 8 2}{cmd:. xcollapse (mean) mpg weight price, by(foreign rep78) format(mpg weight price %8.2f) list(*, sepby(foreign))}

{p 4 8 2}{cmd:. xcollapse (count) nmpg=mpg nweight=weight nprice=price (median) medmpg=mpg medweight=weight medprice=price, by(foreign rep78) format(med* %8.2f) list(foreign rep78 *mpg *weight *price, sepby(foreign) abbrev(16))}

{p 4 4 2}
The following examples use the {cmd:norestore} option to create an output dataset in the memory,
overwriting any pre-existing dataset.

{p 4 8 2}{cmd:. xcollapse mpg weight price, norestore}

{p 4 8 2}{cmd:. xcollapse (median) mpg weight price, norestore}

{p 4 8 2}{cmd:. xcollapse mpg weight price, by(foreign rep78) norestore}

{p 4 8 2}{cmd:. xcollapse (mean) mpg weight price, by(foreign rep78) format(mpg weight price %8.2f) norestore}

{p 4 8 2}{cmd:. xcollapse (count) nmpg=mpg nweight=weight nprice=price (median) medmpg=mpg medweight=weight medprice=price, by(foreign rep78) format(med* %8.2f) norestore}

{p 4 4 2}
The following examples use the {cmd:saving()} option to create an output dataset in a disk file.

{p 4 8 2}{cmd:. xcollapse mpg weight price, saving(mysumm1)}

{p 4 8 2}{cmd:. xcollapse (median) mpg weight price, saving(mysumm2,replace)}

{p 4 8 2}{cmd:. xcollapse mpg weight price, by(foreign rep78) saving(mysumm3,replace)}

{p 4 8 2}{cmd:. xcollapse (mean) mpg weight price, by(foreign rep78) format(mpg weight price %8.2f) saving(mysumm4,replace)}

{p 4 8 2}{cmd:. xcollapse (count) nmpg=mpg nweight=weight nprice=price (median) medmpg=mpg medweight=weight medprice=price, by(foreign rep78) format(med* %8.2f) saving(mysumm5,replace)}

{p 4 4 2}
The following example uses the {cmd:frame()} option to create an output data frame {cmd:nutty} in memory.
This data frame is described, listed and dropped after changing the frame back to {cmd:default}.

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. xcollapse (count) N=mpg (mean) mpg, frame(nutty, replace change))}{p_end}
{p 4 8 2}{cmd:. describe, full}{p_end}
{p 4 8 2}{cmd:. list, abbr(32)}{p_end}
{p 4 8 2}{cmd:. frame change default}{p_end}
{p 4 8 2}{cmd:. frame drop nutty}{p_end}
{p 4 8 2}{cmd:. frame dir}{p_end}


{title:Author}

{p}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
Manual:  {hi:[R] collapse}, {hi:[R] contract}
{p_end}

{p 4 13 2}
Online:  help for {helpb collapse}, {helpb contract}, {helpb egen},
{helpb statsby}, {helpb summarize},
{helpb tabdisp}, {helpb table}
{break} help for {helpb xcontract}, {helpb dsconcat} if installed
{p_end}
