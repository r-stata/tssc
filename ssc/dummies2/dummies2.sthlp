{smcl}
{* version 1.0.5 21aug2012}{...}
{cmd:help dummies2}
{hline}

{title:Title}

{p 5}
{cmd:todummies} {hline 2} Create indicator variables from  
categorical variable or vice versa


{title:Syntax}

{p 5}
Create indicator variables from categorical variable

{p 8}
{cmd:todummies} {varname} [{it:levspec} [{it:levspec ...}]] {ifin} 
[ {cmd:,} {it:to_options}] 


{p 5}
where {it:levspec} is

{p 8}
{it:#} [{cmd:"}{it:varlabel}{cmd:"}] | 
{cmd:(}{it:{help numlist}} [{cmd:"}{it:varlabel}{cmd:"}]{cmd:)}

{p 5}
and parentheses and double quotes are required.


{p 5}
Create categorical variable from indicator variables

{p 8}
{cmd:fromdummies} {varlist} {ifin} {cmd:,} {opt g:enerate(newvarname)}
[{it:from_options}]


{title:Description}

{pstd}
{cmd:todummies} creates indicator variables 
(also called dummy variables) from one categorical variable.

{pstd}
One indicator variable is created for each specified level of the 
categorical variable. Enclosing more than one level in parentheses, 
creates one dummy variable, indicating observations for which 
{it:varname} equals one of these values. Omitted levels will be coded 
as missing values in the created indicator variables. Omitting all 
levels, results in one indicator for each level of the original 
variable (see {help tabulate oneway:tabulate}).

{pstd}
{cmd:min} and {cmd:max} may be used as {it:#} and in {it:numlist} to 
refer to the minimum and maximum of {it:varname}. Consecutive {it:#} 
may be specified as a {help numlist} of the form 
{it:from}{bf:/}{it:to} (There is no space between {it:from}, {cmd:/} 
and {it:to}). There may not be more than 249 distinct values 
specified.

{pstd}
Indicator variables will be labeled according to the value labels of 
the categorical variable, if no variable labels are specified. If 
{it:varname} has no value label attached, the dummies will not be 
labeled.


{pstd}
{cmd:fromdummies} creates one categorical variable from binary 
indicator variables. It thus reverses

{phang2}{help tabulate oneway:{bf:tabulate}} {varname} 
{cmd:,generate(}{it:stubname}{cmd:)}{p_end}

{pstd}
A value label is defined for {it:newvarname}, associating variable 
labels attached to variables in {it:varlist} with the corresponding 
values in {it:newvarname}.


{title:Options}

{dlgtab:to_options}

{phang}
{opt g:enerate}{cmd:(}{it:namelist}|{it:stub}{cmd:)} specifies names 
for the indicator variables. If one {it:stub} is specified, dummies 
{it:stub{bf:1}}, {it:stub{bf:2}}, {it:...} will be created. If 
{opt generate} is not specified, {it:stub} defaults to {it: varname}.

{phang}
{opt ref:erence}{cmd:(}{it:{help numlist}}{cmd:)} specifies values of 
{it:varname} to be used as the reference category. No additional 
indicator variable will be created. Instead, observations for 
which {it:varname} equals one of the values in {it:numlist} are coded 
0 in all indicator variables. {hi:rest} may be specified as reference, 
meaning all (nonmissing) values not specified in {it:levspec}. This 
option is ignored if no levels are specified.

{phang}
{opt sic} changes the default {it:stub} to {it:varname} as typed 
(possibly abbreviated), if {opt generate} is not specified. If only 
one indicator variable is created, {opt sic} suppreses numeric 
suffixes.

{phang}
{opt novarl:abel} prevents labeling the indicator variables.


{dlgtab:from_options}

{phang}
{opt g:enerate(newvarname)} specifies the name for the categorical 
variable. This is a required option.

{phang}
{opt ref:erence} creates the categorical variable, even if the dummies 
do not add up to 1. Observations for which all dummies are 0, are 
coded {it:k} + 1, where {it:k} is the number of indicator variables.
The value label "reference" is added. {cmd:fromdummies} aborts with an 
error if the sum of the dummies is larger than 1.

{phang}
{opt nam:es} in the created value label, associates variable names in 
{it:varlist} with corresponding values in {it:newvarname}.

{phang}
[{hi:{ul:no}}]{opt vall:abel}[{opt (lblname)}] defines {it:lblname} as 
a value label for the categorical variable. Default {it:lblname} is 
{it:newvarname}. {opt novallabel} does not create a value label for 
the categorical variable.

{phang}
{opt varl:abel(name)} specifies a variable label for the categorical 
variable. There is no default variable label.


{title:Remarks} 

{pstd}
{cmd:todummies vs.} {bf:{help todummy}}

{pstd}
{cmd:todummies} is useful to create indicator variables from one 
categorical variable, if some of the levels are to be collapsed. 

{pstd}
Say we have a variable, {hi:foo}, with 5 levels: values 1 to 5. We 
want to create one binary variable, indicating level 1 and another 
indicator variable, representing levels 2 to 3. Level 4 is the 
reference, and level 5 represents missing values. 

{pstd}
There are many ways to create our variables. Here is one:

{phang2}{cmd:. recode foo (3 = 2)(5 = .), generate(bar)}{p_end}
{phang2}{cmd:. tabulate bar ,generate(foobar)}{p_end}

{pstd}
We can now use variables {hi:foobar1} and {hi:foobar2} in our 
analysis, omitting variable {hi:foobar3} as the reference.

{pstd}
Here is how we use {cmd:todummies} to create the indicator variables

{phang2}{cmd:. todummies foo 1 (2 3) ,reference(4) generate(foobar)}{p_end}

{pstd}
Basically we collapsed the two lines of code above, into one line. 
Note that {hi:foobar3} is not created in this example.

{pstd}
We can also use {cmd:todummy} to create the indicator variables, coding

{phang2}{cmd:. todummy foo if (foo != 5) ,values(1 \ 2 3 \ 4) stub(foobar)}{p_end}

{pstd}
As with {cmd:todummies}, we have one line of code, but the need to 
specify an {help if} qualifier makes this approach less convenient. 
The {cmd:if} qualifier makes sure that all observations with value 5 
in variable {hi:foo} are coded {hi:.} (missing value) in the created 
indicator variables. Because specifying an {cmd:if} qualifier is 
easily forgotten, I recommend using {cmd:todummies}. Also, from a 
more technical point of view, {cmd:todummy} is very slow.


{title:Examples}

{phang2}{cmd:. sysuse nlsw88}{p_end}
{phang2}{cmd:. todummies race 2 (1 3) ,generate(black other)}{p_end}
{phang2}{cmd:. fromdummies black other ,generate(race2)}{p_end}

{phang2}{cmd:. todummies occ (1/2 "High occ.") 3/4 ,reference(9 10) sic}{p_end}
{phang2}{cmd:. fromdummies occ? ,generate(occu) names reference}{p_end}


{title:Acknowledgments}

{pstd}
{cmd:dummies2} is inspired by {stata findit dummies:dummies} 
and {stata findit dummieslab:dummieslab} by Nick Cox and 
Philippe van Kerm. 


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help tabulate}, {help fvvarlist} (Stata 11 an higher)
{p_end}

{psee}
if installed: {help dummies}, {help dummieslab}, {help todummy}{p_end}
