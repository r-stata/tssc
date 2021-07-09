{smcl}
{* *! version 2.0.1 Matthew White 09mar2015}{...}
{title:Title}

{phang}
{cmd:readreplace} {hline 2}
Make replacements that are specified in an external dataset


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:readreplace using} {it:{help filename}}{cmd:,}
{opth id(varlist)} {opth var:iable(varname)} {opth val:ue(varname)}
[{it:options}]

{* Using -help odbc- as a template.}{...}
{* 20 is the position of the last character in the first column + 3.}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth id(varlist)}}variables for matching observations with
the replacements specified in the using dataset{p_end}
{p2coldent:* {opth var:iable(varname)}}variable in the using dataset that
indicates the variables to replace{p_end}
{p2coldent:* {opth val:ue(varname)}}variable in the using dataset that
stores the new values{p_end}

{syntab:Import}
{synopt:{opt insheet}}use {helpb insheet} to import {it:filename};
the default{p_end}
{synopt:{opt u:se}}use {helpb use} to load {it:filename}{p_end}
{synopt:{opt exc:el}}use {helpb import excel} to import {it:filename}{p_end}
{synopt:{opt import(options)}}options to specify to the import command{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt id()}, {opt variable()}, and {opt value()} are required.


{title:Description}

{pstd}
{cmd:readreplace} modifies the dataset currently in memory by
making replacements that are specified in an external dataset,
the replacements file.

{pstd}
The list of differences saved by the SSC program {helpb cfout} is designed for
later use by {cmd:readreplace}. After the addition of a new variable to
the {cmd:cfout} differences file that holds the new (correct) values,
the file can be used as the {cmd:readreplace} replacements file.


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:readreplace} changes the contents of existing variables by
making replacements that are specified in a separate dataset,
the replacements file. The replacements file should be long by
replacement such that each observation is a replacement to complete.
Replacements are described by a variable that contains
the name of the variable to change, specified to option {opt variable()},
and a variable that stores the new value for the variable,
specified to option {opt value()}. The replacements file should also hold
variables shared by the dataset in memory that indicate
the subset of the data for which each change is intended;
these are specified to option {opt id()}, and are used to match
observations in memory to their replacements in the replacements file.

{pstd}
Below, an example replacements file is shown with three variables:
{cmd:uniqueid}, to be specified to {opt id()},
{cmd:Question}, to be specified to {opt variable()},
and {cmd:CorrectValue}, to be specified to {opt value()}.

{cmd}{...}
    {c TLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c TRC}
    {c |} uniqueid     Question   CorrectValue {c |}
    {c LT}{hline 10}{c -}{hline 12}{c -}{hline 14}{c RT}
    {c |}      105     district             13 {c |}
    {c |}      125          age              2 {c |}
    {c |}      138       gender              1 {c |}
    {c |}      199     district             34 {c |}
    {c |}        2   am_failure              3 {c |}
    {c BLC}{hline 10}{c -}{hline 12}{c -}{hline 14}{c BRC}
{txt}{...}

{pstd}
For each observation of the replacements file,
{cmd:readreplace} essentially runs the following {helpb replace} command:

{phang}
{cmd:replace} {it:Question_value} {cmd:=} {it:CorrectValue_value}
{cmd:if uniqueid ==} {it:uniqueid_value}

{pstd}
That is, the effect of {cmd:readreplace} here is the same as
these five {cmd:replace} commands:

{cmd}{...}
{phang}replace district{space 3}= 13 if uniqueid == 105{p_end}
{phang}replace age{space 8}= 2{space 2}if uniqueid == 125{p_end}
{phang}replace gender{space 5}= 1{space 2}if uniqueid == 138{p_end}
{phang}replace district{space 3}= 34 if uniqueid == 199{p_end}
{phang}replace am_failure = 3{space 2}if uniqueid == 2{p_end}
{txt}{...}

{pstd}
The variable specified to {opt value()} may be numeric or string;
either is accepted.

{pstd}
The replacements file may be one of the following formats:

{* Using -help anova- as a template.}{...}
{phang2}o  {it:Comma-separated data.} This is the default format,
but you may specify option {cmd:insheet}; either way, {cmd:readreplace} will use
{cmd:insheet} to import the replacements file. You can also specify
any options for {helpb insheet} to option {opt import()}.{p_end}
{phang2}o  {it:Stata dataset.} Specify option {cmd:use} to {cmd:readreplace},
passing any options for {helpb use} to {opt import()}.{p_end}
{phang2}o  {it:Excel file.} Specify option {cmd:excel} to {cmd:readreplace},
passing any options for {helpb import excel} to {opt import()}.{p_end}

{pstd}
{cmd:readreplace} may be employed for a variety of purposes,
but it was designed to be used as part of a data entry process in which
data is entered two times for accuracy.
After the second entry, the two separate entry datasets need to be reconciled.
{helpb cfout} can compare the first and second entries,
saving the list of differences in a format that is useful for data entry teams.
Data entry operators can then add a new variable to the differences file for
the correct value.
Once this variable has been entered, load either of the two entry datasets,
then run {cmd:readreplace} with the new replacements file.

{pstd}
The GitHub repository for {cmd:readreplace} is
{browse "https://github.com/PovertyAction/readreplace":here}.
Previous versions may be found there: see the tags.


{marker remarks_promoting}{...}
{title:Remarks for promoting storage types}

{pstd}
{cmd:readreplace} will change variables' {help data types:storage types} in
much the same way as {helpb replace},
promoting storage types according to these rules:

{* Using -help 663- as a template.}{...}
{phang2}1.  Storage types are only promoted;
they are never {help compress:compressed}.{p_end}
{phang2}2.  The storage type of {cmd:float} variables is never changed.{p_end}
{phang2}3.  If a variable of
integer type ({cmd:byte}, {cmd:int}, or {cmd:long}) is replaced with
a noninteger value, its storage type is changed to
{cmd:float} or {cmd:double} according to
the current {helpb set type} setting.{p_end}
{phang2}4.  If a variable of integer type is replaced with an integer value that
is too large or too small for its current storage type, it is promoted to
a longer type ({cmd:int}, {cmd:long}, or {cmd:double}).{p_end}
{phang2}5.  When needed, {cmd:str}{it:#} variables are promoted to
a longer {cmd:str}{it:#} type or to {cmd:strL}.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Make the changes specified in {cmd:correctedValues.csv}
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. readreplace using correctedValues.csv,
id(uniqueid) variable(question) value(correctvalue){p_end}
{txt}{...}

{pstd}
Same as the previous {cmd:readreplace} command,
but specifies option {cmd:case} to {cmd:insheet} to import the replacements file
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. readreplace using correctedValues.csv,
id(uniqueid) variable(Question) value(CorrectValue) import(case){p_end}
{txt}{...}

{pstd}
Same as the previous {cmd:readreplace} command,
but loads the replacements file as a Stata dataset
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. readreplace using correctedValues.dta,
id(uniqueid) variable(Question) value(CorrectValue) use{p_end}
{txt}{...}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:readreplace} stores the following in {cmd:r()}:

{* Using -help spearman- as a template.}{...}
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of real changes{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}variables replaced{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(changes)}}number of real changes by variable{p_end}
{p2colreset}{...}


{marker authors}{...}
{title:Authors}

{pstd}Ryan Knight{p_end}
{pstd}Matthew White{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/readreplace/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


{title:Also see}

{psee}
Help:  {manhelp generate D}

{psee}
User-written:  {helpb cfout}, {helpb bcstats}, {helpb mergeall}
{p_end}
