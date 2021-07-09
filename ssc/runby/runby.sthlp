{smcl}
{* *! version 1.0.0  04oct2017}{...}
{vieweralsosee "ssc describe rangestat" "net describe http://fmwww.bc.edu/repec/bocode/r/rangestat"}{...}
{vieweralsosee "ssc describe rangerun" "net describe http://fmwww.bc.edu/repec/bocode/r/rangerun"}{...}
{vieweralsosee "ssc describe rangejoin" "net describe http://fmwww.bc.edu/repec/bocode/r/rangejoin"}{...}
{vieweralsosee "ssc describe filelist" "net describe http://fmwww.bc.edu/repec/bocode/f/filelist"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] by" "help by"}{...}
{vieweralsosee "[D] egen" "help egen"}{...}
{vieweralsosee "[D] statsby" "help statsby"}{...}
{vieweralsosee "[D] joinby" "help joinby"}{...}
{viewerjumpto "Syntax" "runby##syntax"}{...}
{viewerjumpto "Description" "runby##description"}{...}
{viewerjumpto "Options" "runby##options"}{...}
{viewerjumpto "When to use" "runby##when_to_use"}{...}
{viewerjumpto "Basic functionality" "runby##basic_functionality"}{...}
{viewerjumpto "Example: panel-specific regression" "runby##panel_regression"}{...}
{viewerjumpto "Example: partitioning a file into subfiles" "runby##partitioning"}{...}
{viewerjumpto "Example: case-control pairing" "runby##case_control"}{...}
{viewerjumpto "Example: compared with statsby" "runby##Compared_with_statsby"}{...}
{viewerjumpto "Example: finding the nearest neighbors within by-group" "runby##geonearby"}{...}
{viewerjumpto "Acknowledgements" "runby##acknowledgements"}{...}
{viewerjumpto "Authors" "runby##authors"}{...}
{viewerjumpto "Also see" "runby##alsosee"}{...}

{title:Title}

{phang}
{cmd:runby} {hline 2} Run Stata commands on by-groups of observations


{title:Syntax}

