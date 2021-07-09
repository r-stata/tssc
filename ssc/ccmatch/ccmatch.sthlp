{smcl}
{* *! version 1.3  27 Jan 2015}{...}
{cmd:help ccmatch}{right: (version 1.3) }
By Daniel E. Cook {Danielecook@gmail.com} {right: www.Danielecook.com}
{hline}
{title:ccmatch}

{p 5 16 20}{cmd:ccmatch} {hline 2} Used to randomly match cases and controls based on specified criteria. For instance, if you wanted to randomly match cases and controls based on age, you 
can use ccmatch to specify age as a criterion on which to match cases and controls and it will match randomly by age. You can use multiple variables to match based on multiple criteria{p_end}

{p 5 16 20}ccmatch creates two variables:{p_end}

{p 16 16 20}{bf:match_id} gives the id of the partner an individual has been matched to.{p_end}

{p 16 16 20}{bf:matched_pair} Numbers pairs starting from one. Pairs will share the same number in this column (see example below).{p_end}



{p2colreset}{...}

{title:Syntax}

{p 5 16 2 200}
{cmd:ccmatch} {it: variable_list}, {cmd:cc() id()}

{p 10 10}{it: variable_list} -- Specify variables you want each pair to share here.{p_end}

{p 10 10}{cmd:cc({it:var})} -- Specify the variable you use to identify cases and controls. Must be coded 0=controls, 1=cases.{p_end}

{p 10 10}{cmd:id({it:var})} -- Specify the variable you to name individuals/observations in your dataset. {p_end}



{title:Example}


{col 10}{bf:match_id}{col 25}{bf:matched_pair}{col 40}{bf:name}{col 65}{bf:case_control}{col 90}{bf:age}
{col 10}a6{col 25}1	{col 40}a2{col 65}0{col 90}15
{col 10}a2{col 25}1	{col 40}a6{col 65}1{col 90}15
{col 10}a7{col 25}2	{col 40}a4{col 65}0{col 90}16
{col 10}a4{col 25}2	{col 40}a7{col 65}1{col 90}16
{col 10}a8{col 25}3	{col 40}a5{col 65}0{col 90}17
{col 10}a5{col 25}3	{col 40}a8{col 65}1{col 90}17
{col 10}a10{col 25}4{col 40}a1{col 65}0{col 90}19
{col 10}a1{col 25}4{col 40}a10{col 65}1{col 90}19
{col 10}{col 25}.{col 40}a3{col 65}0{col 90}15
{col 10}{col 25}.{col 40}a9{col 65}1{col 90}18

{p 5 5}The above output is an example of what match can do. The original data ({bf:name, case_control, age}) is unchanged, except that it has been reordered The command used was:{p_end}

{p 5}{cmd:ccmatch age, id(name) cc(case_control)}

{p 5 5} Age was specified following {cmd:ccmatch} to indicate that we wanted to match cases/control who are the same age. 

{p 5 5}The case/control variable is specified as an option using {cmd: cc()}, and the id of each individual is specified using {cmd: id()}.


{hline}
{p}{it:note} I use individual in this document but it could be interchanged with the word 'observation' and meaning would be the same. This program should be used in cases where each row of your dataset constitutes a single individual.{p_end}
{hline}
Last Revised {it: 01/27/15}
{it: Update} - 01/27/15 - Fixed bugs that caused missing values to match.
{it: Update} - 03/06/13 - Fixed bugs, reduced number of lines of code.
{it: Update} - 12/18/12
{col 10} - Huge performance improvement - works on extremely large datasets now. 

{it: Update} - 06/27/12
{col 10} - Fixed issue where a maximum of only 1600 individuals could be matched. 

{it: Initial Release} - 12/18/11


