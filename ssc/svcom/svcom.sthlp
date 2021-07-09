{smcl}
{* *! version 1.0  22feb2018 Dennis Lund Hansen dlh@dadlnet.dk}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "svcom##syntax"}{...}
{viewerjumpto "Description" "svcom##description"}{...}
{viewerjumpto "Limits" "svcom##limitis"}{...}
{viewerjumpto "Options" "svcom##options"}{...}
{viewerjumpto "Examples" "svcom##examples"}{...}
{viewerjumpto "Acknowledgements" "svcom##acknowledgements"}{...}
{viewerjumpto "Stored scalars" "svcom##storedscalars"}{...}
{title:Title}

{phang}
{bf:svcom} {hline 2} save command output and comments to log, without additonal logging noise



{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmdab:svcom:}
logname
:
command 
[{cmd:,} {it:command_options {opt head:line(txt)} {opt note:txt(txt)} {opt nocom:mand}  {opt noli:ne} {opt dup:licate} permanent_options}]

{it: 	where:}
{phang2}logname is the reference name of the log, specified in {cmd: log using "path\name", name(logname)}{p_end} 
{phang2}command is the command from which the output derives.{p_end}



{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:logname}
{synopt:{opt logname}}only needs to be defined first time either 
{cmd:svcom} or {helpb svtxt} is used{p_end}

{syntab:Main}
{synopt:{opt command_options}}options from the command in focus{p_end}
{synopt:{opt head:line(txt)}}displays txt and command as headline above output {p_end}
{synopt:{opt note:txt(txt)}}displays txt as explanatory notes below output{p_end}
{synopt:{opt nocom:mand}}turn off the inclusion of the command in headline{p_end}
{synopt:{opt dup:licate}}duplicates the command as a normal command in the main log-file right before the cleaned version{p_end}
{synopt:{opt noli:ne}}removes the line drawn before and after the output from svcom{p_end}

{syntab:Permanent options}
{synopt:{opt nocommand:permanent(on/off)}}turns {cmd:nocommand} permantly on in the logfile until the off command is given{p_end}
{synopt:{opt duplicate:permanent(on/off)}}turns {cmd:duplicate} permantly on in the logfile until the off command is given{p_end}
{synopt:{opt noline:permanent(on/off)}}turns {cmd:noline} permantly on in the logfile until the off command is given{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} and {cmd:bysort} are not supported by {cmd:svcom}, but can be used as normally 
with the command given after the colon.


{marker description}{...}
{title:Description}

{pstd}
{cmd:svcom} is intended to make an output file or log file with a more readable and coherent content.{p_end}
{pstd} 
A stata log, if made for documentatation of the work process tends to be large and containing a huge amount of information
about the work-up process and a lot of intermediate information.{p_end}
{pstd}
This can "disguise" the relevant results and make it tedious to find them, especially in large log files,
where there are a lot of data transformations between results.{p_end}
{pstd}
Stata is generic, offering the possibility of using muliple logs 
where one or more can be turned on/off with the {cmd:log on} - {cmd:log off} commands. 
But this places redundant noice of logname and time in the log. 
Even if the {cmd:quietly} command is used there will be some extra noise and a tedious amout of extra lines to be writen in the do-file.{p_end}
{pstd}
Further, the use of {cmd:log on} - {cmd:log off} will erase the content of the r-class,
making it impossible to cite newly performede calcualtions by the use of the local result macro.
This can be handled by more lines of code saving the results in new local macros or the use of {cmd:svcom}. 

{pstd}
{cmd:svcom} offers an easy, usable solution to this. Where the logfile can be distributede e.g. 
among colleagues in a research group in easily readable form without noise.
This is achivede by a wrapper to normal stata commands, without the need for extra compiling and extra mark up.
Being simple to use, there are certain limitation in the command,
and it is not meant for e.g. writing complete manuscripts.
But can be used for less text burdend standard reports and internal documents 
(including specified result output for manuscripts or retrievable reports from a 
secure data area where a normal log would be at risk of unintentionally containing  unallowed material).  

{marker limits} {...}
{title:Limits}

{pstd}
Graphic output (e.g.: {helpb graph} or {helpb hist}), can be used with {cmd:svcom} 
but the output is not incorporated in the logfile - just as standard in stata. 
If graphic output has to be placed in the logfile consider {helpb graphlog}, 
{helpb markdoc} or {helpb texdoc}.

