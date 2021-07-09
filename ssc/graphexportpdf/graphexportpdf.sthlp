{smcl}
{* 27apr2009}{...}
{hline}
help for {hi:graphexportpdf}
{hline}

{title:Improved support for saving graphs as pdf} 

{p 8 17 2} 
{cmd:graphexportpdf} {it:newfilename}[, {cmdab:dropeps}]


{title:Description} 

{p 4 4 2} 
{cmd:graphexportpdf} is an alternative to the standard {cmd:graph export} 
syntax, which produces unsatisfactory pdf files in Mac and does not support
pdf for Linux or Solaris at all. {cmd:graphexportpdf} provides superior pdf
output for UNIX-like systems (sorry, no Windows support) by first saving as 
eps then translating to pdf.


{title:Remarks} 

{p 4 4 2}
The program works by first using Stata's excellent support for eps,
then using the shell to convert eps to pdf. Because it relies on the shell
for the latter step, the ado-file only runs on UNIX-like systems (Mac, Linux, 
Solaris). If run on a Windows computer it will just produce an eps.

{p 4 4 2}
"Replace" is assumed so both {it:newfilename.eps} and {it:newfilename.pdf}
will be overwritten if they already exist. 

{p 4 4 2}
This command runs slower than using "{cmd:graph export} {it:newfilename.pdf}" 
on Stata for Mac (the only version that supports that syntax), but the output 
is much more attractive, especially for line graphs and kernel density plots.

{title:Options} 
 
{p 4 8 2}
{cmd:dropeps} specifies that {it:newfilename.eps} (which is created as an 
intermediate step) will be deleted.

{title:Examples}


. graphexportpdf pricempg dropeps

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. twoway scatter price mpg}{p_end}
{p 4 8 2}{cmd:. graphexportpdf pricempg, dropeps}{p_end}


{title:Author}

{p 4 4 2}Gabriel Rossman, UCLA{break} 
rossman@soc.ucla.edu

{title:Also see}

{p 4 13 2}On-line:  
help for {help graph export}, 
help for {help shell}

