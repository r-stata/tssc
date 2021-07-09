{smcl}
{cmd:help gendist}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :gendist {hline 2}}Generates distances for a battery of spatial placements{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt gendist} {varlist} 
   [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth res:pondent(varname)}}(required) the variable containing the respondent's self-placement 
in the space (e.g. the issue space) in which items (e.g. the political parties) have been placed.{p_end}
{synopt :{opth con:textvars(varlist)}}a set of variables identifying different electoral contexts
(by default all cases are treated as part of the same context).{p_end}
{synopt :{opth sta:ckid(varname)}}a variable identifying different "stacks", for which distances will be 
separately generated if {cmd:gendist} is issued after stacking.{p_end}
{synopt :{opt nos:tack}}override the default behavior that treats each stack as a separate context.{p_end}
{synopt :{opt mis:sing(mean|same|diff)}}plugs missing values on object placements{p_end}
{synopt :{opt rou:nd}}rounds plugged values to the nearest integer{p_end}
{synopt :{opt ppr:efix(name)}}prefix for generating mean-plugged placement variables (default is "p_"){p_end}
{synopt :{opt mpr:efix(name)}}prefix for generating variables indicating original missingness of either 
component (item location or respondent location) of a distance measure (default is "m_"){p_end}
{synopt :{opt dpr:efix(name)}}prefix for generating distance variables (default is "d_"){p_end}
{synopt :{opt mco:untname(name)}}name of a generated variable reporting original count of missing items 
for each case (default is "_gendist_mc"){p_end}
{synopt :{opt mpl:uggedcountname(name)}}name of a generated variable reporting the count
of missing items for each case after mean-plugging (default is "_gendist_mpc"){p_end}
{synopt :{opt rep:lace}}drops all party location variables and mean-plugged placement variables 
after the generation of distances.


{synoptline}

{title:Description}

{pstd}
{cmd:gendist} generates Euclidean distances for a battery of spatial items, where variables in {bf:{it:varlist}}
contain the placement of different objects on the spatial scale and the variable specified in {bf:respondent} 
contains the self-placement of the respondent on the same spatial scale. Distances between the respondent 
and each spatial item in the battery are placed in corresponding members of a new battery of items. Only 
one battery of items can be processed on a single invocation of {cmd:gendist}.

{pstd}
The items in the new battery are given names derived from appending the names in {it:varlist} to the
prefix established in option {bf:dprefix} (default {it:d_}).

{pstd}
If optioned by {bf:missing}, {cmd:gendist} also generates a new battery of items with the prefix established 
in option {bf:pprefix} (default {it:p_}) which is identical to the original battery but with missing values 
plugged by mean values. These mean values can be mean placements (e.g. of political parties on the left-right 
scale) by all respondents, mean placements by respondents who themselves have the same position as the 
placement, or mean placements by respondents themselves having a different position, depending on what is 
specified in option {bf:missing}. 

{pstd}
Conventionally in published work the plugged value has been based on all placements. However, it might be 
thought that respondents having the same position would be more knowledgeable about the object concerned. 
Alternatively it might be thought that respondents having the same position might include individuals who  
were simply assuming that 'their' party had the same position as they did. Each of the {bf:missing} 
options is defensible theoretically so the user should think carefully about which to employ. The default 
is not to plug the missing data, so that distances are generated only for valid cases.

{pstd}
The {cmd:gendist} command can be issued before or after stacking. If issued after stacking, by default it 
treats each stack as a separate context to take into account along with any higher-level contexts. However, 
the {cmd:nostack} option can be employed to force {cmd:gendist} to ignore the stack-specific contexts. 
In addition, this command can be employed with or without distinguishing between higher-level contexts, if 
any, (with or without the {cmd:contextvars} option) depending on what makes methodological sense.{break}
NOTE that it is unlikely to make methodological sense to employ {cmd:gendist} after stacking 
along with both the {cmd:nostack} and the {cmd:mean} options, since this would result in missing 
values being plugged with a mean that combined the values of what were (before stacking) several different 
variables.

{pstd}
SPECIAL NOTE ON MULTIPLE BATTERIES. Gendist is only aware of the battery it is currently processing. Thus 
it cannot diagnose an error if that battery is of a different length than other batteries of items 
pertaining to the objects (eg political parties) being asked about. Yet stacked datasets (the type of 
datasets for which distances are wanted) absolutely require all batteries pertaining to the objects being 
stacked to contain the same number of items and have these items in the correct sequential order 
({cmd:gendist} will produce stacks in the correct order, padded as needed with stacks that contain only 
missing values, if the numeric suffixes to all batteries of items are correct). In datasets 
derived from election studies is is quite common for some questions (eg about party locations on certain 
issues) to be asked only for a subset of the objects being investigated (eg parties). Moreover, questions 
relating to those objects may not always list them in the same order. If the user employs 
{cmd:tab1} or {cmd:gendummies} to generate a battery of dummy variables corresponding to questions that 
did not list all parties or listed them in a different order then not only may the number of items in 
the resulting battery be different from those in another battery but also the numeric suffixes generated 
by {cmd:tab1} or {cmd:gendummies} may refer to different objects in the case of items from the different 
batteries. One part of this problem is alleviated by the use of {bf:{help gendummies:gendummies}} which 
generates dummy variable suffixes from the values actually found in the data, rather then numbering these 
sequentially as does {cmd:tab1}. But those values do need to be correct, which only the user can check. 
See also the special note on multiple batteries in the help text for {bf:{help genstacks:genstacks}}.

