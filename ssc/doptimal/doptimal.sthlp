{smcl}
{* *! version 1.0 20 Aug 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "doptimal##syntax"}{...}
{viewerjumpto "Description" "doptimal##description"}{...}
{viewerjumpto "Options" "doptimal##options"}{...}
{viewerjumpto "Remarks" "doptimal##remarks"}{...}
{viewerjumpto "Examples" "doptimal##examples"}{...}
{title:Title}
{phang}
{bf:doptimal} {hline 2} To find the D-optimal Design for Dose Ranging studies

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:doptimal}
[{help varlist}]
[{help if}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt theta(numlist)}}  specifies the model parameters or the starting values for the optimization routine.

{pstd}
{p_end}
{synopt:{opt max:dose(#)}}  specifies the highest possible dose.

{pstd}
{p_end}
{synopt:{opt min:dose(#)}}  specifies the lowest possible dose.

{pstd}
{p_end}
{synopt:{opt m:odel(string)}}  specifies which model to assume, these can be selected from linear, quad, emax or log4.

{pstd}
{p_end}
{synopt:{opt usedata}}  specifies that the model parameters are estimated from the current dataset

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:doptimal} is a command that produces the D-optimal design within a dose ranging design. The command either
takes some data and estimates the model parameters or the user can specify the model parameter values. Then with the paramter estimates the command will find the number of design points or doses, usually including the minimum and maximum doses and then will find the weights or proportion of people who should be allocated to each dose.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt theta(numlist)}     specifies the model parameters or the starting values for the optimization routine.

{pstd}
{p_end}
{phang}
{opt max:dose(#)}     specifies the highest possible dose.

{pstd}
{p_end}
{phang}
{opt min:dose(#)}     specifies the lowest possible dose.

{pstd}
{p_end}
{phang}
{opt m:odel(string)}     specifies which model to assume, these can be selected from linear, quad, emax or log4.

{pstd}
{p_end}
{phang}
{opt usedata}     specifies that the model parameters are estimated from the current dataset

{pstd}
{p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
For the Emax model and assuming the model parameters are 1, 30 and 0.2, find the D-optimal design
by the following command

{pstd}
 {stata doptimal, theta(1 30 0.2) model(emax) mindose(0) maxdose(1.5)}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(design)}}  The design matrix {p_end}
{synopt:{cmd:r(theta)}}  The model parameters {p_end}

{pstd}

{pstd}


{title:Author}
{p}

Prof Adrian Mander, Cardiff University.

Email {browse "mailto:mandera@cardiff.ac.uk":mandera@cardiff.ac.uk}



{title:See Also}
Related commands:

{help crm} (if installed)   {stata ssc install crm} (to install this command)

{help mtpi} (if installed)  {stata ssc install mtpi} (to install this command)

{help pipe} (if installed)  {stata ssc install pipe} (to install this command)

