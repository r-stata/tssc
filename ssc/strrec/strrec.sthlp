{smcl}
{* version 1.0.8 31may2011}
{cmd:help strrec}
{hline}

{title:Title}

{p 5 15}
{cmd:strrec} {hline 2} Recode string variables, modify value labels or 
recode variables referring to value labels

{title:Syntax}

{p 8}
{cmd:strrec} {varlist} {bf:(}{it:rule}{bf:)} [{bf:(}{it:rule}{bf:)} {it:...}] {ifin} 
[{cmd:,} {it:options}]

{p 5}
where {it:rule} is one of

{p 23}
{bf:"}{it:str}{bf:"} [{bf:"}{it:str}{bf:"} {it:...}] {bf:=} {it:#} [{bf:"}{it:lbl}{bf:"}]

{p 23}
{bf:"}{it:str}{bf:"} [{bf:"}{it:str}{bf:"} {it:...}] {bf:=} {bf:"}{it:newstr}{bf:"} 

{p 5 8}
{it:str} is a string. Double quotes may be omitted if {it:str} does not contain embedded 
spaces.

{p 5 8}
{it:#} is a number. Non-integers are allowed.

{p 5 8}
{it:lbl} is a value label. Double quotes may be omitted if {it:lbl} does not contain 
embedded spaces. Make sure to insert a blank between {it:#} and {it:lbl} if not 
using double quotes. This part of {it:rule} is optional.

{p 5 8}
{it:newstr} is a single string. Double quotes may be omitted if {it:newstr} does not 
contain embedded spaces.

{p 5 8}
Parentheses around {it:rules} must be used.


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:main options}}
{synopt:{opt pre:fix(name)}}use {it:name} as prefix for transformed variables{p_end}
{synopt:{opt g:enerate(namelist)}}create variables {it:name1, ..., namek} containing 
transformed variables{p_end}
{synopt:{opt replace}}replace {it:var} with transformed values{p_end}
{synopt:{opt sub}}recode if {it:str} is a substring in {it:var}{p_end}
{synopt:{opt case:sensitive}}case-sensitive recode{p_end}
{synopt:{opt str:ing}}force new variables to be string variables{p_end}
{syntab :{it:numeric options}}
{synopt:{opt def:ine(name)}}specify name for defined value label{p_end}
{synopt:{opt nol:abel}}do not define value label/s{p_end}
{syntab :{it:string options}}
{synopt:{opt elsemiss}}set strings that do not meet the conditions of {it:rules} to 
missing{p_end}
{synopt:{opt copy:rest}}copy strings that are excluded by the {it:if} and {it:in} 
qualifiers from {it:var}{p_end}
{syntab :{it:extended options}}
{synopt:{opt vall:ab}}apply {it:rules} to value labels (numeric variables){p_end}
{synopt:{opt nodel:ete}}do not delete value labels that are changed{p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:strrec} recodes string variables according to {it:rules}. Variables may either be 
recoded into numeric variables or into string variables. Any string in {it:var} that does 
not meet the conditions of {it:rules} is set to missing in created numeric variables and 
copied from {it:var} in created string variables. Value labels will be defined for numeric 
variables, assigning {it:str} (or, if specified {it:lbl}) to corresponding numeric values.

{pstd}
{hi:Remarks:} {cmd:strrec} may also be used to recode numeric variables referring to their 
value labels. See option {help strrec##vl:vallab}.

{title:Options}

{dlgtab:Options}

{phang}
{opt prefix(name)} uses {it:name} as prefix for recoded variables. If not specified 
{hi:r_} is default. May also be used with {opt generate()}.

{phang}
{opt generate(namelist)} creates new variables {it:name1, ..., namek} containing recoded 
variables. The number of names specified must equal the number of variables in {it:varlist}.

{phang}
{opt replace} replaces {it:var} with transformed variable.

{phang}
{opt sub} recodes {it:var} if {it:str} is a substring of {it:var}. In {it:str}, {bf:"?"} 
means any single character, {bf:"*"} means zero or more characters. The synonym 
{opt wild:cards} may be used.

{phang}
{opt casesensitive} specifies that {it:str} (as well as {it:var}) is treated "as is", 
meaning case-sensitive {hi:and} with leading- trailing- and consecutive internal blanks. If 
specified, {it:var} will only be recoded if it perfectly matches {it:str}.

{phang}
{opt string} forces new variable/s to be string variables. {cmd:strrec} sets the new 
variables' type (numeric or string) according to the first rule specified. If {it:newstr} 
is a single number in the first rule and you want to create string variables, specify 
{opt string}. 

{phang}
{opt define(name)} specifies a name for the created value label. If not specified, the new 
variables' names are used as value label name.

{phang}
{opt nolabel} specifies that no value labels will be defined.

{phang}
{opt elsemiss} specifies that strings that do not meet the conditions of {it:rules} are set 
to missing ({bf:""}). Default is to copy those strings from {it:var}.

{phang}
{opt copyrest} specifies that strings are copied from {it:var}, even if they are excluded 
by the {it:if} and {it:in} qualifier. Default is to set those strings to missing ({bf:""}).

{marker vl}
{phang}
{opt vallab} applies {it:rules} to the value labels of (numeric) variables in {it:varlist}. 
In case {it:"str"} = {it:"newstr"} is used as {it:rule/s}, only the text in the variables' 
value labels will be changed. Using {it:"str"} = # {it:"lbl"} as {it:rule/s} will change 
the value labels (text and integer) {hi:and} the values of {hi:all} variables using the 
respective value label. The {it:if} and {it:in} qualifiers are ignored and only options 
{opt sub}, {opt casesensitive} and {opt nodelete} may be used. {opt vl:ab} or 
{opt labrec} are synonyms for {opt vallab}. See {help strrec##vlex:example}.

{phang}
{opt nodelete} does not delete (old) value labels that are changed by 
{it:rules}. This option should be specified if {it:rules} refer to the 
same text as {it:str} and {it:lbl}. 

{title:Examples}

	. sysuse auto ,clear
	(1978 Automobile Data)

	. tabulate make

	    Make and Model |      Freq.     Percent        Cum.
	-------------------+-----------------------------------
	       AMC Concord |          1        1.35        1.35
	         AMC Pacer |          1        1.35        2.70
	        AMC Spirit |          1        1.35        4.05
	         Audi 5000 |          1        1.35        5.41
	          Audi Fox |          1        1.35        6.76
	[...]
	         VW Dasher |          1        1.35       94.59
	         VW Diesel |          1        1.35       95.95
	         VW Rabbit |          1        1.35       97.30
	       VW Scirocco |          1        1.35       98.65
	         Volvo 260 |          1        1.35      100.00
	-------------------+-----------------------------------
	             Total |         74      100.00

	{cmd:. strrec make ("AMC*" = 1 "AMC")("Audi*" = 2 "Audi") ///}
	{cmd:> [...] ("VW*" = 22 "VW")("Volvo*" = 23 "Volvo") ,sub generate(make_only)}
	make_only
	(3 real changes made)
	(2 real changes made)
	(1 real change made)
	(7 real changes made)
	(3 real changes made)
	(6 real changes made)
	(4 real changes made)
	(4 real changes made)
	(1 real change made)
	(2 real changes made)
	(2 real changes made)
	(3 real changes made)
	(1 real change made)
	(6 real changes made)
	(7 real changes made)
	(1 real change made)
	(5 real changes made)
	(6 real changes made)
	(1 real change made)
	(1 real change made)
	(3 real changes made)
	(4 real changes made)
	(1 real change made)

	. tabulate make_only

	  make_only |      Freq.     Percent        Cum.
	------------+-----------------------------------
	        AMC |          3        4.05        4.05
	       Audi |          2        2.70        6.76
	[...]
	         VW |          4        5.41       98.65
	      Volvo |          1        1.35      100.00
	------------+-----------------------------------
	      Total |         74      100.00

{marker vlex}
{pstd}
{ul:{opt vallab} option}

{pstd}
Consider the following value labels in a dataset

	. label list
	agelbl:
	         888 Don't know
	         999 Refusal
	pollbl:
	          -9 REFUSAL
	          -8 DON'T KNOW
	           1 very interested
	           2 quite interested
	           3 hardly interested
	           4 not at all interested
	marlbl:
	           0 not married
	           1 married
	           9 Refusal
	tvlbl:
	           1 no time at all
	           2 less than 30 min
	           3 30 to 60 min
	           4 60 to 90 min
	           5 90 to 180 min
	           6 more than 180 min
	           8 don't know
	           9 refused

{pstd}
Note that missing value codes, as well as the spelling of the labels' text
"don't know" and "refused" vary across variables.

	{cmd:. strrec _all ("don't know" = .a)(ref* = .b "refused") ,vallab sub}
	[...]
	
	. label list
	marlbl:
	           0 not married
	           1 married
	          .b refused
	agelbl:
	          .a don't know
	          .b refused
	pollbl:
	           1 very interested
	           2 quite interested
	           3 hardly interested
	           4 not at all interested
	          .a don't know
	          .b refused
	tvlbl:
	           1 no time at all
	           2 less than 30 min
	           3 30 to 60 min
	           4 60 to 90 min
	           5 90 to 180 min
	           6 more than 180 min
	          .a don't know
	          .b refused 

{pstd}
All variables will be recoded accordingly. Note that old value labels 
(e.g. 888 Don't know) are deleted. To prevent {cmd:strrec} from doing 
so, add option {opt nodelete}. The option should be added if {it:rules} 
are used to swap value labels as in

	. {cmd:strrec anyvar ("one" = 5 "five") ("five" = 1 "one")}
	
{title:Further Remarks}

{pstd}
Make sure to always use the typewriter apostrophe ({bf:'}), even if left 
single quotes ({bf:`}) are used as apostrophe in the labels. {cmd:strrec} 
will change those left single quotes to typewriter apostrophes.


{title:Author}

{pstd}Daniel Klein, University of Bamberg, klein.daniel.81@gmail.com

{title:Also see}

{psee}
Online: {helpb encode}, {helpb recode}, {help label}{p_end}

{psee}
if installed: {help labrec} (old){p_end}
