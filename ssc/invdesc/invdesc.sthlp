{smcl}
{hline}
help for {cmd:invdesc} and {cmd:sinvdesc} {right:(Roger Newson)}
{hline}


{title:Change variable attributes using a {helpb describe} or {helpb descsave} resultsset}

{p 8 15}
{cmd:invdesc} , {cmdab:dfr:ame}{cmd:(}{it:dframe_name}{cmd:)} [
{break}
{cmdab:lfr:ame}{cmd:(}{it:lframe_name} [ ,
{cmd:replace} {cmdab:la:bels}{cmd:(}{it:namelist}{cmd:)} ] {cmd:)}
{break}
{opth na:me(varname)}
{opth ty:pe(varname)}
{opth is:numeric(varname)}
{opth fo:rmat(varname)}
{opth val:lab(varname)}
{opth var:lab(varname)}
{opth dest:opts(varname)}
{opth tost:opts(varname)}
{opth ch:arvars(varlist)}
{break}
]


{p 8 15}
{cmd:sinvdesc} , [
{break}
{cmdab:lfr:ame}{cmd:(}{it:lframe_name} [ ,
{cmd:replace} {cmdab:la:bels}{cmd:(}{it:namelist}{cmd:)} ] {cmd:)}
{break}
{opth na:me(varname)}
{opth ty:pe(varname)}
{opth is:numeric(varname)}
{opth fo:rmat(varname)}
{opth val:lab(varname)}
{opth var:lab(varname)}
{opth dest:opts(varname)}
{opth tost:opts(varname)}
{opth ch:arvars(varlist)}
{break}
]

{pstd}
where {it:dframe_name} and {it:lframe_name} are {help frame:data frame names}.


{title:Description}

{pstd}
{cmd:invdesc} inputs a {help frame:data frame}
containing descriptive data in a {helpb describe} or {helpb descsave} output dataset 
or resultsset),
and (optionally) another (or the same)  {help frame:data frame},
containing  value labels.
It uses information in the variables in the descriptive resultsset
to change the attributes of variables in the dataset
in the current {help frame:data frame} in memory.
These attributes can be variable mode (string or numeric),
{help datatype:storage type}, {help format:format},
{help label:value label}, {help label:variable label},
or {help char:variable characteristics}.
The descriptive resultsset can be created using {helpb describe} or {helpb descsave},
or can be created manually using a spreadsheet (generic or proprietary),
and can contain extra variables and/or exclude variables usually present,
in which case the corresponding variable attributes are not modified.
{cmd:sinvdesc} is a version of {cmd:invdesc} which attempts to find the descriptives
in the current {help frame:data frame}.
The {helpb descsave} package can be downloaded from {help ssc:SSC}
using the {helpb ssc} command.


{title:Options for {cmd:invdesc} only}

{p 4 8 2}
{cmd:dframe(}{it:dframe_name}{cmd:)} must be present.
It specifies a {help frame:data frame},
containing a dataset with 1 observation for each of a list of variables,
and data on variable attributes such as mode (string or numeric),
{help datatype:storage type}, {help format:format},
{help label:value label}, {help label:variable label},
or {help char:variable characteristics}.


{title:Options for {cmd:invdesc} and {cmd:sinvdesc}}

{p 4 8 2}
{cmd:lframe(}{it:lframe_name}[ ,
{cmd:replace} {cmd:labels}{cmd:(}{it:namelist}{cmd:)} ] {cmd:)}
specifies a {help frame:data frame}
containing value labels,
which will be copied from there to the current frame
for use in labelling the values of variables there.
The frame may or may not be the same frame specified by the {cmd:dframe()} option.
The {cmd:replace} suboption specifies that value labels of the same names in the current frame
will be replaced (instead of being modified).
The {cmd:labels()} suboption specifies a subset of the value labels in the label frame
to be copied to the current frame.
Note that a dataset in a data frame may contain value labels only,
and have no variables or observations.

