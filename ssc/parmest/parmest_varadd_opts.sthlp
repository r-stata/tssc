{smcl}
{hline}
{cmd:help parmest_varadd_opts}{right:(Roger Newson)}
{hline}


{title:Variable-adding options for {helpb parmest} and {helpb parmby}}


{title:Syntax}

{synoptset 16}
{synopthdr}
{synoptline}
{synopt:{opt mset:ype}}Variable containing parameter matrix stripe element type{p_end}
{synopt:{opt om:it}}Variable containing parameter omit status{p_end}
{synopt:{opt emp:ty}}Variable containing parameter empty cell status{p_end}
{synopt:{opt l:abel}}Variable containing {it:X}-variable labels{p_end}
{synopt:{opt yl:abel}}Variable containing {it:Y}-variable labels{p_end}
{synopt:{opt idn:um(#)}}Numeric dataset ID variable{p_end}
{synopt:{opt ids:tr(string)}}String dataset ID variable{p_end}
{synopt:{cmdab:sta:rs}{cmd:(}{help numlist:{it:numlist}})}Variable containing stars for the {it:P}-value{p_end}
{synopt:{opt em:ac(name_list)}}Variables containing macro estimation results{p_end}
{synopt:{opt es:cal(name_list)}}Variables containing scalar estimation results{p_end}
{synopt:{opt er:ows(name_list)}}Variables containing rows of matrix estimation results{p_end}
{synopt:{opt ec:ols(name_list)}}Variables containing columns of matrix estimation results{p_end}
{synopt:{opt ev:ec(name_list)}}Variables containing vectors extracted from matrix estimation results{p_end}
{synoptline}

{pstd}
where {it:name_list} is a list of names of Stata {help estimates:estimation results}.


{title:Description}

{pstd}
These options allow the user to add optional extra variables
to the output dataset (or resultsset) created by {helpb parmest} or {helpb parmby}.


{title:Options}

{p 4 8 2}
{cmd:msetype} specifies that a string variable named {cmd:msetype} is to be generated in the output dataset,
containing, in each observation, the matrix stripe element type
of the value of the variable {cmd:parm} in that observation.
The matrix stripe element type indicates the type of parameter corresponding to that observation,
and may be {cmd:variable}, {cmd:error}, {cmd:factor}, {cmd:interaction}, or {cmd:product}.

{p 4 8 2}
{cmd:omit} specifies that a variable named {cmd:omit} is to be generated in the output dataset,
containing, in each observation, the omit status of the parameter corresponding to that observation
(1 if the parameter is omitted, 0 otherwise).
A parameter is flagged as omitted because of collinearity with other parameters.
This happens in the case where a parameter corresponds
to the effect of a baseline level of a {help fvvarlist:factor variable}.

{p 4 8 2}
{cmd:empty} specifies that a variable named {cmd:empty} is to be generated in the output dataset,
containing, in each observation, the empty cell status of the parameter corresponding to that observation
(1 if the parameter corresponds to an empty cell, 0 otherwise).
A parameter is flagged as empty if it corresponds to an empty cell
in a frequency table of {help fvvarlist:factor variables}.
This happens in the case where a parameter corresponds
to the effect of a combination of levels of {help fvvarlist:factor variables}
which does not appear in the input data sample.

{p 4 8 2}
{cmd:label} specifies that a variable named {cmd:label} is to be generated in the output dataset,
containing, in each observation, a descriptive label for the corresponding parameter.
It is set to the variable label of the variable corresponding to the parameter name for that observation,
if such a variable exists in the pre-existing dataset and is unique.
For a parameter named
{hi:_cons}, which is always a constant term in a model, the variable {hi:label} is set to "Constant".
If the estimation command is {helpb lincomest} (a version of {helpb lincom} downloadable from {help ssc:SSC}),
then {hi:label} is set to the linear combination formula specified to {helpb lincomest},
truncated if necessary to the maximum length of a string variable
in the version of Stata currently being used,
which is stored in the {help creturn:c-class value} {cmd:c(maxstrvarlen)}.
Otherwise, {cmd:label} is set to an empty string ({cmd:""}).

{p 4 8 2}
{cmd:ylabel} specifies that a variable named {hi:ylabel} is to be generated in the output dataset,
containing the variable labels of {it:Y}-variables.
This variable is generated as follows.
If the value of the {help ereturn:estimation result} {hi:e(depvar)} is a single name belonging to an existing variable,
then all values of {hi:ylabel} are set to its variable label.
Otherwise, the equation name corresponding to each parameter is checked
to ensure that it is a single name belonging to an existing variable.
If this is the case, then the value of {hi:ylabel} corresponding to that parameter is set to its variable label.
Otherwise, the value of {hi:ylabel} corresponding to that parameter is set to an empty string.

{p 4 8 2}
{cmd:idnum(}{it:#}{cmd:)} specifies an ID number for the output dataset.
It is used to create a numeric variable {hi:idnum} in the output dataset, with that value for all observations.
This is useful if the output dataset is concatenated with other {helpb parmest} or {helpb parmby} output datasets
using {helpb append}.

{p 4 8 2}
{cmd:idstr(}{it:string}{cmd:)} specifies an ID string for the output dataset.
It is used to create a string variable {hi:idstr} in the output dataset, with that value for all observations.
This is useful if the output dataset is concatenated with other {helpb parmest} or {helpb parmby} output datasets
using {helpb append}.
A {helpb parmest} or {helpb parmby} output dataset may contain a variable {hi:idnum},
a variable {hi:idstr}, both, or neither.

{p 4 8 2}
{cmd:stars(}{it:numlist}{cmd:)} specifies a descending list of {it:P}-value thresholds.
If {cmd:stars()} is specified, then a string variable {hi:stars} is created in the output dataset,
containing, in each observation, a string of stars whose length is equal to the number of
{it:P}-value thresholds in the list at least as large as the value of the {it:P}-value variable {hi:p}
in that observation.
For instance, if the user specifies {cmd:stars(0.05 0.01 0.001 0.0001)},
then the variable {hi:stars} will contain an empty string {hi:""} if {hi:p>0.05},
a single star {hi:"*"} if {hi:0.05>=p>0.01}, two stars {hi:"**"} if {hi:0.01>=p>0.001},
three stars {hi:"***"} if {hi:0.001>=p>0.0001}, and four stars {hi:"****"} if {hi:p<=0.0001}.

{p 4 8 2}
{cmd:emac(}{it:name_list}{cmd:)} specifies a list of names of macro
{help estimates:estimation results} to be stored as additional string variables in the output dataset.
These variables will be named {hi:em_1}, ..., {hi:em_}{it:n}, in the order in which they are
specified in the {it:name_list}.
Their values will be the values of the corresponding macro
{help estimates:estimation results}, truncated if necessary to the maximum length of a string variable
in the version of Stata currently being used,
which is 244 characters in {help version:Stata Version 9}).
For instance, if the user specifies {cmd:emac(depvar command)},
then the output dataset will contain a string variable {hi:em_1}, equal in all observations to the value of the {help estimates:estimation result} {hi:e(depvar)},
and a string variable {hi:em_2}, equal in all observations to the value of the {help estimates:estimation result} {hi:e(command)}.

{p 4 8 2}
{cmd:escal(}{it:name_list}{cmd:)} specifies a list of names of scalar
{help estimates:estimation results} to be stored as additional numeric variables in the output dataset.
These variables will be named {hi:es_1}, ..., {hi:es_}{it:n},
in the order in which they are specified in the {it:name_list}.
Their values will be the values of the corresponding scalar {help estimates:estimation results}.
For instance, if the user specifies {cmd:escal(N N_clust)},
then the output dataset will contain two numeric variables {hi:es_1} and {hi:es_2},
equal in all observations to the values of the {help estimates:estimation results}
{hi:e(N)} and {hi:e(N_clust)}, respectively.

{p 4 8 2}
{cmd:erows(}{it:name_list}{cmd:)} specifies a list of names of matrix
{help estimates:estimation results}, whose rows will be stored as additional numeric variables
in the output dataset.
These variables will have default names of the form {hi:er_}{it:y}{hi:_}{it:k}, where {it:y} is the order
of the matrix in the name list and {it:k} is the row number.
For instance, if the user specifies {cmd:erows(V)}, then the additional variables will be named
{hi:er_1_1}, ..., {hi:er_1_}{it:n}, where {it:n} is the number of rows of the variance matrix {hi:e(V)},
and they will contain the rows of the variance matrix.
These additional variables, like all others in the output dataset, will have one observation per model parameter.
If the matrix rows are longer than the number of parameters, then the additional variables will be truncated.
If the matrix rows are shorter than the number of parameters, then the additional variables will be completed
with missing values.

{p 4 8 2}
{cmd:ecols(}{it:name_list}{cmd:)} specifies a list of names of matrix
{help estimates:estimation results}, whose columns will be stored as additional numeric variables
in the output dataset.
These variables will have default names of the form {hi:ec_}{it:y}{hi:_}{it:k}, where {it:y} is the order
of the matrix in the name list and {it:k} is the column number.
For instance, if the user specifies {cmd:ecols(V)}, then the additional variables will be named
{hi:ec_1_1}, ..., {hi:ec_1_}{it:n}, where {it:n} is the number of columns of the variance matrix {hi:e(V)},
and they will contain the columns of the variance matrix.
These additional variables, like all others in the output dataset, will have one observation per model parameter.
If the matrix columns are longer than the number of parameters, then the additional variables will be truncated.
If the matrix columns are shorter than the number of parameters, then the additional variables will be completed
with missing values.

{p 4 8 2}
{cmd:evec(}{it:name_list}{cmd:)} specifies a list of names of matrix {help estimates:estimation results},
from which vectors will be extracted to be stored as additional numeric variables in the output dataset.
These variables will be named {hi:ev_1}, ..., {hi:ev_}{it:n},
in the order in which the corresponding {help estimates:estimation results} are specified in the {it:name_list}.
Their values will be extracted from the corresponding matrix
{help estimates:estimation results}, and will be reformatted if necessary,
in order to fit in a variable with one observation per model parameter.
If the matrix is a square matrix with numbers of rows and columns equal to the
number of parameters in the model, then the corresponding output variable will
contain its vector diagonal.
Otherwise, if the matrix has a number of columns
equal to the number of parameters, then the corresponding output variable will
contain its first row.
Otherwise, if the matrix has a number of rows equal to the
number of parameters, then the corresponding output variable will contain its first column.
Otherwise, the corresponding output variable will contain its first
column, truncated or completed with missing values as necessary.
If the matrix estimation result does not exist, then the corresponding output variable will
be filled with missing values.
These rules may seem complicated, but are probably sensible.


{title:Notes}

{pstd}
The names of the extra variables created by these options, as given in the descriptions above,
are the default names.
They all may be changed by the user, using the
{cmd:rename()} option. (See {help parmest_varmod_opts:{it:parmest_varmod_opts}}.)
For more details on the variables in the output dataset (or resultsset)
created by {helpb parmest} or {helpb parmby}, see {help parmest_resultssets:{it:parmest_resultssets}}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {findalias frestimate},{break}
{manlink D append}, {manlink R lincom}, {manlink R nlcom}
{p_end}

{psee}
{space 2}Help:  {manhelp estcom U:20 Estimation and postestimation commands},{break}
{manhelp append D}, {manhelp lincom R}, {manhelp nlcom R}{break}
{helpb parmest}, {helpb parmby},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {help parmest_ci_opts:{it:parmest_ci_opts}}, {help parmest_varmod_opts:{it:parmest_varmod_opts}},
{help parmby_only_opts:{it:parmby_only_opts}}, {help parmest_resultssets:{it:parmest_resultssets}}
{break}
{helpb lincomest} if installed
{p_end}
