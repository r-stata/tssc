{smcl}
{* *! version 1.0 20.12.2018}{...}
{title:Title}
{phang}
{cmd:expandihlp} {hline 2} inserts the content of .ihlp-files into .sthlp-files 

{title:Description}
{cmd:expandihlp} is a tool meant for programmers who want to include the same text in the help-files for their programs. 
The standard way to do so is via the "INCLUDE help something" SMCL-directive which integrates the content of something.ihlp into the .sthlp file.
However, you have to distribute the .ihlp-files if you want to use this approach for a program being installed by someone else.
{cmd:expandihlp} reads the .sthlp-file, searches for "INCLUDE help something" SMCL-directives and integrates the content of something.ihlp into the .sthlp file like the Stata viewer would do.
By default {cmd:expandihlp} tests for the existince of the directives, reports the numbers (and names) and creates a new file named "program_expanded.sthlp" which contains the integrated content and leaves the original file unchanged. 

The full path to the help file can be provided, but the command will look for the help file in the standard search paths.
{title:Syntax}
{phang}
{cmd:expandihlp}  , {cmdab:f:ile(string)}[ {cmdab:ren:ame} {cmdab:not:est} {cmdab:suf:fix(string)} ] 

{synoptline}
{synoptset 15 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt :{opt f:ile}(string)} specify the helpfile with or without the .sthlp extension. The full path to the help file can be provided, but the command will look for the help file in the standard search paths. {p_end}
{synopt :{opt not:est}} do not test for the existince of "INCLUDE"-directives and expands the file irrespective whether .ihlp files and display the number (and the name of the files) to be included. 
If no "INCLUDE"-directives are found, then the command is aborted. {p_end}
{synopt :{opt ren:ame}} renames the newly created file "program_expanded.sthlp" to "program.sthlp" and "program.sthlp" to "program_old.sthlp"{p_end}
{synopt :{opt suf:fix}} changes the suffix of the newly created file. By default the suffix "_expanded" is added to the program name.{p_end}

{title:Examples}
Expands the help file for this program, changes the suffix for the new file and replaces the original file with the expanded file.
{tab}{cmd: expandihlp, file(expandihlp) ren suf(_parsed)}

{title:Saved results}
{synoptset 15 tabbed}{...}
{cmd:expandihlp} saves the following in {cmd:r()}:
{p2col 5 20 24 2: Macro}{p_end}
{synopt: {cmd:r(inccnt)}}the number of files included.{p_end}
{synopt: {cmd:r(incfiles)}}the expanded and included ihlp-files. {p_end}
{synopt: {cmd:r(origfile)}}the filename of the original help-file. {p_end}
{synopt: {cmd:r(expfile)}}the filename of the expanded help-file. {p_end}
{* p2colreset}{...}

{title:Author}
Sven-Kristjan Bormann, PhD student, School of Economics and Business Administration, University of Tartu 

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools}{p_end}




