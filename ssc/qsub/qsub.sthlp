{smcl}
{* *! version 1.0  02/10/2015 Adrian Sayers}{...}
{cmd:help qsub}
{hline}

{title:Title}

{phang}
{cmd:qsub} {hline 2} queue submission program to emulate a cluster environment using your desktop PC.

{title:Syntax}

{p 8 17 2}
{cmd:qsub} , {opth jobdir(string)}
[{cmd:} {opth maxp:roc(integer)}  
{opth queue:sheet(string)}
{opth flags:tart(string)}
{opth flage:nd(string)}
{opth wait(integer)}
{opth waitb4:append(integer)}
{opth statadir(string)}
{opt append}
{opth outputdir(string)}
{opth outputsave:name(string)}
{opt deletelogs}
    ]

{title:Description}

{pstd}{cmd:qsub} is a queue submission program that compiles a lists of jobs in a folder and then submits them to different instances of Stata on a desktop computer, and then compiles results if requested.{p_end}

{pstd} The program provides a simple way to perform simulation studies, bootstrapping, multiple imputation, data level parallelisation operations and other computationally intensive tasks on a desktop PC utilising all available CPUs. It is also a useful way to debug programs before uploading them to a cluster environment.{p_end}

{pstd} Prior to using {cmd:qsub}, you are required to create a directory containing all the jobs you intend to implement, and optionally a folder to store results or data within. {p_end}

{pstd} By default {cmd:qsub} creates .log file for each instance of every evoked stata session, and records the output. These logs are excellent way of debugging mistakes and errors. {p_end}

{title:Compulsory Options}

{phang} {opth jobdir(string)} Specifies the directory of stored job files.{p_end}


{title:Optional Options}

{phang} {opth maxp:roc(integer)} Specifies the number of processors available for use on your desktop machine, default is 2.{p_end}

{phang} {opth queue:sheet(string)} Specify the name of the queuesheet of jobs to be completed, default is "queuesheet.dta".{p_end}

{phang} {opth flags:tart(string)} Specifies the number of processors available for use on your desktop machine, default is "flagstart.dta".{p_end}

{phang} {opth flage:nd(string)} Specifies the name of the  of processors available for use on your desktop machine, default is "flagend.dta".{p_end}

{phang} {opth wait(integer)} Specifies the length of pause in seconds between looking for completed jobs, default is 1. Longer pauses should be used for jobs that take a long time, and short pauses for faster jobs.{p_end}

{phang} {opth waitb4:append(integer)} Specifies the length of pause before appending results, default is 1. Longer pauses should be used for slow systems with long lags when reading writing data.{p_end}

{phang} {opth statadir(string)} Specifies the directory of Stata, default is "C:\Program Files (x86)\Stata14\StataMP-64.exe". However this is simply changed by editing the .ado file if required.{p_end}

{phang} {opt append} Instructs Stata to append outputs into a single file.{p_end}

{phang} {opth outputdir(string)}} Specifies where outputed results will be stored.{p_end}

{phang} {opth outputsave:name(string)} Specify the name of the appended files.{p_end}

{phang} {opt deletelogs} Instructs Stata to delete *.log files created during the batch process.{p_end}

{title:How qsub works}

{pstd} 1. {cmd:qsub} compiles a list of jobs saved in {opth jobdir(string)} and saves them into a file which is named using {opth queuesheet(string)} suboption, if no name is specified the default file name "queuesheet.dta" is created. {p_end}

{pstd} 2. {cmd:qsub} then uses the queuesheet to assign jobs to an instance of stata based on the maximum number of processors indicated to be available for use using the {opth maxproc(integer)} option. {p_end}

{pstd} 3. {cmd:qsub} appends a few lines of codes at the beginning and end of each do file to create indicator files to show when a job has started and when a job has ended. The indicator files are named using the {opth flagstart(string)} and {opth flagend(string)} suboptions. If no options are specified the default names are used.{p_end}

