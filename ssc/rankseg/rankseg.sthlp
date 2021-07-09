{smcl}
{* *! version 3.0 26 january 2018}{...}

{hline}
help file for {cmd:rankseg} version 3.0
{hline}

{title:Title}

{phang}
{bf:rankseg} {hline 2} compute rank-order segregation measures with finite sample-bias correction

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:rankseg}
{varlist}
{ifin}
{cmd:,} {opt ORDers(numlist)} {opt index}
 [options]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required Index Specifications}

{synopt:{opt ord:ers(numlist)}}Specifies the polyunomial order used in estimation{p_end}
{synopt:{opt h:seg} | {opt r:seg}}Specifies which segregation indices are computed{p_end}

            Note: at least one of the index options ({opt h:seg} | {opt r:seg}) must be specified.

{syntab:Optional Index Specifications}

{synopt:{opt by(varname)}}Specifies that segregation indices are to be calculated within each value of {varname}{p_end}
{synopt:{opt u:nit(varname)}}Specifies that segregation is to be calculated between observations with distinct values of {varname}{p_end}

{syntab:Output Options}

{synopt:{opt fil:e(filename)}}Specifies name of new file containing rank-order segregation values{p_end}
{synopt:{opt tfil:e(filename)}}Specifies name of new file containing binary segregation values at each threshold{p_end}
{synopt:{opt nodis:play}}Supppresses output display{p_end}
{synopt:{opt replace}}Specifies that {opt file} and {opt tfile} should overwrite existing files{p_end}

{syntab:Bias-Correction Options}

{synopt:{opt adj:ust}}Specifies the finite sample bias adjustment should be used{p_end}
{synopt:{opt pop:counts}}Specifies that variables in {varlist} describe population counts{p_end}
{synopt:{opt samp:counts}}Specifies that variables in {varlist} describe sample counts{p_end}
{synopt:{opt rat:e(varname)}}Specifies the variable containing the within-unit sampling rate{p_end}
{synopt:{opt tsiz:e(varname)}}Specifies the variable containinng the within-unit population size{p_end}
{synopt:{opt nsiz:e(varname)}}Specifies the variable containing the within-unit sample size{p_end}
{synopt:{opt wrep:lacement}}Specifies sampling was done with replacement (default is without replacement){p_end}

{synoptline}
{p2colreset}{...}
{p 4 4 2}
{cmd:weight}s are not allowed. use {opt tsiz:e} option to weight units.

{marker description}{...}
{title:Description}

{pstd}
{cmd:rankseg} calculates rank-order segregation indices for the variables in {varlist}.
The {opt by} and {opt unit} options allow specification of the organization level 
at which segregation is to be calculated. The {opt generate}, {opt file}, and 
{opt tfile} options allow index values for each value of the by-group variable(s) 
to be output to either the current file or new files. The bias-correction options 
perform finite sample bias adjustments to the computed indices. {opt adjust} must be specified to bias-correct the estimates.
{cmd:rankseg} requires the {cmd:seg} command to be installed.

{marker options}{...}
{title:Options}

{dlgtab: Required Index Specifications}

{phang}
{opt orders(numlist)} specifies the polynomial orders to be used in computing rank-order 
segregation.{it: numlist} must include non-negative integers, all of which must 
be less than K-1, where K is the number of ordered variables in {varlist}. If 
order 0 is specified, {cmd:rankseg} will compute the ordinal segregation indices 
described in Reardon (2009).

{phang}
{opt hseg} specifies that the Rank-Order Information Theory Index is to be calculated. If
{opt tfil:e(filename)} is specified, the (binary) Theil Entropy Diversity Index is also calculated at each 
threshold and saved to {it: filename}.

{phang}
{opt rseg} specifies that the Rank-Order Variance Ratio Index is to be calculated.  If
{opt tfil:e(filename)} is specified, the (binary) Simpson Diversity Index is also calculated at each 
threshold and saved to {it: filename}.

{dlgtab:Optional Index Specifications}

{phang}
{opt by(varlist)} specifies that the indices are to be calculated within {varlist}. 
If the {opt by} option is not sepcified, then segregation is calculated over the 
entire set of observations.

{phang}
{opt unit(varname)} specifies that segregation is to be calculated between 
observations with distinct values of {it:varname}. Observations are 
grouped on the unit variable, and segregation is calculated between these units. This
is used, for example, if each observation is a census block group (a subunit of a census tract) and one 
wants to calculate segregation between tracts. If the {opt unit} variable option 
is not specified, then each observation is treated as a separate unit. Note: The 
{opt unit} option cannot be used with the {opt adjust} option. Instead,
the data should be collapsed to the unit-level (and sampling rates or 
sample sizes should be computed for each unit) before running {cmd:rankseg}.

