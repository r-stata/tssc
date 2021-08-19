{smcl}
{* *! version 1.0.1, 2021-02-15}{...}
{title:Title}

{phang}
{bf:mcwr} {hline 2} Markov chain with rewards calculations

{marker syntax}{...}{* * * * * * * * * * * * * * * * * * *  SYNTAX * * * * * * * * * * * * * * * * * }
{title:Syntax}

{pstd}
Check that data set is set up correctly

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_check:{ul:ch}eck}} [{cmd:,} {opt ij} {opt sk:ipexit} {opt noex:it}]


{pstd}
Change from-state and target state index convention of variable names

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_switch:{ul:sw}itch}} [{cmd:,} {opt ij} {opt noi:sily}] 


{pstd}
Edit or check last (exit) row of data set

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_exit:exit}} {cmd:,} {opt age(ageval, [replace update])} [{opt rew:ards(rwval)}] 


{pstd}
Generate (additional) transition probability or rewards variables

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_genvars:{ul:ge}nvars}} [{cmd:,} {opt tim:ing(timespec, {add|replace})} {opt nop} {opt nor} {opt ord:er}]


{pstd}
Calculate state and overall expectancies

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_expectancies:{ul:exp}ectancies}} [{cmd:,} {opt ini:tprop(initspec)} {opt tim:ing(timespec, {add|replace})} {opt keep}] 


{pstd}
View matrices involved in the calculations in the data browser

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_matbrowse:{ul:matbr}owse}} {c -(}e|P|F|R#{c )-} [{cmd:,} {opt f:ormat(%fmt)} {opt norestore} {opt nosh:ow}]


{pstd}
List matrices involved in the calculations

{p 8 13 2}
{cmd:mcwr {helpb mcwr##mcwr_matlist:{ul:matli}st}} [{cmd:,} {it:matlistopts}]


{synoptset 33 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:    }
{synopt:subcmd {cmd:check}}{p_end}
{synopt:{opt ij}}data set is in {help mcwr##ijformat:ij-format}{p_end}
{synopt:{opt sk:ipexit}}do not check last row of data set{p_end}
{synopt:{opt noex:it}}exit row is missing in data set{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:switch}}{p_end}
{synopt:{opt ji}}data set will always be in {help mcwr##definitions:ji-format} after command conclusion{p_end}
{synopt:{opt noi:sily}}display verbose error messages{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:exit}}{p_end}
{synopt:{opt age(ageval, [replace update])}}age of exit row of data set{p_end}
{synopt:{opt rew:ards(rwval)}}rewards value to use for exit transitions{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:genvars}}{p_end}
{synopt:{opt tim:ing(timespec, {add|replace})}}specify rewards for from and target states{p_end}
{synopt:{opt ord:er}}order variables alphabetically according to varlist 'age p* r*'{p_end}
{synopt:{opt nop}}do not generate any p-variables{p_end}
{synopt:{opt nor}}do not generate any r-variables{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:expectancies}}{p_end}
{synopt:{opt ini:tprop(initspec)}}initial state fractions at baseline age{p_end}
{synopt:{opt tim:ing(timespec, {add|replace})}}see above{p_end}
{synopt:{opt keep}}keep newly generated p/r-variables necessary for the computation in the data set{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:matbrowse}}{p_end}
{synopt:{opt f:ormat(%fmt)}}format numbers accoding to {it:%fmt}{p_end}
{synopt:{opt norestore}}do not restore data set but keep matrix data in memory{p_end}
{synopt:{opt nosh:ow}}do not open browser with matrix data{p_end}
{synopt:}{p_end}
{synopt:subcmd {cmd:matlist}}{p_end}
{synopt:{it:matlistopts}}all options allowed by {help matlist}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}{* * * * * * * * * * * * * * * * * * *  DESCRIPTION * * * * * * * * * * * * * * * * * }
{title:Description and Overview}

{pstd}
{cmd:mcwr} implements Markov chain with rewards calculations. It accompanies the article{break}

{pmore}
Schneider / Myrskylä / van Raalte (2021):
Flexible Transition Timing in Discrete-Time Multistate Life Tables
Using Markov Chains with Rewards. MPIDR Working Paper, February 2021.
Available {browse "https://www.demogr.mpg.de/en/publications_databases_6118/publications_1904/mpidr_working_papers":here}.

{pstd}
Below, this article will be referred to as "the paper" and its appendix as "the appendix".

{pstd}
The main subcommand, which does the actual calculations, is {cmd:mcwr expectancies}. The other subcommands
either check the data set for consistency, carry out data management tasks, or display results.