{pstd} 4. {cmd:qsub} assigns jobs based to a Stata instance based on the indicated number of processors available {opth maxproc(integer)}, and reassigns jobs when the process has finished. {p_end}

{pstd} 5. {cmd:qsub} then waits untill all jobs are finished before control is returned to Stata. {p_end}

{title:Optionally}

{pstd} 6. {cmd:qsub} can compile outputs saved in a specific directory {opth outputdir(string)} and saves them in a single file specified by {opth outputsavename(string)}. {p_end}

{pstd} 7. {cmd:qsub} then deletes all log files "*.log" in the working directory, log files are automatically created when running Stata in batch mode from the working directory. {p_end}

{hline}

{title:Example: Simulation}

{phang} * Clear and then create a job, output and data directory. {p_end}
{phang} * {hilite:!WARNING!} ! rmdir "folder" /s /q forcefully removes {ul:all} content, useful for quick clears when debugging but be careful. {hilite:!WARNING!} {p_end}

{phang}	{bf: mkdir _output} {p_end}
{phang}	{bf: mkdir _queue}{p_end}
{phang}	{bf: mkdir _data} {p_end}

{phang} * Create your simulated data of interest {p_end}

{phang} {bf:set seed 1} {p_end}
{phang} {bf:clear} {p_end}
{phang} {bf:set obs 50} {p_end}
{phang} {bf:gen x = 100*uniform() } {p_end}
{phang} {bf:gen y = 10 + 0.1*x } {p_end}
{phang} {bf:save _data/design.dta , replace } {p_end}

