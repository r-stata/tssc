{smcl}
{* NJC 16dec2016} 
{viewerjumpto "Syntax" "stripolate##syntax"}{...}
{viewerjumpto "Description" "stripolate##description"}{...}
{viewerjumpto "Remarks" "stripolate##remarks"}{...}
{viewerjumpto "Options" "stripolate##options"}{...}
{viewerjumpto "Examples" "stripolate##examples"}{...}
{title:Title}

{p2colset 5 20 20 2}{...}
{p2col :stripolate{space 2}{hline 2}}  Interpolate string values{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:stripolate}
{it:stryvar}
{it:xvar}
{ifin}
{cmd:,}
{opth gen:erate(newvar)} 
[
{opt f:orward}
{opt b:ackward}
{opt g:roupwise} 
]

{phang}
{opt by} is allowed; see {manhelp by D}. 
A {cmd:by()} option may be specified instead, but not in conjunction. 


{marker description}{...}
{title:Description}

{pstd}
{opt stripolate} creates in {newvar} an interpolation of the string
variable {it:stryvar} on {it:xvar} for missing values of {it:stryvar}. 

{pstd}
{opt stripolate} uses one of the following methods: forward, backward,
groupwise. One of these options must be specified. 


{marker remarks}{...}
{title:Remarks}

{pstd}
Interpolation requires that {it:stryvar} be a function of {it:xvar}, so
cannot proceed if two or more distinct non-missing values are observed
for {it:stryvar} fr the same {it:xvar} 
(or with the {cmd:by:} prefix, for the same 
{it:xvar} and the same values of the variables specified by {cmd:by:}).
When {it:stryvar} is not missing, the value of {it:newvar} is just
{it:stryvar}.

{pstd}
{cmd:stripolate} does not require {help tsset} or {help xtset} data and
makes no check for, or use of, any such settings. With panel data, it
will usually be essential to specify a panel identifier to {cmd:by:}. 

{pstd} 
Use of the {cmd:by:} prefix restricts interpolation to at most
the same group of observations as defined by the variable(s) specified. 


{marker options}{...}
{title:Options}

{phang}{opth generate(newvar)} is required and specifies the name of the
new variable to be created.

{phang}{opt forward} specifies forward interpolation, so that any known 
value just before one or more missing values is copied in cascade to 
provide interpolated values, constant within any such block. 

{phang}{opt backward} specifies backward interpolation, so that any known 
value just after one or more missing values is copied in cascade to 
provide interpolated values, constant within any such block. 

{phang}{opt groupwise} specifies that non-missing values be copied to
missing values if, and only if, just one distinct non-missing value
occurs in each group. Thus a group of values "", "A", "", "" qualifies
as "A" is not missing and is the only non-missing value in the group.
Hence the missing values in that group will be replaced with "A" in the
new variable.  By the same rules "A", "", "A", "" qualifies but "A", "",
"B", "" does not.  Normally, but not necessarily, this option is used in
conjunction with {cmd:by:}, which is how groups are specified; otherwise
the (single) group is the entire set of observations being used. 

{pmore}Note that {it:xvar} is strictly irrelevant for this method, as
order of values is immaterial. To keep syntax consistent, it should be
specified any way. 


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 15}{p_end}
{phang2}{cmd:. gen id = ceil(_n/5)}{p_end}
{phang2}{cmd:. bysort id: gen time = _n}{p_end}
{phang2}{cmd:. gen foo = "A" if inlist(_n, 2, 4)}{p_end}
{phang2}{cmd:. replace foo = "B" if inlist(_n, 6, 8, 12)}{p_end}
{phang2}{cmd:. replace foo = "C" in 14}

{pstd}List the data{p_end}
{phang2}{cmd:. list, sepby(id)}

{pstd}Methods illustrated{p_end} 
{phang2}{cmd:. by id: stripolate foo time, gen(barf) forward}{p_end}
{phang2}{cmd:. by id: stripolate foo time, gen(barb) backward}{p_end}
{phang2}{cmd:. by id: stripolate foo time, gen(barg) groupwise}

{pstd}List the data and results{p_end}
{phang2}{cmd:. list, sepby(id)}


{title:Author}

{pstd}Nicholas J. Cox, Durham University, U.K.{break}  
    n.j.cox@durham.ac.uk


{vieweralsosee "mipolate (SSC)"}{...}
