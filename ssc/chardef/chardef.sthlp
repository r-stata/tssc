{smcl}
{hline}
help for {cmd:chardef} and {cmd:charundef}{right:(Roger Newson)}
{hline}

{title:Assign values to a {help char:characteristic} of a list of items}

{p 8 21 2}
{cmd:chardef} [ {it:evarlist} ] [ ,
  {opt c:har(name)} {opt v:alues(string_list)} {opt pr:efix(string)} {opt su:ffix(string)}
  ]

{p 8 21 2}
{cmd:charundef} [ {it:evarlist} ] [ , {opt c:harlist(characteristic_list)} ]

{pstd}
where {it:evarlist} is a list of names which are either variable names or {cmd:_dta},
and {it:characteristic_list} is

{pstd}
{it:namelist} | {cmd:*}


{title:Description}

{pstd}
{cmd:chardef} is a mass-production version of the {helpb char:char define} command.
It assigns a list of values to a named {help char:characteristic}
of a list of items, which can be variables,
or the current dataset.
If the {it:evarlist} is not supplied, then {cmd:chardef} assigns the values
to the named {help char:characteristic} for all variables in the dataset currently in the memory.
If the named {help char:characteristic} is not supplied,
then the values are assigned to the {help char:characteristic} {cmd:varname},
used by the {helpb list} command.
If the list of values is shorter than the {it:evarlist},
then the list of values is extended on the right with copies of the last value.
Optionally, a prefix and/or a suffix may be added to the values.
The {cmd:charundef} module resets a list of characteristics to empty strings
for a list of items.


{title:Options for {cmd:chardef}}

{phang}
{opt char(name)} specifies the name of the {help char:variable characteristic}
whose values will be reset for all items in the {it:evarlist}.
If the {cmd:char()} option is not supplied,
then the values are assigned to the {help char:characteristic} {cmd:varname},
used by the {cmd:subvarname} option of the {helpb list} command.

{phang}
{opt values(string_list)} specifies the list of values to be assigned
to the {help char:characteristic} specified by the {cmd:char()} option,
for the corresponding items in the {it:evarlist}.
If not specified, then it is initialized to a single empty string ({cmd:""}).
If the list of values is shorter than the {it:evarlist},
then it is extended on the right with copies of the last value in the list,
which may or may not be an empty string.
Therefore, in default,
the values of the named {help char:characteristic}
are cleared for all items in the {it:evarlist}.

{phang}
{opt prefix(string)} specifies a common prefix string,
to be added to the left of the values specified by the {cmd:values()} option,
before assignment to the {help char:characteristic} named by the {cmd:char()} option
for the corresponding items in the {it:evarlist}.

{phang}
{opt suffix(string)} specifies a common suffix string,
to be added to the right of the values specified by the {cmd:values()} option,
before assignment to the {help char:characteristic} named by the {cmd:char()} option
for the corresponding items in the {it:evarlist}.


{title:Options for {cmd:charundef}}

{phang}
{opt charlist(characteristic_list)} specifies a list of names of characteristics to be undefined
(by being set to the empty string {cmd:""}).
It may be a list of legal Stata names, or may be {cmd:*},
implying a list of the names of all characteristics present for any item in the {it:evarlist}.
If not set,
{cmd:charlist()} is set to the names of all characteristics present for any item in the {it:evarlist}.


{title:Remarks}

{pstd}
{cmd:chardef} and {cmd:charundef} are designed to save the user the work of typing multiple {helpb char:char define} commands
for multiple variables and/or for the current dataset.
It is particularly useful if the user is using the {helpb listtab} package,
downloadable from {help ssc:SSC},
to generate tables for TeX, HTML, XML or RTF documents.
The user may want to specify one or more header rows, using the {cmd:headlines()} option of {helpb listtab},
and generate some of these header rows using the {helpb listtab:listtab_vars} module.
These header rows will typically be rows of header cells,
separated by the {cmd:delimiter()} string used by {helpb listtab}.
The text in the header cells may be prefixed using the {cmd:prefix()} option of {cmd:chardef},
and/or suffixed using the {cmd:suffix()} option of {cmd:chardef},
to specify alignment and/or formatting in the generated table.
The whole header row may be prefixed and suffixed by the {cmd:begin()} and {cmd:end()} strings, respectively,
specified as options to {helpb listtab}.
For more about the use of {cmd:chardef} with {helpb listtab} and other packages to create tables,
see {help chardef##references:Newson (2012)}.


{title:Examples}

{pstd}
Setup

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.describe}{p_end}

