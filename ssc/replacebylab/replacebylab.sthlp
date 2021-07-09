{smcl}
{* 03mar2014}{...}
{hline}
help for {hi:replacebylab}
{hline}

{title: Title}

{p 4 4 2}{hi:replacebylab} {hline 2} Replace values by drawing on value labels


{title:Table of contents}

	{help replacebylab##syn:Syntax}
	{help replacebylab##des:Description}
	{help replacebylab##opt:Options}
	{help replacebylab##rem:Remarks}
	{help replacebylab##exa:Examples}
	{help replacebylab##aut:Author}

{marker syn}	
{title: Syntax}

{p 4 8 2}{cmd:replacebylab} {it:{help varlist:varlist}} [{it:{help if:if} exp}] [{it:{help in:in} range}]{it:, }{it:{help replacebylab##opt:options}}

{p 4 4 2}Both options {cmd:label}{cmd:(}{it:string}{cmd:)} and {cmd:setvalue}{cmd:(}{it:numeric}{cmd:)} are required. 

{marker des}
{title:Description}

{p 4 4 2} {cmd:replacebylab} changes values on basis of labels assigned to values. Every value with the respective label is recoded to a pre-specified new value. 
In this process, every value label of every whole number between the minimum and maximum value 
of the respective variables is examined. {cmd:replacebylab} applies to {it:numerical} variables only.

{marker opt}
{title:Options}

{p 4 4 2} {cmd:label}{cmd:(}{it:string}{cmd:)} specifies the label of the values which should be recoded.  

{p 4 4 2} {cmd:setvalue}{cmd:(}{it:numeric}{cmd:)} specifies the {it:new} value to which every value with the {cmd:label}{cmd:(}{it:string}{cmd:)} should be changed.

{p 4 4 2} {cmd:substr} optionally forces {cmd:replacebylab} to recode all values with labels which {it:include} the string defined by {cmd:label}{cmd:(}{it:string}{cmd:)}.

{p 4 4 2} {cmd:newlabel}{cmd:(}{it:string}{cmd:)} is optional and contains a label which will be assigned to the {it:new} value (defined by {cmd:setvalue}{cmd:(}{it:numeric}{cmd:)}).

{p 4 4 2} {cmd:dellab} is optional and specifies that the old value labels will be deleted.

{p 4 4 2} {cmd:display} is optional and results in an output showing which values have been replaced in each variable.

{marker rem}
{title:Remarks}

{p 4 4 2} {cmd:replacebylab} crawls the value label definitions of every specified variable. This is done from the lowest to the highest value for each variable. In a data set with (many) high dimensional variables, this may result in 
poor performance of {cmd:replacebylab}. In this case, it is highly recommended to exclude the respective variables.

{p 4 4 2} {cmd:replacebylab} will not work with an active {help numlabel:numlabel} command. {help numlabel:numlabel} prefixes the numeric values to a label. Hence, "don´t know" does not correspond to "99. don´t know".
	
{marker exa}
{title:Examples}

{p 4 8 2} Recode all "don´t know" answers to -99 for the whole data set.

	{com}. replacebylab _all, label(don´t know) setvalue(-99)
	{txt}

{p 4 8 2} Recode all answers which include the substring "yes" to 1 for variables v1, v2, and v3. Additionally, 1 will be labeled "positive" by applying the {cmd:newlabel}{cmd:(}{it:string}{cmd:)} option.

	{com}. replacebylab v1 v2 v3, label(yes) setvalue(1) substr newlab(positiv)
	{txt}	

{p 4 8 2} Recode all "don´t know" answers to -99 for the whole data set. Additionally, {cmd:display} is specified to get information on which values are replaced. 

	{com}. replacebylab _all, label(don´t know) setvalue(-99)
	{txt}
	
{marker aut}
{title:Author}

{p 4 8 2} Tobias Gummer, GESIS - Leibniz Institute for the Social Sciences, tobias.gummer@gesis.org




