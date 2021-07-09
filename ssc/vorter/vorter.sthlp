{smcl}
{cmd:help vorter}
{hline}

{title:Title}

{p 5 12 2}
{cmd:vorter} {hline 2} Reorder variables in dataset based on sorted 
values


{title:Syntax}

{p 5 12 2}
Order based on values in observation

{p 8 16 2}
{cmd:vorter} [{cmd:+}|{cmd:-}] {varlist} 
[{help in:{it:in}} {it: #}]
[{cmd:, not} {it:{help order:order-options}}]


{p 5 12 2}
Order based on statistic

{p 8 16 2}
{cmd:vorter} [{cmd:+}|{cmd:-}] 
{cmd:(}{it:{help vorter##stat:statspec}}{cmd:)} {varlist}
{ifin}
[{cmd:, not} {it:{help order:order-options}}]


{p 5 12 2}
Order randomly

{p 8 16 2}
{cmd:vorter} [{cmd:+}|{cmd:-}] {cmd:({ul:rand}om)} {varlist} 
[{cmd:, not} {it:{help order:order-options}}]

{marker stat}
{p 5 8 2}
where {it:statspec} is {it:stat} [{cmd:,} {opt m:issing}], 
and {it:stat} is one of {opt m:ean}, {opt cou:nt}, {opt ma:x}, 
{opt mi:n}, {opt su:m}, {opt sd} or {opt v:ariance}. If  
suboption {opt m:issing} is specified with {opt mean}, 
{opt max}, {opt min} or {opt sum}, missing values are 
terated as such. Default is to ignore missing values. Option 
{opt missing} may not be specified with any other {it:stat}. 


{title:Description}

{pstd}
{cmd:vorter} reorders variables in the dataset based on sorted 
values. Values are sorted in ascending order if {hi:+} or nothing 
is typed in front of {it:varlist} or {cmd:(}{it:statspec}{cmd:)}, 
and in descending order if {hi:-} is typed.

{pstd}
The first syntax orders variables according to the sorted values 
in the {it:#}th observation. If no observation is specified, the 
first observation is used. 

{pstd}
The second syntax orders variables according to the specified 
{it:stat}. Think of this as adding one observation to the 
dataset, holding the specified {it:stat} for the respective 
variables in {it:varlist}. {cmd:vorter} sorts on the values of 
this additional observation. String variables are not allowed.

{pstd}
The third syntax orders variables randomly. Technically, each 
variable is assigned a random number between 0 and (nearly) 1 
(see {help runiform()}). {cmd:vorter} sorts on this random 
number. 


{title:Options}

{phang}
{opt not} does not change the order of variables in the dataset, 
but still returns the reordered list of variable names in 
{cmd:r(varlist)}.

{phang}
{it:{help order:order-options}} are options used with 
{helpb order}. Options {opt alphabetic} and {opt sequential} 
are ignored.


{title:Examples}

{pstd}
Set up

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. input str5 othervar v1 v2 v3 v4 v5}{p_end}
{phang2}{cmd:"obs1" 1 3 2 5 4}{p_end}
{phang2}{cmd:"obs2" 2 3 6 . 0}{p_end}
{phang2}{cmd:end}{p_end}

{pstd}
Reorder variables {cmd:v1-v5} in descending order of the 
values in the first observation  

{phang2}{cmd:. vorter - v1-v5 in 1}{p_end}

{pstd}
Reorder variables staring with {cmd:v} according to their mean, 
placing them after {cmd:othervar}

{phang2}{cmd:. vorter (mean) v* , after(othervar)}{p_end}

{pstd}
Reestablish the original order

{phang2}{cmd:. order `r(corder)'}{p_end}


{title:Saved results}

{pstd}
{cmd:vorter} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(varlist)}}{varlist} reordered{p_end}
{synopt:{cmd:r(oorder)}}{varlist} in original order{p_end}
{synopt:{cmd:r(corder)}}complete list of variable names in 
original order{p_end}

{pstd}
Matrices{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r({it:stat})}}specified statistic for {varlist}{p_end}


{title:Acknowledgments}

{pstd}
Tamás Keller suggested ordering variables randomly.

{pstd}
A question from an anynymous poster and answers by Joseph Coveney 
and Jorge Eduardo Perez Perez to 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1306002-sort-on-the-number-of-observations":Statalist}
stimulated sorting on statistics.

{pstd}
A first draft of the program appeared as an answer to a question on 
{browse "http://www.stata.com/statalist/archive/2012-12/msg00577.html":Statalist} 
posted by Pedro Nakashima.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help order}, {help sort}, {help gsort}
{p_end}