{phang} * Write a loop which creates a jobfile which echoes a {cmd:do} using mysimfile with arguments.{p_end}
{phang}	{bf: forvalues sim = 1/10 {c -(} } {p_end}
{phang} {bf: file open  mydofile using _queue\sim`sim'.do, write replace} {p_end}
{phang} {bf: file write mydofile `"do mysimfile.do `sim' "'}  {p_end}
{phang} {bf: file close mydofile} {p_end}
{phang} {bf: {c )-}} 	{p_end}

{phang}	* Where mysimfile.do contains your code of interest for example: {p_end}

{phang} * ----mysimfile.do----------------------------------------------------------------{p_end}
{phang} * postfile results sim cons cons_se x x_se using _output/results`1'.dta, replace {p_end}
{phang} * use _data/design.dta , clear {p_end}
{phang} * set rngstream `1' {p_end}
{phang} * set seed 1{p_end}
{phang} * gen e =15*invnorm(uniform()) {p_end}
{phang} * gen yobs = y + e {p_end}
{phang} * reg yobs x  {p_end}
{phang} * post results (`1') (_b[_cons]) (_se[_cons]) (_b[x]) (_se[x]) {p_end}
{phang} * postclose results {p_end}
{phang} * --------------------------------------------------------------------------------{p_end}
	
{phang} {bf: qsub , jobdir(_queue) maxproc(8) append deletelogs outputdir(_output) outputsavename(simresults.dta) } {p_end}

{hline}

{title:Example: Bootstrap}

{phang} * Clear and then create a job, output and data directory. {p_end}
{phang} * {hilite:!WARNING!} ! rmdir "folder" /s /q forcefully removes {ul:all} content, useful for quick clears when debugging but be careful. {hilite:!WARNING!} {p_end}

{phang}	{bf: mkdir _output} {p_end}
{phang}	{bf: mkdir _queue}{p_end}
{phang}	{bf: mkdir _data} {p_end}

{phang} *  Write a loop which creates a jobfile which echoes a do using mybootfile with arguments.{p_end}
{phang} {bf:forvalues bs = 1/10 {c -(} } {p_end}
{phang} {bf:file open mydofile using _queue\boot`bs'.do, write replace} {p_end}
{phang} {bf:file write mydofile `"do mybootfile.do `bs' "'} {p_end}
{phang} {bf:file close mydofile} {p_end}
{phang} {bf:   {c )-}} {p_end}

{phang}	* Where mybootfile.do contains your code of interest for example: {p_end}

{phang} * ----mybootfile.do----------------------------------------------------------------{p_end}
{phang} * postfile results i proportion using _output/boot`1'.dta, replace {p_end}
{phang} * webuse bsample1 ,clear{p_end}
{phang} * set rngstream `1'{p_end}
{phang} * set seed 1 {p_end}
{phang} * bsample {p_end}
{phang} * ci proportion female ,  wald  {p_end}
{phang} * post results (`1') (`r(proportion)')  {p_end}
{phang} * postclose results {p_end}
{phang} * --------------------------------------------------------------------------------{p_end}

{phang} {bf: qsub , jobdir(_queue) maxproc(8) append deletelogs outputdir(_output) outputsavename(bootresults.dta) } {p_end}

{hline}

{title:Example: Multiple Imputation}

{phang} * Clear and then create a job, output and data directory. {p_end}
{phang} * {hilite:!WARNING!} ! rmdir "folder" /s /q forcefully removes {ul:all} content, useful for quick clears when debugging but be careful. {hilite:!WARNING!} {p_end}

{phang}	{bf: mkdir _output} {p_end}
{phang}	{bf: mkdir _queue} {p_end}

{phang}	* Load some pretend data & remove mi set {p_end}
{phang}	{bf:webuse mheart8s0 , clear} {p_end}
{phang}		{bf:mi unset} {p_end}
{phang}			{bf:drop mi_*} {p_end}
{phang}				{bf:gen id = _n} {p_end}
{phang}					{bf:save mheart8s0 , replace} {p_end}

{phang} *  Write a loop which creates a jobfile which echoes a do using mymifile with arguments.{p_end}
{phang} {bf:forvalues mi = 1/10 {c -(} } {p_end}
{phang} {bf:file open mydofile using _queue\mi`mi'.do, write replace} {p_end}
{phang} {bf:file write mydofile `"do mymifile.do `mi' "'} {p_end}
{phang} {bf:file close mydofile} {p_end}
{phang} {bf:   {c )-}} {p_end}

{phang} {bf: qsub , jobdir(_queue) maxproc(4) deletelogs} {p_end}

{phang} * Analyse imputed datasets {p_end}
{phang} {bf: use mheart8s0 , clear}	{p_end}
{phang} {bf: cd _output} {p_end}
{phang} {bf: mi import flongsep myimp , using( _1_imp{1-10} ) id(id) clear imputed( age bmi)} {p_end}
{phang} {bf: mi estimate : logit smokes age bmi , or} {p_end}



{phang} * ----mymifile.do----------------------------------------------------------------{p_end}
{phang} * Load original data & mi set {p_end}
{phang}  use mheart8s0 , clear {p_end}

{phang} * Change Directory to _output {p_end}
{phang}  cd _output {p_end}

{phang} * Seperate Imputation locations to avoid conflicts in temporary files & change directory {p_end}
{phang} mkdir imp`1' {p_end}
{phang}	cd imp`1' {p_end}
	
{phang}  mi set flongsep imp`1' {p_end}
{phang}  set rngstream `1' {p_end}
{phang}  set seed 1 {p_end}

{phang}  * Specify Imputation {p_end}
{phang}  mi register imputed bmi age {p_end}
{phang}  mi impute chained (regress) bmi age = attack smokes hsgrad female, add(1) {p_end}

{phang} * Remove mi indicators, and pretend its from an external source {p_end}
{phang}  use _1_imp`1' , clear {p_end}
{phang}  drop _mi_id  {p_end}
{phang}  save _1_imp`1' , replace {p_end}

{phang} * Erase mi set copy of original {p_end}
{phang}  erase imp`1'.dta 	 {p_end}

{phang} * Move Imputed to dataset to central location and tidy up {p_end}
{phang} copy  imp`1'\_1_imp`1'.dta _1_imp`1'.dta , replace {p_end}
{phang} erase imp`1'\_1_imp`1'.dta {p_end}
{phang} rmdir imp`1' {p_end}

{phang} * Return to root folder {p_end}
{phang}  cd .. {p_end}
{phang} * --------------------------------------------------------------------------------{p_end}

{hline}

{title:Example: Data Level Parallelisation}
{phang}* Clear and then create an output and job directory. {p_end}
{phang} * {hilite:!WARNING!} ! rmdir "folder" /s /q forcefully removes {ul:all} content, useful for quick clears when debugging but be careful. {hilite:!WARNING!} {p_end}

{phang}	{bf: mkdir _output} {p_end}
{phang}	{bf: mkdir _queue}{p_end}

{phang}* Create some source data. {p_end}

{phang} {bf:set seed 1} {p_end}
{phang} {bf:clear} {p_end}
{phang} {bf:set obs 200000} {p_end}
{phang} {bf:gen myid = round(50* uniform(),1.0) } {p_end}
{phang}	{bf: save mylist.dta , replace} {p_end}

{phang}* Read in your source data and create a list of variables to parallelise your code over. {p_end}
{phang}	{bf: use mylist.dta , clear} {p_end}
{phang}	{bf: levelsof myid , local(myidlist)} {p_end}

{phang}* Write a loop which creates a jobfile which echoes a {cmd:do} using mydofile with arguments.{p_end}
{phang}	{bf: foreach id in `myidlist'} {c -(} {p_end}
{phang} {bf: file open  mydofile using _queue\job_`id'.do, write replace} {p_end}
{phang} {bf: file write mydofile `"do mydofile.do `id' "'}  {p_end}
{phang} {bf: file close mydofile} {p_end}
{phang} {bf: {c )-}} 	{p_end}

{phang}* Where mydofile.do contains your code of interest for example: {p_end}

{phang}*---mydofile.do--------------------------------------{p_end}
{phang}*	 sysuse mylist.dta ,clear  {p_end}
{phang}*	 keep if myid==`1'  {p_end}
{phang}*	 egen count = count(myid) {p_end}
{phang}*	 save _output\myid`1' , replace {p_end}
{phang}*----------------------------------------------------{p_end}

{phang} {bf: qsub , jobdir(_queue) maxproc(8) append deletelogs outputdir(_output) outputsavename(compiledresults.dta) } {p_end}

{hline}


{title:TopTip}
{pstd} Mount a RAM DISK. This speeds up the reads and writes of datasets and makes everything run more smoothly.

{title:Remarks}
{pstd} {cmd:qsub} is deliberately written as a light program with a very specific focus. I hope the focussed nature will allow greater flexibility given the wide variety of potential uses.{p_end}
{pstd} {cmd:qsub} also does not asign an instance of Stata to a specific processor. {cmd:qsub} spawns instances and hopes Windows will assign them to processors in a sensible way.{p_end} 

{title:Disclaimer}
{p 4 4 2} {bf:qsub} comes with no warranty intended or implied.  We recommend that users check their results with those obtained through other algorithms.  Users are also encouraged to check their results with those produced by other statistical software.{p_end}

{title:Author}

{pstd} Adrian Sayers {p_end}
{pstd} University of Bristol{p_end}
{pstd} adrian.sayers@bristol.ac.uk {p_end}
{pstd}  {p_end}

{title:Acknowledgements}
{pstd} I would like to thank Nick Cox for allowing me to incorporate the {cmd:filei} command which is used to write lines of code at the beginning of the do file. I am also grateful to Tim Morris for testing {cmd:qsub} and providing helpful comments.{p_end}

{title:Also see}

{pstd}
{help parallel:parallel} {help set rngstream:set rngstream} {help mirubin :mirubin }
{p_end}
