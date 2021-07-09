{smcl}
{viewerjumpto "Syntax" "plztowknr##syn"}{...}
{viewerjumpto "Options" "plztowknr##opt"}{...}
{viewerjumpto "Description" "plztowknr##des"}{...}
{viewerjumpto "Examples" "plztowknr##exa"}{...}
{viewerjumpto "Acknowledgments" "plztowknr##ack"}{...}
{viewerjumpto "Notes" "plztowknr##not"}{...}
{viewerjumpto "Authors" "plztowknr##aut"}{...}

{title:Title}

{p 4 4 2}{hi:plztowknr} {hline 2} Stata module to translate German zip codes into electoral districts 

{marker syn}	
{title:Syntax}

{p 4 8 2}{cmd:plztowknr} {it:{help varname:varname}} [{it:{help if:if}}] [{it:{help in:in}}]
[{it:, }{it:{help plztowknr##opt:options}}]

{p 6 8 2}where {it:{help varname:varname}} has to be a numeric variable 

{synoptset 21 tabbed}{...}
{marker opt}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth gen:erate(newvar)}}specifies the name of the new variable containing the electoral districts{p_end}
{synopt :{opth year(real)}}specifies the election year for which zip codes are translated into electoral districts{p_end}
{synopt :{opth mis:singcode(real)}}specifies existing missing values in {it:{help varname:varname}} {p_end}
{synopt :{opt eng:lish}}assigns english value and variable labels to {it:newvar}; by default german labels are used {p_end}
{synopt :{opt nog:les}}assigns no values labels for missing values in {it:newvar}; by default missing value labels are assigned based on the scheme of the German Longitudinal Election Study {p_end}{synoptline}
{p2colreset}{...}

{marker des}
{title:Description}

{p 4 4 2} The {cmd:plztowknr} module translates German zip codes into electoral districts for the German
federal elections of 1998, 2002, 2005, 2009, 2013, or 2017. It is important to note that German zip codes might correspond to more than one electoral district.
{cmd:plztowknr} thus generates a new variable for each {it:potential} electoral district. 
For example, a person living in zip code 01157 could be voting in electoral district 159 or 160. In this case, {cmd:plztowknr} generates two additional variables{hline 2}one for each potential district. 
Each of these variables will be named by the string specified in {opth gen:erate(newvar)} followed by a number. 

{p 4 4 2} There are no official lists that link zip codes to election districts in Germany. 
The dictionaries of {cmd:plztowknr} thus have to rely on several administrative documents. Note that these dictionaries are not
comprehensive and that these lists and in consequence {cmd:plztowknr} have to be used carefully and should be checked for errors. In the following we provide an overview of how the dictionaries 
for each election year were created. The dictionaries of 2009, 2013, and 2017 were created as part of the data preparation of the German Longitudinal Election Study (GLES; www.gles.eu)
and, thus, are more comprehensive than the other lists.

{p 4 8 2} {ul:1998} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office.

{p 4 8 2} {ul:2002} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office.

{p 4 8 2} {ul:2005} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office.

{p 4 8 2} {ul:2009} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office and by the search tool provided by the German Bundestag. 

{p 4 8 2} {ul:2013} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office and by the search tool provided by the German Bundestag.

{p 4 8 2} {ul:2017} Dictionary parsed from Gemeindeverzeichnis (directory of municipalities) that is provided by the German Statistical Office and by the search tool provided by the German Bundestag.

{marker exa}
{title:Example}

{p 4 4 2} The following command translates zip codes from the variable {it:plz} into electoral districts. The electoral districts will be stored in 
newly generated variables named {it:elecdist, elecdist1, elecdist2}(, ...). Furthermore, {cmd:plztowknr} is instructed to use the correspondence list for the German federal election of 2017. 
{cmd:plztowknr} ignores existing missing values in {it:plz} (in this example -98 and -99) when assigning electoral districs. 
Because {opt eng:lish} is not specified, the value and variable labels are in German. Because {opt nog:les} is not specified missing value codes will be labeled using the scheme developed by GLES. 
In the output window, {cmd:plztowknr} will display an overview of assigned, unknown, 
multiple zip codes as well as the number of missing values (if specified). 

	{com}. plztowknr plz, generate(elecdist) year(2017) missingcode(-99 -98)
	{txt}

{p 4 4 2}  The number of system missings are always displayed in the output window; extended missings can be specified in {opt mis:singcode}:

	{com}. plztowknr plz, generate(elecdist) year(2017) missingcode(.a .b)
	{txt}
   	
	
{marker ack}
{title:Acknowledgments}

{p 4 4 2} The dictionaries used in {cmd:plztowknr} were collected as part of the data preparation of the German Longitudinal Election Study (GLES; www.gles.eu/) 
carried out by GESIS and were kindly made available for this Stata module.
	
{marker not}
{title:Notes}

{p 4 4 2} The {cmd:plztowknr} module draws on dictionaries for translating the zip codes. Use 
{it:{help adoupdate:adoupdate}} to get the latest version. 
The installed version is 1.0 (15-Feb-2018). 	
	
{marker aut}
{title:Authors}

{p 4 4 2} Konstantin Glinitzer, GESIS Leibniz-Institute for the Social Sciences, konstantin.glinitzer@gesis.org

{p 4 8 2} Tobias Gummer, GESIS Leibniz-Institute for the Social Sciences, tobias.gummer@gesis.org 

{p 4 4 2} Malte Kaukal, Hessisches Statistisches Landesamt, malte.kaukal@gmx.de

{p 4 4 2} Joss Roßmann, GESIS Leibniz-Institute for the Social Sciences, joss.roßmann@gesis.org 

{p 4 4 2} Copyright (C) 2018  Konstantin Glinitzer, Tobias Gummer, Malte Kaukal, Joss Roßmann

{marker ack}
{title:Citation}

{p 4 4 2} This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

{p 4 4 2} This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details <http://www.gnu.org/licenses/>.

{p 4 4 2} Recommended citation (APA Style, 6th ed.): Glinitzer, K., Gummer, T., Kaukal, M., Roßmann, J. (2018): plztowknr: Stata module to translate German zip codes into electoral districts (Version: 1.0) [Computer Software]. Chestnut Hill, MA: Boston College.