{pstd}
The following example sets the default {cmd:varname} characteristic for 5 variables,
and lists them using {helpb list}.

{phang2}{cmd:.chardef make foreign weight length mpg, values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.list make foreign weight length mpg, abbr(32) subvarname}{p_end}

{pstd}
The following example sets the {cmd:varname} characteristic for the first variable ({cmd:make}),
and clears the {cmd:varname} characteristic for all other variables (using the empty string {cmd:""}),
and lists all variables.

{phang2}{cmd:.chardef, values("Model of car" "")}{p_end}
{phang2}{cmd:.list, abbr(32) subvarname}{p_end}

{pstd}
The following example clears the {cmd:varname} characteristic for all variables, and lists them.

{phang2}{cmd:.chardef}{p_end}
{phang2}{cmd:.list, abbr(32) subvarname}{p_end}

{pstd}
The following example assigns the non-default {cmd:header} characteristic for 5 variables.

{phang2}{cmd:.chardef make foreign weight length mpg, char(header) values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.char list}{p_end}

{pstd}
The following 3 examples assign the {cmd:header} characteristic for 5 variables,
and then unset it.

{phang2}{cmd:.chardef make foreign weight length mpg, char(header) values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.char list}{p_end}
{phang2}{cmd:.charundef}{p_end}

{phang2}{cmd:.chardef make foreign weight length mpg, char(header) values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.char list}{p_end}
{phang2}{cmd:.charundef, char(*)}{p_end}

{phang2}{cmd:.chardef make foreign weight length mpg, char(header) values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.char list}{p_end}
{phang2}{cmd:.charundef make foreign weight length mpg, char(*)}{p_end}

{pstd}
The following advanced example demonstrates the use of {cmd:chardef},
with the packages {helpb sdecode}, {helpb listtab} and {helpb rtfutil},
to create a Rich Text Format (RTF) file {cmd:myrtf1.rtf},
containing a table of 5 variables for odd-numbered car models.
The packages {helpb sdecode}, {helpb listtab} and {helpb rtfutil}
can be downloaded from {help ssc:SSC}.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.keep if mod(_n,2)}{p_end}
{phang2}{cmd:.chardef make foreign weight length mpg, char(hcell) prefix("\qr{c -(}\i ") suffix("{c )-}") values("Car model" "Where from?" "How heavy?"  "How long?" "How efficient?")}{p_end}
{phang2}{cmd:.replace make="\qr{c -(}"+make+"{c )-}"}{p_end}
{phang2}{cmd:.foreach Y of var foreign weight length mpg {c -(}}{p_end}
{phang2}{cmd:.  sdecode `Y', replace prefix("\qr{c -(}") suffix("{c )-}")}{p_end}
{phang2}{cmd:.{c )-}}{p_end}
{phang2}{cmd:.tempname buff1}{p_end}
{phang2}{cmd:.rtfopen `buff1' using "myrtf1.rtf", replace template(fnmono1)}{p_end}
{phang2}{cmd:.capture noisily {c -(}}{p_end}
{phang2}{cmd:.  rtfrstyle make foreign weight length mpg, cwidth(2000 1000) lo(b d e)}{p_end} 
{phang2}{cmd:.  listtab_vars make foreign weight length mpg, b(`b') d(`d') e(`e') substitute(char hcell) lo(hrow)}{p_end}
{phang2}{cmd:.  listtab make foreign weight length mpg, handle(`buff1') head("`hrow'") b(`b') d(`d') e(`e')}{p_end}
{phang2}{cmd:.{c )-}}{p_end}
{phang2}{cmd:.rtfclose `buff1'}{p_end}

{pstd}
The following example clears all characteristics of the current dataset:

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.char list}{p_end}
{phang2}{cmd:.charundef _dta}{p_end}
{phang2}{cmd:.char list}{p_end}


{title:Saved results}

{cmd:charundef} saves the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(charlist)}}list of names of characteristics cleared (in alphabetic order)
{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{marker references}{title:References}

{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.


{title:Also see}

{psee}
Manual:  {manlink P char}
{p_end}

{psee}
{space 2}Help:  {manhelp char P}{break}
{helpb sdecode}, {helpb listtab}, {helpb rtfutil} if installed
{p_end}
