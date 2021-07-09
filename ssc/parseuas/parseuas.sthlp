{smcl}
{* version 1.3}{...}
{* 08jan2016}{...}
{viewerjumpto "Syntax" "parseuas##syn"}{...}
{viewerjumpto "Options" "parseuas##opt"}{...}
{viewerjumpto "Description" "parseuas##des"}{...}
{viewerjumpto "Examples" "parseuas##exa"}{...}
{viewerjumpto "Authors" "parseuas##aut"}{...}
{viewerjumpto "Notes" "parseuas##not"}{...}
{title:Title}

{p 4 4 2}{hi:parseuas} {hline 2} Extract detailed information from user agent strings

{marker syn}	
{title:Syntax}

{p 8 8 2}{cmd:parseuas} {it:{help varname:varname}} [{it:{help if:if} exp}] [{it:{help in:in} range}]
[{it:, }{it:{help parseuas##opt:options}}]

{p 4 8 2}where {it:{help varname:varname}} is a string variable containing the 
user agent strings. 

{synoptset 21 tabbed}{...}
{marker opt}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth bro:wser(newvar)}}generates a variable containing the information on the browser name{p_end}
{synopt :{opth browserv:ersion(newvar)}}generates a variable containing the information on the version of the browser{p_end}
{synopt :{opth os(newvar)}}generates a variable containing the information on the operating system{p_end}
{synopt :{opth dev:ice(newvar)}}generates a variable containing the information on the device type{p_end}
{synopt :{opth smart:phone(newvar)}}generates a dummy variable, which indicates whether a smartphone was used{p_end}
{synopt :{opth tab:let(newvar)}}generates a dummy variable, which indicates whether a tablet computer was used{p_end}
{syntab:Optional}
{synopt :{opt num:eric}}generate numeric variables instead of strings{p_end}
{synopt :{opt n:oisily}}output of frequency tables for browser name, browser version, operating system, and device type{p_end}
{synoptline}
{p2colreset}{...}

{marker des}
{title:Description}

{p 4 4 2} The {cmd:parseuas} module extracts detailed information from user agent strings. 
The user agent is software that acts as interface to the user, for example 
a web browser. The client software sending the request to a server is identified 
in a user agent header field. The header contains the so-called user agent 
string. In general, user agent strings include information on the browser 
name, the browser version, the operating system, and the device type. 
The {cmd:parseuas} module displays and optionally stores this information in new 
variables as specified by the user. 

{p 4 4 2}Example for a user agent string: 
"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0" 
(Windows 7 running on a 64-bit personal computer. The browser is Mozilla Firefox version 31.0). 

{p 4 8 2} The parseuas module gives the names and versions of several popular web {hi:browsers} and a residual category: 
Android Webkit, Chrome, Edge, Firefox, Iceweasel, Internet Explorer, Iron, K-Meleon, 
Maxthon, Netscape, Opera, Safari, SeaMonkey, Silk, and Browser (other) 
	
{p 4 8 2} It codes several types and versions of some widely used {hi: operating systems} and a residual category: 
Android, BlackBerry OS, Linux, Mac OS X, Symbian, Windows, iOS, and OS (other)

{p 4 8 2} The parseuas module also codes several categories for the {hi:device type}: 
Mobile phone (Android), Mobile phone (Windows), Mobile phone (iPhone), Mobile phone (other), 
Tablet (Android), Tablet (Windows), Tablet (iPad), Tablet (other), and Device (other)
	
{marker exa}
{title:Examples}

{p 4 8 2} Display information on the device type, the browser name and version, 
and the operating system for all cases in the data set. 

	{com}. parseuas useragentstring, noisily
	{txt}

{p 4 8 2} Display information on the device type, the browser name and version, 
and the operating system for the first case in the data set. 

	{com}. parseuas useragentstring in 1, noisily
	{txt}

{p 4 8 2} Save complete information from user agent strings in numeric variables 
for all cases in the data set. 

	{com}. parseuas useragentstring, bro(browser) browserv(browserversion) os(operatingsystem) 
	{com}device(device) smart(smartphone) tab(tablet) numeric
	{txt}
	
{p 4 8 2} Save complete information from user agent strings in string 
variables for all cases of group one.

	{com}. parseuas useragentstring if group==1, bro(browser) 
	{com}browserv(browserversion) os(operatingsystem) 
	{com}device(device) smart(smartphone) tab(tablet)  
	{txt}
	
{marker aut}
{title:Authors}

{p 4 8 2} Joss Roßmann, GESIS - Leibniz Institute for the Social Sciences, joss.rossmann@gesis.org 

{p 4 8 2} Tobias Gummer, GESIS - Leibniz Institute for the Social Sciences, tobias.gummer@gesis.org

{p 4 8 2} Copyright (C) 2016  Joss Roßmann & Tobias Gummer

{p 4 8 2} This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

{p 4 8 2} This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details <http://www.gnu.org/licenses/>.

{p 4 8 2} Recommended citation (APA Style, 6th ed.): {break}
Roßmann, J., & Gummer, T. (2016): PARSEUAS: Stata module to extract detailed 
information from user agent strings (Version: 1.3) [Computer Software]. 
Chestnut Hill, MA: Boston College.

{marker not}
{title:Notes}

{p 4 8 2} The {cmd:parseuas} module partly draws on dictionaries for coding. Use 
{it:{help adoupdate:adoupdate}} to get the latest version. 
The installed version is 1.3 (08-Jan-2016). 