{dlgtab:Output Options}

{phang}
{opt nodisplay} specifies that output should be surpressed.  If two or more 
variables are listed in the {opt by} option, {opt nodisplay} is the default.

{phang}
{opt file(filename)} specifies that the values of the indices requested are to 
be written to a separate file. Note: {cmd:rankseg} reserves several variable 
names as defaults: {opt Total}, 
{opt nunits}, {opt h}{it:OrdNum}, abd {opt r}{it:OrdNum}, where {it: OrdNum} is an interger 
value from the the {opt: order} option. 
This can cause a conflict if a variable specified in the {opt by} option uses one 
of these reserved names. 

{phang}
{opt tfile(filename)} specifies that the pairwise values of the indices at each 
threshold are to be written to a separate file. 

{phang}
{opt replace}, when specified with the {opt file} or {opt tfile} option, forces {cmd:rankseg} 
to overwrite the file(s) specified in the {opt file} and {opt tfile} options, if they 
already exist. If {opt replace} is not specified and the file(s) already exist, 
they will not be overwritten.

{dlgtab:Bias-Correction Options}

{phang}
{opt adjust} specifies that finite sampling bias adjustments should be used. This 
option is only available for indices {opt h} and {opt r}. See Reardon, Bischoff, Owens, and 
Townsend (2018) for more on the bias adjustment.

{phang}
{opt popcounts} specifies that the counts in {varlist} are population counts, as 
opposed to sample counts. {opt popcounts} is the default when {opt sampcounts} is not 
specified. If {opt popcounts} is specified, but {opt nsize}, {opt rate}, and {opt wreplacement} 
are not specified, {cmd:seg} assumes self-weighting sampling 
with replacement. This option may not be specified with {opt sampcounts} or {opt tsize}.

{phang}
{opt sampcounts} specifies that the counts in {varlist} are sample counts, as opposed to 
population counts. If neither {opt popcounts} or {opt sampcounts} is specified, 
{opt popcounts} is assumed. If {opt sampcounts} is specified, but {opt tsize}, {opt rate}, and 
{opt wreplacement} are not specified, {cmd:seg} assumes self-weighting 
sampling with replacement. This option may not be specified with {opt popcounts} or 
{opt nsize}.

{phang}
{opt rate(varname)} indicates the variable containing the unit-level sampling rate. When 
{opt popcounts} and {opt nsize} are specified, {opt rate} is redundant and is not allowed. When 
{opt sampcounts} and {opt tsize} are specified, {opt rate} is redundant and is not allowed.

{phang}
{opt tsize(varname)} indicates the variable containing the within-unit population size. {opt tsize} 
may not be specified with {opt popcounts}. When {opt sampcounts} and {opt rate} 
are specified, {opt tsize} is redundant and is not allowed.
See above for restrictions using this option with other bias-correction options.

{phang}
{opt nsize(varname)} indicates the variable containing the within-unit sample size. {opt nsize} 
may not be specified with {opt sampcounts}. When {opt popcounts} and {opt rate} 
are specified, {opt nsize} is redundant and is not allowed.
See above for restrictions using this option with other bias-correction options.

{phang}
{opt wreplacement} specifies that sampling was done with replacement (default is 
without replacement).

{marker remarks}{...}
{title:Remarks}

{pstd}
The {varlist} variables should be non-negative integer counts of mutually exclusive 
ordered categories (e.g. counts by income category). The variables should be listed
in the order of the categories. The {opt by} option is used to specify the level of 
organization within which segregation is to be calculated, and the {opt unit} option 
is used to specify the level of organization between which segregation is to be 
calculated.  

{pstd}
Observations with missing values on any of the variables in {varlist} are dropped, 
as are observation with missing values on {opt by}, {opt unit}, {opt rate}, {opt nsize}, or
{opt tsize} if these are specified.

{pstd}
{cmd:rankseg} uses the user-written {cmd:seg} command, so {cmd:seg} must be installed.

{pstd}
{cmd:rankseg} calculates the indices using the formulas in Reardon (2011). The {opt adjust} 
option uses the formulas in Reardon, Bischoff, Owens, and Townsent (2018).

{pstd}
To adjust the segregation measures {opt h} and/or {opt r} for finite sampling bias, 
specify {opt adjust}. The {opt adjust} option requires {cmd: rankseg} to be passed or 
to calculate both the unit total (the sum of {varlist} by unit) and the unit-level 
sampling rate. In most cases, this means passing {cmd: rankseg}:

