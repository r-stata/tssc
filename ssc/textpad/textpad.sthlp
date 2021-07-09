{smcl}
{hline}
help for {cmd:textpad}{right:(Roger Newson)}
{hline}

{title:Call TextPad to edit a file}

{p 8 21 2}
{cmd:textpad} [ {it:command_line_parameters} ] [ {it:filename} ]

{pstd}
where {it:command_line_parameters} is a list of command line parameters
for TextPad. (See internal on-line help for TextPad under {cmd:Command Line Parameters}).


{title:Description}

{pstd}
{cmd:textpad} calls the {browse "http://www.textpad.com/":TextPad} text editor,
if this editor is installed on the user's system.
The TextPad text editor is a powerful multi-purpose text editor,
available under Microsoft Windows operating environments.


{title:Technical note}

{pstd}
{cmd:textpad} assumes that the path of the TextPad executable
is stored in the {help global:global macro}
{cmd:$TextPad_path}, unless that macro is empty,
in which case it assumes that the path of the TextPad executable
is {cmd:"c:\Program Files\TextPad 8\TextPad.exe"}.
The user can set the global macro {cmd:$TextPad_path}
in the {help profile:user-profile file} {cmd:profile.do}.


{title:Examples}

{p 8 12 2}{cmd:. textpad create1.do}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] shell}
{p_end}
{p 4 13 2}
On-line: help for {helpb shell}, {helpb winexec}, {helpb profile}
{p_end}
{p 4 13 2}
{bind:  }Other: {browse "http://www.textpad.com/":TextPad},
{browse "http://fmwww.bc.edu/repec/bocode/t/textEditors.html":Some notes on text editors for Stata users}
{p_end}