{pstd}
{cmd:svcom} can be used with {helpb display} and {helpb smcl}-directives, 
but it is not recommend to write longe texts or to use commas, 
as this will result in a syntax error, 
{helpb svtxt} is intended to complement {cmd:svcom} when there is a need for a large text output.


{marker options}{...}
{title:Options}

{dlgtab:Log}

{phang}
{opt logname} only needs to be specified the first time or if you change log. 
The name is stored and reused. If you are using different logs to store results, 
remember to specify logname every time you are changing log. Logname is 
reused by both {cmd:svcom} and {cmd:svtxt}.

{dlgtab:Main}

{phang}
{opt headline(txt)} displays the txt as headline above the output.
Accepts a variety of {help smcl}-directives, including {cmd: {break}} for line breaks.{p_end}

{phang}
{opt notetxt(txt)} displays the txt as a note below the output.
Accepts a variety of {help smcl}-directives, including {cmd: {break}} for line breaks{p_end}

{phang}
{opt nocommmand} prevents the display of the {it:command} in the headline. 
Standard is to display the input command. 
The combination of not specifying the heading and using the nocommand will be 
a complete absence of text before the output. {p_end}


{phang}
{opt duplicate} one problem with {cmd:svcom} is that it will obscure the input of the command in focus a bit,
as it blends with the options for svcom. Turning on the duplicate option will
 allow the command to be displayed and executed as normal,
right before the cleaned input that will be copied in the result log.{p_end}

{phang}
{opt noline} standard for {cmd: svcom} is to issue a line before the headline and after the notetext.
{cmd: noline} turns this function off.{p_end}

{dlgtab:Permanent options}

{phang}
{opt nocommandpermanent(on/off)} same functions as  {opt nocommand} options above. 
If the "on" option is given, command will not be showen in the headline, 
until the "off" option is given again.
Default is "off", i.e. command is shown in the headline.

{phang}
{opt duplicatepermanent(on/off)} same function as {opt duplicate} above, 
turns on duplication mode, but works from the "on"
 is specified until the "off" option is specified again. Default is "off", i.e.
 not duplication command in the main logfile.

{phang}
{opt nolinepermanent(on/off)} same function as {opt duplicate} above, 
turns noline mode permanently on, until the "off" option is specified.
Default is "off" i.e. printing line before and after execution of {cmd: svcom}.


{marker examples}{...}
{title:Examples}

{pstd}
The basic use of {cmd: svcom} is illustrated in this example. 
After the colon you type in the command as usual.

{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - basicsvcom}{...}
	* Display of basic functionality in svcom
	* In this display only one log is active
	set more off
	
	log using one-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	
	svcom results : tab rep78
	
	svcom : tab rep78 foreign, row
	
	log close results
	view one-log.smcl
	
	* clearning up
	rm one-log.smcl
		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svcom_run basicsvcom using svcom.sthlp:click to run})}

{pstd}
The following example uses headlines and notes to explain the output.
The note and headline accept a variety of {cmd:smcl} commands, 
including {cmd:{c -(}break{c )-}}, {cmd:{c -(}it{c )-}} 
and {cmd:{c -(}ul{c )-}}.{p_end}

{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - textsvcom}{...}
	* Adding text to the logfile
	* In this display only one log is active
	set more off
	
	log using one-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	
	svcom results : tab rep78, headline(First tabel) ///
	note(This is a one-way table)
	
	svcom : tab rep78 foreign, row ///
	headline(Second table, including row-percentages) ///
	notetxt(This is a two-way table, but still a bit meaningless. ///
	Please note that the first and second table have short ///
	horisontal lines before and after them)
	
	svcom : tab rep78 foreign, row nocommand noline ///
	headline(Third table, including row-percentages) ///
	notetxt(The lines and the inclusion of the command in the headline ///
	can be removed with the use of noline and nocommand)
	
	svcom : proportion rep78, over(foreign) nocommand noline ///
	headline(Use of proportion) ///
	notetxt(the use of noline can make the output look more coherent, ///
	but also a bit more confusing, if you are looking for something particular.)
	
	log close results
	view one-log.smcl
	
	* clearning up
	rm one-log.smcl
		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svcom_run textsvcom using svcom.sthlp:click to run})}

{pstd}
The permanent options work in the same way, only that they turn the option on 
or off until the options are changed. 

