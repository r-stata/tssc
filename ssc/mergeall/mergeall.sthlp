{smcl}
{* *! version 0.1  14sep2010}{...}
{cmd:help mergeall}
{hline}

{title:Title}

    {hi:mergeall} -- A safe way to merge many files

{title:Syntax}

{p 8 17 2}
{cmdab:mergeall} {varlist} {cmd: using} {it: folder}
[{cmd:,} {it:options}]

{help varlist} is the match variables that uniquely identify observations. It is required.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt csv}}files to be merged are .csv (default){p_end}
{synopt:{opt txt}}files to be merged are .txt{p_end}
{synopt:{opt dta}}files to be merged are .dta{p_end}
{synopt:{opt tab}}insheet tab delimited data{p_end}
{synopt:{opt comma}}insheet comma delimited data{p_end}
{synopt:{opt double}}insheet all numeric variables as double. See {help format}{p_end}
{synopt:{opt format}}specify a format to be used in the event that a numberic variable must be converted to string. See {help tostring} and {help format}{p_end}
{synopt:{opt do(filename)}}runs the specified do file on each individual file before merging{p_end}
{synopt:{opt strings(varlist)}}force the varlist to string format and all others to numeric{p_end}
{synopt:{opt force}}forces conversion to string or numeric. Required with the string option.{p_end}
{synopt:{opt showsource}}generates a new string variable containing the name of the file each observation was drawn from.{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:mergeall} merges all of the files in a folder without loss of data due to variable storage types or duplicate unique identifiers.
				
{title:Remarks}

{pstd}
{cmd: mergeall} loops through all of the files in the folder
you specify, checking variable types before merging.  It sets all
variables that are string in any file to be string in every file 
to prevent loss of data. By default, Stata forces the variable
type of the master file on the using file, which can result in
lost data.

{pstd}
{cmd: mergeall} requires a unique identifier to be specified
and exits with error if the identifier is not unique within files. 
A unique identifier is required because Stata can sometimes merge 
in unexpected ways when there is no unique identifier, 
and the goal of mergeall is to make merging many files super-safe.

{pstd}
{cmd: mergeall} Performs 1 to 1 merges using Stata10 style merging
and creates a new variable, {it:_disagreement}, which equals 1 if an observation
exists in two or more datasets, and the datasets disagree on its value.
If {it:_disagreement} equals 1, you have lost information.

{pstd}
If you are so inclined, you can run a cleaning .do
file on each dataset before merging using {opt do(filename)} (this is
useful for fixing errors in unique identifiers, for example). 

{pstd}
{opt strings} is probably a bad idea because it can result in the loss of
data, but if you are very sure you won't lose data, it runs a little faster. 

{pstd}
The {opt showsource} option is useful for troubleshooting when you want to
return to the raw data to check values, but you don't know which raw file
contains the observation you are looking for.

{title:Also see}

{psee}
Online:  {manhelp merge D} {manhelp append D}, {manhelp cross D}, {manhelp joinby D},
{manhelp save D}, {manhelp sort D}

{title:Author}

{phang}
Ryan Knight, rknight at poverty-action.org
