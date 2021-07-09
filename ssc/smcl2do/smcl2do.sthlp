{smcl}
{* *! version May 1, 2014 @ 09:23:49}{...}
{viewerjumpto "Syntax" "smcl2do##syntax"}{...}
{viewerjumpto "Description" "smcl2do##description"}{...}
{viewerjumpto "Options" "smcl2do##options"}{...}
{viewerjumpto "Remarks" "smcl2do##remarks"}{...}
{viewerjumpto "Examples" "smcl2do##examples"}{...}
{viewerjumpto "Stored Results" "smcl2do##stored_results"}{...}
{* {viewerjumpto "Acknowledgements" "smcl2do##acknowledgements"}}{...}
{viewerjumpto "Author" "smcl2do##author"}{...}
{* {viewerjumpto "References" "smcl2do##references"}}{...}
{...}
{vieweralsosee "log" "help log "}{...}
{vieweralsosee "splitlog" "help splitlog "}{...}
{...}
{title:Title}

{phang}
{cmd:smcl2do} {hline 2} convert a SMCL log file to a do-file
{p_end}


{marker syntax}{...}
{title:Syntax}
{* put the syntax in what follows. Don't forget to use [ ] around optional items}
{p 8 17 2}
   {cmd: smcl2do}
   {help using} {it:filename}
   [{cmd:,}
   {it:options}
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{* {synopt:{opt min:abbrev}}description of what option{p_end}}{...}
{* {synopt:{opt min:abbrev(arg)}}description of another option{p_end}}{...}
{synopt:{opt saving(do-file)}}file in which to save the do-file{p_end}
{synopt:{opt replace}}replace {it:do-file} if it exists{p_end}
{synopt:{opt all}}keep all commands, even those which caused errors{p_end}
{synopt:{opt clean}}get rid of non-programmatic commands, such as {cmd:help} and {cmd:edit}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:smcl2do} turns a SMCL log file into a do-file. By default, {cmd:smcl2do} strips all commands which resulted in errors.
Thus, the resulting do-file should run flawlessly (except for such things as writing files which already exist). 
{p_end}


{marker options}{...}
{title:Options}

{phang}{opt saving(do-file name)} gives a filename to save the resulting do-file.
If not specified, the name defaults to the {it:using} filename with a {cmd:.do} extension.
{p_end}

{phang}{opt replace} allows an exising {it:do-file name} to be overwritten.
{p_end}

{phang}{opt all} writes all commands from the log file to the do-file, including those which did not complete.
{p_end}

{phang}{opt clean} strips out commands which have no direct consquence for the data, dataset, or any analysis:
{help browse}, {help db}, {help doedit}, {help edit}, {help help}, {help projmanager}, {help search}, {help varmanage}, {help view}, and {help viewsource}.
{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:smcl2do} turns a SMCL log file into a do-file, doing its best to ensure that the resulting do-file will run.
This can be very useful for recovering commands from a long logged Stata session, because it can be done long after the session is over.
{p_end}

{pstd}
{cmd:smcl2do} can handle many complicated constructs: loops, Mata, wrapped lines, {help do} commands, and continued commands.
{p_end}

{pstd}
The default extension of the {cmd:using} {it:filename} is {cmd:.smcl} and the default extension of the saved file is {cmd:.do}.
{p_end}

{pstd}If you would like to experiment with it, try making a do-file which keeps a log, and then use {cmd:smcl2do} to turn the log file back into a do-file.
You should see that the resulting do-file will match the original well, except for keeping its own log.
{p_end}

{pstd}
There are a few restrictions which are needed to make the resulting do-file work properly:
{p_end}

{pmore}
If you have {help do} commands within loops, they must be run {help quietly}. Without {cmd:quietly} the commands echoed by the do-file get included in the do-file created by {cmd:smcl2do}, and hence would be run twice.
{p_end}

{pmore}Mata blocks should be started with
{p_end}
{pmore2}{cmd:mata}
{p_end}
{pmore}and not with
{p_end}
{pmore2}{cmd:mata:}
{p_end}
{pmore}The problem with the latter form is that any Mata command which causes an error jumps back to Stata without an {cmd:end} command, thus making any resulting do-file buggy.
{p_end}

{pmore}The maximum length command is 255 characters, because this is the maximum {help linesize} which can be handled using the {help translate} command.
{p_end}

{pmore}Do not use any {cmd:{c -(}com{c )-}.} or {cmd:{c -(}com{c )-}:} SMCL directives (you shouldn't be doing this anyway).
{p_end}

{marker examples}{...}
{title:Examples}{* Be sure to change Example(s) to either Example or Examples}

{phang}{cmd:. smcl2do somelog}{break}
turns the log file {cmd:somelog.smcl} into the do-file {cmd:somelog.do}, excluding all the commands which did not complete because of errors or interruptions.
{p_end}

{phang}{cmd:. smcl2do somelog, all}{break}
turns the log file {cmd:somelog.smcl} into the do-file {cmd:somelog.do}, including all the commands from the log file, including those which did not complete.
{p_end}

{phang}{cmd:. smcl2do somelog, clean}{break}
turns the log file {cmd:somelog.smcl} into the do-file {cmd:somelog.do}, excluding all the commands which did not complete and also excluding commands such as {cmd:help} and {cmd:edit}. 
{p_end}


{marker stored_results}{...}
{title:Stored results}

{pstd}None
{p_end}


{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org/Stata":http://louabill.org/Stata}
{p_end}
