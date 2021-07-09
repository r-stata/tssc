{smcl}
{* *! version 3.0, January 2018} {...}

{hline}
help file for {cmd:seg} version 3.0
{hline}

{title:Title}

{phang}
{bf:seg} {hline 2} compute multiple-group diversity and segregation indices with 
finite sample-bias correction

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:seg}
{varlist}
{ifin}
{cmd:,}
{cmd: index}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required Index Specifications}

{synopt: Specifies which segregation indices are computed}{p_end}

{pmore}
At least one of the index options ({opt d} | {opt g} | {opt h} | {opt c} | {opt r} | {opt p} | {opt x} | {opt s} | {opt n}) must be specified.

{syntab:Optional Index Specifications}

{synopt:{opt by(varname)}}Specifies that segregation indices are to be 
calculated within each value of {varname}{p_end}
{synopt:{opt u:nit(varname)}}Specifies that segregation is to be calculated 
between observations with distinct values of {varname}{p_end}
{synopt:{opt base(num)}}Specifies that the entropy index of diversity should be 
calculated using logarithms of base {it: num}, where {it: num} is an integer greater than 1. 
The default is to use base M, where M is the number of groups specified in 
{varlist}.{p_end}

{syntab:Output Options}

{synopt:{opt fil:e(filename)}}Specifies that the values of the indices requested
are to be written to a separate file with the name {it: filename}.
{p_end}
{synopt:{opt gen:erate(genlist)}}Specifies variable names for segregation 
indices{p_end}
{synopt:{opt nodis:play}}Supppresses output display{p_end}
{synopt:{opt replace}}Specifies that {opt file} should 
overwrite existing files{p_end}

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
{cmd:seg} calculates multiple-group diversity and segregation indices for the 
variables in {varlist}. The {opt by} and {opt unit} options allow specification 
of the organization level at which segregation is to be calculated. The 
{opt generate}, and {opt file} options allow index values for each 
value of the by-group variable(s) to be output to either the current file or new 
files. The bias-correction options perform finite sample bias adjustments to the 
computed indices. {opt adjust} must be specified to bias-correct the estimates.

{pstd}
{it:genlist} must have the form:
({it:index} {it:newvar} [{it:index} {it:newvar} [{it:index} {it:newvar} [...]]])

{pmore}
where {it:index} indicates the index to be output, and {it:newvar} is the name 
of the variable to be created. {it:index} must be one of the following:

{pmore}{it:t}      for total by-group counts{p_end}
{pmore}{it:u}      for the number of units within each by-group{p_end}
{pmore}{it:i}	    for Normalized Simpson Interaction Diversity Index{p_end}
{pmore}{it:e}	    for Entropy Diversity Index{p_end}
{pmore}{it:d}	    for Dissimilarity Segregation Index{p_end}
{pmore}{it:g}	    for Gini Segregation Index{p_end}
{pmore}{it:h}      for Information Theory Segregation Index{p_end}
{pmore}{it:c}	    for Sqsuared Coefficient of Variation Segregation Index{p_end}
{pmore}{it:p}	    for (n-group) Normalized Exposure Segregation Index{p_end}
{pmore}{it:r}      for Relative Diversity Segregation Index{p_end}
{pmore}{it:o}      for Hutchens' Square Root Segregation Index{p_end}
{pmore}{it:x}	    for Exposure Index{p_end}
{pmore}{it:s}	    for Isolation Index{p_end}
{pmore}{it:n}	    for 2-group Normalization Exposure Index{p_end}

{pmore}
If the {opt adjust} option is specified, the {it:h} and/or {it:r} indices will be returned 
with the corresponding bias-adjusted versions with the variable name {it:newvar}_adj.

{pstd}
If {it:genlist} is not specified, {cmd:seg} will assign the requested index the name
INDEXseg (e.g. {opt Hseg} if index {opt h} is specified). In this case, {cmd:seg}
will also return {opt nunits}, the number of units in a given by-group, and 
{opt Total}, the total count in all units within a given by-group.

{marker options}{...}
{title:Options}

{dlgtab: Required Index Specifications}

{phang}
{opt d} specifies that the Dissimilarity Index is to be calculated. The Simpson 
Diversity Indices are also calculated if this option is specified.

