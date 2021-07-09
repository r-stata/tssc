{smcl}
{* *! version 1.0  09february2011}{...}
{cmd:help fvprevar}
{hline}


{title:Version of {helpb fvrevar} generating permanent result variables}


{title:Syntax}

{p 8 17 2}
{cmd:fvprevar} [{varlist}] {ifin} {cmd:,}
        {opt g:enerate(stub)}
        [
        {cmd:no}{opt lab:el}
	{opt sub:stitute}
	{opt ts:only}
	{opt l:ist}
        {opt fast}
	]

{phang}
You must {cmd:tsset} your data before using {cmd:fvprevar} if {it:varlist}
contains time-series operators; see {helpb tsset:[TS] tsset}.


{title:Description}

{pstd}
{cmd:fvprevar} is an extended version of {helpb fvrevar},
which returns the generated result variables as permanent variables
(instead of as temporary variables),
with names prefixed with a user-specified stub.


{title:Options}

{phang}
{opt generate(stub)} must be specified.
It specifies a prefix, used to produce names for the generated variables,
and suffixed by positive whole numbers from 1 to the number of generated variables.

{phang}
{cmd:nolabel} specifies that no variable labels will be defined
for the generated permanent result variables.
If {cmd:nolabel} is not specified,
then the generated permanent result variables
will have variable labels equal to the {help char:variable characteristic}
{it:varname}{cmd:[fvrevar]},
saved by {cmd:fvprevar} and {helpb fvrevar},
containing the expanded name of the virtual factor variable
corresponding to the generated variable.

{phang}
{opt substitute} specifies that equivalent, permanent variables,
with names prefixed using the {cmd:generate()} option,
will be substituted
for any expanded factor variables, interactions, or time-series-operated variables in
the {varlist}.
{opt substitute} is the default action taken by {opt fvprevar};
you do not need to specify the option.

{phang}
{opt tsonly} specifies that results variables will be substituted for
only the time-series-operated variables in {it:varlist}.

{phang}
{opt list} specifies that all factor-variable operators and time-series
operators be removed from {it:varlist}.
No new variables are created with this option.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:fvprevar} will do no extra work to restore the original dataset
(without the generated result variables) if the user presses {help break:Break}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}

{pstd}Describe the data{p_end}
{phang2}{cmd:. describe}{p_end}

{pstd}Create five variables {cmd:b_1}, {cmd:b_2}, {cmd:b_3}, {cmd:b_4} and {cmd:b_5},
containing the values for each level of factor variable {cmd:rep78}{p_end}

{phang2}{cmd:. fvprevar i.rep78, generate(b_)}{p_end}
{phang2}{cmd:. describe b_*}{p_end}


{title:Saved results}

{pstd}
{cmd:fvprevar} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(ngenvar)}}Number of generated result variables{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}the expanded variable list or list of base-variable names
{p_end}
{p2colreset}{...}

{pstd}
{cmd:fvprevar} (like {helpb fvrevar}) also sets, for each generated variable,
the {help char:variable characteristic} {it:varname}{cmd:[fvrevar]},
containing the expanded virtual factor variable name
for that generated variable.


{title:Also see}

{psee}
Manual:  {manlink R fvrevar}{p_end}

{psee}
{space 2}Help:  {manhelp fvrevar R}, {manhelp tsrevar TS}, {manhelp syntax P}, {manhelp unab P}
{p_end}
