{smcl}
{hline}
{hi:help multishell}{right: v. 2.0 - October 2018}
{hline}
{title:Title}

{p 4 4}{cmd:multishell} - allotting do files and variations of loops across parallel instances of Stata and computers efficiently.
Do files and loops are dissected and distributed across parallel instances of Stata and computers, mimicking a cluster.{p_end}

{p 4}See list of {help multishell##contents:Contents} and {help multishell##description:Description} below. 
{cmd: multishell} is a complex command, please read the help file carefully before using it.{p_end}


{marker syntax}{title:Syntax}

{marker settingup}{p 2}{ul: Setting up {cmd:multishell}}{p_end}

{p 4 13}{cmd: multishell path} {it: path} [,clear] {break}
Sets the path for temporary files and do files.
If option {cmd: clear} is used, {cmd: multishell} deletes {bf:{ul:ALL}} files and folders in the directory irrevocably! {p_end}

{p 4 13}{cmd: multishell adopath} {it: path}{break}
Specifies path for ado files. 
Necessary if {cmd: multishell} is not installed into one of the main adopath directory.{p_end}

{p 4 13}{cmd: multishell alttext} {it:old text} @ {it:new text}{break}
{it:string} which is replaced from {it: old text} to {it:new text} in the do files specified by {cmd: multishell add}.
This option is useful if {cmd:multishell} is used to run do files across computers with a different folder structure or to insert computer specific commands.
For an example see {help multishell##example2:Examples}.
Number of text to be replaced is not limited (in theory).{p_end}

{p 4 13}{cmd: multishell add} {it: path}{break}
Adds do file to queue. 
The number of do files is not restricted (in theory at least).
{cmd: /* multishell loop*/} ensures that only certain loops are considered.
See {help: multishell##multishellloop}.  {p_end}

{p 4 13}{ul: Optional}

{p 4 13}{cmd: multishell exepath} {it:path}{break}
{cmd: multishell exepath} is optional, only necessary if multishell cannot find the Stata.exe.
The option is necessary to point {cmd:multishell} to the correct Stata.exe.
Under the default settings {cmd:multishell} automatically detects the Stata.exe.{p_end}

{p 2}{ul: Setting up the seed/random-number state}{p_end}

{p 4 13}{cmd: multishell seed save {it:filename}}{break}
Saves the used random-number state as a .dta in the folder defined by {cmd: multishell path}.
The state is saved together with the id and the variation of the loop of the task.
This option makes hardly sense as without further options, the states will be the same for all tasks.{p_end}

{p 4 13}{cmd: multishell seed load {it:filename} [, state noseedstream]}{break}
Loads the seed or states from {it:filename.dta}. 
The seeds have to be saved as variable {it:seed} and the number of the task in variable {it: id}.
The default is that what is saved in variable {it:seed} are seeds.
If they are random-number states (see {help rngstate}), then option {cmd:state} needs to be used.
In this case {cmd: set rngstate} rather than {cmd:set seed} is used to set the random 
number generator.{break}
Option {cmd:noseedstream} has only an effect for Stata 15 or later. 
If the option is invoked, all tasks will have the same seed-stream, namely stream 1. 
Otherwise they will use the task number as seed stream, which is the default.{break}
This option is useful if, the random-number state is saved by a earlier simulation and
results are meant to be reproduced.{p_end}

{p 4 13}{cmd: multishell seed create {it:filename} [, seed(#|random) rngstate({it:rngcode)} noseedstream]}{break}
A dummy dataset with seeds defined by {cmd:seed()} or {cmd:rngstate()} is created.
The dataset can be manipulated and then used to run {cmd: multishell run}, together with
{cmd:multishell seed load}. 
The random-number states are saved in {it:filename}.
If none of the options is used, then no seed is set and Stata's initial seed is used.{break}
With the option {cmd:seed(}{it:#}{cmd:)} an unique seed for all tasks can be set.
If {cmd:seed(random)} is used, then a random seed is used from {browse www.random.org:random.org}.
For Stata version before 15, a different seed for all tasks is obtained.
For Stata 15 and later, one seed is obtained and then each task is allocated a different stream.
In general, a use of Stata 14 or earlier is not recommended, see {help multishell##seed:multishell seed}.{break}
Option {cmd:noseedstream} has only an effect for Stata 15 or later. 
If the option is invoked, all tasks will have the same seed-stream, namely stream 1.
This implies that all random numbers are drawn from the same sequence. 
The option is only recommended if this is on purpose.{p_end}

{p 4 13}It is recommended to use Stata 15 with {cmd:mutishell}. 
When {cmd:multishell seed save} or {cmd:multishell seed create} is used with Stata 15,
{cmd:multishell} uses Stata's {help rngstream} function (unless option {cmd:noseedstream} 
is used), see {help multishell##seed:multishell seed}.{p_end}

{p 4 4} All seed options require {cmd: multishell path} and {cmd:multishell add}. 
If {cmd: multishell seed} is not used Stata's initial seed applies.
This implies that the random number generator draws the same random numbers even if using different instances of Stata.
For further information about setting the seed in Stata, see {help set_seed}.{p_end}

{p 4 4}For an overview of the options and their effect on random numbers see 
{help multishell##seedoptions:overview of seed options}.

{p 4 14}{cmd:mulitshell seed} is only required for the server.{p_end}

{p 2}{ul: Starting {cmd:multishell}}{p_end}

{p 4 13}{cmd: multishell run} [, {cmd: threads(}{it:integer}{cmd:)} {cmd: sleep(}{it:integer}{cmd:)} 
{cmd:nolog} {cmd:ncls} 
{cmd:stop(}{it:date time [, killall]}{cmd:)}  {cmd:maxtime(}{it:time}{cmd:)}
{cmd:continue}
{cmd:seedstream}
]{break}
Starts the server (or single computer).{break}
Option {cmd: threads(}{it:integer}{cmd:)} defines the maximum number of parallel Stata instances.
It is not advisable to set more threads than number of cores of the CPU.{break}
{cmd: sleep(}{it:integer}{cmd:)} sets the miliseconds {cmd:multishell} waits 
until it refreshes the task list and starts a new instance.{break}
{cmd:nolog} avoids saving a log file. 
The default is that a log file is saved in the folder defined by {cmd:path}.
A clickable link to the log file will appear in the output.
Each log file starts with an overview, which includes the set seed, the random-number generator
state, the seed stream number and the random-number generator type. 
In addition the name of the parent do file, the folder and the 
current variation of the loop is show.{break}
The default is that each time multishell is refreshed the output is cleared. 
Option {cmd:ncls} avoids the output window to be cleared.{break}
Options {cmd:stop(}{it:date time [, killall]}{cmd:)} and {cmd:maxtime(}{it:time}{cmd:)}
restrict the running time of {cmd:multishell}. 
See {help multishell##example6 :Stopping multishell}.
Option {cmd:continue} is only of use in conjunction with 
{cmd:stop()} and {cmd:maxtime()}.{break}
{cmd:seedstream} is only available for Stata 15 and if {cmd: multishell seed} is not used.
{cmd:seedstream} uses the current random-number state and uses different seed streams
for all tasks. Using {cmd:multishell seed save seeddta, rngstate({c 'g}c(rngstate)')}
would lead to the same result.
{p_end}

{p 4 13}{cmd: multishell run client} [, {cmd: threads(}{it:integer}{cmd:)} {cmd: sleep(}{it:integer}{cmd:)}
{cmd:nolog} {cmd:ncls} 
{cmd:stop(}{it:date time [, killall]}{cmd:)} {cmd:maxtime(}{it:time}{cmd:)}]
{cmd:continue}
{cmd:seedstream}]{break}
Starts the client.{break}
Options {cmd: threads(}{it:integer}{cmd:)}, {cmd: sleep(}{it:integer}{cmd:)}, 
{cmd:nolog}, {cmd:ncls}, {cmd:stop(}{it:date time}{cmd:)}}, {cmd:seedstream} and {cmd:maxtime(}{it:time}{cmd:)} are defined as above.
{cmd: mutltishell add} is not required as the client receives the tasks from the server. 
{cmd:nostop} causes the client to continue running, even if all tasks are finished.
This option allows to start new tasks on client by starting a new multishell instance on the server.{p_end}

{p 2}{ul: Restart {cmd:multishell}}{p_end}

{p 4 13}{cmd: multishell restart} {it:type} {cmd: , computer(}{it:computername}{cmd:)}{break}
Restarts (or re-queues) the tasks defined in {it: type} for the computer with the name defined in the option {it:computername}.
This option is useful if a computer crashes, a do file aborts with an error and tasks are not completed. 
{cmd: multishell} can be running on other computers, the task list will automatically be updated.{p_end}

{p 13}{it:type} can be:{p_end}
{col 15} {it: type} {col 35}Description
{col 15}{hline 60}
{col 15} {it: assigned} {col 35} all assigned tasks to queued.
{col 15} {it: running} {col 35} all running tasks to queued.
{col 15} {it: finished} {col 35} all finished tasks to queued.
{col 15} {it: error} {col 35} all tasks with an error to queued.
{col 15} {it: stopped}{col 35} all tasks which were stopped to queued.
{col 15} {it: id(#)} {col 35} task number # to queued.
{col 15}{hline 60}

{p 13 13}The changes apply only to the computer defined in {cmd:computer(}{it:computername}{cmd:)}.
To restart all computers, use option {cmd:computer(}{it:_all}{cmd:)}.
All types can be combined and called at the same time.
{p_end}

{p 2}{ul: Diagnosis}{p_end}

{p 4 13}{cmd: multishell status}{break}
Displays the output window and an overview of all visible clients.
Lists additional set ado paths, path to exe file, temporary path and strings to be replaced by {cmd: alttext}.{p_end}

{marker contents}{title:Contents}

{p 4}{help multishell##syntax:Syntax}{p_end}
{p 4}{help multishell##description:Description}{p_end}
{p 4}{help multishell##seed:Multishell and seeds}{p_end}
{p 4}{help multishell##seedoptions:- Overview of seed options}{p_end}
{p 4}{help multishell##example1:Example 1: Single Computer}{p_end}
{p 4}{help multishell##example2:Example 2: Multiple Computers}{p_end}
{p 4}{help multishell##example3:Example 3: Continue and restart multishell}{p_end}
{p 4}{help multishell##example4:Example 4: Using multishell seed}{p_end}
{p 4}{help multishell##example5:Example 5: Skipping loops}{p_end}
{p 4}{help multishell##example6:Example 6: Stopping multishell}{p_end}
{p 4}{help multishell##exampleZZ:Example 7: Short Examples}{p_end}
{p 4}{help multishell##problems:Known Problems and Limitations}{p_end}
{p 4}{help multishell##about:About}{p_end}
{p 4}{help multishell##disclaimer:Disclaimer}{p_end}
{p 4}{help multishell##changelog:Further See}{p_end}


{marker description}{title:Description}

{p 4 4}{cmd:multishell} allows the efficient processing of loops and multiple do files across a single and multiple computers.
{cmd:multishell} dissects {cmd: forvalues} and {cmd: foreach} loops and creates for each variation (tasks) a separate do file. 
The do files are queued and sequentially processed. 
Besides the do file, a {cmd:.bat} file is created for each task. 
Then Stata's build in {help shell} command is used to start a new instance of Stata using the {cmd:.bat} file.
The instance is closed as soon as the task is completed (or failed, then it is reported) and a new instance processing the next task is started.
One instance is reserved to organise the tasks and starts other instances. 
Multiple instances can be run in parallel on the same computer.
Please read carefully the section about {help multishell##seed:multishell and seed} if running simulations which involve 
drawing random numbers.{p_end}

{p 4 4}In addition {cmd:multishell} can use the computation power of multiple computers, mimicking a cluster. 
The requirement is that all computers have access to the folder {cmd: multishell} uses.
The structure pointing to the folder, such as parent folders or drives is allowed to vary across computers.
Access can be either in form of a network drive or using an internet cloud based service such Dropbox or Backup and Sync from Google.
One computer acts as a server and assigns tasks to the clients.
As in the single computer case, one instance manages the incoming tasks and runs them.{p_end}

{p 4 4}The main aim of {cmd:multishell} is to make efficient use of computational power, of one machine or a network, to run simulations with multiple changing parameters.
For example, it is common to use Monte Carlo simulations to assess the bias of an estimator. 
This is done by varying the number of observations, let's say from N=10 in steps of 10 to N = 130.
Assume the DGP and the regression are part of the program {cmd: MonteCarloSim}. 
The number of observations is set as the only argument of the program and the estimated coefficient of variable {it: x} is returned as r(x).
This can be coded using Stata's {help simulate} command nested in a {cmd: forvalues} loop:
{p_end}

{p 10}{cmd: forvalues n = 10 (10) 130} {c -(}{p_end}
{p 15}{cmd:	simulate bx = r(x), reps(1000) : MonteCarloSim {c 'g}n'}{p_end}
{p 10}{cmd:{c )-} }{p_end}

{p 4 4} {cmd:multishell} creates for each of the variations of n (n=10, n=40,...,n=130) a do file and a .bat file. 
The files are then queued and consecutively processed by multiple instances of Stata on a single computer or by multiple computers.
The number of parallel Stata instances depends on the CPU and the number of cores. 
If the machine has 8 cores, then 7 instances plus the instance managing the tasks can be started.
It is not advised to start more instances of Stata in total than the CPU has cores!
Windows usually automatically distributes the workload of a Stata instance to a different core.
For example the managing instance uses core 1, the first instance called by {cmd: multishell} core 2, and so on.{p_end}

{p 4 4}It is possible to process only certain loops and thus skip other loops.
If the differentiation is made, loops which are supposed to be dissected need to be 
labelled with /* multishell loop */. 
{cmd:multishell} automatically dectes if this option is used and adjusts accordingly.{p_end}

{p 4 4}If a task (or Stata instance) aborts with an error, {cmd: multishell} will continue and start the next task in the list. 
The error will be posted in the output window.
In addition log files, saved as .txt, can be found in the folder {it:path}\temp\{it:task}, where {it:path} is the path specified by
{cmd: multishell path} and {it:task} is the task number.
The {cmd: multishell} server or client, or a Stata instance running a task can be stopped by using the break button or closing the Stata window.
It is possible to continue {cmd: multishell} and restart the server and client.
Options, such as the number of maximum Stata threads can be changed and further do files added.
If the server is stopped, no new tasks will assigned during this period, but remaining tasks will continue in the background.
{p_end}

{p 4 4}{cmd:multishell} can stop tasks and itself after an user specified running time
or after a certain date and time is reached. 
To do so {cmd:multishell} maintains a list with all running Stata instances 
and their Windows Process ID. 
If a tasks overruns, it automatically closes the running Stata instances.
Starting {cmd:multishell} with several Stata instances does not work however,
as the program cannot determine which Stata instance is the main instance.
{p_end}

{marker seed}{title:multishell and seeds}

{p 4 4} Using {cmd:multishell} has important implications for the seed.
Please read carefully to ensure correct results.
There are two main difficulties when running parrallel isntances of Stata.{p_end}

{p 4 4}{ul:Same numbers across tasks and instances}{break}
The first is, that random numbers across instances (tasks) and computers can be the same. 
Stata has a powerful random number generator, as described in {help set seed}. 
If not changed, the state of the random number generator (seed) is the same when Stata is started and therefore #
drawn numbers are identical.
If in a simulation random numbers a drawn and it is run on separate instances of 
Stata on the same machine, the numbers will be the same.
The same applies if the same different tasks are performed on mutiple machines.
This implies that in the extreme, a Monte Carlo simulation using multiple 
instances of Stata even on different computers produces the same results. 
Stata uses a sequence of pre-determined random numbers, specified by the seed or 
the state of the random number generator. This means, that the following code produces
the same numbers:{p_end}

{col 15}{stata clear}
{col 15}{stata set obs 10}
{col 15}{stata set seed 123} 
{col 15}{stata x = rnormal()}
{col 15}{stata set seed 123} 
{col 15}{stata y = rnormal()}
{col 15}{stata list x y}

{p 4 4}The idea is to assign a unique seed to each task:{p_end}
{col 15}{stata clear}
{col 15}{stata set obs 10}
{col 15}{stata set seed 123} 
{col 15}{stata x = rnormal()}
{col 15}{stata set seed 456} 
{col 15}{stata y = rnormal()}
{col 15}{stata list x y}

{p 4 4}The nubers in {it:x} and {it:y} are different.{p_end}

{p 4 4}{ul:Different Seeds but overlapping seed streams}{break}
The second difficulty is, that the seeds can overlap and therefore the drawn 
random numbers repeat.
As explained, Stata uses pre-determined seeds. 
The sequence of the seeds is called a seed stream, thus two sequences can 
overlap.{break}
Let's assume two tasks are performed, {it:x1} in the first with 10 observations 
and {it:x2} for the second with 20 observations.
Using the same seed would lead to the same first 10 random numbers. 
The following example will show this.{p_end}

{col 15}{stata clear}
{col 15}{stata set obs 20}
{col 15}{stata set seed 123} 
{col 15}{stata gen x1 = rnormal() if _n <= 10 }
{col 15}{stata set seed 123}
{col 15}{stata gen x2 = rnormal()  }
{col 15}{stata list x1 x2}

{p 4 4}For a Monte Carlo simulation, {it:x1} and {it:x2} are not independent anymore
and thus results using this example would be invalid.
A simple solution would be to use a different seed for both. 
However as shown next, the two seeds can overlap and produce same numbers.{break}
The following code will draw 10 numbers, save the seed, draw further 10 numbers for 
variable {it:x1} and then resets the seed and draws further 10 numbers for {it:x2}:
{p_end}

{col 15}{stata clear}
{col 15}{stata set obs 20}
{col 15}{stata set seed 1234} 
{col 15}{stata gen x1 = rnormal() if _n <= 10 }
{col 15}{stata local seed =  c(rngstate)}
{col 15}{stata replace x1 = rnormal() if _n>10}
{col 15}{stata set seed `seed'}
{col 15}{stata gen x2 = rnormal() if _n > 10 }
{col 15}{stata list x1 x2}

{p 4 4}We have shown that even though a different seed is set, the same random numbers
are drawn. Why is this the case?
The reason is that after each random number, the state of the random number generator
is set shifted along the seed stream. 
The seeds at observation 11 overlap (i.e. they are the same) and
thus the same random numbers are produced. 
The following graph (which resembles the one in {help rngstream}) shows this. 
For example, assume two tasks, first we draw 10 numbers, then 10 further numbers.{p_end}

{col 11}rng-State {col 20}a {col 30} b {col 40} c
{col 10} Task 1{col 20} |---------|---------|
{col 10} Task 2{col 30} |---------|
{col 11}Numbers {col 20} 1 {col 30} 10 {col 40} 20

{p 4 4}Task 1 starts with random number generator (rng) state {it:a} and draws 10 random numbers.
Then it reaches rng-state {it:b} and draws further 10 random numbers. 
If for Task 2 the rng-state is set to {it:b} the 10 random numbers will be the same,
because the rng-states of both tasks overlap. This problem is more theoretical,
but it might occur and therefore is important to discuss.

{p 4 4}{ul: Stata Version 14.2 and lower}{break}
For versions 14.2 and lower, a seed for each task is obtained from {browse random.org}.
This ensures that the seeds for each task will be different each time Stata is started.
However it is theoretically possible (and thus it will happen if repeated often enough, whatever
often means), that two or more sequences overlap each other. 
Even though this is very unlikely, it is important for the user to note.
At the moment there is no workaround of this problem.{p_end}

{p 4 4}Seeds are saved if the options {cmd:multishell seed save} or
{cmd:multishell seed create} are used.{p_end}

{p 4 4}{ul: Stata Version 15 and following}{break}
For version 15 and following the two problems are sufficiently solved.
{cmd:multishell seed create , seed(random)} obtains a random number from 
{browse random.org} which is used as a seed.
This ensures that if {cmd:multishell run} is repeated, respectively on different
computers, the initial seed differs (this is the first difficulty).{p_end}

{p 4 4}The second difficulty is solved by using {help set rngstream:seed streams}
and is only available for Stata 15 following. 
A different seed stream number is allocated to each task. 
Following the example from above, each task (and thus Stata instance) is started
with the same intial seed obtained as a random number from random.org, however
each task is assigned a different stream number. 
By construction, task 1 will be allocated stream 1, task two stream 2:{p_end}

{col 11}rng-State {col 20}a1 {col 30} b {col 40} c {col 44} a2
{col 10} Task 1{col 20} |---------|---------|
{col 10} Task 2{col 44} |---------|
{col 11}Numbers {col 20} 1 {col 30} 10 {col 39} 20 {col 44} 1 {col 54} 10	

{p 4 4}where a1 is the seed with stream 1 and a2 the same seed, but with stream 2.
With this method it is (almost) impossible to obtain the same sequence of random
numbers twice. 
The method works across computers as long as the inital seeds are different.
For more background reading, please see {help set rngstream}.{p_end}

{p 4 4}Seeds (the individual for each task) and the stream numbers are 
saved if the options {cmd:multishell seed save} or
{cmd:multishell seed create} are used.{p_end}

{p 4 4}This function benefitted from many discussions at the London Stata User Group 
Meeting 2018, especially with Ben Jann, Yulia Marchenko, Tim Morris, Austin Nichols and Adrian Sayers.{p_end}


{marker seedoptions}{p 4 4}{ul:Overview of multishell's seed options}{break}
The following table shows the effect of the different options relating seeds and 
random number-states. Three tasks are run, hence three instances of Stata and all
draw 100 random numbers. The seeds are shown in the tables.{p_end}

{p 4 4}For Stata 14:{p_end}

{col 10}multishell{col 20}{c |}  seed save  {col 35} {col 43} seed create {it:dta}, {col 65} seed load  {col 82} seed 
{col 10}command{col 20}{c |} {col 35} seed(random) {col 52} seed(123)**{col 65} {col 80} not set
{col 10}{hline 10}{c +}{hline 75}
{col 10} task 1 {col 20}{c |} default* {col 36} random #1{col 52} 123* {col 65} seed #1** {col 80} default* 
{col 10} task 2 {col 20}{c |} default* {col 36} random #2{col 52} 123* {col 65} seed #2** {col 80} default* 
{col 10} task 3 {col 20}{c |} default* {col 36} random #3{col 52} 123* {col 65} seed #3** {col 80} default* 
{col 10}{hline 10}{c BT}{hline 75}

{p 4 10}where * means all seeds are the same across tasks,{break}
** or corresponding rngstate(),{break}
random #{it:i}, is random number {it:i} obtained from random.org,{break}
seed #i is seed {it:i} in the dta with seed/random-number states.
{p_end}

{p 4 4}For Stata 15 or later:{p_end}

{col 10}multishell{col 20}{c |}   {col 35}{c |}{col 57} seed create {it:dta}, {col 65} 
{col 10}command{col 20}{c |}  seed save {col 35}{c |}{col 45} seed(random){col 65} {c |}  {col 75} seed(123)**
{col 20}{c |} {col 35}{c |} {it:seed stream} {col 50}{c |} noseedstream {col 65} {c |} {it:seed stream}{col 80}{c |} noseedstream
{col 10}{hline 10}{c +}{hline 14}{c BT}{hline 14}{c BT}{hline 15}{c BT}{hline 13}{c BT}{hline 15}
{col 10} task 1 {col 20}{c |} default* (1){col 35} random #1 (1){col 51} random #1 (1)* {col 68} 123 (1){col 83} 123 (1)*
{col 10} task 2 {col 20}{c |} default* (1){col 35} random #1 (2){col 51} random #1 (1)* {col 68} 123 (2){col 83} 123 (1)*
{col 10} task 3 {col 20}{c |} default* (1){col 35} random #1 (3){col 51} random #1 (1)* {col 68} 123 (3){col 83} 123 (1)*
{col 10}{hline 10}{c BT}{hline 75}

{col 10}multishell{col 20}{c |} {col 27} seed load {it:dta}, {col 52} run, {col 67} seed
{col 10}command {col 20}{c |} {it:seed stream} {col 35}noseedstream {col 50} {cmd:seedstream} {col 65} not set
{col 10}{hline 10}{c +}{hline 60}
{col 10} task 1 {col 20}{c |} seed #1 (1){col 35} seed #1 (1){col 50} default (1){col 65} default (1)* 
{col 10} task 2 {col 20}{c |} seed #2 (2){col 35} seed #2 (1){col 50} default (2){col 65} default (1)* 
{col 10} task 3 {col 20}{c |} seed #3 (3){col 35} seed #3 (1){col 50} default (3){col 65} default (1)*

{p 4 10}where the number of the random-number stream is parenthesis,{break}
* means all seeds are the same across tasks{break}
** or corresponding rngstate(){break}
random #{it:i}, is random number {it:i} obtained from random.org,{break}
seed #i is seed {it:i} in the dta with seed/random-number states,{break}
{it:seed stream} is using the seed stream (no option required, default),{break}
noseedstream means option {cmd:noseedstream} is used,{break}
{cmd:seedstream} is the {cmd:seedstream} option of {cmd:multishell run}.
{p_end}

{marker example1}{title:Example 1: Single Computer}

{p 4 4}Assume the Monte Carlo simulation example from above, using only one computer and allowing for 6  parallel running Stata instances. 
To use {cmd: multishell}, two do files are required. 
The first contains the code for the MonteCarlo simulation, the second one contains the code for multishell.
The simulation results are stored in a dataset called {it:results_{c 'g}n'} in a separate subfolder.
The .ado files for {cmd: multishell} are located in {it: multishell\ado} in the documents folder.{p_end}

{p 4 4}The simulation including the program are saved in the do file {it: MonteCarloSimulation.do} in the subfolder {it: multishell\simulation}:{p_end}

{col 10}{cmd: program define MonteCarloSim , rclass} 
{col 12}{cmd: syntax anything }
{col 14}{cmd: clear}
{col 14}{cmd: set obs {c 'g}anything'}
{col 14}{cmd: drawnorm x e}
{col 14}{cmd: gen y = 1 + 0.5 * x + e}
{col 14}{cmd: reg y x}
{col 14}{cmd: return scalar x = _b[x]}
{col 10}{cmd: end} 

{col 10}{cmd: clear}
{col 10}{cmd: forvalues n = 10 (10) 130 {c -(}}
{col 12}{cmd: simulate bx = r(x) , reps(1000) : MonteCarloSim {c 'g}n'}
{col 12}{cmd: save "C:\documents\multishell\results\results_{c 'g}n'", replace	}
{col 10}{cmd: {c )-} }

{p 4 4} In the first part of the do file, the program for the Monte Carlo simulation is defined. 
Within the program, the number of observations is set, random numbers for x and the error term e are drawn and y is calculated.
Then a simple regression of x on y is performed and the estimated coefficient on x is returned.
The second part of the do file includes the for-loop, which loops over different number of observations.
For programming issues, it is important that there is a space between the name of the local (here n) and the equal sign.
Within the loop, the MonteCarloSim program is called, executed 1000 times and the resulting coefficient estimates saved in a dta file called results.{p_end}

{p 4 4}The second do file contains the code for {cmd: multishell}. 
The adopath for multishell is added, followed by the path for the temporary files and the Stata exe file.
The adopath option is only necessary if {cmd: multishell} is not loaded automatically with Stata.
In addition it allows the user to add further .ado files to Stata, which might be unique to the project.
Using {cmd: multishell add} the do file is added. 
{cmd: multishell} creates the do files for each variation in a subfolder specified by path.
In the final line of code, the simulation is called and the running Stata instance calls up to 6 further threads.
The option {cmd: sleep(2000)} indicates that Stata waits for 2000ms before it refreshes the task list.{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\", clear}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell add "C:\documents\multishell\simulation\MonteCarloSimulation.do" }
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}The resulting Stata window will look like:{p_end}

{col 6}----------------------------------------------------------------------------------------------------
{col 6} #   do-file                                State          Time                     Machine
{col 6}----------------------------------------------------------------------------------------------------
{col 6}     MonteCarloSimulation.do                queued and running
{col 6} 1       n = 10                             finished       17 Jul 2018 - 11:37:39   Research181
{col 6} 2       n = 20                             finished       17 Jul 2018 - 11:37:39   Research181
{col 6} 3       n = 30                             running        17 Jul 2018 - 11:37:29   Research181
{col 6} 4       n = 40                             running        17 Jul 2018 - 11:37:29   Research181
{col 6} 5       n = 50                             running        17 Jul 2018 - 11:37:29   Research181
{col 6} 6       n = 60                             running        17 Jul 2018 - 11:37:29   Research181
{col 6} 7       n = 70                             running        17 Jul 2018 - 11:37:27   Research181
{col 6} 8       n = 80                             running        17 Jul 2018 - 11:37:27   Research181
{col 6} 9       n = 90                             queued         17 Jul 2018 - 11:37:27   
{col 6} 10      n = 100                            queued         17 Jul 2018 - 11:37:27   
{col 6} 11      n = 110                            queued         17 Jul 2018 - 11:37:27   
{col 6} 12      n = 120                            queued         17 Jul 2018 - 11:37:28   
{col 6} 13      n = 130                            queued         17 Jul 2018 - 11:37:28   
{col 6}----------------------------------------------------------------------------------------------------
{col 6} Machine           Queued    Assigned  Running   Finished  Total
{col 6} This Computer     5         0         6         2         8
{col 6}----------------------------------------------------------------------------------------------------
{col 6}Computername: Research181
{col 6}as of 17 Jul 2018 - 11:37:39; started at 17 Jul 2018 - 11:37:28
{col 6}next refresh in 2s.

{p 4 4}The output shows the name of the do file, the number of tasks and a breakdown of all variations.
The State column indicates, weather a task is queued, assigned (only necessary for multi computer use, see below), running or finished.
The final columns indicate the time of the last action (i.e. queued, running, finished) and the name of the machine running the task.
Overview statistics are shown at the end.{p_end}

{p 4 4}As soon as a task is completed, stopped or aborts with an error, a clickable link
to the log file will appear, unless option {cmd:nolog} is used.
Each log file will start with an overview of the task. 
The parent and running do file name and folder, variation and its number are shown.
In addition the random number type, the stream number, the current state of the random number generator 
and the set seed are displayed as well.
The set seed is usually the seed which is inputted by {cmd:multishell seed ... , seed(123)} or 
obtained from random.org.{break}
The beginning of the log file looks the following:{p_end}

{col 6}*******************************************************************************{col 85}*
{col 6}*                                                                              {col 85}*
{col 6}*                           Multishell Version 2.0                             {col 85}*
{col 6}*                                                                              {col 85}*
{col 6}*   Parent File Properties                                                     {col 85}*
{col 6}*      Folder:          C:/Main Path/St~/test {col 85}*
{col 6}*      do Filename:     test.do {col 85}*
{col 6}*   Running File Properties     {col 85}*
{col 6}*      Folder:          C:/Main Path/St~/test/3 {col 85}*
{col 6}*      do Filename:     test_200.do {col 85}*
{col 6}*      Variation No.:   3           {col 85}*
{col 6}*      Variation:       N = 200     {col 85}*
{col 6}*                                                                              {col 85}*
{col 6}*   Random Number Generator Properties                                         {col 85}*
{col 6}*      RNG Type : mt64s                                                        {col 85}*
{col 6}*      Seed Stream Number : 3                                                  {col 85}*
{col 6}*      RNG State  = XBA0000000027ede55c017af28fd825f52d5a6e0f4de27......     {col 85}*
{col 13}.....
{col 6}*      Set Seed = 669902172                                                    {col 85}*
{col 6}*                                                                              {col 85}*
{col 6}*******************************************************************************{col 85}*

{p 4 4}It is strongly advisable to carefully check the log file and especially  the overview in the beginning with the seeds.{p_end}

{p 4 4}An example do file can be download from within Stata via {stata "net describe multishell, from(http://www.ditzen.net/Stata)"}
or {stata "net get multishell, from(http://www.ditzen.net/Stata)"}.{p_end}

{p 4 4}{cmd:multishell exepath} is not required and will be omitted for the 
remaining examples.{p_end}

{marker example2}{title:Example 2: Multiple Computers}

{p 4 4}For this example assume the Monte Carlo simulation from above is used and in addition a second do file for a panel estimation with fixed effects is added.
The code for the panel estimation is saved as {it: MonteCarloSimulation_panel.do} and reads:

{col 10}{cmd: program define MonteCarloSim , rclass} 
{col 12}{cmd: syntax anything }
{col 14}{cmd: clear}
{col 14}{cmd: tokenize {c 'g}anything'}
{col 14}{cmd: local n = {c 'g}1'}
{col 14}{cmd: local t = {c 'g}2'}
{col 14}{cmd: set obs {c 'g}={c 'g}n*{c 'g}t''}
{col 14}{cmd: egen id = seq(), block({c 'g}t')}
{col 14}{cmd: by id, sort: gen t = _n}
{col 14}{cmd: xtset id t}
{col 14}{cmd: drawnorm x e}
{col 14}{cmd: gen y = 1 + 0.5 * x + e}
{col 14}{cmd: xtreg y x, fe}
{col 14}{cmd: return scalar x = _b[x]}
{col 10}{cmd: end} 

{col 10}{cmd: clear}
{col 10}{cmd: forvalues n = 50 (10) 130 {c -(}}
{col 12}{cmd: forvalues t = 10 (10) 50 {c -(}}
{col 14}{cmd: simulate bx = r(x) , reps(1000) : MonteCarloSim {c 'g}n' {c 'g}t'}
{col 14}{cmd: save "PATH1\multishell\results\results_{c 'g}n'_{c 'g}t'", replace	}
{col 12}{cmd: {c )-} }
{col 10}{cmd: {c )-} }

{p 4 4}The folder structure across computers can differ, for example different drives are used. 
{cmd: multishell} allows for a computer specific structure in the do files as well.
PATH1 will be replaced by a string using the {cmd: multishell alttext} function.{p_end}

{p 4 4}A do file for each computer is required, as the server (Research181) and the client (HPJD) are called differently.
The file for the server is the same as above, but the second do file is added and the function {cmd: alttext} used.
In addition the number of instances (or threads) is restricted to 2.{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\"}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell alttext "PATH1 @ C:\documents\" }
{col 10}{cmd: multishell add "C:\documents\multishell\simulation\MonteCarloSimulation.do" }
{col 10}{cmd: multishell add "C:\documents\multishell\simulation\MonteCarloSimulation_panel.do" }
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}Let's assume the folder structure for the client is the same, but on drive F, rather than C and in the subfolder Users. 
The argument of the function {cmd: multishell alttext} is adjusted as well. 
We allow 6 threads at the same time.
As the server will create the do files for the tasks, we do not need to specify those in the client do file.
Also note, the option {cmd: clear} for {cmd: multishell path} is not used.
It is only used for the client, which is started first:{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "F:\users\documents\multishell\ado\"}
{col 10}{cmd: multishell path "F:\users\documents\multishell\test\output\", clear}
{col 10}{cmd: multishell adopath "F:\users\documents\multishell\ado\"}
{col 10}{cmd: multishell alttext "PATH1 @ F:\users\documents\" }
{col 10}{cmd: multishell run client, threads(2) sleep(2000)}

{p 4 4}As soon as we start the do file on the client, the Stata window is locked and the client searches in the directory for the Server.
The output window displays:{p_end}

{col 10}{cmd: Check if multishell Server is set-up. . . . . . .}

{p 4 4}When the server is started and ready the following appears:{p_end}

{col 10}{cmd: multishell Server set up, waiting for assigned tasks (for HPJD). . . . }

{p 4 4}As soon as the server assigned tasks to the client, the following is displayed in the output window:{p_end}

{col 6}----------------------------------------------------------------------------------------------------
{col 6} #   do-file                                State          Time                     Machine
{col 6}----------------------------------------------------------------------------------------------------
{col 6}     MonteCarloSimulation.do                running and finished
{col 6} 1       n = 50                             finished       17 Jul 2018 - 14:26:50   HPJD
{col 6} 2       n = 60                             finished       17 Jul 2018 - 14:26:50   HPJD
{col 6} 3       n = 70                             finished       17 Jul 2018 - 14:26:50   HPJD
{col 6} 4       n = 80                             finished       17 Jul 2018 - 14:26:51   HPJD
{col 6} 5       n = 90                             finished       17 Jul 2018 - 14:26:52   HPJD
{col 6} 6       n = 100                            running        17 Jul 2018 - 14:26:50   HPJD
{col 6} 7       n = 110                            finished       17 Jul 2018 - 14:26:41   Research181
{col 6} 8       n = 120                            finished       17 Jul 2018 - 14:26:41   Research181
{col 6} 9       n = 130                            finished       17 Jul 2018 - 14:26:50   Research181
{col 6}     MonteCarloSimulation_panel.do          queued and running
{col 6} 10      n = 30 , t = 30                    running        17 Jul 2018 - 14:26:43   Research181
{col 6} 11      n = 30 , t = 40                    running        17 Jul 2018 - 14:26:53   HPJD
{col 6} 12      n = 30 , t = 50                    assigned       17 Jul 2018 - 14:26:31   HPJD
{col 6} 13      n = 40 , t = 30                    assigned       17 Jul 2018 - 14:26:32   HPJD
{col 6} 14      n = 40 , t = 40                    running        17 Jul 2018 - 14:26:52   Research181
{col 6} 15      n = 40 , t = 50                    assigned       17 Jul 2018 - 14:26:32   HPJD
{col 6} 16      n = 50 , t = 30                    assigned       17 Jul 2018 - 14:26:32   HPJD
{col 6} 17      n = 50 , t = 40                    queued         17 Jul 2018 - 14:26:33   
{col 6} 18      n = 50 , t = 50                    queued         17 Jul 2018 - 14:26:33   
{col 6}----------------------------------------------------------------------------------------------------
{col 6} Machine           Queued    Assigned  Running   Finished  Total
{col 6} HPJD              0         4         2         5         11
{col 6} This Computer     0         0         2         3         5
{col 6}----------------------------------------------------------------------------------------------------
{col 6} Total             2         4         4         8         16
{col 6}----------------------------------------------------------------------------------------------------
{col 6}Computername: Research181
{col 6}as of 17 Jul 2018 - 14:26:54; started at 17 Jul 2018 - 14:26:33
{col 6}next refresh in 2s.

{p 4 4}The output shows the name of the two do files, which are consecutively processed, and the different tasks.
All tasks are distributed to both computers (the server, Research181 and the client HPJD).
There are four tasks which are assigned to the client, but are not yet started.
{p_end}

{p 4 4}An example do file can be download from within Stata via {stata "net describe multishell, from(http://www.ditzen.net/Stata)"}
or {stata "net get multishell, from(http://www.ditzen.net/Stata)"}.{p_end}

{marker example3}{title:Example 3: Continue and restart a running multishell}

{p 4 4}{ul: Continue a running multishell}{break}It is possible to stop the server or the client clicking on the {help break} button. 
The tasks running in the background will continue until finished.
If the server is stopped, no new tasks will be assigned to the clients.
Both can be restarted using the {cmd: multishell run} command, for the client with the client extension.
The {cmd: multishell} set-up commands, {cmd: path}, {cmd: adopath}, {cmd: alttext} and if used {cmd: exepath} need to be executed again.
Do {ul:not} use {cmd: multishell add} again, as the do files would be overwritten.
{p_end}

{p 4 4}The option allows the change the number of parrallel Stata instances or the time to refresh.
Restarting the server using the code from {help multishell##example2:above} with 8 instead of 6 threads would read:{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\"}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell alttext "PATH1 @ C:\documents\" }
{col 10}{cmd: multishell run, threads(8) sleep(2000)}

{p 4 4}The two lines containing {cmd: multishell add} were removed and {cmd:threads(8)} rather than {cmd:threads(6)} is used.
The remainder is the same as the code above.{p_end}


{p 4 4}{ul: Restart a running multishell}{break}
In the case a do-file aborts with an error, a Stata instance or a computer crashes, it is possible to continue {cmd: multishell}. 
Using the example from  {help multishell##example2:above}, assume computer HPJD crashed, all running and assigned tasks need to be resetted. 
The set-up commands, {cmd: path}, {cmd: adopath}, {cmd: alttext} and if used {cmd: exepath} need to be executed again:{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\"}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell alttext "PATH1 @ F:\users\documents\"}
{col 10}{cmd: multishell reset assigned running , computer(HPJD)}
{col 10}{cmd: multishell status}
{col 10}{cmd: multishell run client, threads(2) sleep(2000)}

{p 4 4}The command resets the status of the tasks which were assigned or running on computer HPJD. 
{cmd: multishell status} displays the current state of {cmd: multishell} and the last line restarts the client.{break}
If for example task 7 needs to be resetted, then the command line is:{p_end}

{col 10}{cmd: multishell reset id(7), computer(Research181)}

{marker example4}{title: Example 4: Using multishell seed}

{p 4 4}The section about {help multishell##seed:multishell and seed} gives a basic 
introduction and motivation for the use of {cmd: multishell seed}. 
If {cmd: multishell seed} is not used, then no seed is set and different instances of Stata 
might produce identical random numbers. 
Before {cmd: multishell seed} can be used, a path has to be set and do files added.{p_end}

{p 4 4}{ul: Saving the seeds}{break}
In order to repeat a Monte Carlo simulation and to retrieve the same results, the state of the random number generator, the seed, is required.
{cmd: multishell seed save {it: filename}} saves the seed together with the id of the task and the variation. Following {help multishell##example1:Example 1}, one line of code is added before the final line:
{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\"}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell add "C:\documents\multishell\simulation\MonteCarloSimulation.do" }
{col 10}{cmd: multishell seed save "seed file"}
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}The seeds of each task saved in the Stata dataset file {it: seed file.dta}.
The file contains the id of the task, the options (i.e. the value of n) and the seed.
For example the first two lines would read:{p_end}

{col 10}     +----------------------------+
{col 10}     | id     options        seed |
{col 10}     |----------------------------|
{col 10}  1. | 1      n = 10    XN0000... |
{col 10}  2. | 2      n = 20    XN0000... |
{col 10}  3. ......

{p 4 4}where the seed is abbreviated for a better readability.
As the seed was not specified further, it is the same for both variations and the first drawn numbers for both are the same.
It is now possible to use the saved seed from to reproduce the exact Monte Carlo simulation results, as shown next.{p_end}

{p 4 4}{ul: Using a saved seed}{break}
If the seed is already saved in the file {it: seed file}, {cmd: multishell} can open the file and assign it to the corresponding tasks. 
The identification of the tasks is done by the task's id only.
To do so, the penultimate line is altered again:
{p_end}

{col 10}{cmd: clear all}
{col 10}{cmd: adopath ++ "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell path "C:\documents\multishell\test\output\"}
{col 10}{cmd: multishell adopath "C:\documents\multishell\ado\"}
{col 10}{cmd: multishell add "C:\documents\multishell\simulation\MonteCarloSimulation.do" }
{col 10}{cmd: multishell seed load "seed file"}
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}For each of the variations, the seed is automatically loaded from the dataset and accordingly set.{p_end}

{p 4 4}{ul: Creating a dummy dataset}{break}
{cmd: multishell} can create a dummy dataset with empty seeds or prefilled "random" seeds. 
The dataset contains a row for each variation, with the id and the variation itself.
It is possible to alter the dataset, change the seeds and the run {cmd: multishell}.
A dummy dataset is created using {cmd: multishell seed create {it:filename}}. 
Let's assume the seed for the first variation is supposed to be 1, for the 2nd 2 and so on, the following code is required 
(for a better readability for the following examples, the code starts after {cmd:multishell add}):{p_end}

{col 10}{cmd: ...}
{col 10}{cmd: multishell seed create "seed file"}
{col 10}{cmd: use "C:\documents\multishell\test\output\seed file", clear}
{col 10}{cmd: replace seed = _n}
{col 10}{cmd: save "C:\documents\multishell\test\output\seed file", replace}
{col 10}{cmd: multishell seed load "seed file"}
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}The dummy file is created and then opened. Then variable {it: seed} is replaced by {cmd:_n}, thus 1, 2, ..., N. 
The dataset is saved, {cmd: multishell} loads the dataset and is started.{p_end}

{p 4 4}{ul: Using seeds from random.org}{break}
The above example would lead to different draws.
In addition it is possible to do the steps above, but with random numbers instead of _n, if the option {cmd: seed(random)} is used:{p_end}

{col 10}{cmd: ...}
{col 10}{cmd: multishell seed create "seed file", seed(random)}
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}{cmd:multishell run} can be called after {cmd:, seed(random)} without any further commands.
The random numbers are obtained from {browse www.random.org} and with a 
altered version of {help setrngseed}.
In the file {it: seed file} the seeds for all tasks are saved and can be used to replicate Monte Carlo simulation results.{p_end}

{p 4 4}{ul: Using  the same seed}{break}
This option makes only sense for Stata 15 and together with the seed stream.{p_end}

{col 10}{cmd: ...}
{col 10}{cmd: multishell seed create "seed file", seed(123)}
{col 10}{cmd: multishell run, threads(6) sleep(2000)}

{p 4 4}In this case all Stata instances will have the seed 123.
If Stata 15 is used, each task will have a different stream and thus
the random numbers are unlikely to be repeated.{p_end}

{marker example5}{title:Example 5: Skip loops}

{p 4 4}As a default {cmd:multishell} processes all loops. 
If some loops should be skipped by multishell and only certain considered,
then those to be processed can be marked with /*mulitshell loop*/.
For example, the same simulation as in {help: multishell##example1} is run,
but the estimate for the intercept is saved as well. 
The coefficients to be returned are saved in a local which is created by a loop:{p_end}

{col 10}{cmd: program define MonteCarloSim , rclass} 
{col 12}{cmd: syntax anything }
{col 14}{cmd: clear}
{col 14}{cmd: set obs {c 'g}anything'}
{col 14}{cmd: drawnorm x e}
{col 14}{cmd: gen y = 1 + 0.5 * x + e}
{col 14}{cmd: reg y x}
{col 14}{cmd: return scalar x = _b[x]}
{col 14}{cmd: return scalar cons = _b[_cons]}
{col 10}{cmd: end} 

{col 10}{cmd: clear}
{col 10}{cmd: foreach coeff in x cons {c -(}}
{col 12}{cmd: local ToReturn "{c 'g}ToReturn' {c 'g}coeff' = r({c 'g}coeff')"}
{col 10}{cmd: {c )-} }
{col 10}{cmd: /* mulitshell loop */ forvalues n = 10 (10) 130 {c -(}}
{col 12}{cmd: simulate {c 'g}ToReturn' , reps(1000) : MonteCarloSim {c 'g}n'}
{col 12}{cmd: save "C:\documents\multishell\results\results_{c 'g}n'", replace	}
{col 10}{cmd: {c )-} }

{p 4 4}In the example above, {cmd:multishell} will skip over the 
loop {cmd: foreach coeff in x cons {c -(}}....{cmd: {c )-} }, but 
will recognize the loop marked with {cmd:/* multishell loop*/}.
{cmd:multishell} will automaticall detect if any loop is marked and then only process those.
If no loop is marked, it will process all.{break}
Thanks to Ben Jann for suggesting this option.
{p_end}

{marker killprocess}
{marker example6}{title: Example 6: Stopping multishell}

{p 4 4}Two options are available to restrict the running time of {cmd:multishell}. 
For both it is important that the only one instance of Stata is running
when {cmd:multishell} is started.{p_end}

{p 4 4}{ul: Setting a specific date and time to stop multishell}{p_end}

{col 10}{cmd:multishell run , ... stop(}{date time [,killall]}{cmd:)}

{p 4 4} specifies a date and time {cmd:multishell} will stop.
For example, a simulation is set up and supposed to run over the weekend. 
At Monday morning, say 1. October 2018 at 8.30am, it should stop, no matter if the 
simulations are finished or not.
Then multishell can be started with the following parameters:
{p_end}

{col 10}{cmd: multishell run, ... stop("1 Oct 2018 8:30")}

{p 4 4}In this case {cmd:mutlishell} will stop on 1st Oct 2018 at 8:30 to start 
new tasks. 
If set up as a server, no new tasks for the client will be assigned.
Running tasks in the background will be completed. 
To interrupt running tasks, the option {cmd: killall} can be used:{p_end}

{col 10}{cmd: multishell run, ... stop("1 Oct 2018 8:30, killall")}

{p 4 4}In this case all runnings tasks will be closed.{p_end}

{p 4 4}{ul:Note:} Date and time format have to be the same as stored in the macro
{cmd: c(current_date)}, see {help creturn##values :c(current_date)}.
Time can only be defined by hours and minutes, seconds are omitted.
The option {cmd:killall} has to be enclosed in parenthesis.{p_end}

{p 4 4}{ul: Setting a maximum time for a task}{break}
It is possible to abort a task after a specifed amount of time.
The following option can be used when {cmd:multishell} ist started:{p_end}

{col 10}{cmd: multishell run, ... maxtime(}{it:time}{cmd:)}

{p 4 4}where time is in the format hh:mm. 
For example if a task is limited to run for 10 minutes:{p_end}

{col 10}{cmd: multishell run, ... maxtime("0:10")}

{p 4 4}is used. Then any task is closed after 10 minutes.
Option {cmd:maxtime()} is computer specific. 
This means, if it is used on a server, but not on a client, tasks on a client
are allowed to run longer. Same principle applies to the opposite case.{p_end}

{p 4 4}{ul:Technical Notes}{break}
{ul:a)} If the options {cmd:maxtime()} and {cmd:stopp()} are invoked, {cmd:multishell}
maintains a computer specific list of running Stata instances and their 
Windows process id. 
The list is obtained from the command line of the operating system.
The process id is then used to stop a specific task.
When {cmd:multishell} is started, only one instance of Stata is allowed to run.
Otherwise it will get confused of which instance is the main instance.
If further Stata instances are started, for example to do some other 
work, {cmd:multishell} can get confused if the additional 
instance is started between a start of a new {cmd:multishell} Stata instance 
and a refresh.
This is more a hypothetical case, but can occur.{break}
{ul:b)} It is possible to re-start a {cmd:multishell} server or client, if it is done
from the same Stata instance.
In this case, option {cmd:continue} needs to be used.{break}
{ul:c)} Server and client are independent and 
{cmd:stop()} and {cmd:maxtime()}
need to be set on both machines. 
The server cannot kill a task on any client or vice versa.
{p_end}

{p 4 4}Thanks to Mark Schaffer and Adrian Sayers for the idea and discussions 
of this feature.{p_end}

{marker exampleZZ}{title: Example 7: Short Examples}

{p 4 4}The log files are saved in the subfolders for each variation in Z:\test.{p_end}

{p 4 4}{ul: nostop option}{break}
The {cmd:nostop} option is only available for the client. 
{cmd:multishell} will keep running after all variations are worked through. 
The option allows to finish one task and then start a new list of tasks from the server.
For example, the client is started {p_end}

{col 10}{cmd: ....}
{col 10}{cmd: multishell run client, threads(2) sleep(2000) nostop}

{p 4 4}and the do file {it: first simulation} is started from the server with:{p_end}

{col 10}{cmd: ....}
{col 10}{cmd: multishell add "C:\documents\first simulation.do"}
{col 10}{cmd: multishell run, threads(2) sleep(2000)}

{p 4 4}The file is processed and the simulations are finished. 
Then the {cmd: multishell} server stops.
The {cmd: multishell} client instance keeps running and awaits the next task.
If a new {cmd: multishell} instance is started on the server, like{p_end}

{col 10}{cmd: ....}
{col 10}{cmd: multishell add "C:\documents\second simulation.do"}
{col 10}{cmd: multishell run, threads(2) sleep(2000)}

{p 4 4}the client will pick it up and start running variations.
Thus, it is possible to start new instances of Stata on the client without being present in front of the actual computer.{p_end}

{marker problems}{title:Known Problems and Limitations}

{p 4 8} - {ul:In general} {cmd: multishell} has sometimes problem with mutliple Stata versions accessing the same files.
Errors are often caused by slow internet or network connections.
Restarting the do file usually helps.{p_end}
{p 4 8} - {ul:Seeds}, to obtain seeds from {browse www.random.org} an internet connection
is necessary. 
If {cmd: multishell seed} is used across computers with different versions 
of Stata (i.e. 14 and 15) problems with the seeds might occur. In general, it is
advisable to use the same version of Stata for all computers.{p_end}
{p 4 8} - {ul:Special characters in do files} such as single quotes ({c 'g} and '), double quotes ("), 
can produce an error message which can be ignored.{p_end}
{p 4 8} - {ul:Loops} {cmd: multishell} tries to dissect all loops, even if they are not part of the simulation or commented out (by a "*").
Best is to move all other loops into a separate do file and include it by using the Stata command {cmd: include}. 
Alternatively, mark only needed loops by /*multishell loop*/, 
see {help multishell##example5:Skipping loops}.{p_end}
{p 4 8} - {ul:locals in loops} at the moment it is not possible to use {cmd: locals} in the loops. 
For example the following does not work:{break}
{cmd: foreach arg in {c 'g}list' ...}{break}
The local {c 'g}list' is unknown to the Stata instance processing the foreach loop and therefore the loop would be empty.{p_end}
{p 4 8} - {ul:Missing spaces} between the name of the local and the equal sign lead lead to an error. 
For example {cmd: foreach n=1(1)10} does not work.
It is necessary to add a space between the name of the local and the equal sign, such as
{cmd: foreach n = 1(1)10}.{p_end}
{p 4 8} - {ul:Cloud services} such as Dropbox and Backup and Sync from Google can be slow synchronizing files.
Read/write errors are usually not common, but can occur.{p_end}
{p 4 8} - {ul:Read/write errors} occur if a file is not correctly closed. Best is to restart multishell.{p_end}
{p 4 8} - Only Windows is supported.{p_end}
{p 4 8} - If {cmd: multishell} is run on a mapped network drive, the log file is saved in the My documents folder.
This is a Windows/DOS bug. {p_end}
{p 4 8} - {help set more} needs to be set off.{p_end}
{p 4 8} - {cmd:multishell} only speed ups loops. 
It does not help to speed up existing Stata commands such as {cmd: regress}, {cmd: simulate}, etc.{p_end}


{marker about}{title:Author}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:j.ditzen@hw.ac.uk":j.ditzen@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{p 4 8}Thanks to Francesca Watson for reminding me using batch files to run multiple instances of Stata. 
{cmd:multishell} was presented at the Stata User Group Meeting 2018 in London and
I am greatful for many comments, especially (in alphabetical order) from 
Ben Jann, Yulia Marchenko, Tim Morris, Austin Nichols, Adrian Sayers and Mark Schaffer.
The program code to obtain random numbers from random.org is taken from
{help setrngseed}, written by William Gould and Antoine Terracol.
{p_end}

{p 4 8}Please cite as follows:{break}
Ditzen, J. 2018. multishell{p_end}

{p 4 8}The latest versions and examples can be obtained via {stata "net from http://www.ditzen.net/Stata"}.{p_end}


{marker disclaimer}{title:Disclaimer}

{p 4 4}{cmd: multishell} is a user-written command and comes with no warranty intended or implied. 
Please note that some of the functions involve deleting (sub)folders and files, so carefully check the folder before executing the command.
I do not take over responsibility for any computer crashes, lost work or financial losses following the use of {cmd:multishell}.{p_end}


{marker changelog}{title:Changelog}

{p 4 8}This version: 2.0 - 2. October 2018{p_end}


{title:Also see}

{p 4 4}See also: {help parallel}, {help qsub}, {help setrngseed}{p_end} 
