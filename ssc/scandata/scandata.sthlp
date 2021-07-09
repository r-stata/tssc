{smcl}
{* *! version 1.4.3 28Apr2017}{...}
{vieweralsosee "[R] help" "help help "}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "scandata##syntax"}{...}
{viewerjumpto "Description" "scandata##description"}{...}
{viewerjumpto "Returned Results" "scandata##results"}{...}
{title:Title}

{p 4 16 2}
{bf:scandata} {hline 2} Scans the dataset and identifies variables fitting criteria of variable specifications (uppercase letters, length, mutated vowels, odd distributions) and partly corrects them.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:scandata} [{cmd:,} {it:options}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt len:gth(length_options)}} checks for variable names, value and variable labels having more than the amount of characters specified in {it:length_options} {p_end}
{synopt:{opt nol:abel}} checks for unlabeled values {p_end}
{synopt:{opt odd:var(criteria)}} identifies variables with an odd distribution based on three criteria specified in {it:criteria} {p_end}
{synopt:{opt um:laut}} checks for variable names, labels, value labels containing mutated vowels  {p_end}
{synopt:{opt strum:laut}} checks for strings containing mutated vowels  {p_end}
{synopt:{opt up:percase}} checks for variable names containing uppercase characters {p_end}

{synopt:{opt all: }} runs all checks above  {p_end}
{synopt:{opt cor:rect}} corrects uppercase letters and/or mutated vowels {p_end}
{synopt:{opt nop:rint}} shows a short summary of found variables instead of listing them in detail  {p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:scandata} scans the dataset and checks if variables fit certain criteria being important in light of data preparation. Those criteria can be chosen by using the options
{opt length}, {opt nolabel}, {opt oddvar}, {opt umlaut} and {opt uppercase}. At least one criterion must be named. To account for all criteria at once {opt all} can be used. Variables being found are presented in tables.
Furthermore, variables containing uppercase letters and/or mutated vowels can be corrected automatically by using {opt correct}. Thresholds used in {opt length} and {opt oddvar} can be changed by using further options (see option details).

{marker opt}
{title:Options}

{p 4 8 2} {opt all} accounts for every check available in the ado and can be combined with {opt correct} and {opt noprint}. If {opt all} is called only default values for {opt length} and {opt oddvar} are assigned.

{p 4 8 2} {opt correct} can be used to correct variables found by {opt scandata}. Be aware that only variables regarding uppercase characters and mutated vowels can be corrected. For details see detailed description
of {opt umlaut} and {opt uppercase}.

