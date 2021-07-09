{smcl}
{* Juli 8, 2009 @ 10:43:09 UK}{...}
{cmd:help clickout}

{hline}

{title:Title}

{p2colset 5 17 22 2}{...}
{p2col :{hi:  clickout} {hline 2}}produces a list of clickable files for your clicking pleasure{p_end}

{marker s_Syntax}
{title:Syntax}

{p 4 4 6}
{cmdab:clickout} [{it:file extension}] [{it:using <directory>}]

{marker s_Description}
{title:Description}

{p 4 4 6}
{cmd:clickout} provides a fast and easy way to open the files contents of current directory ({help cd}) 
or any folder for your clicking pleasure.

{marker s_0}
{title:Examples}

{p 4 4 6}* assuming you have a file with .xml extension in your current directory:{p_end}
{p 4 4 6}{stata clickout xml }{p_end}

{p 4 4 6}* assuming you have anything in your current directory:{p_end}
{p 4 4 6}{stata clickout}{p_end}
{p 4 4 6}{stata clickout *}{p_end}

{p 4 4 6}* assuming you have anything in your "c:/" folder:{p_end}
{p 4 4 6}{stata `"clickout * using "c:/""'}{p_end}


{title:Remarks}

{p 4 12 6}No guaratee that all files will successfully open.{p_end}


{title:Author}

{p 4 4 6}Ulrich Kohler, WZB, kohler@wzb.eu{p_end}
{p 4 4 6}Roy Wada, roywada@hotmail.com{p_end}


{title:Also see}

{psee} Online: {help ldta}, {help ltex}, {help cdout}, {help fastcd} (if installed)
{p_end}

