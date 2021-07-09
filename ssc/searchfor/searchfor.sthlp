{smcl}
{* Attaullah Shah 1.1.0 05Jan2017}{...}
{cmd:help searchfor}{right:version:  1.0.0}
{hline}

{title:Title}

{p 4 8}{cmd:searchfor}  -  Searches for texts in selected or all string variables {p_end}


{title:Syntax}

{p 4 6 2}
{cmd:searchfor}
TEXT {cmd:,} {cmdab:in(}{it:varlist}{cmd:)}
{cmdab:edit(}{it:varlist}{cmd:)}
{cmdab:list(}{it:varlist}{cmd:)}

{p 4 4 2}


{title:Description}

{p 4 4 2} This program finds text in string variables and either lists the selected variables{break}
on screen or edits the varaibles in Data Editor. The search text is capitalizaiton free.  {break}
 {p_end}



{title:Syntax Details}

{p 4 4 2}
The program has 3  options: They are {break}
1. {opt in} : to select string variables in which the text will searched for. If left empty, the desired text will be searched in all string variables. {break}
2. {opt edit}: This option will edit selected variables in the Data Editor in instances where the search result is true {break}
3. {opt list}: This option will list selected variables in instances where the search result is true; {p_end}
 

{title:Example 1: Find Text in all String Variables}
 {p 4 8 2}{stata "sysuse census.dta" :. sysuse census.dta}{p_end}
 {p 4 8 2}{stata "searchfor Alabama  " :. searchfor Alabama } {p_end}
 {p 4 8 2}{stata "searchfor Alab  " :. searchfor Alab } {p_end}
 {p 4 8 2}{stata "searchfor ALAB  " :. searchfor ALAB } {p_end}


 {title:Example 2: Show Selected Variables Where searchfor Finds Matching string} 
 {p 4 8 2}{stata "searchfor Alabama, list(state state2 region pop) " :. searchfor Alabama, list(state state2 region pop) } {p_end}
 

 {title:Example 3:  Find Text in Selected String Variables} 
 {p 4 8 2}{stata "searchfor Alabama, in(state)" :. searchfor Alabama, in(state) } {p_end}
 {p 4 8 2} This will search for Alabama in the variable 'state' only {p_end}
 {p 4 8 2}{stata "searchfor Alabama, in(state) list(state state2 region pop)" :. searchfor Alabama, in(state) list(state state2 region pop) } {p_end}

 
 {title:Example 4:  Find Text in Selected String Variables and Edits Selected variables}  
  {p 4 8 2}{stata "searchfor Alabama, in(state) edit(state state2 region pop)" :. searchfor Alabama, in(state) edit(state state2 region pop) } {p_end}

 {p 4 8 2} This will search for Alabama in the variable 'state' only and edit state, state2, region, and pop variables in the editor window where the search finds a match {p_end}


{title:Author}

{p 4 8 2} 

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                             *
*                       Dr. Attaullah Shah                                    *
*            Institute of Management Sciences, Peshawar, Pakistan             *
*                     Email: attaullah.shah@imsciences.edu.pk                 *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{help findit}, {stata "ssc desc asrol":asrol}, {stata "ssc desc ascol":ascol}, {stata "ssc desc moss":moss}, {stata "www.OpenDoors.Pk" : www.OpenDoors.Pk}
{p_end}