{p 8 17 2}
{cmd:runby} 
{it:program_name} 
{cmd:,} 
{opth by(varlist)}
[
{opt v:erbose}
{opt u:seappend}
{opt s:tatus}
{opt a:llocate(#)}
]


{marker Description}{...}
{title:Description}

{pstd}
{cmd:runby} loops over data by-groups. 
At each pass, the data in memory is filled with a by-group's
observations and {it:program_name} is executed. 
What's left in memory when {it:program_name} terminates
is considered results and stored. 
Once all by-groups have been processed, all stored results are
combined and replace the data in memory.

{pstd}
A by-group is a subset of the initial data in memory and includes all
observations with the same value for the variables in {varlist}.
There is no overlap between by-groups and all observations fall into
one of the by-groups (missing values in {varlist} count as a distinct
value).

{pstd}
{it:program_name} is a Stata program that has been previously defined.
It contains all the commands that you want to run on each by-group
data subset.

{pstd}
{cmd:runby} makes no assumptions about what's left in memory when
{it:program_name} terminates. 
You can create new variables, drop any or all variables, add or remove
observations.
It's OK if the program terminates with no data in memory.
If {it:program_name} terminates with an error, {cmd:runby} discards
what's left in memory and stores nothing for the by-group.

{pstd}
By default, {cmd:runby} uses {help Mata} to do its thing because it is
very fast at moving data around.
The downside is that it requires extra memory to store a copy of the
initial data and to store results.

{pstd}
If the {opt u:seappend} option is specified, only Stata commands are
used. 
The initial data in memory is saved to a temporary file and Stata's
{help use} command with an appropriate {help in} qualifier is used to
load each by-group subset.
Results are stored in temporary files and {help append} is used to
combine them all.
The Stata-only machinery minimizes the amount of memory needed but all
these file operations have definite an impact on execution time.

{pstd}
When accumulating results from by-groups, if a
variable changes from string to numeric (or vice versa) across
by-groups, missing values will be stored for by-groups that are
inconsistent with the initial variable type.


{marker options}{...}
{title:Options}

{dlgtab:Options}

{phang}{opth by(varlist)} is required. 
The variable(s) define the by-groups.

{phang}{opt v:erbose} specifies that the output from {it:program_name}
is not suppressed. 

{phang}{opt u:seappend} specifies that all operations be done using
Stata-only (no {help Mata}) commands. 

{phang}{opt s:tatus} causes status reports to be printed in the
{hi:Results} window at regular intervals.

{phang}{opt a:llocate(#)} specifies an initial number of observations
for the dynamic arrays used to store accumulated results in 
{help Mata}.
{cmd:runby} initially allocates enough space to accomodate one
observation per group. 
{cmd:runby} will automatically grow the arrays when needed and will
wait until 10 by-groups have been processed before making a projection
based on the number of observations saved so far, the number of
by-group observations processed at that point and the total number of
initial observations.
Use this option if you are concerned that this projection may request
an excessive amount of memory because the first 10 groups are not
representative.
This option is ignored if the {opt u:seappend} option is specified.


{marker when_to_use}{...}
{title:When to use runby}

{pstd}
Stata is most efficient when it performs calculations on all
observations in one swoop.
Do not expect {cmd:runby} to outperform calculations made with the
{help by:by:} prefix used in conjunction with {help generate}, 
{help replace}, or {help egen} because once the data is sorted by groups,
results are generated for all observations in one pass.

{pstd}
{cmd:runby} is for problems where each group needs to be treated
separately.  Such problems are typically addressed by looping over by-groups.
The challenge with such problems is how to efficiently target by-group
data subsets and store results.
See below for a few fully worked out examples of useful and efficient
ways to use {cmd:runby}.


{marker basic_functionality}{...}
{title:Basic functionality}

{pstd}
The following example creates a demonstration dataset containing
lower priced cars and saves it in the current directory:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - runby_data_demo}{...}
	sysuse auto, clear
	keep if price < 4000
	keep make-rep78 foreign
	sort make
	list
	save "runby_data_demo.dta", replace
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run runby_data_demo using runby.sthlp:click to run})}

{pstd}
The mechanics of {cmd:runby} are quite simple: put the code you want
to run in a Stata program and call {cmd:runby}.
{cmd:runby} does not pass any arguments to your program and any 
{help return:stored results} in {hi:r()}, {hi:e()}, and {hi:s()} are ignored.
If you want to save results, you store them in regular Stata variables.

{pstd}
It's a good idea to start a do-file with a {help clear all}
statement.
To define a new program, your start with a {cmd:program} statement
followed by the name you want to use.
The program ends with and {cmd:end} statement.
The following {cmd:my_first_program} program calculates the mean repair record
and the number of non-missing values of {hi:rep78}.
Each time {cmd:my_first_program} is called, it will run on
a different by-group data subset.
The {opt verbose} option is used so that you can see the output
from commands within {cmd:my_first_program}
in the {cmd:results} window.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - basic1}{...}
	clear all

	program my_first_program
	  summarize rep78, meanonly
	  gen mrep78   = r(mean)
	  gen mrep78_N = r(N)
	  list
	end
	
	use "runby_data_demo.dta"
	runby my_first_program, by(foreign) verbose
	list, sepby(foreign)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run basic1 using runby.sthlp:click to run})}

{pstd}
When {cmd:runby} is done, the accumulated data (if any) is ordered by groups.
The order within by-groups follows the data order when {cmd:runby} was called.

{pstd}
The following repeats the example but this time reduces the data to
one observation per by-group and replaces the content of {hi:rep78}
with the mean:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - basic2}{...}
	clear all
	
	program my_first_program
	  summarize rep78, meanonly
	  replace rep78 = r(mean)
	  gen mrep78_N  = r(N)
	  keep foreign rep78 mrep78_N
	  keep in 1
	end
	
	use "runby_data_demo.dta"
	runby my_first_program, by(foreign) verbose
	list
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run basic2 using runby.sthlp:click to run})}


