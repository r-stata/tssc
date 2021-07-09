{smcl}
{right:version 1.0.0}
{title:Title}

{phang}
{cmd:calldiagram} {hline 2} analyzes executed ado programs and produces a dynamic profile diagram named {it:calldiagram.gv} which can be rendered to a graphical file 
 using {help diagram} command. For more information visit
 adding  {browse "http://www.haghish.com/diagram/diagram.php":hyperlink} 
 

{title:Syntax}

{p 8 16 2}
{cmd: calldiagram} [{bf:supress}({it:adoname list})] {it:Stata-command}

{p 4 4 2}
The {bf:calldiagram} program tracks all of the executed ado programs, including 
Stata open-source programs (e.g. {it:clear} and {it:findfile} both are open source 
adofiles that can be viewed using {help viewsource} command.     {break}

{p 4 4 2}
In order to avoid including Stata adoprograms in the profile diagram, provide 
the list of the program names that you wish to ignore using the 
{bf:supress({it:adoname list})} subcommand. This subcommand can be useful for 
generating profile diagrams that only include adoprograms included in a 
userwritten package (see the example section). 


{title:Description}

{p 4 4 2}
generates dynamic profile diagram, illustrating the chain of executed 
ado-programs in Stata. The command can be used to visualize all of the commands 
that are executed when a user-written package is executed.    {break}


{title:Remarks}

{p 4 4 2}
The remarks are the detailed description of the command and its 
nuances. Official documented Stata commands don{c 39}t have much for 
remarks, because the remarks go in the documentation.

{title:Example(s)}

    produce a profile from the makediagram.ado which is included in {help diagram} package
        . copy "https://github.com/haghish/diagram/blob/master/examples/cluster.dta?raw=true" ///
          "cluster.dta", replace
        . calldiagram makediagram using "cluster.dta", export(cluster.gv) replace
		
    the previous example includes Stata ado.programs that can be suppressed
        . calldiagram suppress(duplicates clear label) 					///
          makediagram using "cluster.dta", export(cluster.gv)  replace


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
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":http://www.haghish.com/markdoc}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}       {break}

    {hline}

{p 4 4 2}
{it:This help file was dynamically produced by {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}} 

