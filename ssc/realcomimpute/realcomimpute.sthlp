{smcl}
{cmd:help realcomImpute}
{hline}

{title:Title}

{phang}
{bf:realcomImpute} Export data to Realcom-Impute

{title:Syntax}

{p 8 17 2} {cmd:realcomImpute} {it:varlist} {helpb using} {it:filename} , options

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt numresponses(num)}}number of response variables (variables to be imputed) in {it:varlist}{p_end}
{p2coldent:* {opt cons(consvar)}}variable containing constant{p_end}
{p2coldent:* {opt level2id(level2idvar)}}variable level 2 identifiers{p_end}
{synopt :{opt level1wgt(level1wgtvar)}}variable containing level 1 weights{p_end}
{synopt :{opt level2wgt(level2wgtvar)}}variable containing level 2 weights{p_end}

{p2coldent :+ {opt replace}}overwrite existing {it:filename}{p_end}
{synoptline}
{p2coldent :* denotes required option}{p_end}
{p2coldent :If {it:filename} is specified without an extension, .txt is assumed.}{p_end}
{p2coldent :If your {it:filename} contains embedded spaces, remember to enclose it in double quotes.}{p_end}

{pstd}
An element of {it:varlist} for {cmd:realcomImpute} which is a response takes one of three forms:
{it:varname}, {hi:m.}{it:varname}, or {hi:o.}{it:varname}. Details are given in {help realcomImpute##remarks:Remarks}

{title:Description}

{pstd}
{cmd:realcomImpute} exports data to a file that can be read by the Realcom Impute
package, which can perform multiple imputation of missing 
values in multi-level datasets - for more details visit the Realcom Impute website
at {browse "http://www.cmm.bristol.ac.uk/research/Realcom/imputation.shtml":www.cmm.bristol.ac.uk/research/Realcom/imputation.shtml}.

{title:Options}

{phang}
{opt numresponses(num)} specifies how many of the variables in {it:varlist} are to be responses in the imputation model (variables to be imputed).
 The first {opt numresponses(num)} variables in {it:varlist} are assumed to be the responses. This option must be specified.

{phang}
{opt cons(consvar)} specifies the name of a variable which contains a constant (i.e. all observations set to 1). This option is required.

{phang}
{opt level2id(level2idvar)} specifies the name of the variable which contains the level 2 identifier. This option is required. 
The data should be sorted by this variable - if it is not, the command will give an error. 
If you wish to perform single-level imputation, specify some variable 
for the level 2 id, and then in Realcom, click the button labelled 'Clear level-2 identifier'.

{phang}
{opt level1wgt(level1wgtvar)} specifies the name of the variable containing level 1 weights. This is optional.

{phang}
{opt level2wgt(level2wgtvar)} specifies the name of the variable containing level 2 weights. This is optional.

{title:Remarks}
{marker remarks}{...}

{pstd}
{cmd:realcomImpute} exports data to a file that can be read by the Realcom Impute package, which can perform multiple imputation of missing
    values in multi-level datasets. 

{pstd}	
	The {it:varlist} should contain all the variables you want to export, with responses (variables that you want to impute) followed by
    explanatory/auxiliary variables (which should have no missing values). The command assumes that the first {opt numresponses(num)} 
	variables are responses (variables to be imputed), with the remainder explanatory variables in the imputation model. Level 1 response variables
	must precede level 2 response variables. Note that which variables are responses/explanatory variables in the imputation model depends on which variables
	have missing values, and not which will be responses/explanatory variables in your final model of interest.
	
{pstd}
Those elements of {it:varlist} which are responses (variables to be imputed) take one of three forms:
{it:varname}, {hi:m.}{it:varname}, or {hi:o.}{it:varname}. {hi:m.}{it:varname} denotes that the variable is unordered categorical,
 {hi:o.}{it:varname} that it is ordered categorical, and {it:varname} that it is continuous.
 Binary responses can be entered either using {hi:m.}{it:varname} or {hi:o.}{it:varname}. Only variables which are responses (i.e. to be imputed)
 may have a prefix specified. Alternatively, one can use {it:varname} to enter all response variables, and then edit
 the response types in the Realcom Impute program.
 
{pstd}
For categorical variables which have no missing values, and which will serve as explanatory variables in the imputation model, you must generate 
appropriate dummy variables for the different levels and pass these dummy variables to {cmd:realcomImpute}.
	
{pstd}
	The command creates a file of the listed variables which can be
    read into the Realcom Impute package. After creating multiple imputations using Realcom
	Impute, the imputations can be loaded back into Stata using the {helpb realcomImputeLoad} command.

{title:Examples}

{phang}
	{cmd:. realcomImpute nlitpre m.fsmn nlitpost using temp.txt, numresponses(2) cons(cons) level2id(school) replace}
	
{title:Author}

    Jonathan Bartlett
	jwb133@googlemail.com
	www.thestatsgeek.com
	www.missingdata.org.uk

{title:Also see}

    {helpb realcomImputeLoad}