{marker panel_regression}{...}
{title:Example: panel-specific regression}

{pstd}
The following example carries out a regression for each panel of a
longitudinal data set.
This approach could apply to problems that involve calculating a
separate "beta" for each stock in a portfolio, or estimating a linear
trend rate for each person in a cohort.

{pstd}
It's always a good idea to make a test run first by starting with a
small number of groups and use the {opt verbose} option:

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - panel_reg1}{...}
	clear all

	program define my_regress
	  regress ln_wage c.tenure i.union
	  gen long nobs = e(N)
	  foreach x in b se {
	    gen `x'_tenure = _`x'[tenure]
	    gen `x'_union  = _`x'[1.union]
	  }
	end
	
	webuse nlswork
	keep if idcode < 5
	runby my_regress, by(idcode) verbose
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run panel_reg1 using runby.sthlp:click to run})}

{pstd}
After running the example above, you see that {cmd:runby} reports that
the program terminated with an error for one by-group.
Scanning the output, we see one case where {hi:1.union} is omitted.
The first {cmd:generate} statement that tries to save a return for
{hi:1.union} generates an error and that stops the program.
Since the program terminated with an error, no results are saved for
that by-group.

{pstd}
One solution is to use {cmd:capture} to absorb the error(s) and let
the program continue on. 
If you tried again on more by-groups, you would see that the
program terminates in error when there is not enough observations
to run the regression.
Again, the solution is the same, use {cmd:capture} to absorb the error
and use {help exit_program:exit} to leave the program.
Since this takes a bit of time to run, the {opt s:tatus} option
is used to get progress reports.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - panel_reg2}{...}
	clear all

	program define my_regress
	  capture regress ln_wage c.tenure i.union
	  if _rc exit
	  gen long nobs = e(N)
	  foreach x in b se {
	    capture gen `x'_tenure = _`x'[tenure]
	    capture gen `x'_union  = _`x'[1.union]
	  }
	end
	
	webuse nlswork
	runby my_regress, by(idcode) status
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run panel_reg2 using runby.sthlp:click to run})}

{pstd}
Now {cmd:runby} reports no error and results appear for all by-groups,
with missing values when measures could not be calculated.


{marker partitioning}{...}
{title:Example: partitioning a file into subfiles}

{pstd}
Stata does not have a command to save data subsets as separate files.  
But it is often useful to break up a large data set into smaller ones,
one for each distinct value of a {help varlist}.  
For example, a European data set might be profitably partitioned into
country-specific data sets.

{pstd}
The following breaks-up the {hi:auto} dataset by distinct values of
{hi:foreign rep78}.
We save each by-group subset using a filename that includes the value
of each variable that defines the by-group.
We pick the values from the first observation but that does not really
matter since all observations have the same value for these by-group
variables.

{pstd}
We do not need {cmd:runby} to store what was just saved so all
observations are dropped.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - partition}{...}
	clear all
	
	program define split_file
	  local f = foreign[1]
	  local r = rep78[1]
	  save "auto_foreign`f'_rep`r'.dta", replace
	  drop _all
	end

	sysuse auto
	runby split_file, by(foreign rep78) verbose
	dir auto*
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run partition using runby.sthlp:click to run})}

{pstd}
You can even use {hi:runby} to do the inverse, that is combine data
from separate files.
The following uses {cmd:filelist}
(from SSC, {stata ssc install filelist:click here to install})
to create a dataset of filenames.
As used in the following example, {cmd:filelist} captures all the
files in the current directory and the next command prunes the list to
the datasets created in the example above.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - combine}{...}
	clear all
	
	program define recombine
	  local f = filename[1]
	  use "`f'", clear
	  gen source = "`f'"
	end

	filelist , norecur
	keep if strpos(filename, "auto_foreign") == 1
	runby recombine, by(filename) verbose
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run combine using runby.sthlp:click to run})}

{pstd}
For convenience, we reused the datasets created in the previous
example but the approach can easily be extended to import and
combine data in any format (xls, tab or csv delimited, etc.).
Note that {cmd:filelist} can scan directories recursively so you can
combine data even when files are stored in multiple sub-directories,
even many levels deep.


