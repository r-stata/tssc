{smcl}
{* *! version 1.2.1 22aug2019}{...}
{findalias asfradohelp}{...}
{title:batcher}

{phang}
{bf:batcher} {hline 2} Simple task paralleliser for Stata dofiles


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: batcher }{it:{help filename}}
{cmd:,} {it: {ul:i}ter(numlist) {ul:t}empfolder(string)} {it:options}

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt i:ter(numlist)}}iterations you want to execute{p_end}
{synopt:{opt t:empfolder(string)}}folder to store logs (used to track progress) {p_end}
{synopt:{opt sts(string)}}{help sendtoslack} url or saved name to get updates on success/failure{p_end}
{synopt:{opt sl:eepduration(integer)}}delay between start of dofiles and completion tracking{p_end}
{synopt:{opt notrack}}disable progress tracker{p_end}
{synopt:{opt sts_exceptsuccess}}only send message to slack on failure{p_end}
{synopt:{opt nostop}}do not stop dofile on error (see {mansection R do:do manual entry [PDF]}){p_end}
{synopt:{opt noquit}}keep Stata windows of iterations open after completion{p_end}
{synopt:{opt save:options(string)}}saves specified options as default (so you can omit them){p_end}
{synopt:{opt st:ataexe(string)}}path to the Stata exe, normally not required{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:batcher} is a simple way to parallelise tasks in Stata {p_end}

{p 8 12} 1. You specify which dofile to run and add an iteration number {break}

{p 8 12} 2. {cmd:batcher} starts the dofile, feeds in the iteration number {break}

{p 8 12} 3. The code in the dofile takes this iteration number to determine what to do{break}

{p 8 12} 4. The main Stata window tracks progress by reading log files{break}

{p 8 12} 5. Optionally send completion/failure updates to your phone through {help sendtoslack}{break}


{pstd}
The main inspiration for this command was frustration with existing parallelisation programs. They were either too complicated to use
or somehow failed to provide the results I needed. Instead, batcher is very straightforward to use and only requires minor changes
to the underlying dofile. There is no magic under the hood (except maybe the progress tracker). The code in your dofile determines
how the parallelisation happens, where everything is saved, etc. This program simply saves you the effort of opening multiple Stata windows
and fixing the setting each time. {p_end}

{pstd}
Finally, to cater to my own laziness, {cmd:batcher} has a {cmdab:save:options} feature, which places any options you specified 
in the profile.do file. The command will then use these options the next time you use {cmd:batcher}, 
without requiring you to add the options (overwrite by typing "overwrite", see examples). 
It's quite cool, even though I say so myself.

{marker options}{...}
{title:Options}

{phang}
{opt i:ter(numlist)} This is the key of the whole program. Provide a numlist here, each element of which will be fed to your dofile as first argument.
See the examples for more info.

{phang}
{opt t:empfolder(string)} This option is required. You can simply point this to your Stata working directory, or to some Dropbox folder, it really
does not matter. I recommend saving this option through saveoptions (see later) so you only have to specify it once.

{phang}
{opt sts(string)} If you specify a valid {cmd:sendtoslack} url or name in sts(), {cmd:batcher} will send a message to the specified Slack room (-> your smartphone) to inform you
upon errors or completion. If you want to send to the default you saved in {cmd:sendtoslack}, specify url(default). See {help sendtoslack} for more information.

{phang}
{opt sl:eepduration(string)} Personal preference. By default batcher waits 60 seconds to start the tracker, but on slow PCs this might cause issues, while for short programs this might be too long. The sleep duration
is defined in seconds.

{phang}
{opt notrack} I don't know why you'd want to disable the tracker, but with this option you can.

{phang}
{opt sts_exceptsuccess} Only meaningful if specified with sts(). Prevents the program from sending messages to slack on successes. Mainly relevant
if you are running many iterations and don't want to get spammed.

{phang}
{opt nostop} This is a dofile option. Prevents the dofile from stopping on errors.

{phang}
{opt noquit} By default, {cmd:batcher} closes the windows it opens to run the iterations. Specify noquit to keep them open.

{phang}
{opt st:ataexe(string)} You shouldn't need to use this option as {cmd:batcher} uses internal machinery to detect the location of the Stata executable.
But if for some reason that would fail, you could manually specify it here.

