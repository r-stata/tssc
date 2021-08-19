{smcl}
{right:version 1.0.0}
{title:Title}

{phang}
{cmd:div} {hline 2} {bf:div} performs Stata command and echoes the command or output or both to the HTML log file. This command belongs to {bf:{help weaver}} packages.
 

{title:Syntax}

    Perform command and echo command and output to the HTML log
	
	{cmdab:div} [{cmdab:c:ode} | {cmdab:r:esult}] {it:command}

{p 4 4 2}
If the {cmdab:c:ode} subcommand is specified, only the command will be included, 
supressing the output from Weaver log. In contrast, if the {cmdab:r:esult} 
subcommand is specified, only the output will be included in the Weaver log and 
the command will be ignored. 


{title:Description}

{p 4 4 2}
{bf:div} run Stata {it:command} and echo the command and output in the HTML log
in {help weaver} package. If {help weaver} is not in use (i.e. there is not HTML
log open), {bf:div} run the command and return the output and at the end, it
also return a warning that the HTML log is not on.

{pstd}
The {cmdab:c:ode} subcommand can be added to {bf:div} command to only echo
the {it:command} in the HTML log and suppress the output from the HTML log. Although
it continues to print the output in Stata results window.

{pstd}
The {cmdab:r:esult} subcommand can be added to {bf:div} command to only echo the
output in the HTML log and suppress {it:command} from the HTML log.
Although it continues to print the output in Stata results window.


{title:Example(s)}

   {bf:div} echoes the command and output to the Weaver log. 

        . sysuse auto, clear
        . div regress mpg weight foreign headroom

    the {cmdab:r:esult} only includes the output in the weaver log

        . div r code misstable summarize
		
    the {cmdab:c:ode} subcommand only includes the command in the weaver log
	
        . div c generate newvar = price


{title:Author}

{p 4 4 2}
{bf:E. F. Haghish}       {break}
Center for Medical Biometry and Medical Informatics       {break}
University of Freiburg, Germany       {break}
{it:and}          {break}
Department of Mathematics and Computer Science         {break}
University of Southern Denmark       {break}
haghish@imbi.uni-freiburg.de       {break}

{p 4 4 2}
{browse "www.haghish.com/weaver":Weaver Homepage}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}      {break}

    {hline}

{p 4 4 2}
{it:This help file was dynamically produced by {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}} 