{p 4 8 2} {opt length(length_options)} checks if any variable name, value or variable label in the dataset contains more than a certain amount of characters. The exact amount can be specified by using the {it:length_options}
 {opth vallabel(#)} (default is 119 (120 is the maximum value label length in SPSS)), {opth varlabel(#)} (default is 79) and {opth varname(#)} (default is 8). If no values are entered into the brackets the default values will be used.
  In order to control just for one of those three possibilities the unnecessary options can be simply left out.

{p 4 8 2} {opt nolabel} crawls through every value coded in the dataset checking if a label is assigned. This is useful, since little typos in programming of questionnaires can cause unlabled values. Furthermore,
it can be used to identify wild codes. To avoid unnecessary checks only those variables are scanned which contain an assigned value label. So, unlabeled values can only be found if other labels have been assigned to values already.

{p 4 8 2} {opt noprint} can be used to create a short summary where only counts of variables being found are reported.

{p 4 8 2} {opt oddvar(criteria)} checks if a variable may contain an odd distribution. An odd distribution is defined as fitting at least one of three criteria, incorporated in this program. Those criteria can be set on/off and modified
 as well by using {opth crit1(#)}, {opth crit2(#)} and {opth crit3(#)} within {it:criteria}.  If no values are entered into the brackets the default values will be used. In order to control just for one or two of those three criteria the
 unnecessary ones can be simply left out. Variables fitting at least one criterion are stored in r(odd_or] and those fitting all applied criteria are stored in r(odd_and). {p_end}

{p 8 8 2} The first criterion {opth crit1(#)} takes account of the amount of different values being in the variable. If the actual amount differs to a great extent from the available values named in the value label it could be a hint to
a misleading filter or program error. Thus, the variable is supposed to have an odd distribution. With {opth crit1(#)} the user can set the percentage threshold below which a variable is marked. {opth (#)} has to be a real number between zero
 and one (the default is 0.01 and therefore 1 percent).

{p 8 8 2} The second criterion {opth crit2(#)} looks for values having a distinct high frequency and therefore might hint at some type of program or filter error. Like for the first criterion the threshold being used can be modified,
 but has to be a real number between zero and one. Here, {cmd:scandata} marks all variables which have certain value frequencies above the chosen threshold (the default is 0.95 and therefore 95 percent).

{p 8 8 2} The third criterion {opth crit3(#)} looks for values having rather small observations hinting at some kind of wild codes or program/filter error. Therefore, {opth (#)} has to be an integer setting how many and less
 observations are supposed to indicate an error in a variable. The default threshold is one.

{p 4 8 2} {opt strumlaut} does the same as {opt umlaut} but only checks for string variables. Please note that string variables will be duplicated and get the suffix "_cmv" (corrected mutated vowels). Thus, the original strings are maintained.

{p 4 8 2} {opt umlaut} goes through every variable name, label, value label and string and checks for existing mutated vowels. Concerning transformation in other formats or downwards compatibility to former Stata versions it can be useful
to replace them with their "normal" vowels. {opt correct} takes care of that step as well. Thus, "{c 228}" becomes "{c 97}{c 101}", "{c 252}" "{c 117}{c 101}", "{c 246}" "{c 111}{c 101}" and "{c 223}" "{c 115}{c 115}".
If those mutated vowels are upper-case characters they will be transformed in upper-case characters as long as the previous or following character are of an uppercase type, too. For example, "GR{c 220}NE" becomes "GRUENE" but
"{c 220}brige" becomes "Uebrige".

{p 8 8 2} Make sure to translate the dataset into unicode if you use Stata 14 (see {help unicode}). Otherwise, {opt scandata} cannot identify the mutated vowels. Furthermore, please note that quotation marks ({c 39},{c 34}) in labels
cause problems in scanning the labels. Thus, they are transformed in the (hopefully) unique character {c 7} and {c 8} temporally. However, if your dataset contains such characters replace them with some other characters to avoid becoming
them quotation marks after scandata has finished.

{p 4 8 2} {opt uppercase} accounts for checks regarding uppercase characters in the variable name. Upper-case characters, especially when mixed with lowercase characters, can be an issue when it comes to transformation in other formats.
If {opt correct} is named as well, all uppercase characters are turned into lowercase characters.



{marker results}{...}
{title:Returned results}

{pstd} Macros:

{p2col 5 20 21 4 :{cmd:r(capvar)}} list of variables with uppercase letters in variable names {p_end}
{p2col 5 20 21 4 :{cmd:r(length_name)}} list of variables with more than the chosen threshold of characters in variable name {p_end}
{p2col 5 20 21 4 :{cmd:r(length_var)}} list of variables with more than the chosen threshold of characters in variable label {p_end}
{p2col 5 20 21 4 :{cmd:r(length_val)}} list of variables with more than the chosen threshold of characters in value label {p_end}
{p2col 5 20 21 4 :{cmd:r(umlaut_name)}} list of variables with mutated vowels in variable names  {p_end}
{p2col 5 20 21 4 :{cmd:r(umlaut_var)}} list of variables with mutated vowels in variable labels  {p_end}
{p2col 5 20 21 4 :{cmd:r(umlaut_val)}} list of numeric variables with mutated vowels in value labels  {p_end}
{p2col 5 20 21 4 :{cmd:r(umlaut_str)}} list of string variables with mutated vowels  {p_end}
{p2col 5 20 21 4 :{cmd:r(nolabel)}} list of numeric variables with unlabeled values  {p_end}
{p2col 5 20 21 4 :{cmd:r(oddvar_or)}} list of variables which fit {ul:one} of all applied criteria of an odd distribution  {p_end}
{p2col 5 20 21 4 :{cmd:r(oddvar_and)}} list of variables which fit {ul:all} applied criteria of an odd distribution  {p_end}


{title:Examples}

{p 4 4 2}
Using all available checks with default settings

	{cmd: . scandata, all}

{p 4 4 2}
Using all available checks with default settings and correct uppercase characters and mutated vowels

	{cmd: . scandata, all correct}

{p 4 4 2}
Checking for to many characters in labels and variable names, using default settings for variable labels and other thresholds for variable names and value labels

	{cmd: . scandata, length(varname(10) varlabel() vallabel(50))}

{p 4 4 2}
Checking for mutated vowels in the dataset, no correction, display variables within a table

	{cmd: . scandata, umlaut}

{p 4 4 2}
Checking for mutated vowels, correct them and supressing the table

	{cmd: . scandata, umlaut correct nop}

{p 4 4 2}
Checking for an odd distribution with different values applying all criteria

	{cmd: . scandata, oddvar(crit1(0.02) crit2(0.99) crit3(3))}

{p 4 4 2}
Checking for an odd distribution with different values applying only one criterion

	{cmd: . scandata, oddvar(crit2(0.99))}

{p 4 4 2}
Using all checks with default settings but one different value for the third criterion

	{cmd: . scandata, all oddvar(crit1() crit2() crit3(2))}


{title:Author}
{p 4 4 2 70}
Malte Kaukal, Hessen State Statistical Office malte.kaukal@gmx.de

{pstd}Thank your for citing this software as follows:

{pmore}Kaukal, Malte.2016. SCANDATA: Stata module to scan a dataset for specified characteristics. Available from
http://EconPapers.repec.org/RePEc:boc:bocode:s458186.

{title:Acknowledgement}
{p 4 4 2}
Regarding processing through each single value label this ado benefits a lot of the ado {help labellist} written by Daniel Klein.

{p 4 4 2}
I would like to acknowledge the support of GESIS, which lead to the creation of the Stata command {cmd: scandata}.
Further I would like to thank my colleagues for their thoughtful comments and tests of earlier versions.
{p_end}