{phang2}
{opt popcounts} in combination with either a sampling rate variable (passed through 
{opt rate(varname)}) or a unit-level sampling count variable (passed using 
{opt nsize(varname)}); or

{phang2}
{opt sampcounts} in combination with either a sampling rate variable (passed 
through {opt rate(varname)}) or a unit-level total count variable (passed using 
{opt tsize(varname)}).

{pstd}
If {opt adjust} is specified without any other bias-correction options, or 
with {opt popcounts} or {opt sampcounts} only, {cmd:seg} assumes self-weighting 
sampling with replacement. {cmd:seg} assumes that {varlist} represents 
{opt popcounts} when neither {opt popcounts} nor {opt sampcounts} is specified 
(and the above outlined rules for passing {opt popcounts} with other 
bias-correction options are enforced).

{pstd}
See the helpfile for {cmd: seg} for more on how the segregation indices are calculated.

{marker examples}{...}
{title:Examples}

{pstd}
Suppose the data contain household counts counts by income category and
census tract, with variables {opt counry} and {opt msa} 
identifying the county and metropolitan area of each tract, and 
with variables {opt inc01}, {opt inc02},... {opt inc16} containing within-tract
household counts for 16 ordered income categories.  Then

{phang2}{cmd:. rankseg inc01-inc16, order(4) h}

{pmore2}
calculates the between-tract rank-order information theory index
among all tracts in the data set, using a 4th order polynomial.  

{phang2}{cmd:. rankseg inc01-inc16, order(4 5 6) h r by(msa) u(county)}

{pmore2}
calculates for each metropolitan area the between-county rank-order 
information theory index and the rank order variance ratio index, 
and outputs them to the variables {opt h4}, {opt h5}, and {opt h6} and {opt r4},
{opt r5}, and {opt r6}.

{pstd}
Suppose the data are based on samples rather than population counts, and suppose 
that the variable {opt srate} contains the sampling rate of students in a given 
school. Then

{phang2}{cmd:. rankseg inc01-inc16, order(4) h r by(msa) adjust sampcounts rate(srate) tfile(c:\outfile.dta)}

{pmore2}
calculates for each metropolitan area the between-county rank-order 
information theory index and the rank order variance ratio index, as well as bias-adjusted
versions of these indices, and outputs both to the the file "c:\outfile.dta". Because the option
{opt tfile} was specified, the rank-order indices variables, which are named {opt h4}, {opt h4_adj}, 
{opt r4}, and {opt r4_adj}, will be output with the pairwise values of the indices at each
threshold; the names will be {opt h}, {opt h_adj}, {opt r}, and {opt r_adj}

{marker author}{...}
{title:Authors}

{pstd}
sean f. reardon{p_end}
{phang}sean.reardon@stanford.edu{p_end}

{phang}Joseph B. Townsend{p_end}
{phang}townsend.joseph@gmail.com

{marker references}{...}
{title:References}

{phang}Reardon, S.F. (2011). {browse "https://cepa.stanford.edu/content/measures-income-segregation":"Measures of Income Segregation"}. CEPA Working Paper.

{phang}Reardon, S.F. (2009). "Measures of Ordinal Segregation". Research on Economic Inequality, 17: 129-155.
	  
{phang}Reardon, S.F., Bischoff, K., Owens, A., & Townsend, J.B. 2018. {browse "https://tinyurl.com/yaa8rjhs":"Has Income Segregation Really Increased? Bias and Bias Correction in Sample-Based Segregation Estimates."}


	  
{*    {it:genlist} must have the form:																		} 
{*        ({it:index} {it:newvar} [{it:index} {it:newvar} [{it:index} {it:newvar} [...]]])					}
{*    where {it:index} indicates the index to be output, and {it:newvar}									}
{*    is the name of the variable to be created.  {it:index} must be 										}
{*    one of the following:																					}
{*        {it:t}      for total by-group counts																}
{*        {it:u}      for the number of units within each by-group											}	
{*       	{it:h}      for Information Theory Segregation Index											}
{*       	{it:hadj}   for Bias-adjusted Information Theory Segregation Index								}
{*       	{it:hadj2}  for Alternate Bias-adjusted Information Theory Segregation Index (not recommended)	}
{*        {it:r}      for Relative Diversity Segregation Index												}
{*        {it:radj}   for Bias-adjusted Relative Diversity Segregation Index								}
{*        {it:o}      for Hutchens' Square Root Segregation Index											}
