{smcl}
{* *! version 1.1.1  14jan2015}{...}
{* findalias asfradohelp}{...}
{* vieweralsosee "" "--"}{...}
{* vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "holsti##syntax"}{...}
{viewerjumpto "Description" "holsti##description"}{...}
{viewerjumpto "Options" "holsti##options"}{...}
{viewerjumpto "Remarks" "holsti##remarks"}{...}
{viewerjumpto "Examples" "holsti##examples"}{...}
{viewerjumpto "Stored reults" "holsti##results"}{...}
{viewerjumpto "Authors" "holsti##author"}{...}
{viewerjumpto "References" "holsti##references"}{...}
{title:Title}

{phang}
{bf:holsti} {hline 2} Calculates the Holsti intercoder reliability coefficient.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:holsti:}
{it:varname} {ifin} [, {it:options}]

{p2colreset}{...}
{p 4 6 2}
{cmd:varname} defines either the variable, for which the Holsti coefficient is computed,
or two or more coders, for which intercoder reliability shall be calculated.{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gen:erate(var)}}define a variable containing the number of disagreements per case{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed; see {manhelp by D}.{p_end}
{p 4 6 2}
{cmd:fweight}s are not allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:holsti} calculates the intercoder reliability coefficient for different 
coders' ratings of one given variable or the intracoder reliability coefficient 
for one or more coders for one variable at different points in time. Variables 
can be either integer or string; however, mixing both types will not work.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt generate} defines a variable in which the number of disagreements for each 
analyzed case (given a certain variable or different coders) is stored (useful for 
diagnostic purposes). 


{marker remarks}{...}
{title:Remarks}

{pstd}
(1) Disagreements for diagnostic purposes are computed as follows: holsti 
retrieves the different codings that have been assigned to each case and computes 
their respective frequency. The prevailing coding for a given case is defined as 
"correct". Every occurence of a code different from the "correct" code is counted 
as a disagreement. In case there are equal frequencies for more than one code, 
holsti defines the first most occuring code as being "correct", the others as disagreeing.

{pstd}
(2) Please note that the dataset needs to have a certain structure in order for the 
Holsti-coefficient to be calculated properly. 

{pstd}
Each column in the dataset stands for one single coder and his or her ratings of 
one given category. The rows define units which are rated concerning the given category. 
If coders rate different categories, the coders' ratings of the different categories have 
to be placed in separate columns.

{pstd}Let c1, c2, c3 be different coders and stub1, stub2 different categories. The
corresponding dataset would be structured as follows:

        {c TLC}{hline 56}{c TRC}
        {c |}c1_stub1 c2_stub1 c3_stub1   c1_stub2 c2_stub2 c3_stub2 {c |}
        {c |}{hline 56}{c |}
        {c |}    1        1        1          a        a        a    {c |}
        {c |}    2        2        2          c        a        c    {c |}
        {c |}    1        1        1          a        b        a    {c |}
        {c |}    3        2        3          b        c        c    {c |}
        {c |}    2        2        1          b        b        b    {c |}
        {c BLC}{hline 56}{c BRC}


{marker examples}{...}
{title:Examples}

{phang}{cmd:. sysuse holstidata}{p_end}
{phang}{cmd:. holsti stub1}{p_end}
{phang}{cmd:. holsti stub1, gen(dev)}{p_end}
{phang}{cmd:. holsti c1_stub1 c3_stub1}{p_end}



{marker results}{...}
{title:Stored Results}

{pstd}
{cmd:holsti} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(holsti)}}computed overall Holsti-coefficient{p_end}
{synopt:{cmd:r(coder)}}number of coders{p_end}
{synopt:{cmd:r(units)}}number of units belonging to one variable (i.e. rownumber in the dataset) {p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(varcoder)}}name of the variable and/or the coders for which Holsti-coefficients were computed{p_end}
{synopt:{cmd:r(varnames)}}list of all variables/coders (i.e. columns in the dataset) that holsti selects using r(varcoder){p_end}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(pw_holsti)}}matrix containing pairwise Holsti-coefficients{p_end}
{synopt:{cmd:r(denominator)}}matrix containing the number of total codings for each pair of coders{p_end}
{synopt:{cmd:r(numerator)}}matrix containing the number of disagreeing codings for each pair of coders{p_end}
{p2colreset}{...}


{marker author}
{title:Authors}

{phang}Mona Krewel, Universitaet Mannheim, mona.krewel@mzes.uni-mannheim.de{p_end}
{phang}Julia Partheymueller, Mannheimer Zentrum fuer Europaeische Sozialforschung, julia.partheymueller@mzes.uni-mannheim.de{p_end}
{phang}Alexander Staudt, Universitaet Mannheim, astaudt@mail.uni-mannheim.de{p_end}


{marker references}{...}
{title:References}

{phang} Holsti, O. R. 1969. {it:Content Analysis for the Social Sciences and Humanities.} Reading, MA: Addison-Wesley.{p_end}
{phang} Lombard, M./Snyder-Duch, J./Bracken, C. C. 2002. Content Analysis in Mass Communication: Assessment and Reporting of Intercoder Reliability. {it:Human Communication Research} 28(4): 587-604.
