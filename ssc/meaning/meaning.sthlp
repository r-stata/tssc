{smcl}
{* *! version 1.0.0  25feb2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "meaning##syntax"}{...}
{viewerjumpto "Description" "meaning##description"}{...}
{viewerjumpto "Remarks" "meaning##remarks"}{...}
{viewerjumpto "Examples" "meaning##examples"}{...}
{title:Title}

{phang}
{bf:meaning} {hline 2} Uses internet to search for the meaning for a word or phrase, and print in a temporary text file. You can listen to the pronunciation using pronounce option.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:meaning}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt pro:nounce}}Listen to the pronunciation. Remember to turn on audio.{p_end}
{synoptline}
{p2colreset}{...}


{p 8 17 2}
{cmdab:meaning} [string], pronunciation


{marker description}{...}
{title:Description}

{pstd}
The command works in windows only. It searches meaning for a word or phrase, and paste the search result in a temporary notepad file. If you close the notepad window, the search result is deleted. If you specify pronunciation option, make sure to turn on the audio from your computer.


{marker remarks}{...}
{title:Remarks}

{pstd}
This program uses windows powershell and internet exploer to search in google.

{marker examples}{...}
{title:Examples}

{phang}{cmd:. meaning poverty}{p_end}
{phang}{cmd:. meaning poverty, pronunciation}{p_end}
{phang}{cmd:. meaning poverty, pro}{p_end}


{marker author}{...}
{title:Author}

{pstd}Mehrab Ali{p_end}
{pstd}For questions or suggestions e-mail at mehrabbabu@gmail.com.{p_end}
