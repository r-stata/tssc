{smcl}
{* *! version 1.2  13December2019}{...}
{viewerjumpto "Syntax" "sublime##syntax"}{...}
{viewerjumpto "Description" "sublime##description"}{...}
{viewerjumpto "Remarks" "sublime##remarks"}{...}

{title:Title}

{phang}{bf:sublime} {hline 2} Program to set up {browse "https://github.com/mattiasnordin/StataEditor":StataEditor} (a package of Sublime Text) automatically


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
	{cmd:sublime}
	[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt i:nstalled}}set {cmd:StataEditor} assuming Sublime Text has been installed on user’s system{p_end}
{synopt:{opt p:ortable}}set {cmd:StataEditor} assuming the path to portable version of Sublime Text has been stored with {cmd:whereis}{p_end}
{synopt:{opt keep:whereis}}force {cmd:sublime} not to remove the entry named {it:Sublime} from {cmd:whereis}{p_end}
{synopt:{opt m:anually}}write the settings file for {cmd:StataEditor} in current working directory{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
By default, {cmd:sublime} will assume that you are using portable version of Sublime Text and locate the directory of Sublime Text by retrieving the path stored with SSC package {search whereis}.
If {cmd:sublime} fails to locate the directory of portable version, it will assume that Sublime Text has been installed on your system and depend on environment variable to locate the directory.
Then {cmd:sublime} will write the settings file for {cmd:StataEditor} in that directory.{p_end}
{p 4 6 2}
If {opt installed} is specified, {cmd:sublime} will not depend on {cmd:whereis} even if you have stored the path to Sublime Text with {cmd:whereis}.{p_end}
{p 4 6 2}
If {opt portable} is specified, {cmd:sublime} will not locate the directory of installed version even if you have installed Sublime Text on your system.
To specify this option, you should first install {cmd:whereis} from SSC archive and then create an entry named {cmd:Sublime} to store the location of portable version as follows:{p_end}
{pmore}{cmd:. whereis Sublime "path/to/portable version/sublime_text.exe"}{p_end}

{p 4 6 2}
By default, if you specified {opt portable} while the path stored with {cmd:whereis} is indeed {it:not the location of portable version}, {cmd:sublime} will automatically remove the entry named {it:Sublime} from {cmd:whereis}.
If you don’t want this behavior, specify {opt keepwhereis}.{p_end}
{p 4 6 2}
If {opt manually} is specified, {cmd:sublime} will not locate the directory of Sublime Text and just write the settings file for {cmd:StataEditor} in current working directory.
You might manually move this file to your Sublime Text directory to set {cmd:StataEditor}.{p_end}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
	{cmd:sublime} automates the installation process of {cmd:StataEditor}, a Sublime Text package enabling Stata users to interactively send code to Stata from Sublime Text.
	After getting {cmd:StataEditor} and {cmd:Pywin32} via Package Control, {it:to run Stata and execute this command} will finish the setup of {cmd:StataEditor}.

{pstd}
	What does {cmd:sublime} do for you in detail?
	{cmd:sublime} automatically detects the version of current Stata session, locates Sublime Text directory, writes the settings file for {cmd:StataEditor}
	and registers {browse "https://www.stata.com/automation/#createmsapp":the Stata Automation type library}.
	Note that you might have to {it:run Stata as Administrator} to register the Stata Automation type library.


{marker remarks}{...}
{title:Remarks}

{pstd}
	Below addresses known issue(s).

{pstd}
	1. {cmd:StataEditor} opens new Stata session every time and does not send code to Stata!

{pmore}
	This problem lies in the failure to register the Stata Automation type library.
	If you are using Windows 10, please execute {cmd:sublime} with {it:Stata running as Administrator}.
	If you are using Windows 7/8/Vista, you might need to follow the Windows Vista instruction which can be found {browse "https://www.stata.com/automation/#createmsapp":here}.


{marker author}{...}
{title:Author}

{pstd}
	{browse "https://jhmin.weebly.com":JeongHoon Min}, Sogang University, plus1@sogang.ac.kr


{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}
	The author is grateful to Germán Rodríguez for the {browse "https://ideas.repec.org/c/boc/bocode/s458303.html":whereis} program.

