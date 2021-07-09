
{smcl}
{* *! Version 1.3.0 by Francisco Perales 17-July-2019}{...}
{bf:help lsacsetup}
{hline}


{title:Title}

    {bf:lsacsetup} -  Creates a longitudinal dataset for Growing Up in Australia: The Longitudinal Study of Australian Children (LSAC)
	
	
{title:Syntax}

{p 8 12}{cmd:lsacsetup} , {cmdab:data:directory}({it:string}) {cmdab:saving:directory}({it:string}) {cmdab:file:name}({it:string}) {cmdab:var:iables}({it:string}) {cmdab:rel:ease}({it:#}) [{it:options}]


{it:options}		description
{hline}
Main
{synopt:{opt data:directory}({it:string})} specifies the directory in which the original LSAC files are located{p_end}
{synopt:{opt saving:directory}({it:string})} specifies the directory in which the resulting longitudinal LSAC file will be placed{p_end}
{synopt:{opt file:name}({it:string})} specifies the name to be given to the resulting longitudinal LSAC file{p_end}
{synopt:{opt var:iables}({it:string})} specifies the subset of variables from the LSAC longitudinal files to be used{p_end}
{synopt:{opt rel:ease}({it:integer})} specifies the release of LSAC data used{p_end}
{synopt:{opt hh:file}} specifies the subset of variables from the LSAC household file to be used {p_end}
{synopt:{opt naplan:file}} specifies the subset of variables from the LSAC NAPLAN file to be used {p_end}
{synopt:{opt nomid:wave}} supresses the use of LSAC's between-wave questionnaires (a.k.a. waves 2.5 and 3.5){p_end}
{hline}


{title:Description}

{p 0 4}	{cmd:lsacsetup} creates a longitudinal dataset for Growing Up in Australia: The Longitudinal Study of Australian Children (LSAC), Australia's flagship birth cohort study,
using a single line of Stata code. LSAC data are disseminated as a collection of cross-sectional files which need to be combined by the user. The command {cmd:lsacsetup} is designed
to substantially simplify and speed up the process of combining the information in LSAC into a single analytic dataset in long format. {cmd:lsacsetup} supports variables contained
in the LSAC longitudinal files (e.g., lsacgrb0), the household files (e.g., plegrhhb), and the NAPLAN files (e.g., lsacnaplanacara_gr/lsacnaplan) featured in the general release of LSAC.
Users are required to specify the directories in which the original data are located and where the new file will be stored; the variables in the longitudinal LSAC files that are required;
the preferred name for the longitudinal dataset to be created; and the data release used. Additionally, users have the option to specify whether they require any variables from the
household or NAPLAN data files, and whether they wish to use information from LSAC's between-wave questionnaires (a.k.a. waves 2.5 and 3.5). {cmd:lsacsetup} currently supports
only the general release of LSAC and does not handle variables from LSAC data files not mentioned in this description (e.g., the PLE, TUD or Medicare files).

 
{title:Options}
	
{p 0 4}{cmdab:data:directory}({it:string}) specifies the directory in which the original LSAC files are located.
Note that this can be specified within quotation marks and should not include a backslash at the end.
For instance, {cmd:datadirectory("C:\Data")} would be appropriate whereas {cmd:datadirectory(C:\Data)} or {cmd:datadirectory("C:\Data\")} would not be appropriate.
Note also that the name of the original LSAC files should not have been altered beforehand.

{p 0 4}{cmdab:saving:directory}({it:string}) specifies the directory in which the resulting longitudinal LSAC file will be placed.
Note that this can be specified within quotation marks and should not include a backslash at the end.
For instance, {cmd:datadirectory("C:\Mydata")} would be appropriate whereas {cmd:datadirectory(C:\Mydata)} or {cmd:datadirectory("C:\Mydata\")} would not be appropriate.
Note also that the user must have writing permission onto this directory.

{p 0 4}{cmdab:file:name}({it:string}) specifies the name to be given to the resulting longitudinal LSAC file.
Note that this should be a single word (or a string of words joined by underscores) and adhere to Windows file naming conventions.
There is no need to specify the file extension (i.e., .dta).

{p 0 4}{cmdab:var:iables}({it:string}) specifies the subset of variables from the LSAC longitudinal files to be used.
Variable names should be introduced without the wave prefixes.
Variables identifying the child (i.e., hicid), the cohort (i.e., cohort) and the wave (i.e., wave) are automatically included in this list.
The requested variables can be any variables in the datasets with names beginning 'lsacgr*' in the original LSAC data folder.
The use of stars to denote groups of variables beginning with a common prefix is allowed, and so is the inclusion of variables which do not appear in every wave of the panel.
If a variable which does not exist in LSAC is requested, the request will be ignored.

{p 0 4}{cmdab:rel:ease}({it:integer}) specifies the release of the LSAC data to be used (e.g., 7).

{p 0 4}{cmdab:hh:file} specifies the subset of variables from the LSAC household files (hhgrb & hhgrk) to be used.
The use of stars to denote groups of variables beginning with a common prefix is allowed.
If a variable which does not exist in LSAC is requested, the request will be ignored.

{p 0 4}{cmdab:naplan:file} specifies the subset of variables from the LSAC naplan file (lsacnaplanacara_gr/lsacnaplan) to be used.
{ul:Important:} The NAPLAN file must be manually relocated by the user to the folder in which the longitudinal files are stored for this option to work.
The use of stars to denote groups of variables beginning with a common prefix is allowed.
If a variable which does not exist in LSAC is requested, the request will be ignored.

{p 0 4}{cmdab:nomid:wave} supresses the use of LSAC's between-wave questionnaires (a.k.a. waves 2.5 and 3.5)



{title:Example}

{p 2 2}{inp:. lsacsetup, data("D:\Data\LSAC") saving("D:\Mydata\LSAC") filename(LSAC) release(7) var(zhb05c zbf6mth bwpct prel asdqta asdqtb asdqtb csdqtb) hhfile(aweights cdwt) naplanfile(stream y3write) nomid}



{title:References and useful links}
  
{p 4 4} Australian Institute of Family Studies. (2018). The Longitudinal Study of Australian Children: Data User Guide – December 2018. Melbourne: Australian Institute of Family Studies.
  
{p 4 4} http://www.growingupinaustralia.gov.au/

 
{title:Author}

Francisco Perales
ARC Centre of Excellence for Children and Families over the Life Course,
Institute for Social Science Research, The University of Queensland
f.perales@uq.edu.au                 

	
	
