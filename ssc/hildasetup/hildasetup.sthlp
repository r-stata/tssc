
{smcl}
{* *! Version 1.1.0 by Francisco Perales 24-April-2013}{...}
{bf:help hildasetup}
{hline}


{title:Title}

    {bf:hildasetup} -  Creates a longitudinal dataset for the Household, Income and Labour Dynamics in Australia (HILDA) Survey
	
	
{title:Syntax}

{p 8 12}{cmd:hildasetup} , {cmdab:data:directory}({it:string}) {cmdab:saving:directory}({it:string}) {cmdab:file:name}({it:string}) {cmdab:var:iables}({it:string}) {cmdab:rel:ease}({it:#}) [{it:options}]


{it:options}		description
{hline}

Main
{cmdab:data:directory}({it:string})		specifies the directory in which the original HILDA files are located
{cmdab:saving:directory}({it:string})		specifies the directory in which the resulting longitudinal HILDA file will be placed
{cmdab:file:name}({it:string})			specifies the name to be given to the resulting longitudinal HILDA file
{cmdab:var:iables}({it:string})			specifies the subset of variables from the HILDA longitudinal files to be used
{cmdab:rel:ease}({it:integer})			specifies the release of HILDA data used
{cmdab:master:file}			   specifies the subset of variables from the HILDA Master file to be used 
{cmdab:lw:file}				   specifies the subset of variables from the HILDA Longitudinal Weights file to be used  
{cmdab:unconf:identialised}		   is used when Unconfidentialised/In-confidence rather than General Release HILDA data is used 

{hline}


{title:Description}

{p 0 4}	{cmd:hildasetup} creates a longitudinal dataset for the Household, Income and Labour Dynamics in Australia (HILDA) Survey, one of the largest household panel surveys in the world.
As is customary for household panel surveys, HILDA data are disseminated as a collection of cross-sectional files which need to be combined by the user. The command {cmd:hildasetup} is designed
to substantially simplify and speed up the process of combining the information in HILDA, and supports variables contained in the 'Combined' longitudinal files, the 'Master' file, and the
'Longitudinal Weights' file featured in each release of the HILDA survey. Users are required to specify the directories in which the original data is located and where the new file will
be stored; the variables in the longitudinal HILDA files that are required; the preferred name for the longitudinal dataset to be created; and the data release used. Additionally, users have
the option to specify whether they require any variables from the 'Master' or 'Longitudinal Weights' data files. The longitudinal file produced by {cmd:hildasetup} has a 'long' format.

 
{title:Options}
	
{p 0 4}{cmdab:data:directory}({it:string}) specifies the directory in which the original HILDA files are located.
Note that this can be specified within quotation marks and should not include a backslash at the end.
For instance, {cmd:datadirectory("C:\Data")} would be appropriate whereas {cmd:datadirectory(C:\Data)} or {cmd:datadirectory("C:\Data\")} would not be appropriate.
Note also that the name of the original HILDA files should not have been altered beforehand.

{p 0 4}{cmdab:saving:directory}({it:string}) specifies the directory in which the resulting longitudinal HILDA file will be placed.
Note that this can be specified within quotation marks and should not include a backslash at the end.
For instance, {cmd:datadirectory("C:\Mydata")} would be appropriate whereas {cmd:datadirectory(C:\Mydata)} or {cmd:datadirectory("C:\Mydata\")} would not be appropriate.
Note also that you must have writing permission onto this directory.

{p 0 4}{cmdab:file:name}({it:string}) specifies the name to be given to the resulting longitudinal HILDA file.
Note that this should be a single word (or a string of words joined by underscores) and adhere to Windows file naming conventions.
There is no need to specify the file extension (i.e. .dta).

{p 0 4}{cmdab:var:iables}({it:string}) specifies the subset of variables from the HILDA longitudinal files to be used.
Variable names should be introduced without the wave prefixes.
The personal identifier variable 'xwaveid' is assumed to be needed and should not be included in this list.
A variable denoting the wave of the panel to which an observation belongs is created automatically.
The requested variables can be any variables in the datasets named 'Combined' in the original HILDA data folder.
The use of stars to denote groups of variables beginning with a common prefix is allowed, and so is the inclusion of variables which do not appear in every wave of the panel.
If a variable which does not exist in HILDA is requested, the request will be ignored.

{p 0 4}{cmdab:rel:ease}({it:integer}) specifies the release of the HILDA data to be used (e.g. 10 or 11).
Note that only the first version of a release is currently allowed (e.g. version 10 but not 10.1).

{p 0 4}{cmdab:master:file} specifies the subset of variables from the HILDA Master file to be used.
The personal identifier variable 'xwaveid' is assumed to be needed and should not be included in this list.
Note however that some of the variables are in this dataset are in 'wide' format by default.
The use of stars to denote groups of variables beginning with a common prefix is allowed.
If a variable which does not exist in HILDA is requested, the request will be ignored.

{p 0 4}{cmdab:lw:file} specifies the subset of variables from the HILDA Longitudinal Weights file to be used.
The personal identifier variable 'xwaveid' is assumed to be needed and should not be included in this list.
The use of stars to denote groups of variables beginning with a common prefix is allowed.
If a variable which does not exist in HILDA is requested, the request will be ignored.

{p 0 4}{cmdab:unconf:identialised} must be specified when Unconfidentialised/In-confidence rather than General Release HILDA data is used.



{title:Example}

{p 2 2}{inp:. hildasetup, data("D:\Data\HILDA") saving("D:\Mydata\HILDA") file(HILDA) var(xwaveid hgage hgsex gcany atw*) rel(11) master(yrenter yrleft) lw(wlea_j)}



{title:References and useful links}
  
{p 4 4} Summerfield, M., Freidin, S., Hahn, M., Ittak, P., Li, N., Macalalad, N., Watson, N., Wilkins, R. and Wooden, M. (2012).
{it: HILDA User Manual – Release 11}. Melbourne Institute of Applied Economic and Social Research, University of Melbourne.

{p 4 4} www.melbourneinstitute.com/hilda/

 
{title:Author}

    Francisco Perales
    School of Social Science
    The University of Queensland
    Brisbane
    QLD 4072
    Australia
    f.perales@uq.edu.au                 

	
	
