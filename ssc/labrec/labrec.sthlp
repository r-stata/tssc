{smcl}
{* version 1.0.0 06aug2010}
{cmd:help labrec}
{hline}

{title:Title}

{p 5}
{cmd:labrec} {hline 2} Recode variables according to value label

{title:Syntax}

{p 8}
{cmd:labrec} {it:#} {bf:"}{it:label}{bf:"} [{it:#} {bf:"}{it:label}{bf:"} {it:...}] 
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt var:iables(varlist)}}recode variables specified in {help varlist}{p_end}
{synopt:{opt abb:rev}}recode if specified {it:label} is part of a value label{p_end}
{synopt:{opt noma:tch}}recode only if labels perfectly match{p_end}
{synopt:{opt noch:ange}}keep original label{p_end}
{synopt:{opt nore:place}}do not recode variables{p_end}
{synopt:{opt tra}}change left single quote to typewriter apostrophe{p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:labrec} recodes variables according to a user defined value label. The user is to 
define a value label in the same way this would be done using {help label define} 
(except no labelname is specified). {cmd:labrec} will recode any variable specified in 
{it:varlist} according to the defined value label, if the defined {it:label/s} match 
the (value) label/s attached to the variable. The value label/s themselves are also 
"recoded".

{title:Options}

{dlgtab:Options}

{phang}
{opt variables(varlist)} specifies that only variables in {it:varlist} are to be 
recoded. The default is {hi:_all}.

{phang}
{opt abbrev} changes value labels and recode variables if a value label contains the 
specified {it:label}. This option can be used to abbreviate labels, but it is not 
limited to abbreviations (see example).

{phang}
{opt nomatch} changes value labels and recode variables only if the label/s perfectly 
match. If specified, "Refusal" for example does not match "refusal". In default 
setting capitalization does not matter. This option is ignored if {opt abrevv} is
specified.

{phang}
{opt nochange} uses the original label to "recode" the value labels. By default the 
user defined label is used (see example).

{phang}
{opt noreplace} does not recode variables. If specified, only the value labels will be
"recoded", while the variables will remain unchanged. If you think about using this 
option you might want to see {help labmm} which modifies value labels, first. To 
install type: {stata . ssc install labmm}