{phang}
{opt g} specifies that the Gini Index is to be calculated. The Simpson Diversity
Indices are also calculated if this option is specified.

{phang}
{opt h} specifies that the Theil Information Theory Index is to be calculated.
The Theil Entropy Diversity Index is also calculated if this option is 
specified.

{phang}
{opt c} specifies that the Squared Coefficient of Variation Index is to be 
calculated. The Simpson Diversity Indices are also calculated if this option is 
specified.

{phang}
{opt r} specifies that the Relative Diversity Index is to be calculated. The 
Simpson Diversity Indices are also calculated if this option is specified.

{phang}
{opt p} specifies that the (multi-group) Normalized Exposure Index is to be 
calculated. The Simpson Diversity Indices are also calculated if this option is 
specified.

{phang}
{opt x} specifies that the (two-group) Exposure Index is to be calculated. The 
calculated exposure is the exposure of the group specified in {it: var1} to the group 
specified in {it: var2}. Other groups listed in {varlist} are included in the 
calculation of the exposure index.

{phang}
{opt s} specifies that the Isolation Index is to be calculated for the group 
specified in {it: var1}. Other groups listed in {varlist} are included in the 
calculation of the isolation index.

{phang}
{opt n} specifies that the (two-group) Normalized Exposure Index is to be 
calculated. The calculated exposure is the exposure of the group specified in 
{it: var1} to the group specified in {it: var2}. Other groups listed in {varlist} are 
included inthe calculation of the normalized exposure index.

{dlgtab:Optional Index Specifications}

{phang}
{opt by(varlist)} specifies that the indices are to be calculated within the 
{opt by} {varlist}. If the {opt by} option is not sepcified, then segregation is
calculated over the entire set of observations.

{phang}
{opt unit(varname)} specifies that segregation is to be calculated between 
observations with distinct values of {it:varname}. Observations are 
grouped on the unit variable, and segregation is calculated between these units. 
This is used, for example, if each observation is a census block group 
(a subunit of a census tract) and one 
wants to calculate segregation between tracts. If the {opt unit} variable option 
is not specified, then each observation is treated as a separate unit. Note: The 
{opt unit} option cannot be used with the {opt adjust} option. Instead, the data 
should be collapsed to the unit-level (and sampling rates or sample sizes should 
be computed for each unit) before running {cmd:seg}.

{phang}
{opt base(num)} specifies that the entropy index of diversity should be 
calculated using logarithms of base {it: num}, where {it: num} is an integer greater than 1. 
The default is to use base M, where M is the number of groups specified in {varlist}.

{dlgtab:Output Options}

{phang}
{opt nodisplay} specifies that output should be surpressed. If two or more 
variables are listed in the {opt by} option, {opt nodisplay} is the default.

{phang}
{opt generate(genlist)} specifies that the values of the indices indicated in {it: genlist} 
are to be written to the current file, with variable names as indicated in {it: genlist}. 
If the {opt file} option is also specified, {opt generate} will cause 
the variables listed in {it: genlist} to be written to the new file(s) rather than to 
the current file.

{phang}
{opt file(filename)} specifies that the values of the indices requested are to 
be written to a separate file. [Note: {cmd: seg} reserves several variable names as 
defaults if none are specified in {opt generate}: {opt total}, {opt nunits}, 
{opt Dseg}, {opt Gseg}, {opt Hseg}, {opt Cseg}, {opt Rseg}, {opt Pseg}, {opt Xseg}, 
{opt Sseg}, {opt Nseg}, {opt Idiv}, and {opt Ediv}. This can cause a conflict if a 
variable specified in the by option uses one of these reserved names. Conflicts 
can be avoided in this case by using the {opt generate} option to specify new 
names for the variables written to the new file.]

{phang}
{opt replace}, when specified with the {opt file} or {opt tfile} option, forces {cmd: seg} to 
overwrite the file(s) specified in the {opt file} and {opt tfile} options, if they already 
exist. If {opt replace} is not specified and the file(s) already exist, they will not be 
overwritten.

{dlgtab:Bias-Correction Options}

