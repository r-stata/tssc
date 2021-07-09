{smcl}
{* *! version 0.0.0  31DEC2015}{...}
{cmd:help libhtml}
{hline}

{title:Title}

{hi:libhtml {hline 2}} A utility program to compile the libhtml Mata library.

{title:Syntax}

{p 4 4 4}{cmd:libhtml} [, {cmdab:rep:lace} {cmdab:lib:rary} {cmdab:mos:ave}
{cmd:dir(}{it:passthru}{opt )} {cmd:size(}{it:passthru}{opt )} {cmdab:c:omplete} ] {break}

{title:Description}

{p 4 4 4}{cmd:libhtml} is used to make it easier to compile the libhtml Mata 
library on your system.  Additionally, there are options provided to compile the 
classes and save them into compiled object files (see {help mata mosave} for 
additional information).  When called without arguments the classes will be 
compiled for the Stata session, but will not persist without the {cmdab:mos:ave} 
or {cmdab:lib:rary} options. For additional information about this package visit 
the project repository {browse "http://github.com/wbuchanan/matahtml"}.{p_end}

{title:Options}
{p 4 4 8}{cmdab:rep:lace} option specifies that any existing instances of the 
class definitions should first be dropped before recompiling.  This option also 
causes the program to overwrite previously save object or library files. {p_end}

{p 4 4 8}{cmdab:lib:rary} an option used to create a .mlib file containing all 
of the compiled classes and methods.  For additional information about .mlib files 
see {help mata mlib}.{p_end}

{p 4 4 8}{cmdab:mos:ave} an option used to save each compiled Mata class in its 
own object file.  See {help mata mosave} for additional information. {p_end}

{p 4 4 8}{cmd:dir} is an option passed directly to either the {help mata mosave} 
or {help mata mlib} commands based on either the {cmdab:mos:ave} or {cmdab:lib:rary} 
options being specified. {p_end}

{p 4 4 8}{cmd:size} is an option that only affects the creation of a .mlib file.  
If no value is specified, the program defaults to the maximum allowable value (2048). {p_end}

{p 4 4 8}{cmdab:c:omplete} is an option used in conjunction with the {cmdab:mos:ave} or 
{cmdab:lib:rary} options and throws an error if the class definition is incomplete. 
{it:This option can be helpful to ensure the classes compile correctly on your system before submitting an issue to the github repository}.{p_end}

{title: Author}{break}
{p 1 1 1} William R. Buchanan, Ph.D. {break}
Data Scientist {break}
{browse "http://mpls.k12.mn.us":Minneapolis Public Schools} {break}
William.Buchanan at mpls [dot] k12 [dot] mn [dot] us

