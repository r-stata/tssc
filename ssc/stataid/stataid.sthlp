{smcl}
{hline}
{hi:help stataid}{right: v. 1.0 - January 2019}
{hline}
{title:Title}

{p 4 4}{cmd:stataid} - Obtaining and displaying information about running Stata instances under 
Microsoft Windows. 
{cmd:stataid} can close Stata instances using a Windows process id.
{p_end}

{title:Contents}

{p 4}{help stataid##syntax:Syntax}{p_end}
{p 4}{help stataid##description:Description}{p_end}
{p 4}{help stataid##options:Options}{p_end}
{p 4}{help stataid##rclass:Stored Values}{p_end}
{p 4}{help stataid##Examples:Examples}{p_end}
{p 4}{help stataid##about:About}{p_end}


{marker syntax}{title:Syntax}

{p 4 8}To obtain infomation about running Stata instances:

{p 6 13}{cmd: stataid list , [exename({it:string}) list mata ]}{p_end}

{p 4 8}To close a running Stata instance using a Windows process id:{p_end}

{p 6 12}{cmd: stataid kill, id({it:idnumber})}{p_end}

{marker options}{title:Options}

{p 4 8}{cmd:exename({it:string})} Name of Stata executable. 
{cmd:stataid} tries to determine the name of the executable, but might fail 
in case the executable has a non standard name.
{p_end}

{p 4 8}{cmd:mata} Saves the data in a mata matrix called {it:stataid}.{p_end}

{p 4 8}{cmd:kill({it:idnumber})} Kills process with specific id number.{p_end}

{marker description}{title:Description}

{p 4 8}{cmd:stataid} obtains information about all running Stata processes of a 
Microsoft Windows system.
It retrieves the running tasks using {help shell} and tasklist 
of the command line. 
The following information are saved: {p_end}
{col 10}1. Name of the exe file (image name)
{col 10}2. Process id
{col 10}3. The name of the session
{col 10}4. The number of the session
{col 10}5. Memory used
{col 10}6. The status
{col 10}7. The username
{col 10}8. CPU time
{col 10}9. Windowtitle

{p 4 8}{cmd:stataid} can close any Stata instance, including the running one.
Using the parameter {cmd:kill}, it closes the Stata instance defined by {cmd:id()}. 
Internally {cmd:stataid} uses the Windows command line command
{it: taskkil} to kill the Stata instance. 
Note, Stata is closed {ul:{bf:without}} saving any data!{p_end}

{marker rclass}{title:Stored Values}

{p 4 8}{cmd:stataid} stores the following in {cmd:r()}:{p_end}

{col 4}Scalars

{col 8}{cmd:r(instances)} {col 25}Number of Stata instances (only with {cmd:stataid list}).

{marker Examples}{title:Examples}

{p 4 8}To retrieve a list of all current running Stata instances (2 are running and list the result):{p_end}

{col 12}{stata stataid list}

{p 4 8}The output will be:{p_end}

{col 12}{com}. stataid list
{col 12}Obtaining number of Stata instances running under StataSE-64.exe.
{col 12}2 Stata instance(s) running.
{reset}

{p 4 8}Kill Stata instance with id {it:13424}:{p_end}

{col 12}{com}. stataid kill , id(13424)
{col 12}CPU process id 13424 going to be closed.
{reset}

{marker about}{title:Author}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:j.ditzen@hw.ac.uk":j.ditzen@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}
{p 4}Github: {browse "https://janditzen.github.io/stataid/":https://janditzen.github.io/stataid/}{p_end}

{marker changelog}{title:Changelog}

{p 4 8}This version: 1.0{p_end}
