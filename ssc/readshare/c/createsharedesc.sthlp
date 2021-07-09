{smcl}
{* *! version 0.1  28oct2016}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:createSHAREDesc} {hline 2} Create SHARE variables description table


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:createSHAREDesc}
[{cmd:,} {it:options}]

{synoptset 14 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth sDir(string)}}Folder with SHARE data directories{p_end}
{synopt :{opth dirs(string)}}SHARE data directories given as separate paths{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:createSHAREDesc} is used to create SHARE data description table 
to be further used together with {helpb readSHARE}. 

{pstd}
The command requires SHARE data to be located in one folder (with subfolders),
with data for each wave located in a separate subfolder. The folder with SHARE data can 
be provided both as a {bf:sDir(path)} option and manually after
running {cmd:createSHAREDesc} without any options.

{pstd}
The program will access every subfolder found in the folder given
as the parameter and will search for .dta files.
Based on the filename it finds it will extract module names and the corresponding wave number. It is thus 
important to keep the original SHARE file naming convention (as in the official release).

{pstd}
For every module the program reads variable names and variable labels and creates a data description table in the .dta format.

{pstd}
Using the {bf:dirs()} option allows alternative location names for SHARE data. 
In such cases the folders need to be provided using separate paths, e.g.
{bf:dirs(}"C:\SHARE\W1" "C:\SHARE\W2" "C:\SHARE\W3" "C:\SHARE\W4"{bf:)}. 
Complete paths need to be provided.

{pstd}
The final data description .dta file is not saved automatically and has to be saved after
the program has finished running. At the end the program will display
globals to be set before running other SHARE tool data commands (such as readSHARE and addSHARE). A global
macro {bf:shareDesc} has to be set by the user with the path where the data description .dta has been saved.


{marker remarks}{...}
{title:Remarks}

{pstd}
In case of questions or errors please contact: 

{pstd}
Mateusz Najsztub: {it:mnajsztub@cenea.org.pl}.


{marker examples}{...}
{title:Examples}

{pstd}Prompt for the SHARE data path{p_end}
{phang2}{cmd:. createSHAREDesc}{p_end}

{pstd}Create the description table using share data directory as a parameter{p_end}
{phang2}{cmd:. createSHAREDesc, sDir("C:\Documents\SHARE\data\")}{p_end}

{pstd}Create the description table with data directories set as parameters{p_end}
{phang2}{cmd:. createSHAREDesc, dirs("C:\SHARE\W1" "C:\SHARE\W2" "C:\SHARE\W3" "C:\SHARE\W4")}{p_end}