{marker case_control}{...}
{title:Example: case-control pairing}

{pstd}
In this example we begin by creating a demonstration data set of 10,000
cases and 40,000 potential matched controls divided among 7 study
sites.  
The goal is to assign to each case three randomly selected controls,
matched exactly on {hi:sex} and {hi:site}, and agreeing on {hi:age} to
within 5 years, and body mass index ({hi:bmi}) to within 2.5 kg/m2.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - case_control_ex1}{...}
	clear all
	set obs 50000
	gen long id = _n
	label define case 0 "Control" 1 "Case"
	gen byte case:case = _n <= _N/5

	//	ASSIGN STUDY SITE, RANDOM SEX, AGE, BODY MASS INDEX, 
	gen byte site = mod(_n, 7)
	set seed 1234
	gen byte sex = runiform() < 0.5
	gen int age = rpoisson(45)
	gen bmi = rgamma(30, 1)
	save "runby_case_control.dta", replace
	tab case
	tab site sex
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run case_control_ex1 using runby.sthlp:click to run})}

{pstd}
Since we are matching exactly on {hi:sex} and {hi:site}, we can use
{cmd:runby} to run our {cmd:matchem} program on data subsets that have
the same values for {hi:sex} and {hi:site}.
For each by-group, the {cmd:matchem} program starts by splitting the
data into cases and controls.
Then {cmd:rangejoin} is used to form all case-control pairs with ages
differing by at most 5 years.  
This is followed by a {cmd:keep} command to reduce the data to only
those observations which also have {hi:bmi} differing by at most 
2.5 kg/m2.  
Finally, from the surviving pairings, 3 are selected at random.  
This requires {cmd:rangejoin} 
(from SSC, {stata ssc install rangejoin:click here to install})
and 
{cmd:rangestat} 
(also from SSC, {stata ssc install rangestat:click here to install})

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - case_control_ex2}{...}
	clear all

	program define matchem
	  summarize
	  
	  // split cases and controls
	  tempfile controls copy
	  quietly save `copy'
	  keep if case == 0
	  drop case 
	  quietly save `controls'
	  use `copy', clear
	  keep if case == 1
	  drop case
	  
	  rangejoin age -5 5 using `controls', prefix(cntrl_)
	  keep if inrange(bmi - cntrl_bmi, -2.5, 2.5)
	  
	  // randomize and pick the first 3
	  gen double shuffle = runiform()
	  by id (shuffle), sort: keep if _n <= 3
	  drop shuffle*
	end
	
	use "runby_case_control.dta", clear
	runby matchem, by(site sex) verbose
	
	assert sex == cntrl_sex
	assert site == cntrl_site
	assert abs(age - cntrl_age) <= 5
	assert abs(bmi - cntrl_bmi) <= 2.5
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run case_control_ex2 using runby.sthlp:click to run})}

{pstd}
Note that if the dataset is small, you can perform the same task as
above using {bind:{cmd:rangejoin ..., by(sex site)}} to find all
matches within the desired range for {hi:age} and then further reduce
the data with matches that are within range for {hi:bmi}.
But this requires having enough memory to hold all pairings within
range for {hi:age} for all by-groups first.

{pstd}
With {cmd:runby}, you only need to hold on to pairings formed within a single
{hi:site sex} by-group.
Once all by-groups have been processed, you will have formed exactly the same
pairings as if you had tried to do all groups at once using {cmd:rangejoin}.

{pstd}
Generally, any task that requires forming all pairwise combinations by
group ({cmd:joinby}, {cmd:rangejoin}) followed by a further pairing
down can benefit from using {cmd:runby}.


{marker Compared_with_statsby}{...}
{title:Example: compared with statsby}