{phang}
{opt adjust} specifies that finite sampling bias adjustments should be used. This 
option is only available for indices {opt h} and {opt r}. If this option is specified 
with other indices, {cmd:seg} will return an error. See Reardon, Bischoff, Owens, and 
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
The {varlist} variables should be non-negative counts of mutually exclusive 
categories (e.g. counts by race, sex, etc.). The {opt by} option is used to 
specify the level of organization within which segregation is to be calculated, 
and the {opt unit} option is used to specify the level of organization between which 
segregation is to be calculated.

{pstd}
Observations with missing values on any of the variables in {varlist} are dropped, 
as are observation with missing values on {opt by}, {opt unit}, {opt rate}, {opt nsize}, or
{opt tsize} if these are specified.

{pstd}
To adjust the segregation measures {opt h} and/or {opt r} for finite sampling bias, 
specify {opt adjust}. The {opt adjust} option requires {cmd: seg} to be passed or 
to calculate both the unit total (the sum of {varlist} by unit) and the unit-level 
sampling rate. In most cases, this means passing {cmd: seg}:

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
{cmd:seg} calculates the indices as follows. For each unit, calculate the total 
count within the unit as

{phang2}t=SUM({varlist})

{phang}and the proportion of the unit within category {opt n} as

{phang2}q{opt n} = var{opt n}/t.

{phang}The Simpson Interaction Diversity Index of each unit is then

{phang2}I{opt u} = SUM[q{opt n} * (1 - q{opt n})]

{phang}The Normalized Interaction Index of each unit is then

{phang2}NI{opt u} = [n/(n-1)] * I{opt u}

{phang}The Entropy Diversity Index of each unit is then

{phang2}E{opt u} = SUM[q{opt n} * LOG(1/q{opt n})].

{phang}The corresponding Diversity indices of each by-group (I{opt g}, NI{opt g}, & E{opt g}) are calculated similarly

{phang2}I{opt g} = SUM[Q{opt n} * (1 - Q{opt n})]

{phang2}NI{opt g} = [n/(n-1)] * I{opt g}

{phang2}E{opt g} = SUM[Q{opt n} * LOG(1/Q{opt n})]

{phang}where T and Q{opt n} are calculated over each by-group rather than each unit.

{phang}The multiple-group segregation indices of each by-group {it: g} are defined then as follows:

{phang2}D{opt g} = SUMn[SUMu[t * |Q{opt n} - q{opt n}|]] / (2 * T * I{opt g})

{phang2}G{opt g} = SUMn[SUMui[SUMuj[t{opt i} * t{opt j} * |q{opt ni} - q{opt nj}|]]] / (2 * T * T * I{opt g})

{phang2}H{opt g} = 1 - [SUM((t/T)*E{opt u}) / E{opt g}].

{phang2}C{opt g} = SUMn[SUMu[t * (Q{opt n} - q{opt n}) * (Q{opt n} - q{opt n})] / [T * Q{opt n} * (M - 1)]].

{phang2}R{opt g} = SUMn[SUMu[t * (Q{opt n} - q{opt n}) * (Q{opt n} - q{opt n})] / (T * I{opt g})].

{phang2}P{opt g} = SUMn[SUMu[t * (Q{opt n} - q{opt n}) * (Q{opt n} - q{opt n})] / [T * (1 - Q{opt n})]].

{phang2}X{opt g} = SUMu((t * q{opt 1} * q{opt 2}) / (T * Q{opt 1})].

{phang2}S{opt g} = SUMu((t * q{opt 1} * q{opt 1}) / (T * Q{opt 1})].

{phang2}N{opt g} = 1 - X{opt g}/Q{opt 2}.

{pstd}where M is the number of groups specified in {varlist}; where SUMn 
indicates a sum over all n groups in {varlist}; and where SUMu (and SUMui or 
SUMuj) indicates as sum over all units.

{pstd}Seven of the segregation indices (D G H C R P N) have a minimum of 0 
(no segregation) and a maximum of 1 (complete segregation). X has a minimum of 
0 (no exposure) and an upper bound of 1 (complete exposure). S has a lower 
bound of 0 (no isolation) and a maximum of 1 (complete isolation).

{pstd}
The bias-adjusted {opt H} and {opt R} are calculated as follows:

