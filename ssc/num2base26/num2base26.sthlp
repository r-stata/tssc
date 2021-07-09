{smcl}
{* *! version 1.0.0  20may2018}{...}
{cmd:help num2base26}
{title:Title}
{cmd:num2base26} {hline 2} A Stata interface to Mata's hidden numtobase26() function.  

{title:Description}
{cmd:num2base26} {hline 2} Converts an integer number into a letter and returns it. 
It accepts as argument integer numbers like 1, 2,..., but also real valued numbers like 1.5, 4.534 or a macro containing the number
or any valid mathematical expression as long as it results in a number. Any number is rounded down to the nearest integer number.
This command was inspired by{browse "http://www.wmatsuoka.com/stata/category/numtobase26": this post}.
The command is similar to but not related to the {help Excelcol} package (available from the SSC archive): 
type {net "describe excelcol, from(http://fmwww.bc.edu/RePEc/bocode/e)":ssc describe excelcol}


{title:Syntax}
{cmd:num2base26} {it:number} , [{cmdab:low:er} {cmdab:disp:lay} {cmdab:R:eturn(string)}]

{synoptset 20 tabbed}{...}
{synopthdr :Options}
{synoptline}
{synopt : {cmdab:low:er}} return a lowercase letter. Default is uppercase letter.{p_end}
{synopt : {opt disp:lay}} displays the letter.{p_end}
{synopt : {opt R:eturn(string)}} changes the name of the local macro that contains the returned letter. The default value is {bf:letter}.
							This option is more meant for my personal use, 
							because the name of the returning local macro was a different one before. I changed the name to make it easier to remember, but thereby broke
							older do-files that rely heavily on the command.{p_end}

{title:Examples}
{tab}{cmd:. num2base26 4}
{tab}{cmd:. display "`r(letter)'"}
{tab} "D" 

{tab}{cmd:. local num = 4}
{tab}{cmd:. num2base 4+`num', lower} 
{tab}{cmd:. display "`r(letter)'"}
{tab} "h" 

{title:Saved results}

{synoptset 15 tabbed}{...}
{cmd:num2base26} saves the following in {cmd:r()}:
{p2col 5 20 24 2: Macro}{p_end}
{synopt:{cmd:r(letter)}}Letter{p_end}

{title:Author}
Sven-Kristjan Bormann

{title:Bug Reporting}
Please submit bugs, comments and suggestions via email to: sven-kristjan@gmx.de
