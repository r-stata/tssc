{smcl}
{hline}
{cmd:help parmby_only_opts}{right:(Roger Newson)}
{hline}


{title:Options for {helpb parmby} only}


{title:Syntax}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{cmd:by(}{varlist}{cmd:)}}Specify variables defining by-groups{p_end}
{synopt:{opt com:mand}}Add a variable containing the command called{p_end}
{synoptline}


{title:Description}

{pstd}
These options may not be specified for {helpb parmest}.
They allow the user to call an {help estcom:estimation command} once for each of a set of by-groups,
and to create an the output dataset (or resultsset)
with one observation per parameter per by-group.


{title:Options}

{p 4 8 2}
{cmd:by(}{it:varlist}{cmd:)} specifies a list of existing variables which would normally appear
in the {help by:{cmd:by} {it:varlist}{cmd::}} section of the Stata estimation command called by {helpb parmby}.
{helpb parmby} creates an output dataset with one observation for each parameter in each by-group in
which the command executed successfully.
The output dataset contains values of the by-variables in each by-group (if {cmd:by()} is specified),
in addition to the variables created by {helpb parmest}.
However, the {cmd:by()} option is optional, and {helpb parmby} will still work without it,
creating an output dataset with one observation per parameter of a single set of estimation results.

{p 4 8 2}
{opt command} is a {help parmest_varadd_opts:variable-adding option}.
If specified, it creates a string variable named {hi:command} in the output dataset,
containing the text of the {help estcom:estimation command} called by {helpb parmby}.
The text of the command is truncated, if necessary, to the
maximum length of a string variable under the edition of Stata currently in use,
which is 244 characters in {help version:Stata Version 9}. (See help for {help limits}.)
The variable {hi:command} has the same value in all observations in the output dataset,
and is useful as an identifier if the user creates multiple {helpb parmby} output datasets,
using different commands, and concatenates them using {helpb append},.


{title:Notes}

{pstd}
Note that the variable {hi:command} can be renamed by the {cmd:rename()} option,
but the variables specified in {cmd:by(}{varlist}{cmd:)} cannot.
See help for {help parmest_varmod_opts:{it:parmest_varmod_opts}}
for details on the {cmd:rename()} option,
and help for {help parmest_resultssets:{it:parmest_resultssets}} for details
of other variables in the output datasets (or resultssets} produced by {helpb parmest} and {helpb parmby}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frestimate},{break}
{mansection U 11.4varlists:{bf:[U] 11.4 varlists}},{break}
{manlink D append}, {manlink D by}
{p_end}

{psee}
{space 2}Help:  {manhelp estcom U:20 Estimation and postestimation commands},{break}
{manhelp varlists U:11.4 varlists},{break}
{manhelp append D}, {manhelp by D}{break}
{helpb parmest}, {helpb parmby},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {help parmest_ci_opts:{it:parmest_ci_opts}},
{help parmest_varadd_opts:{it:parmest_varadd_opts}}, {help parmest_varmod_opts:{it:parmest_varmod_opts}},
{help parmest_resultssets:{it:parmest_resultssets}}
{p_end}
