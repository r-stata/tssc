{smcl}
{* *! version 1.0.0  20may2009}{...}
{cmd:help eperiod} {right:dialog:  {bf:{dialog eperiod}}}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: eperiod} {hline 2}}Elapsed period calculator - age calculator{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:eperiod}
{it:final_date initial_date}
{ifin}
{cmd:,}[ {it:options}]


{title:Description}

{pstd}
For the elapsed time between final_date and initial_date, eperiod calculates
the number of Years, Month, or days according to the specified option. Input 
variables could either have a date format or not. 



{title:Options}


{syntab:Main}
{synoptline}

{phang}
{opt y:ear} Calculates the elapsed period by years between initial and final date.

{phang}
{opt m:onth} Calculates the elapsed period by months between initial and final date.

{phang}
{opt d:ay} Calculates the elapsed period by days between initial and final date.


{syntab:Options}
{synoptline}

{phang}
{opt t:oday(freq)} May not be used with a {it:final_date}. Calculates the elapsed 
period by {it:freq} between final and current date. Where {it:freq} is:

{synoptset 5 tabbed}{...}
{syntab:freq}
{synopt:{opt y}}Year frequency.{p_end}
{synopt:{opt m}}Month frequency.{p_end}
{synopt:{opt d}}day frequency.{p_end}


{phang}
{opth g:enerate(newvar)} Specifies the name of the new variable to be created. If 
{it:newvar} is not specified, {cmd:eperiod} creates a default variable name.


{title:Example}

{phang}.{cmd: eperiod} enrolled graduated, year{p_end}
{phang}.{cmd: eperiod} enrolled graduated, month generate(studied_months){p_end}
{phang}.{cmd: eperiod} graduated, today(d) generate(experience_days){p_end}



{title:Author}

{phang}Juan M. Villa{p_end}
{phang}Inter-American Development Bank (not responsible){p_end}
{phang}juanmiguelv@iadb.org{p_end}







