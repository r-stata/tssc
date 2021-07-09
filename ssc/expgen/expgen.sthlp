{smcl}
{hline}
help for {cmd:expgen}{right:(Roger Newson)}
{hline}

{title:Duplicate observations sorted in original order with generated variables}

{p 8 21 2}
{cmd:expgen} {help newvar:{it:newvarname1}} {cmd:=} {it:ncexp} {ifin} [ {cmd:,} 
{cmdab:o:ldseq}{cmd:(}{help newvar:{it:newvarname2}}{cmd:)}
{cmdab:c:opyseq}{cmd:(}{help newvar:{it:newvarname3}}{cmd:)}
{cmdab:s:ortedby}{cmd:(}{it:sortedby_interpretation}{cmd:)}
{cmdab:or:der}
{cmdab:m:issing} {cmdab:z:ero}
{cmd:fast}
]

{pstd}
where {it:sortedby_interpretation} is one of

{pstd}
{cmdab:i:gnore} | {cmdab:g:roup} | {cmdab:u:nique}

{pstd}
or any abbreviation of any of these.


{title:Description}

{pstd}
{cmd:expgen} is an extended version of {helpb expand}.
It replaces each observation in the
current dataset with {it:nc} copies of the observation, sorted in the original order,
where {it:nc} is equal to the integer part {cmd:int(}{it:ncexp}{cmd:)} of the required expression {it:ncexp}.
{cmd:expgen} may also add new variables.
These are {help newvar:{it:newvarname1}} (containing the value of the expression {it:ncexp}),
{help newvar:{it:newvarname2}} (containing the sequential order of the original observation in the old dataset),
and {help newvar:{it:newvarname3}} (containing the sequential order of each copy in the set of copies
generated from its original observation).
If {cmd:missing} and/or {cmd:zero} is specified,
then observations in the old dataset with missing and/or non-positive values
for {cmd:int(}{it:ncexp}{cmd:)} are each replaced by one observation in the new dataset.


{title:Options for use with {cmd:expgen}}

{phang}
{cmd:oldseq(}{help newvar:{it:newvarname2}}{cmd:)} specifies a new variable to be generated, containing the sequential
order of the observation in the old dataset from which the current
observation was copied, as defined in the old dataset.
This old sequential order is defined after the exclusion from the old dataset of observations
not satisfying the {helpb if} and {helpb in} requirements, and after the exclusion of
observations with missing values of {it:ncexp} (if {cmd:missing} was not specified)
and of observations with non-positive values of {cmd:int(}{it:ncexp}{cmd:)}
(if {cmd:zero} was not specified).
(See {cmd:missing} and {cmd:zero} below.)

{phang}
{cmd:copyseq(}{help newvar:{it:newvarname3}}{cmd:)} specifies a new variable to be generated, containing the sequential
order of the copied observation in the new dataset, in the set of
observations copied from the same original observation in the old dataset.
If an observation in the old dataset has a value {cmd:int(}{it:ncexp}{cmd:)} equal to {it:k},
then the {it:k} duplicates of that observation in the new dataset have values
of the {cmd:copyseq()} variable in ascending order from 1 to {it:k}.

{phang}
{cmd:sortedby(}{it:sortedby_interpretation}{cmd:)} specifies the interpretation given to the {varlist}
by which the input dataset is sorted,
given as output by the {help macro:extended macro function} {cmd:sortedby}.
This option is used to specify the {varlist} by which the output dataset will be sorted.
If {cmd:sortedby(ignore)} is specified,
then the {varlist} by which the input dataset is sorted is ignored,
and the output dataset is sorted primarily by the {cmd:oldseq()} variable (if specified),
and secondarily by the {cmd:copyseq()} variable (if specified).
If {cmd:sortedby(group)} is specified,
then the {varlist} by which the input dataset is sorted is assumed to be a group identifier,
possibly with multiple observations with the same combination of values,
and the output dataset is sorted primarily by these variables,
and secondly by the {cmd:oldseq()} variable (if specified),
and thirdly by the {cmd:copyseq()} variable (if specified).
If {cmd:sortedby(unique)} is specified,
then the {varlist} by which the input dataset is sorted is assumed to be a unique observation identifier,
with no more than one observation with the same combination of values
in the subset of observations specified by the {helpb in} and {helpb if} qualifiers,
and the output dataset is sorted primarily by these variables,
and secondly by the {cmd:copyseq()} variable (if specified).
If the user specifies {cmd:sortedby(unique)}
and the dataset is in fact not sorted,
or is in fact sorted by variables which do not uniquely identify the observations,
then {cmd:expgen} fails with an error message.
If the user does not specify a {cmd:sortedby()} option,
then {cmd:sortedby(ignore)} is assumed.
Note that, whichever {cmd:sortedby()} option is specified,
the order of the observations in the output dataset will be the same,
and will be primarily the order of the observations in the input dataset from which the copies were made,
and secondarily by the {cmd:copyseq()} variable (if specified).
The {cmd:sortedby()} option only affects the list of variables recognized by Stata
as defining the sorting order,
as reported by {helpb describe}.

