{smcl}
{cmd:help which_version}
{hline}

{title:Title}

{p 4 12 2}
{cmd:which_version} {hline 2} Return location and programmer's 
version of ado-files


{title:Syntax}

{p 8 12 2}
{cmd:which_version}
{it:fname}[{cmd:.}{it:ftype}]
[ {cmd:,} {it:options} ]


{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt firstvers:ion}}
extract only the first programmer's version number
{p_end}
{synopt:{cmdab:assertvers:ion(}[{it:{help operator:relop}}] {it:#}{cmd:.}{it:#}[{cmd:.}{it:#}[{cmd:.}{it:#}]]{cmd:)}}
{help assert} programmer's version number 
{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:which_version} looks for {it:fname}{cmd:.}{it:ftype} along the 
{help sysdir:ado-path} and, if it finds the file, displays the full 
path and filename, along with all lines in the file that begin with 
{cmd:*!}. If {it:fname}{cmd:.}{it:ftype} is not found, the command 
exits with error and sets the return code to 111.

{pstd}
{cmd:which_version} returns the full path and filename of 
{it:fname}{cmd:.}{it:ftype} in {cmd:s(fn)}. Additionally, 
{cmd:which_version} searches all lines in {it:fname}{cmd:.}{it:ftype} 
that begin with {cmd:*!} for the programmer's version number and, if 
it finds the version number, returns it in {cmd:s(version)}; see 
{help which_version##remarks:Remarks}.


{title:Options}

{phang}
{opt firstversion} extracts from {it:fname}{cmd:.}{it:ftype} only the 
first programmer's version number. Default is to extract the largest 
version number. See {help which_version##remarks:Remarks}.

{phang}
{cmd:assertversion(}[{it:{help operator:relop}}]
{it:#}{cmd:.}{it:#}[{cmd:.}{it:#}[{cmd:.}{it:#}]]{cmd:)} verifies that 
the programmer's version number equals the specified version number and, 
if it does not, exits with error and sets the return code to 9. If there 
is no programmer's version number in {it:fname}{cmd:.}{it:ftype}, the 
return code is set to 6. {it:{help operator:relop}} is one of the relational 
operators {cmd:>}, {cmd:<}, {cmd:>=} or {cmd:<=}, and verifies that the 
programmer's version number is larger (or equal) or lower (or equal) to the 
specified version number. 


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:which_version} extracts from {it:fname}{cmd:.}{it:ftype} the 
programmer's version number if it follows the pattern typically used 
by StataCorp.  

{phang2}
{cmd:*! version {it:#}.{it:#}.{it:#}{bind:  }{it:Day}{it:Month}{it:Year}}

{pstd}
Many community-contributed commands mimic this pattern to indicate the 
programmer's version number; many do not. {cmd:which_version} recognizes 
any of the following variations

{phang2}{cmd:*! version 2.1.0 11nov2019 daniel klein}{p_end}
{phang2}{cmd:*! 1.0.4 NJC 24 March 2014}{p_end}
{phang2}{cmd:*! NJC 1.3.0 28 Feb 2014}{p_end}
{phang2}{cmd:*! version 3.23{bind:  }31may2019{bind:  }Ben Jann}{p_end}
{phang2}{cmd:*! v.2.1.1 Confirmatory factor analysis, by Stas Kolenikov {it:...}}{p_end}
{phang2}{cmd:*! v 14.3{bind:       }2Feb2019{bind:               }by Joao Pedro Azevedo {it:...}}{p_end}

{pstd}
and extracts the programmer's version numbers {cmd:2.1.0}, {cmd:1.0.4}, 
{cmd:1.3.0}, {cmd:3.23}, {cmd:2.1.1}, and {cmd:14.3}.

{pstd}
Technically, {cmd:which_version} looks, in lines of 
{it:fname}{cmd:.}{it:ftype} that begin with {cmd:*!}, for the first 
occurrence of the pattern 

{phang2}
[{cmd:v}[{cmd:.}]]{it:#}{cmd:.}{it:#}[{cmd:.}{it:#}[{cmd:.}{it:#}]]

{pstd}
and interprets it as the programmer's version number. The pattern is 
expected to be one word; white spaces are not allowed. The pattern may 
optionally begin with the letter {cmd:v}, followed by a dot. The 
pattern must contain at least two and at most four numbers, separated 
by dots. Although it is not shown, the pattern may be terminated by a 
white space, a comma ({cmd:,}), a colon ({cmd::}), or a semi-colon ({cmd:;}).

{pstd}
Some community-contributed commands include as comments a version-history 
and, thus, multiple programmer's version numbers. {cmd:which_version} 
extracts the latest, i.e., largest programmer's version number. For example, 
from

{phang2}{cmd:*! 1.1.15 MLB 22Mar2012}{p_end}
{phang2}{cmd:*! 1.1.13 MLB 03Aug2010}{p_end}
{phang2}{cmd:{it:...}}{p_end}
{phang2}{cmd:*! 1.1.9  MLB 28Apr2010}{p_end}
{phang2}{cmd:{it:...}}{p_end}
{phang2}{cmd:*! 1.0.1  MLB 15May2007}{p_end}

{pstd}
{cmd:which_version} extracts the programmer's version number 
{cmd:1.1.15}. Likewise, from

{phang2}{cmd:*! version 1.0.0  2008.04.26}{p_end}
{phang2}{cmd:*! version 1.0.1  2009.01.20}{p_end}
{phang2}{cmd:{it:...}}{p_end}
{phang2}{cmd:*! version 2.0.1  2010.08.27 Version submitted to SSC}{p_end}
{phang2}{cmd:*!}{p_end}
{phang2}{cmd:*! by David C. Elliott}{p_end}
{phang2}{cmd:*! Text file chunking algorithm}{p_end}
{phang2}{cmd:{it:...}}{p_end}

{pstd}
{cmd:which_version} extracts the programmer's version number 
{cmd:2.0.1}.

{pstd}
Note that from

{phang2}{cmd:*! Version 2.3.4.1: Changes made June 15, 2019: option label {it:...}}{p_end}
{phang2}{cmd:*! Version 2.3.40 : Changes made June 6, 2019: eform() {it:...}}{p_end}
{phang2}{cmd:*! Version 2.3.3.9: command replay added. This is used {it:...}}{p_end}
{phang2}{cmd:{it:...}}{p_end}
{phang2}{cmd:*! Version 2.1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk,Aug1, 2018}{p_end}
{phang2}{cmd:*! Version 1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk,7Jan2018}{p_end}
{phang2}{cmd:{it:...}}{p_end}

{pstd}
{cmd:which_version} extracts, perhaps unexpectedly, the programmer's 
version number {cmd:2.3.40}. Changing from two numbers ({cmd:Version 1.0}) 
to four numbers ({cmd:Version 2.3.4.1}) that indicate the programmer's 
version is not a problem. However, {cmd:which_version} insists that 
{cmd:2.3.40 != 2.3.4.0} and that {cmd:2.3.40[{cmd:.0}] > 2.3.4.1}.

{pstd}
Sometimes, {cmd:which_version} extracts a wrong programmer's version 
number. For example, from

{phang2}{cmd:*! version 1.1.2{bind:  }30may2015{bind:  }Robert Picard, Picard@netbox.com & NJC}{p_end}
{phang2}{cmd:*! cloned from egen version 3.4.1  05jun2013; modified to accept tsvarlists}{p_end}

{pstd}
{cmd:which_version} extracts the (wrong) programmer's version number 
{cmd:3.4.1}. The {opt firstversion} option fixes this problem.  

{pstd}
If {cmd:which_version} cannot find a programmer's version number, it 
displays "unknown version" and returns nothing in {cmd:s(version)}.


{title:Examples}

{phang2}
{cmd:. which_version recode}
{p_end}
{phang2}
{cmd:. sreturn list}
{p_end}

{phang2}
{cmd:. which_version which_version , assertversion(> 1.0.0)}
{p_end}
{phang2}
{cmd:. sreturn list}
{p_end}


{title:Saved results}

{pstd}
{cmd:which_version} saves the following in {cmd:s()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:s(fn)}}full path and filename
{p_end}
{synopt:{cmd:s(version)}}programmer's version number
{p_end}


{title:Author}

{pstd}
Daniel Klein, INCHER-Kassel, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help which}, {help findfile}, {help f_regexm:regexm()}{p_end}

