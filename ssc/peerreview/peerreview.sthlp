{smcl}
{* *! version 1.0.0  15apr2020}{...}
{viewerjumpto "Syntax" "peerreview##syntax"}{...}
{viewerjumpto "Description" "peerreview##description"}{...}
{viewerjumpto "Options" "peerreview##options"}{...}
{viewerjumpto "Examples" "peerreview##examples"}{...}
{title:Title}

{phang}
{bf:peerreview} {hline 2} Randomly assign papers to peers for review


{marker syntax}{...}
{title:Syntax}

{phang}Basic syntax{p_end}
{p 8 16 2}
{cmd:peerreview}
{cmd:,} 
{cmdab:r:eviewers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}
{cmdab:p:apers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}
[{opt clear}]


{phang}Full syntax{p_end}
{p 8 16 2}
{cmd:peerreview} {varname}
{cmd:,} 
{cmdab:p:apers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}
[{opth num:ber(newvar)}]


{synoptset 32 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:r:eviewers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}}expects number of reviewers; integer{p_end}
{synopt:{cmdab:p:apers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)}}expects number of papers to be read per reviewer; integer{p_end}
{synopt:{opt clear}}clears data in memory before execution{p_end}
{synopt:{opth num:ber(newvar)}}generates new variable with distinct number for each observation{p_end}
{synoptline}
{syntab:name_suboption}
{synopt:{opth n:ame(newvar)}}specifies name for new variable(s) to be generated{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:peerreview} randomly assigns papers to peers for review, based on the principle of assignment without replacement which
ensures that each paper is assigned an equal number of times. 

{pstd}
Assignment is carried out with two constraints: Reviewers cannot review their own paper and reviewers cannot read papers more than once.

{pstd}
There are two syntaxes. If no {it:varname} is given, {cmd:peerreview} will create a dataset from scratch for {it:n} 
reviewers and {it:p} papers to be read per reviewer, generating a reviewer variable with numbers 1 to {it:n}, and {it:p}
variables containing the papers assigned to the reviewers. 

{pstd}
If a {it:varname} is given, {cmd:peerreview} will take the values of {it:varname}
and randomly assign them {it:p} time(s). Alternatively, the {opt number} option may be specified. In this case, 
{cmd:peerreview} will not take the values of {it:varname}, but instead assigns a number from 1 to the number of observations 
and does the assignment based on these numbers. This can be useful when there are duplicate values in {it:varname}.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:reviewers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)} expects number of reviewers; integer

{phang}
{cmd:papers(}{it:#} [{cmd:,} {it:name_suboption}]{cmd:)} expects number of papers to be read per reviewer; integer

{phang}
{opt clear} clears data in memory before execution; must be specified if data in memory has changed

{phang}
{opth number(newvar)} generates new variable with distinct number from 1 to the number of observations and uses these values for assignment

{dlgtab:name_suboption}

{phang}
{opth name(newvar)} specifies name for new variable(s) to be generated
{break}The default for {opt reviewers} is {it:reviewer}
{break}The default for {opt papers} is {it:review#}, with {it:#} being 1 to {it:p} when {it:p} > 1


{marker examples}{...}
{title:Examples}

{pstd}Create dataset assigning 1 paper each to 3 reviewers{p_end}
{phang}{cmd:. set seed 1234}{p_end}
{phang}{cmd:. peerreview, reviewers(3) papers(1) clear}{p_end}

{pstd}Create dataset assigning 2 papers each to 3 reviewers with non-default variable names{p_end}
{phang}{cmd:. set seed 2020}{p_end}
{phang}{cmd:. peerreview, r(3, n(student)) p(2, n(peer)) clear}{p_end}

{pstd}Assign 2 papers to each student of variable {cmd:student}, using the values (names) of {cmd:student}{p_end}
{phang}{cmd:. input str14 student}{p_end}
{phang}{space 12}student{p_end}
{phang}{cmd:  1. "John Smith"}{p_end}
{phang}{cmd:  2. "James Black"}{p_end}
{phang}{cmd:  3. "Maria Garcia"}{p_end}
{phang}{cmd:  4. "Patricia Brown"}{p_end}
{phang}{cmd:  5. end}{p_end}
{phang}{cmd:. set seed 1122}{p_end}
{phang}{cmd:. peerreview student, p(2)}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Wouter Wakker, wouter.wakker@outlook.com