{phang}
{opt tra} changes left single quotes that are used in value labels to typewriter 
apostrophe (which is the same as the right single quote). Suppose the value label 
"somelabel" associates value 99 with label "don`t know". Here the left single quote 
({bf:`}) is used as an apostrophe. {cmd:labrec} will return error code {search r(132)} 
(too few quotes) for value label "somelabel", because no matching right single quote 
is found. Specifying {opt tra} will change the single left quote in "don`t know" to a 
typewriter apostrophe ({bf:'}). 
{hi:Caution:} the program will perform even slower if this option is specified, since 
every single value label has to be checked. I recommend running the program first 
without specifying {opt tra}. If there are any error messages you can run the program 
a second time for the variable/s that produced the error/s, specifying {opt tra} and 
the {opt variables()} option.

{title:Examples}

{pstd}
To see how {cmd:labrec} works consider a simple example:

	. tab mar

	    Marital |
	     status |      Freq.     Percent        Cum.
	------------+-----------------------------------
	not married |          3       25.00       25.00
	    married |          6       50.00       75.00
	    Refusal |          3       25.00      100.00
	------------+-----------------------------------
	      Total |         12      100.00

	. label list marlbl
	marlbl:
	           0 not married
	           1 married
	           9 Refusal

	{cmd:. labrec .a "refusal" ,var(mar)}
	1 change(s) made

	. tab mar

	    Marital |
	     status |      Freq.     Percent        Cum.
	------------+-----------------------------------
	not married |          3       33.33       33.33
	    married |          6       66.67      100.00
	------------+-----------------------------------
	      Total |          9      100.00

	. label list marlbl
	marlbl:
	           0 not married
	           1 married
	          .a refusal

{pstd}
The three missing observations are coded ".a". You will get the same result using 
{help mvdecode} and {help label define} with the {opt modify} option. 

{pstd}
Now consider a large(r) data set, in which the values associated with the answers 
"don't know" and "refusal" differ across variables. The spelling of the labels also 
vary.

	. label list
	tvlbl:
	           1 no time at all
	           2 less than 30 min
	           3 30 to 60 min
	           4 60 to 90min
	           5 90-180min
	           6 more than 180min
	           8 don't know
	           9 refused
	marlbl:
	           0 not married
	           1 married
	           9 Refusal
	pollbl:
	          -9 REFUSAL
	          -8 DON'T KNOW
	           1 very interested
	           2 quite interested
	           3 hardly interested
	           4 not at all interested
	agelbl:
	         888 Don't know
	         999 Refusal

{pstd}
Of course it is still possible to work with the above mentioned commands, but it will 
take a lot of typing. Using {cmd:labrec} instead, only one line will be needed:{p_end}

	{cmd:. labrec .a "don't know" .b "refus" ,abbrev nochange}

{pstd}
{ul:How to use the options}

{pstd}
Note the use of {opt abbrev} and {opt nochange} above. In the former option the 
abbreviation "refus" is used in order to match "refusal" as well as "refused". Without 
the latter option, value ".b" would be labeled "refus". You might want to use these 
two options together every time you are using abbreviations but {opt abbrev} is not 
limited to this kind of usage. Suppose there are numeric prefixes assigned to the 
value labels in the data by {help numlabel}.  

	. label list marlbl
	marlbl:
	           0 0. not married
	           1 1. married
	           9 9. Refusal

	{cmd:. labrec .b "refusal" ,var(mar)}
	0 change(s) made

{pstd}
There are no changes made, because "refusal" does not match "9. refusal". Specifying 
the {opt abbrev} option will solve this problem.

	{cmd:. labrec .b "refusal" ,var(mar) abbrev}
	1 change(s) made

	. label list marlbl
	marlbl:
	           0 0. not married
	           1 1. married
	          .b refusal

{pstd}
Use this option carefully. Typing:

	{cmd:. labrec .b "r" ,var(mar) abbrev}

{pstd}
will result in:

	. label list marlbl
	marlbl:
	          .b r

{pstd}
since "not married", "married" and "Refusal" all contain "r" (or "R" as capitalization 
does not matter).
	
{pstd}
Using the {opt nomatch} option:

	{cmd:. labrec .a "don't know" .b "refusal" ,var(age) nomatch}
	0 change(s) made

{pstd}
results in 0 changes, because "don't know" does not match "Don't know" and "refusal" 
does not match "Refusal".

{pstd}
{hi:Hint:} To change numeric values to system missing values, type:{p_end}
	
	{cmd:. labrec . "{it:label}"}

{pstd}
This line will remove {it:label} and the associated numeric value form the value 
labels and change the variable values accordingly.

{title:Acknowledgments}

{pstd}
The package {cmd:labelsof} written by Ben Jann is required in order to obtain the 
value labels attached to each variable. To install this package type{p_end}
	{stata . ssc install labelsof}

{pstd}
The name {cmd:labrec} is in line with the commands in the {cmd:labutil} package 
by Nicholas J. Cox. To install this package type{p_end}
	{stata . ssc install labutil}

{title:Author}

{pstd}Daniel Klein, University of Bamberg, daniel1.klein@gmx.de

{title:Also see}

{psee}
Online: {helpb label}, {helpb recode}, {helpb mvdecode}{p_end}

{psee}
if installed: {help labelsof}, {help labcd}, {help labcopy}, {help labdel}, 
{help lablog}, {help labdtch}, {help labmap}, {help labnoeq}, {help labvarch}, 
{help labvalch}, {help labmask}, {help labvalclone}, {help labeldup}, 
{help labelrename} {p_end}