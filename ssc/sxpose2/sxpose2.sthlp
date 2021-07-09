{smcl}
{* *! version 1.0.0  17oct2020}{...}
{vieweralsosee "[D] xpose" "mansection D xpose"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] reshape" "help reshape"}{...}
{vieweralsosee "[D] stack" "help stack"}{...}
{viewerjumpto "Syntax" "sxpose2##syntax"}{...}
{viewerjumpto "Description" "sxpose2##description"}{...}
{viewerjumpto "Options" "xpose##options"}{...}
{viewerjumpto "Examples" "xpose##examples"}{...}
{p2colset 1 14 16 2}{...}

{p2col:{bf: sxpose2} {hline 2}}Transponse of string (and numeric) variable dataset{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}{cmd:sxpose2, clear} [{it:options}]

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt clear}}reminder that untransposed data will be lost if not previously saved{p_end}
{synopt :{opt de:string}}tries to destring variables after the transponse has happened{p_end}
{synopt :{opt first:names}}apply specified format to all variables in transposed data{p_end}
{synopt :{opt force}}allows to transponse numeric variables. {p_end}
{synopt :{opth f:ormat(%fmt)}}apply specified format to all variables in transposed data{p_end}
{synopt :{opt varl:abel}}add variable {opt _varlabel} containing original variable label{p_end}
{synopt :{opt varn:ame}}add variable {opt _varname} containing original variable names{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {cmd:clear} is required.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:sxpose2} transposes the data, changing variables into observations and
observations into variables. In contrast to the implemented command xpose, it also
allows string variables to be transposed. It is build upon the well-received 
user-written command sxpose and adds the possibility to keep variable names and/or
variable labels. 

{marker options}{...}
{title:Options}

{phang}
{opt clear} is required and is supposed to remind you that the
untransposed data will be lost (unless you have saved the data previously).

{phang}
{opt de:string}  specifies that {cmd:destring, replace} will be run on the new dataset 
in an attempt to convert variables that are unambiguously numeric in content to numeric. 
No force will be applied. See help on {help destring}. 

{phang}
{opt first:names} specifies that the first variable of the existing dataset is to be treated 
the new variable names of the transposed dataset. Any values that are not legal variable names will be lost. {p_end}

{phang}
{opt force} is required when the dataset contains numeric variables. Numeric values will 
be saved as strings using the format %12.0g by default. Other formats can be specified using the format() option. 
Please be aware that you may lose precision using this option. The {cmd: xpose} command allows to 
transpone a numeric dataset with higher precision.

{phang}
{opt f:ormat} specifies a numeric format to use in coercing numeric values to string. See the force option.

{phang}
{opt varl:name} adds the new variable {cmd:_varname} to the transposed data containing 
the original variable names.

{phang}
{opt varl:abel} adds the new variable {cmd:_varlabel} to the transposed data containing 
the original variable labels.


{marker examples}{...}
{title:Examples}

    Setup
{phang2}{cmd: . clear all}{p_end}
{phang2}{cmd: . input str1 id str1 var1 str1 var2 }{p_end}
{phang2}{cmd: . "a"     "d" 	"g"}{p_end}
{phang2}{cmd: . "b"     "e"    "h"}{p_end}
{phang2}{cmd: . "c"     "f"  "i"}{p_end}
{phang2}{cmd: . end}{p_end}
{phang2}{cmd: . label var var1 "VAR-1"}{p_end}
{phang2}{cmd: . label var var2 "VAR-2"}{p_end}

    List the original data
{phang2}{cmd: . list}{p_end}
{phang2}{cmd: . sxpose2, clear firstnames varlabel varname}{p_end}

    List the results
{phang2}{cmd:. list}{p_end}

{title:Acknowledgements} 

{pstd}Nicholas J. Cox who wrote {cmd:sxpose}. See: {rnethelp "http://fmwww.bc.edu/RePEc/bocode/s/sxpose.hlp"}

{title:Author} 

{p 4 4 6}Stephan Huber{p_end}
{p 4 4 6}DrStephanHuber@yahoo.com {p_end}

{title:Also see}

{psee}
Online:  help for {help xpose} 
{p_end}
