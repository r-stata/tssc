{smcl}
{* *! version 2.1.2 22may2020}{...}
{findalias asfradohelp}{...}
{title:cdo}

{phang}
{bf:cdo} {hline 2} Alternative to Stata's do: get an update when the dofile stalls and other quality of life improvements


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: cdo }{it:{help filename}}
[{cmd:,} {it: {ul:a}rguments(string)}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt a:rguments(string)}}any arguments you want to pass on to your dofile{p_end}
{synopt:{opt u:rl(string)}}{help sendtoslack} url or saved name to get updates (on success/failure){p_end}
{synopt:{opt p:rogram(string)}}program you want to run on program end (...){p_end}
{synopt:{opt l:og(log_opts)}}make a log (some extra features described below){p_end}
{synopt:{opt nocopy}}do not make a local copy of the dofile{p_end}
{synopt:{opt r:un}}run dofile instead of do-ing it{p_end}
{synopt:{opt save:options}}saves specified options as default (so you can omit them){p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cdo} is just like Stata's default {help do} but then with some extra features. {p_end}

{p 8 12} 1. Executes a local copy of the dofile instead of the original file {break}
-> You can still edit the dofile while it is running (no sharing violation errors) {break}
-> Your program won't halt when the connection between your computer and the dofile is broken (e.g. you unplugged external drive or server lost connection){p_end}
{p 8 12} 2. Can send an update on errors/completion to your smartphone with the url() option{p_end}
{p 8 12} 3. Can execute a program upon errors/completion {break}
-> E.g. log out of pay-per-minute server {p_end}
{p 8 12} 4. Create log files internally {break}
-> Functionality built in to add time/date to name of logfile{p_end}

{pstd}
The main inspiration for this command was frustration. Often I'd start a long dofile and move on, only for it to crash after 5 lines because of some stupid coding mistake.
 Likewise, I've lost many computer-hours due to network issues
 causing the server to lose access to the dofile and just stopping dead in its tracks.
 This, and many other problems can be fixed by using this command. {p_end}

{pstd}
Finally, to cater to my own laziness, {cmd:cdo} has a {cmdab:save:options} feature, which places any options you specified in the profile.do file.
The command will then use these options the next time you use {cmd:cdo}, without requiring you to add the options (overwrite by typing "overwrite" or "no", see examples). It's quite cool, even though I say so myself.

{marker options}{...}
{title:Options}

{phang}
{opt arguments(string)} Known by few, it is possible to pass arguments to your dofile. For more info, see the {mansection R do:manual section}.

{phang}
{opt url(string)} If you specify a valid {cmd:sendtoslack} url or name in url(), {cmd:cdo} will send a message to the specified Slack room (-> your smartphone) to inform you
upon errors or completion. If you want to send to the default you saved in {cmd:sendtoslack}, specify url(default). See {help sendtoslack} for more information.

{phang}
{opt program(string)} You can tell cdo to execute a certain program on errors/completion.
 This program will also be able to access the return code (error) that the dofile produced,
 which allows you to distinguish your response based on successful or failed execution.
 See the worked example for more info.

{phang}
{opt log(log_opts)} The log() syntax is as follows: log({help filename} [, append replace text smcl date time forcemsg]).
 {it:filename} is where you want to save the log.
 {it:append/replace/text/smcl} are standard {help log} options.
 {it:date} and {it:time} will respectively add the current date and time to the logfile's document name.
 {it:forcemsg} tells cdo to display the msg you get when you close a log (by default it is omitted).

{phang}
{opt save:options} Some of these options you might want to use all the time (e.g. you generally only use one url for the smartphone updates).
 If you execute {cmd:cdo} with {it:saveoptions}, it will save any specified options to {help profile}.do.
 Any subsequent use of {cmd:cdo} will then use these options. In exceptions, you can specify that option with an "overwrite" or "no" argument.
 That will not work for argument-free options. In that case you will have to clear the global yourself (e.g. global cdo_run "").
 The examples might clarify this a bit.

{marker examples}{...}
{title:Examples}

{p 4 8}Execute the copy of a dofile {break} {cmd:. cdo "C:/StataWD/sleep 2000.do"}{p_end}

{p 4 8}Run the copy instead {break} {cmd:. cdo "C:/StataWD/sleep 2000.do", run}{p_end}

{p 4 8}Save a text log called thelog. {break} {cmd:. cdo "C:/StataWD/sleep 2000.do", log(C:/StataWD/thelog, replace text)}{p_end}

{p 4 8}Save a text log and call it thelog_28Nov2018_165504 (at time of writing){break} {cmd:. cdo "C:/StataWD/sleep 2000.do", log(C:/StataWD/thelog, replace text date time)}{p_end}

{p 4 8}Execute a dofile (don't copy it first){break} {cmd:. cdo "C:/StataWD/sleep 2000.do", nocopy}{p_end}

{p 4 8}Send a message to webhooks channel upon completion/error{break} {cmd:. cdo "C:/StataWD/sleep 2000.do", url(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}

{p 4 8}Perform program upon completion/error {break}
	{cmd:program define helloWorld} {break}
	{cmd:. di "Hello World"} {break}
	{cmd:. if `s(returnCode)' == 0 di "Success!"} {break}
	{cmd:. if `s(returnCode)' != 0 di "Failure!"} {break}
	{cmd:end} {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", program(helloWorld)}{p_end}
	
{p 4 8} Save url option {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", saveoptions url(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}
{p 4 8} Use saved option {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do"}{p_end}	
	
{p 4 8} Save run option {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", saveoptions run}{p_end}
{p 4 8} Use saved run option, but not the saved url {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", url(no)} {p_end}
{p 4 8} Do not use saved options {break}
	{cmd:. global cdo_run ""} {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", url(no)} {break}
	{cmd:. cdo "C:/StataWD/sleep 2000.do", url(overwrite)} {break}{p_end}

	
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
{p2colreset}{...}