{phang}
{opt save:options(string)} Some of these options you might want to use all the time (e.g. you generally only use one {help sendtoslack} url for the smartphone updates).
 If you execute {cmd:batcher} with {it:saveoptions(string)}, it will save any specified options to {help profile}.do.
 Any subsequent use of {cmd:batcher} will then use these options. In exceptions, you can specify that option with an "overwrite" argument.
 That will not work for argument-free options. In that case you will have to clear the global yourself (e.g. global batcher_run "").
 The examples might clarify this a bit.

{marker examples}{...}
{title:Examples}
{p 4 4}Showing examples for {cmd:batcher} is somewhat tricky, as it requires a dofile to run. {break} We provided an example dofile to illustrate 
some of the possibilities. {break} This dofile was saved in the same folder as the ado file. {break} Execute the following code to gain access to the location
of this dofile.{p_end}
{p 8 8} {cmd:. qui findfile batcher.ado} {break}
{break} {cmd:. global examplePath = subinstr("`r(fn)'", "batcher.ado", "exampleDofile.do", .)}{p_end}

{p 4 8} The code below opens this dofile, so you can use it as inspiration for your own projects. {break}
 {cmd:. doed $examplePath} {p_end}
 
{p 4 8 4} Let's try a first parallelisation exercise. {break}
 {cmd: . batcher $examplePath, i(1/2) tempfolder(`c(pwd)')} {break}
 Normally, this opened two stata windows. In the first it mentioned displaying 1, in the second displaying two. {break}
 This is because we first fed "1" to the dofile, then "2". You would find a log of the two runs in your current working directory (c(pwd)).{p_end}
 
{p 4 8 4}Next, we want to be informed on progress in Slack.{break}
 {cmd:.  batcher $examplePath, i(3/4) tempfolder(`c(pwd)') sts(https://hooks.slack.com/services/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)}{break}
 This performed two regressions, with different independent variables in each iteration. It also sent messages to the webhooks channel {break}
 when each iteration finished and at the end.{p_end}

{p 4 8 4}Now let's see what happens when an iteration fails{break}
 {cmd:.  batcher $examplePath, i(5/7) tempfolder(`c(pwd)') sts(https://hooks.slack.com/services/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) sts_exceptsuccess}{break}
 This attempted to calculate three means of prices. One for domestic cars, one for foreign cars and one for the non-existent category 999.{break}
 The first two ran without issue. But the third ended with a failure. We only received a message in slack for this failed iteration because {break} 
 we specified the sts_exceptsuccess option. At the end of the batcher run, we were again informed that this iteration failed.{p_end}

{p 4 8 4}Now let's save the tempfolder option specified{break}
 {cmd:.  batcher $examplePath, saveoptions(tempfolder) i(1/2) tempfolder(`c(pwd)')}{break}
 If you didn't have a profile.do yet, it created this file for you. Then it added one line to it which saves the tempfolder option. {break}
 Every time you start Stata, this global is defined and batcher knows where to find it. As a result, you no longer need to specify the option, {break}
 which we illustrate below.
 {p_end}
 
{p 4 8 4}Use saved option{break}
 {cmd:.  batcher $examplePath, i(1/2)}{break}
 {cmd:batcher} used the tempfolder you saved earlier, without requiring you to specify the option.
 {p_end}

	
{title:Author}

Jesse Wursten
Faculty of Economics and Business
KU Leuven
jesse (dot) wursten (at) kuleuven (dot) be}

Other commands by the same author

{synoptset 14 tabbed}{...}
{synopt:{cmd:sendtoslack}} Stata Module to send notifications from Stata to your smartphone through Slack{p_end}
{synopt:{cmd:stop}} Stata command to interrupt dofiles intelligently (closes logfiles and optionally sends a message to your smartphone){p_end}
{synopt:{cmd:xtqptest}} Bias-corrected LM-based test for panel serial correlation{p_end}
{synopt:{cmd:xthrtest}} Heteroskedasticity-robust HR-test for first order panel serial correlation{p_end}
{synopt:{cmd:xtistest}} Portmanteau test for panel serial correlation{p_end}
{synopt:{cmd:xtcdf}} CD-test for cross-sectional dependence{p_end}
{synopt:{cmd:timeit}} Easy to use single line version of timer on/off, supports incremental timing{p_end}
{synopt:{cmd:pwcorrf}} Faster version of pwcorr, with builtin reshape option{p_end}
{synopt:{cmd:cdo}} Alternative to Stata's do: get an update when the dofile stalls and other quality of life improvements {p_end}
{p2colreset}{...}


