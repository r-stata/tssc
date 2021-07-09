{smcl}
{* *! version 1.1.0  22aug2010}{...}
{cmd:help grcomb}
{hline}


{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:grcomb} {hline 2}}create and combine several single graphs into 
one{p_end}
{p2colreset}{...}



{title:Syntax}

{p 8 16 2}
{cmd:grcomb}
{it:graph command}
{it:var1[*#] var2[*#] var3[*#] var4[*#]} [...]
{ifin}
{cmd:,}
{opt v:arblock(#)}
[{opt o:rder(abab|aabb)}
{opt name(name[, replace])}
{opt d:raw}
{opt f:eedback}
{it:graph options}]


{pstd}
{cmd:by} is not allowed.{break}
{cmd: Weights} are not allowed.


{title:Description}

{pstd}
{cmd:grcomb} allows you to generate, in a single command, several graphs of the 
same type and using the same options; to optionally display them; and to combine 
them into a single graph window. It is a wrapper for Stata's built-in graph 
commands, in particular the {cmd:graph combine} command.

{pstd}
{cmd:grcomb} options will now be further described using the following two 
examples. In each example, it is supposed that you want to combine three single 
graphs into a combined graph:

{pstd}
(1){p_end}
{pstd}
{cmd:scatter} {bf:a1 b, jitter(8)}{break}
{cmd:scatter} {bf:a2 b, jitter(8)}{break}
{cmd:scatter} {bf:a3 b, jitter(8)}

{pstd}
This is achieved by{p_end}
{pstd}
{cmd:grcomb} {bf:scatter a1 b a2 b a3 b, v(2) jitter(8)}

{pstd}
(2){p_end}
{pstd}
{cmd:scatter} {bf:a1 b1, jitter(8)}{break}
{cmd:scatter} {bf:a2 b2, jitter(8)}{break}
{cmd:scatter} {bf:a3 b3, jitter(8)}

{pstd}
This is achieved by{p_end}
{pstd}
{cmd:grcomb} {bf:scatter a1 b1 a2 b2 a3 b3, v(2) jitter(8)}


{title:Options}

{phang}
{opt var*}{it:#} replaces {opt var} with {it:#} copies of itself in 
{cmd:grcomb}'s varlist. The purpose of this option will become clear shortly.

{phang}
{opt varblock(#)} specifies the number of variables for a single graph command. 
In both examples (1) and (2), the single {cmd:scatter} commands each take two 
variables as arguments. Therefore, varblock is 2 in both cases. If the single 
graph commands were {cmd:histogram}, varblock would be 1, since histograms take 
only one variable as argument.

{phang}
{opt order(abab|aabb)} specifies the order of the variables in {cmd:grcomb}'s 
varlist. The default is {opt order(abab)} and is exemplified by both examples 
(1) and (2), where the variables for the single graph commands sequentially 
follow each other in {cmd:grcomb}'s varlist (e.g. in (2), {bf:a1} is plotted 
against {bf:b1}, {bf:a2} is plotted against {bf:b2}, and {bf:a3} is plotted 
against {bf:b3}). Specifiying {opt order(aabb)} requires the variables to be 
listed in the order {bf:a1 a2 a3 b1 b2 b3} (example (2)). The point of this 
option is to allow simplifying the varlist to {bf:a* b*} (or maybe {bf:a? b?}). 
I.e. given that {bf:a1}-{bf:a3} and {bf:b1}-{bf:b3} are the only variables 
starting with letters "a" and "b", respectively, the {cmd:grcomb} command in 
example (2) can be shortened to {cmd:grcomb} {bf:scatter a* b*, v(2) order(aabb) jitter(8)}. Example (1), in turn, could be simplified to {cmd:grcomb} 
{bf:scatter a* b*3, v(2) order(aabb) jitter(8)}, since, by way of cashing in 
option {opt var}{it:*#}, {bf:b*3} expands to {bf:b b b}. (Don't confuse the 
wildcard asterisk ,*' with the multiply operator ,*' of option {opt var}{it:*#}.)

{phang}
{opt name(name[, replace])} lets you enter a name for the combined graph and 
optionally replace any previous graph of the same name. But {cmd:grcomb} 
automatically names your graphs for you, so you don't usually need this option. 

{phang}
{opt draw} displays the single graphs. If you omit this option, display of the 
single graphs (e.g. the three scatter plots in examples (1) and (2)) is 
suppressed.

{phang}
{opt feedback} shows feedback on {cmd:grcomb}'s progress in terms of the number 
of single graph commands it has processed.

{phang}
{it:graph options} include all the options possible with the single graph 
command. In examples (1) and (2), this would be the {bf:jitter(8)} option. You 
can specify here any number of options that are allowed with the single graph 
command you've chosen.


{title:Remarks}

{pstd}
{cmd:grcomb} may run into trouble if you have a variable in your data set with 
the same name as (one of the words of) your single graph command. It will 
recognize this for the first word of your single graph command, but not for any 
potential subsequent words. 

{pstd}
Example:{break}
If you have a variable {bf:scatter} in your data set and you type {cmd:grcomb} 
{bf:scatter var1 var2 var3 var4, v(2)}, {cmd:grcomb} will catch the error and 
ask you to remove or rename variable {bf:scatter}. However, if you type 
{cmd:grcomb} {bf:twoway scatter var1 var2 var3 var4, v(2)}, {cmd:grcomb} will 
crash without any helpful error message.

{pstd}
{cmd:grcomb} gives unique names to both the single and the combined graphs it 
produces, so that none of the graphs produced by any single or consecutive calls 
to {cmd:grcomb} will be overwritten. (If you must know, the names correspond to 
the number of seconds expired since midnight, prefixed with the letter "g".)

{pstd}
By default, {cmd:grcomb} uses the {bf:altshrink} option of Stata's {cmd:graph combine} command. At present, there's nothing you can do to change this (except 
editing out the word "altshrink" from "grcomb.ado".)


{title:Examples}

{pstd}
Plotting temperature vs pressure for five timepoints

{pin}
{it:Awkward version:}{p_end}
{phang2}
{cmd:. grcomb} {bf:scatter temperature1 pressure1 temperature2 pressure2 temperature3 pressure3 temperature4 pressure4 temperature5 pressure5, v(2)}

{pin}
{it:Elegant version:}{p_end}
{phang2}
{cmd:. grcomb} {bf:scatter temperature* pressure*, v(2) order(aabb)}

{pstd}
Displaying single graphs, and feedback{p_end}
{phang}
{cmd:. grcomb} {bf:spineplot education sex incomeclass sex, v(2) draw f}

{pstd}
Graph commands with different numbers of arguments

{pin}
{it:Combine 3 histograms:}{p_end}
{phang2}
{cmd:. grcomb} {bf:hist age height bmi, v(1) bins(10) percent}

{pin}
{it:Combine 2 scatterplots:}{p_end}
{phang2}
{cmd:. grcomb} {bf:scatter sales returns year nemploy nlayoff year, v(3)} 

{pstd}
Multi-word graph commands{p_end}
{phang}
{cmd:. grcomb} {bf:graph twoway bar income nchildren education*2, v(2) order(aabb)}


{title:Author}

{pstd}
Alex Gamma, University Hospital of Psychiatry, Zurich, Switzerland. Email: alex.gamma@uzh.ch


{title:Also see}

{psee}
Manual: {bf:[G] graph combine}

{psee}
Online: {manhelp graph_combine G}, {help spineplot:{bf:spineplot}} (if 
installed){p_end}
