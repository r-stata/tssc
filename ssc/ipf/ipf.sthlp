{smcl}
{* *! version 1.1 15May2009}{...}
{cmd:help ipf}
{hline}

{title:Title}

     {hi: Log-linear modelling using Iterative Proportional Fitting}

{title:Syntax}

{p 8 17 2}
{cmdab:ipf} [{varlist}] [{cmd:weight}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt fit:}({it:string})} specifies the log-linear model. {p_end}
{synopt:{opt constr}({it:string})} specifies initial values for the expected frequencies.{p_end}
{synopt:{opt confile}({it:filename})} specifies a *.dta file that contains initial values
for the expected counts.{p_end}
{synopt:{opt convars}({varlist})} specifies the variables specified in constraint file.{p_end}
{synopt:{opt save}({it:filename})} saves the expected frequencies and probabilities per cell.{p_end}
{synopt:{opt expect}} specifies that the expected frequencies are displayed.{p_end}
{synopt:{opt nolog}} specifies whether the log-likelihood is displayed at each iteration. {p_end}
{synoptline}
{p2colreset}{...}

{hi:fweights} are  allowed; see help {help weights}.

{title:Description}

{pstd}
The iterative proportional fitting (IPF) algorithm is a simple method to calculate
the expected counts of a hierarchical loglinear model. The algorithm's rate
of convergence is first order. The more commonly used Newton-Rahpson algorithm 
is second order, however, each iteration of the IPF algorithm is quicker because
Newton-Rahpson inverts matrices. This makes the IPF algorithm much
quicker for contingency tables with high dimensionality.

{pstd}
The IPF algorithm has the following steps

{pstd}
1) Initial estimates of the expected frequencies are given. The initial estimates
should have associations and interactions that are less complex than the model being
fitted. By default the initial frequencies are 1.

{pstd}
2) Successively adjust the estimates of the expected frequencies by scaling factors
so they match each marginal table.

{pstd}
3) The scaling continues until the loglikelihood converges.

{pstd}
The algorithm always converges to the correct expected frequencies even when 
the likelihood is poorly behaved, for example, when there are zero fitted counts.

{pstd}
The varlist defines the dimension of the continguency table that the Poisson likelihood is
calculated over. If the varlist is not
specified the variables in the fit() option define the dimensions of the continguency table.

{title:Latest Version}

{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{pstd}
{stata ssc install ipf, replace}.

{title:Options}

{dlgtab:Main}

{phang}
{opt fit(string)} specifies the loglinear model. It requires special syntax of
the form {hi:var1*var2+var3+var4} .The term {hi:var1*var2} includes all the interactions
between the two variables and also the main effects of {hi:var1} and {hi:var2}.
The main effects {hi:var3} and {hi:var4} are also included in the model but
no interactions. This syntax is used in most books on Loglinear modelling.

{phang}
{opt constr(string)} specifies initial values for the expected frequencies. The
syntax requires an if statement followed by a value for the expected
frequency. Hence [sex=="male"]2 replaces all initial values for males to
be 2.

{phang}
{opt confile(filename)}specifies a *.dta file that contains initial values
for the expected counts, the variable containing the frequencies must
be called Efreqold.
This option requires {hi:convars} also to specified.

{phang}
{opt save(filename)} specifies the expected frequencies and probabilities for every cell to be saved in a *.dta file.

{phang}
{opt convars(varlist)} specifies the variables in the file specified in {hi:confile()},
excluding Efreqold because this variable is always needed.

{phang}
{opt expect} specifies that the expected frequencies are displayed.

{phang}
{opt nolog} specifies whether the loglikelihood is displayed at each iteration.

{title: Examples}

{pstd}
For a 3-way continguency table containing the factors sex, age and treatment
the saturated model is given by

{pstd}
{space 2}{inp:.ipf, fit(sex*age*treatment)}

{pstd}
If the data was not individual records the command would require a variable
containing the frequency counts, {hi:freq} say.

{pstd}
{space 2}{inp:.ipf [fw=freq], fit(sex*age*treatment)}

{pstd}
Using a file for initial frequencies.

{pstd}
{space 2}{inp:.ipf [fw=freq], fit( sex+age) convars(sex age) confile(constrain) exp}

{title:Author}

{pstd}
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.{p_end}
{pstd}
Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

{title:Also see}

{pstd}
Related commands

{pstd}
HELP FILES {space 13}SSC installation links{space 4}Description

{pstd}
{help gipf} (if installed){space 5}({stata ssc install gipf}){space 8}Graphical representation of a log-linear model {p_end}
{pstd}
{help hapipf} (if installed){space 3}({stata ssc install hapipf}){space 6}Haplotype frequency estimation using log-linear models {p_end}



