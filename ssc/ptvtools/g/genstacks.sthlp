{smcl}
{cmd:help genstacks}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :genstacks {hline 2}}Stacks a dataset for PTV analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt genstacks} {namelist}
   [{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth con:textvars(varlist)}}the variables identifying different electoral contexts 
(leave unspecified for conventional datasets with only one context){p_end}
{synopt :{opt rep:lace}}drops original variable sets after reshaping them{p_end}
{synopt :{opth sta:ckid(name)}}provides a variable name for the generated variable 
identifying each specific stack in the reshaped dataset (default is genstacks_stack){p_end}
{synopt :{opt noc:heck}}relaxes the requirement that all batteries to be reshaped contain 
the same number of items. 
identifying each specific stack in the reshaped dataset (default is genstacks_stack){p_end}
{synopt :{opth ite:mname(name)}}provides a variable name for the generated variable 
identifying the original item number before reshaping (default is genstacks_item){p_end}
{synopt :{opth tot:stackname(name)}}provides a variable name for the generated variable 
containing the total number of stacks found for each context(default is 
genstacks_totstacks){p_end}

{synoptline}

{title:Description}

{pstd}
{cmd:genstacks} reshapes the current dataset to a stacked format for PTV analysis.{break}

{pstd}Sets of variables (aka batteries), each set identified by one of the stubs specified in 
{it:namelist}, will be reshaped into what Stata calls a 'long' format (see {help reshape:reshape}). 
Suffixes identifying the individual variables in each set are retained as item identifiers 
in the reshaped data. By default, suffixes must be identical for each set of variables - typically 
these are numbers running from 1 to the number of variables in the set. This requirement can be 
relaxed by specifying the {cmd:nockeck} option, in which case variables omitted from a battery will 
be stacked as though a variable had been supplied whose values were all missing. The first battery 
must, however, contain all variable suffixes included in any subsequent battery - if necessary by 
including variables with all missing data codes - and each suffix employed in subsequent batteries 
must match one of the suffixes for variables in the first battery. {break}

{pstd}All other variables (those not identified by stubs in {it:namelist}) are copied onto all stacks 
(it is advisable to drop unwanted variables before stacking as the dataset expands K-fold 
where K is the number of variables in each set). If the {cmd:contextvars} option is specified, 
the procedure is applied separately to each electoral context identified by {cmd:contextvars}. 
Typically these will be different countries, or different countries within different years.{break}

{pstd}{cmd:genstacks} constitutes something of a watershed within the {cmd:ptvtools} package, 
since it reshapes the data from having a single stack per case to having multiple stacks 
per case. No provision is made for unstacking a dataset once it has been stacked, but other 
ptvtools commands can be used with either stacked or unstacked data.{break}

{pstd}See {help ptvtools:ptvtools} for a description of the workflow inherent in these commands.

{pstd}
SPECIAL NOTE ON MULTIPLE BATTERIES. {cmd:genstacks} identifies the items in a battery with corresponding 
dependent variables by means of the numeric suffix appended to the stubname for each battery. It is 
thus essential that these numeric suffixes relate to the same objects for each battery. By default 
{cmd:genstacks} also requires all batteries to contain the same number of items. However it cannot  
check that the numeric suffixes are correct. It is important to be aware that, in datasets 
derived from election studies, it is quite common for some questions (eg about party locations on certain 
issues) to be asked only for a subset of the objects being investigated (eg parties). Moreover, those 
objects and questions relating to those objects may not always be listed in the same order. So counting 
on the relative position of each item to retain the same meanings across batteries may lead to grievous 
errors. Moreover, if the user employs {cmd:tab1} or {cmd:gendummies} to generate a battery of dummy 
variables corresponding to questions that 
did not list all parties or listed them in a different order then not only may the number of items in 
the resulting battery be different from those in another battery but also the numeric suffixes generated 
by {cmd:tab1} or {cmd:gendummies} may refer to different objects in the case of items from the different 
batteries. Part of this problem is alleviated by the use of {bf:{help gendummies:gendummies}} which 
generates dummy variable suffixes from the values actually found in the data, rather then numbering these 
sequentially as does {cmd:tab1}. But those values do need to be correct, which only the user can check. 
See also the special note on multiple batteries in the help text for {bf:{help gendist:gendist}}.


{title:Options}

{phang}
{opt contextvars(varlist)} if specified, the variable(s) whose (combinations of) values 
identify different electoral contexts (eg. countries, years). The default is to assume all 
cases fall within a single context.

{phang}
{opt replace} if specified, all original sets of variables identified by the stubs specified 
in {it:namelist} will be dropped.

{phang}
{opt stackid(name)} if specified, provides a variable name for the generated variable 
identifying each specific stack (default is genstacks_stack which is the default variable 
name expected by {cmd:genyhats}, {cmd:iimpute} or {cmd:gendist} if invoked after stacking.{p_end}

{phang}
{opt nocheck} if specified, relaxes the requirement that batteries of items to be reshaped all 
contain the same number of items (it is still required that all the item numbers of items in 
any battery be included in the battery whose stubname appears first in {it:namelist}).

{phang}
{opt itemname(name)} if specified, provides a variable name for the generated variable 
identifying the original item (default is genstacks_item). The difference between the 
{it:itemname} and {it:stackid} variables emerges when non-consecutive items are found 
in the original set of variables, e.g. if parties in a battery are party1, party3, party7. 
In this case, stacks will be numbered 1,2,3, while items will be numbered 1,3,7, 
to preserve the connection with the unstacked data.{p_end}

{phang}
{opt totstackname(name)} if specified, a variable name for the generated variable 
containing the total number of stacks in each context (default is genstacks_totstacks). 
Evidently this cannot be more than the number of ptv variables in {it:namelist} but may
be less for specific contexts - for example if the contexts are countries that have 
different party systems.{p_end}


{title:Examples:}

{pstd}
The following command stacks a dataset where observations are nested in contexts defined 
by {it:cid}; variable sets {it:i_ptv*} and {it:i_lrd*} will be stacked into new variables 
{it:i_ptv} and {it:i_lrd}, with the original variables dropped. All other variables 
in the dataset are duplicated across the k records for each case created by reshaping 
the k variables in each set.{p_end}{break}
{phang2}
{cmd:. genstacks i_ptv i_lrp, contextvars(cid) replace}{p_end}

{pstd}
NOTE that {it:i_ptv} and {it:i_lrp} in the above command are stubnames, not variable lists. 
The use of {it:i_ptv*} or {it:i_lrd1-i_lrd10} in this command would cause an error. The 
{it:i_} prefix used in these stubnames suggests the likelihood that this command follows 
the use if {bf:{help iimpute:iimpute}} to impute missing data for the variables indicated 
by each stubname. These stubs become the names of the reshaped variables.{p_end}


{title:Generated variables}

{pstd}
{cmd:genstacks} saves the following variables and variable sets:

{synoptset 21 tabbed}{...}
{synopt:name [name]...} the variables named by the stubs specified in {it:namelist} 
(originals left unchanged unless {cmd:replace} is optioned).{p_end}
{synopt:genstacks_stack} (or other name defined in option {it:stackname}) 
a variable identifying the k different rows (stacks) generated by reshaping 
the k different items in each set named in {it:namelist} (ID numbers are consecutive).{p_end}
{synopt:genstacks_item} (or other name defined in option {it:stackname}) 
a variable identifying the k different items before stacking 
(need not be consecutive but must be the same for each set of items).{p_end}
{synopt:genstacks_totstacks} (or other name defined in option {it:totstackname}) 
a variable giving the number of rows (stacks) for each unstacked case (respondent) 
in each context after reshaping.