{phang}
{cmd:order} specifies that the variables by which the output dataset is sorted
will be reordered to the start of the {help order:variable order}.
These variables are as specified by the {cmd:sortedby()} option.
If {cmd:order} is specified,
then they will be the first variables in the output dataset listed by {helpb describe}.

{phang}
{cmd:missing} specifies that observations in the old dataset with missing values of
{it:ncexp} are each to be replaced in the new dataset with a single observation.
If {cmd:missing} is absent, then such old observations are deleted from the new dataset.

{phang}
{cmd:zero} specifies that observations in the old dataset with non-positive values
of {cmd:int(}{it:ncexp}{cmd:)} are each to be replaced in the new dataset with a single observation.
If {cmd:zero} is absent, then such old observations are deleted from the new dataset.

{phang}
{cmd:fast} is an option for programmers.
It specifies that {cmd:expgen} will take no action to restore the original dataset
if {cmd:expgen} fails, or if the user presses {help break:Break}.


{title:Remarks}

{pstd}
{cmd:expgen} is designed as an improved version of {helpb expand}.
Unlike {helpb expand}, it returns duplicate observations sorted in the original order of the
corresponding observations in the old dataset, from which they were copied.
There is also the option of adding new variables to the duplicate observations.
{cmd:expgen} was designed for use, in a medical setting, in the case when the
original dataset is from a spreadsheet with one row per patient, and with
multiple columns containing multiple repeated measurements on the same patient
at different times and/or on different parts of the same patient's body.
We might want to expand this dataset to a new dataset with 1 observation per
repeated measurement, and then perform a repeated measures analysis.
The {cmd:copyseq()} variable can be used to generate a new variable in this new dataset,
containing the repeated measures.
The new variable might have values each copied from one of a list of variables in the original dataset,
depending on the value of the {cmd:copyseq()} variable.
(See Examples.
In SAS, this kind of duplication is done using a SAS data step
containing a SAS {cmd:OUTPUT} statement inside a SAS {cmd:DO}-loop,
iterating over a list of variables defined as a SAS array.)

{pstd}
{cmd:expgen} can be used with the {helpb keyby} package, downloadable from {help ssc:SSC},
to enforce the relational database model in Stata.
In the relational database model, a dataset is viewed as a mathematical function,
whose domain is the set of all available value combinations of a list of key variables,
and whose range is the set of all possible value combinations of the non-key variables.
If a dataset is keyed using {helpb keyby},
and is then expanded using {cmd:expgen},
specifying the {cmd:copyseq()} option and {cmd:sortedby(unique)},
then the expanded dataset generated by {cmd:expgen}
will automatically be a relational dataset,
keyed primarily by the original key variables specified by {helpb keyby},
and secondly by the {cmd:copyseq()} variable.
And, if the user also specifies the {cmd:order} option with {cmd:expgen},
then the key variables will be the first in the order of variables in the output dataset.


{title:Examples}

{p 8 12 2}{cmd:. expgen nreps=rep78, old(modseq) copy(repseq) miss zero}{p_end}

{p 8 12 2}{cmd:. sysuse auto, clear}{p_end}
{p 8 12 2}{cmd:. sort foreign make}{p_end}
{p 8 12 2}{cmd:. expgen nreps=rep78, copy(repseq) sortedby(unique) order}{p_end}
{p 8 12 2}{cmd:. describe}{p_end}

{pstd}
The following example uses the {help sysuse:census} dataset, and expands it from a dataset
of US states to a dataset of combinations of US state and age group:

{p 8 12 2}{cmd:. sysuse census, clear}{p_end}
{p 8 12 2}{cmd:. expgen =4, copy(agegp)}{p_end}
{p 8 12 2}{cmd:. lab def agegp 1 "0-4" 2 "5-17" 3 "18-64" 4 "65+"}{p_end}
{p 8 12 2}{cmd:. lab val agegp agegp}{p_end}
{p 8 12 2}{cmd:. gene popul = (agegp==1)*poplt5 + (agegp==2)*pop5_17 + (agegp==3)*(pop18p-pop65p) + (agegp==4)*pop65p}{p_end}
{p 8 12 2}{cmd:. drop pop poplt5 pop5_17 pop18p pop65p}{p_end}
{p 8 12 2}{cmd:. desc}{p_end}
{p 8 12 2}{cmd:. list state agegp popul}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] expand}, {hi:[D] expandcl}, {hi:[D] joinby}, {hi:[D] contract}, {hi:[D] collapse}, {hi:[D] reshape},
{hi:[D] order}, {hi:[D] describe}
{p_end}
{p 4 13 2}
On-line: help for {helpb expand}, {helpb expandcl}, {helpb joinby}, {helpb contract}, {helpb collapse}, {helpb reshape}, {helpb order}, {helpb describe}{break}
         help for {helpb keyby}, {helpb expandby} if installed
{p_end}