{p 4 8 2}
{opth name(varname)}, {opth type(varname)}, {opth isnumeric(varname)}, {opth format(varname)},
{opth vallab(varname)} and {opth varlab(varname)} specify alternative names for the variables
in the input data frame containing the attributes to be changed.
In default, these variables in the input data frame
are assumed to have the same names as the corresponding options,
and to contain the same informaton as the variables of the same names
in the output datasets (or resultssets) created by {helpb describe} or {helpb descsave}.

{p 4 8 2}
{opth destopts(varname)} and {opth tostopts(varname)}
specify the names of variables in the descriptive dataset,
containing lists of options (other than {cmd:generate} and {cmd:replace})
for {helpb destring} and {helpb tostring}, respectively.
If the {cmd:isnumeric()} variable in the descriptive dataset
is 1 (specifying a numeric variable)
and the corresponding variable in the current dataset
specified by the {cmd:name()} variable in the descriptive dataset
is string,
then {cmd:invdesc} uses {helpb destring} to convert the string variable to numeric,
using the {cmd:destopts()} variable (if present) to specify {helpb destring} options.
If the {cmd:isnumeric()} variable in the descriptive dataset
is 0 (specifying a string variable)
and the corresponding variable in the current dataset
specified by the {cmd:name()} variable in the descriptive dataset
is numeric,
then {cmd:invdesc} uses {helpb tostring} to convert the string variable to numeric,
using the {cmd:tostopts()} variable (if present) to specify {helpb tostring} options.
If the {cmd:destopts()} or {cmd:tostopts()} option is absent,
then {cmd:invdesc} looks for a variable with the same name as the option.

{p 4 8 2}
{opth charlist(varlist)} specifies a list of variables
in the {cmd:dframe()} data frame,
assumed to contain {help char:variable characteristics}
for the variables in the current data frame.
Such variables are created in {helpb descsave} resultssets,
using the {cmd:char()} option of {helpb descsave}.
The characteristics specified by these variables
are identified using the {cmd:charname} characteristic of each variable (if present),
or assumed to be the same as the variable names otherwise.


{title:Variables in the descriptive input dataset specified by {cmd:dframe()}}

{pstd}
The descriptive input dataset specified by {cmd:dframe()}
has one observation for each of a list of variables,
which may be present in the current data frame.
In default, it may contain the following variables:

{p2colset 4 20 22 2}{...}
{p2col:Default name}Description{p_end}
{p2line}
{p2col:{cmd:name}}Variable name{p_end}
{p2col:{cmd:type}}Storage type{p_end}
{p2col:{cmd:isnumeric}}Numeric indicator{p_end}
{p2col:{cmd:format}}Display format{p_end}
{p2col:{cmd:vallab}}Value label{p_end}
{p2col:{cmd:varlab}}Variable label{p_end}
{p2col:{cmd:destopts}}{helpb destring} options{p_end}
{p2col:{cmd:tostopts}}{helpb tostring} options{p_end}
{p2col:{it:charvars_list}}Variable characteristics{p_end}
{p2line}
{p2colreset}

{pstd}
The variable {cmd:name} contains the name of a variable, which may be present in the current data frame.
The variable {cmd:isnumeric} is 1 if the variable is to be numeric and 0 if the variable is to be non-numeric.
Variable mode is enforced using {helpb tostring} or {helpb destring},
and it may be necessary to set the {cmd:tostopts()} or {cmd:destopts()} variable to contain {cmd:force}.
The variables in the {it:charvars_list} are string variables containing variable characteristics
for the variable specified in the {cmd:name} variable.
The name of the characteristic specified is given by the {cmd:charname} characteristic of the {it:charlist_variable}
(if the {cmd:charname} characteristic exists),
or is assumed to be the same as the name of the characteristic variable otherwise.
To use a variable of a different name for each function,
use the {cmd:invdesc} option of the same name.

{pstd}
The descriptive dataset does not need to contain all the variables listed above,
although the {cmd:name()} variable must be present.
Variable attributes specified by absent variables are not modified.
The descriptive dataset may also contain additional variables,
especially if it is created manually iin a spreadsheet (generic or proprietary),
instead of being output by {helpb describe} or {helpb descsave}.


{title:Remarks}

