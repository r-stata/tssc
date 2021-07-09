{smcl}
{* *! version 1.0 11.05.2016}{...}
{* *! Lars Zeigermann}{...}

{cmd:help timestamp}

{hline}

{title:Title}

{phang}
{bf:timestamp} {hline 2} UNIX timestamp and current time/date in both coordinated universal time (UTC) and local time of a user-specified timezone

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:timestamp}
[,
{opt time:zone(string)}
 {opt for:mat(string)}
 {opt qui:etly}]
 
{p 8 17 2}
{cmdab:timestamp_zones}
[,
{opt reg:ion(string)}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:timestamp} returns a UNIX timestamp as well as the current time and date in coordinated universal time (UTC) and the local time of a timezone specified by the user. The data is obtained from the application programming interface (API) provided by {browse "http://www.convert-unix-time.com/"}. Running {cmd:timestamp} requires {cmd:insheetjson} and {cmd:libjson} written by Erik Lindsley which are available from SSC. All results are stored in {cmd:r()}.
{p_end}

{pstd}
{cmd:timestamp_zones} lists all valid timezones for which {cmd:timestamp} can obtain the local time and date.{p_end}

{marker options}{...}
{title:Options}

{dlgtab:timestamp}

{phang}
{opt timezone(string)} specifies the timezone for which the local date and time are returned. The default is UTC. Use {cmd:timestamp_zones} to obtain a complete list of all valid timezones.

{phang}
{opt format(string)} specifies the format in which date and time are displayed. Valid formats are {it: default}, {it:english}, {it:english12}, {it:german}, {it: rfc1123} and {it: iso8601}.

{phang}
{opt quietly} surpresses the output.

{dlgtab:timestamp_zones}


{phang}
{opt region(string)} selects the region(s) for which all valid timezones are displayed. Valid regions are {it:Africa}, {it:America}, {it:Antarctica}, {it:Arctic}, {it:Asia}, {it:Atlantic}, {it:Australia}, {it:Europe}, {it:Indian}, {it:Pacific} and {it:others}.  Default is all regions.{p_end}

{marker example}{...}
{title:Example}

{pstd}
To obtain a UNIX timestamp and the current time in UTC, we simply type
{p_end}

{phang2}
{stata `"timestamp"'}
{p_end}

{pstd}
If we need the local time of a specific timezone rather than UTC, we can first check all valid timezones by typing
{p_end}

{phang2}
{stata `"timestamp_zones"'}
{p_end}

{pstd}
or, if we are interested in timezones in America and the Pacific only:
{p_end}

{phang2}
{stata `"timestamp_zones, region(America Pacific)"'}
{p_end}

{pstd}
Finally, if we want to obtain the current time for, let's say, Kiritimati (aka Christmas Island) displayed in ISO 8601 format, we specify {cmd:timestamp} as follows:
{p_end}

{phang2}
{stata `"timestamp, timezone(Kiritimati) format(iso8601)"'}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:timestamp} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(timezone)}}timezone{p_end}
{synopt:{cmd:r(timestamp)}}UNIX timestamp{p_end}
{synopt:{cmd:r(utcDate)}}UTC date and time{p_end}
{synopt:{cmd:r(localDate)}}date and time of user-specified timezone{p_end}
{synopt:{cmd:r(dst)}}yes if daylight saving time, no otherwise{p_end}

{title: Required SSC packages}

{pstd}
Required ssc packages: {help insheetjson}, {help libjson}

{title:Author}

{pstd}
Lars Zeigermann, D{c u:}sseldorf Institute for Competition Economics (DICE), {browse "mailto:zeigermann@dice.hhu.de":zeigermann@dice.hhu.de}{p_end}