{smcl}
{.-}
help for {cmd:dolog} and {cmd:dosmcl} {right:(Roger Newson)}
{.-}
 
{title:Execute commands from a do-file, creating a text or {help smcl:SMCL} log file}

{p 8 27}
{cmd:dolog} {it:filename}  [ {it:arguments} ] [ {cmd:,} {opt nostop} ]

{p 8 27}
{cmd:dosmcl} {it:filename}  [ {it:arguments} ] [ {cmd:,} {opt nostop} ]


{title:Description}

{p}
{cmd:dolog} and {cmd:dosmcl} (like {helpb do}) causes Stata to execute the commands stored in
{it:filename}{cmd:.do} as if they were entered from the keyboard,
and echos the commands as it executes them,
creating a {help log:text log file} {it:filename}{cmd:.log} (in the case of {cmd:dolog})
or a {help smcl:SMCL log file} {it:filename}{cmd:.smcl} (in the case of {cmd:dosmcl}).
If {it:filename} is specified without an extension,
then {it:filename}.do is assumed.
If {it:filename} is specified with an extension other than {cmd:.do},
or with no extension,
then the log file will still have {cmd:.log} or {cmd:.smcl} as its extension,
so {cmd:dolog} and {cmd:dosmcl} will not overwrite the original do-file.
Arguments are allowed (as with {helpb do} or {helpb run}).


{title:Options}

{phang}
{opt nostop} allows the do-file to continue executing even if an error occurs.
Normally, Stata stops executing the do-file when it detects an error
(nonzero return code).


{title:Remarks}

{p}
The original version of {cmd:dolog} was an example given as {cmd:dofile}
in a Stata NetCourse. This version is slightly improved.

{p}
Note that a {help do:do-file} should nearly always start with a {helpb version} statement
at or near the top.
This is because, nearly always, we prefer the do-file to run
in the {help version:Stata version} in which it was written, even if the version of Stata
has been upgraded.
This practice also ensures that, if the do-file is run using {cmd:dolog} or {cmd:dosmcl},
then it is run under its own Stata version,
and not under the Stata version of the current version of {cmd:dolog} or {cmd:dosmcl}.

{p}
An exception to this rule occurs when the do-file is a
{help cscript:certification script}. For these, it is better to use the
{helpb dologx} package instead of {cmd: dolog}. To find unofficial Stata packages
which you might want to download, use {helpb net:net search} or {helpb findit}.

{p}
{cmd:dolog} and {cmd:dosmcl} are recursive,
meaning that a master do-file input to {cmd:dolog} or {cmd:dosmcl}
may contain {cmd:dolog} or {cmd:dosmcl} commands
that call other do-files (known as servant do-files).
However, it is not usually a good idea to do this,
because the same output will then appear both in the log file for the master do-file
and in the log files for the servant do-files,
consuming disk space.
If the user wants to run a master do-file calling a sequence of servant do-files,
then the user should usually use the {helpb do} command to call the master do-file,
which should contain multiple {cmd:dolog} or {cmd:dosmcl} commands calling the servant do-files.
This practice also makes it easy to test the servant do-files one by one,
before executing the whole sequence using the master do-file.


{title:Examples}

{p 8 16}{inp:. dolog trash1}{p_end}

{p 8 16}{inp:. dosmcl trash1}{p_end}

{p 8 16}{inp:. dolog mycom argone argtwo}{p_end}


{title:Author}

{p}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{psee}
Manual:  {manlink R do}, {manlink R doedit}, {manlink R log}, {manlink P smcl}, {manlink P version}
{p_end}

{psee}
{space 2}Help:  {manhelp do R}, {manhelp run R}, {manhelp doedit R}, {manhelp log R}, {manhelp smcl P},
{manhelp version P}, {manhelp cscript P}
{break}
{helpb dologx} if installed
{p_end}
