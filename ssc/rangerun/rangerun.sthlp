{smcl}
{* 30may2017/8jun2017}{...}
{cmd:help rangerun}
{hline}

{title:Title}

{phang}
{cmd:rangerun} {hline 2} Run Stata commands on observations within range


{title:Syntax}

{p 8 17 2}
{cmd:rangerun} 
{it:program_name} 
{ifin} 
{cmd:,} 
{opt i:nterval(keyvar low high)}
[
{it:{help rangerun##table_options:options}}
]

{synoptset 27 tabbed}{...}
{marker table_options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt i:nterval(keyvar low high)}}use observations where {it:keyvar}
is within the bounds indicated by {it:low} and {it:high}
{p_end}
{synopt :{opth by(varlist)}}the set of observations to use is found within {it:by} group
{p_end}
{synopt :{opth u:se(varlist)}}the set of numeric variables visible to {it:program_name}
{p_end}
{synopt :{opth s:prefix(string)}}variable name prefix used to create scalars to hold current observation's values
{p_end}
{synopt :{opt v:erbose}}output while running {it:program_name} is not suppressed 
{p_end}
{synoptline}
{phang}* {opt i:nterval(keyvar low high)} is required. 
{it:keyvar} is a numeric variable.
The lower and upper bound of the closed interval to use 
for each observation can be
specified using a numeric variable, a {it:#}, or a {help missing:system missing value}.
If a {it:#} is used, the bound for each observation is computed by adding {it:#} to {it:keyvar}.
If {it:low} is specified using a {help missing:system missing value}, {it:low} is set to 
missing for all observations. 
{cmd:rangerun} applies the same rules as {help inrange()} for missing bounds.
{p2colreset}{...}


{marker Description}{...}
{title:Description}

{pstd}
{cmd:rangerun} requires the latest version
of {stata ssc des rangestat:rangestat}. 
Click {stata ssc install rangestat:here to install} {cmd:rangestat}
from SSC.

{pstd}
{cmd:rangerun} uses the same mechanics as {cmd:rangestat} to identify,
for each observation in the sample, the set of observations that fall
within the bounds of the specified interval.
Please consult {cmd:rangestat}'s {help rangestat:help file};
it contains detailed instructions on how to set the {opt i:nterval()} 
as well as numerous examples of how to control the sample,
including how to implement various types of rolling windows.

{pstd}
{cmd:rangerun} makes a virtual copy of the numeric variables to use
for all observations in the sample
(stored in a Mata matrix)
and then loops over each of these observations.
At each iteration, the data in memory is cleared and replaced
with the set of observations in range for the current observation.
The observations in range are sorted by {it:keyvar} and
follow the order they appear
in the initial data in memory when {it:keyvar} values are the same.

{pstd}
{it:program_name} is then called.
{it:program_name} takes no argument and returns nothing.
{it:program_name} may include as many Stata commands as needed.
Results are picked out from what is left in memory when {it:program_name}
terminates without error.
{cmd:rangerun} identifies all new numeric variables
and stores results using values from the last observation in memory.

{pstd}
If you have multiple observations with the same interval
bounds, you should follow the advice in the
{it:{help rangerun##Controlling_the_sample:Controlling the sample: Median salary of non-teammates}}
example below on how to designate a representative
observation to avoid running {it:program_name} needlessly
over the same subset of observations.

{pstd} 
The references give a context of previous discussions of related problems. In essence, the main point is that {cmd:rangerun} and {help rangestat} supersede many of the techniques discussed there. 


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opt i:nterval(keyvar low high)} is required and defines the interval 
that selects the set of observations to use to calculate results for the 
current observation.
{it:keyvar} is a numeric variable.
Observations whose values for {it:keyvar} fall within the 
closed interval bounds are selected.
{it:low} and {it:high} can each be
specified using a numeric variable, a {it:#} (a number in Stata parlance), or a {help missing:system missing value}.
If a {it:#} is used, the bound for each observation is computed by adding {it:#} to {it:keyvar}.
If {it:low} is specified using a {help missing:system missing value}, {it:low} is set to missing
for all observations. 
{cmd:rangerun} applies the same rules as {help inrange()} for missing bounds:
if the lower bound is missing, observations will match up to and including
the value of {it:high}.
If both {it:low} and {it:high} are missing, all observations will match.

{phang}{opth by(varlist)} specifies that observations
in range with respect to the current observation are found
only within the same group of the variables named. 

{phang}{opth u:se(varlist)} specifies the set of numeric variables
in the data in memory when {it:program_name} is called. 
If not specified, all numeric variables are included.
Since the data in memory is constantly being refreshed with
the set of observations in range for the current observation,
fewer variables will result in faster execution times. 

{phang}{opth s:prefix(string)} specifies the prefix to use when
creating scalars to hold the value of each variable for the 
current observation. 
The name of each scalar is the combination of the prefix followed
by the variable name. 
This allows your program to condition a task based 
on the value of some variable(s) for the current observation.
You can, for example, exclude the current observation when
performing calculations (see the 
{help rangerun##Controlling_the_sample:Controlling the sample: Median salary of non-teammates}
example below).
The scalars are created with the correct value even if
the current observation does not fall within the
set of observations in range.
If the option is not specified, no scalar is created.

{phang}{opt v:erbose} indicates that the output generated by
{it:program_name} should appear in the Results window. 
This option is useful for testing your program on
a small subsample. 
WARNING: this can generate a tremendous
amount of output as {it:program_name} will be called
as many times as there are observations in the overall sample.


{marker Examples}{...}
{title:Examples}

{pstd}
If you are familiar with {help rangestat}, {help rolling}, 
{help statsby}, 
or if you have used a loop to generate results based on
subsets of observations,
you may get started quickly by browsing the following examples that
contrast a {cmd:rangerun} solution to each alternative method:

	{help rangerun##Compared_with_rangestat:Compared with rangestat}
	{help rangerun##Compared_with_rolling:Compared with rolling}
	{help rangerun##Compared_with_statsby:Compared with statsby}
	{help rangerun##Compared_with_looping:Compared with looping over observations}
        
{pstd}
Users are encouraged to step through an extended example
of how to perform a weighted regression over a rolling window:

	{help rangerun##weighted_regression:Weighted regression over a rolling window}

{pstd}
Additional examples:

	{help rangerun##Controlling_the_sample:Controlling the sample: Median salary of non-teammates}
	{help rangerun##measures_of_skew:Collation and comparison of various measures of distribution skew}


{title:Examples where rangerun is compared with alternative solutions}


{marker Compared_with_rangestat}{...}
{pstd}{ul:Compared with rangestat}

{pstd}
{cmd:rangerun} is very similar to {cmd:rangestat} and everything
that can be done with {cmd:rangestat} can also be done with {cmd:rangerun}.
With {cmd:rangestat}, however, you are limited to built-in functions
or you must create your own Mata function to get what you want.

{pstd}
The following example creates panel data for 100 companies, each with data
over a 360 month period. 
There are missing values and gaps in the data.
The task is to calculate basic statistics for the variable {hi:invest}
over a 12 month rolling window within panels.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared2rangestat}{...}
	* create data for 100 companies over 360 months
	clear all
	set seed 31231
	set obs 100
	gen long company = _n
	expand 360
	bysort company: gen mdate = ym(1987,1) + _n
	format %tm mdate
	gen invest = runiform() if runiform() < .95
	drop if runiform() < .05

	timer on 1
	program myprog
	  sum invest
	  gen rrun_n = r(N)
	  gen double rrun_mean = r(mean)
	  gen double rrun_sd = r(sd)
	end
	rangerun myprog, interval(mdate -11 0) use(invest) by(company)
	timer off 1

	timer on 2
	rangestat (count) invest (mean) invest (sd) invest, ///
		interval(mdate -11 0) by(company)
	timer off 2
	
	* confirm that results are the same using both methods
	assert rrun_n == invest_count
	assert rrun_mean == invest_mean
	assert rrun_sd == invest_sd
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run compared2rangestat using rangerun.sthlp:click to run})}

{pstd}
{stata timer list:Click here} to list
the timer results.
{cmd:rangerun} is a bit slower than {cmd:rangestat}
but it is vastly more flexible since you can use the full
complement of Stata statistical commands.
If possible, use the most efficient Stata command to do the job
since {it:program_name} will be called for each observation in 
the sample (except if there is no
observation within the interval bounds of the current observation).

{pstd}
Note that execution times for both {cmd:rangerun} and {cmd:rangestat}
increase linearly, in proportion to the number of observations.
So if you double the number of companies in the example above, the
run times will be twice as long.


{marker Compared_with_rolling}{...}
{pstd}{ul:Compared with rolling}

{pstd}
Everything that can be done with {cmd:rolling} can also be done with {cmd:rangerun}.
The following replicates the last example in {cmd:rolling}'s {help rolling:help file}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared2rolling}{...}
	webuse lutkepohl2, clear
	tsset qtr
	rolling ratio=(r(mean)/r(p50)), window(10): summarize inc, detail
	list in 1/10
	
	clear all
	program myprog
	  if _N < 10 exit
	  summarize inc, detail
	  gen ratio = r(mean)/r(p50)
	end
	webuse lutkepohl2, clear
	rangerun myprog, interval(qtr -9 0) use(inc)
	list qtr inc ratio in 1/19, sep(0)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run compared2rolling using rangerun.sthlp:click to run})}

{pstd}
Note that
execution times with {cmd:rolling} increase exponentially
as the data size increases. 
For large problems, {cmd:rangerun} will be orders of magnitude faster than {cmd:rolling}.


{marker Compared_with_statsby}{...}
{pstd}{ul:Compared with statsby}

{pstd}
Everything that can be done with {cmd:statsby} can also be done with {cmd:rangerun}.
The following replicates the last example in {cmd:statsby}'s {help statsby:help file}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared2statsby}{...}
	sysuse auto, clear
	statsby mean=r(mean) sd=r(sd) size=r(N), by(rep78):  summarize mpg
	list
	
	clear all
	program myprog
	  if mi(rep78) exit
	  sum mpg
	  gen size = r(N)
	  gen mean = r(mean)
	  gen sd = r(sd)
	end
	
	sysuse auto
	bysort rep78 (make): gen high = cond(_n==1, ., -1)
	rangerun myprog, interval(price . high) by(rep78)
	list rep78 mpg size mean sd if high == . & !mi(rep78)
	
	* if desired, carry forward the results of the first obs within rep78 groups
	by rep78: replace size = size[1]
	by rep78: replace mean = mean[1]
	by rep78: replace sd = sd[1]
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run compared2statsby using rangerun.sthlp:click to run})}

{pstd}
To replicate {cmd:statsby}'s functionality, 
you specify a {hi:by(rep78)} option combined with
an interval
that selects all observations within these {hi:by()} groups.
If both {it:low} and {it:high} bounds are missing, all observations
within the {hi:by()} group are selected. 
The example uses {hi:price} as {it:keyvar} because
it contains no missing values (missing values would exclude the
observation from the overall sample), but any numeric variable with
no missing values would have worked.
To avoid running {hi:myprog} over and over for each observation
within each {hi:rep78} group, we make the {it:high} bound missing
for the first observation in the group and -1 for all repeats.
Since there is no value for {hi:price} between minus infinity and -1, 
there are no observations in range for these repeated observations.
When that happens, {cmd:rangerun} does not run {hi:myprog} 
and results are set to missing.

{pstd}
Note that
execution times with {cmd:statsby} increase exponentially
as the data size increases. 
For large problems, {cmd:rangerun} will be orders of magnitude faster than {cmd:statsby}.


{marker Compared_with_looping}{...}
{pstd}{ul:Compared with looping over observations}

{pstd}
You can loop over each observation to calculate statistics based on
other observations.
The following calculates a regression on a rolling window of 7 years
(including the current observation) and stores
the constant term.
A minimum of 4 observations is required

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared2looping}{...}
	clear all
	webuse grunfeld
	
	local nobs = _N
	gen alpha = .
	quietly forvalues i = 1/`nobs' {
	  capture regress invest kstock if company == company[`i'] & ///
	      inrange(year, year[`i']-6, year[`i'])
	  if _rc == 0 & e(N) >= 4 replace alpha = _b[_cons] in `i'
	}
	
	program myprog
	  if _N < 4 exit
	  regress invest kstock
	  gen alpha_rr = _b[_cons]
	end
	rangerun myprog, interval(year -6 0) by(company)
	
	assert alpha == alpha_rr
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run compared2looping using rangerun.sthlp:click to run})}

{pstd}
Note that when looping over all observations,
execution times increase exponentially as the data size increases. 
For large problems, {cmd:rangerun} will be orders of magnitude faster than looping.



{marker weighted_regression}{...}
{title:Extended example: weighted regression over a rolling window}

{pstd}
Let's say that you need to perform a weighted regression
using a 5-year rolling window that includes the current observation.
The weights are 1 for the most distant observation and increase
by 1 up to 5 for the current observation.


{pstd}
{ul:Step 1: How to target the observations in range}

{pstd}
With a rolling window problem, the subset of observations in the
current window changes from one observation to the next.
This means that results are specific to each observation
and must be calculated separately.
Let's say that we chose to calculate results for observation 50
in the data. 
We could identify the subset of relevant observations
this way:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step1a}{...}
	webuse grunfeld, clear
	list in 46/50
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step1a using rangerun.sthlp:click to run})}

{pstd}
But this will not work if there are gaps in the data. Further, it is not
a good approach if the regression needs to be carried out within a panel.
A better way is to use {help subscripting:explicit subscripting}
to construct a condition that ensures that the company is the
same and that the year is within the desired 5-year window. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step1b}{...}
	webuse grunfeld, clear
	list if company == company[50] & inrange(year, year[50]-4, year[50])
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step1b using rangerun.sthlp:click to run})}


{pstd}
{ul:Step 2: Calculate results using the observations in range for observation 50}

{pstd}
Since we don't need the other observations to do this,
the simplest solution is to reduce the data in memory 
to the observations in the subsample for observation 50.
The weights are then easy to generate: these match
the number of each observation (see {help _variables}).
The {help regress} command supports {help weights} so
all we need is to specify the desired regression.
Since {cmd:rangerun} will collect results from new variable(s),
using the values from the last observation in memory, we store
the desired results that way.
Note that we store {hi:_b[mvalue]} in all observations
while we store {hi:_b[_cons]} only in the last observation
in memory (see {help in:help in}).
While it appears wasteful to generate {hi:b_mvalue} this way,
it is faster than how {hi:b_cons} is generated since 
Stata must evaluate the {help in} condition.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step2}{...}
	webuse grunfeld, clear
	keep if company == company[50] & inrange(year, year[50]-4, year[50])
	
	gen long myweight = _n
	regress invest mvalue [aw=myweight]
	gen b_mvalue = _b[mvalue]
	gen b_cons = _b[_cons] in l
	
	list
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step2 using rangerun.sthlp:click to run})}


{pstd}
{ul:Step 3: Construct a program to perform the task}

{pstd}
Now that we have determined the set of commands needed to generate
results for one observation, we enclose these commands in a
Stata program. 
This program can then be called on any subsample and will generate
the desired results for that subsample.
There is nothing special about this program: it does nothing but  
run the exact same commands we detailed above.

{pstd}
Here is the same example as above, with the commands embedded in
a Stata program.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step3}{...}
	clear all
	webuse grunfeld
	keep if company == company[50] & inrange(year, year[50]-4, year[50])
	
	* define the program and include all desired commands
	program my_rw_reg
	  gen long myweight = _n
	  regress invest mvalue [aw=myweight]
	  gen b_mvalue = _b[mvalue]
	  gen b_cons = _b[_cons] in l
	end
	
	* run the program
	my_rw_reg
	
	list
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step3 using rangerun.sthlp:click to run})}


{pstd}
{ul:Step 4: Make a practice run using rangerun}

{pstd}
Before trying to perform the task on the whole dataset, it would be
prudent to run a test on a small subset of the data.
The interval to use mimics the one we determined in step 1.
Since these regressions are done within panels, we
specify the {hi:by(company)} option.
As with most Stata commands, you can restrict the sample
used by {cmd:rangerun} using an {help if} condition.
Since we have focused on observation 50 so far, we
limit the sample to company 3 and stop in 1944, the
year in observation 50.
By default, {cmd:rangerun} will suppress all output
generated by the commands in {hi:my_rw_reg}.
Since this is a test run on just a small subset of the
data, we also specify the {opt verbose} option to get a good sense
of what is happening.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step4}{...}
	clear all
	webuse grunfeld
	
	* define the program and include all desired commands
	program my_rw_reg
	  gen long myweight = _n
	  regress invest mvalue [aw=myweight]
	  gen b_mvalue = _b[mvalue]
	  gen b_cons = _b[_cons]
	end
	
	rangerun my_rw_reg if company == 3 & year <= 1944, ///
		interval(year -4 0) by(company) verbose
	
	list if company == 3 & year <= 1944
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step4 using rangerun.sthlp:click to run})}

{pstd}
Naturally, the first years of a panel have fewer observations than
the specified 5 year window. This leads to an
error of insufficient observations for the first year.
If there were gaps in the data, this could also occur
at any point in the time series.
It is interesting to note that {cmd:rangerun}
does not stop when there's an error within {cmd:my_rw_reg},
but simply moves on to the next window without recording 
any results.

{pstd}
Since {cmd:my_rw_reg} will run as many times as there
are observations in the sample, it makes sense to reduce
the amount of work it does as much as possible. 
If we are only interested in results from a window with
a full complement of years, we can simply exit the program
if that's the case. 
Similarly, we can restrict which variables to
load before running {cmd:my_rw_reg}, saving the extra
overhead required to populate the dataset with variables
that will not be used.
Finally, we notice that the {hi:myweight} variable
is returned because it is a new variable, created by
the {cmd:my_rw_reg} program.
We don't want it, so we perform some housekeeping at
the end of the program.

{pstd}
So a retooled version of the test run would be:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step4b}{...}
	clear all
	webuse grunfeld
	
	* define the program and include all desired commands
	program my_rw_reg
	  if _N < 5 exit
	  gen long myweight = _n
	  regress invest mvalue [aw=myweight]
	  gen b_mvalue = _b[mvalue]
	  gen b_cons = _b[_cons]
	  drop myweight
	end
	
	rangerun my_rw_reg if company == 3 & year <= 1944, ///
		interval(year -4 0) by(company) use(invest mvalue) verbose
	
	list if company == 3 & year <= 1944
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step4b using rangerun.sthlp:click to run})}

{pstd}
If you scroll back up to step 2 and run the example, you'll see
that we match the results we calculated for observation 50.


{pstd}
{ul:Step 5: Run rangerun on the whole sample}

{pstd}
Once you are satisfied that {cmd:my_rw_reg} produces the
results you want and that the interval is correctly specified,
you can go ahead and make a run for the whole sample.
You need to remove the {opt verbose} option to suppress output
and to remove the condition used for the test run.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - rw_step5}{...}
	clear all
	webuse grunfeld
	
	* define the program and include all desired commands
	program my_rw_reg
	  if _N < 5 exit
	  gen long myweight = _n
	  regress invest mvalue [aw=myweight]
	  gen b_mvalue = _b[mvalue]
	  gen b_cons = _b[_cons]
	  drop myweight
	end
	
	rangerun my_rw_reg, interval(year -4 0) by(company) use(invest mvalue)
	
	list in 50
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run rw_step5 using rangerun.sthlp:click to run})}


{title:Additional examples}


{marker Controlling_the_sample}{...}
{pstd}
{ul:Controlling the sample: Median salary of non-teammates}

{pstd}
The following example constructs a dataset
of 10 teams, each with 15 years of salary data for
their 20 players.
Then it creates an instrument consisting of 
the median annual salary of players from other teams.

{pstd}
The {hi:by(year)} option is specified because the median is to be calculated
using the observations in the same {hi:year}.

{pstd}
The {it:keyvar} for the interval is {hi:teamID}
(chosen here because it has no missing values)
and when both {it:low} and {it:high} bounds are missing, 
all observations will be selected.
But since the instrument is constant per team and year, 
we can speed up the calculation by designating one player per
{hi:teamID year} group and call the {cmd:median_exclude} program
only for this representative player.
The example sets the {it:high} bound to -1 for other players
and since there are no observations where {hi:teamID} is between 
minus infinity and -1, these repeat observations will be ignored.

{pstd}
The {cmd:median_exclude} program needs to know which team the
designated player belongs to. 
The {hi:sprefix(rr_)} option tells {cmd:rangerun} to create
scalars using the values for the current observation.
Each scalar is named by combining the prefix string with the
variable name.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - median_salary3}{...}
	clear all
	set seed 32424
	set obs 10
	gen teamID = _n
	expand 15
	bysort teamID: gen year = 1999 + _n
	expand 20
	bysort teamID year: gen player = _n
	gen salary = runiform()
	
	* define the program; scalars with the values for current obs start with rr_
	program median_exclude
	  sum salary if teamID != rr_teamID, detail
	  gen double med_others = r(p50)
	end
	
	* the first player per group is the designated player, -1 for others
	by teamID year: gen high = cond(_n==1, ., -1)
	rangerun median_exclude, by(year) interval(teamID . high) use(salary teamID) sprefix(rr_)
	
	* carry over the results to non-designated players
	by teamID year: gen median_ot = med_others[1]
	
	* spot check for observation 100
	sum salary if teamID != teamID[100] & year == year[100], detail
	list in 100
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run median_salary3 using rangerun.sthlp:click to run})}


{pstd}
The example above was inspired by 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1384241-generating-a-variable-for-median-salary-of-non-team-mates":this post}
on Statalist.


{marker Controlling_the_sample}{...}
{pstd}
{ul:Collation and comparison of various measures of distribution skew}

{pstd}{cmd:summarize, detail} yields moment-based skewness directly as
the r-class result {cmd:r(skewness)} and allows calculation of some
other measures from its results.  75, 50 and 25% percentiles or
quantiles (upper quartile, median and lower quartile) allow calculation
of 
{cmd:[(p75 - p50) - (p50 - p25)] / [p75 - p25]}. 
Mean, median and SD appear in {cmd:(mean - p50) / sd}. Both measures
must lie within [-1, 1]. Notation here reflects Stata's notation for
saved results such as {cmd:r(p75)}. 

{pstd}A further measure based on L-moments comes from a program
{cmd:lmoments} (click 
{stata ssc install lmoments:here}
to install from SSC). 
See its {help lmoments:help} for explanation. 

{pstd}For a skewness program there is no loss in insisting on a minimum
sample size of 3. There is no information on skewness in samples of size
1, while even if a sample of size 2 includes two distinct values,
skewness measures are either undefined or identically zero. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - skewness}{...}
	clear all
	program myskew 
	  su mvalue, detail  
	  if r(N) < 3 exit
	  gen skewness = r(skewness) 
	  gen mmskew = (r(mean) - r(p50)) / r(sd)
	  gen qskew = (r(p75) - 2 * r(p50) + r(p25)) / (r(p75) - r(p25))
	  lmoments mvalue, short  
	  gen t3skew = r(t_3) 
	end

	webuse grunfeld
	rangerun myskew, interval(year -9 0) use(mvalue year) by(company)
	list if company == 1
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangerun_run skewness using rangerun.sthlp:click to run})}


{title:References}

{pstd}
Cox, N.J. 2007. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0033":Events in intervals.} 
{it:Stata Journal} 7: 440{c -}443. 

{pstd}
Cox, N.J. 2009. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0046":Rowwise.} 
{it:Stata Journal} 9: 137{c -}157. 

{pstd}
Cox, N.J. 2010. 
{browse "http://www.stata-journal.com/article.html?article=st0204":The limits of sample skewness and kurtosis.}
{it:Stata Journal} 10: 482{c -}495. 

{pstd}
Cox, N.J. 2011. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0055":Compared with ....} 
{it:Stata Journal} 11: 305{c -}314. 

{pstd}
Cox, N.J. 2014. 
{browse "http://www.stata-journal.com/article.html?article=dm0075":Self and others.} 
{it:Stata Journal} 14: 432{c -}444. 


{title:Acknowledgements}

{pstd}
Several members of Statalist helped directly and indirectly by posting 
challenging problems. 


{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}

{pstd}Nicholas J. Cox, Durham University, U.K.{p_end}
{pstd}n.j.cox@durham.ac.uk{p_end}


{title:Also see}

{psee}
Stata:  
{help egen}, 
{help rolling}, 
{help statsby}, 
{help tssmooth}, 
{help tsvarlist}, 
{help tsrevar}
{p_end}

{psee}
SSC:  
{stata "ssc desc rangejoin":rangejoin}, 
{stata "ssc desc tsegen":tsegen}, 
{stata "ssc desc mvsumm":mvsumm}, 
{stata "ssc desc rollstat":rollstat}, 
{stata "ssc desc egenmore":egenmore}
{p_end}
