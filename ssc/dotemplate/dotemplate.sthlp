{smcl}
{* *! version 1.0 18 Dec 2013}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "dotemplate##syntax"}{...}
{viewerjumpto "Description" "dotemplate##description"}{...}
{viewerjumpto "Options" "dotemplate##options"}{...}
{viewerjumpto "Remarks" "dotemplate##remarks"}{...}
{viewerjumpto "Examples" "dotemplate##examples"}{...}
{hline}
help for {cmd:dotemplate}{right:R.Andrés Castañeda}
{hline}

{phang}
{bf:dotemplate} {hline 2} Creates an organized template for do-files

{marker syntax}{...}
{title:Syntax}

{phang}
Using dialog box

{p 8 17 2}{cmdab:dotemplate}{p_end}

{phang}
Using Stata regular syntax

{p 8 17 2}
{cmdab:dotemplate}
{cmd:,} {it:file(string)} [
{it:options}]

{phang}
{err:Note}: I highly recommend using the dialog box syntax rather than the regular 
Stata syntax. Just type {cmd:dotemplate} in Stata and fill up the fields. The only 
mandatory options if {it:file(string)} to provide the name of the file. 

{marker sections}{...}
{title:Sections}

{pstd}
Help is presented under the following headings:

	{help dotemplate##description:Description}
	{help dotemplate##options:Options}
	{help dotemplate##examples:Examples}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:main}
{synopt:{opt pro:ject(string)}}objective of the do-file{p_end}
{synopt:{opt f:ile(string)}}name of the do-file{p_end}
{synopt:{opt aut:hor(string)}}author name{p_end}
{synopt:{opt p:ath(string)}}directory path where do-file will be placed{p_end}
{synopt:{opt ty:pe(string)}}type of template. {it:basic} or {it:complete}{p_end}
{synopt:{opt dep:end(string)}}institutions/s working for in the project{p_end}
{synopt:{opt out:put(string)}}list of files produced with the do-file{p_end}
{synopt:{opt sec:tions(#)}}number of sections in do-file.default is 3.{p_end}
{synopt:{opt step:s(#)}}number of steps with sections.{p_end}
{synopt:{opt log}}produced log file with the same name as the do-file{p_end}
{synopt:{opt replace}}replace{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:dotemplate} Creates template for do-files. Two different type of template are provided. 
{cmd:dotemplate} is useful for being organized as programmer and standardize do-files among a 
team or group of programmers. If any of the options above is not specified, {cmd:dotemplate}
will request for them. The user could press {it:Enter} from the keyboard if no information 
is desired to be prompted, or type in the Stata commands window the specific information. 

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt pro:ject(string)} Name of the project or objective of the do-files

{phang}
{opt aut:hor(string)} Name of author. Default is the name stored in macro c(username)

{phang}
{opt f:ile(string)} Name of do-file to create

{phang}
{opt p:ath(string)} Directory path in which the do-file template will be created. Default is current 
directory

{phang}
{opt ty:pe(string)} Select between basic or complete type of template. default is complete


{phang}
{opt dep:end(string)} Dependencies for which the project of the do-file is done.. if any. 

{phang}
{opt out:put(string)} Expected output from the do-file

{phang}
{opt sec:tions(#)} Estimated number of sections that do-file will have. If the number of sections is 
greater or smaller than expected the user just have to add or erase as she needs. Default value is 3

{phang}
{opt steps(#)} Estimated number of steps or sub-sections in each sections. This option might be seldom
used but in some cases it will be useful in case the user needs a guide to organize her do-files. 

{phang}
{opt log} In case user likes to work with log-file, {cmd:dotemplate} will create above the header and 
just before the end the corresponding lines to create the log file. The name of the log-file will be
the same than the name of the do-file in text format. 

{col 30}{help dotemplate##sections:Back to Sections}

{marker examples}{...}
{title:Examples}

{dlgtab:Basic}
{phang}
Create a basic template with only one sections and no specification of log-file. {help dotemplate##basic:Example}

{col 5}{cmd:dotemplate}, project("Program to create Templates for do-file") ///
{col 10}file(detemplate)              ///
{col 10}author(Andres Castaneda)      ///
{col 10}path("C:\data\personal")      ///
{col 10}type(basic)


{dlgtab:complete}
{phang}
Create a complete template for do-file with four sections and 3 sub-sections. Lines for log-file are
specified. type(complete) is not necessary since it is the default option. {help dotemplate##complete:Example}

{col 5}{cmd:dotemplate}, project("Program to create Templates for do-file") ///
{col 10}file(detemplate)              ///
{col 10}author(Andres Castaneda)      ///
{col 10}path("C:\data\personal")      ///
{col 10}depend(The World Bank-LCSPP)  ///
{col 10}output(dotemplate.ado)        ///
{col 10}sections(2)                   ///
{col 10}steps(2)                      ///
{col 10}log

{title:Author}

{p 6 6 4}{cmd:R.Andrés Castañeda}{p_end}
{p 6 6 4}Development Economics, Data Group | 
{browse "http://iresearch.worldbank.org/PovcalNet/home.aspx":PovcalNet Team}{p_end}
{p 6 6 4}The World Bank|1818 H St. N.W., Washington, D.C. 20433{p_end}
{p 6 6 4}Email: {browse "acastanedaa@worldbank.org":   acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub:{browse "https://github.com/randrescastaneda":  randrescastaneda }{p_end}
{p 6 6 4}Website:{browse "https://randrescastaneda.rbind.io/": randrescastaneda.rbind.io }{p_end}

{title:Source}

{phang}
you may find the source code in the Github repository 
{browse "https://github.com/randrescastaneda/dotemplate":/randrescastaneda/dotemplate }


{hline}

{marker basic}{...}
{title:Example of basic template}

/*===========================================================================
project:      Program to create Templates for do-file
Author:       Andres Castaneda 
Program Name: detemplate.do
---------------------------------------------------------------------------
Creation Date:      December 20, 2013 
===========================================================================*/

/*=========================================================================
                         0: Program Setup
===========================================================================*/



exit
------------------------------------------------------------------
{col 30}{help dotemplate##sections:Back to Sections}

{marker complete}{...}
{title:Example of complete template}

capture log close
log using "C:\data\personal/detemplate.txt", replace text
/*===========================================================================
project:      Program to create Templates for do-file
Author:       Andres Castaneda 
Program Name: detemplate.do
Dependencies: The World Bank-LCSPP
---------------------------------------------------------------------------
Creation Date:      December 20, 2013 
Modification Date:    
version:              
References:           
Output:             dotemplate.ado
===========================================================================*/

/*=========================================================================
                         0: Program Setup
===========================================================================*/
* Program Setup
version 12.1
drop _all


/*=========================================================================
                        1: <Describe>
===========================================================================*/

*------------------------ 1.1: <Describe> ----------------------------------

*------------------------ 1.2: <Describe> ----------------------------------


/*=========================================================================
                         2: <Describe>
===========================================================================*/

*------------------------ 2.1: <Describe> ----------------------------------

*------------------------ 2.2: <Describe> ----------------------------------


log close
exit

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

{col 30}{help dotemplate##sections:Back to Sections}


