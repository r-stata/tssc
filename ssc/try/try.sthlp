{smcl}
{* *! version 1.0.0  04apr2021}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[U] prefix commands" "help prefix"}{...}
{viewerjumpto "Syntax" "try##syntax"}{...}
{viewerjumpto "Description" "try##description"}{...}
{viewerjumpto "Options" "try##options"}{...}
{viewerjumpto "Remarks" "try##remarks"}{...}
{viewerjumpto "Examples" "try##examples"}{...}
{p2colset 1 8 10 2}{...}
{p2col:{bf:try} {hline 2}}Call a Stata command repeatedly until it succeeds{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{pstd}
Standard syntax

{p 8 12 2}
{cmd:try} {cmd::} {it:stata_cmd}

{pstd}
Full syntax

{p 8 12 2}
{cmd:try} [#]
[{cmd:,} {opt t:max(#)} {opt v:erbose} {opt nodots}] {cmd::} {it:stata_cmd}

{pstd}
where # specifies the upper limit on the number of times that {it:stata_cmd}
will be called. The default is {bf:30}.


{marker description}{...}
{title:Description}

{pstd}
{bf:try} calls {it:stata_cmd} up to a certain number of times, with a random
{help sleep} of between 500-1000 milliseconds before each subsequent attempt.
Calls are stopped after the first successful execution of the command.

{pstd}
A common use for {bf:try} is to avoid the problem of {help export excel}
timing out on a network.


{marker options}{...}
{title:Options}

{phang}
{opt tmax(#)} specifies the upper limit in seconds on the total time that
	Stata will sleep; default {cmd:tmax(900)}.

{phang}
{opt verbose} reports the number of attempts and the total sleep time.

{phang}
{opt nodots} specifies whether to display iteration dots.
	By default, one dot is displayed for each attempt.


{marker remarks}{...}
{title:Remarks}

{pstd}
If unsuccessful, {bf:try} will stop calling {it:stata_cmd} when the
accumulated sleep time will exceed the sleep time in {cmd:tmax()}, or
when the number of requested attempts is reached, whichever comes first.

{pstd}
With the default number of attempts being 30, the expected total sleep
time is 22.5 seconds. Thus the following will stop after 30 attempts

{pmore}
{cmd:. try, tmax(60): ...}

{pstd}
If you want {cmd:try} to run up to 60 seconds, irrespective of the number of
attempts, code

{pmore}
{cmd:. try ., tmax(60): ...}


{marker examples}{...}
{title:Examples}

{pstd}Typical use{p_end}
{phang2}{cmd:. try: export excel ...}

{pstd}As above, but call {cmd:export excel} up to 20 times instead
of the default 30 times{p_end}
{phang2}{cmd:. try 20: export excel ...}

{pstd}Call {cmd:export excel} up to 100 times but spend no longer than 60 seconds{p_end}
{phang2}{cmd:. try 100, tmax(60): export excel ...}

{pstd}Call {cmd:export excel} for up to 60 seconds, irrespective of the number of attempts{p_end}
{phang2}{cmd:. try ., tmax(60): export excel ...}

{pstd}Report the number of attempts and the total sleep time{p_end}
{phang2}{cmd:. try, verbose: export excel ...}


{marker authors}{...}
{title:Authors}

{pstd}Rafal Raciborski{p_end}
{pstd}rraciborski@gmail.com{p_end}
