{smcl}
{hline}
{hi:help simulate2}{right: v. 1.01 - 03. November 2019}
{hi:help psimulate2}{right: v. 1.03 - 27. February 2020}
{hline}
{title:Title}

{p 5 4}{cmd:simulate2} - enhanced functions for {help simulate}.{p_end}
{p 4 4}{cmd:psimulate2} - running {cmd:simulate2} in parallel.{p_end}

{title:Syntax}

{p 9 17 2}
{cmd:simulate2}
        [{it:{help exp_list}}]
        {cmd:,} {opt r:eps(#)} [{it:options1 options2}]
        {cmd::} {it:command}
{p_end}

{p 8 17 2}		
{cmd:psimulate2} [{it:{help exp_list}}]
        {cmd:,} {opt r:eps(#)} {cmdab:p:arallel(}{it:#2, options3}{cmd:)} [{it:options2}]
        {cmd::} {it:command}

{synoptset 25}{...}
{synopt:{it:options1}}Description{p_end}
{synoptline}
{synopt:{opt nodots}}suppress replication dots{p_end}
{synopt :{opt dots(#)}}display dots every {it:#} replications{p_end}
{synopt:{opt noi:sily}}display any output from {it:command}{p_end}
{synopt:{opt tr:ace}}trace {it:command}{p_end}
{synopt:{opt nol:egend}}suppress table legend{p_end}
{synopt:{opt v:erbose}}display the full table legend{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 25}{...}
{synopt:{it:options2}}Description{p_end}
{synoptline}
{synopt:{help prefix_saving_option:{bf:{ul:sa}ving(}{it:filename}{bf:, ...)}}}save
        results to {it:filename}{p_end}
{synopt:{opt seed(options)}}control of seed, see {help simulate2##optionsSeed: seed options}{p_end}
{synopt:{opt seeds:ave(options)}}saves the used seeds, see {help simulate2##SeedSaving: saving seeds}{p_end}
{synopt:{opt seedstream(integer)}}starting seedstream, only {cmd:psimulate2}{p_end}
{synoptline}
{p2colreset}{...}	
		
{synoptset 25}{...}
{synopt:{it:options3}}Description{p_end}
{synoptline}
{synopt:{opt exe(string)}}sets the path to the Stata.exe{p_end}
{synopt:{opt temppath(string)}}alternative path for temporary files{p_end}
{synopt:{opt proc:essors(string)}}max number of processors, only for Stata MP{p_end}
{synopt:{opt simulate}}use {help simulate} rather than {cmd:simulate2}. 
If {cmd:psimulate2} is run on Stata 15 then {help simulate} is automatically used. {p_end}
{synoptline}
{p2colreset}{...}


{p 4 6 2}
All weight types supported by {it:command} are allowed; see {help weight}.
{opt simulate2} uses {help frames} and requires Stata 16 or higher. 
{opt psimulate2} requires Stata 15 or higher. 
{opt psimulate2} works on MacOS, Microsoft Windows and Unix systems.
{p_end}

{p 4 6 2}
{cmd:#} is the number of repetitions and {cmd:#2} the number of parallel Stata instances.
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt simulate2} eases the programming task of performing Monte Carlo-type
simulations.  Typing

{pin}
{cmd:. simulate2} {it:{help exp_list}}{cmd:, reps(}{it:#}{cmd:)} {cmd::} {it:command}

{pstd}
runs {it:command} for {it:#} replications and collects the results in
{it:exp_list}.

{pstd}
{it:command} defines the command that performs one simulation.
Most Stata commands and user-written programs can be used with
{opt simulate2}, as long as they follow {help language:standard Stata syntax}.
The {opt by} prefix may not be part of {it:command}.

{pstd}
{it:{help exp_list}} specifies the expression to be calculated from the
execution of {it:command}.
If no expressions are given, {it:exp_list} assumes a default, depending upon
whether {it:command} changes results in {opt e()} or {opt r()}.  If
{it:command} changes results in {opt e()}, the default is {opt _b}.  If
{it:command} changes results in {opt r()} (but not {opt e()}), the default is
all the scalars posted to {opt r()}.  It is an error not to specify an
expression in {it:exp_list} otherwise.

{pstd}
{opt simulate2} is an extension (or "hack") of the Stata build-in {help simulate} command.
It extends the command by allowing programs to return macros ({it:strings}) to 
{opt e()} or {opt r()}. 
To do so it uses {help frame post} rather than {help postfile}.
The computational costs to return strings are small and
{opt simulate2} is only marginally slower than {help simulate}.

{pstd}
{cmd:simulate2} and {cmd:psimulate2} can save results to frames 
instead of dtas. Frames and .dta can be both appended as well.

{pstd}
{opt simulate2} has advanced options to assign seeds, random number generator states to specific draws of {opt simulate2} and save those.
The {help rngstate:rngstate} (or seed), the {help rng:random number generator}
and the {help rngstream:seed stream} can saved in a separate {it:frame} or
{it:datatset}. 

{pstd}
For an introduction into drawing pseudo random numbers see {help set_rng:set rng}, {help seed} and {help rngstream}.

{pstd}
{cmd:psimulate2} is a parallel version of {cmd:simulate2} speeding up simulations. Typing

{pin}
{cmd:. psimulate2} {it:{help exp_list}}{cmd:, reps(}{it:#}{cmd:) parallel(}{it:}#2{cmd:) :} {it:command}

{pstd}
runs {it:command} for {cmd:#} replication on {cmd:#2} parallel Stata instances and collects 
the results in {it:exp_list}.

{pstd}
{cmd:psimulate2} splits the number of replications into equal blocks and each block
is run on a separate Stata instance. 
To do so {cmd:psimulate2} creates a do file and a batch file. 
The batch file is then used to start a new Stata instance running the corresponding do file.
The running instance is acting as a parent instance, the other are child instances.
The output of {cmd:psimulate2} differs to the one from {cmd:simulate} or {cmd:simulate2}.
It shows the percentage which is done, elapsed time and expected time left and finishing time.

{pstd}
Before a new instance is started {cmd:psimulate2} saves the current data set in memory.
This allows all that all Stata instances start using the same dataset.
It is also able move all programs in memory which are not saved in an ado directory, 
such as programs defined in the do file before calling {cmd:psimulate2}.
Any mata defind functions (see {stata mata mata memory}, {help mata mata memory:help file})
will be moved from the parent to the child instance.
{cmd:psimulate2} will create a new {help mata lmbuild:mlib} file and store it
in the temp folder and then set the temp folder as a new ado path.
Mata matrices are moved from the parent to the child instance and 
are saved in the temp folder.
Globals and not permanently set ado paths are moved as well.
It {bf:{ul:does not}} move frames, locals, matrices (only Stata), scalars (only Stata)
or values saved in e(), r() or s() from the parent to the child instances.

{pstd}
{cmd:psimulate2} uses {help seedstream:seedstreams} if no {cmd:seedstream} is 
defined in option {cmd:seed()}.
In this case each child instance is assigned its own {cmd:seedstream}. 
This ensures that random number draws do not overlap.
Parallel use of {cmd:psimulate2} is possible with different seedstreams for
each machine.
The option {cmd:seedstream()} sets the seedstream for the first instance.

{marker psimLoop}{pstd}
Care is required if {cmd:psimulate2} is used in loops.
If no seed options are set, {cmd:psimulate2} will {ul:{bf:always}} use the 
current Stata seed.
However after {cmd:psimulate2} is completed it {ul:{bf:does not}}
(and cannot) set the seed to the last seed from the simulation.
Therefore random draws will be the same across iterations of the loop.
To avoid this behaviour {cmd:seed(}{it:_current}{cmd:)} saves the last used 
seed in a global. In all consecutive iterations of a loop, the global will be 
picked up, the seed updated for the {cmd:simulate2} runs used and 
after finishing the global will be updated again.
This allows that draws across iterations of a loop differ. 


{marker options}{...}
{title:Options}

{phang}
{opt reps(#)} is required -- it specifies the number of replications to
    be performed.

INCLUDE help dots

{phang}
{opt noisily} requests that any output from {it:command} be displayed.
This option implies the {opt nodots} option.

{phang}
{opt trace} causes a trace of the execution of {it:command} to be displayed.
This option implies the {opt noisily} option.

{phang}
{cmd:saving(}{help filename}{cmd: [, }{it:suboptions}{cmd: frame append])} creates a Stata data file (.dta file) consisting of (for each statistic in exp_list) a variable containing the replicates.

{pmore}
See {it:{help prefix_saving_option}} for details about {it:suboptions}. 
{cmd:simulate2} and {cmd:psimulate2} can save to frames if option {cmd:frame} is used. 
It appends an existing dta or frame if option {cmd:append} is used.

{phang}
{opt nolegend} suppresses display of the table legend.  The table
legend identifies the rows of the table with the expressions they represent.

{phang}
{opt verbose} requests that the full table legend be displayed.  By default,
coefficients and standard errors are not displayed.

{phang}
{opt simulate} requests {cmd:psimulate2} to use {help simulate} rather than {cmd:simulate2}. 
If {cmd:psimulate2} is run on Stata 15 then {help simulate} is automatically used.
If option {cmd:simulate} is used each instance is assigned its own seed stream.

{marker optionsSeed}{phang}
{cmd: seed(}{it:options}{cmd:)} controls the random-number seed. 
It is possible to set a seed, the random number generator and seed stream or
to load all three from either a frame or saved Stata dataset.
Options are:

{pmore}
{cmd:seed(}{bf:{it:#}}{cmd:)}  sets the random-number seed.  Specifying this option is
equivalent to typing the following command before calling {opt simulate}:

{pmore2}
{cmd:. set seed} {it:#}

{pmore2}
or

{pmore2}
{cmd:. simulate  ... , ... seed(#): ...}

{pmore}
If {help simulate} is used in combination with {cmd:psimulate2}, 
then only {cmd:seed(#)} can be set. Seed streams are automatically assigned. 
 
{pmore}
{cmd:seed(}{it:integer1 [string integer3]}{cmd:)} sets the {help seed} ({it:integer1}),
the {help rng:random-number generator} ({it:string})
and the {help seedstream} ({it:integer3}). 
The default for {it:string} is the default random-number generator and for {it:integer3} seedstream number 1.

{pmore2}
{cmd:. simulate2 ..., seed(123 mt64s 6): ...} 

{pmore2}
sets the seed to {it:123}, the {help rng:random-number generator} to {it:mt64s}
and the {help seedstream} to stream number {it:6}. Typing this is equivalent to:

{pmore2}
{cmd:. set rng mt64s}{break}
{cmd:. set seedstream 6}{break}
{cmd:. set seed 123}

{pmore}
{cmd:seed({help frame}|{it:filepath} {it: varname} [{it:varlist}], frame|dta [start(#)])}{break} 
uses either a frame or Stata dataset to load the seeds. 
The name of the frame is specified with {it:frame}, the path and name of the dataset
with {it:filepath}. 
The options {cmd:frame} and {cmd:dta} indicate whether the first argument is 
a filepath or frame. 
{it:varname} is the variable name containing the seed.
The optional argument {it:varlist} contains the name of the variable containing 
the random-number generator and the seedstream.{break}
{cmd:start(#)} allows to start with the #th seed in the frame or dataset.{break}
{cmd:seed(,frame|dta)} requires the same or a higher number of seeds as repetitions set by {cmd:reps(#)}.  
{cmd:seed(,frame|dta)} assumes that the data in the frame or datatset is ordered 
according to the draws. 
This is important if {cmd:simulate2} is applied to a subset of draws and 
results are being compared. 
Options {cmd:frame} and {cmd:dta} cannot be combined.

{pmore2}
{cmd:. simulate2 , reps(100) seed(seedframe seedvar rngvar streamvar , frame start(10)) : ... }

{pmore2}
Uses seeds saved in frame {it:seedframe}.
The {help rngstate} is taken from variable {it:seedvar},
the {help rng:random number generator} from variable {it:rngvar}
and the number of the {help seedstream} from variable {it:streamvar}.
It starts with the 10th observation in frame {it:seedframe} 
for the first draw of the program called by {cmd:simulate2}.
It then continues with observations 11 for draw number 2.


{pmore}
{cmd:seed(}{it:_current}{cmd:)} allows the usage of {cmd:psimulate2} in loops.
It uses the current seed options as a starting seed for {cmd:psimulate2}. 
This allows {cmd:psimulate2} to be nested within loops. 
See {help simulate2##psimLoop: psimulate2 in loops}.


{phang}
{cmd:seedstream(}{it:integer}{cmd:)} is a convience option for {cmd:psimulate2}.
It sets the inital seedstream number for the first instance. 
For example if 3 instances are set ({cmd:parallel(3)}) and 
{cmd:seedstream(4)} is used, then instance 1 will use seed stream number 4,
instance 2 stream 5 and instance 3 stream 6. 
This function allows the parallel use of {cmd:psimulate2} on multiple 
computers with the same starting seed, but different seedstreams.

{phang}{marker SeedSaving}
{cmd:seedsave({it:filename}|{it:frame}), [frame append seednumber(#)]} Saves the seeds from the 
beginning of each draw in a dataset defined by {it:filename}. 
If option {cmd:frame} is used, it saves the seeds in a frame. 
{cmd:append} appends the frame or dataset. 
{cmd:seednumber(#)} specifies the first value of variable {it:run}.
If not specified it is set to 1 and in the case of option {cmd:append} it is set
to {it:_N + 1}.
In all cases, the number of the draw, state of the random number generator, the type and 
the stream are saved in the following variables:

{synoptset 15}{...}
{synopt:Variablename}Description{p_end}
{synoptline}
{synopt:{it:run}}Number of draw, from 1,2,...,reps(#){p_end}
{synopt:{it:seed}}State of random-number generator (seed){p_end}
{synopt:{it:seedstream}}Number of seedstream{p_end}
{synopt:{it:rng}}Type of random number generator{p_end}
{synoptline}
{p2colreset}{...}

{pmore}
The state of the random number generator is a string with approximately 5,000 
characters. Saving 500 seeds requires about 2.4 MB, a restriction 
the user has to bear in mind when saving seeds.{p_end}

{phang}
{cmd:parallel(#2)} sets the number of parallel Stata instances. 
It is advisable not to use more instances than CPU cores are available. 

{phang}
{cmd:parallel(#2, exe(string))} sets the path to the Stata.exe when using {cmd:psimulate2}.
{cmd:psimulate2} will try to find the path, but might fail if Stata.exe
is in a non-conventional folder or has a non-conventional file name.

{phang}
{cmd:parallel(#2, temppath(string))} sets an alternative path to save temporary files.
{cmd:psimulate2} saves several do file and .bat files in the temporary folder
({ccl tmpdir}). 
In rare cases Stata might not have read/write rights or
it is not possible to start a .bat file from this folder. 
In this case {cmd:temppath()} is required.
{cmd:psimulate2} cleans up the temp folder before using it. 
All files starting with {it:psim2_} are removed.

{phang}
{cmd:parallel(#2, processors(integer))} sets the maximum number of processors 
each Stata instance is allowed, see {help set processors}.
This is only relevant for Stata MP. 
For example if Stata MP with 4 cores is used and two parallel instance of {cmd:psimulate2},
then the remaining two cores can be used for each instance. 
The default is 1, meaning that {cmd:psimulate} only one processor is available to
each Stata instance.


{marker SavedValuse}{title:Saved Values}
{pstd}
{cmd:psimulate2} saves the following in {cmd:r()}:

{col 4} Macros
{col 8}{cmd: r(rng_current)}{col 27} The random number generator type of the last run of the last instance. 
{col 8}{cmd: r(rngseed_mt64s)}{col 27} The random number generator seed of the last run of the last instance. 
{col 8}{cmd: r(rngstate)}{col 27} The random number generator state of the last run of the last instance. 


{marker examples}{title:Examples}
{pstd}
Make a dataset containing the OLS coefficient, standard error, the current time
and save the seeds in a frame called {it:seed_frame}. Perform the experiment 1000 times:

	{cmd:program define testsimul, rclass}
		{cmd:version {ccl stata_version}}
		{cmd:syntax anything}
		{cmd:clear}
		{cmd:set obs `anything'}
		{cmd:gen x = rnormal(1,4)}
		{cmd:gen y = 2 + 3*x + rnormal()}
		{cmd:reg y x}
		{cmd:matrix b = e(b)}
		{cmd:matrix se = e(V)}
		{cmd:ereturn clear}
		{cmd:return scalar b = b[1,1]}
		{cmd:return scalar V = se[1,1]}
		{cmd:return local time "`r(current_time)'"}
	{cmd:end}
	{phang}
	{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(1000) saveseed(seed_frame,frame): testsimul 100}
	
{pstd}
Now we can pick up the seeds and re-do the experiment for the first 500 repetitions:

{phang}
{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(500) seed(seed_frame seeds, frame): testsimul 100}

{pstd}
and for the second 500 repetitions the starting seed is set to seed number 501:

{phang}
{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(500) seed(seed_frame seeds, frame start(501)): testsimul 100}

{pstd}
Likewise, we can first do 500 draws, save the seeds, do another 500 draws, append the saved seeds and do the
experiment for all 1000 draws. For comparison results are saved in frames:{p_end}

{p 4 4}
{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(500) seed(123) seedsave(seed_frame, frame) saving(first500, frame): testsimul 100 }{break}
{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(500) seedsave(seed_frame, frame append) saving(second500, frame): testsimul 100 }{break}
{cmd:. simulate2 time = r(time) b = r(b) V = r(V), reps(1000) seed(seed_frame seeds, frame): testsimul 100 }{p_end}

{pstd}
Note that for the second run, no new seed is set and the option {cmd:append} is used. First we
compare the results for the first 500 draws, then for the second 500 draws:{p_end}

{p 4 4}
{cmd:. sum if _n <= 500}{break}
{cmd:. frame first500: sum}{break}
{cmd:. sum if _n > 500}{break}
{cmd:. frame second500: sum}{p_end}

{pstd}
The results of the first two command lines and the second two command lines
are expected to be identical.
{p_end}

{pstd}
Likewise, we can parallelise the simulation from above. For example we want to 
run two instances at the same time, i.e. instance 1 runs the first 500, instance
2 the second 500 repetitions:

{p 4 4}
{cmd:. psimulate2 , reps(500) seed(123) parallel(2, temppath("C:\psim2_temp")): testsimul 200}
{p_end}

{pstd}
{cmd:parallel(2, temppath("C:\LocalStore\jd71\temp"))} sets two parallel instances.
{cmd:temppath()} specifies the path temporary files are saved to. 
This option is only necessary if Windows does not allow to run batch files from
the temp folder. The runs 1 and 500 will have the same random-number state, but 
a different seed stream and therefore random draws will differ.{p_end}

{pstd}
In the case one or more {cmd:psimulate2} are nested in a loop or called sequentially,
they would use the same initial seed. 
To avoid this, {cmd:psimulate2} returns the last seed state of the last instance 
in {cmd:r()}.
To run {cmd:psimulate} sequentially we code:

{p 4 4}
{cmd:. psimulate2 , reps(100) seed(_current) p(2) seedsave(seed, frame): testsimul 200}{break}
{cmd:. set rng `r(rng_current)'}{break}
{cmd:. set rngstate `r(rngstate)'}{break}
{cmd:. psimulate2 , reps(100) seed(_current) p(2) seedsave(seed, frame): testsimul 200}
{p_end}

{pstd}
Using {it:_current} within {cmd:seed()} {cmd:psimulate2} will use the 
current seed of the parent instance as an initial seed for all child instances.
Each child instance will still have a different seed stream to ensure the random 
number draws are different.


{marker about}{title:Author}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:j.ditzen@hw.ac.uk":j.ditzen@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{p 4 4}{opt simulate2} was inspired by comments from Alan Riley 
and Tim Morris at the Stata User group meeting 2019 in London.
Parts of the program code and help file were taken from {help simulate}.
Kit Baum initiated the integration of MacOS and Unix and assisted in the implementation. 
I am grateful for his help.
All remaining errors are my own.{p_end}

{title:Change Log}
{p 4}Version 1.01 to Version 1.02{p_end}
{p 8 8}- Mata matrices and scalars are moved from parent to child instance as well.
{p 4}Version 1.0 to Version 1.01{p_end}
{p 8 8}- bug fixes in program to get exe name{p_end}
{p 8 8}- no batch file written anymore; support for MacOS{p_end}
{p 8 8}- added options nocls and processors to set max processors for Stata MP{p_end}
{p 8 8}- added that mata defined function are moved.{p_end}

{title:Also see}
{p 4} See also: {help simulate}, {help multishell}{p_end} 
