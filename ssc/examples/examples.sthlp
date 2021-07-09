{smcl}
{* 15 July 2004/25 July 2007}{...}
{hline}
help for {hi:examples} 
{hline}

{title:Show examples from on-line help files}

{p 8 17 2}{cmd:examples} {it:topicname} 

{p 8 17 2}{cmd:examples} {it:function()} 


{title:Description}

{p 4 4 2}{cmd:examples} looks for help on {it:topicname} and displays any
Examples sections found in a Viewer window. Alternatively, {cmd:examples}
looks for help on {it:function()} (note the parentheses) and displays a
definition in a Viewer window. It is especially designed to show quick and
easy reminders of the syntax of a given command. 


{title:Remarks}

{p 4 4 2}Given a {it:topicname}, {cmd:examples} looks for sections starting
with titles specified in SMCL containing the word {cmd:Examples} (or
alternatively {cmd:Example}) within any help file corresponding to
{it:topicname}. It will not be able to show material from older, pre-SMCL help
files or examples given otherwise. 


{title:Examples}

{p 4 8}{inp:. examples regress}{p_end}
{p 4 8}{inp:. examples reg}

{p 4 8}{inp:. examples normden()} 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 4 2}Ken Higbee gave valuable help on aliases. Clive Nicholas pointed
towards a bug. Roger Harbord identified a bug and fixed it. Dick Campbell 
pointed out that {cmd:examples} (as was) was broken by Stata 10. 


{title:Also see}

{p 4 13 2}On-line:  help for {help help}; {help smcl}


