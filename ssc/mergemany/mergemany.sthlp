{smcl}
{* 07 August 2012}{...}
{hline}
help for {hi:mergemany}
{hline}

{title:Title}

{p 8 20 2}
    {hi:mergemany} {hline 2} A flexible command to merge many files

{title:Syntax}

One-to-one merge of files where user lists full file names

{p 8 20 2}
{cmdab:mergemany} {cmd:1:1} {it: filename1 filename2}...{cmd:,}
match({varlist}) [{it:options}]


One-to-one merge of files where user takes advantage of numerical regularity in file name

{p 8 20 2}
{cmdab:mergemany} {cmd:1:1}  {it: fileprefix}{cmd:,} 
match({varlist}) {cmdab:num:erical(}{help numlist}{cmd:)} [{it:options}]


One-to-one merge of all files in the current working directory

{p 8 20 2}
{cmdab:mergemany} {cmd:1:1}  {it: all}{cmd:,} 
match({varlist}) {cmdab:all} [{it:options}]



This syntax also generalises to one-to-many, many-to-one, and many-to-many matches as per {help merge}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth m:atch(varlist)}}lists the variable(s) upon which the match is performed; this is a required option.
{p_end}
{...}
{synopt :{cmdab:num:erical(}{help numlist}{cmd:)}}used when specifying a merge based upon the numerical suffix of a file name; 
cannot be used with {cmd:all}
{p_end}
{...}
{synopt :{opt all}}merges all files in the current working directory; cannot be used with {cmdab:num:erical(}{help numlist}{cmd:)}
{p_end}
{...}
{synopt :{opt keep}}conserves the dataset currently in memory while simultaneously performing the merge between all filnames; 
in this case the option {cmdab:sav:ing(}{it:filename}{cmd:)} is recommended 
{p_end}
{...}
{synopt :{cmdab:sav:ing(}{it:filename}{cmd:)}}saves the resulting parent file from all merges as {it: filename.dta}; 
recommended when conserving the dataset in memory via {cmd:keep}
{p_end}
{...}
{synopt :{opt ver:bose}}creates a variable to mark merge results for each separate merge; by default this is _merge_{it:filename}
{...}
{p_end}
{synopt :{cmdab:imp:ort(}{it:filetype}{cmd:)}}allows for non .dta files to be imported and merged directly.  
{it:filetype} must display the data type which is being imported (eg .csv, .raw).  When using .dta files, this option should not be used.
{p_end}
{...}
{synopt :{cmdab:inop:tion(}{help insheet##syntax:options}{cmd:)}}allows for {help insheet} options to be specified when importing data.  Any
{help insheet##syntax:options} which are available in {help insheet} can be used.  This option should only be used when importing via {cmdab:imp:ort(}{it:filetype}{cmd:)}
{p_end}
{...}
{synoptline}
{p2colreset}


{title:Description}

{p 6 6 2}
{hi:mergemany} is an extension to the command {help merge}, providing a flexible way for many 'using' datasets to be merged into one final dataset.  {hi:mergemany} is able to perform the standard 
merges defined in {help merge} (one-to-one, one-to-many, many-to-one, many-to-many); one of these matches must be specified. 

{p 6 6 2}
{hi:mergemany} provides a number of ways to specify the files to be merged.  File names may be listed in full allowing for merges of files in separate directories or with no obvious 
naming scheme.  A numerical suffix can be used in the case that files share a common prefix but differ due to a non-identical suffix (such as {it:file1}, {it:file2}, {it:file3}...).  In this 
case the suffix is listed as an argument and the option {cmdab:num:erical(}{help numlist}{cmd:)} must be specified.  Finally, all files of a given type from the current working directory can be merged 
into one file (see {help cd} for help in navigating to a required directory).  When merging all files from a directory the argument {it:all} should be included in place of file names and the option {cmd:all} 
must be specified. 

{p 6 6 2}
The resulting match rate for each using file merged into the parent file are displayed as program output, however in order for a resulting variable to be included listing the 
source and contents of each observation (as per the variable {cmd:_merge} in {help merge}), the option {cmdab:ver:bose} must be specified.  For more details regarding these outputs and the values
taken by these variables (if specified), see the {help merge##results:match results table} in {help merge}.

{p 6 6 2}
{hi:mergemany} allows non .dta files to be imported directly and merged in one step.  In this case the option {cmdab:imp:ort(}{it:filetype}{cmd:)} should be specified, where {it:filetype}
refers to the type of data being imported.  This supports any data type which can be imported via the {help insheet} command.  In the case that further options of {help insheet} are necessary when
importing the data (such as {help insheet##syntax:case}), the option {cmdab:inop:tion(}{help insheet##syntax:options}{cmd:)} can be used.



{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Perform 1:1 match merge listing full file names{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse autosize}{p_end}
{phang2}{cmd:. list}{p_end}
{phang2}{cmd:. webuse autoexpense}{p_end}
{phang2}{cmd:. list}{p_end}
{phang2}{cmd:. webuse auto}{p_end}
{phang2}{cmd:. list}{p_end}

{phang2}{cmd:. mergemany 1:1 http://www.stata-press.com/data/r12/autoexpense http://www.stata-press.com/data/r12/autosize http://www.stata-press.com/data/r12/auto, match(make)}{p_end}
{phang2}{cmd:. list}{p_end}

    {hline}
{pstd}Perform 1:1 match merge, using all files in a folder called auto{break}

{pstd}Setup{p_end}
{phang2}{cmd:. mkdir auto}{p_end}
{phang2}{cmd:. cd auto}{p_end}
{phang2}{cmd:. webuse autosize}{p_end}
{phang2}{cmd:. save auto1}{p_end}
{phang2}{cmd:. webuse autoexpense}{p_end}
{phang2}{cmd:. save auto2}{p_end}
{phang2}{cmd:. webuse auto}{p_end}
{phang2}{cmd:. save auto3}{p_end}

{phang2}{cmd:. mergemany 1:1 all, match(make) all}{p_end}



    {hline}
{pstd}Perform 1:1 match merge, using numerical regularity of all files in the auto folder (created {help mergemany##examples:above}) {break}

{phang2}{cmd:. mergemany 1:1 auto, match(make) numerical(1(1)3)}{p_end}

    {hline}



{title:Also see}

{psee}
Online:  {manhelp merge D} {manhelp insheet D}, {manhelp cross D}, {manhelp append D}, {manhelp joinby D}, {manhelp sort D}



{title:Author}

{pstd}
Damian C. Clarke, University of Oxford and ComunidadMujer. {browse "mailto:damian.clarke@economics.ox.ac.uk"}
{p_end}
