{smcl}
{* *! version 1.3.0  26jun2018}{...}
{findalias asfradohelp}{...}
{title:censusapi}

{phang}
{bf:stop} {hline 2} Stata command to download Census data through the Census API


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd: censusapi }
{cmd:,} [url(string)] [{ul:dest}ination(string)] [dataset(string) {ul:var}iables(string) predicate(string)] [key(string) savekey]

{synoptset 20 tabbed}{...}
{synoptline}
{synopt:{opt url(string)}} most basic option, simply paste the url here you'd normally enter in the browser{p_end}
{synopt:{opt destination(string)}} where you want to save the data you retrieved, include the .txt suffix{p_end}
{synoptline}
{synopt:{opt dataset(string)}} dataset you want to access, e.g. sf1{p_end}
{synopt:{opt variables(string)}} variables you want to retrieve, things such as P0100001-P0100022 are allowed{p_end}
{synopt:{opt predicate(string)}} the predicate part which determines your datasplit, e.g. "for=place:*&in=state:12"{p_end}
{synoptline}
{synopt:{opt key(string)}} your Census API key (required for larger requests){p_end}
{synopt:{opt savekey}} saves your API key, so you don't need to enter it again{p_end}

{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:censusapi} is a simple tool to access the US Census data. It facilitates the whole "API" part, and provides some functionality to make variable selection easier. 
Note that you need to have cURL installed for this command to work. It is installed by default in recent versions of Windows. If you are running an older version, you can download cURL at https://curl.haxx.se/download.html .

There are two ways of using this command.

{phang}
{opt url(string)} You can use {cmd:censusapi} merely as an API toolkit. In this case, you simply supply the correct URL in the {opt url(string)} option and run the program. Example 1 (see below) illustrates this method. 
The command will then simply send your request to the Census website, download whatever it gets back and load this data. You can also use the {opt destination(string)} option to immediately save the cleaned csv file to disk.

{phang}
Alternatively, you can use the {opt dataset(string)}, {opt variables(string)} and {opt predicate(string)} options to make your life a bit easier. This essentially cuts the url up into its constituent parts. Example 2 (see below) illustrates this method.
Now, you first specify the link to the {bf dataset} you are downloading from, then which {bf variables} you are interested in and finally the {bf predicate} part, which determines which geographic regions you'll be downloading information on. 
One nifty advantage of the {cmd:censusapi} command is that it parses variable lists for you. Say, you want to download all age shares. With this command, you can simply specify P0110001-P0110031 and it will immediately convert this to P0110001,P0110002,...,P0110031 for you.
It will also split your census call if you are requesting more than 50 variables (the maximum allowed by one call) and combine the data afterwards.

{phang}
You might need a census API key to complete your download (at the time of writing these could be requested for free). You can add this to your request through the {opt key(string)} option. If you are as lazy and forgetful as I am, then you will be happy
to hear that there is also a {opt savekey} option. This will save the key in your profile.do (google it). From that points onwards, {cmd censusapi} will always use that key. Specifying a different key will overwrite this setting. Specifying key(overwrite) will run
censusapi without a key.

{marker examples}{...}
{title:Examples}

{pstd}Example 1: the url() way: some info about San Francisco{p_end}
{phang2}{cmd:. censusapi, url("https://api.census.gov/data/1990/sf1?get=P0010001,ANPSADPI,H0010001&for=place:67000&in=state:6")}{p_end}

{pstd}Example 2: the alternative method, illustrating also the variable parsing and saving capacities {p_end}
{phang2}{cmd:. censusapi, dataset("https://api.census.gov/data/1990/sf1") variables("P0010001 AREALAND P0110001-P0110031 P0060001-P0060005 H0010001 H0230001-H0230020") predicate("for=place:*&in=state:*") destination("test.txt")}{p_end}

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
{synopt:{cmd:stop}} Alternative to exit/error 1 that facilitates log closure and links up with sendtoslack{p_end}
{synopt:{cmd:pwcorrf}} Faster version of pwcorr, with builtin reshape option{p_end}
{p2colreset}{...}