{phang2}adjusted H{opt g} = estimated H{opt g} - (B / (2*E{opt g}))

{phang2}adjusted R{opt g} = (estimated R{opt g} - B) / (1 - B))

{pstd}where B is defined as

{phang2}B = (z / (t-bar - 1)) * ((1-r) / r)

{pstd}where t-bar is defined as the unit-mean of the total of {varlist} within a 
given by-group, r is the harmonic mean of the unit sampling rates, and z is 
defined as 

{phang2}z = 1 + (1/t-bar)*((t-bar-1) / [(t-1)-harm] - 1)

{pstd}where (t-1)-harm is the harmonic mean of (t-1)

{marker examples}{...}
{title:Examples}

{pstd}
Suppose the data contain racial enrollment counts by school, with variables 
{opt sch}, {opt dst}, and {opt msa} identifying the school, district, and 
metropolitan area of each school, and with {opt white}, {opt black}, {opt hisp}, 
{opt asian}, and {opt natam} variables containing within-school enrollment 
counts for 5 racial/ethnic groups. Then

{phang2}{cmd:. seg white black, d}{p_end}

{pmore2}calculates the between-school dissimilarity index between White and 
Black students among all schools in the data set.

{phang2}{cmd:. seg white black hisp asian, g by(msa) u(dst) gen(g gwbha i iwbha)}

{pmore2}calculates for each metropolitan area the between-district gini index 
among White, Black, Hispanic, and Asian students, and outputs the gini index and 
diversity of each metropolitan area to the variables {opt gwbha} and {opt iwbha}.

{phang2}{cmd:. seg white black, d g v h by(msa dst) file(c:\outfile.dta) replace}

{pmore2}calculates and writes to file "c:\outfile.dta" the dissimilarity, gini, 
variance ratio, and entropy indices (and the relevant diversity indices) between 
White and Black students within each district in each metropolitan area. 
Because two variables are listed in the BY option, the results will not be 
displayed to the screen.

{phang2}{cmd:. seg white black hisp asian natam, x s n}

{pmore2}calculates the white-black exposure index, the white isolation index, 
and the normalized white-black exposure index among all schools in the data. 
Note that this will give different results than

{phang2}{cmd:. seg white black, x s n}

{pmore2}which will calculate the exposure and isolation indices ignoring all 
students other than black and white students.

{pstd}
Suppose the data are based on samples rather than population counts, and suppose 
that the variable {opt srate} contains the sampling rate of students in a given 
school. Then

{phang2}{cmd:. seg white black, h r by(dst) gen(h h r r) file(c:\outfile.dta) adjust sampcounts rate(srate)}{p_end}

{pmore2}calculates for each district the between-school bias-adjusted Information Theory 
Segregation Index ({opt h}) and the bias-adjusted Relative Diversity Segregation Index 
({opt r}) between white and black students, and outputs the results as variables {opt h_adj} 
and {opt r_adj} into the file "c:\outfile.dta". Unadjusted versions of {opt h} and {opt r} 
are also returned.

{marker author}{...}
{title:Authors}

{pstd}
sean f. reardon{p_end}
{phang}sean.reardon@stanford.edu{p_end}

{phang}Joseph B. Townsend{p_end}
{phang}townsend.joseph@gmail.com

{marker references}{...}
{title:References}

{phang}James, David R. and Karl E. Taeuber. 1985. "Measures of Segregation." Sociological Methodology, 14:1-32.

{phang}Massey, Douglas S. and Nancy A. Denton. 1988. "The dimensions of racial segregation." Social Forces. 67:281-315.

{phang}Reardon, Sean F., and Glenn Firebaugh. 2002. "Measures of multigroup segregation." Sociological Methodology 32: 33-67.

{phang}Reardon, S.F., Bischoff, K., Owens, A., & Townsend, J.B. 2018.
{browse "https://tinyurl.com/yaa8rjhs":"Has Income Segregation Really Increased? Bias and Bias Correction in Sample-Based Segregation Estimates."}

{phang}White, Michael J. 1986. "Segregation and diversity measures in population distribution." Population Index 52:198-221.

{phang}Zoloth, Barbara S. 1976. "Alternative measures of school segregation." Land Economics 52:278-298.


