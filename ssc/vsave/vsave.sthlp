{smcl}
{cmd:help vsave}
{hline}

{title:Title}

{p 5 11 2}
{cmd:vsave} {hline 2} Save Stata dataset under version control


{title:Syntax}

{p 8 16 2}
{cmd:vsave} [{it:{help filename}}] [{cmd:,} {it:options}]


{title:Description}

{pstd}
{cmd:vsave} saves the current dataset under the name 
{it:filename} and does so in the {help dta:Stata format} 
implied by {help version:version control}.

{pstd}
The {helpb save} command always stores datasets in the most 
recent Stata format (version {cmd:{ccl stata_version}}), 
regardless of the {help version} the command interpreter is 
set to. Stata has another command, {helpb saveold}, that 
writes datasets in formats that can be read by prior versions 
of Stata. {cmd:vsave} is a hybrid of these two commands. It 
acts like {cmd:saveold}, when the command interpreter is set 
to less than the current version of Stata and is equivalent 
to {cmd:save} otherwise.

{pstd}
{cmd:vsave} requires Stata version 11.2 and works up to 
version 14 (the most recent version). The command might 
continue to work in version 15 and higher, but this 
cannot yet be tested. 


{title:Options}

{phang}
{opt v:ersion(#)} saves the dataset in Stata {it:#} format.

{phang}
{it:{help save##saveoptions:save_options}} and
{it:{help save##saveold_options:saveold_options}} 
are other options for {cmd:save} or {cmd:saveold}.


{title:Example}

{pstd}
Save dataset in Stata 11 format

{phang2}
{cmd:version 11 : vsave myfile}
{p_end}

{pstd}
Equivalent to above

{phang2}
{cmd:vsave myfile , version(11)}
{p_end}


{title:Acknowledgments}

{pstd}
This command is strongly inspired by Michael Stepner's {cmd:save12} 
and {cmd:save13} commands (available from the {helpb ssc:SSC}), who 
also suggested the {opt version()} option. He motivates the 
development of these tools on 
{browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1360275-save12-and-save13-save-datasets-in-a-specific-dta-format-available-in-ssc":Statalist}.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help save}, {help saveold}, {help use}, {help dta}
{p_end}

{psee}
if installed: {help save12}, {help save13}, {help use13}
{p_end}