{pstd}
Everything that can be done with {cmd:statsby} can also be done with
{cmd:runby}. The following replicates the last example in
{cmd:statsby}'s {help statsby:help file}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - compared2statsby}{...}
	clear all
	sysuse auto
	statsby mean=r(mean) sd=r(sd) size=r(N), by(rep78):  summarize mpg
	list
	
	program myprog
	  sum mpg
	  gen mean = r(mean)
	  gen sd = r(sd)
	  gen size = r(N)
	  keep in 1
	  keep make rep78 mean sd size
	end
	
	sysuse auto, clear
	runby myprog, by(rep78)
	list if !mi(rep78)
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run compared2statsby using runby.sthlp:click to run})}

{pstd}
{cmd:runby} offers several advantages over {cmd:statsby}.  
Most prominent, in large data sets, {cmd:runby} is faster. 
An occasional problem encountered with {cmd:statsby} is that before
doing by-group calculations, it runs the command on the entire data
set.  
For some commands, the full data set is not an acceptable input for
the command, in which case {cmd:statsby} halts with an error message.  
{cmd:runby} does not do this.
Also, if a by-group does not produce valid results, your program will
generate an error and {cmd:runby} will simply move on to the next
by-group.


{marker geonearby}{...}
{title:Example: finding the nearest neighbors within by-groups}

{pstd}
Say you have data on stores, including geographic coordinates
(lat/lon) and business category and you want to find the nearest store
in the same category.
You can use {cmd:geonear} 
(from SSC, {stata ssc install geonear:click here to install})
to find the nearest store overall but you would have to do a fair
amount of data management gymnastics to do it by category by-groups.
Here's a small example that shows how to do this with {cmd:runby}.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - exgeonearby}{...}
	clear all
	set seed 123456
	set obs 2000
	gen long storeid = _n
	gen double lat = 37 + (41 - 37) * uniform()
	gen double lon = -109 + (109 - 102) * uniform()
	gen category = int(runiform()*100)
	gen x = runiform()
	save "runby_store_data.dta", replace
	
	program myprog
	  // save a copy of the stores in this category
	  tempfile f
	  save "`f'"
	  
	  rename storeid storeid0
	  rename category category0
	  rename x x0
	  geonear storeid0 lat lon using "`f'", n(storeid lat lon) ignoreself
	end
	
	runby myprog, by(category)
	
	// merge to get nearest neighbor variables
	rename nid storeid
	merge m:1 storeid using "runby_store_data.dta", keep(master match) nogen
	sort storeid0 km_to_nid storeid
	
	list storeid0 x0 km_to_nid storeid x if category == 10
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run exgeonearby using runby.sthlp:click to run})}

{pstd}
It's always a good idea to spot check the results to make sure that
you set up your commands correctly. 
The following uses a brute force approach to calculate the distance
between all stores in category 10.
This requires {cmd:geodist} 
(from SSC, {stata ssc install geodist:click here to install})

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - exgeonearby10}{...}
	use if category == 10 using "runby_store_data.dta", clear
	tempfile cat10
	save "`cat10'"
	
	rename storeid storeid0
	rename category category0
	rename x x0
	rename lat lat0
	rename lon lon0
	
	// form all pairwise combinations of stores
	cross using "`cat10'"
	
	// calculate the distance, drop distance to self, and keep closest neighbor
	geodist lat0 lon0 lat lon, gen(d) sphere
	drop if storeid0 == storeid
	bysort storeid0 (d storeid): keep if _n == 1
	list storeid0 x0 d storeid x
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata runby_run exgeonearby10 using runby.sthlp:click to run})}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Thanks to M.B. Ross for his Statalist question on how to efficiently
partition a large dataset. 


{marker authors}{...}
{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}

{pstd}Clyde Schechter, Albert Einstein College of Medicine{p_end}
{pstd}clyde.schechter@einstein.yu.edu{p_end}


{marker alsosee}{...}
{title:Also see}

{psee}
Stata:  
{help by}, 
{help egen}, 
{help statsby}, 
{help joinby}
{p_end}

{psee}
SSC:  
{stata "ssc desc rangestat":rangestat},
{stata "ssc desc rangerun":rangerun}, 
{stata "ssc desc rangejoin":rangejoin},
{stata "ssc desc filelist":filelist}
{p_end}
