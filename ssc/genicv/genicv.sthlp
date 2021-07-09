{smcl}
{* version 1.0.2 18mar2011}
{cmd:help genicv}
{hline}

{title:Title}

{p 5}
{cmd:genicv} {hline 2} {hi:Gen}erate {hi:i}nteraction between {hi:c}ontinuous (or dummy) 
{hi:v}ariables

{title:Syntax}

{p 8}
{cmd:genicv} {varlist} {ifin} [{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}replace existing variables{p_end}
{synopt:{opt x(chars)}}use {it:chars} as separator in variable labels{p_end}
{synopt:{opt sep:vars(chars)}}use {it:chars} as separator for variable names{p_end}
{synopt:{opt mvc(mvc)}}replace interactions with {it:mvc} if variables have hard 
missings{p_end}
{synopt:{opt l:ocal(macname)}}save created variable names in {it:macname}{p_end} 
{synoptline}

{title:Description}

{pstd}
{cmd:genicv} multiplies variables to create two or three-way interactions. If two variables 
are specified in {it:varlist}, one new variable {it:varname1_varname2} is created as the 
product of {it:var1} and {it:var2}. If three variables are specified, {cmd: genicv} creates 
{it:varname1_varname2_varname3} and all three two-way interactions ({it:varname1_varname2}, 
{it:varname1_varname3}, {it:varname2_varname3}). If all variables in {it:varlist} are 
labeled, new variable labels will be {it:"labeli * labelj} [{it:* labelk}]{it:"}. If one or 
more variables in {it:varlist} are not labeled, new variables will not be labeled.

{title:Options}

{dlgtab:options}

{phang}
{opt replace} replaces existing variables. Default is to only create variables, that do not 
yet exist.

{phang}
{opt sepvars(chars)} use {it:varnamei}{hi:{it:chars}}{it:varnamej}
[{hi:{it:chars}}{it:varnamek}] as variable names. Default is "{hi:_}".

{phang}
{opt x(chars)} use {it:labeli} {hi:{it:chars}} {it:labelj} [{hi:{it:chars}} {it:labelk}] as 
variable labels. Default is "{hi:*}".

{phang}
{opt mvc(mvc)} replaces interactions with hard missing {it:mvc} (where {it:mvc} is one 
of .a, ..., .z), if one of the original variables has hard missings.

{phang}
{opt local(macname)} saves the created variable names in {cmd:r(}{it:macname}{cmd:)}. Default 
{it:macname} is {it:icv}.


{title:Example}

	. sysuse nlsw88 ,clear
	(NLSW, 1988 extract)

	{cmd:. genicv wage age married}

	. describe

	[...]
	----------------------------------------------------------------------------
	                [...] value
	variable name   [...] label     variable label
	----------------------------------------------------------------------------
		[...]
	age                             age in current year
		[...]
	married               marlbl    married
		[...]
	wage                            hourly wage
		[...]
	wage_age                        hourly wage * age in current year
	wage_married                    hourly wage * married
	age_married                     age in current year * married
	wage_age_marr~d                 hourly wage * age in current year * married
	----------------------------------------------------------------------------


{title:Saved results}

{pstd}
{cmd:genicv} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synopt:{cmd:r(macname)}}created variable names{p_end}


{title:Author}

{pstd}Daniel Klein, University of Bamberg, klein.daniel.81@gmail.com

{title:Also see}

{psee}
Online: {help generate}, {help xi}, {help fvvarlist} {p_end}
{psee}
if installed: {help tuples}, {help selectvars}, {help chm}
{p_end}