{pstd}
{cmd:invdesc} is designed to supersede the {cmd:dofile()} option of {helpb descsave},
whch can also be used to modify data attributes, using a generated do-file.
Using {cmd:invdesc} has the advantage that variable and value labels,
and variable characteristics,
can contain strings that cannot be surrounded by simple or compound quotes,
such as strings containing an unpaired right compound quote.
Another advantage is that {cmd:invdesc} can input descriptive datasets
created manually using generic or proprietary spreadsheets,
and then imported into a Stata data frame,
using {helpb import delimited} or {helpb import excel}.

{pstd}
The {cmd:sinvdesc} module is intended for use mostly in meta-metadatasets,
which contain descriptives for descriptive variables,
such as those in {helpb describe} or {helpb descsave} resultssets.
It is useful if the user creates {helpb describe} or {helpb descsave} resultssets
manually in a spreadsheet,
and wants to convert the spreadsheet to a Stata dataset,
complete with variable attributes.


{title:Examples}

{pstd}
The following example assumes the presence of 3 generic tab-delimited spreadsheets
in the current folder, distributed with the {cmd:invdesc} package.
These are
{cmd:descriptive.txt} containing the descriptives (with 1 row per variable per dataset),
{cmd:valuelabelstxt} containing value labels (with 1 row per label per value),
and {cmd:xauto.txt} containing a modified version of the {help sysuse:auto} dataset
(with 1 observation per car model).
The example uses {cmd:invdesc} and {cmd:sinvdesc} together with the {helpb vallabdef} package,
which can be downloaded from {help ssc:SSC}.

{pstd}
Create descriptive dataset in data frame {cmd:desframe} using {cmd:sinvdesc}:

{p 16 20}{inp:. frame create desframe}{p_end}
{p 16 20}{inp:. frame desframe {c -(}}{p_end}
{p 16 20}{inp:. import delimited using descriptive.txt, delim(tab) varnames(1) clear stringcols(_all)}{p_end}
{p 16 20}{inp:. sinvdesc}{p_end}
{p 16 20}{inp:. describe, full}{p_end}
{p 16 20}{inp:. list, abbr(32)}{p_end}
{p 16 20}{inp:. {c )-}}{p_end}

{pstd}
Create value labels dataset in data frame {cmd:labframe}using {cmd:invdesc} and {helpb vallabdef}:

{p 16 20}{inp:. frame create labframe}{p_end}
{p 16 20}{inp:. frame labframe {c -(}}{p_end}
{p 16 20}{inp:. import delimited using valuelabels.txt, delim(tab) varnames(1) clear stringc(_all)}{p_end}
{p 16 20}{inp:. invdesc,  dfr(desframe)}{p_end}
{p 16 20}{inp:. describe, full}{p_end}
{p 16 20}{inp:. list, abbr(32) sepby(labname)}{p_end}
{p 16 20}{inp:. vallabdef labname value label}{p_end}
{p 16 20}{inp:. label list}{p_end}
{p 16 20}{inp:. {c )-}}{p_end}

{pstd}
Create extended auto dataset in current frame:

{p 16 20}{inp:. import delimited using xauto.txt, delim(tab) varnames(1) clear stringcols(_all)}{p_end}
{p 16 20}{inp:. invdesc, dfr(desframe) lfr(labframe, replace) charvars(_fv_*)}{p_end}

{pstd}
Check extended auto dataset:

{p 16 20}{inp:. describe, full}{p_end}
{p 16 20}{inp:. char list}{p_end}
{p 16 20}{inp:. label dir}{p_end}
{p 16 20}{inp:. label list}{p_end}
{p 16 20}{inp:. tab foreign, m}{p_end}
{p 16 20}{inp:. tab odd, m}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {manhelp char D}, {manhelp describe D}, {manhelp destring D}, {manhelp tostring D},
{manhelp import D}, {manhelp label D}
{p_end}
{p 4 13 2}
On-line: help for {helpb char}, {helpb describe}, {helpb destring}, {helpb  tostring},
{helpb import delimited}, {helpb import excel}, {helpb label}
 {break} help for {helpb descsaave}, {helpb vallabdef} if installed
{p_end}
