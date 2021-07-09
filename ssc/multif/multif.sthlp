{smcl}
{* *!Version 1.15 20.06.2018}{...}
{title:Titel}
{cmd:multif} {hline 1} Constructs multiple if-restrictions with the same value for different variables. 

{title:Description}
This command was developed out of the need to apply the same if-restriction like "!mi(VAR)" or "inrange(VAR,x,y)" to multiple variables.
Even with only a few variables, writing the if-restrictions can be quite error prone.
This command eases the construction of such restrictions for the variables supplied in {varlist}.
The command should work in the most common scenarios, but it does not check if the generated restriction(s) itself is/are valid. 
A {stata db multif:dialog file} is provided to make the usage of this command easier.

{title:Syntax}

{cmd:multif} {it:varlist} ,{cmdab:cond:ition}() {cmdab:con:nection}() [{cmdab:com:mand}() {cmdab:comopt:ion}() {cmdab:var:id}() {cmdab:add:if}() {cmdab:addc:on}() test {cmdab:disp:lay}]

{synoptline}
{synoptset 20 tabbed}{...}
{synopthdr: Options}
{synoptline}
{synopt :{cmdab:cond:ition}()} defines the if restrictions which should be applied to all variables in the list.{p_end}
{synopt :{cmdab:con:nection}()} defines the logical connector like "&, |" between different restrictions.{p_end}
{synopt :{cmdab:com:mand}()}	defines the command to be run with the created multiple if restrictions.{p_end}
{synopt :{cmdab:comopt:ion}()} adds options to the command provided in the {opt com:mand()} option. {p_end}
{synopt :{opt var:id()}}	defines a different variable identifier used in the {opt cond:ition()} option. The default value is "VAR".{p_end}
{synopt :{cmdab:add:if}()} adds another if-restriction  to the command option {p_end}
{synopt :{cmdab:addc:on}()} connector for {opt add:if()} option {p_end}
{synopt :{opt test}} enables an experimental test for equality of variable identifier in all restrictions with the supplied identifier {p_end}
{synopt :{opt disp:lay}} displays the resulting restriction(s).{p_end}

{title:Options}

{dlgtab:Required options}

{phang}
{cmdab:cond:ition}() defines the if restrictions which should be applied to all variables in the list.

{phang}
{cmdab:con:nection}() defines the logical connector like "&, |" between different restrictions.


{dlgtab:Additional options}

{phang}
{cmdab:com:mand}()	defines the command to be run with the created multiple if restrictions.

{phang}
{cmdab:comopt:ion}() adds options to the command provided in the {opt com:mand()} option. 

{phang}
{opt var:id()}	defines a different variable identifier used in the {opt cond:ition()} option. The default value is "VAR".

{phang}
{cmdab:add:if}() adds another if-restriction  to the command option.

{phang} 
{cmdab:addc:on}() connector for {opt add:if()} option.

{phang} 
{opt test} enables an experimental test for equality of variable identifier in all restrictions with the supplied identifier.

{phang} 
{opt disp:lay} displays the resulting restriction(s).


{title:Examples}
{tab}{cmd:. use auto}
{tab}{cmd:. multif make price mpg, condition(!mi(VAR)) connection(&) command(count)}
{tab}	74
{tab}{cmd:. display "`r(multif)'"}
{tab}  !mi(make) & !mi(price) & !mi(mpg)

{tab}{cmd:. multif headroom price mpg, condition(!mi(v) & v>0) connection(&) command(count) varid(v) addif(price<6000) addcon(|) display}
{tab}The resulting multiple restrictions expressions is:
{tab} !mi(headroom) & headroom>0 & !mi(price) & price>0 & !mi(mpg) & mpg>0 | price<6000


{title:Saved results}
{synoptset 15 tabbed}{...}
{cmd:multif} saves the following in {cmd:r()}:
{p2col 5 20 24 2: Macro}{p_end}
{synopt: {cmd:r(multif)}}the multiple if-restrictions containing also the restriction provided by the {opt addif()} option. {p_end}

{* p2colreset}{...}
{* INCLUDE help author }
{title:Author}
Sven-Kristjan Bormann

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools }{p_end}

{title:Known Bugs}
The variable ID must be set correctly in all conditions, otherwise {cmd:multif} returns silently a condition which cannot be used further!
An experimental test for this scenario is available via the {opt test} option, but the test does not cover all potential errors yet.
This might be fixed in a next version. 
