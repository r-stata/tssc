{smcl}
{cmd:help ptvtools}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :ptvtools {hline 2}}Various tools for PTV analysis{p_end}
{p2colreset}{...}

{title:Introduction}

{pstd}
The {cmd:ptvtools} package is a small collection of tools for the analysis of PTVs.
In electoral survey research, this acronym refers to Propensities To Vote, batteries
of items concerning the self-reported probability that the respondent will {it:ever} 
vote for a specific party, and intended as indicators of what Downs (1957) referred
to as "electoral utilities" (see van der Eijk and Franklin, Choosing Europe, 
University of Michigan Press 1996; van der Eijk et al., Electoral Studies 2006;
van der Eijk and Franklin, Elections and Voters, Palgrave Macmillan 2009).{p_end}

{pstd}
PTV analysis makes some specific demands both on the data and on the methods of analysis.{break}

{pstd}
Firstly, data {it:stacking} is usually involved, implying that - in Stata terminology - data
are better analyzed when in {it:long} rather than in {it:wide} form (see {help reshape:reshape}).
However, the tools facilitate reshaping of a dataset with multiple contexts, (eg. countries)
each with possibly different numbers of items (eg. parties) in the battery(ies) to be stacked 
(different numbers of items having missing data for all cases in the context). After 
stacking, each respondent is represented by multiple rows in the data matrix, one for each 
of the items that was not entirely missing.{break}

{pstd}
Secondly, the dependent variable is usually not the propensity to vote for a particular party, 
but for a {it:generic} party (yielding comparability across contexts if these involve different 
party systems, as is common). This also affects {it:independent} variables, which have to be specially
treated - reformulated it terms of distances (proximities) or in terms of some other type of affinity, 
for instance so-called {it:y-hats} - before they can be used in a stacked analysis. In this, ptv 
analysis resembles analysis of discrete choice models for which it serves as a substitute, 
dealing with directly-measured preferences (utilities) rather than deriving these from the analysis 
of choices made.


{title:Description}

{pstd}
The {cmd:ptvtools} package includes the following commands:

{p2colset 5 20 22 2}{...}
{p2col :{bf:{help gendist:gendist}}}(Context-wise) generation of distances for a battery of spatial 
items, after optionally plugging missing data on the spatial items{p_end}
{p2col :{bf:{help iimpute:iimpute}}}(Context-wise) incremental simple or multiple imputation of a 
set of variables{p_end}
{p2col :{bf:{help genstacks:genstacks}}}(Context-wise) reshaping of a dataset for PTV analysis{p_end}
{p2col :{bf:{help genyhats:genyhats}}}(Context-wise) generation of {it:y-hat} affinity measures 
linking indeps to ptvs{p_end}
{p2col :{bf:{help gendummies:gendummies}}}generation of a set of dummy variables, with specific 
options{p_end}{break}

{pstd}
These tools largely duplicate existing commands in Stata but operate on data with multiple contexts 
(eg. countries) each of which requires separate treatment. Moreover, all of the commands in 
{cmd:ptvtools} have additional features not readily duplicated with existing Stata commands even 
for data that relate to a single context. If the {cmd:contextvars} option is not specified, each of 
the individual tools treats the data as belonging to a single context.

{pstd}
The commands take a variety of options, as documented in individual help files, some with quite 
cumbersome names. However, ALL options can be abbreviated to their first three characters and many 
can be omitted (as documented).

{pstd}
The commands also save a variety of indicator variables (as documented). Most of these start with an 
underscore character and can be deleted by "drop _*" if you don't want them to clutter your dataset. 
Three variables created by the command {help genstacks:genstacks} are needed by other tools and do not 
start with the underscore character. These are  genstacks_stack, genstacks_item and genstacks_nstacks.


{title:Workflow}

{pstd}
The {cmd:genstacks} command always operates on an unstacked dataset, reshaping it into a stacked format. 
Other commands may operate either before or after stacking. No means is provided for unstacking a 
previously stacked dataset.{break}

{pstd}The commands, {cmd:gendist}, {cmd:iimpute} and {cmd:genyhats} by default assume the data are stacked 
and treat each stack as a separate context to be taken into account along with any higher-level contexts. 
These commands can, however, be used on unstacked data or they can be forced to ignore the stacked structure 
of the data by specifying the {cmd:nostack} option. This option has no effect on {cmd:gendummies} or on 
a command that is being used on unstacked data (since unstacked data have only one stack per case). With 
stacked data the {cmd:nostack} option has the effect of making the command ignore the separate contexts 
represented by each stack. This might be considered desirable if prior analysis has established that 
there is no stack-specific heterogeneity relevant to the estimation model for which these operations 
are being conducted, or in order to impute a variable that is completely missing in one stack (for example 
a question that was not asked for a particular choice option).{break} 

{pstd}For logical reasons some restrictions apply to the order in which commands can be issued. 
In particular:{p_end} 
{pmore}(1) {cmd:iimpute} (when used for its primary purpose of imputing missing values for a battery 
of items) requires that data are not stacked, since members of that battery (eg. PTVs) are used for the 
imputation of other members of the same battery; 

{pmore}(2) {cmd:gendist} can be useful for removing missing data from items that can then be named in 
the {cmd:addvars} option to help {cmd:iimpute} missing data on other variables;

{pmore}(3) if {cmd:genyhats} is used before stacking, it will have to be used once 
for each of the individual depvars that will, after stacking, become a single (generic) depvar; 

{pmore}(4) if {cmd:gendist} is employed after stacking, the items to which distances are computed 
have themselves to have been reshaped into long format by stacking them; and finally

{pmore}
(5) after stacking and the generation of y-hat affinity variables, the number of indeps required for 
a final (set of) {cmd:iimpute} command(s) will generally be greatly reduced, making it easier to adhere 
to Stata's 30 variable limit on indeps used for imputation.

{pstd}
Consequently, a typical workflow would involve {cmd:iimpute} to fill out the battery of PTVs by imputing
any missing data, followed by {cmd:genstacks} to stack the data. This would probably be followed by 
{cmd:genyhats}, used to transform indeps (those that will not be transformed into distance 
measures) into y-hat affinity measures linking these indeps to the stacked depvar. The {cmd:gendist} 
command would then be used to plug missing values on item location variables and generate distances to 
be used in a final (set of) {cmd:iimpute} command(s) that will eliminate remaining missing data. This 
entire workflow sequence would need to be repeated as many times as datasets are required for multiple 
imputation.{break} 

{pstd}
Considerable flexibility is available, however, to transform a dataset in any sequence thought 
appropriate, since any of the other commands can be employed either before or after {cmd:genstacks}. 
Moreover, the researcher can use the {cmd:nostack} option to force the production of y-hats that 
"average out" contextual differences by regarding all stacks (and perhaps also all higher-level 
contexts) as a single context. This might be thought desirable after having established that there 
were no significant differences between these contexts in terms of the behavior of variables 
to be included in an estimation model.


{title:Authors}

{pstd}
Lorenzo De Sio - European University Institute;{break}
Mark Franklin - European University Institute;{break}
includes previous code and other contributions by Elias Dinas


{title:Referencing}

{pstd}
If you use {bf:ptvtools} in published work, please use the following citation:{break}
De Sio, L. and Franklin, M. (2011), PTVTOOLS: A Stata package for PTV analysis (version 0.9), 
Statistical Software Components, Boston College Department of Economics.
