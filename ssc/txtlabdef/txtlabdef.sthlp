{smcl}
{* version 1.0.3 07may2011}
{cmd:help txtlabdef}
{hline}

{title:Title}

{p 5}
{cmd:txtlabdef} {hline 2} Define value labels from ASCII (text) file

{title:Syntax}

{p 8}
{cmd:txtlabdef} [{it:dofile}] {helpb using} {it:filename}
[{cmd:,} {it:options}]


{p 5}
where {it:dofile} is the do-file to be created{p_end}
{p 5 5}
and {it:filename} is the ASCII (text) file, containing the value 
labels{p_end}

{p 5 5}
Use double quotes if {it:dofile} or {it:filename} contain embedded 
spaces. If {it:filename} is specified without extension .{it:txt} 
is the default.


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt q:uotes}}do not remove double quotes from value labels{p_end}
{synopt:{opt rem:ove(str)}}remove {it:str} from content in {it:filename}
{p_end}
{synopt:{opt start(#)}}value labels in {it:filename} start at line {it:#}
{p_end}
{synopt:{opt stop(#)}}value labels in {it:filename} end at line {it:#}
{p_end}
{synopt:{opt replace}}replace existing do-file{p_end}
{synopt:{opt append}}append existing do-file{p_end}
{synopt:{opt nodef:ine}}create do-file but do not define value labels{p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:txtlabdef} defines value labels from a plain text (ASCII) file. The 
first line of a value label in the text file must be a valid value label 
name. Each line following must start with one integer number followed by 
text. The next line that does not start with an integer number marks the 
beginning of a new value label. Optionally a do-file is created. Existing 
value labels will be modified. 

{pstd}
{hi:Remarks:} integer numbers may be separated from text by {bf:":"}, 
{bf:"="}, {bf:"-"}, {bf:"."}, {bf:","}, space ({bf:" "}) or horizontal tab 
stop in the (plain) text file. These separators may be mixed between value 
labels and even within one value label. There is no need for double quotes, 
since everything following the integer number on the same line in the ASCII 
file is interpreted as text. In fact all double quotes are removed from the 
content in {it:filename}. 


{title:Options}

{dlgtab:Options}

{phang}
{opt quotes} specifies that double quotes are not to be removed from content 
in {it:filename}. If text in value labels contains double quotes, use 
{opt quotes} to make sure they are not removed. Default is to remove all 
double quotes.

{phang}
{opt remove(str)} removes {it:str} from content in {it:filename}. {it:str} 
is ["]string["] [["][string]["]][...].

{phang}
{opt start(#)} specifies that value labels in the ASCII (plain text) file 
start at line {it:#}. Lines 1 to {it:#} in {it:filename} are ignored. 

{phang}
{opt stop(#)} specifies that value labels in the ASCII (plain text) file 
end at line {it:#}. Lines in {it:filename} following {it:#} are ignored. 

{phang}
{opt replace} replaces the do-file, if it already exists. May only be 
specified if {it:dofile} is also specified.

{phang}
{opt append} specifies that an existing do-file is appended. May only be 
specified if {it:dofile} is also specified.

{phang}
{opt nodefine} does not define value labels, but only "translates" the ASCII 
file and creates a do-file. May only be specified if {it:dofile} is also 
specified.

{title:Examples}

{pstd}
Define value labels form the ASCII file {it:example.txt}.

	. type example.txt ,asis
	{it:yesno}

	{it:0 no}
	{it:"1 yes"}
	{it:2}

	{it:agree}
	{it:1: strongly disagre}
	{it:2: disagree}
	{it:3: undecided}
	{it:4: agree}
	{it:5: strongly agree} 


	{it:fre}

	{it:1.      once a year}
	{it:2:once a week}
	{it:3 - once a day} 

	{cmd:. txtlabdef mydo using c:/ado/example.txt}
	file mydo.do saved
	
	. label list
	fre:
	           1 once a year
	           2 once a week
	           3 once a day
	agree:
	           1 strongly disagree
	           2 disagree
	           3 undecided
	           4 agree
	           5 strongly agree
	yesno:
	           0 no
	           1 yes
	           2 

	. type mydo.do ,asis
	/*value labels from c:/ado/example.txt
	created 15 Jan 2011 16:47:44*/

	label define yesno 0 "no" ,modify
	label define yesno 1 "yes" ,modify
	label define yesno 2 "" ,modify

	label define agree 1 "strongly disagree" ,modify
	label define agree 2 "disagree" ,modify
	label define agree 3 "undecided" ,modify
	label define agree 4 "agree" ,modify
	label define agree 5 "strongly agree" ,modify

	label define fre 1 "once a year" ,modify
	label define fre 2 "once a week" ,modify
	label define fre 3 "once a day" ,modify

{pstd}
Example 2. The ASCII file {it:example2.txt} contains some text and 
value labels.

	. type example2.txt ,asis
	{it:This file demonstrates how txtlabdef handles information in a text file.}

	{it:This is the third line and it contains number 1.}
	{it:The integer value 1 in the line above is ignored because the line does }
	{it:not start with an integer number.}
	{it:Since the following line starts with the integer number}
	{it:2, txtlabdef will interpret "Since" in line 6 (above) }
	{it:as a value label name and everything following number 2 in line 7, }
	{it:will be interpreted as text associated with number 2.}

	{it:Now we will define a value label, starting with a value label name.}
	{it:labelname}
	{it:1 strongly agree}
	{it:2 agree}
	{it:3 undecided}
	{it:4 disagree}
	{it:5 strongly disagree}

	{it:Note that txtlabdef will create the value label "labelname". In fact, if }
	{it:all lines in the ASCII file start with valid (value label) names or an }
	{it:integer number, txtlabdef will find the value labels in the plain text and }
	{it:will not terminate.}
 
	{it:The problem in this very text file is, that the value label "Since" will }
	{it:also be created. To prevent txtlabdef from doing so, specifiy}

	{it:. txtlabdef using example2.txt ,start(12) stop(17)}

	{it:That's the end of example2.txt.}
	
	{cmd:. txtlabdef using example2.txt}

	. label list
	labelname:
	           1 strongly agree
	           2 agree
	           3 undecided
	           4 disagree
	           5 strongly disagree
	Since:
	           2 txtlabdef will interpret Since in line 6 (above)

	. clear

	{cmd:. txtlabdef using example2.txt ,start(12) stop(17)}

	. label list
	labelname:
	           1 strongly agree
	           2 agree
	           3 undecided
	           4 disagree
	           5 strongly disagree


{title:Saved results}

{pstd}
{cmd:txtlabdef} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synopt:{cmd:r(labelnames)}}value label names{p_end}


{title:Acknowledgments}

{pstd}
The name {cmd:txtlabdef} is in line with {cmd:varlabdef} by Roger Newson.

{title:Author}

{pstd}Daniel Klein, University of Bamberg, klein.daniel.81@gmail.com

{title:Also see}

{psee}
Online: {helpb label}, {help file}{p_end}
{psee}
if installed: {help varlabdef}
{p_end}
