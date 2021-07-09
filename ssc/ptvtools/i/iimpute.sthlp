{smcl}
{cmd:help iimpute}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :iimpute {hline 2}}Incremental simple (or multiple separate) imputation(s) of a set of variables{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt iimpute} {varlist}
   [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt add:itional(varlist)}}additional variables to include in the imputation model{p_end}
{synopt :{opt con:textvars(varlist)}}a set of variables identifying different electoral contexts 
(by default all cases are treated as part of the same context).{p_end}
{synopt :{opt sta:ckid(varname)}}a variable identifying different "stacks", for which values will be 
separately imputed if {cmd:iimpute} is issued after stacking.{p_end}
{synopt :{opt nos:tack}}override the default behavior that treats each stack as a separate context).{p_end}
{synopt :{opt min:ofrange(#)}}minimum value of the item range (used for recoding imputed values){p_end}
{synopt :{opt max:ofrange(#)}}maximum value of the item range (used for recoding imputed values){p_end}
{synopt :{opt ipr:efix(name)}}prefix for generated imputed variables (default is "i_"){p_end}
{synopt :{opt mpr:efix(name)}}prefix for generated variables indicating original missingness
of a variable (default is "m_"){p_end}
{synopt :{opt mco:untname(name)}}name of a generated variable reporting original number of missing items
(default is "_iimpute_mc"){p_end}
{synopt :{opt mim:putedcountname(name)}}name of a generated variable reporting number
of missing items after imputation (default is "_iimpute_mic"){p_end}
{synopt :{opt noi:nflate}}do not inflate the variance of imputed values to match the variance of original 
item values (default is to add random perturbations to these values, as required).{p_end}
{synopt :{opt rou:nd}}round each final value (after inflation, unless that was suppressed) to the nearest 
integer (default is to leave values unrounded).{p_end}
{synopt :{opt lim:itdiag(#)}}number of contexts for which to display full diagnostics (these can 
be quite voluminous) as imputation progresses (default is to display diagnostics for all contexts).{p_end}
{synopt :{opt rep:lace}}drops all original variables in {it:{bf:varlist}} after imputation.{p_end}


{synoptline}

{title:Description}

{pstd}
Though {cmd:iimpute} can impute missing values for a single variable (by calling Stata's {cmd:impute}, but 
with various options as described below) its primary function is to impute multiple variables 
according to an incremental procedure which - if required - is applied separately to electoral 
contexts identified by {it:contextvars}:

{pstd}1) Within each context, observations are split into groups, based on the number of missing items.
Observations for which only one variable has a missing value are processed first, and so on.

{pstd}2) Within each of the above groups, variables are ranked according to the number of missing 
observations. Variables with fewer missing observations are processed first, and so on.

{pstd}3) According to the order defined in step 2 (and within each group defined in step 1),
variables are imputed through simple imputation (using Stata's {cmd:impute} command).

{pmore}This implements the incremental nature of the procedure.
Since observations with fewer missing variables are imputed first, and (within each group) items
with fewer missing observations are imputed first,
later imputations (that have to impute more data) will use a more complete (partially imputed) dataset.

{pmore}The imputation model is based on all valid values of variables in {it:varlist},
plus all variables specified in the {cmd:additional()} option, which - understandably - 
would be crucial for imputation of those observations where all variables in {it:varlist} 
have missing values (but there might be theoretical reasons for basing imputation only 
on the values of other members of a battery).

{pmore}Please note that Stata's {bf:{help impute:impute}} command's {cmd:regsample()} option is used,
with a dummy variable generated from the actual value of {it:contextvar}.
This means that the sample used in the imputation model is the whole electoral 
context and not only the restricted group defined in step 1.

{pmore}NOTE that the number of independent variables upon which to base the imputation (the total of 
{it:{bf:varlist}} and {cmd:additional}) is limited to 30 because that is the limit for Stata's {cmd:impute} 
command. This limitation might lead the user to prefer to issue the {cmd:iimpute} command after 
{bf:{help genstacks:genstacks}} and {bf:{help genyhats:genyhats}} have reduced the number of indeps in the dataset.

{pstd}4) The variance of imputed item values is then inflated to match the variance of original item 
values, as recommended in the literature. If this is not wanted then the option {cmd:noinflate} should be 
employed.

{pstd}5) Imputed values are finally rounded, if {cmd:round} is optioned. Specifying the {cmd:minofrange()} 
and/or {cmd:maxofrange()} options further constrains the imputed values to a specific range.
While such options are not useful when imputing heterogeneous variables,they can be useful when a 
battery of analogous items is being imputed. This may suggest calling {cmd:iimpute} multiple times 
with different settings for these constraints. By default no constraint is applied.

{pstd}
The {cmd:iimpute} command can be issued before or after stacking. If issued after stacking, by default it 
treats each stack as a separate context to take into account along with any higher-level contexts. However, 
the {cmd:nostack} option can be employed to force {cmd:iimpute} to ignore the stack-specific contexts. In 
addition, the {cmd:iimpute} command can be employed with or without distinguishing between higher-level 
contexts, if any, (with or without the {cmd:contextvars} option) depending on what makes methodological 
sense.{break}

{title:Multiple Imputation}

{pstd}It is possible to impute multiple different datasets by using Stata's {bf:{help set seed:set_seed}} 
command to supply a different seed for the random number generator called by {cmd:iimpute} that 
inflates the variance of the imputed values returned by Stata's {cmd:impute}. Each dataset created 
in this way needs to be separately saved before changing the seed to impute a different dataset.
The resulting datasets can be imported into Stata's {bf:{help mi:mi}} or used to arrive at separate 
estimates that are then combined manually. NOTE that, if Stata's {cmd:seed} command is not employed, 
the separate datasets will still be different from each other (a different dataset would be 
created on each occasion because by default Stata employs a different random seed each time it inflates 
the variance of imputed values), but these differences will not be replicable.

{title:Options}

{phang}
{opth additional(varlist)} if specified, additional variables to include in the imputation model 
beyond those in {it:varlist}. These additional variables will not have any missing values imputed.

{phang}
{opth contextvars(varlist)} if specified, variables whose combinations identify
different electoral contexts (default is to treat all cases as part of the same context) 

{phang}
{opth stackid(varname)} if specified, a variable identifying different "stacks" for which values will be 
separately imputed in the absence of the {cmd:nostack} option. The default is to use the "genstacks_stack" 
variable if the {cmd:iimpute} command is issued after stacking.

{phang}
{opt nostack} if present, overrides the default behavior of treating each stack as a separate context (has no effect 
if the {cmd:iimpute} command is issued before stacking).

{phang}
{opth minofrange(name)} if specified, minimum value of the item range (used for constraining imputed 
values).{p_end}

{phang}
{opth maxofrange(name)} if specified, maximum value of the item range (used for constraining 
imputed values).{p_end}

{phang}
{opth iprefix(name)} if specified, prefix for generated imputed variables (default is "i_"){p_end}

{phang}
{opth mprefix(name)} if specified, prefix for generating variables that indicate original
missingness of a variable (default is "m_"){p_end}

{phang}
{opth mcountname(name)} if specified, name of a generated variable reporting number of
missing items before imputation (default is "_iimpute_mc"){p_end}

{phang}
{opth mimputedcountname(name)} if specified, name of a generated variable reporting number of
missing items after imputation, which could still be non-zero if all variables in the imputation 
model are missing for certain cases (default is "_iimpute_mic"){p_end}

{phang}
{opt noinflate} if specified, do not inflate the variance of imputed values to match the variance 
of original item values (default is to add random perturbations to these values, as required){p_end}

{phang}
{opt round} if specified, round each final value (after inflation, if any) to the closest integer 
(default is to leave values unrounded){p_end}

{phang}
{opth limitdiag(#)} if specified, limits the number of contexts for which full diagnostics are 
displayed to # (default is to display diagnostics for all contexts, which can be quite voluminous){p_end}

{phang}
{opt replace} if specified, drops all original variables for which imputed versions have been created 
(default is to keep original as well as new variables){p_end}


{title:Examples:}

{pstd}The following command imputes PTVs stored in variables whose names begin with {it:ptv}, 
(using standard Stata variable variable list conventions) in a dataset where observations are 
nested in contexts defined by {it:cid}. The imputation model is based only on the PTV variables. 
Imputed values will be rounded to the nearest integer between 0 and 10. The data 
are assumed to not be already stacked.{p_end}{break}

{phang2}{cmd:. iimpute ptv*, context(cid) min(0) max(10) round} {p_end}

{pstd}The following command imputes variables {it:ptv} and {it:lrresp} in a dataset that
had already been stacked and where observations are nested in contexts defined by {it:cid}. The 
imputation model is based on these variables plus a variety of y-hat affinity varlables and one
party-level variable (seats). Imputed values will not be constrained in any way. Such a command
might well be issued prior to a call on gendist to create euclidean distances between lrresp
(if that was left-right respondent location) and a battery of party location variables.{p_end}{break}

{phang2}{cmd:. iimpute ptv lrresp, additional(y_class-y_churchatt seats) contextvars(cid)} {p_end}


{title:Generated variables}

{pstd}
{cmd:iimpute} saves the following variables and variable sets:

{synoptset 20 tabbed}{...}
{synopt:i_{it:name1} i_{it:name2} ...} a set of variables with names matching the original variables
(which are left unchanged) for which missing data has been imputed.{p_end}
{synopt:m_{it:name1} m_{it:name2} ...} a set of dummy variables indicating whether each specific variable was 
imputed in a specific observation (i.e. was originally missing).{p_end}
{synopt:_iimpute_mc} a variable showing the original count of missing items for each case.{p_end}
{synopt:_iimpute_mic} a variable showing the count of items that are still missing for each case after imputation.
This might happen, eg., if the variables specified in {it:additional} also have mostly missing values on the 
same observations where all variables in {it:varlist} are missing.{p_end}

{phang}
NOTE that a subsequent invocation of {cmd:iimpute} will replace {it:_iimpute_mc} and {it:_iimpute_mic} with new 
counts of missing values for that invocation of {cmd:iimpute}. So the user should save these values after 
issuing the previous command, if they will be of later interest.