{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - permsvcom}{...}
	* Adding text to the logfile
	* In this display, only one log is active
	set more off
	
	log using one-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	
	svcom results : tab rep78, headline(First tabel) ///
	note(This is a one-way table, made by the command {it: tab rep78}. ///
	The command in the headline has been removed, ///
	but the demarcation lines are still there.) ///
	nocommandpermanent(on)
	
	svcom : tab rep78 foreign, ///
	headline(Second table) ///
	notetxt(This is a two-way table, made by the command {it: tab rep78 foreign}. ///
	Please note, there is no command in the headline ///
	and no line before or after the output.) ///
	nolinepermanent(on)
	
	svcom : tab rep78 foreign, row ///
	headline(Third table, including row-percentages) ///
	notetxt(This table has still no command in the headline and no demarcation line)
	
	svcom : tab foreign, plot ///
	notetxt(if "headline()" is empty, this plain output will be the result) 
	
	svcom : proportion rep78, over(foreign) ///
	headline(Use of proportion) ///
	notetxt(Demarcation lines are back) ///
	noline(off)
	
	log close results
	view one-log.smcl
	
	* cleaning up
	rm one-log.smcl
		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svcom_run permsvcom using svcom.sthlp:click to run})}

{pstd}
This last example reuses the former one, adding the duplicate option, and 
showing both the unfiltered and the restricted log.
It also shows a possible use of the {cmd:by} prefix.

{space 8}{hline 10} {it:example do-file content} {hline 10}
{cmd}{...}
{* example_start - twosvcom}{...}
	* Adding text to the logfile
	* In this display there are two active logs
	set more off
	
	log using first-log.smcl, replace
	log using second-log.smcl, replace name(results)
	log off results
	sysuse auto, clear
	
	svcom results : tab rep78, headline(First tabel) ///
	note(This is a one-way table, made by the command {it: tab rep78}. ///
	The command in the headline has been removed, ///
	but the demarcation lines are still there.) ///
	nocommandpermanent(on) ///
	duplicate
	
	svcom : tab rep78 foreign, ///
	headline(Second table) ///
	notetxt(This is a two-way table, made by the command {it: tab rep78 foreign}. ///
	Please note, there is no command in the headline ///
	and no line before or after the output.) ///
	nolinepermanent(on)
	
	svcom : tab rep78 foreign, row ///
	headline(Third table, including row-percentages) ///
	notetxt(This table has still no command in the headline and no demarcation line)
	
	svcom : tab foreign, plot ///
	notetxt(if "headline()" is empty, then this plain output will be the result) 
	
	svcom : bysort foreign : tab rep78, plot ///
	headline(Use of bysort in combination with svcom) ///
	notetxt(Demarcation lines is back) ///
	noline(off) ///
	duplicate
	
	log close _all
	view first-log.smcl 
	view second-log.smcl
	
	* clearning up
	rm first-log.smcl
	rm second-log.smcl
		
{* example_end}{...}
{txt}{...}
{space 8}{hline 45}
{space 8}{it:({stata svcom_run twosvcom using svcom.sthlp:click to run})}



{marker acknowledgements}
{title:Acknowledgements}
{pstd}
Thanks to Robert Picard for writing the{cmd: rangerun_run.ado} command and allowing the 
reuse of it in the example do-files in this help-file and in the 
help-file for {helpb svtxt}.

{pstd}
Thanks to countless answeres, to me or other, on the statalist for providing indirect help 
for this little project and other stata problems.

{pstd}
Thanks Nich Cox, Clyde Schecter and Jens Lauritsen for providing answers 
directly relvant for this program.


{marker storedscalars}
{title:Stored Scalars}
{pstd}
In order to remember the permant options, {cmd: svcom} leaves behind up to four scalars containg 
information about logname and settings.{p_end}

{synoptset 30 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:sv_lognavn_dvpd}} name of the log{p_end}
{synopt:{cmd:scalar_nocommand_permanent}} informaton if nocommand is permanently on or off{p_end}
{synopt:{cmd:scalar_noline_permanent}} information if noline is permantly on or off{p_end}
{synopt:{cmd:scalar_duplicate_permanent}} information if duplicate is permanently on or off{p_end}


{title:Author}
Dennis Lund Hansen
MD, PhD-fellow
Odense University Hospital, 
Department of Haematology
dlh@dadlnet.dk
