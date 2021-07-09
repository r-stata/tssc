{smcl}
{* *! version May 1, 2014 @ 09:16:56}{...}
{viewerjumpto "Syntax" "splitlog##syntax"}{...}
{viewerjumpto "Description" "splitlog##description"}{...}
{viewerjumpto "Options" "splitlog##options"}{...}
{viewerjumpto "Remarks" "splitlog##remarks"}{...}
{viewerjumpto "Examples" "splitlog##examples"}{...}
{viewerjumpto "Stored Results" "splitlog##stored_results"}{...}
{viewerjumpto "Author" "splitlog##author"}{...}
{...}
{vieweralsosee "log" "help log "}{...}
{vieweralsosee "smcl2do" "help smcl2do "}{...}
{...}
{title:Title}

{phang}
{cmd:splitlog} {hline 2} marks and numbers commands and results in a Stata log file
{p_end}


{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 8 17 2}
   {cmd: splitlog}
   {help using}
   {it:{help filename}}
   [{cmd:,}
   {it:options}
   {it:{help splitlog##tag:tag format options}}
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{* {synopt:{opt min:abbrev}}description of what option{p_end}}{...}
{* {synopt:{opt min:abbrev(arg)}}description of another option{p_end}}{...}
{synopt:{opt saving(filename)}}file in which to save the split log{p_end}
{synopt:{opt replace}}replace {it:saving} file if it exists{p_end}
{synopt:{opt cmd:only}}save only commands (no results){p_end}
{synopt:{opt res:only}}save only results (no commands){p_end}
{synopt:{opt nonum:ber}}squelch numbering of blocks{p_end}
{synopt:{opt strip(int)}}level of stripping on commands{p_end}
{synopt:{it:tag format options}}(nearly) endless list of formatting options for tags{p_end}


{synoptset 28 tabbed}
{marker tag}{...}
{synopthdr:tag format options}
{synoptline}

{syntab:{it:tagging commands}}
{synoptline}
{synopt:{opt commandname(str)}}name of command environment in split file{p_end}
{synopt:{opt commandnumberingname(str)}}what to call the command numbers{p_end}
{synopt:{opt commandbeginprefix(str)}}prefix of lines marking the start of commands{p_end}
{synopt:{opt commandbeginsuffix(str)}}suffix of lines marking the start of commands{p_end}
{synopt:{opt commandendprefix(str)}}prefix of lines marking the end of commands{p_end}
{synopt:{opt commandendsuffix(str)}}suffix of lines marking the end of commands{p_end}

{syntab:{it:tagging results}}
{synoptline}
{synopt:{opt resultname(str)}}name of result environment in split file{p_end}
{synopt:{opt resultnumberingname(str)}}what to call the result numbers{p_end}
{synopt:{opt resultbeginprefix(str)}}prefix of lines marking the start of results{p_end}
{synopt:{opt resultbeginsuffix(str)}}suffix of lines marking the start of results{p_end}
{synopt:{opt resultendprefix(str)}}prefix of lines marking the end of results{p_end}
{synopt:{opt resultendsuffix(str)}}suffix of lines marking the end of results{p_end}

{syntab:{it:tagging orphans}}
{synoptline}
{synopt:{opt orphanname(str)}}name of orphan environment in split file{p_end}
{synopt:{opt orphannumberingname(str)}}what to call the orphan numbers{p_end}
{synopt:{opt orphanbeginprefix(str)}}prefix of lines marking the start of orphans{p_end}
{synopt:{opt orphanbeginsuffix(str)}}suffix of lines marking the start of orphans{p_end}
{synopt:{opt orphanendprefix(str)}}prefix of lines marking the end of orphans{p_end}
{synopt:{opt orphanendsuffix(str)}}suffix of lines marking the end of orphans{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:splitlog} takes logs in SMCL format and puts tags (specially formatted comments)  before and after each command and its results (if any).
It also marks orphans, which is the output from a command not in the log file (typically the header resulting from a {help log} command).
{cmd:splitlog} is meant as a programmers' utility that allows processing of the commands and results.
An example of this is {help smcl2do}, which uses {cmd:splitlog} to create do-files from log files.
{p_end}

{marker options}{...}
{title:Options}

{phang}{opt saving(filename)} gives a filename to save the split log file.
If not specified, the name defaults to {it:filename}{cmd:_split.smcl}.
{p_end}

{phang}{opt replace} allows an exising {it:filename} to be overwritten.
{p_end}

{phang}{opt cmd:only} saves only the command blocks. This would rarely be used on its own.
{p_end}

{phang}{opt res:only} saves only the result blocks. This would rarely be used on its own. Only one of {cmd:cmdonly} or {cmd:resonly} may be specified.
{p_end}

{phang}{opt nonum:ber} keeps the command and result blocks from being numbered. This, too, would rarely be used on its own.
{p_end}

{phang}{opt strip(int)} tells how much should be stripped from the front of commands.
This is meant to help programmers manipulate log files.
{p_end}

{pmore}0: strips nothing (default) {p_end}
{pmore}1: strips continuation characters {p_end}
{pmore}2: also strips numbering from lines inside of loops {p_end}
{pmore}3: also strips dot and colon prompts {p_end}
{* {pmore}Use -pmore- for additional paragraphs within and option description. }{...}
{* {p_end}}{...}

{phang}Tag formatting options{p_end}
{pmore}{cmd:splitlog} distinguishes among three types of output in the smcl file: commands, results, and orphans.
Each of these output types has five options associated with it, so that formatting of the tags is flexible.
{p_end}

{pmore}The output from type {it:type} starts with a tag built as {p_end}
{pmore2}{it:type}{cmd:beginprefix}+{it:type}{cmd:name}+{it:type}{cmd:numberingname}+#+{it:type}{cmd:beginsuffix}{p_end}
{pmore}where # is the command or orphan number (results share their numbers with commands).{p_end}

{pmore}Then comes the command/results/orphan itself.{p_end}

{pmore}The output from type {it:type} then ends with a tag built as {p_end}
{pmore2}{it:type}{cmd:endprefix}+{it:type}{cmd:name}+{it:type}{cmd:numberingname}+#+{it:type}{cmd:endsuffix}{p_end}
{pmore}where # is again the command or orphan number.{p_end}

{pmore}Here are all the tag options and their default values; note that many of the defaults have leading and/or trailing spaces for aesthetic reasons.{p_end}
{synoptset 30 tabbed}
{synopt:{it:tag option}}{it:default value}{p_end}
{synoptline}
{synopt:{opt commandname(str)}}{cmd:"command "}{p_end}
{synopt:{opt commandnumberingname(str)}}{cmd:" number: "}{p_end}
{synopt:{opt commandbeginprefix(str)}}{cmd:"\*** Begin "}{p_end}
{synopt:{opt commandbeginsuffix(str)}}{cmd:" ***/"}{p_end}
{synopt:{opt commandendprefix(str)}}{cmd:"\*** End "}{p_end}
{synopt:{opt commandendsuffix(str)}}the value of {opt commandbeginsuffix()}, meaning that only one suffix need be specified if both are the same.{p_end}

{synopt:{opt resultname(str)}}{cmd:"result "}{p_end}
{synopt:{opt resultnumberingname(str)}}{cmd:" number: "}{p_end}
{synopt:{opt resultbeginprefix(str)}}{cmd:"\***** Begin "}{p_end}
{synopt:{opt resultbeginsuffix(str)}}{cmd:" *****/"}{p_end}
{synopt:{opt resultendprefix(str)}}{cmd:"\***** End "}{p_end}
{synopt:{opt resultendsuffix(str)}}the value of {opt resultbeginsuffix()}, meaning that only one suffix need be specified if both are the same.{p_end}

{synopt:{opt orphanname(str)}}{cmd:"orphan "}{p_end}
{synopt:{opt orphannumberingname(str)}}{cmd:" number: "}{p_end}
{synopt:{opt orphanbeginprefix(str)}}{cmd:"\******* Begin "}{p_end}
{synopt:{opt orphanbeginsuffix(str)}}{cmd:" *******/"}{p_end}
{synopt:{opt orphanendprefix(str)}}{cmd:"\******* End "}{p_end}
{synopt:{opt orphanendsuffix(str)}}the value of {opt orphanbeginsuffix()}, meaning that only one suffix need be specified if both are the same.{p_end}

{pstd}The {help splitlog##tagdefaults:default appearance} is in the Remarks below.
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:splitlog} takes a SMCL log file and produces another SMCL file where commands, results, and orphaned results are enclosed by special comments. It also tracks the commands which ended in error, so that these could be processed differently by any command consuming the file produced by {cmd:splitlog}.
{p_end}

{pstd}
If the file extensions for the {cmd:using} or {cmd:saving()} filenames are not given, they are assumed to be {cmd:.smcl}.
{p_end}

{marker tagdefaults}{...}
{pstd}
By default, each command is marked
{p_end}
{pmore}
{cmd:/*** Begin command number }{it:num}{cmd: ***/}
{p_end}
{pmore2}{it:some stata command...} 
{p_end}
{pmore}
{cmd:/*** End command number }{it:num}{cmd: ***/}
{p_end}

{pstd}
By default, each result is marked
{p_end}
{pmore}
{cmd:/***** Begin result number }{it:num}{cmd: *****/}
{p_end}
{pmore2}{it:some stata output...} 
{p_end}
{pmore}
{cmd:/***** End result number }{it:num}{cmd: *****/}
{p_end}

{pstd}
By default, each orphan is marked
{p_end}
{pmore}
{cmd:/******* Begin orphan number }{it:num}{cmd: *******/}
{p_end}
{pmore2}{it:some log header...} 
{p_end}
{pmore}
{cmd:/******* End orphan number }{it:num}{cmd: *******/}
{p_end}

{pstd}
Orphans are results not associated with any command.
These arise from {help log} commands starting log files with a header but without the {cmd:log} command itself.
{p_end}

{pstd}Everything resulting from a {cmd:do} command is treated as one big result rather than the series of commands it represents.
{p_end}

{pstd}
{cmd:splitlog} is meant as a programmers' tool for going through SMCL code and marking and number the start and end of commands and their results. Once the chunks have been marked, another program can manipulate them.
{p_end}

{pstd}
There are a few known limitations:
{p_end}
{pmore}
{cmd:splitlog} leaves an extra orphan at the bottom of the split file because of the way that {cmd:log close} adds a bunch of smcl which looks like the start of a header of a new log file.
{p_end}

{pmore}
Using {help do} commands within loops causes problems, because the actual {cmd:do} commands do not get echoed.
This result is that {cmd:splitlog} does not know when to go into result mode, and hence thinks the commands echoed in the results are true commands.
You can work around this by always using {cmd:quietly do} in loops.
{p_end}

{pmore}
Using two very specific SMCL directives: {c -(}com{c )-}. or {c -(}com{c )-}: will trick {cmd:splitlog}.
In reality, this should never be a problem, as these directives are supposed to be used only in producing a log file, and never in any actual {help display} commands.
{p_end}

{marker examples}{...}
{title:Examples}{* Be sure to change Example(s) to either Example or Examples}

{phang}{cmd:. splitlog using somelog}{break}
turns the log file {cmd:somelog.smcl} into the file {cmd:somelog_split.smcl} with commands and results separated by numbered comments.
{p_end}

{phang}{cmd:. splitlog using somelog, saving(justcmds) cmdonly}{break}
turns the log file {cmd:somelog.smcl} into the file {cmd:justcmds.smcl} with commands separated by numbered comments.
None of the results from the {cmd:somelog.smcl} appear in {cmd:justcmds.smcl}.
{p_end}

{phang}{cmd:. splitlog using somelog, saving(justresults) resonly}{break}
turns the log file {cmd:somelog.smcl} into the file {cmd:justresults.smcl} with results separated by numbered comments.
None of the commands from the {cmd:somelog.smcl} appear in {cmd:justresults.smcl}.
{p_end}

{marker stored_results}{...}
{title:Stored results}

{pstd}{* replace r() with e() for an estimation command}
{cmd:splitlog} stores the following in {cmd:r()}:

{* here is everything saved from estimation commands}{...}
{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(errLn)}}The list of command numbers which ended in errors{p_end}
{synopt:{cmd:r(cmdnum)}}The number of commands/results marked (which is also the number of the last command){p_end}
{synopt:{cmd:r(orphannum)}}The number of orphans{p_end}


{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org/Stata":http://louabill.org/Stata}
{p_end}

