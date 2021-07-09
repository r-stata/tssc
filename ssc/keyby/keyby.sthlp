{smcl}
{hline}
help for {cmd:keyby} and {cmd:keybygen}{right:(Roger Newson)}
{hline}

{title:Key the dataset by a variable list}

{p 8 21 2}
{cmd:keyby} {varlist} [ , {cmdab::no}{cmdab:o:rder} {opt m:issing} {opt fast:} ]

{p 8 21 2}
{cmd:keybygen} [ {varlist} ] , {opth g:enerate(newvarname)} [ {opt replace} {opt drop:constant} {cmdab::no}{cmdab:o:rder} {opt m:issing} {opt fast:} ]


{title:Description}

{pstd}
{cmd:keyby} sorts the dataset currently in memory by the variables in a {varlist},
checking that the variables in the {varlist} uniquely identify the observations.
This makes the variables in the {varlist} a primary key for the dataset in memory.
If the user does not specify otherwise,
then {cmd:keyby} also reorders the variables in the {varlist}
to the start of the variable order in the dataset,
and checks that all values of these variables are nonmissing.
{cmd:keybygen} sorts the dataset currently in memory by the variables in a {varlist},
preserving the existing order of observations within each by-group,
and then generates a new variable,
containing the sequential order of each observation within its by-group,
to form a primary key with the existing variables in the {varlist}.
{cmd:keyby} and {cmd:keybygen} can be useful if the user combines multiple datasets using {helpb merge},
which may cause a dataset in memory to become unsorted.


{title:Options for {cmd:keyby} and {cmd:keybygen}}

{phang}
{opt noorder} specifies that the variables in the {varlist}
(and the {cmd:generate()} variable created by {cmd:keyby})
are not reordered to the beginning of the variable order of the dataset in memory.
If {cmd:noorder} is not specified, then the variables in the {varlist}
(and the {cmd:generate()} variable created by {cmd:keyby})
are reordered to the beginning of the variable order (see {helpb order}).

{phang}
{opt missing} specifies that missing values in the variables in the {varlist} are allowed.
If {cmd:missing} is not specified,
then missing values in the variables in the {varlist} cause {cmd:keyby} or {cmd:keybygen} to fail.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:keyby} or {cmd:keybygen} will take no action
to restore the existing dataset in memory in the event of failure,
or if the user presses the {help break:Break} key..
If {cmd:fast} is not specified, then {cmd:keyby} will take this action,
which uses an amount of time depending on the size of the dataset in memory.


{title:Options for {cmd:keybygen} only}

{phang}
{opth generate(newvarname)} is required.
It specifies the name of a new variable to be generated,
containing, in each observation,
the sequential order of that observation within its by-group defined by the {varlist},
or the sequential order of that observation in the dataset, if the {varlist} is empty.
The new variable is appended to the {varlist} to form the new primary key,
by which the dataset is sorted,
and which uniquely identifies observations in the dataset.
Note that {cmd:keybygen}, unlike {cmd:keyby}, works with an empty {varlist}.
Also, note that the new variable specified by {cmd:generate()}
may not have the same name as any existing variable in the {varlist}.

{phang}
{opt replace} specifies that any existing variable with the name specified by the {cmd:generate()} option
will be replaced.
If {opt replace} is not specified, and an existing variable has the same name as the {cmd:generate()} option,
then {cmd:keybygen} will fail.

{phang}
{opt dropconstant} specifies that the generated new key variable will be dropped
if it has a constant value of 1.
In that case, the new variable is not really necessary,
because the key variables in the input {varlist} identify the observations uniquely,
without a new variable.


{title:Remarks}

{pstd}
{cmd:keyby} is a "clean" version of the {helpb sort} command without the {cmd:stable} option.
{cmd:keybygen} is a "clean" version of the {helpb sort} command with the {cmd:stable} option.
Either of them can be used to make a dataset conform to the relational database model,
under which a dataset is viewed as a mathematical function,
whose domain is the set of existing primary key value combinations,
and whose range is the set of all possible value combinations for variables outside the primary key.
If all datasets conform to the relational database model,
then the user can use the {helpb addinby} package,
which can also be downloaded from {help ssc:SSC},
to add variables from a disk dataset into the dataset in memory,
based on the values of a list of variables in the dataset in memory,
which is also the primary key of the dataset on disk.
The {helpb addinby} command is a "clean" version of the {helpb merge} command.


{title:Examples}

{p 8 12 2}{cmd:. keyby foreign make}{p_end}

{p 8 12 2}{cmd:. keyby foreign make, noorder}{p_end}

{p 8 12 2}{cmd:. keyby rep78 make, missing}{p_end}

{p 8 12 2}{cmd:. keybygen foreign, gene(modseq)}{p_end}

{p 8 12 2}{cmd:. keybygen foreign, gene(modseq) replace noorder}{p_end}

{p 8 12 2}{cmd:. keybygen, gene(obsseq)}{p_end}

{p 8 12 2}{cmd:. keybygen foreign make, gene(modseq) dropconstant}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] generate}, {hi:[D] sort}, {hi:[D] gsort}, {hi:[D] merge}, {hi: [D] order}, {hi:[D] drop}, {hi:[U] 12.2.1 Missing values}
{p_end}
{p 4 13 2}
On-line: help for {helpb generate}, {helpb sort}, {helpb gsort}, {helpb merge}, {helpb order}, {helpb drop}, {helpb missing}
{break}
help for {helpb addinby} if installed
{p_end}
