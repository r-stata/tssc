{smcl}
{* *! version 2.0.1  09 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "splitit##syntax"}{...}
{viewerjumpto "Description" "splitit##description"}{...}
{viewerjumpto "Options" "splitit##options"}{...}
{viewerjumpto "Remarks" "splitit##remarks"}{...}
{viewerjumpto "Examples" "splitit##examples"}{...}
{title:Title}

{phang}
{bf:splitit} {hline 2} splits overlapping spells in spell data

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:splitit}
{varlist}{cmd:,}
[{it:options}]

{p 4 4 2}
where {varlist} denominates 5 existing variables in the working file, standing for {it:case_ID}, {it:start_date} (num int), {it:end_date} (num int), {it:spell_type}, and {it:spell_ID}. {bf:The named sequence of variables is obligatory}.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt srt:(varlist)}}variables serving as additional sort criteria of the split data {p_end}
{synopt:{opt por:tions(#)}}specifies the number of portions the source file is divided into for processing. Default is 1 portion for ca. 25,000 obervatons  {p_end}
{synopt:{opt cv:ars}}orders four specific count variables for the split spells{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:splitit} splits overlapping spells within a case. The result is a file where each split spell of a case is either chronologically unique or 
chronologically completely parallel to other split spells of the same case (having exactly the 
same start and end_dates, in the following called "isochronic spells"). The graph and table below illustrate the principle of this operation. 

{pstd}
Spell splitting is an essential step for most of the methods to analyze episode data, and is a 
preliminary step in transforming spell data into sequence data. 
In contrast to other tools for spell data, (i.e. {help newspell}), {cmd:splitit} exclusively splits the data and leaves it untouched in every other aspect. 
Therefore no prior knowledge regarding the precedence of spell_types is needed. Together with {help combival.ado} (also written by the authors), 
{cmd:splitit} can be used to explore the data in order to investigate the existing parallelities and, subsequently, determine a rank order or 
define new spell_types.

{pstd}
{cmd:splitit} works by an elaborate comparison of every begin and end_date within each case. The resulting file has the fewest possible number of split spells, satisfying the condition not to overlap, for a given data set. Because of this 
property, {cmd:splitit} can be used to split data that has - compared to the whole represented time span - very finely grained time units. 

{pstd}
A special feature of portioned processing optimizes the runtime and makes {cmd:splitit} applicable to very large data sets. It has been tested with a dataset of about 30 Mio observations. A feature that measures the runtime of the program is 
included.

{pstd}
The versions from 2.0.0 are adapted to work with Stata 14, and are tested to work with previous versions from Stata 11.2

{phang}
{bf:Graphical example:}

	Original spells of a case in the source file
	           A
	|----------------------|
	                        B
	               |------------------|

	Split spells of this case
	       A1          A2	                      
	|-------------||-------|
	                   B1        B2
	               |-------||---------|


{phang}
{bf:Tabular example:}

	Source file table
	case	spellid   start	     end       spelltype 
	10001	    1     jan2010    dec2012       A     
	10001	    2     apr2012    nov2013       B     

	Table after splitting
	case	spellid   start	     end       spelltype  start_split	end_split  sid_split
	10001	    1	  jan2010    dec2012       A      jan2010	mar2012	       1
	10001	    1     jan2010    dec2012       A      apr2012	dec2012	       2
	10001	    2	  apr2012    nov2013       B      apr2012	dec2012	       3
	10001	    2	  apr2012    nov2013       B      jan2013	nov2013	       4


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt srt(varlist)} The sort order of the split data after the execution of {cmd:splitit} is {it:case_ID}, {it:start_date of the split spells}, {it:spell_type}, and, if specified, the variables named in the {cmd:srt()} option. The sort order is 
reflected in the newly generated variable {it:sid_split}, which is the ID of the split spells within a case.

{phang}
{opt por:tions(#)} By default, {cmd:splitit} divides the data into portions of approximately 25,000 observations, providing for placing spells of the same case into the same portion. This feature is implemented because Stata tends to become 
disproportionally slow with increasing computer capacity utilization. Depending on the users' computer environment, the default might result in portions that are too large or too small. {cmd:splitit} produces a message with a time stamp for 
each portion being processed. As a rule of thumb, the default number of portions ought to be increased if more than 5 minutes elapse before the next portion is completed.

{phang}
{opt cv:ars} generates 4 variables relating to the number of split spells:

{p 8 10 2}
- {it:levela} counts spell splits per case and spell_type, beginning with 0, for each value of split_start.

{p 8 10 2}
- {it:levelb} counts spell splits per case, beginning with 0, for each value of split_start.

{p 8 10 2}
- {it:nlevela} represents the sum of spell splits per case and spell_type for each value of split_start.

{p 8 10 2}
- {it:nlevelb} represents the sum of spell splits per case for each value of split_start.

{p 8 8 2}
{bf:Please note:} with split spell data all spells having a certain split_start always have the same split_end.


{marker remarks}{...}
{title:Remarks}

{pstd}
The {varlist} assigned to {cmd:splitit} is required to contain 5 variables, standing for {it:case_ID}, {it:start_date}, {it:end_date}, 
{it:spell_type}, and {it:spell_ID} in the active working file. 

{pstd}
{bf:The following requirements are mandatory:}

{p 8 10 2}
- The above named sequence of the variables in {varlist} is compulsory, because {cmd:splitit}
derives the meaning of the variables from their position within {varlist}.

{p 8 10 2}
- None of the 5 variables of {varlist} must have missing values, (or blanks, if string type). If there are any, {cmd:splitit} issues an error message and stops processing. 

{p 8 10 2}
- The start and end_date variables in {varlist} must be numeric and hold integer values, as is the case with Stata date variables. {cmd:splitit} copies the format of the date variables in {varlist} to the newly generated variables 
{it:start_date_split} and {it:end_date_split}.

{p 8 10 2}
- The duration of spells, calculated as {it:end_date} minus {it:start_date}, must not be negative. If there are any spells with a negative duration, {cmd:splitit} issues an error message and stops processing.

{pstd}
{bf:Further information}:

{p 8 8 2}
All variables of {varlist} except the start and end_date of the spells may be numeric or string variables.

{p 8 8 2}
If a spell has the same start_date as the end_date of the previous spell, the two spells will be treated as overlapping for one time unit. If this is not desired, one of the two spells must be shortened by one time unit before applying 
{cmd:splitit}.

{p 8 8 2}
Gaps in the sequence of spells do not cause problems.

{p 8 8 2}
After splitting, the original spell_ID is no longer unique. Therefore a new unique split spell_ID is generated, named "sid_split".

{pstd}
{bf:Undoing and repeating the splitting}:

{p 8 8 2} You can undo the splitting very easily with:{p_end}
{p 12 12 2} {cmd:. keep if}  {it:start_date_split} {cmd: == } {it:start_date}{p_end}

{p 8 8 2} Alternatively, and provided that case_ID and spell_ID identify the observations in the original unsplit file uniquely,
you can use:{p_end} {p 12 12 2}{cmd:. duplicates drop} {it:case_ID} {it:spell_ID} {cmd:, force} 

{p 8 8 2} 
The variables generated by {cmd:splitit} are senseless after that and should be dropped.

{p 8 8 2}
If you want to repeat the splitting because the data has changed (i.e. spells have been dropped or merged), the best way is to undo the splitting as described above and then apply {cmd:splitit} again.

{p 8 8 2}
If for any reason you want to apply {cmd:splitit} on previously split data, you will need to pay attention to the names of the variables in {varlist}: {p_end}
{p 8 8 2}{it:start_date}, {it:end_date} and {it:spell_ID} of the first run have become {it:start_date_split}, {it:end_date_split} and {it:sid_split} in the second run.

{p 8 8 2}
If you apply {cmd:splitit} inadvertently on your working file with the same parameters more than once, {cmd:splitit} will produce duplicates and additional sets of generated variables. Provided that case_ID and spell_ID identify the observations 
in the original unsplit file uniquely, you can get rid of those with:{p_end}
{p 12 12 2}{cmd:. duplicates drop} {it:case_ID} {it:spell_ID} {it:start_date_split}{cmd:, force}

{p 8 8 2}   
(subsequently drop the additionally generated variable sets).


{marker examples}{...}
{title:Examples}

   {cmd:. use testdata_splitit, clear}
   (testdata_splitit.dta)
   {cmd:. splitit persno begin end sptype spellno}

   {cmd:. use testdata_splitit, clear}
   (testdata_splitit.dta)
   {cmd:. splitit persno begin end sptype spellno, srt(netincd)}

   {cmd:. use testdata_splitit, clear}
   (testdata_splitit.dta)
   {cmd:. splitit persno begin end sptype spellno, cv}

   {cmd:. use testdata_splitit, clear}
   (testdata_splitit.dta)
   {cmd:. splitit persno begin end sptype spellno, por(4) cv}


{marker:Authors}
{title:Authors}

Klaudia Erhardt, SOEP, DIW Berlin
Email {browse "mailto:firstname.givenname@domain":kerhardt@diw.de}

Ralf Kuenster, NEPS, WZB Berlin
Email {browse "mailto:firstname.givenname@domain":ralf.kuenster@wzb.eu}

Edition: V.2.0.1, May 2018
