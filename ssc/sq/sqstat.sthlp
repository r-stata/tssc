{smcl}
{* August 18, 2011 @ 09:39:16 UK}{...}
{vieweralsosee "sqclusterdat" "help sqclusterdat "}{...}
{vieweralsosee "sqdes" "help sqdes "}{...}
{vieweralsosee "sqegen" "help sqegen "}{...}
{vieweralsosee "sqindexplot" "help sqindexplot "}{...}
{vieweralsosee "sqmdsadd" "help sqmdsadd "}{...}
{vieweralsosee "sqmodalplot" "help sqmodalplot "}{...}
{vieweralsosee "sqom" "help sqom "}{...}
{vieweralsosee "sqpercentageplot" "help sqpercentageplot "}{...}
{vieweralsosee "sqset" "help sqset "}{...}
{vieweralsosee "sqstat" "help sqstat "}{...}
{vieweralsosee "sqstrlev" "help sqstrlev "}{...}
{vieweralsosee "sqstrmerge" "help sqstrmerge "}{...}
{vieweralsosee "sqtab" "help sqtab "}{...}



{cmd:help sqstatlist}, {cmd:help sqstatsum},{right:(SJ6-4: st0111)}
{cmd:help sqstattab1}, {cmd:help sqstattab2},
{cmd:help sqstattabsum}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi: sqstat} {hline 2} Describe variables generated with sq-egen functions}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 5 17 2}
{cmdab:sqstatlist}
[{varlist}]
{ifin}
[{cmd:,} {cmd:replace} {opt ranks(numlist)} {opt not(varlist)} {cmd:replace} {it:list_options}]

{p 6 17 2}
{cmdab:sqstatsum}
[{varlist}]
{ifin}
[{cmd:,} {opt not(varlist)} {cmd:exclude0} {it:summarize_options}] 

{p 5 17 2}
{cmdab:sqstattab1}
[{varlist}]
{ifin}
[{cmd:,} {opt not(varlist)} {cmd:exclude0} {cmdab:l:istwise} {it:tab1_options}]

{p 5 17 2}
{cmdab:sqstattab2}
{it:varname1} [{it:varname2}]
{ifin}
[{cmd:,} {opt not(varlist)} {cmd:exclude0} {cmdab:l:istwise} {it:tab2_options}]

{p 3 17 2}
{cmdab:sqstattabsum}
{it:varname1} [{it:varname2}]
{ifin}
[{cmd:,} {opt not(varlist)} {cmd:exclude0} {cmdab:l:istwise} {opt format(%fmt)} {it:tabsum_options}]


{title:Description}

{pstd}Commands that provide a convenient way to describe the variables
generated with {help sqegen}. The commands are useful because SQ-data
is in long form, while the variables generated with {help sqegen}
refer to the sequences as entire entity. To further describe the new
variables one might want to reshape the data to wide. The
{cmd:sqstat}-commands allow to summarize, tabulate, and list the
variables generated with the {cmd:sqegen} function as if the data were
in wide format. Thereby the names of the variables generated with
{cmd:sqegen} are automatically processed.

{pstd}The following {cmd:sqstat} programs are available: 

{phang} {cmd:sqstatlist} [{varlist}] [ {cmd:, replace ranks(}{it:numlist}{cmd:)} ]:
Lists all variables generated with
{cmd:sqegen}.  With varlist only the specified variables are
listed. {cmd:replace} is used to keep the listed dataset in
memory. This is useful to produce some non-standard description (like
graphs, for example) of the e-generated variables. {cmd:ranks()} is
used to restrict the output to the most frequent sequences. Inside the
parentheses a {help numlist} might be specified, which refer to the
position of the sequences in the sorted frequency table.

{phang} {cmd:sqstatsum} [{varlist}]: If given without the optional
varlist the command summarizes all variables generated with the
{cmd:sqegen} bundle. With varlist only the specified variables are
summarized.

{phang} {cmd:sqstattab1} [{varlist}]: If given without the optional
varlist the command produces one way frequency tables of all variables
generated with the {cmd:sqegen} bundle. With varlist only the
specified variables are used.

{phang} {cmd:sqstattabsum} {it:varname1} [{it:varname2} ]: Summarizes
all e-generated variables for categories of the specified
variables. Option {cmd:format(}%fmt{cmd:)} allows to set the display
{help format} of all cells in the output. The default is %9.0g. 

  
{phang} {cmd:sqstattab2} {it:varname1} [{it:varname2}]]: If given
without the optional varname2 the command displays a two-way table of
varname1 against all variables generated with the {cmd:sqegen}
bundle. If specified with varname2 a two-way table of the two
specified variables is displayed.


{title:Options}

{phang}
{opt replace} keeps listed data in memory.

{phang}
{opt ranks(numlist)} restricts tabulation on most frequent sequences.

{phang}
{opt not(varlist)} do not show variables from varlist

{phang} {opt exclude0} Restrict calculation of statistics for
egen-erated variables to observations not equal to zero.

{phang} {opt listwise} is used in connection with {opt exclude0}. If
specified, it restricts the calculation of statistics for egen-erated
variables to observations not equal to zero on all variables specified.

{phang}
{it:list_options} are any of the options allowed with {helpb list}.

{phang}
{it:summarize_options} are any of the options allowed with {helpb summarize}.

{phang}
{it:tab1_options} are any of the options allowed with {helpb tabulate oneway}.

{phang}
{it:tab2_options} are any of the options allowed with {helpb tabulate twoway}.

{phang}
{opt format(%fmt)} specifies output {helpb format}.

{phang}
{it:tabsum_options} are any of the options allowed with
{helpb tabulate, summarize()}.


{title:Author}

{pstd}Ulrich Kohler, University of Potsdam, ulrich.kohler@uni-potsdam.de{p_end}


{title:Examples}

{phang}{cmd:. sqstatlist}

{phang}{cmd:. sqstatlist, ranks(1/10)}

{phang}{cmd:. sqstatsum}

{phang}{cmd:. sqstattab1}


{title:Also see}

{psee}
Manual: {bf:[R] list} {bf:[R] summarize} {bf:[R] tabulate} 

{psee} Online: {helpb sq}, {helpb sqdemo}, {helpb sqset},
{helpb sqdes}, {helpb sqegen}, {helpb sqstat}, {helpb sqindexplot},
{helpb sqparcoord}, {helpb sqom}, {helpb sqclusterdat},
{helpb sqclustermat}
{p_end}
