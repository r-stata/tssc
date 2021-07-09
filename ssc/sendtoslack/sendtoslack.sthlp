{smcl}
{* *! version 1.3.4  22may2020}{...}
{findalias asfradohelp}{...}
{title:sendtoslack}

{phang}
{bf:sendtoslack} {hline 2} Stata Module to send notifications from Stata to your smartphone through Slack


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: sendtoslack }
[{cmd:,} {it:{ul:u}rl(string) {ul:m}essage(string) method(string)} saveurlas(string)] 

{marker description}{...}
{title:Description}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt url}}your private slack url (instructions below){p_end}
{synopt:{opt message}}message you want to send to your slack {p_end}
{synopt:{opt method}}use alternative to powershell (currently only curl){p_end}
{synopt:{opt saveurlas}}store private slack url in profile.do (instructions at bottom)(read: save url as){p_end}
{syntab:Programmer}
{synopt:{opt col(#)}}moves all output from sendtoslack # spaces to the right{p_end}
{synoptline}
{p2colreset}{...}


{marker remarks}{...}
{title:Remarks}

{pstd}
There are three ways to use this command, in increasing usefulness and complication.

{pstd}
{bf: Option 1}: no Slack account and send to public chatroom

{tab}1. Go to https://statamessage.slack.com/
{tab}2. Sign in as 
{tab}{tab}statamessage@outlook.com 
{tab}{tab}test123
{tab}3. Go to the webhooks channel (you might already be there)(channels are listed at the top left)
{tab}  [warning: will send your computer's name to the public chatroom]
{tab}4. Return to Stata, and execute the {cmd:sendtoslack} command without specifying any options.
{tab}5. You should now see the default message in Slack, prefixed by your computer name.

{pstd}
{bf: Option 2}: create Slack account, send to public chatroom

{tab}1. Go to https://join.slack.com/t/statamessage/shared_invite/MjM0NTA0MzQwNzM3LTE1MDQyNjkwODQtZWE2NDliNGI4MQ
{tab}2. Enter your e-mail address
{tab}3. Follow the instruction to create your slack account (takes less than a minute)
{tab}{tab} Enter details
{tab}{tab} Skip inviting team members
{tab}{tab} Skip or follow the tutorial
{tab}{tab} Go to the webhooks channel (top left)
{tab}4. Return to Stata, and execute the {cmd:sendtoslack} command without specifying any options.
{tab}5. You should now see the default message in Slack, prefixed by your computer name.

{pstd}
{bf: Option 3}: create Slack account, send yourself a private message

{tab}1. Go to https://join.slack.com/t/statamessage/shared_invite/MjM0NTA0MzQwNzM3LTE1MDQyNjkwODQtZWE2NDliNGI4MQ
{tab}2. Enter your e-mail address
{tab}3. Follow the instruction to create your slack account (takes less than a minute)
{tab}{tab} Enter details
{tab}{tab} Skip inviting team members
{tab}{tab} Skip or follow the tutorial
{tab}{tab} Go to the webhooks channel (top left)
{tab}4. Go to https://statamessage.slack.com/apps/new/A0F7XDUAZ-incoming-webhooks
{tab}5. In "Post to Channel", select Privately to @(your name) and click "Add Incoming Webhooks integration"
{tab}6. Copy the "Webhook URL" (something along the lines of https://hooks.slack.com/services/code1/code2/code3)
{tab}7. Return to Stata, and execute {cmd:sendtoslack}{it:, url(paste the url here)}
{tab}8. You should now see the default message sent to yourself in Slack.

{pstd}
The best thing is that you can now install the Slack app on your smartphone, 
login and get a notification the instant your code has finished running 
(or get live updates, which can even contain regression results). 
You may need to modify the settings of the app to give you instant updates (default is 20 minutes delay).
This can be done by going to Settings - Notifications(Settings) - Start mobile notifications...
From what I've noticed so far, Slack doesn't send you a notification if it is also open in the web browser.

{pstd}
{bf: Using saveurlas}: Make your life easy by storing the URL in profile.do.

{tab} 1. Execute {cmd:sendtoslack}{it:, url}(<your private url>) {it:saveurlas}(<name>)
{tab} 2a. If you specified the name "default"
{tab}{tab} You can now use {cmd:sendtoslack} without the url option
{tab} 2b. If you specified a custom name, say "boss"
{tab}{tab} You can now use {cmd:sendtoslack}{it:, url(boss)} and it will send it to the url you stored

{pstd}
This command has only been tested on Windows. Non-windows users are invited to contact me so we can get it to work for them too. The default version will only work on Windows 8+/Server 2008+. 
Those using older versions should install curl and use the {it: method(curl)} option. On MACs, specifying {it:method(curl)} might work as well.

{marker examples}{...}
{title:Examples}

* Send default message to #webhooks channel
{phang}{cmd:sendtoslack}{p_end}

* Send default message to #webhooks channel (explicitly enter URL)
{phang}{cmd:sendtoslack, url(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw)}{p_end}

* Send custom message to #webhooks channel (..)
{phang}{cmd:sendtoslack, url(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw) message("Regression one has been completed.")}{p_end}

* Use saveurlas
** Store a url in profile.do (default)
{phang}{cmd:sendtoslack, url(https://hooks.sl{c 97}ck.com/services/T6XRDG3{c 56}E/BDRK{c 55}90Q7/b4FiICy1qG46NdCy26K4DQnw) saveurlas(default)}{p_end}

** Send custom message to stored url 
{phang}{cmd:sendtoslack, message("Regression one has been completed.")}{p_end}

** Store a url in profile.do (custom)
{phang}{cmd:sendtoslack, url("https://hooks.sl{c 97}ck.com/services{c 47}T6XRDG38E{c 47}B6WUW61B4{c 47}Yv{c 97}hNJxCFHi{c 97}fnYVlvlxs3V{c 55}") saveurlas(theAuthor)}{p_end}

* Send a message to someone else (me)
{phang}{cmd:sendtoslack, url("https://hooks.sl{c 97}ck.com/services{c 47}T6XRDG38E{c 47}B6WUW61B4{c 47}Yv{c 97}hNJxCFHi{c 97}fnYVlvlxs3V{c 55}") m(This program is the best!)}{p_end}

* Send a message to someone else (me), using the stored url
{phang}{cmd:sendtoslack, url(theAuthor) m(This program is the best!)}{p_end}


{marker integration}{...}
{title:Integrating sendtoslack in your own commands}

{pstd}
Sendtoslack really shines when it's integrated into other commands, which requires very little effort.

{tab}1. Add an option "sts(string)" to your syntax
{tab}2. Optionally, allow the user to send a custom message with the option "message(string)"
{tab}3. Add one of the following lines to your code
{tab}{tab}a. if "`sts'" != "" sendtoslack, url(`sts')
{tab}{tab}b. if "`sts'" != "" sendtoslack, url(`sts') message(`"`message'"')
{tab}{tab}c. if "`sts'" != "" sendtoslack, url(`sts') message(`"`message'"') col(4)
{tab}4. Done!

{pstd}
Users can even use their named urls by specifying that name in sts(), or their stored default by specifying sts(default).
The col(4) option shifts the output from sendtoslack 4 spaces to the right, which might look better in your output. Other integers are of course also possible.
Let me know if you would like to see any other functionality and I will see what's feasible.

{title:Author}
Jesse Wursten
Faculty of Economics and Business
KU Leuven
{browse "mailto:jesse.wursten@kuleuven.be":jesse.wursten@kuleuven.be} 

Inspired by {cmd:statapush}.