{pstd}
Running {cmd:mcwr} demands a very specific data set in memory (called {help mcwr##defnitions:mcwr data set},
laid out in section {help mcwr##datasetup:Data setup}).
Several data management commands aide in creating such a specific data set.

{pstd}
The main data management subcommand is {cmd:mcwr genvars}, which generates
{help mcwr##definitions:p- and r- variables} that are missing from the data set.
These variables specify transition probabilities and rewards.
Other data management commands check the data set for consistency ({cmd:mcwr check}),
transform variable names ({cmd:mcwr switch}), or check or create an exit row ({cmd:mcwr exit}).

{pstd}
Two commands display results: {cmd:mcwr matbrowse} grabs results matrices and displays them
in Stata's data browser. This greatly facilitates looking at large matrices. {cmd:mcwr matlist}
is a simple wrapper for {help matlist} and displays results matrices in a nice format.


{marker abbreviations}{...}{* * * * * * * * * * * * * * * * * ABBREVIATIONS * * * * * * * * * * * * * * * *}
{title:Abbreviations and definitions used in this help entry}

{synoptset 27 tabbed}{...}
{syntab:Abbreviations}
{synoptline}
{synopt:MCWR}Markov chain with rewards{p_end}
{synopt:}{p_end}

{marker definitions}{...}
{syntab:Definitions}
{synoptline}
{synopt:p-variables}Variables whose name is of the format 'p##'.
They contain transition probability data.
The numbers encode from and target state.
The default for this number pair is the ji-format (see below).
For example, variable 'p12' has transition probabilities from-state 1 to state 2.{p_end}
{synopt:r-variables}Variables whose name is of the format 'r#_##'.
They contain rewards data.
The first number encodes the state that receives the reward.
The second and third numbers encode from and target state.
The default for this number pair is the ji-format (see below).{p_end}
{synopt:ji/ij-format}Variable (names) are said to be in ji-format if the first number of the variable name
specifies the from-state and the second number specifies the target state.
{bf:The index j always denotes the from-state.}
Consequently, variable (names) in ij-format state the target state first and then the from-state.{p_end}
{synopt:from/target/initial states}From-state and target state are the two states that are connected
by a state transition. The initial state is the state at baseline age.{p_end}
{synopt:mcwr data set}A data set that fulfills all requirements for {cmd:mcwr} to run on it
without error. The structure of the data set is set forth in section {help mcwr##datasetup:Data setup}.{p_end}
{synopt:}{p_end}
{synopt:}{p_end}

{marker options}{...}{* * * * * * * * * * * * * * * * * OPTIONS * * * * * * * * * * * * * * * *}
{title:Subcommand Detail and Options}

{dlgtab:Auxiliary data management subcommands}

{pstd}{marker mcwr_check}{...}
{cmd:mcwr check}

{pstd}
Run {cmd:mcwr check} to check whether your data set is a valid mcwr data set or whether you have
to modify something. It is also run internally by the other subcommands, so you are always safe
not to be using incorrectly set up data.

{pstd}
A second use of the subcommand is to gather comprehensive information about existing and missing model
variables, and more. See section {help mcwr##savedresults:Saved results}.

{phang2}{bf:Options}{p_end}

{phang2}
{opt ij} data set is in {help mcwr##ijformat:ij-format}.

{phang2}
{opt sk:ipexit} do not check the last row of the data set.

{phang2}
{opt noex:it} the exit row is missing in the data set.


{pstd}{marker mcwr_switch}{...}
{cmd:mcwr switch}

{pstd}
The appendix notation follows the ij-notation, where the first index refers to the
target state and the second index to the from-state. This has the advantage of conforming
with the conventions of matrix algebra.
{help mcwr##pvariables:p- and r-variables} of mcwr data sets, however, generally follow the ji-convention.
The advantage of this is that sorting the variables alphabetically results in a sensible
and intuitive ordering. Therefore, your data set variables are required to follow the ji-convention.
The convenience command {cmd:mcwr switch} allows you to switch between the two conventions.
If you have a consistent data set in ij-format, running this command will rename
variables according to the ji-convention.
Your data must be in ji-format before you can run any other of the {cmd:mcwr} subcommands that rely on
the data set in memory.
As a brief example, we load data in ji-format, then switch to ij-format and back:

{phang2}{help mcwr##examples:(learn how to download the example data; after the download:)}{p_end}
{phang2}{stata mcwr exampledata 1:(click to load example data)}{p_end}
{phang2}{stata list in 1/3:. list in 1/3}{p_end}
{phang2}{stata mcwr switch:. mcwr switch}{p_end}
{phang2}{stata list in 1/3:. list in 1/3}{p_end}
{phang2}{stata mcwr switch:. mcwr switch}{p_end}
{phang2}{stata list in 1/3:. list in 1/3}{p_end}

{phang2}{bf:Options}{p_end}

{phang2}
{opt ji} data set will always be in {help mcwr##definitions:ji-format} after command conclusion.
That is, if the data are in ij-format they will be converted to ji-format, and will be left
untouched otherwise.

{phang2}
{opt noi:sily} will display verbose error messages. This is useful if the command tells you that
it can neither find a consistent ji data set nor a consistent ij data set. The error messages
under option {opt noisily} may give you a clue about the source of the error.


{pstd}{marker mcwr_exit}{...}
{cmd:mcwr exit}

{pstd}
{cmd:mcwr} requires that all data points that do not enter matrix calculations be set to missing
in order to avoid incorrectly set up data. This rule makes the last (exit) row of the mcwr data set
somewhat tedious to manage.
The convenience command {cmd:mcwr exit} makes it easier to create or edit the last (exit) row
of the data set.

{phang2}{bf:Options}{p_end}

{phang2}
{opt age(ageval, [replace update])} specifies the age of the exit row in the data set. It may or may not exist.
It may not be smaller than the largest age in the data set.

{pmore2}
If {it:ageval} corresponds to the largest age in the data set,
suboption {opt replace} must be specified. The values of the corresponding row are replaced.
Exit transition values for p-variables are set to 1.
Exit transition values for r-variables are left as-is if they are non-missing and suboption {opt update}
is not used. Otherwise they are set to {it:rwval}.
Values of all other transitions are set to missing.

{pmore2}
If {it:ageval} is larger than the largest age in the data set, a new row will be inserted.
Exit transitions are set to 1 for p-variables and to {it:rwval} for r-variables.
Values of all other transitions are set to missing.

{phang2}
{opt rew:ards(rwval)} determines the rewards value for exit transitions.
Its default value (when left unspecified) is 0.

{dlgtab:Main subcommands}

{pstd}{marker mcwr_genvars}{...}
{cmd:mcwr genvars}

{pstd}
The main purpose of this subcommand is to generate rewards variables (r-variables).
It examines existing p- and r-variables, determines the implied full set of states,
and generates any missing variables that are missing from the data set.
It interacts flexibly with existing r-variables:
You can leave them unchanged or have them replaced.

{pstd}
An effective way to create r-variables may be to generate a full set of r-variables
using {cmd:mcwr genvars} and then edit them where necessary.
This is illustrated under {help mcwr##examples:Examples}.

{phang2}{bf:Options}{p_end}

{phang2}
{opt tim:ing(timespec, {add|replace})} specifies how rewards are distributed to
from and target states. It is required if option {opt nor} is not used.
{it:timespec} can be one of 'bop', 'mid', and 'eop', which stands for
'beginning-of-period', 'mid-period', and 'end-of period', respectively.
Alternatively, it can also be a number in the interval [0 1] that specifies
the fraction of the interval that goes to the {it:from}-state.
Values of 0, 0.5, and 1 correspond to 'beginning-of-period', 'mid-period', and
'end-of-period', respectively.

{pmore2}
{opt add} will leave existing r-variables unchanged.

{pmore2}
{opt replace} will replace them.

{phang2}
{opt nop} does not generate any p-variables. By default, all missing p-variables are
generated. Since existing p-variables must satisfy the sums-to-unity condition, only
p-variables that are (by implication) all-zero can be missing. {cmd:mcwr expectancies} will
run whether such redundant variables exist or not.

{phang2}
{opt nor} does not generate any r-variables.

{phang2}
{opt ord:er} orders variables alphabetically according to the varlist 'age p* r*'.


{pstd}{marker mcwr_expectancies}{...}
{cmd:mcwr expectancies}

{pstd}
This is the subcommand that does the actual calculations.
It returns its results in r(), most notably in r() matrices.

{phang2}{bf:Options}{p_end}

{phang2}
{opt ini:tprop(initspec)} supplies information about the initial state fractions at baseline age.
{it:initspec} can either be a numlist of values in the interval [0 1] which sum to 1.
Numbers are taken to correspond to from-states in an sequential order. For example,
If your model contains from-states 1 2 7, {it:initspec} must consist of three numbers,
specifying the initial proportion of each state in turn.
Alternatively, {it:initspec} may also be the name of a Stata matrix with one row
and columns according to the number of from-states in the model.
Its column names must either be the numeric, sequential from-states ('1 2 7' in the
above example) or their label equivalents, determined by value label MCWR
(see section {help mcwr##themcwrvaluelabel:The MCWR value label}).

{phang2}
{opt tim:ing(timespec, {add|replace})} - see {help mcwr##mcwr_genvars:mcwr genvars} above.

{pmore2}
In most cases, you do not have to create a full set
of r-variables using subcommand {cmd:genvars}.
r-variables that correspond to timings that can be accommodated
by the {opt timing()} option can be created automatically, behind the scenes.
You do so by specifying the {opt timing()} option in subcommand {opt expectancies}
instead in the subcommand {cmd:genvars}.
Any missing r-variables (and p-variables, for that matter) will then be created behind
the scenes before calculations are done.
They will get deleted before the command concludes.

{pmore2}
r-variables with more complicated timings have to be created explicitly before running
subcommand {cmd:expectancies}.

{phang2}
{opt keep} will keep any temporarily generated p- and r-variables that are
necessary for the computation. The default is to drop them
before command conclusion.


{dlgtab:Results display subcommands}

{pstd}{marker mcwr_matbrowse}{...}
{cmd:mcwr matbrowse}

{pstd}
This subcommand exists to facilitate looking at large matrices. The best way in
Stata to look at large matrices is to convert them to a data set and then
{help browse} the matrix data. {cmd:mcwr matbrowse} does this, and upon
any keystroke restores the data that had been in memory before.

{pstd}
It only works on {cmd:mcwr} results matrices (e, P, F, R#) and you must specify
one of them in the command statement.
It first looks for the corresponding matrix in r() (e.g., r(P)) and, if it
cannot find the matrix there, under its regular matrix name (e.g., P).

{phang2}{bf:Options}{p_end}

{phang2}
{opt f:ormat(%fmt)} formats variables accoding to {it:%fmt}.

{phang2}
{opt norestore} does not restore the previous data set but keeps the matrix data in memory.

{phang2}
{opt nosh:ow} transfers the matrix data to the data in memory but does not open
the data browser.


{pstd}{marker mcwr_matlist}{...}
{cmd:mcwr matlist}

{pstd}
This subcommand is a simple wrapper for {help matlist} and separates states by lines
when displaying results matrices.

{phang2}{bf:Options}{p_end}

{phang2}
{it:matlistopts} all options allowed by {help matlist}


{marker remarks}{...}{* * * * * * * * * * * * * * * * * REMARKS * * * * * * * * * * * * * * * *}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

    {help mcwr##datasetup:Data setup}
    {help mcwr##themcwrvaluelabel:The MCWR value label}
    {help mcwr##limitations:Limitations}
    {help mcwr##lifetablesandopenageintervals:Life table and open age intervals}
    {help mcwr##othercomm:Other community-contributed commands related to multistate models}
    
{marker datasetup}{...}
{title:Data setup}

{pstd}
{cmd:mcwr} requires the transition data to be in a very specific format, called 'mcwr data set' in this help entry. To give you a quick idea of what
is required, {stata clear} your data in memory and click {stata mcwr exampledata 5 :here} to load an example data set. Then list its
beginning and ending rows:

{pmore}
{stata list if !inrange(age, 56, 105), noobs sep(6) : list if !inrange(age, 56, 105), noobs sep(6)}

{pstd}
In general, the following rules and conventions apply:

{p2colset 7 9 9 2}{...}
{p2col:-}Transition probabilities are specified in {help mcwr##definitions:p-variables}.
The default convention for specifying from and target states is the {help mcwr##definitions:ji-format}:
The first number encodes the from-state, the second number the target state.{p_end}
{p2col:-}Rewards are specified in {help mcwr##definitions:r-variables}.
The numbers occuring in the variable names specify the rewarded state, the from-state, and the
target state, respectively.{p_end}
{p2col:-}A maximum number of 9 states (including the absorbing state) is allowed.
States must be encoded using numbers 1-9. 0 is not allowed.{p_end}
{p2col:-}Only a single absorbing state is allowed. It is encoded by the highest
number occuring for all states. In the example, 5 is the aborbing state.{p_end}
{p2col:-}States can be non-contiguous. In the example, states 2 and 3 are missing
from the model. The states of the model are 1, 4, 5.{p_end}
{p2col:-}Transition probabilities must sum to 1. For example, columns p11, p14, p15 sum to 1.{p_end}
{p2col:-}As long as the sums-to-unity condition is satisfied, not all p-variables must be present.
In the example, variable p41 is missing, and all-zero by implication.{p_end}
{p2col:-}Age (or, more general, time) is specified in a variable called 'age'.{p_end}
{p2col:-}{bf:Irregular age intervals are allowed.} The {help mcwr##ex_ltb5:Examples} section
illustrates this with a life table on a 'demographic' 5-year age grid (childhood age intervals are shorter).{p_end}
{p2col:-}The first row of the data set specifies the baseline age. All p- and r-variables must have
missing values in the first row.{p_end}
{p2col:-}The last row of the data set corresponds to the exit age. At this age, all subjects
are required to die (enter the absorbing state). In the example, variables p15 and p45 are set
to 1 at age 111. All other transitions at the exit age must be set to missing.{p_end}
{p2col:-}In general, whenever values of a mcwr data set are certain to not enter matrix calculations,
they must be set to missing in the data set. Conversely, data points that are certain to enter
matrix calculations must never be missing.{p_end}
{p2col:-}The first transition takes place in row 2 (age 51 in the example).
{bf:It is important to keep in mind that age specifies a point in time, not an interval.}
It is the point in time when the subject turns 51.{p_end}
{p2col:-}At this point, rewards can be distributed for the previous age (interval).
Standard Markov chain calculations would distribute occupancy times end-of-period
(the transition takes place at exact age 51).
By contrast, in the example we distribute time rewards and assume mid-period transitions, i.e. we assume
that state transitions take place at ages 50.5, 51.5, etc. The reward for state 1 of the 1->4 transition
at age 51 is specified to be 0.5. This covers the period [50 50.5).
The reward for state 4 of the 1->4 transition
at age 51 is also specified to be 0.5. This covers the period [50.5 51). From the same logic,
staying in the same state carries a reward of 1. It is made up of rewards of 0.5 for each one
of the periods [50 50.5) and [50.5 51), respectively.{p_end}
{p2col:-}Rewards can only flow to from or target states.
For example, a variable 'r3_12' in the data set will be flagged as an error.{p_end}
{p2col:-}Rewards can only flow to transient states.
In the example, where the absorbing state is 5, a variable 'r5_45' will generate an error.{p_end}
{p2col:-}Rewards can take on any numeric value, including negative ones.{p_end}
{p2col:-}You may have additional variables (variables other than p- and r-variables) in the data set.
They will be ignored.{p_end}
{p2colreset}{...}

{pstd}
As a minor remark on the example data set,
it is derived from the SHARE application in the paper. In that
application, state 1 is left with certainty when turning 71, with no return possible.
The values shown in the data set for p14 and p15 for ages 71 and higher are therefore
immaterial, given that this state is never occupied at these ages.

{marker themcwrvaluelabel}{...}
{title:The MCWR value label}

{pstd}
If the value label 'MCWR' is present, its mappings are used for more convenient input options,
labelling r()-output, and variable names.
No consistency checks on the value label definition are performed, however.


{marker limitations}{...}
{title:Limitations}

{pstd}
At the risk of redundancy, here are the limitations that the command places on the model setup:

{p2colset 7 9 9 2}{...}
{p2col:-}The maximum number of states is 9 (including the absorbing state).{p_end}
{p2col:-}Only a single absorbing state is allowed.{p_end}
{p2col:-}Rewards can only flow to from or target states.{p_end}
{p2colreset}{...}

{pstd}
Moreover, the code of the command has been written with user convenience in mind, which
took its toll on efficiency. So, it is somewhat slow.
To give you a rough idea, using a 4GHz single core computer to run the command
on 10,000 mcwr data sets (110 observations, 3 transient states) took around 20 minutes
(0.12 seconds per iteration).

{marker lifetablesandopenageintervals}
{title:Life tables and open age intervals}

{pstd}
The last age group of life tables is frequently an open interval.
What does this mean for mcwr data sets?
In the present context, the important thing to recognize is that {cmd:mcwr expectancies}
must have access to the proper ax value (Chiang's a).
The best way to achieve this is to set exit age (certain transition into
death) to some number greater than the previous age.
It does not really matter which age you choose as long as you assign the
ax value to the correct rewards variable.
The {help mcwr##ex_ltb1:Examples} section below illustrates this.

{marker othercomm}
{title:Other community-contributed commands related to multistate models}

{pstd}
Recent commands related to multistate modelling include 
{cmd:multistate} ({help mcwr##references:Crowther, Michael J., and Paul C. Lambert (2017)}),
{cmd:mstatecox} ({help mcwr##references:Metzger, Shawna K., and Benjamin T. Jones (2018)}), and
{cmd:mslt} ({help mcwr##references:Muniz, Jerônimo Oliveira (2020)}).


{marker examples}{...}{* * * * * * * * * * * * * * * * * EXAMPLES * * * * * * * * * * * * * * * *}
{title:Examples}

{pstd}
{bf:{ul:Downloading example data sets:}} You need to download the example
data sets first in order to
execute the examples below. Do {title:so} by

{center:{stata net get mcwr :. net get mcwr}}

{pstd}
This will download three small Stata files (total 8KB) to your working directory.
The examples will either be based on these files
directly or on small modifications of them.
The appropriate example data will be stored in memory by the links
{title:below} that read "(click to load example data)".

{phang}{marker ex_ret}
The first example uses a subset of the data from the retirement example in the paper.
The example data set only contains transition variables.
We verify that the data set is suitable for {cmd:mcwr} and gather some model information

{phang2}{stata mcwr exampledata 1:(click to load example data)}{p_end}
{phang2}{stata mcwr check :. mcwr check}{p_end}
{phang2}{stata return list:. return list}{p_end}

{pmore}
r(s_frm) tells us that the from-states are 1 2 4, and r(s_abs) indicates 5 to be
the absorbing state. There are 61 age classes in the model, which we can see from r(numages).
Given initial proportions, we can immediately calculate expectancies with different timing assumptions:

{phang2}{stata mcwr expectancies , timing(mid) initprop(0.95 0.04 0.01):. mcwr expectancies , timing(mid) initprop(0.95 0.04 0.01)}{p_end}
{phang2}{stata mcwr expectancies , timing(eop) initprop(0.95 0.04 0.01):. mcwr expectancies , timing(eop) initprop(0.95 0.04 0.01)}{p_end}

{pmore}
Since we have a regular age grid of 1, the corresponding magnitudes in the
'end-of-period' specification are higher by 0.5.
The output also tells us that total life expectancy does not depend on the initial state and that
some occupation times are zero.
This comes from the particular data restrictions and assumptions of the application in the paper:
Mortality does not differ across states,
and transitions from state 4 (retirement) to states 1 (working) or 2 (unemployed) never occur (by assumption).
See the paper for more details.

{pmore}
Since we are talking about the meaning of the state encodings:
Let's label the numeric values with meaningful descriptions.
If we define a value label called 'MCWR', {cmd:mcwr} will use it to make the output a little nicer:

{phang2}{stata label define MCWR 1 work 2 unem 4 retr 5 dead , modify:. label define MCWR 1 work 2 unem 4 retr 5 dead , modify}{p_end}
{phang2}{stata mcwr expectancies , timing(eop) initprop(0.95 0.04 0.01):. mcwr expectancies , timing(eop) initprop(0.95 0.04 0.01)}{p_end}

{pmore}
This is also useful when browsing matrices (this will open the data browser):

{phang2}{stata mcwr matbrowse F:. mcwr matbrowse F}{p_end}
{phang2}{stata X :(resume Stata execution)}{p_end}

{pmore}
Let's now assume that retirement occurs on average 3 months into the retirement
year. The easiest way to specify this is to generate all rewards variables first
as mid period and then edit them as needed:

{phang2}{stata mcwr genvars , timing(mid) order:. mcwr genvars , timing(mid) order}{p_end}
{phang2}{stata describe:. describe}{p_end}
{phang2}{stata replace r1_14 = 0.25 if !mi(r1_14):. replace r1_14 = 0.25 if !mi(r1_14)}{p_end}
{phang2}{stata replace r4_14 = 0.75 if !mi(r4_14):. replace r4_14 = 0.75 if !mi(r4_14)}{p_end}
{phang2}{stata replace r2_24 = 0.25 if !mi(r2_24):. replace r2_24 = 0.25 if !mi(r2_24)}{p_end}
{phang2}{stata replace r4_24 = 0.75 if !mi(r4_24):. replace r4_24 = 0.75 if !mi(r4_24)}{p_end}

{pmore}
We do not have to worry about transitions out of retirement since their probability
is zero.

{pmore}
At this point it is useful to {stata browse:browse} the data.
In particular, take note of how the first and last few rows are structured.

{pmore}
We recalculate:

{phang2}{stata mcwr expectancies, initprop(0.95 0.04 0.01):. mcwr expectancies, initprop(0.95 0.04 0.01)}{p_end}

{pmore}
As an alternative to the above {cmd:replace} statements,
we could have solely used subcommand {cmd:genvars} in conjunction
with the {opt timing()} option of {cmd:mcwr expectancies}.
This has the advantage of not having to worry about getting the 
baseline and exit age rows right (the "if !mi()" part of the statements).

{phang2}{stata drop r*:. drop r*}{p_end}
{phang2}{stata mcwr genvars , timing(0.25) order:. mcwr genvars , timing(0.25) order}{p_end}
{phang2}{stata keep age p?? r?_14 r?_24:. keep age p?? r?_14 r?_24}{p_end}
{phang2}{stata mcwr expectancies , timing(mid, add) initprop(0.95 0.04 0.01):. mcwr expectancies , timing(mid, add) initprop(0.95 0.04 0.01)}{p_end}

{pmore}
After the creation of the 'timing(0.25)' rewards variables, we could 
have generated the remaining rewards variables explicitly:

{phang2}{stata mcwr genvars , timing(mid, add) order:. mcwr genvars , timing(mid, add) order}{p_end}
{phang2}{stata mcwr expectancies, initprop(0.95 0.04 0.01):. mcwr expectancies, initprop(0.95 0.04 0.01)}{p_end}


{phang}{marker ex_ltb1}
Next, we illustrate the equivalence to standard life table calculations.
We first look at a regularly spaced 1-year life table.

{phang2}{stata mcwr exampledata 2:(click to load example data)}{p_end}
{phang2}{stata describe:. describe}{p_end}

{pmore}
Checking whether we have a proper mcwr data set reveals problems:

{phang2}{stata mcwr check:. mcwr check} // <- generates error{p_end}

{pmore}
We look at the beginning and ending rows of the data set:

{phang2}{stata list if !inrange(_n, 6, 106) , sep(5) noobs:. list if !inrange(_n, 6, 106) , sep(5) noobs}{p_end}

{pmore}
We see that a number of mcwr data requirements, in particular those concerning the first and last
row of the data set, are not met.

{phang2}{stata mcwr exampledata 6:(click to load the same data as a mcwr data set)}{p_end}
{phang2}{stata list if !inrange(_n, 6, 107) , sep(5) noobs:. list if !inrange(_n, 6, 107) , sep(5) noobs}{p_end}

{pmore}
The correct life table value for e0 is 80.16. Mid-period {cmd:mcwr} calculations yield

{phang2}{stata mcwr expectancies , timing(mid):. mcwr expectancies , timing(mid)}{p_end}

{pmore}
This ignores the values in the ax variable, which are different from 0.5
for the first and last age.
We take them into account be generating an r-variable with corresponding values.

{phang2}{stata gen r1_12 = ax:. gen r1_12 = ax}{p_end}
{phang2}{stata mcwr expectancies , timing(mid, add):. mcwr expectancies , timing(mid, add)}{p_end}

{pmore}
The result is a little more accurate than the previous calculation.

{phang}{marker ex_ltb5}
Let's look at the corresponding 5-year life table.

{phang2}{stata mcwr exampledata 3:(click to load example data)}{p_end}
{phang2}{stata mcwr check:. mcwr check} // <- generates error{p_end}
{phang2}{stata list, sep(0) noobs:. list, sep(0) noobs}{p_end}

{pmore}
The data set must again be first transformed to a valid mcwr data set.

{phang2}{stata mcwr exampledata 7:(click to load the modified data)}{p_end}
{phang2}{stata mcwr check:. mcwr check}{p_end}
{phang2}{stata list, sep(0) noobs:. list, sep(0) noobs}{p_end}

{pmore}
We again perform calculations with and without taking ax into account:

{phang2}{stata mcwr expectancies , timing(mid):. mcwr expectancies , timing(mid)}{p_end}

{phang2}{stata ren ax r1_12:. ren ax r1_12}{p_end}
{phang2}{stata mcwr expectancies , timing(mid, add) keep:. mcwr expectancies , timing(mid, add) keep}{p_end}

{pmore}
This time we also specified the {opt keep} option.
This option kept the rewards variable r1_11, which was generated by {cmd:mcwr expectancies}
behind the scenes, from being dropped before the command concluded:

{phang2}{stata list, sep(0) noobs:. list, sep(0) noobs}{p_end}

{pmore}
We did this to illustrate how {cmd:mcwr} uses rewards to handle irregularly spaced age intervals.


{marker savedresults}{...}{* * * * * * * * * * * * * * * * * SAVEDRESULTS * * * * * * * * * * * * * * * *}
{title:Saved results}

{pstd}
Below, all returned lists are sorted.


{pstd}
{cmd:mcwr check} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Macros}
{synopt:{cmd:r(p_exi)}}p-variables in the data set{p_end}
{synopt:{cmd:r(p_ful)}}full set of p-variables implied by states{p_end}
{synopt:{cmd:r(p_new))}}p-variables that are implied by states but not in the data set{p_end}
{synopt:{cmd:r(s_trn))}}list of transitions occuring in data set{p_end}
{synopt:{cmd:r(s_frm))}}list of from-states{p_end}
{synopt:{cmd:r(s_trg))}}list of target states{p_end}
{synopt:{cmd:r(s_abs))}}absorbing state{p_end}
{synopt:{cmd:r(s_omt))}}states omitted from the model{p_end}
{synopt:{cmd:r(r_exi))}}r-variables in the data set{p_end}
{synopt:{cmd:r(r_ful))}}full set of p-variables implied by states{p_end}
{synopt:{cmd:r(r_new))}}r-variables that are implied by states but not in the data set{p_end}
{synopt:{cmd:r(r_trn))}}list of transitions covered by existing r-variables{p_end}
{synopt:{cmd:r(s_rcv))}}states receiving rewards{p_end}
{synopt:{cmd:r(s_nrc))}}states not receiving rewards{p_end}
{synopt:{cmd:r(s#desc))}}description / value label of state #{p_end}
{synopt:{cmd:r(numages))}}number of age classes in the model{p_end}
{synopt:{cmd:r(agelist))}}list of age classes of the model{p_end}
{synopt:{cmd:r(ageintervals))}}list of lengths of age intervals{p_end}
{synopt:{cmd:r(hasexit))}}0/1: whether data has an exit row{p_end}


{pstd}
{cmd:mcwr switch} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Macros}
{synopt:{cmd:r(oldorder)}}the previous order: one of 'ji' or 'ij'{p_end}
{synopt:{cmd:r(neworder)}}the new order: one of 'ji' or 'ij'{p_end}
{synopt:{cmd:r(oldvarnames)}}list of p- and r-variables before the switch{p_end}
{synopt:{cmd:r(newvarnames)}}list of p- and r-variables after the switch{p_end}


{pstd}
{cmd:mcwr genvars} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Macros}
{synopt:{cmd:r(vars_existed)}}p- and r-variables that already existed{p_end}
{synopt:{cmd:r(vars_filled)}}p- and r-variables that were newly created{p_end}


{pstd}
{cmd:mcwr expectancies} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(total)}}total weighted expectancy{p_end}

{syntab:Matrices}
{synopt:{cmd:r(e)}}state expectancies{p_end}
{synopt:{cmd:r(P)}}transition probabilities{p_end}
{synopt:{cmd:r(F)}}fundamental matrix{p_end}
{synopt:{cmd:r(R#)}}rewards matrix for state #{p_end}
{synopt:{cmd:r(initprop)}}matrix of initial proportions, if supplied to the command{p_end}
{p2colreset}{...}


{marker author}{...}{* * * * * * * * * * * * * * * * * AUTHOR * * * * * * * * * * * * * * * *}
{title:Author}

{pstd}
Daniel C. Schneider, Mikko Myrskylä, Alyson van Raalte{break}
Max Planck Institute for Demographic Research ({browse www.mpidr.de}){break}
Support: schneider@demogr.mpg.de


{marker references}{...}{* * * * * * * * * * * * * * * * * REFERENCES * * * * * * * * * * * * * * * *}
{title:References}

{phang}{marker smv2021}{...}
Schneider, Daniel C., Myrskylä, M., and Alyson van Raalte (2021):
Flexible Transition Timing in Discrete-Time Multistate Life Tables
Using Markov Chains with Rewards. {it:MPIDR Working Paper}, February 2021.

{phang}{marker cl2017}{...}
Crowther, Michael J., and Paul C. Lambert (2017): Parametric Multistate Survival Models: Flexible Modelling Allowing Transition-Specific
Distributions with Application to Estimating Clinically Useful Measures of Effect Differences.
{it:Statistics in Medicine} 36 (29): 4719–42. https://doi.org/10.1002/sim.7448.

{phang}{marker mj2028}{...}
Metzger, Shawna K., and Benjamin T. Jones (2018): Mstatecox: A Package for Simulating Transition Probabilities from
Semiparametric Multistate Survival Models. {it:The Stata Journal} 18 (3): 533–63. https://doi.org/10.1177/1536867X1801800304

{phang}{marker m2020}{...}
Muniz, Jerônimo Oliveira (2020): Multistate Life Tables Using Stata. {it:The Stata Journal} 20 (3): 721–45.
https://doi.org/10.1177/1536867X20953577.



{marker alsosee}{...}{* * * * * * * * * * * * * * * * * ALSOSEE * * * * * * * * * * * * * * * *}
{title:Also see}

{psee}
User-written, if installed:

{col 5}{bf:mslt}{col 20}{stata help mslt:-help-}{col 27}{stata "net install st0615, from(http://www.stata-journal.com/software/sj20-3)":-install-}{...}
{col 37}{stata "view net describe st0615, from(http://www.stata-journal.com/software/sj20-3)":-remote help-}

{col 5}{bf:mstatecox}{col 20}{stata help mstatecox:-help-}{col 27}{stata "net install st0534_1, from(http://www.stata-journal.com/software/sj19-3)":-install-}{...}
{col 37}{stata "view net describe st0534_1, from(http://www.stata-journal.com/software/sj19-3)":-remote help-}

{col 5}{bf:multistate}{col 20}{stata help stms:-help-}{col 27}{stata ssc install multistate:-install-}{col 37}{stata "view net describe multistate, from(http://fmwww.bc.edu/repec/bocode/m)":-remote help-}