{title:Options}

{phang}
{opth respondent(varname)} (required) the variable containing the respondent's self-placement on the battery 
of items.

{phang}
{opth contextvars(varlist)} if present, variables whose combinations identify different electoral contexts
(by default all cases are assumed to belong to the same context).

{phang}
{opth stackid(varname)} if specified, a variable identifying different "stacks", for which distances will be 
separately generated in the absence of the {cmd:nostack} option. The default is to use the "genstacks_stack" 
variable if the {cmd:gendist} command is issued after stacking.

{phang}
{opt nostack} if present, overrides the default behavior of treating each stack as a separate context (has 
no effect if data are not stacked).

{phang}
{opth missing(mean|same|diff)} if present, determines treatment of missing values for object placement variables
(by default they remain missing).{break}
  If {bf:mean} is specified, missing values are replaced with the overall mean placement of that object,
calculated on the whole sample.{break}
  If {bf:same} is specified, missing values are replaced with the mean placement of the object,
calculated only among those respondents that placed themselves on the same position as the object.{break}
  If {bf:diff} is specified, missing values are replaced with the mean placement of the object,
calculated only among those respondents who placed themselves on a different position than the object  
(see discussion under 'Description' above regarding choice between these options).{break}
  When missing values are plugged, a set of p_{it:varlist} variables is generated, and the original
variables are left unchanged (the p_ prefix can be altered by use of the option {bf:pprefix}).{break}
NOTE: More sophisticated imputation facilites are offered by {bf:{help iimpute:iimpute}}.

{phang}
{opt round} if present, causes rounding of all plugged values to the closest integer.

{phang}
{opth dprefix(name)} if present, provides a prefix for generated distance variables (default is "d_").

{phang}
{opth pprefix(name)} if present, provides a prefix for generated mean-plugged placements (default is "p_").

{phang}
{opth mprefix(name)} if present, provides a prefix for generated variables indicating for each case whether, 
before mean-plugging of an item in the battery, either the item placement or the respondent placement was 
missing for that case (default is "m_").

{phang}
{opth mcountname(name)} if specified, name of a generated variable reporting original number of
missing items (default is "_gendist_mc"){p_end}

{phang}
{opth mpluggedcountname(name)} if specified, name of a generated variable reporting number of
missing items after mean-plugging, which could still be non-zero (even after all missing values 
on item positions have been plugged) if the respondent's own self-placement is missing (default is 
"_gendist_mpc"){p_end}

{phang}
{opt replace} if specified, drops all party position and mean-plugged 
placement variables after the generation of distance 
measures{p_end}

{title:Examples:}

{pstd}The following command generates distances on a left-right dimension, where party placements
are in variables lrp1-lrp10, and R's self-placement is in lrresp; missing placements are replaced
by simple mean-plugging, and then rounded to the nearest integer.{p_end}{break}
{phang2}{cmd:. gendist lrp1-lrp10, respondent(lrresp) missing(mean) round}{p_end}

{title:Generated variables}

{pstd}
{cmd:gendist} saves the following variables and variable sets:

{synoptset 16 tabbed}{...}
{synopt:p_{it:var1} p_{it:var2} ... (or other prefix set by option {bf:pprefix})} a set of mean-plugged 
placement variables with names p_var1, p_var2, etc., where the names var1, var2, etc. match the original 
variable names. Those variables are left unchanged.{p_end}
{synopt:m_{it:var1} m_{it:var2} ... (or other prefix set by option {bf:mprefix})} a set of variables with    
names m_var1, m_var2, etc., where the names var1, var2, etc. match the original variable names of the 
battery of items. These variables indicate the original missingness of var1, var2, etc., or of the 
corresponding placement of the respondent on the scale concerned.{p_end}
{synopt:d_{it:var1} d_{it:var2 ...} (or other prefix set by option {bf:dprefix})} a set of distances 
from the respondent to each (mean-plugged if optioned) placement variable. These distance variables are 
named d_var1, d_var2, etc., where the names var1, var2, etc. match the original variable names. Those 
variables are left unchanged.{p_end}
{synopt:_gendist_mc} a variable showing the original count of missing items for each case.{p_end}
{synopt:_gendist_mpc} a variable showing the count of remaining missing items for each case after 
mean-plugging.{p_end}

{phang}
NOTE that a subsequent invocation of {cmd:gendist} will replace {it:_gendist_mc} and {it:_gendist_mpc} with 
new counts of missing values for that invocation of {cmd:gendist}. So the user should save these 
values after issuing the previous command, if the values will be of later interest.
