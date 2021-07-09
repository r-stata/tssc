{smcl}
{* *! version 1.0.2 22may2020}{...}
{findalias asfradohelp}{...}
{title:stop}

{phang}
{bf:stop} {hline 2} Stata command to interrupt dofiles intelligently (closes logfiles and optionally sends a message to your smartphone)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: stop }
[{cmd:,} {it:sts(string) {ul:m}essage(string)} {ul:l}ogfile(string)} {ul:save}options] 

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sts(string)}}sendtoslack url, name or "default"{p_end}
{synopt:{opt message(string)}}message you want to display and optionally send to slack {p_end}
{synopt:{opt logfile(string)}}logfile to close (default: any open logfiles){p_end}
{synopt:{opt save}}saves specified options as default (so you can omit them){p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stop} stops dofiles, closes any running logfiles and optionally sends a message to your smartphone (see {help sendtoslack}). 
The main inspiration for this command is frustration - often you want to run a dofile up to a certain point and evaluate the results. In simple cases, an "exit" or "error 1" works just fine.
But when you are running the same dofile in multiple instances (potentially on different machines), this gets tricky, because any log files you have open will now
throw an error if you try to use them elsewhere. 
Moreover, if your dofiles take ages to run, it would be great if you were informed when they finish.

{pstd}
This command saves you the hassle of coding all those things manually (every time). {cmd:stop} will close any logfiles that are open (or just some of them, see below). If desired, 
it will then inform you that you reached the stopping point by sending a message to your cellphone through Slack. Once that's done, it will 
stop the dofile by throwing an {cmd:error 1}, which is equivalent to pressing the red break button in the command window.

{pstd}
Finally, to cater to my own laziness, {cmd:stop} has a {it:save} option, which places any options you specified in the profile.do file.
The command will then use these options the next time you call for a {cmd:stop}, without requiring you to add the options. It's quite cool, even though I say so myself.

{marker options}{...}
{title:Options}

{phang}
{opt sts(string)} If you specify a valid {cmd:sendtoslack} url or name in sts, {cmd:stop} will send a message to the specified Slack room to inform you
the dofile {cmd:stop}ped. If you want to send to the default you saved in {cmd:sendtoslack}, specify sts(default). See {help sendtoslack} for more information about
saving {cmd:sendtoslack} urls as names or defaults.

{phang}
{opt message(string)} The message option is mainly interesting if you are sending messages to a Slack room, as it allows you to customise said message. This is particularly
useful when {cmd:stop}ping multiple dofiles, as you can then use the message to distinguish which one has finished.

{phang}
{opt logfile(string)} There might be moments when you don't want to close all logfiles. The logfile option allows you to specify
the name of the logfile to be stopped, allowing any other to continue.

{phang}
{opt save} It is tiresome to specify these options all the time. The save option stores the options you provided in your profile.do 
file. A simple {cmd:stop} without any options would then send the correct message to the right Slack room (and stop the right logfile). See the examples for an illustration.


{marker examples}{...}
{title:Examples}

{pstd}Stop dofile, close all logs.{p_end}
{phang2}{cmd:. log using temp, replace}{p_end}
{phang2}{cmd:. stop}{p_end}

{pstd}Stop dofile, close all logs and send a message to Slack{p_end}
{phang2}{cmd:. log using temp, replace}{p_end}
{phang2}{cmd:. stop, sts(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}

{pstd}Stop dofile, close specific log and send a custom message{p_end}
{phang2}{cmd:. log using temp, replace name(keepRunning)}{p_end}
{phang2}{cmd:. log using temp2, replace name(closeThisOne)}{p_end}
{phang2}{cmd:. stop, message(A custom message) logfile(closeThisOne) sts(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}
{phang2}{cmd:. log close keepRunning}{p_end}

{pstd}Save sts url and message (will not stop program or close logfiles){p_end}
{phang2}{cmd:. log using temp, replace}{p_end}
{phang2}{cmd:. stop, save m(This is a saved custom message!) sts(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}
{phang2}{cmd:. log close _all}{p_end}

{pstd}Use saved url and message{p_end}
{phang2}{cmd:. log using temp, replace}{p_end}
{phang2}{cmd:. stop}{p_end}

{pstd}Do {it:not} use saved url and message (just stop){p_end}
{phang2}{cmd:. log using temp, replace}{p_end}
{phang2}{cmd:. stop, sts(overwrite) m(overwrite)}{p_end}

{title:Author}

Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 

Other commands by the same author

{synoptset 14 tabbed}{...}
{synopt:{cmd:sendtoslack}} Stata Module to send notifications from Stata to your smartphone through Slack{p_end}
{synopt:{cmd:xtqptest}} Bias-corrected LM-based test for panel serial correlation{p_end}
{synopt:{cmd:xthrtest}} Heteroskedasticity-robust HR-test for first order panel serial correlation{p_end}
{synopt:{cmd:xtistest}} Portmanteau test for panel serial correlation{p_end}
{synopt:{cmd:xtcdf}} CD-test for cross-sectional dependence{p_end}
{synopt:{cmd:timeit}} Easy to use single line version of timer on/off, supports incremental timing{p_end}
{synopt:{cmd:pwcorrf}} Faster version of pwcorr, with builtin reshape option{p_end}
{p2colreset}{...}


