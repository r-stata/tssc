{smcl}
{* *! version 1.2.1  07mar2013}{...}
{viewerjumpto "Title" "swindex##title"}{...}
{viewerjumpto "Syntax" "swindex##syntax"}{...}
{viewerjumpto "Description" "swindex##description"}{...}
{viewerjumpto "Options" "swindex##options"}{...}
{viewerjumpto "Remarks" "swindex##remarks"}{...}
{viewerjumpto "Examples" "swindex##examples"}{...}
{cmd:help swindex}{right: ({browse "https://doi.org/10.1177/1536867X20976325":SJ20-4: st0622})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{cmd:swindex} {hline 2}}A command to create a standardized weighted
index of multiple indicator variables{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:swindex}
{it:varlist}
{ifin}{cmd:,} {opth g:enerate(varname)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {opth g:enerate(varname)}}specify the new variable that takes the value of the constructed composite index{p_end}
{synopt:{opt replace}}specify that if the variable in {cmd:generate()} already exists, it should instead be replaced{p_end}
{synopt:{opth fl:ip(varlist)}}reverse the sign of specified variables in {it:varlist} when calculating the index{p_end}
{synopt:{opth norm:by(varname)}}specify that only observations for which {it:varname} is equal to one shall be used to normalize the variables in {it:varlist} for generalized least-squares (GLS) weighting procedure{p_end}
{synopt:{opt nos:td}}do not normalize the variables in {it:varlist} for GLS weighting procedure; cannot be combined with {cmd:normby()}{p_end}
{synopt:{opt fullr:escale}}rescale the final index based on the full sample mean and standard deviation; cannot be combined with {cmd:norescale}; default when {cmd:normby()} and {cmd:nostd} are not specified{p_end}
{synopt:{opt nore:scale}}specify no rescaling of the final index; cannot be combined with {cmd:fullrescale}{p_end}
{synopt:{opth n:umvars(newvar)}}store in {it:newvar} the number of nonmissing variables of {it:varlist} for each observation{p_end}
{synopt:{opt d:isplayw}}display the index weights for each indicator in {it:varlist}{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
* {opt generate(varname)} is required.


{marker description}{...}
{title:Description}

{pstd}
{cmd:swindex} calculates a standardized weighted index from the variables in
{it:varlist}.  The procedure follows a GLS weighting procedure as described in
Anderson (2008).

{pstd}
Several options are provided to allow the user to customize the calculation.
Variables included in the index should work in the same direction (for
example, increases in the variables all indicate better outcomes).
{cmd:swindex} allows users to include variables that move in the opposite
direction (for example, where increases indicate worse outcomes) by specifying
them in {it:varlist} provided in the option {cmd:flip()}.  The signs of
variables included in {cmd:flip()} will change for the purposes of the
calculation, but no changes are made to the dataset in memory.

{pstd}
The recommended method standardizes the indicator variables in {it:varlist}
prior to constructing the inverted covariance matrix used in the GLS weighting
procedure.  This standardization can employ a subsample (for example, the
control group) as a reference group, or otherwise use the full sample as a
reference group, for calculating the mean and standard deviation used for
normalization.  By default, the program normalizes against the full sample
mean and standard deviation, which is equivalent to obtaining the weights by
inverting the correlation matrix.  If the user wishes to use the mean and
standard deviation from a subsample, the user may specify the subsample
varname using the {cmd:normby()} option.  For example, in a randomized
trial, the {cmd:normby()} option can be used to standardize based on the
control group subsample.  The user can also opt not to standardize by invoking
{cmd:nostd}, though this is not recommended for most applications.

{pstd}
By default, the program rescales the calculated index to the mean and standard
deviation of the sample used for the standardization in the GLS weighting
procedure.  This rescaling results in an "effect size" interpretation where
the index is distributed mean zero with standard deviation one within the
sample used.  The {cmd:fullrescale} option allows the user to rescale the
calculated index using the full sample, even if {cmd:normby()} has been
invoked for the GLS weighting procedure.  Further, the user can opt not to
rescale at all by specifying {cmd:norescale}.

{pstd}
The procedure accommodates construction of the index even when data on
indicators are missing.  It does so by setting missing indicator values to
zero, which is the mean of the reference group following normalization.  The
{cmd:numvars()} option saves the number of variables in {it:varlist} missing
for each observation.


{marker options}{...}
{title:Options}

{phang}
{opth generate(varname)} creates a new variable that takes the value of the
constructed composite index.  {it:varname} in {cmd:generate()} does not have
to be a new varible name.  Use the option {cmd:replace} if {it:varname} exists
and is to be replaced.  {cmd:generate()} is required.

{phang}
{opt replace} changes the contents of an existing variable.  Because
{cmd:replace} alters data, the command cannot be abbreviated.

{phang}
{opth flip(varlist)} alters the sign of variables in {it:varlist} to calculate
the index.  This command should be used when the variables in {it:varlist}
move in the opposite direction as the summary index (for example, where
increases indicate "worse" outcomes).  The variables in {it:varlist} provided
in {cmd:flip()} must be a subset of the variables in {it:varlist}.  Invoking
this option will not result in changes to the variables in {it:varlist} in the
permanent dataset.

{phang}
{opth normby(varname)} specifies the reference group over which to standardize
the variables in {it:varlist} during the GLS weighting procedure.  When one
estimates impacts from a randomized intervention, {cmd:normby()} will
typically be an indicator for being in the control group.  The specified
varname must be a binary variable.  With {cmd:normby()}, the specified
varname is also used to rescale the calculated index unless the
{cmd:fullrescale} or {cmd:norescale} option is specified.  This option cannot
be combined with {cmd:nostd}.

{phang}
{opt nostd} specifies that no standardization should take place during the GLS
weighting procedure.  When {cmd:nostd} is specified, the calculated index is
also not rescaled unless {cmd:fullrescale} is specified.  This option cannot
be combined with {cmd:normby()}.

{phang}
{opt fullrescale} specifies the full sample be used to rescale the calculated
index.  This is the default option when {cmd:normby()} and {cmd:nostd} are not
specified.

{phang}
{opt norescale} specifies that the calculated index not be rescaled.  This is
the default option when {cmd:nostd} is specified.

{phang}
{opth numvars(newvar)} stores the number of nonmissing variables in
{it:varlist} for each observation.

{phang}
{opt displayw} interactively displays the proportional weights used in the
index calculation.  The displayed weight matrix is also stored in the return
list as {cmd:r(pw)}, while the raw weights are stored as {cmd:r(wt)}.


{marker examples}{...}
{title:Examples}

{pstd}
Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}
Create a new index called {cmd:sizeindex} from the variables {cmd:trunk},
{cmd:weight}, and {cmd:length}.  By default, size index will be standardized
using the full sample standard deviation and rescaled to be a standard normal
variable over the full sample.{p_end}
{phang2}{cmd:. swindex trunk weight length, generate(sizeindex)}{p_end}

