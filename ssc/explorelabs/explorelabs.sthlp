{smcl}
{* *! version 1.0.1 14Feb2017}{...}
{vieweralsosee "[R] help" "help help "}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "explorelabs##syntax"}{...}
{viewerjumpto "Description" "explorelabs##description"}{...}
{title:Title}

{p 4 16 2}
{bf:explorelabs} {hline 2} explores value labels and shows their frequency and assigned values.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:explorelabs} {varlist} [{cmd:,} {it:options}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Explore modus}
{synopt:{opt last:values(#)}} explore only value labels attached to the last (highest) # values of {it:varlist}  {p_end}
{synopt:{opt neg:ative}} explore only value labels attached to negative values of {it:varlist} {p_end}

{syntab:Output}
{synopt:{opt fre:quency}} show frequency of value labels according to {it:explore modus} {p_end}
{synopt:{opt lab:eltext(string)}} limit output only to value labels matching {it:string} {p_end}
{synopt:{opt l:ist}} list each variable of {it:varlist}, its values and labels according to {it:explore modus} {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:explorelabs} explores the value labels of every variable named in {it:varlist} and gives an overview of their use by reporting specific labels, their frequency and values being attached to those labels.
{cmd:explorelabs} offers two explore modes. By using the option {opt lastvalues(#)} the user can decide how many values of a scale are reported. This can
be useful if a missing value scheme is applied that always refers to the last/highest values of a variable. The second mode is {opt negative} and does the same as {opt lastvalues(#)} but for
negative values only. Be aware that these modes only look at values having labels attached. Thus, values having no label at all are not considered. However, if the label is
specified as " "(one blank minimum) it is taken into account. If both options are not used {cmd:explorelabs} looks at all labels available.

{pstd}
Two different outputs can be obtained. Either a list of variables and their values and labels ({opt list})
 or a table of labels, their frequency and all their values attached to them ({opt frequency}). As a default both outputs are shown. Furthermore, {opt labeltext(string)} enables the user
  to limit the output to only those labels matching the string expression (see {helpb strmatch()} for matching patterns).

{p 4 17 2}{ul:Please note:} Depending on the amount of defined labels in {it:varlist} {cmd:explorelabs} surely can take its time. Don't despair and get yourself your favourite hot/cold beverage.

{marker opt}
{title:Options}

{p 4 8 2} {ul:Explore mode}

{p 4 8 2} {opt lastvalues(#)} takes the last (highest) values of a variable named in {it:varlist} into account. The amount of values to look at is chosen by defining {opt (#)} as an integer greater than zero. For example,
using {opt lastcodes(2)} makes {cmd: explorelabs} to report only the last {ul:two} values of every variable in {it:varlist} and so on. Thus, the user is able to investigate if missing value labels (including stata missing values
like .a, .b, because they are defined es great numbers) are always attached to the last values of a variable. This would be the case if e.g. the label "{input:no answer}" appears many times but with different values attached.
If the variable does not contain as many values as the user is calling for all value labels are displayed. If this option or {opt negative} are not called {cmd:explorelabs} looks at all labels of {it:varlist}.

{p 4 8 2} {opt negative} takes only negative values of a variable named in {it:varlist} into account. Thus, the user can investigate if a missing scheme is applied that only uses negative values. Furthermore, in combination with
{opt frequency} it can be explored if this scheme is applied correctly, meaning that every label should have attached only one value. If this option or {opt lastvalues(#)} are not called {cmd:explorelabs} looks at all labels of {it:varlist}.

{p 4 8 2} {ul:Output}

{p 4 8 2} {opt frequency} provides some descriptive statistics of the labels being used in the dataset. It lists every unique label attached to the investigated values (set by {it:explore mode}) in
an alphabetical order and shows the frequency of each label and which values are attached to it.

{p 4 8 2} {opt labeltext(string)} enables the user to limit the reported labels to those that match the string expression. As in other string functions (e.g. {helpb strmatch()}) this expression can contain placeholders
 like "{input:*}" or "{input:?}". {opt labeltext(string)} can be applied to both kinds of outputs.

{p 4 8 2} {opt list} gives back every variable with a value label, lists their called on labels (negative or last # values) and underlines those labels being also actually in the dataset as observations.

{title:Examples}

{p 4 4 2}
Explore every label of {it:varlist} and get the full output:

	{cmd: . explorelabs {varlist}}

{p 4 4 2}
Explore the last two values of {it:varlist} and {ul:only} list them:

	{cmd: . explorelabs {varlist}, lastvalues(2) list}

{p 4 4 2}
Explore the last two values of {it:varlist} and {ul:only} get their frequencies:

	{cmd: . explorelabs {varlist}, lastvalues(2) frequency}

{p 4 4 2}
Explore only negative values of {it:varlist}, list them and get their frequencies (e.g. to control if a missing value scheme of negative values has only exactly one value attached to a label):

	{cmd: . explorelabs {varlist}, negative}

{p 4 4 2}
Explore only those labels that contain "{input:answer}", take all labels into account and get their frequencies:

	{cmd: . explorelabs {varlist}, frequency labeltext(*answer*)}


{title:Author}
{p 4 4 2 70}
Malte Kaukal, Hessen State Statistical Office malte.kaukal@gmx.de

{pstd}Thank you for citing this software as follows:

{pmore}Kaukal, Malte.2017. EXPLORELABS: Stata module to explore the use of value labels. Available from https://EconPapers.repec.org/RePEc:boc:bocode:s458299.

{title:Acknowledgement}
{p 4 4 2}
Regarding processing through each single value label this ado benefits a lot from the ado {help labellist} written by Daniel Klein.

{p 4 4 2}
I would like to acknowledge the support of GESIS, which led to the creation of the Stata command {cmd: explorelabs}.
Further I would like to thank my colleagues for their thoughtful comments and tests of earlier versions.
{p_end}