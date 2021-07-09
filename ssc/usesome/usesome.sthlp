{smcl}
{* version 1.2.0}{...}
{cmd:help usesome}
{hline}

{title:Title}

{p 5}
{cmd:usesome} {hline 2} {help Use} subset of Stata dataset


{title:Syntax}

{p 8}
{cmd:usesome} [{it:varspec}] {helpb using} {it:{help filename}}
[{cmd:,} {opt not} {it:{help usesome##sopt:s-options}} 
{it:options}]


{p 5}
where {it:varspec} is 

{p 8}
[{varlist}] [{cmd:(}{it:{help numlist}}{cmd:)}
[{cmd:(}{it:{help numlist}}{cmd:)} {it:...}]]

{p 5 5}
In {it:{help numlist}} integers in the range 0 < # <= {it:k} and 
{hi:k} are allowed, where {it:k} is the number of variables in the 
dataset to be used and {hi:k} will be replaced with {it:k}. Note 
that each (expanded) {it:{help numlist}} is limited to 1600 elements. 
Parentheses around {it:{help numlist}} are required.


{title:Description}

{pstd}
{cmd:usesome} loads a subset of a Stata dataset into memory. The 
program is similar to official Stata's {help use} but enhances its 
functionality in three ways:

{phang2}1. the user may specify variables that are {hi:not} to be used
{p_end}

{phang2}2. the user may specify properties of variables instead of 
variable names{p_end}

{phang2}3. the user may specify variable indices instead of variable 
names{p_end}

{pstd}
These enhancements are intended for use with flavors of Stata, where 
the maximum number of variables allowed in a dataset is rather small 
(2,047 for Stata IC, 99 for Small Stata). The current settings allow 
a maximum number of {ccl maxvar} variables.


{title:Options}

{phang}
{opt not} loads variables not specified in {it:varspec} from 
{it:filename}. In other words: variables in {it:varspec} are 
not loaded.

{marker sopt}{...}
{phang}
{it:{opt s-options}} are the {it:Advanced} {help ds} options 
{opt has(spec)}, {opt not(spec)} and {opt inse:nsitive}, and select 
variables by properties. All variables {help ds} returns in 
{cmd:r(varlist)} are added to the variables specified in {it:varspec}. 
All {help ds} options (except {opt not}) are allowed. However, since 
{cmd:usesome} does not show any {help ds} output, specifying {it:Main} 
options will merely slow down execution time.

{phang}
{opt clear} allows the data in memory to be replaced.

{phang}
{cmd:if(}{it:{help exp}}{cmd:)} loads the subset of the dataset for 
which {it:exp} is true. Variable names specified in {it:exp} must 
also be specified in {it:varspec}.

{phang}
{cmd:in(}{it:{help in:range}}{cmd:)} specifies observations to be used 
from {it:filename}.

{phang}
{opt nol:abel} is the same as {opt nolabel} used with {help use}. 

{phang}
{opt findname}[{cmd:not}] uses user-written 
{stata findit findname:findname} (Cox 2010, 2012) instead of {help ds} 
to select variables by properties. {opt findnamenot} finds, and adds 
to {it:varspec}, variables that do not have the specified properties. 
As with {help ds}, all {help findname} options (except {opt not}) are 
allowed, but not all of them are useful. It is not allowed to mix 
{help ds} and {help findname} options.


{title:Remarks}

{pstd}
{cmd:usesome} is not to be understood as an alternative to {help use}, 
as its enhancements may come with speed penalties (see 
{help usesome##tech:Technical remarks}). Whenever {help use} can be 
used, doing so is probably faster than using {cmd:usesome}, although 
slightly more typing might be involved. 

{pstd}
I will consider three examples where the enhancements of {cmd:usesome} 
come handy, before discussing circumstances under which {help use} 
might be preferred.

{pstd}
{ul:Using {cmd:usesome}}

{pstd}
Suppose we know that all variable names we do {hi:not} want to load 
from a dataset end with {hi:_xyz}, but none of the variables we want 
does. We can load the subset of the dataset typing

{phang2}{cmd:usesome *_xyz using {it:filename} ,not}{p_end}

{pstd}
Or, if we know that all variables we want to load have variable labels 
containing {hi:xyz}, while none of the variables we do not want to 
load has, we load this subset typing

{phang2}{cmd:usesome using {it:filename} ,has(varlabel *xyz*)}
{p_end}

{pstd}
Finally, suppose we do not know the names of the variables we want to 
load but their position in the dataset and want to load variables 
1-50, 100-200, 500, 510 and 520. We do so typing

{phang2}{cmd:usesome (1/50 100/200 500(10)520) using {it:filename}}
{p_end}

{pstd}
{ul:Using {helpb use}}

{pstd}
If the number of variables in {it:filename}, in the examples described 
above, does not exceed the limits of our Stata version (see 
{help memory:maxvar}), we can use official Stata's {help use} to load 
the entire dataset into memory and select the subset afterwards. Doing 
so, in the first example we type the two lines

{phang2}{cmd:use {it:filename}}{p_end}
{phang2}{cmd:drop *_xyz}{p_end}

{pstd}
In the second example we type three lines of code.

{phang2}{cmd:use {it:filename}}{p_end}
{phang2}{cmd:ds ,has(varlabel *xyz*)}{p_end}
{phang2}{cmd:keep `r(varlist)'}{p_end}

{pstd}
The third example requires two lines, including one line of 
{help mata:Mata} code. The code is

{phang2}{cmd:use {it:filename}}{p_end}
{phang2}
{cmd:mata : st_keepvar((1..50, 100..200, 500, 510, 520))}
{p_end}

{pstd}
If, however, the number of variables in {it:filename} exceeds the 
limit of our Stata version, {help use} can only be directly applied 
if we know (and are willing to specify) the names of all variables we 
wish to load. Whenever this "keep-logic" is convenient, {help use} is 
convenient.

{marker tech}{...}
{pstd}
{ul:Technical remarks}

{pstd}
As stated, {cmd:usesome} might be comparatively slow, and will be if 
{it:{opt s-options}} are specified. In this case, loading a subset 
of {it:filename}, {cmd:usesome} splits the variable list in 
{it:filename} into parts (chunks), small enough not to hit the limits 
imposed by {help memory:maxvar}. {cmd:usesome} then loads each part of 
{it:filename} into memory, selects the variables indicated by 
{it:{opt s-options}} and finally loads the specified subset of 
{it:filename}.


{title:Examples}

{pstd}
Load all variables, except {hi:foreign}, from the auto dataset.

{phang2}{cmd:. usesome foreign using}
{cmd:http://www.stata-press.com/data/r11/auto ,not}{p_end}

{pstd}
Load all variables with value labels attached from the auto dataset.

{phang2}{cmd:. usesome using}
{cmd:http://www.stata-press.com/data/r11/auto}
{cmd: ,has(vallabel) clear}{p_end}

{pstd}
Load the first three and last three variables from the auto dataset.

{phang2}{cmd:. usesome (1/3 k-2/k) using}
{cmd:http://www.stata-press.com/data/r11/auto ,clear}{p_end}


{title:Saved results}

{pstd}
{cmd:usesome} saves the following in {cmd:r()}:

{pstd}
Scalars{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(k)}}number of variables in {it:filename}{p_end}
{synopt:{cmd:r(chunks)}}number of {it:varlist}s 
({cmd:r(k)}/{ccl maxvar}){p_end}

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(varspec)}}{it:varspec} fully expanded{p_end}
{synopt:{cmd:r(varlist)}}variable names in {it:filename} 
(if {cmd:r(k)} < {ccl maxvar}){p_end}
{synopt:{cmd:r(varlist}{it:#}{cmd:)}}{it:#} of {cmd:r(chunks)} 
lists of variable names in {it:filename}{p_end}


{title:References}

{p 4 8 2}
Cox, N. J. 2012. Update: Finding variable names. {it:Stata Journal}
volume 12, number 1. 
({browse "http://www.stata-journal.com/article.html?article=up0035":dm0048_2})

{p 4 8 2}
Cox, N. J. 2010. Update: Finding variable names. {it:Stata Journal} 
volume 10, number 4. 
({browse "http://www.stata-journal.com/article.html?article=up0030":dm0048_1})

{p 4 8 2}
Cox, N. J. 2010. Speaking Stata: Finding variables. {it:Stata Journal}
volume 10, number 2. 
({browse "http://www.stata-journal.com/article.html?article=dm0048":dm0048})


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help use}, {help describe}, {help ds}, {help drop}, 
{help nlist}{p_end}

{psee}
if installed: {help findname}, {help usedrop}, {help chunky}, 
{help savesome}{p_end}