{pstd}
Replace {cmd:sizeindex} with an index that standardizes over the standard
deviation of foreign cars only.{p_end}
{phang2}{cmd:. swindex trunk weight length, generate(sizeindex) normby(foreign) replace}{p_end}

{pstd}
Replace {cmd:sizeindex} with an index that standardizes over the standard
deviation of foreign cars but includes the negative value of {cmd:mpg}.{p_end}
{phang2}{cmd:. swindex trunk weight length mpg, generate(sizeindex) replace flip(mpg) normby(foreign)}{p_end}


{title:Stored results}

{pstd}
{cmd:swindex} stores the following in {cmd:r()}:{p_end}

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(pw)}}matrix of proportional weights used to construct index variable{p_end}
{synopt:{cmd:r(wt)}}matrix of raw weights used to construct index variable{p_end}


{title:Reference}

{phang}
Anderson, M. L. 2008. Multiple inference and gender differences in the effects
of early intervention: A reevaluation of the Abecedarian, Perry Preschool, and
Early Training Projects.
{it:Journal of the American Statistical Association} 103: 1481-1495.
{browse "https://doi.org/10.1198/016214508000000841"}.


{marker authors}{...}
{title:Authors}

{pstd}
Benjamin Schwab{break}
Kansas State University{break}
Department of Agricultural Economics{break}
Manhattan, KS{break}
benschwab@ksu.edu

{pstd}
Sarah Janzen{break}
University of Illinois at Urbana Champaign{break}
Department of Agricultural and Consumer Economics{break}
Urbana, IL{break}
sjanzen@illinois.edu

{pstd}
Nicholas P. Magnan{break}
University of Georgia{break}
Department of Agricultural and Applied Economics{break}
Athens, GA{break}
nmagnan@uga.edu

{pstd}
William M. Thompson{break}
IDInsight{break}
New Delhi, India{break}
will.thompson@idinsight.org


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 20, number 4: {browse "https://doi.org/10.1177/1536867X20976325":st0622}{p_end}
